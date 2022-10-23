#****************************************************************************
#**  Summary  :  Aeon Sub Commander Script
#****************************************************************************

oldUAL0301 = UAL0301
UAL0301 = Class(oldUAL0301) {
    
    CreateEnhancement = function(self, enh)
        AWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        #Teleporter
        #ResourceAllocation              
        
        if enh == 'ResourceAllocation' then
        	if not Buffs['AeonSCUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'AeonSCUResourceAllocation',
                    DisplayName = 'AeonSCUResourceAllocation',
                    BuffType = 'AeonSCUResourceAllocation',
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
            Buff.ApplyBuff(self, 'AeonSCUResourceAllocation')
        elseif enh == 'AeonSCUResourceAllocation' then
            Buff.RemoveBuff(self,'AeonSCUResourceAllocation',false)
        
        #Engineering Focus Module
        elseif enh =='EngineeringFocusingModule' then
            if not Buffs['AeonSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'AeonSCUBuildRate',
                    DisplayName = 'AeonSCUBuildRate',
                    BuffType = 'SCUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCUBuildRate')
        elseif enh == 'EngineeringFocusingModuleRemove' then
            if Buff.HasBuff( self, 'AeonSCUBuildRate' ) then
                Buff.RemoveBuff( self, 'AeonSCUBuildRate' )
            end
            
        #SystemIntegrityCompensator
        elseif enh == 'SystemIntegrityCompensator' then
        	if not Buffs['AeonSCURegen'] then
                BuffBlueprint {
                    Name = 'AeonSCURegen',
                    DisplayName = 'AeonSCURegen',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCURegen')
        elseif enh == 'SystemIntegrityCompensatorRemove' then
            if Buff.HasBuff( self, 'AeonSCURegen' ) then
                Buff.RemoveBuff( self, 'AeonSCURegen' )
            end
        
        #StabilitySupressant
        elseif enh =='StabilitySuppressant' then
        	if not Buffs['AeonSCUStabilitySuppressant'] then
                BuffBlueprint {
                    Name = 'AeonSCUStabilitySuppressant',
                    DisplayName = 'AeonSCUStabilitySuppressant',
                    BuffType = 'AeonSCUStabilitySuppressant',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        DamageRadius = {
                            Add =  bp.NewDamageRadiusMod,
                            Mult = 1,
                            ByName = {
                            	RightReactonCannon = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'AeonSCUStabilitySuppressant')
        elseif enh =='StabilitySuppressantRemove' then
        	 if Buff.HasBuff( self, 'AeonSCUStabilitySuppressant' ) then
                Buff.RemoveBuff( self, 'AeonSCUStabilitySuppressant' )
            end
        else
        	oldUAL0301.CreateEnhancement(self, enh)
        end
    end,
    
}

TypeClass = UAL0301
