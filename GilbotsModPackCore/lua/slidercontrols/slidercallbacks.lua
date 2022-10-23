--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/slidercontrols/slidercallbacks.lua
--#**  Author(s):  Modded by Neruz and Gilbot-X
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

local GetBPValueFromArray = 
    import('/mods/GilbotsModPackCore/lua/slidercontrols/sliderdatatypes.lua').GetBPValueFromArray

local debugSliderControls = false


--#*
--#*  Gilbot-X says:  
--#*
--#*  These next 4 functions all deal with shields and were originally 
--#*  written by Neruz, but I uphauled all the code.
--#**
function SetShieldSizeCallback(data)
    --# Start with safety check on arguments passed
    if type(data.EntityTable) == "table" then 
        for entityId, newStatValue in data.EntityTable do
            
            local unit = GetEntityById(entityId)
            local unitbp = unit:GetBlueprint()
            
            --# Make sure there is actually an update needed first
            if unit.MyShield.Size ~= newStatValue then
                --# Only use the gradually resizing animation 
                --# on this bubble shield if it is actually turned on
                if unit.MyShield:IsOn() then
                    AnimateShieldSizeChange(unit.MyShield, unitbp, newStatValue, data)
                else
                --# Set the new shield size so it takes 
                --# that size when it comes back on.
                    UpdateShieldSize(unit.MyShield, unitbp, newStatValue, data)
                end
            end
        end
    end
end



--#*
--#*  Gilbot-X says: 
--#*
--#*  This function is called by the SetShieldSize callback above.
--#*  It provides an animation if the shield is switched on.
--#**                
AnimateShieldSizeChange = function(shieldArg, unitbpArg, newStatValueArg, data)
    
    --# Fork a thread to do this!!
    --# If a resize thread was active (unlikely) then kill it
    if shieldArg.Owner.ShieldResizeThread then
        KillThread(shieldArg.Owner.ShieldResizeThread)
        shieldArg.Owner.ShieldResizeThread = nil
    end
                
    shieldArg.Owner.ShieldResizeThread = shieldArg.Owner:ForkThread(
        function(self, shieldArg, unitbp, newStatValue, data)
                 
            local isSizeIncreasing = true
            if newStatValue < shieldArg.Size then isSizeIncreasing = false end
            
            --# Keep track of what size was before resizing
            shieldArg.SizeBefore = shieldArg.Size
        
            local unitsToResizeBy = math.abs(newStatValue - shieldArg.Size)
            for i=0, unitsToResizeBy  do
                if shieldArg:IsOn() and 
                   shieldArg.Owner:GetAIBrain():GetEconomyStored('ENERGY') > 0 
                then
                    --# This next block is for debugging only.
                    --# This can be deleted when debugging is finished.
                    if debugSliderControls then
                      LOG('Slider mod: SimCallbacks.lua: UpdateSize: Going to resize another step.')
                    end
                    
                    if isSizeIncreasing then
                        shieldArg.SizeWhileResizing = shieldArg.SizeBefore + i
                    else
                        shieldArg.SizeWhileResizing = shieldArg.SizeBefore - i
                    end
                    
                    local newVerticalOffset = 
                        CalculateShieldVerticalOffset(unitbpArg, shieldArg.SizeWhileResizing)
                    
                    
                    --# This next block is for debugging only.
                    --# This can be deleted when debugging is finished.
                    if debugSliderControls then
                      LOG('Slider mod: SimCallbacks.lua: UpdateSize: Changing shield object.')
                    end
                    
                    --# Set up shield to be new size 
                    shieldArg:SetCollisionShape('Sphere', 0, 0, 0, shieldArg.SizeWhileResizing/2) 
                    shieldArg:SetParentOffset(Vector(0, newVerticalOffset, 0)) 
                    shieldArg:SetDrawScale(shieldArg.SizeWhileResizing) 
                    shieldArg.Size = shieldArg.SizeWhileResizing
                    shieldArg.ShieldVerticalOffset = newVerticalOffset
                    shieldArg.MeshZ:SetDrawScale(shieldArg.SizeWhileResizing) 
                    shieldArg.MeshZ:SetParentOffset(Vector(0, newVerticalOffset, 0))
                    
                    --# Animation pause
                    WaitTicks(1)
                    
                    --# This line accounts for fact that unitsToResizeBy may be non integer.  
                    if i == math.floor(unitsToResizeBy) then break end
                else
                    --# This finishes the job if power was cut off and
                    --# makes sure consumption values are up-to-date
                    UpdateShieldSize(shieldArg, unitbp, newStatValue, data)
                
                    ChangeState(shieldArg, shieldArg.EnergyDrainRechargeState)
                end
            end

            --# This finishes the job if power was cut off and
            --# makes sure consumption values are up-to-date
            UpdateShieldSize(shieldArg, unitbp, newStatValue, data)
            
            --# Thread marks itself dead as it terminates
            shieldArg.Owner.ShieldResizeThread = nil
        end,
    
        --# These are arguments to the function we forked as a thread    
        shieldArg, unitbpArg, newStatValueArg, data
    )
   
end


--#*
--#*  Gilbot-X says: 
--#*
--#*  Called by AnimateShieldSizeChange and UpdateShieldSize.
--#*
--#*  This code was from Neruz.  I haven't changed it.
--#*  I think it needs adjusting because I don't put 150% limit on sheild growth.
--#**
CalculateShieldVerticalOffset = function(unitbpArg, currentShieldSize)
    local minShieldSize, maxShieldSize = CalculateMinMaxShieldSizes(unitbpArg)
    local minVerticalOffset, maxVerticalOffset = 
        0, unitbpArg.Defense.Shield.ShieldVerticalOffset *1.5 - 0.617263328
    local offsetUnitsPerShieldSizeUnit = 
        (maxVerticalOffset-minVerticalOffset) / (maxShieldSize-minShieldSize)
    local currentVerticalOffset = (offsetUnitsPerShieldSizeUnit * (currentShieldSize - minShieldSize))
    return currentVerticalOffset
end



--#*
--#*  Gilbot-X says: 
--#*
--#*  Called by CalculateShieldVerticalOffset above.
--#*
--#*  This code was from Neruz.  I haven't changed it.
--#*  I think it needs replacing because I don't put 150% limit on sheild growth.
--#**
CalculateMinMaxShieldSizes = function(unitbpArg)
    
    --# This next block is for debugging only.
    --# This can be deleted when debugging is finished.
    if debugSliderControls then
      LOG('Slider mod: SimCallbacks.lua: CalculateMinMaxShieldSizes: Starting.')
    end
    
    local x,y,z = unitbpArg.SizeX*2,unitbpArg.SizeY*2,unitbpArg.SizeZ*2
    local minShieldSize = math.ceil(math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2)))
    local maxShieldSize =  math.ceil(unitbpArg.Defense.Shield.ShieldSize * 1.5)
    local normalsize = unitbpArg.Defense.Shield.ShieldSize
    
    --# This next block is for debugging only.
    --# This can be deleted when debugging is finished.
    if debugSliderControls then
        LOG('Slider mod: SimCallbacks.lua: For the selected shield unit, ' 
         .. ' minsize= ' .. minShieldSize 
         .. ' and maxShieldSize=' .. maxShieldSize
        )
    end
    
    return minShieldSize, maxShieldSize
end




--#*
--#*  Gilbot-X says: 
--#*
--#*  Called by SetShieldSize above.
--#*  
--#**   
UpdateShieldSize = function(shieldArg, unitbp, newStatValue, data)

    local unit = shieldArg.Owner
    local unitbp = unit:GetBlueprint()
            
    shieldArg:SetSize(newStatValue)
    shieldArg:SetVerticalOffset(CalculateShieldVerticalOffset(unitbp, newStatValue))
    
    --# Update the unit's sync table for the 
    --# slider control value if it is using
    --# the sync table for that.
    TryUpdateSync(unit, 'ShieldSize', newStatValue)
            
    --# If no value for ResourceDrainId supplied
    --# then this does not consume energy or mass
    if data.UpdateConsumptionImmediately and data.ResourceDrainID then
        UpdateStatValueConsumption(
            unit,
            newStatValue,
            data.StatType,   
            data.ResourceDrainID,
            data.BPDefaultValueLocation,
            data.BPDefaultValueName
        )
    end
    
end
    
    

        
        


--#*
--#*  Called by StatSliderMenu class.
--#*  
--#**          
function SetStatValueCallback(data)
    
    if type(data.EntityTable) == "table" then 
        for entityId, newStatValue in data.EntityTable do
            
            local unit = GetEntityById(entityId)
       
            --# Make the unit change according to
            --# how the slider control 
            DoUpdateFunction(unit, data.StatType, newStatValue)
         
            --# Update the unit's sync table for the 
            --# slider control value if it is using
            --# the sync table for that.
            TryUpdateSync(unit, data.StatType, newStatValue)
        
            --# If no value for ResourceDrainId supplied
            --# then this does not consume energy or mass
            if data.UpdateConsumptionImmediately and data.ResourceDrainID then
                UpdateStatValueConsumption(
                    unit,
                    newStatValue,
                    data.StatType,   
                    data.ResourceDrainID,
                    data.BPDefaultValueLocation,
                    data.BPDefaultValueName
                )  
            end
        end
    end
end
            

                
--#*
--#*  Called by SetStatValueCallback and UpdateShieldSize.
--#**          
function TryUpdateSync(unit, statType, newStatValue)
    --# Look for synch data
    if unit.SliderControlledStatValues and 
       unit.SliderControlledStatValues[statType] 
    then
        --# Update unit's copy of sync table with changes we are making now
        unit.SliderControlledStatValues[statType].CurrentValue = newStatValue
        
        --# We need to force a resync here from the sim side, 
        --# otherwise if the unit doesn't change the
        --# stat value itself (and resynch), it will never get re-synched
        --# and we'll get the out-of-date value in the sync table
        --# (the one that was there before we made this change)                    
        unit.Sync.SliderControlledStatValues = unit.SliderControlledStatValues
    end
end



--#*
--#*  Get a sim side function that updates whatever 
--#*  property, feature or variable that the stat slider
--#*  was designed to adjust.
--#*
--#*  The functions must take exactly 2 arguments:
--#*  the unit to update, and the new value being set.
--#*
--#*  You cannot refer to other functions inside a 
--#*  function you return unless it is defined inside 
--#*  this file or you use the 'import' statement.
--#**
DoUpdateFunction = function(unit, statType, newStatValue)
     
    if statType == 'RadarStealthFieldRadius' then 
        --# These fields do not take decimal values
        newStatValue = math.floor(newStatValue)
        unit:SetIntelRadius('RadarStealthField', newStatValue)
        --# This is for dummy weapon that indicates range
        --# when a unit has both stealth and cloak fields
        --# but they are sized separately.
        local weapon = unit:GetWeaponByLabel('RadarStealthFieldRadius')
        if weapon then weapon:ChangeMaxRadius(newStatValue) end
    elseif statType == 'RadarRadius' then 
        --# These fields do not take decimal values
        newStatValue = math.floor(newStatValue)
        unit:SetIntelRadius('Radar', newStatValue)
    else
        --# For custom stat slider types, defer to the modded unit class
        unit:DoStatValueUpdateFunction(statType, newStatValue)
    end
    
end
        

   
            

     
            
 
--#*
--#*  Called only by SetStatValue or SetShieldSize.
--#*  
--#**          
function UpdateStatValueConsumption(unit, newStatValue, statType, resourceDrainId, 
                                    bpDefaultValueLocation, bpDefaultValueName)
    
    --# These are arguments we'll use for a function call          
    local referenceStatValue=0
    local referenceConsumption = {Energy=0, Mass=0}
    
    --# Look for synch data
    if unit.SliderControlledStatValues then 
        
        if not unit.SliderControlledStatValues[statType] then
            WARN('Slider mod: Unit ' .. unit:GetEntityId() .. 
                  ' has synch data for sliders but not for ' .. statType)
            return
        else
            --# Get sync data needed to work out 
            --# how much energy the unit will consume
            --# once we've made the changes requested from the slider menu
            referenceStatValue = 
                unit.SliderControlledStatValues[statType].DefaultValue
            referenceConsumption.Energy = 
                unit.SliderControlledStatValues[statType].DefaultEnergyConsumption or 0
            referenceConsumption.Mass = 
                unit.SliderControlledStatValues[statType].DefaultMassConsumption or 0
        end
    else
        --# Get reference values for consumption from unit blueprints.
        referenceConsumption = unit:GetReferenceConsumptionFromBlueprint(resourceDrainId)
    
        --# Try to provide a default value for the stat value itself from unit BP
        local unitbp = unit:GetBlueprint()
        if bpDefaultValueLocation and bpDefaultValueName then 
            referenceStatValue = 
                GetBPValueFromArray(unitbp, bpDefaultValueLocation, bpDefaultValueName)
        else
            WARN('UpdateStatValueConsumption: Cannot get referenceStatValue:' 
              .. ' bpDefaultValueLocation=' .. repr(bpDefaultValueLocation)
              .. ' bpDefaultValueName=' .. repr(bpDefaultValueName)
            )
            return
        end
       
    end
   
    --# Without a reference value we can't update the consumption to anything meaningful
    if referenceStatValue and referenceStatValue > 0 then 
        unit:UpdateConsumptionWhenAbilityChanges(
            newStatValue, 
            referenceStatValue, 
            resourceDrainId, 
            referenceConsumption
        )
    end
end