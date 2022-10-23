--#****************************************************************************
--#**
--#**  Hook File:  /units/UEL0301/UEL0301_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF SACU Unit Script
--#**
--#****************************************************************************

local PreviousVersion = UEL0301
UEL0301 = Class(PreviousVersion) {

    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this because UEF SACU
    --#*  forks a thread to create a shield from 
    --#*  an enhancement but doesn't do this to
    --#*  destroy it when enhancement is removed.
    --#**
    CreateEnhancement = function(self, enh)
        --# I have to replace this because of my
        --# enhancement queue code.  Creation of 
        --# the shield is in a thread that waits 1 tick.
        --# This was trying to destrot the shield before
        --# it was created. Now I destroy the shield 
        --# after waiting 2 ticks.
        if enh=='ShieldGeneratorFieldRemove' then
            --# Skip base class version and call 
            --# the version it overrides.
            local Unit = import('/lua/sim/unit.lua').Unit
            Unit.CreateEnhancement(self, enh)
            --# Destroy shield only after we are
            --# sure it has already been created
            ForkThread(function()
                WaitTicks(2)
                self:DestroyShield()
                self:SetMaintenanceConsumptionInactive()
                self:RemoveToggleCap('RULEUTC_ShieldToggle')
            end)
        else
            --# Now the Pod's button will be added
            PreviousVersion.CreateEnhancement(self, enh)
        end
    end,
    
}   
    
TypeClass = UEL0301