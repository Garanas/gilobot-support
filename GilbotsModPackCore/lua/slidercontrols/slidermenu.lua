--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/slidercontrols/slidermenu.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Slider controls UI code
--#**  
--#***************************************************************************

local UIUtil = import('/lua/ui/uiutil.lua')
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Slider = import('/lua/maui/slider.lua').Slider
local Button = import('/lua/maui/button.lua').Button
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Tooltip = import('/lua/ui/game/tooltip.lua')

--# My own included files
local SupportedTypes = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/sliderdatatypes.lua').SupportedTypes
local GetCustomStatTypesFromUnit = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/sliderdatatypes.lua').GetCustomStatTypesFromUnit
local UnitText = 
    import('/mods/GilbotsModPackCore/lua/unittext.lua')
local NumberToStringWith2DPMax = 
    import('/mods/GilbotsModPackCore/lua/utils.lua').NumberToStringWith2DPMax 

    
--# These values are constants
local MinSliderValue = 0
local MaxSliderValue = 20
local SliderValueRange = MaxSliderValue-MinSliderValue
local debugThisFile = false


StatSliderMenu = Class { 

    --# These are private variables
    SelectedUnits = nil,
    EntityTables = nil,
    StatSliders = nil,
    OKButtonPanel = nil,
    LastSlider = nil,
    IsMenuActive = false,


    --#*
    --#*  Constructor function for the class
    --#*  It sets up the menu with sliders, labels and buttons.
    --#**
    __init = function(self, unitsSelected)
        
        --# Reset these tables here just to be safe
        self.EntityDisplayTexts = {}
        self.StatSliders = {}
        self.EntityTables = {}
        self.EncounteredCustomStatValueTypes = {}
        
        self.xPos = 10
        self.yPos = 170
        self.yOffset = 39
        self.LastSlider = nil
        self.Parent = GetFrame(0)
            
        --# Store argument for later use    
        self.SelectedUnits = unitsSelected
        
        for k, selectedUnit in self.SelectedUnits do
        
            --# Check sync table as custom units 
            --# designed for this mod will pass data to use through it. 
            self.AttachAnySynchDataTo(selectedUnit)
   
            --# for each type of stat that can use a slider
            for kType, vType in SupportedTypes do
                if vType:Condition(selectedUnit) then
                    self:AddSliderForStatValue(selectedUnit, vType)
                end
            end
            
            --# for each type of custom stat this unit has
            for kType, vType in GetCustomStatTypesFromUnit(selectedUnit) do
                --# if its the first time we've seen it in this menu instance
                if not self.EncounteredCustomStatValueTypes[kType] then
                    if vType:Condition(selectedUnit) then
                        --# add a slider to the menu for it
                        self:AddSliderForStatValue(selectedUnit, vType)
                        --# keep a record of it
                        self.EncounteredCustomStatValueTypes[kType] = vType
                    end
                end
            end
            
            --# Create a button under the last slider
            if self.LastSlider then 
                self.IsMenuActive = true
                self:CreateOKButtonPanel()
            end
                
        end
    end,
    
    
    --#*
    --#*  Check sync table as custom units 
    --#*  designed for this mod will pass data to use through it. 
    --#**
    AttachAnySynchDataTo = function(selectedUnit)
        if UnitData[selectedUnit:GetEntityId()] then
            selectedUnit.SliderSyncData =
                UnitData[selectedUnit:GetEntityId()].SliderControlledStatValues
            return selectedUnit
        end
    end,
    
    
    
    --#*
    --#*  Add a slider with appropriate parameters 
    --#*  for this stat type and link it to the unit. 
    --#**
    AddSliderForStatValue = function(self, selectedUnit, statDef)
  
        local unitbp = selectedUnit:GetBlueprint()
    
        --# Create the entity table
        if not self.EntityTables[statDef.TypeName] then
            self.EntityTables[statDef.TypeName] = {}
        end
        
        --# Get the variable name for where we will put the value
        --# inside the active unit object (remember we are on UI side here)
        local varName = statDef.VariableNameInUnit
        
        
        --# Record the value of the stat in the unit object,
        --# based on what we think it should be now.
        --# Note: We are doing this from the UI side here,
        --# we need to access SIM side to be sure.
        if not selectedUnit[varName] then
            --# If we'd done it before, leave it as what it was, otherwise 
            --# use the default value
            selectedUnit[varName] = statDef:GetDefaultValue(selectedUnit)
        end
 
        
        --# Check sync data for more up-to-date value of what the stat is now
        if selectedUnit.SliderSyncData then
            if selectedUnit.SliderSyncData[statDef.TypeName] then 
                --# This next line will overwrite what was just obtained in the block above,
                --# i.e. either what the slider menu remembered the value was 
                --# last time it was set here, or the default value if this is the first time
                --# the slider is setting it on this unit.
                selectedUnit[varName] = selectedUnit.SliderSyncData[statDef.TypeName].CurrentValue
            end
        end
        
        --# Put the entity ID and stat value of this unit into a table of changes to make.
        if not table.find(self.EntityTables[statDef.TypeName], selectedUnit:GetEntityId()) then
            self.EntityTables[statDef.TypeName][selectedUnit:GetEntityId()] = 
                selectedUnit[varName]
        end
        
        --# Create a slider for this stat if that hasn't been done already
        if not self.StatSliders[statDef.TypeName] then 
            
            --# Start with top panel
            if not self.TopPanel then self:CreateTopPanel() end
            
            --# Create slider and keep a ref to it
            self.StatSliders[statDef.TypeName] = self:CreateSlider(selectedUnit[varName], selectedUnit, statDef)
            
            --# Record that so far this is the last/lowest slider in the menu
            self.LastSlider = self.StatSliders[statDef.TypeName]
        end
    end, 
                    
    

  
    --#*
    --#*  Create slider UI control
    --#**
    CreateTopPanel = function(self)
        self.TopPanel = Bitmap(self.Parent, '/mods/textures/Gilbot/slidermenutop.dds')
        --# Set its position relative to where the mouse was clicked
        self.TopPanel.Left:Set(self.xPos)
        self.TopPanel.Top:Set(self.yPos)
        self.TopPanel.Depth:Set(1000)
        --# Change layout position for any following slider to be under this
        self.yPos = self.yPos + 7
    end,
    
    
    --#*
    --#*  Create slider UI control
    --#**
    CreateSlider = function(self, unitValue, unitArg, statDefArg)
                  
        local sliderPanel = Bitmap(self.Parent, '/mods/textures/Gilbot/slidermenumiddle.dds')
        --# Set its position relative to where the mouse was clicked
        sliderPanel.Left:Set(self.xPos)
        sliderPanel.Top:Set(self.yPos)
        sliderPanel.Depth:Set(1000)
        --# Add text to it
        local labelText = UIUtil.CreateText(sliderPanel, statDefArg.DisplayText, 12, UIUtil.bodyFont)
        --# Set its position above slider control
        LayoutHelpers.AtLeftTopIn(labelText, sliderPanel, 10, 2)
        --# These sliders are used in the options dialog
        sliderPanel.Slider = Slider(sliderPanel, false, MinSliderValue, MaxSliderValue, 
            UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), 
            UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'),
            UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'),
            UIUtil.SkinnableFile('/slider02/slider-back_bmp.dds'))  
        --# Set its position relative to where the mouse was clicked
        LayoutHelpers.AtLeftTopIn(sliderPanel.Slider, sliderPanel, 2, 14)
        --# Set the slider position
        sliderPanel.Slider.Unit = unitArg
        sliderPanel.Slider.StatDef = statDefArg
        --# The slider gets a knob position based on the stat that creates it
        local sliderValue = self:CalculateSliderValueForStatValue(unitArg, unitValue, statDefArg)
        sliderPanel.Slider:SetValue(sliderValue)
        --# Output the most recent value.
        sliderPanel.ValueLabel = UIUtil.CreateText(sliderPanel, NumberToStringWith2DPMax(unitValue), 12, UIUtil.bodyFont)
        --# Set its position above slider control
        LayoutHelpers.AtLeftTopIn(sliderPanel.ValueLabel, sliderPanel, 200, 14)
        --# Add function to update display of slider value
        sliderPanel.Slider.OnValueSet = function(slider, newValue)
            local unitValue = self:CalculateStatValueFromSlider(slider.Unit, newValue, slider.StatDef)
            sliderPanel.ValueLabel:SetText(NumberToStringWith2DPMax(unitValue))
        end
        
        --# Change layout position for any 
        --# following slider to be under this one
        self.yPos = self.yPos + self.yOffset
        --# Return the slider and panel
        return sliderPanel
    end,
    
    
    
    --#*
    --#*  Create OK button for menu 
    --#**
    CreateOKButtonPanel = function(self)
        
        self.OKButtonPanel = Bitmap(self.Parent, '/mods/textures/Gilbot/slidermenubottom.dds')
        --# Set its position relative to where the mouse was clicked
        self.OKButtonPanel.Left:Set(self.xPos)
        self.OKButtonPanel.Top:Set(self.yPos)
        self.OKButtonPanel.Depth:Set(1000)
        
        if true then 
            --# Use bitmaps already in game from 'create prifle' menu
            self.OKButtonPanel.okButton = Button(self.OKButtonPanel,
                UIUtil.SkinnableFile('/menus02/profile-select_btn_up.dds'), 
                UIUtil.SkinnableFile('/menus02/profile-select_btn_over.dds'),
                UIUtil.SkinnableFile('/menus02/profile-select_btn_down.dds'),
                UIUtil.SkinnableFile('/menus02/profile-select_btn_dis.dds'))  
            
            --# Add text to button
            local buttonText = UIUtil.CreateText(self.OKButtonPanel.okButton, "OK", 12, UIUtil.bodyFont)
            LayoutHelpers.AtCenterIn(buttonText, self.OKButtonPanel.okButton)
      
            --# This gives a mouseover highlight effect 
            self.OKButtonPanel.okButton.HandleEvent = function(control, event)
                if event.Type == 'MouseEnter' then
                    --Need to define tooltip text in the tooltip file if you want to have one
                    --Tooltip.CreateMouseoverDisplay(self.OKButtonPanel.okButton, "update stats ", 5, true)
                    buttonText:SetColor('ff000000')
                elseif event.Type == 'MouseExit' then
                    --Tooltip.DestroyMouseoverDisplay()
                    buttonText:SetColor(UIUtil.fontColor())
                end
                Button.HandleEvent(control, event)
            end
        else
            --# This is a big dialog button
            self.OKButtonPanel.okButton = UIUtil.CreateButtonStd(self.OKButtonPanel, '/widgets/small', 'OK', 16)
        end
    
        --# Add button to panel
        LayoutHelpers.AtLeftTopIn(self.OKButtonPanel.okButton, self.OKButtonPanel, 170, 0)
        --# Call function in our menu class when clicked
        self.OKButtonPanel.okButton.OwnerMenu = self
        self.OKButtonPanel.okButton.OnClick = function(self, modifiers)
            self.OwnerMenu:FinishSlider()
        end
    end,
    
    
    
    
    --#*
    --#*  This is called after the button is pressed.
    --#*  The user is finished usng the sliders to set new values.
    --#*  We can update the units now.
    --#**
    FinishSlider = function(self)

        --# We are going to call 'update-functions' on all 
        --# relevant units, so first we must iteratively
        --# get 'update-function' arguments for all the units
        for k, selectedUnit in self.SelectedUnits do
        
            --# for each type of stat that can use a slider
            for kType, vType in SupportedTypes do
            
                --# check if this unit has that stat 
                if vType:Condition(selectedUnit) then
                    self:PutValueInUpdatesTable(selectedUnit, vType)
                end
            end

            --# Now do the same for any custom stat types this unit has
            for kType, vType in GetCustomStatTypesFromUnit(selectedUnit) do
                if vType:Condition(selectedUnit) then
                    self:PutValueInUpdatesTable(selectedUnit, vType)
                end
            end
        end
        
        --# Now call the update functions!!!
        --# for each type of stat that can use a slider
        for kStatTypeName, vEntityTable in self.EntityTables do
            --# if there was a slider for this type of stat value 
            --# then link to sim via callback to set stat values on unit
            if SupportedTypes[kStatTypeName] then 
                self:DoSimCallback(SupportedTypes[kStatTypeName])
            else
                self:DoSimCallback(self.EncounteredCustomStatValueTypes[kStatTypeName])
            end
        end
        
        --# Display text added in the loop above
        self:DisplayTextOnUnits()
        
        --# We are finsihed so destroy the menu
        self:Destroy()
    end,
    
    
    --#*
    --#* 
    --#*  This is called by the FinishSlider function above.
    --#**
    DisplayTextOnUnits = function(self)
        
        --# Give each unit a list of strings that 
        --# gives the value set by each slider
        for kStatTypeName, vEntityTable in self.EntityTables do
            for entityId, newStatValue in vEntityTable do
                --# Make sure this entity has a text table.
                if not self.EntityDisplayTexts[entityId] then
                    self.EntityDisplayTexts[entityId]  = {}
                end                
                --# Here we can add display text to unit.
                table.insert(self.EntityDisplayTexts[entityId], kStatTypeName .. ' = ' .. NumberToStringWith2DPMax(newStatValue))
            end
        end
        
        --# Now set the combined display text on each unit
        for entityId, vText in self.EntityDisplayTexts do
            --# Here we can add display text to unit.
            local entryData = {
                Text = vText,
                Entity = entityId,
                FadeAfterSeconds = 5,
                Color ='ffbbeeff', -- light blue
                FontSize = 12,
                SyncTextVariable = nil                
            }
            UnitText.StartDisplay(entryData)
        end
    end,


    --#*
    --#* 
    --#*  This is called by the FinishSlider function above.
    --#**
    DoSimCallback = function(self, statDef)
  
        local functionName = 'SetStatValue'
        
        --# Shield size has its own callback function
        --# because the size change is animated
        if statDef.TypeName == 'ShieldSize' then
            functionName = 'SetShieldSize'
        end
      
        --# Invoke sim side code.
        --# Not sure if you can pass a nested table as argument.
        --# You definitely can't pass functions or classes.
        --# You can definitely pass flat tables.
        SimCallback( {  Func=functionName,
                        Args={ 
                          EntityTable= self.EntityTables[statDef.TypeName],
                          StatType = statDef.TypeName,
                          ResourceDrainID = statDef.ResourceDrainID,
                          BPDefaultValueLocation = statDef.BPDefaultValueLocation,
                          BPDefaultValueName = statDef.BPDefaultValueName,
                          UpdateConsumptionImmediately = statDef.UpdateConsumptionImmediately
                        }
                      }
                    )
    end,
    
    
    
    --#*
    --#* 
    --#*  This is called by the FinishSlider function above.
    --#**
    Destroy = function(self)
    
        --# Time to clean up and dispose of the menu.
        --# First get rid of the slider controls and their labels...
        for statName, sliderPanel in self.StatSliders do 
            if sliderPanel then 
                --# Destroy the panel and all contents
                --sliderPanel.Slider:Destroy()
                --sliderPanel.Label:Destroy()
                sliderPanel:Destroy()
                sliderPanel=false
                --# Wipe the table
                self.EntityTables[statName] = false
            end
        end
        
        --# Then get rid of the OK button
        self.OKButtonPanel:Destroy()
        self.OKButtonPanel = nil
        self.TopPanel:Destroy()
        self.TopPanel = nil
        
        --# By this point everything should be destroyed!
        self.IsMenuActive = false
        
    end, 
    
    
    
    
    --#*
    --#* 
    --#*  This is called by the FinishSlider function above.
    --#**
    PutValueInUpdatesTable = function(self, selectedUnit, statDef)
          --# Get the variable name for where we will put the stat value
          --# inside the active unit object (remember we are on UI side here)
          local varName = statDef.VariableNameInUnit
          
          --# Get the new stat value the user set with the slider
          selectedUnit[varName] = 
              self:CalculateStatValueFromSlider(selectedUnit, 
                                                self.StatSliders[statDef.TypeName].Slider:GetValue(), 
                                                statDef)
          
          --# Update our table so we can synchronise all units after this
          self.EntityTables[statDef.TypeName][selectedUnit:GetEntityId()] = selectedUnit[varName] 
    end,
    

    

    --#*
    --#*  Work out the starting position of the slider control's knob
    --#*  from last shield size, intel radius, or other stat value in the unit.
    --#*  This is called by the class constructor 
    --#**
    CalculateSliderValueForStatValue = function(self, selectedUnit, statValue, statDef)
        
        --# Get min and max values for this stat
        local minStatValue = statDef:GetMinValue(selectedUnit) or 0
        local maxStatValue = statDef:GetMaxValue(selectedUnit) or 0
        
        --# Perform scaling and return calculated result
        local sliderValuesPerStatUnit = SliderValueRange / (maxStatValue-minStatValue) 
        local sliderValue = MinSliderValue + (sliderValuesPerStatUnit * (statValue - minStatValue))
        return sliderValue
    end,
    
    
    
    --#*
    --#*  Get shield size, intel radius, or other stat value, from the slider
    --#*  This is called by FinishSlider.
    --#**
    CalculateStatValueFromSlider = function(self, selectedUnit, currentSliderValue, statDef)
        --# Get min and max values for this stat
        local minStatValue = statDef:GetMinValue(selectedUnit) or 0
        local maxStatValue = statDef:GetMaxValue(selectedUnit) or 0
        
        --# Perform scaling and return calculated result
        local statUnitsPerSliderUnits = (maxStatValue-minStatValue) / SliderValueRange
        local statValueFromSlider = minStatValue + 
            (statUnitsPerSliderUnits * (currentSliderValue - MinSliderValue))

        return statValueFromSlider
    end,
    
}
