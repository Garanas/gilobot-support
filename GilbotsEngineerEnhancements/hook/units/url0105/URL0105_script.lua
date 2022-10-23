--#****************************************************************************
--#**
--#**  Hook File:  /units/URL0105/URL0105_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran T1 Engineer Script
--#**
--#**  Notes    :  Code taken from Cybran ACU script file.  
--#****************************************************************************

local CConstructionUnit = import('/lua/cybranunits.lua').CConstructionUnit
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

    
URL0105 = Class(CConstructionUnit) {

    RebuildEnhancement = 0,
    ReclaimEnhancementFactor = 1,
    ReclaimEnhancementBonus = 0,

    OnStopBeingBuilt = function(self,builder,layer)
        CConstructionUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
    end,
    
    
    
    --# ***************************
    --# Cybran Build Effects
    --# ***************************    
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.SpawnBuildBots( self, unitBeingBuilt, 5, self.BuildEffectsBag )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)    
        CConstructionUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true        
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        CConstructionUnit.OnStopBuild(self, unitBeingBuilt)
        if self:BeenDestroyed() then return end  
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,
    
    
    OnPaused = function(self)
        CConstructionUnit.OnPaused(self)
        if self.BuildingUnit then
            CConstructionUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            CConstructionUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        CConstructionUnit.OnUnpaused(self)
    end,   
    
    
    --# ***************************
    --# Enhancements
    --# ***************************  
    GetRebuildBonus = function(self, rebuildUnitBP)
        --# originally everything is re-built is 50% complete to begin with
        return 0.5 + self.RebuildEnhancement
    end,
    
    --# Return the total time in seconds, cost in energy, and cost in mass to reclaim the given target from 100%.
    --# The energy and mass costs will normally be negative, to indicate that you gain mass/energy back.
    GetReclaimCosts = function(self, target_entity)
        local bp = self:GetBlueprint()
        local target_bp = target_entity:GetBlueprint()
        if IsUnit(target_entity) then
            
            local mtime = target_bp.Economy.BuildCostEnergy / self:GetBuildRate()
            local etime = target_bp.Economy.BuildCostMass / self:GetBuildRate()
            local time = mtime
            if mtime < etime then
                time = etime
            end
            
            time = time * (self.ReclaimTimeMultiplier or 1)
            return (time/10), target_bp.Economy.BuildCostEnergy, target_bp.Economy.BuildCostMass
        elseif IsProp(target_entity) then
            local time, energy, mass =  target_entity:GetReclaimCosts(self)
            mass = (mass * self.ReclaimEnhancementFactor) + self.ReclaimEnhancementBonus
            --WARN('Reclaiming a prop.  Time = ', repr(time), ' Mass = ', repr(mass), ' Energy = ', repr(energy))
            return time, energy, mass
        end
    end,
    
    CreateEnhancement = function(self, enh)
        CConstructionUnit.CreateEnhancement(self, enh)
        if enh == 'StealthGenerator' then
            self:AddToggleCap('RULEUTC_CloakToggle')
            if self.IntelEffectsBag then
                EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
                self.IntelEffectsBag = nil
            end
            self.CloakEnh = false        
            self.StealthEnh = true
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('SonarStealth')
        elseif enh == 'StealthGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('SonarStealth')           
            self.StealthEnh = false
            self.CloakEnh = false 
            self.StealthFieldEffects = false
            self.CloakingEffects = false    
        elseif enh == 'RebuildBonusIncrease' then
            self.RebuildEnhancement = 0.2
        elseif enh == 'RebuildBonusIncreaseRemove' then
            self.RebuildEnhancement = 0
        elseif enh == 'ReclaimMassBonus' then
            self.ReclaimEnhancementFactor = 2
            self.ReclaimEnhancementBonus = 5
        elseif enh == 'ReclaimMassBonusRemove' then
            self.ReclaimEnhancementFactor = 1
            self.ReclaimEnhancementBonus = 0            
        elseif enh == 'ResourceAllocation' then
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
        elseif enh == 'CloakingGenerator' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            self.StealthEnh = false
            self.CloakEnh = true 
            self:EnableUnitIntel('Cloak')
        elseif enh == 'CloakingGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Cloak')
            self.CloakEnh = false 
        end             
    end,
    
    
    --# ***************************
    --# Intel
    --# ***************************    
    IntelEffects = {
        Cloak = {
            {
                Bones = {
                    'URL0105',
                    'Buildpoint_Center',
                },
                Scale = 1.0,
                Type = 'Cloak01',
            },
        },
        Field = {
            {
                Bones = {
                    'URL0105',
                    'Buildpoint_Center',
                },
                Scale = 1.6,
                Type = 'Cloak01',
            },	
        },	
    },
    
    OnIntelEnabled = function(self)
        CConstructionUnit.OnIntelEnabled(self)
        if self.CloakEnh and self:IsIntelEnabled('Cloak') then 
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
			    self.IntelEffectsBag = {}
			    self.CreateTerrainTypeEffects( self, self.IntelEffects.Cloak, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
			end            
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()  
            if not self.IntelEffectsBag then 
	            self.IntelEffectsBag = {}
		        self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  self:GetCurrentLayer(), nil, self.IntelEffectsBag )
		    end                  
        end		
    end,

    OnIntelDisabled = function(self)
        CConstructionUnit.OnIntelDisabled(self)
        if self.IntelEffectsBag then
            EffectUtil.CleanupEffectBag(self,'IntelEffectsBag')
            self.IntelEffectsBag = nil
        end
        if self.CloakEnh and not self:IsIntelEnabled('Cloak') then
            self:SetMaintenanceConsumptionInactive()
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') and not self:IsIntelEnabled('SonarStealth') then
            self:SetMaintenanceConsumptionInactive()
        end          
    end,
    
    
    OnScriptBitSet = function(self, bit)
        if bit == 8 then --# cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')          
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 8 then --# cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        end
    end,
}

TypeClass = URL0105