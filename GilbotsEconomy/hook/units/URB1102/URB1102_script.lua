--#****************************************************************************
--#**
--#**  Hook File:  /units/URB1102/URB1102_script.lua
--#**
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  Cybran Hydrocarbon Power Plant Script
--#**
--#****************************************************************************

local HydroCarbonPowerPlant = 
    import('/mods/GilbotsModPackCore/lua/unitmods/hcpp.lua').HydroCarbonPowerPlant
local MakeCloakFieldUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/cloakfieldunit.lua').MakeCloakFieldUnit

--# Apply common code for my units that have cloak fields
local BaseClass = MakeCloakFieldUnit(HydroCarbonPowerPlant)

URB1102 = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Initialisation.
    --#**
    OnCreate = function(self,builder,layer)
        --# Call base class version first
        BaseClass.OnCreate(self)
        
        --# This table overrides one from the the MaintenanceConsumption Mod
        --# which declares/instantiates this table variable in a hook of unit.lua .
        --# The mod uses this table to keep track of how many types of intel are active.
        self.EnabledResourceDrains = {
            Stealth = false,
            Cloak = false,
        }
    end,
    
        
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Override this with  code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        --# Do base class versions first
        BaseClass.DoBeforeAnyStateChanges(self)
        
        --# This turns off the toggles for cloak and stealth
        self:SetScriptBit('RULEUTC_CloakToggle', true)
        self:SetScriptBit('RULEUTC_StealthToggle', true)
    end,
    
}

TypeClass = URB1102