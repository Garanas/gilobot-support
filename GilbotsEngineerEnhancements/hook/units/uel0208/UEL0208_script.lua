--#****************************************************************************
--#**
--#**  Hook File:  /units/UEL0208/UEL0208_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF Tech 2 Engineer
--#**
--#****************************************************************************

local PreviousVersion = UEL0208
UEL0208 = Class(PreviousVersion) {

    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        --# Add enhancement for Resource Allocation
        --# which is usefull if player is desperate for 
        --# wants to use wasted resources in strong economy
        if enh == 'ResourceAllocation' then
            local bp = self:GetBlueprint().Enhancements[enh]
            local bpEcon = self:GetBlueprint().Economy
            if not bp then return end
            self:SetProductionPerSecondEnergy(bp.ProductionPerSecondEnergy +
                                              (bpEcon.ProductionPerSecondEnergy or 0))
            self:SetProductionPerSecondMass(bp.ProductionPerSecondMass + 
                                            (bpEcon.ProductionPerSecondMass or 0))
        elseif enh == 'ResourceAllocationRemove' then
            local bpEcon = self:GetBlueprint().Economy
            self:SetProductionPerSecondEnergy(bpEcon.ProductionPerSecondEnergy or 0)
            self:SetProductionPerSecondMass(bpEcon.ProductionPerSecondMass or 0)
        elseif enh == 'Speed' then
            self:SetSpeedMult(2)
        elseif enh == 'SpeedRemove' then
            self:SetSpeedMult(1)
        end
    end,
}
    
TypeClass = UEL0208