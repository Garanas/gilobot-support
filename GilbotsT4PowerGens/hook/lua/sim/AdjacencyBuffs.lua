--#****************************************************************************
--#*
--#*  Hook File :  /lua/sim/AdjacencyBuffs.lua
--#*
--#*  Modded By : Gilbot-X
--#*
--#****************************************************************************



--##################################################################
--## TIER 4 POWER GEN BUFF TABLE
--##################################################################

T4PowerGeneratorAdjacencyBuffs = {
    'T4PowerEnergyBuildBonusSize4',
    'T4PowerEnergyBuildBonusSize8',
    'T4PowerEnergyBuildBonusSize12',
    'T4PowerEnergyBuildBonusSize16',
    'T4PowerEnergyBuildBonusSize20',
    'T4PowerEnergyWeaponBonusSize4',
    'T4PowerEnergyWeaponBonusSize8',
    'T4PowerEnergyWeaponBonusSize12',
    'T4PowerEnergyWeaponBonusSize16',
    'T4PowerEnergyWeaponBonusSize20',
    'T4PowerEnergyMaintenanceBonusSize4',
    'T4PowerEnergyMaintenanceBonusSize8',
    'T4PowerEnergyMaintenanceBonusSize12',
    'T4PowerEnergyMaintenanceBonusSize16',
    'T4PowerEnergyMaintenanceBonusSize20',
    'T4PowerRateOfFireBonusSize4',
}


--##################################################################
--## ENERGY BUILD BONUS - TIER 4 POWER GENS
--## Gilbot-X:  Triple the bonus of T3
--##################################################################

BuffBlueprint {
    Name = 'T4PowerEnergyBuildBonusSize4',
    DisplayName = 'T4PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyBuildBonusSize8',
    DisplayName = 'T4PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyBuildBonusSize12',
    DisplayName = 'T4PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyBuildBonusSize16',
    DisplayName = 'T4PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyBuildBonusSize20',
    DisplayName = 'T4PowerEnergyBuildBonus',
    BuffType = 'ENERGYBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyBuildBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyBuildBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyBuildBuffRemove,
    Affects = {
        EnergyActive = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

--##################################################################
--## ENERGY MAINTENANCE BONUS - TIER 4 POWER GENS
--## Gilbot-X:  Triple the bonus of T3
--##################################################################

BuffBlueprint {
    Name = 'T4PowerEnergyMaintenanceBonusSize4',
    DisplayName = 'T4PowerEnergyMaintenanceBonus',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyMaintenanceBonusSize8',
    DisplayName = 'T4PowerEnergyMaintenanceBonus',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyMaintenanceBonusSize12',
    DisplayName = 'T4PowerEnergyMaintenanceBonus',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyMaintenanceBonusSize16',
    DisplayName = 'T4PowerEnergyMaintenanceBonus',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyMaintenanceBonusSize20',
    DisplayName = 'T4PowerEnergyMaintenanceBonus',
    BuffType = 'ENERGYMAINTENANCEBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyMaintenanceBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyMaintenanceBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyMaintenanceBuffRemove,
    Affects = {
        EnergyMaintenance = {
            Add = -0.1875*3,
            Mult = 1.0,
        },
    },
}



--##################################################################
--## ENERGY WEAPON BONUS - TIER 4 POWER GENS
--## Gilbot-X:  Triple the bonus of T3
--##################################################################

BuffBlueprint {
    Name = 'T4PowerEnergyWeaponBonusSize4',
    DisplayName = 'T4PowerEnergyWeaponBonus',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyWeaponBonusSize8',
    DisplayName = 'T4PowerEnergyWeaponBonus',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyWeaponBonusSize12',
    DisplayName = 'T4PowerEnergyWeaponBonus',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyWeaponBonusSize16',
    DisplayName = 'T4PowerEnergyWeaponBonus',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerEnergyWeaponBonusSize20',
    DisplayName = 'T4PowerEnergyWeaponBonus',
    BuffType = 'ENERGYWEAPONBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyWeaponBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyWeaponBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyWeaponBuffRemove,
    Affects = {
        EnergyWeapon = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

--##################################################################
--## RATE OF FIRE WEAPON BONUS - TIER 4 POWER GENS
--## Gilbot-X:  Triple the rate of fire bonus of T3
--##################################################################

BuffBlueprint {
    Name = 'T4PowerRateOfFireBonusSize4',
    DisplayName = 'T4PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE4 ARTILLERY',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerRateOfFireBonusSize8',
    DisplayName = 'T4PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE8',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerRateOfFireBonusSize12',
    DisplayName = 'T4PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE12',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerRateOfFireBonusSize16',
    DisplayName = 'T4PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE16',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}

BuffBlueprint {
    Name = 'T4PowerRateOfFireBonusSize20',
    DisplayName = 'T4PowerRateOfFireBonus',
    BuffType = 'RATEOFFIREADJACENCY',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.RateOfFireBuffCheck,
    OnBuffAffect = AdjBuffFuncs.RateOfFireBuffAffect,
    OnBuffRemove = AdjBuffFuncs.RateOfFireBuffRemove,
    Affects = {
        RateOfFire = {
            Add = -0.075*3,
            Mult = 1.0,
        },
    },
}






--##################################################################
--## TIER 1 ENERGY STORAGE
--##################################################################
T1EnergyStorageAdjacencyBuffs = {
    'T1EnergyStorageEnergyProductionBonusSize4',
    'T1EnergyStorageEnergyProductionBonusSize8',
    'T1EnergyStorageEnergyProductionBonusSize12',
    'T1EnergyStorageEnergyProductionBonusSize16',
    'T1EnergyStorageEnergyProductionBonusSize20v2',
}

--##################################################################
--## ENERGY PRODUCTION BONUS - TIER 1 ENERGY STORAGE
--##################################################################

BuffBlueprint {
    Name = 'T1EnergyStorageEnergyProductionBonusSize20v2',
    DisplayName = 'T1EnergyStorageEnergyProductionBonus',
    BuffType = 'MASSBUILDBONUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    EntityCategory = 'STRUCTURE SIZE20',
    BuffCheckFunction = AdjBuffFuncs.EnergyProductionBuffCheck,
    OnBuffAffect = AdjBuffFuncs.EnergyProductionBuffAffect,
    OnBuffRemove = AdjBuffFuncs.EnergyProductionBuffRemove,
    Affects = {
        EnergyProduction = {
            --Add = 0.025,  --# Reduce to 1%
            Add = 0.01,
            Mult = 1.0,
        },
    },
}