name = "Gilbot-X's Units: T4 Power Generators"
uid = "12345678-2050-4530-a3a2-0bc66e315dfc"
icon = "/mods/GilbotsModPackCore/icon.png" 
version = 2.05 --(of the Mod Pack)
description = "This mod gives all factions a T4 Power generator. They are more efficient to build than T3 Power generators, but they are highly volatile."
author = "Gilbot-X"

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