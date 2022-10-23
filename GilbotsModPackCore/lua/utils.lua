--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/utils.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  
--#**      Utilities for manipulating tables used in many of my scripts.
--#**      These are alternatives to versions by GPG which I made 
--#**      because I wanted different behaviour.
--#** 
--#****************************************************************************

--# This is used for debugging only
local hasWarnedAboutACU = {}


--#*
--#*  Gilbot-X says:
--#*      
--#*  Common code used by functions below as a safe way to  
--#*  make that unit returned is a valid alive ACU.
--#** 
local function SafeACUReturn(acuUnitArg, armyId)
    local armyIdString = repr(armyId)
    --# Don't return a dead unit!
    if not acuUnitArg then 
        if not hasWarnedAboutACU[armyIdString] then
            LOG('Tried to get ACU for army=' .. armyIdString  
            .. " but nothing was returned. "
            .. " Maybe this is a civilian army or "
            .. " this army's ACU was just killed?"
            )
            hasWarnedAboutACU[armyIdString] = true
        end
        return nil 
    end
    --# The BeenDestroyed test only works in the SIM state
    --if acuUnitArg:BeenDestroyed() then return nil end
    if acuUnitArg:IsDead() then 
        if not hasWarnedAboutACU[armyIdString] then
            LOG('Tried to get ACU for army=' .. repr(armyIdString) 
            .. ' but the unit returned was dead.'
            .. " Maybe this army's ACU was just killed?"
            )
            hasWarnedAboutACU[armyIdString] = true
        end
        return nil 
    end
    --# The next test is only for games not played in 
    --# Assassin mode, because if the gmae is played
    --# with other victory conditions, the ACU can be 
    --# killed and then whatever is built next will
    --# take the ACU's old entity ID.  So we need to 
    --# test of the unit is actually an ACU!
    if not (EntityCategoryContains(categories.COMMAND, acuUnitArg)) then 
            --# Entity ids get reused when units die. The ACUs entity ID 
            --# will be used by another unit when you are not playing Assassin mode.
            if not hasWarnedAboutACU[armyIdString] then
                LOG('Tried to get ACU for army=' .. repr(armyIdString) 
                .. ' but something else was returned instead: '
                .. ' UnitId=' .. repr(acuUnitArg:GetUnitId())
                .. " Maybe this is a civilian army"
                .. " or maybe this army's ACU was just killed?"
                )
                hasWarnedAboutACU[armyIdString] = true
            end
        return nil 
    end
    return acuUnitArg
end


--#*
--#*  Gilbot-X says:
--#*      
--#*  ACUs can store information for the whole army
--#*  and be referenced throughout their lifetime.
--#*  If you are playing non-assassin mode and you 
--#*  lose your commander, then tough, you lose your 
--#*  army's data!
--#*
--#*  If you are playing with Victory conditions set to 
--#*  Supremacy, Annihilation or Sandbox, then whatever is
--#*  built first after the ACU does will get its entity id.
--#*  This function returns nil if that has happened.
--#*  In all versions of SC and FA, 1048576 was the multiple
--#*  that could be used to calculate the first entity built
--#   for each army, which is always the ACU when it warps in.
--#** 
GetCommanderFromArmyId = function(myArmyId)
    return SafeACUReturn(GetUnitById(((myArmyId -1) * 1048576)), myArmyId)
end
GetFocusArmyACU = function()
    return GetCommanderFromArmyId(GetFocusArmy())
end
GetACUEntityIdFromArmyId = function(myArmyId)
    return repr((myArmyId -1) * 1048576)
end
GetFocusArmyACUId = function()
    return GetACUEntityIdFromArmyId(GetFocusArmy())
end


--#*
--#*  Gilbot-X says:
--#*
--#*  I added this to mimick the function table.remove it but returns false
--#*  if table is empty and doesn't leave any nil keys in the table.
--#*  It also works on tables with string keys as well as arrays.
--#**
function RemoveFromTableByKey(tableArg, keyArg, optionalLeaveEmptyTable)
    --# Do this for safety because when ACU dies, we get problems.
    if type(tableArg) == 'table' then 
        --# Try to remove the item from the table
        local result = {}
        local containsSomething = false
        for k,v in tableArg do
            if k ~= keyArg then
                result[k] = v
                containsSomething = true
            end
        end
        --# Return result
        if containsSomething then return result end
    end
    --# We get here if table passed was invalid
    --# or we end up with an empty table as a result.
    --# Give response according to preference of calling code.     
    if optionalLeaveEmptyTable then 
        return {}
    else 
        return false 
    end
end


--#*
--#*  Gilbot-X says:
--#*
--#*  I added this to mimick the function table.remove it but returns false
--#*  if table is empty and doesn't leave any nil keys in the table.
--#*  It also works on tables with string keys as well as arrays.
--#**
function RemoveFromTableByKeys(tableArg, keyListArg, optionalLeaveEmptyTable)
    --# Do this for safety because when ACU dies, we get problems.
    if type(tableArg) == 'table' and type(keyListArg) == 'table' then 
        --# Try to remove the item from the table
        local result = {}
        local containsSomething = false
        for kTableKey, vTableEntry in tableArg do
            local keyMatched = false
            for kUnusedArrayIndex, vKeyInListArg in keyListArg do
                if kTableKey == vKeyInListArg then keyMatched = true end
            end
            if keyMatched then
                result[kTableKey] = vTableEntry
                containsSomething = true
            end
        end
        --# Return result
        if containsSomething then return result end
    end
    --# We get here if table passed was invalid
    --# or we end up with an empty table as a result.
    --# Give response according to preference of calling code.     
    if optionalLeaveEmptyTable then 
        return {}
    else 
        return false 
    end
end


--#*
--#*  Gilbot-X says:
--#*
--#*  I added this as a new function to the file as a helper function
--#*  It mimicks a function table.removeByValue but returns false
--#*  if table is empty and doesn't leave any nil keys in the table.
--#*  It is designed to deal with lists, so it uses table[k] = v to
--#*  populate the new list.
--#**
function RemoveFromListByValue(tableArg, valueArg, optionalLeaveEmptyTable)
    --# Do this for safety because when ACU dies, we get problems.
    if type(tableArg) == 'table' then 
        --# Try to remove the item from the table
        local result = {}
        local containsSomething = false
        for k,v in tableArg do
            if v ~= valueArg then
                result[k] = v
                containsSomething = true
            end
        end
        --# Return result
        if containsSomething then return result end
    end
    --# We get here if table passed was invalid
    --# or we end up with an empty table as a result.
    --# Give response according to preference of calling code.     
    if optionalLeaveEmptyTable then 
        return {}
    else 
        return false 
    end
end


--#*
--#*  Gilbot-X says:
--#*
--#*  I added this as a new function to the file as a helper function
--#*  It mimicks a function table.removeByValue but returns false
--#*  if table is empty and doesn't leave any nil keys in the table.
--#*  It is designed to deal with arrays, so it uses table.insert to
--#*  populate the new list.
--#**
function RemoveFromArrayByValue(tableArg, valueArg, optionalLeaveEmptyTable)
    local bRemoved = false
    --# Do this for safety because when ACU dies, we get problems.
    if type(tableArg) == 'table' then 
        --# Try to remove the item from the table
        local result = {}
        local containsSomething = false
        for k,v in tableArg do
            if v == valueArg then
                --# record this to return later
                bRemoved = true
            else
                table.insert(result, v)
                containsSomething = true
            end
        end
        --# Return result
        if containsSomething then return result, bRemoved end
    end
    --# We get here if table passed was invalid
    --# or we end up with an empty table as a result.
    --# Give response according to preference of calling code.     
    if optionalLeaveEmptyTable then 
        return {}, bRemoved
    else 
        return false, bRemoved
    end
end



--#*
--#*  Gilbot-X says:
--#*
--#*  I added this as a new function to the file as a helper function
--#*  It mimicks a function table.find but returns false
--#*  if table is empty and doesn't return bad values
--#**
function IsValueInTable(tableArg, valueArg)
    --# If it's not a table, return false
    if type(tableArg) ~= 'table' then return false end
    --# return true when u find it
    for k,v in tableArg do
        if v == valueArg then
            return true
        end
    end
    --# false if never found
    return false 
end



--#*
--#*  Gilbot-X says:
--#*
--#*  I added this as a new function to the file as a helper function
--#*  It mimicks a function table.find but works on 2D nested tables
--#*  and returns false if table is empty.  
--#*  Unlike the GPG version, it never returns nil.
--#**
function IsValueIn2DTable(table2DArg, valueArg)
    if type(table2DArg) ~= 'table' then return false end
    --# return true when u find it
    for k1, vTable in table2DArg do
        if type(vTable) == 'table' then 
            for k2, vPotentialMatch in vTable do
                if vPotentialMatch == valueArg then
                    return true
                end
            end
        end
    end
    --# false if never found
    return false
end
    
    
    
    

--#*
--#*  Gilbot-X says:
--#*
--#*  I added this as a new function so I could traverse 
--#*  through a table with string keys in reverse order
--#*  If table is empty it returns false.
--#**
function GetTableKeysReversed(tableArg)
    --# If it's not a table, return false
    if type(tableArg) ~= 'table' then return false end
    --# Put the result in here
    local result = {}
    --# Take each key as we go through the table
    for key, value in tableArg do
        --# and insert it at the front of the result list
        table.insert(result, 0, key)
    end
    return result
end


--#*
--#*  Gilbot-X says:
--#*
--#*  I added this as a new function so I could traverse 
--#*  through an array table with numerical keys in reverse order
--#*  If table is empty it returns false.
--#**
function GetArrayReversed(tableArg)
    --# If it's not a table, return false
    if type(tableArg) ~= 'table' then return false end
    --# Put the result in here
    local result = {}
    --# Take each key as we go through the table
    for key, value in tableArg do
        --# and insert it at the front of the result list
        table.insert(result, 0, value)
    end
    return result
end


       
--#*
--#*  Gilbot-X says:
--#*
--#*  This is called when mapping ResourceNetwork and ResourceInterNetwork 
--#*  objects over their physical networks when something in them changes 
--#*  which forves these objects to be rebuilt by pathing from one of the remaining nodes.
--#*  It returns false if there are no redundant entries.  
--#*  Because an item can only appear one in one network/internetwork 
--#*  this function exists as a safety check to make sure that never happens.
--#**
FindRedundantEntryIn2DTable = function(table2DArg)
    --# No network should appear twice in the same InterNetwork.
    --# For every network in each table of potential internetworks..
    for kInnerTableIndex1, vInnerTable1 in table2DArg do
        for kObjectIndex1, vObject1 in vInnerTable1 do
            
            --# Pair up against another one...
            for kInnerTableIndex2, vInnerTable2 in table2DArg do
                for kObjectIndex2, vObject2 in vInnerTable2 do
                    --# If a network gets paired up with a copy of itself ...
                    if vObject1 == vObject2 and not 
                          ((kInnerTableIndex1 == kInnerTableIndex2) and 
                          (kObjectIndex1 == kObjectIndex2)) 
                       then
                          --# Return first one found
                          return vObject1
                    end
                end
            end
        end
    end
    
    --# Nothing was found
    return nil
end



--#*
--#*  Gilbot-X says:
--#*      
--#*  This is called from ShowRateOfFireMessage in Unit.lua
--#*  and various other UI functions in this mod.
--#*  It formats a number as a string up to 2 d.p.
--#*  and returns it.
--#** 
NumberToStringWith2DPMax = function(numberArg)
    --# safety check first
    if not type(numberArg) == 'number' then return end
    local resultText = repr(numberArg)
    if string.find(resultText, "%d+.%d%d") then 
        local s = string.gfind(resultText, "%d+.%d%d")
        resultText = s()
    elseif string.find(resultText, "%d+.%d") then 
        local s = string.gfind(resultText, "%d+.%d")
        resultText = s()
    end
    return resultText
end