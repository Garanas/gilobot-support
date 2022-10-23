--#****************************************************************************
--#**
--#**  Hook File:  /units/URB1104/URB1104_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran Mass Fabricator
--#**              Modded because my autotoggle code was shutting 
--#**              off the unit before it had a chance to create its rotator.
--#**
--#****************************************************************************
local CMassFabricationUnit = import('/lua/cybranunits.lua').CMassFabricationUnit

URB1104 = Class(CMassFabricationUnit) {
    DestructionPartsLowToss = {'Blade',},

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        self.Rotator = CreateRotator(self, 'Blade', 'z')
        self.Trash:Add(self.Rotator)
        self.Rotator:SetAccel(40)
        self.Rotator:SetTargetSpeed(150)
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
        --# Spin when activated
        self.Rotator:SetTargetSpeed(150)
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
        --# Just effects: Stop spinning when switched off
        if self.Rotator then self.Rotator:SetTargetSpeed(0) end
    end,
}

TypeClass = URB1104