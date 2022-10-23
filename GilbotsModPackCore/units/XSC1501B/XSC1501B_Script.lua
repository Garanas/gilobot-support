--#****************************************************************************
--#*
--#*  Hook File:  /mods/.../units/XSC1501B/XSC1501B_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  Seraphim Resource Network Unifier Script
--#*
--#*  
--#****************************************************************************


--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local MakePauseableActiveEffectsUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/pauseableactiveeffectsunit.lua').MakePauseableActiveEffectsUnit

local MakeAdjacencyUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencyunit.lua').MakeAdjacencyUnit
local MakeRemoteAdjacencyFieldUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencyfieldunit.lua').MakeRemoteAdjacencyFieldUnit
local SStructureUnit = 
    import('/lua/seraphimunits.lua').SStructureUnit
local BaseClass = 
    MakePauseableActiveEffectsUnit(MakeRemoteAdjacencyFieldUnit(MakeAdjacencyUnit(SStructureUnit)))
    
local ResourceInterNetwork = 
    import('/mods/GilbotsModPackCore/lua/adjacency/resourceinternetwork.lua').ResourceInterNetwork
    
    
XSC1501B = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Called by UpdateConsumptionWhenAbilityChanges in my hook of unit.lua
    --#*  as result of slider control callbacks.
    --#* 
    --#**          
    UpdateActiveEffectsWhenAbilityChanges = function(self, changeFactor, resourceDrainId)
        --# Use the square root to stop effects getting too big (or small)
        self.ActiveEffectIncreaseMultiplier = math.pow(changeFactor, 0.5)
        self.ActiveEffectsSettings.Offset.z = -2 * self.ActiveEffectIncreaseMultiplier
        self:UpdateActiveEffects()
    end,
}

TypeClass = XSC1501B