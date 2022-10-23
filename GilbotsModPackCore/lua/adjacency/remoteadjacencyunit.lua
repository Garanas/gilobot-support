--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/remoteadjacencyunit.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Definition of remote-link units using beams,
--#**              common to all factions except Seraphim.
--#** 
--#****************************************************************************


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
function MakeRemoteAdjacencyUnit(baseClassArg) 

local BaseClass = baseClassArg
local resultClass = Class(BaseClass) {

    --# This constant shared variable provides a convenient means 
    --# of testing any object to see if it uses this class.
    IsRemoteAdjacencyUnit = true,

    
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
    end,

    
        
    --#*
    --#*  Gilbot-X says: 
    --#*  
    --#*  I added this function in AdjacencyStructureUnit to be called 
    --#*  from my override of OnStopBeingBuilt to apply
    --#*  adjacency as soon as the structures are built.
    --#*  This only runs once in a structure's lifetime.
    --#    
    --#*  This override is the same as the version in the 
    --#*  AdjacencyStructureUnit class, except here we try for remote
    --#*  Adjacency at the end.
    --#**
    AddExtendedAdjacencyToNearbyUnits = function(self)
        --# Call base class version first if one exists
        if self.IsAdjacencyStructureUnit then
            BaseClass.AddExtendedAdjacencyToNearbyUnits(self)
        end
        --# Fork a thread so there can be  a pause after between each 
        --# remote adjacency is connected.
        ForkThread(self.FindAndCreateRemoteAdjacencyConnections, self)
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
    
    end,
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from FindAndCreateRemoteAdjacencyConnections 
    --#*  between each call to TryToGiveOrReceiveRemoteAdjacency 
    --#*  in this class or any overrides.  We may have found a list of units
    --#*  to add, but some still on the list to be added might have already 
    --#*  joined our internetwork when we added one before it that had 
    --#*  a remote connection to it.
    --#**
    CheckAgainIfNowOnOurInterNetwork = function(self, nearbyUnitArg)
      
      --# Don't connect to a unit or network that we are already connected to.
        if self.MyNetwork and self.MyNetwork.MyInterNetwork and
            nearbyUnitArg.MyNetwork and nearbyUnitArg.MyNetwork.MyInterNetwork and
              (self.MyNetwork.MyInterNetwork == nearbyUnitArg.MyNetwork.MyInterNetwork)
        then 
            --# Notify calling code of the following:
            --# These two units should not get a remote adjacency 
            --# connection as the connection would be redundant.
            return true
        end
        --# Notify calling code of the following:
        --# Connecting these 2 units would not be redundant.
        return false
    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from FindAndCreateRemoteAdjacencyConnections in this class.
    --#*  That function is always forked as a thread, and so this runs in that thread.
    --#*
    --#*  Unlike the calling function, this code gets executed 
    --#*  more than once: if networks are broken it gets called again.
    --#*
    --#*  Therefore this function separates the code into reusable sections
    --#*  and makes the code more readable.
    --#**
    CheckIfEligibleForRemoteAdjacency = function(self, nearbyUnitArg)
        
        --# Each remote adjacency unit has to filter
        --# what types of unit it can connect to.
        if not self:CheckUnitLayerandTypeAcceptable(nearbyUnitArg) then
            return false
        end
        
        --# Avoid redundant connections
        if self:CheckWouldConnectionBeRedundant(nearbyUnitArg) then
            return false
        end
        
        --# If these units are in one of each other's ranges 
        --# then return that range or false if out of range
        return self:CheckIsInRemoteRange(nearbyUnitArg)
        
    end,
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from CheckIfEligibleForRemoteAdjacency in this class.
    --#*
    --#*  If these units are in one of each other's ranges 
    --#*  then return that range or false if out of range
    --#**
    CheckUnitLayerandTypeAcceptable = function(self, nearbyUnitArg)
        
        --# Only connect to units in specified layers
        local nearbyUnitLayer = nearbyUnitArg:GetCurrentLayer() 
        if not self.CanConnectToLayers[nearbyUnitLayer] then return false end
        
        --# Check for flags on units that explicitly disallow remote connections
        if nearbyUnitArg.IsNotRemoteAdjacencyReceiver then 
            return false
        end
        if not nearbyUnitArg.IsAdjacencyUnit then 
            return false
        end
        if self.OnlyConnectToOtherRemoteAdjacencyUnits and
            not nearbyUnitArg.IsRemoteAdjacencyUnit then 
            return false
        end
        --# Notify calling code of the following:
        --# The proposed unit type is acceptable
        return true
    end,

   
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from CheckIfEligibleForRemoteAdjacency in this class.
    --#*
    --#*  If these units are in one of each other's ranges 
    --#*  then return that range or false if out of range
    --#**
    CheckWouldConnectionBeRedundant = function(self, nearbyUnitArg)
        --# Don't connect to ourself!
        if self == nearbyUnitArg
        --# Don't connect to a unit or network that we are already connected to.
        or self:CheckIfAlreadyConnected(nearbyUnitArg, 'Local') 
        or self:CheckIfAlreadyConnected(nearbyUnitArg, 'Remote') 
        or
          --# Don't join a local network we are already part of!
          ( self.MyNetwork and nearbyUnitArg.MyNetwork and 
              (self.MyNetwork == nearbyUnitArg.MyNetwork)
          )
          --# Don't join an internetwork we are already part of
        or 
          ( self.MyNetwork and self.MyNetwork.MyInterNetwork and
            nearbyUnitArg.MyNetwork and nearbyUnitArg.MyNetwork.MyInterNetwork and
              (self.MyNetwork.MyInterNetwork == nearbyUnitArg.MyNetwork.MyInterNetwork)
          )
        then 
            --# Notify calling code of the following:
            --# These two units should not get a remote adjacency 
            --# connection as the connection would be redundant.
            return true
        end
        --# Notify calling code of the following:
        --# Connecting these 2 units would not be redundant.
        return false
    end,
        
      

    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from CheckIfEligibleForRemoteAdjacency in this class.
    --#*
    --#*  If these units are in one of each other's ranges 
    --#*  then return that range or false if out of range
    --#**
    CheckIsInRemoteRange = function(self, nearbyUnitArg)
        --# Calculate maximum allowed separation based 
        --# on the remote adjacency ranges these units have.
        local myRange, yourRange = 0, 0
        
        --# Check if other pipeline unit is paused.
        if not nearbyUnitArg.IsRemoteAdjacencyPaused then 
            --# The other pipeline is not paused so use its max range.
            yourRange = nearbyUnitArg.RemoteAdjacencyAllowedSeparationDistance
        end
        --# Check if I'm paused.
        if not self.IsRemoteAdjacencyPaused then 
            --# I'm not paused so use my max range.
            myRange = self.RemoteAdjacencyAllowedSeparationDistance
        end
        --# Take the bigger of the two units' ranges as max.  
        local maxSeparationForAdjacency = math.max(myRange, yourRange)
                      
        --# If these units are in each other's range then
        separation = self:GetSeparationDistance(nearbyUnitArg)        
        if maxSeparationForAdjacency > 0 and 
          separation <= maxSeparationForAdjacency then
            return separation
        else
            return false
        end 
    end,
    
    
     
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from FindAndCreateRemoteAdjacencyConnections in this class.
    --#*  That function is always forked as a thread, and so this runs in that thread.
    --#*
    --#*  Unlike the calling function, this code gets executed 
    --#*  more than once: if networks are broken it gets called again.
    --#*
    --#*  Therefore this function separates the code into reusable sections
    --#*  and makes the code more readable.
    --#**
    TryToGiveOrReceiveRemoteAdjacency = function(self, nearbyUnitArg)
        --# This makes sure we don't join a network twice while 
        --# it is being rebuilt from a broken one and more nodes 
        --# are being added.
        while(nearbyUnitArg.MyNetwork.IsStillBeingReconstructed) do WaitTicks(5) end
        --# Connect units with a beam and swap adjacency bonuses
        self:OnRemotelyAdjacentTo(nearbyUnitArg)
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by AddExtendedAdjacencyToNearbyUnits
    --#*  defined above.  Each unit keeps a reference to the other.
    --#**
    OnRemotelyAdjacentTo = function(self, adjacentUnitArg)
    
    end,
    
    
   
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to mod this to make sure tables are cleaned up.
    --#*  Base class version cancels bonuses and cleans up effects.
    --#*  
    --#**
    OnNotRemotelyAdjacentTo = function(self, adjacentUnitArg)
    
    end,
    
    

    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is paused, remote-links are disabled.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnRemoteAdjacencyPaused = function(self, immediateBool)

    end,
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is unpaused, remote-links are re-established.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnRemoteAdjacencyUnpaused = function(self)

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
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by the slider control.
    --#*  It must update whatever property, feature or variable that 
    --#*  the slider control declared in this unit's BP file was designed to adjust.
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        
    end,
    
    
        
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by AddExtendedAdjacencyToNearbyUnits
    --#*  defined above.
    --#*
    --#*  No known issues with this function.
    --#*
    --#**
    GetSeparationDistance = function(self, adjacentUnitArg)
          
          local xSeparation = 0
          local zSeparation = 0
          
          local SB1 = self:GetSkirtBounds()
          local SB2 = adjacentUnitArg:GetSkirtBounds()
          
          --# If my top is below your bottom
          if SB1.UpperLeft.z > SB2.BottomRight.z then
              --# I am below you
              zSeparation = SB1.UpperLeft.z - SB2.BottomRight.z
          --# but if your top is below my bottom
          elseif SB2.UpperLeft.z > SB1.BottomRight.z then
              --# You are below me!!
              zSeparation = SB2.UpperLeft.z - SB1.BottomRight.z
          end 
          
          --# If my left side is to the right of your right side
          if SB1.UpperLeft.x > SB2.BottomRight.x then
              --# I am to the right of you
              xSeparation = SB1.UpperLeft.x - SB2.BottomRight.x
          --# But if your left side is to the right of my right side
          elseif SB2.UpperLeft.x > SB1.BottomRight.x then
              --# You are to the right of me
              xSeparation = SB2.UpperLeft.x - SB1.BottomRight.x
          end
          
          --# Use Pythagoras Theorem to find separation
          return math.sqrt(math.pow(xSeparation,2) + math.pow(zSeparation,2))
              
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called from CleanUpAdjacencyOnDeath in
    --#*  adjacencyunit.lua when the unit dies, is reclaimed 
    --#*  or captured.  Unit loses any remote connections.
    --#*
    --#** 
    CleanUpRemoteAdjacency = function(self)
        for kAdjacentUnit, vAdjacentUnit in self.AdjacentUnits['Remote'] do
            self:OnNotRemotelyAdjacentTo(vAdjacentUnit)
        end
    end,
    
   
} --(end of class definition)

return resultClass

end