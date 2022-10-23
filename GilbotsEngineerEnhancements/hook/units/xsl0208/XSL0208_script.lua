--#****************************************************************************
--#**
--#**  Hook File:  /units/XSL0208/XSL0208_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Seraphim Engineer Tier 2 Script
--#**
--#****************************************************************************

local Buff = import('/lua/sim/Buff.lua')

PreviousVersion = XSL0208
XSL0208 = Class(PreviousVersion) {

   
    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        if enh =='AdvancedEngineering' then
            if not Buffs['SeraphimT2EngineerBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimT2EngineerBuildRate',
                    DisplayName = 'SeraphimT2EngineerBuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimT2EngineerBuildRate')
        elseif enh =='AdvancedEngineering2' then
            if not Buffs['SeraphimT2EngineerBuildRate2'] then
                BuffBlueprint {
                    Name = 'SeraphimT2EngineerBuildRate2',
                    DisplayName = 'SeraphimT2EngineerBuildRate2',
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
            Buff.ApplyBuff(self, 'SeraphimT2EngineerBuildRate2')
        elseif enh =='AdvancedEngineeringRemove' then
            if Buff.HasBuff( self, 'SeraphimT2EngineerBuildRate' ) then
                Buff.RemoveBuff( self, 'SeraphimT2EngineerBuildRate' )
            end
        elseif enh =='AdvancedEngineering2Remove' then
            if Buff.HasBuff( self, 'SeraphimT2EngineerBuildRate2' ) then
                Buff.RemoveBuff( self, 'SeraphimT2EngineerBuildRate2' )
            end
        end
    end,
}

TypeClass = XSL0208