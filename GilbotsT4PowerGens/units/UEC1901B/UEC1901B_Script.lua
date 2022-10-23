--#****************************************************************************
--#** 
--#**  File     :  /cdimage/units/UEC1901/UEC1901_script.lua 
--#**  Author(s):  John Comes, David Tomandl 
--#** 
--#**  Summary  :  Earth Blacksun, Ver1
--#** 
--#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--#****************************************************************************
local TEnergyCreationUnit = import('/lua/terranunits.lua').TEnergyCreationUnit
local TIFCommanderDeathWeapon = import('/lua/terranweapons.lua').TIFCommanderDeathWeapon

UEC1901B = Class(TEnergyCreationUnit) {

    --# This code makes us explode
    --# This line needed if FireOnDeath not set to true 
    --# in weapon BP of DeathWeapon
    --# See line 866 in unit.lua
    DeathThreadDestructionWaitTime = 1,
    
    --# It has to be called DeathWeapon otherwise it doesn't work
    Weapons = {
        DeathWeapon = Class(TIFCommanderDeathWeapon) {},
    },	
}


TypeClass = UEC1901B

