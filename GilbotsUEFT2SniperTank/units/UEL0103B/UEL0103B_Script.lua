--#****************************************************************************
--#**
--#**  New File :  /units/UEL0103B/UEL0103B_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  UEF T2 Sniper Tank Script
--#**
--#****************************************************************************

local TLandUnit = import('/lua/terranunits.lua').TLandUnit
--# This is the weapon class used by the normal T2 tank.
local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon

UEL0103B = Class(TLandUnit) {
    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {}
    },
}

TypeClass = UEL0103B