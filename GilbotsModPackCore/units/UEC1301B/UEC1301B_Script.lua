--#****************************************************************************
--#*
--#*  Hook File:  /mods/.../units/UEC1301B/UEC1301B_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  UEF Auto Toggle Controller Node Script
--#*
--#*  
--#****************************************************************************

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local TStructureUnit = 
    import('/lua/terranunits.lua').TStructureUnit
local MakeAutoToggleController = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua').MakeAutoToggleController
local BaseClass = 
    MakeAutoToggleController(TStructureUnit)
    
UEC1301B = Class(BaseClass) {
}

TypeClass = UEC1301B