local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local Button = import('/lua/maui/button.lua').Button
local ToolTip = import('/lua/ui/game/tooltip.lua')
local Prefs = import('/lua/user/prefs.lua')
local Grid = import('/lua/maui/grid.lua').Grid
local Combo = import('/lua/ui/controls/combo.lua').Combo
local Dragger = import('/lua/maui/dragger.lua').Dragger

--# In my mod, this must be used to give the enhancement order.
local QueueEnhancement = import('/mods/GilbotsModPackCore/lua/enhancementqueue.lua').UserQueueEnhancement
local ATConfigWindowFile = import('/mods/gilbotsGUIadditions/autotoggleconfigwindow.lua')

--# Local variables used in more
--# than one instance of a function call
local SCUManagerWindow = nil
        
--# This contains the defaults for what the 2 upgrade
--# paths are for SCUs in each faction. 
--# This is used if no updtaed settings could be loaded 
--# from file, which is what happens the first time the 
--# SCU manager is used.
local DefaultEnhancementPathTable = {
	UEF = {
		Engineer = {
			{'ResourceAllocation',          'RCH'},
			{'Shield',                     'Back'},
			{'ShieldGeneratorField',       'Back'},
		},
		Combat = {
			{'HighExplosiveOrdnance',       'RCH'},
			{'AdvancedCoolingUpgrade',      'LCH'},
			{'Shield',                     'Back'},
			{'ShieldGeneratorField',       'Back'},
		},
	},
	CYBRAN = {
		Engineer = {
			{'Switchback',                  'LCH'},
			{'ResourceAllocation',          'RCH'},
			{'NaniteMissileSystem',        'Back'},
		},
		Combat = {
			{'FocusConvertor',              'RCH'},
			{'EMPCharge',                   'LCH'},
			{'SelfRepairSystem',           'Back'},
		},
	},
	AEON = {
		Engineer = {
			{'EngineeringFocusingModule',   'LCH'},
			{'ResourceAllocation',          'RCH'},
		},
		Combat = {
			{'StabilitySuppressant',        'RCH'},
			{'Shield',                     'Back'},
			{'ShieldHeavy',                'Back'},
		},
	},
	SERAPHIM = {
		Combat = {
			{'DamageStabilization',         'LCH'},
			{'Missile',                    'Back'},
			{'Overcharge',                  'RCH'},
		},
		Engineer = {
			{'EngineeringThroughput',       'LCH'},
			{'Shield',                     'Back'},
		}
	},
}
--# This will store the data from the table 
--# above but will include changes made by the user 
local CurrentEnhancementPathTable = {}

--# Used at bottom of file
local markerTable = {}


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function is called before 
--#*  opening a conflicting window
--#**
function IsWindowOpen()
    if SCUManagerWindow 
    then return true 
    else return false 
    end
end


--#*
--#*  Gilbot-X:
--#*
--#*  Called in CreateUI function in gamemain.lua.  
--#*  Just initilises this section of GUI.
--#**
function Init()
	--add beat function to display markers
	import('/lua/ui/game/gamemain.lua').AddBeatFunction(ShowMarkers)
	--get the table of upgrades to use from prefs, or use default if prefs isn't available
	CurrentEnhancementPathTable = Prefs.GetFromCurrentProfile("Gilbot_SCU_Manager_settings") or DefaultEnhancementPathTable
end

--#*
--#*  Gilbot-X:
--#*
--#*  Called in 3 places.  In a button handler 
--#*  defined in this function, and twice in LayoutGrid above.
--#*  Return a table of what enhancements are already on the unit.
--#**
local function GetEnhancements(unit)
	local tempEntityID = unit:GetEntityId()
	local existingEnhancements = 
        import('/lua/enhancementcommon.lua').GetEnhancements(tempEntityID)
	return existingEnhancements
end


--#*
--#*  Gilbot-X:
--#*
--#*  Called only by CreateEnhancementButton below.
--#**
local function GetEnhancementPrefix(unitID, iconID)
    local prefix = ''
    if string.sub(unitID, 2, 2) == 'a' then
        prefix = '/game/aeon-enhancements/'..iconID
    elseif string.sub(unitID, 2, 2) == 'e' then
        prefix = '/game/uef-enhancements/'..iconID
    elseif string.sub(unitID, 2, 2) == 'r' then
        prefix = '/game/cybran-enhancements/'..iconID
    elseif string.sub(unitID, 2, 2) == 's' then
        prefix = '/game/seraphim-enhancements/'..iconID
    end
    return prefix
end


--#*
--#*  Gilbot-X:
--#*
--#*  Called in 3 places.  In a button handler 
--#*  defined in this function, and twice in LayoutGrid above.
--#**
local function CreateEnhancementButton(parent, enhancementName, enhancementBpArg, tempSCUBpId, size, faction, scuType, buttonGrid)
    local tempBmpName = ""
    
    --# First argument is needed to determine faction
    tempBmpName = GetEnhancementPrefix(tempSCUBpId, enhancementBpArg.Icon)

    local button = false
	if( string.find( enhancementName, 'Remove' ) ) then
        --# Create this button inverse of other
        button = Button(parent,
            --# UIFile will look in /textures/ui/common 
            --# + prefix and name.
            UIUtil.UIFile(tempBmpName .. '_btn_sel.dds'),
            UIUtil.UIFile(tempBmpName .. '_btn_over.dds'),
            UIUtil.UIFile(tempBmpName .. '_btn_down.dds'),
            UIUtil.UIFile(tempBmpName .. '_btn_up.dds'),
            "UI_Enhancements_Click", "UI_Enhancements_Rollover")
    else
        button = Button(parent,
            --# UIFile will look in /textures/ui/common 
            --# + prefix and name.
            UIUtil.UIFile(tempBmpName .. '_btn_up.dds'),
            UIUtil.UIFile(tempBmpName .. '_btn_over.dds'),
            UIUtil.UIFile(tempBmpName .. '_btn_down.dds'),
            UIUtil.UIFile(tempBmpName .. '_btn_sel.dds'),
            "UI_Enhancements_Click", "UI_Enhancements_Rollover")
    end
    button.Width:Set(size)
    button.Height:Set(size)

    button.OnClick = function(self, modifiers)
		if size == 46 then
			--# if it's a main button, find the last free 
            --# queue space and add the enhancement to the queue
			local nextfree = false
			for index, space in	parent.QueuedUpgrades do
				if not space.Icon then
					nextfree = index
					break
				end
			end
            --# If there was a space free
            --# to add another enhancement...
			if nextfree then
				parent.QueuedUpgrades[nextfree].Icon = CreateEnhancementButton(parent.QueuedUpgrades[nextfree], enhancementName, enhancementBpArg, tempSCUBpId, 22, faction)
				LayoutHelpers.AtCenterIn(parent.QueuedUpgrades[nextfree].Icon, parent.QueuedUpgrades[nextfree])
				parent.QueuedUpgrades[nextfree].Icon.EnhancementName = enhancementName
                parent.QueuedUpgrades[nextfree].Icon.Slot = enhancementBpArg.Slot
				parent.QueuedUpgrades[nextfree].Icon.Index = nextfree
				CurrentEnhancementPathTable[string.upper(faction)][scuType][nextfree] = {enhancementName, enhancementBpArg.Slot}
			end
		else
			--if not a main button then remove it from the queue and shift all the higher ones down a spot
			CurrentEnhancementPathTable[string.upper(faction)][scuType][parent.Icon.Index] = nil
			local firstnil = false
			parent.Icon:Destroy()
			parent.Icon = false
			for i, v in buttonGrid.QueuedUpgrades do
				if firstnil then
					if v.Icon then
						buttonGrid.QueuedUpgrades[i-1].Icon = buttonGrid.QueuedUpgrades[i].Icon
						buttonGrid.QueuedUpgrades[i-1].Icon.Index = i-1
						CurrentEnhancementPathTable[string.upper(faction)][scuType][i] = nil
						CurrentEnhancementPathTable[string.upper(faction)][scuType][i-1] = {
                            buttonGrid.QueuedUpgrades[i].Icon.EnhancementName, 
                            buttonGrid.QueuedUpgrades[i].Icon.Slot
                        }
						buttonGrid.QueuedUpgrades[i].Icon:Destroy()
						buttonGrid.QueuedUpgrades[i].Icon = false
					end
				end
				if not v.Icon then
					firstnil = true
				end
			end
		end
		LayoutGrid(buttonGrid, faction, scuType)
    end

	--if there's a selection then show info for the enhancement
	local testUnit = GetSelectedUnits()
    button.HandleEvent = function(self, event)
		if testUnit then
	        if event.Type == 'MouseEnter' then
	            import('/lua/ui/game/unitviewDetail.lua').ShowEnhancement(
                    enhancementBpArg, 
                    tempSCUBpId, 
                    enhancementBpArg.Icon, 
                    GetEnhancementPrefix(tempSCUBpId, enhancementBpArg.Icon), 
                    testUnit[1]
                )
	        end
		end
		if event.Type == 'MouseExit' then
			import('/lua/ui/game/unitviewDetail.lua').Hide()
		end
        Button.HandleEvent(self, event)
    end
    button:UseAlphaHitTest(false)

    return button
end


--#*
--#*  Gilbot-X:
--#*
--#*  Called in OpenSCUConfigWindow and in a button handler 
--#*  defined in CreateEnhancementButton.
--#*  It populates the "Confgure Upgrades path" windpow.
--#*  Shows available and current enhancements for an scu type
--#*  and allows user to configure the upgrade paths
--#**
function LayoutGrid(buttonGrid, faction, scuType)
	--# Get the enhancements available to whichever scu is being edited
	local tempSCUBpId = 'ual0301'
	if faction == 'Cybran' then
		tempSCUBpId = 'url0301'
	elseif faction == 'UEF' then
		tempSCUBpId = 'uel0301'
	elseif faction == 'Seraphim' then
		tempSCUBpId = 'xsl0301'
	end
	local bp = __blueprints[tempSCUBpId]
	local availableEnhancements = bp["Enhancements"]

	--# Clear the current enhancements, and add the new ones
	for positionInEnhancementPath, vBitmap in buttonGrid.QueuedUpgrades do
        --# If there was an icon set
        --# in this box,
		if vBitmap.Icon then
            --# Destroy it
			vBitmap.Icon:Destroy()
			vBitmap.Icon = false
		end
        
        --# If anything is selected for this index in the upgrade path
		if CurrentEnhancementPathTable[string.upper(faction)][scuType][positionInEnhancementPath] then
			local entry = CurrentEnhancementPathTable[string.upper(faction)][scuType][positionInEnhancementPath]
            local enhancementName = entry[1]
			vBitmap.Icon = CreateEnhancementButton(vBitmap, enhancementName, availableEnhancements[enhancementName], tempSCUBpId, 22, faction, scuType, buttonGrid)
			vBitmap.Icon.EnhancementName = enhancementName
            vBitmap.Icon.Slot= entry[2]
			vBitmap.Icon.Index = positionInEnhancementPath
			LayoutHelpers.AtCenterIn(vBitmap.Icon, vBitmap)
		end
	end

	--# Make a table of available enhancements, 
    --# not showing any that are already in the enhancement path, 
    --# or any that need a prerequisite that isn't in already added to the path, 
    --# or any that can't be added because the slot is already full.
	--# First, empty out what was there before.
    buttonGrid:DeleteAndDestroyAll(true)
	local visCols, visRows = buttonGrid:GetVisible()
	local currentRow = 1
	local currentCol = 1
	buttonGrid:AppendCols(visCols, true)
	buttonGrid:AppendRows(1, true)
    
	local index = 0
	local tempAvailableButtons = {}
	for enhName, enhBP in availableEnhancements do
		local alreadyOwns = false
        --# Make sure it's not already 
        --# selected for the upgrade path.
		for i, v in buttonGrid.QueuedUpgrades do
			if v.Icon.EnhancementName then
				if v.Icon.EnhancementName == enhName then
					alreadyOwns = true
				end
			end
		end
        --# It's not already selected, so proceed
		if not alreadyOwns then
            --# If this is not a 'Remove' enhancement, proceed
			if enhBP['Slot'] and not string.find(enhName, 'Remove') then
				--# Check prerequisites
                if enhBP['Prerequisite'] then
					for i, v in buttonGrid.QueuedUpgrades do
						if v.Icon.EnhancementName then
							--# If we have added the prerequisite...
                            if v.Icon.EnhancementName == enhBP['Prerequisite'] then
                                --# Then we can add this to the upgrade path.
								table.insert(tempAvailableButtons, {Name = enhName, Enhancement = enhBP})
							end
						end
					end
				else
                    --# There was no prerequisite, 
                    --# so it needs an empty slot.
					local slotUsed = false
					for i, v in buttonGrid.QueuedUpgrades do
						if v.Icon.EnhancementName then
							if availableEnhancements[v.Icon.EnhancementName].Slot == enhBP['Slot'] then
								slotUsed = true
							end
						end
					end
					if not slotUsed then
                        --# The slot was empty, so add this into it.
						table.insert(tempAvailableButtons, {Name = enhName, EnhancementBP = enhBP})
					end
				end
			end
		end
	end
    --# Sort the icons in our chosen path according to slot alphabetically, i.e. Back, LCH, RCH...
    --# Then alphabetically by name (this can but icons before their prerequisites)
	table.sort(tempAvailableButtons, function(up1, up2) return (up1.EnhancementBP.Slot .. up1.Name) <= (up2.EnhancementBP.Slot .. up2.Name) end)
    
    --# Go through the icons we put in the table for adding.
    --# Create a large icon for each and put into the grid.
	for _, vEntry in tempAvailableButtons do
		local button = CreateEnhancementButton(buttonGrid, vEntry.Name, vEntry.EnhancementBP, tempSCUBpId, 46, faction, scuType, buttonGrid)
		buttonGrid:SetItem(button, currentCol, currentRow, true)
		if currentCol < visCols then
			currentCol = currentCol + 1
		else
			currentCol = 1
			currentRow = currentRow + 1
			buttonGrid:AppendRows(1, true)
		end
	end
	buttonGrid:EndBatch()
end


--#*
--#*  Gilbot-X:
--#*
--#*  Global function called in GUI button handlers 
--#*  from another file.
--#*  
--#*  It creates the "Configure Upgrades path" window.
--#*  Shows available and current enhancements for an SCU type
--#*  and allows user to configure the upgrade paths
--#**
function CloseSCUConfigWindow()
    CurrentEnhancementPathTable = Prefs.GetFromCurrentProfile("Gilbot_SCU_Manager_settings") or DefaultEnhancementPathTable
    if SCUManagerWindow then 
        SCUManagerWindow:Destroy()
        SCUManagerWindow = nil
    end
end


--#*
--#*  Gilbot-X:
--#*
--#*  Global function called in GUI button handlers 
--#*  from another file.
--#*  
--#*  It creates the "Configure Upgrades path" window.
--#*  Shows available and current enhancements for an SCU type
--#*  and allows user to configure the upgrade paths
--#**
function OpenSCUConfigWindow()
	
    --# Prevent Duplicate window
    if SCUManagerWindow or ATConfigWindowFile.IsWindowOpen()
    then return end
    
    --# Create the wiondow on the upper right of screen
    SCUManagerWindow = Bitmap(GetFrame(0))
	SCUManagerWindow:SetTexture('/mods/GilbotsGoomGUI/textures/scumanager/configwindow.dds')
	LayoutHelpers.AtRightTopIn(SCUManagerWindow, GetFrame(0), 100, 100)
	SCUManagerWindow.Depth:Set(1000)
	
    --# This is where buttonGrid is defined.
    local buttonGrid = Grid(SCUManagerWindow, 48, 48)
	LayoutHelpers.AtLeftTopIn(buttonGrid, SCUManagerWindow, 10, 30)
	buttonGrid.Right:Set(function() return SCUManagerWindow.Right() - 10 end)
	buttonGrid.Bottom:Set(function() return SCUManagerWindow.Bottom() - 32 end)
	buttonGrid.Depth:Set(SCUManagerWindow.Depth() + 10)

    --# Add combo box
	local factionChooserCombo = Combo(SCUManagerWindow, 14, 4, nil, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
	--# with 2 checkbox buttons to its right for choosing upgrade path
	local combatButton = Checkbox(SCUManagerWindow, 
        UIUtil.UIFile('scumanager/combat_up.dds', true), 
        UIUtil.UIFile('scumanager/combat_sel.dds', true),
        UIUtil.UIFile('scumanager/combat_over.dds', true), 
        UIUtil.UIFile('scumanager/combat_over_sel.dds', true),
        UIUtil.UIFile('scumanager/combat_up.dds', true),
        UIUtil.UIFile('scumanager/combat_up.dds', true),
        "UI_Menu_MouseDown_Sml", 
        "UI_Menu_MouseDown_Sml"
    )
	local EngineerButton = Checkbox(SCUManagerWindow, 
        UIUtil.UIFile('scumanager/engineer_up.dds', true),
        UIUtil.UIFile('scumanager/engineer_sel.dds', true),
        UIUtil.UIFile('scumanager/engineer_over.dds', true), 
        UIUtil.UIFile('scumanager/engineer_over_sel.dds', true), 
        UIUtil.UIFile('scumanager/engineer_up.dds', true),
        UIUtil.UIFile('scumanager/engineer_up.dds', true),
        "UI_Menu_MouseDown_Sml", 
        "UI_Menu_MouseDown_Sml"
    )
	combatButton:SetCheck(true)
	--# Format combobox
	LayoutHelpers.AtLeftTopIn(factionChooserCombo, SCUManagerWindow, 6, 6)
	factionChooserCombo.Width:Set(100)
	factionChooserCombo:AddItems({'Aeon', 'Cybran', 'UEF', 'Seraphim'})
	factionChooserCombo.OnClick = function(self, index, text)
		if combatButton:IsChecked() 
		then LayoutGrid(buttonGrid, text, 'Combat')
		else LayoutGrid(buttonGrid, text, 'Engineer')
		end
	end
	--# Format checkboxes
	LayoutHelpers.AtLeftTopIn(combatButton, SCUManagerWindow, 108, 6)
	LayoutHelpers.RightOf(EngineerButton, combatButton)
	combatButton.OnClick = function(self, modifiers)
		EngineerButton:SetCheck(false)
		combatButton:SetCheck(true)
		local index, fact = factionChooserCombo:GetItem()
		LayoutGrid(buttonGrid, fact, 'Combat')
	end
	EngineerButton.OnClick = function(self, modifiers)
		combatButton:SetCheck(false)
		EngineerButton:SetCheck(true)
		local index, fact = factionChooserCombo:GetItem()
		LayoutGrid(buttonGrid, fact, 'Engineer')
	end

	--# This is a list of the (up to 6) bitmaps showing 
    --# which upgrades the scu will recieve in the selected path.
    --# Format the 6 boxes to have little frames.
	buttonGrid.QueuedUpgrades = {}
	for i = 1, 6 do
		local index = i
		buttonGrid.QueuedUpgrades[index] = Bitmap(buttonGrid)
		buttonGrid.QueuedUpgrades[index]:SetTexture('/mods/GilbotsGoomGUI/textures/scumanager/queueborder.dds')
		if index == 1 
		then LayoutHelpers.AtLeftTopIn(buttonGrid.QueuedUpgrades[index], SCUManagerWindow, 150, 4)
		else LayoutHelpers.RightOf(buttonGrid.QueuedUpgrades[index], buttonGrid.QueuedUpgrades[index-1])
		end
	end

    --# Add OK button to close dialog
	local okButton = UIUtil.CreateButtonStd(SCUManagerWindow, '/widgets/small', 'OK', 16)
	LayoutHelpers.AtLeftTopIn(okButton, SCUManagerWindow, 160, 123)
	okButton.OnClick = function(self)
		Prefs.SetToCurrentProfile("Gilbot_SCU_Manager_settings", CurrentEnhancementPathTable)
		Prefs.SavePreferences()
		SCUManagerWindow:Destroy()
        SCUManagerWindow = nil
	end
    --# Add Cancel button to close dialog
	local cancelButton = UIUtil.CreateButtonStd(SCUManagerWindow, '/widgets/small', 'Cancel', 16)
	LayoutHelpers.AtLeftTopIn(cancelButton, SCUManagerWindow, 8, 123)
	cancelButton.OnClick = function(self)
		CurrentEnhancementPathTable = Prefs.GetFromCurrentProfile("Gilbot_SCU_Manager_settings") or DefaultEnhancementPathTable
		SCUManagerWindow:Destroy()
        SCUManagerWindow = nil
	end

    --# If something is selected now, then
    --# set up the window for that faction and refresh.
    --# Aeon is selected in combobox otherwise.
	if GetSelectedUnits() then
		local faction = GetSelectedUnits()[1]:GetBlueprint().General.FactionName
		FactionIndexTable = {Aeon = 1, Cybran = 2, UEF = 3, Seraphim = 4}
		if FactionIndexTable[faction] then
			factionChooserCombo:SetItem(FactionIndexTable[faction])
			LayoutGrid(buttonGrid, faction, 'Combat')
		else
			LayoutGrid(buttonGrid, 'Aeon', 'Combat')
		end
	else
		LayoutGrid(buttonGrid, 'Aeon', 'Combat')
	end
end


--#*
--#*  Gilbot-X:
--#*
--#*  Called in ApplyUpgrades below, and in PlaceMarker 
--#*  and UpgradeSCUAroundPoint, both defined below.
--#*  It creates the "Configure Upgrades path" window.
--#*  Shows available and current enhancements for an SCU type
--#*  and allows user to configure the upgrade paths
--#**
local function GetUnitFaction(unit)
	local faction = false
	if unit:IsInCategory('UEF') then
		return 'UEF'
	elseif unit:IsInCategory('AEON') then
		return 'AEON'
	elseif unit:IsInCategory('CYBRAN') then
		return 'CYBRAN'
	elseif unit:IsInCategory('SERAPHIM') then
		return 'SERAPHIM'
	end
end


--#*
--#*  Gilbot-X:
--#*
--#*  Called in GetIdleSCUsWithoutEnhancements below. 
--#*  It works out if the SCU has completed either
--#*  of the upgrade paths.
--#**
function IsPathComplete(unit, upgType)
    local faction = GetUnitFaction(unit)
	if faction then
		local enhancementPathItems = CurrentEnhancementPathTable[faction][upgType]
		if table.getsize(enhancementPathItems) == 0 then
			return
		end
        local enhancementButtonsSet = GetEnhancements(unit)
        --LOG('IsPathComplete: enhancementPathItems=' .. repr(enhancementPathItems))
		for _, vEntry in enhancementPathItems do
            local targetEnhancementName = vEntry[1]
            local slot = vEntry[2]
            --# If the slot is empty then path is not finished
            local buttonInThisSlot = enhancementButtonsSet[slot]
			if not buttonInThisSlot then return false end
            --# If what we have in the slot matches the item in the path
            --# then we move on to the next item in the path
			if buttonInThisSlot ~= targetEnhancementName then 
                --# Get any Prerequisites for Current Enhancement buton in the slot
                local buttonInThisSlotBP = unit:GetBlueprint().Enhancements[buttonInThisSlot]
                local buttonInThisSlotPreReq1, buttonInThisSlotPreReq2 =  
                    buttonInThisSlotBP.Prerequisite, nil
                --# If there are no prereqs at this stage, then this
                --# button cannot be part of the path.
                if not buttonInThisSlotPreReq1 then return false end
                 --# If the item in the path is a prerequisite of what 
                --# we have in the slot, then we move on to the next item
                if buttonInThisSlotPreReq1 ~= targetEnhancementName then
                    buttonInThisSlotPreReq2 = 
                        unit:GetBlueprint().Enhancements[buttonInThisSlotPreReq1].Prerequisite 
                    --# If the target item is not an indirect prerequisite, or 
                    --# a direct one, or the same one, then the item in the path has 
                    --# not been fulfilled.  The path cannot be complete.
                    if buttonInThisSlotPreReq2 ~= targetEnhancementName then return false end
                end
            end
		end
        --# If we got here, it means that all items
        --# in the upgrade path are either part of 
        --# the unit or they are prerequisites of what the
        --# unit has.  We cannot add anything more from this path.        
        return true
    end
end


--#*
--#*  Gilbot-X:
--#*
--#*  Called in ApplyUpgrades Below.
--#*  Get Idle SCUs without enhancements
--#**
function GetSCUType(unit)
    --# If neither upgarde paths are complete...
    if IsPathComplete(unit, 'Combat') then return 'Combat' end
    if IsPathComplete(unit, 'Engineer') then return 'Engineer' end
    return false    
end
    
    
--#*
--#*  Gilbot-X:
--#*
--#*  Called in ApplyUpgrades Below.
--#*  Get Idle SCUs without enhancements
--#**
function GetIdleSCUsWithoutEnhancements()
	local idleEngineers = GetIdleEngineers()
	if idleEngineers then
		local idleSCUs = EntityCategoryFilterDown(categories.SUBCOMMANDER, idleEngineers)
		local returnTable = {}
		for i, unit in idleSCUs do
            --# If neither upgarde paths are complete...
            if (not IsPathComplete(unit, 'Combat'))
            and (not IsPathComplete(unit, 'Engineer'))
            then
                --# This unit can be classes as eligible.
                table.insert(returnTable, unit)
            end                
		end
		return returnTable
	else
		return false
	end
end



--#*
--#*  Gilbot-X:
--#*
--#*  Called in ApplyUpgrades below, and in PlaceMarker 
--#*  and UpgradeSCUAroundPoint, both defined below.
--#*  It creates the "Configure Upgrades path" window.
--#*  Shows available and current enhancements for an SCU type
--#*  and allows user to configure the upgrade paths
--#**
local function UpgradeSCU(unit, upgType)
	local faction = GetUnitFaction(unit)
	if faction then
		local enhancementPathItems = CurrentEnhancementPathTable[faction][upgType]
		if table.getsize(enhancementPathItems) == 0 then
			return
		end
        --LOG('enhancementPathItems=' .. repr(enhancementPathItems))
		for _, vEntry in enhancementPathItems do
            --LOG('Calling QueueEnhancement on e=' .. unit:GetEntityId()
            --.. ' with Enh=' .. repr(vEntry[1]) 
            --.. ' in slot ' .. repr(vEntry[2])
            --)
            QueueEnhancement(unit, vEntry[1], vEntry[2])
		end
	end
end



--#*
--#*  Gilbot-X:
--#*
--#*  Global function called in GUI button handlers 
--#*  from another file.
--#*  
--#*  Gets a list of idle scus, and then starts 
--#*  the selected upgrade path on them.
--#**
function ApplyUpgrades(type)
	local SCUList = GetIdleSCUsWithoutEnhancements()
	if SCUList then
		for i, v in SCUList do
			UpgradeSCU(v, type)
		end
	end
end





--#################################################################################################
--# AUTOMATIC UPGRADE MARKER FUNCTIONS
--# to stop show/hide being used constantly (may or may not be a bad thing...
local showing = false
--# This is set as a beat function, above
--# to show all active markers
function ShowMarkers()
	if IsKeyDown('Shift') then
		if not showing then
			showing = true
			for i, marker in markerTable do
				marker:Show()
				marker:SetNeedsFrameUpdate(true)
			end
		end
	else
		if showing then
			showing = false
			for i, marker in markerTable do
				marker:Hide()
				marker:SetNeedsFrameUpdate(false)
			end
		end
	end
end

--# Not called in this file.
--create the dialog to choose enhancement marker type
local dialog = false
function CreateMarker()
	local position = GetMouseWorldPos()
	if not dialog then
		dialog = UIUtil.QuickDialog(
            GetFrame(0), 
            'Choose your enhancement type',  
            "Combat", 
            function() 
                PlaceMarker('Combat', position) 
                dialog:Destroy() 
                dialog = false 
            end, 
            "Engineer", 
            function() 
                PlaceMarker('Engineer', position) 
                dialog:Destroy() 
                dialog = false 
            end, nil, nil, false
        )
	end
end

--# called above in CreateMarker.
--# create the marker
local index = 1
function PlaceMarker(upgradeType, position)
	local worldview = import('/lua/ui/game/worldview.lua').viewLeft
	markerTable[index] = Bitmap(GetFrame(0))
	markerTable[index]:SetTexture('/mods/GilbotsGoomGUI/textures/scumanager/'..upgradeType..'_up.dds')
	markerTable[index].Depth:Set(100)
	markerTable[index].Left:Set(100)
	markerTable[index].Top:Set(100)
	markerTable[index].Index = index
	markerTable[index].position = position
	markerTable[index].upgradeType = upgradeType
	--move and destroy code
	markerTable[index].HandleEvent = function(self, event)
		if event.Type == 'ButtonPress' then
			if event.Modifiers.Right and event.Modifiers.Ctrl then
				KillThread(self.checkThread)
				local removeIndex = self.Index
				self:Destroy()
				self = false
				markerTable[removeIndex] = nil
			elseif event.Modifiers.Left then
				self:SetNeedsFrameUpdate(false)
				self.drag = Dragger()
				local moved = false
				GetCursor():SetTexture(UIUtil.GetCursor('MOVE_WINDOW'))
				self.drag.OnMove = function(dragself, x, y)
					self.Left:Set(function() return  (x - (self.Width()/2)) end)
					self.Top:Set(function() return  (y - (self.Height()/2)) end)
					moved = true
					dragself.x = x
					dragself.y = y
				end
				self.drag.OnRelease = function(dragself)
					self:SetNeedsFrameUpdate(true)
					if moved then
						self.position = GetMouseWorldPos()
					end
				end
				self.drag.OnCancel = function(dragself)
					self:SetNeedsFrameUpdate(true)
					self:EnableHitTest()
				end
				PostDragger(self:GetRootFrame(), event.KeyCode, self.drag)
				return true
			end
		end
	end
	--position each frame to keep same world position
	markerTable[index].OnFrame = function(self)
		self.Left:Set(function() return worldview:Project(self.position)[1]  - (self.Width()/2) +worldview.Left() end)
		self.Top:Set(function() return worldview:Project(self.position)[2] - (self.Height()/2) +worldview.Top() end)
	end
	markerTable[index]:Hide()
	markerTable[index].checkThread = ForkThread(UpgradeSCUAroundPoint, markerTable[index])
	index = index+1
end


--#*
--#*  Gilbot-X:
--#*
--#*  Forked as thread from PlaceMarker above.
--#*  
--#*  Gets a list of idle scus around a point, and then starts 
--#*  the selected upgrade path on them.
--#**
function UpgradeSCUAroundPoint(marker)
	while true do
		local idleEngineers = GetIdleEngineers()
		if idleEngineers then
			local idleSCUs = EntityCategoryFilterDown(categories.SUBCOMMANDER, idleEngineers)
			for i, unit in idleSCUs do
				if not GetEnhancements(unit) then
					if VDist3(marker.position, unit:GetPosition()) < 11 then
						UpgradeSCU(unit, marker.upgradeType)
					end
				end
			end
		end
		WaitSeconds(4)
	end
end