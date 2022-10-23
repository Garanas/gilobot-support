name = "Gilbot-X's Mod Pack Modules: Engineer Enhancements"
uid = "12345678-2050-4bfd-8588-26fd00e97578"
version = 2.05 --(of the Mod Pack)
copyright = "Gilbot-X"
description = "Most engineers have upgrade options. Enhancements include movement speed, build-rate, cloak, stealth, teleport, shields, and more."
author = "Gilbot-X"
icon = "/mods/GilbotsModPackCore/icon.png" 
selectable = true
enabled = true
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
conflicts = {"fb281220-9e76-4bfd-8588-26fd00e97577"}
before = {}
