local CArtilleryProtonProjectile = import('/lua/cybranprojectiles.lua').CArtilleryProtonProjectile
		
ScathisProjectile01 = Class(CArtilleryProtonProjectile) {
			
	OnImpact = function(self, targetType, targetEntity)
        CArtilleryProtonProjectile.OnImpact(self, targetType, targetEntity)
        
        local army = self:GetArmy()
        CreateLightParticle( self, -1, army, 24, 12, 'glow_03', 'ramp_red_06' )
        CreateLightParticle( self, -1, army, 8, 22, 'glow_03', 'ramp_antimatter_02' )
        
        local offset = 0.8
        local pos = self:GetPosition()
        local unitGroup = {}
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x,     pos.y, pos.z , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x+offset, pos.y, pos.z , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x-offset, pos.y, pos.z , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x,     pos.y, pos.z+offset , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x+(0.8*offset), pos.y, pos.z+(0.8*offset) , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x-(0.8*offset), pos.y, pos.z+(0.8*offset) , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x,     pos.y, pos.z-offset , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x+(0.8*offset), pos.y, pos.z-(0.8*offset) , 0, 0, 0, 1))
        table.insert(unitGroup, CreateUnit('xrl0302', army, pos.x-(0.8*offset), pos.y, pos.z-(0.8*offset) , 0, 0, 0, 1))
	end,
}

TypeClass = ScathisProjectile01