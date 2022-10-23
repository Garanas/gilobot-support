--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/adjacencystructureunit.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  My redefinition of the StructureUnit class.
--#**              This imported by defaultunits.lua and the 
--#**              StructureUnit class includes this as a base class.
--#**              This style allows me to separate code for defaultunits 
--#**              into a new file.  There was already too much code in that file!
--#**
--#****************************************************************************

local MakeAdjacencyUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencyunit.lua').MakeAdjacencyUnit
local GilbotUtils = 
    import('/mods/GilbotsModPackCore/lua/utils.lua')
local ApplyPositionCorrection = 
    import('/mods/GilbotsModPackCore/lua/positioncorrections.lua').ApplyPositionCorrection
local EffectUtil = 
    import('/lua/EffectUtilities.lua')
local ResourceNetwork = 
    import('/mods/GilbotsModPackCore/lua/adjacency/resourcenetwork.lua').ResourceNetwork
local AdjacencyBonusTypes = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencybonustypes.lua').AdjacencyBonusTypes
local Buff = 
    import('/lua/sim/Buff.lua')
local AdjacencyBuffs = 
    import('/lua/sim/AdjacencyBuffs.lua')    
local SeraphimAdjacencyEffects = 
    import('/lua/EffectTemplates.lua').SAdjacencyAmbient01

local debugAdjacencyCode = false
    
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeAdjacencyStructureUnit(baseClassArg)

local BaseClass = MakeAdjacencyUnit(baseClassArg)
local resultClass = Class(BaseClass) {

--[[

Gilbot-X says: 
  
In the code that follows, the first 3 fields are settings that only take effect when your ACU has died.  They govern the maximum x or z separation between our unit skirt and the centre of position of a nearby unit that can be checked and then qualify for extended adjacency!

Note that this fetch rectangle is also used for checking if units have Diagonal adjacency, so if you set it to zero then you get no diagonal adjacency.  I recommend 5 as a minimum, that will make sure that all GPG units in patch 3260 can at least get diagonal adjacency.

Keeping this number as small as possible while not skipping any valid adjacency opportunities will optimise performance!

You need to allow for the larger skirt sizes of things you might want to catch in the rectangle, 
i.e. factories, T3 powergens, T3 arty and Quantum gates.

These are some example skirt sizes:
1 = T1 point defense
2 = T1 Powergen, T1 Massfab
6 = T2 Powergen, T3 Mass Fab
8 = Factory, T3 Powergen, T3 Arty
10 = Quantum Gateway
 
My settings:
  
    MaxRemoteAdjacencyAllowedWithoutACU_ModSetting = 8,
    MaxSkirtXFromCentre_ModSetting = 5, 
    MaxSkirtZFromCentre_ModSetting = 5, 
   
Setting above mean that you can give extended adjacency to a Quantum Gateway that is up to 8 o-grids away. Alternatively it means a T1 Massfab that is up to (5+8)-1 = 12 o-grids away.
    
The calculations assume you need half the skirt-size to get the unit's position in the fetch rectangle, because normally position is taken at (or very near) the centre of the skirt. It could even give diagonal adjacency to a unit with skirtsize of (5+8)*2 = 26!  That's 260% of a Quantum Gateway's size!!
 
As a rule of thumb, for skirt settings, take the largest skirt size of any structure in the game and set this value to half of that. There is a +1 added in the calculation just to be safe for units whose reference positions aren't perfectly in the centre of their skirts.

]]
    MaxRemoteAdjacencyAllowedWithoutACU_ModSetting = 8,
    MaxSkirtXFromCentre_ModSetting = 5, 
    MaxSkirtZFromCentre_ModSetting = 5, 
    
    AllowDiagonalAdjacency_ModSetting = true,
--[[    

The 4 fields above are mod settings.  The values can be changed.  See text above.


    
]]
    
    --# Constant variables are declared here.
    --# This next variable makes it easy to check which units 
    --# can get extended adjacency (and which can't).
    IsAdjacencyStructureUnit = true,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# Perform original class version first
        BaseClass.OnCreate(self)
        
        --# T1 Point Defenses and AA Towers occupy same O-Grid as
        --# a T1 power generator so let them qualify for direct adjacency in same way
        if EntityCategoryContains(categories.TECH1 * categories.STRUCTURE * 
            (categories.ANTIAIR + categories.DIRECTFIRE), self) 
        then 
            --# Mark this unit as it needs special treatment
            self.IsOffsetStructure = true
            self.IsT1PDorAA = true 
            if self:GetBlueprint().General.FactionName == 'Seraphim' then
                self.IsSeraphimT1PDorAA = true 
            end
        end
        
        if EntityCategoryContains(categories.SONAR * categories.STRUCTURE, self) 
        then 
            --# Mark this unit as it needs special treatment
            self.IsSonarStructure = true
            self.AttachBeamToCentre = true
            self.IsOffsetStructure = true
        end
        
        if EntityCategoryContains(categories.ANTINAVY * categories.STRUCTURE
                                * categories.TECH1, self) 
        then 
            --# Mark this unit as it needs special treatment
            self.IsAntiNavyStructure = true
            self.AttachBeamToCentre = true
            self.IsOffsetStructure = true
        end
        
        if EntityCategoryContains(categories.ANTINAVY * categories.STRUCTURE
                                * categories.TECH2, self) 
        then 
            --# Mark this unit as it needs special treatment
            self.IsAntiNavyStructure = true
            self.AttachBeamToCentre = true
        end
        
        
        if EntityCategoryContains(categories.NAVAL * categories.FACTORY, self) 
        then 
            --# Mark this unit as it needs special treatment
            self.IsNavalFactory = true
            self.IsOffsetStructure = true
        end
    end,
    

 
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from my override of OnStopBeingBuilt to apply
    --#*  adjacency as soon as the structures are built.
    --#*  This only runs once in a structure's lifetime.
    --#*  
    --#*  This version records which units our structure 
    --#*  has adjacency with already and adds diagonal 
    --#*  adjacency where allowed/applicable.
    --#**
    AddExtendedAdjacencyToNearbyUnits = function(self)
    
        local structureTable = self:GetNearbyFriendlyStructures('IsAdjacencyStructureUnit')
        for kNearbyUnit, vNearbyUnit in structureTable do
                
            --# Next we will check if any skirt boundaries coincide.
            local hasGPGAdjacency, hasDiagonalAdjacency = 
                    self:CheckForDirectAdjacency(vNearbyUnit)
            
            --# We record these so we don't give them extended adjacency 
            --# because that would be giving them adjacency a second time!
            if hasGPGAdjacency then
                self:AddToEachOthersAdjacencyTables(vNearbyUnit, 'GPG')
            
            --# We give these extended adjacency if the mod setting is set.
            elseif hasDiagonalAdjacency and self.AllowDiagonalAdjacency_ModSetting then 
                --# Debugging only
                if debugAdjacencyCode then
                    self:AdjacencyLog('Unit ' .. self.DebugId 
                    .. ' is diagonally Adjacent to ' .. vNearbyUnit.DebugId)
                end
                --# Make sure there are appropriate tables.
                self:AddToEachOthersAdjacencyTables(vNearbyUnit, 'Diagonal') 
                --# Apply adjacency as if these were actually adjacent
                self:OnAdjacentTo(vNearbyUnit)  
            end
	end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from AddExtendedAdjacencyToNearbyUnits below.
    --#*  It separates the code into resuable sections
    --#*  and makes the code more readable.
    --#**
    GetDirectAdjacencyBoundsForT1PDorAAStructure = function(self)
          
        --# Don't recalculate, as structures don't move!
        if not self.MyDirectAdjacencySkirtBounds then 
        
            --# This will give us a MySkirtBounds variable.
            local mySkirtBounds = self:GetSkirtBounds()
  
            --# Need to extend skirtbounds by 0.5 in each direction
            --# so they can link with each other and larger structures
            self.MyDirectAdjacencySkirtBounds = {
                UpperLeft = {
                    x = mySkirtBounds.UpperLeft.x  - 0.5,
                    z = mySkirtBounds.UpperLeft.z  - 0.5,
                },
                BottomRight = {
                    x = mySkirtBounds.BottomRight.x + 0.5,
                    z = mySkirtBounds.BottomRight.z + 0.5,
                },
            }
        end
        
        --# Debugging Only
        if debugAdjacencyCode then
          self:AdjacencyLog(self.DebugId
            .. ': My skirtbound2: UL:'
              .. ' x=' .. self.MyDirectAdjacencySkirtBounds.UpperLeft.x
              .. ' z=' .. self.MyDirectAdjacencySkirtBounds.UpperLeft.z .. ' BR:'
              .. ' x=' .. self.MyDirectAdjacencySkirtBounds.BottomRight.x
              .. ' z=' .. self.MyDirectAdjacencySkirtBounds.BottomRight.z)
        end
              
        --# This result is used by CheckForDirectAdjacency
        return self.MyDirectAdjacencySkirtBounds
    end,              
          
        
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from AddExtendedAdjacencyToNearbyUnits below.
    --#*  It separates the code into resuable sections
    --#*  and makes the code more readable.
    --#**
    CheckForDirectAdjacency = function(self, nearbyUnitArg)
           
          --# This stops units on seabed from linking with units on water
          --# where heights (y-position) can be very different!
          if self:GetCurrentLayer() ~= nearbyUnitArg:GetCurrentLayer() then return false, false end
          
          --# Next we will check if any skirt boundaries coincide.
          local hasGPGAdjacency = false
          local hasDiagonalAdjacency = false
          
          --# If both structures are T1 PD or AA or neither of them are then
          if (self.IsOffsetStructure and nearbyUnitArg.IsOffsetStructure)
            or ((not self.IsOffsetStructure) and (not nearbyUnitArg.IsOffsetStructure))
          then
              --# Use their normal skirt bounds
              hasGPGAdjacency, hasDiagonalAdjacency = 
                  self.CheckForTouching(
                      self:GetSkirtBounds(), 
                      nearbyUnitArg:GetSkirtBounds()
                  )
          --# Otherwise if one is a T1 PD/AA but not the other,
          elseif self.IsOffsetStructure then
              --# Adjust the skirt bounds of the T1 PD/AA
              hasGPGAdjacency, hasDiagonalAdjacency = 
                  self.CheckForTouching(
                      self:GetDirectAdjacencyBoundsForT1PDorAAStructure(), 
                      nearbyUnitArg:GetSkirtBounds())
              --# GPG code doesn't automatically give adjacency from a pipeline to a T1 PD/AA
              --# so we mark it as diagonal adjacency so we manage it ourselves
              if hasGPGAdjacency and nearbyUnitArg.IsPipeLineUnit then 
                  return false, true
              end
              
              --# This had to be added because of naval bases
              local doForce = self.ForceDiagonalAdjacency(
                  self:GetDirectAdjacencyBoundsForT1PDorAAStructure(), 
                  nearbyUnitArg:GetSkirtBounds())
              if doForce then 
                  --# Debugging only
                  if debugAdjacencyCode then
                    self:AdjacencyLog('Forcing diagonal adjacency between ' 
                      .. self.DebugId .. ' to ' .. nearbyUnitArg.DebugId
                    )
                  end
                  return false, true 
              end
                  
          else
              --# Adjust the skirt bounds of the T1 PD/AA
              hasGPGAdjacency, hasDiagonalAdjacency = 
                  self.CheckForTouching(
                      self:GetSkirtBounds(),
                      nearbyUnitArg:GetDirectAdjacencyBoundsForT1PDorAAStructure())
              --# GPG code doesn't automatically give adjacency from a pipeline to a T1 PD/AA
              --# so we mark it as diagonal adjacency so we manage it ourselves
              if hasGPGAdjacency and self.IsPipeLineUnit then 
                  return false, true
              end
              
              --# This had to be added because of naval bases
              local doForce = self.ForceDiagonalAdjacency(
                  self:GetSkirtBounds(),
                  nearbyUnitArg:GetDirectAdjacencyBoundsForT1PDorAAStructure())
              if doForce then 
                  --# Debugging only
                  if debugAdjacencyCode then
                    self:AdjacencyLog('Forcing diagonal adjacency between ' 
                      .. self.DebugId .. ' to ' .. nearbyUnitArg.DebugId
                    )
                  end
                  return false, true 
              end
          end
          
          --# Respond to calling function
          return hasGPGAdjacency, hasDiagonalAdjacency
          
      end,
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from AddExtendedAdjacencyToNearbyUnits below.
    --#*  It separates the code into resuable sections
    --#*  and makes the code more readable.
    --#**
    CheckForTouching = function(mySkirtBounds, nearbyUnitSkirtBounds)
           
          --# Next we will check if any skirt boundaries coincide.
          local oneSideIsFullyTouchingAnother = false
          local onlyCornersTouchOrPartOfOneSideIsTouchingAnother = false
          
          --# Check if the top of one touches the bottom of another
          if (mySkirtBounds.BottomRight.z == nearbyUnitSkirtBounds.UpperLeft.z) 
          or (mySkirtBounds.UpperLeft.z == nearbyUnitSkirtBounds.BottomRight.z) then
              --# if my left is equal to or right of your left,
              if (mySkirtBounds.UpperLeft.x >= nearbyUnitSkirtBounds.UpperLeft.x) then
                  --# and if my right is left or equal to your right
                  if (mySkirtBounds.BottomRight.x <= nearbyUnitSkirtBounds.BottomRight.x) then
                      --# I am smaller than you and within your skirtbounds.  
                      --# You will have received adjacency from GPG code.
                      oneSideIsFullyTouchingAnother = true
                  --# but if my left is at least left of your right or level with it
                  elseif (mySkirtBounds.UpperLeft.x <= nearbyUnitSkirtBounds.BottomRight.x) then
                      --# then we overlap or our corners touch 
                      onlyCornersTouchOrPartOfOneSideIsTouchingAnother = true
                  end
              end
              --# if your left is equal to or right of my left,
              if (nearbyUnitSkirtBounds.UpperLeft.x >= mySkirtBounds.UpperLeft.x) then
                  --# and if your right is left or equal to my right
                  if (nearbyUnitSkirtBounds.BottomRight.x <= mySkirtBounds.BottomRight.x) then
                      --# You are smaller than me and within my skirtbounds.  
                      --# You will have received adjacency from GPG code.
                      oneSideIsFullyTouchingAnother = true
                  --# but if your left is at least left of my right or level with it
                  elseif (nearbyUnitSkirtBounds.UpperLeft.x <= mySkirtBounds.BottomRight.x) then
                      --# then we overlap or our corners touch 
                      onlyCornersTouchOrPartOfOneSideIsTouchingAnother = true
                  end
              end

          --# Check if the left side of one touches the right side of another
          --# NB: Use elseif because the only way we can touch two sides is 
          --# to be touching the corner so we save ourselves checks and don't
          --# give structures with touching corners adjacency twice
          elseif (mySkirtBounds.BottomRight.x == nearbyUnitSkirtBounds.UpperLeft.x) 
          or (mySkirtBounds.UpperLeft.x == nearbyUnitSkirtBounds.BottomRight.x) then
              --# if my top is equal to or below your top,
              if (mySkirtBounds.UpperLeft.z >= nearbyUnitSkirtBounds.UpperLeft.z) then
                  --# and if my bottom is higher or level with your bottom
                  if (mySkirtBounds.BottomRight.z <= nearbyUnitSkirtBounds.BottomRight.z) then
                      --# I am smaller than you and within your skirtbounds.  
                      --# You will have received adjacency from GPG code.
                      oneSideIsFullyTouchingAnother = true
                  --# but if my top is at least above your bottom or level with it
                  elseif (mySkirtBounds.UpperLeft.z <= nearbyUnitSkirtBounds.BottomRight.z) then
                      --# then we overlap or our corners touch 
                      onlyCornersTouchOrPartOfOneSideIsTouchingAnother = true
                  end
              end
               --# if your top is equal to or below my top,
              if (nearbyUnitSkirtBounds.UpperLeft.z >= mySkirtBounds.UpperLeft.z) then
                  --# and if your bottom is higher or level with my bottom
                  if (nearbyUnitSkirtBounds.BottomRight.z <= mySkirtBounds.BottomRight.z) then
                      --# You are smaller than me and within my skirtbounds.  
                      --# You will have received adjacency from GPG code.
                      oneSideIsFullyTouchingAnother = true
                  --# but if your top is at least above my bottom or level with it
                  elseif (nearbyUnitSkirtBounds.UpperLeft.z <= mySkirtBounds.BottomRight.z) then
                      --# then we overlap or our corners touch 
                      onlyCornersTouchOrPartOfOneSideIsTouchingAnother = true
                  end
              end
          end
          
          --# Respond to calling function
          return oneSideIsFullyTouchingAnother, onlyCornersTouchOrPartOfOneSideIsTouchingAnother
          
    end,
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from AddExtendedAdjacencyToNearbyUnits below.
    --#*  It separates the code into resuable sections
    --#*  and makes the code more readable.
    --#**
    ForceDiagonalAdjacency = function(mySkirtBounds, nearbyUnitSkirtBounds)
           
          --# Next we will check if any skirt boundaries coincide.
          local oneSideIsFullyTouchingAnother = false
          
          --# Check if the top of one touches the bottom of another
          if  (  (mySkirtBounds.BottomRight.z == nearbyUnitSkirtBounds.UpperLeft.z) 
              or (mySkirtBounds.UpperLeft.z == nearbyUnitSkirtBounds.BottomRight.z)
              ) 
              --# if my left is equal to or right of your left,
              and ((mySkirtBounds.UpperLeft.x == nearbyUnitSkirtBounds.UpperLeft.x) or 
                  --# and if my right is left or equal to your right
                  (mySkirtBounds.BottomRight.x == nearbyUnitSkirtBounds.BottomRight.x)) then
                      --# You will not have received adjacency from GPG code.
                      --# This next block is for debugging only.
                      --# This can be delete wheh debugging is done.
                      return true
    
          --# Check if the left side of one touches the right side of another
          --# NB: Use elseif because the only way we can touch two sides is 
          --# to be touching the corner so we save ourselves checks and don't
          --# give structures with touching corners adjacency twice
          elseif ( (mySkirtBounds.BottomRight.x == nearbyUnitSkirtBounds.UpperLeft.x) 
                or (mySkirtBounds.UpperLeft.x == nearbyUnitSkirtBounds.BottomRight.x)
                 )
              --# if my top is equal to or below your top,
              and ((mySkirtBounds.UpperLeft.z == nearbyUnitSkirtBounds.UpperLeft.z) or 
                  (mySkirtBounds.BottomRight.z == nearbyUnitSkirtBounds.BottomRight.z)) then
                  return true 
          end
          
          --# Respond to calling function
          return false
    end,
  
   
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  I give an effect to T1 Seraphim PD and AA units
    --#*  when they become adjacent to one another.
    --#*  They can be linked so closely that there isn't room
    --#*  to put hubs between them, so they themselves get
    --#*  a radiating effect to show they have adjacency
    --#*
    --#**
    CleanUpSeraphimPDToPDAdjacencyEffects = function(self)
   
        --# This links to code in effect until for seraphim
        if self.IsSeraphimT1PDorAA then
            --# Check if it's adjacent to another Seraphim T1 PD or AA
            local hasSeraphimT1PDInLocalAdjacencyTable = false
            for kUnusedArrayIndex, vUnit in self.AdjacentUnits['Local'] do
                if vUnit.IsSeraphimT1PDorAA then
                    hasSeraphimT1PDInLocalAdjacencyTable = true
                    break
                end
            end
            if not hasSeraphimT1PDInLocalAdjacencyTable then
                --# Allow effect to be added next time
               self:RemoveSeraphimPDToPDEffect()
            end
        end
    end,
   
   
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  I give an effect to T1 Seraphim PD and AA units
    --#*  when they become adjacent to one another.
    --#*  They can be linked so closely that there isn't room
    --#*  to put hubs between them, so they themselves get
    --#*  a radiating effect to show they have adjacency
    --#*
    --#**
    CreateSeraphimPDToPDEffect = function(self)
        --# Avoid duplicate effects
        if not self.HasT1PDAdjacencyEffect then
            self.SeraphimT1PDAdjacencyEffects = TrashBag()
            local army = self:GetArmy()
            for k, vEmit in SeraphimAdjacencyEffects do
                emit = CreateAttachedEmitter( self, 0, army, vEmit )
                self.SeraphimT1PDAdjacencyEffects:Add(emit)
                self.Trash:Add(emit)
            end
            self.HasT1PDAdjacencyEffect = true
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  I give an effect to T1 Seraphim PD and AA units
    --#*  when they become adjacent to one another.
    --#*  They can be linked so closely that there isn't room
    --#*  to put hubs between them, so they themselves get
    --#*  a radiating effect to show they have adjacency
    --#*
    --#**
    RemoveSeraphimPDToPDEffect = function(self)
        if self.HasT1PDAdjacencyEffect then
            --# Destroy our effect
            self.SeraphimT1PDAdjacencyEffects:Destroy()
            self.SeraphimT1PDAdjacencyEffects = nil
            self.HasT1PDAdjacencyEffect = false
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from the ResourceNetwork class.
    --#**
    CheckIfUnitIsBridgeInNetwork = function(self)
        
        --# Need to be connected to at least 2 other units to be a bridge.
        if self:GetNumberOfConnectedUnits('Local') < 2 then 
            self.IsNonRedundantBridgeInNetwork = false
            return false 
        end
        
        --# For every unit we are connected to in this network,
        for unusedArrayIndex1, vAdjacentUnit1 in self.AdjacentUnits['Local'] do
            --# For every other unit we can pair it with in this network,
            for unusedArrayIndex2, vAdjacentUnit2 in self.AdjacentUnits['Local'] do
                --# (Don't pair a unit with itself)
                if vAdjacentUnit1 ~= vAdjacentUnit2 then
                    --# If these units are not connected to each other directly then
                    if not vAdjacentUnit1:CheckIfAlreadyConnected(vAdjacentUnit2, 'Local') then 
                        
                        --# We found a bridge.
                        --# This next block is for debugging only.
                        --# This can be delete wheh debugging is done.
                        if false and debugAdjacencyCode then 
                            self:AdjacencyLog('Unit ' .. self.DebugId 
                            .. ' is a bridge in a network' 
                            .. ' between ' .. vAdjacentUnit1.DebugId 
                            .. ' and ' .. vAdjacentUnit2.DebugId
                            )
                        end
                        
                        --# Check if these two units are bridged indirectly by another unit.
                        if not self:CheckIfUnitsHaveAlternateBridgeInNetwork(
                                  vAdjacentUnit1, vAdjacentUnit2
                               ) 
                        then
                            --# Alert user, calling code and record result
                            self.IsNonRedundantBridgeInNetwork = true
                            --# This next block is for debugging only.
                            --# This can be delete wheh debugging is done.
                            if false and debugAdjacencyCode then 
                                self:AdjacencyLog('Unit ' .. self.DebugId 
                                .. ' is Non-redundant bridge in a network '
                                .. ' between ' .. vAdjacentUnit1.DebugId 
                                .. ' and ' .. vAdjacentUnit2.DebugId
                                )
                            end
                            return true
                        end
                    end
                end
            end
        end
        
        --# Didn't find any bridges
        self.IsNonRedundantBridgeInNetwork = false
        return false
    end,
         

         
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from the ResourceNetwork class.
    --#**
    CheckIfUnitsHaveAlternateBridgeInNetwork = function(self, unitArg1, unitArg2)
        
        --# look at every unit that the first node is connected to in this network,
        --# as each one can be a bridge from the first unit to the second.
        for unusedArrayIndex1, vPotentialBridgingUnit in unitArg1.AdjacentUnits['Local'] do
            --# (Ignore the first bridge found before calling this function)
            if vPotentialBridgingUnit ~= self then
                --# Look at all units it could be connecting indirectly to via this bridge
                for unusedArrayIndex2, vIndirectlyConnectedUnit in
                                              vPotentialBridgingUnit.AdjacentUnits['Local'] do
                    --# If this potential bridge is indirectly connecting 
                    --# the first unit to the second, then                     
                    if vIndirectlyConnectedUnit == unitArg2 then
                        
                        --# This next block is for debugging only.
                        --# This can be delete wheh debugging is done.
                        if false and debugAdjacencyCode then 
                            self:AdjacencyLog('Unit ' .. vPotentialBridgingUnit.DebugId 
                            .. ' Is alternate bridge bewteen units ' .. unitArg1.DebugId
                            .. ' and ' .. unitArg2.DebugId .. ' In Network.')
                        end
                        --# There is an alternate bridge in the network,
                        --# in other words, we are a *redundant* bridge.
                        return true
                    end
                end
            end
        end
        
        --# Didn't find any alternate bridges
        return false
    end,
    
    

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by 
    --#*  GetNearbyFriendlyStructures
    --#*
    --#**
    GetSearchRectangleXZCoordinates = function(self)
    
        local maxSkirtXFromCentre, maxSkirtZFromCentre = 4, 4
        local offset = self.RemoteAdjacencyAllowedSeparationDistance
    
        --# Experimental approach to improving efficiency 
        --# that works while ACU is alive : Need to test ???????
        local myCommander = self:GetMyCommander()
        --# If commander is alive...
        if myCommander then
            --# Give this to ACU who will decide if thsi is the largest range
            myCommander:ReceiveACUMessage_SetMaxAdjacencyRangeEncounteredSoFar(
                self.RemoteAdjacencyAllowedSeparationDistance
            )
            --# ACU tells us the largest offset this army is capable of.
            offset = 
                math.max(myCommander:ReceiveACUMessage_GetMaxAdjacencyRangeEncounteredSoFar() or 0, offset)
            
            --# ACU tells us highest values for skirt sizes
                maxSkirtXFromCentre, maxSkirtZFromCentre = 
                    myCommander:ReceiveACUMessage_GetMaxSkirtBoundsEncounteredSoFar()
        else
            --# Without ACU alive, use the defaults defined at the top of the file, 
            --# unless the unit looking for adjacency has higher values itself.
            --# Thus we see the new role of ACU as information coordinator
            --# who can improve army efficiency.  Some connections might not be made
            --# automatically without the ACU alive.
            offset = math.max(offset, self.MaxRemoteAdjacencyAllowedWithoutACU_ModSetting)
            maxSkirtXFromCentre = math.max(maxSkirtXFromCentre, self.MaxSkirtXFromCentre_ModSetting)
            maxSkirtZFromCentre = math.max(maxSkirtZFromCentre, self.MaxSkirtZFromCentre_ModSetting)
        end
        
        
        --# This will give us the MySkirtBounds variable to use below.
        mySkirtBounds = self:GetSkirtBounds()
 
        --# Get nearby units to check for touching adjacency
	local x1 = mySkirtBounds.UpperLeft.x - (1+offset+maxSkirtXFromCentre)
	local z1 = mySkirtBounds.UpperLeft.z - (1+offset+maxSkirtZFromCentre)
	local x2 = mySkirtBounds.BottomRight.x + (1+offset+maxSkirtXFromCentre)
	local z2 = mySkirtBounds.BottomRight.z + (1+offset+maxSkirtZFromCentre)
	
        return Rect(x1, z1, x2, z2)
    end,
        
    

} --(end of class definition)

return resultClass

end