--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/autodefend/dls.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Damage limitation system is used by some UEF units.
--#**
--#****************************************************************************

local MakeAutoDefendUnit = 
    import('/mods/GilbotsModPackCore/lua/autodefend/autodefendunit.lua').MakeAutoDefendUnit

    
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeDamageLimitationSystemUser(baseClassArg) 


--#*
--#*  Gilbot-X says:
--#* 
--#*  Any unit class that uses DLS
--#*  should inherit this class for common
--#*  DLS management functions.
--#**
local BaseClass = MakeAutoDefendUnit(baseClassArg)
local resultClass = Class(BaseClass) {

    --# Quick way to check if a unit is an 
    --# autopack unit that extends this class.
    IsDamageLimitationSystemUser = true,
    --# An option
    MustDisableAutoDefendWhileUpgrading = false,
    
    --# When DLS is active, this is the percentage of damage 
    --# dealt by the projectile that actually
    --# gets taken off the unit's HP (health points), 
    --# i.e. setting it to 0.4 means 40% of damage 
    --# amount projectile should inflict is actually taken 
    --# off of this unit's health; a reduction of 60% in damage taken.
    InitialDLSDamageReductionFactor = 0.5,
    
    --# Effect blueprints
    DLSEffectBlueprints = {
        '/effects/emitters/sparks_01_emit.bp',
        '/effects/emitters/sparks_02_emit.bp',
        '/effects/emitters/sparks_03_emit.bp',
        '/effects/emitters/sparks_04_emit.bp',
        '/effects/emitters/sparks_05_emit.bp',
        '/effects/emitters/sparks_06_emit.bp',
        '/effects/emitters/sparks_07_emit.bp',
        '/effects/emitters/sparks_08_emit.bp',
        '/effects/emitters/sparks_09_emit.bp',
        '/effects/emitters/sparks_10_emit.bp',
    },
    
--[[

Gilbot-X says:
----------------
You need to put an entry like this into the 'Display' table in your unit's blueprint file for it to  use the DLS effects.  This example is from my hook of the UEF HCPP unit blueprint file:



Defense = {
    DLSDamageReductionFactor = 0.5,
},
    
Display = {
    DLSEffectSettings = {
        Sparks = {
            Bone = 'UEB1102', 
            Scale = 1.6,
            LODCutoff = 80,
            Offset = { x=0, y=0, z=0},
        },
        Flash = {
            Bone = 'UEB1102', 
            Scale = 8,
            LODCutoff = 100,
            Offset = { x=0, y=0, z=0},
        },
    },
},
    
    
]]


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
    
        --# Get settings from blueprint
        local bp = self:GetBlueprint()
        self.DLSEffectSettings = bp.Display.DLSEffectSettings
        self.InitialDLSDamageReductionFactor = bp.Defense.DLSDamageReductionFactor or 0.5
    end, 
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This overrides the version in autopackunit.lua
    --#*  Damage Limitiation System reduces damage here.
    --#**
    OnDamageWhenPaused = function(self, instigator, amount, vector, damageType)
        --# Record that we were damaged so WatchLoop 
        --# (defined in AutoPackUnit abstract class) can query it.
        self.Damaged = true
        
        --# Work out what effect DLS will have.
        --# This gives extra protection like shields, but shields
        --# regen automatically, DLS units needs to be repaired.
        --# Another reason why DLS is not the same as extra health/armour.
        --# Repairing the HCPP with 1000x DLS protection takes the same time/energy
        --# as repairing it with its initial 2x DLS protection.  Increasing
        --# Maxhealth means increasing repair times.
        
        --# DLS is active, so reduce the amount of damage inflicted.
        --# If the updating DLSDamageReductionFactor is not available,
        --# then use the static InitialDLSDamageReductionFactor value.
        amount = math.ceil(amount*
              (self.DLSDamageReductionFactor or self.InitialDLSDamageReductionFactor)
        )
   
        --# Forwarding OnDamage to Unit class - this damage will count 
        self:DoNormalDamage(instigator, amount, vector, damageType)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Overrided so DLS can be on during an upgrade.
    --#**
    OnDamageInOtherStates = function(self, instigator, amount, vector, damageType)
        if (not self.MustDisableAutoDefendWhileUpgrading) and self.IsProductionPaused then
            --# Behave as if DLS is on
            self:OnDamageWhenPaused(instigator, amount, vector, damageType)
        else
            --# Forwarding OnDamage to Unit class to reduce our health
            self:DoNormalDamage(instigator, amount, vector, damageType)
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Add Damage Limitiation System effects.
    --#**
    AddInactiveEffects = function(self)
    
        --# Destroy any previous effects including production smoke.
        self:DestroyEffects()
        
        --# Work out how big to make the effect.
        self.DLSEffectsScaleMultiplier = 
            math.pow(self.ProductionPercentageIncrease['Aggregate'], 0.25) 
        
        --# Add flash effect.
        table.insert(self.DLSEffectsBag, 
                         CreateAttachedEmitter(self, self.DLSEffectSettings.Sparks.Bone, self:GetArmy(), 
                                               '/effects/emitters/flashing_blue_glow_01_emit.bp')
                          :ScaleEmitter(self.DLSEffectSettings.Flash.Scale)
                            :OffsetEmitter(self.DLSEffectSettings.Flash.Offset.x,
                                           self.DLSEffectSettings.Flash.Offset.y,
                                           self.DLSEffectSettings.Flash.Offset.z)
                              :SetEmitterParam('LODCutoff', self.DLSEffectSettings.Flash.LODCutoff)
        )
        --# Add spark effects.
        for keffect,veffect in self.DLSEffectBlueprints do
            table.insert(self.DLSEffectsBag, 
                         CreateAttachedEmitter(self, self.DLSEffectSettings.Sparks.Bone, 
                                               self:GetArmy(), veffect)
                          :ScaleEmitter(self.DLSEffectSettings.Sparks.Scale *
                                        self.DLSEffectsScaleMultiplier)
                            :OffsetEmitter(self.DLSEffectSettings.Sparks.Offset.x,
                                           self.DLSEffectSettings.Sparks.Offset.y,
                                           self.DLSEffectSettings.Sparks.Offset.z)
                              :SetEmitterParam('LODCutoff', self.DLSEffectSettings.Sparks.LODCutoff)
            )
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Destroy active effects only.  
    --#*  This is safe to call more than once,
    --#*  i.e. it is state independent.
    --#**
    DestroyInactiveEffects = function(self)
        if self.DLSEffectsBag then 
            for keys,values in self.DLSEffectsBag do
                values:Destroy()
            end
        end
        self.DLSEffectsBag = {}
    end,  
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Destroy all effects.  
    --#*  This is safe to call more than once,
    --#*  i.e. it is state independent.
    --#**
    DestroyEffects = function(self)
        --# Try to call superclass version of function if any superclass has it defined
        if BaseClass.DestroyEffects then BaseClass.DestroyEffects(self) end
        --# Destroy any effects used by DLS system if they are running
        self:DestroyInactiveEffects()
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
        --# This makes sure that damage stabilisation effect is stopped
        self:DestroyInactiveEffects()
       
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
        
        --# Finally activate defense effects.
        --# Extending class can overriode this as long as it 
        --# calls this base class version first before
        --# activating its defense effects!
        self:AddInactiveEffects()
        --# Disable immediate upgrade because 
        --# InactiveEffects must be switched off first
        self.NotReadyToUpgrade = true
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*   
    --#*  This happens when unit's production is paused
    --#*  during an upgrade but we don't want autodefend to run
    --#*  so we run it and call this to switch defense effects off
    --#**
    DisableAutoDefendWhileUpgrading = function(self)
        --# This makes sure that damage stabilisation effect is stopped
        --# The health effects will have been altered anyway
        --# due to state change away from paused state.
        self:DestroyInactiveEffects()
    end,
    
}


return resultClass

end