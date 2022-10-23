--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/adjacencyunit.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  My redefinition of the StructureUnit class.
--#**              This imported by defaultunits.lua and the 
--#**              StructureUnit class includes this as a base class.
--#**              This style allows me to separate code for defaultunits 
--#**              into a new file.  There was already too much code in that file!
--#**
--#****************************************************************************

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

    
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeAdjacencyUnit(baseClassArg) 

local BaseClass = baseClassArg
local resultClass = Class(BaseClass) {
    
    --# Constant variables are declared here.
    --# This next variable makes it easy to check which units 
    --# can get extended adjacency (and which can't).
    IsAdjacencyUnit = true,
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
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# Perform original class version first
        BaseClass.OnCreate(self)
        
        --# Do non-static variable initialization
        self.AdjacentUnits = {
            GPG = {},
            Diagonal = {},
            Remote = {},
            Local = {},
        }
        
        --# This is for adjacency beam effects
        self.AdjacencyBeamsBag = {}
        
        --# This needs to be called for ResourceNetworks to function.
        self:InitialiseBonusMarkers()
    
        --# This is the only time we check the BP for this value
        --# but every structure unit does it, so we don't need to do it again.
        --# (the slider mod might check it).
        self.RemoteAdjacencyAllowedSeparationDistance = 
            self:GetBlueprint().AdjacencySettings.AdjacencyExtensionDistance or 0
            
        --# If the Pipeline is no longer working for us,
        --# the callback updates its status.
        self:AddOnCapturedCallback(self.CleanUpAdjacencyOnDeath)
        
    end,

    ApplyAdjacencyBuffs = function() end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnStopBeingBuilt so I could 
    --#*  check for extended adjacency at this time.
    --#** 
    OnStopBeingBuilt = function(self,builder,layer)
        --# Perform original class version first
        BaseClass.OnStopBeingBuilt(self,builder,layer)
        
        --# This will give us a MySkirtBounds variable.
        self:GetSkirtBounds()
        --# For debugging only
        if false and self.DebugAdjacencyCode then self:DumpSkirtBounds() end
        
        --# If ACU is not alive then don't allow any more adjacency.
        local myCommander = self:GetMyCommander() 
        if myCommander then 
            if self.IsRemoteAdjacencyBeamUnit then
                myCommander:ReceiveACUMessage_RegisterUnit(self, 'RemoteAdjacencyBeamUnit')
            end
            
            --# Seraphim units should check for an adjacency field tower
            --if self:GetBlueprint().General.FactionName == 'Seraphim' then
                myCommander:ReceiveACUMessage_ConnectMeWithAnyAdjacencyFieldSource(self)
            --end
            if self.AddExtendedAdjacencyToNearbyUnits then 
                --# Try to add extended adjacency
                ForkThread(
                    function(self)
                        --# Need to wait just in case we
                        --# just upgraded!
                        WaitSeconds(1)
                        self:AddExtendedAdjacencyToNearbyUnits()
                    end, self
                )
            end
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    InitialiseBonusMarkers = function(self)
    
        --# These tables are used by Resource Networks
        self.IsAdjacencyBonusReceiver = {}
        self.IsAdjacencyBonusGiver = {}
  
        --# How we add the unit depending on its type.
    	if self.IsPipeLineUnit then return end
        
        --# Populate tables above 
        --# based on what this unit can receive
        self:MarkAdjacencyBonusesUnitCanReceive()
        self:MarkAdjacencyBonusesUnitCanGive()
    end,
    
   
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  Populate the IsAdjacencyBonusReceiver table with bonus types 
    --#*  based on what adjacency bonuses this unit can receive.
    --#*
    --#*  No known issues with this function.
    --#**
    MarkAdjacencyBonusesUnitCanReceive = function(self)
        --# For some types of adjacency bonus, 
        --# unit blueprints are used for checking if the 
        --# unit can receive that type of bonus.
        --# Weapon and shield bonuses are the exception. 
        local bp = self:GetBlueprint()
      
        if (bp.Economy.BuildableCategory and 
            table.getn(bp.Economy.BuildableCategory) > 0 
           )
        or EntityCategoryContains(categories.SILO, self)
        then
            self.IsAdjacencyBonusReceiver['EnergyActive'] = true
            self.IsAdjacencyBonusReceiver['MassActive'] = true
        end
        
        if bp.Economy.ProductionPerSecondEnergy and 
           bp.Economy.ProductionPerSecondEnergy > 0 then
            self.IsAdjacencyBonusReceiver['EnergyProduction'] = true
        end
        
        if bp.Economy.ProductionPerSecondMass and 
           bp.Economy.ProductionPerSecondMass > 0 then
            self.IsAdjacencyBonusReceiver['MassProduction'] = true
        end
    
        if bp.Economy.MaintenanceConsumptionPerSecondEnergy or 
          self.EnergyMaintenanceConsumptionOverride then
            self.IsAdjacencyBonusReceiver['EnergyMaintenance'] = true
        end

        if bp.Economy.MaintenanceConsumptionPerSecondMass or
          self.MassMaintenanceConsumptionOverride then
            self.IsAdjacencyBonusReceiver['MassMaintenance'] = true
        end
        
        local weaponCount = self:GetWeaponCount()
        if weaponCount > 0 then
            for i = 1, weaponCount do
                local wep = self:GetWeapon(i)
                 --# Don't tell us the rate of fire of dummy weapons.
                local weaponBP = wep:GetBlueprint()
                if weaponBP.RateOfFire 
                  and (weaponBP.Label ~= 'Charge')
                  and (weaponBP.Label ~= 'CloakFieldRadius')
                  and (weaponBP.Label ~= 'AdjacencyRange')
                  and (weaponBP.Label ~= 'RadarStealthFieldRadius')
                  and (weaponBP.WeaponCategory ~= 'Death') 
                  and (weaponBP.WeaponCategory ~= 'Kamikaze') 
                  and (not weaponBP.DummyWeapon)
                then
                    self.IsAdjacencyBonusReceiver['RateOfFire'] = true
                    if wep:WeaponUsesEnergy() then
                        self.IsAdjacencyBonusReceiver['EnergyWeapon'] = true
                    end
                end
            end
        end
        
        --# Testing self.MyShield didn't work here - 
        --# perhaps a race condition where shield wasn't created yet?
        if self.IsSensitiveShieldUser or 
          EntityCategoryContains(categories.SHIELD, self) then 
            --LOG('Gilbot: Unit ' .. self.DebugId .. ' gets ShieldStrength adjacency bonus.') 
            self.IsAdjacencyBonusReceiver['ShieldStrength'] = true
        end

    end,
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  Populate the IsAdjacencyBonusReceiver table with bonus types 
    --#*  based on what adjacency bonuses this unit can receive.
    --#*
    --#*  No known issues with this function.
    --#**
    MarkAdjacencyBonusesUnitCanGive = function(self)
        --# This unit needs an Adjacency table in its blueprint
        --# in order to give any adjacency bonuses.
        local adjacencyBPName = self:GetBlueprint().Adjacency
        if not adjacencyBPName then return end
        for k,vBuffName in AdjacencyBuffs[adjacencyBPName] do
            local buffDef = Buffs[vBuffName]
            if not buffDef then
                error("*ERROR: Tried to add a buff that doesn\'t exist! Name: ".. buffName, 2)
                return 
            end
        
            local buffAffects = buffDef.Affects
            for bonusTypeName, vals in buffAffects do
                self.IsAdjacencyBonusGiver[bonusTypeName] = true
            end
        end
    end,
        
        
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that tables are 
    --#*  cleaned up when a unit completes an upgrade and 
    --#*  destroys itself.
    --#*
    --#*  This function is defined in Unit.lua
    --#*  and ends by changing state to DeadState
    --#*  so I have to call my extra code before calling
    --#*  the base class code.
    --#**
    OnDestroy = function(self)
        --# Gilbot-X says:  
        --# I added this block of code so that when 
        --# units upgrade they get cleaned out of ResourceNetwork 
        --# tables and the ACU's auto-toggle tables.
        self:CleanUpAdjacencyOnDeath() 
             
        --# Finally the rest is GPG code.
        BaseClass.OnDestroy(self)
    end,
    
    

    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  by ResourceNetwork objects so that when they
    --#*  give this unit a reference to themselves,
    --#*  the unit can update its label if the display 
    --#*  is toggled on.
    --#**
    SetNetwork = function(self, networkArg)
        --# Store the network reference set
        self.MyNetwork = networkArg
        self:SyncNetworkNumbersDisplay()
    end,
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  by ResourceNetwork objects so that when they
    --#*  remove this unit's reference to themselves,
    --#*  the unit can update its label if the display 
    --#*  is toggled on.
    --#**
    ClearNetwork = function(self)
        --# Store the network reference set
        self.MyNetwork = nil
        self:SyncNetworkNumbersDisplay()
        self:StripBonuses()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called from both LocklAndStripBonusesFromAllUnits and 
    --#*  SalvageSubNetworksFromBrokenNetwork as it is code common to both.
    --#*  We inspect the list of remaining units in the old network and 
    --#*  turn off all their bonuses (pipeline units are ignored).
    --#**
    StripBonuses = function(self)
        --# Safety check
        if self.IsPipeLineUnit or not self:IsAlive() then return end
        --# Remove bonuses
        for bonusTypeIndex, bonusTypeName in AdjacencyBonusTypes do
            --# Remove all bonuses from this unit if it is not dead
            self:SetAdjacencyBonus(bonusTypeName, 0)
        end
        --# Remove all bonuses from this unit if it is not dead
        self:RequestRefreshUI()
    end,  
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  by ResourceNetwork objects they can update 
    --#*  this unit's network ID label if the display 
    --#*  is toggled on.  It is also called indirectly
    --#*  through calls to SetNetwork defined above.
    --#*  The option arg is used to clear the display
    --#*  without repeating redundant tests.
    --#**
    SyncNetworkNumbersDisplay = function(self, clearBool)
        local displayLines = {}
        --# Put a label on if requested
        --# If this unit is in a valid network
        if (not clearBool) and self.MyNetwork and 
          (not self.MyNetwork.IsBroken)
        then
            --# Put network id in label
            displayLines["1"] = 'N=' .. repr(self.MyNetwork.NetworkId) 
            
            --# Add internetwork ID if it has one
            if self.MyNetwork.MyInterNetwork and 
              not self.MyNetwork.MyInterNetwork.IsBroken 
            then 
                displayLines["2"] =  'I=' .. repr(self.MyNetwork.MyInterNetwork.InterNetworkId)
            end 
                      
        end
        --# Sync the new label
        self.Sync.NetworkDisplayText = displayLines
    end,
    
    
    
  

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by AddExtendedAdjacencyToNearbyUnits
    --#*  defined above.  Each unit keeps a reference to the other.
    --#**
    AddToEachOthersAdjacencyTables = function(self, adjacentUnitArg, tableKeyArg)
        --# Each unit keeps a reference to the other
        table.insert(self.AdjacentUnits[tableKeyArg], adjacentUnitArg)
        table.insert(adjacentUnitArg.AdjacentUnits[tableKeyArg], self)
    end,
    
  
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is required by OnNotAdjacentTo.
    --#*
    --#*  The last boolean argument to RemoveFromArrayByValue is optional.  
    --#*  It means don't destroy the empty table
    --#*  if last value is removed.  I think it's needed if we are 
    --#*  iterating through the table as it will stop the loop at the end of
    --#*  the table or when table is empty?
    --#**
    RemoveFromEachOthersAdjacencyTables = function(self, adjacentUnitArg, tableKeyArg)
    
        --# Take them out of our table.
        self.AdjacentUnits[tableKeyArg] = 
            GilbotUtils.RemoveFromArrayByValue(self.AdjacentUnits[tableKeyArg], 
                                                adjacentUnitArg, true)
        --# Take us out of their table.
        adjacentUnitArg.AdjacentUnits[tableKeyArg] = 
            GilbotUtils.RemoveFromArrayByValue(adjacentUnitArg.AdjacentUnits[tableKeyArg], 
                                                self, true)
    end,
    
    
    
     
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This overrided function is only called from inside
    --#*  function calls to OnAdjacentTo and OnNotAdjacentTo.
    --#*  It creates a single linking beam effect between two units.
    --#*
    --#*  I overrided this because GetEntityId doesn't work 
    --#*  in the way GPG tried to use it here.
    --#*  I had to remove code that tries to use the entity id as if it was a GUID.
    --#*  Unlike a GUID, entity IDs are reused as units die.
    --#*    
    --#*  Anyway it will only try to create an effect twice (once each way) maximum.
    --#*  If two units give and receive adjacency to each other, or are pipelines,
    --#*  then OnAdjacentTo is called twice.
    --#*
    --#**
    CreateAdjacentEffect = function(self, adjacentUnitArg)
                
        --# Create trashbag to hold all these entities and beams
        if not self.AdjacencyBeamsBag then
            WARN('Recreating adjacency beams bag.')
            self.AdjacencyBeamsBag = {}
        end
        
        --# This is an effect for seraphim only who don't get beams/hubs between T1 PD or AA
        if self.IsSeraphimT1PDorAA and adjacentUnitArg.IsSeraphimT1PDorAA then 
            self:CreateSeraphimPDToPDEffect()
            adjacentUnitArg:CreateSeraphimPDToPDEffect()
        else
            --# Make the beam.
            EffectUtil.CreateAdjacencyBeams(self, adjacentUnitArg, self.AdjacencyBeamsBag)
        end
    end,
    
   
   
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required to get rid of beams between units when 
    --#*  the adjacency is switched off. It's only called from inside
    --#*  class to OnAdjacentTo and OnNotAdjacentTo.
    --#*
    --#*  No known issues with this function.
    --#*
    --#** 
    CleanUpAdjacentEffectsWith = function(self, adjacentUnitArg)
    
        --# Safety check
        if not adjacentUnitArg then return end
    
        --# Remove any beam effect from you to me.
        --# Make sure they have a beam bag
        if adjacentUnitArg.AdjacencyBeamsBag then 
            --# Iterate through it till we find our beam
            for kBeamBagEntry, vBeamBagEntry in adjacentUnitArg.AdjacencyBeamsBag do
                if vBeamBagEntry then 
                    if vBeamBagEntry.Unit == self then
                        --# Destroy our beam
                        vBeamBagEntry.Trash:Destroy()
                        adjacentUnitArg.AdjacencyBeamsBag[kBeamBagEntry] = nil
                    end
                end
            end
        end
        
        --# Now destroy any beam effects originating from me to you.
        if self.AdjacencyBeamsBag then
            --# Iterate through it till we find our beam
            for kBeamBagEntry, vBeamBagEntry in self.AdjacencyBeamsBag do
                if vBeamBagEntry then 
                    if vBeamBagEntry.Unit == adjacentUnitArg then
                        --# Destroy our beam
                        vBeamBagEntry.Trash:Destroy()
                        self.AdjacencyBeamsBag[kBeamBagEntry] = nil
                    end
                end
            end
        end
        
        --# Remove any reference to each other in the tables
        self:RemoveFromEachOthersAdjacencyTables(adjacentUnitArg, 'Local')
        self:RemoveFromEachOthersAdjacencyTables(adjacentUnitArg, 'GPG')
        self:RemoveFromEachOthersAdjacencyTables(adjacentUnitArg, 'Diagonal')
    	self:RemoveFromEachOthersAdjacencyTables(adjacentUnitArg, 'Remote')
        
        --# This is for Seraphim units only.  I added these effects.
        if self.HasT1PDAdjacencyEffect then 
            self:CleanUpSeraphimPDToPDAdjacencyEffects() 
        end
        if adjacentUnitArg.HasT1PDAdjacencyEffect then 
            adjacentUnitArg:CleanUpSeraphimPDToPDAdjacencyEffects()
        end
    end,
    
   
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to mod this because OnNotAdjacentTo is called by the engine
    --#*  on the units it gave adjacency to, but not the ones I give    
    --#*  diagonal and remote adjacency to.  I make sure its called explicitly
    --#*  and I provide a safeguard against multiple calls to avoid duplicate side effects.  
    --#*
    --#*  This function is only called when a unit is captured, reclaimed, destroyed etc.
    --#**
    CleanUpAdjacencyOnDeath = function(self)
        
        --# Stop this from being called twice on same object.
        if not self.WasAlreadyCalled_CleanUpAdjacencyOnDeath then
            
            --# Stop this from being called twice on same object.
            self.WasAlreadyCalled_CleanUpAdjacencyOnDeath = true
            
            --# For debugging only, delete after
            self:AdjacencyLog('Cleaning Up Extended Adjacency on ' .. self.DebugId)
            
            --# Deal with remote adjacency first
            if self.IsRemoteAdjacencyUnit then
                --# Remove any remote links
                --# For debugging only, delete after
                self:CleanUpRemoteAdjacency()
                --# These RemoteAdjacencyBeamUnit units register with ACU when built,
                --# so they have to unregister when they are being destroyed, captured, etc.
            end
            
            --# Destroy beam effects from units giving me an adjacency bonus
            for kAdjacentUnit, vAdjacentUnit in self.AdjacentUnits['Diagonal'] do
                --# This is why I have a separate table for 'Diagonal' adjacency.
                --# because OnNotAdjacentTo always gets called by engine code
                --# on units that it decided were adjacent.  I have to call it 
                --# explicitly where I have decided additional units qualify.
                self:OnNotAdjacentTo(vAdjacentUnit)  
            end
            
            --# Just for safety, 
            --# Destroy effects from me to any adjacent units I gave a bonus to.
            if self.AdjacencyBeamsBag then
                for k, v in self.AdjacencyBeamsBag do
                    v.Trash:Destroy()
                end
            end
        end
    end,
    
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I moved the code here from StructureUnit class and add an entry
    --#*  for my new type of adjacency.  Call on thsi unit to see what 
    --#*  bonus value it will give to the other unit (supplied as an argument)
    --#*  for the type of bonus specified (as the other argument).
    --#*
    --#*  The original version returned 1 when there was no bonus in 
    --#*  the blueprint.  Now it returns 0 because the ResourceNetwork 
    --#*  class actually sums up the values that this function returns
    --#*  to get a modifier to apply to all units in the network 
    --#*  of this type.
    --#*
    --#*  No known issues with this function.
    --#**
    GetAdjacentBonus = function(self, adjacentUnit, bonusTypeName)
        local resultAdd, resultMult = 0, 0
        
        --# Pauseable production units (such as MassFabs, HCPP and 
        --# shield strengthening units) do not give bonuses when output is paused.
        if self.IsProductionPaused then return resultAdd, resultMult end
        
        --# This unit needs an Adjacency table in its blueprint
        --# in order to give any adjacency bonuses.
        local adjacencyBPName = self:GetBlueprint().Adjacency
        if not adjacencyBPName then return resultAdd, resultMult end
        for k,vBuffName in AdjacencyBuffs[adjacencyBPName] do
            local buffDef = Buffs[vBuffName]
            if buffDef and buffDef.EntityCategory then
                local cat = ParseEntityCategory(buffDef.EntityCategory)
                if EntityCategoryContains(cat, adjacentUnit) then
                    --# Apply any test functions in the buff definition
                    if buffDef.BuffCheckFunction and (not buffDef:BuffCheckFunction(adjacentUnit)) then
                        --LOG('Unit ' .. adjacentUnit.DebugId 
                        --.. ' failed BuffTest to receive ' .. repr(vBuffName)
                        --.. ' from unit ' .. self.DebugId 
                        --)
                    else
                        local buffAffects = buffDef.Affects
                        if buffAffects[bonusTypeName] then 
                            resultAdd = buffAffects[bonusTypeName].Add
                            resultMult = buffAffects[bonusTypeName].Mult or 1.0
                            --# The self.ModifierDifference key is set by stat slider controls
                            --# so we don't actually have to change the blueprint values
                            if self.ModifierDifference then 
                                resultAdd = resultAdd + 
                                    (self.ModifierDifference[buffDef.EntityCategory].Add or 0)
                                resultMult = resultMult + 
                                    (self.ModifierDifference[buffDef.EntityCategory].Mult or 0)
                            end
                        end
                    end
                end
            end
        end
        
        --# This is new for FA.
        --# It means that directly connected units give each other full bonuses
        --# but indirectly connected units on the same local network get
        --# half the bonus, where as units connected remotely on 
        --# separate local networks give 25% of full bonus.
        local attenuationFactor = 1
        if not self:CheckIfAlreadyConnected(adjacentUnit, 'Local') then 
            if self.MyNetwork.NetworkId == adjacentUnit.MyNetwork.NetworkId
            then attenuationFactor = 0.5
            else attenuationFactor = 0.25
            end
        end
         
        --# We should have worked out the bonus now.
        return resultAdd * attenuationFactor, math.pow(resultMult, attenuationFactor)
    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I overrided this function so we are not adding
    --#*  or taking away from the previous bonus, we are
    --#*  setting it outright.  I can do this because
    --#*  each unit can only receive bonuses from one source: 
    --#*  i.e. the network it is attached to.
    --#*
    --#*  No known issues with this function.
    --#**
    SetAdjacencyBonus = function(self, bonusTypeName, bonusAdd)
        
        local oldValue, newValue = 0,0
        if bonusTypeName == 'MassActive' then
            oldValue = self.MassBuildAdjMod or 1
            self.MassBuildAdjMod = 1 + bonusAdd
            newValue = self.MassBuildAdjMod
            self:UpdateConsumptionValues()
        
        elseif bonusTypeName == 'EnergyActive' then
            oldValue = self.EnergyBuildAdjMod or 1
            self.EnergyBuildAdjMod = 1 + bonusAdd
            newValue = self.EnergyBuildAdjMod
            self:UpdateConsumptionValues()
        
        elseif bonusTypeName == 'MassMaintenance' then
            oldValue = self.MassMaintAdjMod or 1
            self.MassMaintAdjMod = 1 + bonusAdd
            newValue = self.MassMaintAdjMod
            self:UpdateConsumptionValues()
        
        elseif bonusTypeName == 'EnergyMaintenance' then
            oldValue = self.EnergyMaintAdjMod or 1
            self.EnergyMaintAdjMod = 1 + bonusAdd
            newValue = self.EnergyMaintAdjMod
            self:UpdateConsumptionValues()
        
        elseif bonusTypeName == 'MassProduction' then
            oldValue = self.MassProdAdjMod or 1
            self.MassProdAdjMod = 1 + bonusAdd
            newValue = self.MassProdAdjMod
            self:UpdateProductionValues()
        
        elseif bonusTypeName == 'EnergyProduction' then
            oldValue = self.EnergyProdAdjMod or 1
            self.EnergyProdAdjMod = 1 + bonusAdd
            newValue = self.EnergyProdAdjMod
            self:UpdateProductionValues()
        
        elseif bonusTypeName == 'EnergyWeapon' then
            for i = 1, self:GetWeaponCount() do
                local wep = self:GetWeapon(i)
                if wep:WeaponUsesEnergy() then
                    oldValue = wep.AdjEnergyMod or 1
                    wep.AdjEnergyMod = 1 + bonusAdd
                    newValue = wep.AdjEnergyMod
                end
            end
            
        elseif bonusTypeName == 'RateOfFire' then
            for i = 1, self:GetWeaponCount() do
                local wep = self:GetWeapon(i)
                if wep.CanUpdateRateOfFireFromBonuses then
                    --# Set bonus on weapon so it is listed with other bonuses
                    oldValue = wep.LastRateOfFireAdjacencyBonusAdd or 0
                    wep.LastRateOfFireAdjacencyBonusAdd = bonusAdd
                    newValue = wep.LastRateOfFireAdjacencyBonusAdd
                    --# Tell weapon to recalculate ROF from all bonuses
                    wep:UpdateRateOfFireFromBonuses()
                end
            end
            
        --# This is a new type of bonus I added.
        elseif bonusTypeName == 'ShieldStrength' then
            if self.MyShield or self.IsSensitiveShieldUser then
                --LOG('ShieldStrength bonus of ' .. repr(bonusAdd) .. ' applied to shield of ' .. self.DebugId)
                oldValue = self.ShieldStrengthMod or 1
                self.ShieldStrengthMod = 1 + bonusAdd
                newValue = self.ShieldStrengthMod            
                --# If the adjacency bonus on shield strength changed
                if (oldValue ~= newValue) then
                    --# Show message to user
                    self.MyShield:DoSyncForUI()
                end
            end
        end
        
        --# Feedback to user
        if oldValue ~= newValue then 
            if (bonusAdd == 0) then 
                self:FlashMessage("Bonus Removed: "  .. bonusTypeName 
                --.. " oldValue=" .. GilbotUtils.NumberToStringWith2DPMax(oldValue) .. " newValue=" .. repr(newValue)
                , 3)
            else
                local changed = "Decreased"
                if ((bonusAdd > 0) and (newValue > oldValue))
                or ((bonusAdd < 0) and (newValue < oldValue))
                then changed = "Increased" 
                end
                self:FlashMessage("Bonus " .. changed .. ": "  .. bonusTypeName .. " = " .. GilbotUtils.NumberToStringWith2DPMax(newValue), 3)
            end
        end
    end,
    
    

    
    
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to mod this to make sure tables are cleaned up.
    --#*  Base class version cancels bonuses and cleans up effects.
    --#*  
    --#**
    OnAdjacentTo = function(self, adjacentUnitArg)
        
        --# Safety checks are grouped together in another function
        local canLink, tryLater = self:CanLinkWith(adjacentUnitArg) 
        --# Defer if a trylater received as it means
        --# units are currently compatible but there is
        --# a concurrency issue.
        if tryLater and type(tryLater) == 'number' then 
            ForkThread(
                function(self, adjacentUnitArg)
                    WaitSeconds(tryLater)
                    self:AdjacencyLog('Retrying OnAdjacentTo with ' .. self.DebugId 
                     .. ' and ' .. adjacentUnitArg.DebugId
                     .. ' after waiting '  .. repr(tryLater) .. ' seconds.'
                    )
                    self:OnAdjacentTo(adjacentUnitArg)
                end, self, adjacentUnitArg
            )
            return 
        end
        --# Abort if a definite no response received
        if not canLink then return end

        --# Call code that deals with resource networks and internetworks
        self:AddLinkToNetwork(adjacentUnitArg)
        
        --# Create link effect
        self:CreateLink(adjacentUnitArg)
        
        --# This (amongst other purposes) will stop this being executed more than once. 
        self:AddToEachOthersAdjacencyTables(adjacentUnitArg, 'Local')
    end,

    
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by OnAdjacentTo.
    --#*  Contains safety checks that can abort linking in OnAdjacentTo.
    --#*
    --#*  Returns two values.  
    --#*  The first boolean represents a response, i.e. can they link.
    --#*  The second is a flag which for concurrency purposes asks
    --#*  the calling code to wait and try again in a couple ticks.
    --#*  the second argument can be ignored if the warning never 
    --#*  is found in a log file.  If the second flag is set, it gives
    --#*  a number specifying how long the calling code should wait before 
    --#*  trying again.
    --#*
    --#*  If either unit is on a network being merged or salvaged
    --#*  then we must wait because these units may be passed references
    --#*  to a new network and that could cause problems.
    --#**
    CanLinkWith = function(self, adjacentUnitArg)
    
        --# This is a to protect against applying GPG adjacency
        --# to units that do not inherit this class.
        if not adjacentUnitArg.IsAdjacencyUnit then return false, false end
        
        --# Don't make a link with unit that is just finishing an 
        --# upgrade, as it will disconnect right away anyway!
        if self.EndOfCompletedUpgrade_AboutToDestroySelf
        or adjacentUnitArg.EndOfCompletedUpgrade_AboutToDestroySelf then 
            return false, false 
        end
        
        --# This is a safety GPG uses to protect against
        --# duplicate applications of GPG adjacency.
        if self:IsBeingBuilt() or adjacentUnitArg:IsBeingBuilt() then return false, false end
        
        --# This next call is a safety against duplicate links.
        if self:CheckIfAlreadyConnected(adjacentUnitArg, 'Local') then return false, false end
        if self:CheckIfAlreadyConnected(adjacentUnitArg, 'Remote') then return false, false end
        
        --# Extra safety - both must be alive
        if not (self:IsAlive() and adjacentUnitArg:IsAlive()) then return false, false end
        
        --# If ACU is not alive then don't allow any more adjacency.
        if not self:GetMyCommander() then return false, false end
        
        --# This penultimate check is just about concurrency
        --# and probably will never fail but I've put it here
        --# for debugging purposes until code is trusted to be stable.
        --# It waits for network merge operations to finish.
        if (self.MyNetwork and self.MyNetwork.IsStillBeingReconstructed)
          or (adjacentUnitArg.MyNetwork and adjacentUnitArg.MyNetwork.IsStillBeingReconstructed)
        then
            self:AdjacencyLog('CanLinkWith: Cannot link ' .. self.DebugId
            .. ' and ' .. adjacentUnitArg.DebugId
            .. ' yet as at least one of their networks has the' 
            .. ' IsStillBeingReconstructed flag set.'
            )
            return false, 1
        end
        
        --# This final check is just about concurrency
        --# and probably will never fail but I've put it here
        --# for debugging purposes until code is trusted to be stable.
        --# It waits for network salvage operations to finish.
        if self.WaitingToBeReassignedNewNetwork or 
          adjacentUnitArg.WaitingToBeReassignedNewNetwork 
        then
            local gTickString = GetGameTick()
            self:AdjacencyLog('CanLinkWith: Tick= ' .. repr(gTickString)
            .. ': Cannot link ' .. self.DebugId
            .. ' and ' .. adjacentUnitArg.DebugId
            .. ' yet as at least one is waiting to be reassigned to' 
            .. ' a new network after its previous network was split. No explanation.'
            )
            return false, 2
        end
        
        --# Passed all safety checks
        return true, false
    end,
    
    
 
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by OnAdjacentTo.
    --#*  Deals with ResourceNetwork objects.
    --#**
    AddLinkToNetwork = function(self, adjacentUnitArg)
        
        --# Only create and associate with a brand new network supervsior
        --# if we haven't had one already or the last one was broken up and is invalid.
        local useMyNetwork = true
        --# First check if we have a valid network.
        if not self.MyNetwork or self.MyNetwork.IsBroken then
            --# if the adjacent unit has a functioning network
            if adjacentUnitArg.MyNetwork and (not adjacentUnitArg.MyNetwork.IsBroken) then
                --# Add it to the adjacent unit's network because 
                --# has a valid one and we don't.
                adjacentUnitArg.MyNetwork:AddLinkToNetwork(adjacentUnitArg, self)
                useMyNetwork = false
            else
                --# We'll make a new network for this unit
                --# because neither unit had a network.
                --# This is the only time/place we create
                --# a new network.                 
                self:SetNetwork(ResourceNetwork(self))
            end
        end
        --# Add the link to this unit's (possibly new) network if we didn''t
        --# already add it to the other unit's network.
    	if useMyNetwork then self.MyNetwork:AddLinkToNetwork(self, adjacentUnitArg) end
    
    end,
        
        
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by OnAdjacentTo.
    --#*  Deals with ResourceNetwork objects.
    --#**
    CreateLink = function(self, adjacentUnitArg)
    
        --# Always create/remove a linking beam effect regardless
        --# of whether or not bonus is applied.
        --# Create adjacency beam effect
    	ForkThread(
            function(self, adjacentUnitArg) 
                --# You get errors if it tries to create effects too quickly.
                WaitSeconds(1)
                self:CreateAdjacentEffect(adjacentUnitArg)
            end, self, adjacentUnitArg
        )
     
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to mod this to make sure tables are cleaned up.
    --#*  Base class version cancels bonuses and cleans up effects.
    --#**
    OnNotAdjacentTo = function(self, adjacentUnitArg)

        --# Safety checks are gropuped together in another function
        if not self:CanDisconnectFrom(adjacentUnitArg, 'Local') then return end
        
        --# Always remove a linking beam effect regardless
        --# of whether or not bonus is applied:
        --# Remove any adjacency beam effects between this pair.
        --# Also removes references to each other from all connection tables,
        --# which stops this function from being called a second time on the same pair.
        self:CleanUpAdjacentEffectsWith(adjacentUnitArg)
        
        --# Both units should have reference to same network object because they were attached
        --# but when a large network containing many units is severed then
        --# all unit in that network have their references to it removed stright away
        --# so we might have lost our references that way.  If that is the case
        --# then we don't need to contact the network anyway, as long as 
        --# the network removes dead units itself or it destroys itself.
        --# Typically it destroys itself and checks if a unit is still alive 
        --# before trying to add it to a new network.
        local commonNetwork = self:GetLiveNetwork() or adjacentUnitArg:GetLiveNetwork()
        if not commonNetwork then return end
        --# This is here just for debugging purposes and can be removed
        --# when the code in this file is trusted to be stable.
        local Nid1 = self:GetLiveNetworkId() 
        local Nid2 = adjacentUnitArg:GetLiveNetworkId() 
        if Nid1 and Nid2 and Nid1 ~= Nid2 then
          WARN('OnNotAdjacentTo: Units ' .. self.DebugId
            .. ' and ' .. adjacentUnitArg.DebugId
            .. ' appear to have been on separate live networks: N='
            .. repr(Nid1) .. ' and N=' .. repr(Nid2)
          )
        end
        
        --# This function only ever gets called when an adjacency structure unit dies.
        --# It is called by the moho engine and I also call it explicitly.
        --# Here is a sanity check to make sure that one died!
        local unlinkingUnitWillBeDestroyedOrCaptured = false
        if self.WasAlreadyCalled_CleanUpAdjacencyOnDeath then 
            commonNetwork:RemoveUnitFromNetwork(self) 
            unlinkingUnitWillBeDestroyedOrCaptured=true
        end
        if adjacentUnitArg.WasAlreadyCalled_CleanUpAdjacencyOnDeath then
            commonNetwork:RemoveUnitFromNetwork(adjacentUnitArg) 
            unlinkingUnitWillBeDestroyedOrCaptured=true
        end
        if self.IsAdjacencyStructureUnit 
        and adjacentUnitArg.IsAdjacencyStructureUnit
        and not unlinkingUnitWillBeDestroyedOrCaptured then
          self:AdjacencyLog('OnNotAdjacentTo: Neither structure unit needed to be removed from local Network: ' .. self.DebugId
            .. ' nor ' .. adjacentUnitArg.DebugId
          )
        end
                
        --# This call will tell the network to update itself after units are lost.
        --# If there are units left in it, the network will either recalulate bonuses 
        --# or, if told it must by the argument, it will split into subnetworks
        --# and then recalculate bonuses.  If there are no units left in it, 
        --# the network object is destroyed.
        commonNetwork:OnLinkRemovedFromNetwork()
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by OnNotAdjacentTo.
    --#*  Contains safety checks that can abort discionnecting in OnNotAdjacentTo.
    --#**
    CanDisconnectFrom = function(self, adjacentUnitArg, connectionTypeArg)
        --# These next call is a safety against duplicate calls.
        return self:CheckIfAlreadyConnected(adjacentUnitArg, connectionTypeArg)
    end,
    
    
    
  
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from RebuildRemoteAdjacencyConnections.
    --#*  It separates the code into resuable sections
    --#*  and makes the code more readable.
    --#*
    --#*  It's also used as a safety in OnNotAdjacentTo.
    --#*
    --#**
    CheckIfAlreadyConnected = function(self, nearbyUnitArg, tableKeyArg)
        return
          (        
            GilbotUtils.IsValueInTable(self.AdjacentUnits[tableKeyArg], nearbyUnitArg)
              or 
            GilbotUtils.IsValueInTable(nearbyUnitArg.AdjacentUnits[tableKeyArg], self)
          )
    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from IsNonRedundantBridgeInNetwork below.
    --#**
    GetNumberOfConnectedUnits= function(self, tableKeyArg)
        return table.getsize(self.AdjacentUnits[tableKeyArg])
    end,
    
    

    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by AddLinkToInterNetwork 
    --#*  in the RemoteAdjacencyUnit class,
    --#*  but called on anything it can connect to, 
    --#*  so I moved it here.
    --#**
    EnsureUnitHasValidNetwork = function(self)
        --# This attaches a new network object to the unit if 
        --# there isn't a valid one there already
        if (not self.MyNetwork) or self.MyNetwork.IsBroken then
            --# We'll make a new network for this unit
            self.MyNetwork = ResourceNetwork(self)
            --# This next block is for debugging only.
            --# This can be delete wheh debugging is done.
            self:AdjacencyLog(
                'Adjacency: EnsureUnitHasValidNetwork:'
            .. ' Attaching new network object to ' .. self.DebugId
            .. ' with ID=' .. repr(self.MyNetwork.NetworkId)
            )
        end
    end,

    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by OnNotAdjacentTo in this class.
    --#**
    GetLiveNetwork = function(self)
        --# This attaches a new network object to the unit if 
        --# there isn't a valid one there already
        if self.MyNetwork and not self.MyNetwork.IsBroken 
        then return self.MyNetwork
        else return false
        end
    end,
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Called by OnNotAdjacentTo in this class.
    --#**
    GetLiveNetworkId = function(self)
        --# This attaches a new network object to the unit if 
        --# there isn't a valid one there already
        if self.MyNetwork and not self.MyNetwork.IsBroken 
        then return self.MyNetwork.NetworkId
        else return false
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by 
    --#*  AddExtendedAdjacencyToNearbyUnits
    --#*  and RebuildRemoteAdjacencyConnections.
    --#*
    --#**
    GetNearbyFriendlyStructures = function(self, flagToCheck)
        --# Supply default value for argument
        if not flagToCheck then flagToCheck = 'IsAdjacencyUnit' end
        
        local searchRectangle = self:GetSearchRectangleXZCoordinates()
	    local UnitsinRec = GetUnitsInRect(searchRectangle) or {}
      
        --# Return result to calling code
        return self:FilterUnitsForChecking(UnitsinRec, flagToCheck)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by 
    --#*  GetNearbyFriendlyStructures.
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
            --# Give this to ACU who will decide if this is the largest range
            myCommander:ReceiveACUMessage_SetMaxAdjacencyRangeEncounteredSoFar(
                self.RemoteAdjacencyAllowedSeparationDistance
            )
            --# ACU tells us the largest offset this army is capable of.
            offset = 
                math.max(myCommander:ReceiveACUMessage_GetMaxAdjacencyRangeEncounteredSoFar() or 0, offset)
            
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
        
        --# The table variable we will return.
        local resultTable = {}
        
        local myPosition = self:GetPosition()
 
        --# Get nearby units to check for touching adjacency
        local x1 = myPosition.x - (1+offset+maxSkirtXFromCentre)
        local z1 = myPosition.z - (1+offset+maxSkirtZFromCentre)
        local x2 = myPosition.x + (1+offset+maxSkirtXFromCentre)
        local z2 = myPosition.z + (1+offset+maxSkirtZFromCentre)
	
        return Rect(x1, z1, x2, z2)
        
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this.  It is called by 
    --#*  GetNearbyFriendlyStructures.
    --#*
    --#**
    FilterUnitsForChecking = function(self, unfilteredTable, flagToCheck)
    
        --# The table variable we will return.
        local resultTable = {}

        --# Now filter through the units found (shouldn't be too many)
        for kNearbyUnit, vNearbyUnit in unfilteredTable do
            --# Ignore dead/dying units
            if self:IsAlive() and vNearbyUnit:IsAlive() then 
                --# Don't connect to ourself!!
                if self ~= vNearbyUnit and 
                  --# unit has to be in same army
                  self:GetArmy() == vNearbyUnit:GetArmy()
                  --# Both units must inherot this class!
                  and vNearbyUnit[flagToCheck]
                then
                    --# Check that it's not a structure contained within a structure,
                    if (not self.ContainingStructure) or 
                        --# or if it is then that we are not trying to 
                        --# connect to our containing unit!
                       (self.ContainingStructure ~= vNearbyUnit)
                    then  
                        --# This unit qualifies
                        table.insert(resultTable, vNearbyUnit)
                    end
                end
            end
        end
        
        --# Return result to calling code
        return resultTable
        
    end,    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from AddExtendedAdjacencyToNearbyUnits below.
    --#*  It is to save on repeated code.
    --#*
    --#**
    GetSkirtBounds = function(self)
        
        --# Don't recalculate, as structures don't move!
        if not self.MySkirtBounds then 
          
            local myBP = self:GetBlueprint()
    
            --# bounding box overrided by skirt size if set
            local myBPSkirtXFromCentre = (myBP.Physics.SkirtSizeX or myBP.SizeX) * 0.5
            local myBPSkirtZFromCentre = (myBP.Physics.SkirtSizeZ or myBP.SizeZ) * 0.5
            
            --# Correction for custom units
            self.MySkirtBoundsCentrePosition = ApplyPositionCorrection(self, self:GetPosition())
            
            --# Get edge corner positions, { TOP, LEFT, BOTTOM, RIGHT }
            self.MySkirtBounds = {
                UpperLeft = {
                    z = self.MySkirtBoundsCentrePosition.z - myBPSkirtZFromCentre,
                    x = self.MySkirtBoundsCentrePosition.x - myBPSkirtXFromCentre,
                },
                BottomRight = {
                    z = self.MySkirtBoundsCentrePosition.z + myBPSkirtZFromCentre,
                    x = self.MySkirtBoundsCentrePosition.x + myBPSkirtXFromCentre,
                }
            }
            
            --# New approach to improving efficiency 
            --# that works while ACU is alive.
            local myCommander = self:GetMyCommander()
            --# If commander is alive...
            if myCommander then
                --# Give new skirt values to ACU 
                --# who will then decide if these are the largest so far
                myCommander:ReceiveACUMessage_SetMaxSkirtBoundsEncounteredSoFar(
                    myBPSkirtXFromCentre, myBPSkirtZFromCentre 
                )
            end
                
        end
        
        --# Return value just in case a copy is needed.
        --# Might make calling code easier to read.        
        return self.MySkirtBounds
    end,
    
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from AddExtendedAdjacencyToNearbyUnits below.
    --#*  It is only for debugging.
    --#*
    --#*  No known issues with this function.
    --#*
    --#**
    DumpSkirtBounds = function(self)
        
        local myposition = self:GetPosition()
        
        self:AdjacencyLog(self.DebugId
            .. ': position:'
            .. ' x=' .. myposition.x 
            .. ' z=' .. myposition.z
            .. '    centre of skirtbound position:'
            .. ' x=' .. self.MySkirtBoundsCentrePosition.x 
            .. ' z=' .. self.MySkirtBoundsCentrePosition.z
            .. '    skirt sizes:'
            .. ' x=' .. self:GetBlueprint().Physics.SkirtSizeX 
            .. ' z=' .. self:GetBlueprint().Physics.SkirtSizeZ)
  
        self:AdjacencyLog(self.DebugId
            .. ': My skirtbounds: UL:'
            .. ' x=' .. self.MySkirtBounds.UpperLeft.x
            .. ' z=' .. self.MySkirtBounds.UpperLeft.z .. ' BR:'
            .. ' x=' .. self.MySkirtBounds.BottomRight.x
            .. ' z=' .. self.MySkirtBounds.BottomRight.z)
        
        if math.mod(myposition.x,1) ~= 0.5 then
            if not self.IsPipeLineUnit then 
              WARN('Adjacency: unit ' .. self:GetUnitId() .. 
                   ' does not have valid x position:' .. repr(myposition.x))
            end
        end
        if math.mod(myposition.z,1) ~= 0.5 then
            if not self.IsPipeLineUnit then 
              WARN('Adjacency: unit ' .. self:GetUnitId() .. 
                   ' does not have valid z position:' .. repr(myposition.z))
            end
        end
        
    end,
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I overrided this function because I had lots
    --#*  of problems when units upgrade and call 
    --#*  self:Destroy().
    --#*
    --#*  No known issues with this function.
    --#**
    UpgradingState = State {
        Main = function(self)
            self.UnitBeingBuilt.UpgradedAdjacencyStructureUnit_JustCreated = true
            self.UnitBeingBuilt.DebugId = self.UnitBeingBuilt.DebugId .. " (upgraded from " .. self.DebugId .. " )"
            self.StartOfUpgrade_MightDestroySelf = true
            BaseClass.UpgradingState.Main(self)
        end,
        --# I added one line to this to stop 
        --# calling self:Destroy too soon.
        OnStopBuild = function(self, unitBuilding)
            --# Remove adjacency before we get
            --# a destroy call issued.
            if unitBuilding:GetFractionComplete() == 1 then
                --# Remove all adjacency here?
                self.EndOfCompletedUpgrade_AboutToDestroySelf = true
                self:CleanUpAdjacencyOnDeath() 
            end
            --# This is a safe non-destructive hook.
            BaseClass.UpgradingState.OnStopBuild(self, unitBuilding)
        end,
        
        --# This stays the same.
        OnFailedToBuild = BaseClass.UpgradingState.OnFailedToBuild,
    },
        
    
} --(end of class definition)

return resultClass

end