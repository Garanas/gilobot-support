do--(start of non-destructive hook)	
local Prefs = import('/lua/user/prefs.lua')
local options = Prefs.GetFromCurrentProfile('options')
local Effect = import('/lua/maui/effecthelpers.lua')

--#*
--#*  If the option to allow all races to build 
--#*  other races templates is selected, then
--#*  OnSelection is hooked.  This is also hooked
--#*  in my Core mod, but there are no conflicts.
--#**
if options.gui_all_race_templates ~= 0 then

    local oldOnSelection = OnSelection
    function OnSelection(buildableCategories, selection, isOldSelection)
        --# Previous code preserved.
        oldOnSelection(buildableCategories, selection, isOldSelection)

        if table.getsize(selection) > 0 then
            --repeated from original to access the local variables
            local allSameUnit = true
            local bpID = false
            local allMobile = true
            for i, v in selection do
                if allMobile and not v:IsInCategory('MOBILE') then
                    allMobile = false
                end
                if allSameUnit and bpID and bpID ~= v:GetBlueprint().BlueprintId then
                    allSameUnit = false
                else
                    bpID = v:GetBlueprint().BlueprintId
                end
                if not allMobile and not allSameUnit then
                    break
                end
            end
            
            local templates = Templates.GetTemplates()
            local buildableUnits = EntityCategoryGetUnitList(buildableCategories)
            if allMobile and templates and table.getsize(templates) > 0 then
                local currentFaction = selection[1]:GetBlueprint().General.FactionName
                if currentFaction then
                    sortedOptions.templates = {}
                    local function ConvertID(BPID)
                        local prefixes = {
                            ["AEON"] = {
                                "uab",
                                "xab",
                                "dab",
                            },
                            ["UEF"] = {
                                "ueb",
                                "xeb",
                                "deb",
                            },
                            ["CYBRAN"] = {
                                "urb",
                                "xrb",
                                "drb",
                            },
                            ["SERAPHIM"] = {
                                "xsb",
                                "usb",
                                "dsb",
                            },
                        }
                        for i, prefix in prefixes[string.upper(currentFaction)] do
                            if table.find(buildableUnits, string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")) then
                                return string.gsub(BPID, "(%a+)(%d+)", prefix .. "%2")
                            end
                        end
                        return false
                    end
                    for templateIndex, template in templates do
                        local valid = true
                        local converted = false
                        for _, entry in template.templateData do
                            if type(entry) == 'table' then
                                if not table.find(buildableUnits, entry[1]) then

                                    entry[1] = ConvertID(entry[1])
                                    converted = true
                                    if not table.find(buildableUnits, entry[1]) then
                                        valid = false
                                        break
                                    end
                                end
                            end
                        end
                        if valid then
                            if converted then
                                template.icon = ConvertID(template.icon)
                            end
                            template.templateID = templateIndex
                            table.insert(sortedOptions.templates, template)
                        end
                    end
                end

                --refresh the construction tab to show any new available templates
                if not isOldSelection then
                    if not controls.constructionTab:IsDisabled() then
                        controls.constructionTab:SetCheck(true)
                    else
                        controls.selectionTab:SetCheck(true)
                    end
                elseif controls.constructionTab:IsChecked() then
                    controls.constructionTab:SetCheck(true)
                elseif controls.enhancementTab:IsChecked() then
                    controls.enhancementTab:SetCheck(true)
                else
                    controls.selectionTab:SetCheck(true)
                end
            end
        end
    end
end

--#*
--#*  If the option for bigger strategic build icons
--#*  is selected, the CommonLogic function gets hooked:  
--#**
if options.gui_bigger_strat_build_icons ~= 0 then
    local straticonsfile = import('/mods/GilbotsGoomGUI/modules/straticons.lua')
    local oldCommonLogic = CommonLogic
    function CommonLogic()
        oldCommonLogic()
        local oldSecondary = controls.secondaryChoices.SetControlToType
        local oldPrimary = controls.choices.SetControlToType
        controls.secondaryChoices.SetControlToType = function(control, type)
            oldSecondary(control, type)
            if control.StratIcon.Underlay then
                control.StratIcon.Underlay:Hide()
            end
            StratIconReplacement(control)
        end
        controls.choices.SetControlToType = function(control, type)
            oldPrimary(control, type)
            if control.StratIcon.Underlay then
                control.StratIcon.Underlay:Hide()
            end
            StratIconReplacement(control)
        end
    end
    
    function StratIconReplacement(control)
        if __blueprints[control.Data.id].StrategicIconName then
            local iconName = __blueprints[control.Data.id].StrategicIconName
            local iconConversion = straticonsfile.aSpecificStratIcons[control.Data.id] or straticonsfile.aStratIconTranslation[iconName]
            if iconConversion and DiskGetFileInfo('/mods/GilbotsGoomGUI/textures/icons_strategic/'..iconConversion..'.dds') then
                control.StratIcon:SetTexture('/mods/GilbotsGoomGUI/textures/icons_strategic/'..iconConversion..'.dds')
                LayoutHelpers.AtTopIn(control.StratIcon, control.Icon, 1)
                LayoutHelpers.AtRightIn(control.StratIcon, control.Icon, 1)
                LayoutHelpers.ResetBottom(control.StratIcon)
                LayoutHelpers.ResetLeft(control.StratIcon)
                control.StratIcon:SetAlpha(0.8)
                --[[if string.find(iconName, '%d') then
                    local techGuess = string.sub(iconName, string.find(iconName, '%d'))
                    if (techGuess == '1' or techGuess == '2' or techGuess == '3') then
                        if control.StratIcon.Underlay then
                            control.StratIcon.Underlay:SetTexture('/mods/GilbotsGoomGUI/textures/icons_strategic/tech_'..techGuess..'_underlay.dds')
                            control.StratIcon.Underlay:Show()
                        else
                            control.StratIcon.Underlay = Bitmap(control.StratIcon, '/mods/GilbotsGoomGUI/textures/icons_strategic/tech_'..techGuess..'_underlay.dds')
                            control.StratIcon.Underlay.Depth:Set(function() return control.StratIcon.Depth() - 1 end)
                        end
                        LayoutHelpers.AtLeftTopIn(control.StratIcon.Underlay, control.StratIcon)
                    end
                end]]
            else
                LOG('Strat Icon Mod Error: updated strat icon required for: ', iconName)
            end
        end
    end
end


--#*
--#*  If the option to enable template rotator
--#*  is selected, the OnClickHandler function gets 
--#*  hooked. OnClickHandler is also hooked
--#*  in my Core mod, but there are no conflicts. 
--#**
if options.gui_template_rotator ~= 0 then
    
    --# Hook this function
    local oldOnClickHandler = OnClickHandler
    function OnClickHandler(button, modifiers)
        --# Previous code is preserved
        oldOnClickHandler(button, modifiers)
        
        --# This code is appended
        local item = button.Data
        if item.type == "templates" then
            local activeTemplate = item.template.templateData
            local worldview = import('/lua/ui/game/worldview.lua').viewLeft
            local oldHandleEvent = worldview.HandleEvent
            worldview.HandleEvent = function(self, event)
                if event.Type == 'ButtonPress' then
                    if event.Modifiers.Middle then
                        ClearBuildTemplates()
                        local tempTemplate = table.deepcopy(activeTemplate)
                        for i = 3, table.getn(activeTemplate) do
                            local index = i
                            activeTemplate[index][3] = 0 - tempTemplate[index][4]
                            activeTemplate[index][4] = tempTemplate[index][3]
                        end
                        SetActiveBuildTemplate(activeTemplate)
                    elseif event.Modifiers.Shift then
                    else
                        worldview.HandleEvent = oldHandleEvent
                    end
                end
            end
        end
    end
end


--#*
--#*  If the option to enable draggable build queue
--#*  is selected, the gameParent.HandleEvent function 
--#*  gets hooked, as does SetSecondaryDisplay, and OnRolloverHandler
--#**
if options.gui_draggable_queue ~= 0 then
    
    local dragging = false
    local index = nil			--index of the item in the queue currently being dragged
    local originalIndex = false	--original index of selected item (so that UpdateBuildQueue knows where to modify it from)
    local oldQueue = {}
    local modifiedQueue = {}
    local updateQueue = true	--if false then queue won't update in the ui
    local modified = false		--if false then buttonrelease will increase buildcount in queue
    local dragLock = false		--to disable quick successive drags, which doubles the units in the queue

    --add gameparent handleevent for if the drag ends outside the queue window
    local gameParent = import('gamemain.lua').GetGameParent()
    local oldGameParentHandleEvent = gameParent.HandleEvent
    gameParent.HandleEvent = function(self, event)
        if event.Type == 'ButtonRelease' then
            import('/lua/ui/game/construction.lua').ButtonReleaseCallback()
        end
        oldGameParentHandleEvent(self, event)
    end 

    function MoveItemInQueue(queue, indexfrom, indexto)
        modified = true
        local moveditem = queue[indexfrom]
        if indexfrom < indexto then
            --take indexfrom out and shunt all indices from indexfrom to indexto up one
            for i = indexfrom, (indexto - 1) do
                queue[i] = queue[i+1]
            end
        elseif indexfrom > indexto then
            --take indexfrom out and shunt all indices from indexto to indexfrom down one
            for i = indexfrom, (indexto + 1), -1 do
                queue[i] = queue[i-1]
            end
        end
        queue[indexto] = moveditem
        modifiedQueue = queue
        currentCommandQueue = queue
        --update buttons in the UI
        SetSecondaryDisplay('buildQueue')
    end

    function UpdateBuildList(newqueue, from)
        --The way this does this is UGLY but I can only find functions to remove things from the build queue and to add them at the end
        --Thus the only way I can see to modify the build queue is to delete it back to the point it is modified from (the from argument) and then 
        --add the modified version back in. Unfortunately this causes a momentary 'skip' in the displayed build cue as it is deleted and replaced

        for i = table.getn(oldQueue), from, -1  do
            DecreaseBuildCountInQueue(i, oldQueue[i].count)	
        end
        for i = from, table.getn(newqueue)  do
            blueprint = __blueprints[newqueue[i].id]
            if blueprint.General.UpgradesFrom == 'none' then
                IssueBlueprintCommand("UNITCOMMAND_BuildFactory", newqueue[i].id, newqueue[i].count)
            else
                IssueBlueprintCommand("UNITCOMMAND_Upgrade", newqueue[i].id, 1, false)
            end
        end
        ForkThread(dragPause)
    end

    function dragPause()
        WaitSeconds(0.4)
        dragLock = false
    end

    function ButtonReleaseCallback()
        if dragging == true then
            PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
            --don't update the queue next time round, to avoid a list of 0 builds
            updateQueue = false
            --disable dragging until the queue is rebuilt
            dragLock = true
            --reset modified so buildcount increasing can be used again
            modified = false
            --mouse button released so end drag
            dragging = false
            if originalIndex <= index then
                first_modified_index = originalIndex
            else 
                first_modified_index = index
            end
            --on the release of the mouse button we want to update the ACTUAL build queue that the factory does. So far, only the UI has been changed,
            UpdateBuildList(modifiedQueue, first_modified_index)
            --nothing is now selected
            index = nil    
        end  
    end
    
    --don't update the queue the tick after a buttonreleasecallback
    local oldSetSecondaryDisplay = SetSecondaryDisplay
    function SetSecondaryDisplay(type)
        if updateQueue then
            oldSetSecondaryDisplay(type)
        else
            updateQueue = true
        end
    end
    
    local oldOnRolloverHandler = OnRolloverHandler
    function OnRolloverHandler(button, state)
        local item = button.Data
        if item.type == 'queuestack' and prevSelection and EntityCategoryContains(categories.FACTORY, prevSelection[1]) then
            if state == 'enter' then
                button.oldHandleEvent = button.HandleEvent
                --if we have entered the button and are dragging something then we want to replace it with what we are dragging
                if dragging == true then
                    --move item from old location (index) to new location (this button's index)
                    MoveItemInQueue(currentCommandQueue, index, item.position) 
                    --since the currently selected button has now moved, update the index
                    index = item.position
                    
                    button.dragMarker = Bitmap(button, '/mods/GilbotsGoomGUI/textures/queuedragger.dds')
                    LayoutHelpers.FillParent(button.dragMarker, button)
                    button.dragMarker:DisableHitTest()
                    Effect.Pulse(button.dragMarker, 1.5, 0.6, 0.8)
    
                end
                button.HandleEvent = function(self, event)
                    if event.Type == 'ButtonPress' or event.Type == 'ButtonDClick' then
                        local count = 1
                        if event.Modifiers.Ctrl == true or event.Modifiers.Shift == true then
                            count = 5
                        end

                        if event.Modifiers.Left then
                            if not dragLock then
                                --left button pressed so start dragging procedure
                                dragging = true
                                index = item.position
                                originalIndex = index
                                
                                self.dragMarker = Bitmap(self, '/mods/GilbotsGoomGUI/textures/queuedragger.dds')
                                LayoutHelpers.FillParent(self.dragMarker, self)
                                self.dragMarker:DisableHitTest()
                                Effect.Pulse(self.dragMarker, 1.5, 0.6, 0.8)
                                
                                --copy un modified queue so that current build order is recorded (for deleting it)
                                oldQueue = table.copy(currentCommandQueue)
                            end
                        else
                            PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
                            DecreaseBuildCountInQueue(item.position, count)
                        end
                    elseif event.Type == 'ButtonRelease' then
                        if dragging then
                            --if queue has changed then update queue, else increase build count (like default)
                            if modified then
                                ButtonReleaseCallback()
                            else
                                PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
                                dragging = false
                                local count = 1
                                if event.Modifiers.Ctrl == true or event.Modifiers.Shift == true then
                                    count = 5
                                end
                                IncreaseBuildCountInQueue(item.position, count)
                            end
                            if self.dragMarker then
                                self.dragMarker:Destroy()
                                self.dragMarker = false
                            end
                        end
                    else
                        button.oldHandleEvent(self, event)
                    end
                end
                button.Glow:SetNeedsFrameUpdate(true)
            else
                if button.oldHandleEvent then
                    button.HandleEvent = button.oldHandleEvent
                else
                    WARN('OLD HANDLE EVENT MISSING HOW DID THIS HAPPEN?!')
                end
                if button.dragMarker then
                    button.dragMarker:Destroy()
                    button.dragMarker = false
                end
                button.Glow:SetNeedsFrameUpdate(false)
                button.Glow:SetAlpha(0)
                UnitViewDetail.Hide()
            end
        else
            oldOnRolloverHandler(button, state)
        end
    end
end


end--(of non-destructive hook)