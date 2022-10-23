--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/UAL0101B/UAL0101B_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Aeon Advanced Land Scout Script
--#**
--#****************************************************************************

local AHoverLandUnit = import('/lua/aeonunits.lua').AHoverLandUnit
local ADFLaserLightWeapon = import('/lua/aeonweapons.lua').ADFLaserLightWeapon

UAL0101B = Class(AHoverLandUnit) {
    Weapons = {
        LaserTurret = Class(ADFLaserLightWeapon) {}
    },
    
    OnStopBeingBuilt = function(self, builder, layer)
        AHoverLandUnit.OnStopBeingBuilt(self, builder, layer)
        --# Was on floor during upgrade so raise
        self:SetElevation(0.50)
        self:SetSpeedMult(1.5)
    end,
}

TypeClass = UAL0101B