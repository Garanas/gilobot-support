--#****************************************************************************
--#*
--#*  Hook File:  /units/UEB1202/UEB1202_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  UEF T2 Mass Extractor Script
--#*              Hooked to remove unwanted code from class.
--#*  
--#****************************************************************************

local TMassCollectionUnit = import('/lua/terranunits.lua').TMassCollectionUnit

UEB1202 = Class(TMassCollectionUnit) {
}

TypeClass = UEB1202