#****************************************************************************
#**  Summary  :  UEF SubCommander Script
#****************************************************************************

local Buff = import('/lua/sim/Buff.lua')

local oldUEL0301 = UEL0301
UEL0301 = Class(oldUEL0301) {
    

    CreateEnhancement = function(self, enh)
        TWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if enh =='ResourceAllocation' then
            if not Buffs['UefSCUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'UefSCUResourceAllocation',
                    DisplayName = 'UefSCUResourceAllocation',
                    BuffType = 'UefSCUResourceAllocation',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MassProductionBuf = {
                            Add =  bp.ProductionPerSecondMass,
                            Mult = 1,
                        },
                        EnergyProductionBuf = {
                            Add = bp.ProductionPerSecondEnergy,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UefSCUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'UefSCUResourceAllocation',false)
        
        #SensorRangeEnhancer
        elseif enh == 'SensorRangeEnhancer' then
        	if not Buffs['UefSCUSensorRangeEnhancer'] then
                BuffBlueprint {
                    Name = 'UefSCUSensorRangeEnhancer',
                    DisplayName = 'UefSCUSensorRangeEnhancer',
                    BuffType = 'UefSCUSensorRangeEnhancer',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        VisionRadius = {
                            Add =  bp.NewVisionRadius,
                            Mult = 1,
                        },
                        OmniRadius = {
                            Add = bp.NewOmniRadius,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UefSCUSensorRangeEnhancer')
        elseif enh == 'SensorRangeEnhancerRemove' then
            Buff.RemoveBuff(self,'UefSCUSensorRangeEnhancer',false)
        
        #AdvancedCoolingUpgrade
        elseif enh =='AdvancedCoolingUpgrade' then
        	if not Buffs['UefSCUAdvancedCoolingUpgrade'] then
                BuffBlueprint {
                    Name = 'UefSCUAdvancedCoolingUpgrade',
                    DisplayName = 'UefSCUAdvancedCoolingUpgrade',
                    BuffType = 'UefSCUAdvancedCoolingUpgrade',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        RateOfFireBuf = {
                            Add =  bp.NewRateOfFire,
                            Mult = 1,
                            ByName = {
                            	RightHeavyPlasmaCannon = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UefSCUAdvancedCoolingUpgrade')
        elseif enh =='AdvancedCoolingUpgradeRemove' then
        	Buff.RemoveBuff(self,'UefSCUAdvancedCoolingUpgrade',false)
        
       	#High Explosive Ordnance
        elseif enh =='HighExplosiveOrdnance' then
        	if not Buffs['UefSCUHighExplosiveOrdnance'] then
                BuffBlueprint {
                    Name = 'HighExplosiveOrdnance',
                    DisplayName = 'HighExplosiveOrdnance',
                    BuffType = 'HighExplosiveOrdnance',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Damage = {
                            Add =  bp.NewDamageRadius,
                            Mult = 1,
                            ByName = {
                            	RightHeavyPlasmaCannon = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'HighExplosiveOrdnance')
        
        elseif enh =='HighExplosiveOrdnanceRemove' then
            Buff.RemoveBuff(self,'UefSCUHighExplosiveOrdnance',false)
        else
        	oldUEL0301.CreateEnhancement(self, enh)
        end
    end,

      

}

TypeClass = UEL0301