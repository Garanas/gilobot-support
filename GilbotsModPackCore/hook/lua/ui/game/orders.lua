--#****************************************************************************
--#**
--#**  Hook File:  /lua/ui/game/orders.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  This is purely a bugfix.
--#**              Only a few lines in the CreateAltOrders function changed.  
--#**              See below for reason.
--#**
--#****************************************************************************

--#*
--#*  Gilbot-X says:
--#*
--#*  I overrided this so that when a group of units
--#*  are selected and between them they have more alt 
--#*  orders/toggles than there are slots (i.e 6) that
--#*  only the first 6 are shown and it doesn't create script errors.
--#**
CreateAltOrders = function(availableOrders, availableToggles, units)
    --# This is original FA code.
    --Look for units in the selection that have special ability buttons
    --If any are found, add the ability information to the standard order table
    if units and categories.ABILITYBUTTON and EntityCategoryFilterDown(categories.ABILITYBUTTON, units) then
        for _, unit in units do
            local tempBP = UnitData[unit:GetEntityId()]
            if tempBP.Abilities then
                for abilityIndex, ability in tempBP.Abilities do
                    if ability.Active ~= false then
                        table.insert(availableOrders, abilityIndex)
                        standardOrdersTable[abilityIndex] = table.merged(ability, import('/lua/abilitydefinition.lua').abilities[abilityIndex])
                        standardOrdersTable[abilityIndex].behavior = AbilityButtonBehavior
                    end
                end
            end
        end
    end
    --# This is original FA code.
    local assitingUnitList = {}
    local podUnits = {}
    if table.getn(units) > 0 and (EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units) or EntityCategoryFilterDown(categories.POD, units)) then
        local PodStagingPlatforms = EntityCategoryFilterDown(categories.PODSTAGINGPLATFORM, units)
        local Pods = EntityCategoryFilterDown(categories.POD, units)
        local assistingUnits = {}
        if table.getn(PodStagingPlatforms) == 0 and table.getn(Pods) == 1 then
            assistingUnits[1] = Pods[1]:GetCreator()
            podUnits['DroneL'] = Pods[1]
            podUnits['DroneR'] = Pods[2]
        elseif table.getn(PodStagingPlatforms) == 1 then
            assistingUnits = GetAssistingUnitsList(PodStagingPlatforms)
            podUnits['DroneL'] = assistingUnits[1]
            podUnits['DroneR'] = assistingUnits[2]
        end
        if assistingUnits[1] then
            table.insert(availableOrders, 'DroneL')
            assitingUnitList['DroneL'] = assistingUnits[1]
        end
        if assistingUnits[2] then
            table.insert(availableOrders, 'DroneR')
            assitingUnitList['DroneR'] = assistingUnits[2]
        end
    end
    --# This is original FA code.
    --# determine what slots to put alt orders
    --# we first want a table of slots we want to fill, and what orders want to fill them
    local desiredSlot = {}
    local usedSpecials = {}
    for _, availOrder in availableOrders do
        if standardOrdersTable[availOrder] then 
            local preferredSlot = standardOrdersTable[availOrder].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availOrder)
        else
            if specialOrdersTable[availOrder] ~= nil then
                specialOrdersTable[availOrder].behavior()
                usedSpecials[availOrder] = true
            end
        end
    end
    --# This is original FA code.
    for _, availToggle in availableToggles do
        if standardOrdersTable[availToggle] then 
            local preferredSlot = standardOrdersTable[availToggle].preferredSlot
            if not desiredSlot[preferredSlot] then
                desiredSlot[preferredSlot] = {}
            end
            table.insert(desiredSlot[preferredSlot], availToggle)
        else
            if specialOrdersTable[availToggle] ~= nil then
                specialOrdersTable[availToggle].behavior()
                usedSpecials[availToggle] = true
            end
        end
    end
    --# This is original FA code.
    for i, specialOrder in specialOrdersTable do
        if not usedSpecials[i] and specialOrder.notAvailableBehavior then
            specialOrder.notAvailableBehavior()
        end
    end
    --# This is original FA code.
    --# now go through that table and determine what doesn't fit and look for slots that are empty
    --# since this is only alt orders, just deal with slots 7-12
    local orderInSlot = {}
    --# This is original FA code.
    --# go through first time and add all the first entries to their preferred slot
    for slot = firstAltSlot,numSlots do
        if desiredSlot[slot] then
            orderInSlot[slot] = desiredSlot[slot][1]
        end
    end

    --# I changed the LOG line only. 
    --# Does the same as the original FA code.
    --# Put any additional entries wherever they will fit
    for slot = firstAltSlot,numSlots do
        if desiredSlot[slot] and table.getn(desiredSlot[slot]) > 1 then
            for index, item in desiredSlot[slot] do
                if index > 1 then
                    local foundFreeSlot = false
                    for newSlot = firstAltSlot, numSlots do
                        if not orderInSlot[newSlot] then
                            orderInSlot[newSlot] = item
                            foundFreeSlot = true
                            break
                        end
                    end
                    if not foundFreeSlot then
                        LOG("Gilbot's hook of orders.lua: No free slot for order: " .. item)
                        --# could break here, but don't, then you'll know how many extra orders you have
                    end
                end
            end
        end
    end

    --# This is original FA code.
    --# now map it the other direction 
    --# so it's order to slot
    local slotForOrder = {}
    for slot, order in orderInSlot do
        slotForOrder[order] = slot
    end

    --# This is the main change and the reason for hooking this file.
    --# This does exactly the same as the original FA code but
    --# only tries to add buttons that have a slot allocated.
    --# The next two lines have been changed.  This should not
    --# affect other mods as long as they do not hook this function too.
    for _, availOrder in orderInSlot do
        if standardOrdersTable[availOrder] and (not commonOrders[availOrder]) and slotForOrder[availOrder] then
            --# This is original FA code.
            local orderInfo = standardOrdersTable[availOrder] or AbilityInformation[availOrder]
            local orderCheckbox = AddOrder(orderInfo, slotForOrder[availOrder], true)
            orderCheckbox._order = availOrder
            --# This is original FA code.
            if standardOrdersTable[availOrder].script then
                orderCheckbox._script = standardOrdersTable[availOrder].script
            end
            --# This is original FA code.
            if assitingUnitList[availOrder] then
                orderCheckbox._unit = assitingUnitList[availOrder]
            end
            --# This is original FA code.
            if podUnits[availOrder] then
                orderCheckbox._pod = podUnits[availOrder]
            end
            --# This is original FA code.
            if orderInfo.initialStateFunc then
                orderInfo.initialStateFunc(orderCheckbox, currentSelection)
            end
            --# This is original FA code.
            orderCheckboxMap[availOrder] = orderCheckbox
        end
    end
end