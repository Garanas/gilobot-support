--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units/UAC1401B/UAC1401B.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Aeon Shield Strength Enhancer Script
--#**
--#****************************************************************************
local AdjacencyStructureUnit = 
    import('/lua/defaultunits.lua').AdjacencyStructureUnit

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local MakePauseableActiveEffectsUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/pauseableactiveeffectsunit.lua').MakePauseableActiveEffectsUnit

local BaseClass = MakePauseableActiveEffectsUnit(AdjacencyStructureUnit)  

--# This is for the new adjacency stuff
local Buff = 
    import('/lua/sim/Buff.lua')
local AdjacencyBuffs = 
    import('/lua/sim/AdjacencyBuffs.lua')    


UAC1401B = Class(BaseClass) {
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This code is from the UAC1401 unit script
    --#**
    OnCreate = function(self)
        --#  Call base class code first
        BaseClass.OnCreate(self)

        -- Add dome effect on top of unit
        self.DomeEntity = import('/lua/sim/Entity.lua').Entity({Owner = self,})
        self.DomeEntity:AttachBoneTo( -1, self, 'UAC1401' )
        self.DomeEntity:SetMesh('/effects/Entities/UAC1401-DOME_M001/UAC1401-DOME_mesh')
        self.DomeEntity:SetDrawScale(0.1*0.5)
        self.DomeEntity:SetVizToAllies('Intel')
        self.DomeEntity:SetVizToNeutrals('Intel')
        self.DomeEntity:SetVizToEnemies('Intel')            
        self.Trash:Add(self.DomeEntity)
        
        --# This is necessary for stat slider controls that
        --# edit adjacency bonus values.  See usage in function below.
        self.ModifierDifference = {}
        
        --# New for FA because of new adjacency sytem linked to buffs
        local buffDef = Buffs['T4ShieldStrengthBonus']
        if not buffDef then
            error("*ERROR: T4ShieldStrengthBonus buff not found.", 2)
            return 
        end            
        self.ModifierDifference[buffDef.EntityCategory] = {
            Add=0,
            Mult=0,
        }
    end,
    
  

    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my 'Stat Slider' mod.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#*
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        --# Update value of bonus.
        --# New for FA because of new adjacency sytem linked to buffs
        local buffDef = Buffs['T4ShieldStrengthBonus']
        if not buffDef then
            error("*ERROR: T4ShieldStrengthBonus buff not found.", 2)
            return 
        end    
        --# Instead of changing the value in the blueprint
        --# (which messes up calculating the new resource consumption)
        --# we instead record the difference between the blueprint
        --# value and the slider-control-adjusted value.
        --# The code that deals with adjacency bonuses will just check
        --# if a difference is set with the ModifierDifference table,
        --# and will add it to the bonus if it finds one.   This means
        --# the code still works for units that do not define the
        --# ModifierDifference table.
        self.ModifierDifference[buffDef.EntityCategory] = {
            Add = newStatValue - buffDef.Affects.ShieldStrength.Add,
            Mult = 0,
        }
        --# Tell the network to recalculate bonuses.
        self:RefreshAdjacencyBonus()
    end,

}

TypeClass = UAC1401B


