name = "Goom's GUI Pack (Gilbot's Compatibilty Fix)"
uid = "12345678-2050-11dc-8314-0800200c9a67"
version = 6
description = "This is a fix of Gooms GUI6 that is compatible with Gilbot-X's mods.  All modules can be enabled/disabled in the options menu ingame."
author = "Goom et al, with compatibility tweaks by Gilbot-X"
url = "http://forums.gaspowered.com/viewtopic.php?p=323645#323645"
icon = "/mods/GilbotsGoomGUI/mod_icon.dds"
selectable = true
enabled = true
exclusive = false
ui_only = true
requires = { }
requiresNames = { }
conflicts = {
  "23c15cf2-9b8b-11dc-8314-0800200c9a66",
  "51E46BF0-9D29-11DC-8314-0800200C9A66",
  "3da7bd94-9c30-11dc-8314-0800200c9a66",
  "D29D93D8-9735-11DC-84C8-D5A156D89593",
  "4fb56516-9d9c-11dc-8314-0800200c9a66", -- Original Unadapted version GOOM's GUI 6 (SCU manager)

}
after = {
    "12345678-2050-4bf6-9236-451244fa8029", -- Gilbot-X's Modpack Core
    "12345678-2050-4efa-b0c3-f900bd68ffa3", -- Gilbot-X's 'Unit-Icons-in-one-folder' Mod
    "12345678-2050-4f67-3333-a79b5bb07c8e", -- Gilbot-X's Mod Pack Modules: GUI Additions (for v2.1)
}
requires = {
    "12345678-2050-4bf6-9236-451244fa8029", -- Gilbot-X's Modpack Core
    "12345678-2050-4efa-b0c3-f900bd68ffa3", -- Gilbot-X's 'Unit-Icons-in-one-folder' Mod
    "12345678-2050-4f67-3333-a79b5bb07c8e", -- Gilbot-X's Mod Pack Modules: GUI Additions (for v2.1)
}
requiresNames = {
    ["12345678-2050-4bf6-9236-451244fa8029"] = 
        "Gilbot-X's Modpack Core",
    ["12345678-2050-4efa-b0c3-f900bd68ffa3"] = 
        "Gilbot-X's Mod Pack Modules: Icons Mod",
    ["12345678-2050-4f67-3333-a79b5bb07c8e"] =  
        "Gilbot-X's Mod Pack Modules: GUI Additions (for v2.1)",
}
