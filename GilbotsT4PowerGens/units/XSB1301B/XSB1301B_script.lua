--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/XSB1301B/XSB1301B_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Seraphim T4 Power Generator Script
--#**
--#****************************************************************************

local SEnergyCreationUnit = import('/lua/seraphimunits.lua').SEnergyCreationUnit
local SIFCommanderDeathWeapon = import('/lua/seraphimweapons.lua').SIFCommanderDeathWeapon
local EmtBpPath = '/effects/emitters/'

XSB1301B = Class(SEnergyCreationUnit) {
    
    AmbientEffects = 'ST3PowerAmbient',
    GilbotEffects = {
        --EmtBpPath .. 'aeon_t3power_ambient_01_emit.bp',
        --EmtBpPath .. 'aeon_t3power_ambient_02_emit.bp',
    },
    
    --# This code makes us explode
    --# This line needed if FireOnDeath not set to true 
    --# in weapon BP of DeathWeapon
    --# See line 866 in unit.lua
    DeathThreadDestructionWaitTime = 1,
    
    --# It has to be called DeathWeapon otherwise it doesn't work
    Weapons = {
        DeathWeapon = Class(SIFCommanderDeathWeapon) {},
    },	
    
    OnStopBeingBuilt = function(self, builder, layer)
        SEnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
        for k, v in self.GilbotEffects do
            local fx = CreateAttachedEmitter(self, 0, self:GetArmy(), v):OffsetEmitter(0, 0, 0):ScaleEmitter(2)
            self.Trash:Add(fx)
        end
        self.Trash:Add(CreateRotator(self, 'Orb', 'y', nil, 0, 15, 80 + Random(0, 20)))
    end,
}

TypeClass = XSB1301B