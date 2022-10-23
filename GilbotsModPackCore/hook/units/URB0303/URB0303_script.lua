--#****************************************************************************
--#**
--#**  Hook File:  /units/URB0303/URB0303_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Cybran Sea Factory T3 Script
--#**              Hooked because there was an error.
--#**              If you pause this unit too quickly when it 
--#**              is first built, there is an error because 
--#**              the ArmSlider has not yet been created.
--#**
--#****************************************************************************

local BaseClass = URB0303
URB0303 = Class(BaseClass) {
    OnStopBeingBuilt = function(self)
        if not self.ArmSlider1 then
            self.ArmSlider1 = CreateSlider(self, 'Right_Arm03')
            self.Trash:Add(self.ArmSlider1)
        end
        if not self.ArmSlider2 then
            self.ArmSlider2 = CreateSlider(self, 'Right_Arm02')
            self.Trash:Add(self.ArmSlider2)
        end
        if not self.ArmSlider3 then
            self.ArmSlider3 = CreateSlider(self, 'Right_Arm01')
            self.Trash:Add(self.ArmSlider3)
        end
        BaseClass.OnStopBeingBuilt(self)
    end,
}

TypeClass = URB0303