do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/seraphimunits.lua
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Unit class generic overrides for Seraphim faction
--#**
--#**  Note: 707 lines in original file so if you get an error 
--#**  subtract 707 from the line number it gives you to find 
--#**  where it is in this hook file.
--#**  
--#****************************************************************************

local MakeAdjacencyStructureUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencystructureunit.lua').MakeAdjacencyStructureUnit

--#* 
--#*  Gilbot-X says:
--#*
--#*  All Seraphim defense-weapon structures (such as artillery) extend 
--#*  This class directly from their script files.
--#*
--#** 
SStructureUnit = MakeAdjacencyStructureUnit(SStructureUnit)


end --(of non-destructive hook)