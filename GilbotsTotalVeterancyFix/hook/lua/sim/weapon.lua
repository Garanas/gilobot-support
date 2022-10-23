do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/sim/Weapon.lua
--#**
--#**  Modded By :  Eni
--#**
--#**  Summary   : The base weapon class for all weapons in the game.
--#**
--#****************************************************************************

local oldWeapon = Weapon
Weapon = Class(oldWeapon) {
    
    --#*
    --#*  A non-destructive override 
    --#*  that ????
    --#*  Totally safe???
    --#**
	OnCreate = function(self)
		oldWeapon.OnCreate(self)
		local bp = self:GetBlueprint()
        --# These are used by buffs in Buff.lua
		self.DamageRadius =	bp.DamageRadius
		self.Damage = bp.Damage
		self.range = bp.MaxRadius  --except this: used where?
		self.rangeMod = 1
		self.adjRoF= 1
        self.bufRoF = bp.RateOfFire
        
        if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeInnerRingDamage and bp.NukeInnerRingRadius then
	        self.NukeOuterRingDamage = bp.NukeOuterRingDamage or 10
	        self.NukeOuterRingRadius = bp.NukeOuterRingRadius or 40
	       
	        self.NukeInnerRingDamage = bp.NukeInnerRingDamage or 2000
	        self.NukeInnerRingRadius = bp.NukeInnerRingRadius or 30
        end
	end,
	
    
    --#*
    --#*  A non-destructive override 
    --#*  that ????
    --#*  Totally safe???
    --#**
	CreateProjectileForWeapon = function(self, bone)
    	local proj = oldWeapon.CreateProjectileForWeapon(self, bone)
    	if proj and not proj:BeenDestroyed() then
    		local bp = self:GetBlueprint()
	    	local Lifetime = bp.ProjectileLifetime
	    	if Lifetime == 0 then Lifetime = proj:GetBlueprint().Physics.Lifetime * self.rangeMod end
	    	proj.initLifetime=Lifetime
	    	proj:SetLifetime(Lifetime)
	    	
	    	if bp.NukeOuterRingDamage and bp.NukeOuterRingRadius and bp.NukeOuterRingTicks and bp.NukeOuterRingTotalTime and
                bp.NukeInnerRingDamage and bp.NukeInnerRingRadius and bp.NukeInnerRingTicks and bp.NukeInnerRingTotalTime then
                local data = {
                    NukeOuterRingDamage = self.NukeOuterRingDamage,
                    NukeOuterRingRadius = self.NukeOuterRingRadius,
                    NukeOuterRingTicks = bp.NukeOuterRingTicks or 20,
                    NukeOuterRingTotalTime = bp.NukeOuterRingTotalTime or 10,
        
                    NukeInnerRingDamage = self.NukeInnerRingDamage,
                    NukeInnerRingRadius = self.NukeInnerRingRadius,
                    NukeInnerRingTicks = bp.NukeInnerRingTicks or 24,
                    NukeInnerRingTotalTime = bp.NukeInnerRingTotalTime or 24,
                }
                proj:PassData(data)
            end
	    end
    	return proj
    end,
	

        
    --#*
    --#*  A non-destructive override 
    --#*  that just adds an alias for 
    --#*  a variable in its return value. 
    --#*  Totally safe.
    --#**
    GetDamageTable = function(self)
        local damageTable = oldWeapon.GetDamageTable(self)
        --# This fixes a bad variable mismatch between
        --# Weapon and collisonbeam classes in FA. 
        damageTable.DamageAmount = (self.Damage or 0)
        --# I'm guessing this next line was just done for safety
        --# as there is no obvious issue with it.
    	damageTable.DamageRadius = (self.DamageRadius or 0)
        return damageTable
    end,

    
}
end--(of non-destructive hook)