name = "Gilbot-X's Units: UEF T3 Mobile Heavy SAM Launcher"
uid = "12345678-2050-42fb-8067-a054296450b9"

version = 2.05 --(of the Mod Pack)
description = "Gives the UEF a T3 Mobile SAM launcher with a nuclear SAM upgrade. Good against T3 gunships and slow moving Experimental air units."
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

