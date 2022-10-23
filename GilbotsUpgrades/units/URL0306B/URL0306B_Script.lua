--#****************************************************************************
--#**
--#**  File     :  /mods/.../URL0306B/URL0306B_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Cybran Mobile Counter-Intel Script
--#**
--#****************************************************************************

local CLandUnit = 
    import('/lua/cybranunits.lua').CLandUnit
local EffectUtil = 
    import('/lua/EffectUtilities.lua')
local MakeCloakFieldUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/cloakfieldunit.lua').MakeCloakFieldUnit
    
--# Apply common code for my units that have cloak fields
local BaseClass = MakeCloakFieldUnit(CLandUnit)

URL0306B = Class(BaseClass) {
    --# We use transparent cloak effect
    --# instead of blue haze
    IntelEffects = nil,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I had to override this because the cloak field was not activating
    --#*  correctly when this unit was given autotoggle straight away.
    --#*  It needs to be switched on first and allowed to work for a second
    --#*  before autotoggle is switched on.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        BaseClass.OnStopBeingBuilt(self, builder, layer)
        --# Switch off cloak field if it was on
        if self:GetScriptBit('RULEUTC_CloakToggle') == false then
            self:SetScriptBit('RULEUTC_CloakToggle', true)
            self:RequestRefreshUI()
        end
        --# Wait, then turn on cloak field, wait again, 
        --# then enable Auto Toggle on Cloak field.
        self:ForkThread(
            function(self)
                WaitSeconds(1)
                self:SetScriptBit('RULEUTC_CloakToggle', false)
                self:RequestRefreshUI()
                --self:SetMaintenanceConsumptionActive()
                WaitSeconds(1)
                self:AddAutoToggle({8,3}, self:GetBlueprint().Economy.MaintenanceConsumptionPerSecondEnergy)
            end
        )
    end,
}

TypeClass = URL0306B