do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/ui/game/gamemain.lua
--#**
--#**  Modded By:  Gilbot-X, with link to code from Goom
--#**
--#**  Summary  :  Overrided to add keymappings for slider controls
--#**              and autotoggle priority order changes
--#**
--#****************************************************************************

--#*
--#*  Gilbot-X says:
--#*
--#*  I overrided this to add my extra 
--#*  keymappings when the UI is created.
--#**
local OldCreateUI = CreateUI
function CreateUI(isReplay)
    --# Execute original code first
    OldCreateUI(isReplay)
    --# Init my version of Goom's Area Commands mod.
    import('/mods/GilbotsModPackCore/lua/areacommands.lua').Init()
    --# Add my new key mappings
    IN_AddKeyMapTable(import('/mods/GilbotsModPackCore/lua/newkeymappings.lua').KeyMappings)
end


--#*
--#*  Gilbot-X says:
--#*
--#*  I overrided this so that any slider menu gets  
--#*  destroyed if the selection is changed. 
--#**
local OldOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
    import("/mods/GilbotsModPackCore/lua/userinterfacemappings.lua").DestroyLastStatSliderMenu()
    OldOnSelectionChanged(oldSelection, newSelection, added, removed)
end

end --(end of non-destructive hook)