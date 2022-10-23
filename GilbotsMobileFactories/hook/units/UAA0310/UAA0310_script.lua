do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/UAA0310/UAA0310_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Aeon Czar.
--#**
--#****************************************************************************

PreviousVersion = UAA0310
UAA0310 = Class(PreviousVersion) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Makes the Czar rotate.
    --#**
   OnStopBeingBuilt = function(self,builder,layer)
       self.Rotator1 = CreateRotator(self, 'UAA0310', 'y', nil, 0, 2, 4)
       PreviousVersion.OnStopBeingBuilt(self,builder,layer)
   end,
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Stops the Czar's rotation when it is killed.
    --#**
   OnKilled = function(self, instigator, type, overkillRatio)
       if self.Rotator1 then self.Rotator1:SetTargetSpeed(0) end
       PreviousVersion.OnKilled(self, instigator, type, overkillRatio)
   end,
   
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
           
           --# Added next line for toggle
           if self:GetScriptBit('RULEUTC_ProductionToggle') == true 
            and self:TransportHasAvailableStorage() then
               self:AddUnitToStorage(unitBuilding)
           else
               local worldPos = self:CalculateWorldPositionFromRelative({0, 0, -20})
               IssueMoveOffFactory({unitBuilding}, worldPos)
               --# Added this line
               IssueGuard({unitBuilding}, self)
               unitBuilding:ShowBone(0,true)
           end
           self:SetBusy(false)
           self:RequestRefreshUI()
           ChangeState(self, self.IdleState)
       end,
   },

}

TypeClass = UAA0310


end --(of non-destructive hook)