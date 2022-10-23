--#****************************************************************************
--#**
--#**  New File :  /mods.../units/URL0106B/URL0106B_script.lua
--#**  
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran Upgraded Light Infantry Script
--#**
--#****************************************************************************

local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local CDFLaserPulseLightWeapon = import('/lua/cybranweapons.lua').CDFLaserPulseLightWeapon
local MakeChargingUnit = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').MakeChargingUnit
local ChargingWeapon = import('/mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua').ChargingWeapon

local BaseClass = CWalkingLandUnit


URL0106B = Class(BaseClass) {
    
    Weapons = {
        MainGun = Class(CDFLaserPulseLightWeapon) {
        
            OnWeaponFired = function(self, target)
				CDFLaserPulseLightWeapon.OnWeaponFired(self, target)
				ChangeState( self.unit, self.unit.VisibleState )
			end,
			
			OnLostTarget = function(self)
				CDFLaserPulseLightWeapon.OnLostTarget(self)
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
        --# Do not let cloak effect get enabled
        --# when cloak is momentarilly enabled 
        --# in the GPG base class code of this function
        --# in unit.lua.
        self.DoNotEnableCloakEffect = true
        BaseClass.OnStopBeingBuilt(self, builder, layer)
        self.DoNotEnableCloakEffect = false
        
        --#These start enabled, so before going to InvisState, 
        --# disabled them.. they'll be reenabled shortly
        self:DisableConditionalCloak()
        --# If spawned in we want the unit to be invis, 
        --# normally the unit will immediately start moving
        --# take care of power usage first
        if self.ResourceDrainBreakDown then 
            self.EnabledResourceDrains.Cloak = true
            self:UpdateConsumptionValues()
            self:OnIntelEnabled()
        else 
            self:SetMaintenanceConsumptionActive()
        end
        ChangeState( self, self.InvisState ) 
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement.
    --#**
    InvisState = State() {
        Main = function(self)
            if not self:GetScriptBit('RULEUTC_CloakToggle') then
                --# This is copy-and pasted code
                --# That must be executed within a state
                self.Cloaked = false
                local bp = self:GetBlueprint()
                if bp.Intel.StealthWaitTime then
                    WaitSeconds(bp.Intel.StealthWaitTime)
                end
                self:EnableUnitIntel('RadarStealth')
                self:EnableUnitIntel('Cloak')
                self.Cloaked = true
            end
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new ~= 'Stopped' then
                ChangeState( self, self.VisibleState )
            end
            BaseClass.OnMotionHorzEventChange(self, new, old)
        end,
        
        --#*
        --#*  This happens when cloak button was off 
        --#*  but now is on and unit was already cloaked
        --#**   
        OnScriptBitClear = function(self, bit)
            if bit == 8 then
                --# turn on power usage first
                if self.ResourceDrainBreakDown then 
                    self.EnabledResourceDrains.Cloak = true
                    self:UpdateConsumptionValues()
                    self:OnIntelEnabled()
                else 
                    self:SetMaintenanceConsumptionActive()
                end
                --# Then cloak the unit itself 
                if not self.Cloaked then 
                    --# This is copy-and pasted code
                    --# That must be executed within a state
                    self.Cloaked = false
                    self:ForkThread(
                        function(self)
                            local bp = self:GetBlueprint()
                            if bp.Intel.StealthWaitTime then
                                WaitSeconds(bp.Intel.StealthWaitTime)
                            end
                            self:EnableUnitIntel('RadarStealth')
                            self:EnableUnitIntel('Cloak')
                            self.Cloaked = true
                        end
                    )
                end
            else
                --# Call base class code
                BaseClass.OnScriptBitClear(self, bit)
            end
        end,
        
        --#*
        --#*  This happens when cloak button was on but
        --#*  just got switched off while it cloaked.  
        --#**     
        OnScriptBitSet = function(self, bit)
            if bit == 8 then 
                if self.Cloaked then self:DisableConditionalCloak() end
                if self.ResourceDrainBreakDown then
                    self.EnabledResourceDrains.Cloak = false
                    self:UpdateConsumptionValues()
                    self:OnIntelDisabled()
                else
                    self:SetMaintenanceConsumptionInactive()
                end
            else
                --# Call base class code
                BaseClass.OnScriptBitSet(self, bit)
            end
        end,
    },
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement.
    --#**
    VisibleState = State() {
        Main = function(self)
            if self.Cloaked then self:DisableConditionalCloak() end
        end,
        
        OnMotionHorzEventChange = function(self, new, old)
            if new == 'Stopped' then
                ChangeState( self, self.InvisState )
            end
            BaseClass.OnMotionHorzEventChange(self, new, old)
        end,
        
        --#*
        --#*  This happens when cloak button was off 
        --#*  but now is on, but unit is moving or firing 
        --#*  anyway so just switch on power drain.
        --#**   
        OnScriptBitClear = function(self, bit)
            if bit == 8 then
                --# take care of power usage only
                if self.ResourceDrainBreakDown then 
                    self.EnabledResourceDrains.Cloak = true
                    self:UpdateConsumptionValues()
                    self:OnIntelEnabled()
                else 
                    self:SetMaintenanceConsumptionActive()
                end
            else
                --# Call base class code
                BaseClass.OnScriptBitClear(self, bit)
            end
        end,
        
        --#*
        --#* This happens when cloak button was on but
        --#* just got switched off while not cloaked. 
        --#* Just switch off power drain.        
        --#**     
        OnScriptBitSet = function(self, bit)
            if bit == 8 then 
                --# take care of power usage only
                if self.ResourceDrainBreakDown then
                    self.EnabledResourceDrains.Cloak = false
                    self:UpdateConsumptionValues()
                    self:OnIntelDisabled()
                else
                    self:SetMaintenanceConsumptionInactive()
                end
            else
                --# Call base class code
                BaseClass.OnScriptBitSet(self, bit)
            end
        end,
    },
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement.
    --#**
    DisableConditionalCloak = function(self)
        self:DisableUnitIntel('RadarStealth')
		self:DisableUnitIntel('Cloak')
		self.Cloaked = false
    end,
}

URL0106B = MakeChargingUnit(URL0106B)
TypeClass = URL0106B