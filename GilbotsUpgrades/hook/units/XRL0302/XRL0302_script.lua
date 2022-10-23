--#****************************************************************************
--#**
--#**  Hook File:  /units/XRL0302/XRL0302_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  Cybran Upgradeable Crawling Bomb
--#**
--#****************************************************************************
local Weapon = 
    import('/lua/sim/weapon.lua').Weapon
local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit
local MakeChargingUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/bombautotargeting.lua').MakeChargingUnit
local ChargingWeapon = 
    import('/mods/GilbotsModPackCore/lua/unitmods/bombautotargeting.lua').ChargingWeapon

local BaseClass = MakeCustomUpgradeMobileUnit(XRL0302, 'torso', 0.4)

local EMPDeathWeapon = Class(Weapon) {
    OnCreate = function(self)
        Weapon.OnCreate(self)
        --# starts off disabled so it only
        --# gets fired at same time as normal death weapon        
        self:SetWeaponEnabled(false)
    end,
}

XRL0302 = Class(BaseClass) {

    Weapons = {
        DeathWeapon = Class(CMobileKamikazeBombDeathWeapon) {
            OnFire = function(self)			
				CMobileKamikazeBombDeathWeapon.OnFire(self)
                --# This next block is added
                if self.unit.EMPEnhancementEnabled then
                    self.unit.FireEMP(self.unit)
                end
                if self.unit.FlareEnhancementEnabled then
                    self.unit.FireFlare(self.unit)
                end
			end,
        },
        Suicide = Class(CMobileKamikazeBombWeapon) {        
			OnFire = function(self)			
				--#disable death weapon
				self.unit:SetDeathWeaponEnabled(false)
				CMobileKamikazeBombWeapon.OnFire(self)
                --# This next block is added
                if self.unit.EMPEnhancementEnabled then
                    self.unit.FireEMP(self.unit)
                end
                if self.unit.FlareEnhancementEnabled then
                    self.unit.FireFlare(self.unit)
                end
			end,
        },
        --# This dummy weapon just makes the bomb
        --# run straight at any opponents in its area
        --# which should put it in range of its blast
        Charge = Class(ChargingWeapon) {},
        --# Needed for EMP
        EMP = Class(EMPDeathWeapon) {},
    },
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called from within a weapon class.
    --#**
    FireEMP = function(self)
        --# This next block of code reads the BP data needed
        --# to actually stun the units from the Buffs field in the unit blueprint!!
        local buffBluePrint
        for tableindex, v in self:GetBlueprint().Buffs do
            if v.Add.OnDeath then
                buffBluePrint = v
            end
        end 
        if buffBluePrint == nil then return end
        
        --# This makes the pretty flare visual.
        --# Can't put this next one in the Weapon's OnFire Class, the value of self changes
        --# Field 4 is size, field 5 is time 
        --# Make one that's fast and big, another that is slow and small
        CreateLightParticle( self, -1, -1, 150, 10, 'flare_lens_add_02', 'ramp_red_10' )
        CreateLightParticle( self, -1, -1, 20, 50, 'flare_lens_add_02', 'ramp_red_10' )
      
        --# Apply Buff
        --# This next block of code actually stuns the units!!
        self:AddBuff(buffBluePrint)
        
        --# This does cosmetic stuff
        local emp = self:GetWeaponByLabel('EMP')        
        emp:SetWeaponEnabled(true)
        emp:OnFire()
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called from within a weapon class.
    --#**
    FireFlare = function(self)
        --# This makes the pretty flare visual.
        --# Can't put this next one in the Weapon's OnFire Class, the value of self changes
        --# Field 4 is size, field 5 is time
        --# Make an initial 1 second flash that can be seen from space,
        --# Then a 10 second flare that fills a zoomed in screen and
        --# could obscure part of a base
        CreateLightParticle( self, -1, -1, 20*50, 20, 'flare_lens_add_02', 'ramp_red_10' )
        CreateLightParticle( self, -1, -1, 20*30, 50, 'flare_lens_add_02', 'ramp_red_10' )
        CreateLightParticle( self, -1, -1, 20*10, 70, 'flare_lens_add_02', 'ramp_red_10' )
        CreateLightParticle( self, -1, -1, 20*5, 100, 'flare_lens_add_02', 'ramp_red_10' )
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
        
        if  enh == "Nuke" then
            --# Do an instant upgrade to the relevant unit
            self:ReplaceMeWithUpgradedUnit(bp.UnitId) 
        elseif enh == "EMP" then
            --# Allow EMP
            self.EMPEnhancementEnabled=true
        elseif enh == "EMPRemove" then
            --# Allow EMP
            self.EMPEnhancementEnabled=false
        elseif enh == "Flare" then
            --# Allow flare
            self.FlareEnhancementEnabled=true
        elseif enh == "FlareRemove" then
            --# Allow flare
            self.FlareEnhancementEnabled=false
        elseif enh == 'Cloak' then
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
    --#*  This had to be overrided.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        BaseClass.OnStopBeingBuilt(self, builder, layer)
        
        --# Disable these until enhancements add them.
        self:DisableUnitIntel('RadarStealth')
        self:DisableUnitIntel('Cloak')
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

XRL0302 = MakeChargingUnit(XRL0302)
TypeClass = XRL0302