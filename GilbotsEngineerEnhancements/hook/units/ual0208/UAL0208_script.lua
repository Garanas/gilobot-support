--#****************************************************************************
--#**
--#**  Hook File:  /units/UAL0208/UAL0208_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Aeon T2 Engineer Script
--#**
--#****************************************************************************
--#
--# AEON TECH 2 ENGINEER
--#
local AConstructionUnit = import('/lua/aeonunits.lua').AConstructionUnit
UAL0208 = Class(AConstructionUnit) {
    CreateEnhancement = function(self, enh)
        AConstructionUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        end
    end,
}

TypeClass = UAL0208

