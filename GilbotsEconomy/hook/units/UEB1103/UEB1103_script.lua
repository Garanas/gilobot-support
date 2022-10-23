--#****************************************************************************
--#*
--#*  Hook File:  /units/UEB1103/UEB1103_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  UEF T1 Mass Extractor Script
--#*              Hooked to remove unwanted code from class.
--#*  
--#****************************************************************************

local TMassCollectionUnit = import('/lua/terranunits.lua').TMassCollectionUnit

UEB1103 = Class(TMassCollectionUnit) {
}

TypeClass = UEB1103