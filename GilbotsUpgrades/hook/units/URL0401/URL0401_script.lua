--#****************************************************************************
--#**
--#**  Hook File:  /mods/gilbotsupgrades/units/url0401/url0401_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Scathis to use enhancements.
--#**
--#****************************************************************************

local PreviousVersion = URL0401
URL0401 = Class(PreviousVersion) {
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my enhancements
    --#*  so that they can be removed correctly.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        PreviousVersion.OnStopBeingBuilt(self, builder, layer)
        
        --# Gilbot-X: This is used with my slider control 
        --# that needs to use sync values if its min 
        --# and max values are changing due to enhancements.
        --# I just put some default values in. These will 
        --# be overwritten in a moment.
        self.SliderControlledStatValues = {
            RateOfFire = {
                CurrentValue = 0.5,
                MinValue = 0.1, -- once every 10 seconds
                MaxValue = 0.5, -- once every 2 seconds
                DefaultValue= 0.5,
                DefaultEnergyConsumption= 0,
                DefaultMassConsumption= 0,
                CanUseSliderNow=false,
            },
        }
    
        --# Do the first sync now so it works
        self.Sync.SliderControlledStatValues = self.SliderControlledStatValues
      
        --# Make sure the button that represents 
        --# the default weapon is already selected.
        self:CreateEnhancement('RapidFire1')
        self.StartingEnhancementInitialisationDone = true         
    end,
       
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  The enahncements add enhanced projectiles that spout a group of
    --#*  crawling bombs that can use stealth and cloak.
    --#**
    CreateEnhancement = function(self, enh)
        --# Enhancement calling superclass 
        PreviousVersion.CreateEnhancement(self, enh)
        --# Read enhancement details from blueprint
        local bp = self:GetBlueprint().Enhancements[enh]    
        if not bp then return end
        
        --# All enhancements deal with the main weapon
        local weapon = self:GetWeapon(1)
        local weaponBP = weapon:GetBlueprint()
        
        if enh == "CrawlingBombLauncher" or
           enh == "StunningTheftLauncher" then
            weapon.RateOfFireEnhancementBonus = bp.RateOfFireMultiplier
            weapon:UpdateRateOfFireFromBonuses()
            --# Replace Weapon
            self:ChangeWeaponDamage(weapon, bp.Damage)
            weapon:ChangeDamageRadius(bp.DamageRadius)
            weapon:ChangeMaxRadius(bp.MaxRadius)
            weapon:ChangeMinRadius(bp.MinRadius)
            weapon:ChangeProjectileBlueprint(bp.ProjectileId)
            --# This is used with my slider control for data sync
            local newMaxRateOfFire = weaponBP.RateOfFire * bp.RateOfFireMultiplier
            local newMinRateOfFire = weaponBP.RateOfFire * bp.RateOfFireMultiplierMin
            self.SliderControlledStatValues.RateOfFire.CurrentValue = newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.MaxValue = newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.MinValue = newMinRateOfFire
            self.SliderControlledStatValues.RateOfFire.DefaultValue= newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.CanUseSliderNow=true
            --# Do the sync
            self.Sync.SliderControlledStatValues = self.SliderControlledStatValues
       
        elseif enh == "RapidFire1" then
            --# This is the original weapon
            weapon.RateOfFireEnhancementBonus = bp.RateOfFireMultiplier
            weapon:UpdateRateOfFireFromBonuses()
            
            --# Revert the other weapon features to their original state.
            --# Don't do this as part of unit initialisation.
            if self.StartingEnhancementInitialisationDone then  
                self:ChangeWeaponDamage(weapon, weaponBP.Damage)
                weapon:ChangeDamageRadius(weaponBP.DamageRadius)
                weapon:ChangeMaxRadius(weaponBP.MaxRadius)
                weapon:ChangeMinRadius(weaponBP.MinRadius)
                weapon:ChangeProjectileBlueprint(weaponBP.ProjectileId)
            end
            --# This is used with my slider control for data sync
            local newMaxRateOfFire = weaponBP.RateOfFire * bp.RateOfFireMultiplier
            local newMinRateOfFire = weaponBP.RateOfFire * bp.RateOfFireMultiplierMin
            self.SliderControlledStatValues.RateOfFire.CurrentValue = newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.MaxValue = newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.MinValue = newMinRateOfFire
            self.SliderControlledStatValues.RateOfFire.DefaultValue= newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.CanUseSliderNow=true
            --# Do the sync
            self.Sync.SliderControlledStatValues = self.SliderControlledStatValues
        
        elseif  enh == "RapidFire2" or 
                enh == "RapidFire3" then
            --# Revert the weapon to its original state.
            --# Don't do this as part of unit initialisation.
            weapon.RateOfFireEnhancementBonus = bp.RateOfFireMultiplier
            weapon:UpdateRateOfFireFromBonuses()
            --# This is used with my slider control for data sync
            local newMaxRateOfFire = weaponBP.RateOfFire * bp.RateOfFireMultiplier
            local newMinRateOfFire = weaponBP.RateOfFire * bp.RateOfFireMultiplierMin
            self.SliderControlledStatValues.RateOfFire.CurrentValue = newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.MaxValue = newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.MinValue = newMinRateOfFire
            self.SliderControlledStatValues.RateOfFire.DefaultValue= newMaxRateOfFire
            self.SliderControlledStatValues.RateOfFire.CanUseSliderNow=true
            --# Do the sync
            self.Sync.SliderControlledStatValues = self.SliderControlledStatValues
        
        --# If removing enhancements then make sure 
        --# the default one is selected afterwards.
        elseif enh == "CrawlingBombLauncherRemove" or
               enh == "StunningTheftLauncherRemove" or 
               enh == "RapidFire2Remove" or 
               enh == "RapidFire3Remove"
        then
            self:CreateEnhancement('RapidFire1') 
        end
            
    end,
    

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this because Weapon:ChangeDamage() does not work in FA.
    --#*  This is called from the CreateEnhancement() function above.
    --#**
    ChangeWeaponDamage = function(self, weapon, newDamageValue)
        --# Perform safety check so we have a positive integer
        if newDamageValue < 0 then newDamageValue=0 end
        newDamageValue = math.floor(newDamageValue)
        local originalDamageValue = weapon:GetBlueprint().Damage
        --# Hopefully DamageMod accepts negative numbers!
        weapon.DamageMod= newDamageValue - originalDamageValue
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my 'Stat Slider' mod.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#*
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        if statType == "RateOfFire" then
            local weapon = self:GetWeapon(1)
            local originalROF= weapon:GetBlueprint().RateOfFire
            local rateOfFireMultiplier = newStatValue/originalROF
            weapon.RateOfFireEnhancementBonus = rateOfFireMultiplier
            weapon:UpdateRateOfFireFromBonuses()
        end
    end,
}

TypeClass = URL0401