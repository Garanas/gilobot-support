--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/timebasedoutputunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : This extra code is code that was used by both my Exponential 
--#*            Mass Extractors mod and my HCPP mod. It manages a thread that
--#*            updates the output of the unit based on the time it has been alive.          
--#*
--#*****************************************************************************

--# Need this so we can call base class code
--# and bypass any intervening superclass
local Unit = import('/lua/sim/unit.lua').Unit


--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeTimeBasedOutputUnit(baseClassArg)

local resultClass = Class(baseClassArg) {

    --# This constant gives us a quick way to 
    --# check if a unit extends this class.
    IsTimeBasedOutputUnit = true,

    --# These two variables are constants.
    ProductionResourceTypes = {'Mass','Energy'},    
    ProductionUpdateSeconds = 10,  
    
    --# These two keys are used when upgrading.
    --# Do we pass on time-based bonus to upgraded unit?
    PassOnProductionPercentageIncreaseToUpgrade = false,
    --# If the upgraded unit has a higher base level of production,
    --# then we will get a massive jump in production when we upgrade.
    JumpFactorLimit = 2,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# Perform original class version first
        baseClassArg.OnCreate(self)
        
        --# This table is updated repeatedly by a thread.
        --# The table must be asigned inside a function,
        --# or the table variable will be treated as a static variable 
        --# and will be shared by other units that use this class.
        self.ProductionPercentageIncrease = {
            Mass = 1.0, 
            Energy = 1.0,
            Aggregate = 1.0,
        }
        
        --# Record this now to save querying it later more than once
        self.UpgradeBPName = self:GetBlueprint().General.UpgradesTo or false
        --# This next line was needed as self.UpgradeBPName was becoming ""
        if self.UpgradeBPName == "" then self.UpgradeBPName = false end
        self.BuildableCategoryName = self:GetBlueprint().Economy.BuildableCategory[1]
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Override this with  code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        --# Do base class versions first
        baseClassArg.DoBeforeAnyStateChanges(self)
    
        --# Initialise variables
        self:InitTimeBasedResourceOutputUnit()
        
        --# Launch thread that updates/increases energy output
        self.ResourceProductionThreadHandle = 
              self:ForkThread(self.ResourceProductionUpdateThread, self)
    end, 
  
  
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Override this with  code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    InitTimeBasedResourceOutputUnit = function(self)
        --# We'll be reading in values from the unit's blueprint.
        local econbp = self:GetBlueprint().Economy
        --# This is used by upgrading mexes so that they 
        --# use less energy and mass to upgrade if they have a good time bonus
        self.UpgradeDiscountFactor = {
            Mass=1,
            Energy=1,
        }
        
        --# We'll add to this table an entry 
        --# for Energy, Mass or both, depending 
        --# on what this unit produces.
        self.BaseProduction = {}
        --# Look for energy production and add to table if it's there
        if econbp.ProductionPerSecondEnergy then 
            self.BaseProduction.Energy = econbp.ProductionPerSecondEnergy 
        end
        --# Look for Mass production and add to table if it's there
        if econbp.ProductionPerSecondMass then
            self.BaseProduction.Mass = econbp.ProductionPerSecondMass 
        end
        
        --# We'll add to this table an entry 
        --# for Energy, Mass or both, depending 
        --# on what this unit produces.
        self.GrowthConstant = {}
        --# Look for energy production and add to table if it's there
        if econbp.EnergyProductionGrowthConstant then 
            self.GrowthConstant.Energy = econbp.EnergyProductionGrowthConstant 
        end
        --# Look for Mass production and add to table if it's there
        if econbp.MassProductionGrowthConstant then 
            self.GrowthConstant.Mass = econbp.MassProductionGrowthConstant 
        end
        
        --# We'll add to this table an entry 
        --# for Energy, Mass or both, depending 
        --# on what this unit produces.
        self.ProductionCap = {}
        --# Look for energy production and add to table if it's there
        if econbp.MaxProductionPerSecondEnergy then 
            self.ProductionCap.Energy = econbp.MaxProductionPerSecondEnergy 
        end
        --# Look for Mass production and add to table if it's there
        if econbp.MaxProductionPerSecondMass then 
            self.ProductionCap.Mass = econbp.MaxProductionPerSecondMass 
        end

        --# Note: Upgrade code is only based on mass production in this version.
        --# If we made something upgradeable that generated energy we'd have to change this code.
        if self.IsUpgradeablePauseableProductionUnit and self.UpgradeBPName then
            --# Temporarily block manual upgrade if the blueprint specifies that.
            self.AllowManualUpgradeAt = econbp.AllowManualUpgradeAt or false
            if (not self.AllowManualUpgradeAt) 
                or self.BaseProduction.Mass < self.AllowManualUpgradeAt 
            then
                self.UpgradeBlocked = true
                if self.AllowManualUpgradeAt then 
                    self.UpgradeBlockedMessage =  
                    "Blocked until >=" .. self.AllowManualUpgradeAt 
                    self.AllowManualUpgradeAtIncrease = 
                        self.AllowManualUpgradeAt / self.BaseProduction.Mass
                else
                    self:AddBuildRestriction(categories[self.BuildableCategoryName])
                end
            end
            
            --# Set AutoUpgrade level if BP specifies it
            self.AutoUpgradeAt = econbp.AutoUpgradeAt or false
            if self.AutoUpgradeAt then 
                self.AutoUpgradeAtIncrease = self.AutoUpgradeAt / self.BaseProduction.Mass
            end
        end
        
    end,
    
  
  
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This function gives us exponential time-based production increases
    --#*  on our Hydrocarbon Power Plants (HCPPs).  It is simpler than the 
    --#*  corresponding thread for Mass Extractors, because HCPPs have no upgrades.
    --#**
    ResourceProductionUpdateThread = function(self)
          
        --# This loop is where we update the production value based on
        --# the number of iterations (which is proportional to the amount of 
        --# time passed since this unit's creation).
        self.ProductionLimitReached = false
        while not self.ProductionLimitReached and not self:IsDead() do
        
            --# This is how often the thread updates/increases MeX production
            WaitSeconds(self.ProductionUpdateSeconds)
            
            --# Don't update if upgrading!!
            if not self:IsUnitState('Upgrading') then 
                --# Update unit production values.
                self:UpdateProductionValues()
            end  
            
            --# Update increases for next potential round.
            for unusedArrayIndex, typeName in self.ProductionResourceTypes do
                if self.BaseProduction[typeName] then
                    --# Increase next time-based production bonus.  
                    --# Current system is exponential, i.e. x1.02^t
                    --# similar to compound interest.
                    self.ProductionPercentageIncrease[typeName]  = 
                      self.ProductionPercentageIncrease[typeName] * self.GrowthConstant[typeName]     
                end
            end
            
            --# Work out aggregate of these increases
            self:CalculateAggregateProductionPercentageIncrease()

            --# The rest of this deals with permitting or forcing upgrades
            --# which is so far only used by the 9 MeX units
            if not self:IsUnitState('Upgrading') then 
            
                --# Deal with AllowManualUpgradeAt blueprint key if there was one set
                if self.UpgradeBlocked and self.AllowManualUpgradeAtIncrease and 
                  self.ProductionPercentageIncrease['Aggregate'] >= self.AllowManualUpgradeAtIncrease 
                then
                    self.UpgradeBlocked = false
                    if self.RestrictionNeedsLifting then
                        self:RemoveBuildRestriction(categories[self.BuildableCategoryName])
                    end
                end
            
                --# Deal with AutoUpgrade blueprint key if there was one set  
                if self.AutoUpgradeAtIncrease and 
                  self.ProductionPercentageIncrease['Aggregate'] >= self.AutoUpgradeAtIncrease 
                then
                    --# This is a free upgrade
                    self.UpgradeDiscountFactor = {
                        Mass=0,
                        Energy=0,
                    }
                    --# Try to upgrade
                    if self.UpgradeBPName then
                        IssueUpgrade( {self}, self.UpgradeBPName )
                    else
                        WARN("TimeBasedResourceOutputUnit: " ..
                            "ResourceProductionUpdateThread: " .. 
                            "Tried to upgrade but UpgradesTo not defined in BP!")
                    end
                    return
                end
            end
        end
        
    end,
    
    
    
    
    --#* 
    --#*  Work out aggregate of these increases.
    --#*  Default version takes the maximum.
    --#*  This works when only one production type exists.
    --#**
    CalculateAggregateProductionPercentageIncrease = function(self)
        self.ProductionPercentageIncrease['Aggregate'] = math.max(
            self.ProductionPercentageIncrease['Mass'] or 0,
            self.ProductionPercentageIncrease['Energy'] or 0
        )
    end,
            
            
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This code is a destructive override for UpdateProductionValues in /lua/sim/Unit.lua .
    --#*  This deals with problem that time-based production increases were
    --#*  being lost when an energy storage was being built adjacent to the HCPP.
    --#*  The class that extends this must override UpdateProductionValues to point to this.
    --#*
    --#*  If this unit is an AutoPack unit that uses a sensitive shield 
    --#*  then it sets the maximum power of its shield relative to production value.
    --#**
    UpdateProductionValues = function(self)
       
        --# keep this to check if we need to update DLS or sensitive shields
        local productionChanged = false

        for unusedArrayIndex, typeName in self.ProductionResourceTypes do
            if self.BaseProduction[typeName] then
       
                --# Query what the production level of this 
                --# resource type was just before the update
                local oldProduction = self['GetProductionPerSecond' .. typeName](self)
       
                --# Calculate what the production level of this 
                --# resource type should be after this update 
                local newProduction = 
                    math.floor(self.ProductionPercentageIncrease[typeName] * 
                               self.BaseProduction[typeName]
                    )
                
                --# Deal with MaxProductionPerSecondEnergy/Mass blueprint key if there was one set    
                if self.ProductionCap[typeName] and newProduction >= self.ProductionCap[typeName] then
                    self.ProductionLimitReached = true
                    newProduction = self.ProductionCap[typeName]
                    --# Don't allow ProductionPercentageIncrease to overrun its limit either
                    self.ProductionPercentageIncrease[typeName] = 
                        newProduction/self.BaseProduction[typeName]
                end
                
                --# Apply adjacency bonuses on production after capping
                --# so that building energy storage does have a benefit even
                --# after we are not increasing production by time anymore. 
                newProduction = newProduction * (self[typeName .. 'ProdAdjMod'] or 1)
                
                --# Is the production level changed?
                if self.CalledFromBuildFail or oldProduction ~= newProduction then
                    --# Do the update on ecomony 
                    self['SetProductionPerSecond' .. typeName](self, newProduction)
                    --# record that there was a change
                    productionChanged = true
                end
            end
        end
        
        --# If either resource type was changed ..
        if productionChanged then
        
            --# Don't update the effects if we are cloaked!!
            if self.UpdateActiveEffects then 
                --# ActiveEffectIncreaseMultiplier is square root of the ratio 
                --# increase of production rate but
                --# rounded to 1 dp with this bit of maths
                --# The 4th (quartic) root function 
                --# (i.e. math.pow(self.ProductionPercentageIncrease,0.5) 
                --# means that exponential growth
                --# of output will have effect increase that is still 
                --# exponential but with effectively 50% of the growth rate.                
                self.ActiveEffectIncreaseMultiplier = (math.floor(10 * 
                    math.pow(self.ProductionPercentageIncrease['Aggregate'],0.5))) /10
                self:UpdateActiveEffects()
            end
            
            --# Update animation speed
            if self.UpdateActiveAnimation then 
                self:UpdateActiveAnimation()
            end
            
            --# Do code for sensitive shield users (Aeon)
            if self.IsSensitiveShieldUser then
                --# Update shield strength
                local bpShield = self:GetBlueprint().Defense.SensitiveShield
                --# This safety appeared to be necessary.
                if self.MyShield then 
                    --# Buff the shield's max health, health, and regen rate
                    self.MyShield:SetMaxHealthAndRegenRate(
                        bpShield.ShieldMaxHealth * self.ProductionPercentageIncrease['Aggregate']
                    )
                else
                    --# Warn programmer if unit misses an update
                    --# other than when this function is called when the unit is just built
                    WARN(' TimeBasedOutputUnit.lua: '
                      .. ' In function UpdateProductionValues: ' 
                      .. ' self.MyShield not defined on SensitiveShieldUser .'
                      .. ' This unit will miss one update to its shield strength.'
                      .. ' u=' .. self:GetUnitId()
                      .. ' e=' .. self:GetEntityId()
                      .. ' when increase was ' 
                      .. repr(self.ProductionPercentageIncrease['Aggregate'])
                    )
                end
            
            --# Do code for damage limitiation system (DLS) users (UEF)
            elseif self.IsDamageLimitationSystemUser then
                --# Work out what effect DLS will have based on 
                --# ProductionPercentageIncreasedue to age of HCPP.
                --# This version has a minimum reduction of halving damage
                --# (when HCP is new) up to reducing the damage by 
                --# double the maximum energy production increase factor 
                --# (effectively reducing damage by 1000 times at full output).
                --# This gives more protection than the Aeon's shield, but shields
                --# regen automatically.  This HCPP needs to be repaired.
                self.DLSDamageReductionFactor = 
                    self.InitialDLSDamageReductionFactor / 
                        math.pow(self.ProductionPercentageIncrease['Aggregate'], 0.5)
            end
            
            --# This is used by upgrading mexes so that they 
            --# use less energy and mass to upgrade if they have a good time bonus
            --# Deal with AutoUpgrade blueprint key if there was one set  
            if self.AutoUpgradeAtIncrease then
                --#  1 means no discount. 0 means 100% discount (free upgrade)
                self.UpgradeDiscountFactor.Mass = 
                    1-((self.ProductionPercentageIncrease['Aggregate'] -1)/ 
                                (self.AutoUpgradeAtIncrease-1))
                                --# safety check to avoid negative value
                if self.UpgradeDiscountFactor.Mass < 0 then self.UpgradeDiscountFactor.Mass = 0 end             
                --# Have same discount for mass and energy
                self.UpgradeDiscountFactor.Energy = self.UpgradeDiscountFactor.Mass
            end
        end
    end,
    
    
    
    --#*    
    --#*  Gilbot-X says:    
    --#*
    --#*  This is called from my overrided version of OnStartBuild in 
    --#*  pauseableproductionunit.lua.
    --#* 
    --#*  Note: This code cannot be put into UpgradingState because, in a GPG base
    --#*  class, OnStartBuild actually tells the unit to go into UpgradingState.
    --#**
    DecideIfCanPassOnProductionPercentageIncreaseToUpgrade = function(self, unitBeingBuilt)
    
        --# Get the actual BP values given BP name
        local myEconBP = self:GetBlueprint().Economy
        local upgradeEconBP = unitBeingBuilt:GetBlueprint().Economy
        
        --# Pass on bonus only if toggles that forbid this were not set 
        --# in either this unit or the one we are upgrading to
        if myEconBP.PassOnTimeBonus 
          and upgradeEconBP.InheritTimeBonus 
        then 
            --# Don't pass on the time bonus if there is 
            --# a large jump in base production!
            local jumpfactor = (upgradeEconBP.ProductionPerSecondMass /
                                      myEconBP.ProductionPerSecondMass)
            --# The JumpFactorLimit value will only let production increase 
            --# by up to a certain factor on an upgrade or bonus will not be passed on!
            if jumpfactor <= self.JumpFactorLimit then
                self.PassOnProductionPercentageIncreaseToUpgrade = true
              LOG('TimeBasedOutputUnit: OnStartBuild: ' 
                  .. 'jumpfactor=' .. repr(jumpfactor) 
                  .. " so passing on ProductionPercentageIncrease.")
            else
                self.PassOnProductionPercentageIncreaseToUpgrade = false
              LOG('TimeBasedOutputUnit: OnStartBuild: ' 
                  .. 'jumpfactor=' .. repr(jumpfactor) 
                  .. " so not passing on ProductionPercentageIncrease.")
            end
        else
            self.PassOnProductionPercentageIncreaseToUpgrade = false
              --LOG("TimeBasedOutputUnit: OnStartBuild: " ..
              --   "not passing on ProductionPercentageIncrease because of BP toggles.")
        end
    end,
                
                
    
    --#*
    --#*  Gilbot-X says:
    --#*        
    --#*  Normally this state gets initiated from OnStartBuild
    --#*  when a Mex unit is given an upgrade command.
    --#**  
    UpgradingState = State {
    
        --# Defer this to base class code
        Main = baseClassArg.UpgradingState.Main,

        --#*
        --#*  Gilbot-X says:
        --#*        
        --#*  Normally this function gets called 
        --#*  after the unit being built calls OnStopBeingBuilt.
        --#*
        --#*  My extra code does two things:
        --#*  1/ It optionally passes on time-based increase to the 
        --#*  upgraded unit (a mod setting toggles whether this happens)
        --#*  2/ It kills the thread that updates the time-based increase
        --#*  on the unit that just finished the upgrade.
        --#**
        OnStopBuild = function(self, unitBeingBuilt)
            baseClassArg.UpgradingState.OnStopBuild(self, unitBeingBuilt)
                
            --# When upgrading, pass on the percentage increase bonus
            if self.PassOnProductionPercentageIncreaseToUpgrade then
                unitBeingBuilt.ProductionPercentageIncrease = self.ProductionPercentageIncrease
                WARN("TimeBasedOutputUnit: ProductionPercentageIncrease is being set to :" ..
                    self.ProductionPercentageIncrease .. " in upgraded unit.")
            end
            
            --# This unit will cease to exist when upgrade is done so...
            if self.ResourceProductionThreadHandle then
                --# Would this have been done by garbage collection 
                --# automatically when this unit was destroyed?
                KillThread(self.ResourceProductionThreadHandle)
                self.ResourceProductionThreadHandle = nil
            end
        end,
        
        --# Had to override this as stopping upgrade
        --# would lose all the timebased production bonus.
        OnFailedToBuild = function(self)
            ForkThread(
                function(self) 
                    --# Wait for the production to be set
                    --# to BP values by GPG code
                    WaitTicks(1)
                    --# Set this flag to force immediate update
                    self.CalledFromBuildFail = true
                    self:UpdateProductionValues()
                    --# Reset this flag
                    self.CalledFromBuildFail = false
                end, self
            )
            
            --# Defer rest to base class.
            baseClassArg.UpgradingState.OnFailedToBuild(self)
            
        end,
    },
    
    
}


return resultClass

end
