--#****************************************************************************
--#**
--#**  Hook File:  /units/UEB1303/UEB1303_script.lua
--#**  
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF T3 Mass Fabricator
--#**
--#****************************************************************************

local PreviousVersion = UEB1303
UEB1303 = Class(PreviousVersion) {

    OnProductionPaused = function(self)
        PreviousVersion.OnProductionPaused(self)
        self:ForkThread(self.StopActiveAffects, self)
    end,
    
    
    StopActiveAffects = function(self)
        while not self.Rotator do WaitTicks(5) end
        self.Rotator:SetSpinDown(true)
        if self.AmbientEffects then
            self.AmbientEffects:Destroy()
            self.AmbientEffects = nil
        end  
    end,    
}

TypeClass = UEB1303