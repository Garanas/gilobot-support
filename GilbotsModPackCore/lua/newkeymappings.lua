--#****************************************************************************
--#**
--#**  New File:  /mods/GilbotsModPackCore/lua/newkeymappings.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  These are imported into /lua/ui/game/gamemain.lua
--#**              so that these keymappings are added to the game.
--#**
--#****************************************************************************

KeyMappings = {
    ['Alt-NumMinus']  = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/autotoggle/autotoggleprioritychanges.lua").ChangeAutoTogglePriorityClass("Decrease")', 
        stringkey = 'decrease_autotoggle_priority_class', 
        category = '<LOC keymap_category_0036>Orders', 
        order = 29,
    },
    ['Alt-NumPlus']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/autotoggle/autotoggleprioritychanges.lua").ChangeAutoTogglePriorityClass("Increase")', 
        stringkey = 'increase_autotoggle_priority_class', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 30,
    },
    ['Ctrl-NumMinus']  = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/autotoggle/autotoggleprioritychanges.lua").ChangeAutoTogglePriority("Decrease")', 
        stringkey = 'decrease_autotoggle_priority', 
        category = '<LOC keymap_category_0036>Orders', 
        order = 31,
    },
    ['Ctrl-NumPlus']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/autotoggle/autotoggleprioritychanges.lua").ChangeAutoTogglePriority("Increase")', 
        stringkey = 'increase_autotoggle_priority', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 32,
    },
    ['Ctrl-NumStar']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/nexttounitdisplaymanager.lua").ToggleDisplay("AutoToggleDisplay")', 
        stringkey = 'show_autotoggle_priorities', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 33,
    },
    ['Ctrl-NumSlash']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/nexttounitdisplaymanager.lua").ToggleDisplay("NetworkDisplayText")', 
        stringkey = 'show_network_id', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 34,
    },
    ['Ctrl-Alt-NumSlash']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/userinterfacemappings.lua").ToggleEntityDisplay()', 
        stringkey = 'show_entity_id', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 35,
    },
    ['Alt-S']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/shieldhpdisplay.lua").ToggleShieldStrengthDisplay()', 
        stringkey = 'show_shield_strength', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 36,
    },
    ['Alt-F']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/rateoffiredisplay.lua").ToggleRateOfFireDisplay()', 
        stringkey = 'show_rate_of_fire', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 37,
    },
    ['Ctrl-Alt-M']   = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/userinterfacemappings.lua").ToggleExtraAltOrderButtons()', 
        stringkey = 'toggle_extra_alt_order_buttons', 
        category = '<LOC keymap_category_0036>Orders',  
        order = 38,
    },
    ['Alt-R']  = {
        action =  'UI_Lua import("/mods/GilbotsModPackCore/lua/userinterfacemappings.lua").CreateStatSliderMenu()', 
        stringkey = 'create_slider', 
        category = '<LOC keymap_category_0036>Orders', 
        order = 39,
    },
}