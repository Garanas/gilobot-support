do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/UES0401/UES0401_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the UEF T4 Sub Aircraft Carrier
--#**
--#****************************************************************************

PreviousVersion = UES0401
UES0401 = Class(PreviousVersion) {

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

            --# This was written by 4th dimension
            --# If the "store new units" button is set and 
            --# there is still transport storage available...
            if self:GetScriptBit('RULEUTC_ProductionToggle') == true and self:TransportHasAvailableStorage() then
                --# Store aircraft if space avalible and player selected not to auto guard
                self:AddUnitToStorage(unitBuilding)
            --# If it is not set and we are on the water's surface...
            elseif self:GetScriptBit('RULEUTC_ProductionToggle') == false and self:GetCurrentLayer() == 'Water' then
                --# Assign aircraft to guard only if carrier above water and auto guard selected
                local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
                IssueMoveOffFactory({unitBuilding}, worldPos)
                --# Next line added
                IssueGuard({unitBuilding}, self)
                unitBuilding:ShowBone(0,true)

            elseif self:TransportHasAvailableStorage() then
                --# Store aircraft if space avalible
                self:AddUnitToStorage(unitBuilding)

            --# There is no transport storage left.
            elseif self:GetCurrentLayer() == 'Water' then
                --# Assign aircraft to guard only if carrier is above water
                local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
                IssueMoveOffFactory({unitBuilding}, worldPos)
                IssueGuard({unitBuilding}, self)
                unitBuilding:ShowBone(0,true)
            else
                --# If the carrier is underwater and has 
                --# no room for the new unit, destoy it.
                unitBuilding:Destroy()
            end
            self:SetBusy(false)
            self:RequestRefreshUI()
            ChangeState(self, self.IdleState)
        end,
    },
}

TypeClass = UES0401


end --(of non-destructive hook)