--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/autotoggle/autotogglecallbacks.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  
--#**
--#**  This module contains the Sim-side lua functions that can be invoked
--#**  from the user side.  These need to validate all arguments against
--#**  cheats and exploits.
--#**
--#**  We store the callbacks in a sub-table (instead of directly in the
--#**  module) so that we don't include any.
--#**  
--#***************************************************************************

local ATSystem = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua')


--#*
--#*  Gilbot-X says:  
--#*
--#*  This helper function gets the unit selected, 
--#*  checks if it is an AutoToggle unit, and if it is, 
--#*  returns the AT entry requested if it is there.
--#*  If it isn't there it produces a warning.
--#**
local function GetAutoToggleEntry(unitEntityIdArg, resourceDrainIdArg)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local selectedUnit = GetEntityById(unitEntityIdArg)
    --# Only pass on call if this is an autotoggle unit.
    if not selectedUnit.IsAutoToggleUnit then return false end
    if table.getsize(selectedUnit.AutoToggleEntries) < 1 then return false end
    if not selectedUnit.AutoToggleEntries[resourceDrainIdArg] then
        local keys = ""
        for kResourceDrainId, vEntry in selectedUnit.AutoToggleEntries do
            keys = keys .. kResourceDrainId .. ", "
        end
        WARN('IsValidArgs: ' 
        .. ' R=' .. repr(resourceDrainIdArg)
        .. ' was not found in the AT entries of ' 
        .. repr(unitEntityIdArg) .. ' which were: ' .. keys
        )
        return false
    end
    
    --# If we got here, the rags were good.
    return selectedUnit.AutoToggleEntries[resourceDrainIdArg]
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  SIM callback.
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to register it
--#*  in its ordered AT priority list.
--#**
function DisableAutoToggleCallback(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local autoToggleEntry = GetAutoToggleEntry(data.SelectedUnitEntityId, data.ResourceDrainId)
    --# Only pass on call if this is an autotoggle unit.
    if autoToggleEntry then
        --# This argument specifies if we register or unregister
        if data.DisableToggle
        then ATSystem.EntryCommands.StopToggling(autoToggleEntry)
        else ATSystem.EntryCommands.StartToggling(autoToggleEntry)
        end
        --# Set this to remember setting if AT Controller is
        --# destroyed and then rebuilt, so we only switch back on 
        --# the ones the player wants.        
        autoToggleEntry.HasATDisabled = data.DisableToggle
    end
end


--#*
--#*  Gilbot-X says:  
--#*
--#*  SIM callbacks.
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to change its priority position 
--#*  in the ordered priority list.
--#**
function SetPriorityToFirstOrLastInClassCallBack(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local autoToggleEntry = GetAutoToggleEntry(data.SelectedUnitEntityId, data.ResourceDrainId)
    --# Only pass on call if this is an autotoggle unit.
    if autoToggleEntry then
        ATSystem.EntryCommands.Reinsert(autoToggleEntry, data.Placement)
    end
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  SIM callback.
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to change its priority position 
--#*  in the ordered priority list.
--#**
function DecreasePriorityCallback(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local autoToggleEntry = GetAutoToggleEntry(data.SelectedUnitEntityId, data.ResourceDrainId)
    --# Only pass on call if this is an autotoggle unit.
    if autoToggleEntry then
        ATSystem.EntryCommands.DecreasePriority(autoToggleEntry)
    end
end

--#*
--#*  Gilbot-X says:  
--#*
--#*  SIM callback.
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to change its priority position 
--#*  in the ordered priority list.
--#**
function IncreasePriorityCallback(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local autoToggleEntry = GetAutoToggleEntry(data.SelectedUnitEntityId, data.ResourceDrainId)
    --# Only pass on call if this is an autotoggle unit.
    if autoToggleEntry then
        ATSystem.EntryCommands.IncreasePriority(autoToggleEntry)
    end
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  SIM callback.
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to change its priority position 
--#*  in the ordered priority list.
--#**
function DecreasePriorityClassCallback(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    for kUnusedArrayIndex, entityId in data.SelectedUnitEntityIds do
        local autoToggleEntry = GetAutoToggleEntry(entityId, data.ResourceDrainId)
        --# Only pass on call if this is an autotoggle unit.
        if autoToggleEntry then
            ATSystem.EntryCommands.DecreasePriorityClass(autoToggleEntry)
        end
    end
end

--#*
--#*  Gilbot-X says:  
--#*
--#*  SIM callback.
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to change its priority position 
--#*  in the ordered priority list.
--#**
function IncreasePriorityClassCallback(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    for kUnusedArrayIndex, entityId in data.SelectedUnitEntityIds do
        local autoToggleEntry = GetAutoToggleEntry(entityId, data.ResourceDrainId)
        --# Only pass on call if this is an autotoggle unit.
        if autoToggleEntry then
            ATSystem.EntryCommands.IncreasePriorityClass(autoToggleEntry)
        end
    end
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  SIM callback.
--#*  This function gets the unit selected, checks if 
--#*  it is an AutoToggle unit, and if it is, it 
--#*  calls the ACU function to change its priority position 
--#*  in the ordered priority list.
--#**
function SetPriorityClassCallback(data)
    --# Try to get an autotoggle unit from the ID passed by UI side.
    local autoToggleEntry = GetAutoToggleEntry(data.SelectedUnitEntityId, data.ResourceDrainId)
    --# Only pass on call if this is an autotoggle unit.
    if autoToggleEntry then
        ATSystem.EntryCommands.SetPriorityClass(autoToggleEntry, data.NewClass)
    end
end



--#*
--#*  Gilbot-X says:
--#*
--#*  USER state code called from keymapping.
--#*  I created this so that auto-toggle priorities 
--#*  can be changed by selecting auto-toggler units 
--#*  and using + and - on the keyboard numberpad. 
--#**
ChangeAutoTogglePriority = function(increaseOrDecrease)
    --# Find out what units are selected
    local unitsSelected = GetSelectedUnits()
    
    --# If exactly one unit is selected
    if unitsSelected 
    and (type(unitsSelected) == 'table') 
    and (table.getsize(unitsSelected) == 1)
    then 
        --# Make a sim call to change its priority
        local functionName = increaseOrDecrease .. 'AutoTogglePriority'
        --# Get entity Id to pass as argument
        local entityArg = unitsSelected[1]:GetEntityId()
        
        --# We need a resourceDrainId to pass 
        --# as argument in order do anything
        local resourceDrainId = nil
        --# Iterate through all the AutoToggle IDs
        for kResourceDrainId, vEntry in UnitData[entityArg].AutoToggleEntries do
            --# Take first one
            resourceDrainId = kResourceDrainId
            break
        end
        
        --# Invoke sim side code.
        SimCallback( 
          {  
            Func=functionName,
            Args={ 
              SelectedUnitEntityId= entityArg,
              ResourceDrainId = resourceDrainId,
            }
          }
        )
    end
    
end



--#*
--#*  Gilbot-X says:
--#*
--#*  USER state code called from keymapping.
--#*  I created this so that auto-toggle priorities 
--#*  can be changed by selecting auto-toggler units 
--#*  and using + and - on the keyboard numberpad. 
--#**
ChangeAutoTogglePriorityClass = function(increaseOrDecrease)
    
    --# Find out what units are selected
    local unitsSelected = GetSelectedUnits()
    
    --# If exactly one unit is selected
    if unitsSelected 
    and (type(unitsSelected) == 'table') 
    then 
        --# Make a sim call to change its priority
        local functionName = increaseOrDecrease .. 'AutoTogglePriorityClass'
        
        --# Get entity Id to access SIM sync
        local entityArg = unitsSelected[1]:GetEntityId()
        
        --# We need a resourceDrainId to pass 
        --# as argument in order do anything
        local resourceDrainId = nil
        --# Iterate through all the AutoToggle IDs
        for kResourceDrainId, vEntry in UnitData[entityArg].AutoToggleEntries do
            --# Take first one
            resourceDrainId = kResourceDrainId
            break
        end
        
        --# Make a list of entity Ids to pass as argument
        local unitEntityIdListArg = {} 
        --# Iterate through selected units...
        for unusedArrayIndex, vUnit in unitsSelected do
            --# Get entity Id to access SIM sync
            local unitEntityId = vUnit:GetEntityId()
            --# If this unit has the same AutoToggle entry
            --# and it is registered with the ACU
            if  UnitData[entityArg].AutoToggleEntries and 
                UnitData[entityArg].AutoToggleEntries[resourceDrainId] and
                UnitData[entityArg].AutoToggleEntries[resourceDrainId].IsRegisteredWithATSystem
            then
                --# Add this to units we'll chenge
                table.insert(unitEntityIdListArg, vUnit:GetEntityId())
            end
        end
        
        --# Invoke sim side code.
        SimCallback( 
          {  
            Func=functionName,
            Args={ 
              SelectedUnitEntityIds= unitEntityIdListArg,
              ResourceDrainId = resourceDrainId,
            }
          }
        )
    end
    
end