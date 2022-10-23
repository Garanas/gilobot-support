do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/defaultunits.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Default definitions of units
--#**
--#**              Original file had 1731 lines so if you get an error,
--#**              you can subtract 1731 from the line number they give 
--#**              you to find where the error was in the hook.
--#**
--#****************************************************************************

local MakeTimeBasedOutputMassCollectionUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/timebasedmasscollectionunit.lua').MakeTimeBasedOutputMassCollectionUnit
local MakeActiveAnimationUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/activeanimationunit.lua').MakeActiveAnimationUnit
local MakeUpgradeablePauseableProductionUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/upgradeablepauseableproductionunit.lua').MakeUpgradeablePauseableProductionUnit
local ModMassCollectionUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/masscollectionunit.lua').ModMassCollectionUnit

--# Apply visual effects improvements and other changes
MassCollectionUnit = 
    MakeTimeBasedOutputMassCollectionUnit(
        MakeActiveAnimationUnit(
            MakeUpgradeablePauseableProductionUnit(
                ModMassCollectionUnit(MassCollectionUnit)
            )
        )
    )

end --(of non-destructive hook)