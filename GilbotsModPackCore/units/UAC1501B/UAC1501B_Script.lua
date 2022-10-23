--#****************************************************************************
--#*
--#*  Hook File:  /mods/.../units/UAC1501B/UAC1501B_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  Aeon Auto Toggle Controller Node Script
--#*
--#*  
--#****************************************************************************

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local AStructureUnit = 
    import('/lua/aeonunits.lua').AStructureUnit
local MakeAutoToggleController = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua').MakeAutoToggleController
local BaseClass = 
    MakeAutoToggleController(AStructureUnit)
    
UAC1501B = Class(BaseClass) {
}

TypeClass = UAC1501B