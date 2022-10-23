--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/activeanimationunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : This extra code was originally from my Exponential Mass Extractors mod.
--#*            I made it to remove jumps in animation and to make use of the
--#*            fact that certain positions in the unit's animations make them 
--#*            appear to be either in a defensive or vulnerable state or position.          
--#*
--#*            Adds the following Interface to PauseableProductionUnit:
--#*            ---------------------------------
--#*            EnsureActiveAnimationManipulatorIsCreated
--#*            PauseActiveAnimation
--#*            
--#*            Changes this GPG Interface:
--#*            ---------------------------------
--#*            PlayActiveAnimation
--#*            OnActive/OnInactive
--#*
--#*            The Auto-Pack interface can also be added to a unit that has this, 
--#*            but the autopack interface must be added after this one, not before.
--#*            Neither of these interfaces can be applied without the PauseableProductionUnit
--#*            interface being applied beforehand.
--#*
--#*            For example, the ??? units use this interface without the AutoPackUnit
--#*            interface, but all the Aeon mexes use the AutoPackUnit and ActiveAnimationUnit 
--#*            interfaces together.
--#*
--#*****************************************************************************

local GilbotUtils_IsValueInTable = 
    import('/mods/GilbotsModPackCore/lua/utils.lua').IsValueInTable
    
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeActiveAnimationUnit(baseClassArg)

local BaseClass = baseClassArg 
local resultClass = Class(BaseClass) {

    --# Quick way to check if a unit extends this class.
    IsActiveAnimationUnit = true,

    --# This is all for animation control.
    ActiveAnimationRate = 1,
    ActiveAnimationMaxRate =8, -- might even need to lower this...
    
    --# Extending classes should define this next key
    --# if their active animation is not to
    --# be played in an infinite loop, i.e. they use autopack.
    --# So far the Aeon Mexes are the only units to use this.
    --# because of their animation files.  Using this can
    --# occaisionally cause some script errors 
    --# which stops the animation from occuring even when 
    --# active so for FA I recommend against using this.
    ActiveAnimationDoesNotUseInfiniteLoop = false,
    
    --# Declare this here in hope that it stays in scope better
    ActiveAnimationManipulator = nil,

    
    --#*    
    --#*  Gilbot-X says:    
    --#*
    --#*  This is just a stub in StructureUnit class, 
    --#*  so no need to call any base class versions.
    --#*  It is called by OnStopBeingBuilt in that class.
    --#*  but it is only called once to start the animation.
    --#*  Pausing/resuming the animation is done from 
    --#*  the update thread and in States defined
    --#*  in the TimeBasedMassCreationUnit class.
    --#**
    PlayActiveAnimation = function(self)
        --# Next line might be redundant but kept for safety
        self.AnimationIsAtBeginning = false
        self:PauseActiveAnimation(false)
    end,
        
  

    --#*    
    --#*  Gilbot-X says:    
    --#*
    --#*  It is called by PauseActiveAnimation in this class and 
    --#*  in Aeonunits.lua where that class does packing/unpacking.
    --#**
    EnsureActiveAnimationManipulatorIsCreated = function(self)
        
        --# Make sure there is an animation manipulator working.
        if not self.ActiveAnimationManipulator then
            
            --# This is for debugging only.  I intend to delete it.
            if self.AlreadyMadeOneActiveAnimationManipulator then
              WARN('MassCollectionUnit: PauseActiveAnimation: '
                .. 'Creating replacement ActiveAnimationManipulator.')
            end
        
            --# Create a new animation manipulator.
            --# This should last the lifetime of the MeX object
            --# but I have made many observations of that not happening.
            self.ActiveAnimationManipulator = CreateAnimator(self)
            self.Trash:Add(self.ActiveAnimationManipulator)
            self.AlreadyMadeOneActiveAnimationManipulator = true
            
            if not self.ActiveAnimationDoesNotUseInfiniteLoop then
                --# Play animation in a loop
                self.ActiveAnimationManipulator:PlayAnim(
                    self:GetBlueprint().Display.AnimationActivate,       
                    true
                )
                self.AnimationIsAtBeginning = false
            end
        end
    end,
  
  
  
    --#*    
    --#*  Gilbot-X says:    
    --#*
    --#*  This is called once by OnStopBeingBuilt and then 
    --#*  again whenever unit is paused/unpaused.
    --#*  Pausing/resuming the animation should be done inside
    --#*  the context of appropriate states.
    --#**
    PauseActiveAnimation = function(self, toggleToPaused)
        --# Make sure there is an animation manipulator working.
        self:EnsureActiveAnimationManipulatorIsCreated()
        
        --# Resume animation at appropriate speed, 
        --# or pause it, depending on toggle argument
        if toggleToPaused then
            --# We are pausing animation that runs in an infinite loop
            self.ActiveAnimationManipulator:SetRate(0)
        else
            --# Make sure animation is moving forward at whatever speed is appropriate
            --# So current loop can finish or if infinite animation is being unpaused
            self.ActiveAnimationManipulator:SetRate(self.ActiveAnimationRate)
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
        --# Call base class code first
        BaseClass.OnActive(self)
        --# Make sure animation is not paused.
        self:PauseActiveAnimation(false)
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
        --# Make sure animation is paused.
        --# Note that this call does nothing 
        --# to Autopack units as that class
        --# overrides the function.
        self:PauseActiveAnimation(true)
        --# Call base class code first
        BaseClass.OnInactive(self)
    end,
}


return resultClass

end