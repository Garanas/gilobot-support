do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/ui/game/unitview.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Overrided so that UI shows shield HP, not %,
--#**              and all bonuses to shield HP are also also included.
--#**
--#****************************************************************************

--# This hook file conflicts with Total Veterancy UI
--# so only apply code if TV UI is not in list of mods active.
local GetActiveModLocation = import('/Mods/GilbotsModPackCore/lua/modlocator.lua').GetActiveModLocation
if  not(GetActiveModLocation("77775cf2-9b8b-11dc-8314-2800200c9a66")) --Total Veterancy 1.17 UI
and not(GetActiveModLocation("12345678-2050-11dc-8314-2800200c9a66")) then --Total Veterancy 1.18 UI (In Gilbot's Mod pack)
    --# Debugging only
    LOG("Gilbot-X's Modpack core running without Total Vetrancy UI active, " 
    .. " so it is modding the shield HP percentage in the UI's unit view panel to an absolute HP value."
    )
    
    local EnhanceCommon = import('/lua/enhancementcommon.lua')
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I overrided this so that UI shows shield HP, not %
    --#*  and all bonuses to shield HP are also also included.
    --#**
    statFuncs[5] =
        function(info, bp)
            if info.shieldRatio > 0 then
                local selectedUnitId = info.userUnit:GetEntityId()
                local shieldMaxHealth = nil
                
                --# Look in enhancements first...
                if bp.Enhancements then
                    local selectedEnhancements = EnhanceCommon.GetEnhancements(selectedUnitId)
                    for kEnhName, vEnhBP in bp.Enhancements do
                        if selectedEnhancements[vEnhBP.Slot] == kEnhName
                        and vEnhBP['ShieldMaxHealth'] 
                        then
                            --LOG('ShieldMaxHealth set from enhancement ' .. repr(kEnhName))
                            shieldMaxHealth = vEnhBP['ShieldMaxHealth']                  
                        end
                    end
                end
                --# Then look in the normal place.
                if not shieldMaxHealth then
                    --# Get BP value for shield's max HP
                    if bp.Defense.SensitiveShield then 
                        shieldMaxHealth = bp.Defense.SensitiveShield.ShieldMaxHealth 
                    elseif bp.Defense.Shield then 
                        shieldMaxHealth = bp.Defense.Shield.ShieldMaxHealth 
                    end      
                end               
                --# Check the sync to see if bonuses were added
                local syncVal = UnitData[selectedUnitId].ShieldMaxHealth
                if syncVal and syncVal > 0 then shieldMaxHealth = syncVal end
                --# Apply Safety check
                if not shieldMaxHealth then return false end
                --# Return the calculated shield HP             
                return repr(math.floor(shieldMaxHealth*info.shieldRatio))
            else
                return false
            end
        end
end

end --(end of non-destructive hook)