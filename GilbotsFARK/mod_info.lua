name = "Gilbot-X's Units: Aeon F.A.R.K. (Fast Assist & Repair K-Bot)"
uid = "12345678-2050-454a-8534-c6acf412c30f"
version = 2.05 --(of the Mod Pack)
description = "Adds a TA style F.A.R.K. to Aeon that only repairs and assists. UEF & Cybran have Engineering Stations, but now Aeon has the F.A.R.K."
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