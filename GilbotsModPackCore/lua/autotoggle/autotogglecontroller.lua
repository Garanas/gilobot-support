--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  The unit that inherits this class controls 
--#**              Auto Toggle.  This is where a lot of AT code is.
--#**
--#****************************************************************************

local GilbotUtils = import('/mods/GilbotsModPackCore/lua/utils.lua')

--# This table has an entry for each army
--# referenced by an army Id string
--# obtained using repr(Unit.GetArmy(self))
--# Make it local so other files cannot manipulate it
--# directly.  This makes interface to other files
--# easier to understand. 
local AutoToggleControlTables = {}
--# This effects how often ACU will check auto-toggle.
--# It refers to wait time measured in seconds between checks.
local ATCyclePeriod = 2

    
--#*
--#*  Gilbot-X says:
--#*      
--#*  This is called from InitializeKnowledge(), which itself is  
--#*  called from an override of the ACU's Unit:OnCreate(), so I can
--#*  do variable initialization common to all ACUs at this time.
--#** 
InitializeAutoToggleSystem = function(ACUarg)
    
    --# Three tables, one for each tech level.
    if not AutoToggleControlTables[ACUarg.ArmyIdString] then 
        
        --# Create a table for this army
        AutoToggleControlTables[ACUarg.ArmyIdString] = {
            CategoryTables = {
                {{},{},{},{}},  --C-1 MassFabs
                {{},{},{},{}},  --C=2 for units that only get switched on when energy ratio storage is high
                {{},{},{},{}},  --C=3 for Intel
                {{},{},{},{}},  --C=4 for Stealth/Cloak
                {{},{},{},{}},  --C=5 for Mobile Shields
                {{},{},{},{}},  --C=6 for Shield Structures
            },

            --# When mass is full at start, these are not allowed on.
            MassFabsAreAllowedToBeOn = false,
            
            --# Initialise priority list used by
            --# switch on/off cycles.
            PriorityList = {},
            ControllerEntityIds = {},
            ATIsOn = true,
            AutoToggleManagementThreadHandle = nil,
            
            ClassThresholds = {
                Energy = {
                    0.99,
                    0.90,
                    0.50,
                    0.25,
                    0.20,
                    0.10,
                },
                Mass = {
                    0.30,
                    0.25,
                    0.20,
                    0.15,
                    0.10,
                    0.05,
                },          
            },
            MassFabThreshold = 0.50,
            
            --# This sets the minimum number of units of
            --# both mass and energy you can have before
            --# something MUST be turned off.
            --# This value overrides the ratio thresholds
            --# set at priority class levels.
            MinimumUnitsofResourceLeft = { 
                Energy = 100,
                Mass = 30,
            },

            --# Store reference to this just once
            AIBrain = ACUarg:GetAIBrain(),
        }
    end    
end
    

    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  This is called from InitializeKnowledge(), which itself is  
--#*  called from an override of the ACU's Unit:OnCreate(), so I can
--#*  do variable initialization common to all 3 ACUs at this time.
--#** 
local AddATController = function(armyIdStringArg, controllerEntityIdArg)
    --# Make sure control table has a reference to us
    table.insert(AutoToggleControlTables[armyIdStringArg].ControllerEntityIds, controllerEntityIdArg)
    
    --# If this is the first AT controller...
    if table.getsize(AutoToggleControlTables[armyIdStringArg].ControllerEntityIds) == 1 then
        --# Look at all types of registered auto-toggle units, 
        --# remove auto-toggle name/priority and extra toggle.
        for kUnitType, vAutoToggleTechTables in AutoToggleControlTables[armyIdStringArg].CategoryTables do
            for kTechLevel, vAutoToggleEntryTable in vAutoToggleTechTables do
                for kAutoToggleEntry, vAutoToggleEntry in vAutoToggleEntryTable do 
                    if vAutoToggleEntry.Unit:IsAlive() then
                        --# Remove auto-toggle toggle for this unit
                        if not vAutoToggleEntry.HasATDisabled 
                        then EntryCommands.StartToggling(vAutoToggleEntry)
                        else vAutoToggleEntry.Unit:DoUserSyncOfAutoToggleEntries()
                        end
                    end
                end
            end
        end

        --# If it was off because last unit dies, turn it on 
        AutoToggleControlTables[armyIdStringArg].ATIsOn = true
        --# Launch thread to auto switch on or off, if one not active already
        if not AutoToggleControlTables[armyIdStringArg].AutoToggleManagementThreadHandle then 
            AutoToggleControlTables[armyIdStringArg].AutoToggleManagementThreadHandle = 
                ForkThread(AutoToggleManagementThread, armyIdStringArg) 
        end
    end
end
        
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  This should be called when the ACU dies so it 
--#*  is obvious that autotoggle has been disabled on all units.
--#*  This is safe to be called more than once.
--#** 
local RemoveAutoToggleController = function(armyIdStringArg, controllerEntityIdArg)

    --# Make sure control table no longer has a reference to us
    AutoToggleControlTables[armyIdStringArg].ControllerEntityIds = 
        GilbotUtils.RemoveFromArrayByValue( 
            AutoToggleControlTables[armyIdStringArg].ControllerEntityIds, 
            controllerEntityIdArg,
            true
        )
  
    --# If there are no other units that can keep AT going....
    if table.getsize(AutoToggleControlTables[armyIdStringArg].ControllerEntityIds) == 0 then
        --# Stop update thread
        AutoToggleControlTables[armyIdStringArg].ATIsOn = false
        --# Look at all types of registered auto-toggle units, 
        --# remove auto-toggle name/priority and extra toggle.
        for kUnitType, vAutoToggleTechTables in AutoToggleControlTables[armyIdStringArg].CategoryTables do
            for kTechLevel, vAutoToggleEntryTable in vAutoToggleTechTables do
                for kAutoToggleEntry, vAutoToggleEntry in vAutoToggleEntryTable do 
                    if vAutoToggleEntry.Unit:IsAlive() then
                        --# Remove auto-toggle toggle for this unit
                        if not vAutoToggleEntry.HasATDisabled 
                        then EntryCommands.StopToggling(vAutoToggleEntry)
                        else vAutoToggleEntry.Unit:DoUserSyncOfAutoToggleEntries()
                        end
                    end
                end
            end
        end
    end
end

    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  I moved code here for units to be removed from
--#*  registration tables.  This can be called during a 
--#*  cleanup or when the user unregsiters a living unit.
--#**     
local RemoveFromAutoToggleRegistrationTable = function(armyIdStringArg, autoToggleEntryArg)

    --# Remove from nested table
    local index1 = autoToggleEntryArg.PriorityCategory
    local index2 = autoToggleEntryArg.Unit.TechLevel
    local bRemoved = false
    AutoToggleControlTables[armyIdStringArg].CategoryTables[index1][index2], bRemoved = 
        GilbotUtils.RemoveFromArrayByValue(
            AutoToggleControlTables[armyIdStringArg].CategoryTables[index1][index2], 
            autoToggleEntryArg, 
            true
        )
    if not bRemoved then
        --# This happens when a dead unit was cleaned up
        --# before this was called on it.
        if autoToggleEntryArg.Unit:IsAlive() then
            WARN('An AT registered unit not removed from AT registration ' 
            .. 'table during an unregistration call for it.  ' 
            .. 'Normally this happens when a unit is already cleaned up ' 
            .. 'if multiple units died at the same time.  However, this unit is not dead.'
            )
        end
    end
end
    
    
--#*
--#*  Gilbot-X says:
--#*
--#*  Update the priority list used by the toggle on/off cycles.
--#*  It mimicks a function table.removeByValue but also resets 
--#*  priority indicators on the items so user can see what the new 
--#*  priorities are.
--#**
local RemoveFromPriorityTableByValue = function(armyIdStringArg, autoToggleEntryArg)
    
    local newList = {}
    local newPriority = 1
    local startUpdatingDisplays = false
    local unitsToCleanUp = {}
    
    --# Copy over items we are keeping from the old list to a new one
    for oldPriorityListPosition, vAutoToggleEntry in AutoToggleControlTables[armyIdStringArg].PriorityList do
    
        if vAutoToggleEntry == autoToggleEntryArg then
            --# Do nothing. By not adding it to the new list, 
            --# we have just removed the unit we wanted to.
            autoToggleEntryArg.IsInAutoTogglePriorityList = false
            if autoToggleEntryArg.Unit:IsAlive() then
                --# This causes a sync.
                autoToggleEntryArg:SetPriorityListPosition(0)
            end
        --# This is not the unit we were told to remove...           
        --# Check if any clean-up needed before adding to new list.
        else 
            if vAutoToggleEntry.Unit:IsAlive() then
                --# Have we already removed the unit we wanted to?
                vAutoToggleEntry:SetPriorityListPosition(newPriority)
                --# Add it to the end of the new table
                table.insert(newList, vAutoToggleEntry)
                --# increase the priority position for ther next unit  
                newPriority = newPriority + 1
            else
                --# This next block is for debugging only.
                LOG('RemoveFromPriorityTableByValue: ' 
                 .. ' Cleaning up additional dead unit ' .. vAutoToggleEntry.Unit.DebugId 
                 .. ' found in ACU AutoToggleOffPriorityList.' 
                )
                --# Add this unit to list of units to remove from nested tables.
                table.insert(unitsToCleanUp, vAutoToggleEntry)
                vAutoToggleEntry.IsInAutoTogglePriorityList = false
            end
        end
    end
    
    --# Transfer result to our list variable
    AutoToggleControlTables[armyIdStringArg].PriorityList = newList 
    --# Return list of dead units that need
    --# to be removed (cleaned up) from nested 
    --# tables to calling code.
    return unitsToCleanUp
end
    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  I added this to be called by auto-toggle units
--#*  from their own class when created, to inform the ACU 
--#*  so they can be used by the ACU's Auto Power-down.
--#** 
local RemoveFromPriorityTableByValueWithCleanup = function(armyIdStringArg, autoToggleEntryArg)

    --# This will generate an updated priority list, 
    --# removing this unit and any other dead units from it.
    local unitsToCleanUpFromNestedTables = 
        RemoveFromPriorityTableByValue(armyIdStringArg, autoToggleEntryArg)
    
    --# Continue any clean-up of other dead units found.            
    --# Copy over items we are keeping from the old list to a new one
    for unusedArrayIndex, vAutoToggleEntry in unitsToCleanUpFromNestedTables do
        RemoveFromAutoToggleRegistrationTable(armyIdStringArg, vAutoToggleEntry)
    end
end



--#*
--#*  Gilbot-X says:
--#*      
--#*  I added this to be called by cleanup code in this class to remove dead entries
--#*  left in the table by concurrency problems. 
--#*  It is also called by the AutoToggleEntry class.
--#*  above which can be called by the unit itself
--#*  when it dies or when the player toggles off its auto-toggle.
--#** 
local UnregisterATEntry = function(armyIdStringArg, autoToggleEntryArg)
    --# If the user flagged to clean up nested table
    RemoveFromAutoToggleRegistrationTable(armyIdStringArg, autoToggleEntryArg)
    --# This will generate an updated priority list, 
    --# removing this unit and any other dead units from it.
    RemoveFromPriorityTableByValueWithCleanup(armyIdStringArg, autoToggleEntryArg)

    --# Need to set this here for the code 
    --# directly below it to work...
    autoToggleEntryArg.IsRegisteredWithATSystem = false
end


--#*
--#*  Gilbot-X says:
--#*      
--#*  I added this to be called by auto-toggle units
--#*  from their own class when created, to inform the ACU 
--#*  so they can be used by the ACU's Auto Power-down.
--#** 
local RegisterATEntry = function(armyIdStringArg, autoToggleEntryArg, placementArg)
    
    --# Perform safety first
    if autoToggleEntryArg.IsRegisteredWithATSystem then return end
    --# Block units that have no ACU as these are civilain units
    --# or units from dummy armies designed to be wreckage.
    if not AutoToggleControlTables[armyIdStringArg] then return end
    
    --# Set a default for this argument.  
    --# The possible options are 'FIRST' and 'LAST',
    --# whuch mean insert as the first or last (P=?) number 
    --# to be switched off in that class (C=? number)
    if not placementArg then placementArg = 'FIRST' end
 
    --# Keep a reference to the unit object
    local index1 = autoToggleEntryArg.PriorityCategory
    local index2 = autoToggleEntryArg.Unit.TechLevel
    table.insert(
        AutoToggleControlTables[armyIdStringArg].CategoryTables[index1][index2], 
        autoToggleEntryArg
    )
    
    --# Record action
    autoToggleEntryArg.IsRegisteredWithATSystem = true
    autoToggleEntryArg.Unit:DoUserSyncOfAutoToggleEntries()
end
    
    
    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  Update the priority list used by the toggle on/off cycles.
--#*  It inserts the new autotoggle unit into the ordered list 
--#*  according to its default priority level, which is set in the mod scripts.
--#*    
--#*  This function must be executed via the PerformCleanCycle function
--#*  so that when any dead entries are encountered, they are cleaned up,
--#*  and this function will be called again to complete the job.
--#** 
local InsertIntoPriorityTable = function(armyIdStringArg, autoToggleEntryArg, placementArg) 
    
    --# Perform safety
    if placementArg ~= 'FIRST' and placementArg ~= 'LAST' then 
        WARN('AutoToggle: InsertIntoPriorityTable: Bad argument ' .. repr(placementArg) 
        .. ' for placementArg. Must be "FIRST" or "LAST".'
        )
    end
    
    local newList = {}
    local newPriority = 1
    local alreadyPlaced = false

    --# Copy over items we are keeping from the old list to a new one
    for oldPriorityListPosition, vATEntryInList in AutoToggleControlTables[armyIdStringArg].PriorityList do
    
        --# Check if any clean-up needed
        if not vATEntryInList.Unit:IsAlive() then                
            --# This is used to defer clean up of dead table entry
            --# This next block is for debugging only.
            LOG('AutoToggle: InsertIntoPriorityTable: ' 
             .. ' Going to clean up dead unit ' .. vATEntryInList.Unit.DebugId 
             .. ' found in ACU AutoToggleOffPriorityList.' 
            )
            --# Abandon this cycle to perform clean-up.
            --# This must be executed with PerformCleanCycle
            --# so that once this entry is cleaned up, 
            --# this function will be called again.
            return vATEntryInList
                    
        --# First check for duplicates and abort if found
        elseif vATEntryInList == autoToggleEntryArg then
            WARN('AutoToggle: InsertIntoPriorityTable: '
             .. ' Attempted to add duplicate entry for ' .. autoToggleEntryArg.Unit.DebugId 
             .. ' to AutoToggleOffPriorityList.'
            )
            return
        
        --# Next, check flag to see if new unit has already been placed.  If it has...
        elseif alreadyPlaced then
            --# Re-label next unit (because priority will be one lower) and then copy over 
            vATEntryInList:SetPriorityListPosition(newPriority)
            table.insert(newList, vATEntryInList)
            --# increment index for next entry
            newPriority = newPriority + 1
        
        --# Check if this is the right place for insertion.
        elseif --# If we are to be the first in this category, insert before the first unit in the same category as us
            (placementArg == 'FIRST' and (vATEntryInList.PriorityCategory+1) > autoToggleEntryArg.PriorityCategory)
            or --# If we are to be the last in this category, insert before the first unit in the same category as us
            (placementArg == 'LAST' and vATEntryInList.PriorityCategory > autoToggleEntryArg.PriorityCategory)
        then
            --# This next block is for debugging only.
            --# This can be delete wheh debugging is done.
            if false then
                LOG('InsertIntoPriorityTable: ' 
                 .. ' Inserted toggle ' .. autoToggleEntryArg.ResourceDrainId 
                 .. ' on unit ' .. autoToggleEntryArg.Unit.DebugId 
                 .. ' into position= ' .. repr(newPriority)
                )
            end
            
            --# Insert new auto-toggle unit here and label priority
            autoToggleEntryArg:SetPriorityListPosition(newPriority)
            table.insert(newList, autoToggleEntryArg)
            --# Move to next position in list
            newPriority = newPriority + 1
            
            --# Put the unit from the list we compared against just after it
            vATEntryInList:SetPriorityListPosition(newPriority)
            table.insert(newList, vATEntryInList)
            --# increment index for next entry
            newPriority = newPriority + 1
            
            --# Future units all get shifted one position along
            alreadyPlaced = true
           
        else
            --# We haven't inserted it yet.
            --# Just do a straight copy
            vATEntryInList:SetPriorityListPosition(newPriority)   
            table.insert(newList, vATEntryInList)
            --# increment index for next entry
            newPriority = newPriority + 1
        end
        
    end
    
    --# If there were no units already in the list 
    --# that this unit should be inserted after, then 
    if not alreadyPlaced then
        --# This next block is for debugging only.
        --# This can be delete when debugging is done.
        if false then 
            LOG('AutoToggle: InsertIntoPriorityTable: ' 
             .. ' Appended toggle ' .. autoToggleEntryArg.ResourceDrainId
             .. ' on unit ' .. autoToggleEntryArg.Unit.DebugId 
             .. ' at final position= ' .. repr(newPriority)
            )
        end
        --# Put this in at the end
        autoToggleEntryArg:SetPriorityListPosition(newPriority)
        table.insert(newList, autoToggleEntryArg)
    end
    
    --# Transfer result to our list variable
    AutoToggleControlTables[armyIdStringArg].PriorityList = newList
    --# Assume the insert is always successful
    autoToggleEntryArg.IsInAutoTogglePriorityList = true
    
end
    
    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  Update the priority list used by the toggle on/off cycles.
--#*  It swaps the position of the unit selected with the unit before it.
--#*    
--#*  This function must be executed via the PerformCleanCycle function
--#*  so that when any dead entries are encountered, they are cleaned up,
--#*  and this function will be called again to complete the job.
--#** 
local DecreasePositionInPriorityTable = function(armyIdStringArg, autoToggleEntryArg) 
    
    --# The size of the table is also the index of the last position 
    --# in the table because these tables have 1 as the first index.
    local priorityTableSizeAndLastPosition = table.getsize(AutoToggleControlTables[armyIdStringArg].PriorityList)
    
    if false then
        --# This next block is for debugging only.
        --# This can be delete wheh debugging is done.
        LOG('AutoToggle: DecreasePositionInPriorityTable: ' 
         .. ' Called on unit ' .. autoToggleEntryArg.Unit.DebugId 
         .. ' with old P= ' .. repr(autoToggleEntryArg.PriorityListPosition)
         .. ' and there are ' .. repr(priorityTableSizeAndLastPosition) 
         .. ' units in the table.' 
        )
    end
    
    --# Can't swap if there are less than two units in the list!
    if priorityTableSizeAndLastPosition < 2 then return end
    
    --# Can't increase priority list position if the position is already the max value
    if autoToggleEntryArg.PriorityListPosition == 1 then return end
  
    --# We can do a swap.
    local newList = {}
    local newPriority = 1
    local swapSuccessful = false
    local doNothingPosition = autoToggleEntryArg.PriorityListPosition
    local doSwapPosition = autoToggleEntryArg.PriorityListPosition - 1
    
    --# Only swap if they are in the same Class, i.e. C=2
    if AutoToggleControlTables[armyIdStringArg].PriorityList[doSwapPosition].PriorityCategory ~=
    AutoToggleControlTables[armyIdStringArg].PriorityList[doNothingPosition].PriorityCategory 
    then return end
    
    --# This next block is for debugging only.
    --# This can be delete wheh debugging is done.
    if false then
        LOG('AutoToggle: DecreasePositionInPriorityTable: ' 
         .. ' Swapping ' .. AutoToggleControlTables[armyIdStringArg].PriorityList[doNothingPosition].Unit.DebugId 
         .. ' P=' .. repr(AutoToggleControlTables[armyIdStringArg].PriorityList[doNothingPosition].PriorityListPosition)
         .. ' with ' .. repr(AutoToggleControlTables[armyIdStringArg].PriorityList[doSwapPosition].Unit.DebugId) 
         .. ' P=' .. repr(AutoToggleControlTables[armyIdStringArg].PriorityList[doSwapPosition].PriorityListPosition)
        )
    end
    
    --# Copy over items we are keeping from the old list to a new one
    for oldPriorityListPosition, vAutoToggleEntry in AutoToggleControlTables[armyIdStringArg].PriorityList do
    
        --# Check if any clean-up needed
        if not vAutoToggleEntry.Unit:IsAlive() then
            --# This is used to defer clean up of dead table entry
            --# Abandon this cycle to perform clean-up.
            --# This must be executed with PerformCleanCycle
            --# so that once this entry is cleaned up, 
            --# this function will be called again.
            return vAutoToggleEntry
                    
        --# Check if this is the right place for insertion.
        --# If this unit in the list already has not had a custom priority set
        elseif oldPriorityListPosition == doNothingPosition then
            --# Do nothing
        elseif oldPriorityListPosition == doSwapPosition then

            --# The new unit that used to be after it 
            --# now goes in the position before it
            autoToggleEntryArg:SetPriorityListPosition(newPriority)
            table.insert(newList, autoToggleEntryArg)
 
            --# increment index for next entry
            newPriority = newPriority + 1
            
            --# This unit goes into the slot we left empty last time
            vAutoToggleEntry:SetPriorityListPosition(newPriority)
            table.insert(newList, vAutoToggleEntry)

            --# Move to current position in list
            newPriority = newPriority + 1
            
            --# Future units just get copied 
            swapSuccessful = true
        else
            --# Update anyway even if we arent swapping these 
            --# just in case there was a clean up
            vAutoToggleEntry:SetPriorityListPosition(newPriority)
            --# Just do a straight copy
            table.insert(newList, vAutoToggleEntry)
            
            --# increment index for next entry
            newPriority = newPriority + 1
        end
        
    end
    
    --# If the swap actually happened..
    if swapSuccessful then
        --# Transfer result to our list variable
        AutoToggleControlTables[armyIdStringArg].PriorityList = newList 
    end
    
end




--#*
--#*  Gilbot-X says:
--#*      
--#*  Update the priority list used by the toggle on/off cycles.
--#*  It swaps the position of the unit selected with the unit after it.
--#*    
--#*  This function must be executed via the PerformCleanCycle function
--#*  so that when any dead entries are encountered, they are cleaned up,
--#*  and this function will be called again to complete the job.
--#** 
local IncreasePositionInPriorityTable = function(armyIdStringArg, autoToggleEntryArg) 

    --# The size of the table is also the index of the last position 
    --# in the table because these tables have 1 as the first index.
    local priorityTableSizeAndLastPosition = table.getsize(AutoToggleControlTables[armyIdStringArg].PriorityList)
    
    --# This next block is for debugging only.
    --# This can be delete wheh debugging is done.
    if false then
        LOG('AutoToggle: IncreasePositionInPriorityTable: ' 
         .. ' Called on unit ' .. autoToggleEntryArg.Unit.DebugId 
         .. ' with old P= ' .. repr(autoToggleEntryArg.PriorityListPosition)
         .. ' and there are ' .. repr(priorityTableSizeAndLastPosition) 
         .. ' units in the table.' 
        )
    end
    
    --# Can't swap if there are less than two units in the list!
    if priorityTableSizeAndLastPosition < 2 then return end
    
    --# Can't increase priority list position if the position is already the max value
    if autoToggleEntryArg.PriorityListPosition == priorityTableSizeAndLastPosition then return end
  
    --# We can do a swap.
    local newList = {}
    local newPriority = 1
    local swapSuccessful = false
    --# Swap the unit called with the unit after it
    --# Insert this first
    local doSwapPosition = autoToggleEntryArg.PriorityListPosition + 1
    --# So we skip this in the iteration but add it later
    local doNothingPosition = autoToggleEntryArg.PriorityListPosition
    
    --# Only swap if they are in the same Class, i.e. C=2
    if AutoToggleControlTables[armyIdStringArg].PriorityList[doSwapPosition].PriorityCategory ~=
    AutoToggleControlTables[armyIdStringArg].PriorityList[doNothingPosition].PriorityCategory 
    then return end
    
    --# This next block is for debugging only.
    --# This can be delete wheh debugging is done.
    if false then 
        LOG('AutoToggle: IncreasePositionInPriorityTable: ' 
         .. ' Swapping ' .. AutoToggleControlTables[armyIdStringArg].PriorityList[doNothingPosition].Unit.DebugId 
         .. ' P=' .. repr(AutoToggleControlTables[armyIdStringArg].PriorityList[doNothingPosition].PriorityListPosition)
         .. ' with ' .. repr(AutoToggleControlTables[armyIdStringArg].PriorityList[doSwapPosition].Unit.DebugId) 
         .. ' P=' .. repr(AutoToggleControlTables[armyIdStringArg].PriorityList[doSwapPosition].PriorityListPosition)
        )
    end
    
    --# Copy over items we are keeping from the old list to a new one
    for oldPriorityListPosition, vAutoToggleEntry in AutoToggleControlTables[armyIdStringArg].PriorityList do
    
        --# Check if any clean-up needed
        if vAutoToggleEntry.Unit:BeenDestroyed() or vAutoToggleEntry.Unit:IsDead() then
            --# This is used to defer clean up of dead table entry
            --# Abandon this cycle to perform clean-up.
            --# This must be executed with PerformCleanCycle
            --# so that once this entry is cleaned up, 
            --# this function will be called again.
            return vAutoToggleEntry
                    
        --# Check if this is the right place for insertion.
        --# If this unit in the list already has not had a custom priority set
        elseif oldPriorityListPosition == doNothingPosition then
            --# Do nothing
        elseif oldPriorityListPosition == doSwapPosition then
            
            --# This unit goes into the slot we left empty last time
            vAutoToggleEntry:SetPriorityListPosition(newPriority)
            table.insert(newList, vAutoToggleEntry)

            --# Move to current position in list
            newPriority = newPriority + 1
            
            --# The new unit that used to be before it 
            --# now goes in the position after it
            autoToggleEntryArg:SetPriorityListPosition(newPriority)
            table.insert(newList, autoToggleEntryArg)

            --# increment index for next entry
            newPriority = newPriority + 1
            
            --# Future units just get copied 
            swapSuccessful = true
        else
            vAutoToggleEntry:SetPriorityListPosition(newPriority)
            --# Just do a straight copy
            table.insert(newList, vAutoToggleEntry)   
            --# increment index for next entry
            newPriority = newPriority + 1
        end
        
    end
    
    --# If the swap actially happened..
    if swapSuccessful then
        --# Transfer result to our list variable
        AutoToggleControlTables[armyIdStringArg].PriorityList = newList 
    end
    
end 
    

 
--#*
--#*  Gilbot-X says:
--#*      
--#*  Turn a single unit off, chosen according to order in priority list.
--#*
--#*  This function must be executed via the PerformCleanCycle function
--#*  so that when any dead entries are encountered, they are cleaned up,
--#*  and this function will be called again to complete the job.
--#*  Returns a reference to unit to clean up if any, otherwise return nil.
--#** 
local PerformToggleOffCycle = function(armyIdStringArg, classLimit, optionalArg) 

    --# Supply default value for safety
    if not classLimit then classLimit = 6 end
    local economyChanged = false
    
    --# Go through each unit in priority list
    for kPriority, vAutoToggleEntry in AutoToggleControlTables[armyIdStringArg].PriorityList do  
        
        --# Check for dead units.  This happens occaisionally (concurrency issue).
        if vAutoToggleEntry.Unit:BeenDestroyed() or vAutoToggleEntry.Unit:IsDead() then
            --# This is used to defer clean up of dead table entry,
            --# i.e. a new priority list will be drawn up and then this
            --# function will be called again.
            --# This next block is for debugging only.
            --# This can be delete wheh debugging is done.
            LOG('PerformToggleOffCycle:' 
            .. ' Dead unit ' .. vAutoToggleEntry.Unit.DebugId
            .. ' found in ACU AutoToggleOffPriorityList. Stopping cycle to cleanup.'
            )
            --# Abandon this cycle to perform clean-up
            return vAutoToggleEntry, economyChanged
        else
            --# Update its P number
            vAutoToggleEntry:SetPriorityListPosition(kPriority)
            --# Only switch off units in class N or lower
            if vAutoToggleEntry.PriorityCategory <= classLimit 
               --# Make sure the unit is actually switched on 
               --# before trying to switch off...
                and vAutoToggleEntry.On 
                --# This condition means we skip entries that don't use mass
                --# if that flag was set in the optional argument                
                and ((optionalArg ~= "MassConsumersOnly") or vAutoToggleEntry.Consumption.Mass)
                --# Don't let units auto-power on or off when under attack.
                and not vAutoToggleEntry.UnderAttack 
            then
                --# Test to see if switching this on/off makes any difference to our economy.
                if vAutoToggleEntry.Consumption.Energy > 0 then economyChanged = true end
                
                --# Switch it off regardless off 
                --# what energy or mass it is using.
                vAutoToggleEntry:SwitchOff() 
                --LOG('AT: Switching off ' .. vAutoToggleEntry.Unit.DebugId 
                --.. ' with optionalArg=' .. repr(optionalArg)
                --)
                --# Only stop here if we found 
                --# something that consumes energy  
                --# (or both mass and energy).
                if economyChanged then 
                    --# Signal to caller:
                    --# Nothing to clean up,
                    --# action was performed                
                    return nil, economyChanged
                end
            end
        end 
    end
end

    

--#*
--#*  Gilbot-X says:
--#*      
--#*  Turn a single unit on, chosen according to order in priority list.
--#*
--#*  As switching off priority uses the same ordered list as switching on priorty,
--#*  then we have to trawl through the nested tables in the opposite order
--#*  to how we did when switching units off.
--#*
--#*  This function must be executed via the PerformCleanCycle function
--#*  so that when any dead entries are encountered, they are cleaned up,
--#*  and this function will be called again to complete the job.
--#*  Returns a reference to unit to clean up if any, otherwise return nil.
--#*
--#*  This function is called only once per loop of the AT Management thread cycle.
--#*  The class argument specifies the lowest class that can be turned on.
--#*  It will start with the highest and go through all of them until it turns one on
--#*  (that affects the economy, i.e. will consume energy right away when turned on)
--#*  or until it has tried all entries that are up to the class limit specified.
--#*  Because the thresholds are checked in order from 1 to 6, we only need to do this
--#*  once in a loop because calling with a higher class number would just check 
--#*  a subset of the same entries we've already checked.
--#** 
local PerformToggleOnCycle = function(armyIdStringArg, classLimit, economySnapShot) 

    --# Supply default values for safety
    if not classLimit then classLimit = 1 end
    local economyChanged = false
    
    --# Go through each unit im priority list but in reverse order
    local reversedUnits = GilbotUtils.GetArrayReversed(AutoToggleControlTables[armyIdStringArg].PriorityList)
    local pMax = table.getsize(AutoToggleControlTables[armyIdStringArg].PriorityList)
    for kReversedIndex, vAutoToggleEntry in reversedUnits do       
        --# Work out what this unit's P number would be.
        --# Note that kReversedIndex starts at 0.
        local priorityIndex = pMax-(kReversedIndex)  

        --# This thread needs to die when the unit dies.
        if vAutoToggleEntry.Unit:BeenDestroyed() or vAutoToggleEntry.Unit:IsDead() then
            --# This is used to defer clean up of dead table entry
            --# i.e. a new priority list will be drawn up and then this
            --# function will be called again.
            --# This next block is for debugging only.
            --# This can be delete wheh debugging is done.
            LOG('PerformToggleOnCycle:' 
            .. ' Dead unit ' .. vAutoToggleEntry.Unit.DebugId
            .. ' found in ACU AutoToggleOffPriorityList. Stopping cycle to cleanup.'
            )
            --# Abandon this cycle to perform clean-up
            return vAutoToggleEntry, economyChanged
        else  
            vAutoToggleEntry:SetPriorityListPosition(priorityIndex)          
            --# Make sure it uses this resource
            if --# Only turn on those at class N or higher
              vAutoToggleEntry.PriorityCategory >= classLimit and 
              --# Make sure it's actually off 
              --# before trying to turn back on
              (not vAutoToggleEntry.On) and 
              --# This can be cleared, i.e. on Massfabs when there is full mass.
              vAutoToggleEntry.CanAutoToggleOnNow and
              --# Don't let units auto-power on or off when under attack.
              (not vAutoToggleEntry.UnderAttack) then
                
                local canSwitchBackOn = true
                --# Look at economy snapshot to check for a reason not to switch back on
                for kResourceTypeId, vConsumption in vAutoToggleEntry.Consumption do
                    --# What would be the rate per second of resource change 
                    --# if we switched this unit back on?
                    local potentialTrend = economySnapShot[kResourceTypeId].Trend - vConsumption
                    --# Some unit like shields need to recahnge, so there
                    --# is no point switching them back on for only 2 cycles!
                    local secondsToLeaveOn = math.max(vAutoToggleEntry.MinimumOnTime, (ATCyclePeriod * 2))
                    --LOG('AT: Minimum seconds on for ' .. vAutoToggleEntry.ResourceDrainId
                    --.. ' on unit ' .. vAutoToggleEntry.Unit.DebugId 
                    --.. ' is ' .. repr(secondsToLeaveOn)
                    --)
                    --# How much resource would be left after 2 cycles 
                    --# if we switched this unit back on?
                    local resourceLeftAbsoluteAfterOnForMinimumTime = 
                        economySnapShot[kResourceTypeId].StorageAbsolute + (potentialTrend * secondsToLeaveOn)
                    --# What would the ratio be after minimum on time 
                    --# if we switched this unit back on?
                    local resourceRatioAfterOnForMinimumTime = 
                        resourceLeftAbsoluteAfterOnForMinimumTime / economySnapShot[kResourceTypeId].StorageAbsoluteMax
                    if resourceRatioAfterOnForMinimumTime > 1 then resourceRatioAfterOnForMinimumTime = 1 end
                    
                 
                    --# If any resource would be left to stop our shields from cutting...
                    local ratioThreshold = AutoToggleControlTables[armyIdStringArg].ClassThresholds[kResourceTypeId][vAutoToggleEntry.PriorityCategory]
                    --LOG('AT: Ratio after on=' .. repr(resourceRatioAfterOnForMinimumTime) .. ' out of ' .. repr(ratioThreshold))
                    if (resourceLeftAbsoluteAfterOnForMinimumTime < AutoToggleControlTables[armyIdStringArg].MinimumUnitsofResourceLeft[kResourceTypeId]) or 
                       (resourceRatioAfterOnForMinimumTime < ratioThreshold)
                    then 
                        canSwitchBackOn = false 
                        --LOG('AT: Cannot switch back on ' .. vAutoToggleEntry.ResourceDrainId 
                        --.. ' on' .. vAutoToggleEntry.Unit.DebugId
                        --)                        
                    end
                end
                
                --# If no reason was found
                --# why we could not switch back on
                if canSwitchBackOn then 
                
                    --# Test to see if switching this on/off makes any difference to our economy.
                    if vAutoToggleEntry.Consumption.Energy > 0 then economyChanged = true end
                    --LOG('AT: Switching on ' .. vAutoToggleEntry.Unit.DebugId)
                    --# Turn the unit on
                    vAutoToggleEntry:SwitchOn() 

                    --# Only stop here if we found 
                    --# something that consumes energy  
                    --# (or both mass and energy).
                    if economyChanged then 
                        --# Signal to caller:
                        --# Nothing to clean up,
                        --# action was performed                
                        return nil, economyChanged
                    end
                else
                    --# This unit was next in line to be switched on 
                    --# but we didn't have enough energy or mass.
                    --# Do we skip it and turn on something with a 
                    --# lower priority number, or do we wait until
                    --# we have more energy and mass?
                    --# This function is only run once per loop,
                    --# so to not skip this, just return.
                    if not vAutoToggleEntry.Consumption.Mass then
                        --# Signal to caller:
                        --# Nothing to clean up,
                        --# no action was performed                
                        return nil, economyChanged
                    end                    
                end
            end
        end
    end
end
    
    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  This is repeated code from AutoToggleManagementThread which 
--#*  I separated into its own function for good code modularity.
--#** 
local PerformCleanCycle = function(armyIdStringArg, functionRef, optionalArg1, optionalArg2, optionalArg3)
    
    --# Use vAutoToggleEntryToCleanUp to record reference to any dead unit 
    --# that needs to be cleaned up from auto-toggle table
    local ATEntryToCleanUp = true
    local returnArg2 = nil
    while ATEntryToCleanUp do
        
        --# Don't do another pass unless we have 
        --# to stop next one to do a table clean-up.
        ATEntryToCleanUp, returnArg2 =
            --# Do cycle which will traverse tables and 
            --# potentially examine all tables and unit entries
            functionRef(armyIdStringArg, optionalArg1, optionalArg2, optionalArg3)
        
        --# If a dead unit was found in one of the tables,
        --# it will have ben recorded and traverse exited prematurely.
        if ATEntryToCleanUp and ATEntryToCleanUp.IsAutoToggleEntry then
            --# Do the clean up, i.e. remove the unit from the table
            UnregisterATEntry(armyIdStringArg, ATEntryToCleanUp, true, true)
            --# Prevent another access to that unit now that its been cleaned up
            ATEntryToCleanUp = true
        end
    end
    
    --# Only some of the functions
    --# will return this, so it can be nil.
    return returnArg2
end

    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  Just switch off all units in thsi table unconditionally
--#*  or mark all of them as allowed to be switched back on.
--#*  Note: Doesn't do any clean-up.
--#** 
local AllowMassFabsToBeOn = function(armyIdStringArg, toggleCanBeOn) 
    --# We will return this value...
    local actionPerformedThisLoop = false

    --# Go through all units registered....
    for kPriority, vAutoToggleEntry in AutoToggleControlTables[armyIdStringArg].PriorityList do
        vAutoToggleEntry:SetPriorityListPosition(kPriority)
        --# Make sure it's a massfab and not dead (don't worry about cleaning up here)
        if vAutoToggleEntry.Unit.IsMassFabricationUnit and vAutoToggleEntry.Unit:IsAlive() then
            --# If we are allowing them to be on...
            if toggleCanBeOn then 
                --# Allow it to be on but don't do any switching on.
                vAutoToggleEntry.CanAutoToggleOnNow = true
            else
                --# switch it off and make sure it can't come back on
                --# until this function is called again with the opposite
                --# argument.
                if vAutoToggleEntry.On then
                    actionPerformedThisLoop = true                    
                    vAutoToggleEntry:SwitchOff()
                end
                vAutoToggleEntry.CanAutoToggleOnNow = false
            end
        end 
    end
    
    --# Record this state
    AutoToggleControlTables[armyIdStringArg].MassFabsAreAllowedToBeOn = toggleCanBeOn
    
    --# Signal to calling code if AT did anything in this loop
    return actionPerformedThisLoop
end
    
    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  This is called by AutoToggleManagementThread.
--#*  It checks conditions for the class provided
--#*  and takes an action if necessary, and returns status
--#*  if whether or not it did anything to calling code.    
--#** 
local GoThroughAllEnergyConsumers = function(armyIdStringArg, economySnapShot)
    --# Use this flag to signal if we made
    --# a change that will affect the economy.
    local actionPerformedThisLoop = false
    for C = 1, 6 do
        --# Remember: We've already iterated through the mass thresholds and turned
        --# off any units we could in each C when we were below one.
        --# If we are here, then either we are above all the mass thresholds,
        --# or there are no more mass consuming operations left that we can pause.
        --# This cycle can turnm mass consumers back on but will make sure first
        --# that turning them back on will not breach a mass threshold,
        --# otherwise the entry will be skipped.       
        if economySnapShot['Energy'].StorageRatio > AutoToggleControlTables[armyIdStringArg].ClassThresholds['Energy'][C] then 
            --# A toggle on cycle should only be done once if the C numbers
            --# are increasing, as increasing the C just limits what you can 
            --# turn on each time, so you are not doing anything new.
            if (not AutoToggleControlTables[armyIdStringArg].HasDoneToggleOnCycleThisLoop) then
                --# Turn the next highest priority thing 
                --# back on that won't breach this threshold in
                --# our energy reserves in the next 2 cycles.
                AutoToggleControlTables[armyIdStringArg].HasDoneToggleOnCycleThisLoop = true
                actionPerformedThisLoop = PerformCleanCycle(armyIdStringArg, PerformToggleOnCycle, C, economySnapShot)
            end
            --# Safe to return now, as if we are above
            --# threshold for class C=n then we must also 
            --# be above threshold for class C=n+1, as the
            --# thresholds decrease as C gets higher.
            return actionPerformedThisLoop
        else 
            --# Turn the next one off
            actionPerformedThisLoop = PerformCleanCycle(armyIdStringArg, PerformToggleOffCycle, C) 
            if actionPerformedThisLoop then return actionPerformedThisLoop end
        end
    end
    --# This will still be false
    --# if we got here
    return actionPerformedThisLoop
end



--#*
--#*  Gilbot-X says:
--#*      
--#*  This is called by AutoToggleManagementThread.
--#*  It checks conditions for mass consumers to be on,
--#*  and switches any off if necessary, and returns status
--#*  if whether or not it did anything to calling code.
--#*
--#*  When mass and energy are both below thresholds, 
--#*  turning off mass consumers first is a natural choice,
--#*  beause it will affect both the mass and energy trends of the
--#*  economy.  If we first turned off a bunch of units that 
--#*  only consume energy, our mass could still be zero,
--#*  and we would still have to go back afterwards and turn 
--#*  off mass consumers until our mass was OK.  By this time,
--#*  we could have a surplus of energy! Instead,
--#*  if mass and energy are both low, if we first turn
--#*  off a unit that consumes both, we might solve both
--#*  our mass and energy deficits in one action.
--#*  When things are turned back on, it is done according
--#*  to P number, regardless of whether or not unit consumes 
--#*  mass (as long as the economy can support it being turned
--#*  back on; thresholds are checked again to ensure this.) 
--#** 
local WasMassConsumerToggledOff = function(armyIdStringArg, economySnapShot)
    --# Use this flag to signal if we made
    --# a change that will affect the economy.
    local actionPerformedThisLoop = false
    for C = 1, 6 do
        if economySnapShot['Mass'].StorageRatio < AutoToggleControlTables[armyIdStringArg].ClassThresholds['Mass'][C] then 
            --# Turn the next one off
            actionPerformedThisLoop = PerformCleanCycle(armyIdStringArg, PerformToggleOffCycle, C, "MassConsumersOnly") 
            if actionPerformedThisLoop then return actionPerformedThisLoop end
        end
    end
    --# This will still be false
    --# if we got here
    return actionPerformedThisLoop
end




--#*
--#*  Gilbot-X says:
--#*      
--#*  This thread periodically checks if this unit should be on or off.
--#*  The check itself is defered to code in CheckAutoPowerConditions.
--#** 
AutoToggleManagementThread = function(armyIdStringArg) 

    --# Keep doing this while at least one controller is alive
    while AutoToggleControlTables[armyIdStringArg].ATIsOn do
    
        --# At the start of loop, reset loop-time variables that 
        --# have recorded what happened during the previous loop        
        AutoToggleControlTables[armyIdStringArg].HasDoneToggleOnCycleThisLoop = false
    
        --# Get a snapshot of the economy
        local aiBrain = AutoToggleControlTables[armyIdStringArg].AIBrain 
        local economySnapShot= {Energy ={}, Mass = {}}
        for kResourceTypeId, vTable in economySnapShot do
            local resourceTypeId = string.upper(kResourceTypeId)
            vTable.Trend = aiBrain:GetEconomyTrend(resourceTypeId) * 10
            vTable.StorageAbsolute = aiBrain:GetEconomyStored(resourceTypeId)
            vTable.StorageRatio = aiBrain:GetEconomyStoredRatio(resourceTypeId)
            vTable.StorageAbsoluteMax = math.ceil(vTable.StorageAbsolute / vTable.StorageRatio)
        end
        
        local actionPerformedThisLoop = false

        --# If we have full storage for mass, 
        --# then don't allow any massfabs to be on.  
        --# We don't want to waste energy on massfabs 
        --# or even let economy indicators show income 
        --# with wasteful massfabs on.
        if economySnapShot.Mass.StorageRatio < 1 and 
          economySnapShot.Energy.StorageRatio > AutoToggleControlTables[armyIdStringArg].MassFabThreshold then 
            --# Allow them to get switched on when its their turn in the queue
            if not AutoToggleControlTables[armyIdStringArg].MassFabsAreAllowedToBeOn then 
                AllowMassFabsToBeOn(armyIdStringArg, true)
            end
        else 
            --# Force them all to be turned off now and stay off
            if AutoToggleControlTables[armyIdStringArg].MassFabsAreAllowedToBeOn then 
                --# if there were any on, this is all we do this round 
                actionPerformedThisLoop = AllowMassFabsToBeOn(armyIdStringArg, false)
            end
        end
        
        --# If we didn't turn anything on/off already in this loop...
        if not actionPerformedThisLoop then
            --# If mass will run out (fall below 10 units left) 
            --# in next 2 cycles of this management thread... 
            --# (each cycle is an instance where this loop runs
            --#  and CyclePeriod is how long this thread waits between loops)
            local massLeftAfter2Seconds = economySnapShot.Mass.StorageAbsolute + 
                (economySnapShot.Mass.Trend * ATCyclePeriod * 2)        
            if massLeftAfter2Seconds < AutoToggleControlTables[armyIdStringArg].MinimumUnitsofResourceLeft['Mass'] then
                --# Switch off the next least essential unit
                --# all the way to C=6 (C=1,2,3 are already off)
                actionPerformedThisLoop = PerformCleanCycle(armyIdStringArg, PerformToggleOffCycle, 6, "MassConsumersOnly")
            end
            --# Mass was OK or a mass consumer could
            --# not be toggled off...
            if not actionPerformedThisLoop then
                --# Now do the same check for energy
                local energyLeftAfter2Seconds = economySnapShot.Energy.StorageAbsolute + 
                    (economySnapShot.Energy.Trend * ATCyclePeriod * 2)        
                if energyLeftAfter2Seconds < AutoToggleControlTables[armyIdStringArg].MinimumUnitsofResourceLeft['Energy'] then
                    --# Switch off the next least essential unit
                    --# all the way to C=6 (C=1,2,3 are already off).
                    --# If this can't switch anything off, nothing can
                    --# and we shouldn't try to turn anything back on.
                    PerformCleanCycle(armyIdStringArg, PerformToggleOffCycle, 6)
                elseif not WasMassConsumerToggledOff(armyIdStringArg, economySnapShot) then 
                    --# This loop will perform one action only.
                    --# On the last iteration when class=6, 
                    GoThroughAllEnergyConsumers(armyIdStringArg, economySnapShot)
                end
            end
        end

        --# Delay between cycles needs to allow 
        --# for economy changes to take effect and 
        --# must reduce burden on CPU, but not be too
        --# slow so that auto-toggle is less desireable than
        --# micro-managing toggles.           
        WaitSeconds(ATCyclePeriod)
    end
    
    --# This thread is ending so end block on launching new threads
    AutoToggleControlTables[armyIdStringArg].AutoToggleManagementThreadHandle = nil
end
    
    
    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  This table is used like a namespace.
--#** 
EntryCommands = {

    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from autotoggleunit.lua when unit is  
    --#*  created or an enhancement is added.
    --#** 
    Register = function(autoToggleEntryArg)
        RegisterATEntry(autoToggleEntryArg.Unit.ArmyIdString, autoToggleEntryArg)
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from autotoggleunit.lua when unit is  
    --#*  destroyed or an enhancement is removed.
    --#** 
    Unregister = function(autoToggleEntryArg)
        --# Don't let this be called when the autotoggle is already unregistered
        if autoToggleEntryArg.IsRegisteredWithATSystem then
            --# Replace button that manually toggles ability
            UnregisterATEntry(autoToggleEntryArg.Unit.ArmyIdString, autoToggleEntryArg) 
            autoToggleEntryArg.Unit:DoUserSyncOfAutoToggleEntries()
        end
    end,

    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from function AddATController and from 
    --#*  Sim Callbacks in autotogglecallbacks.lua when the
    --#*  ON button in the ST menu is checked.
    --#** 
    StartToggling = function(autoToggleEntryArg)
        --# Perform safety
        if (not autoToggleEntryArg.IsRegisteredWithATSystem) or 
          autoToggleEntryArg.IsInAutoTogglePriorityList then return end
        --# We cache this to access AT table values  
        local armyIdString = autoToggleEntryArg.Unit.ArmyIdString
        
        --# First need to work out if this toggle was on or off:
        autoToggleEntryArg:SetATOnStateFromUnitToggleState()
        
        --# Mark all massfabs in case they move class
        if autoToggleEntryArg.Unit.IsMassFabricationUnit then
            --# Disable if need be
            if AutoToggleControlTables[armyIdString].MassFabsAreAllowedToBeOn then 
                autoToggleEntryArg.CanAutoToggleOnNow = true
            else
                --# switch it off and make sure it can't come back on
                --# until this function is called again with the opposite
                --# argument. Do not update display now - that is
                --# always done below when unit is inserted into P table.               
                autoToggleEntryArg:SwitchOff()
                autoToggleEntryArg.CanAutoToggleOnNow = false
            end
        end
    
        --# Allow AT to toggle this unit on Energy
        PerformCleanCycle(armyIdString, InsertIntoPriorityTable, autoToggleEntryArg, "FIRST")
        
        --# Remove button that manually toggles ability
        --# if not a construction toggle
        if autoToggleEntryArg.PowerDownToggleBit ~= 9 then 
            autoToggleEntryArg.Unit:RemoveToggleCap(autoToggleEntryArg.PowerDownToggleName)
        end
        --# Refresh sync of data and display text for UI
        autoToggleEntryArg.Unit:DoUserSyncOfAutoToggleEntries()
        return true
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from function RemoveAutoToggleController and from 
    --#*  Sim Callbacks in autotogglecallbacks.lua when the
    --#*  ON button in the ST menu is unchecked
    --#** 
    StopToggling = function(autoToggleEntryArg)
        --# Perform safety
        if not (  autoToggleEntryArg.IsRegisteredWithATSystem 
              and autoToggleEntryArg.IsInAutoTogglePriorityList)              
        then return end
        
        --# Do not allow AT to toggle this unit on energy
        RemoveFromPriorityTableByValueWithCleanup(autoToggleEntryArg.Unit.ArmyIdString, autoToggleEntryArg)
      
        --# Replace button that manually toggles ability
        if autoToggleEntryArg.Unit:IsAlive() then
            --# if not a construction toggle
            if autoToggleEntryArg.PowerDownToggleBit ~= 9 then
                autoToggleEntryArg:ReplaceOriginalButton()
            end
            --# Refresh sync of data and display text for UI
            autoToggleEntryArg.Unit:DoUserSyncOfAutoToggleEntries()
        end
    end,
    
        
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from Sim Callbacks in autotogglecallbacks.lua
    --#*  when they are configured from the new menu
    --#*  to set their (P=? number) priorities to the highest 
    --#*  or lowest in their class (C=? number)
    --#** 
    Reinsert = function(autoToggleEntryArg, placementArg)
        --# Set a default for this argument.  
        --# The possible options are 'FIRST' and 'LAST',
        --# whuch mean insert as the first or last (P=?) number 
        --# to be switched off in that class (C=? number)
        if not placementArg then placementArg = 'FIRST' end
        --# This will generate an updated priority list, 
        --# removing this unit and any other dead units from it.
        RemoveFromPriorityTableByValueWithCleanup(autoToggleEntryArg.Unit.ArmyIdString, autoToggleEntryArg, 'Energy')
        --# This will generate a new priority list,
        --# removing any dead units from it.
        PerformCleanCycle(autoToggleEntryArg.Unit.ArmyIdString, InsertIntoPriorityTable, autoToggleEntryArg, placementArg, 'Energy')
    end,


    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from Sim Callbacks in autotogglecallbacks.lua
    --#*  when the minus button is pressed or the CTL-NUMMINUS hotkey
    --#** 
    DecreasePriority = function(autoToggleEntryArg)
        PerformCleanCycle(autoToggleEntryArg.Unit.ArmyIdString, DecreasePositionInPriorityTable, autoToggleEntryArg, 'Energy')
    end,
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from Sim Callbacks in autotogglecallbacks.lua
    --#*  when the plus button is pressed or the CTL-NUMPLUS hotkey
    --#** 
    IncreasePriority = function(autoToggleEntryArg)
        PerformCleanCycle(autoToggleEntryArg.Unit.ArmyIdString, IncreasePositionInPriorityTable, autoToggleEntryArg, 'Energy')
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from Sim Callbacks in autotogglecallbacks.lua
    --#*  when the minus button is pressed or the ALT-NUMMINUS hotkey
    --#** 
    DecreasePriorityClass = function(autoToggleEntryArg)
        if autoToggleEntryArg.PriorityCategory > 1 then
            SetPriorityClass(autoToggleEntryArg, autoToggleEntryArg.PriorityCategory - 1)
        end
    end,
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from Sim Callbacks in autotogglecallbacks.lua
    --#*  when the plus button is pressed or the ALT-NUMPLUS hotkey
    --#** 
    IncreasePriorityClass = function(autoToggleEntryArg)
        if autoToggleEntryArg.PriorityCategory ~= 6 then
            SetPriorityClass(autoToggleEntryArg, autoToggleEntryArg.PriorityCategory + 1)
        end
    end,
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from Sim Callbacks in autotogglecallbacks.lua
    --#*  when the combo box in the AT config window is set.
    --#** 
    SetPriorityClass = function(autoToggleEntryArg, newClassArg)
        autoToggleEntryArg.Unit.StopSync = true
        UnregisterATEntry(autoToggleEntryArg.Unit.ArmyIdString, autoToggleEntryArg)
        autoToggleEntryArg.PriorityCategory = newClassArg
        RegisterATEntry(autoToggleEntryArg.Unit.ArmyIdString, autoToggleEntryArg)
        if not autoToggleEntryArg.HasATDisabled then EntryCommands.StartToggling(autoToggleEntryArg) end
        autoToggleEntryArg.Unit.StopSync = false
        autoToggleEntryArg.Unit:DoUserSyncOfAutoToggleEntries()
    end,
}    
    
    
    
--#*
--#*  Gilbot-X says:
--#*      
--#*  Use this as a secondary base class in the ACU script files.
--#*  I made this class so I could add extra functionality to all 3 ACUs 
--#*  without mixing my code in the same file as GPG's code. 
--#** 
MakeAutoToggleController = function(baseClassArg)

local resultClass = Class(baseClassArg) {  
   
    --# This flag gives us a quick way to test
    --# if a unit is inheriting this abstract class
    IsAutoToggleController = true,

    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnStopBeingBuilt so I could 
    --#*  check for extended adjacency at this time.
    --#** 
    OnStopBeingBuilt = function(self,builder,layer)
        --# Perform original class version first
        baseClassArg.OnStopBeingBuilt(self,builder,layer)
        --# Append specific code
        self:InitialiseATController()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This is called from InitializeKnowledge(), which itself is  
    --#*  called from an override of the ACU's Unit:OnCreate(), so I can
    --#*  do variable initialization common to all 3 ACUs at this time.
    --#** 
    InitialiseATController = function(self)
        --# Make sure control table has a reference to us
        AddATController(self.ArmyIdString, self:GetEntityId())
        
        --# By default switch AutoToggle button on so
        --# that newly built units have their auto-toggle engaged
        self.ActivateAutoToggleOnNewlyBuiltUnits = true
        if not self:GetScriptBit('RULEUTC_WeaponToggle') then
            --# Switch auto-toggle on
            self:SetScriptBit('RULEUTC_WeaponToggle', true)
        end
        
        --# If the Pipeline is no longer working for us,
        --# the callback updates its status.
        self:AddOnCapturedCallback(self.ATControllerOnDestroyCallaback)
    end, 
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my slider control.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#*
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        newStatValue = math.floor(newStatValue)
        if statType == "AutoToggleClass3Threshold" then 
            AutoToggleControlTables[self.ArmyIdString].ClassThresholds['Energy'][3] = newStatValue/100
            self:FlashMessage("C=3 on when Energy > " .. repr(newStatValue) .. "%",2)
        elseif statType == "AutoToggleMassFabThreshold" then 
            AutoToggleControlTables[self.ArmyIdString].MassFabThreshold = newStatValue/100
            self:FlashMessage("MassFabs on when Energy > " .. repr(newStatValue) .."%",2)
        elseif statType == "EnergyReserve" then 
            AutoToggleControlTables[self.ArmyIdString].MinimumUnitsofResourceLeft['Energy'] = newStatValue
            self:FlashMessage("Energy Reserve = " .. repr(newStatValue),2)
        elseif statType == "MassReserve" then 
            AutoToggleControlTables[self.ArmyIdString].MinimumUnitsofResourceLeft['Mass'] = newStatValue
            self:FlashMessage("Mass Reserve = " .. repr(newStatValue),2)
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that tables are 
    --#*  cleaned up when a unit completes an upgrade and 
    --#*  destroys itself.
    --#*
    --#*  This function is defined in Unit.lua
    --#*  and ends by changing state to DeadState
    --#*  so I have to call my extra code before calling
    --#*  the base class code.
    --#**
    ATControllerOnDestroyCallaback = function(self)
        --# Gilbot-X says:  
        --# I added this block of code so that when 
        --# units upgrade they get cleaned out of ResourceNetwork 
        --# tables and the ACU's auto-toggle tables.
        RemoveAutoToggleController(self.ArmyIdString, self:GetEntityId())
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that 
    --#*  Auto-toggle and ResourceNetworks are not used 
    --#*  when ACU dies.
    --#*
    --#*  This function is defined in Unit.lua
    --#*  and ends by changing state to DeadState
    --#*  so I have to call my extra code before calling
    --#*  the base class code.
    --#**
    OnDestroy = function(self)
        --# Gilbot-X says:  
        --# I added this call so that Auto-toggle
        --# and ResourceNetworks are not used 
        --# when ACU dies.
        self:ATControllerOnDestroyCallaback()
        --# Finally the rest is GPG code.
        baseClassArg.OnDestroy(self)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  These functions are called when the weapon-toggle button
    --#*  (which I use as the auto-pause toggle button) using bit 1
    --#*  is pressed.  They are called from my override of OnScriptBitSet
    --#*  and OnScriptBitClear defined in my hook of Unit.lua.
    --#**
    OnScriptBit1Clear = function(self)
        self.ActivateAutoToggleOnNewlyBuiltUnits = false      
    end,

    OnScriptBit1Set = function(self)
        self.ActivateAutoToggleOnNewlyBuiltUnits = true
    end,
    
}

return resultClass

end--(of Class making function)


--#*
--#*  Gilbot-X says:
--#*
--#*  These functions are called from autotoggleentry.lua
--#*  and autotoggleunit.lua.
--#**
GetAutoToggleController = function(armyIdStringArg)
    if table.getsize(AutoToggleControlTables[armyIdStringArg].ControllerEntityIds) > 0 then
        return GetEntityById(AutoToggleControlTables[armyIdStringArg].ControllerEntityIds[1])
    else return nil end
end

--#*
--#*  Gilbot-X says:
--#*
--#*  These functions are called from autotoggleentry.lua
--#*  and autotoggleunit.lua.
--#**
DoesArmyHaveATSystem = function(armyIdStringArg)
    if AutoToggleControlTables[armyIdStringArg] 
    then return true
    else return false 
    end
end