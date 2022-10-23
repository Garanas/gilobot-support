do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/UEL0401/UEL0401_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the UEF T4 Fatboy
--#**
--#****************************************************************************

PreviousVersion = UEL0401
UEL0401 = Class(PreviousVersion) {

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  In FA, this normally would eject any unit without orders.
    --#*  Now units are ejected and told to guard their mobile factory.
    --#**
    DestroyRollOffEffects = function(self)
       PreviousVersion.DestroyRollOffEffects(self)
       --# This is the added code
       if not self.UnitBeingBuilt:IsDead() then
           IssueGuard({self.UnitBeingBuilt}, self)
       end
   end,

}

TypeClass = UEL0401


end --(of non-destructive hook)