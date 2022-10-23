do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/URB2302/URB2302_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Cybran T3 Artillery
--#**
--#****************************************************************************

local PreviousVersion = URB2302
URB2302 = Class(PreviousVersion) {
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Makes enhancements work.
    --#**
    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        --# Get the unit's only weapon
        local weapon = self:GetWeapon(1)
        --# and the original value for its range.
        local originalValue = weapon:GetBlueprint().MaxRadius
            
        if  enh == "MaxWeaponRadius1" or 
            enh == "MaxWeaponRadius2" or
            enh == "MaxWeaponRadius3" then
            --# Update weapon with extra bonus
            weapon:ChangeMaxRadius(originalValue*bp.MaxWeaponRadiusMultiplier)
        
        elseif  enh == "MaxWeaponRadius1Remove" or 
                enh == "MaxWeaponRadius2Remove" or
                enh == "MaxWeaponRadius3Remove" then
            --# Revert the weapon to original value
            weapon:ChangeMaxRadius(originalValue)
        
        elseif  enh == "RateOfFire1" or 
                enh == "RateOfFire2" or
                enh == "RateOfFire3" then
            --# Update weapon with extra bonus
            weapon.RateOfFireEnhancementBonus = bp.RateOfFireMultiplier
            weapon:UpdateRateOfFireFromBonuses()
        
        elseif  enh == "RateOfFire1Remove" or 
                enh == "RateOfFire2Remove" or 
                enh == "RateOfFire3Remove" then
            --# Update the weapon
            weapon.RateOfFireEnhancementBonus = 1
            weapon:UpdateRateOfFireFromBonuses()
        end
    end,
}

TypeClass = URB2302



end --(of non-destructive hook)