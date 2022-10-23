--#****************************************************************************
--#**
--#**  File     :  /mods/gilbotst4powergens/projectiles/CT4PGExplosion/CT4PGExplosion_script.lua
--#**  Author(s):  
--#**
--#**  Summary  :  EMP Death Explosion
--#**
--#****************************************************************************

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell


T4PGExplosion = Class(NullShell) {

    --# This wasn't being called by Unit.CreateProjectile
    --# so I get my weapon's Fire method to call it explicitly
    --# For some reason, in the nuke version it does get 
    --# called automatically
    OnCreate = function(self)
        --LOG("T4PG: OnCreate called for CT4PGExplosion projectile")
        NullShell.OnCreate(self)
    end,
    
    --# Called from Fire method in weapon
    PassDamageData = function(self, damageData)
        --LOG("T4PG: PassDamageData called for CT4PGExplosion projectile")
        NullShell.PassDamageData(self, damageData)
        local instigator = self:GetLauncher()
        if instigator == nil then
            instigator = self
        end

        --# Do Damage
        self:DoDamage( instigator, self.DamageData, nil )  
    end,
    
    --# Does this ever get called?  I don't think so, 
    --# because this projectile is created with the method call :SetCollision(false)
    OnImpact = function(self, targetType, targetEntity)
        --WARN("T4PG: OnImpact called for CT4PGExplosion projectile")
        self:Destroy()
    end,
}

TypeClass = T4PGExplosion

