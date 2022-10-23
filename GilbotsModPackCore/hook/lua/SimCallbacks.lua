do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/SimCallbacks.lua
--#**  Modded by:  Gilbot-X, with code from Neruz and Goom
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


--#*
--#*  Gilbot-X says:  
--#*  These are part of Goom's area commands mod.
--#**
Callbacks.AreaCommandCallback = 
    import('/mods/GilbotsModPackCore/lua/areacommands.lua').AreaCommand
Callbacks.DrawRectangle = 
    import('/mods/GilbotsModPackCore/lua/areacommands.lua').DrawRectangle


--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for my slider control menu.
--#**
Callbacks.SetShieldSize =
    import('/mods/GilbotsModPackCore/lua/slidercontrols/slidercallbacks.lua').SetShieldSizeCallback
Callbacks.SetStatValue = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/slidercallbacks.lua').SetStatValueCallback
    
    
--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for my auto-toggle system.
--#**
local ATCallbacks = import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecallbacks.lua')
Callbacks.DecreaseAutoTogglePriority = ATCallbacks.DecreasePriorityCallback
Callbacks.IncreaseAutoTogglePriority = ATCallbacks.IncreasePriorityCallback
Callbacks.DecreaseAutoTogglePriorityClass = ATCallbacks.DecreasePriorityClassCallback
Callbacks.IncreaseAutoTogglePriorityClass = ATCallbacks.IncreasePriorityClassCallback
Callbacks.SetPriorityToFirstOrLastInClass = ATCallbacks.SetPriorityToFirstOrLastInClassCallBack
Callbacks.SetAutoTogglePriorityClass = ATCallbacks.SetPriorityClassCallback
Callbacks.DisableAutoToggle = ATCallbacks.DisableAutoToggleCallback    

   
--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for debugging my Resource Network system.
--#**
Callbacks.ToggleNetworkDisplay = 
    import('/mods/GilbotsModPackCore/lua/adjacency/resourcenetworkcallbacks.lua').ToggleNetworkDisplayCallback     

--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for general debugging.
--#**
Callbacks.ToggleEntityDisplay = 
    import('/mods/GilbotsModPackCore/lua/debuggingcallbacks.lua').ToggleEntityDisplayCallback    
Callbacks.GiveSIMScreenBounds = 
    import('/mods/GilbotsModPackCore/lua/onscreenunitdisplay.lua').GiveSIMScreenBoundsCallback    

--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for debugging shields and
--#*  the Aeon shield strength enhancer
--#**
Callbacks.ToggleShieldStrengthDisplay = 
    import('/mods/GilbotsModPackCore/lua/shieldhpdisplay.lua').ToggleShieldStrengthDisplayCallback     

--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for debugging shields and
--#*  the Aeon shield strength enhancer
--#**
Callbacks.ToggleRateOfFireDisplay = 
    import('/mods/GilbotsModPackCore/lua/rateoffiredisplay.lua').ToggleRateOfFireDisplayCallback     
           
--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for units that have more than 6 alt commands.
--#**
Callbacks.ToggleExtraAltOrderButtons = 
    import('/mods/GilbotsModPackCore/lua/extraaltorders.lua').ToggleExtraAltOrderButtonsCallback   

    
--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for queuing enhancements
--#**
Callbacks.AddEnhancementToQueue = 
    import('/mods/GilbotsModPackCore/lua/enhancementqueue.lua').AddEnhancementToQueueCallback   
--#*
--#*  Gilbot-X says:  
--#*  These callbacks are for queuing enhancements
--#**
Callbacks.UpdateQueueStatus = 
    import('/mods/GilbotsModPackCore/lua/enhancementqueue.lua').UpdateQueueStatusCallback   

    
    
end --(of non-destructive hook)