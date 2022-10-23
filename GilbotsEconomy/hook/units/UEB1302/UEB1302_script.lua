--#****************************************************************************
--#*
--#*  Hook File:  /units/UEB1302/UEB1302_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  UEF T3 Mass Extractor Script
--#*              Hooked to remove unwanted code from class.
--#*  
--#****************************************************************************

local TMassCollectionUnit = import('/lua/terranunits.lua').TMassCollectionUnit

UEB1302 = Class(TMassCollectionUnit) {
}

TypeClass = UEB1302