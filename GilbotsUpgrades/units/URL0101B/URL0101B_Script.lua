--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/URL0101B/URL0101B_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran Advanced Land Scout Script
--#**
--#****************************************************************************

local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local Entity = import('/lua/sim/Entity.lua').Entity
local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local BaseClass = MakeCustomUpgradeMobileUnit(BaseClass, 'URL0101', 0.3)

URL0101B = Class(BaseClass) {
    
    --# This is all GPG code
    OnStopBeingBuilt = function(self,builder,layer)
        BaseClass.OnStopBeingBuilt(self,builder,layer)
        --#entity used for radar
        local bp = self:GetBlueprint()
        self.RadarEnt = Entity {}
        self.Trash:Add(self.RadarEnt)
        self.RadarEnt:InitIntel(self:GetArmy(), 'Radar', bp.Intel.RadarRadius)
        self.RadarEnt:EnableIntel('Radar')
        self.RadarEnt:AttachBoneTo(-1, self, 0)
        --#antena spinner
        CreateRotator(self, 'Spinner', 'y', nil, 90, 5, 90)
        --#enable cloaking economy
        --#self:SetMaintenanceConsumptionActive()
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_CloakToggle', true)
        self:RequestRefreshUI()
    end,
}	

TypeClass = URL0101B