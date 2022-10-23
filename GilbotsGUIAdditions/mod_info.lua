name = "Gilbot-X's Mod Pack Modules: GUI Additions (for v2.4)"
uid = "12345678-2050-4f67-3333-a79b5bb07c8e"
version = 2.05 --(of the Mod Pack)
description = "Includes a new in-game menu for the Auto Toggle featues of the mod pack core, and buttons to launch AT menus and slider control menus."
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
    "12345678-2050-4efa-b0c3-f900bd68ffa3", -- Gilbot-X's 'Unit-Icons-in-one-folder' Mod
}
requiresNames = {
    ["12345678-2050-4bf6-9236-451244fa8029"] = 
        "Gilbot-X's Modpack Core",
    ["12345678-2050-4efa-b0c3-f900bd68ffa3"] = 
        "Icons Mod: Gilbot-X's put unit-icons-in-one-folder' Mod",
}
conflicts = {
    "4fb56516-9d9c-11dc-8314-0800200c9a66", --GOOM's GUI 6 (SCU manager)
}