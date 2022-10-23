do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/aeonweapons.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Default definitions of Aeon weapons.
--#**              I modded thsi because there were errors in line 87
--#**              when the ADFTractorClaw weapon called to AttachBoneTo.
--#**              I added a check to make sure the unit we are trying 
--#**              to attach has not been destroyed.
--#**
--#**  Note: 441 lines in original file so if you get an error 
--#**  subtract 441 from the line number it gives you to find 
--#**  where it is in this hook file
--#**
--#****************************************************************************

local PreviousVersion = ADFTractorClaw
ADFTractorClaw = Class(PreviousVersion) {

    TractorThread = function(self, target)
        self.unit.Trash:Add(target)
        local beam = self.Beams[1].Beam
        if not beam then return end


        local muzzle = self:GetBlueprint().MuzzleSpecial
        if not muzzle then return end


        local pos0 = beam:GetPosition(0)
        local pos1 = beam:GetPosition(1)

        local dist = VDist3(pos0, pos1)

        self.Slider = CreateSlider(self.unit, muzzle, 0, 0, dist, -1, true)

        
        
        
        WaitFor(self.Slider)
        --# I added this to try and prevent some script errors.
        --# I added this to try and prevent some script errors.
        if self.unit:BeenDestroyed() then 
            WARN('ADFTractorClaw: self.unit:BeenDestroyed')
            return 
        end
        --# I added this to try and prevent some script errors.
        if target:BeenDestroyed() then 
            WARN('ADFTractorClaw: target:BeenDestroyed')
            return 
        end
         --# I added this to try and prevent some script errors.
        if self.unit:IsDead() then 
            WARN('ADFTractorClaw: self.unit:IsDead')
            return 
        end
        --# I added this to try and prevent some script errors.
        if target:IsDead() then 
            WARN('ADFTractorClaw: target:IsDead')
            return 
        end
 
 
 
 
        --# This kept creating errors.
        target:AttachBoneTo(-1, self.unit, muzzle)
        
        self.AimControl:SetResetPoseTime(10)
        target:SetDoNotTarget(true)

        self.Slider:SetSpeed(15)
        self.Slider:SetGoal(0,0,0)

        
        
        
        WaitFor(self.Slider)
        --# I added this to try and prevent some script errors.
        if self.unit:BeenDestroyed() then 
            WARN('ADFTractorClaw: self.unit:BeenDestroyed')
            return 
        end
        --# I added this to try and prevent some script errors.
        if target:BeenDestroyed() then 
            WARN('ADFTractorClaw: target:BeenDestroyed')
            return 
        end
         --# I added this to try and prevent some script errors.
        if self.unit:IsDead() then 
            WARN('ADFTractorClaw: self.unit:IsDead')
            return 
        end
        --# I added this to try and prevent some script errors.
        if target:IsDead() then 
            WARN('ADFTractorClaw: target:IsDead')
            return 
        end
        
        
        
        
        if not target:IsDead() then
            target:Kill()
        end
        self.AimControl:SetResetPoseTime(2)
    end,
}



end --(of non-destructive hook)