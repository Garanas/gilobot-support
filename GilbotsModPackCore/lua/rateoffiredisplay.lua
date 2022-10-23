--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/rateoffiredisplay.lua
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


local UnitText = 
    import('/mods/GilbotsModPackCore/lua/unittext.lua')
local NumberToStringWith2DPMax = 
    import('/mods/GilbotsModPackCore/lua/utils.lua').NumberToStringWith2DPMax 

--#*
--#*  Gilbot-X says:  
--#*
--#*  This SIM side function is a callback that
--#*  gets the units selected, checks if each 
--#*  is alive and has weapons unit, and if it is, it 
--#*  calls the function to flash a message to the user
--#*  (using the custom naming system).
--#**
function ToggleRateOfFireDisplayCallback(data)
    
    --# For each unit that was selected
    for k, unitEntityId in data.UnitEntityIdList do
        
        --# Try to get an autotoggle unit from the ID passed by UI side.
        local selectedUnit = GetEntityById(unitEntityId)
       
        --# Only pass on call if this is unit is not dead.
        if selectedUnit:IsAlive() then
            --# CalculateRateOfFireMessage is defined in my hook of Unit.lua
            --# Show player the selected units' rate of fire
         
            CalculateRateOfFireMessage(selectedUnit) 
        end
    end
end


   
--#*
--#*  Gilbot-X says:
--#*      
--#*  This is called from file debuggingcallbacks.lua
--#*  when a player selects units and hits ALT-F.
--#*  It displays each unit's Rate Of Fire over the
--#*  unit (as its custom name) for 3 seconds.
--#** 
CalculateRateOfFireMessage = function(unitArg)
    local weaponCount = unitArg:GetWeaponCount()
    if weaponCount == 0 then return end
    local messageText = {}
    --# This block will make a comma separated list
    --# listing the ROF of all wepons this unit has
    local lineNumber = 1
    for i = 1, weaponCount do
        --# Get weapon object from SIM
        local weapon = unitArg:GetWeapon(i)
        local weaponBP = weapon:GetBlueprint()
        --# Don't tell us the rate of fire of dummy weapons.
        if weaponBP.RateOfFire 
          and (weaponBP.Label ~= 'Charge')
          and (weaponBP.Label ~= 'CloakFieldRadius')
          and (weaponBP.Label ~= 'AdjacencyRange')
          and (weaponBP.Label ~= 'RadarStealthFieldRadius')
          and (weaponBP.WeaponCategory ~= 'Death') 
          and (weaponBP.WeaponCategory ~= 'Kamikaze') 
          and (not weaponBP.DummyWeapon)
        then
            --# Look for cache of last rate of fire set from 
            --# a buff or adjacency bonus
            local weaponROF = weapon.LastRateOfFireSet or false
            if not weaponROF then
                --# Otherwise use default value from its blueprint
                weaponROF = weaponBP.RateOfFire
            end
            --# Add a comma to list if there's another weapon to do
            --# Format number as a string with 2 d.p.
            local weaponROFtext = weaponBP.DisplayName or "<unknown>"
            weaponROFtext = weaponROFtext .. "= " ..
                NumberToStringWith2DPMax(weaponROF)
            messageText[repr(lineNumber)] = weaponROFtext
            lineNumber = lineNumber+1
        end
    end
    
    --# Notify user
    unitArg.Sync.ROFText= messageText
end
    
    

--#*
--#*  Gilbot-X says:
--#*
--#*  This is a USER side function.
--#*  I created this so that entity IDs 
--#*  can be displayed by selecting units 
--#*  and using ALT-F on the keyboard numberpad. 
--#**
ToggleRateOfFireDisplay = function()
    
    local unitsSelected = GetSelectedUnits()
   --# If at least one unit is selected
    if unitsSelected 
    and (type(unitsSelected) == 'table') then
    
        --# Put entity Ids of the units selected
        --# into a new table because the UserUnit references
        --# themselves cannot be marshalled and sent 
        --# to the Sim side.
        local unitEntityIdListArg = {} 
        for unusedArrayIndex, vUnit in unitsSelected do
            table.insert(unitEntityIdListArg, vUnit:GetEntityId())
        end
        
        --# If any units were selected ...
        if (table.getsize(unitsSelected) > 0) then
            --# Invoke sim side code on the unit list.
            SimCallback( 
              {  
                Func='ToggleRateOfFireDisplay',
                Args={ 
                    UnitEntityIdList = unitEntityIdListArg,
                }
              }
            )
        end
        
        ForkThread(
            function(unitEntityIdListArg)
                WaitSeconds(1)
                for unusedArrayIndex, vUnitEntityId in unitEntityIdListArg do
                    --# Test
                    local text = {}
                    if UnitData[vUnitEntityId] and UnitData[vUnitEntityId].ROFText then
                        text = UnitData[vUnitEntityId].ROFText
                        local entryData = {
                            Text = text,
                            Entity = vUnitEntityId,
                            FadeAfterSeconds = 5,
                            Color ='ffbbeeff', -- light blue
                            FontSize = 12,
                            SyncTextVariable = 'ROFText'                
                        }
                        UnitText.StartDisplay(entryData)
                    end                
                end
            end, unitEntityIdListArg
        )
    end
end
        