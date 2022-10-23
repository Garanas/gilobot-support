--#****************************************************************************
--#**
--#**  File     :  /cdimage/units/URB1201/URB1201_script.lua
--#**  Author(s):  John Comes, Dave Tomandl, Jessica St. Croix
--#**
--#**  Summary  :  Cybran Tier 2 Power Generator Script
--#**
--#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
--#****************************************************************************

local CEnergyCreationUnit = import('/lua/cybranunits.lua').CEnergyCreationUnit
local EmtBpPath = '/mods/gilbotst4powergens/units/urb1201b/'
local CIFCommanderDeathWeapon = import('/lua/cybranweapons.lua').CIFCommanderDeathWeapon


URB1201B = Class(CEnergyCreationUnit) {
    
    GilbotEffects = {
        EmtBpPath .. 'cybran_t4power_ambient_01_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_01b_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_02_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_02b_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_03_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_03b_emit.bp',
    },

    
    OnStopBeingBuilt = function(self,builder,layer)
        CEnergyCreationUnit.OnStopBeingBuilt(self,builder,layer)
        
        for k, v in self.GilbotEffects do
            local fx = CreateAttachedEmitter(self, 0, self:GetArmy(), v):OffsetEmitter(0, 0, 0):ScaleEmitter(4)
            self.Trash:Add(fx)
        end
        
        ChangeState(self, self.ActiveState)
    end,

    ActiveState = State {
        Main = function(self)
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Activate then
                self:PlaySound(myBlueprint.Audio.Activate)
            end
        end,

        OnInActive = function(self)
            ChangeState(self, self.InActiveState)
        end,
    },

    InActiveState = State {
        Main = function(self)
        end,

        OnActive = function(self)
            ChangeState(self, self.ActiveState)
        end,
    },
    
    --# This code makes us explode
    --# This line needed if FireOnDeath not set to true 
    --# in weapon BP of DeathWeapon
    --# See line 866 in unit.lua
    DeathThreadDestructionWaitTime = 1,
    
    --# It has to be called DeathWeapon otherwise it doesn't work
    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {},
    },	

}

TypeClass = URB1201B