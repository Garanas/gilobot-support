--#****************************************************************************
--#**
--#**  Hook File:  /units/XSL0101/XSL0101_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  Seraphim Light Assault Bot Script
--#**
--#****************************************************************************

local Buff = 
    import('/lua/sim/Buff.lua')
local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit
local MakeChargingUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = 
    import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon

local PreviousVersion = MakeCustomUpgradeMobileUnit(XSL0101, 'Torso', 0.3)
XSL0101 = Class(PreviousVersion) {

     Weapons = {
		LaserTurret = Class(SDFPhasicAutoGunWeapon) {
			OnWeaponFired = function(self, target)
				SDFPhasicAutoGunWeapon.OnWeaponFired(self, target)
				ChangeState( self.unit, self.unit.VisibleState )
			end,
			
			OnLostTarget = function(self)
				SDFPhasicAutoGunWeapon.OnLostTarget(self)
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
    
    
    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if  enh == "Armour" then
            --# This gives the unit its ability
            if not Buffs['SeraphimScoutArmourBonus'] then
               BuffBlueprint {
                    Name = 'SeraphimScoutArmourBonus',
                    DisplayName = 'SeraphimScoutArmourBonus',
                    BuffType = 'HEALTHBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = 0,
                            Mult = bp.MaxHealthMultiplier,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'SeraphimScoutArmourBonus' ) then
                Buff.RemoveBuff( self, 'SeraphimScoutArmourBonus' )
            end  
            Buff.ApplyBuff(self, 'SeraphimScoutArmourBonus')  
            --# Housekeeping of resources
            self.PossibleEnhancementInEffect[enh]=true
            self.UpgradeDiscountAmounts.Mass = 
                self.UpgradeDiscountAmounts.Mass + (bp.BuildCostMass*0.9)
            self.UpgradeDiscountAmounts.Energy = 
                self.UpgradeDiscountAmounts.Energy + (bp.BuildCostEnergy*0.9)
        elseif  enh == "ArmourRemove"  then
            --# Update the weapon
            if Buff.HasBuff( self, 'SeraphimScoutArmourBonus' ) then
                Buff.RemoveBuff( self, 'SeraphimScoutArmourBonus' )
            end   
            self.PossibleEnhancementInEffect.Armour=false
        elseif  enh == "Damage" then
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
        elseif  enh == "DamageRemove"  then
            --# Update the weapon
            gun.DamageMod=0
            self.PossibleEnhancementInEffect.Damage=false
        elseif  enh == "RateOfFire" then
            --# Update weapon with extra bonus
            local gun = self:GetWeapon(1)
            gun.RateOfFireEnhancementBonus = bp.RateOfFireMultiplier
            gun:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect[enh]=true
            self.UpgradeDiscountAmounts.Mass = 
                self.UpgradeDiscountAmounts.Mass + (bp.BuildCostMass*0.9)
            self.UpgradeDiscountAmounts.Energy = 
                self.UpgradeDiscountAmounts.Energy + (bp.BuildCostEnergy*0.9)
        elseif  enh == "RateOfFireRemove" then
            --# Update the weapon
            local gun = self:GetWeapon(1)
            gun.RateOfFireEnhancementBonus = 1
            gun:UpdateRateOfFireFromBonuses()
            self.PossibleEnhancementInEffect.RateOfFire=false
        else
            WARN('Seraphim scout: Unknown enhancment.')
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
            Armour= false,
            RateOfFire = false,
            Damage = false,
        }
    end, 
}

XSL0101 = MakeChargingUnit(XSL0101)
TypeClass = XSL0101