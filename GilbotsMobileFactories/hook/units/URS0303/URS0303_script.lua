do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/URS0303/URS0303_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Cybran T3 Aircraft Carrier
--#**
--#****************************************************************************

PreviousVersion = URS0303
URS0303 = Class(PreviousVersion) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  In FA, this normally would store all new units
    --#*  and eject any unit if no storage was available.
    --#*  Now units are ejected and told to guard their
    --#*  mobile factory if a toggle is set on the factory.
    --#**
    FinishedBuildingState = State {
        Main = function(self)
            --# This is FA code
            self:SetBusy(true)
            local unitBuilding = self.UnitBeingBuilt
            unitBuilding:DetachFrom(true)
            self:DetachAll(self.BuildAttachBone)
            
            --# Next line added
            if self:GetScriptBit('RULEUTC_ProductionToggle') == true 
            and self:TransportHasAvailableStorage() then
                self:AddUnitToStorage(unitBuilding)
            else
                local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
                IssueMoveOffFactory({unitBuilding}, worldPos)
                --# Line added
                IssueGuard({unitBuilding}, self)
                unitBuilding:ShowBone(0,true)
            end
            self:SetBusy(false)
            self:RequestRefreshUI()
            ChangeState(self, self.IdleState)
        end,
    },
}

TypeClass = URS0303

end --(of non-destructive hook)