--#****************************************************************************
--#*
--#*  Hook File:  /mods/.../units/XSC1301B/XSC1301B_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  Seraphim Auto Toggle Controller Node Script
--#*
--#*  
--#****************************************************************************

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local SStructureUnit = 
    import('/lua/seraphimunits.lua').SStructureUnit
local MakeAutoToggleController = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua').MakeAutoToggleController
local BaseClass = 
    MakeAutoToggleController(SStructureUnit)
    
XSC1301B = Class(BaseClass) {
}

TypeClass = XSC1301B