--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/UEL0101B/UEL0101B_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Aeon Advanced Land Scout Script
--#**
--#****************************************************************************

local TConstructionUnit = import('/lua/terranunits.lua').TConstructionUnit
local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon


UEL0101B = Class(TConstructionUnit) {
    
    Weapons = {
        MainGun = Class(TDFMachineGunWeapon) {
        },
    },
    
    OnStopBeingBuilt = function(self, builder, layer)
        TConstructionUnit.OnStopBeingBuilt(self, builder, layer)
        self:SetSpeedMult(1.5)
    end,

}


TypeClass = UEL0101B
