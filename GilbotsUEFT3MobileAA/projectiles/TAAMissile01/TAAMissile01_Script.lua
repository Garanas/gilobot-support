local EffectTemplate = import('/lua/EffectTemplates.lua')
local DefaultProjectileFile = import('/lua/sim/defaultprojectiles.lua')
local EmitterProjectile = DefaultProjectileFile.EmitterProjectile
local TIFMissileNuke = import('/lua/terranprojectiles.lua').TIFMissileNuke

local TIFMissileCruise01 = import('/projectiles/TIFMissileCruise01/TIFMissileCruise01_script.lua').TIFMissileCruise01

TAAMissile01 = Class(TIFMissileCruise01) {

     OnImpact = function(self, TargetType, TargetEntity)
        if not TargetEntity or not EntityCategoryContains(categories.PROJECTILE, TargetEntity) then
            --# Play the explosion sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Explosion then
                self:PlaySound(myBlueprint.Audio.NukeExplosion)
            end
           
            nukeProjectile = self:CreateProjectile('/mods/GilbotsUEFT3MobileAA/projectiles/TAAMissile01/TAAMissileNukeEffect_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            
            --local damageTable = self:GetDamageTable()
            --nukeProjectile:PassDamageData(self.Data)
            
            
            --[[nukeProjectile = self:CreateProjectile('/effects/Entities/UEFNukeEffectController01/UEFNukeEffectController01_proj.bp', 0, 0, 0, nil, nil, nil):SetCollision(false)
            
            self.Data = {
                NukeOuterRingDamage = 100,
                NukeOuterRingRadius = 10,
                NukeOuterRingTicks = 10,
                NukeOuterRingTotalTime = 20,
                NukeInnerRingDamage = 300,
                NukeInnerRingRadius =5,
                NukeInnerRingTicks = 20,
                NukeInnerRingTotalTime = 40,
            }
            nukeProjectile:PassData(self.Data)
            ]]
            
        end
        TIFMissileCruise01.OnImpact(self, TargetType, TargetEntity)
    end,
}
TypeClass = TAAMissile01

