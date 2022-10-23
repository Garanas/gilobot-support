name = "Gilbot-X's Mod Pack Modules: Military Upgrades Part 2"
uid = "12345678-2050-4f67-a58a-a79b5bb07aaa"
version = 2.05 --(of the Mod Pack)
description = "Adds upgrades in the same way as part 1, but the units in part 2 will also takle advantage of veterancy buffs from the Experimental Wars mod."
author = "Gilbot-X"
    
selectable = true
exclusive = false
ui_only = false
icon = "/mods/GilbotsModPackCore/icon.png" 

after = {
    "12345678-2050-4bf6-9236-451244fa8029", --Gilbot-X's Mod Pack Modules: Core
    "12345678-2050-4efa-b0c3-f900bd68ffa3", --Gilbot-X's 'Unit-Icons-in-one-folder' Mod
    "12345678-2050-4f67-a58a-a79b5bb07c8e", --Gilbot-X's Mod Pack Modules: Military Upgrades Part 1
}
requires = {
    "12345678-2050-4bf6-9236-451244fa8029", --Gilbot-X's Mod Pack Modules: Core
    "12345678-2050-4efa-b0c3-f900bd68ffa3", --Gilbot-X's 'Unit-Icons-in-one-folder' Mod
    "12345678-2050-4f67-a58a-a79b5bb07c8e", --Gilbot-X's Mod Pack Modules: Military Upgrades Part 1
}
requiresNames = {
    ["12345678-2050-4bf6-9236-451244fa8029"] = 
        "Gilbot-X's Modpack Core",
    ["12345678-2050-4efa-b0c3-f900bd68ffa3"] = 
        "Icons Mod: Gilbot-X's put unit-icons-in-one-folder' Mod",
    ["12345678-2050-4f67-a58a-a79b5bb07c8e"] = 
        "Gilbot-X's Mod Pack Modules: Military Upgrades Part 1",
}