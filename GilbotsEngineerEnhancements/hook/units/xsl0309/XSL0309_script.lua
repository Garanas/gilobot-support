--#****************************************************************************
--#**
--#**  Hook File:  /units/XSL0309/XSL0309_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Seraphim Engineer Tier 3 Script
--#**
--#****************************************************************************

local Buff = import('/lua/sim/Buff.lua')

PreviousVersion = XSL0309
XSL0309 = Class(PreviousVersion) {

   
    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        if enh =='AdvancedEngineering' then
            if not Buffs['SeraphimT3EngineerBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimT3EngineerBuildRate',
                    DisplayName = 'SeraphimT3EngineerBuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimT3EngineerBuildRate')
        elseif enh =='AdvancedEngineering2' then
            if not Buffs['SeraphimT3EngineerBuildRate2'] then
                BuffBlueprint {
                    Name = 'SeraphimT3EngineerBuildRate2',
                    DisplayName = 'SeraphimT3EngineerBuildRate2',
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
            Buff.ApplyBuff(self, 'SeraphimT3EngineerBuildRate2')
        elseif enh =='AdvancedEngineeringRemove' then
            if Buff.HasBuff( self, 'SeraphimT3EngineerBuildRate' ) then
                Buff.RemoveBuff( self, 'SeraphimT3EngineerBuildRate' )
            end
        elseif enh =='AdvancedEngineering2Remove' then
            if Buff.HasBuff( self, 'SeraphimT3EngineerBuildRate2' ) then
                Buff.RemoveBuff( self, 'SeraphimT3EngineerBuildRate2' )
            end
        end
    end,
}

TypeClass = XSL0309