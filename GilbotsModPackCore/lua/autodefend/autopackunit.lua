--#****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/autodefend/autopackunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Used by weaponless structures (i.e. economy based) 
--#*            that have an open/active animation that we can 
--#*            manipulate to appear in (or out of) a particular defensive 
--#*            position.  This interface allows these units to automatically 
--#*            assume that position when threatened or under fire.
--#*
--#*            Adds the following new Interfaces:
--#*            ---------------------------------
--#*            DoPackUpOperation
--#*            WaitUntilAnimationStart
--#*            DoAnimationWaitForLoop
--#*            
--#*            Updates these Interfaces to ActiveAnimationUnit:
--#*            ---------------------------------
--#*            OnActive/OnInactive
--#*            PauseActiveAnimation
--#*
--#*            Updates these Interfaces to UpgradeablePauseableProductionUnit:
--#*            ---------------------------------
--#*            PreparingToUpgradeState
--#*
--#*            This interface is automatically applied on top of the 
--#*            AutoDefendUnit interface.
--#*
--#****************************************************************************

local MakeAutoDefendUnit = 
    import('/mods/GilbotsModPackCore/lua/autodefend/autodefendunit.lua').MakeAutoDefendUnit

    
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeAutoPackUnit(baseClassArg) 

local BaseClass = MakeAutoDefendUnit(baseClassArg)
local resultClass = Class(BaseClass) {
 
    --# Quick way to check if a unit is an 
    --# autopack unit that extends this class.
    IsAutoPackUnit = true,
    
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  This function contains code peripheral to the packing
    --#*  unpacking animation; i.e. it handles the state change safely.
    --#**
    DoPackUpOperation = function(self, isPackedRequested)
        --# Do we need to pack or unpack to acheive this?
        if self.IsPacked ~= isPackedRequested then
        
            --# Check if we need to adjust our animation
            --# so that we appear in a defensive state/position.
            --# Aeon Mexes and HCPP do this.
            --# UEF units don't as far as I remember.
            if self.DoPackUpAnimation then
                --# Disable upgrade while packing/unpacking
                self.NotReadyToUpgrade = true
                --# Work ot what toggles we need to temporarily disable
                self.HasShieldToggles =  self:TestToggleCaps('RULEUTC_ShieldToggle')
                
                --# There is an animation to do.
                --# Disable toggle buttons and lock while we animate.
                self.Animating = true
                self:RemoveToggleCap('RULEUTC_ProductionToggle')
                self:RemoveToggleCap('RULEUTC_WeaponToggle')
                if self.HasShieldToggles then self:RemoveToggleCap('RULEUTC_ShieldToggle') end
                
                --# This must be defined in extending class
                self:DoPackUpAnimation(isPackedRequested)
                
                --# reenable toggle buttons and unlock
                if self.HasShieldToggles then self:AddToggleCap('RULEUTC_ShieldToggle') end
                self:AddToggleCap('RULEUTC_WeaponToggle')
                self:AddToggleCap('RULEUTC_ProductionToggle')
                self.Animating = false
            end
            --# Record operation is complete.
            self.IsPacked = isPackedRequested
            --# Does this operation enable the upgrade?
            if (self.IsPacked and self.UpgradesFromPacked) 
              or (not self.IsPacked and not self.UpgradesFromPacked)
            then
                --# Enable upgrade
                self.NotReadyToUpgrade = false 
            end
        end
    end,
  

--[[   



Any extending class needs to define this next function to conform to the example below. It must manipulate the open animation to give the effect of the unit packing/unpacking, depending on argument.
This makes it look like the unit can change into a defensive position.
    
    DoPackUpAnimation = function(self, isPackedRequested)
        --# Do we need to pack or unpack to acheive this?
        if isPackedRequested then 
            --# We are deactivating production, so perform pack animation
            self.AnimationManipulator:SetRate(-0.5)
            --# Perform some unit specific waiting condition here
        else
            --# We are activating production, so perform unpack animation.
            self.AnimationManipulator:PlayAnim(
                self:GetBlueprint().Display.AnimationOpen, false):SetRate(0.5)
            --# Perform some unit specific waiting condition here
        end
    end,
    
    
    
]]
    

    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  This function manipulates the open animation
    --#*  to give the effect of the unit packing/unpacking.
    --#*  This makes it look like the unit can change into a defensive position.
    --#*  Do not change the numerical values in these functions
    --#*  or the animation will lose its smoothness and appear to jump.
    --#*          
    --#*  This used to be done with a simple WaitFor SIM function
    --#*  but that sometimes causes errors in FA, so this code
    --#*  was an alternative using the WaitTicks SIM function.
    --#*
    --#**
    WaitUntilAnimationStart = function(self)
        --# Safety check first
        if self.AnimationIsAtBeginning or 
          not self.IsActiveAnimationUnit then 
            return 
        end
    
        --# Units that do the pack up animation will not normally
        --# play the active animation in an infinite loop but
        --# I put in this next line to test as I can disbale it.
        if self.ActiveAnimationDoesNotUseInfiniteLoop then
            WARN('WaitUntilAnimationStart: Using deprecated WaitFor method.')
                --# Debugging code
                --local thisThread = CurrentThread()
                --if self.LastThread ~= thisThread then
                --    LOG('AMassCollectionUnit#' .. self:GetEntityId() 
                --    .. ': NewThread=' .. repr(thisThread)
                --    )
                --    self.LastThread = thisThread 
                --end

            --# Wait until we are at beginning of animation.
            WaitFor(self.ActiveAnimationManipulator)
      
        else
    
            --# The way to check if the animation is at the beginning 
            --# is if its AnimationTime is zero.
            local previousTick = 0
            local thisTick = self.ActiveAnimationManipulator:GetAnimationTime()
            if thisTick > previousTick then 
                --# Make sure animation is running
                self.ActiveAnimationManipulator:SetRate(self.ActiveAnimationRate)
                --# The way to check if its reached beginning again is if it 
                --# thisTick passes zero again.
                while thisTick > previousTick do
                    WaitTicks(1)
                    previousTick, thisTick = 
                        thisTick, self.ActiveAnimationManipulator:GetAnimationTime() 
                end
            end
            
            --# Stop animation at near enough right place
            self.ActiveAnimationManipulator:SetRate(0)
            self.ActiveAnimationManipulator:SetAnimationTime(0)
        end
        
        --# Record we have reached the animation start.
        self.AnimationIsAtBeginning = true
        --# Record if we are packed (or not) now that
        --# we have reached the animation start.
        self.IsPacked = self.PackedAtAnimationStart
        --# Next, check/record if we are ready to upgrade.
        if self.IsPacked and self.UpgradesFromPacked then 
            self.NotReadyToUpgrade = false
        end
    end,

    
    
    --#*    
    --#*  Gilbot-X says:    
    --#*
    --#*  This is called once by OnStopBeingBuilt and then 
    --#*  again whenever unit is paused/unpaused.
    --#*  Pausing/resuming the animation should be done inside
    --#*  the context of appropriate states.
    --#*
    --#*  This is an override of a function defined in 
    --#*  ActiveAnimationUnit.lua.
    --#**
    PauseActiveAnimation = function(self, toggleToPaused)
        
        --# Autopack units don't do pause the active animation, 
        --# they wait to start of animation and pack instead,
        --# which is done elsewhere in the code.
        --# If animating (already packing/unpacking) then also 
        --# ignore this call (call shouldn't have been made).
        if toggleToPaused or self.Animating then return end
        
        --# Make sure there is an animation manipulator working.
        --# It also makes sure that infinite loop animations
        --# are playing.
        self:EnsureActiveAnimationManipulatorIsCreated()
        self.AnimationIsAtBeginning = false
        self.NotReadyToUpgrade = true
        
        --# If this unit does its animation one loop at a time
        --# and its at the beginning or end of a loop then
        --# play another loop
        if self.ActiveAnimationDoesNotUseInfiniteLoop then
            --# Play animation once   
            self.ActiveAnimationManipulator:PlayAnim(
                self:GetBlueprint().Display.AnimationActivate,       
                false
            )
        end
        --# Make sure animation is moving forward at whatever speed is appropriate
        --# So current loop can finish or if infinite animation is being unpaused
        self.ActiveAnimationManipulator:SetRate(self.ActiveAnimationRate)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Certain units get this called from UnpausedState
    --#**
    DoAnimationWaitForLoop = function(self)
        --# This while loop keeps the active animation going and
        --# performs a routine scan for enemies as part of autopack.
        while not (self:BeenDestroyed() or self:IsDead() or self.IsProductionPaused) do
            --# Scan for nearby enemy units
            if self.AutoDefendToggledOn and self:CheckAreEnemyUnitsNearby() then
                --# Pause production
                self:SetScriptBit('RULEUTC_ProductionToggle', true)    
            end
           
            --# Play another loop of the animation
            self:PauseActiveAnimation(false) 
            self:WaitUntilAnimationStart()
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
        --# Any extending class makes sure that 
        --# damage stabilisation effect is stopped or
        --# sensitive shield switched off before calling its 
        --# baseclass version (which could be this)

        --# The unpack call is made between destroying 
        --# defense effects and adding active effects
        self:DoPackUpOperation(false)
        
        --# Call base class code now to take care of active animations, 
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
        --# That will take care of active animations,
        --# sounds, consumption etc.        
        BaseClass.OnInactive(self)
        
        --# The unpack call is made in this class so we can sandwich call
        --# in between destroying defense effects and adding active effects
        self:DoPackUpOperation(true)
        
        --# Finally activate defense effects.
        --# Extending class can overriode this as long as it 
        --# calls this base class version first before
        --# activating its defense effects!
    end,
    
}


return resultClass

end