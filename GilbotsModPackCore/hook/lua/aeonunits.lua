do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/aeonunits.lua
--#**  Modded By :  Gilbot-X
--#**
--#**  Summary   :  Unit class generic overrides for Aeon faction
--#**
--#**  Note: 310 lines in original file so if you get an error 
--#**  subtract 310 from the line number it gives you to find 
--#**  where it is in this hook file
--#**  
--#****************************************************************************

local MakeAdjacencyStructureUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencystructureunit.lua').MakeAdjacencyStructureUnit

--#* 
--#*  Gilbot-X says:
--#*
--#*  All Aeon defense-weapon structures (such as artillery) extend 
--#*  This class directly from their script files.
--#*
--#** 
AStructureUnit = MakeAdjacencyStructureUnit(AStructureUnit)

end --(end of non-destructive hook)