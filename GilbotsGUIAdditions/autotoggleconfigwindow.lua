--#****************************************************************************
--#**
--#**  New File:  /mods/gilbotsGUIadditions/autotoggleconfigwindow.lua
--#**
--#**  Modded By:  Gilbot-X, based on code from Goom
--#**
--#**  Summary  :  Extra GUI for autotoggle priority order changes
--#**
--#****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Button = import('/lua/maui/button.lua').Button
local Grid = import('/lua/maui/grid.lua').Grid
local Combo = import('/lua/ui/controls/combo.lua').Combo

local ToggleDisplay = 
    import('/mods/GilbotsModPackCore/lua/nexttounitdisplaymanager.lua').ToggleDisplay
local SCUManager = 
    import('/mods/GilbotsGoomGUI/modules/scumanager.lua')

--#*
--#*  Gilbot-X says:  
--#*
--#*  The 9 toggle buttons from orders.lua
--#*  that respond to SetScriptBit and GetScriptBit
--#**	
local Toggles = { 
    Shield =        { Name = 'RULEUTC_ShieldToggle',       helpText = "toggle_shield",          bitmapId = 'shield',              bit= 0},
    Weapon =        { Name = 'RULEUTC_WeaponToggle',       helpText = "toggle_weapon",          bitmapId = 'toggle-weapon',       bit= 1},    
    Jamming =       { Name = 'RULEUTC_JammingToggle',      helpText = "toggle_jamming",         bitmapId = 'jamming',             bit= 2},
    Intel =         { Name = 'RULEUTC_IntelToggle',        helpText = "toggle_intel",           bitmapId = 'intel',               bit= 3},
    Production =    { Name = 'RULEUTC_ProductionToggle',   helpText = "toggle_production",      bitmapId = 'production',          bit= 4},
    Stealth =       { Name = 'RULEUTC_StealthToggle',      helpText = "toggle_stealth",         bitmapId = 'stealth',             bit= 5},
    Generic =       { Name = 'RULEUTC_GenericToggle',      helpText = "toggle_generic",         bitmapId = 'production',          bit= 6},
    Special =       { Name = 'RULEUTC_SpecialToggle',      helpText = "toggle_special",         bitmapId = 'activate-weapon',     bit= 7},
    Cloak =         { Name = 'RULEUTC_CloakToggle',        helpText = "toggle_cloak",           bitmapId = 'intel-counter',       bit= 8},
    Construction =  { Name = nil,                          helpText = nil,                      bitmapId = 'production',          bit= 9},
}

--# Local variables used in more
--# than one instance of a function call
local SelectedButton = nil
local MenuTargetUnitEntityId = nil
local TargetUnit = nil
local ATConfigWindow = nil
local ControlsToUpdate = {
    Combo = false,
    Label = false,
    TypeLabel = false,
    MinusButton = false,
    PlusButton = false,
    MinusMinusButton = false,
    PlusPlusButton = false,
    IsRegisteredCheckBox = false,
    OrderButtons = {},
}


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function created the configuration window
--#*  for the selected auto-toggle unit.
--#**
local function UpdateControls()
    
    --# Wait a bit before 
    --# doing first update
    WaitSeconds(0.2)
    
    while ATConfigWindow and MenuTargetUnitEntityId 
        and not TargetUnit:IsDead() do 
        
        --# Update our information about this unit so we know about 
        --# any relevant changes made in the last second.        
        local syncData = UnitData[MenuTargetUnitEntityId].AutoToggleEntries[SelectedButton]
  
        --# so set the check according to unit state
        if syncData.IsInAutoTogglePriorityList and 
            not ControlsToUpdate.IsRegisteredCheckBox:IsChecked() 
        then 
            ControlsToUpdate.IsRegisteredCheckBox:SetCheck(true, true)
        end
        
        --# so set the check according to unit state
        if (not syncData.IsInAutoTogglePriorityList) and 
            ControlsToUpdate.IsRegisteredCheckBox:IsChecked() 
        then 
            ControlsToUpdate.IsRegisteredCheckBox:SetCheck(false, true) 
        end
    
        --# Update combox with new C=? value
        ControlsToUpdate.Combo:SetItem(syncData.PriorityCategory)
        --# Update label with new P=? value
         
        if syncData.PriorityListPosition == 0 
        then 
            ControlsToUpdate.MinusButton:Hide()
            ControlsToUpdate.PlusButton:Hide()
            ControlsToUpdate.MinusMinusButton:Hide()
            ControlsToUpdate.PlusPlusButton:Hide()
            --# The text takes up larger area
            ControlsToUpdate.Label.Width:Set(150)
            ControlsToUpdate.Label:SetText("AT will not pause " .. SelectedButton) 
        else 
            --# The text takes up smaller area 
            ControlsToUpdate.Label.Width:Set(100)
            ControlsToUpdate.Label:SetText("    Priority = " .. repr(syncData.PriorityListPosition)) 
            ControlsToUpdate.MinusButton:Show()
            ControlsToUpdate.PlusButton:Show()
            ControlsToUpdate.MinusMinusButton:Show()
            ControlsToUpdate.PlusPlusButton:Show()
        end
        

        --# Low update frequency
        --# should be adequate
        WaitSeconds(1)
    end
    
    --# If the unit died, 
    --# we close the menu here
    CloseATConfigWindow()
    
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This function is called before 
--#*  opening a conflicting window
--#**
function IsWindowOpen()
    if ATConfigWindow 
    then return true 
    else return false 
    end
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This function created the configuration window
--#*  for the selected auto-toggle unit.
--#**
function CloseATConfigWindow()
    --# Make the local variables safe
    SelectedButton = nil
    MenuTargetUnitEntityId = nil
    TargetUnit = nil
    ControlsToUpdate.OrderButtons = {}
    
    --# Close the window
    if ATConfigWindow then 
        ATConfigWindow:Destroy() 
        ATConfigWindow = nil
        --# Turn off display
        ToggleDisplay("AutoToggleDisplay", 'OFF')
    end
end
    
    
--#*
--#*  Gilbot-X says:  
--#*
--#*  This function created the configuration window
--#*  for the selected auto-toggle unit.
--#**
function OpenATConfigWindow()
    
    --# Prevent duplicate windows
    if ATConfigWindow or SCUManager.IsWindowOpen() then return end
    
    --# Make sure the display is on
    ToggleDisplay("AutoToggleDisplay", 'ON')
    
    --# Set up window invariants
	ATConfigWindow = Bitmap(GetFrame(0))
	ATConfigWindow:SetTexture('/mods/textures/Gilbot/configwindow3.dds')
	LayoutHelpers.AtRightTopIn(ATConfigWindow, GetFrame(0), 100, 100)
	ATConfigWindow.Depth:Set(1000)
	local buttonGrid = Grid(ATConfigWindow, 48, 48)
	LayoutHelpers.AtLeftTopIn(buttonGrid, ATConfigWindow, 10, 30)
	buttonGrid.Right:Set(function() return ATConfigWindow.Right() - 10 end)
	buttonGrid.Bottom:Set(function() return ATConfigWindow.Bottom() - 32 end)
	buttonGrid.Depth:Set(ATConfigWindow.Depth() + 10)

    --# Set local variable used in other 
    --# functions defined in this file
    --# Get data from unit
    TargetUnit = GetSelectedUnits()[1]
    MenuTargetUnitEntityId = TargetUnit:GetEntityId()
  	local unitBp = TargetUnit:GetBlueprint()
    local tempAvailableButtons = {}
    
    --#
    --#  Get data from Sync
    --#
    local syncATEntryList = UnitData[MenuTargetUnitEntityId].AutoToggleEntries
    for kResourceDrainId, vAutoToggleEntry in syncATEntryList do
        --# Set local variable used in other 
        --# functions defined in this file
        if not SelectedButton then SelectedButton = kResourceDrainId end
        --# Populate button data table
        local buttonData = {
            EntityId = MenuTargetUnitEntityId,
            ResourceDrainId = kResourceDrainId,
        }
        tempAvailableButtons[kResourceDrainId] = buttonData
    end
    
    --#
    --#  Make AT On/Off button
    --#
    ControlsToUpdate.IsRegisteredCheckBox = UIUtil.CreateCheckboxStd(ATConfigWindow, 'Gilbot/square20')
    ControlsToUpdate.IsRegisteredCheckBox.label = UIUtil.CreateText(ControlsToUpdate.IsRegisteredCheckBox, "ON", 10)
    LayoutHelpers.AtCenterIn(ControlsToUpdate.IsRegisteredCheckBox.label, ControlsToUpdate.IsRegisteredCheckBox, 0, 0)
    ControlsToUpdate.IsRegisteredCheckBox.label:DisableHitTest()
    ControlsToUpdate.IsRegisteredCheckBox.OnRolloverEvent = function(self, event)
        if event == 'enter' then
            self.label:SetColor(UIUtil.fontOverColor)
        elseif event == 'exit' then
            self.label:SetColor(UIUtil.fontColor)
        elseif event == 'down' then
            self.label:SetColor(UIUtil.fontDownColor)
        end
    end
    LayoutHelpers.AtLeftTopIn(ControlsToUpdate.IsRegisteredCheckBox, ATConfigWindow, 6, 6)
	ControlsToUpdate.IsRegisteredCheckBox.OnCheck = function(self, checked)
        if checked then
            --# Invoke sim side code to add this 
            --# enhancement to the unit's enhancement queue
            SimCallback( 
              {  
                Func='DisableAutoToggle',
                Args={ 
                  SelectedUnitEntityId= MenuTargetUnitEntityId,
                  ResourceDrainId = SelectedButton,
                  DisableToggle = false,
                }
              }
            )
        else
            --# Invoke sim side code to add this 
            --# enhancement to the unit's enhancement queue
            SimCallback( 
              {  
                Func='DisableAutoToggle',
                Args={ 
                  SelectedUnitEntityId= MenuTargetUnitEntityId,
                  ResourceDrainId = SelectedButton,
                  DisableToggle = true,
                }
              }
            )
        end
    end
 
    --#
    --#  Make Class (C=1, C=2, ..) combobox
    --#
	ControlsToUpdate.Combo = Combo(ATConfigWindow, 12, 6, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
    LayoutHelpers.AtLeftTopIn(ControlsToUpdate.Combo, ATConfigWindow, 30, 6) -- 30=6+20+4
	ControlsToUpdate.Combo.Width:Set(80)
	ControlsToUpdate.Combo:AddItems({'C=1', 'C=2', 'C=3', 'C=4', 'C=5', 'C=6'})
	ControlsToUpdate.Combo:SetItem(syncATEntryList[SelectedButton].PriorityCategory)
    ControlsToUpdate.Combo.OnClick = function(self, index, text)
        --# Invoke sim side code to add this 
        --# enhancement to the unit's enhancement queue
        SimCallback( 
          {  
            Func='SetAutoTogglePriorityClass',
            Args={ 
              SelectedUnitEntityId= MenuTargetUnitEntityId,
              ResourceDrainId = SelectedButton,
              NewClass = index,
            }
          }
        )
	end
    
    --#
    --#  Make Priority Label
    --#
    ControlsToUpdate.Label = UIUtil.CreateText(ATConfigWindow, "    Priority = ", 11)
    ControlsToUpdate.Label.Width:Set(100)
	LayoutHelpers.AtLeftTopIn(ControlsToUpdate.Label, ATConfigWindow, 120, 9) -- 120=30+80+10
    
    --#
    --#  Make Priority Minus button
    --#
	ControlsToUpdate.MinusButton = UIUtil.CreateButtonStd(ATConfigWindow, 'Gilbot/square20', '-', 14)
    LayoutHelpers.AtLeftTopIn(ControlsToUpdate.MinusButton, ATConfigWindow, 230, 6) --210=120+100+10
	ControlsToUpdate.MinusButton.OnClick = function(self)
		SimCallback( 
          {  
            Func='DecreaseAutoTogglePriority',
            Args={ 
              SelectedUnitEntityId= MenuTargetUnitEntityId,
              ResourceDrainId = SelectedButton,
            }
          }
        )
    end
    
    --#
    --#  Make Priority Plus button
    --#
	ControlsToUpdate.PlusButton = UIUtil.CreateButtonStd(ATConfigWindow, 'Gilbot/square20', '+', 14)
	LayoutHelpers.RightOf(ControlsToUpdate.PlusButton, ControlsToUpdate.MinusButton)
	ControlsToUpdate.PlusButton.OnClick = function(self)
		SimCallback( 
          {  
            Func='IncreaseAutoTogglePriority',
            Args={ 
              SelectedUnitEntityId= MenuTargetUnitEntityId,
              ResourceDrainId = SelectedButton,
            }
          }
        )
	end
        
    --#
    --#  Make 'Priority To Fisrt' Button
    --#
	ControlsToUpdate.MinusMinusButton = UIUtil.CreateButtonStd(ATConfigWindow, 'Gilbot/square20', '--', 14)
	LayoutHelpers.RightOf(ControlsToUpdate.MinusMinusButton, ControlsToUpdate.PlusButton)
    ControlsToUpdate.MinusMinusButton.OnClick = function(self)
		SimCallback( 
          {  
            Func='SetPriorityToFirstOrLastInClass',
            Args={ 
              SelectedUnitEntityId= MenuTargetUnitEntityId,
              ResourceDrainId = SelectedButton,
              Placement = 'FIRST',
            }
          }
        )
	end
    
    --#
    --#  Make 'Priority To Last' Button
    --#
	ControlsToUpdate.PlusPlusButton = UIUtil.CreateButtonStd(ATConfigWindow, 'Gilbot/square20', '++', 14)
	LayoutHelpers.RightOf(ControlsToUpdate.PlusPlusButton, ControlsToUpdate.MinusMinusButton)
    ControlsToUpdate.PlusPlusButton.OnClick = function(self)
		SimCallback( 
          {  
            Func='SetPriorityToFirstOrLastInClass',
            Args={ 
              SelectedUnitEntityId= MenuTargetUnitEntityId,
              ResourceDrainId = SelectedButton,
              Placement = 'LAST',
            }
          }
        )
	end
    
    
    --#
    --#  Order buttons 
    --#
    --#  Array of buttons for each things we can autotoggle
    --#
    buttonGrid:DeleteAndDestroyAll(true)
	local visCols, visRows = buttonGrid:GetVisible()
	local currentRow = 1
	local currentCol = 1
	buttonGrid:AppendCols(visCols, true)
	buttonGrid:AppendRows(1, true)
	local index = 0
	for kResourceDrainId, vButtonData in tempAvailableButtons do
		local button = CreateOrderButton(buttonGrid, 46, buttonGrid, vButtonData)
		buttonGrid:SetItem(button, currentCol, currentRow, true)
		if currentCol < visCols then
			currentCol = currentCol + 1
		else
			currentCol = 1
			currentRow = currentRow + 1
			buttonGrid:AppendRows(1, true)
		end
        if kResourceDrainId == SelectedButton then
            button:SetCheck(true)
        end
        ControlsToUpdate.OrderButtons[kResourceDrainId] = button
	end
	buttonGrid:EndBatch()
    
    
    
    --#
    --#  Make ResourceDrainId Label
    --#
    ControlsToUpdate.TypeLabel = UIUtil.CreateText(ATConfigWindow, SelectedButton, 14)
    ControlsToUpdate.TypeLabel.Width:Set(150)
	LayoutHelpers.AtLeftTopIn(ControlsToUpdate.TypeLabel, ATConfigWindow, 20, 132)

    --#
    --#  OK button that just closes window
    --#
	local okButton = UIUtil.CreateButtonStd(ATConfigWindow, '/widgets/small', 'OK', 16)
	LayoutHelpers.AtLeftTopIn(okButton, ATConfigWindow, 160, 123)
	okButton.OnClick = function(self)
		--# This will also cause 
        --# update thread to end
        --# after next update
        CloseATConfigWindow()
	end
    
    --# Use a thread to update 
    --# this menu continually, as
    --# the building of other unit in
    --# background will change P numbers.
    ForkThread(UpdateControls)
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This was copied straight from orders.lua
--#*  as it is also a local function there.
--#**	
local function GetOrderBitmapNames(resourceDrainId)

    local bitmapId = Toggles[resourceDrainId].bitmapId
    if not bitmapId then
        LOG("Error - No bitmap for " .. resourceDrainId 
        .. " passed to GetOrderBitmapNames.")
        bitmapId = "basic-empty"   
    end
    
    local button_prefix = "/game/orders/" .. bitmapId .. "_btn_"
    return {
        up      = UIUtil.SkinnableFile(button_prefix .. "up.dds"),
        upsel   = UIUtil.SkinnableFile(button_prefix .. "up_sel.dds"),
        over    = UIUtil.SkinnableFile(button_prefix .. "over.dds"),
        oversel = UIUtil.SkinnableFile(button_prefix .. "over_sel.dds"),
        dis     = UIUtil.SkinnableFile(button_prefix .. "dis.dds"),
        dissel  = UIUtil.SkinnableFile(button_prefix .. "dis_sel.dds")
    }
end


--#*
--#*  Gilbot-X says:  
--#*
--#*  This is based on the version in orders.lua
--#*  but I make it work like a radio button.
--#**	
function CreateOrderButton(parent, size, buttonGrid, buttonData)

    local texturePaths = GetOrderBitmapNames(buttonData.ResourceDrainId)
    local checkBox = nil
    
    if buttonData.ResourceDrainId == 'Shield' then 
        checkBox = Checkbox(parent, 
            texturePaths.up,
            texturePaths.upsel,
            texturePaths.over,
            texturePaths.oversel,
            texturePaths.dis,
            texturePaths.dissel,
            "UI_Action_MouseDown", 
            "UI_Action_Rollover"
            )
    else
        checkBox = Checkbox(parent, 
            texturePaths.upsel,
            texturePaths.up,
            texturePaths.oversel,
            texturePaths.over,
            texturePaths.dissel,
            texturePaths.dis,
            "UI_Action_MouseDown", 
            "UI_Action_Rollover"
            )
    end
          
    checkBox.data = buttonData         
    checkBox.Width:Set(size)
    checkBox.Height:Set(size)

    checkBox.HandleEvent = function(self, event)
        if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
            --# Change which AT entry is affected by 
            --# the controls at the top.
            SelectedButton = self.data.ResourceDrainId
            self:SetCheck(true)
            ControlsToUpdate.TypeLabel:SetText(SelectedButton)
            
            --# Give radio Button behaviour
            for kResourceDrainId, vCheckBox in ControlsToUpdate.OrderButtons do
                if kResourceDrainId ~= SelectedButton then
                    vCheckBox:SetCheck(false)
                end
            end
        else
            Checkbox.HandleEvent(self, event)
        end
    end
    
    return checkBox
end