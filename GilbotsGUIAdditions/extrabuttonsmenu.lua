--#****************************************************************************
--#**
--#**  New File:  /mods/gilbotsGUIadditions/extrabuttonsmenu.lua
--#**
--#**  Modded By:  Gilbot-X, based on code from Goom
--#**
--#**  Summary  :  Extra GUI for autotoggle priority order changes
--#**
--#****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Group = import('/lua/maui/group.lua').Group
local Button = import('/lua/maui/button.lua').Button
local ToolTip = import('/lua/ui/game/tooltip.lua')
local Grid = import('/lua/maui/grid.lua').Grid

local ATConfigWindowFile = import('/mods/gilbotsGUIadditions/autotoggleconfigwindow.lua')
local NextToUnitDisplay = import('/mods/GilbotsModPackCore/lua/nexttounitdisplaymanager.lua')
local buttonGroup = false
local SCUManager = import('/mods/GilbotsGoomGUI/modules/scumanager.lua')


--#*
--#*  Gilbot-X says:  
--#*
--#*  Put tooltips here with names that match
--#*  for buttons that sit behind the avatars
--#**
local TooltipInfo = {
	AutoToggle = {
		title = 'Auto Toggle',
		description = 'Left-click to change settings for this unit.  Right-click toggles display.',
	},
    SliderControls = {
		title = 'Slider Controls',
		description = 'Left-click to open any slider controls available on this unit.',
	},
    Combat = {
		title = 'Combat Upgrade Path',
		description = 'Upgrades all idle unupgraded SCUs along the combat path. Right click to configure (select an SCU first!).',
	},
	Engineer = {
		title = 'Engineer Upgrade Path',
		description = 'Upgrades all idle unupgraded SCUs along the engineer path. Right click to configure (select an SCU first!).',
	},
}


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function is a handler for the 
--#*  Mousenter and MouseExit events and is
--#*  common to all these buttons.
--#**
local function HandleToolTipEvents(self, event)
    if event.Type == 'MouseEnter' then
        if not self.tooltip then
            self.tooltip = ToolTip.CreateExtendedToolTip(self, TooltipInfo[self.Name].title, TooltipInfo[self.Name].description)
            LayoutHelpers.LeftOf(self.tooltip, self)
            self.tooltip:SetAlpha(0, true)
            self.tooltip:SetNeedsFrameUpdate(true)
            self.tooltip.OnFrame = function(self, deltaTime)
                self:SetAlpha(math.min(self:GetAlpha() + (deltaTime * 3), 1), true)
                if self:GetAlpha() == 1 then
                    self:SetNeedsFrameUpdate(false)
                end
            end
        end
    elseif event.Type == 'MouseExit' then
        if self.tooltip then
            self.tooltip:Destroy()
            self.tooltip = nil
        end
    end
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  These functions are handlers for the 
--#*  buttons that sits behind the avatars
--#**
local ButtonEventHandlers = {

    AutoToggle = function (self, event)
        HandleToolTipEvents(self, event)
        if event.Type == 'ButtonPress' then
            if event.Modifiers.Left then
                --# This is a state safe  call, 
                --# i.e. safe to be called multiple times
                ATConfigWindowFile.OpenATConfigWindow()
            elseif event.Modifiers.Right then
                NextToUnitDisplay.ToggleDisplay("AutoToggleDisplay")
            end
        end
    end,

    SliderControls = function (self, event)
        HandleToolTipEvents(self, event)
        if event.Type == 'ButtonPress' then
            if event.Modifiers.Left then
                --# This is a state safe  call, 
                --# i.e. safe to be called multiple times
                import("/mods/GilbotsModPackCore/lua/userinterfacemappings.lua").ToggleStatSliderMenu()
            end
        end
    end,
    
    Combat = function (self, event)
        HandleToolTipEvents(self, event)
        if event.Type == 'ButtonPress' then
            if event.Modifiers.Left then
                SCUManager.ApplyUpgrades(self.Name)
            elseif event.Modifiers.Right then
                SCUManager.OpenSCUConfigWindow()
            end
        end
    end,
    
    Engineer = function (self, event)
        HandleToolTipEvents(self, event)
        if event.Type == 'ButtonPress' then
            if event.Modifiers.Left then
                SCUManager.ApplyUpgrades(self.Name)
            elseif event.Modifiers.Right then
                SCUManager.OpenSCUConfigWindow()
            end
        end
    end,
}


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function adds a button to the 
--#*  group of buttons that sits behind the avatars
--#**
function AddButton(arg)
    --# Perform safety
    if not buttonGroup then return end
    
    --# This will be the button we add
    local button = false
    
    --# If we are adding the AT button:
    if arg == 'AutoToggle' then
        button = UIUtil.CreateButtonStd(buttonGroup, 'Gilbot/square20', 'AT', 10)
        button.Name = arg
        button.HandleEvent = ButtonEventHandlers[arg]
    end
    
    --# If we are adding the SL button:
    if arg == 'SliderControls' then
        button = UIUtil.CreateButtonStd(buttonGroup, 'Gilbot/square20', 'SL', 10)
        button.Name = arg
        button.HandleEvent = ButtonEventHandlers[arg]
    end
    
    --# If we are adding the SCU combat upgrade path button:
    if arg == 'Combat' then
        button = Button(buttonGroup, 
            UIUtil.UIFile('scumanager/combat_up.dds', true), 
            UIUtil.UIFile('scumanager/combat_down.dds', true), 
            UIUtil.UIFile('scumanager/combat_over.dds', true), 
            UIUtil.UIFile('scumanager/combat_up.dds', true), 
            "UI_Menu_MouseDown_Sml", 
            "UI_Menu_MouseDown_Sml"
        )
        button.Name = arg
        button.HandleEvent = ButtonEventHandlers[arg]
    end
    
    --# If we are adding the SCU Engineer upgrade path button:
    if arg == 'Engineer' then
        button = Button(buttonGroup, 
            UIUtil.UIFile('scumanager/engineer_up.dds', true), 
            UIUtil.UIFile('scumanager/engineer_down.dds', true), 
            UIUtil.UIFile('scumanager/engineer_over.dds', true), 
            UIUtil.UIFile('scumanager/engineer_up.dds', true), 
            "UI_Menu_MouseDown_Sml", 
            "UI_Menu_MouseDown_Sml"
        )
        button.Name = arg
        button.HandleEvent = ButtonEventHandlers[arg]
    end
    
	--# Add the requested button 
    --# if the argument was good
    if button then
        --# Is this the first button in the group?
        local lastButtonIndex = table.getsize(buttonGroup.GilbotAddedButtons)
        if lastButtonIndex > 0 then 
            --# It isnt so put new button below last
            local lastButton = buttonGroup.GilbotAddedButtons[lastButtonIndex]
            LayoutHelpers.Below(button, lastButton)
        else
            --# First button.
            LayoutHelpers.AtRightTopIn(button, buttonGroup)
        end
        --# Keep a record so we can delete it when selection changes.
        table.insert(buttonGroup.GilbotAddedButtons, button)
    end
end





--#*
--#*  Gilbot-X says:  
--#*
--#*  This function is called once by CreateUI 
--#*  in gamemain.lua.  It initialises this part of the UI.
--#**
function Init()
	--create the button container
	buttonGroup = Group(GetFrame(0))
	LayoutHelpers.AtRightTopIn(buttonGroup, GetFrame(0))
	buttonGroup.Height:Set(10)
	buttonGroup.Width:Set(10)
	buttonGroup.Depth:Set(500)
	buttonGroup:DisableHitTest()
    --# We will store references to 
    --# buttons added to it here later
    buttonGroup.GilbotAddedButtons = {}
    --# Move it to underneath the collapse button of the avatars tab
    local avatarControls = import('/lua/ui/game/avatars.lua').controls
    buttonGroup.Right:Set(function() return avatarControls.collapseArrow.Right() - 2 end)
    buttonGroup.Top:Set(function() return avatarControls.collapseArrow.Bottom() end)
end


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function removes all buttons from the 
--#*  group of buttons that sit behind the avatars
--#**
function ClearButtons()
    --# Perform safety
    if not buttonGroup then return end
	--# Clear the button container
    for k, vButton in buttonGroup.GilbotAddedButtons do
        vButton:Destroy()
    end
	buttonGroup.GilbotAddedButtons = {}
    --# Close any window opened by AT button.  
    --# This is a state safe  call, 
    --# i.e. safe to be called multiple times
    ATConfigWindowFile.CloseATConfigWindow()
end


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function removes all buttons from the 
--#*  group of buttons that sit behind the avatars
--#**
function HasButton(arg)
    --# Perform safety
    if not buttonGroup then return end
	--# Clear the button container
    for k, vButton in buttonGroup.GilbotAddedButtons do
        if arg == vButton.Name then return true end
    end
	return false
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This function removes all buttons from the 
--#*  group of buttons that sit behind the avatars
--#**
function RemoveButton(arg)
    --# Perform safety
    if not buttonGroup then return end
	--# This is an efficient way of 
    --# removing the item from the table
    --# and calling destroy on it
    local newTable = {}
    for k, vButton in buttonGroup.GilbotAddedButtons do
        if arg == vButton.Name then 
            vButton:Destroy()
        else
            --# Put it in the new table
            table.insert(newTable, vButton)
        end
    end
    --# Point to new table that doesn't 
    --# have the button we just removed
	buttonGroup.GilbotAddedButtons = newTable
end



--[[
--#*
--#*  Gilbot-X says:  
--#*
--#*  This function is an alternative to 
--#*  the version provided in uiutil.lua
--#*  which is more standardised for my menu
--#**
local function CreateButton(parent, up, down, over, disabled, label, pointSize, textOffsetVert, textOffsetHorz)
    textOffsetVert = textOffsetVert or 0
    textOffsetHorz = textOffsetHorz or 0
    up = SkinnableFile(up)
    down = SkinnableFile(down)
    over = SkinnableFile(over)
    disabled = SkinnableFile(disabled)

    local button = Button(parent, up, down, over, disabled, "UI_Menu_MouseDown_Sml", "UI_Menu_Rollover_Sml")
    button:UseAlphaHitTest(true)

    if label and pointSize then
        button.label = UIUtil.CreateText(button, label, pointSize)
        LayoutHelpers.AtCenterIn(button.label, button, textOffsetVert, textOffsetHorz)
        button.label:DisableHitTest()
        button.label.

        -- if text exists, set up to grey it out
        button.OnDisable = function(self)
            Button.OnDisable(self)
            button.label:SetColor(UIUtil.disabledColor)
        end

        button.OnEnable = function(self)
            Button.OnEnable(self)
            button.label:SetColor(UIUtil.fontColor)
        end
        button.OnRolloverEvent = function(self, event)
            if event == 'enter' then
                button.label:SetColor(UIUtil.fontOverColor)
            elseif event == 'exit' then
                button.label:SetColor(UIUtil.fontColor)
            elseif event == 'down' then
                button.label:SetColor(UIUtil.fontDownColor)
            end
        end
    end
    return button
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This function is an alternative to 
--#*  the version provided in uiutil.lua
--#*  which is more standardised for my menu
--#**
local function CreateButtonStd(parent, filename, label, pointSize, textOffsetVert, textOffsetHorz)
    return CreateButton(parent
        , filename .. "_btn_up.dds"
        , filename .. "_btn_down.dds"
        , filename .. "_btn_over.dds"
        , filename .. "_btn_dis.dds"
        , label
        , pointSize
        , textOffsetVert
        , textOffsetHorz
        )
end
--]]
