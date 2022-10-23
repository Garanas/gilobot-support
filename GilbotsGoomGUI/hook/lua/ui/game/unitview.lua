do--(start of non destructive hook)
local Prefs = import('/lua/user/prefs.lua')
local options = Prefs.GetFromCurrentProfile('options')

local SCUManager = 
    import('/mods/GilbotsGoomGUI/modules/scumanager.lua')
    
--# If SCU manager is turned on...
if options.gui_scu_manager ~= 0 then

    --# Hook this function
    local originalUpdateWindow = UpdateWindow
    function UpdateWindow(info)
        --# Do previous version of code first
        originalUpdateWindow(info)
        --# Then do appended SCU manager code.
        controls.SCUType:Hide()
        if info.userUnit then
            local unitId = info.userUnit:GetUnitId()
            if string.sub(unitId, 3) == 'l0301' then
                local mySCUType = SCUManager.GetSCUType(info.userUnit)
                --LOG('Unit=' .. repr(unitId) .. ' is SCU of type=' .. repr(mySCUType))
                if mySCUType then
                    controls.SCUType:SetTexture('/mods/GilbotsGoomGUI/textures/scumanager/'..mySCUType..'_icon.dds')
                    controls.SCUType:Show()
                end
            end
        end
    end	
    
    --# Hook this function
    local originalCreateUI = CreateUI
    function CreateUI()
        originalCreateUI()
        controls.SCUType = Bitmap(controls.bg)
        LayoutHelpers.AtRightIn(controls.SCUType, controls.icon)
        LayoutHelpers.AtBottomIn(controls.SCUType, controls.icon)
    end
end


--# If UnitView option is turned on...
if options.gui_enhanced_unitview ~= 0 then
   
    --# Hook this function to add stuff to the
    --# OnFrame beat function to the UI.
    local originalCreateUI = CreateUI
    function CreateUI()
        --# Preserve previous code
        originalCreateUI()
        
        --# Add code to bg.OnFrame function
        local oldBGOnFrame = controls.bg.OnFrame
        controls.bg.OnFrame = function(self, delta)
            local info = GetRolloverInfo()
            -- If no rollover, then see if we have a single unit selected
            if not info and import("/mods/GilbotsGoomGUI/modules/selectedinfo.lua").SelectedInfoOn then
                local selUnits = GetSelectedUnits()
                if selUnits and table.getn(selUnits) == 1 and import('/lua/ui/game/unitviewDetail.lua').View.Hiding then
                    info = import("/mods/GilbotsGoomGUI/modules/selectedinfo.lua").GetUnitRolloverInfo(selUnits[1])
            --LOG(repr(import('/lua/enhancementcommon.lua').GetEnhancements(info.entityId)))
                end
            end
            -- Original function code
            if info then
                UpdateWindow(info)
                if self:GetAlpha() < 1 then
                    self:SetAlpha(math.min(self:GetAlpha() + (delta*3), 1), true)
                end
                import(UIUtil.GetLayoutFilename('unitview')).PositionWindow()
            elseif self:GetAlpha() > 0 then
                self:SetAlpha(math.max(self:GetAlpha() - (delta*3), 0), true)
            end
        end
    end

    --# Hook this function to make sure 
    --# progress bar is not hidden by fuel bar
    local originalUpdateWindow = UpdateWindow
    function UpdateWindow(info)
        originalUpdateWindow(info)
        -- Replace fuel bar with progress bar
        if info.blueprintId ~= 'unknown' then
            controls.fuelBar:Hide()
            if info.workProgress > 0 then
                controls.fuelBar:Show()
                controls.fuelBar:SetValue(info.workProgress)
            end
        end
    end
end


end--(of non destructive hook)