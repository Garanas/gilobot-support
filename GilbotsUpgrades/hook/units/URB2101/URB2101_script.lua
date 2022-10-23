do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/URB2101/URB2101_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Cybran T1 Point Defense
--#**
--#****************************************************************************

local PreviousVersion = URB2101
URB2101 = Class(PreviousVersion) {
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my slider control.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#*
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        if statType == "RateOfFire" then 
            --# PD has only one weapon
            local gun = self:GetWeapon(1)
            --# Change the range
            gun:ChangeMaxRadius(newStatValue)
            --# Work out new rate of fire 
            --# Weapon rate of fire and max radius are inversly proportional 
            gun.RangeReductionRateOfFireBonus = gun:GetBlueprint().MaxRadius / newStatValue
            gun:UpdateRateOfFireFromBonuses()
        end
    end,
}

TypeClass = URB2101



end --(of non-destructive hook)