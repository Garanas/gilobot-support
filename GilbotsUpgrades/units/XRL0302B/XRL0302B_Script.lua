--#****************************************************************************
--#**
--#**  New File :  /mods/units/XRL0302B/XRL0302B_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Cybran Upgraded Mobile Bomb Script
--#**
--#****************************************************************************
local CWalkingLandUnit = 
    import('/lua/cybranunits.lua').CWalkingLandUnit
local CIFCommanderDeathWeapon = 
    import('/lua/cybranweapons.lua').CIFCommanderDeathWeapon
local MakeChargingUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/bombautotargeting.lua').MakeChargingUnit
local ChargingWeapon = 
    import('/mods/GilbotsModPackCore/lua/unitmods/bombautotargeting.lua').ChargingWeapon

local BaseClass = CWalkingLandUnit


XRL0302B = Class(BaseClass) {

    CustomUpgradeEffects = {
        '/effects/emitters/unit_upgrade_ambient_01_emit.bp',
    },
    
    Weapons = {
        DeathWeapon = Class(CIFCommanderDeathWeapon) {
            --# Called when unit wants to fire its weapon itself
            --# when in range of its target
            OnFire = function(self)
                self.unit.Kill(self.unit, self.unit, 'Normal',0)
            end,
        },
        --# This dummy weapon just makes the bomb
        --# run straight at any opponents in its area
        --# which should put it in range of its blast
        Charge = Class(ChargingWeapon) {},
    },
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This had to be overrided.
    --#**
    OnStopBeingBuilt = function(self,builder,layer)
        BaseClass.OnStopBeingBuilt(self,builder,layer)
        
        --# Declare non-static member variables here
        self.CustomUpgradeEffectsBag = false
        
        --# Need to do this or it won't fire
        self:SetWeaponEnabledByLabel('DeathWeapon', true)
        
        --# Disable these until enhancements add them.
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('Cloak')
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by the Unit class when
    --#*  an enhancement is finished being installed.
    --#*  This is where we actually change our units'
    --#*  properties or behaviour.
    --#**
    CreateEnhancement = function(self, enh)
        BaseClass.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if enh == 'Cloak' then
            --# Give ability to unit
            self:AddToggleCap('RULEUTC_CloakToggle')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('Cloak')
            self:SetEnergyMaintenanceConsumptionOverride(bp.MaintenanceConsumptionPerSecondEnergy or 0)
            self:SetMaintenanceConsumptionActive()
            --# Housekeeping
            self.CloakEnhancementEnabled = true
            --# This next line is needed?
            self:DisableConditionalCloak()
            --# Enable Auto Toggle on Cloak.
            self:AddAutoToggle({8,3}, bp.MaintenanceConsumptionPerSecondEnergy or 0)
        elseif enh == 'CloakRemove' then
            --# Disable Auto Toggle on Cloak.
            self:RemoveAutoToggle(8)
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:SetMaintenanceConsumptionInactive()
            ChangeState( self, self.IdleState ) 
        else
            WARN('Cybran : Unknown enhancment.')
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I Added this because when upgrading I have no animation
    --#*  and when enhancing, effect is too large.
    --#**
    CreateCustomUpgradeEffects = function(self)
          --# Remove any old effects
        self:DestroyCustomUpgradeEffects()
        --# Add new effects
        self.CustomUpgradeEffectsBag = {}
        for k, v in self.CustomUpgradeEffects do
            table.insert( self.CustomUpgradeEffectsBag, CreateAttachedEmitter( self, 'torso', self:GetArmy(), v ):ScaleEmitter(0.4))
        end
    end,
    --# Clean up any custom upgrading effects
    DestroyCustomUpgradeEffects = function(self)
        --# Destroy any old effects
        if self.CustomUpgradeEffectsBag then
            for k, v in self.CustomUpgradeEffectsBag do
                v:Destroy()
            end
            --# Setting it to false stops garbage collection 
            --# trying to destroy it when its already been destroyed
            self.CustomUpgradeEffectsBag = false
        end
    end,
    --# Clean up any custom upgrading effects when destroyed
    OnDestroy = function(self)
        self:DestroyCustomUpgradeEffects()
        BaseClass.OnDestroy(self)
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles cloaking enhancement
    --#*  on a unit that can build or enhance.
    --#**
    IdleState = State() {
        Main = function(self)
            CWalkingLandUnit.IdleState.Main(self)
            if self.CloakEnhancementEnabled then 
                ChangeState( self, self.InvisState )
            end
        end,
    },
    
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
            CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
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
                CWalkingLandUnit.OnScriptBitClear(self, bit)
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
                CWalkingLandUnit.OnScriptBitSet(self, bit)
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
            CWalkingLandUnit.OnMotionHorzEventChange(self, new, old)
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
                CWalkingLandUnit.OnScriptBitClear(self, bit)
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
                CWalkingLandUnit.OnScriptBitSet(self, bit)
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

XRL0302B = MakeChargingUnit(XRL0302B)
TypeClass = XRL0302B