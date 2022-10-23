--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/autotoggle/autotogglecallbacks.lua
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

local GilbotUtils = import('/mods/GilbotsModPackCore/lua/utils.lua')

--# This effects what is output to the log.
--# Switch it to false if you are not debugging.
local debugAdjacencyCode = false


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function gets the ACU for the focus army,
--#*  checks if it is alive, and if it is, it 
--#*  calls the ACU function to toggle display 
--#   of all priority position numbers 
--#*  in the ordered priority list.
--#**
function ToggleNetworkDisplayCallback(data)
    
    --# This next block is for debugging only.
    --# This can be delete wheh debugging is done.
    if debugAdjacencyCode then 
      LOG('Adjacency: ResourceNetworksCallbacks.lua: ' 
      .. ' ToggleNetworkDisplayCallback: ' 
      .. ' Function called with arg data.ArmyId=' 
      .. repr(data.ArmyId)
      )
    end
    
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local myCommander = GilbotUtils.GetCommanderFromArmyId(data.ArmyId)
       
    --# Only pass on call if this is an autotoggle unit.
    if myCommander then
        myCommander:ReceiveACUMessage_ToggleNetworkDisplay()
    end
  
end
