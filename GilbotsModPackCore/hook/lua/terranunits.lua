do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/terrannunits.lua
--#**  Modded By :  Gilbot-X
--#**
--#**  Summary   :  Unit class generic overrides for UEF faction
--#**
--#**  Note: 397 lines in original file so if you get an error 
--#**  subtract 397 from the line number it gives you to find 
--#**  where it is in this hook file
--#**  
--#****************************************************************************

local MakeAdjacencyStructureUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencystructureunit.lua').MakeAdjacencyStructureUnit

--#* 
--#*  Gilbot-X says:
--#*
--#*  All UEF defense-weapon structures (such as artillery) extend 
--#*  This class directly from their script files.
--#*
--#** 
TStructureUnit = MakeAdjacencyStructureUnit(TStructureUnit)
--#*  
--#*  Make sure it also becomes an extended adjacency unit.
--#**
TPodTowerUnit = MakeAdjacencyStructureUnit(TPodTowerUnit)

end --(of non-destructive hook)