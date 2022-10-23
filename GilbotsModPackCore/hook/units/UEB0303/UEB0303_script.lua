--#****************************************************************************
--#**
--#**  Hook File:  /units/UEB0303/UEB0303_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  UEF Sea Factory T3 Script
--#**              Hooked because there was an error.
--#**              If you pause this unit too quickly when it 
--#**              is first built, there is an error because 
--#**              the ArmSlider has not yet been created.
--#**
--#****************************************************************************

local BaseClass = UEB0303
UEB0303 = Class(BaseClass) {
    OnStopBeingBuilt = function(self)
        if not self.ArmSlider1 then
            self.ArmSlider1 = CreateSlider(self, 'Right_Arm')
            self.Trash:Add(self.ArmSlider1)
        end
        if not self.ArmSlider2 then
            self.ArmSlider2 = CreateSlider(self, 'Center_Arm')
            self.Trash:Add(self.ArmSlider2)
        end
        if not self.ArmSlider3 then
            self.ArmSlider3 = CreateSlider(self, 'Left_Arm')
            self.Trash:Add(self.ArmSlider3)
        end
        BaseClass.OnStopBeingBuilt(self)
    end,
}

TypeClass = UEB0303