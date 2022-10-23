--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units/GEB5201/GEB5201_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  T2 UEF Pipeline Script
--#**
--#****************************************************************************
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit
local PipeLineUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/pipelines.lua').PipeLineUnit
local BaseClass = MakeRemoteAdjacencyBeamUnit(PipeLineUnit)

GEB5201 = Class(BaseClass) {
    OnlyConnectToOtherRemoteAdjacencyUnits = true,
    
    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
    
        self.CanConnectToLayers.Land=true 
        self.CanConnectToLayers.Seabed=true
        self.CanConnectToLayers.Water=true
        self.CanConnectToLayers.Sub=true --# Cybran Harms
    end,
}

TypeClass = GEB5201