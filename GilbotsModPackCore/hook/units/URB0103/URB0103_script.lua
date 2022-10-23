--#****************************************************************************
--#**
--#**  Hook File:  /units/URB0103/URB0103_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Cybran Sea Factory T1 Script
--#**              Hooked because there was an error.
--#**              If you pause this unit too quickly when it 
--#**              is first built, there is an error because 
--#**              the ArmSlider has not yet been created.
--#**
--#****************************************************************************

local BaseClass = URB0103
URB0103 = Class(BaseClass) {
    OnStopBeingBuilt = function(self)
        if not self.ArmSlider then
            self.ArmSlider = CreateSlider(self, 'Right_Arm03')
            self.Trash:Add(self.ArmSlider)
        end
        BaseClass.OnStopBeingBuilt(self)
    end,
}

TypeClass = URB0103