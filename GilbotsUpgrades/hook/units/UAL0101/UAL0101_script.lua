--#****************************************************************************
--#**
--#**  Hook File:  /units/UAL0101/UAL0101_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  Aeon Scout Script
--#**
--#****************************************************************************

local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local PreviousVersion= MakeCustomUpgradeMobileUnit(UAL0101, 'UAL0101', 0.3)
UAL0101 = Class(PreviousVersion) {

    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
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
            local gun = self:GetWeapon(1)
            local originalDamage = gun:GetBlueprint().Damage
            local newDamage = originalDamage * bp.DamageMultiplier
            gun:AddDamageMod(newDamage-originalDamage)
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
            gun.DamageMod=0
            self.PossibleEnhancementInEffect.Damage1=false
            self.PossibleEnhancementInEffect.Damage2=false
            self.PossibleEnhancementInEffect.Damage3=false
        else
            WARN('Aeon Scout: Unknown enhancment.')
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
    --#*  This runs when unit starts upgrading
    --#**
    GetIntoUpgradePosition = function(self)
        --# Hover unit lands to upgrade
        self:DestroyIdleEffects()
        self:DestroyMovementEffects()
        self:SetElevation(0)
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This runs when unit starts upgrading
    --#*  and when an all enhancements are done
    --#*  and a replacement is being done.
    --#**
    MakeUpgradedUnitMirrorMyPosition = function(self, unitBeingBuilt)
        --# Setting elevation doesn't work to 
        --# put unit being built on the ground
        local pos = unitBeingBuilt:GetPosition()
        pos.y = pos.y - 0.25
        unitBeingBuilt:SetPosition(pos, true)
        --# Make sure unit we are ugrading to has same orientation
        unitBeingBuilt:SetOrientation(self:GetOrientation(), true)
    end,
}
TypeClass = UAL0101