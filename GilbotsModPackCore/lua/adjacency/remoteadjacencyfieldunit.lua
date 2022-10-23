--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/remoteadjacencyfieldunit.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Definition of Seraphim tech that uses a field to
--#**              share resources between networked units.
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
function MakeRemoteAdjacencyFieldUnit(baseClassArg) 

local BaseClass = MakeRemoteAdjacencyUnit(baseClassArg)
local resultClass = Class(BaseClass) {

    --# This constant shared variable provides a convenient means 
    --# of testing any object to see if it uses this class.
    IsAdjacencyFieldUnit = true,

    --# We don't want pipelines and other 
    --# ones of these towers conneting to us
    IsNotRemoteAdjacencyReceiver=true,

    --# Remove these functions as we won't have effects.
    CreateAdjacentEffect  = function()
    end,
    CleanUpAdjacentEffectsWith = function()
    end,
    
    
    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
        
        --# Gilbot-X says: 
        --# This is for my Maintenance Consumption Breakdown Mod
        --# which keep tracks of which / how many types of resource 
        --# consuming abilities are currently active in the unit.
        self.EnabledResourceDrains = {
            Production = true,
        }
        
        --# Override this after calling base class of OnCreate
        self.CanConnectToLayers = { 
            Land=true, 
            Seabed=false, 
            Water=true,
            Sub=false, --# Cybran Harms?
        }
        
        --# Always have an internetwork object.
        self:EnsureUnitHasValidInterNetwork()
        self.OtherTowersToRefresh = {}
    end,

    
    
    --#*
    --#*  Gilbot-X says: 
    --#*  
    --#*  Called from OnCreate and when the unit gets switched back 
    --#*  on from the off position.
    --#*  
    --#**
    EnsureUnitHasValidInterNetwork = function(self)
        --# We'll make a new network for this unit
        --# and never lose it.
        self:EnsureUnitHasValidNetwork()
        self.MyNetwork.IsAdjacencyFieldUnitNetwork = true
        --# We'll make a new internetwork for this unit
        --# and never lose it.
        if (not self.MyNetwork.MyInterNetwork) or 
           self.MyNetwork.MyInterNetwork.IsBroken
        then
            self.MyNetwork.MyInterNetwork = ResourceInterNetwork(self.MyNetwork)
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
    FindAndCreateRemoteAdjacencyConnections = function(self)
        --# This next block is for debugging only.
        --# This can be delete wheh debugging is done.
        self:AdjacencyLog('Adjacency: FindAndCreateRemoteAdjacencyConnections called.')
    
        --# If ACU is not alive then don't allow any more adjacency.
        if not self:GetMyCommander() then return end
    
        --# This is needed when switching on
        self:EnsureUnitHasValidInterNetwork()
        self.MyNetwork.MyInterNetwork.SupressUpdate = true
        
        --# We are going to look at all possible connections 
        --# before we connect to anything.
        local PotentialConnections = {}
     
        --# This gets a list of units we can consider connecting to
        local structureTable =
            self:GetAIBrain():GetUnitsAroundPoint(
                categories.STRUCTURE, 
                self:GetPosition(), 
                self.RemoteAdjacencyAllowedSeparationDistance, 
                'Ally'
            ) or {}
            
        --# This next block is for debugging only.
        --# This can be delete wheh debugging is done.
        self:AdjacencyLog(
            'Field Unit ' .. self.DebugId 
        .. ' FindAndCreateRemoteAdjacencyConnections:' 
        .. ' Found ' .. repr(table.getsize(structureTable)) .. ' structures in my range.'
        )
            
        --# Start looking for potential connections
        for kNearbyUnit, vNearbyUnit in structureTable do
      
            --# Next we will check if there are any pipelines in range
            --# that we haven't already connected to.
            local separation = 
                self:CheckIfEligibleForRemoteAdjacency(vNearbyUnit)
            
            --# If this unit is eligible to connect remotely with us then
            if separation then
            
                --# Both units need to have a valid 
                --# ResourceNetwork object in order to do this.
                vNearbyUnit:EnsureUnitHasValidNetwork()
        
                --# First wait for any network reconstruction to finish
                --# before recording the network Id of the unit 
                --# we will potentially connect to.
                while vNearbyUnit.MyNetwork.IsStillBeingReconstructed do WaitTicks(2) end
                
                --# Now it's safe to query network ID. 
                local networkID = vNearbyUnit.MyNetwork.NetworkId
                if networkID and networkID > 0 then 
                    PotentialConnections[networkID] = {
                        Unit = vNearbyUnit,
                        Separation = separation,
                    }
                end
            end
	end
        
        for kNetworkId, vConnection in PotentialConnections do
            --# This will check if the units qualify for remote adjacency.
            --# If they qualify, they will also be given it.
            self:TryToGiveOrReceiveRemoteAdjacency(vConnection.Unit)
        end
        
        --# Don't suppress update anymore
        self.MyNetwork.MyInterNetwork.SupressUpdate = false
        self.MyNetwork.MyInterNetwork:PropogateBonusesThroughInterNetwork()
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
        
        --# Safety checks are grouped together in another function
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
            --# Other units need a network to be abke to join with us
            adjacentUnitArg:EnsureUnitHasValidNetwork()
            self:AddLinkToInterNetwork(adjacentUnitArg)
        end
        
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
        --# Always add new units to our internetwork object
        self.MyNetwork.MyInterNetwork:AddRemoteLinkToInterNetwork(
            adjacentUnitArg.MyNetwork
        )
        --# Put a link to us in this network object
        --# in a special table for passively receiving remote adacency 
        --# from an area of effect field
        table.insert(adjacentUnitArg.MyNetwork.WithinPassiveRemoteAdjacencyFieldOf, self)
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
        --# Contact the network to remove this link from network.
        self:RemoveFromEachOthersAdjacencyTables(adjacentUnitArg, 'Remote')
        --# Tell the network object it's not in our field
        adjacentUnitArg.MyNetwork:OnNetworkNotInField(adjacentUnitArg, self)
        --# If it hasn't destroyed itself and dropped us, 
        --# then tell our own inernetwork object we've dropped something from it
    	if self.MyNetwork.MyInterNetwork then
            self.MyNetwork.MyInterNetwork:OnRemoteLinksRemovedFromInterNetwork()
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called when the unit dies or loses 
    --#*  ability to maker remote connections.
    --#*
    --#** 
    CleanUpRemoteAdjacency = function(self)
        --# Do baseclass version first
        BaseClass.CleanUpRemoteAdjacency(self)
        
        --# Remove reference to dead Internetwork object
        self.MyNetwork.MyInterNetwork = nil
        self:SyncNetworkNumbersDisplay(true)
        
        --# Units we removed can still be in other fields
        for k, vTower in self.OtherTowersToRefresh do
            if vTower:IsAlive() then
                self:AdjacencyLog('Refreshing Tower=' .. vTower.DebugId)
                vTower:RefreshField()
            end
        end
        self.OtherTowersToRefresh = {}
    end,

    
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is paused, remote-links are disabled.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnRemoteAdjacencyPaused = function(self)
        --# Record state
        self.IsRemoteAdjacencyPaused = true
        --# These next two lines go together
        self:CleanUpRemoteAdjacency()
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
        
        if statType == 'AdjacencyExtensionDistance' then 

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
                self:CleanUpRemoteAdjacency() 
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
    --#*  This is called by neighbouring adjacencyfieldunit towers
    --#*  if they relaese a unit that they knw is also in this unit's range.
    --#*  The refresh makes sure it gets connected to this unit after its release.
    --#**
    RefreshField = function(self)
        --# If the unit is paused, there is nothing to turn off
        if self.IsRemoteAdjacencyPaused then return end
        --# Refresh is just look for more units in same range,
        --# don't worry about units leaving range.
        self:CleanUpRemoteAdjacency() 
        ForkThread(self.FindAndCreateRemoteAdjacencyConnections, self)
    end,
    
   
} --(end of class definition)

return resultClass

end