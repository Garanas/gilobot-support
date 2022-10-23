--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units/GEB5301B/GEB5301B_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  T3 UEF Seabed Pipeline Script
--#**
--#****************************************************************************
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit
local PipeLineUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/pipelines.lua').PipeLineUnit
local BaseClass = MakeRemoteAdjacencyBeamUnit(PipeLineUnit)

GEB5301B = Class(BaseClass) {

    OnlyConnectToOtherRemoteAdjacencyUnits = true,

    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
        
        --# Gilbot-X says: 
        --# This is for my Maintenance Consumption Breakdown Mod
        --# which keep tracks of which / how many types of resource 
        --# consuming abilities are currently active in the unit.
        self.EnabledResourceDrains.Shield= true
        
        self.CanConnectToLayers.Land=true 
        self.CanConnectToLayers.Seabed=true
        self.CanConnectToLayers.Water=true
        self.CanConnectToLayers.Sub=true --# Cybran Harms
    end,
}


TypeClass = GEB5301B