--#****************************************************************************
--#**
--#**  New File :  /units/UAL0106B/UAL0106B_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Aeon Light Assault Bot Script
--#**
--#****************************************************************************

local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit
local ADFSonicPulsarWeapon = import('/lua/aeonweapons.lua').ADFSonicPulsarWeapon
local MakeChargingUnit = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon
--# Added wepon from EW
local ADFLaserLightWeapon = 
    import('/lua/aeonweapons.lua').ADFLaserLightWeapon

local BaseClass = AWalkingLandUnit

UAL0106B = Class(BaseClass) {
    Weapons = {
        ArmLaserTurret = Class(ADFSonicPulsarWeapon) {},
        ArmLaserTurretMod = Class(ADFLaserLightWeapon) {},
		ArmLaserTurretMod02 = Class(ADFLaserLightWeapon) {},
        --# This dummy weapon just makes the LAB
        --# run straight at any opponents in its area
        --# which should put it in range of its main weapon.
        Charge = Class(ChargingWeapon) {},
    },
}

UAL0106B = MakeChargingUnit(UAL0106B)
TypeClass = UAL0106B