do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /units/UAA0310/UAA0310_script.lua
--#**  
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Aeon CZAR Script
--#**
--#****************************************************************************

--# Make this unit have same auto-toggle priority class as counter-intel
local BaseClass = UAA0310
UAA0310 = Class(BaseClass) {
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my 'Stat Slider' mod.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#*
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        self.MyShield:SetMaxHealthAndRegenRate(newStatValue)
    end,
}

TypeClass = UAA0310


end --(of non-destructive hook)