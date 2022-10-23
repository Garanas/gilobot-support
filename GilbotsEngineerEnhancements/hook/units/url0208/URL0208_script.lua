--#****************************************************************************
--#**
--#**  Hook File:  /units/URL0208/URL0208_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran T2 Engineer Script
--#**
--#**  Notes    :  Code taken from Cybran ACU script file.  
--#****************************************************************************

local CConstructionUnit = import('/lua/cybranunits.lua').CConstructionUnit
local EffectUtil = import('/lua/EffectUtilities.lua')

URL0208 = Class(CConstructionUnit) {
    Treads = {
        ScrollTreads = true,
        BoneName = 'URL0208',
        TreadMarks = 'tank_treads_albedo',
        TreadMarksSizeX = 0.65,
        TreadMarksSizeZ = 0.4,
        TreadMarksInterval = 0.3,
        TreadOffset = { 0, 0, 0 },
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        CConstructionUnit.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionInactive()
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('SonarStealth')
        self:DisableUnitIntel('Cloak')
    end,
    

    --# ***************************
    --# Enhancements
    --# ***************************  
    
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
                    'URL0208',
                    'Buildpoint_Center',
                },
                Scale = 1.0,
                Type = 'Cloak01',
            },
        },
        Field = {
            {
                Bones = {
                    'URL0208',
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
            self:SetEnergyMaintenanceConsumptionOverride( 
                self:GetBlueprint().Enhancements['CloakingGenerator'].MaintenanceConsumptionPerSecondEnergy or 0
            )
            self:SetMaintenanceConsumptionActive()
            if not self.IntelEffectsBag then
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects( self, self.IntelEffects.Cloak, 'FXIdle',  
                                               self:GetCurrentLayer(), nil, self.IntelEffectsBag )
            end            
        elseif self.StealthEnh and self:IsIntelEnabled('RadarStealth') and self:IsIntelEnabled('SonarStealth') then
            self:SetEnergyMaintenanceConsumptionOverride(
                self:GetBlueprint().Enhancements['StealthGenerator'].MaintenanceConsumptionPerSecondEnergy or 0
            )
            self:SetMaintenanceConsumptionActive()  
            if not self.IntelEffectsBag then 
                self.IntelEffectsBag = {}
                self.CreateTerrainTypeEffects( self, self.IntelEffects.Field, 'FXIdle',  
                                               self:GetCurrentLayer(), nil, self.IntelEffectsBag )
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
        elseif self.StealthEnh and not self:IsIntelEnabled('RadarStealth') 
                               and not self:IsIntelEnabled('SonarStealth') then
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

TypeClass = URL0208