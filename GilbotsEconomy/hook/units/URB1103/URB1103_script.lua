--#****************************************************************************
--#*
--#*  Hook File:  /units/URB1103/URB1103_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  Cybran T1 Mass Extractor Script
--#*              Hooked to remove unwanted code from class.
--#*  
--#****************************************************************************

local CMassCollectionUnit = import('/lua/cybranunits.lua').CMassCollectionUnit

URB1103 = Class(CMassCollectionUnit) {}

TypeClass = URB1103