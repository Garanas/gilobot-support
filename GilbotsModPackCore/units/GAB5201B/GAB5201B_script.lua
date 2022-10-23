--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units/GAB5201B/GAB5201B_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  T2 Aeon Seabed Pipeline Script
--#**
--#****************************************************************************
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit
local PipeLineUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/pipelines.lua').PipeLineUnit
local BaseClass = MakeRemoteAdjacencyBeamUnit(PipeLineUnit)

GAB5201B = Class(BaseClass) {
    OnlyConnectToOtherRemoteAdjacencyUnits = true,
    
    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
        
        --# Like the T1/T2 sonar, enable us to 
        --# remotely connect to units under the sea only.
        self.CanConnectToLayers.Land=true 
        self.CanConnectToLayers.Seabed=true
        self.CanConnectToLayers.Water=true
        self.CanConnectToLayers.Sub=true --# Cybran Harms
    end,
    
}

TypeClass = GAB5201B
