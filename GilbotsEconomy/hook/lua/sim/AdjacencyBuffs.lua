--#****************************************************************************
--#*
--#*  Hook File :  /lua/sim/AdjacencyBuffs.lua
--#*
--#*  Modded By : Gilbot-X
--#*
--#*  Summary   : Allow Aeon Mex and HCPP to get Shield strength
--#*              bonuses on their sensitive shields from the T4
--#*              shield strength enhancer. 
--#*
--#****************************************************************************



--##################################################################
--## TIER 4 Aeon Shield Strength Enhancer BUFF TABLE
--## Gilbot-X says:  I added this for my new unit.
--##################################################################

table.insert(T4ShieldStrengthAdjacencyBuffs, 'T4ShieldStrengthBonusForAeonMassExtractor')
BuffBlueprint {
    Name = 'T4ShieldStrengthBonusForAeonMassExtractor',
    DisplayName = 'T4ShieldStrengthBonusForAeonMassExtractor',
    BuffType = 'SHIELDSTRENGTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'MASSEXTRACTION AEON',
    BuffCheckFunction = AdjBuffFuncs.ShieldStrengthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldStrengthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldStrengthBuffRemove,
    Affects = {
        ShieldStrength = {
            Add = 0.1,
            AddMin = 0.1,
            AddMax = 1.0,
            Mult = 1,
        },
    },
}


table.insert(T4ShieldStrengthAdjacencyBuffs, 'T4ShieldStrengthBonusForAeonHCPP')
BuffBlueprint {
    Name = 'T4ShieldStrengthBonusForAeonHCPP',
    DisplayName = 'T4ShieldStrengthBonusForAeonHCPP',
    BuffType = 'SHIELDSTRENGTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'HYDROCARBON AEON',
    BuffCheckFunction = AdjBuffFuncs.ShieldStrengthBuffCheck,
    OnBuffAffect = AdjBuffFuncs.ShieldStrengthBuffAffect,
    OnBuffRemove = AdjBuffFuncs.ShieldStrengthBuffRemove,
    Affects = {
        ShieldStrength = {
            Add = 0.1,
            AddMin = 0.1,
            AddMax = 1.0,
            Mult = 1,
        },
    },
}