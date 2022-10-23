--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/hcpp.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Used by HCPP so that energy output increases over time.
--#*            It is code from my Exponential Hydrocarbon mod.
--#*
--#*****************************************************************************

--# This unit will receive any changes
--# made to EnergyCreationUnit class.
local EnergyCreationUnit = 
    import('/lua/defaultunits.lua').EnergyCreationUnit

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local MakePauseableActiveEffectsUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/pauseableactiveeffectsunit.lua').MakePauseableActiveEffectsUnit
local MakeTimeBasedOutputUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/timebasedoutputunit.lua').MakeTimeBasedOutputUnit
local BaseClass = 
    MakeTimeBasedOutputUnit(
        MakePauseableActiveEffectsUnit(EnergyCreationUnit)
    )
    
HydroCarbonPowerPlant = Class(BaseClass) {
    --# This defines how often the HCPP 
    --# updates its output, in seconds.   
    ProductionUpdateSeconds = 10,
}
