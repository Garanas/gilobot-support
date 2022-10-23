--#****************************************************************************
--#**
--#**  Hook File:  /units/XEL0209/UXL0209_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF Tech 2 Field Engineer
--#**
--#****************************************************************************
local Shield = import('/lua/shield.lua').Shield

local PreviousUnit = XEL0209
XEL0209 = Class(PreviousUnit) {

    CreateEnhancement = function(self, enh)
        PreviousUnit.CreateEnhancement(self, enh)
        
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if enh == 'Speed' then
            self:SetSpeedMult(2)
        elseif enh == 'SpeedRemove' then
            self:SetSpeedMult(1)
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:CreatePersonalShield(bp)
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            RemoveUnitEnhancement(self, 'ShieldRemove')
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'ShieldGeneratorField' then
            self:DestroyShield()
            ForkThread(function()
                WaitTicks(1)
                self:CreateShield(bp)
                self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
                self:SetMaintenanceConsumptionActive()
            end)
        elseif enh == 'ShieldGeneratorFieldRemove' then
            self:DestroyShield()
            self:SetMaintenanceConsumptionInactive()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        end
    end,
}

TypeClass = XEL0209