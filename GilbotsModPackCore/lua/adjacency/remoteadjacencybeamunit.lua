--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Definition of remote-link units using beams,
--#**              common to all factions except Seraphim.
--#** 
--#****************************************************************************


--# These are new files I created.
local GilbotUtils = 
    import('/mods/GilbotsModPackCore/lua/utils.lua')
local ResourceNetwork = 
    import('/mods/GilbotsModPackCore/lua/adjacency/resourcenetwork.lua').ResourceNetwork
local ResourceInterNetwork = 
    import('/mods/GilbotsModPackCore/lua/adjacency/resourceinternetwork.lua').ResourceInterNetwork
local MakeRemoteAdjacencyUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencyunit.lua').MakeRemoteAdjacencyUnit
    

--#*
--#*
--#*  Gilbot-X says:
--#*
--#*  This class is for the T2 version of pipeline 
--#*  and versions higher up the tech tree.
--#*  
--#*  These must be build within a certain distance of each other
--#*  but do not need to have touching skirts.  They cannot 
--#*  link directly to units, but the can join up smaller networks made of 
--#*  T1 pipelines.
--#*  
--#*  These form intelligent networks that only make enough connections
--#*  to form a closed network, and they re-link to different connections
--#*  if the loss of a link isolates any units from a network.
--#*
--#***

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeRemoteAdjacencyBeamUnit(baseClassArg) 

local BaseClass = MakeRemoteAdjacencyUnit(baseClassArg)
local resultClass = Class(BaseClass) {

    --# This constant shared variable provides a convenient means 
    --# of testing any object to see if it uses this class.
    IsRemoteAdjacencyBeamUnit = true,


    --#*
    --#*  Gilbot-X says: 
    --#*  
    --#*  Call this to examine all potential pipeline connections
    --#*  and then try to connect to the best.  Only connects to 
    --#*  pipelines in other networks and waits for other networks to 
    --#*  finish any reconstruction work.
    --#*
    --#*  I added this function to be called 
    --#*  from DoStatValueUpdateFunction for my adjacency range slider menu.
    --#**
    FindAndCreateRemoteAdjacencyConnections = function(self)

        --# If ACU is not alive then don't allow any more adjacency.
        local myCommander = self:GetMyCommander() 
        if not (myCommander and myCommander:IsAlive()) then return end
    
        --# Concurrency protection.
        while self.WaitForSwitchOffRemoteLinkGiving do WaitTicks(5) end
        --# All salve operations assumed complete.
        --# Now we can rejoin networks.
        self.DontRejoinInterNetwork = false
        
        --# This gets a list of units we can consider connecting to
        local tableOfRemoteLinks = 
            myCommander:ReceiveACURequest_GetRegisteredUnitsInCategory('RemoteAdjacencyBeamUnit')
        
        --# This next block is for debugging only.
        --# This can be delete wheh debugging is done.
        self:AdjacencyLog(
            'FindAndCreateRemoteAdjacencyConnections:' 
        .. ' Found ' .. repr(table.getsize(tableOfRemoteLinks))
        .. ' registered with ACU.'
        )
        
        --# We are going to look at all possible connections 
        --# before we connect to anything.
        local PotentialConnections = self:FilterPotentialConnectionsFromUnitTable(tableOfRemoteLinks)
     
        for kNetworkId, vConnection in PotentialConnections do
            --# This will check if the units qualify for remote adjacency.
            --# If they qualify, they will also be given it.
            if not self:CheckAgainIfNowOnOurInterNetwork(vConnection.Unit) then 
                self:TryToGiveOrReceiveRemoteAdjacency(vConnection.Unit)
            end
        end

    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*  
    --#*  Call this to examine all potential pipeline connections
    --#*  and then try to connect to the best.  Only connects to 
    --#*  pipelines in other networks and waits for other networks to 
    --#*  finish any reconstruction work.
    --#*
    --#*  I added this function to be called 
    --#*  from DoStatValueUpdateFunction for my adjacency range slider menu.
    --#**
    FilterPotentialConnectionsFromUnitTable = function(self, tableOfRemoteLinksArg)

        --# We are going to look at all possible connections 
        --# before we connect to anything.
        local PotentialConnections = {}
    
        --# Start looking for potential connections
        for kNearbyUnit, vNearbyUnit in tableOfRemoteLinksArg do
            if not vNearbyUnit:IsAlive() then 
                WARN('FilterPotentialConnectionsFromUnitTable: '
                  ..' Dead unit found: ' .. vNearbyUnit.DebugId
                )
            else
                --# Next we will check if there are any pipelines in range
                --# that we haven't already connected to.
                local separation = 
                    self:CheckIfEligibleForRemoteAdjacency(vNearbyUnit)
                
                --# If this unit is eligible to connect remotely with us then
                if separation then
                    --# Both units need to have a valid 
                    --# ResourceNetwork object in order to do this.
                    self:EnsureUnitHasValidNetwork()
                    vNearbyUnit:EnsureUnitHasValidNetwork()
            
                    --# First wait for any network reconstruction to finish
                    --# before recording the network Id of the unit 
                    --# we will potentially connect to.
                    while vNearbyUnit.MyNetwork.IsStillBeingReconstructed do
                        
                        WaitTicks(2)
                        
                        --# This next block is for debugging only.
                        --# This can be delete wheh debugging is done.
                        if self.DebugAdjacencyCode then
                          WARN('Adjacency: FindAndCreateRemoteAdjacencyConnections:' 
                              .. ' waiting for network ' .. repr(vNearbyUnit.MyNetwork.NetworkId)
                              ..  ' to be reconstructed..' 
                          )
                        end
                    end
                    
                    --# Now it's safe to query network ID. 
                    local networkID = vNearbyUnit.MyNetwork.NetworkId
                    
                    --# This safety was necessary because we 
                    --# were getting an error here about invalid table arguments
                    --# caused by the network id - this seems to happen after 
                    --# an ACU explosion (will possibly happen after a nuke).
                    if networkID and networkID > 0 then 
                    
                        --# Put all potential connections in a nested table grouped by network id.
                        if not PotentialConnections[networkID] then
                            
                            --# This next block is for debugging only.
                            --# This can be delete wheh debugging is done.
                            if false then
                              self:AdjacencyLog(
                                  'FindAndCreateRemoteAdjacencyConnections:' 
                              .. ' first potential connection for network=' .. repr(networkID)
                              .. ' is ' .. vNearbyUnit.DebugId
                              )
                            end
                            
                            PotentialConnections[networkID] = {
                                Unit = vNearbyUnit,
                                Separation = separation,
                            }
                        else
                            --# This next block is for debugging only.
                            --# This can be delete wheh debugging is done.
                            if false then
                              self:AdjacencyLog(
                                 'FindAndCreateRemoteAdjacencyConnections:' 
                              .. ' another potential connection for network=' .. repr(networkID)
                              .. ' is ' .. vNearbyUnit.DebugId
                              )
                            end
                            
                            --# Compare this potential connection and the previous
                            --# one.  The best one is kept.
                            PotentialConnections[networkID] = 
                                self:ChooseBetterConnection(
                                    PotentialConnections[networkID],
                                    {Unit = vNearbyUnit, 
                                     Separation = separation}
                                )                            
                        end
                    
                    else
                        --# This next block is for debugging only.
                        --# This can be delete wheh debugging is done.
                        if self.DebugAdjacencyCode then
                          WARN('Adjacency: FindAndCreateRemoteAdjacencyConnections: ' 
                              .. vNearbyUnit.DebugId .. ' has no network ID.'
                          )
                        end
                    end
                end
            end
	end
        
        return PotentialConnections
        
    end,
    
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*  
    --#*  Given two possible connections to the same network as arguments,
    --#*  it returns the pipeline that is a better way to connect to that network.
    --#*  If they are equally desireable connections then just return the first by default.
    --#*
    --#*  Both connection arguments must be a table with two string-key fields:
    --#*     { Unit = ??, Separation = ?? }
    --#*
    --#*  One of those arguments will be returned.
    --#*
    --#*  I added this function to be called from
    --#*  FindAndCreateRemoteAdjacencyConnections in this class, which is where 
    --#*  I extracted the code from.
    --#*  That function is always forked as a thread, and so this runs in that thread.
    --#*
    --#*  This function gets executed with higher frequency than its calling function.
    --#*  If new pipelines are built or networks are broken then it gets called again.
    --#*
    --#*  I moved this code into this function to make the code more readable.
    --#**
    ChooseBetterConnection = function(self, connectionArg1, connectionArg2)
      
        --# Check if they are different tech levels
        mytl = self:GetMyTechLevel()
        tl1 = connectionArg1.Unit:GetMyTechLevel()
        tl2 = connectionArg2.Unit:GetMyTechLevel()
        
        --# Prefer to link with pipeline of the same tech level
        --# or fewer tech levels away
        if math.abs(mytl - tl1) < math.abs(mytl - tl2) then return connectionArg1 end
        if math.abs(mytl - tl1) > math.abs(mytl - tl2) then return connectionArg2 end
        
        --# if both potential connections are the same number of tech levels away 
        --# (i.e. we are a T2 pipeline and we choose between T1 and T3 pipelines)
        --# then choose to connect to the higher tech level.
        if (mytl - tl1) > (mytl - tl2) then return connectionArg1 end
        if (mytl - tl1) < (mytl - tl2) then return connectionArg2 end
        
        --# Find out how far away they both are
        local d1 = connectionArg1.Separation
        local d2 = connectionArg2.Separation
        
        --# Choose the closest or the first if they are equal.
        if d1 < d2 then return connectionArg1 else return connectionArg2 end
        
    end,
    
    
    

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by AddExtendedAdjacencyToNearbyUnits
    --#*  defined above.  Each unit keeps a reference to the other.
    --#**
    OnRemotelyAdjacentTo = function(self, adjacentUnitArg)
        --# If ACU is not alive then don't allow any more adjacency.
        local myCommander = self:GetMyCommander() 
        if not (myCommander and myCommander:IsAlive()) then return end
        
        --# Safety checks are gropuped together in another function
        local canLink, tryLater = self:CanLinkWith(adjacentUnitArg) 
        --# Defer if a trylater received as it means
        --# units are currently compatible but there is
        --# a concurrency issue.
        while tryLater and type(tryLater) == 'number' do
            WaitSeconds(tryLater)
            WARN('OnRemotelyAdjacentTo: Retrying CanLinkWith from ' .. self.DebugId 
             .. ' to ' .. adjacentUnitArg.DebugId
             .. ' after waiting '  .. repr(tryLater) .. ' seconds.'
            )
            canLink, tryLater = self:CanLinkWith(adjacentUnitArg)
        end
        --# Abort if a definite no response received
        if not canLink then return end
        
        --# Call code that deals with resource networks and internetworks
        if myCommander.InterNetworkMappingEnabled then 
            self:AddLinkToInterNetwork(adjacentUnitArg)
        end
        
        --# Create link effect
        self:CreateLink(adjacentUnitArg)
        
        --# Make sure there are appropriate tables.       
        self:AddToEachOthersAdjacencyTables(adjacentUnitArg, 'Remote') 
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by OnRemotelyAdjacentTo.
    --#*  Deals with ResourceNetwork objects.
    --#**
    AddLinkToInterNetwork = function(self, adjacentUnitArg)
        
        --# For safety, although not sure this is necessary.
        self.MyNetwork.RemoveMeFromMyInterNetwork = false
        adjacentUnitArg.MyNetwork.RemoveMeFromMyInterNetwork = false
        
        --# Only create and associate with a brand new network supervsior
        --# if we haven't had one already or the last one was broken up and is invalid.
        local useMyInterNetwork = true
        --# First check if we have a valid internetwork.
        if (not self.MyNetwork.MyInterNetwork) or self.MyNetwork.MyInterNetwork.IsBroken then
            --# if the adjacent unit has a functioning internetwork
            if adjacentUnitArg.MyNetwork.MyInterNetwork and 
            (not adjacentUnitArg.MyNetwork.MyInterNetwork.IsBroken) then
            
                --# This next block is for debugging only.
                --# This can be delete wheh debugging is done.
                self:AdjacencyLog(
                    'AddLinkToInterNetwork:'
                .. ' Using internetwork object on ' .. adjacentUnitArg.DebugId
                )
             
                --# Add it to the adjacent unit's network because 
                --# has a valid one and we don't.
                adjacentUnitArg.MyNetwork.MyInterNetwork:AddRemoteLinkToInterNetwork(
                    self.MyNetwork
                )
                useMyInterNetwork = false
            else
                --# This next block is for debugging only.
                --# This can be delete wheh debugging is done.
                self:AdjacencyLog(
                    'AddLinkToInterNetwork:'
                .. ' Attaching new internetwork object to ' .. self.DebugId
                )
                
                --# We'll make a new internetwork for this unit
                --# because neither unit had a network.
                --# This is the only time/place we create
                --# a new internetwork.                 
                self.MyNetwork.MyInterNetwork = ResourceInterNetwork(self.MyNetwork)
            end
        end
        --# Add the link to this unit's (possibly new) network if we didn''t
        --# already add it to the other unit's network.
    	if useMyInterNetwork then 
        
            --# This next block is for debugging only.
            --# This can be delete wheh debugging is done.
            if self.DebugAdjacencyCode and not self.MyNetwork.MyInterNetwork then
              ERROR('Adjacency: AddLinkToInterNetwork:'
                  .. ' internetwork object missing on ' .. self.DebugId
              )
            end
            
            self.MyNetwork.MyInterNetwork:AddRemoteLinkToInterNetwork(
                adjacentUnitArg.MyNetwork
            ) 
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to mod this to make sure tables are cleaned up.
    --#*  Base class version cancels bonuses and cleans up effects.
    --#*  
    --#**
    OnNotRemotelyAdjacentTo = function(self, adjacentUnitArg)

        --# Safety checks are gropuped together in another function
        if not self:CanDisconnectFrom(adjacentUnitArg, 'Remote') then return end
        
        --# Always remove a linking beam effect regardless
        --# of whether or not bonus is applied:
        --# Remove any adjacency beam effects between this pair.
        --# Also removes references to each other from all connection tables,
        --# which stops this function from being called a second time on the same pair.
        self:CleanUpAdjacentEffectsWith(adjacentUnitArg)
        
        --# Both units will have same network object because they were attached
        local internetwork = self.MyNetwork.MyInterNetwork or adjacentUnitArg.MyNetwork.MyInterNetwork 
        --# Contact the network to remove this link from network.
        --# First check if we have the correct variables to make the call.
    	if internetwork then
            internetwork:OnRemoteLinksRemovedFromInterNetwork()
    	end
  
    end,
    
    

   
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is paused, remote-links are disabled.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnRemoteAdjacencyPaused = function(self, immediateBool)
        --# Record state
        self.IsRemoteAdjacencyPaused = true
        --# These next two lines go together
        if immediateBool then 
            self:CleanUpRemoteAdjacency()
        else
            ForkThread(self.SwitchOffRemoteLinkGiving, self)
            self.WaitForSwitchOffRemoteLinkGiving = true
        end
        --# These next two lines go together
        self.EnabledResourceDrains.Production = false
        self:UpdateConsumptionValues()
    end,
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is unpaused, remote-links are re-established.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnRemoteAdjacencyUnpaused = function(self)
        --# Record state
        self.IsRemoteAdjacencyPaused = false
        --# This thread will automatically wait until the other thread 
        --# running SwitchOffRemoteLinkGiving has marked that it has finished.
        ForkThread(self.FindAndCreateRemoteAdjacencyConnections, self)
        --# These next two lines go together
        self.EnabledResourceDrains.Production = true
        self:UpdateConsumptionValues()
    end,
    
    
     
     
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by the slider control.
    --#*  It must update whatever property, feature or variable that 
    --#*  the slider control declared in this unit's BP file was designed to adjust.
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        
        if statType == 'ShieldMaxHealth' then 
            --# Update shield strength.  No need to store value.
            self.MyShield:SetMaxHealthAndRegenRate(newStatValue)
        
        elseif statType == 'AdjacencyExtensionDistance' then 

            --# Rebuild remote adjacency connections.
            
            --# First we need to do make sure our internetwork is split, 
            --# and then salvaged into separate parts, otherwise
            --# we won't be able to reconnect to any of them that
            --# are in reach of the new range.
            
            --# If the unit is paused, there is nothing to turn off
            if not self.IsRemoteAdjacencyPaused then
                --# Fork a thread to iteratively break each remote link 
                --# so there can be a pause after/between each 
                --# remote connection removal.
                ForkThread(self.SwitchOffRemoteLinkGiving, self)
                self.WaitForSwitchOffRemoteLinkGiving = true
            end
            
            --# Record new value from slider menu
            self.RemoteAdjacencyAllowedSeparationDistance = newStatValue
            
            --# Update red circle effect that illustrates adjacency range
            local gun = self:GetWeapon(1)
            gun:ChangeMaxRadius(newStatValue)
            
            --# If the unit is paused, there is nothing to turn on
            if not self.IsRemoteAdjacencyPaused then
                --# This thread will automatically wait until the other thread 
                --# running SwitchOffRemoteLinkGiving has marked that it has finished.
                ForkThread(self.FindAndCreateRemoteAdjacencyConnections, self)
            end
        end
        
    end,
    
    
        
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from SwitchOffRemoteLinkGiving in this class.
    --#*  That function is always forked as a thread, and so this runs in that thread.
    --#*
    --#*  Unlike the calling function, this code gets executed 
    --#*  more than once: if networks are broken it gets called again.
    --#*
    --#*  Therefore this function separates the code into reusable sections
    --#*  and makes the code more readable.
    --#**
    CanStillReceiveRemoteLinkWith = function(self, nearbyUnitArg)
        --# Don't disconnect to a unit or network that we are already connected to.
        if not self:CheckIfAlreadyConnected(nearbyUnitArg, 'Remote') then
            return false
        end
        
        --# Check if other pipeline unit is paused.
        if nearbyUnitArg.IsRemoteAdjacencyPaused then 
            return false
        end 
        
        --# If these units are in each other's range then
        local separation = self:GetSeparationDistance(nearbyUnitArg)        
        if separation <= nearbyUnitArg.RemoteAdjacencyAllowedSeparationDistance then
            return true
        else
            return false
        end 
        
    end,
    
    
    
      
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by DoStatValueUpdateFunction for my 'Stat Slider' mod.
    --#*  I need to be able to remove all remote adjacency, which normally happens
    --#*  when one of the units dies.  Here I remove it without any death
    --#*  so we can re-apply it with a larger radius.
    --#*
    --#** 
    SwitchOffRemoteLinkGiving = function(self)
    
        --# For each unit we have to remove
        for kAdjacentUnit, vAdjacentUnit in self.AdjacentUnits['Remote'] do
            if not self:CanStillReceiveRemoteLinkWith(vAdjacentUnit) then
                --# Call OnNotAdjacentTo in only one direction 
                --# to break the link.  Each call will cause a network split.
                self:OnNotRemotelyAdjacentTo(vAdjacentUnit)
                --# Wait before proceeding so the internetwork's split operation can complete.
                local waitMore = true
                while waitMore do 
                    --# Waiting for network split/salvage operation to complete
                    WaitTicks(5)
                    --# Check if its finished (valid network that is not being reconstructed)
                    if vAdjacentUnit.MyNetwork and not vAdjacentUnit.MyNetwork.IsBroken then
                        waitMore = vAdjacentUnit.MyNetwork.IsStillBeingReconstructed
                    end
                end
            end
        end
        
        --# Allow calling thread to continue
        self.WaitForSwitchOffRemoteLinkGiving = false
    end,
     
   
} --(end of class definition)

return resultClass

end