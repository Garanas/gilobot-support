--#****************************************************************************
--#**
--#**  New File:  /mods/GilbotsModPackCore/lua/userinterfacemappings.lua
--#**
--#**  Modded By:  Gilbot-X, with link to code from Goom
--#**
--#**  Summary  :  Overrided to add keymappings for slider controls
--#**              and autotoggle priority order changes
--#**
--#****************************************************************************

local StatSliderMenu = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/slidermenu.lua').StatSliderMenu
    
--# Use this reference to check if a slider menu is already active
--# so we don't show a new one till the previous one is gone.
local ReferenceToLastSliderMenu

--#*
--#*  Gilbot-X says:
--#*
--#*  I added this to be called from OnSelectionChanged
--#*  in gamemain.lua so that any slider menu gets  
--#*  destroyed if the selection is changed. 
--#**
ToggleStatSliderMenu = function()
    --# If there is already a slider control menu we can reference
    if ReferenceToLastSliderMenu and ReferenceToLastSliderMenu.IsMenuActive then
        --# Destroy menu and make sure nothing can reference it
        ReferenceToLastSliderMenu:Destroy()
        ReferenceToLastSliderMenu = nil
    else
        --# Create menu and make sure we can reference it
        ReferenceToLastSliderMenu = StatSliderMenu(GetSelectedUnits())
    end
end

--#*
--#*  Gilbot-X says:
--#*
--#*  I added this to be called from OnSelectionChanged
--#*  in gamemain.lua so that any slider menu gets  
--#*  destroyed if the selection is changed. 
--#**
DestroyLastStatSliderMenu = function()
    if ReferenceToLastSliderMenu then 
        if ReferenceToLastSliderMenu.IsMenuActive then
            --# Destroy menu and make sure nothing can reference it
            ReferenceToLastSliderMenu:Destroy()
            ReferenceToLastSliderMenu = nil
        end
    end
end

--#*
--#*  Gilbot-X says:
--#*
--#*  I created this so that a new slider menu can be launched 
--#*  by pressing Alt-R (but only if there isn't one active already).
--#**
CreateStatSliderMenu = function()
    
    if ReferenceToLastSliderMenu and ReferenceToLastSliderMenu.IsMenuActive then
        --# Menu already active when Alt-R pressed,
        --# so do nothing, as we can't display new controls
        --# until previous set are gone.
        return
    end
    
    local unitsSelected = GetSelectedUnits()
    if unitsSelected and type(unitsSelected) == 'table' then 
        ReferenceToLastSliderMenu = StatSliderMenu(unitsSelected)
        --# Don't have to add this menu object to the trash because 
        --# it destroys itself when the unit selection 
        --# changes or the player hits the OK button.
    end
end



--#*
--#*  Gilbot-X says:
--#*
--#*  I created this so that extra alt orders units 
--#*  can receive a message to change the buttons 
--#*  shown on their command menu, i.e. reveal 
--#*  ones not showing when there are more than 6.
--#**
ToggleExtraAltOrderButtons = function()
    --# Find out what units are selected
    local unitsSelected = GetSelectedUnits()
    
    --# If exactly one unit is selected
    if unitsSelected 
    and (type(unitsSelected) == 'table') 
    and (table.getsize(unitsSelected) == 1)
    then 
        --# Get entity Id to pass as argument
        local entityArg = unitsSelected[1]:GetEntityId()
        
        --# Invoke sim side code.
        SimCallback( 
          {  
            Func='ToggleExtraAltOrderButtons',
            Args={ 
              SelectedUnitEntityId= entityArg,
            }
          }
        )
    end
    
end




--#*
--#*  Gilbot-X says:
--#*
--#*  I created this so that network IDs of units 
--#*  in Resource Networks can be displayed by pressing
--#*  CTRL-/ on the keyboard numberpad. 
--#*  Make sure that Num Lock is active on your keyboard.
--#**
ToggleNetworkDisplay = function()
    
    --# Find out what army did this
    local myArmyId = GetFocusArmy()
    
    --# If we have an army
    if myArmyId then 
        --# Invoke sim side code.
        SimCallback( 
          {  
            Func='ToggleNetworkDisplay',
            Args={ 
                ArmyId= myArmyId
            }
          }
        )
    end
    
end



--#*
--#*  Gilbot-X says:
--#*
--#*  I created this so that entity IDs 
--#*  can be displayed by selecting units 
--#*  and using CTRL-ALT-/ on the keyboard numberpad. 
--#*  Make sure that Num Lock is active on your keyboard.
--#**
ToggleEntityDisplay = function()
    
    local unitsSelected = GetSelectedUnits()
   --# If at least one unit is selected
    if unitsSelected 
    and (type(unitsSelected) == 'table') then
    
        --# Put entity Ids of the units selected
        --# into a new table because the UserUnit references
        --# themselves cannot be marshalled and sent 
        --# to the Sim side.
        local unitEntityIdListArg = {} 
        for unusedArrayIndex, vUnit in unitsSelected do
            table.insert(unitEntityIdListArg, vUnit:GetEntityId())
        end
        
        --# If any units were selected ...
        if (table.getsize(unitsSelected) > 0) then
            --# Invoke sim side code on the unit list.
            SimCallback( 
              {  
                Func='ToggleEntityDisplay',
                Args={ 
                    UnitEntityIdList = unitEntityIdListArg,
                }
              }
            )
        end
    end
    
end