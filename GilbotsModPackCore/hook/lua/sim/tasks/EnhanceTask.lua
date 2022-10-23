do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/sim/tasks/enhancetask.lua
--#**
--#**  Summary  :  Enhancements
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Changes  : 
--#**    Modded so that some arial units can begin enhancement while 
--#**    drifting but not fully stopped.  Also to prevent crashes
--#**    if there is an error spotted in enhancement queuing.
--#**    
--#****************************************************************************

local ScriptTask = import('/lua/sim/ScriptTask.lua').ScriptTask
local TASKSTATUS = import('/lua/sim/ScriptTask.lua').TASKSTATUS
local AIRESULT = import('/lua/sim/ScriptTask.lua').AIRESULT

EnhanceTask = Class(ScriptTask) {
    OnCreate = function(self,commandData)
        ScriptTask.OnCreate(self,commandData)
        self:GetUnit():SetWorkProgress(0.0)
        self:GetUnit():SetUnitState('Enhancing',true)
        self:GetUnit():SetUnitState('Upgrading',true)
        self.LastProgress = 0
        ChangeState(self, self.Stopping)
    end,
    
    OnDestroy = function(self)
        self:GetUnit():SetUnitState('Enhancing',false)
        self:GetUnit():SetUnitState('Upgrading',false)
        self:GetUnit():SetWorkProgress(0.0)
        if self.Success then
            self:SetAIResult(AIRESULT.Success)
        else
            self:SetAIResult(AIRESULT.Fail)
            self:GetUnit():OnWorkFail(self.CommandData.Enhancement)
        end
    end,
    
    --# Gilbot-X: I only changed this State
    Stopping = State {
        TaskTick = function(self)
            local unit = self:GetUnit()

            if (not unit.EnhanceEvenIfMoving) 
              and unit:IsMobile() and unit:IsMoving() then
                unit:GetNavigator():AbortMove()
                --# Gilbot: I added this block.
                if unit.IsSlowToStartEnhancing then 
                    if not unit.RecordedSpeedOnLastTick then 
                        unit.RecordedSpeedOnLastTick = true
                        local currentPosition = unit:GetPosition()
                        local x, y, z = unpack(currentPosition)
                        unit.LastDriftPosition={x=x, y=y, z=z}
                        unit.TicksWaitedToEnhance = 0
                    else
                        if unit.TicksWaitedToEnhance >= 5 then
                            unit.TicksWaitedToEnhance = 0
                            --# Work out how far we moved since last tick
                            local currentPosition = unit:GetPosition()
                            local lastposition = Vector(
                                unit.LastDriftPosition.x,
                                unit.LastDriftPosition.y,
                                unit.LastDriftPosition.z
                            )
                            local separation = VDist3(lastposition, currentPosition) 
                            --LOG('Separation=' .. repr(separation))
                            if separation < 0.05 then 
                                unit.EnhanceEvenIfMoving = true
                            else
                                local x, y, z = unpack(currentPosition)
                                unit.LastDriftPosition={x=x, y=y, z=z}
                            end
                        else
                            --Increment number of ticks waited
                            unit.TicksWaitedToEnhance = unit.TicksWaitedToEnhance + 1
                        end                        
                    end
                    
                end
                return TASKSTATUS.Wait
            else
                --# Gilbot: I added this block.
                if unit.IsSlowToStartEnhancing then
                    unit.RecordedSpeedOnLastTick = false
                    unit.EnhanceEvenIfMoving = false
                    unit.LastDriftPosition = nil
                end
                --# Added a test so that it aborts on failure
                if unit:OnWorkBegin(self.CommandData.Enhancement) then
                    ChangeState(self, self.Enhancing)
                    return TASKSTATUS.Repeat
                else
                    --# Give up
                    return TASKSTATUS.Done
                end
            end
        end,
    },
    
    Enhancing = State {
        TaskTick = function(self)
            local unit = self:GetUnit()
            if unit:IsPaused() then
                return TASKSTATUS.Wait
            end
            
            local current = unit.WorkProgress
            
            local obtained = unit:GetResourceConsumed()
            if obtained > 0 then
                local frac = ( 1 / ( unit.WorkItemBuildTime / unit:GetBuildRate()) ) * obtained * SecondsPerTick()
                current = current + frac
                unit.WorkProgress = current
            end
            
            if( ( self.LastProgress < 0.25 and current >= 0.25 ) or
                ( self.LastProgress < 0.50 and current >= 0.50 ) or
                ( self.LastProgress < 0.75 and current >= 0.75 ) ) then
                unit:OnBuildProgress(self.LastProgress,current)
            end
            
            self.LastProgress = current
            unit:SetWorkProgress(current)
            
            if( current < 1.0 ) then
                return TASKSTATUS.Wait
            end
            
            unit:OnWorkEnd(self.CommandData.Enhancement)
            self.Success = true

            return TASKSTATUS.Done            
        end,
    },
}

end--(of non-destructive hook)