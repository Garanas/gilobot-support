--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/slidercontrols/slidermenubutton.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Slider controls UI code.  Call this code to check
--#**              if the selected unit has any slider controls.
--#**              You can then enable the button if this is so.
--#**  
--#***************************************************************************

local SupportedTypes = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/sliderdatatypes.lua').SupportedTypes
local GetCustomStatTypesFromUnit = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/sliderdatatypes.lua').GetCustomStatTypesFromUnit

function DoesUnitHaveSliderControls(selectedUnit)
    --# Check sync table as custom units 
    --# designed for this mod will pass data to use through it. 
    if UnitData[selectedUnit:GetEntityId()].SliderControlledStatValues then
        selectedUnit.SliderSyncData =
            UnitData[selectedUnit:GetEntityId()].SliderControlledStatValues
    end

    --# for each type of stat that can use a slider
    for kType, vType in SupportedTypes do
        if vType:Condition(selectedUnit) then return true end
    end
    
    --# for each type of custom stat this unit has
    for kType, vType in GetCustomStatTypesFromUnit(selectedUnit) do
        if vType:Condition(selectedUnit) then return true end
    end
end