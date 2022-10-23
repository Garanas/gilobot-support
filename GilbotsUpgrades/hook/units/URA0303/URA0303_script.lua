--#****************************************************************************
--#**
--#**  Hook File:  /units/URA0303/URA0303_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  Cybran T3 Air Superiority Fighter Script
--#**
--#****************************************************************************

local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local BaseClass = MakeCustomUpgradeMobileUnit(URA0303, 'URA0303', 0.7)
URA0303 = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I overrided this so planes cannot upgrade 
    --#*  while still in the air. 
    --#**
    OnStopBeingBuilt = function(self,builder,layer)
        BaseClass.OnStopBeingBuilt(self,builder,layer)
        --# ban upgrade until unit has landed
        self:AddBuildRestriction(categories.BUILTBYUPGRADINGAIRUNIT * categories.CYBRAN * categories.TECH3)
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I overrided this so planes cannot upgrade 
    --#*  while still in the air. 
    --#**
    OnMotionVertEventChange = function(self, new, old)
        --# Baseclass version also starts with this safety check
        if self:IsDead() then return end
        
        --# If landed...
        if (new == 'Bottom') or (new == 'Hover') then
            --# Allow upgrade
            self:RemoveBuildRestriction(categories.BUILTBYUPGRADINGAIRUNIT * categories.CYBRAN * categories.TECH3)
        --# otherwise if just taking off
        elseif (new == 'Up' or ( new == 'Top' and ( old == 'Down' or old == 'Bottom' ))) then
            --# Ban upgrade
            self:AddBuildRestriction(categories.BUILTBYUPGRADINGAIRUNIT * categories.CYBRAN * categories.TECH3)
        end
        --# Call base class which plays 
        --# sounds and handles motion effects 
        BaseClass.OnMotionVertEventChange(self, new, old)
    end,
}
TypeClass = URA0303