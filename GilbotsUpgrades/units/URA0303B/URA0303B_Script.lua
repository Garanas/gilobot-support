--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/URL0101B/URL0101B_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran T3 Stealth Air Superiority Fighter Script
--#**
--#****************************************************************************

local CAirUnit = 
    import('/lua/cybranunits.lua').CAirUnit
local CAAMissileNaniteWeapon = 
    import('/lua/cybranweapons.lua').CAAMissileNaniteWeapon

--# Apply common code for my mobile units that have AT
local BaseClass = CAirUnit

URA0303B = Class(BaseClass) {
    ExhaustBones = { 'Exhaust', },
    ContrailBones = { 'Contrail_L', 'Contrail_R', },
    Weapons = {
        Missiles1 = Class(CAAMissileNaniteWeapon) {},
        Missiles2 = Class(CAAMissileNaniteWeapon) {},
    },
    OnStopBeingBuilt = function(self,builder,layer)
        BaseClass.OnStopBeingBuilt(self,builder,layer)
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_StealthToggle', true)
        self:RequestRefreshUI()
    end,
}

TypeClass = URA0303B
