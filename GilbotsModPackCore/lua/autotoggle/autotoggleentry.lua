--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/autotoggle/autotoggleentry.lua
--#**
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  
--#**     This is the code for units that consume energy when active
--#**     that allows a controller unit to power them down automatically 
--#**     when the player's economy is low on energy.
--#**
--#**
--#****************************************************************************

AutoToggleEntry = Class
{

    --# This variable provides a convenient means 
    --# of testing any class to see if it is this one.
    IsAutoToggleEntry = true,
        
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This runs when an instance of the class is created.
    --#** 
    __init = function(self, settings, parent)
        
        self.Unit = parent
        self.UnitEntityId = parent:GetEntityId()
        self.ToggleOnPosition = false
        self.ToggleOffPosition = true
        self.IsRegisteredWithATSystem = false
        self.IsInAutoTogglePriorityList = false
        self.PriorityListPosition = 0
        self.MinimumOnTime = 1
        
        --# Make sure these values are copied over
        self.ResourceDrainId =      settings.ResourceDrainId
        self.PowerDownToggleBit =   settings.PowerDownToggleBit
        self.Consumption =          settings.Consumption

        --# Safety check
        if not self.ResourceDrainId then 
            WARN('Gilbot: AT Entry Needs ResourceDrainId')
            return
        end            
        
        if settings.PowerDownToggleBit < 10 then
            self.PowerDownToggleName = 
                'RULEUTC_' .. self.ResourceDrainId .. 'Toggle'
        else
            WARN('Gilbot: AT Entry: Behaviour not defined yet for building.')
        end
        
        --# Apply sensible defaults   
        --# Shield        
        if settings.PowerDownToggleBit == 0 then
            self.ToggleOnPosition = true
            self.ToggleOffPosition = false
            self.PriorityCategory = settings.PriorityCategory or 5
            --# Assume the unit has already created the shield.
            if self.Unit.MyShield then 
                self.MinimumOnTime = (self.Unit.MyShield.ShieldEnergyDrainRechargeTime or 5) + 10
            else
                WARN('AT Shield Entry: Shield was not already created when AT entry created.')
            end
        --# Jammer     
        elseif settings.PowerDownToggleBit == 2 then
            self.PriorityCategory = settings.PriorityCategory or 4
            self.MinimumOnTime = (self.Unit:GetBlueprint().Intel.ReactivateTime or 10) + 3
        --# Intel (radar)
        elseif settings.PowerDownToggleBit == 3 then
            self.PriorityCategory = settings.PriorityCategory or 3
            self.MinimumOnTime = (self.Unit:GetBlueprint().Intel.ReactivateTime or 10) + 3
        --# This unit can pause production (i.e. massfabs) or give 
        --# remote adjacency, so let  use Auto-toggle on it.
        elseif settings.PowerDownToggleBit == 4 then
            self.PriorityCategory = settings.PriorityCategory or 1
        --# Stealth 
        elseif settings.PowerDownToggleBit == 5 then
            self.PriorityCategory = settings.PriorityCategory or 4
            self.MinimumOnTime = (self.Unit:GetBlueprint().Intel.ReactivateTime or 10) + 5
        --# Generic
        elseif settings.PowerDownToggleBit == 6 then
            self.PriorityCategory = settings.PriorityCategory or 2
        --# Special   
        elseif settings.PowerDownToggleBit == 7 then
            self.PriorityCategory = settings.PriorityCategory or 2
        --# Cloak
        elseif settings.PowerDownToggleBit == 8 then
            self.PriorityCategory = settings.PriorityCategory or 4
            self.MinimumOnTime = (self.Unit:GetBlueprint().Intel.ReactivateTime or 10) + 5
        elseif settings.PowerDownToggleBit == 9 then
            self.PriorityCategory = settings.PriorityCategory or 5
            --# Define this so we can add it to list
            --# of entries that are toggled off when 
            --# mass gets low.
            self.Consumption.Mass = 0
        else
            --# Inappropriate argument.  Programming error in third party unit mod.
            WARN("Gilbot-X's Modpack: Bad value " .. repr(settings.PowerDownToggleBit) 
            .. " for PowerDownToggleBit in autotoggleunit.lua"
            )
            return
        end
           
        --# Start switched on
        --# But thsi will be updtaed when 
        --# we register the entry with a controller.
        self.On = true
        --# Start permitted to be switched back on
        self.CanAutoToggleOnNow = true
    end,
    

    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This function makes sure that Ui is updated.
    --#** 
    SetPriorityListPosition = function(self, newPositionArg)
        self.PriorityListPosition = newPositionArg
        --# Were we asked to update the display?
        self.Unit:DoUserSyncOfAutoToggleDisplayText()
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This function makes sure that on/off state is valid
    --#*  when autotoggle calls for the toggle to be set. 
    --#*
    --#*  You can't call this from OnScriptBitSet or OnScriptBitClear
    --#*  because this function also tries to set the same script bit. 
    --#** 
    SwitchOff = function(self)
        --# Only switch off if 
        --# we were already on
        if self.On then
            --# Switch off depending on unit type
            if self.PowerDownToggleBit == 9 then 
                --# Pause construction
                self.Unit:SetPaused(true)
            else
                --# if it is not the shield
                if self.ToggleOffPosition == true then 
                    --# setting the bit turns it off
                    self.Unit:OnScriptBitSet(self.PowerDownToggleBit) 
                else
                    --# otherwise clearing the bit turns it off
                    self.Unit:OnScriptBitClear(self.PowerDownToggleBit) 
                end
            end
            
            --# Record that we 
            --# are switched off
            self.On = false
                
            --# Were we asked to update the display?
            self.Unit:DoUserSyncOfAutoToggleDisplayText()
    
            --# Signal to calling code that 
            --# a toggle change took place
            return true
        else
            --# Signal to calling code that 
            --# a toggle change did not take place
            return false
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This function makes sure that on/off state is valid
    --#*  when autotoggle calls for the toggle to be set.
    --#*
    --#*  You can't call this from OnScriptBitSet or OnScriptBitClear
    --#*  because this function also tries to set the same script bit. 
    --#** 
    SwitchOn = function(self)
        --# Only switch on if 
        --# we were already off
        if not self.On then 
            --# Switch off depending on unit type
            if self.PowerDownToggleBit == 9 then 
                --# Pause construction
                self.Unit:SetPaused(false)
            else
                --# If its the shield
                if self.ToggleOffPosition == false then 
                    --# Setting the bit turns it on
                    self.Unit:OnScriptBitSet(self.PowerDownToggleBit) 
                else
                    --# otherwise clearing the bit turns it on
                    self.Unit:OnScriptBitClear(self.PowerDownToggleBit) 
                end
            end
            --# Record that we 
            --# were switched on
            self.On = true
            --# Were we asked to update the display?
            self.Unit:DoUserSyncOfAutoToggleDisplayText()

            --# Signal to calling code that 
            --# a toggle change took place
            return true
        else
            --# Signal to calling code that 
            --# a toggle change did not take place
            return false
        end 
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called when a living AT unit unregisters from AT.
    --#** 
    ReplaceOriginalButton = function(self)
        --# Perform safety check first
        if self.PowerDownToggleBit==9 then return end
        --# Replace the button (inherits toggle state it had when it was removed)
        self.Unit:AddToggleCap(self.PowerDownToggleName)
        ForkThread(    
            function(self)
                WaitTicks(1)
                --# I second is long enough for unit to 
                --# have been destroyed, either by an enemy 
                --# or maybe an upgrade finished
                if not self.Unit:IsAlive() then return end
                --# Make sure toggle state matches unit state
                if self.On then
                    --# toggle is in off position
                    if self.Unit:GetScriptBit(self.PowerDownToggleName) == self.ToggleOffPosition then
                        --# put toggle in on position
                        self.Unit:SetScriptBit(self.PowerDownToggleName, self.ToggleOnPosition)
                    end
                else
                    --# toggle is in off position
                    if self.Unit:GetScriptBit(self.PowerDownToggleName) == self.ToggleOnPosition then
                        --# put toggle in off position
                        self.Unit:SetScriptBit(self.PowerDownToggleName, self.ToggleOffPosition)
                    end
                end
            end, self
        )
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Use this so that AT's self.On flag agrees 
    --#*  with the unit's true toggled state.
    --#** 
    SetATOnStateFromUnitToggleState = function(self)
        --# Perform safety check first
        if not self.Unit:IsAlive() then return end
        if self.IsInAutoTogglePriorityList then 
            WARN("AT: SetATOnStateFromUnitToggleState: Called on unit already in AT priority list.")
            return 
        end
        --# If this is a construction toggle...
        if self.PowerDownToggleBit==9 then 
            if self.Unit.ActiveConsumption 
            then self.On = true
            else self.On = false
            end
        else -- This is an alt orders toggle
            if self.Unit:GetScriptBit(self.PowerDownToggleName) == self.ToggleOnPosition
            then self.On = true
            else self.On = false
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Called from UpdateConsumptionWhenAbilityChanges in unit.lua
    --#** 
    RefreshAutoToggleConsumptionRate = function(self, resourceDrainId, newEnergyConsumption)
        --# If we have multiple power drains...
        if self.Unit.ResourceDrainBreakDown and  
            self.ResourceDrainId ~= resourceDrainId then
            --# add protection to stop thr wrong resource 
            --# drain from getting accidental increases.
            return 
        end
            
        --# Assume unit has single power drain source
        self.Consumption.Energy = newEnergyConsumption
    end,
    

    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Moved this into a function to keep consistency.
    --#** 
    GetAutoToggleClassAndPriority = function(self)
        if self.IsInAutoTogglePriorityList then
            local onText = "OFF"
            if self.On then onText = "ON" end
            return self.ResourceDrainId, 
                "C=" .. repr(self.PriorityCategory) 
                .. " P=" .. repr(self.PriorityListPosition), 
                onText
        else
            return self.ResourceDrainId, 
                "C=" .. repr(self.PriorityCategory), 
                "Disabled"
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Added this to make syncing safe and efficient.
    --#** 
    GetSyncableData = function(self)
        local syncableCopy = {
            PriorityCategory= self.PriorityCategory,
            PriorityListPosition = self.PriorityListPosition,
            IsInAutoTogglePriorityList = self.IsInAutoTogglePriorityList,
            PowerDownToggleName=  self.PowerDownToggleName,
            ResourceDrainId = self.ResourceDrainId,
            PowerDownToggleBit = self.PowerDownToggleBit, 
        }
        return syncableCopy
    end,
}