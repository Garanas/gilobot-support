name = "Gilbot-X's Units: UEF T3 Mobile Shield"
uid = "12345678-2050-4b5c-9aa0-28830d6fb38a"

version = 2.05 --(of the Mod Pack)
description = "Gives the UEF a T3 Mobile Shield.  Less armor and more expensive than a stationary T3 Shield Generator, but same shield strength."
author = "Gilbot-X"
icon = "/mods/GilbotsModPackCore/icon.png" 

selectable = true
exclusive = false
ui_only = false

after = {
    "12345678-2050-4bf6-9236-451244fa8029", 
    "12345678-2050-4efa-b0c3-f900bd68ffa3",
}
requires = {
    "12345678-2050-4bf6-9236-451244fa8029", -- Gilbot-X's Modpack Core
    "12345678-2050-4efa-b0c3-f900bd68ffa3",  -- Gilbot-X's 'Unit-Icons-in-one-folder' Mod
}
requiresNames = {
    ["12345678-2050-4bf6-9236-451244fa8029"] = 
        "Gilbot-X's Modpack Core",
    ["12345678-2050-4efa-b0c3-f900bd68ffa3"] = 
        "Icons Mod: Gilbot-X's put unit-icons-in-one-folder' Mod",
}

--[[
Unit was not going into formation, possibly because there is no category SHIELD is used by static shields and units with personal shields.  
Hooked formation file to remedy this.

Better to have a category for SHIELDGEN or STEALTHGEN or PROTECTION in the formations file?  Can use for AA, shields, and stealth.

]]