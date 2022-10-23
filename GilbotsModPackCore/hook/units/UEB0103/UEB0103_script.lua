--#****************************************************************************
--#**
--#**  Hook File:  /units/UEB0103/UEB0103_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  UEF Sea Factory T1 Script
--#**              Hooked because there was an error.
--#**              If you pause this unit too quickly when it 
--#**              is first built, there is an error because 
--#**              the ArmSlider has not yet been created.
--#**
--#****************************************************************************

local BaseClass = UEB0103
UEB0103 = Class(BaseClass) {
    OnStopBeingBuilt = function(self)
        if not self.ArmSlider then
            self.ArmSlider = CreateSlider(self, 'Right_Arm')
            self.Trash:Add(self.ArmSlider)
        end
        BaseClass.OnStopBeingBuilt(self)
    end,
}

TypeClass = UEB0103