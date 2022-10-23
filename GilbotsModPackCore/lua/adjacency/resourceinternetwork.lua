--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/adjacency/resourceinternetwork.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Internetwork management system for spreading adjacency 
--#*            between two or more local networks connected by remote liks.
--#*
--#*****************************************************************************
local GilbotUtils = 
    import('/mods/GilbotsModPackCore/lua/utils.lua')
local ApplyBonusCap = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencybonustypes.lua').ApplyBonusCap


ResourceInterNetwork = Class
{
    --# Toggle on/off detailed logging
    DebugAdjacencyCode = false,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  For debugging only.
    --#** 
    AdjacencyLog = function(self, messageArg)
        if self.DebugAdjacencyCode then 
            if type(messageArg) == 'string' then
                LOG('Adjacency: a=' .. self.ArmyIdString .. ' ' .. messageArg)
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
        
        --# Initialise data structures        
        self:ClearNetworkTables()

        --# Safety: firstNode is not always supplied.
        if firstNode then 
            if firstNode.IsAdjacencyFieldUnitNetwork then 
                self:AddFieldSourceToInterNetwork(firstNode)
            else 
                self:AddLocalNetworkToInterNetwork(firstNode)
            end
        else
            if optionalArg == 'SpawningFromBroken' then
                self.IsStillBeingReconstructed = true
            else
                WARN('ResourceInterNetwork: __init: object was created with ' 
                      .. 'no initial remote link node in constructor.')
            end
        end
    end,
    
   
  
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only called by the constructor to initialise 
    --#*  and in the BreakNetworkAndSalvagePieces function to 
    --#*  make the network object safe (unusable because it contains no units).
    --#**
    ClearNetworkTables = function(self)
        --# Use this to keep a list of linking nodes in the internetwork
        self.AttachedNodesTable = {} 
        self.FieldSources = {} 
    end,
        
    

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only called by AddToInterNetwork to initialise 
    --#*  network properties that require the first network to be added 
    --#*  to the internetwork.  The first network gives us a reference to the
    --#*  army ID and thus we can contact the ACU if it is alive.
    --#**
    SetFirstNode = function(self, localNetworkArg)
        --# Keep a reference to the army so we can check for capturing
        if type(localNetworkArg.Army) ~= "table" then
            self.MyArmyId = localNetworkArg.Army
            self.ArmyIdString = repr(self.MyArmyId)
        else
            WARN('ResourceInterNetwork: SetFirstNode: Army is a table.')
            self.MyArmyId = nil
            self.ArmyIdString = '?'
        end
        self.MyCommander = localNetworkArg.MyCommander
        
        --# Keep reference to first network that joined
        self.FirstNode = localNetworkArg
         
        --# If commander is alive...
        if self.MyCommander and self.MyCommander:IsAlive() then
            --# Put a reference to us in the ACU's table
            self.MyCommander:ReceiveACUMessage_AddNewInterNetwork(self)
        else
            --# Prevent any more checks to see if ACU is dead
            --# because we know it is already
            self.MyCommander = nil
        end
    end,
 
 
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is only for debugging.
    --#**
    TellACU_DumpAllActiveNetworks = function(self)

        --# If commander is alive...
        if self.MyCommander and self.MyCommander:IsAlive()
        then
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
    AddRemoteLinkToInterNetwork = function(self, localNetworkArg2)
        
        --# The first unit must have a network to be running this function.
        --# If the other unit has no valid network,
        if (not localNetworkArg2.MyInterNetwork) or localNetworkArg2.MyInterNetwork.IsBroken then
            --# The other unit has just been built and has no 
            --# network supervisor yet, so it now will associate with ours.
            --# No need to merge.
            self:AddLocalNetworkToInterNetwork(localNetworkArg2)
            --# Change this so we only update if the 
            --# network that joined had adjacency givers or receivers
            if localNetworkArg2:DoesImpactInterNetworkBonus() then 
                self:PropogateBonusesThroughInterNetwork() 
            end
            
        --# They both have networks, so if they are not already the same 
        --# network we'll have to merge them both.
        elseif self ~= localNetworkArg2.MyInterNetwork then            
            --# Now merge the smaller of the two networks into the larger.
            --# Bonuses will automatically be switched on after the merge.
            --# Check who has most units before deciding who merges into who.
            local nodesAlreadyInMyInterNetwork = 
                table.getsize(self.AttachedNodesTable)
            
            local nodesAlreadyInOtherInterNetwork =  
                table.getsize(localNetworkArg2.MyInterNetwork.AttachedNodesTable)
                
            --# If this internetwork has more nodes..
            if nodesAlreadyInMyInterNetwork > nodesAlreadyInOtherInterNetwork
            then
                --# merge the other internetwork into me
                self:MergeInterNetworks(localNetworkArg2.MyInterNetwork)
            else
                --# we merge into them
                localNetworkArg2.MyInterNetwork:MergeInterNetworks(self)
            end
        end
        --# Otherwise if they have the same supervisor it means there 
        --# is a loop in the network.  Loops happen and are not a problem.
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This can be called by RemoteAdjacencyUnit nodes when their 
    --#*  OnNotRemotelyAdjacentTo function is called.  This function then decides 
    --#*  if they can just drop either of the two units from the network, 
    --#*  or if the entire network needs to be broken up.
    --#* 
    --#*  Adjacency beam effects are taken care of by the AdjacencyStructureUnit
    --#*  class. We just have to remove all bonuses and references to these units 
    --#*  from the network.
    --#*  
    --#*  If there is no need to break up this network into two or more subnetworks,
    --#*  then the units remianing in the network get recalculated bonuses.
    --#*  If the network does get broken up into subnetworks, these subnetworks 
    --#*  will get their own new ResourceInterNetwork object with its own set of 
    --#*  recalculated adjacency bonuses.
    --#**
    OnRemoteLinksRemovedFromInterNetwork = function(self)
         
        --# The internetwork may have been broken on a previous call to this function
        --# but we allow subsequent calls to get this far anyway as it stops other 
        --# units in the network that died just a tick or so afterwards 
        --# from being added to newly spawned networks.
        if self.IsBroken then return end
        
        --# Only the ACU can remap internetworks
        if self.MyCommander and self.MyCommander:IsAlive() then 
            self.MyCommander:ReceiveACUMessage_MapNewResourceInternetworks()
            --# Purge ourself from ACU's table as we will destroy ourself next
            self.MyCommander.ActiveInterNetworks[self.InterNetworkId] = nil
        end
        
        --# Make this redundant object safe
        self:Destroy()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Retire this object by removing all its references 
    --#*  and removing any references to it.
    --#**
    Destroy = function(self)
        
        --# Mark as broken (but not ready to recycle)
        self.IsBroken = true
        
        --# Remove reference to us from ACU
        if type(self.InterNetworkId) == 'number' 
          and self.MyCommander and self.MyCommander:IsAlive() then 
            self.MyCommander.ActiveInterNetworks[self.InterNetworkId] = nil
        end
        
        --# Remove references to make them safe
        self.MyArmyId = nil
        self.MyCommander = nil
        self.FirstNode = nil
        
        --# To break the internetwork, remove any references
        --# to it from all of the members.  Once this is done,
        --# Calling propogate bonuses on that network will make 
        --# sure it doesn't get the bonuses from the internetwork.
        for arrayIndex, vNetwork in self.AttachedNodesTable do
            --# Just don't remove references to the internetwork
            --# from an adjacencyfield unit as they will keep calling this
            --# function until all the units in its field have been removed.
            --# Only the first call will do anything though.
            if vNetwork and (not vNetwork.IsBroken) 
              and vNetwork.MyInterNetwork == self then 
                --# If the network is broken 
                --# it won't get bonuses anyway
                --# as the units in it can contact 
                --# it or the internetwork so no need 
                --# to remove reference to us from
                --# broken networks.
                vNetwork:ClearInterNetwork()
            end
        end
        
        --# Clear all our network tables now as 
        --# this network object should never be used again.
        self:ClearNetworkTables()
        --# Delete our unique id number
        --# so we won't be used
        self.InterNetworkId = nil
        --# Mark that ACU can recycle 
        --# our unique network ID number
        self.IsSafeToRecycle = true
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
    MergeInterNetworks = function(self, smallerInterNetworkArg)
        
        --# This next block is for debugging only.
        --# This can be delete wheh debugging is done.
        self:AdjacencyLog('MergeInterNetworks:'
         .. ' Merging I=' .. repr(smallerInterNetworkArg.InterNetworkId)
         .. ' into I=' .. repr(self.InterNetworkId)
        )
        
        --# Warn any remote-link units that they need to wait 
        --# before connecting to this internetwork and
        --# to abandon trying to connect to the smaller one we
        --# are merging into us.        
        self.IsStillBeingReconstructed = true
        smallerInterNetworkArg.IsBroken = true
        
        --# Merge the bonus givers lists from the other 
        --# network supervisor into the list for this one.
        local needToRecalculateBonuses = 
            self:MergeNetworkLists(self.AttachedNodesTable, 
                                   smallerInterNetworkArg.AttachedNodesTable)
        --# Merge field sources
        self:MergeNetworkLists(self.FieldSources, smallerInterNetworkArg.FieldSources)

        --# inform any remote-link units waiting that they don't need 
        --# to wait anymore before connecting to this internetwork.    
        self.IsStillBeingReconstructed = false
        --# Destroy the object merged in to us so 
        --# its Id number can be recycled.
        smallerInterNetworkArg:Destroy()
        
        --# Propogate bonuses throughout this network if needed
        if needToRecalculateBonuses then 
            self:PropogateBonusesThroughInterNetwork() 
        end 
    end,
	


    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This function is called by the function MergeNetworks defined above. 
    --#*
    --#*  It merges tables that contain references to network objects 
    --#*  and remote-link units in each internetwork. 
    --#*  It merges table2 into table1 and updates all items changing internetwork
    --#*  so that they have a reference to the internetwork they just merged into
    --#*  (instead of the old internetwork they just came from which will be destroyed next).
    --#**
    MergeNetworkLists = function(self, table1, table2)
    	--# Nothing to do as table 2 is empty
        if table.getn(table2) == 0 then
            return false
    	end
        --# Table 1 is empty so copy
        --# table 2 into table 1
    	if table.getn(table1) == 0 then
            for k, vUnit in table2 do
                table.insert(table1, vUnit)
            end
            return false
    	end
        
  	--# Have to do a merge.
        --# Iterate through the values to merge.
        local needToRecalculateBonuses = false
    	for k1, vNodeInTable2 in table2 do
        
            local foundInTable1 = false
            --# Iterate through the values to merge into
            --# to see if it's in both tables
            for k2, vNodeInTable1 in table1 do
                if vNodeInTable1 == vNodeInTable2 then
                    foundInTable1 = true
                end
            end
            --# Do the merge if the unit wasn't alredy in both tables
            if not foundInTable1 then
                --# Doing merge.
                --# Network objects and remote link objects both 
                --# get a reference to their new internetwork.
                vNodeInTable2:SetInterNetwork(self)
                
                --# Work out if we will have to recalulate the bonuses on 
                --# all networks after the merege.
                if vNodeInTable2:DoesImpactInterNetworkBonus() then
                    needToRecalculateBonuses = true
                end
                
                --# Give their new internetwork a reference to them
                table.insert(table1, vNodeInTable2)	
            end
    	end
        --# Tell calling code to update bonuses on all 
        --# member networks if necessary
        return needToRecalculateBonuses  	
    end,
    
 
	
        
 
    
    
    --#***************************
    --#*
    --#*  Adding and Removing from Network
    --#*  
    --#***********************************************
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Add a network or remote link to this internetwork by giving it a reference 
    --#*  to this internetwork, and setting references in this internetwork back to 
    --#*  any subnetwork as a bonus giver or receiver, and to remote links
    --#*  for reconnection purposes.
    --#**
    AddLocalNetworkToInterNetwork = function(self, localNetworkArg)
        --# Perform last bit of network initialisation 
        --# if this is the first node added to the network. 
        if not self.FirstNode then self:SetFirstNode(localNetworkArg) end
        
        --# The added local network needs a reference to its 
        --# new internetwork so it can call us to tell us to update new bonuses
        localNetworkArg:SetInterNetwork(self)
        localNetworkArg.RemoveMeFromMyInterNetwork = false
        
        --# We keep a reference to the network 
        table.insert(self.AttachedNodesTable, localNetworkArg)
    end,
    
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Add a network or remote link to this internetwork by giving it a reference 
    --#*  to this internetwork, and setting references in this internetwork back to 
    --#*  any subnetwork as a bonus giver or receiver, and to remote links
    --#*  for reconnection purposes.
    --#**
    AddFieldSourceToInterNetwork = function(self, localNetworkArg)
        --# Perform last bit of network initialisation 
        --# if this is the first node added to the network. 
        if not self.FirstNode then self:SetFirstNode(localNetworkArg) end
        
        --# The added local network needs a reference to its 
        --# new internetwork so it can call us to tell us to update new bonuses
        localNetworkArg:SetInterNetwork(self)
        localNetworkArg.RemoveMeFromMyInterNetwork = false
        
        --# We keep a reference to the network 
        table.insert(self.FieldSources, localNetworkArg)
        self.HasFieldSources = true
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Nodes are either networks or remote-link units.
    --#*  This function removes the node from this internetwork by 
    --#*  removing any references from the node to the internetwork, 
    --#*  and from the internetwork to the node.
    --#**
    RemoveLocalNetworkFromInterNetwork = function(self, localNetworkArg)   
        
        --# If the unit is leaving this network then it isn't in any network.
        if localNetworkArg and localNetworkArg.MyInterNetwork then 
            localNetworkArg:SetInterNetwork(nil) 
        end
        
        --# Remove it from accounting list
        self.AttachedNodesTable = 
            GilbotUtils.RemoveFromArrayByValue(self.AttachedNodesTable, localNetworkArg, true)
        

    end,
    

 
    
    
    --#***************************
    --#*
    --#*  Bonuses
    --#*  
    --#***********************************************
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Tell all networks to do update. 
    --#*  Networks will call CalulateBonus in this object
    --#*  if they have a reference to it and the internetwork
    --#*  flags that it has at least more than one  
    --#**
    PropogateBonusesThroughInterNetwork = function(self)
        --# Adjacency field Towers can set this
        if self.SupressUpdate then return end
        --# For each network on the internetwork, Tell them to recalculate
        --# bonuses for all of their bonus consuming nodes.
        --# Calls to CalulateBonus will be passed to this object,
        --# so all adjacency givers on the internetwork will be 
        --# included in the calculation.
        for unusedArrayIndex, vLocalNetwork in self.AttachedNodesTable do
            --# This next block is for debugging only.
            --# This can be delete wheh debugging is done.
            self:AdjacencyLog('PropogateBonusesThroughInterNetwork:' 
                  .. ' On networkId=' .. repr(vLocalNetwork.NetworkId)
                  .. ' calling PropogateBonusesThroughThisNetworkOnly().' 
            )          
            vLocalNetwork:PropogateBonusesThroughThisNetworkOnly()
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Values for bonuses are recalculated from scratch here.
    --#*  This gets called by PropogateBonusesThroughNetwork 
    --#*  each time something is added to the network.
    --#**
    CalulateBonus = function(self, bonusTypeName, bonusConsumer)	
        local modValue = 0
        
        --# Added Safety Check
        if self.IsBroken then return end
        
        --# For each network on the internetwork
        for kNetworkId, vLocalNetwork in self.AttachedNodesTable do
            --# Added check here as I caught a broken network here once
            if vLocalNetwork.IsBroken then 
                --# Remove the invalid network
                self:RemoveLocalNetworkFromInterNetwork(vLocalNetwork)
            else
                --# Get each giver on the network to boost up the bonus by its amount
                for k, vUnit in vLocalNetwork.AdjacencyGiversTable[bonusTypeName] do
                    --# This safety check is required
                    if vUnit and vUnit:IsAlive() then 
                        --# Add up the bonus modifiers from each giver for this category
                        modValue = modValue + vUnit:GetAdjacentBonus(bonusConsumer, bonusTypeName)
                    else                    --# Clean up dead entry in table.
                        vLocalNetwork:RemoveUnitFromNetwork(vUnit, true)
                    end
                    --# Put this in to stop an error that appears when 
                    --# lots of buildings are being destroyed.
                    if not vLocalNetwork.AdjacencyGiversTable then
                        WARN('ResourceInterNetwork: CalulateBonus: Exit loop because '
                          .. 'vLocalNetwork.AdjacencyGiversTable no longer defined.')
                        break
                    end
                end
                --# Put this in to stop an error that appears when 
                --# lots of buildings are being destroyed.
                if not self.AttachedNodesTable then
                    WARN('ResourceInternetwork: CalulateBonus: Exit loop because '
                      .. 'self.AttachedNodesTable no longer defined.')
                    break
                end
            end
        end
        --# Apply cap limit to the bonus (limit depends on bonus type)
        return ApplyBonusCap(modValue, bonusTypeName, bonusConsumer:GetUnitId())
        
    end,
    
}