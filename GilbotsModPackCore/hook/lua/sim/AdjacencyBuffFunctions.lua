--#****************************************************************************
--#*
--#*  Hook File :  /lua/sim/AdjacencyBuffFunctions.lua
--#*
--#*  Modded By :  Gilbot-X
--#*
--#****************************************************************************


--# New Shield Strength Bonus added by Gilbot-X
ShieldStrengthBuffCheck = function(buff, unit)
    local bpDefense = unit:GetBlueprint().Defense
    LOG('Gilbot: Defense for unit ' .. unit:GetUnitId() 
    .. ' is ' .. repr(bpDefense)
    )
    if EntityCategoryContains(categories.SHIELD, unit) 
     or bpDefense.SensitiveShield
    then return true
    else return false
    end
end

ShieldStrengthBuffRemove = function(buff, unit, instigator)
    DefaultBuffRemove(buff, unit, instigator)
end

ShieldStrengthBuffAffect = function(buff, unit, instigator)
    DefaultBuffAffect(buff, unit, instigator)
end
