--#****************************************************************************
--#**
--#**  Hook File:  /mods/GilbotsModPackCore/lua/intelfieldbounds.lua
--#**  
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Common code for my units that generate intel fields.
--#**              Despite what you would logically assume, intel fields
--#**              are not circular in the Moho engine, although that is 
--#**              how they are presented in the blueprints and lua scripts.
--#**              Instead, the fields are a pattern of square 2x2 OGrids 
--#**              and these patterns loosely approximate a circle so the 
--#**              player cannot really spot the difference.  These patterns
--#**              can be approximated as a series of overlapping rectangular
--#**              regions.  The bounds for those rectangles are provided
--#**              in this file. 
--#**
--#****************************************************************************


IntelFieldBoundsForRadius = {
    --# Bounds for intel radius 4 to 7
    From4To7 = {
        SearchRectangleBounds= {
            XOffsetWest = 0,
            XOffsetEast = 4,
            ZOffsetNorth = 4,
            ZOffsetSouth = 4,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 4,
                ZOffsetSouth = 4,
            }, 
        },
    },
    --# Bounds for intel radius 8 to 11
    From8To11 = {
        SearchRectangleBounds= {
            XOffsetWest = 4,
            XOffsetEast = 8,
            ZOffsetNorth = 8,
            ZOffsetSouth = 8,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 4,
                XOffsetEast = 8,
                ZOffsetNorth = 4,
                ZOffsetSouth = 4,
            },
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 8,
                ZOffsetSouth = 8,
            },
        },
    },
    --# Bounds for intel radius 12 to 15
    From12To15 = {
        SearchRectangleBounds= {
            XOffsetWest = 8,
            XOffsetEast = 12,
            ZOffsetNorth = 12,
            ZOffsetSouth = 12,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 4,
                XOffsetEast = 8,
                ZOffsetNorth = 4,
                ZOffsetSouth = 4,
            },
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 8,
                ZOffsetSouth = 8,
            },
        },
    },
    --# Bounds for intel radius 16 to 19
    From16To19 = {
        SearchRectangleBounds= {
            XOffsetWest = 12,
            XOffsetEast = 16,
            ZOffsetNorth = 16,
            ZOffsetSouth = 16,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 12,
                XOffsetEast = 16,
                ZOffsetNorth = 8,
                ZOffsetSouth = 8,
            },
            {
                XOffsetWest = 8,
                XOffsetEast = 12,
                ZOffsetNorth = 12,
                ZOffsetSouth = 12,
            },
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 16,
                ZOffsetSouth = 16,
            },
        },
    },
    --# Bounds for intel radius 20 to 23
    From20To23 = {
        SearchRectangleBounds= {
            XOffsetWest = 16,
            XOffsetEast = 20,
            ZOffsetNorth = 20,
            ZOffsetSouth = 20,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 16,
                XOffsetEast = 20,
                ZOffsetNorth = 12,
                ZOffsetSouth = 12,
            },
            {
                XOffsetWest = 12,
                XOffsetEast = 16,
                ZOffsetNorth = 16,
                ZOffsetSouth = 16,
            },
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 20,
                ZOffsetSouth = 20,
            },
        },
    },
     --# Bounds for intel radius 24 to 27
    From24To27 = {
        SearchRectangleBounds= {
            XOffsetWest = 20,
            XOffsetEast = 24,
            ZOffsetNorth = 24,
            ZOffsetSouth = 24,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 20,
                XOffsetEast = 24,
                ZOffsetNorth = 12,
                ZOffsetSouth = 12,
            },
            {
                XOffsetWest = 16,
                XOffsetEast = 20,
                ZOffsetNorth = 16,
                ZOffsetSouth = 16,
            },
            {
                XOffsetWest = 12,
                XOffsetEast = 16,
                ZOffsetNorth = 20,
                ZOffsetSouth = 20,
            },
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 24,
                ZOffsetSouth = 24,
            },
        },
    },
    --# Bounds for intel radius 28 to 31
    From28To31 = {
        SearchRectangleBounds= {
            XOffsetWest = 24,
            XOffsetEast = 28,
            ZOffsetNorth = 28,
            ZOffsetSouth = 28,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 24,
                XOffsetEast = 28,
                ZOffsetNorth = 12,
                ZOffsetSouth = 12,
            },
            {
                XOffsetWest = 20,
                XOffsetEast = 24,
                ZOffsetNorth = 16,
                ZOffsetSouth = 16,
            },
            {
                XOffsetWest = 16,
                XOffsetEast = 20,
                ZOffsetNorth = 20,
                ZOffsetSouth = 20,
            },
            {
                XOffsetWest = 12,
                XOffsetEast = 16,
                ZOffsetNorth = 24,
                ZOffsetSouth = 24,
            },
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 28,
                ZOffsetSouth = 28,
            },
        },
    },
     --# Bounds for intel radius 32 to 35
    From32To35 = {
        SearchRectangleBounds= {
            XOffsetWest = 28,
            XOffsetEast = 32,
            ZOffsetNorth = 32,
            ZOffsetSouth = 32,
        },
        SourceAreaBounds = {
            XStart=0,
            ZStart=0,
            XLength = 4,
            ZLength = 4,
        },
        EffectAreaBounds = { 
            {
                XOffsetWest = 28,
                XOffsetEast = 32,
                ZOffsetNorth = 12,
                ZOffsetSouth = 12,
            },
            {
                XOffsetWest = 24,
                XOffsetEast = 28,
                ZOffsetNorth = 20,
                ZOffsetSouth = 20,
            },
            {
                XOffsetWest = 20,
                XOffsetEast = 24,
                ZOffsetNorth = 24,
                ZOffsetSouth = 24,
            },
            {
                XOffsetWest = 12,
                XOffsetEast = 16,
                ZOffsetNorth = 28,
                ZOffsetSouth = 28,
            },
            {
                XOffsetWest = 0,
                XOffsetEast = 4,
                ZOffsetNorth = 32,
                ZOffsetSouth = 32,
            },
        },
    },
}