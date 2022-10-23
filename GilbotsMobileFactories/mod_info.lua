name = "Gilbot-X's Mod Pack Modules: Mobile Factory Improvements"
uid = "12345678-2050-4f67-a58a-339b5bb07c8e"
version = 2.05 --(of the Mod Pack)
description = "Units built by mobile factories will guard the factory. Mobile factories that can transport can toggle if new units are stored or deployed."
author = "Gilbot-X"
    
selectable = true
exclusive = false
ui_only = false
icon = "/mods/GilbotsModPackCore/icon.png" 

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