--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/enhancementqueue.lua
--#**
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Allows units to queue enhancement orders.
--#**
--#****************************************************************************


--#*
--#*  Gilbot-X says:  
--#*
--#*  This is for debugging
--#**   
function EnhanceQueueLog(message)
    local debugEnhanceQueue = false
    if debugEnhanceQueue then 
        LOG('Gilbot: EnhanceQueue: ' .. message) 
    end
end


--#*
--#*  Gilbot-X:
--#*
--#*  This is USER state code, not SIM state.
--#*  I added this so that I can apply a series of enhancements 
--#*  in a queue on any single unit or group of units.  
--#**
function UserQueueEnhancement(unitArg, enhancementArg, slotArg)

    --# Cache this as we will use it many times
    local entityId = unitArg:GetEntityId()

    --# Invoke sim side code to add this 
    --# enhancement to the unit's enhancement queue
    SimCallback( 
      {  
        Func='AddEnhancementToQueue',
        Args={ 
          SelectedUnitEntityId= entityId,
          Enhancement = enhancementArg,
          Slot = slotArg,
        }
      }
    )
    
    ForkThread(
        function()
            --# Give time for a sync to take place
            WaitSeconds(1)
            
            --# Only proceed if we can sync back 
            --# data from SIM side to USER side   
            if  UnitData[entityId] 
            and UnitData[entityId].EnhancementQueue then
            
                --# Iterate through EnhancementQueue data from SIM side       
                for k, vEntry in UnitData[entityId].EnhancementQueue do
                    if vEntry.Status == 'Command Not Yet Issued' then
                        --# I added these next 2 lines from GOOM's SCU manager code
                        --# so that orders are queued and do not block or cancel each other.
                        local commandmode = import('/lua/ui/game/commandmode.lua')
                        local currentCommand = commandmode.GetCommandMode()
                        --# Original GPG code
                        local orderData = {
                            TaskName = "EnhanceTask",
                            Enhancement = vEntry.Enhancement,
                        }
                        --# Original GPG code.  This order will only work if the enhancement
                        --# was successfully added to the unit's enhancement queue.                 
                        IssueUnitCommand({unitArg}, "UNITCOMMAND_Script", orderData, false)
                        --# I added this next line from GOOM's SCU manager code,
                        --# so that orders are queued and do not block or cancel each other.
                        commandmode.StartCommandMode(currentCommand[1], currentCommand[2])
                        --# Update status (Invoke sim side code to do this) 
                        SimCallback( 
                          {  
                            Func='UpdateQueueStatus',
                            Args={ 
                              SelectedUnitEntityId= entityId,
                              Enhancement = vEntry.Enhancement,
                              Slot = slotArg,
                            }
                          }
                        )
                    end
                end
            
            else
                WARN('No sync data found for unit ' .. unitArg:GetUnitId() 
                 .. ' e=' .. entityId
                )
            end
        end
    )
end



--#*
--#*  Gilbot-X says:  
--#*
--#*  This function is called by the one above
--#*  and actually queues the enhancement.
--#**
local QueueEnhancement = function(self, enhancementArg, slotArg)

    --# We will use this a lot so cache it
    local bpEnhancement = self:GetBlueprint().Enhancements[enhancementArg]
  
    --# We are going to queue this enhancement.
    EnhanceQueueLog('QueueEnhancement: Unit ' .. self.DebugId
    .. ' will apply enhancement ' .. repr(bpEnhancement.Name)
    .. ' in slot=' .. repr(bpEnhancement.Slot)
    )
    
    --# If we are already doing something them we may need to stop first
    if table.getsize(self.EnhancementQueue) < 1 then
        --EnhanceQueueLog('QueueEnhancement: This is first entry in the queue for ' .. self.DebugId)
        --# Need to get rid of any old commands if not already enhancing.
        if not (self:IsUnitState('Enhancing') or self:IsUnitState('Upgrading') 
             or self:IsIdleState()) then 
            --EnhanceQueueLog('QueueEnhancement: Issuing stop on ' .. self.DebugId)
            IssueStop({self})
            IssueClearCommands({self})
        else
            --EnhanceQueueLog('QueueEnhancement: Stop command not required on ' .. self.DebugId)
        end
    end
    
    --# I moved this over from unit.lua
    AddUnitEnhancement(self, enhancementArg, slotArg)
    --# Moved next line to construction.lua
    if bpEnhancement.RemoveEnhancements then
        for k, v in bpEnhancement.RemoveEnhancements do
            RemoveUnitEnhancement(self, v)
            EnhanceQueueLog('QueueEnhancement: Removing ' .. v)
        end
    end
    --# Need to do this so we can see which buttons 
    --# are set or unset without closing and opening menu
    self:RequestRefreshUI()
    
    --# Add this to the list so we can undo the button
    --# in the unit's enhancement menu if building does not complete
    table.insert(self.EnhancementQueue, 
        {Enhancement = enhancementArg, Status='Command Not Yet Issued'})
        
    --# Do a sync now so user code can read it
    self.Sync.EnhancementQueue = self.EnhancementQueue
end

    
--#*
--#*  Gilbot-X says:  
--#*
--#*  This function examines the enhancement
--#*  requested and decides if it is to be queued
--#*  on this unit, which depends on what it 
--#*  already has.
--#**
function AddEnhancementToQueueCallback(data)

    --# Do this to make code like 
    --# a function in the unit class
    local self = GetEntityById(data.SelectedUnitEntityId)
    
    --# Get the BP for the 'target' enhancement we are trying to issue
    local bpTargetEnhancement = self:GetBlueprint().Enhancements[data.Enhancement]
     --# Get any Prerequisites for this target enhancement
    local targetPrereq1, targetPrereq2 = bpTargetEnhancement.Prerequisite, nil
    if targetPrereq1 then 
        targetPrereq2 = 
            self:GetBlueprint().Enhancements[targetPrereq1].Prerequisite
    end
    
    --# The enhancementButtonsSet table tells you which buttons are set, 
    --# not which enhancements are active.  Find out what is already set
    --# and what their prerequisites are.  We do not want to apply
    --# inferior enhancements in an upgarde path we already started.   
    local enhancementButtonsSet = import('/lua/enhancementcommon.lua').GetEnhancements(data.SelectedUnitEntityId)
    local buttonInThisSlot = enhancementButtonsSet[bpTargetEnhancement.Slot]
    local buttonInThisSlotBP = self:GetBlueprint().Enhancements[buttonInThisSlot]
    local buttonInThisSlotCannotDowngrade = buttonInThisSlotBP.CannotDowngradeToPrerequisites
    --# Get any Prerequisites for Current Enhancement buton in the slot
    local buttonInThisSlotPreReq1, buttonInThisSlotPreReq2 =  
        buttonInThisSlotBP.Prerequisite, nil
    if buttonInThisSlotPreReq1 then 
        buttonInThisSlotPreReq2 = 
            self:GetBlueprint().Enhancements[buttonInThisSlotPreReq1].Prerequisite 
    end
   
    --# Is the slot for this enhancement empty?
    if not buttonInThisSlot then
        --# If the target enhancement has a prerequisite
        if targetPrereq1 then
            --# The prerequisite is not there because nothing is there, then
            if targetPrereq2 then 
                --# Queue the Prerequisite
                QueueEnhancement(self, targetPrereq2, bpTargetEnhancement.Slot)
            end
             --# Queue the Prerequisite
            QueueEnhancement(self, targetPrereq1, bpTargetEnhancement.Slot)
        end
        --# Queue the target
        QueueEnhancement(self, data.Enhancement, bpTargetEnhancement.Slot)
    
    --# An upgrade path was already started on this unit
    --# in this slot.  There are three possible actions:
    --# add enhancement onto path, replace path, or ignore.
    else
        --# If the enhancement requested is (or is a 
        --# prerequisite of) the enhancement already there
        --# then it is in the same upgrade path but it 
        --# is not a follow-on from what is already there..
        if (buttonInThisSlot == data.Enhancement) or 
           (buttonInThisSlotCannotDowngrade and 
                (           
                   (buttonInThisSlotPreReq1 == data.Enhancement) 
                or (buttonInThisSlotPreReq2 == data.Enhancement)
                )
            )
        then
            --# so do nothing because we would be downgrading unecessarily
            EnhanceQueueLog('AddEnhancementToQueueCallback: Unit ' .. self.DebugId
            .. ' will not apply enhancement ' .. repr(bpTargetEnhancement.Name)
            .. ' because it already has ' .. repr(enhancementButtonsSet[bpTargetEnhancement.Slot])
            .. ' in slot=' .. repr(bpTargetEnhancement.Slot)
            )
            --# Do a sync now anyway because the sync will be read
            --# on this unit next and there may have been other
            --# updates made elsewhere
            self.Sync.EnhancementQueue = self.EnhancementQueue
            return
        --# Is the target enhancement the immediate follow-on in 
        --# the upgrade path already started?    
        elseif targetPrereq1 == buttonInThisSlot then
            QueueEnhancement(self, data.Enhancement, bpTargetEnhancement.Slot)
        --# We are the highest upgarde in the path and 
        --# the button active is the first.  We need to apply
        --# the second in the path first.
        elseif targetPrereq2 == buttonInThisSlot then
            QueueEnhancement(self, targetPrereq1, bpTargetEnhancement.Slot)
            QueueEnhancement(self, data.Enhancement, bpTargetEnhancement.Slot)
        --# Otherwise there is an upgrade from another path 
        --# in that slot and the player might want to swap it.
        --# We can issue the enhancemwent but we must clear 
        --# the slot first by isuing a remove task on it.
        else
            --# Queue a slot removal
            QueueEnhancement(self, enhancementButtonsSet[bpTargetEnhancement.Slot]..'Remove', bpTargetEnhancement.Slot)
            --# Queue any Prerequisite of any Prerequisite
            if targetPrereq2 then
                QueueEnhancement(self, targetPrereq2, bpTargetEnhancement.Slot)
            end
            --# Queue any Prerequisite
            if targetPrereq1 then
                QueueEnhancement(self, targetPrereq1, bpTargetEnhancement.Slot)
            end
            --# Queue target
            QueueEnhancement(self, data.Enhancement, bpTargetEnhancement.Slot)
        end
    end
end


--#*
--#*  Gilbot-X says:  
--#*
--#*  This function examines the enhancement
--#*  requested and decides if it is to be queued
--#*  on this unit, which depends on what it 
--#*  already has.
--#**
function UpdateQueueStatusCallback(data)

    --# Do this to make code like 
    --# a function in the unit class
    local self = GetEntityById(data.SelectedUnitEntityId)
    
    --# Go through Queue starting with oldest
    --# and first to execute.  When we find rhe first entry
    --# that matches this enhancement that has not 
    --# already been marked as having the command issued,
    for kArrayIndex, vEntry in self.EnhancementQueue do
        if vEntry.Enhancement == data.Enhancement and 
           vEntry.Status == 'Command Not Yet Issued' 
        then
            --# Mark it and exit.
            vEntry.Status = 'Command Has Been Queued'
            --[[
            --# Debugging
            EnhanceQueueLog('UpdateQueueStatusCallback: ' 
              .. ' Entry was updated for ' .. self.DebugId 
              .. ' on enhancement ' .. repr(data.Enhancement)
            )
            EnhanceQueueLog('UpdateQueueStatusCallback: EnhancementQueue=' 
              .. repr(self.EnhancementQueue)
            )]]
            --# Do a sync now so user code can read it
            self.Sync.EnhancementQueue = self.EnhancementQueue
            return
        end
    end
    
    --# Sometimes get here if work started on a 
    --# enhancement before we marked it.
    EnhanceQueueLog('UpdateQueueStatusCallback: ' 
      .. ' No entry was updated for ' .. self.DebugId 
      .. ' on enhancement ' .. repr(data.Enhancement)
    )
    EnhanceQueueLog('UpdateQueueStatusCallback: ' 
      .. repr(self.EnhancementQueue)
    )
end