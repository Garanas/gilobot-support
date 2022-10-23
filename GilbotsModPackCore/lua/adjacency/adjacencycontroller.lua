--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/adjacencycontroller.lua
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
    


--#*
--#*
--#*  Gilbot-X says:
--#*
--#*  This class contains ACU code relevant to adjacency.
--#*
--#***

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeRemoteAdjacencyController(baseClassArg) 

local BaseClass = baseClassArg
local resultClass = Class(BaseClass) {

    --# This constant shared variable provides a convenient means 
    --# of testing any object to see if it uses this class.
    IsRemoteAdjacencyController = true,
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
    --#*  This is called from InitializeKnowledge() in the file  
    --#*  ACUCommon.lua, which itself is called from an override 
    --#*  of the ACU's Unit:OnCreate(), so I can do variable 
    --#*  initialization common to all 4 ACUs at this time.
    --#** 
    InitializeResourceNetworkSystem = function(self)
        --# Make this value globally available to other scripts in my mod.
        self.MyMaxAdjacencyRangeEncounteredSoFar = 0
        
        --# Set this to a T1 Powergen or MeX
        self.MyMaxSkirtXFromCentre = 1
        self.MyMaxSkirtZFromCentre = 1
        
        --# ACU knows about which networks are running.
        self.HighestNetworkNumber =0
        self.ActiveNetworks = {}
        
        --# ACU knows about which inter-networks are running.
        self.HighestInterNetworkNumber =0
        self.ActiveInterNetworks = {}
        
        --# This flag decides whether or not 
        --# Internetwork objects acn be established
        self.InterNetworkMappingEnabled = true
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by structure units
    --#*  to update the commander (thus the army) that
    --#*  a new adjacency range is available, so the commamder
    --#*  should now try to link units that are further apart.
    --#** 
    ReceiveACUMessage_SetMaxAdjacencyRangeEncounteredSoFar = function(
                                                      self, 
                                                      maxAdjacencyRangeEncounteredSoFarArg)
        self.MyMaxAdjacencyRangeEncounteredSoFar = 
            math.max(
                maxAdjacencyRangeEncounteredSoFarArg,
                self.MyMaxAdjacencyRangeEncounteredSoFar
            )
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by structure units
    --#*  to ask the commander (thus the army) what
    --#*  the max adjacency range available is, so the commander
    --#*  should now try to link units that are this far apart.
    --#** 
    ReceiveACUMessage_GetMaxAdjacencyRangeEncounteredSoFar = function(self)
        return self.MyMaxAdjacencyRangeEncounteredSoFar
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by structure units
    --#*  to update the commander (thus the army) that
    --#*  a new adjacency range is available, so the commamder
    --#*  should now try to link units that are further apart.
    --#** 
    ReceiveACUMessage_SetMaxSkirtBoundsEncounteredSoFar = function(self, 
                                                    maxSkirtXFromCentreArg, 
                                                    maxSkirtZFromCentreArg)
          self.MyMaxSkirtXFromCentre = 
              math.max(
                  maxSkirtXFromCentreArg,
                  self.MyMaxSkirtXFromCentre
              )
              
          self.MyMaxSkirtZFromCentre = 
              math.max(
                  maxSkirtZFromCentreArg,
                  self.MyMaxSkirtZFromCentre
              )
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by structure units
    --#*  to ask the commander (thus the army) what
    --#*  the max adjacency range available is, so the commander
    --#*  should now try to link units that are this far apart.
    --#** 
    ReceiveACUMessage_GetMaxSkirtBoundsEncounteredSoFar = function(self)
        return self.MyMaxSkirtXFromCentre, self.MyMaxSkirtZFromCentre 
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by ResourceNetwork objects
    --#*  when created to inform the ACU (thus the army) 
    --#*  a new network has been created.
    --#** 
    ReceiveACUMessage_AddNewNetwork = function(self, networkArg)
        
        --# We will first check if we can reuse an old 
        --# network ID number from a network that was destroyed
        local reuseableNetworkNumber = false
        --# Using value of 9 encourages single digit network IDs
        --# which means clearer displays on units
        local startRecyclingPoint = 9
        
        --# This is for safety to avoid a numerical overflow
        if self.HighestNetworkNumber >= startRecyclingPoint then
            --# Defer call to each active network.
            local logmessage1 = '    Free network numbers <= ' 
                .. repr(self.HighestNetworkNumber) .. ' :##: '
            local logmessage2 = 'Broken network numbers <= ' 
                .. repr(self.HighestNetworkNumber) .. ' :##: '
            for index = 1, self.HighestNetworkNumber do 
                if (not self.ActiveNetworks[index]) or 
                    self.ActiveNetworks[index].IsSafeToRecycle 
                  then
                    logmessage1 = logmessage1 .. repr(index) .. ', '
                    reuseableNetworkNumber = reuseableNetworkNumber or index
                elseif self.ActiveNetworks[index] 
                  and self.ActiveNetworks[index].IsBroken
                  and (not self.ActiveNetworks[index].IsSafeToRecycle)
                  then
                    logmessage2 = logmessage2 .. repr(index) .. ', '
                end
            end
            --self:AdjacencyLog(logmessage1)
            --self:AdjacencyLog(logmessage2)
        end
        
        --# Give the new network a copy of its unique reference number
        if reuseableNetworkNumber then
            --# Give the new network a copy of its unique reference number
            networkArg.NetworkId = reuseableNetworkNumber
        else
            --# Update network number 
            self.HighestNetworkNumber = self.HighestNetworkNumber+1
            --# Give the new network a copy of its unique reference number
            networkArg.NetworkId = self.HighestNetworkNumber
        end
        
        
        --# ACU keeps a reference to the network object
        --# using this unique number as a table key
        self.ActiveNetworks[networkArg.NetworkId] = networkArg
        
        --# If we were already displaying numbers for 
        --# other networks, then display for this new one too.
        networkArg:SyncAllNetworkNumbersDisplay() 
      
    end,
          
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by ResourceInterNetwork objects
    --#*  when created to inform the ACU (thus the army) 
    --#*  a new remote-linked inter-network has been created.
    --#** 
    ReceiveACUMessage_AddNewInterNetwork = function(self, interNetworkArg)
        --# Check if this is disabled first
        if not self.InterNetworkMappingEnabled then return end
        --# We will first check if we can reuse an old 
        --# network ID number from a network that was destroyed
        local reuseableInterNetworkNumber = false
        --# Using value of 9 encourages single digit network IDs
        --# which means clearer displays on units
        local startRecyclingPoint = 5
        
        --# This is for safety to avoid a numerical overflow
        if self.HighestInterNetworkNumber >= startRecyclingPoint then
            --# Defer call to each active network.
            local logmessage1 = '    Free InterNetwork numbers <= ' 
                .. repr(self.HighestInterNetworkNumber) .. ' :##: '
            local logmessage2 = 'Broken InterNetwork numbers <= ' 
                .. repr(self.HighestInterNetworkNumber) .. ' :##: '
            for index = 1, self.HighestInterNetworkNumber do 
                if (not self.ActiveInterNetworks[index]) or 
                    self.ActiveInterNetworks[index].IsSafeToRecycle 
                  then
                    logmessage1 = logmessage1 .. repr(index) .. ', '
                    reuseableInterNetworkNumber = reuseableInterNetworkNumber or index
                elseif self.ActiveInterNetworks[index] 
                  and self.ActiveInterNetworks[index].IsBroken
                  and (not self.ActiveInterNetworks[index].IsSafeToRecycle)
                  then
                    logmessage2 = logmessage2 .. repr(index) .. ', '
                end
            end
            --self:AdjacencyLog(logmessage1)
            --self:AdjacencyLog(logmessage2)
        end
        
        --# Give the new network a copy of its unique reference number
        if reuseableInterNetworkNumber then
            --# Give the new network a copy of its unique reference number
            interNetworkArg.InterNetworkId = reuseableInterNetworkNumber
        else
            --# Update network number 
            self.HighestInterNetworkNumber = self.HighestInterNetworkNumber+1
            --# Give the new network a copy of its unique reference number
            interNetworkArg.InterNetworkId = self.HighestInterNetworkNumber
        end
         
        --# ACU keeps a reference to the InterNetwork object
        --# using this unique number as a table key
        self.ActiveInterNetworks[interNetworkArg.InterNetworkId] = interNetworkArg
    end,

    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by Seraphim adjacency receiving units
    --#*  when created to try and connect to any existing adjacency fields.
    --#** 
    ReceiveACUMessage_ConnectMeWithAnyAdjacencyFieldSource = function(self, unitArg)
        --# Check all internetworks for an adjacency field tower
        for k, vInterNetwork in self.ActiveInterNetworks do
            --# For each one found...
            for k2, vFieldSourceNetwork in vInterNetwork.FieldSources do
                --# If operational....
                if not vFieldSourceNetwork.IsBroken then
                    local adjacencyFieldSource = vFieldSourceNetwork.FirstNode
                    --# and not paused
                    if unitArg ~= adjacencyFieldSource 
                      and not adjacencyFieldSource.IsRemoteAdjacencyPaused then
                        --# if we are allowed to connect with it
                        if adjacencyFieldSource:CheckIfEligibleForRemoteAdjacency(unitArg) then
                            --Then do so
                            adjacencyFieldSource:TryToGiveOrReceiveRemoteAdjacency(unitArg) 
                        end
                    end
                end
            end
        end
    end,    
        
 
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This should be called when the ACU dies so it 
    --#*  is obvious that autotoggle has been disabled on all units.
    --#*  This is safe to be called more than once.
    --#** 
    SyncAllNetworkNumbersDisplay = function(self)    
        --# Defer call to each active network.
        for kNetworkId, vNetwork in self.ActiveNetworks do
            if not vNetwork.IsBroken then
                vNetwork:SyncAllNetworkNumbersDisplay()
            end
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This should be called when the ACU dies so 
    --#*  adjacency is disabled on all units.
    --#** 
    NoMoreResourceNetworks = function(self)    
        
        --# iterate through all networks and break them up.
        for k, vNetwork in self.ActiveNetworks do
            if not vNetwork.IsBroken then
                vNetwork:BreakNetworkWhenACUDies()
            end
        end
        
        --# Make tables totally safe
        self.ActiveNetworks = {}
        self.ActiveInterNetworks = {}
    end,
   
   
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This should be called when the ACU dies so it 
    --#*  is obvious that autotoggle has been disabled on all units.
    --#** 
    SwitchOffResourceInterNetworks = function(self)   
        --# iterate through all inter-networks and break them up.
        for k, vInterNetwork in self.ActiveInterNetworks do
            if not vInterNetwork.IsSafeToRecycle then
                vInterNetwork:Destroy()
            end
        end
        self.ActiveInterNetworks={}
        self.HighestInterNetworkNumber=0
    end,
        
   
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by auto-toggle units
    --#*  from their own class when created, to inform the ACU 
    --#*  so they can be used by the ACU's Auto Power-down.
    --#** 
    ReceiveACUMessage_MapNewResourceInternetworks = function(self)
        if not self.FindNewRemoteBridgesThread then
            self.FindNewRemoteBridgesThread = ForkThread(
                self.MapNewSubInterNetworks, self
            )
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is forked as a thread from OnNotAdjacentTo defined above.
    --#*  We inspect the list of remaining units in the old network and 
    --#*  try to break it down into subnetworks that can have their own bonuses.
    --#**
    MapNewSubInterNetworks = function(self) 
        --# Allow time for chain reactions to finish.
        --# These can wipe out entire networks in less than a second.
        --# Bigger explosions from nukes will take longer than a second
        --# and these may cause problems.  Wait longer here as networks 
        --# have to reassemble before we start reassembling InterNetworks
        self:FlashMessage('Routing Internetwork Bonuses')
        WaitSeconds(2)
        
       
        --# Defer call to each active network.
        local logmessage1 = '      Active network numbers :##: '
        local logmessage2 = 'Potential network numbers :##: '
        --# By this point, all nodes in this network now have a reference
        --# that points to a broken InterNetwork.  This network can no longer 
        --# give bonuses.  Units can no longer be added to it.
        --# The nodes that were in it now need to be reassigned.
        local numberOfNetworksToConnect = 0
        local numberOfNetworksActive = 0
        for index, vNetwork in self.ActiveNetworks do
            if vNetwork and (not vNetwork.IsBroken) then
                numberOfNetworksActive = numberOfNetworksActive +1
                logmessage1 = logmessage1 .. repr(index) .. ', '
                if (not vNetwork.MyInterNetwork) and
                  table.getn(vNetwork.AttachedRemoteLinksTable) > 0 
                then
                    numberOfNetworksToConnect = numberOfNetworksToConnect+1
                    logmessage2 = logmessage2 .. repr(index) .. ', '
                end
            end
        end    
        --self:AdjacencyLog(logmessage1)
        --self:AdjacencyLog(logmessage2)
        self:AdjacencyLog('MapNewSubInterNetworks: '
          .. ' ACU will now try to create InterNetworks from ' .. repr(numberOfNetworksToConnect) 
          .. ' of the ' .. repr(numberOfNetworksActive)
          .. ' registered active networks.'
        )
        
        --# This table will store tables of network references
        --# grouped together by the new InterNetworks they will form.
        local newSubInternetworksTable = {}
        
        --# Use a subset of networks that don't have an internetwork reference
        --# as the set of networks to build internetworks from.  We are only mapping 
        --# internetworks onto an existing topology, sop thsi is not called when a new
        --# remote link is established, it is called when an existing remote link goes down.
        for arrayIndex, vNetwork in self.ActiveNetworks do
            if vNetwork and (not vNetwork.IsBroken) and (not vNetwork.MyInterNetwork) and
              table.getn(vNetwork.AttachedRemoteLinksTable) > 0 
              and not GilbotUtils.IsValueIn2DTable(newSubInternetworksTable, vNetwork) then
                --# This network is a potential for a new Internetwork but we need
                --# to make sure it has a remote link to another potential.
                --# Create a new subnetwork starting from this unit
                local potentialInterNetwork = {}
                table.insert(potentialInterNetwork, vNetwork)
                potentialInterNetwork = 
                    self:TryToPathMoreLocalNetworksIntoNewSubInterNetwork(
                        vNetwork, potentialInterNetwork)
                --# If the potential InterNetwork contains more than one network
                if table.getsize(potentialInterNetwork) > 1 then 
                    table.insert(newSubInternetworksTable, potentialInterNetwork)
                end
            end
        end
     
        --# Spawn the InterNetworks we found if no redundancies exist in them.
        local redundantNetwork = GilbotUtils.FindRedundantEntryIn2DTable(newSubInternetworksTable)
        if redundantNetwork then
            WARN('MapNewSubInterNetworks: redundantNetwork N=' .. repr(redundantNetwork.NetworkId))
        else
            self:SpawnNewInternetworks(newSubInternetworksTable)
        end
        
        --# Setting this to nil allows the ACU to do this again
        self.FindNewRemoteBridgesThread = nil
        
        --# This is just for debugging.
        --# Delete when code trusted to be stable.        
        if self.DebugAdjacencyCode then
            self:DumpInterNetworks()
        end
    end, 
  
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by BreakNetworkAndSalvagePieces defined above.
    --#*  We inspect the broken network to try to find and create
    --#*  subnetworks.  Each AdjacencyStructureUnit in the network has a list 
    --#*  it maintains of which other units it is directly connected to.
    --#*  We recursively search through these lists to expand new subnetworks
    --#*  until no more units can be added to them.
    --#**
    TryToPathMoreLocalNetworksIntoNewSubInterNetwork = function(self, networkArg, newSubInterNetwork)
        
        --# Iterate through all remote links this network has
        for unusedArrayIndex1, vRemoteAdjacencyUnit in networkArg.AttachedRemoteLinksTable do
        
            --# Look at all the other networks this remote link is connecting to remotely
            for unusedArrayIndex2, vAdjacentRemoteAdjacencyUnit 
                                          in vRemoteAdjacencyUnit.AdjacentUnits['Remote'] do
                --# Don't try to verify if the connection is still valid,
                --# instead assume that if it was invalid it would have been removed.
                --# When remote link units die or are switched off they break these links 
                --# straight away.
                if not GilbotUtils.IsValueInTable(
                    newSubInterNetwork, 
                    vAdjacentRemoteAdjacencyUnit.MyNetwork
                ) 
                then
                  --# this can go in our subnetwork.
                  table.insert(newSubInterNetwork, vAdjacentRemoteAdjacencyUnit.MyNetwork)
                  --# Try to add whatever this newly added network
                  --# is connected to it in the same way with this recursive call.
                  newSubInterNetwork = 
                      self:TryToPathMoreLocalNetworksIntoNewSubInterNetwork(
                          vAdjacentRemoteAdjacencyUnit.MyNetwork, newSubInterNetwork)
                end
            end
        end
        
        --# return result
        return newSubInterNetwork
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This function is called by the function CreateNewSubInterNetworks 
    --#*  defined above.  It takes a table where each entry is a list of unit nodes
    --#*  that will form a subnetwork, and it attaches them to a new network manager
    --#*  and gets the new bonuses recalculated and switched on.
    --#**
    SpawnNewInternetworks = function(self, newSubInternetworksTable)
        --# For each subnetwork we found...
        for unusedArrayIndex1, localNetworkList in newSubInternetworksTable do
            --# Create a new network.
            local newInternetwork = ResourceInterNetwork(nil, 'SpawningFromBroken')
            --# Attach all its units
            for unusedArrayIndex2, vLocalNetwork in localNetworkList do
                newInternetwork:AddLocalNetworkToInterNetwork(vLocalNetwork)
            end
            --# Try to set the network going
            newInternetwork.IsStillBeingReconstructed = false
            newInternetwork:PropogateBonusesThroughInterNetwork()
    	end
    end,
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is paused, remote-links are disabled.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnScriptBitSet = function(self, bit)
        if bit == 4 then --# production pause toggle
            self:OnRemoteAdjacencyPaused()
        else
            --# Base class version will deal with shields etc.
            BaseClass.OnScriptBitSet(self, bit)
        end
    end,

    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is unpaused, remote-links are re-established.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnScriptBitClear = function(self, bit)
        --# Gilbot-X says: I added this to call my code
        if bit == 4 then --# production pause toggle
            self:OnRemoteAdjacencyUnpaused()
        else
            --# Base class version will deal with shields etc.
            BaseClass.OnScriptBitClear(self, bit)
        end
    end,
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is paused, ACU destroys all
    --#* Internetwork objects leaving the physical network
    --#* unchanged so that bonuses are just not propogated.
    --#**
    OnRemoteAdjacencyPaused = function(self, immediateBool)
       self.InterNetworkMappingEnabled= false
       self:SwitchOffResourceInterNetworks()
    end,
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is unpaused, ACU tries to map 
    --#* Internetwork objects onto the physical network
    --#* so that these bonuses are propogated.
    --#**
    OnRemoteAdjacencyUnpaused = function(self)
        self.InterNetworkMappingEnabled = true
        if not self.FindNewRemoteBridgesThread then
            self.FindNewRemoteBridgesThread = ForkThread(
                self.MapNewSubInterNetworks, self
            )
        end
    end,
    
   
} --(end of class definition)

return resultClass

end