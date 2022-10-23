--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/adjacency/resourcenetwork.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Network management system for adjacency links in a network
--#*            connected by 1 or more pipeline nodes.
--#*
--#*****************************************************************************
local GilbotUtils = 
    import('/mods/GilbotsModPackCore/lua/utils.lua')
local AdjacencyBonusTypes = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencybonustypes.lua').AdjacencyBonusTypes
local ApplyBonusCap = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencybonustypes.lua').ApplyBonusCap


ResourceNetwork = Class
{
    --# This constant shared variable provides a convenient means 
    --# of testing any object to see if it uses this class.
    IsResourceNetwork = true,
    --# Toggle on/off detailed logging
    DebugAdjacencyCode = false,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  For debugging only.
    --#** 
    AdjacencyLog = function(self, messageArg)
        if self.DebugAdjacencyCode then
            --# Perform safety
            if type(self.ArmyIdString) ~= 'string' or type(messageArg) ~= 'string' 
            then WARN('Bad call to Adjacency log.')
            else LOG('Adjacency: a=' .. self.ArmyIdString .. ' ' .. messageArg)
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called in function OnAdjacentTo in the 
    --#*  AdjacencyStructureUnit class.  All units from that class
    --#*  must have a reference to an object of this class once
    --#*  they become adjacent and connected to another unit in
    --#*  forming part of a network.  This class stores and manages
    --#*  all the necessary information about that network,
    --#*  including which units have joined it, and a record of
    --#*  which ones can give and receive each type of bonus.
    --#*  Functions of this class are called to calculate what
    --#*  bonuses should be spread arouind the network, and to
    --#*  switch on/off the distribution of those bonuses.
    --#*  Units that can join networks just have to call code
    --#*  in this class that either adds or removes them from the 
    --#*  network.
    --#**
    __init = function(self, firstNode, optionalArg)
        
        --# Default value before node assigned
        self.ArmyIdString = '?'
        
        --# Initialise data structures        
        self:ClearNetworkTables()
        self:InitialiseBonusTables()
        
        --# Initially this network is not connected 
        --# to any others by remote link.  
        self.MyInterNetwork = nil
        
        --# Safety: firstNode is not always supplied.
        if firstNode then self:AddUnitToNetwork(firstNode)
        else
            if optionalArg == 'SpawningFromBroken' then
                self.IsStillBeingReconstructed = true
            else
                WARN('ResourceNetwork: __init: Object was created with ' 
                      .. 'no initial node in constructor.')
            end
        end
    end,
    
   
  
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only called by the constructor to initialise 
    --#*  and in the Destroy function to 
    --#*  make the network object safe (unusable because it contains no units).
    --#**
    ClearNetworkTables = function(self)
    
        --# Use this to keep a list of linking nodes in the network
        self.AttachedNodesTable = {} 
        self.AttachedRemoteLinksTable = {} 
        self.WithinPassiveRemoteAdjacencyFieldOf = {} 
        
        --# Use this to keep a list of units that give the adjacency bonuses
        --# (powergens, mex, massfabs, energy storage, mass storage, etc.)
        self.AdjacencyGiversTable = {} 
        
        --# Use this to keep a list of units that use the adjacency bonuses
        --# (factories, shields, arty, radar, etc.)
        self.AdjacencyUsersTable = {} 
  
    end,
        
        
        
        
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only called by the constructor to initialise, and
    --#*  by LockAndStripBonusesFromAllUnits and BreakNetworkWhenACUDies
    --#*  to make sure that no more bonuses are propogated 
    --#*  on a broken network that is being dismantled,
    --#*  while units are being taken out of the network
    --#*  and an attempt is made to create new subnetworks with them.
    --#**
    InitialiseBonusTables = function(self)
        --# Initialise tables
        for bonusTypeIndex, bonusTypeName in AdjacencyBonusTypes do
            self.AdjacencyGiversTable[bonusTypeName] = {}
            self.AdjacencyUsersTable[bonusTypeName] = {}
        end
    end,
 
 
 
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  by ResourceInterNetwork objects so that when they
    --#*  give this unit a reference to themselves,
    --#*  the network can update the labels on all its units 
    --#*  if the network ID display is toggled on.
    --#**
    SetInterNetwork = function(self, interNetworkArg)
        --# Store the network reference set
        self.MyInterNetwork = interNetworkArg
        
        --# If that network was already displaying its ID 
        --# on its units, then request an update for it.
        self:SyncAllNetworkNumbersDisplay() 
        
    end,
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  by ResourceInterNetwork objects when they
    --#*  are destroyed, so that this network removes its reference,
    --#*  and can update the labels on all its units 
    --#*  if the network ID display is toggled on.
    --#*  It also recalculates the reduced bonuses.
    --#*  Hopefully this happens in one tick
    --#*  so concurrency isn't an issue.
    --#**
    ClearInterNetwork = function(self)
        --# Store the network reference set
        self.MyInterNetwork = nil
        if not self.IsBroken then 
            --# Tell the network to refresh its bonuses
            --# without its internet object.
            self:PropogateBonusesThroughThisNetworkOnly()
            --# If that network was already displaying its ID 
            --# on its units, then request an update for it.
            self:SyncAllNetworkNumbersDisplay() 
        end
    end,
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  Safety and garbage collection.
    --#**
    Destroy = function(self)
        --# Make safe and to be deleted
        --# by removing reference to anything usable
        self.IsBroken = true
        self.ArmyIdString = '?'
        
        --# Remove upward references and make sure nobody is referencing us
        if self.MyInterNetwork then 
            self.MyInterNetwork:OnRemoteLinksRemovedFromInterNetwork() 
            self.MyInterNetwork = nil
        end
        
        --# Remove this network from any field source
        for k, vFieldSource in self.WithinPassiveRemoteAdjacencyFieldOf do
            --# Remove this from any field source.
            --# We won't rejoin during refresh, as we are marked broken.
            vFieldSource:RefreshField()
        end
        --# Clear out that table as it won't be used again
        self.WithinPassiveRemoteAdjacencyFieldOf={}
        
        --# Clear all our network tables now as this 
        --# network object will never be used again.
        self:ClearNetworkTables()
        --# Delete our unique id number
        --# so we won't be used
        self.NetworkId = nil
        --# Mark that ACU can recycle 
        --# our unique network ID number
        self.IsSafeToRecycle = true
    end,
 
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only called by AddUnitToNetwork to initialise 
    --#*  network properties that require the first unit to be added 
    --#*  to the network.  The first unit gives us a reference to the
    --#*  army ID and thus we can contact the ACU if it is alive.
    --#**
    SetFirstNode = function(self, nodeArg)
        --# Keep a reference to the army so we can check for capturing
        self.MyArmyId = nodeArg:GetArmy()
        
        --# This next 'if' line is for safety
        if type(self.MyArmyId) ~= "table" then
            self.ArmyIdString = repr(self.MyArmyId)
        end
        
        --# The supervisor's first node is always a pipeline node
        --# because this is how the class is created.
        self.FirstNode = nodeArg
         
        --# ACU can keep track of networks while alive
        self.MyCommander = nodeArg:GetMyCommander()
        --# If commander is alive...
        if self.MyCommander then
            --# Put a reference to us in the ACU's table
            self.MyCommander:ReceiveACUMessage_AddNewNetwork(self)
        end
    end,
 
 
 
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only for debugging.
    --#**
    TellACU_DumpAllActiveNetworks = function(self)

        --# If commander is alive...
        if self.MyCommander and self.MyCommander:IsAlive() then
            self.MyCommander:ReceiveACUMessage_DumpActiveNetworks()
        else
            --# Prevent any more checks to see if ACU is dead
            --# because we know it is already
            self.MyCommander = nil
        end
    end,
    
    
     --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only called by AdjacencyStructureUnit nodes 
    --#*  when their OnAdjacentTo function is called, i.e. when
    --#*  two units are being connected to each other.
    --#*
    --#*  The creation of adjacency beam effects are 
    --#*  taken care of by the AdjacencyStructureUnit class.
    --#*  In this class, we just have to add appropriate references to the 
    --#*  two structures to a network.  There could be other units attached to 
    --#*  either of the two units being connected here, so we actually 
    --#*  merge one network into another if they are both already part of one.
    --#**
    PropogateBonusesAfterAddingNewUnit = function(self)
        if not self.PropogateBonusesThreadWaiting then
            self.PropogateBonusesThreadWaiting = ForkThread(
                function(self)
                    --# This delay allows extended adjacency units
                    --# to finish updating their tables
                    --# before we try to calulate net bonuses. 
                    --# if we don't wait then bonuses are halved
                    --# as entries are not found in local adjacency tables.                    
                    WaitTicks(1)
                    self:PropogateBonuses() 
                end, self
            )
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only called by AdjacencyStructureUnit nodes 
    --#*  when their OnAdjacentTo function is called, i.e. when
    --#*  two units are being connected to each other.
    --#*
    --#*  The creation of adjacency beam effects are 
    --#*  taken care of by the AdjacencyStructureUnit class.
    --#*  In this class, we just have to add appropriate references to the 
    --#*  two structures to a network.  There could be other units attached to 
    --#*  either of the two units being connected here, so we actually 
    --#*  merge one network into another if they are both already part of one.
    --#**
    AddLinkToNetwork = function(self, unitAlreadyInNetworkArg, unitArg2)
        
        --# The first unit must have a network to be running this function.
        --# If the other unit has no valid network,
        if (not unitArg2.MyNetwork) or unitArg2.MyNetwork.IsBroken then
            --# The other unit has just been built and has no 
            --# network supervisor yet, so it now will associate with ours.
            --# No need to merge.
            self:AddUnitToNetwork(unitArg2)
            self:PropogateBonusesAfterAddingNewUnit()
            
            
        --# They both have networks, so if they are not already the same 
        --# network we'll have to merge them both.
        elseif self ~= unitArg2.MyNetwork then
            --# Prepare to merge the two networks.
            --# Now merge the smaller of the two networks into the larger.
            --# Bonuses will automatically be switched on after the merge.
            --# Check who has most units before deciding who merges into who.
            local unitsAlreadyInMyNetwork = 
                table.getsize(self.AttachedNodesTable)
            
            local unitsAlreadyInOtherNetwork =  
                table.getsize(unitArg2.MyNetwork.AttachedNodesTable)
                
            --# If this network has more units..
            if unitsAlreadyInMyNetwork > unitsAlreadyInOtherNetwork
            then
                --# merge the other network into me
                self:MergeNetworks(unitArg2.MyNetwork)
            else
                --# we merge into them
                unitArg2.MyNetwork:MergeNetworks(self)
            end
            
        end
        --# Otherwise if they have the same supervisor it means there 
        --# is a loop in the network.  Loops happen with t1 pipelines 
        --# and are not a problem.
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This can be called by AdjacencyStructureUnit nodes when their 
    --#*  OnNotAdjacentTo function is called.  This function then decides 
    --#*  if they can just drop either of the two units from the network, 
    --#*  or if the entire network needs to be broken up.
    --#* 
    --#*  Adjacency beam effects are taken care of by the AdjacencyStructureUnit
    --#*  class. We just have to remove all bonuses and references to these units 
    --#*  from the network.
    --#*  
    --#*  If there is no need to break up this networkinto two or more subnetworks,
    --#*  then the units remaining in the network get recalculated bonuses.
    --#*  If the network does get broken up into subnetworks, these subnetworks 
    --#*  will get their own new ResourceNetwork object with its own set of 
    --#*  recalculated adjacency bonuses.
    --#**
    OnLinkRemovedFromNetwork = function(self)
      
        --# The network may have been broken on a previous call to this function
        --# but we allow subsequent calls to get this far anyway as it stops other 
        --# units in the network that died just a tick or so afterwards 
        --# from being added to newly spawned networks.
        if self.IsBroken then return end
        
        --# What happens next depends in what is left in the network.
        --# Units may have been removed so bonuses must be assumed to be 
        --# out-of-date.  All paths out of this function must call PropogateBonuses.
        local unitsLeftInNetwork =  
            table.getsize(self.AttachedNodesTable)
          
        --# If we just removed a bridging node 
        --# (one that links two other nodes together indirectly)
        if unitsLeftInNetwork > 1 then
            --# A bridge node is being removed.  We need to reconstruct the network.
            --# All terminals that it connected to the network must now be removed from it
            --# Launch salvage thread if it wasn't already launched.
            --# It can only ever be launched once.
            self.IsBroken = true
            if not self.SalavageThread then
                --# Now strip all existing bonses 
                --# that this network gave previously.
                self:LockAndStripBonusesFromAllUnits()
                --# Create a single salvage operation.
                self.SalavageThread = ForkThread(self.SalvageSubNetworksFromBrokenNetwork, self)
            end
        elseif unitsLeftInNetwork == 1 then 
            --# If we are the last unit in the network then
            --# we don't need a network object.
            --# and leave the unit on its own
            self.AttachedNodesTable[1]:ClearNetwork()
            self:Destroy()            
        else
            --# All units dropped from this network.
            --# That means no more units have a reference that 
            --# points to this network.  Mark the network as
            --# broken to ensure it will never be used again.
            --# Any garbage collection should also be done here.
            self:Destroy()
        end
    end,
    
    
    
      
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by the ACU when it dies.
    --#*  We inspect the list of remaining units in the network and 
    --#*  try to break all links, remove bonuses, and destroy pipelines.
    --#**
    BreakNetworkWhenACUDies = function(self) 
        --# This will stop any of the units in this broken network 
        --# from getting any new bonuses set on them.
        self:InitialiseBonusTables()

        --# For safety's sake remove all bonuses from member units first
        for arrayIndex, vUnitInNetwork in self.AttachedNodesTable do
            --# No need to lock units.
            --# ACU is dead so no new links can form.
            vUnitInNetwork:StripBonuses()
            vUnitInNetwork:ClearNetwork()
        end
        
        --# Use the list of pipeline nodes still in the broken network
        --# as a starting point to try rebuild new subnetworks.
        for arrayIndex, vUnitInNetwork in self.AttachedNodesTable do
            if vUnitInNetwork:IsAlive() then
                --# Destroy all pipelines
                if vUnitInNetwork.IsPipeLineUnit then 
                    --# This pipeline will automatically 
                    --# disconnect from everything when it dies
                    vUnitInNetwork:Kill()
                else
                    --# Iterate through all units this node is still connected to
                    for k, vConnectedUnit in vUnitInNetwork.AdjacentUnits['Local'] do
                        --# if it isn't a dead/recalaimed/captured pipeline
                        if vConnectedUnit:IsAlive() then  
                            --# Remove direct link
                            vUnitInNetwork:CleanUpAdjacentEffectsWith(vConnectedUnit)
                        end
                    end
                end
            end
        end
        
        --# Clear all our network tables now as this 
        --# network object will never be used again.
        self:Destroy()
    end, 
           
        
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is forked as a thread from OnLinkRemovedFromNetwork defined above.
    --#*  We inspect the list of remaining units in the old network and 
    --#*  try to break it down into subnetworks that can have their own bonuses.
    --#**
    SalvageSubNetworksFromBrokenNetwork = function(self) 
        --# Allow time for chain reactions to finish.
        --# These can wipe out entire networks in less than a second.
        --# Bigger explosions from nukes will take longer than a second
        --# and these may cause problems.
        WaitSeconds(2)
        --# By this point, all nodes in this network now have a reference
        --# that points to a broken network.  This network can no longer 
        --# give bonuses.  Units can no longer be added to it.
        --# The nodes that were in it now need to be reassigned.
        self:RemoveDeadUnitsFromNetwork()
        self:AdjacencyLog('SalvageSubNetworksFromBrokenNetwork: '
          .. ' Called on N=' .. repr(self.NetworkId)
          .. ' and will now salvage from network containing ' 
          .. repr(table.getsize(self.AttachedNodesTable)) .. ' unit references.'
        )
        --# Only allow networks to be rebuilt if the
        --# army's ACU is still alive.
        if not GilbotUtils.GetCommanderFromArmyId(self.MyArmyId) then 
            self:UnlockAllUnits()
            return 
        end
        
        local subNetworks = {}
        --# Use the list of pipeline nodes still in the broken network
        --# as a starting point to try rebuild new subnetworks.
        for arrayIndex, vUnit in self.AttachedNodesTable do
            if vUnit and vUnit:IsAlive() and 
              --# Don't make a new network for a unit not attached to anything
              (table.getn(vUnit.AdjacentUnits['Local']) +
               table.getn(vUnit.AdjacentUnits['Remote'])) > 0
              and not GilbotUtils.IsValueIn2DTable(subNetworks, vUnit) then
                --# Create a new subnetwork starting from this unit
                local newSubNetwork = {}
                table.insert(newSubNetwork, vUnit)
                newSubNetwork = self:FindSubNetwork(vUnit, newSubNetwork)
                table.insert(subNetworks, newSubNetwork)
            end
        end
        
        --# Normally we can assume no redundant nodes exist
        --# because of the pathing algorithm I use to map networks.
        local redundantNode = nil
        if self.DebugAdjacencyCode then
            redundantNode = GilbotUtils.FindRedundantEntryIn2DTable(subNetworks)
        end
        --# Spawn the subnetworks we found if no redundancies exist in them
        if redundantNode then
            WARN('SalvageSubNetworksFromBrokenNetwork:'
              .. ' first redundantNode is ' .. redundantNode.GetUnitId() 
              .. ' e=' .. redundantNode.GetEntityId()
            )
        else
            self:SpawnNewNetworks(subNetworks)
        end
        
        --# Remove concurrency lock on all units that were 
        --# in old network we were breaking
        self:UnlockAllUnits()
        --# Clear all our network tables now as this 
        --# network object will never be used again.
        self:Destroy()
    end, 
                    
    

  
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called from OnLinkRemovedFromNetwork just before
    --#*  SalvageSubNetworksFromBrokenNetwork is called.
    --#*  We inspect the list of remaining units in the old network and 
    --#*  turn off all their bonuses (pipeline units are ignored).
    --#*  A flag is marked that delays these units from being
    --#*  added in an OnAdjacentToCall until UnlockAllUnits is called.
    --#**
    LockAndStripBonusesFromAllUnits = function(self)
    
        --# We get rid of any reference to a ResourceInterNetwork object here.
        --# That object will lose its reference to us when any remote links
        --# we contain calls its OnRemoteAdjacencyPaused function.        
        if self.MyInterNetwork then self:ClearInterNetwork() end
        
        --# This will stop any of the units in this broken network 
        --# from getting any new bonuses set on them.
        self:InitialiseBonusTables()
        --# Now strip all existing bonses that this network gave previously.
        for arrayIndex, vUnit in self.AttachedNodesTable do
            --# For each type of bonus available
            vUnit.WaitingToBeReassignedNewNetwork = true
            --# If this is a remote-link pipeline
            if vUnit.IsRemoteAdjacencyUnit then
                --# Pause the unit's adjacency and don't let 
                --# player unpause it till we are done
                vUnit:RemoveToggleCap('RULEUTC_ProductionToggle')
                if (not vUnit.IsRemoteAdjacencyPaused) then 
                    --# This might break up a ResourceInterNetwork.
                    --# Record state (so we can't give connections)
                    vUnit.IsRemoteAdjacencyPaused = true
                    --# Force all remote links to be switched off
                    --# whether they are active or passive
                    vUnit:CleanUpRemoteAdjacency()
                    --# These next two lines go together
                    vUnit.EnabledResourceDrains.Production = false
                    vUnit:UpdateConsumptionValues()
                end
            end   
            --# Remove bonuses from this unit if it's 
            --# not a pipeline unit and it's still alive
            vUnit:ClearNetwork()
        end
    end,  
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This must be called after LockAndStripBonusesFromAllUnits
    --#*  Otherwise we wull not be able to expand the newly built networks.
    --#*  We inspect the list of remaining units in the old network and 
    --#*  remove concurrency locks that delay attempts to form direct links.
    --#**
    UnlockAllUnits = function(self)
        --# Update unit status (potentially can avoid concurrency issues)
        for arrayIndex, vUnit in self.AttachedNodesTable do
            vUnit.WaitingToBeReassignedNewNetwork = false
            vUnit.UpgradedAdjacencyStructureUnit_JustCreated = false
            --# We switched off remote adjacency units earlier
            if vUnit.IsRemoteAdjacencyUnit then
                --# if it was switched on
                if not vUnit:GetScriptBit('RULEUTC_ProductionToggle') then
                    --# Switch it back on.  This might join us
                    --# to a ResourceInterNetwork.
                    vUnit:OnRemoteAdjacencyUnpaused()
                end
                --# Give player the switch back
                vUnit:AddToggleCap('RULEUTC_ProductionToggle')
            end
        end
    end,  
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by SalvageSubNetworksFromBrokenNetwork defined above.
    --#*  We inspect the broken network to try to find and create
    --#*  subnetworks.  Each AdjacencyStructureUnit in the network has a list 
    --#*  it maintains of which other units it is directly connected to.
    --#*  We recursively search through these lists to expand new subnetworks
    --#*  until no more units can be added to them.
    --#**
    FindSubNetwork = function(self, linkUnitArg, newSubNetwork)
        
        --# Iterate through all units this node is still connected to
        for k, vUnit in linkUnitArg.AdjacentUnits['Local'] do

            --# if it isn't a dead/recalaimed/captured pipeline
            if vUnit:IsAlive() 
              --# check for captured terminal
              and vUnit:GetArmy() == self.MyArmyId
              --# check it's not in a subnetwork already.
              --# it shouldn't be in a different subnetwork!!              
              and not GilbotUtils.IsValueInTable(newSubNetwork, vUnit) then
                --# this can go in our subnetwork.
                table.insert(newSubNetwork, vUnit)
                --# If it's a pipeline node, then try to add whatever 
                --# is connected to it in the same way with this recursive call.
                newSubNetwork = self:FindSubNetwork(vUnit, newSubNetwork)
            end
        end
        
        --# return result
        return newSubNetwork
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This function is called by the function SalvageSubNetworksFromBrokenNetwork 
    --#*  defined above.  It takes a table where each entry is a list of unit nodes
    --#*  that will form a subnetwork, and it attaches them to a new network manager
    --#*  and gets the new bonuses recalculated and switched on.
    --#**
    SpawnNewNetworks = function(self, newSubNetworks)
    	
        --# Only allow networks to be rebuilt if the
        --# army's ACU is still alive.
        if not GilbotUtils.GetCommanderFromArmyId(self.MyArmyId) then return end
        
        --# For each subnetwork we found...
        for k1, nodeList in newSubNetworks do
  
            --# Create a new network.
            local ntwrkSupervisor = ResourceNetwork(nil, 'SpawningFromBroken')
            
            --# Keep a reference to the army so we can check for capturing
            ntwrkSupervisor.Army = nodeList[1]:GetArmy()
            
            --# Attach all its units
            for k2, vUnit in nodeList do
                ntwrkSupervisor:AddUnitToNetwork(vUnit)
            end
            
            --# Try to set the network going
            ntwrkSupervisor.IsStillBeingReconstructed = false
            ntwrkSupervisor:PropogateBonuses()
    	end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This function is called by the function AddLinkToNetwork defined above. 
    --#* 
    --#*  It is called to merge another network into this one.  
    --#*  The calling code should ensure that the smaller network gets 
    --#*  chosen to be mergeged into the larger one. After the merge, 
    --#*  this ResourceNetwork object takes over the management of all 
    --#*  the units from both networks, and the smaller network is destroyed.
    --#**
    MergeNetworks = function(self, smallerNetwork)
        
        --# Warn any pipelines that they need to wait before 
        --# connecting to these networks        
        self.IsStillBeingReconstructed = true
        smallerNetwork.IsBroken = true
        
        --# Merge bonus givers/users tables first
    	for bonusTypeIndex, bonusTypeName in AdjacencyBonusTypes do
            
            --# Merge the bonus givers lists from the other 
            --# network supervisor into the list for this one.
            self:MergeUnitsIntoMyTable(self.AdjacencyGiversTable[bonusTypeName], 
                smallerNetwork.AdjacencyGiversTable[bonusTypeName])
            
            --# Merge the bonus consumers lists from the other 
            --# network supervisor into the list for this one.
            self:MergeUnitsIntoMyTable(self.AdjacencyUsersTable[bonusTypeName], 
                smallerNetwork.AdjacencyUsersTable[bonusTypeName])    	
        end
        
    	--# Merge the node list from the smaller network into ours.
    	self:MergeUnitsIntoMyTable(
            self.AttachedNodesTable, 
            smallerNetwork.AttachedNodesTable
        )
              
        --# Propogate bonuses throughout this network.
        smallerNetwork:Destroy()
        self.IsStillBeingReconstructed = false
        self:PropogateBonusesAfterAddingNewUnit()
    end,
	


    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This function is called by the function MergeNetworks defined above. 
    --#*
    --#*  It merges tables that conatin references to units in each network. 
    --#*  It merges table2 into table1 and updates all units changing network
    --#*  so that they have a reference to the network they just merged into
    --#*  (instead of the old network they just came from which will be destroyed next).
    --#**
    MergeUnitsIntoMyTable = function(self, table1, table2)
    	--# Nothing to do as table 2 is empty
        if table.getn(table2) == 0 then
            return
    	end
        --# Table 1 is empty so copy
        --# table 2 into table 1
    	if table.getn(table1) == 0 then
            for k, vUnit in table2 do
                table.insert(table1, vUnit)
            end
            return
    	end
  	--# Have to do a merge.
        --# Iterate through the values to merge.
    	for k1, vUnitInTable2 in table2 do
        
            local foundInTable1 = false
            --# Iterate through the values to merge into
            --# to see if it's in both tables
            for k2, vUnitInTable1 in table1 do
                if vUnitInTable1 == vUnitInTable2 then
                    foundInTable1 = true
                end
            end
            --# Do the merge if the unit wasn't alredy in both tables
            if not foundInTable1 then
                --# Doing merge.
                --# First give them a reference to their new network
                vUnitInTable2:SetNetwork(self)
                --# Give their new network a reference to them
                table.insert(table1, vUnitInTable2)	
            end
    	end    	
    end,
    
 
	
        
 
    
    
    
    
    --#***************************
    --#*
    --#*  Helpers
    --#*  
    --#***********************************************
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Call for debugging only.
    --#**
    RemoveDeadUnitsFromNetwork = function(self)
        --# Dump link units
        for k, vUnit in self.AttachedNodesTable do
            if not vUnit:IsAlive() then
                --# Clean up dead unit from table
                self:RemoveUnitFromNetwork(vUnit)
            end
        end
    end,     
    
    

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Called by ACU to toggle display numbers on units
    --#*  so user can see which units belong to which network.
    --#**
    SyncAllNetworkNumbersDisplay = function(self)
        --# Dump link units
        for k, vUnit in self.AttachedNodesTable do
            --# Check if any clean-up needed
            if not vUnit:IsAlive() then
                --# Clean up dead unit from table
                self:RemoveUnitFromNetwork(vUnit)
                self:AdjacencyLog('Cleaned up dead unit in SyncAllNetworkNumbersDisplay')
                    
            --# Show or hide label
            elseif not vUnit.IsPipeLineUnit then
                vUnit:SyncNetworkNumbersDisplay()
            end
        end
    end,   

 
    
    --#***************************
    --#*
    --#*  Adding and Removing from Network
    --#*  
    --#***********************************************
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Add the unit to this network by giving it a reference 
    --#*  to this network, and setting references in this network to the unit 
    --#*  as a link and possibly a bonus giver or receiver.
    --#**
    AddUnitToNetwork = function(self, unitArg)
        --# Perform last bit of network initialisation 
        --# if this is the first node added to the network. 
        if not self.FirstNode then 
            self:SetFirstNode(unitArg)
        end
        
        --# The added pipeline node needs a reference to its new network 
        unitArg:SetNetwork(self)
        
        --# The supervisor keeps a reference to this non-pipeline node
        --# just for accounting purposes.
        table.insert(self.AttachedNodesTable, unitArg)       
        
        --# If this is a remote-link pipeline
        if unitArg.IsRemoteAdjacencyUnit then
            --# add it to a special table used by internetwork objects.
             table.insert(self.AttachedRemoteLinksTable, unitArg)    
        end        
        
        --# How we add the unit depending on its type.
    	if not unitArg.IsPipeLineUnit then
            --# For each bonus type
            for bonusTypeIndex, bonusTypeName in AdjacencyBonusTypes do
                --# If the new unit can receive it, it joins the receivers list.
                if unitArg.IsAdjacencyBonusReceiver[bonusTypeName] then
                    table.insert(self.AdjacencyUsersTable[bonusTypeName], unitArg)
                end
                --# If the new unit can give it, it joins the givers list.
                if unitArg.IsAdjacencyBonusGiver[bonusTypeName] then
                    table.insert(self.AdjacencyGiversTable[bonusTypeName], unitArg)
                end
            end
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Everytime you call this, the bonuses in a network will be
    --#*  out of date and will need to be recalculated.
    --#*
    --#*  This can also be called as a clean-up function for dead units.
    --#*  It removes the unit from this network by removing any references
    --#*  from the unit to the network, and from the network to the unit.
    --#**
    OnNetworkNotInField = function(self, unitArg, fieldSource)   
    
        --# remove the calling field source object from 
        --# the special table used by network objects
        --# to keep track of all the fields they are 
        --# passively receiving adjacency from
        self.WithinPassiveRemoteAdjacencyFieldOf = 
            GilbotUtils.RemoveFromArrayByValue(
                self.WithinPassiveRemoteAdjacencyFieldOf, fieldSource, true)
        
        local inFieldsCount = table.getsize(self.WithinPassiveRemoteAdjacencyFieldOf) or 0
        local remoteLinksCount = table.getsize(self.AttachedRemoteLinksTable) or 0 
      
        --# If this unit is connected to any other field sources, 
        --# keep a record of them so we can refresh them later
        for k, vOtherFieldSource in self.WithinPassiveRemoteAdjacencyFieldOf do
            if not GilbotUtils.IsValueInTable(
                fieldSource.OtherTowersToRefresh, 
                vOtherFieldSource
              )
            then
                table.insert(fieldSource.OtherTowersToRefresh, vOtherFieldSource)
            end
        end
      
        --# If the unit isn't in any other fields
        --# and there are no remote pipelines attached to the network
        if inFieldsCount + remoteLinksCount == 0 then 
            --# It should not be associated with an internetwork anymore
            local nodesOnNetwork = table.getsize(self.AttachedNodesTable)
            
            --# If it is not connected to anything else locally 
            --# Check if we even need a network object.
            --# maybe it was created just to take part in an internetwork?
            if nodesOnNetwork == 1 and unitArg and
               self.AttachedNodesTable[1] == unitArg  
            then 
                --# Destroy this network object
                --# and leave the unit on its own
                unitArg:ClearNetwork()
                self:Destroy()
            end
        end
    end,
    
    
      
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Everytime you call this, the bonuses in a network will be
    --#*  out of date and will need to be recalculated.
    --#*
    --#*  This can also be called as a clean-up function for dead units.
    --#*  It removes the unit from this network by removing any references
    --#*  from the unit to the network, and from the network to the unit.
    --#**
    RemoveUnitFromNetwork = function(self, unitArg)   

        --# We can't do anything if this is nill
        if not unitArg then return end
        
        --# Remove reference to it from this network's node list
        self.AttachedNodesTable = 
            GilbotUtils.RemoveFromArrayByValue(
                self.AttachedNodesTable, unitArg, true) 
            
        --# If this is a remote-link pipeline
        if unitArg.IsRemoteAdjacencyUnit then
            --# remove reference to it from the 
            --# special table used by internetwork objects.
            self.AttachedRemoteLinksTable = 
                GilbotUtils.RemoveFromArrayByValue(
                    self.AttachedRemoteLinksTable, unitArg, true)    
        end   
        
        --# If this unit is the type likely to have a bonus, check bonus tables.
        --# If this is a clean-up, then do it anyway because we can't check type.
        if not unitArg.IsPipeLineUnit then
            --# For each type of bonus available
            for bonusTypeIndex, bonusTypeName in AdjacencyBonusTypes do
                --# If the unit we are removing from the network can receive it..
                if unitArg.IsAdjacencyBonusReceiver[bonusTypeName]  then
                    --# Remove it from this network's table of bonus consumers
                    self.AdjacencyUsersTable[bonusTypeName] = 
                        GilbotUtils.RemoveFromArrayByValue(
                            self.AdjacencyUsersTable[bonusTypeName], unitArg, true) 
                end
                
                --# If the unit we are removing from the network can receive it..
                if unitArg.IsAdjacencyBonusGiver[bonusTypeName] then
                    --# Remove it from this network's table of bonus givers    
                    self.AdjacencyGiversTable[bonusTypeName] = 
                        GilbotUtils.RemoveFromArrayByValue(
                            self.AdjacencyGiversTable[bonusTypeName], unitArg, true) 
                end
            end
        end
        
        --# If unit is alive, we need to switch bonuses off 
        --# and remove its reference to us so it can't remove itself twice
        if unitArg:IsAlive() then unitArg:ClearNetwork() end
        
        --# This next block is for debugging only.
        --# This can be delete wheh debugging is done.
        self:AdjacencyLog('RemoveUnitFromNetwork: ' 
         .. ' Removed unit ' .. unitArg.DebugId
         .. ' from network '.. repr(self.NetworkId) 
        )
  
    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from the ResourceInterNetwork class.
    --#**
    IsBridgeInInterNetwork = function(self)
        --# Look at every remote-link pipeline attached to this network.
        for unusedArrayIndex, vRemoteLinkPipelineUnit in self.AttachedRemoteLinksTable do
            --# if any of them has a remote link to anything else, then we must be 
            --# bridging networks.
            if vRemoteLinkPipelineUnit:GetNumberOfConnectedUnits('Remote') > 0 then return true end
        end            
    end,
    
 
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from the ResourceInterNetwork class.
    --#**
    DoesImpactInterNetworkBonus = function(self)
        --# For each type of adjacebncy bonus possible
        for bonusTypeIndex, bonusTypeName in AdjacencyBonusTypes do
            --# if the network has a unit that gives or receive it
            if table.getsize(self.AdjacencyGiversTable[bonusTypeName]) > 0 or
               table.getsize(self.AdjacencyUsersTable[bonusTypeName]) > 0 
            --# Tell calling code we do impact the internetwork bonuses.
            then return true end
        end
        --# If we got here then our network contains nothing 
        --# that can impact the internetwork bonus.
        return false
    end,
    
    
    --#***************************
    --#*
    --#*  Bonuses
    --#*  
    --#***********************************************
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  If toggleOn is false, it will switch all bonuses off.
    --#**
    PropogateBonuses = function(self)
        --# This next line signals that a waiting thread 
        --# has started propogating
        self.PropogateBonusesThreadWaiting = nil
        
        if self.MyInterNetwork and not self.MyInterNetwork.IsBroken then 
            --# Call version in the ResourceInterNetwork object.
            self.MyInterNetwork:PropogateBonusesThroughInterNetwork() 
        else
            --# call version in this ResourceNetwork object.
            self:PropogateBonusesThroughThisNetworkOnly() 
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This cleans up the adjacency users/givers tables as 
    --#*  it trawls through them. 
    --#**
    PropogateBonusesThroughThisNetworkOnly = function(self)
        
        --# Don't allow a broken network to give adjacency.  
        if self.IsBroken then 
            --# This next block is for debugging only.
            --# This can be delete wheh debugging is done.
            --self:AdjacencyLog('PropogateBonusesThroughThisNetworkOnly called on broken network.')
            return 
        end
        
        --# For each adjacency bonus type possible, 
        for bonusTypeIndex, bonusTypeName in AdjacencyBonusTypes do
            
            --# This safety check turned out to be necessary
            if not self.AdjacencyUsersTable[bonusTypeName] then 
                --# This next block is for debugging only.
                --# This can be delete wheh debugging is done.
                WARN('PropogateBonusesThroughThisNetworkOnly: Missing table: ' 
                     .. ' AdjacencyUsersTable[' .. bonusTypeName .. ']'
                )
                --# Skip this loop
                break 
            end
            
            --# For each recipient unit of this type of bonus
            for k, vBonusConsumingUnit in self.AdjacencyUsersTable[bonusTypeName] do  
                
                --# Perform destroyed unit clean-up check.
                if not vBonusConsumingUnit:IsAlive() then 
                    --# Clean up dead entry in table.
                    self:RemoveUnitFromNetwork(vBonusConsumingUnit)
                else
                    
                    --# Set the factor so we give/remove any 
                    --# bonus the network has for this unit
                    --# depending on the state of toggleOn
                    local bonus = 0
             
                    --# Recalculate what bonus should be given to all units 
                    --# that can receive a bonus of this type.
                    if self.MyInterNetwork and not self.MyInterNetwork.IsBroken then 
                        --# Call version in the ResourceInterNetwork object.
                        bonus = 
                            self.MyInterNetwork:CalulateBonus(
                                bonusTypeName, 
                                vBonusConsumingUnit
                            )
                    else
                        --# call version in this ResourceNetwork object.
                        bonus = 
                            self:CalulateBonus(
                                bonusTypeName, 
                                vBonusConsumingUnit
                            )
                    end
                    
                    
                    --# This next block is for debugging only.
                    --# This can be delete wheh debugging is done.
                    local unitId =  'N=' .. repr(self.NetworkId)
                                  .. ' ' .. vBonusConsumingUnit.DebugId
                    
                    self:AdjacencyLog('PropogateBonusesThroughThisNetworkOnly'
                        .. '    BonusName=' .. bonusTypeName 
                        .. '    BonusConsumingUnit=' .. unitId
                        .. '    BonusAmount=' .. repr(bonus)
                    )
                 

                    --# Set the bonus.
                    vBonusConsumingUnit:SetAdjacencyBonus(bonusTypeName, bonus)
                    
                    --# This next line is normally done when we change 
                    --# adjacency bonuses on a unit.
                    vBonusConsumingUnit:RequestRefreshUI() 
                end
            end
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Values for bonuses are recalculated from scratch here.
    --#*  This gets called by PropogateBonusesThroughThisNetworkOnly 
    --#*  each time something is added to the network.
    --#**
    CalulateBonus = function(self, bonusTypeName, bonusConsumer)	
        local modValue = 0
        
        --# Get each giver on the network to boost up the bonus by its amount
        for k, vUnit in self.AdjacencyGiversTable[bonusTypeName] do
            --# This safety check is required
            if vUnit and vUnit:IsAlive() then 
                --# Add up the bonus modifiers from each giver for this category
                modValue = modValue + vUnit:GetAdjacentBonus(bonusConsumer, bonusTypeName)
            else
                --# Clean up dead entry in table.
                self:RemoveUnitFromNetwork(vUnit)
            end
        end
        
        --# Apply cap limit to the bonus (limit depends on bonus type)
        return ApplyBonusCap(modValue, bonusTypeName, bonusConsumer:GetUnitId())
        
    end,
    
}