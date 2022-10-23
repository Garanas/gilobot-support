--#****************************************************************************
--#**
--#**  Hook File:  /units/UEB1102/UEB1102_script.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF Hydrocarbon Power Plant Script
--#**
--#****************************************************************************

local HydroCarbonPowerPlant = 
    import('/mods/GilbotsModPackCore/lua/unitmods/hcpp.lua').HydroCarbonPowerPlant
local MakeDamageLimitationSystemUser = 
    import('/mods/GilbotsModPackCore/lua/autodefend/dls.lua').MakeDamageLimitationSystemUser

local BaseClass = 
    MakeDamageLimitationSystemUser(HydroCarbonPowerPlant)
    
UEB1102 = Class(BaseClass) {

    --# Effects particular to this unit.  All units can do this.
    DestructionPartsHighToss = {'Exhaust01',},
    DestructionPartsLowToss = {'Exhaust01','Exhaust02','Exhaust03','Exhaust04','Exhaust05',},
    DestructionPartsChassisToss = {'UEB1102'},
}

TypeClass = UEB1102