--#****************************************************************************
--#**
--#**  Hook File:  /data/units/XSB1104/XSB1104_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Seraphim Mass Fabricator
--#**              Modded because its states were not consitent with my 
--#**              PauseableProductionUnit code.
--#**
--#****************************************************************************

local SMassFabricationUnit = import('/lua/seraphimunits.lua').SMassFabricationUnit

XSB1104 = Class(SMassFabricationUnit) {

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        self.Rotator = CreateRotator(self, 'Blades', 'y', nil, 0, 50, 0)
        self.Trash:Add(self.Rotator)
    end,

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This interface is defined in PauseableProductionUnit.
    --#*  It is overrided here to deal with unit specific 
    --#*  animation/effects associated with pausing/unpausing 
    --#*  mass production.
    --#**
    RunFrom_UnpausedState_Main = function(self)
        --# Just effects
        self.Rotator:SetSpinDown(false)
        self.Rotator:SetTargetSpeed(180)
    end,

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This interface is defined in PauseableProductionUnit.
    --#*  It is overrided here to deal with unit specific 
    --#*  animation/effects associated with pausing/unpausing 
    --#*  mass production.
    --#**
    RunFrom_PausedState_Main = function(self)
        --# Call base class version 
        --# Code in PauseableProductionUnit will execute.
        self.Rotator:SetSpinDown(true)
        WaitFor(self.Rotator)
    end,
              
}

TypeClass = XSB1104