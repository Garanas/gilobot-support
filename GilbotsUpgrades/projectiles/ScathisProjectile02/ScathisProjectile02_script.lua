local CArtilleryProtonProjectile = import('/lua/cybranprojectiles.lua').CArtilleryProtonProjectile
		
ScathisProjectile02 = Class(CArtilleryProtonProjectile) {
			
	OnImpact = function(self, targetType, targetEntity)
        CArtilleryProtonProjectile.OnImpact(self, targetType, targetEntity)
        
        local army = self:GetArmy()
        CreateLightParticle( self, -1, army, 24, 12, 'glow_03', 'ramp_red_06' )
        CreateLightParticle( self, -1, army, 8, 22, 'glow_03', 'ramp_antimatter_02' )
        
        local offset = 0.8
        local pos = self:GetPosition()
        local CapturingScouts = {}
        local FlareBombs = {}
        local EMPBombs = {}
        table.insert(EMPBombs,          CreateUnit('xrl0302', army, pos.x,     pos.y, pos.z , 0, 0, 0, 1))
        table.insert(FlareBombs,        CreateUnit('xrl0302', army, pos.x+offset, pos.y, pos.z , 0, 0, 0, 1))
        table.insert(CapturingScouts,   CreateUnit('url0101c', army, pos.x-offset, pos.y, pos.z , 0, 0, 0, 1))
        table.insert(CapturingScouts,   CreateUnit('url0101c', army, pos.x,     pos.y, pos.z+offset , 0, 0, 0, 1))
        table.insert(EMPBombs,          CreateUnit('xrl0302', army, pos.x+(0.8*offset), pos.y, pos.z+(0.8*offset) , 0, 0, 0, 1))
        table.insert(FlareBombs,        CreateUnit('xrl0302', army, pos.x-(0.8*offset), pos.y, pos.z+(0.8*offset) , 0, 0, 0, 1))
        table.insert(CapturingScouts,   CreateUnit('url0101c', army, pos.x,     pos.y, pos.z-offset , 0, 0, 0, 1))
        table.insert(CapturingScouts,   CreateUnit('url0101c', army, pos.x+(0.8*offset), pos.y, pos.z-(0.8*offset) , 0, 0, 0, 1))
        table.insert(EMPBombs,          CreateUnit('xrl0302', army, pos.x-(0.8*offset), pos.y, pos.z-(0.8*offset) , 0, 0, 0, 1))
	
        --# Add the relevant enhancements
        for arrayIndex, vUnit in FlareBombs do
            vUnit:CreateEnhancement('Flare')    
        end
        for arrayIndex, vUnit in EMPBombs do
            vUnit:CreateEnhancement('EMP')    
        end
    end,
}

TypeClass = ScathisProjectile02