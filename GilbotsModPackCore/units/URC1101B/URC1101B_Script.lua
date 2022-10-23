--#****************************************************************************
--#*
--#*  Hook File:  /mods/.../units/URC1101B/URC1101B_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  Cybran Auto Toggle Controller Node Script
--#*
--#*  
--#****************************************************************************

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local CStructureUnit = 
    import('/lua/cybranunits.lua').CStructureUnit
local MakeAutoToggleController = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua').MakeAutoToggleController
local BaseClass = 
    MakeAutoToggleController(CStructureUnit)
    
URC1101B = Class(BaseClass) {
}

TypeClass = URC1101B