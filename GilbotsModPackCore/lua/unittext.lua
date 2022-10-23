--#****************************************************************************
--#**
--#**  New File:  /mods/GilbotsModPackCore/lua/unittext.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Allow UI elements to be added to units onscreen
--#**            
--#**
--#****************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')


local currentDisplays = {}

function StartDisplay(entryData)
    
    --# Set defaults for arguments not provided
    local textColor = entryData.Color or 'ffff7f00'
    local fontSize = entryData.FontSize or 18
    --# Check for mandatory arguments
    if not (entryData.Text and entryData.Entity) then return end
    local hostUnit = GetUnitById(entryData.Entity)
    
    local views = import('/lua/ui/game/worldview.lua').GetWorldViews()
    for _, viewControl in views do
        local view = viewControl
        if not currentDisplays[view._cameraName] then
            currentDisplays[view._cameraName] = {}
        end
        if currentDisplays[view._cameraName][entryData.Entity] then
            for k, vTextObject in currentDisplays[view._cameraName][entryData.Entity] do
                vTextObject:Destroy()
            end
        end
        currentDisplays[view._cameraName][entryData.Entity] = {}
        --LOG('Erasing text for ' .. repr(entryData.Entity))
        local index = 0
        for keyStringIndex, vString in entryData.Text do
            index = index+1
            --# Create text and add to storage array
            currentDisplays[view._cameraName][entryData.Entity][keyStringIndex] =
                UIUtil.CreateText(view, vString, fontSize, UIUtil.bodyFont)
            
            local text = currentDisplays[view._cameraName][entryData.Entity][keyStringIndex]
            text.HeightIndex = index -- needed to work out height
            text.KeyStringIndex = keyStringIndex
            text:SetDropShadow(true)
            text:SetColor(textColor)
            text:DisableHitTest()
            text.userEntity = hostUnit 
            text.position = text.userEntity:GetPosition()
            text.time = 0
            text.startTime = GetGameTimeSeconds()
            text:SetAlpha(1)
            text:SetNeedsFrameUpdate(true)
            text.UpdateTick = function(self)
                if self.userEntity and (not self.userEntity:IsDead())
                  and self:GetAlpha() > 0 
                then
                    self.position = self.userEntity:GetPosition()
                    if entryData.SyncTextVariable and UnitData[entryData.Entity] then 
                        local textUpdate =  UnitData[entryData.Entity][entryData.SyncTextVariable][self.KeyStringIndex]
                        if textUpdate then 
                            self:SetText(textUpdate) 
                        end
                     end 
                else
                    self:Destroy()
                    currentDisplays[view._cameraName][entryData.Entity] = nil
                end
            end
            text.UpdatePosition = function(self)
                local coords = view:Project(self.position)
                self.Left:Set(function() return view.Left() + coords[1] - (self.Width() / 2) end)
                self.Top:Set(function() return view.Top() + coords[2] - ((fontSize+3)*self.HeightIndex) end)
            end
            text.OnFrame = function(self, delta)
                self.time = self.time + delta
                if not self.userEntity then
                    self:Destroy()
                    currentDisplays[view._cameraName][entryData.Entity] = nil
                end
                if GetCamera(view._cameraName):GetTargetZoom() > 100 then
                    self:Hide()
                elseif self.Right() > view.Right() then
                    self:Hide()
                elseif self.Left() < view.Left() then
                    self:Hide()
                elseif self.Bottom() > view.Bottom() then
                    self:Hide()
                elseif self.Top() < view.Top() then
                    self:Hide()
                else
                    self:Show()
                end
                --# Update every second
                if GetGameTimeSeconds() - self.startTime > 1 then
                    self.startTime = GetGameTimeSeconds()
                    self:UpdateTick()
                end
                if entryData.FadeAfterSeconds and self.time > entryData.FadeAfterSeconds then 
                    local newAlpha = math.max(self:GetAlpha() - delta, 0)
                    self:SetAlpha(newAlpha)
                    if newAlpha < 0 then
                        newAlpha = 0
                        self:Destroy()
                        currentDisplays[view._cameraName][entryData.Entity] = nil
                    end
                end
                self:UpdatePosition()
            end
            text:UpdatePosition()
        end
    end
end


function CancelDisplay()
    local views = import('/lua/ui/game/worldview.lua').GetWorldViews()
    for _, viewControl in views do
        local view = viewControl
        if currentDisplays[view._cameraName] then
            for kEntityIndex, vUnitEntityTextTable in currentDisplays[view._cameraName] do
                for kIndex, vTextObject in vUnitEntityTextTable do
                    vTextObject.EntityIndex = kEntityIndex
                    vTextObject.Index = kIndex
                    vTextObject.OnFrame = function(self, delta)
                        local newAlpha = self:GetAlpha() - delta
                        if newAlpha < 0 then
                            newAlpha = 0
                            self:Destroy()
                            currentDisplays[view._cameraName][self.EntityIndex][self.Index] = nil
                        end
                        self:SetAlpha(newAlpha)
                    end
                end
            end
        end
    end
end