do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/UAB2302/UAB2302_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Aeon T3 Artillery
--#**
--#****************************************************************************

local PreviousVersion = UAB2302
UAB2302 = Class(PreviousVersion) {
    
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
            enh == "MaxWeaponRadius2" then
            --# Update weapon with extra bonus
            weapon:ChangeMaxRadius(originalValue*bp.MaxWeaponRadiusMultiplier)
        
        elseif  enh == "MaxWeaponRadius1Remove" or 
                enh == "MaxWeaponRadius2Remove" then
            --# Revert the weapon to original value
            weapon:ChangeMaxRadius(originalValue)
        end
    end,
}

TypeClass = UAB2302



end --(of non-destructive hook)