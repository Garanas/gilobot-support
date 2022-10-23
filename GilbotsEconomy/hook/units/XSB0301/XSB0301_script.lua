--#****************************************************************************
--#**
--#**  Hook File:  /units/XSB0301/XSB0301_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Seraphim Land Factory Tier 3 Script
--#**
--#****************************************************************************

local Buff = import('/lua/sim/Buff.lua')

local BaseClass = XSB0301
XSB0301 = Class(BaseClass) {

    CreateEnhancement = function(self, enh)
        BaseClass.CreateEnhancement(self, enh)
        if enh =='AdvancedEngineering' then
            if not Buffs['SeraphimT3FactoryBuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimT3FactoryBuildRate',
                    DisplayName = 'SeraphimT3FactoryBuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimT3FactoryBuildRate')
        elseif enh =='AdvancedEngineering2' then
            if not Buffs['SeraphimT3FactoryBuildRate2'] then
                BuffBlueprint {
                    Name = 'SeraphimT3FactoryBuildRate2',
                    DisplayName = 'SeraphimT3FactoryBuildRate2',
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
            Buff.ApplyBuff(self, 'SeraphimT3FactoryBuildRate2')
        elseif enh =='AdvancedEngineeringRemove' then
            if Buff.HasBuff( self, 'SeraphimT3FactoryBuildRate' ) then
                Buff.RemoveBuff( self, 'SeraphimT3FactoryBuildRate' )
            end
        elseif enh =='AdvancedEngineering2Remove' then
            if Buff.HasBuff( self, 'SeraphimT3FactoryBuildRate2' ) then
                Buff.RemoveBuff( self, 'SeraphimT3FactoryBuildRate2' )
            end
        end
    end,
}

TypeClass = XSB0301