--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/UEL0106B/UEL0106B_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF Upgraded Light Assault Bot Script
--#**
--#****************************************************************************
local TWalkingLandUnit = import('/lua/terranunits.lua').TWalkingLandUnit
local TDFMachineGunWeapon = import('/lua/terranweapons.lua').TDFMachineGunWeapon
local MakeChargingUnit = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher

local BaseClass = TWalkingLandUnit

UEL0106B = Class(BaseClass) {
    Weapons = {
        ArmCannonTurret = Class(TDFMachineGunWeapon) {
            DisabledFiringBones = {
                'Torso', 'Head',  'Arm_Right_B01', 'Arm_Right_B02','Arm_Right_Muzzle',
                'Arm_Left_B01', 'Arm_Left_B02','Arm_Left_Muzzle'
                },
        },
        MissileRack01 = Class(TSAMLauncher) {},
        --# This dummy weapon just makes the LAB
        --# run straight at any opponents in its area
        --# which should put it in range of its main weapon.
        Charge = Class(ChargingWeapon) {},
    },
}

UEL0106B = MakeChargingUnit(UEL0106B)
TypeClass = UEL0106B