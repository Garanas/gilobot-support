--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/autotoggle/autotoggleunit.lua
--#**
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  
--#**     This is the code for units that consume energy when active
--#**     that allows the ACU to power them down automatically 
--#**     when the player's economy is low on energy.
--#**
--#**
--#****************************************************************************

local AutoToggleEntry = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotoggleentry.lua').AutoToggleEntry
local ResourceDrainIdFromToggleBit = 
    import('/mods/GilbotsModPackCore/lua/resourcedrainid.lua').ResourceDrainIdFromToggleBit
local ATSystem = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua')
local GetAutoToggleController =
    ATSystem.GetAutoToggleController

    
--# This is a table of ATs that
--# are safe to add by default
--# on units that have these toggles.
--# It is not safe to add the other bits.
local ToggleBitFromResourceDrainId = {
    Shield =  0, 
    Jamming = 2, 
    Intel =   3, 
    Stealth = 5, 
    Cloak =   8,
}
    
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function GiveAutoToggleCodeToUnit(baseClassArg)
  
local resultClass = Class(baseClassArg) {
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Overrided to call extra initialisation code.
    --#** 
    OnStopBeingBuilt = function(self,builder,layer)
        
        --# Call base class code first.
        baseClassArg.OnStopBeingBuilt(self,builder,layer)
        
        --# If this unit's army supports AT...
        if ATSystem.DoesArmyHaveATSystem(self.ArmyIdString) then 
            --# Record tech level now because we don't 
            --# want to have to query this on dead units
            self.TechLevel = self:GetMyTechLevel()
            --# This code should not run on ACUs or their building effects
            if (not self.IsACU) and (self:GetUnitId() ~= 'ura0001') then 
                --# If the auto-toggle unit is no longer alive or working for us,
                --# then these callbacks update the ACU with this information.
                self:AddOnCapturedCallback(self.UnregisterAllAutoToggleEntries)
                --# Use a thread to add new ATs once unit hasd 
                --# had chance to add or remove toggle caps
                self:ForkThread(self.AddDefaultAutoToggles)
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  A thread that adds new ATs to this unit.
    --#*  It is called once from OnStopBeingBuilt.
    --#*  It adds ATs for anything appropriate 
    --#*  it finds in the unit's BP.
    --#** 
    AddDefaultAutoToggles = function(self) 
        local unitBP = self:GetBlueprint()
        --# Add construction to anything that can build
        local buildable = unitBP.Economy.BuildableCategory
        if type(buildable) == 'table' and table.getsize(buildable) > 0 then 
            --LOG(self.DebugId .. ' buildable=' .. repr(buildable))
            self:AddAutoToggle({9}) 
        end
        
        --# Perform safety check on toggle factories
        if self.IsToggleFactory then return end
        
        for kResourceDrainId, vIndex in ToggleBitFromResourceDrainId do
            local capsName = 'RULEUTC_' .. kResourceDrainId .. 'Toggle'
            --# If the unit built has this toggle
            if self:TestToggleCaps(capsName) then
                --LOG('Found Toggle ' .. capsName
                --.. ' on unit ' .. self.DebugId
                --)
                self:AddAutoToggle({vIndex})
            end
        end
        
        --# Only add a Production AT if the unit has
        --# settings for it in its BP.  MassFabs do.
        --# So do some remote adjacency units and the
        --# Aeon shield strength enhancer.
        if unitBP.AutoToggleSettings
          and unitBP.AutoToggleSettings['Production'] then
            --LOG('Found BP settings for Production Toggle ' 
            --.. ' on unit ' .. self.DebugId
            --)
            self:AddAutoToggle({4})
        end
    end,
    
        
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Overrided to call extra initialisation code.
    --#** 
    AddAutoToggle = function(self, settingsArg, energyUsageArg)
        --# This variable provides a convenient means 
        --# of testing any unit to see if it uses AT.
        self.IsAutoToggleUnit = true
    
        --# Complete the settings, then apply safety check
        local settings = self:CompleteSettings(settingsArg, energyUsageArg)
        if not settings then return end
        
        --# Add this individual AT entry to our table
        self.AutoToggleEntries[settings.ResourceDrainId] = AutoToggleEntry(settings, self)
        --# and then register it straight away (still need to enable it)
        ATSystem.EntryCommands.Register(self.AutoToggleEntries[settings.ResourceDrainId])
        
        --# Delay switching it on
        if not self.EnsureAutoToggleOnAfterDelayCalled then
            self:ForkThread(self.EnsureAutoToggleOnAfterDelay)
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Overrided to call extra initialisation code.
    --#** 
    RemoveAutoToggle = function(self, resourceDrainIdArg)
        if self.AutoToggleEntries[resourceDrainIdArg] then
            --# Unregister from ACU if registered
            ATSystem.EntryCommands.Unregister(self.AutoToggleEntries[resourceDrainIdArg])
            --# Make the table entry safe (remove from table?)
            self.AutoToggleEntries[resourceDrainIdArg] = nil
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  A thread that switches on any new ATs added.
    --#** 
    EnsureAutoToggleOnAfterDelay = function(self)
        --# Don't allow this to be called again until
        --# this instance has finished
        if self.EnsureAutoToggleOnAfterDelayCalled then return end
        self.EnsureAutoToggleOnAfterDelayCalled = true
        --# This pause allows units to open, unpack etc.
        WaitSeconds(2)
        --# Allow this to be called again
        self.EnsureAutoToggleOnAfterDelayCalled = false
        for kResourceDrainId, vEntry in self.AutoToggleEntries do
            if vEntry then                 
                --# ACU can keep track of networks while alive
                local myATController = GetAutoToggleController(self.ArmyIdString)
                --# If controller is alive...
                if myATController and myATController.ActivateAutoToggleOnNewlyBuiltUnits then
                    ATSystem.EntryCommands.StartToggling(vEntry)
                end
            end
        end    
    end,
        
 
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Added to put energy consumption into settings.
    --#** 
    CompleteSettings = function(self, settingsArg, enhancementEnergyUsageArg)
        local ResourceDrainIdArg = 
            ResourceDrainIdFromToggleBit['r' .. repr(settingsArg[1])]
        --# Abort if wrong arguments given
        if not ResourceDrainIdArg then 
            WARN('Gilbot: GiveAutoToggleCodeToUnit: Bad arg for powerDownToggleBitArg')
            return
        end
        
        --# We'll need this more than once
        local unitBP = self:GetBlueprint()
        
        --# Work out energy consumption
        --# Don't do this for construction entries
        local myEnergyMaintenanceConsumption = enhancementEnergyUsageArg or 0
        if not enhancementEnergyUsageArg then
            if settingsArg[1] == 9 then 
                --# Unit consumes nothing until it starts to build
                myEnergyMaintenanceConsumption = 0
            --# This is a toggle for maintenance consumption
            --# of energy, as opposed to active consumption.
            --# If the unit is marked as having multiple drains...
            elseif self.ResourceDrainBreakDown then
                --# Assign the correct powere drain as the
                --# energy consumption source for this toggle
                myEnergyMaintenanceConsumption = 
                    self.ResourceDrainBreakDown[ResourceDrainIdArg].Energy
            else
                --# Assume unit has single power drain source
                --# Record from BP how much energy this unit uses
                myEnergyMaintenanceConsumption = 
                    unitBP.Economy.MaintenanceConsumptionPerSecondEnergy
            end
        end
            
        --# Generate settings table
        local returnResult = {
            PowerDownToggleBit = settingsArg[1],
            ResourceDrainId = ResourceDrainIdArg,
            PriorityCategory = settingsArg[2],
            Consumption = { 
                Energy = myEnergyMaintenanceConsumption,
            },
        }
        
        --# Get default settings from unit BP
        if not returnResult.PriorityCategory then
            if unitBP.AutoToggleSettings
              and unitBP.AutoToggleSettings[ResourceDrainIdArg] then
                returnResult.PriorityCategory = unitBP.AutoToggleSettings[ResourceDrainIdArg]
            end
        end  

        --# Apply this safety check to catch invalid AT entries
        if not returnResult.Consumption.Energy then return false end            
        
        --# Return the table
        return returnResult
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that tables are 
    --#*  cleaned up when a unit completes an upgrade and 
    --#*  destroys itself.
    --#**
    UnregisterAllAutoToggleEntries = function(self)
        --# Gilbot-X says:  
        --# I added this block of code so that when 
        --# units upgrade they get cleaned out of 
        --# tables in the ACU's auto-toggle tables.
        for k, vEntry in self.AutoToggleEntries do
            ATSystem.EntryCommands.Unregister(vEntry)
        end    
    end,

    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that tables are 
    --#*  cleaned up when a unit completes an upgrade and 
    --#*  destroys itself.
    --#**
    OnDestroy = function(self)
        --# Gilbot-X says:  
        --# I added this block of code so that when 
        --# units upgrade they get cleaned out of 
        --# tables in the ACU's auto-toggle tables.
        self:UnregisterAllAutoToggleEntries()
        --# Finally the rest is GPG code.
        baseClassArg.OnDestroy(self)
    end,

    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This is called by the ACU as part of
    --#*  maintaining the list of registered entities.
    --#** 
    GetRegisteredAutoToggleCount = function(self)
        local count=0
        for k, vEntry in self.AutoToggleEntries do
            if vEntry.IsRegisteredWithATSystem then count=count+1 end
        end
        return count
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Moved this into a function to keep consistency.
    --#** 
    DoUserSyncOfAutoToggleDisplayText = function(self)
        local displayLines = {}
        local lineNumber=1
        --# If there is a controller alive...
        if GetAutoToggleController(self.ArmyIdString) 
        then self.AutoToggleControlsEnabled = true
        else self.AutoToggleControlsEnabled = false
        end
            
        for kResourceDrainId, vEntry in self.AutoToggleEntries do
            local name, priorities, isOn = vEntry:GetAutoToggleClassAndPriority()
            --# Lines are stacked upwards staring 
            --# from first line just above lifebar
            if table.getsize(self.AutoToggleEntries) == 1 then
                if self.AutoToggleControlsEnabled then
                    displayLines[repr(1)]= isOn
                    displayLines[repr(2)] = priorities
                    displayLines[repr(3)] = name
                else
                    displayLines[repr(1)]= ""
                    displayLines[repr(2)] = ""
                    displayLines[repr(3)] = ""
                end
            else
                if self.AutoToggleControlsEnabled then
                    --# Put it onto one line if we have multiple entries
                    displayLines[repr(lineNumber)] = 
                        name .. ": " .. priorities .. " " .. isOn
                else
                    displayLines[repr(lineNumber)] = ""
                end
            end
            --# Increment line number
            lineNumber = lineNumber+1
        end
        
        --# Do sync (does not work for arrays!)
        self.Sync.AutoToggleControlsEnabled = self.AutoToggleControlsEnabled 
        self.Sync.AutoToggleDisplay = displayLines
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This is called by an AT entry every
    --#*  time it changes, so the menu can be up-to-date.
    --#** 
    DoUserSyncOfAutoToggleEntries = function(self)
        --# Allow a flag to temporarily prevent syncs
        --# so we can unregister and reregister an 
        --# AT entry quickly to change its C=? level.
        if self.StopSync then return end
        --# Sync this with the USER state
        local userAutoToggleEntries = {}
        for k, vEntry in self.AutoToggleEntries do
            userAutoToggleEntries[vEntry.ResourceDrainId]= vEntry:GetSyncableData()
        end
        self.Sync.AutoToggleEntries = userAutoToggleEntries
        self:DoUserSyncOfAutoToggleDisplayText()
    end,
    
}


return resultClass

end