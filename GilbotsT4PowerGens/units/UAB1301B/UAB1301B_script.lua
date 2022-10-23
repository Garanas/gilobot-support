--#****************************************************************************
--#**
--#**  File     :  /mods/.../units/UAB1301B/UAB1301B_script.lua
--#**  Author(s):  John Comes, Dave Tomandl, Jessica St. Croix
--#**
--#**  Summary  :  Aeon Power Generator Script
--#**
--#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--#****************************************************************************
local AEnergyCreationUnit = import('/lua/aeonunits.lua').AEnergyCreationUnit
local AIFCommanderDeathWeapon = import('/lua/aeonweapons.lua').AIFCommanderDeathWeapon
local EmtBpPath = '/effects/emitters/'

UAB1301B = Class(AEnergyCreationUnit) {
    
    GilbotEffects = {
        EmtBpPath .. 'aeon_t3power_ambient_01_emit.bp',
        EmtBpPath .. 'aeon_t3power_ambient_02_emit.bp',
    },
    
    --# This code makes us explode
    --# This line needed if FireOnDeath not set to true 
    --# in weapon BP of DeathWeapon
    --# See line 866 in unit.lua
    DeathThreadDestructionWaitTime = 1,
    
    --# It has to be called DeathWeapon otherwise it doesn't work
    Weapons = {
        DeathWeapon = Class(AIFCommanderDeathWeapon) {},
    },	
    
    OnStopBeingBuilt = function(self, builder, layer)
        AEnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
        
        for k, v in self.GilbotEffects do
            local fx = CreateAttachedEmitter(self, 0, self:GetArmy(), v):OffsetEmitter(0, 0, 0):ScaleEmitter(2)
            self.Trash:Add(fx)
        end
        
        self.Trash:Add(CreateRotator(self, 'Sphere', 'x', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'y', nil, 0, 15, 80 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Sphere', 'z', nil, 0, 15, 80 + Random(0, 20)))
    end,
}

TypeClass = UAB1301B


