do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/UAS0401/UAS0401_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Aeon Tempest
--#**
--#****************************************************************************

PreviousVersion = UAS0401
UAS0401 = Class(PreviousVersion) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  In FA, this normally would eject any unit without orders.
    --#*  Now units are ejected and told to guard their mobile factory.
    --#**
    FinishedBuildingState = State {
        Main = function(self)
            --# This is FA code
            self:SetBusy(true)
            local unitBuilding = self.UnitBeingBuilt
            unitBuilding:DetachFrom(true)
            self:DetachAll(self.BuildAttachBone)
            local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
            IssueMoveOffFactory({unitBuilding}, worldPos)
            --# Next Line added
            IssueGuard({unitBuilding}, self)
            self:SetBusy(false)
            self:RequestRefreshUI()
            ChangeState(self, self.IdleState)
        end,
    },
}

TypeClass = UAS0401

end --(of non-destructive hook)