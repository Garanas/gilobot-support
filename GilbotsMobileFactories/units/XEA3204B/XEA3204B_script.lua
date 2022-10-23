--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/XEA3204B/XEA3204B_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF Engineering Assist Pod Script
--#**
--#****************************************************************************
local TConstructionUnit = import('/lua/terranunits.lua').TConstructionUnit

XEA3204B = Class(TConstructionUnit) {

    OnCreate = function(self)
        TConstructionUnit.OnCreate(self)
        self.docked = true
        self.returning = false
    end,

    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.PodName = podName
        self:SetCreator(parent)
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.Parent and not self.Parent:IsDead() then
            self.Parent:NotifyOfPodDeath(self.PodName)
            self.Parent = nil
        end
        TConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    OnStartBuild = function(self, unitBeingBuilt, order )
        TConstructionUnit.OnStartBuild(self, unitBeingBuilt, order )
        self.returning = false
    end,    
    OnStopBuild = function(self, unitBuilding)
        TConstructionUnit.OnStopBuild(self, unitBuilding)
        self.returning = true
    end,
    OnFailedToBuild = function(self)
        TConstructionUnit.OnFailedToBuild(self)
        self.returning = true
    end,
    OnMotionHorzEventChange = function( self, new, old )
        if self and not self:IsDead() then
            if self.Parent and not self.Parent:IsDead() then
                local myPosition = self:GetPosition()
                local parentPosition = self.Parent:GetPosition(self.Parent.PodData[self.PodName].PodAttachpoint)
                local distSq = VDist2Sq(myPosition[1], myPosition[3], parentPosition[1], parentPosition[3])
                if self.docked and distSq > 0 and not self.returning then
                    self.docked = false
                    self.Parent:ForkThread(self.Parent.NotifyOfPodStartBuild)
                    --#LOG("Leaving dock! " .. distSq)
                elseif not self.docked and distSq < 1 and self.returning then
                    self.docked = true
                    self.Parent:ForkThread(self.Parent.NotifyOfPodStopBuild)
                    --#LOG("Docked again " .. distSq)
                end
            end
        end
    end,

}

TypeClass = XEA3204B