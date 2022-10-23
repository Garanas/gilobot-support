--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/debuggingcallbacks.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  
--#**
--#**  This module contains the Sim-side lua functions that can be invoked
--#**  from the user side.  These need to validate all arguments against
--#**  cheats and exploits.
--#**
--#**  We store the callbacks in a sub-table (instead of directly in the
--#**  module) so that we don't include any.
--#**  
--#***************************************************************************

local UnitText = 
    import('/mods/GilbotsModPackCore/lua/unittext.lua')
   
--#*
--#*  Gilbot-X says:  
--#*
--#*  This function gets the units selected, checks if 
--#*  it is alive and a ... unit, and if it is, it 
--#*  calls the function to flash a message to the user
--#*  (using the custom naming system).
--#**
function ToggleEntityDisplayCallback(data)
    --# For each unit that was selected
    for k, unitEntityId in data.UnitEntityIdList do
        --# Try to get an autotoggle unit from the ID passed by UI side.
        local selectedUnit = GetEntityById(unitEntityId)
        --# Only pass on call if this is unit is not dead.
        if selectedUnit:IsAlive() then
            --# FlashMessage is defined in my hook of Unit.lua
            selectedUnit:FlashMessage('e' .. unitEntityId, 5)
        end
    end
end


