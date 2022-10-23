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

local MakeAdjacencyStructureUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencystructureunit.lua').MakeAdjacencyStructureUnit
local ModStructureUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/structureunit.lua').ModStructureUnit
local MakeToggleFactoryUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/togglefactory.lua').MakeToggleFactoryUnit
local MakePauseableProductionUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/pauseableproductionunit.lua').MakePauseableProductionUnit


--#################################################################
--##  STRUCTURE UNITS
--#################################################################
StructureUnit = ModStructureUnit(StructureUnit)
--# This is next global variable is new, not a hook  
--# I added this here to make my code 
--# more efficient to I can make the class once
--# and import it from many places.
AdjacencyStructureUnit = MakeAdjacencyStructureUnit(StructureUnit)

--#-------------------------------------------------------------
--#  FACTORY  UNITS
--#-------------------------------------------------------------
FactoryUnit = MakeAdjacencyStructureUnit(FactoryUnit)
AirFactoryUnit = MakeAdjacencyStructureUnit(AirFactoryUnit)
LandFactoryUnit = MakeAdjacencyStructureUnit(LandFactoryUnit)
SeaFactoryUnit = MakeAdjacencyStructureUnit(SeaFactoryUnit)
QuantumGateUnit = MakeAdjacencyStructureUnit(QuantumGateUnit)
--# You can comment these next 5 lines out 
--# if you don't like my factory toggles!
FactoryUnit = MakeToggleFactoryUnit(FactoryUnit)
AirFactoryUnit = MakeToggleFactoryUnit(AirFactoryUnit)
LandFactoryUnit = MakeToggleFactoryUnit(LandFactoryUnit)
SeaFactoryUnit = MakeToggleFactoryUnit(SeaFactoryUnit)
QuantumGateUnit = MakeToggleFactoryUnit(QuantumGateUnit)



--#-------------------------------------------------------------
--#          ECONOMY STRUCTURE UNITS
--#-------------------------------------------------------------
EnergyCreationUnit = MakeAdjacencyStructureUnit(EnergyCreationUnit) 
EnergyStorageUnit = MakeAdjacencyStructureUnit(EnergyStorageUnit) 
MassStorageUnit = MakeAdjacencyStructureUnit(MassStorageUnit)
MassCollectionUnit = MakeAdjacencyStructureUnit(MassCollectionUnit)
local MassFabBaseClass = MakePauseableProductionUnit(MakeAdjacencyStructureUnit(MassFabricationUnit))
MassFabricationUnit = Class(MassFabBaseClass) {
    --# Gilbot-X: I added this next line for my AT code.
    IsMassFabricationUnit = true,
}

--#-------------------------------------------------------------
--#          INTEL & SHIELD STRUCTURE UNITS
--#-------------------------------------------------------------
RadarUnit = MakeAdjacencyStructureUnit(RadarUnit)
RadarJammerUnit = MakeAdjacencyStructureUnit(RadarJammerUnit)
SonarUnit = MakeAdjacencyStructureUnit(SonarUnit)
ShieldStructureUnit = MakeAdjacencyStructureUnit(ShieldStructureUnit)

--#-------------------------------------------------------------
--#          OTHER STRUCTURE UNITS
--#-------------------------------------------------------------
AirStagingPlatformUnit = MakeAdjacencyStructureUnit(AirStagingPlatformUnit)


end --(of non-destructive hook)