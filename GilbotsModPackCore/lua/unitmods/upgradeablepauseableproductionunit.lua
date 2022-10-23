--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/upgradeablepauseableproductionunit.lua
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
--#*            PreparingToUpgradeState
--#*            UpgradingState
--#*            DisableAutoDefendWhileUpgrading
--#*
--#*            This interface facilitates upgrade delaying and blocking.
--#*
--#*****************************************************************************

--# Need this so we can call base class code
--# and bypass any intervening superclass
local Unit = import('/lua/sim/unit.lua').Unit
local messageDialog=nil

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local MakePauseableProductionUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/pauseableproductionunit.lua').MakePauseableProductionUnit

    
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeUpgradeablePauseableProductionUnit(baseClassArg)

local BaseClass = MakePauseableProductionUnit(baseClassArg)  
local resultClass = Class(BaseClass) {

    --# Quick way to check if a unit extends this class.
    IsUpgradeablePauseableProductionUnit = true,


    --#-----------------------------------------------------------
    --#      Special Upgrading Behaviour
    --#-----------------------------------------------------------
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  The following 3 keys are used here and can
    --#*  be set by extending classes wishing to 
    --#*  use this extra functionality.
    --#*
    --#*  self.NotReadyToUpgrade = true/false   |  Use to delay upgrade so 
    --#*                                        |   an animatuon can be done first
    --#*  self.UpgradeBlocked = true/false      |  Use to prevent any upgrading so 
    --#*                                        |   a condition can be met first
    --#*  self.UpgradeBlockedMessage = string   |  Message to show when upgarding is 
    --#*                                        |   blocked, stating which condition 
    --#*                                        |   must be met first.
    --#*      
    --#*
    --#*  Notes:
    --#*
    --#*  When Unit.OnStartBuild is called, 
    --#*  some code that you can't access/modify will create a mesh for
    --#*  the unit we are upgrading to.  This can sometimes be undersireable.
    --#*  This override allows calls to AdjacencyStructureUnit.OnStartBuild to 
    --#*  be deferred until later, by intercepting and cancelling the order 
    --#*  so we have time to do anything first that we might want to do before
    --#*  the mesh of the new unit is created.
    --#*  
    --#*  For example, waiting until the Aeon MeX activeAnimation is in the 
    --#*  correct position that corresponds with the start of its upgrade animation. 
    --#*
    --#*  In the GPG base classes, OnStartBuild calls ChangeState to go into UpgradingState.
    --#*  Now, I override the UpgradingState to call this BaseClass version of
    --#*  OnStartBuild which will create the mesh, and it then executes the base class
    --#*  version of UpgradingState (main) to execute the rest of the upgarde animating.
    --#**
    OnStartBuild = function(self, unitBeingBuilt, order) 
        --# First, is this upgrade blocked due to a condition not being met?
        --# i.e. the unit trying to upgrade is not old enough yet?
        if self.UpgradeBlocked then 
            --# It is blocked, so simply cancel 
            --# the upgrade command, show message (optional) and then return.
            IssueStop({self})
            IssueClearCommands({self})
            if self.UpgradeBlockedMessage then
                if self.BuildableCategoryName then
                    self:AddBuildRestriction(categories[self.BuildableCategoryName])
                    self.RestrictionNeedsLifting = true
                end
                self:FlashMessage(self.UpgradeBlockedMessage, 5)
            end
        
        --# Upgrade was not blocked...
        else
            --# Check flags to see if the unit is ready to upgrade,
            --# i.e. flags can be set when the animation position is aligned
            --# ready for the upgarde animation manipulator to take over
            --# so that the animation doesn't jump, as for Aeon MeXes.
            if self.PreparingToUpgradeState and self.NotReadyToUpgrade then
                --# Unit isn't ready, so call code to prepare unit for upgrade.
                --# That state will call us back when its done.
                IssueStop({self})
                IssueClearCommands({self})
                ChangeState(self, self.PreparingToUpgradeState)
            --# We are ready to upgrade.
            else
                --# This links to code in timebasedresourceoutputunit.lua
                if self.IsTimeBasedOutputUnit then
                    self:DecideIfCanPassOnProductionPercentageIncreaseToUpgrade(unitBeingBuilt)
                end
                
                --# Store these values (so that 
                --# Unit.OnStartBuild can be called later)
                --# and start upgrading.             
                self.UnitBeingBuilt = unitBeingBuilt
                self.BuildOrder = order
                ChangeState(self, self.UpgradingState)
            end
        end
    end,

    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Called when Mex unit is given an upgrade command.
    --#*  This default version does nothing, it just acts as an interface template.
    --#*  Override this to make use of the functionality.
    --#*  For example, this is overrided by Autopack units where the 
    --#*  unit needs to put its animation in a certain position
    --#*  before it starts the upgrade command.
    --#**
    PreparingToUpgradeState = State {
        Main = function(self)
        
            --# Aeon Mexes do this.  If we have to stop producing when upgrading
            if self.StopProductionWhileUpgrading and not self.IsProductionPaused then
                --# Stop production (update economy)
                Unit.OnProductionPaused(self)
                --# Update unit appearance (autopack)
                self:OnInactive()
            end
            
            if self.MustDisableAutoDefendWhileUpgrading then
                --# Switch off any autodefend effects not lost by changing state
                self:DisableAutoDefendWhileUpgrading()
            end
            
            --# Some units will now need to unpack
            if self.IsAutoPackUnit and not self.UpgradesFromPacked then
                --# We need to unpack.  
                --# Animation will still be stopped
                --# after this call.
                self:DoPackUpOperation(false)
            end    
            
            --# Now we are ready to upgrade so let's try again!
            self.NotReadyToUpgrade = false
            local upgradeBPName = self:GetBlueprint().General.UpgradesTo or false
            if upgradeBPName then IssueUpgrade( {self}, upgradeBPName )  end
        end,
        
        --# Defer to a separate function defined outside the state 
        --# because it runs identically in two states.
        OnDamage = function(self, instigator, amount, vector, damageType)
            if self.OnDamageInOtherStates then
                self:OnDamageInOtherStates(instigator, amount, vector, damageType)
            else self:OnDamage(instigator, amount, vector, damageType)
            end 
        end,
    },
    
    
    --#*
    --#*  Gilbot-X says:
    --#*   
    --#*  This happens when unit's production is paused
    --#*  during an upgrade but we don't want autodefend to run
    --#*  so we run it and call this to switch defense effects off
    --#**
    DisableAutoDefendWhileUpgrading = function(self)
      
    end,
          
    --#*
    --#*  Gilbot-X says:
    --#*        
    --#*  Normally this state gets initiated directly from OnStartBuild
    --#*  when a Mex unit is given an upgrade command.
    --#*  Now it's called from PreparingToUpgradeState so 
    --#*  units can do something first to prepare for upgrading
    --#*  when they are issued an upgrade command.
    --#**  
    UpgradingState = State {
    
        Main = function(self)
            --# In this class, UpgradingState is called by our own override
            --# of OnStartBuild which doesn't call its own base class version.
            --# so we must go back and call the base class version of OnStartBuild now.
            BaseClass.OnStartBuild(self, self.UnitBeingBuilt, self.BuildOrder)
            
            --# This links to code placed in MassCollectUnit in FA
            if self.WatchUpgradeConsumption then 
                self.UpgradeWatcher = self:ForkThread(self.WatchUpgradeConsumption)
            end
        
            --# Otherwise the upgrading state main function
            --# is the same as its base class.
            --# This next call gets the thread to 
            --# do the upgrading animation while the upgrade
            --# takes place.            
            BaseClass.UpgradingState.Main(self)
        end,

        --# Defer this to base class code.
        OnStopBuild = BaseClass.UpgradingState.OnStopBuild,

        --#*
        --#*  Gilbot-X says:
        --#*        
        --#*  I had to override this so if the upgrade is cancelled
        --#*  we go back into one of our states.
        --#**
        OnFailedToBuild = function(self)
            --# This next block is all GPG code.
            --# except I removed a call to PlayAnimation
            --# because that is dealt with by the appropriate states,
            --# and the call to ChangeState at the end.
            do --GPG Code from FA StructureUnit/Unit in defaultunits.lua
              Unit.OnFailedToBuild(self)
              self:EnableDefaultToggleCaps()
              if self.AnimatorUpgradeManip then self.AnimatorUpgradeManip:Destroy() end
              if self:GetCurrentLayer() == 'Water' then
                  self:StartRocking()
              end
              self:PlayUnitSound('UpgradeFailed')
              self:CreateTarmac(true, true, true, 
                                self.TarmacBag.Orientation, 
                                self.TarmacBag.CurrentBP)
            end --of GPG Code from FA StructureUnit in defaultunits.lua
            
            --# Gilbot-X says:
            --# I added this.  Aeon Mex units do this.
            if self.StopProductionWhileUpgrading and 
              (self.PreviousState == self.UnpausedState) then
                --# Switch production back on if it was off 
                --# and we are going back into unpaused state 
                Unit.OnProductionUnpaused(self)
            end
            
            --# I also changed this.
            --# Instead of going to 'idle' state, we go to
            --# the 'paused' or 'unpaused' state.            
            ChangeState(self, self.PreviousState)
            --# The statechange will call OnActive or OnInactive
            --# so we don't need to worry about switching back on autodefend stuff
        end,
        
        --# Defer to a separate function defined outside the state 
        --# because it runs identically in two states.
        OnDamage = function(self, instigator, amount, vector, damageType)
            if self.OnDamageInOtherStates then
                self:OnDamageInOtherStates(instigator, amount, vector, damageType)
            else self:OnDamage(instigator, amount, vector, damageType)
            end
        end,
    },  
}


return resultClass

end