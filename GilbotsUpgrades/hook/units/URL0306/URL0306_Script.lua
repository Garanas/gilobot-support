do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /units/URL0306/URL0306_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran Mobile Radar Jammer Script
--#**
--#****************************************************************************

local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local BaseClass = MakeCustomUpgradeMobileUnit(URL0306, 'URL0306', 0.4)
URL0306 = Class(BaseClass) {

  IntelEffects = nil,
    StealthEffects = {
        {
            Bones = {
                    'AttachPoint',
            },
            Offset = {
                    0,
                    0.3,
                    0,
            },
            Scale = 0.2,
            Type = 'Jammer01',
        },
    },
    

    --# Gilbot-X: I added this function
    AddStealthEffects = function(self)
        --# Get rid of any olf effects
        self:DestroyStealthEffects()
        --# Prepare for new effects
        self.StealthEffectsBag = {}
        
        --# Add new effects
        self.CreateTerrainTypeEffects( self, self.StealthEffects, 'FXIdle',  
                                    self:GetCurrentLayer(), nil, self.StealthEffectsBag )
    end,
    
    
    --# Gilbot-X: I added this function
    DestroyStealthEffects = function(self)
        if self.StealthEffectsBag then
             --# Destroy any old effects
            for k, v in self.StealthEffectsBag do
                v:Destroy()
            end
            self.StealthEffectsBag = nil
        end
    end,
    
    
    --# I override these two functions to toggle stealth effects.
    --# Note: There was an error in the GPG version 
    --# where the effect would get stronger every
    --# time it was toggled off and back on again.
    OnIntelEnabled = function(self)
        CLandUnit.OnIntelEnabled(self)
        self:AddStealthEffects()
    end,
    
    OnIntelDisabled = function(self)
        CLandUnit.OnIntelDisabled(self)
        self:DestroyStealthEffects()
    end,
}
    
TypeClass = URL0306
end --(of non-destructive hook)