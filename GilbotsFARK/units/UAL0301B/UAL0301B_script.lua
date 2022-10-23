--#****************************************************************************
--#**
--#**  New File :  /mods/../units/UAL0301B/UAL0301B_script.lua
--#**
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Aeon FARK Script
--#**
--#****************************************************************************

local AWalkingLandUnit = import('/lua/aeonunits.lua').AWalkingLandUnit
local EffectUtil = import('/lua/EffectUtilities.lua')
local Buff = import('/lua/sim/Buff.lua')

UAL0301B = Class(AWalkingLandUnit) {

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  I added this override.
    --#*  It's easier to increase speed like this
    --#*  than fiddling with values in BP file.
    --#**
    OnStopBeingBuilt = function(self,builder,layer)
        AWalkingLandUnit.OnStopBeingBuilt(self,builder,layer)
        --# Setting it to 3 was too fast
        --# and animations looked crap
        self:SetSpeedMult(2)
    end,
    
    OnPrepareArmToBuild = function(self)
        AWalkingLandUnit.OnPrepareArmToBuild(self)
        self:BuildManipulatorSetEnabled(true)
        self.BuildArmManipulator:SetPrecedence(20)
    end,
        
    
    OnStopReclaim = function(self, target)
        AWalkingLandUnit.OnStopReclaim(self, target)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,

    OnFailedToBuild = function(self)
        AWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        AWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        self.UnitBeingBuilt = unitBeingBuilt
        self.UnitBuildOrder = order
        self.BuildingUnit = true     
    end,    

    OnStopBuild = function(self, unitBeingBuilt)
        AWalkingLandUnit.OnStopBuild(self, unitBeingBuilt)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
        self.UnitBeingBuilt = nil
        self.UnitBuildOrder = nil
        self.BuildingUnit = false          
    end,

    
    OnFailedToBuild = function(self)
        AWalkingLandUnit.OnFailedToBuild(self)
        self:BuildManipulatorSetEnabled(false)
        self.BuildArmManipulator:SetPrecedence(0)
    end,
    
    OnCreate = function(self)
        AWalkingLandUnit.OnCreate(self)
        self:SetCapturable(false)
        self:HideBone('Turbine', true)
        self:SetupBuildBones()
    end,
    
    CreateBuildEffects = function( self, unitBeingBuilt, order )
        EffectUtil.CreateAeonCommanderBuildingEffects( 
            self, unitBeingBuilt, 
            self:GetBlueprint().General.BuildBones.BuildEffectBones, 
            self.BuildEffectsBag 
        )
    end,     
    
    CreateEnhancement = function(self, enh)
        AWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        --#Teleporter
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        --#Shields
        elseif enh == 'Shield' then
            self:AddToggleCap('RULEUTC_ShieldToggle')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:UpdateConsumptionValues()
            self:CreatePersonalShield(bp)
        elseif enh == 'ShieldRemove' then
            self:DestroyShield()
            self:RemoveToggleCap('RULEUTC_ShieldToggle')
        elseif enh == 'ShieldHeavy' then
            self:ForkThread(self.CreateHeavyShield, bp)
        elseif enh == 'ShieldHeavyRemove' then
            self:DestroyShield()
            self:RemoveToggleCap('RULEUTC_ShieldToggle') 
        --#Engineering Focus Module
        elseif enh =='EngineeringFocusingModule' then
             if not Buffs['AeonSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'AeonSCUBuildRate',
                    DisplayName = 'AeonSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCUBuildRate')
        elseif enh == 'AdvancedEngineeringFocusingModule' then
            if not Buffs['AeonSCUBuildRate2'] then
                BuffBlueprint {
                    Name = 'AeonSCUBuildRate2',
                    DisplayName = 'AeonSCUBuildRate2',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCUBuildRate2')
        --#SystemIntegrityCompensator
        elseif enh == 'SystemIntegrityCompensator' then
            self:SetRegenRate(bp.NewRegenRate or 0)
        elseif enh == 'SystemIntegrityCompensatorRemove' then
            self:RevertRegenRate()
        --#Sacrifice
        elseif enh == 'Sacrifice' then
            self:AddCommandCap('RULEUCC_Sacrifice')
        elseif enh == 'SacrificeRemove' then
            self:RemoveCommandCap('RULEUCC_Sacrifice')  
        end
    end,
    
    CreateHeavyShield = function(self, bp)
        WaitTicks(1)
        self:CreatePersonalShield(bp)
        self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
        self:UpdateConsumptionValues()
    end,    
    
    OnPaused = function(self)
        AWalkingLandUnit.OnPaused(self)
        if self.BuildingUnit then
            AWalkingLandUnit.StopBuildingEffects(self, self:GetUnitBeingBuilt())
        end    
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            AWalkingLandUnit.StartBuildingEffects(self, self:GetUnitBeingBuilt(), self.UnitBuildOrder)
        end
        AWalkingLandUnit.OnUnpaused(self)
    end,         
}

TypeClass = UAL0301B
