--#****************************************************************************
--#**
--#**  Hook File:  /units/UEL0101/UEL0101_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  UEF Scout Script
--#**
--#****************************************************************************

local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit

local PreviousVersion= MakeCustomUpgradeMobileUnit(UEL0101, 'UEL0101', 0.3)
UEL0101 = Class(PreviousVersion) {

    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if  enh == "RateOfFire1" or 
            enh == "RateOfFire2" or
            enh == "RateOfFire3" then
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
                enh == "RateOfFire2Remove" or 
                enh == "RateOfFire3Remove" then
            --# Update the weapon
            local weapon = self:GetWeapon(1)
            weapon.RateOfFireEnhancementBonus = 1
            weapon:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect.RateOfFire1=false
            self.PossibleEnhancementInEffect.RateOfFire2=false
            self.PossibleEnhancementInEffect.RateOfFire3=false
        elseif enh == 'Speed' then
            self:SetSpeedMult(bp.SpeedMultiplier)
            self.PossibleEnhancementInEffect[enh]=true
            --self:SetElevation(bp.NewElevation)
        elseif enh == 'SpeedRemove' then
            self:SetSpeedMult(1)
            self.PossibleEnhancementInEffect.Speed=false
            --self:SetElevation(self:GetBlueprint().Physics.Elevation)
        elseif  enh == "Damage1" or
                enh == "Damage2" or
                enh == "Damage3" then 
            --# This gives the unit its ability
            local weapon = self:GetWeapon(1)
            local originalDamage = weapon:GetBlueprint().Damage
            local newDamage = originalDamage * bp.DamageMultiplier
            weapon:AddDamageMod(newDamage-originalDamage)
            --# Housekeeping of resources
            self.PossibleEnhancementInEffect[enh]=true
            self.UpgradeDiscountAmounts.Mass = 
                self.UpgradeDiscountAmounts.Mass + (bp.BuildCostMass*0.9)
            self.UpgradeDiscountAmounts.Energy = 
                self.UpgradeDiscountAmounts.Energy + (bp.BuildCostEnergy*0.9)
        elseif  enh == "DamageRemove1" or
                enh == "DamageRemove2" or
                enh == "DamageRemove3" then
            --# Update the weapon
            weapon.DamageMod=0
            self.PossibleEnhancementInEffect.Damage1=false
            self.PossibleEnhancementInEffect.Damage2=false
            self.PossibleEnhancementInEffect.Damage3=false
        else
            WARN('UEF Scout: Unknown enhancment.')
        end
        
        --# Replace me with upgraded unit if
        --# all enhancements are used
        local doAction = true
        for k,vInEffect in self.PossibleEnhancementInEffect do        
            if vInEffect == false then doAction = false end              
        end
        if doAction then self:ReplaceMeWithUpgradedUnit() end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my 'Stat Slider' mod when enhancements
    --#*  are used that can change whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        PreviousVersion.OnStopBeingBuilt(self, builder, layer)
        
        --# Declare non-static member variables here
        self.PossibleEnhancementInEffect = {
            RateOfFire1 = false,
            RateOfFire2 = false,
            RateOfFire3 = false,
            Speed = false,
            Damage1 = false,
            Damage2 = false,
            Damage3 = false,
        }
    end,
     
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions so that a fully enhanced unit
    --#*  can be replaced with the upgraded version of it.
    --#*  This means that double-clicking units will get
    --#*  all fully upgraded units - enahnced and prebuilt.
    --#**
    ReplaceMeWithUpgradedUnit = function(self)
        local pos = self:GetPosition()
        local newUnit =  CreateUnit('UEL0101b', self:GetArmy(), pos.x, pos.y, pos.z , 0, 0, 0, 1)
        newUnit:SetOrientation(self:GetOrientation(), true)
        --# Destroy this unit as it has been replaced
        self:Destroy()
    end,
}
TypeClass = UEL0101