do--(start of non-destructive hook)
local oldSConstructionUnit = SConstructionUnit
SConstructionUnit = Class(oldSConstructionUnit) {

    --# This was hooked because FA's SConstructionUnit uses
    --# a destructive hook for this fuction.  
    --# GPG  please stop hiring amateur programmers!
 	OnStartBuild = function(self, unitBeingBuilt, order)
 		self.BuildXPThread = ForkThread(self.startBuildXPThread, self)
        oldSConstructionUnit.OnStartBuild(self, unitBeingBuilt, order)
    end,
}
end--(of non-destructive hook)