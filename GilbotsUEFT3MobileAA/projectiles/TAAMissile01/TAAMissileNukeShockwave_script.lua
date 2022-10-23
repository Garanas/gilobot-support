local EmitterProjectile = import('/lua/sim/defaultprojectiles.lua').EmitterProjectile

TAAMissileNukeShockwave = Class(EmitterProjectile) {
    FxTrails = {'/effects/emitters/shockwave_smoke_01_emit.bp',},
}

TypeClass = TAAMissileNukeShockwave