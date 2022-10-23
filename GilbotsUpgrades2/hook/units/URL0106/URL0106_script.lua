--#****************************************************************************
--#**
--#**  Hook File:  /units/URL0106/URL0106_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  Cybran Light Assault Bot Script
--#**
--#****************************************************************************

local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit
local MakeChargingUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local BaseClass = MakeCustomUpgradeMobileUnit(URL0106, 'URL0106', 0.3)

URL0106 = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide weapons upgrades
    --#*  for Experimental Wars Veterancy code,
    --#*  and to add the Charging Dummy Weapon.
    --#**
    Weapons = {
        MainGun = Class(CDFLaserPulseLightWeapon) {
            OnWeaponFired = function(self, target)
				CDFLaserPulseLightWeapon.OnWeaponFired(self, target)
				ChangeState( self.unit, self.unit.VisibleState )
			end,
			
			OnLostTarget = function(self)
				CDFLaserPulseLightWeapon.OnLostTarget(self)
				if self.unit:IsIdleState() then
				    ChangeState( self.unit, self.unit.InvisState )
				end
			end,
        },
        MainGun2 = Class(CDFLaserPulseLightWeapon) {
            OnWeaponFired = function(self, target)
				CDFLaserPulseLightWeapon.OnWeaponFired(self, target)
				ChangeState( self.unit, self.unit.VisibleState )
			end,
			
			OnLostTarget = function(self)
				CDFLaserPulseLightWeapon.OnLostTarget(self)
				if self.unit:IsIdleState() then
				    ChangeState( self.unit, self.unit.InvisState )
				end
			end,
        },
        --# This dummy weapon just makes the LAB
        --# run straight at any opponents in its area
        --# which should put it in range of its main weapon.
        Charge = Class(ChargingWeapon) {},
    },
    

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for mods:
    --#*  Initialisation for Experimental Wars Veterancy code.
    --#**
    OnCreate = function(self)
		BaseClass.OnCreate(self)
        self:HideBone('URL02', true)  
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for mods:
    --#*  Initialisation for Customupgrade unit code
    --#*  Initialisation for Experimental Wars Veterancy code.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        BaseClass.OnStopBeingBuilt(self, builder, layer)
        
        --# Declare non-static member variables here
        self.PossibleEnhancementInEffect = {
            RateOfFire1 = false,
            RateOfFire2 = false,
            Cloak = false,
        }
        
        --# Experimental Wars Veterancy
        self:SetWeaponEnabledByLabel('MainGun2', false)
        self:AddUnitCallback(self.OnVeteran, 'OnVeteran')
        
        --# Cloak enhancements start off.
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('Cloak')
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my 'Experimental Wars mod veterancy.
    --#*  It is called via a callback we set, whenever a new
    --#*  veterancy level has been reached.
    --#**
    OnVeteran = function(self)
        local bp = self:GetBlueprint().ExpeWars_Enhancement[self.VeteranLevel]
		if not bp then return end
        --# Perform standrad processing
        self:ApplyEWVeteranBuff(bp)
	end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for enhancments.
    --#**
    CreateEnhancement = function(self, enh)
        BaseClass.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if  enh == "RateOfFire1" or 
            enh == "RateOfFire2" then
            --# Update weapon with extra bonus
            local gun = self:GetWeapon(1)
            gun.RateOfFireEnhancementBonus = bp.RateOfFireMultiplier
            gun:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect[enh]=true
            self.UpgradeDiscountAmounts.Mass = 
                self.UpgradeDiscountAmounts.Mass + (bp.BuildCostMass*0.9)
            self.UpgradeDiscountAmounts.Energy = 
                self.UpgradeDiscountAmounts.Energy + (bp.BuildCostEnergy*0.9)
        elseif  enh == "RateOfFire1Remove" or 
                enh == "RateOfFire2Remove" then
            --# Update the weapon
            local gun = self:GetWeapon(1)
            gun.RateOfFireEnhancementBonus = 1
            gun:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect.RateOfFire1=false
            self.PossibleEnhancementInEffect.RateOfFire2=false
        elseif enh == 'Cloak' then
            --# Give ability to unit
            self:AddToggleCap('RULEUTC_CloakToggle')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('Cloak')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            --# Housekeeping
            self.PossibleEnhancementInEffect[enh]=true
            self.UpgradeDiscountAmounts.Mass = 
                self.UpgradeDiscountAmounts.Mass + (bp.BuildCostMass*0.9)
            self.UpgradeDiscountAmounts.Energy = 
                self.UpgradeDiscountAmounts.Energy + (bp.BuildCostEnergy*0.9)
            --# This next line is needed?
            self:DisableConditionalCloak()
            --# Enable Auto Toggle on Cloak.
            self:AddAutoToggle({8,3}, bp.MaintenanceConsumptionPerSecondEnergy or 0)
        elseif enh == 'CloakRemove' then
            --# Disable Auto Toggle on Cloak.
            self:RemoveAutoToggle(8)
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:SetMaintenanceConsumptionInactive()
            self.PossibleEnhancementInEffect.Cloak=false
            ChangeState( self, self.IdleState ) 
        else
            WARN('Cybran LAB: Unknown enhancment.')
        end
        
        --# Replace me with upgraded unit if
        --# all enhancements are used
        local doAction = true
        for k,vInEffect in self.PossibleEnhancementInEffect do        
            if vInEffect == false then doAction = false end              
        end
        if doAction then 
            self:ReplaceMeWithUpgradedUnit() 
        end
    end,
    

     
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement
    --#*  on a unit that can build or enhance.
    --#**
    IdleState = State() {
        Main = function(self)
            CWalkingLandUnit.IdleState.Main(self)
            if self.PossibleEnhancementInEffect.Cloak then 
                ChangeState( self, self.InvisState )
            end
        end,
    },
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement.
    --#**
    InvisState = State() {
        Main = function(self)
            if not self:GetScriptBit('RULEUTC_CloakToggle') then
                --# This is copy-and pasted code
                --# That must be executed within a state
                self.Cloaked = false
                local bp = self:GetBlueprint()
                if bp.Intel.StealthWaitTime then
                    WaitSeconds(bp.Intel.StealthWaitTime)
                end
                self:EnableUnitIntel('RadarStealth')
                self:EnableUnitIntel('Cloak')
                self.Cloaked = true
            end
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new ~= 'Stopped' then
                ChangeState( self, self.VisibleState )
            end
            CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
        
        --#*
        --#*  This happens when cloak button was off 
        --#*  but now is on and unit was already cloaked
        --#**   
        OnScriptBitClear = function(self, bit)
            if bit == 8 then
                --# turn on power usage first
                if self.ResourceDrainBreakDown then 
                    self.EnabledResourceDrains.Cloak = true
                    self:UpdateConsumptionValues()
                    self:OnIntelEnabled()
                else 
                    self:SetMaintenanceConsumptionActive()
                end
                --# Then cloak the unit itself 
                if not self.Cloaked then 
                    --# This is copy-and pasted code
                    --# That must be executed within a state
                    self.Cloaked = false
                    self:ForkThread(
                        function(self)
                            local bp = self:GetBlueprint()
                            if bp.Intel.StealthWaitTime then
                                WaitSeconds(bp.Intel.StealthWaitTime)
                            end
                            self:EnableUnitIntel('RadarStealth')
                            self:EnableUnitIntel('Cloak')
                            self.Cloaked = true
                        end
                    )
                end
            else
                --# Call base class code
                CWalkingLandUnit.OnScriptBitClear(self, bit)
            end
        end,
        
        --#*
        --#*  This happens when cloak button was on but
        --#*  just got switched off while it cloaked.  
        --#**     
        OnScriptBitSet = function(self, bit)
            if bit == 8 then 
                if self.Cloaked then self:DisableConditionalCloak() end
                if self.ResourceDrainBreakDown then
                    self.EnabledResourceDrains.Cloak = false
                    self:UpdateConsumptionValues()
                    self:OnIntelDisabled()
                else
                    self:SetMaintenanceConsumptionInactive()
                end
            else
                --# Call base class code
                CWalkingLandUnit.OnScriptBitSet(self, bit)
            end
        end,
    },
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement.
    --#**
    VisibleState = State() {
        Main = function(self)
            if self.Cloaked then self:DisableConditionalCloak() end
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new == 'Stopped' then
                ChangeState( self, self.InvisState )
            end
            CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
        
        --#*
        --#*  This happens when cloak button was off 
        --#*  but now is on, but unit is moving or firing 
        --#*  anyway so just switch on power drain.
        --#**   
        OnScriptBitClear = function(self, bit)
            if bit == 8 then
                --# take care of power usage only
                if self.ResourceDrainBreakDown then 
                    self.EnabledResourceDrains.Cloak = true
                    self:UpdateConsumptionValues()
                    self:OnIntelEnabled()
                else 
                    self:SetMaintenanceConsumptionActive()
                end
            else
                --# Call base class code
                CWalkingLandUnit.OnScriptBitClear(self, bit)
            end
        end,
        
        --#*
        --#* This happens when cloak button was on but
        --#* just got switched off while not cloaked. 
        --#* Just switch off power drain.        
        --#**     
        OnScriptBitSet = function(self, bit)
            if bit == 8 then 
                --# take care of power usage only
                if self.ResourceDrainBreakDown then
                    self.EnabledResourceDrains.Cloak = false
                    self:UpdateConsumptionValues()
                    self:OnIntelDisabled()
                else
                    self:SetMaintenanceConsumptionInactive()
                end
            else
                --# Call base class code
                CWalkingLandUnit.OnScriptBitSet(self, bit)
            end
        end,
    },
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement.
    --#**
    DisableConditionalCloak = function(self)
        self:DisableUnitIntel('RadarStealth')
		self:DisableUnitIntel('Cloak')
		self.Cloaked = false
    end,
    
}

URL0106 = MakeChargingUnit(URL0106)
TypeClass = URL0106