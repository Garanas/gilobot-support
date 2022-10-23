do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/cybranunits.lua
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Unit class generic overrides for Cybran faction
--#**
--#**  
--#****************************************************************************

local BaseClass = CMassCollectionUnit
CMassCollectionUnit = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do non-static variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# Perform original class version
        BaseClass.OnCreate(self)
        
        --# This is used by code from my (now integrated) 
        --# Maintenance Consumption Breakdown mod.
        --# It uses this table to keep track of how many / 
        --# which types of intel are active.
        self.EnabledResourceDrains = {
            Stealth = false,
            ProductionCosts = true,
        }
    end,
    
    
    --# Gilbot-X: This is called once our MeX is built and is ready to become
    --# active.  I always do my unit initilisation code here.
    OnStopBeingBuilt = function(self, builder, layer)
        --# original version will just SetMaintenanceConsumptionActive
        --# and call its superclass, which itself calls
        --# self:PlayActiveAnimation() and then calls the version in unit.lua
        BaseClass.OnStopBeingBuilt(self, builder, layer)
        
        --# Turn stealth off by default, otherwise it's
        --# annoying turning off stealth manually when building
        --# first base at start of game.        
        self:SetScriptBit('RULEUTC_StealthToggle', true)
    end,
}

end --(of non-destructive hook)