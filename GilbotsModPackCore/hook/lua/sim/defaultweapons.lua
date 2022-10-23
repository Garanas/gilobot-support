do --(start of non-destructive hook)
--#****************************************************************************
--#**  Hook File:  /lua/sim/DefaultWeapons.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Default definitions of weapons
--#**
--#****************************************************************************

local PreviousVersion = DefaultProjectileWeapon
DefaultProjectileWeapon = Class(PreviousVersion) {		
    
    --# Stops a weird error in adjacencyunit.lua
    CanUpdateRateOfFireFromBonuses = true,

    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Add this so that we do not add to the weapon's bonus,
    --#*  but we set it outright.  This had to be changed because 
    --#*  I changed SetAdjacency in the StructureUnit class, to do
    --#*  similar.  I can do this because with this form of adjacency
    --#*  each unit can only receive bonuses from one source: 
    --#*  i.e. the network it is attached to.
    --#** 
    SetAdjacentEnergyMod = function(self, energyMod)
        self.AdjEnergyMod = 1 + energyMod
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Added this so that code that updates a weapons
    --#*  rate of fire with bonuses from multiple sources
    --#*  can be called from a single location.
    --#** 
    UpdateRateOfFireFromBonuses = function(self)
        --# Start with original starting value
        local rateOfFire = self:GetBlueprint().RateOfFire
        --# Add bonus from reducing firing range if there was one
        if self.RangeReductionRateOfFireBonus then
            rateOfFire = rateOfFire * self.RangeReductionRateOfFireBonus
        end
        --# Add enhancement bonus if there was one
        if self.RateOfFireEnhancementBonus then 
            rateOfFire = rateOfFire * self.RateOfFireEnhancementBonus
        end
        --# Add enhancement bonus if there was one
        if self.RateOfFireVeterancyBonus then 
            rateOfFire = rateOfFire * self.RateOfFireVeterancyBonus
        end
        --# Add adjacency bonus if there was one
        if self.LastRateOfFireAdjacencyBonusAdd then 
            local delay = 1/rateOfFire
            local newdelay = (1+self.LastRateOfFireAdjacencyBonusAdd) * delay
            rateOfFire = 1/newdelay
        end
        --# Make the change to gameplay        
        self:ChangeRateOfFire(rateOfFire)
        --# Record it for the ALT-F (ROF-display) command
        self.LastRateOfFireSet = rateOfFire
    end,

}


end --(end of non-destructive hook)