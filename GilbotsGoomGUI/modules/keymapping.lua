local KeyMapper = import('/lua/keymap/keymapper.lua')
local Prefs = import('/lua/user/prefs.lua')

function Init()
	KeyMapper.SetUserKeyAction('toggle_repeat_build', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").ToggleRepeatBuild()', category = 'user', order = 1})
	KeyMapper.SetUserKeyAction('show_enemy_life', {action = 'UI_ForceLifbarsOnEnemy', category = 'user', order = 2})
	KeyMapper.SetUserKeyAction('show_network_stats', {action =  'ren_ShowNetworkStats', category = 'user', order = 3})
	--add key to create an upgrade marker
	KeyMapper.SetUserKeyAction('scu_upgrade_marker', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/scumanager.lua").CreateMarker()', category = 'user', order = 4})
	KeyMapper.SetUserKeyAction('toggle_shield', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Shield")', category = 'user', order = 6})
	KeyMapper.SetUserKeyAction('toggle_weapon', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Weapon")', category = 'user', order = 7})
	KeyMapper.SetUserKeyAction('toggle_jamming', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Jamming")', category = 'user', order = 8})
	KeyMapper.SetUserKeyAction('toggle_intel', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Intel")', category = 'user', order = 9})
	KeyMapper.SetUserKeyAction('toggle_production', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Production")', category = 'user', order = 10})
	KeyMapper.SetUserKeyAction('toggle_stealth', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Stealth")', category = 'user', order = 11})
	KeyMapper.SetUserKeyAction('toggle_generic', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Generic")', category = 'user', order = 12})
	KeyMapper.SetUserKeyAction('toggle_special', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Special")', category = 'user', order = 13})
	KeyMapper.SetUserKeyAction('toggle_cloak', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleScript("Cloak")', category = 'user', order = 14})
	KeyMapper.SetUserKeyAction('toggle_all', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleAllScript()', category = 'user', order = 15})
	KeyMapper.SetUserKeyAction('teleport', {action =  'StartCommandMode order RULEUCC_Teleport', category = 'user', order = 5})
	KeyMapper.SetUserKeyAction('military_overlay', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleOverlay("Military")', category = 'user', order = 16})
	KeyMapper.SetUserKeyAction('intel_overlay', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleOverlay("Intel")', category = 'user', order = 17})
	KeyMapper.SetUserKeyAction('select_all_idle_eng_onscreen', {action =  'UI_SelectByCategory +inview +idle ENGINEER', category = 'user', order = 18})
	KeyMapper.SetUserKeyAction('select_all_similar_units', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").GetSimilarUnits()', category = 'user', order = 19})
	KeyMapper.SetUserKeyAction('select_next_land_factory', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").GetNextLandFactory()', category = 'user', order = 20})
	KeyMapper.SetUserKeyAction('select_next_air_factory', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").GetNextAirFactory()', category = 'user', order = 21})
	KeyMapper.SetUserKeyAction('select_next_naval_factory', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").GetNextNavalFactory()', category = 'user', order = 22})
	KeyMapper.SetUserKeyAction('toggle_selectedinfo', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/selectedinfo.lua").ToggleOn()', category = 'user', order = 23})
	KeyMapper.SetUserKeyAction('toggle_selectedrings', {action =  'UI_Lua import("/mods/GilbotsGoomGUI/modules/selectedinfo.lua").ToggleOverlayOn()', category = 'user', order = 24})
    KeyMapper.SetUserKeyAction('toggle_cloakjammingstealth', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleCloakJammingStealthScript()', category = 'user', order = 25})
    KeyMapper.SetUserKeyAction('toggle_intelshield', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").toggleIntelShieldScript()', category = 'user', order = 26})
    KeyMapper.SetUserKeyAction('toggle_mdf_panel', {action = 'UI_Lua import("/lua/ui/game/multifunction.lua").ToggleMFDPanel()', category = 'user', order = 27})
    KeyMapper.SetUserKeyAction('toggle_tab_display', {action = 'UI_Lua import("/lua/ui/game/tabs.lua").ToggleTabDisplay()', category = 'user', order = 28})
    KeyMapper.SetUserKeyAction('zoom_pop', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/zoompopper.lua").ToggleZoomPop()', category = 'user', order = 29})
    KeyMapper.SetUserKeyAction('select_inview_idle_mex', {action = 'UI_SelectByCategory +inview +idle MASSEXTRACTION', category = 'user', order = 30})
    KeyMapper.SetUserKeyAction('select_all_mex', {action = 'UI_SelectByCategory MASSEXTRACTION', category = 'user', order = 31})
    KeyMapper.SetUserKeyAction('select_nearest_idle_lt_mex', {action = 'UI_Lua import("/mods/GilbotsGoomGUI/modules/keymapping.lua").GetNearestIdleLTMex()', category = 'user', order = 32})
end

function ToggleRepeatBuild()
	local selection = GetSelectedUnits()
	if selection then
		local allFactories = true
		local currentInfiniteQueueCheckStatus = false
		for i,v in selection do
			if v:IsRepeatQueue() then
				currentInfiniteQueueCheckStatus = true
			end
			if not v:IsInCategory('FACTORY') then
				allFactories = false
			end
		end
		if allFactories then
			for i,v in selection do
				if currentInfiniteQueueCheckStatus then
					v:ProcessInfo('SetRepeatQueue', 'false')
				else
					v:ProcessInfo('SetRepeatQueue', 'true')
				end
			end
		end
	end
end

--function to toggle things like shields etc
-- Unit toggle rules copied from orders.lua, used for converting to the numbers needed for the togglescriptbit function
unitToggleRules = {
    Shield =  0,
    Weapon = 1,
    Jamming = 2,
    Intel = 3,
    Production = 4,
    Stealth = 5,
    Generic = 6,
    Special = 7,
    Cloak = 8,}

function toggleScript(name)
	local selection = GetSelectedUnits()
	local number = unitToggleRules[name]
	local currentBit = GetScriptBit(selection, number)
	ToggleScriptBit(selection, number, currentBit)
end

function toggleAllScript(name)
	local selection = GetSelectedUnits()
	for i = 0,8 do
		local currentBit = GetScriptBit(selection, i)
		ToggleScriptBit(selection, i, currentBit)
	end
end

local MilitaryFilters = {"Defense","AntiNavy","Miscellaneous","AntiAir","DirectFire","IndirectFire"}
local IntelFilters = {"CounterIntel", "Omni", "Radar", "Sonar"}

function toggleOverlay(type)
	local currentFilters = Prefs.GetFromCurrentProfile('activeFilters') or {}
	local tempFilters = {}
	local MilitaryActive = false
	local IntelActive = false
	for i, filter in MilitaryFilters do
		if currentFilters[string.lower(filter)] then
			MilitaryActive = true
		end
	end
	for i, filter in IntelFilters do
		if currentFilters[string.lower(filter)] then
			IntelActive = true
		end
	end
	
	local function toggleFilters(filterTable, active)
		for i, filter in filterTable do
			if active then
				currentFilters[string.lower(filter)] = nil
			else
				currentFilters[string.lower(filter)] = true
				table.insert(tempFilters, filter)
			end
		end
	end
	
	if type == 'Military' then
		toggleFilters(MilitaryFilters, MilitaryActive)
		if IntelActive then
			for i, filter in IntelFilters do
				table.insert(tempFilters, filter)
			end
		end
	end
	
	if type == 'Intel' then
		toggleFilters(IntelFilters, IntelActive)
		if MilitaryActive then
			for i, filter in MilitaryFilters do
				table.insert(tempFilters, filter)
			end
		end
	end
	
	Prefs.SetToCurrentProfile('activeFilters', currentFilters)
	import('/lua/ui/game/multifunction.lua').UpdateActiveFilters()
end

local currentLandFactoryIndex = 1
local currentAirFactoryIndex = 1
local currentNavalFactoryIndex = 1


function GetNextLandFactory()
	UISelectionByCategory("FACTORY * LAND", false, false, false, false)
	local FactoryList = GetSelectedUnits()
    if FactoryList then
        local nextFac = FactoryList[currentLandFactoryIndex] or FactoryList[1]
        currentLandFactoryIndex = currentLandFactoryIndex + 1
        if currentLandFactoryIndex > table.getn(FactoryList) then
            currentLandFactoryIndex = 1
        end
        SelectUnits({nextFac})
    end
end

function GetNextAirFactory()
	UISelectionByCategory("FACTORY * AIR", false, false, false, false)
	local FactoryList = GetSelectedUnits()
    if FactoryList then
        local nextFac = FactoryList[currentAirFactoryIndex] or FactoryList[1]
        currentAirFactoryIndex = currentAirFactoryIndex + 1
        if currentAirFactoryIndex > table.getn(FactoryList) then
            currentAirFactoryIndex = 1
        end
        SelectUnits({nextFac})
    end
end

function GetNextNavalFactory()
	UISelectionByCategory("FACTORY * NAVAL", false, false, false, false)
	local FactoryList = GetSelectedUnits()
    if FactoryList then
        local nextFac = FactoryList[currentNavalFactoryIndex] or FactoryList[1]
        currentNavalFactoryIndex = currentNavalFactoryIndex + 1
        if currentNavalFactoryIndex > table.getn(FactoryList) then
            currentNavalFactoryIndex = 1
        end
        SelectUnits({nextFac})
    end
end

function GetNearestIdleLTMex()
   local tech = 1
   while (tech < 4) do
      ConExecute('UI_SelectByCategory +nearest +idle +inview MASSEXTRACTION TECH' .. tech)
      tech = tech + 1
      local tempList = GetSelectedUnits()
      if (tempList ~= nil) and (table.getn(tempList) > 0) then
         break
      end   
   end
end

function toggleCloakJammingStealthScript()
   toggleScript("Cloak")
   toggleScript("Jamming")
   toggleScript("Stealth")
end   

function toggleIntelShieldScript()
   toggleScript("Intel")
   toggleScript("Shield")
end

--this function might be too slow in larger games, needs testing
function GetSimilarUnits()
	local enhance = import('/lua/enhancementcommon.lua')
	local curSelection = GetSelectedUnits()
	if curSelection then
		--find out what enhancements the current unit has
		local curUnitId = curSelection[1]:GetEntityId()
        local curUnitEnhancements = enhance.GetEnhancements(curUnitId)

		--select all similar units by category
		local bp = curSelection[1]:GetBlueprint()
		local bpCats = bp.Categories
		local catString = ""
		for i, cat in bpCats do
			if i == 1 then
				catString = cat
			else
				catString = catString.." * " ..cat
			end
		end
		UISelectionByCategory(catString, false, false, false, false)
		
		--get enhancements on each unit and filter down to only those with the same as the first unit
		local newSelection = GetSelectedUnits()
		local tempSelectionTable = {}
		for i, unit in newSelection do
			local unitId = unit:GetEntityId()
	        local unitEnhancements = enhance.GetEnhancements(unitId)
			if curUnitEnhancements and unitEnhancements then
				if table.equal(unitEnhancements, curUnitEnhancements) then
					table.insert(tempSelectionTable, unit)
				end
			elseif curUnitEnhancements == nil and unitEnhancements == nil then
					table.insert(tempSelectionTable, unit)
			end
		end
		SelectUnits(tempSelectionTable)

	end
end
