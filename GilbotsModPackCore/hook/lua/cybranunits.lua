do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/cybranunits.lua
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Unit class generic overrides for Cybran faction
--#**
--#**  Note: 362 lines in original file so if you get an error 
--#**  subtract 362 from the line number it gives you to find 
--#**  where it is in this hook file.
--#**  
--#****************************************************************************

local MakeAdjacencyStructureUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencystructureunit.lua').MakeAdjacencyStructureUnit

--#* 
--#*  Gilbot-X says:
--#*
--#*  All Cybran defense-weapon structures (such as artillery) extend 
--#*  CStructureUnit directly from their script files.
--#** 
CStructureUnit = MakeAdjacencyStructureUnit(CStructureUnit)
--#** Make sure this gets adjacency too.
CConstructionStructureUnit = MakeAdjacencyStructureUnit(CConstructionStructureUnit) 
  

  
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit

--#* 
--#*  Gilbot-X says:
--#*
--#*  Override so all these units get special remote 
--#*  adjacency features to link up submerged units.
--#** 
local BaseClass = MakeRemoteAdjacencyBeamUnit(CSonarUnit)
CSonarUnit = Class(BaseClass) {
    
    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
        
        --# Gilbot-X says: 
        --# This is for my Maintenance Consumption Breakdown Mod
        --# which keep tracks of which / how many types of resource 
        --# consuming abilities are currently active in the unit.
        self.EnabledResourceDrains.Intel= true
    
        --# Do not get remote adjacency from other units, 
        --# only give to seabed units
        self.IsNotRemoteAdjacencyReceiver = true
        --# Override this after calling base class of OnCreate
        self.CanConnectToLayers.Land=false 
        self.CanConnectToLayers.Seabed=true
        self.CanConnectToLayers.Water=false
        self.CanConnectToLayers.Sub=true --# Cybran Harms?
    end,
}

end --(of non-destructive hook)