do--(start of non-destructive hook)
local Prefs = import('/lua/user/prefs.lua')
local options = Prefs.GetFromCurrentProfile('options')

--# If user enabled SCU manager...
if options.gui_scu_manager ~= 0 then
    --# Hook this function to call
    --# another Itit function
    local originalCreateUI = CreateUI
    function CreateUI(isReplay)
        --# Preserve original code
        originalCreateUI(isReplay)
        
        --# This is what is added
        import("/mods/GilbotsGoomGUI/modules/scumanager.lua").Init()
    end
end

--# Hook this function to add code afterwards
local originalOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
    --# Preserve original code
    originalOnSelectionChanged(oldSelection, newSelection, added, removed)

    --# This is what is appended
    if newSelection 
     and table.getn(newSelection) == 1 
     and import("/mods/GilbotsGoomGUI/modules/selectedinfo.lua").SelectedOverlayOn then
         import("/mods/GilbotsGoomGUI/modules/selectedinfo.lua").ActivateSingleRangeOverlay()
    else
         import("/mods/GilbotsGoomGUI/modules/selectedinfo.lua").DeactivateSingleRangeOverlay()
    end   
end

--# This happens once, right at beginning
import('/mods/GilbotsGoomGUI/modules/keymapping.lua').Init()

end--(of non-destructive hook)