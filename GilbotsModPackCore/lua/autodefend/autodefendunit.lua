--#****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/autodefend/autodefendunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Used by weaponless structures (i.e. economy based) 
--#*            This interface allows these units to automatically 
--#*            activate a defense when threatened or under fire.
--#*
--#*            Adds the following new Interfaces:
--#*            ---------------------------------
--#*            WatchState
--#*            CheckAreEnemyUnitsNearby
--#*            DoWatchLoop
--#*            OnDamageWhenPaused
--#*            
--#*            Updates these Interfaces to PauseableProductionUnit:
--#*            ---------------------------------
--#*            PausedState/UnpausedState
--#*          
--#*
--#*            The ActiveAnimationUnit interface can also be added to a unit that has this, 
--#*            but the ActiveAnimationUnit interface must be added before this one, not after.
--#*            Neither of these interfaces can be applied without the PauseableProductionUnit
--#*            interface being applied beforehand.
--#*
--#*            For example, the Aeon HCPP uses this interface without the ActiveAnimationUnit
--#*            interface, but all the Aeon mexes use the AutoPackUnit and ActiveAnimationUnit 
--#*            interfaces together.
--#*
--#****************************************************************************

--# Need this so we can call base class code
--# and bypass any intervening superclass
local Unit = import('/lua/sim/unit.lua').Unit

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeAutoDefendUnit(baseClassArg) 

local resultClass = Class(baseClassArg) {
 
    --# Quick way to check if a unit is an 
    --# autopack unit that extends this class.
    IsAutoDefendUnit = true,
    
    --# This sets how often the unit should 
    --# checks to see if it should unpack.
    --# The longer it waits, the safer it will be
    --# but you will lose out on production time
    --# as a consequence to extra safety.
    WatchLoopPeriod = 10,
 
 
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        --# Do base class versions first
        baseClassArg.DoBeforeAnyStateChanges(self)
    
        --# This isn't important
        --# but I've done it for safety
        self.Damaged = false
            
        --# Switch Auto-pack on.
        --# If it is toggled off.. 
        if not self:GetScriptBit('RULEUTC_WeaponToggle') then
            --# Switch auto-toggle on
            self:SetScriptBit('RULEUTC_WeaponToggle', true)
        else 
            --# or just run the code that switches it on 
            self:OnScriptBit1Set() 
        end
    end, 
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  How to behave when production pause is toggled to 'unpause'
    --#**
    UnpausedState = State {
        Main = function(self)
            --# Call code from PauseableProductionUnit base class first
            baseClassArg.UnpausedState.Main(self)
            
            --# Special code for units whose animation pauses 
            --# after each loop to do processing.
            if self.IsActiveAnimationUnit and self.ActiveAnimationDoesNotUseInfiniteLoop 
              and self.DoAnimationWaitForLoop then
                self:DoAnimationWaitForLoop()
            end
        end,

        --# Defer to a separate function defined outside the state 
        --# because it runs identically in two states.
        OnDamage = function(self, instigator, amount, vector, damageType)
           --# For debugging only
            if instigator == 'SensitiveShield' then
                WARN('AutoDefend: OnDamageWhenUnpaused: SensitiveShield is instigatior.')
                return
            end
        
            --# Record that we were damaged so WatchLoop 
            --# (defined in AutoPackUnit abstract class) can query it.
            self.Damaged = true
            --# Forwarding OnDamage to Unit class to reduce our health
            self:DoNormalDamage(instigator, amount, vector, damageType)
            
            --# This takes place outside WatchState so pause production
            if (not self.Animating) and self.AutoDefendToggledOn then 
                --# Pause production
                self:SetScriptBit('RULEUTC_ProductionToggle', true)
            end
        end,
        
        --# Defer to PauseableProductionUnit base class 
        OnProductionPaused = baseClassArg.UnpausedState.OnProductionPaused
    },

    

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  How to behave when production pause is toggled to 'pause'
    --#**
    PausedState = State {
        Main = function(self)
            --# Call code from PauseableProductionUnit base class first
            --# This switches on shield  or DLS so assume packing done already
            baseClassArg.PausedState.Main(self)
            
            --# Check if we are eligeable to go into WatchState for 
            --# automatic unpacking.
            if self.AutoDefendToggledOn and 
                (self.Damaged or 
                    (self.PackIfEnemyUnitsNearby and self:CheckAreEnemyUnitsNearby())
                )                                   
            then
                --# WatchState is defined in both of the two extending classes.
                ChangeState(self, self.WatchState)
            end
        end,

        --# Defer to a separate function defined outside the state 
        --# because it runs identically in two states.
        OnDamage = function(self, instigator, amount, vector, damageType)
            --# Note, must call using self as we are not linking to baseclass code 
            self:OnDamageWhenPaused(instigator, amount, vector, damageType)
        end,
        
        --# Defer to PauseableProductionUnit base class 
        OnProductionUnpaused = baseClassArg.PausedState.OnProductionUnpaused
    },

    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This state was added so that the unit will wait until  
    --#*  it hasn't been notified of a projectile hit for a while
    --#*  before it automatically unpacks.  
    --#* 
    --#*  Units must be in this state for DLS or SensitiveShield to work.
    --#**
    WatchState = State {
        Main = function(self)
            self:DoWatchLoop()
        end,

        --# Defer to a separate function defined outside the state 
        --# because it runs identically in two states.
        OnDamage = function(self, instigator, amount, vector, damageType)
            --# Note, must call using self as we are not linking to baseclass code 
            self:OnDamageWhenPaused(instigator, amount, vector, damageType)
        end,
        
        --# Defer to PauseableProductionUnit base class 
        OnProductionUnpaused = baseClassArg.PausedState.OnProductionUnpaused
    },
    
    
  

    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by  calls to OnDamage received in PausedState 
    --#*  and WatchState.
    --#*
    --#*  This must be overrided so that damage is taken differently when
    --#*  the unit is packed.
    --#**
    OnDamageWhenPaused = function(self, instigator, amount, vector, damageType)
        WARN('AutoDefend: Base class version of OnDamageWhenPaused called.'
         .. ' This should have been overrided.'
        )
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by  calls to OnDamage received in PausedState 
    --#*  and WatchState.
    --#*
    --#*  This must be overrided so that damage is taken differently when
    --#*  the unit is packed.
    --#**
    DoNormalDamage = function(self, instigator, amount, vector, damageType)
        --# Forwarding OnDamage to Unit class to reduce our health
        baseClassArg.OnDamage(self, instigator, amount, vector, damageType)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is here just as a safety measure.
    --#*  This shouldn't really happen as shield should be off by this point.
    --#*  Without this check we'd get an error.
    --#*  Need to investigate why SensitiveShield is passing calls to
    --#*  OnDamage outside of the PausedState.
    --#**
    OnDamage = function(self, instigator, amount, vector, damageType)
        --# This version gets called when 
        --# the unit is under attack while being built
        if self:IsBeingBuilt() then
            self:DoNormalDamage(instigator, amount, vector, damageType)
        else
            --# This shouldn't happen
            LOG('AutoDefend: OnDamage called outside of valid state in Autodefend unit.'
              .. ' What was unit ' .. self:GetUnitId() 
              .. ' e=' .. self:GetEntityId()
              .. ' doing?'
            )
            --# Forwarding OnDamage to Unit class to reduce our health
            self:OnDamageInOtherStates(instigator, amount, vector, damageType)
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is here just as a safety measure.
    --#*  This shouldn't really happen as shield should be off by this point.
    --#*  Without this check we'd get an error.
    --#*  Need to investigate why SensitiveShield is passing calls to
    --#*  OnDamage outside of the PausedState.
    --#**
    OnDamageInOtherStates = function(self, instigator, amount, vector, damageType)
        --# This is here as a safety measure.
        --# This shouldn't really happen as shield should be off by this point.
        if instigator == 'SensitiveShield' then
            LOG('AutoDefend: OnDamageInOtherStates: SensitiveShield is instigatior.')
        else
            --# Forwarding OnDamage to Unit class to reduce our health
            self:DoNormalDamage(instigator, amount, vector, damageType)
        end
    end,
            
            
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This is the default routine executed by WatchState in an extending class.
    --#*  The unit checks once every 10 seconds to see if it's safe to unpack.
    --#*  The extending class should set self.PackIfEnemyUnitsNearby
    --#*  for this to be used.
    --#**
    DoWatchLoop = function(self)
        while not self:IsDead() and self.AutoDefendToggledOn do
            --# Ignore last time we were damaged; 
            --# look for another hit from now on, 
            --# over the next 10 seconds
            self.Damaged = false
            WaitSeconds(self.WatchLoopPeriod)
            --# If we were not damaged again 
            --# within the last 10 seconds
            if (not self.Damaged) and 
                --# and there aren't enemy units in range if we include that 
                (not (self.PackIfEnemyUnitsNearby and self:CheckAreEnemyUnitsNearby()))
            then
                --# Unpause production
                self:SetScriptBit('RULEUTC_ProductionToggle', false)
            end
        end
    end,
  
  
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Can be used by units to check if it's safe to unpack.
    --#*  The extending class should set self.PackIfEnemyUnitsNearby
    --#*  for this to be used.
    --#**
    CheckAreEnemyUnitsNearby = function(self)
        local Utilities = import('/lua/utilities.lua')
        local nearbyEnemyUnits = Utilities.GetEnemyUnitsInSphere(self, self:GetPosition(), 
                      self:GetBlueprint().Intel.VisionRadius) 
        --# If there were any enemy units nearby..
        for k, vUnit in nearbyEnemyUnits do
            if vUnit:GetBlueprint().Defense.SurfaceThreatLevel > 0.1 and
              not vUnit:IsThisUnitCloaked() then 
                return true
            end
        end
        
        --# No nearby units were dangerous
        return false
    end,
  
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  These functions are called when the weapon-toggle button
    --#*  (which I use as the auto-pause toggle button) using bit 1
    --#*  is pressed.  They are called from my override of OnScriptBitSet
    --#*  and OnScriptBitClear defined in my hook of Unit.lua.
    --#**
    OnScriptBit1Set = function(self)
        self.AutoDefendToggledOn = true
    end,

    OnScriptBit1Clear = function(self)
        self.AutoDefendToggledOn = false
    end,
    
}


return resultClass

end