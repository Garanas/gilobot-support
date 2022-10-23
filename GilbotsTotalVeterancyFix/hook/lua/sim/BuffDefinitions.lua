--#****************************************************************************
--#**
--#**  Hook File :  /lua/sim/buffdefinition.lua
--#**
--#**  Modded By : Eni
--#**
--#**  Summary   : Extra Veterancy definitions added to the game.
--#**       
--#**
--#****************************************************************************


--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - HEALTH AND REGEN
--##################################################################

BuffBlueprint {
    Name = 'VeterancyHealth',
    DisplayName = 'VeterancyHealth',
    BuffType = 'VETERANCYHEALTH',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxHealth = {
            Add = 0,
            Mult = 1.1,
        },
    },
}

BuffBlueprint {
    Name = 'VeterancyRegen',
    DisplayName = 'VeterancyRegen',
    BuffType = 'VETERANCYREGEN',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Regen = {
            Add = 0,
            Mult = 1.1,
        },
    },
}

--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - WEAPONS
--##################################################################

BuffBlueprint {
    Name = 'VeterancyDamage',
    DisplayName = 'VeterancyDamage',
    BuffType = 'VETERANCYDAMAGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Damage = {
            Add = 0,
            Mult = 1.05,
        },
    },
}


BuffBlueprint {
	MaxLevel = 20,
    Name = 'VeterancyDamageArea',
    DisplayName = 'VeterancyDamageArea',
    BuffType = 'VETERANCYDAMAGEAREA',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        DamageRadius = {
            Add = 0,
            Mult = 1.05,
        },
    },
}


BuffBlueprint {
	MaxLevel = 40,
    Name = 'VeterancyRange',
    DisplayName = 'VeterancyRange',
    BuffType = 'VETERANCYRANGE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MaxRadius = {
            Add = 0,
            Mult = 1.025,
        },
    },
}

--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - MOVEMENT
--##################################################################

BuffBlueprint {
	MaxLevel = 20,
    Name = 'VeterancySpeed',
    DisplayName = 'VeterancySpeed',
    BuffType = 'VETERANCYSPEED',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        MoveMult = {
            Add = 0,
            Mult = 1.025,
        },
    },
}

BuffBlueprint {
    Name = 'VeterancyFuel',
    DisplayName = 'VeterancyFuel',
    BuffType = 'VETERANCYFUEL',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        Fuel = {
            Add = 0,
            Mult = 1.05,
        },
    },
}


--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - SHIELDS
--##################################################################

BuffBlueprint {
    Name = 'VeterancyShield',
    DisplayName = 'VeterancyShield',
    BuffType = 'VETERANCYSHIELD',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        ShieldHP = {
            Add = 0,
            Mult = 1.1,
        },
        ShieldRegen = {
            Add = 0,
            Mult = 1.1,
        },
    },
}



--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - INTEL
--##################################################################

BuffBlueprint {
	MaxLevel = 40,
    Name = 'VeterancyVision',
    DisplayName = 'VeterancyVision',
    BuffType = 'VETERANCYVISION',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        VisionRadius = {
            Add = 0,
            Mult = 1.025,
        },
    },
}

BuffBlueprint {
	MaxLevel = 40,
    Name = 'VeterancyOmniRadius',
    DisplayName = 'VeterancyOmniRadius',
    BuffType = 'VETERANCYOMNIRADIUS',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        OmniRadius = {
            Add = 0,
            Mult = 1.025,
        },
    },
}

BuffBlueprint {
	MaxLevel = 40,
    Name = 'VeterancyRadar',
    DisplayName = 'VeterancyRadar',
    BuffType = 'VETERANCYRADAR',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RadarRadius = {
            Add = 0,
            Mult = 1.025,
        },
    },
}


--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - BUILD
--##################################################################

BuffBlueprint {
    Name = 'VeterancyBuildRate',
    DisplayName = 'VeterancyBuildRate',
    BuffType = 'VETERANCYBUILDRATE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        BuildRate = {
            Add = 0,
            Mult = 1.1,
        },
    },
}


--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - ECONOMY
--##################################################################

BuffBlueprint {
    Name = 'VeterancyResourceProduction',
    DisplayName = 'VeterancyResourceProduction',
    BuffType = 'VeterancyResourceProduction',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
    	EnergyProductionBuf = {
			Add = 0,
            Mult = 1.1,
        },
        MassProductionBuf = {
            Add = 0,
            Mult = 1.1,
        },
	},
}

COMMANDVETERANCYPRODUCTION = {
    MaxLevel = 5,
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        EnergyProductionBuf = {
            Add = 200,
            Mult = 1,
        },
        MassProductionBuf = {
            Add = 2,
            Mult = 1,
        },
    },
},



--##################################################################
--## NEW VETERANCY BUFFS FROM TOTAL VETERANCY - ROF FROM ADJACENCY
--##################################################################

BuffBlueprint {
    Name = 'VeterancyRateOfFire',
    DisplayName = 'VeterancyRateOfFire',
    BuffType = 'VETERANCYRATEOFFIRE',
    Stacks = 'ALWAYS',
    Duration = -1,
    Affects = {
        RateOfFireBuf = {
            Add = 0,
            Mult = 1.05,
        },
    },
}




--# This was in original file.
--# I have no idea what it does.
__moduleinfo.auto_reload = true
