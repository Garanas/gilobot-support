--#*****************************************************************************
--#**
--#**  Hook File: /lua/ui/game/construction.lua
--#**
--#**  Modded By: Gilbot-X
--#**
--#**  Last updated:  Dec 9th 2008, Gilbot-X 
--#** 
--#**  Summary: This file contains 1949 lines of UI code for 
--#**           the build dialog that factories, construction units, 
--#**           and units that have upgrades and enhancements all 
--#**           have in one form or another.
--#*****************************************************************************


--#*
--#*  Gilbot-X:
--#*
--#*  I changed this so that I can apply a series of enhancements 
--#*  in a queue on any single unit or group of units.  
--#**
local OldOnSelection = OnSelection
function OnSelection(buildableCategories, selection, isOldSelection)
    --# Call original code first
    OldOnSelection(buildableCategories, selection, isOldSelection)

    if table.getsize(selection) > 0 then
        --# repeated from original to work out value of allSameUnit
        local allSameUnit = true
        local bpID = false
        for i, v in selection do
            if bpID and bpID ~= v:GetBlueprint().BlueprintId then
                allSameUnit = false
                break
            else
                bpID = v:GetBlueprint().BlueprintId
            end
        end

        --# Gilbot-X:
        --# I changed this so that I can apply enhancements to more than one unit
        --# at a time.  It used to disable enhancement button if more than 1 unit
        --# was selected.  Now instead it is enabled if all units selected are of the
        --# same unit id. Goom's code does the same so his can be 
        --# applied before or after mine safely.
        if allSameUnit and selection[1]:GetBlueprint().Enhancements 
        then controls.enhancementTab:Enable()
        else controls.enhancementTab:Disable()
        end
    end
end


--#*
--#*  Gilbot-X:
--#*
--#*  I changed this so that I can apply a series of enhancements 
--#*  in a queue on any single unit or group of units.  
--#**
local OldOnClickHandler = OnClickHandler
function OnClickHandler(button, modifiers)
    --# Gilbot-X:
    --# I changed this so that I can apply a series of enhancements 
    --# in a queue on any single unit or group of units.  
    if button.Data.type == 'enhancement' then
        --# This is done by all cases
        PlaySound(Sound({Cue = "UI_MFD_Click", Bank = "Interface"}))
        local QueueEnhancement = import('/mods/GilbotsModPackCore/lua/enhancementqueue.lua').UserQueueEnhancement
        for arrayIndex, unit in sortedOptions.selection do
            QueueEnhancement(unit, button.Data.id, button.Data.enhTable.Slot)
        end
    else
        --# Use old code
        return OldOnClickHandler(button, modifiers)
    end
end




--#*
--#*  Gilbot-X:
--#*
--#*  I changed this so that I can apply a series of enhancements 
--#*  in a queue on any single unit or group of units.  
--#**
local OldFormatData = FormatData 
function FormatData(unitData, type)
    local retData = {}
    if  (type == 'construction') or
        (type == 'selection') or
        (type == 'templates') then  
        --# Use old code
        return OldFormatData(unitData, type)
    else
        --# Enhancements
        --# Gilbot-X: I added this block
        local selectedEnhancements = EnhanceCommon.GetEnhancements(sortedOptions.selection[1]:GetEntityId())
        for _, vUnit in sortedOptions.selection do 
            for _, vSlot in {'RCH', 'LCH', 'Back'} do
                local existingEnhancements = EnhanceCommon.GetEnhancements(vUnit:GetEntityId())
                if selectedEnhancements[vSlot] and existingEnhancements[vSlot]
                and (existingEnhancements[vSlot] ~= selectedEnhancements[vSlot]) then 
                    selectedEnhancements[vSlot] = nil
                end
            end
        end
        --# End of modified block
        local filteredEnh = {}
        local usedEnhancements = {}
        local restrictList = EnhanceCommon.GetRestricted()
        for index, enhTable in unitData do
            if not string.find(enhTable.ID, 'Remove') then
                local restricted = false
                for _, enhancement in restrictList do
                    if enhancement == enhTable.ID then
                        restricted = true
                        break
                    end
                end
                if not restricted then
                    table.insert(filteredEnh, enhTable)
                end
            end
        end
        local function GetEnhByID(id)
            for i, enh in filteredEnh do
                if enh.ID == id then
                    return enh
                end
            end
        end
        local function FindDependancy(id)
            for i, enh in filteredEnh do
                if enh.Prerequisite and enh.Prerequisite == id then
                    return enh.ID
                end
            end
        end
        local function AddEnhancement(enhTable, disabled)
            local iconData = {
                type = 'enhancement', 
                enhTable = enhTable, 
                unitID = enhTable.UnitID, 
                id = enhTable.ID,
                icon = enhTable.Icon, 
                Selected = false,
                Disabled = disabled,
            }
            --# Moved this into here
            usedEnhancements[enhTable.ID] = true
            --# Gilbot-X: Changed this block slightly
            if selectedEnhancements[enhTable.Slot] == enhTable.ID then
                iconData.Selected = true
            end
            --# Gilbot-X: End of change
            table.insert(retData, iconData)
        end
        local function ShouldBeDisabled(enhTable)
            local searching = true
            local selectedEnhBP = GetEnhByID(selectedEnhancements[enhTable.Slot])
            local selectedEnhPrereqID = selectedEnhBP.Prerequisite
            if not selectedEnhPrereqID then searching = false end
            while searching do
                local prereq1Enh = GetEnhByID(selectedEnhPrereqID) 
                --# If this new button is for an enhnacement that
                --# is the prerequisite of the one already activated
                --# in this slot that can't downgrade
                if prereq1Enh.ID == enhTable.ID then 
                    if selectedEnhBP.CannotDowngradeToPrerequisites then return true end
                    --# Do not continue recursing
                    searching = false
                end
                --# Recurse to next prerequisite of the 
                --# selected enhancement in this slot.
                selectedEnhPrereqID = prereq1Enh.Prerequisite
                if not selectedEnhPrereqID then searching = false end
            end
            --# Found no reason 
            --# to disable button
            return false
        end
        for i, enhTable in filteredEnh do
            --# Do this on items not added that don't have a prerequisite
            if not usedEnhancements[enhTable.ID] and not enhTable.Prerequisite then
                --# Add this enhancement and enable 
                --# it if it has no prerequisites 
                AddEnhancement(enhTable, ShouldBeDisabled(enhTable))
                if FindDependancy(enhTable.ID) then
                    local searching = true
                    local curID = enhTable.ID
                    while searching do
                        --# Add an arrow
                        table.insert(retData, {type = 'arrow'})
                        --# Add the icon
                        local tempEnh = GetEnhByID(FindDependancy(curID))
                        AddEnhancement(tempEnh, ShouldBeDisabled(tempEnh))
                        if FindDependancy(tempEnh.ID) then
                            curID = tempEnh.ID
                        else
                            searching = false
                            --# If this is not the last ewnhancement for this slot
                            if table.getsize(usedEnhancements) <= table.getsize(filteredEnh)-1 then
                                --# Add a spacer
                                table.insert(retData, {type = 'spacer'})
                            end
                        end
                    end
                else
                    if table.getsize(usedEnhancements) <= table.getsize(filteredEnh)-1 then
                        table.insert(retData, {type = 'spacer'})
                    end
                end
            end
        end
        CreateExtraControls('enhancement')
        SetSecondaryDisplay('buildQueue')
        
        import(UIUtil.GetLayoutFilename('construction')).OnTabChangeLayout(type)
        return retData
    end
end