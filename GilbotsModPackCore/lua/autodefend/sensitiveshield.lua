--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/autodefend/sensitiveshield.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Personal Shield that calls OnDamage with 0 damage
--#**              on the shield owner, so the owner knows it was hit.
--#**
--#****************************************************************************

--#*
--#*  Gilbot-X says:
--#* 
--#*  This shield consumes no energy when switched on.
--#*  It does not short out when the economy has no energy.
--#*  If it takes a hit, it notifies its owner, so
--#*  the owner can decide whether to leave the shield on 
--#*  or take it off.
--#**
do --(start of local baseclass definition)
local BaseClass = 
    import('/lua/shield.lua').UnitShield
SensitiveShield = Class(BaseClass) {


    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This is overrided without calling base class,
    --#*  to remove some of the base class code.
    --#*  I removed the check for power running out, 
    --#*  because the HCPP and MeX power their own shield 
    --#*  using their production output.
    --#**
    OnState = State {
    
        Main = function(self)
        
            if self.Owner.CreateShieldSwitchedOff and 
             (not self.AlreadyCreatedSwitchedOff)
            then 
                --# Prevent second use of flag
                self.AlreadyCreatedSwitchedOff = true 
                --# Stay switched off
                ChangeState(self, self.OffState)
            else 
                --# Set initial health of the shield
                if self.OffHealth >= 0 then
                    self:SetHealth(self, self.OffHealth)
                    self.OffHealth = -1
                else
                    self:SetHealth(self, self:GetMaxHealth())
                end

                --# Show Lifebar for shield
                self:UpdateShieldRatio(-1)

                self.Owner:OnShieldEnabled()
                self:CreateShieldMesh()
                
                WaitSeconds(1)
                --# The shield is only switched off by 
                --# ChangState being called by another thread.
                while true do
                    WaitTicks(1)
                    self:UpdateShieldRatio(-1)
                end
            end
        end,

        IsOn = BaseClass.OnState.IsOn,
        
        --#*
        --#*  Gilbot-X says:
        --#* 
        --#*  This override is added so that the shield owner is notified
        --#*  that the shield has been hit if it is on.
        --#**
        OnDamage =  function(self, instigator, amount, vector, damageType)
            self.Owner:OnDamage('SensitiveShield', 0, vector, damageType)
            BaseClass.OnDamage(self, instigator, amount, vector, damageType)
        end,
    },   
    
}
end--(of local baseclass definition)



------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------



do --(start of local baseclass definition)

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeSensitiveShieldUser(baseClassArg) 

--#*
--#*  Gilbot-X says:
--#* 
--#*  Any unit class that uses the SensitiveShield
--#*  class should inherit this class for common
--#*  shield management functions.
--#**
local MakeAutoPackUnit = 
    import('/mods/GilbotsModPackCore/lua/autodefend/autopackunit.lua').MakeAutoPackUnit
local BaseClass = MakeAutoPackUnit(baseClassArg)
local resultClass = Class(BaseClass) {
    
 
    --# Quick way to check if a unit is an 
    --# autopack unit that extends this class.
    IsSensitiveShieldUser = true,
    --# Other settings
    PackIfEnemyUnitsNearby = true,
    SensitiveShieldConsumesEnergy = false,
    CreateShieldSwitchedOff = true,
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Override this with  code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        --# Do base class versions first
        BaseClass.DoBeforeAnyStateChanges(self)
        --# This should be safe to call here
        self:InitSensitiveShieldUser()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  The inheriting class needs to point its OnStopBeingBuilt
    --#*  function to this code after it executes base class versions.
    --#**
    InitSensitiveShieldUser = function(self)
        self.ShieldUsePermitted = false
        self.MyShieldToggledOn = true
        self.MyShieldIsEnabled = false
        self:CreateSensitiveShield()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This function gets the shield spec from the blueprint 
    --#*  so a sensitive personal shield is created.
    --#*  The extending class needs to call this function explicitly.
    --#*
    --#*  For strength to be relative to production output,
    --#*  the unit needs to call self.MyShield.SetMaxHealth().
    --#**
    CreateSensitiveShield = function(self)

        --# Next line is just for safety
        if self.MyShield then self:DestroyShield() end
        
        local bp = self:GetBlueprint()
        local bpShield = bp.Defense.SensitiveShield
        self.MyShield = SensitiveShield {
            --# This code is from unit.lua when they create 
            --# a personal shield.
            Owner = self,
            ImpactEffects = bpShield.ImpactEffects or '',
            CollisionSizeX = bp.SizeX * 0.75,
            CollisionSizeY = bp.SizeY * 0.75,
            CollisionSizeZ = bp.SizeZ * 0.75,
            CollisionCenterX = bp.CollisionOffsetX or 0,
            CollisionCenterY = bp.CollisionOffsetY or 0,
            CollisionCenterZ = bp.CollisionOffsetZ or 0,
            
            --# These next 6 fields are defined in mod_blueprints.lua
            OwnerShieldMesh = bpShield.OwnerShieldMesh,
            ShieldMaxHealth = bpShield.ShieldMaxHealth,
            ShieldRechargeTime = bpShield.ShieldRechargeTime or 10,
            ShieldEnergyDrainRechargeTime = bpShield.ShieldEnergyDrainRechargeTime or 10,
            ShieldRegenRate = bpShield.ShieldRegenRate,
            ShieldRegenStartTime = bpShield.ShieldRegenStartTime or 120,  
            --# Above: Takes this long to start recharging when shield is on
            
            --# New for FA.  Not tested.
            PassOverkillDamage = bpShield.PassOverkillDamage, -- defaults to true in FA???
        }
        --# This code is from unit.lua 
        --# when they create shields.
        self:SetFocusEntity(self.MyShield)
        self.Trash:Add(self.MyShield)
        
        --# Gilbot-X: These next lines 
        --# are my own code
        self.ShieldUsePermitted = true
    end,
        
        
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This overrides the version in unit.lua
    --#*  I don't call base class because that calls
    --#*  SetScriptBit which is a moho/engine method.
    --#*
    --#*  The inheriting class needs to point its
    --#*  EnableShield function to this code.
    --#*
    --#*  I Perform strict checks to see if 
    --#*  unit is currently allowed to run shield.
    --#**
    EnableShield = function(self)
    
        --# Perform safety
        if (self:BeenDestroyed() or self:IsDead()) then return end
        
        if not self.ShieldUsePermitted then 
            WARN("SensitiveShieldUser: EnableShield: " ..
                 "1: Unit does not have a shield or self.ShieldUsePermitted not set!" ..
                 "This is allowed only when the unit is first created - " ..
                 "it happens twice per aeon MeX unit created because of code in OnStopBeingBuilt." .. 
                 "It is also used to stop shield coming on when unit is upgrading." .. self.DebugId)
        else
            if not self.MyShield then 
                WARN("SensitiveShieldUser: EnableShield: 2: not self.MyShield!" .. 
                     "Maybe shield has not been created yet or has been destoyed?" .. self.DebugId) 
            else
                if not self.MyShieldToggledOn then
                    WARN("SensitiveShieldUser: EnableShield: 3: not self.MyShieldToggledOn!" .. 
                         "Maybe user did not toggle the shield on?" .. self.DebugId) 
                else
                    if self.MyShieldIsEnabled then 
                        WARN("SensitiveShieldUser: EnableShield: 4: ".. 
                             "Shield already enabled!!" .. self.DebugId) 
                    else
                        if not self.IsPacked then
                            WARN("SensitiveShieldUser: EnableShield: 5: ".. 
                                 "Can't enable shield when unit not packed!!" .. self.DebugId
                                 .. ' self.IsPacked=' .. repr(self.IsPacked)
                            ) 
                        else
                            if not self:ShieldIsOn() then self.MyShield:TurnOn() end
                            self.MyShieldIsEnabled = true
                        end
                    end
                end
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This overrides the version in unit.lua
    --#*  I don't call base class because that calls
    --#*  SetScriptBit which is a moho/engine method.
    --#*
    --#*  The inheriting class needs to point its
    --#*  DisableShield function to this code.
    --#*
    --#*  I Perform strict checks to see if 
    --#*  unit is currently allowed to run shield.
    --#**
    DisableShield = function(self)
  
        --# Perform safety
        if (self:BeenDestroyed() or self:IsDead()) then return end
        
        if not self.ShieldUsePermitted then 
            WARN("SensitiveShieldUser: DisableShield: 1: " ..
                 "Unit does not have a shield or self.ShieldUsePermitted not set!" .. self.DebugId)
        else
            if not self.MyShield then 
                WARN("SensitiveShieldUser: DisableShield: 2: not self.MyShield!" .. 
                     "Maybe shield has not been created yet or has been destoyed?" .. self.DebugId) 
            else
                if not self.MyShieldIsEnabled then 
                    WARN("SensitiveShieldUser: DisableShield: 3: ".. 
                         "Shield should not be enabled now!! Is this harmless?" .. self.DebugId) 
                else
                    if not self.IsPacked then
                        WARN('SensitiveShieldUser: DisableShield: 4: '.. 
                             'Shouldnt be trying to disable shield ' 
                             .. ' when unit not packed!!' .. self.DebugId
                             .. ' self.IsPacked=' .. repr(self.IsPacked)
                        ) 
                    else
                        if self:ShieldIsOn() then self.MyShield:TurnOff() end
                        self.MyShieldIsEnabled = false
                    end
                end
            end
        end
    end,
    
    
 
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This overrides the version in unit.lua
    --#*  so the shield never drains energy. 
    --#** 
    OnShieldEnabled = function(self)
        self:PlayUnitSound('ShieldOn')
        --# Make the shield drain energy if it is supposed to
        if self.SensitiveShieldConsumesEnergy then
            self:SetMaintenanceConsumptionActive()
        end
    end,
        
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This overrides the version in unit.lua
    --#*  so the shield never drains energy. 
    --#** 
    OnShieldDisabled = function(self)
        self:PlayUnitSound('ShieldOff')
        --# Turn off the energy drain if it has one
        if self.SensitiveShieldConsumesEnergy then
            self:SetMaintenanceConsumptionInactive()
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This overrides the version in autopackunit.lua
    --#*
    --#*  Override this so that damage taken by the shield is registered here.
    --#*  We need to record if shield was hit so we can decide if we are still
    --#*  under attack and if it is safe to switch off shield and unpack.
    --#**
    OnDamageWhenPaused = function(self, instigator, amount, vector, damageType)
        --# Record that we were damaged so WatchLoop 
        --# (defined in AutoPackUnit abstract class) can query it.
        self.Damaged = true
        
        --# Superclass will lower our health
        if instigator ~= 'SensitiveShield' then
            --# Forwarding OnDamage to Unit class to reduce our health
            self:DoNormalDamage(instigator, amount, vector, damageType)
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  What to do when we start producing energy.  
    --#*  This happens when unit's production is unpaused
    --#*  and it has whatever other conditions it needs 
    --#*  to execute production.
    --#**
    OnActive = function(self)
        --# This makes sure that shield is stopped before unpacking
        if self.MyShieldIsEnabled then self:DisableShield() end 
        
        --# Call base class code now: 
        --# If Autopack extended baseclass before we did,
        --# then unpacking is done here...
        
        --# It in turn calls its base class 
        --# to take care of active animations, 
        --# visual effects and sound effect. 
        BaseClass.OnActive(self)
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  What to do when we stop producing energy.  
    --#*  This happens when unit's production is paused
    --#*  or it doesn't have whatever other conditions 
    --#*  it needs to execute production.
    --#**
    OnInactive = function(self)
        --# Call base class first.
        --# If Autopack extended baseclass before we did,
        --# it will call its base class first, so
        --# that will take care of active animations,
        --# sounds, consumption etc.        
        BaseClass.OnInactive(self)
        --# then packing is done next if required...

        --# Finally activate defense.
        if not self.MyShieldIsEnabled then 
            self:EnableShield() 
            --# Disable immediate upgrade because 
            --# shield must be switched off first
            self.NotReadyToUpgrade = true
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*   
    --#*  This happens when unit's production is paused
    --#*  during an upgrade but we don't want autodefend to run
    --#*  so we run it and call this to switch defense effects off
    --#**
    DisableAutoDefendWhileUpgrading = function(self)
        --# Don't let shield run while upgrading.  
        if self.MyShieldIsEnabled then self:DisableShield() end 
    end,
         
}

return resultClass
end--(of function definition)
end--(of local baseclass definition)