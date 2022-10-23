--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/slidercontrols/sliderdatatypes.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Slider controls code that deals with what can be adjusted.
--#**  
--#***************************************************************************

local debugSliderControls = false


--[[

Gilbot-X says:  

This code can be put in your unit script file so you can synch with the slider, if your unit changes any of these stat values itself, i.e. with enhancements, or if it does it automatically based on the economy.


    --# Gilbot-X: This stuff is used with my 'Stat Slider' mod for data sync
    self.SliderControlledStatValues = {
        RadarStealthFieldRadius = { 
            CurrentValue=0,
            MinValue=0,
            MaxValue=0,
            DefaultValue=0,
            DefaultEnergyConsumption=0,
            DefaultMassConsumption=0,
            CanUseSliderNow=false
        },
        CloakFieldRadius = {
            CurrentValue=0, 
            MinValue=0,
            MaxValue=0,
            DefaultValue=0,
            DefaultEnergyConsumption=0,
            DefaultMassConsumption=0,
            CanUseSliderNow=false
        }
    }
    --# You need to do a sync here, otherwise 
    --# the Stat Slider mod will not realise this unit
    --# uses synch data!  This is important if you want to use the mod!       
    self.Sync.SliderControlledStatValues = self.SliderControlledStatValues
        
        
        
        
    
Put this where you change the stat value (change it so it uses your values)
        
    --# Gilbot-X says: This is used with my slider mod for data sync
      self.SliderControlledStatValues.RadarStealthFieldRadius.CurrentValue = 25
      self.SliderControlledStatValues.RadarStealthFieldRadius.MinValue = 5
      self.SliderControlledStatValues.RadarStealthFieldRadius.MinValue = 40
      self.SliderControlledStatValues.RadarStealthFieldRadius.DefaultValue= 25
      self.SliderControlledStatValues.RadarStealthFieldRadius.DefaultEnergyConsumption= 50
      self.SliderControlledStatValues.RadarStealthFieldRadius.DefaultMassConsumption= 0
      self.SliderControlledStatValues.RadarStealthFieldRadius.CanUseSliderNow = true 
      --# Do the sync
      self.Sync.SliderControlledStatValues = self.SliderControlledStatValues


    
        
Put this in the blueprint file.
        
   SliderAdjustableValues = {
        RadarStealthFieldRadius = {
            DisplayText = 'Radar stealth-field radius',
            BPDefaultValueLocation = {'Intel'},
            BPDefaultValueName = 'RadarStealthFieldRadius',
            ResourceDrainID = 'Stealth',
        },
        CloakFieldRadius = {
            DisplayText = 'Cloak-field radius',
            BPDefaultValueLocation = {'Intel'},
            BPDefaultValueName = 'CloakFieldRadius',
            ResourceDrainID = 'Cloak',
        }
    },
   
  
Note: ResourceDrainID is optional and can be set to false or nil if the slider control should not affect resource consumption.  If it is given a value it must match a field used by my Maintenance Consumption Breakdown code.  The other fields are mandatory.
                
    
]]

--#*
--#*  Called by MinVal functions to get min size for some stat values
--#**
CalculateMinCoverageSizeForUnit = function(unitbp)
    --# This calculates the radius of a sphere that will contain the unit
    local x,y,z = unitbp.SizeX*2,unitbp.SizeY*2,unitbp.SizeZ*2
    local minCoverageSize = math.ceil(math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2)))
    return minCoverageSize
end
    
    
    
--#*
--#*  Called by functions to get a blueprint value,
--#*  given a description of its location as an argument.
--#* 
--#*  Example for array argument:
--#*   {'Defense', 'Shield', 'ShieldSize'}
--#*   will return the value for 
--#*   unitbp.Defense.Shield.ShieldSize for that unit.
--#**
GetBPValueFromArray = function(unitbp, array, name)
    if (not array) or (not name) then 
        WARN("Name or Array missing in GetBPValueFromArray")
    end
    local value = unitbp
    local arrayStartIndex = 1
    local indexOfLastEntry = arrayStartIndex+(table.getsize(array)-1)
    
    for i = arrayStartIndex, indexOfLastEntry do
        value = value[array[i]]
    end
    
    return value[name]
    
end
    
    
    
    
--#*    
--#*
--#*  Gilbot-X says:
--#*  
--#*  Note for modders: 
--#*  ResourceDrainID is a field only used 
--#*  my Maintenance Consumption Breakdown mod.
--#*  
--#*  Note for modders:
--#*  You cannot pass a functions to the sim from UI 
--#*  using SimCallbacks, as it won't serialise. 
--#**
StatType = Class {
    
    --#*
    --#*  Constructor function for the class
    --#*  It sets up ...
    --#**
    __init = function(self, typeName, displayText, resourceDrainID, 
                      bpDefaultValueLocation, bpDefaultValueName, updateImmediately, bpVariableName)
        self.TypeName = typeName
        self.DisplayText= displayText
        self.ResourceDrainID = resourceDrainID
        self.BPDefaultValueLocation = bpDefaultValueLocation
        self.BPDefaultValueName = bpDefaultValueName
        self.BPDefaultMinValueName = bpDefaultValueName .. 'Min'
        self.BPDefaultMaxValueName = bpDefaultValueName .. 'Max'
        self.UpdateConsumptionImmediately = updateImmediately
        --# Gilbot-X: changed this on 1st Dec 2008.
        --# so I could set variable name in BPs.
        if not bpVariableName then bpVariableName = bpDefaultValueName end
        self.VariableNameInUnit = 'StatSlider' .. bpVariableName
    end,
    
    
              
    --#==============================================================
    --#  These next 3 function get values from BP only 
    --#==============================================================
  
    GetBPValue= function(self, unitObject)
        return GetBPValueFromArray(unitObject:GetBlueprint(), 
                            self.BPDefaultValueLocation,
                            self.BPDefaultValueName)
    end,
    
    GetBPMinValue= function(self, unitObject)
        return GetBPValueFromArray(unitObject:GetBlueprint(), 
                            self.BPDefaultValueLocation,
                            self.BPDefaultMinValueName)
    end,
    
    GetBPMaxValue= function(self, unitObject)
        return GetBPValueFromArray(unitObject:GetBlueprint(), 
                            self.BPDefaultValueLocation,
                            self.BPDefaultMaxValueName)
    end,
  
  
  
    --#==============================================================
    --#  These next 3 function get values trying sync table first
    --#==============================================================
  
    GetDefaultValue = function(self, unitObject)
        return  self:TrySyncForValue(unitObject, 'DefaultValue') or 
                self:GetBPValue(unitObject) or
                self:TryCalculateDefaultFor(unitObject, 'DefaultValue')
    end,
    
    GetMinValue = function(self, unitObject)
        return  self:TrySyncForValue(unitObject, 'MinValue') or  
                self:GetBPMinValue(unitObject) or 
                self:TryCalculateDefaultFor(unitObject, 'MinValue')
    end,
  
    GetMaxValue = function(self, unitObject)
        return  self:TrySyncForValue(unitObject, 'MaxValue') or 
                self:GetBPMaxValue(unitObject) or 
                self:TryCalculateDefaultFor(unitObject, 'MaxValue')
    end,
    
    
  
    
    --#*
    --#*  Units that use the sync were designed to be used with sliders.
    --#*  The synch provides min and max values for the slider
    --#*  which can change nased upon the unit's state,
    --#*  i.e. it can depend on veterancy, enhancements, health, etc.     
    --#**
    TrySyncForValue = function(self, unitObject, valueName)
        --# Check sync data first 
        if unitObject.SliderSyncData and 
            unitObject.SliderSyncData[self.TypeName] and
            unitObject.SliderSyncData[self.TypeName][valueName]
        then return
            unitObject.SliderSyncData[self.TypeName][valueName]
        else
            return false
        end
    end,
    
    
    
    --#*
    --#*  Units that override ConditionForGenericUnits should also override this.
    --#*  It creates artifical min and max values for the slider for units 
    --#*  that were not originally designed to be used with sliders. 
    --#**
    TryCalculateDefaultFor = function(self, unitObject, valueName)
        WARN('Slider: StatType class: TryCalculateDefaultFor:  ' .. repr(valueName))
        --# This is a custom type so it won't need this -
        --# the creator will have suppliued all values explicitly
        return false
    end, 
    
    
    
    --#*
    --#*  Conditions are used for the set of generic stat value types defined here,
    --#*  (i.e. shield size slider), that can be applied appropriately to certain 
    --#*  eligible units that were not originally designed to be used with sliders. 
    --#*  
    --#*  Units that were designed with these generic stat types in mind can 
    --#*  opt in or out of using any of then explicitly, using the sync table.
    --#*  The synch table is therefore checked first, then type-specific conditions
    --#*  are looked at if nothing explicit was indicated in the sync data.    
    --#**
    Condition= function(self, unitObject)
        --# If there is any sync data
        if unitObject.SliderSyncData 
          --# if it refers to a stat value of this type, then
          and unitObject.SliderSyncData[self.TypeName] then 
            --# it will toggle whether or not we should display the slider
            return unitObject.SliderSyncData[self.TypeName].CanUseSliderNow 
        else
            --# Was this a custom slider controlled variable?
            if self.IsCustomStatType then 
                --# Custom slider control types are always 
                --# enabled unless the sync explicitly disables it
                return true
            else
                --# No sync data for this type of stat value, so 
                --# no evidence that this unit meets the condition
                --# to get a status slider for this stat type.
                return self:ConditionForGenericUnits(unitObject)
            end
        end
    end,    

    
    --#*
    --#*  Conditions are used for the set of generic stat value types defined here,
    --#*  (i.e. shield size slider), that can be applied appropriately to certain 
    --#*  eligible units that were not originally designed to be used with sliders.
    --#*  
    --#*  This is overrided by such a generic stat type, to provide conditions 
    --#*  such as 'the unit has a shield and its not a personal shield', so 
    --#*  it meets the condition to have a shield-size slider.
    --#**
    ConditionForGenericUnits = function(self, unitObject)
        --# By default, don't use this slider for all generic units.
        --# Override this to set specific conditions based on 
        --# unit categories (see examples at end of file)
        return false
    end,
    
}

            
    
    
    
    
--#*    
--#*
--#*  Gilbot-X says:
--#*  
--#*  Define Stat values like this.
--#**
ShieldSize = StatType (
    'ShieldSize',
    'Shield diameter',
    'Shield',
    {'Defense', 'Shield'},
    'ShieldSize',
    true
)
        
ShieldSize.ConditionForGenericUnits = function(self, unitObject)
    return 
        (
          (
            EntityCategoryContains(categories.SHIELD * categories.STRUCTURE, unitObject) 
            or 
            EntityCategoryContains( (
                                      (categories.MOBILE * categories.LAND) *  
                                      (categories.DEFENSE * categories.SHIELD)
                                    ) 
                                      - categories.DIRECTFIRE, unitObject)
          )
          and not unitObject:GetBlueprint().Defense.Shield.PersonalShield
        )
end
    
ShieldSize.TryCalculateDefaultFor = function(self, unitObject, valueName)
    if valueName == 'MinValue' then 
    --# ShieldSize is a diameter so don't halve the result
        return CalculateMinCoverageSizeForUnit(unitObject:GetBlueprint())
    elseif valueName == 'MaxValue' then       
        return math.ceil(self:GetDefaultValue(unitObject) * 1.5)
    else
        return false
    end
end
    
    
    
    
    
--#*    
--#*
--#*  Gilbot-X says:
--#*  
--#*  Define Stat values like this.
--#**
RadarStealthFieldRadius = StatType ( 
    'RadarStealthFieldRadius',
    'Radar stealth-field radius', 
    'Stealth',
    {'Intel'},
    'RadarStealthFieldRadius',
    true
)

RadarStealthFieldRadius.ConditionForGenericUnits= function(self, unitObject)
    return
        (
            EntityCategoryContains(categories.COUNTERINTELLIGENCE - categories.DIRECTFIRE, unitObject) 
            and unitObject:GetBlueprint().Intel.RadarStealthFieldRadius > 0 
            and not unitObject:GetBlueprint().Intel.IntelFree
        )
end        
  
RadarStealthFieldRadius.TryCalculateDefaultFor = function(self, unitObject, valueName)
    if valueName == 'MinValue' then 
        --# Values must be integer multiples of 4.
        --# This is small but not the smallest.
        return 8
    elseif valueName == 'MaxValue' then     
        return math.ceil(self:GetDefaultValue(unitObject) * 1.5)
    else
        return false
    end
end

        
        
--#*    
--#*
--#*  Gilbot-X says:
--#*  
--#*  Automatic slider given for this.
--#**
CloakFieldRadius = StatType ( 
    'CloakFieldRadius',
    'Cloak-field radius', 
    'Cloak',
    {'Intel'},
    'CloakFieldRadius',
    true
)

CloakFieldRadius.ConditionForGenericUnits = function(self, unitObject)
    return
        (
            EntityCategoryContains(categories.COUNTERINTELLIGENCE - categories.DIRECTFIRE, unitObject) 
            and unitObject:GetBlueprint().Intel.CloakFieldRadius > 0 
            and not unitObject:GetBlueprint().Intel.IntelFree
        )
end        
  
CloakFieldRadius.TryCalculateDefaultFor = function(self, unitObject, valueName)
    if valueName == 'MinValue' then 
        --# Values must be integer multiples of 4.
        --# This is small but not the smallest.
        return 8 
    elseif valueName == 'MaxValue' then      
        return math.min(math.ceil(self:GetDefaultValue(unitObject) + 8),32)
    else
        return false
    end
end



--#*    
--#*
--#*  Gilbot-X says:
--#*  
--#*  Define Stat values like this.
--#**
RadarRadius = StatType ( 
    'RadarRadius',
    'Radar radius',  
    'Intel',
    {'Intel'},
    'RadarRadius',
    true
)

RadarRadius.TryCalculateDefaultFor = function(self, unitObject, valueName)
    if valueName == 'MinValue' then 
        --# Use vision radius
        return unitObject:GetBlueprint().Intel.VisionRadius or 
            --# Double what's need to cover the unit
            CalculateMinCoverageSizeForUnit(unitObject:GetBlueprint()) * 2
    elseif valueName == 'MaxValue'  then     
        return math.ceil(self:GetDefaultValue(unitObject) * 1.5)
    else
        return false
    end
end
    

    
--#*    
--#*
--#*  Gilbot-X says:
--#*  
--#*  Now add all of them to a table that can be indexed by their names.
--#*  Again cloakfield commented out as the slider won't work in FA (see above).
--#**
SupportedTypes = {}
SupportedTypes[ShieldSize.TypeName] = ShieldSize
SupportedTypes[RadarStealthFieldRadius.TypeName] = RadarStealthFieldRadius 
SupportedTypes[CloakFieldRadius.TypeName] = CloakFieldRadius
SupportedTypes[RadarRadius.TypeName] = RadarRadius    




--#*    
--#*
--#*  Gilbot-X says:
--#*  
--#*  This will take care of your custom types.
--#*  Just make sure you use the blueprint keys correctly.
--#**
GetCustomStatTypesFromUnit = function(unitObject)
    
    local bpEntry = unitObject:GetBlueprint().SliderAdjustableValues   
    local CustomTypes = {}
    
    --# Check for custom blueprint flags
    if bpEntry and type(bpEntry) == 'table' then  
        for statTypeName, statTypeProperties in bpEntry do
            
            --# This is just for debugging.
            --# It can be deleted.
            if debugSliderControls then
                LOG('Slider: Custom type found in BP: ' 
                .. ' TypeName=' .. repr(statTypeName)
                .. ' DisplayText=' .. repr(statTypeProperties.DisplayText)
                .. ' ResourceDrainID=' .. repr(statTypeProperties.ResourceDrainID)
                .. ' BPDefaultValueLocation=' .. repr(statTypeProperties.BPDefaultValueLocation)
                .. ' BPDefaultValueName=' .. repr(statTypeProperties.BPDefaultValueName)
                .. ' UpdateConsumptionImmediately=' .. repr(statTypeProperties.UpdateConsumptionImmediately)
                )
            end
            
            --# Create a stat value type definition object
            --# using values in the BP entry
            local customType = StatType ( 
                statTypeName,      
                statTypeProperties.DisplayText,
                statTypeProperties.ResourceDrainID,
                statTypeProperties.BPDefaultValueLocation,
                statTypeProperties.BPDefaultValueName,
                statTypeProperties.UpdateConsumptionImmediately or false,
                statTypeProperties.VariableNameInUnit or false
            )
            
            --# Mark it as a custom type
            --# as we need to know for calls to
            --# the Condition() function
            customType.IsCustomStatType = true
            
            --# Put it in the list of custom 
            --# stat type definitions to return
            CustomTypes[statTypeName] = customType    
        end
    end  
    
    --# Return a list of stat value definitions 
    --# (that can be empty if no custom types found).
    return CustomTypes
    
end  
        
     
     
        