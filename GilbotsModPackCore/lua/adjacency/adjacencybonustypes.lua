--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/adjacencybonustypes.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Used by the ResourceNetwork and AdjacencyStructureUnit classes.
--#**
--#****************************************************************************

--#*
--#*  Gilbot-X says:
--#*
--#*  Imported by the ResourceNetwork class.
--#*  Use this list to iterate through the network data structures. 
--#*  Those data structures are nested tables and these are the keys 
--#*  for the first dimension of those nested tables.
--#**
AdjacencyBonusTypes = {
    'EnergyActive',         -- used by factories
    'MassActive',           -- used by factories
    'EnergyProduction',    -- used by powergens, (given by storage)
    'MassProduction',      -- used by mass extractors and massfabs, (given by storage)   
    'EnergyMaintenance',   -- used by intel, stealth, cloak,
    'MassMaintenance',     -- never seen this used but it's obvious what it does
    'EnergyWeapon',        -- used by artillery
    'ShieldStrength',      -- I added this.
    'RateOfFire',          -- New for FA.  Used by ??
}



--#*
--#*  Gilbot-X says: 
--#*
--#*  This function is where limits are set for 
--#*  each bonus that apply to all factions.
--#*  These limits will prevent a situation where a 
--#*  player can build units, use shields and fire 
--#*  artillery at no cost.  We don't ever wan't to 
--#*  remove the need to expand the economy from the game.      
--#*
--#*  No known issues with this function.
--#**
ApplyBonusCap = function(bonusModifer, bonusType, unitBpId)
    
    --# Limit consumption reduction bonuses to a maximimum of 50% 
    --# reduction for each factory on each network.
    if bonusType == 'MassActive' then
        if bonusModifer < -0.2 then
            bonusModifer = -0.2
        end
        
    --# Limit consumption reduction bonuses to a maximimum of 50% 
    --# reduction for each factory on each network.
    elseif bonusType == 'EnergyActive' then
        if bonusModifer < -0.5 then
            bonusModifer = -0.5
        end
    
    --# Limit consumption reduction bonuses to a maximimum of 50% 
    --# reduction for each resource consuming unit on each network.    
    elseif bonusType == 'MassMaintenance' then
        if bonusModifer < -0.5 then
            bonusModifer = -0.5
        end
    
    --# Limit consumption reduction bonuses to a maximimum of 50% 
    --# reduction for each resource consuming unit on each network.
    elseif bonusType == 'EnergyMaintenance' then
        if bonusModifer < -0.5 then
            bonusModifer = -0.5
        end
       
    --# Limit production increase bonus given by storage units to a maximum 50% 
    --# increase for each energy producing item on each network.
    elseif bonusType == 'MassProduction' then
        if bonusModifer > 0.5 then
            bonusModifer = 0.5
        end
       
    --# Limit production increase bonus given by storage units to a maximum 50% 
    --# increase for each energy producing item on each network.
    elseif bonusType == 'EnergyProduction' then
        if bonusModifer > 0.5 then
            bonusModifer = 0.5
        end
       
    --# Limit consumption reduction bonuses to a maximimum of 75% 
    --# reduction for each resource consuming weapon on each network.
    elseif bonusType == 'EnergyWeapon' then
        if bonusModifer < -0.75 then
            bonusModifer = -0.75
        end
        
    --# Limit consumption reduction bonuses to a maximimum of 75% 
    --# reduction for each resource consuming weapon on each network.
    elseif bonusType == 'RateOfFire' then
        if unitBpId == 'ueb2401' then 
            WARN('Applying ROF Bonus Cap to Mavor')
            if bonusModifer < -0.5 then
                bonusModifer = -0.5
            end
        else
            if bonusModifer < -0.75 then
                bonusModifer = -0.75
            end
        end
        
    --# This is a new type of bonus I added.
    --# Limit shield strength increase bonus to a maximum 300% 
    --# increase for each shield on each network.
    elseif bonusType == 'ShieldStrength' then
        if bonusModifer > 3 then
            bonusModifer = 3
        end
    end
    
    --# Return the capped bonus amount to the calling code.
    return bonusModifer
end
    
    
 
        
       