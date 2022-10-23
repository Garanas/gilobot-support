do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/sim/collisionbeam.lua
--#**
--#****************************************************************************

local oldCollisionBeam = CollisionBeam
CollisionBeam = Class(oldCollisionBeam) {

    --#*
    --#*  A non-destructive override.  
    --#*  Looks quite safe.
    --#**
    OnImpact = function(self, impactType, targetEntity)
    	self:SetDamageTable()
    	oldCollisionBeam.OnImpact(self, impactType, targetEntity)
    end,

    --#*
    --#*  A DESTRUCTIVE override that 
    --#*  tries to streamlie FA's code
    --#*  but the drawback is that it blocks
    --#*  this function for other mods.
    --#*  Doesn't seem to add or change 
    --#*  any functionality.
    --#**
    SetDamageTable = function(self)
        self.DamageTable = self.Weapon:GetDamageTable()
        --# Gilbot-X: I added this next line as it look like it was needed.
        self.DamageTable.DamageAmount = self.Weapon:GetBlueprint().Damage
        
        --# This was the old code that we are replacing.
        --[[
        local weaponBlueprint = self.Weapon:GetBlueprint()
        self.DamageTable = {}
        self.DamageTable.DamageRadius = weaponBlueprint.DamageRadius
        self.DamageTable.DamageAmount = weaponBlueprint.Damage
        self.DamageTable.DamageType = weaponBlueprint.DamageType
        self.DamageTable.DamageFriendly = weaponBlueprint.DamageFriendly
        self.DamageTable.CollideFriendly = weaponBlueprint.CollideFriendly
        self.DamageTable.DoTTime = weaponBlueprint.DoTTime
        self.DamageTable.DoTPulses = weaponBlueprint.DoTPulses
        self.DamageTable.Buffs = weaponBlueprint.Buffs
        ]]
    end,
}
end--(of non-destructive hook)