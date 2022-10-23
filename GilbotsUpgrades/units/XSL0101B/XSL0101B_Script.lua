--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/XSL0101B/XSL0101B_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Seraphim Upgraded Land Scout Script
--#**
--#****************************************************************************

local SWalkingLandUnit = import('/lua/seraphimunits.lua').SWalkingLandUnit
local SDFPhasicAutoGunWeapon = import('/lua/seraphimweapons.lua').SDFPhasicAutoGunWeapon
local MakeChargingUnit = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon

XSL0101B = Class(SWalkingLandUnit) {

    Weapons = {
		LaserTurret = Class(SDFPhasicAutoGunWeapon) {
			OnWeaponFired = function(self, target)
				SDFPhasicAutoGunWeapon.OnWeaponFired(self, target)
				ChangeState( self.unit, self.unit.VisibleState )
			end,
			
			OnLostTarget = function(self)
				SDFPhasicAutoGunWeapon.OnLostTarget(self)
				if self.unit:IsIdleState() then
				    ChangeState( self.unit, self.unit.InvisState )
				end
			end,
        },
        --# This dummy weapon just makes the LAB
        --# run straight at any opponents in its area
        --# which should put it in range of its main weapon.
        Charge = Class(ChargingWeapon) {},
    },
    
    OnStopBeingBuilt = function(self, builder, layer)
        SWalkingLandUnit.OnStopBeingBuilt(self, builder, layer)
        
        --# These start enabled, so before going to InvisState, 
        --# disabled them.. they'll be reenabled shortly
        self:DisableUnitIntel('RadarStealth')
		self:DisableUnitIntel('Cloak')
		self.Cloaked = false
        --# If spawned in we want the unit to be invis, 
        --# normally the unit will immediately start moving
        ChangeState( self, self.InvisState ) 
    end,
    
    InvisState = State() {
        Main = function(self)
            self.Cloaked = false
            local bp = self:GetBlueprint()
            if bp.Intel.StealthWaitTime then
                WaitSeconds( bp.Intel.StealthWaitTime )
            end
			self:EnableUnitIntel('RadarStealth')
			self:EnableUnitIntel('Cloak')
			self.Cloaked = true
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new ~= 'Stopped' then
                ChangeState( self, self.VisibleState )
            end
            SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
    
    VisibleState = State() {
        Main = function(self)
            if self.Cloaked then
                self:DisableUnitIntel('RadarStealth')
			    self:DisableUnitIntel('Cloak')
			end
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new == 'Stopped' then
                ChangeState( self, self.InvisState )
            end
            SWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
        end,
    },
}

XSL0101B = MakeChargingUnit(XSL0101B)
TypeClass = XSL0101B