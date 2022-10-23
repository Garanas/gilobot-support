--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units//GRB5301_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  T3 Cybran Pipeline Script
--#**
--#****************************************************************************
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit
local PipeLineUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/pipelines.lua').PipeLineUnit
local BaseClass = MakeRemoteAdjacencyBeamUnit(PipeLineUnit)

GRB5301 = Class(BaseClass)  {

    OnlyConnectToOtherRemoteAdjacencyUnits = true,

    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
        
        --# Gilbot-X says: 
        --# This is for my Maintenance Consumption Breakdown Mod
        --# which keep tracks of which / how many types of resource 
        --# consuming abilities are currently active in the unit.
        self.EnabledResourceDrains.Shield= true
    end,
}

TypeClass = GRB5301