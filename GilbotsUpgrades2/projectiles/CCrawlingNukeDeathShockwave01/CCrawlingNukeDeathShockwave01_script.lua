--#
--# script for projectile BoneAttached
--#
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile

CCrawlingNukeDeathShockwave01 = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/shockwave_smoke_01_emit.bp',},
}

TypeClass = CCrawlingNukeDeathShockwave01