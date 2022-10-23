--#****************************************************************************
--#**
--#**  Hook File:  /units/UAL0309/UAL0309_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Aeon T3 Engineer Script
--#**
--#****************************************************************************
--#
--# AEON TECH 3 ENGINEER
--#
local AConstructionUnit = import('/lua/aeonunits.lua').AConstructionUnit
UAL0309 = Class(AConstructionUnit) {

    CreateEnhancement = function(self, enh)
        AConstructionUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        end
    end,
}

TypeClass = UAL0309

