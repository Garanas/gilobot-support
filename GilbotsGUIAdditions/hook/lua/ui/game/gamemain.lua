do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/ui/game/gamemain.lua
--#**
--#**  Modded By:  Gilbot-X, based on UI work by Goom
--#**
--#**  Summary  :  Overrided to add buttons to a new menu
--#**              when certain units are selected.
--#**
--#****************************************************************************

local ExtraButtonsMenu = 
    import('/mods/GilbotsGUIAdditions/extrabuttonsmenu.lua')
local DoesUnitHaveSliderControls = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/slidermenubutton.lua').DoesUnitHaveSliderControls

    
--#*
--#*  Gilbot-X says:
--#*
--#*  I overrided this so that any menu gets  
--#*  initialised once when the UI is created.
--#**    
local OldCreateUI = CreateUI
function CreateUI(isReplay)
    OldCreateUI(isReplay)
    ExtraButtonsMenu.Init()
end


--#*
--#*  Gilbot-X says:
--#*
--#*  I overrided this so that when units are selected 
--#*  I can add buttons to my extra menu based on that.
--#**   
local OldOnSelectionChanged = OnSelectionChanged
function OnSelectionChanged(oldSelection, newSelection, added, removed)
    --# Run old code first
    OldOnSelectionChanged(oldSelection, newSelection, added, removed)
    
    --# OnSelectionChanged gets called when 
    --# toggle buttons are added or removed from a unit,
    --# so in some cases, there isn't really a change in 
    --# which units are selected, this is just part of a
    --# refresh cycle for the unit view interface.
    if table.getsize(added) + table.getsize(removed) > 0 then 
        --# Start off with no buttons
        ExtraButtonsMenu.ClearButtons()
   
        --# Make a note of what is selected
        local numberOfUnitsSelected  = table.getsize(newSelection) or 0
        local allSameUnit = true
        local bpID = false
        local unitHasSliderControls = false
        for _, vUnit in newSelection do
            --# Record if we come accross any unit with slider controls
            if (not unitHasSliderControls) then 
                --# Reduce the number of times this is called
                if DoesUnitHaveSliderControls(vUnit) then 
                    unitHasSliderControls = true 
                end
            end
            --# Compare this unit's BP id with the last one
            if bpID and bpID ~= vUnit:GetBlueprint().BlueprintId then
                --# if they are different,
                --# they can't all be the same unit!
                allSameUnit = false
                break
            else
                bpID = vUnit:GetBlueprint().BlueprintId
            end
        end
            
        --# Test if unit has AT and add button if it does
        if numberOfUnitsSelected == 1 then     
            local entityId = newSelection[1]:GetEntityId()
            if UnitData[entityId] and UnitData[entityId].AutoToggleEntries 
              and UnitData[entityId].AutoToggleControlsEnabled then
                ExtraButtonsMenu.AddButton('AutoToggle')
            end
        end
        
        --# Allow slider control if there is 
        --# any one type of unit selected
        if unitHasSliderControls and allSameUnit then 
            ExtraButtonsMenu.AddButton('SliderControls')
        end
    end
end


end --(end of non-destructive hook)