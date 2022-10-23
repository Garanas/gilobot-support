do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /units/XEA0002/XEA0002_script.lua
--#**
--#**  Modded By :  Eni, Gilbot-X
--#**
--#**  Summary   :  UEF Defense Satelite Script
--#**
--#****************************************************************************
local PreviousVersion = XEA0002
XEA0002 = Class(PreviousVersion) {
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I changed this as my mod does
    --#*  not use self.Parent.
    --#**
    AddXP = function(self,amount)
        --# Call parent's AddXP if it exists
        if self.Parent and self.Parent.AddXP then
            self.Parent:AddXP(amount)
        end
        PreviousVersion.AddXP(self,amount)
    end,
}
TypeClass = XEA0002
end--(of non-destructive hook)