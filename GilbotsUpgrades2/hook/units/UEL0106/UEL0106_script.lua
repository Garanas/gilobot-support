--#****************************************************************************
--#**
--#**  Hook File:  /units/UEL0106/UEL0106_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  UEF Light Assault Bot Script
--#**
--#****************************************************************************
local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit
local MakeChargingUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon
local TSAMLauncher = 
    import('/lua/terranweapons.lua').TSAMLauncher

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local BaseClass = MakeCustomUpgradeMobileUnit(UEL0106, 'UEL0106', 0.3)

UEL0106 = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide weapons upgrades
    --#*  for Experimental Wars Veterancy code,
    --#*  and to add the Charging Dummy Weapon.
    --#**
    Weapons = {
        ArmCannonTurret = BaseClass.Weapons.ArmCannonTurret,
        MissileRack01 = Class(TSAMLauncher) {},
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
        self:HideBone('MiniMissileRack', true)  
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
        
        --# Experimental Wars Veterancy
        self:SetWeaponEnabledByLabel('MissileRack01', false)
        self:AddUnitCallback(self.OnVeteran, 'OnVeteran')
        
        --# Declare non-static member variables here
        self.PossibleEnhancementInEffect = {
            RateOfFire1 = false,
            RateOfFire2 = false,
            Shield = false,
        }
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
        
        --# Don't allow the following enhancements 
        --# to be removed.
        if enh == 'Veterancy1Remove' or
           enh == 'Veterancy2Remove' or
           enh == 'Veterancy3Remove' then
           return
        end
    
        --# Allow the enhnacement to succeed.
        --# Start with baseclass version of code.
        BaseClass.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if  enh == "RateOfFire1" or 
            enh == "RateOfFire2" then
            --# Update weapon with extra bonus
            local weapon = self:GetWeapon(1)
            weapon.RateOfFireEnhancementBonus = bp.RateOfFireMultiplier
            weapon:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect[enh]=true
            self.UpgradeDiscountAmounts.Mass = 
                self.UpgradeDiscountAmounts.Mass + (bp.BuildCostMass*0.9)
            self.UpgradeDiscountAmounts.Energy = 
                self.UpgradeDiscountAmounts.Energy + (bp.BuildCostEnergy*0.9)
        elseif  enh == "RateOfFire1Remove" or 
                enh == "RateOfFire2Remove" then
            --# Update the weapon
            local weapon = self:GetWeapon(1)
            weapon.RateOfFireEnhancementBonus = 1
            weapon:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect.RateOfFire1=false
            self.PossibleEnhancementInEffect.RateOfFire2=false
        elseif enh == 'Shield' then
            --# This is for compatibility with Experimental wars
            --# because it changes the mesh for this unit.
            if self:GetBlueprint().ExpeWars_Enhancement then 
                bp.OwnerShieldMesh = '/mods/gilbotsupgrades2/shields/UEL0106_PersonalShield_mesh'
            end
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreatePersonalShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            self.PossibleEnhancementInEffect[enh]=true
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
        elseif enh == 'Veterancy1' or 
               enh == 'Veterancy2' or 
               enh == 'Veterancy3' then
            self:AddKills(bp.KillsAdded or 1)
        else
            WARN('UEF mech marine: Unknown enhancment.')
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

UEL0106 = MakeChargingUnit(UEL0106)
TypeClass = UEL0106