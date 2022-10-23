do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /units/XRB3301/XRB3301_script.lua
--#**  Author(s):  Eni
--#**
--#**  Summary  :  Cybran Vision unit thing
--#**
--#****************************************************************************

local oldXRB3301 = XRB3301
XRB3301 = Class(oldXRB3301) {   
 
    --#*
    --#*  A non-destructive override 
    --#*  that adds initialisation.
    --#*  Totally safe.
    --#**
    OnCreate = function(self)
    	oldXRB3301.OnCreate(self)
		self.MaxVisionRadius = self:GetBlueprint().Intel.MaxVisionRadius
		self.MinVisionRadius = self:GetBlueprint().Intel.MinVisionRadius
    end, 
    
    --#*
    --#*  A non-destructive override 
    --#*  that just adds thread management.
    --#*  Totally safe.
    --#**
    OnIntelEnabled = function(self)
        self.OvertimeXPThread = ForkThread(self.startBuildXPThread, self)
        oldXRB3301.OnIntelEnabled(self)
    end,

    --#*
    --#*  A non-destructive override 
    --#*  that just adds thread management.
    --#*  Totally safe.
    --#**
    OnIntelDisabled = function(self)
        if self.OvertimeXPThread then 
            KillThread(self.OvertimeXPThread) 
            self.OvertimeXPThread = nil
        end
        oldXRB3301.OnIntelDisabled(self)
    end,
    
    ExpandingVision = State {
        Main = function(self)
            WaitSeconds(0.1)
            while true do
                if self:GetResourceConsumed() ~= 1 then
                    self.ExpandingVisionEnergyCheck = true
                    self:OnIntelDisabled()
                end
                local curRadius = self:GetIntelRadius('vision')
                --# This next line is the only line changed
                local targetRadius = self.MaxVisionRadius
                if curRadius < targetRadius then
                    curRadius = curRadius + 1
                    if curRadius >= targetRadius then
                        self:SetIntelRadius('vision', targetRadius)
                    else
                        self:SetIntelRadius('vision', curRadius)
                    end
                end
                WaitSeconds(0.2)
            end
        end,
    },
    
    ContractingVision = State {
        Main = function(self)
            while true do
                if self:GetResourceConsumed() == 1 then
                    if self.ExpandingVisionEnergyCheck then
                        self:OnIntelEnabled()
                    else
                        self:OnIntelDisabled()
                        self.ExpandingVisionEnergyCheck = true
                    end
                end
                local curRadius = self:GetIntelRadius('vision')
                --# This next line is the only line changed
                local targetRadius = self.MinVisionRadius
                if curRadius > targetRadius then
                    curRadius = curRadius - 1
                    if curRadius <= targetRadius then
                        self:SetIntelRadius('vision', targetRadius)
                    else
                        self:SetIntelRadius('vision', curRadius)
                    end
                end
                WaitSeconds(0.2)
            end
        end,
    },
}

TypeClass = XRB3301
end--(of non-destructive hook)