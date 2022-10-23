--#****************************************************************************
--#**
--#**  Hook File:  /units/XSL0105/XSL0105_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Seraphim Engineer Tier 1 Script
--#**
--#****************************************************************************

local Buff = import('/lua/sim/Buff.lua')

PreviousVersion = XSL0105
XSL0105 = Class(PreviousVersion) {

   
    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        if enh =='AdvancedEngineering' then
            if not Buffs['SeraphimT1EngineerBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimT1EngineerBuildRate',
                    DisplayName = 'SeraphimT1EngineerBuildRate',
                    BuffType = 'BUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  0,
                            Mult = 2,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraphimT1EngineerBuildRate')
        elseif enh =='AdvancedEngineering2' then
            if not Buffs['SeraphimT1EngineerBuildRate2'] then
                BuffBlueprint {
                    Name = 'SeraphimT1EngineerBuildRate2',
                    DisplayName = 'SeraphimT1EngineerBuildRate2',
                    BuffType = 'BUILDRATE',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  0,
                            Mult = 4,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraphimT1EngineerBuildRate2')
        elseif enh =='AdvancedEngineeringRemove' then
            if Buff.HasBuff( self, 'SeraphimT1EngineerBuildRate' ) then
                Buff.RemoveBuff( self, 'SeraphimT1EngineerBuildRate' )
            end
        elseif enh =='AdvancedEngineering2Remove' then
            if Buff.HasBuff( self, 'SeraphimT1EngineerBuildRate2' ) then
                Buff.RemoveBuff( self, 'SeraphimT1EngineerBuildRate2' )
            end
        end
    end,
}

TypeClass = XSL0105