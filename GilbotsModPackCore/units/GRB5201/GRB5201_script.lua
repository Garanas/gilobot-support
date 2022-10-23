--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units/GRB5201/GRB5201_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  T2 Cybran Pipeline Script
--#**
--#****************************************************************************
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit
local PipeLineUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/pipelines.lua').PipeLineUnit
local BaseClass = MakeRemoteAdjacencyBeamUnit(PipeLineUnit)

GRB5201 = Class(BaseClass) {
    OnlyConnectToOtherRemoteAdjacencyUnits = true,
}

TypeClass = GRB5201