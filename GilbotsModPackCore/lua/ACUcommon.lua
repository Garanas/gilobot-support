--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/ACUcommon.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Common ACU Changes Script
--#**
--#****************************************************************************

local GilbotUtils = import('/mods/GilbotsModPackCore/lua/utils.lua')
local ResourceInterNetwork = 
    import('/mods/GilbotsModPackCore/lua/adjacency/resourceinternetwork.lua').ResourceInterNetwork
local ATSystem = 
    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua')    

--#*
--#*  Gilbot-X says:
--#*      
--#*  Use this as a secondary base class in the ACU script files.
--#*  I made this class so I could add extra functionality to all 3 ACUs 
--#*  without mixing my code in the same file as GPG's code. 
--#** 
ACUKnowledge = Class {    
    
    --# This flag gives us a quick way to test
    --# if a unit is inheriting this abstract class
    IsACU = true,
    
    --# These flags determine what 
    --# type of logging goes to output
    DebugRegistrationCode = false,
    DebugAutoToggleCode = false,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  For debugging only.
    --#** 
    RegistrationLog = function(self, messageArg)
        if self.DebugRegistrationCode then 
            if type(messageArg) == 'string' then
                LOG('Registration: a=' .. self.ArmyIdString .. ' ' .. messageArg)
            end
        end
    end,
    AutoToggleLog = function(self, messageArg)
        if self.DebugAutoToggleCode then 
            if type(messageArg) == 'string' then
                LOG('AutoToggle: a=' .. self.ArmyIdString .. ' ' .. messageArg)
            end
        end
    end,

    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  Call this from an override of OnCreate so I can
    --#*  do variable initialization common to all 3 ACUs at this time.
    --#** 
    InitializeKnowledge = function(self)

        local myArmyId = self:GetArmy()
        local myExpectedCommanderEntityId = (myArmyId -1) * 1048576
        local myEntityId = self:GetEntityId()
        
        --# This next block is for debugging only.
        --# This can be delete wheh debugging is done.
        --# I use it to prove that commander entity IDs 
        --# are always a multiple of 1048576.
        --# This was the case up to version 3269
        --# and still seems to work in FA 3599.
        if false then
          LOG('ACUcommon.lua: Creating Commander for ' 
           .. ' Army= ' .. repr(myArmyId)
           .. ' with entityid=' .. repr(myEntityId)
          )
        end
        
        --# This warning will alert me as a programmer
        --# that the version of Supreme Commander I am running on has 
        --# a new system for allocating entity IDs and that I must
        --# update my method of getting a reference to the ACU.        
        if myEntityId ~= repr(myExpectedCommanderEntityId) then
          WARN('ACUcommon.lua: Commander entityID for ' 
          .. ' Army= ' .. repr(myArmyId)
          .. ' is ' .. myEntityId
          .. ' but expected ' .. repr(myExpectedCommanderEntityId)
          )     
        end
        
        --# This is for Displaying UI elements on
        --# units.  The ACU syncs a list of the
        --# unit entity IDs withing the bounds the 
        --# view camera is viewing.  This list comes
        --# from the SIM, and mustr be returned to 
        --# USER state for processing of the UI.
        self.UnitsOnScreenEntityList = {}
          
        --# This is where I will put all tables where 
        --# units can register themselves so that the ACU
        --# (and therefore the entire army) can keep track of
        --# all living instances of that unit type for 
        --# whatever purpose is required.
        self.RegistrationTables = {}
          
        --# Code to initialize Resource Network system 
        --# was separated into its own function
        --# to make code easier to maintain.
        self:InitializeResourceNetworkSystem()
        
        --# The ACU initilaises the whole AT system 
        --# for that army even if it is not the controller
        ATSystem.InitializeAutoToggleSystem(self)
       
        --# This is so ACU can monitor units with cloak effect on
        --# and remove the effect when unit is no longer in cloak field
        self:InitializeCloakEffectSystem()
      
    end,
    
   
   
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that tables are 
    --#*  cleaned up when a unit completes an upgrade and 
    --#*  destroys itself.
    --#*
    --#*  This function is defined in Unit.lua
    --#*  and ends by changing state to DeadState
    --#*  so I have to call my extra code before calling
    --#*  the base class code.
    --#**
    CallBefore_OnDestroy = function(self)
        --# Gilbot-X says:  
        --# I added this block of code so that when 
        --# units upgrade they get cleaned out of ResourceNetwork 
        --# tables and the ACU's auto-toggle tables.
        self:NoMoreResourceNetworks() 
        
        --# Cloak Effect management thread needs to be killed if one exists
        if self.CloakEffectMonitorThreadHandle then
            KillThread(self.CloakEffectMonitorThreadHandle)
            self.CloakEffectMonitorThreadHandle = nil
        end
    end,
    
    
    
    
--#-------------------------------------------------------------
--#  CLOAK EFFECT SPECIFIC CODE
--#-------------------------------------------------------------

    
     
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  This is called from InitializeKnowledge(), which itself is  
    --#*  called from an override of the ACU's Unit:OnCreate(), so I can
    --#*  do variable initialization common to all 3 ACUs at this time.
    --#** 
    InitializeCloakEffectSystem = function(self)
    
        --# When any unit (un)registers with us, 
        --# these tables will be checked for appropriate callbacks.
        self.OnRegisterCallbacks = {}
        self.OnUnregisterCallbacks = {}
        
        --# Create a function that will be called on a unit 
        --# after it registers as being in a cloakfield.
        self.OnRegisterCallbacks['CloakEffectUnit'] = function(self, unitThatJustRegistered)
            --# Next line is for debugging only. Delete when confident that code works.
            --self:CloakEffectLog('Replacing SetMesh and DeactivateTransparentCloakEffect'
            --.. ' functions and adding effect on ' .. unitThatJustRegistered.DebugId
            --)
            
            --# Add cloak effect
            if not unitThatJustRegistered.HasOwnCloakEnabled then
                unitThatJustRegistered:ActivateTransparentCloakEffect()
            end
            
            --# Make the effect safe by swapping the function handle with a dummy function 
            unitThatJustRegistered.OldSetMesh = unitThatJustRegistered.SetMesh
            unitThatJustRegistered.SetMesh = function(self)
                self:CloakEffectLog('SetMesh Dummy called in ' .. self.DebugId)
            end
            
            --# Make this function safe too.  Store old function to revert later
            unitThatJustRegistered.OldDeactivateTransparentCloakEffect = 
                unitThatJustRegistered.DeactivateTransparentCloakEffect
            --# Put a dummy function in its place
            unitThatJustRegistered.DeactivateTransparentCloakEffect = function(self)
                self:CloakEffectLog('DeactivateTransparentCloakEffect Dummy called in ' .. self.DebugId)
            end    
                
            --# Launch ACU's control thread if it isn't already running.
            if not self.CloakEffectMonitorThreadHandle then
                self.CloakEffectMonitorThreadHandle = ForkThread(self.CloakEffectMonitorThread, self)
            end
        end
        --# Create a function that will be called when a unit 
        --# unregisters as having a cloak field effect.
        self.OnUnregisterCallbacks['CloakEffectUnit'] = function(self, unitUnregistering)
            --# Next line is for debugging only. Delete when confident that code works.
            --self:CloakEffectLog('Reverting SetMesh and DeactivateTransparentCloakEffect'
            --.. ' functions and removing effect on ' .. unitUnregistering.DebugId
            --)
            --# Replace original SetMesh and DeactivateTransparentCloakEffect functions.
            unitUnregistering.SetMesh = unitUnregistering.OldSetMesh
            unitUnregistering.DeactivateTransparentCloakEffect = 
                unitUnregistering.OldDeactivateTransparentCloakEffect 
            --# Replace the old mesh, effectively deleting the effect.
            unitUnregistering:DeactivateTransparentCloakEffect()
        end
    end,
    
    --#*
    --#* This thread runs as long as there are units with a cloak effect on them.
    --#* It checks that the unit is still inside a cloak field and turns off
    --#* the cloak effect if they are not.
    --#**
    CloakEffectMonitorThread = function(self)
        
        --# Next block is for debugging only.  
        --# Delete when confident that code works.
        --LOG('ACU CloakEffectMonitorThread launched.')
      
        while self:IsAlive() do
            --# Unmark all units
            self:UnmarkRegisteredCloakEffectUnits()
            
            --# In the elapsed time we might have been marked 
            --# as being in a cloak feild
            WaitSeconds(self.CloakUpdatePeriod*2)
            
            --# We check and remove unmarked units 
            --# at half the frequency that units with cloak fields 
            --# will mark units as being cloaked.
            self:UnregisterUnmarkedCloakEffectUnits()
            
            --# Are there any units left to monitor?
            local numberOfUnitsStillInCloakField = 
                table.getsize(self.RegistrationTables['CloakEffectUnit'])
                
            --# Just for debugging, no side effects    
            --self:CloakEffectLog(repr(numberOfUnitsStillInCloakField) 
            --  .. ' units left after UnregisterUnmarkedCloakEffectUnits returned'
            --)
            
            --# Kill the thread if no units left to monitor
            if numberOfUnitsStillInCloakField < 1 then 
                self.CloakEffectMonitorThreadHandle = nil
                --LOG('ACU CloakEffectMonitorThread exiting.')
                return
            end
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Update the priority list used by the toggle on/off cycles.
    --#*  It mimicks a function table.removeByValue but also resets 
    --#*  priority indicators on the items so user can see what the new 
    --#*  priorities are.
    --#**
    UnmarkRegisteredCloakEffectUnits = function(self)
        --# Copy over items we are keeping from the old list to a new one
        for unusedArrayIndex, vCloakEffectUnit in self.RegistrationTables['CloakEffectUnit'] do
            vCloakEffectUnit.InCloakField = false
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Update the priority list used by the toggle on/off cycles.
    --#*  It mimicks a function table.removeByValue but also resets 
    --#*  priority indicators on the items so user can see what the new 
    --#*  priorities are.
    --#**
    UnregisterUnmarkedCloakEffectUnits = function(self)
        local unitsToUnregister = {}
        --# Copy over items we are keeping from the old list to a new one
        for unusedArrayIndex, vCloakEffectUnit in self.RegistrationTables['CloakEffectUnit'] do
            --# Check if any clean-up needed
            if not vCloakEffectUnit.InCloakField then
                --# Add it to the end of the new table
                table.insert(unitsToUnregister, vCloakEffectUnit)            
            end
        end
        --# Now we can do a bulk unregister now that we are not 
        --# traversing the table we will be removing items from.
        --# Consider making a bulk unrehsiter function for efficiency 
        --# so we have less table traverses than calling a delete on each table item.
        --# Maybe it is better to be able pass a list and a filter 
        --# function to another version of the unregister function?
        for unusedArrayIndex, vCloakEffectUnit in unitsToUnregister do
            --# Tell unit to update its mesh and we stop monitoring it
            self:ReceiveACUMessage_UnregisterUnit(vCloakEffectUnit, 'CloakEffectUnit') 
            if vCloakEffectUnit:IsAlive() and (not self.HasOwnCloakEnabled) then vCloakEffectUnit:UpdateCloakEffect() end
        end
    end,
    
    
    
    
    
    
    
--#-------------------------------------------------------------
--#  REGISTRATION SPECIFIC CODE
--#-------------------------------------------------------------

  
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by any units that need to 
    --#*  register with the ACU. This functionality
    --#*  automatically protects against redundant calls.
    --#** 
    ReceiveACUMessage_RegisterUnit = function(self, unitToRegisterArg, registrationCategory)
        --# Safety here to make sure table is instantiated
        if not self.RegistrationTables[registrationCategory] then 
            self.RegistrationTables[registrationCategory] = {}
        end
        --# Units are marked to avoid duplicate regsitrations
        local registrationFlag = 'IsRegisteredIn' .. registrationCategory .. 'Table'
        if unitToRegisterArg[registrationFlag] then return end
        unitToRegisterArg[registrationFlag] = true
        --# Put it in table of units to monitor
        table.insert(
            self.RegistrationTables[registrationCategory], 
            unitToRegisterArg
        )
        
        --# This is purely for debugging, it has no side effects.  
        self:RegistrationLog('Unit ' .. unitToRegisterArg.DebugId 
         .. ' registered to category ' .. registrationCategory)
         
        --# Give unit a reference to the category it registered under
        --# Units can regsiter in more than one category so make
        --# this a list.  Create list or add to existing one.
        if not unitToRegisterArg.UnregistrationData then
            unitToRegisterArg.UnregistrationData = {}
        end
        table.insert(unitToRegisterArg.UnregistrationData, registrationCategory)
        
        --# We need to make sure that unit has a function that
        --# uses its unregistration data to unregister and 
        --# that it references it from its Destroy function
        --# and throug an OnCaptured Callback to the old unit.
        if not unitToRegisterArg.UnregisterFromACU then
            --# Create the unregister function
            unitToRegisterArg.UnregisterFromACU = function(self)
                local myCommander = self:GetMyCommander() 
                if myCommander and myCommander:IsAlive() then 
                    for index, vCategory in self.UnregistrationData do
                        myCommander:ReceiveACUMessage_UnregisterUnit(self, vCategory)
                    end
                end
            end
            
            --# Now need to override its Destroy function.
            --# To override, first keep reference to original 
            unitToRegisterArg.OriginalDestroyFunction = unitToRegisterArg.Destroy
            --# Override the function here
            unitToRegisterArg.Destroy = function(self)
                self:UnregisterFromACU()
                --# Do what was there already
                self:OriginalDestroyFunction()
            end
            
            --# Finally, create a callback to unregister if the unit is captured
            unitToRegisterArg:AddOnCapturedCallback(unitToRegisterArg.UnregisterFromACU)
        end
        
        --# If we have any callbacks stored for this registration category 
        if self.OnRegisterCallbacks[registrationCategory] then
            --# Do the callback now.
            self.OnRegisterCallbacks[registrationCategory](self, unitToRegisterArg)
        end        
        
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by any units that 
    --#*  have registered with the ACU and now need to unregister.  
    --#*  This functionality automatically protects against redundant calls.
    --#** 
    ReceiveACUMessage_UnregisterUnit = function(self, unitToUnregisterArg, registrationCategory)
        --# Units are marked to avoid duplicate regsitrations
        local registrationFlag = 'IsRegisteredIn' .. registrationCategory .. 'Table'
        if not unitToUnregisterArg[registrationFlag] then return end
        unitToUnregisterArg[registrationFlag] = false
        --# Take the unit out of our table.
        self.RegistrationTables[registrationCategory] = 
            GilbotUtils.RemoveFromArrayByValue(self.RegistrationTables[registrationCategory], 
                                                unitToUnregisterArg, true)
        --# This is purely for debugging, it has no side effects.                   
        self:RegistrationLog('Unit ' .. unitToUnregisterArg.DebugId 
         .. ' unregistered from category ' .. registrationCategory)
        
        --# When it registered, we gave the unit a reference to 
        --# the category it registered under so it could call us back
        --# to unregister.  Now we can remove that reference if the unit is still
        --# alive and its unregister callbacks have yet to be called.       
        --# Units can regsiter in more than one category, so just 
        --# remove the entry, not the whole list!
        if unitToUnregisterArg:IsAlive() then
            unitToUnregisterArg.UnregistrationData= 
                GilbotUtils.RemoveFromArrayByValue(
                    unitToUnregisterArg.UnregistrationData, 
                    registrationCategory, 
                    true
                )
        end
        
        --# If we have any callbacks stored for this registration category 
        if self.OnUnregisterCallbacks[registrationCategory] then
            --# Do the callback now.
            self.OnUnregisterCallbacks[registrationCategory](self, unitToUnregisterArg)
        end 
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by auto-toggle units
    --#*  from their own class when created, to inform the ACU 
    --#*  so they can be used by the ACU's Auto Power-down.
    --#** 
    ReceiveACURequest_GetRegisteredUnitsInCategory = function(self, registrationCategory)
        --# Safety here which can be commented out or 
        --# deleted when the mod code is trusted as stable
        if not self.RegistrationTables[registrationCategory] then 
            WARN('No ACU registration table for category=' .. repr(registrationCategory))
            return nil
        else
            --# Return reference to the table
            --# which ought to be passed by value for integrity's sake
            --# but as we can't do that, just remember not to 
            --# add or remove anything from it directly!
            return self.RegistrationTables[registrationCategory]
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  For safety.
    --#** 
    RemoveReferencesToDeadUnitsFromRegistrationTable = function(self, registrationCategory)
        --# Its most efficient to rebuild a new table and reassign it
        --# rather than performing lots of deletes operations on the current one
        --# so we only have to make one pass. 
        local inspectedTable = {}
        for k, vUnit in self.RegistrationTables[registrationCategory] do
            if vUnit:IsAlive() then
                --# Keep this unit
                table.insert(inspectedTable, vUnit)
            else
                --# The unit is dead so it can't unregister.  
                --# All we have to do is remove our reference to it.
                --# Warm me for debugging purposes
                WARN('ACUCommon: ACU found dead unit ' ..  vUnit.DebugId 
                 .. ' in its ' .. registrationCategory .. '  registration table'
                )
            end
        end
        --# Copy over new 'clean' list of registered units
        self.RegistrationTables[registrationCategory] = inspectedTable
    end,
    

    
    
    
--#-------------------------------------------------------------
--#  ONSCREEN UNITS SPECIFIC CODE
--#-------------------------------------------------------------

  
  
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I added this to be called by auto-toggle units
    --#*  from their own class when destroyed or auto-toggle is toggled off, 
    --#*  to inform the ACU, so they won't be used anymore by the ACU's Auto Power-down.
    --#** 
    ReceiveACUMessage_SyncOnScreenUnitEntityList = function(self, cameraBoundsRectArg, zoomedOutTooFar)
        
        --# Reset the list of units onscreen
        for _, vEntry in self.UnitsOnScreenEntityList do
            vEntry.WithinCameraBoundsNow = false
        end
            
        --# If optional arg set, nothing gets display
        if not zoomedOutTooFar then 
            --# Use SIM function to get list of unit in camera bounds
            local unitList = GetUnitsInRect(cameraBoundsRectArg) or {}
            
            --# Update this list of entities registered.
            for _, vUnit in unitList do
                self.UnitsOnScreenEntityList[repr(vUnit:GetEntityId())] = 
                    {EntityId = vUnit:GetEntityId(), WithinCameraBoundsNow = true}
            end
        end
        
        --# Perform Sync
        self.Sync.UnitsOnScreenEntityList = self.UnitsOnScreenEntityList
    end,
}