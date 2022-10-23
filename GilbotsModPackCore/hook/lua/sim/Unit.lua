do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/sim/unit.lua
--#**
--#**  Summary  :  The Unit lua module
--#**
--#**  Modded By:  Gilbot-X, with some code from CovertJaguar
--#**
--#**  Changes  : 
--#**    Maintenance Consumption Breakdown code added.
--#**    Adjacency code added.
--#**    Cloak Effect code added (adapted from code by CovertJaguar)
--#**
--#**  Notes    :  
--#**    The original version of unit.lua (in patch 3269) has 3608 lines.
--#**    To find line that caused error, subtract line number given by 
--#**    log file by 3649 to get the line number you need to look at 
--#**    in this file.
--#**
--#****************************************************************************
local GilbotUtils = import('/mods/GilbotsModPackCore/lua/utils.lua')
--# This next switch can turn on/off features
--# provided by the Experimental Wars mod.
local CanUseEWMeshes = false

local PreviousVersion = Unit
Unit = Class(PreviousVersion) {

    --# There is also Sim function
    --# called IsUnit() but it has 
    --# global scope and takes an 
    --# entity as an argument. This 
    --# is a shortcut. So far I only 
    --# use it in ChargingUnit.lua
    IsUnit = true,

    --# These flags determine what 
    --# type of logging goes to output
    DebugCloakEffectCode = false,
    DebugResourceDrainBreakDownCode = false,
    DebugSliderCode = false,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  For debugging only.
    --#** 
    CloakEffectLog = function(self, messageArg)
        if self.DebugCloakEffectCode then 
            if type(messageArg) == 'string' then
                LOG('CloakEffect: a=' .. self.ArmyIdString .. ' ' .. messageArg)
            end
        end
    end,
    ResourceDrainBreakDownLog = function(self, messageArg)
        if self.DebugResourceDrainBreakDownCode then 
            if type(messageArg) == 'string' then
                LOG('ResourceDrainBreakDown: a=' .. self.ArmyIdString 
                .. ': ' .. self.DebugId .. ': ' .. messageArg)
            end
        end
    end,
    SliderLog = function(self, messageArg)
        if self.DebugSliderCode then 
            if type(messageArg) == 'string' then
                LOG('Slider: a=' .. self.ArmyIdString .. ' ' .. messageArg)
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This just saves repeating 
    --#*  a standard safety check
    --#*  and makes code more readable
    --#**
    IsAlive = function(self)
        if (not self) 
          or self:BeenDestroyed() 
          or self:IsDead() 
          or self:GetHealth() <= 0 
        then return false
        else return true
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This just saves repeating 
    --#*  a standard safety check
    --#*  and makes code more readable
    --#**
    IsStillInSameArmyAs = function(self, otherUnit)
        if self:IsAlive() and otherUnit:IsAlive() and 
            otherUnit:GetArmy() == self:GetArmy()
        then return true
        else return false
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# This sets up lots of variables used 
        --# for debugging and saving time that only change when
        --# the unit is created or captured.        
        self:InitializeCachedInstanceVariables()
        
        --# Mark units that can use cloak effect
        if self:GetBlueprint().Intel.Cloak then
            self.IsCloakUnit = true         
        end
        
        --# This is for safety checking.
        self.NumberOfTimesCloakEffectHasBeenEnabledWithoutBeingDisabled = 0
    
        --# Initialisation for enhancenment queue code
        if self:GetBlueprint().Enhancements then
             --# Make sure this table is defined
            self.EnhancementQueue = {}
            --# Make sure this table is defined
            self.EnhancementsActive = {
                LCH = nil,
                Back = nil,
                RCH = nil,            
            }
        end

        --# This is ndeeded for AT code.
        self.AutoToggleEntries = {}
                
        --# Perform original class version first
        PreviousVersion.OnCreate(self)
        --# Next: Make sure we refresh those variables if captured.
        --# The intention is that the new unit runs this function.
        --# **Causes error - GetUnitId() not defined, so timing wrong?
        --self:AddOnCapturedCallback(nil, self.InitializeCachedInstanceVariables)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Do variable initialization when unit
    --#*  is created or captured.
    --#** 
    InitializeCachedInstanceVariables = function(self)
        --# This is useful for general debugging
        --# and saves on code everywhere
        self.DebugId = self:GetUnitId() .. ' e=' .. self:GetEntityId()
        --# Same goes for these
        self.MyArmyId = self:GetArmy()
        self.ArmyIdString = repr(self.MyArmyId)
        --# This is useful too for same reason
        if not self.IsACU then self:GetMyCommander() end
         --# This next block is for network display system.
        self.BaseLabel = nil
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided SetCustomName so I could 
    --#*  call GetCustomName from the user side.
    --#** 
    SetCustomName = function(self, stringArg)
        --# Reduce errors in log file by doing this check
        if not self:IsAlive() then return end
        if self:IsBeingBuilt() then return end

        --# The empty string is always converted to nil
        --# False is also converted to nil.  There must be
        --# only one value that means 'no custom name', 
        --# otherwise this code will break because of the next 
        --# comparison which uses the ~= operator.
        if (not stringArg) or stringArg == "" then stringArg = nil end
        --# Try to keep the unit's original name
        --# as long as we can.
        --# Don't update if new value is the same as old        
        if stringArg ~= self.CurrentCustomName then
            --# Don't actually change display name
            --# yet if a message is being flashed.
            --# The message thread will do that for us
            --# when it is finished if we just store the label now.
            if not self.FlashMessageLabel then
                --# Original class version is a moho method
                local stringArgToPass = (stringArg or "")
                if type(stringArgToPass) ~= "string" then 
                    WARN('Unit.lua: SetCustomName: argument is not a string')
                    return
                end
                PreviousVersion.SetCustomName(self, stringArgToPass)
            end
            --# Store value so we can query from sim side
            --# The empty string is always converted to nil
            --# so this can never be ""
            self.CurrentCustomName = stringArg
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I created a version of this to query from sim side.
    --#*  This function already exists on Class UserUnit.
    --#** 
    GetCustomName = function(self)
        --# We kept this variabe so we can query from sim side
        return self.CurrentCustomName 
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    ClearCustomName = function(self)
        self:SetCustomName(self.BaseLabel)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This is called to flash a message on a unit that 
    --#*  a player can see.
    --#* 
    --#*  Calling this temporarily delays other threads 
    --#*  from changing the custom name text that you see.
    --#** 
    FlashMessage = function(self, stringArg, secondsArg)

        --# Do this for safety
        if not (type(stringArg)=="string") then return end
        if not (type(secondsArg)=="number") then secondsArg=2 end
        
        --# Show our label for a couple seconds
        ForkThread(
            function(self, stringArg, secondsArg)
                
                --# Wait for any FlashMessage thread 
                --# ahead of it to finish.
                while(self.FlashMessageLabel) do
                    WaitSeconds(secondsArg)
                end
                
                --# Setting this stops other threads from 
                --# changing the label until we are done.
                self.FlashMessageLabel = stringArg
                
                --# Original class version is a moho method
                --# We call that to chnage the display label on the unit
                PreviousVersion.SetCustomName(self, self.FlashMessageLabel)
            
                --# Leave it showing according to what 
                --# calling code specified
                WaitSeconds(secondsArg)
                
                --# Now try to restore whatever the label should be now.
                --# Unit may have been destroyed in the meantime
                if self:IsAlive() then 
                    --# Original class version is a moho method
                    PreviousVersion.SetCustomName(self, (self:GetCustomName() or ""))
                    --# Setting this to nil allows
                    --# other threads to change the display name again.
                    self.FlashMessageLabel = nil
                end
            end, self, stringArg, secondsArg
        )
    end,
    
    

    
--[[

Message from Gilbot-X:

To use this mod and use the blueprint keys, your unit's script file must declare the EnabledResourceDrains table as shown below.   

    OnStopBeingBuilt = function(self, builder, layer)
        
        self.EnabledResourceDrains = {
            Cloak  = false,
            Intel  = false,
            Jammer = false,
            Shield = false,
            Stealth= false,
            ProductionCosts = false,
            WeaponFiringCost = false,
        },
        
        --# Note that BaseClass version of  
        --# OnStopBeingBuilt MUST ONLY BE CALLED AFTER
        --# we define the EnabledResourceDrains table.
        BaseClass.OnStopBeingBuilt(self, builder, layer)
        
    end,
    
    
.. or better/safer still, do it sooner in OnCreate to avoid the risk if making a mistake!!!
    
    
    OnCreate = function(self)
        BaseClass.OnCreate(self)
        
        self.EnabledResourceDrains = {
            Cloak  = false,
            Intel  = false,
            Jammer = false,
            Shield = false,
            Stealth= false,
            ProductionCosts = false,
            WeaponFiringCost = false,
        },
    end,
    
    
If you declare this table in an override of OnStopBeingBuilt, You have to declare this table before calling the base class version.  Note: You could alternatively declare the table in an override of OnCreate because OnCreate is called before OnStopBeingBuilt.
    
The keys in the table above show examples of what you can use.  Your unit mod must override the value of this in its script file from within OnCreate or OnStopBeingBuilt.  Do not just declare it outside of a function. Why not?  Because sometimes class member variables are treated as static member variables, especially likely if the value has been set outside a function, even more likely if the value is a table and the table was not set inside a member function of that class. 
  
If you override OnStopBeingBuilt you must call the base class version, otherwise the effects of this mod are lost and your ResourceDrainBreakDown blueprint keys will be ignored.

  ]]
  
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I override this to set up the maintenance consumption 
    --#*  breakdown code.  It also launches the thread that manages
    --#*  cloak effects.
    --#** 
    OnStopBeingBuilt = function(self, builder, layer)
        --# Call superclass version first
        PreviousVersion.OnStopBeingBuilt(self, builder, layer)
     
        --# Set up the maintenance consumption breakdown code.
        self:InitResourceDrainBreakDown()
    end,
    
    
    
    --# This will remain false for units that 
    --# were not designed for use with this mod. 
    --# They will function as normal
    --# without any changes to their BP files.
    ResourceDrainBreakDown = false,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to set up the maintenance consumption 
    --#*  breakdown code.  It is called from OnStopBeingBuilt.
    --#** 
    InitResourceDrainBreakDown = function(self)
        --# get energy consumption values from blueprint
        local tempTable = self:GetBlueprint().Economy.ResourceDrainBreakDown or false
        --# do this because ResourceDrainBreakDown was synching with BP!
        if tempTable then 
            self.ResourceDrainBreakDown = table.deepcopy(tempTable)
        end
        
        --# If the fetch and table copy succeeded then...
        if self.ResourceDrainBreakDown then
            --# This next block is just a safeguard so we don't have to keep checking
            --# if the keys were set correctly in the blueprint file...
            for k,v in self.EnabledResourceDrains do 
                if not self.ResourceDrainBreakDown[k] then 
                    self.ResourceDrainBreakDown[k] = { Energy = 0, Mass = 0 }
                    v = false
                else
                    if not self.ResourceDrainBreakDown[k].Energy then
                        self.ResourceDrainBreakDown[k].Energy = 0
                    end
                    if not self.ResourceDrainBreakDown[k].Mass then
                        self.ResourceDrainBreakDown[k].Mass = 0
                    end
                end
            end
  
            --# We have a valid ResourceDrainBreakDown table,
            --# so let's use it as the unit is ready to start.
            self:UpdateConsumptionValues()
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I added this as the missing complement to 
    --#*  SetEnergyMaintenanceConsumptionOverride which
    --#*  is defined in the origional Unit.lua file.
    --#**
    SetMassMaintenanceConsumptionOverride = function(self, override)
        self.MassMaintenanceConsumptionOverride = override or 0
    end,
    
    
--[[

Message from Gilbot-X:
 
WARNING!!!  This is a destructive hook of the UpdateConsumptionValues function - I do not call original code, I override it!  For that reason it may need to be updated if any patch released by GPG changes the code used in this member function.
  
]]
    --# GPG: work out a total for the energy rate and override the single value in the blueprint
    --# Here we calculate it dynamically for what the toggle/enabled functions should consume
    --# Then call the superclass verision (defined in class Unit)
    UpdateConsumptionValues = function(self)
    
        --###########################
        --# START OF GILBOT-X CODE
        --# We have to treat GPG blueprints as
        --# they were treated in the original unit.lua
        --# so skip all my code if the blueprint file 
        --# isn't set up to use my extra features
        if self.ResourceDrainBreakDown then

            --# Calculate rates
            local energy_rate = 0
            local mass_rate = 0
        
            for k,v in self.ResourceDrainBreakDown do
                if self.EnabledResourceDrains[k] then
                    energy_rate = energy_rate + self.ResourceDrainBreakDown[k].Energy 
                    mass_rate =     mass_rate + self.ResourceDrainBreakDown[k].Mass 
                end
            end
            
            --# set amount of energy drain
            self.EnergyMaintenanceConsumptionOverride = energy_rate
            self.MassMaintenanceConsumptionOverride = mass_rate
            
            --# call code from GPG version that works out bonus etc
            self.MaintenanceConsumption = not (energy_rate == 0 and mass_rate == 0)
        end
        --#  END OF GILBOT-X CODE
        --###########################
        
        --################################################
        --# START OF GPG CODE
        --# The rest is GPG code from unit.lua
        --# but I change a couple lines so that 
        --# MassMaintenanceConsumptionOverride works.
        local myBlueprint = self:GetBlueprint()
        local energy_rate = 0
        local mass_rate = 0
 
        if self.ActiveConsumption then
            local focus = self:GetFocusUnit()
            local time = 1
            local mass = 0
            local energy = 0
            if self.WorkItem then
                time, energy, mass = Game.GetConstructEconomyModel(self, self.WorkItem)
            elseif focus and focus:IsUnitState('SiloBuildingAmmo') then
                --# If building silo ammo; create the energy and mass 
                --# costs based on build rate of the silo
                --# against the build rate of the assisting unit
                time, energy, mass = focus:GetBuildCosts(focus.SiloProjectile)
                local siloBuildRate = focus:GetBuildRate() or 1
                energy = (energy / siloBuildRate) * (self:GetBuildRate() or 1)
                mass = (mass / siloBuildRate) * (self:GetBuildRate() or 1)
            elseif focus then
                --# bonuses are already factored in by GetBuildCosts
                time, energy, mass = self:GetBuildCosts(focus:GetBlueprint())
                --# Gilbot-X:  I added this next block:
                if self:IsUnitState('Upgrading') then
                    --# UpgradeDiscountFactor only really applies to upgrading T1/T2 Mexes
                    --# see timebasedoutputunit.lua for linking code
                    if self.UpgradeDiscountFactor then 
                        --# these values are both checked below anyway to 
                        --# make sure they are at least 1, so no need to do it here
                        energy = energy * self.UpgradeDiscountFactor.Energy
                        mass = mass * self.UpgradeDiscountFactor.Mass
    
                    --# UpgradeDiscountFactor only really applies 
                    --# to upgrading T1 Mech Marine in that mod option.
                    --# see its script.lua for linking code.
                    elseif self.UpgradeDiscountAmounts then
                        --# these values are both checked below anyway to 
                        --# make sure they are at least 1, so no need to do it here
                        if self.UpgradeDiscountAmounts.Energy < 0 then 
                            WARN('Negative energy discount found.')
                        end
                        if self.UpgradeDiscountAmounts.Mass < 0 then 
                            WARN('Negative mass discount found.')
                        end
                        energy = energy - self.UpgradeDiscountAmounts.Energy
                        mass = mass - self.UpgradeDiscountAmounts.Mass
                    end
                end
            end
            energy = energy * (self.EnergyBuildAdjMod or 1)
            if energy < 1 then
                energy = 1
            end
            mass = mass * (self.MassBuildAdjMod or 1)
            if mass < 1 then
                mass = 1
            end
   
            energy_rate = energy / time
            mass_rate = mass / time
            
            --###########################
            --#  START OF GILBOT-X MOD
            --# Added for Auto Toggle
            if self.IsAutoToggleUnit and self.AutoToggleEntries['Construction'] then
                self.AutoToggleEntries['Construction'].Consumption.Energy = energy_rate
                self.AutoToggleEntries['Construction'].Consumption.Mass = mass_rate
            end
            --#  END OF GILBOT-X MOD
            --###########################
        end

        
        if self.MaintenanceConsumption then
            local mai_energy = (self.EnergyMaintenanceConsumptionOverride or
                      myBlueprint.Economy.MaintenanceConsumptionPerSecondEnergy)  or 0
            --###########################
            --#  START OF GILBOT-X MOD
            local mai_mass = (self.MassMaintenanceConsumptionOverride or              
                      myBlueprint.Economy.MaintenanceConsumptionPerSecondMass) or 0
            --#  END OF GILBOT-X MOD
            --###########################
            
            --# apply bonuses
            mai_energy = mai_energy * (100 + self.EnergyModifier) * (self.EnergyMaintAdjMod or 1) * 0.01
            mai_mass = mai_mass * (100 + self.MassModifier) * (self.MassMaintAdjMod or 1) * 0.01

            energy_rate = energy_rate + mai_energy
            mass_rate = mass_rate + mai_mass
        end

        --# apply minimum rates
        energy_rate = math.max(energy_rate, myBlueprint.Economy.MinConsumptionPerSecondEnergy or 0)
        mass_rate = math.max(mass_rate, myBlueprint.Economy.MinConsumptionPerSecondMass or 0)

        self:SetConsumptionPerSecondEnergy(energy_rate)
        self:SetConsumptionPerSecondMass(mass_rate)

        if (energy_rate > 0) or (mass_rate > 0) then
            self:SetConsumptionActive(true)
        else
            self:SetConsumptionActive(false)
        end
        
        --#
        --# END OF GPG CODE
        --################################################
    end,
    
    
    
    
   

    
    
    --##########################################################################################
    --## TOGGLES
    --##########################################################################################
    
--[[

Message from Gilbot-X:

WARNING!!!  These are a destructive hook of the OnScriptBitSet and OnScriptBitClear functions - I do not call original code, I override it!  For that reason it may need to be updated if any patch released by GPG changes the code used in this member function.  Seems to work fine up to patch 3260 though...
  
In these overrides, we first check if the unit whose toggles have been pressed is actually designed to use the extr afeatures of this Maintenance Consumption Breakdown mod.  If it is, instead of calling SetMaintenanceConsumptionActive and SetMaintenanceConsumptionInActive we set the value of keys inside EnabledResourceDrains and make calls to UpdateConsumptionValues.  This is safe for all units, if they were designed for this mod or not.

For units that use the mod, we assume they might have more than one kind of intel and we call OnIntelEnbaled and OnIntelDisabled explicitly when toggle bits 2,3,5,8 are used (these are all classed as intel by GPG).  This was needed to make TransparentCloaks mod compatible with this mod for example.

Now changed so that cloak fields work.  If you enable the Cloak Intel, the CloakField intel won't work.  So now we don't enable cloak if the unit has CloakField define in the blueprint.  If the unit gains CloakField as an enhancement, they can set 'self.HasCloakField = true' or they will have to override this as CloakField won't be defined in the blueprint.

 ]]
    --#*
    --#*  This function does what is needed when 
    --#*  the player toggles shields on or anything else off.  
    --#**     
    OnScriptBitSet = function(self, bit)
    
        if bit == 0 then --# shield toggle
            if self.IsSensitiveShieldUser then
                self.MyShieldToggledOn = true
                --# Try to enable our personal shield if allowed
                if self.ShieldUsePermitted and self.IsPacked then 
                    --# This calls the overrided version
                    --# in the SensitiveShield class
                    self:EnableShield() 
                end
            --# This unit has a normal shield
            else
                --# So we should just turn it on.
                self:PlayUnitAmbientSound('ActiveLoop')
                self:EnableShield()
                if self.ResourceDrainBreakDown then 
                    self.EnabledResourceDrains.Shield = true
                    self:UpdateConsumptionValues()
                end
            end
            
        elseif bit == 1 then --# weapon toggle
            --# Perform this function if it is defined.
            if self.OnScriptBit1Set then 
                self:OnScriptBit1Set() 
            end
            
        elseif bit == 2 then --# jamming toggle
            self:ResourceDrainBreakDownLog("Turning off jammer with bit 2")
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:DisableUnitIntel('Jammer')
            if self.ResourceDrainBreakDown then 
                self:ResourceDrainBreakDownLog("Removing jammer cost only")
                self.EnabledResourceDrains.Jammer = false
                self:UpdateConsumptionValues()
                --# OnIntelDisabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelDisabled()
            else
                self:SetMaintenanceConsumptionInactive()
            end
            
        elseif bit == 3 then --# intel toggle
            self:ResourceDrainBreakDownLog("Turning off intel with bit 3")
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:DisableUnitIntel('Sonar')
            self:DisableUnitIntel('Omni')
            self:DisableUnitIntel('Spoof')
            self:DisableUnitIntel('Radar')
            if self.ResourceDrainBreakDown then 
                self:ResourceDrainBreakDownLog("Removing intel cost only")
                self.EnabledResourceDrains.Intel = false
                self:UpdateConsumptionValues()
                --# OnIntelDisabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelDisabled()
            else
                --# GPG units that weren't designed for this mod
                --# are used to having these enabled when bit 3 is used! 
                self:DisableUnitIntel('Jammer')
                self:DisableUnitIntel('RadarStealth')
                self:DisableUnitIntel('RadarStealthField')
                self:DisableUnitIntel('SonarStealth')
                self:DisableUnitIntel('SonarStealthField')
                self:DisableUnitIntel('Cloak')
                self:DisableUnitIntel('CloakField')
                self:SetMaintenanceConsumptionInactive()
            end
            
        elseif bit == 4 then --# production toggle
            --# see below for my override of this
            self:OnProductionPaused()
            
        elseif bit == 5 then --# stealth toggle
            self:ResourceDrainBreakDownLog("Turning off stealth with bit 5")
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')
            if self.ResourceDrainBreakDown then 
                self:ResourceDrainBreakDownLog("Removing stealth cost only")
                self.EnabledResourceDrains.Stealth = false 
                self:UpdateConsumptionValues() 
                --# OnIntelDisabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelDisabled()
            else
                self:SetMaintenanceConsumptionInactive()
            end
            
        elseif bit == 6 then --# generic pause toggle
            self:SetPaused(true)
            
        elseif bit == 7 then --# special toggle
            self:EnableSpecialToggle()
            
        elseif bit == 8 then --# cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            if self.IsCloakFieldUnit then
                self:DisableUnitIntel('CloakField')
            else
                self:DisableUnitIntel('Cloak')
            end
            if self.ResourceDrainBreakDown then
                self.EnabledResourceDrains.Cloak = false
                self:UpdateConsumptionValues()
                --# OnIntelDisabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelDisabled()
            else
                self:SetMaintenanceConsumptionInactive()
            end
        end
    end,
    
    --#*
    --#*  This function does what is needed when 
    --#*  the player toggles shields off or anything else on.  
    --#**   
    OnScriptBitClear = function(self, bit)
    
        if bit == 0 then --# shield toggle off
            if self.IsSensitiveShieldUser then
                self.MyShieldToggledOn = false
                --# Disable our personal shield if it is enabled
                if self.MyShieldIsEnabled then 
                    --# This calls the overrided version
                    --# in the SensitiveShield class
                    self:DisableShield() 
                end
            --# This unit has a normal shield
            else
                --# so turn it off
                self:StopUnitAmbientSound('ActiveLoop')
                self:DisableShield()
                if self.ResourceDrainBreakDown then 
                    self.EnabledResourceDrains.Shield = false 
                    self:UpdateConsumptionValues() 
                end
            end
            
        elseif bit == 1 then --# weapon toggle
            --# Perform this function if it is defined.
            if self.OnScriptBit1Clear then 
                self:OnScriptBit1Clear() 
            end
            
        elseif bit == 2 then --# jamming toggle on
            self:ResourceDrainBreakDownLog("Turning on jammer with bit 2")
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:EnableUnitIntel('Jammer')
            if self.ResourceDrainBreakDown then 
                self:ResourceDrainBreakDownLog("Adding jammer cost only")
                self.EnabledResourceDrains.Jammer = true
                self:UpdateConsumptionValues()
                --# OnIntelEnabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelEnabled()
            else
                self:SetMaintenanceConsumptionActive()
            end
            
        elseif bit == 3 then --# intel toggle on
            self:ResourceDrainBreakDownLog("Turning on intel with bit 3")
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:EnableUnitIntel('Radar')
            self:EnableUnitIntel('Sonar')
            self:EnableUnitIntel('Omni')
            self:EnableUnitIntel('Spoof')
            if self.ResourceDrainBreakDown then 
                self:ResourceDrainBreakDownLog("Adding intel cost only")
                self.EnabledResourceDrains.Intel = true
                self:UpdateConsumptionValues()
                --# OnIntelEnabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelEnabled()
            else
                --# GPG units that weren't designed for this mod
                --# are used to having these enabled when bit 3 is used! 
                --self:EnableUnitIntel('Jammer')
                --self:EnableUnitIntel('RadarStealth')
                --self:EnableUnitIntel('RadarStealthField')
                --self:EnableUnitIntel('SonarStealth')
                --self:EnableUnitIntel('SonarStealthField')
                --self:EnableUnitIntel('Cloak')
                --self:EnableUnitIntel('CloakField')
                self:SetMaintenanceConsumptionActive()
            end
            
        elseif bit == 4 then --# production toggle on
            --# See below for my override of this
            self:OnProductionUnpaused()
            
        elseif bit == 5 then --# stealth toggle on
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
            if self.ResourceDrainBreakDown then 
                self.EnabledResourceDrains.Stealth = true 
                self:UpdateConsumptionValues()
                --# OnIntelEnabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelEnabled()
            else
                self:SetMaintenanceConsumptionActive()
            end
            
        elseif bit == 6 then --# generic pause toggle on
            self:SetPaused(false)
            
        elseif bit == 7 then --# special toggle off
            self:DisableSpecialToggle()
            
        elseif bit == 8 then --# cloak toggle on
            --# If the unit has this sound then play it
            self:PlayUnitAmbientSound('ActiveLoop')
            
            --# Enable Cloak or Cloakfield
            if self.IsCloakFieldUnit then
                self:EnableUnitIntel('CloakField')
            else
                self:EnableUnitIntel('Cloak')
            end
            
            --# take care of power usage
            if self.ResourceDrainBreakDown then 
                self.EnabledResourceDrains.Cloak = true
                self:UpdateConsumptionValues()
                --# OnIntelEnabled often doesn't get called
                --# if we have multiple intel types
                --# so we do it explicitly for units that use this mod
                self:OnIntelEnabled()
            else 
                self:SetMaintenanceConsumptionActive()
            end
        end
    end,
    
    
    --#*
    --#*  I overrided this to use my ResourceDrainBreakDown key.
    --#**   
    OnProductionPaused = function(self)
        self.IsProductionPaused = true
        --# Change this to use ResourceDrainBreakDown
        if self.ResourceDrainBreakDown then 
            --# Switch off costs because production is paused
            self.EnabledResourceDrains.ProductionCosts = false
            self:UpdateConsumptionValues()
        else
            self:SetMaintenanceConsumptionInactive()
        end
        --# GPG version does this
        self:SetProductionActive(false)
    end,

    --#*
    --#*  I overrided this to use my ResourceDrainBreakDown key.
    --#**   
    OnProductionUnpaused = function(self)
        self.IsProductionPaused = false
        --# Change this to use ResourceDrainBreakDown
        if self.ResourceDrainBreakDown then 
            --# Switch costs on because production is active
            self.EnabledResourceDrains.ProductionCosts = true
            self:UpdateConsumptionValues()
        else
            self:SetMaintenanceConsumptionActive()
        end
        --# GPG version does this
        self:SetProductionActive(true)
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  I moved this code here as it should not be elsewhere.
    --#*  This happens when unit's production is unpaused
    --#*  and it has whatever other conditions it needs 
    --#*  to execute production.
    --#*  The consequence of moving it here is that you may
    --#*  sometimes hear the sound twice.
    --#**
    OnActive = function(self)
        --# Play activate sound if there is one
        local myBlueprint = self:GetBlueprint()
        if myBlueprint.Audio and myBlueprint.Audio.Activate then
            self:PlaySound(myBlueprint.Audio.Activate)
        end
    end,
    
    
    
    
--[[

Message from Gilbot-X:

This function is new, I added it.  Units with enhancements that use this mod should call this function at the end of their override of CreateEnhancement if any of their enhancements consume power!!

]]
    FinishCreatingEnhancement = function(self, enh)
        if not enh then 
            WARN("MaintenanceConsumption Mod: FinishCreatingEnhancement: " .. 
                 "Expected 2 args but got 1 for " .. self.DebugId())
            return
        end
    
        self:ResourceDrainBreakDownLog("FinishCreatingEnhancement: " 
        .. "Applying ResourceDrainChanges for enh=" .. enh
        )
        
        --# Override existing energy consumption values 
        --# with any new values provided in the enhancement blueprint
        local enhancementBP = self:GetBlueprint().Enhancements[enh] 
        if not enhancementBP then 
            WARN("MaintenanceConsumption Mod: FinishCreatingEnhancement: " .. 
                 "BP not found for " .. enh .. " for " .. self.DebugId)
            return
        end
        
        
        if enhancementBP.ResourceDrainChanges then
            for drainsourcekey, drainsourcetable in enhancementBP.ResourceDrainChanges do
                if self.ResourceDrainBreakDown[drainsourcekey] 
                and drainsourcetable then 
                    --# Note, errors in the BP file, 
                    --# no extra keys will be inserted
                    for draintype, drainamount in drainsourcetable do 
                        if draintype == 'Energy' then 
                            self.ResourceDrainBreakDown[drainsourcekey].Energy = drainamount
                        elseif draintype == 'Mass' then 
                            self.ResourceDrainBreakDown[drainsourcekey].Mass = drainamount
                        else
                            WARN("MaintenanceConsumption Mod: FinishCreatingEnhancement: " .. 
                                "Found bad keys in ResourceDrainChanges in enhancement BP: " .. 
                                drainsourcekey .. "." .. draintype .. " for " .. self.DebugId)
                        end
                    end 
                else
                    WARN("MaintenanceConsumption Mod: FinishCreatingEnhancement: " .. 
                          "Found bad keys in ResourceDrainChanges in enhancement BP: " .. 
                          drainsourcekey .. " for " .. self.DebugId)
                end                
            end
        else
            self:ResourceDrainBreakDownLog("FinishCreatingEnhancement: No ResourceDrainChanges found.")
        end
        
        --# Call this so unit will start to consume 
        --# energy according to newly loaded values 
        self:UpdateConsumptionValues()
    end,
    
  
  
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Called only by UpdateConsumptionWhenAbilityChanges.
    --#*  Also called by slider control callbacks. 
    --#*  Get reference values for consumption from unit blueprints.
    --#*  
    --#*  Note:  No point looking at enhancement blueprints.
    --#*  We would need to sync to find out which enhancement we had, 
    --#*  so we would have got data from sync table anyway.
    --#**  
    GetReferenceConsumptionFromBlueprint = function(self, resourceDrainId) 
        local econbp = self:GetBlueprint().Economy
        local referenceConsumption = {Energy=0, Mass=0}
        
        --# Does this unit use the ResourceDrainBreakDown key 
        --# to manage multiple resource drains?
        if self.ResourceDrainBreakDown then
            --# Perform safety check
            if econbp.ResourceDrainBreakDown[resourceDrainId] then
                --# Get values from BP
                referenceConsumption.Energy =            
                    econbp.ResourceDrainBreakDown[resourceDrainId].Energy or 0
                referenceConsumption.Mass =            
                    econbp.ResourceDrainBreakDown[resourceDrainId].Mass or 0
            else
                --# Warn unit programmer they have made a mistake
                --# when trying to use this mod.
                WARN('GetReferenceConsumptionFromBlueprint: Bad resource drain ID ' 
                  .. repr(resourceDrainId) .. ' supplied.'
                )
            end
        else
            --# This unit was not designed for use with 
            --# my Maintenance Consumption Breakdown code.
            referenceConsumption.Energy =  econbp.MaintenanceConsumptionPerSecondEnergy or 0 
            referenceConsumption.Mass = econbp.MaintenanceConsumptionPerSecondMass or 0
        end
        
        --# return result
        return referenceConsumption
    end,
        
        
        
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Called by slider control callbacks and also in unit scripts by other 
    --#*  units who change how much something drains depending on its situation.
    --#**          
    UpdateConsumptionWhenAbilityChanges = function(self, newAbilityValue, 
              referenceAbilityValue, resourceDrainId, referenceConsumption)
          
        local changeFactor = 0
        local newConsumption = {Energy=0, Mass=0}
        
        --# If we didn't get it as an argument...
        if not referenceConsumption then
            --# then get it from the blueprint.
            referenceConsumption = self:GetReferenceConsumptionFromBlueprint(resourceDrainId)
        end
               
        --# Without a reference value we can't update the consumption to anything meaningful
        if referenceAbilityValue > 0 then 
            --# Warning, this change factor can be zero if the newAbilityValue is zero
            changeFactor = newAbilityValue / referenceAbilityValue    
        
             --# Calculate new resource consumption based on linear scaling
            newConsumption.Energy = referenceConsumption.Energy * changeFactor
            newConsumption.Mass   = referenceConsumption.Mass   * changeFactor
      
            --# Alter amount of each resource consumed now that 
            --# abilty value is at this setting.
            if self.ResourceDrainBreakDown then
                --# If resourceDrainId was not defined it means
                --# there should be no resource drain for this ability.
                --# Should this have been called in that case?
                if resourceDrainId then
                    --# Perform safety check to see unit has values
                    if self.ResourceDrainBreakDown[resourceDrainId] then
                        --# Set values in self
                        self.ResourceDrainBreakDown[resourceDrainId].Energy = newConsumption.Energy
                        self.ResourceDrainBreakDown[resourceDrainId].Mass = newConsumption.Mass
                        self:UpdateConsumptionValues()
                    else
                        --# Warn self programmer they have made a mistake
                        --# when trying to use this mod.
                        WARN('UpdateConsumptionWhenAbilityChanges: Bad resource drain ID ' 
                          .. repr(resourceDrainId) .. ' supplied.'
                        )
                    end
                else
                    --# Warn self programmer they have made a mistake
                    --# when trying to use this mod.
                    WARN('UpdateConsumptionWhenAbilityChanges: Called on' 
                     .. ' ResourceDrainBreakDown unit with no resourceDrainId supplied.'
                    )
                end
            else
                --# This unit was probably not designed for use with 
                --# my Maintenance Consumption Breakdown code, or 
                --# it only has one resource consuming ability.
                if newConsumption.Energy then
                    self:SetEnergyMaintenanceConsumptionOverride(newConsumption.Energy)
                    self:SetConsumptionPerSecondEnergy(newConsumption.Energy)
                end
                if newConsumption.Mass then
                    self:SetMassMaintenanceConsumptionOverride(newConsumption.Mass)
                    self:SetConsumptionPerSecondMass(newConsumption.Mass)
                end
            end
            
            --# This next block is for debugging only.
            --# This can be deleted when debugging is finished.
            self:SliderLog('UpdateConsumptionWhenAbilityChanges:' ..
                '  resourceDrainId='        .. repr(resourceDrainId) ..
                '  newConsumption.Energy='  .. repr(newConsumption.Energy) ..
                '  newConsumption.Mass='    .. repr(newConsumption.Mass) ..
                '  referenceAbilityValue='  .. repr(referenceAbilityValue) ..
                '  newValue='               .. repr(newAbilityValue)
            )
            
            --# I added this for Autotoggle units as the ACU
            --# needs to be able to work out how much energy will be 
            --# saved by turning this unit off.
            if self.IsAutoToggleUnit then
                for k, vEntry in self.AutoToggleEntries do
                    if vEntry.ResourceDrainId == resourceDrainId then
                        vEntry:RefreshAutoToggleConsumptionRate(resourceDrainId, newConsumption.Energy)
                    end
                end
            end
            
            --# This code is used by some PauseableActiveEffect units.
            if self.UpdateActiveEffectsWhenAbilityChanges then
                self:UpdateActiveEffectsWhenAbilityChanges(changeFactor, resourceDrainId)
            end
        end
    end,

--[[

Message from Gilbot-X:

This function is new, I added it when making Adjacency v2 to support ACUs carrying information about the army.

]]  
     
     
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Commanders can store information for the army
    --#*  and be referenced throughout their lifetime.
    --#*  If you are playing non-assassin mode and you 
    --#*  lose your commander, then tough, you lose your 
    --#*  army's data!
    --#*
    --#*  If you are playing with Victory conditions set to 
    --#*  Supremacy, Annihilation or Sandbox, then whatever is
    --#*  built first after the ACU does will get its entity id.
    --#*  This function returns nil if that has happened.
    --#** 
    GetMyCommander= function(self)
        --# Try to return cached value first
        if self.MyCommander 
            and self.MyCommander.IsACU 
            and self.MyCommander:IsAlive() 
        --# Return cached value
        then return self.MyCommander 
        end
        --# Now try to get the unit itself.        
        local myCommander = GilbotUtils.GetCommanderFromArmyId(self.MyArmyId)
        --# If no unit came back at all...
        if myCommander 
        then self.MyCommander = myCommander
        else self.MyCommander = nil
        end
        --# Return a reference to the ACU
        --# that allows calling code to call special
        --# functions defined in the ACU's unit script.
        return self.MyCommander
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This is used by the ACUKnowledge class for auto power-down.
    --#** 
    GetMyTechLevel = function(self)
        if EntityCategoryContains(categories.TECH1, self) then return 1 end
        if EntityCategoryContains(categories.TECH2, self) then return 2 end
        if EntityCategoryContains(categories.TECH3, self) then return 3 end
        if EntityCategoryContains(categories.EXPERIMENTAL, self) then return 4 end
    end,
    
    
--------------------------------------------------------------------------------------------------
--  New Functions For Cloak Effect 
--  (Based on concept by CovertJaguar)                                                  	
--------------------------------------------------------------------------------------------------
    
    --# This var is used only by the ACU and by cloakfield units.
    --# Here you set the time in seconds you want between 
    --# each time a cloakfield unit checks its surroundings 
    --# and marks units as being in  a cloak field.
    --# All units will unmark themselves at half the frequency that units are marked.   
    CloakUpdatePeriod = 0.5,
    
    --#*
    --#*  This is called when ever a unit that has 
    --#*  some kind of counterintel has it disabled or enabled.
    --#**    
    UpdateCloakEffect = function(self)
        --# safety check for death so we don't 
        --# call IsIntelEnabled on a dead unit.
        if not self:IsAlive() then return end
        --# We are cloaked if we have our own cloak or our own cloakfield
        --# or we are inside someone elses cloakfield.
        local shouldBeCloakedNow =  self:IsIntelEnabled('Cloak') or 
                                    self:IsIntelEnabled('CloakField') or 
                                    self.InCloakField
        --# We know what we should be.
        --# Blocks against redundant/inappropriate 
        --# calls are in these two functions themselves.
        if shouldBeCloakedNow 
        then self:ActivateTransparentCloakEffect()
        else self:DeactivateTransparentCloakEffect()
        end
    end,

    --#*
    --#*  Units were getting cloak effect before they were
    --#*  finished being built, which meant they lost their 
    --#*  effect when they were finished being built because
    --#*  they got a new mesh, but they thought they still 
    --#*  had the effect so it wasn't reapplied.
    --#**
    AllowedToHaveCloakEffectNow = function(self)
        --# Pipeline units look rubbish 
        --# with cloak effect on.
        if self.IsPipeLineUnit 
        or (not self:IsAlive())
        --or self:IsBeingBuilt()
        or self.DoNotEnableCloakEffect
        then return false
        else return true
        end
    end,
    
    ActivateTransparentCloakEffect = function(self)
        --# Pipelines don't look good with effect because of hub
        if not self:AllowedToHaveCloakEffectNow() then return end
            
        --# This allows a second application just to be sure, but makes sure we
        --# don't apply effect more than twice consecutively to same unit.
        if self.NumberOfTimesCloakEffectHasBeenEnabledWithoutBeingDisabled == 1 then 
            if self.IsCloakUnit or self.IsCloakFieldUnit then
                self:CloakEffectLog("Cloakable unit " .. self.DebugId
                .. " is having transparency mesh applied a redundant time." 
                )
            else
                WARN("Gilbot: Unit " .. self.DebugId
                .. ": is having transparency mesh applied redundantly and is not a counter-intel unit." 
                )
                return
            end
        end 
        
        --# This allows a second application just to be sure, but makes sure we
        --# don't apply effect more than twice consecutively to same unit.
        if self.NumberOfTimesCloakEffectHasBeenEnabledWithoutBeingDisabled > 1 then 
            WARN("Gilbot:  Unit " .. self.DebugId
            .. " is having transparency mesh applied a second redundant time." 
            )
            return 
        end 
          
        --# Record how many times this has been applied
        --# since the last time DeactivateTransparentCloakEffect was called.
        self.NumberOfTimesCloakEffectHasBeenEnabledWithoutBeingDisabled = 
            self.NumberOfTimesCloakEffectHasBeenEnabledWithoutBeingDisabled + 1
            
        --# Remove any effects that conflict with cloak effects
        self:DestroyIdleEffects()
        self:DestroyMovementEffects()
        self:DestroyBeamExhaust()
        
        --# Ask unit to get rid of any conflicting effects
        --# that shouldn't be on when cloak effect is on.
        --# i.e. specific effects not removed by the calls above.
        if self.OnCloakEffectEnabled then 
            self:OnCloakEffectEnabled(true)
        end
        
        --# Make the visual change
        self:SetMesh(self:GetBlueprint().Display.CloakMeshBlueprint, true)
    end,
    
    DeactivateTransparentCloakEffect = function(self)
        --# Pipelines don't look good with effect because of hub
        if self.IsPipeLineUnit then return end 
           
        --# Safeguard against redundant calls
        if self.NumberOfTimesCloakEffectHasBeenEnabledWithoutBeingDisabled == 0 then return end
        
        --# This allows us to activate the effect again
        --# i.e. turns off safeguarg against redundant applications
        self.NumberOfTimesCloakEffectHasBeenEnabledWithoutBeingDisabled = 0
        --self:CloakEffectLog('DeactivateTransparentCloakEffect: '
        --.. 'Removing effect from ' .. self.DebugId
        --)
 
        --# Revert visual change
        self:SetMesh(self:GetBlueprint().Display.MeshBlueprint, true)
        
        --# Ask unit to renable any conflicting effects
        --# that should come back on when cloak effect is switched off
        if self.OnCloakEffectEnabled then 
            self:OnCloakEffectEnabled(false)
            --# i.e. make calls to these:
            --self:CreateIdleEffects()
            --self:CreateMovementEffects()
            --self:UpdateBeamExhaust('Idle')
        end
    end,

    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I added this function to support use of cloak effect.
    --#**
    IsThisUnitCloaked = function(self)
        
        --# First check if we are in someone else's claok field.
        if self.InCloakField then return true end
        
        --# If not, then next check if the unit itself has cloak powers.
        --# If a unit is using my Maintenance Consumption Breakdown code,
        --# then there is an alternative way to test that does not rely on 
        --# the GPG function Unit.IsIntelEnabled.  There were issues about 
        --# the accuracy of that function, for some of my modded units
        --# that have more than one type of intel. So if it isn't trusted, we
        --# can opt (before hook time) to use the alternative method for those
        --# units.        
        local dontTrustIsIntelEnabled = false
        if dontTrustIsIntelEnabled and self.ResourceDrainBreakDown then
            
            --# Yes, Maintenance Consumption Breakdown mod IS being used by this unit
            local cloaked = false
            --# If cloak is switched on
            if self.EnabledResourceDrains.Cloak then
                --# Look at the economy and our unit's energy income
                local aiBrain = self:GetAIBrain()
                local fraction = self:GetResourceConsumed()
                --#  If we are not getting full energy we need to cloak 
                --#  or our economy is at zero energy then we can't be cloaked
                if fraction ~= 1 and aiBrain:GetEconomyStored('ENERGY') <= 0 then
                    cloaked = false
                else
                --# otherwise assume we are cloaked!
                    cloaked = true
                end
            end
          
            return cloaked
        else
            --# No, Maintenance Consumption Breakdown mod 
            --# is NOT being used by this unit
            --# so pray that this GPG code actually works!!
            return self:IsIntelEnabled('Cloak') or self:IsIntelEnabled('CloakField')
        end
    end,
    
    
 
    
--------------------------------------------------------------------------------------------------
--  Overridden Functions For Cloak Effect
--   (Based on code by CovertJaguar)    	
--------------------------------------------------------------------------------------------------
	
    
    --#
    --#*  Gilbot-X:
    --#* 
    --#*  I overrided this so that units with their own cloak
    --#*  will apply transparency effect to themselves.
    --#**  
    EnableIntel = function(self, intel)
        --# IN FA baseclass version is just an empty template
        PreviousVersion.EnableIntel(self, intel)
        --# This will turn our own cloak effect on or off
        if intel == 'Cloak' and self.IsCloakUnit then 
            self.HasOwnCloakEnabled= true
            if not self.InCloakField then
                self:UpdateCloakEffect() 
            end
        end
    end,

    --#
    --#*  Gilbot-X:
    --#* 
    --#*  I overrided this so that units with their own cloak
    --#*  will apply transparency effect to themselves.
    --#**    
    DisableIntel = function(self, intel)
        --# IN FA baseclass version is just an empty template
        PreviousVersion.DisableIntel(self, intel)
        --# This will turn our own cloak effect on or off
        if intel == 'Cloak' and self.IsCloakUnit then 
            self.HasOwnCloakEnabled= false
            if not self.InCloakField then
                self:UpdateCloakEffect() 
            end
        end
    end,


    
    
--------------------------------------------------------------------------------------------------
--  Overridden Functions For Economy
----------------------------------------------------------------------------------------------------

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Watches the unit's resource usage.  If this unit doesn't get all 
    --#*  the energy or mass that it needs, this thread shuts off features.
    --#*  Overrided because GPG version was buggy.  Using GetResourceConsumed 
    --#*  was not a suffient check if a unit was enough energy or mass to power 
    --#*  its features.  Now it uses my IsResourceStarved() function.
    --#**
    IntelWatchThread = function(self)
        local recharge = self:GetBlueprint().Intel.ReactivateTime or 10
        if (not self:GetBlueprint().Intel.ReactivateTime) and self:ShouldWatchIntel() then
            LOG('IntelWatchThread: Units of type ' .. self:GetUnitId() 
            .. ' do not have ReactivateTime defined in their Intel blueprint.')
        end
        while self:ShouldWatchIntel() do
            WaitSeconds(0.5)
            while not self:IsResourceStarved() do
                WaitSeconds(0.5)
            end
            self:DisableUnitIntel(nil)
            WaitSeconds(recharge)
            self:EnableUnitIntel(nil)
        end
        if self.IntelThread then 
            self.IntelThread = nil
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  A better alternative to GetResourceConsumed for checking
    --#*  if a unit that needs energy or mass to power a feature
    --#*  does not have enough to run that feature and we should 
    --#*  switch it off.
    --#**
    IsResourceStarved = function(self)
        if (
            --# If we don't need anything
             (self:GetConsumptionPerSecondEnergy() + 
              self:GetConsumptionPerSecondMass()
             ) <= 0
           ) 
          --# or if we need stuff but we are getting it
          or (self:GetResourceConsumed() == 1)
        then
            --# We are not starved
            return false
        else
            --# Otherwise we are starved
            return true
        end
    end,
    
    
--------------------------------------------------------------------------------------------------
--  Overridden Functions For Pipelines
----------------------------------------------------------------------------------------------------


    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I added this function to support use of x and z offsets
    --#*  in the shield blueprints.
    --#**
    CreateShield = function(self, shieldSpec)
        local bp = self:GetBlueprint()
        local bpShield = shieldSpec
        if not shieldSpec then
            bpShield = bp.Defense.Shield
        end
        if bpShield then
            self:DestroyShield()
            self.MyShield = Shield {
                Owner = self,
                Mesh = bpShield.Mesh or '',
                MeshZ = bpShield.MeshZ or '',
                ImpactMesh = bpShield.ImpactMesh or '',
                ImpactEffects = bpShield.ImpactEffects or '',    
                Size = bpShield.ShieldSize or 10,
                ShieldMaxHealth = bpShield.ShieldMaxHealth or 250,
                ShieldRechargeTime = bpShield.ShieldRechargeTime or 10,
                ShieldEnergyDrainRechargeTime = bpShield.ShieldEnergyDrainRechargeTime or 10,
                ShieldVerticalOffset = bpShield.ShieldVerticalOffset or -1,
                --# Gilbot-X says:
                --# The next 2 lines are new.
                ShieldXOffset = bpShield.ShieldXOffset or 0,
                ShieldZOffset = bpShield.ShieldZOffset or 0,
                ShieldRegenRate = bpShield.ShieldRegenRate or 1,
                ShieldRegenStartTime = bpShield.ShieldRegenStartTime or 5,
                PassOverkillDamage = bpShield.PassOverkillDamage or false,
            }
            self:SetFocusEntity(self.MyShield)
            self:EnableShield()
            self.Trash:Add(self.MyShield)
        end
    end,
    
    
--------------------------------------------------------------------------------------------------
--  Overridden Functions For Enhancement Effects
----------------------------------------------------------------------------------------------------


    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions because enhancement effects
    --#*  were only a suitable size for ACUs and SCUs
    --#**
    CreateEnhancementEffects = function( self, enhancement )
        --# Do original code first
        PreviousVersion.CreateEnhancementEffects(self, enhancement)
        --# Call my function if defined
        if self.CreateCustomUpgradeEffects then
            self:CreateCustomUpgradeEffects()
        end
    end,
    CleanupEnhancementEffects = function( self )
        --# Do original code first
        PreviousVersion.CleanupEnhancementEffects(self)
        --# Call my function if defined
        if self.DestroyCustomUpgradeEffects then
            self:DestroyCustomUpgradeEffects()
        end
    end,
    


    
--------------------------------------------------------------------------------------------------
--  Overridden Functions For Enhancement Queuing
----------------------------------------------------------------------------------------------------

    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions so that multiple units of
    --#*  the same unit ID can be selected together and
    --#*  apply enhancements to all with same click. 
    --#*  Enhancements should also be queued up.
    --#**
    OnWorkBegin = function(self, work)
        --# This replaces code moved to enhancemenentqueue.lua.
        --# If this is not the next thing we are supposed to do...
        if self.EnhancementQueue[1].Enhancement ~= work then 
            LOG('OnWorkBegin: Did not find enhancement ' .. work
            .. ' at front of queue for unit ' .. self.DebugId
            .. ' so that enhancement command will be ignored.'
            )
            LOG('EnhancementQueue: ' .. repr(self.EnhancementQueue))
            return false 
        end
        
        --# Debugging
        if self.EnhancementQueue[1].Status == 'Command Not Yet Issued' then
            LOG('OnWorkBegin: Started work on ' .. work 
              .. ' on unit ' .. self.DebugId 
              .. ' before status was marked that command was issued.'
            )
        end
        --# Update status
        self.EnhancementQueue[1].Status = 'In Progress'
        --# Perform a sync here as we have changed the queue
        self.Sync.EnhancementQueue = self.EnhancementQueue
        
        --# This code was from OnWorkBegin   
        local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(self:GetEntityId())
        local tempEnhanceBp = self:GetBlueprint().Enhancements[work]
    
        --# The rest is unchanged from FA code.
        self.WorkItem = tempEnhanceBp
        self.WorkItemBuildCostEnergy = tempEnhanceBp.BuildCostEnergy
        self.WorkItemBuildCostMass = tempEnhanceBp.BuildCostEnergy
        self.WorkItemBuildTime = tempEnhanceBp.BuildTime
        self.WorkProgress = 0
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('EnhanceStart')
        self:PlayUnitAmbientSound('EnhanceLoop')
        self:UpdateConsumptionValues()
        self:CreateEnhancementEffects(work)
        ChangeState(self,self.WorkingState)
        return true
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked this function so that multiple units of
    --#*  the same unit ID can be selected together and
    --#*  apply enhancements to all with same click. 
    --#*  Enhancements should also be queued up.
    --#**
    WorkingState = State {
        Main = PreviousVersion.WorkingState.Main,

        OnWorkEnd = function(self, work)
            self:SetActiveConsumptionInactive()
            AddUnitEnhancement(self, work)
            self:CleanupEnhancementEffects(work)
            --# This next line is the only line 
            --# that changed.
            self:CreateEnhancement(work)
            self.WorkItem = nil
            self.WorkItemBuildCostEnergy = nil
            self.WorkItemBuildCostMass = nil
            self.WorkItemBuildTime = nil
            self:PlayUnitSound('EnhanceEnd')
            self:StopUnitAmbientSound('EnhanceLoop')
            self:EnableDefaultToggleCaps()
            ChangeState(self, self.IdleState)
        end,
        
        IsWorkingState = function(self) 
            return true
        end,
    },
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions so that multiple units of
    --#*  the same unit ID can be selected together and
    --#*  apply enhancements to all with same click. 
    --#*  Enhancements should also be queued up.
    --#**
    OnWorkFail = function(self, work)
        PreviousVersion.OnWorkFail(self, work)
        
        --# Get highest button set in that slot and any prerequisites
        local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(self:GetEntityId())
        
        --# Reset the button for each item in the queue
        --# because their button was pressed to queue them up.        
        for k, v in self.EnhancementQueue do
            --# if this is not a remove enhancement
            if not string.find(v.Enhancement, 'Remove') then
                --# Remove the button and all that 
                --# are associated for that slot.
                RemoveUnitEnhancement(self, v.Enhancement)
            end
        end
        
        --# Reinstate the buttons of enhancements that were finished
        for kSlotName, vEnhancement in self.EnhancementsActive do
            if vEnhancement then
                --LOG('OnWorkFail: Reinstating ' .. vEnhancement)
                AddUnitEnhancement(self, vEnhancement, kSlotName)
            end
        end
        --# Empty the queue
        self.EnhancementQueue={}
        --# Perform a sync here as we have changed the queue
        self.Sync.EnhancementQueue = self.EnhancementQueue
        --# Update the enhancement menu if it is still visible
        self:RequestRefreshUI()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions so that multiple units of
    --#*  the same unit ID can be selected together and
    --#*  apply enhancements to all with same click. 
    --#*  Enhancements should also be queued up.
    --#**
    CreateQueuedEnhancement = function(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        --LOG('Queued enhancement ' .. repr(enh) 
        --.. ' called on ' .. self.DebugId)
    
        --# Remove item from queue so it cannot be removed from menu
        if self.EnhancementQueue[1].Enhancement ~= enh then 
            WARN('CreateEnhancement: ' .. enh 
            .. ' was not first item in enhancement queue of unit ' .. self.DebugId
            )
            WARN(repr(self.EnhancementQueue))
        else
            --# Remove this item from the gead of the queue.
            table.remove(self.EnhancementQueue, 1)
            --# Perform a sync here as we have changed the queue
            self.Sync.EnhancementQueue = self.EnhancementQueue
        end
        
        --# This is done by FA Code.
        if bp.ShowBones then
            for k, v in bp.ShowBones do
                if self:IsValidBone(v) then
                    self:ShowBone(v, true)
                end
            end
        end
        if bp.HideBones then
            for k, v in bp.HideBones do
                if self:IsValidBone(v) then
                    self:HideBone(v, true)
                end
            end
        end
    end,
        
        
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions so that multiple units of
    --#*  the same unit ID can be selected together and
    --#*  apply enhancements to all with same click. 
    --#*  Enhancements should also be queued up.
    --#**
    CreateEnhancement = function(self, enh)
    
        --# This is code from original
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then
            error('*ERROR: Got CreateEnhancement call with an enhancement that doesnt exist in the blueprint.', 2)
            return false
        end
        
        --# This is my code
        if self:IsWorkingState() then 
            self:CreateQueuedEnhancement(enh)
        else
            --LOG('Unqueued enhancement ' .. repr(enh) 
            --.. ' called on ' .. self.DebugId)
            PreviousVersion.CreateEnhancement(self, enh)
        end
        
        --# Update which enhancements are active
        if not string.find(enh, 'Remove') then
            self.EnhancementsActive[bp.Slot] = enh
        else
            self.EnhancementsActive[bp.Slot] = nil
        end
    end,
    
    IsWorkingState = function(self) 
        return false
    end,
    
    
    
--------------------------------------------------------------------------------------------------
--  Added Functions For Experimental Wars Compatibility
----------------------------------------------------------------------------------------------------

    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I added this function to give support for 
    --#*  Experimental Wars Veterancy.
    --#**
    ApplyEWVeteranBuff = function(self, vetBP)
        --# This line is for switching off features
        --# that only work on meshes provided by 
        --# the Experimental Wars mod.         
        if not CanUseEWMeshes then return end
        --# Add buff to increase MaxHealth
        if vetBP.MaxHealthAdd or vetBP.MaxHealthMult then
            local ewVetBuffName = 
               'VETBUFF' .. string.upper(self:GetUnitId()) 
            .. 'LEVEL' .. repr(self.VeteranLevel)
            .. 'MAXHEALTH'
            --LOG('Applying Buff ' .. ewVetBuffName)
            BuffBlueprint {
                Name = ewVetBuffName,
                DisplayName = ewVetBuffName,
                BuffType = 'MAXHEALTH',
                Stacks = 'REPLACE',
                Duration = -1,
                Affects = {
                    MaxHealth = {
                        Add = vetBP.MaxHealthAdd or 0,
                        Mult = vetBP.MaxHealthMult or 1,
                    },
                },
            }
			Buff.ApplyBuff(self, ewVetBuffName)
        end
        --# Show bones to reveal cool weapons
        if vetBP.ShowBones and type(vetBP.ShowBones) == 'table' then 
            for kBoneName, vToggle in vetBP.ShowBones do
                if vToggle 
                then self:ShowBone(kBoneName, true)
                else self:HideBone(kBoneName, true) 
                end
            end
        end
        --# Show bones to reveal cool weapons
        if vetBP.EnableWeapons and type(vetBP.EnableWeapons) == 'table' then 
            for kWeaponName, vToggle in vetBP.EnableWeapons do
                self:SetWeaponEnabledByLabel(kWeaponName, vToggle)
            end
        end
        --# Add damage to the weapon named
        if vetBP.WeaponDamageAdd and type(vetBP.WeaponDamageAdd) == 'table' then 
            for kWeaponName, vValue in vetBP.WeaponDamageAdd do
                self:GetWeaponByLabel(kWeaponName):AddDamageMod(vValue)
            end
        end
        --# Change ther ROF of the weapon named to the new value given
        if vetBP.RateOfFireBonusFactors and type(vetBP.RateOfFireBonusFactors) == 'table' then 
            for kWeaponName, vValue in vetBP.RateOfFireBonusFactors do
                local weapon = self:GetWeaponByLabel(kWeaponName)
                weapon.RateOfFireVeterancyBonus = vValue
                weapon:UpdateRateOfFireFromBonuses()
            end
        end
        --# Change ther ROF of the weapon named to the new value given
        if vetBP.WeaponMaxRadiusSet and type(vetBP.WeaponMaxRadiusSet) == 'table' then 
            for kWeaponName, vValue in vetBP.WeaponMaxRadiusSet do
                self:GetWeaponByLabel(kWeaponName):ChangeMaxRadius(vValue)
            end
        end
    end,

}

--# Give all units the AT code base
local GiveAutoToggleCodeToUnit = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotoggleunit.lua').GiveAutoToggleCodeToUnit    

--# Now apply AT code
Unit = GiveAutoToggleCodeToUnit(Unit)

end --(end of non-destructive hook)