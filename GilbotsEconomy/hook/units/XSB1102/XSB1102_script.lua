--#****************************************************************************
--#*
--#*  Hook File:  /units/XSB1102/XSB1102_script.lua
--#*
--#*  Modded by:  Gilbot-X
--#*
--#*  Summary  :  Seraphim Hydrocarbon Power Plant Script
--#*
--#****************************************************************************

local HydroCarbonPowerPlant = 
    import('/mods/GilbotsModPackCore/lua/unitmods/hcpp.lua').HydroCarbonPowerPlant
    
XSB1102 = Class(HydroCarbonPowerPlant) {
  
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Override this with  code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        --# Do base class versions first
        HydroCarbonPowerPlant.DoBeforeAnyStateChanges(self)
        
        --# This was in unit script file.
        local bp = self:GetBlueprint().Display
        self.LoopAnimation = CreateAnimator(self)
        self.LoopAnimation:PlayAnim(bp.LoopingAnimation, true)
        self.LoopAnimation:SetRate(0.5)
        self.Trash:Add(self.LoopAnimation)
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This was originally in unit's script file.
    --#*  
    --#**
    OnKilled = function(self, instigator, type, overkillRatio)
        HydroCarbonPowerPlant.OnKilled(self, instigator, type, overkillRatio)
        if self.LoopAnimation then
            self.LoopAnimation:SetRate(0.0)
        end
    end,
}

TypeClass = XSB1102