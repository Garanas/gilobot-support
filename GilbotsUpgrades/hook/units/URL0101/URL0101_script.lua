--#****************************************************************************
--#**
--#**  Hook File:  /units/URL0101/URL0101_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  Cybran Scout Script
--#**
--#****************************************************************************

local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
URL0101 = MakeCustomUpgradeMobileUnit(URL0101, 'URL0101', 0.3)
TypeClass = URL0101

