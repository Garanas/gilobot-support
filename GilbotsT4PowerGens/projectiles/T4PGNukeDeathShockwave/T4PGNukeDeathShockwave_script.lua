--#
--# script for projectile BoneAttached
--#
local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile

T4PGNukeDeathShockwave = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/shockwave_smoke_01_emit.bp',},
}

TypeClass = T4PGNukeDeathShockwave