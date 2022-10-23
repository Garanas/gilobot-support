--#****************************************************************************
--#**
--#**  File     :  /cdimage/units/URB1301/URB1301_script.lua
--#**  Author(s):  John Comes, Dave Tomandl, Jessica St. Croix
--#**
--#**  Summary  :  Cybran Power Generator Script
--#**
--#**  Copyright � 2005 Gas Powered Games, Inc.  All rights reserved.
--#****************************************************************************

local CEnergyCreationUnit = import('/lua/cybranunits.lua').CEnergyCreationUnit
local EmtBpPath = '/mods/gilbotst4powergens/units/urb1301b/'
local CIFCommanderDeathWeapon = import('/lua/cybranweapons.lua').CIFCommanderDeathWeapon

URB1301B = Class(CEnergyCreationUnit) {
    
    GilbotEffects = {
        EmtBpPath .. 'cybran_t4power_ambient_01_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_01b_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_02_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_02b_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_03_emit.bp',
        EmtBpPath .. 'cybran_t4power_ambient_03b_emit.bp',
    },
    
    OnStopBeingBuilt = function(self, builder, layer)
        CEnergyCreationUnit.OnStopBeingBuilt(self, builder, layer)
        
        for k, v in self.GilbotEffects do
            local fx = CreateAttachedEmitter(self, 0, self:GetArmy(), v):OffsetEmitter(0, 0, 0):ScaleEmitter(2)
            self.Trash:Add(fx)
        end
        
        for i = 1, 36 do
            local fxname
            if i < 10 then
                fxname = 'BlinkyLight0' .. i
            else
                fxname = 'BlinkyLight' .. i
            end
            local fx = CreateAttachedEmitter(self, fxname, self:GetArmy(), '/effects/emitters/light_yellow_02_emit.bp'):OffsetEmitter(0, 0, 0.01*2):ScaleEmitter(2.1)
            self.Trash:Add(fx)
        end
    end,
    
    
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

TypeClass = URB1301B




 

    
    
        
      
        