do--(start of non-destructive hook)
--#****************************************************************************
--#**  Summary  :  Seraphim Sub Commander Script
--#****************************************************************************

local oldXSL0301 = XSL0301
XSL0301 = Class(oldXSL0301) {
    
    OnStartBuild = function(self, unitBeingBuilt, order)
        --# FA version didn't call its own base class
        --# So we'll call it for them.
		SWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        oldXSL0301.OnStartBuild(self, unitBeingBuilt, order)
    end,   
    
    CreateEnhancement = function(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        --#Engineering Throughput Upgrade
        if enh =='EngineeringThroughput' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            if not Buffs['SeraphimSCUBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimSCUBuildRate',
                    DisplayName = 'SeraphimSCUBuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimSCUBuildRate')
        
        --#Enhanced Sensor Systems
        elseif enh == 'EnhancedSensors' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
        	if not Buffs['SeraSCUEnhancedSensors'] then
                BuffBlueprint {
                    Name = 'SeraSCUEnhancedSensors',
                    DisplayName = 'SeraSCUEnhancedSensors',
                    BuffType = 'SeraSCUEnhancedSensors',
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
            Buff.ApplyBuff(self, 'SeraSCUEnhancedSensors')
        elseif enh == 'EnhancedSensorsRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            Buff.RemoveBuff(self,'SeraSCUEnhancedSensors',false)
        else
        	oldXSL0301.CreateEnhancement(self, enh)
        end
    end,
     
}

TypeClass = XSL0301
end--(of non-destructive hook)