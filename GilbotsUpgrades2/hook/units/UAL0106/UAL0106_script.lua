--#****************************************************************************
--#**
--#**  Hook File:  /units/UAL0106/UAL0106_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  Aeon Light Assault Bot Script
--#**
--#****************************************************************************

local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit
local MakeChargingUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon
local ADFLaserLightWeapon = 
    import('/lua/aeonweapons.lua').ADFLaserLightWeapon

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local BaseClass = MakeCustomUpgradeMobileUnit(UAL0106, 'UAL0106', 0.3)

UAL0106 = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide weapons upgrades
    --#*  for Experimental Wars Veterancy code,
    --#*  and to add the Charging Dummy Weapon.
    --#**
    Weapons = {
        ArmLaserTurret = BaseClass.Weapons.ArmLaserTurret,
        ArmLaserTurretMod = Class(ADFLaserLightWeapon) {},
		ArmLaserTurretMod02 = Class(ADFLaserLightWeapon) {},
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
        self:HideBone('Turret02', true)  
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
        
        --# Initialisation for Customupgrade unit code
        self.PossibleEnhancementInEffect = {
            RateOfFire1 = false,
            RateOfFire2 = false,
            RateOfFire3 = false,
            Shield = false,
        }
        
        --# Initialisation for Experimental Wars Veterancy code.
        self:SetWeaponEnabledByLabel('ArmLaserTurretMod02', false)
        self:SetWeaponEnabledByLabel('ArmLaserTurret', false)  
	    self:AddUnitCallback(self.OnVeteran, 'OnVeteran') 
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
            enh == "RateOfFire2" or
            enh == "RateOfFire3" then
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
                enh == "RateOfFire2Remove" or 
                enh == "RateOfFire3Remove" then
            --# Update the weapon
            local gun = self:GetWeapon(1)
            gun.RateOfFireEnhancementBonus = 1
            gun:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect.RateOfFire1=false
            self.PossibleEnhancementInEffect.RateOfFire2=false
            self.PossibleEnhancementInEffect.RateOfFire3=false
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreateShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self.PossibleEnhancementInEffect.Shield=true
            self.UpgradeDiscountAmounts.Mass = 
                self.UpgradeDiscountAmounts.Mass + (bp.BuildCostMass*0.9)
            self.UpgradeDiscountAmounts.Energy = 
                self.UpgradeDiscountAmounts.Energy + (bp.BuildCostEnergy*0.9)
            --# Enable Auto Toggle on Shield
            self:AddAutoToggle({0,3}, bp.MaintenanceConsumptionPerSecondEnergy or 0)
        elseif enh == 'ShieldRemove' then
            --# Disable Auto Toggle on Shield.
            self:RemoveAutoToggle(0)
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            RemoveUnitEnhancement(self, 'ShieldRemove')
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
            self.PossibleEnhancementInEffect.Shield=false
        else
            WARN('Aeon LAB: Unknown enhancment.')
        end
        
        --# Replace me with upgraded unit if
        --# all enhancements are used
        local doAction = true
        for k,vInEffect in self.PossibleEnhancementInEffect do        
            if vInEffect == false then doAction = false end              
        end
        if doAction then self:ReplaceMeWithUpgradedUnit() end
    end,
}

UAL0106 = MakeChargingUnit(UAL0106)
TypeClass = UAL0106