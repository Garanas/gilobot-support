--#****************************************************************************
--#**
--#**  Hook File:  /units/UEL0105/UEL0105_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF Tech 1 Engineer
--#**
--#****************************************************************************

local PreviousUnit = UEL0105
UEL0105 = Class(PreviousUnit) {

    CreateEnhancement = function(self, enh)
        PreviousUnit.CreateEnhancement(self, enh)
        --local bp = self:GetBlueprint().Enhancements[enh]
        --if not bp then return end
        if enh == 'Speed' then
            self:SetSpeedMult(2)
        elseif enh == 'SpeedRemove' then
            self:SetSpeedMult(1)
        end
    end,
}

TypeClass = UEL0105