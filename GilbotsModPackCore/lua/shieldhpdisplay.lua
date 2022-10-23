--#****************************************************************************
--#**
--#**  New File:  /mods/GilbotsModPackCore/lua/shieldhpdisplay.lua
--#**
--#**  Modded By:  Gilbot-X, with link to code from Goom
--#**
--#**  Summary  :  Overrided to add keymappings for slider controls
--#**              and autotoggle priority order changes
--#**
--#****************************************************************************

local UnitText = 
    import('/mods/GilbotsModPackCore/lua/unittext.lua')
   
--#*
--#*  Gilbot-X says:
--#*
--#*  This is a USER side function.
--#*  I created this so that entity IDs 
--#*  can be displayed by selecting units 
--#*  and using CTRL-ALT-S on the keyboard numberpad. 
--#**
ToggleShieldStrengthDisplay = function()
    
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
                Func='ToggleShieldStrengthDisplay',
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
                    if UnitData[vUnitEntityId] and UnitData[vUnitEntityId].ShieldStrengthMessage then
                        text = UnitData[vUnitEntityId].ShieldStrengthMessage
                        local entryData = {
                            Text = text,
                            Entity = vUnitEntityId,
                            FadeAfterSeconds = 5,
                            Color ='ffccffdd', -- light green/blue
                            FontSize = 12,
                            SyncTextVariable = 'ShieldStrengthMessage'                
                        }
                        UnitText.StartDisplay(entryData)
                    end                
                end
            end, unitEntityIdListArg
        )
    end
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This function gets the units selected, checks if 
--#*  it is alive and a shield unit, and if it is, it 
--#*  calls the function to flash a message to the user
--#*  (using the custom naming system).
--#**
function ToggleShieldStrengthDisplayCallback(data)

    --# For each unit that was selected
    for k, unitEntityId in data.UnitEntityIdList do
        --# Try to get an autotoggle unit from the ID passed by UI side.
        local selectedUnit = GetEntityById(unitEntityId)
        --# Only pass on call if this is unit is not dead.
        if selectedUnit:IsAlive() then
            --# ShowShieldStrengthMessage is defined in my hook of shield.lua
            --# Show player new shield health
            if selectedUnit.MyShield then
                selectedUnit.MyShield:UpdateShieldStrengthMessage()
            end
        end
    end
end