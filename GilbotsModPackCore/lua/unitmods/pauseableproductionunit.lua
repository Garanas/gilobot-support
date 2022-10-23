--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/pauseableproductionunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : This file is to add an interface to particular structure units,
--#*            namely those that produces energy or mass.  It gives the unit a
--#*            set of States that helps the programmer manage their behaviour
--#*            consistently, so that less code (if any) is needed in individual
--#*            unit scripts.  This is efficient as many of these units benefit
--#*            from having similar functionality. 
--#*
--#*            Defines the following Interface:
--#*            ---------------------------------
--#*            DoBeforeAnyStateChanges
--#*            UnpausedState
--#*            PausedState
--#*
--#*            This interface facilitates upgrade delaying and blocking.
--#*
--#*****************************************************************************

--# Need this so we can call base class code
--# and bypass any intervening superclass
local Unit = import('/lua/sim/unit.lua').Unit
local messageDialog=nil

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakePauseableProductionUnit(baseClassArg)


local resultClass = Class(baseClassArg) {

    --# Quick way to check if a unit extends this class.
    IsPauseableProductionUnit = true,

    --# This function does initialisation of non-static variables.
    --# We set up effect size values and fork the update thread,
    OnStopBeingBuilt = function(self,builder,layer)
        --# Call base class code first
        baseClassArg.OnStopBeingBuilt(self,builder,layer)
    
        --# This was done in GPG code for units that
        --# had production.
        self:SetMaintenanceConsumptionActive()
    
        --# This is code that will be done after the unit has 
        --# been built but before the first state is changed
        --# in a structure unit that uses states.
        self:DoBeforeAnyStateChanges()
        
        --# The rest is the same code we call when 
        --# we are in the PausedState and changing
        --# into the initial state.
        Unit.OnProductionUnpaused(self)           
        ChangeState(self, self.UnpausedState)
    end,
  
 
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This serves as an interface/template for inheriting classes to override.
    --#*  Override this with  code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
    
    end,
    
    
 
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  How to behave when production pause is toggled to 'unpause'.
    --#*  This serves as an interface/template for inheriting classes to override.
    --#*  It contains 'dormant code' just for use by certain of my inheriting classes.
    --#*  Dormant code is code that only run in inheriting classes that set certain 
    --#*  flags that indicate the code should be run.
    --#**
    UnpausedState = State {
        Main = function(self)
            --# Keep a reference to which state we are in
            self.PreviousState = self.UnpausedState
            --# Update effects to match current state
            self:OnActive()
            --# This next function should contain stuff that can only be done in a thread,
            --# i.e. it involves waiting using WaitFor()
            if self.RunFrom_UnpausedState_Main then self:RunFrom_UnpausedState_Main() end
        end,

        --# This is from Massfab code.
        --# Thsi callback runs when user deactivates unit.
        OnConsumptionInActive = function(self)
            baseClassArg.OnConsumptionInActive(self)
            ChangeState(self, self.PausedState)
        end,
        
        OnProductionPaused = function(self)
            --# Call base class version (outside of state) 
            --# which sets production active.
            Unit.OnProductionPaused(self)
            ChangeState(self, self.PausedState)
        end,
    },
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  How to behave when production pause is toggled to 'pause'.
    --#*  This serves as an interface/template for inheriting classes to override.
    --#*  It contains 'dormant code' just for use by certain of my inheriting classes.
    --#*  Dormant code is code that only run in inheriting classes that set certain 
    --#*  flags that indicate the code should be run.
    --#**
    PausedState = State {
        Main = function(self)
            --# Keep a reference to which state we are in
            self.PreviousState = self.PausedState
            --# Update effecst to match current state
            self:OnInactive()
            --# This next function should contain stuff that can only be done in a thread,
            --# i.e. it involves waiting using WaitFor()
            if self.RunFrom_PausedState_Main then self:RunFrom_PausedState_Main() end
        end,

        --# This is from Massfab code.  
        --# This callback is run when user activates unit.
        OnConsumptionActive = function(self)
            baseClassArg.OnConsumptionActive(self)
            ChangeState(self, self.UnpausedState)
        end,
        
        OnProductionUnpaused = function(self) 
            --# Call base class version (outside of state) 
            --# which sets production active.
            Unit.OnProductionUnpaused(self)           
            ChangeState(self, self.UnpausedState)
        end,
    }, 


    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Call this when the bonus we give changes because 
    --#*  this unit is becoming active/inactive or the slider
    --#*  control alters power consumption.
    --#**
    RefreshAdjacencyBonus = function(self)
        --# Only do this if we are part of an active network..
        if self.MyNetwork and not self.MyNetwork.IsBroken then
            --# Recalculate bonuses
            self.MyNetwork:PropogateBonuses()
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
        baseClassArg.OnActive(self)
        --# Tell the network to recalculate bonuses.
        --# New value of self.IsProductionPaused will
        --# mean that bonus is now given again.
        self:RefreshAdjacencyBonus()
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
        --# Call base class code after.
        baseClassArg.OnInactive(self)
        --# Tell the network to recalculate bonuses.
        --# New value of self.IsProductionPaused will
        --# mean that bonus is not given anymore.
        self:RefreshAdjacencyBonus()
    end,
}


return resultClass

end
