--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/positioncorrections.lua
--#**
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Apply corrections to position for custom units
--#**
--#****************************************************************************

local ApplyCorrection = function(positionArg, xamount, zamount)
    return {
        x = positionArg.x + xamount,
        z = positionArg.z + zamount,
    }
end

--# Some of my units where I've scaled the mesh need the skirt centre offset
--# These are for my T4 Powergens
local UnitSpecificPositionCorrections = {
    uab1301b = {x=0.5, z=0.5},
    uec1901b = {x=0.5, z=0.5},
    urb1301b = {x=0.5, z=0.5},
    urb1201b = {x=0.5, z=0.5},
} 

--# This is defined globally so it can be imported.
--# It is called from GetSkirtBounds in the AdjacencyUnit class.
ApplyPositionCorrection = function(unit, unchangedPosition)
    
    --# All naval factories have unit position 
    --# offset from centre of skirt by 2 x-units.
    if unit.IsNavalFactory then 
        return ApplyCorrection(unchangedPosition, -2, 0)
    end
    --# Check against custom units in table above
    --# Some of my units where I've scaled the mesh need the skirt centre offset
    local unitSpecificCorrection = UnitSpecificPositionCorrections[unit:GetUnitId()]
    if unitSpecificCorrection then 
        return ApplyCorrection(unchangedPosition, unitSpecificCorrection.x, unitSpecificCorrection.z)
    end
    
    --# Otherwise return the unchanged position
    return {
        x = unchangedPosition.x,
        z = unchangedPosition.z,
    }
end
      