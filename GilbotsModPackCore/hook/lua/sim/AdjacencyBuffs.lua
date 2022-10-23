--#****************************************************************************
--#*
--#*  Hook File :  /lua/sim/AdjacencyBuffs.lua
--#*
--#*  Modded By : Gilbot-X
--#*
--#****************************************************************************



--##################################################################
--## TIER 4 POWER GEN BUFF TABLE
--## Gilbot-X says:  I added this for my new unit.
--##################################################################

T4ShieldStrengthAdjacencyBuffs = {
    'T4ShieldStrengthBonus',
}

--##################################################################
--## SHIELD STRENGTH BONUS - TIER 4 SHIELD STRENGTHENER
--## Gilbot-X says:  I added this for my new unit.
--##################################################################

BuffBlueprint {
    Name = 'T4ShieldStrengthBonus',
    DisplayName = 'T4ShieldStrengthBonus',
    BuffType = 'SHIELDSTRENGTHBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE',
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


--##################################################################
--## TIER 1 POWER GEN BUFF TABLE
--## Gilbot-X says:  
--## Added ROF bonuses Added for PD, AA and ANTINAVY
--## Added EnergyBuildBonus for Engineering Stations
--##################################################################
--#
--# Already defined in FA but weren't enabled before:
--# Nukes are the only SIZE12
--table.insert(T1PowerGeneratorAdjacencyBuffs, 'T1PowerRateOfFireBonusSize12')
--# T3 Artillery are the only SIZE16
--table.insert(T1PowerGeneratorAdjacencyBuffs, 'T1PowerRateOfFireBonusSize16')

--# I added the next one as in FA, 
--# EngineerStations never got this bonus
table.insert(T1PowerGeneratorAdjacencyBuffs, 'T1PowerEnergyBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T1PowerEnergyBuildBonusEngineerStation',
    DisplayName = 'T1PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.0625,
            Mult = 1.0,
        },
    },
}

--# All Anti Air
table.insert(T1PowerGeneratorAdjacencyBuffs, 'T1PowerRateOfFireBonusSize4AA')
BuffBlueprint {
    Name = 'T1PowerRateOfFireBonusSize4AA',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTIAIR',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

--# All Point Defenses
table.insert(T1PowerGeneratorAdjacencyBuffs, 'T1PowerRateOfFireBonusSize4PD')
BuffBlueprint {
    Name = 'T1PowerRateOfFireBonusSize4PD',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'DIRECTFIRE',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}

--# All torpedo Launchers
table.insert(T1PowerGeneratorAdjacencyBuffs, 'T1PowerRateOfFireBonusSize4AN')
BuffBlueprint {
    Name = 'T1PowerRateOfFireBonusSize4AN',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTINAVY',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}





--##################################################################
--## TIER 2 POWER GEN BUFF TABLE
--## Gilbot-X says:  
--## Added ROF bonuses Added for PD, AA and ANTINAVY
--## Added EnergyBuildBonus for Engineering Stations
--##################################################################
--#
--# Already defined in FA but weren't enabled before:
--# Nukes are the only SIZE12
table.insert(T2PowerGeneratorAdjacencyBuffs, 'T2PowerRateOfFireBonusSize12')
--# T3 Artillery are the only SIZE16
table.insert(T2PowerGeneratorAdjacencyBuffs, 'T2PowerRateOfFireBonusSize16')
--# I added the next one as in FA, 
--# EngineerStations never got this bonus
table.insert(T2PowerGeneratorAdjacencyBuffs, 'T2PowerEnergyBuildBonusEngineerStation')
--# All Anti Air
table.insert(T2PowerGeneratorAdjacencyBuffs, 'T2PowerRateOfFireBonusSize4AA')
--# All Point Defenses
table.insert(T2PowerGeneratorAdjacencyBuffs, 'T2PowerRateOfFireBonusSize4PD')
--# All Torpedo launchers
table.insert(T2PowerGeneratorAdjacencyBuffs, 'T2PowerRateOfFireBonusSize4AN')

--###################################################################
--##  HCPP Gives same buffs as T2 Powergen
--###################################################################
--#
--# Gilbot-X: 
--# Already defined in FA but weren't enabled before:
--# Nukes are the only SIZE12
table.insert(HydrocarbonAdjacencyBuffs, 'T2PowerRateOfFireBonusSize12')
--# T3 Artillery are the only SIZE16
table.insert(HydrocarbonAdjacencyBuffs, 'T2PowerRateOfFireBonusSize16')

--# I added the next one as in FA, 
--# EngineerStations never got this bonus
table.insert(HydrocarbonAdjacencyBuffs, 'T2PowerEnergyBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T2PowerEnergyBuildBonusEngineerStation',
    DisplayName = 'T2PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.125,
            Mult = 1.0,
        },
    },
}

--# All Anti Air
table.insert(HydrocarbonAdjacencyBuffs, 'T2PowerRateOfFireBonusSize4AA')
--# All Point Defenses
table.insert(HydrocarbonAdjacencyBuffs, 'T2PowerRateOfFireBonusSize4PD')
--# All Torpedo launchers
--table.insert(HydrocarbonAdjacencyBuffs, 'T2PowerRateOfFireBonusSize4AN')

--# T1, T2 and T3 AA
BuffBlueprint {
    Name = 'T2PowerRateOfFireBonusSize4AA',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTIAIR',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

--# T1, T2 and T3 PD
BuffBlueprint {
    Name = 'T2PowerRateOfFireBonusSize4PD',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'DIRECTFIRE',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}

--# T1, T2 and T3 TORPEDO LAUNCHERS
BuffBlueprint {
    Name = 'T2PowerRateOfFireBonusSize4AN',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTINAVY',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.05,
            Mult = 1.0,
        },
    },
}



--##################################################################
--## TIER 3 POWER GEN BUFF TABLE
--## Gilbot-X says:  
--## Added ROF bonuses Added for PD, AA and ANTINAVY
--## Added EnergyBuildBonus for Engineering Stations
--##################################################################
--#
--# Gilbot-X: 
--# Already defined in FA but weren't enabled before:
--# Nukes are the only SIZE12
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize12')
--# T3 Artillery are the only SIZE16
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize16')

--# I added the next one as in FA, 
--# EngineerStations never got this bonus
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerEnergyBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T3PowerEnergyBuildBonusEngineerStation',
    DisplayName = 'T3PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875,
            Mult = 1.0,
        },
    },
}

--# T1 Anti Air
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize4AA1')
--# T1 Point Defenses
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize4PD1')
--# T2 Anti Air
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize4AA2')
--# T2 Point Defenses
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize4PD2')
--# T3 Anti Air
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize4AA3')
--# T3 Point Defenses
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize4PD3')
--# All Torpedo launchers
table.insert(T3PowerGeneratorAdjacencyBuffs, 'T3PowerRateOfFireBonusSize4AN')

--# T1 AA
BuffBlueprint {
    Name = 'T3PowerRateOfFireBonusSize4AA1',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTIAIR',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.5,
            Mult = 1.0,
        },
    },
}

--# T2 AA
BuffBlueprint {
    Name = 'T3PowerRateOfFireBonusSize4AA2',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTIAIR',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.2,
            Mult = 1.0,
        },
    },
}

--# T3 AA
BuffBlueprint {
    Name = 'T3PowerRateOfFireBonusSize4AA3',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTIAIR',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}

--# T1 PD
BuffBlueprint {
    Name = 'T3PowerRateOfFireBonusSize4PD1',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'DIRECTFIRE TECH1',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.5,
            Mult = 1.0,
        },
    },
}

--# T2 PD
BuffBlueprint {
    Name = 'T3PowerRateOfFireBonusSize4PD2',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'DIRECTFIRE TECH2',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.2,
            Mult = 1.0,
        },
    },
}

--# T3 PD
BuffBlueprint {
    Name = 'T3PowerRateOfFireBonusSize4PD3',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'DIRECTFIRE TECH3',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}

--# T1, T2 and T3 TORPEDO LAUNCHERS
BuffBlueprint {
    Name = 'T3PowerRateOfFireBonusSize4AN',
    DisplayName = 'T1PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ANTINAVY',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}



--##################################################################
--## MASS EXTRACTOR BUFF TABLES
--## Gilbot-X says:  
--## Added MassBuildBonus for Engineering Stations
--##################################################################

table.insert(T1MassExtractorAdjacencyBuffs, 'T1MEXMassBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T1MEXMassBuildBonusEngineerStation',
    DisplayName = 'T1MEXMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.1,
            Mult = 1.0,
        },
    },
}

table.insert(T2MassExtractorAdjacencyBuffs, 'T2MEXMassBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T2MEXMassBuildBonusEngineerStation',
    DisplayName = 'T2MEXMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.15,
            Mult = 1.0,
        },
    },
}

table.insert(T3MassExtractorAdjacencyBuffs, 'T3MEXMassBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T3MEXMassBuildBonusEngineerStation',
    DisplayName = 'T3MEXMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.2,
            Mult = 1.0,
        },
    },
}


--##################################################################
--## MASS FABRICATOR BUFF TABLES
--## Gilbot-X says:  
--## Added MassBuildBonus for Engineering Stations
--##################################################################
table.insert(T1MassFabricatorAdjacencyBuffs, 'T1FabricatorMassBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T1FabricatorMassBuildBonusEngineerStation',
    DisplayName = 'T1FabricatorMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.025,
            Mult = 1.0,
        },
    },
}
table.insert(T3MassFabricatorAdjacencyBuffs, 'T3FabricatorMassBuildBonusEngineerStation')
BuffBlueprint {
    Name = 'T3FabricatorMassBuildBonusEngineerStation',
    DisplayName = 'T3FabricatorMassBuildBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'ENGINEERSTATION',
    BuffCheckFunction = AdjBuffFuncs.MassBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.MassBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.MassBuildBuffRemove,
    Affects = {
        MassActive = {
            Add = -0.075,
            Mult = 1.0,
        },
    },
}