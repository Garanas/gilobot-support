--#****************************************************************************
--#**
--#**  Hook File:  /data/units/UEB1104/UEB1104_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  UEF Mass Fabricator
--#**              Modded because its states were not consitent with my 
--#**              PauseableProductionUnit code.
--#**              90 Lines in original file.
--#**
--#****************************************************************************

local TMassFabricationUnit = import('/lua/terranunits.lua').TMassFabricationUnit

UEB1104 = Class(TMassFabricationUnit) {

    DestructionPartsLowToss = {'B01','B02',},
    DestructionPartsChassisToss = {'UEB1104'},

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        --# This was in the FA code.  I just moved it here 
        --# to conform with my code interface.
        self.SliderManip = CreateSlider(self, 'B03')
        self.NeedsCreateStateFirst = true
        self.Closed = false
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This was in the FA code.
    --#**
    CreateState = State {
        Main = function(self)
            --# This unit's default position is open,
            --# so we have to hide the bone, close the unit,
            --# and then show the bone once its in its closed position.
            self:HideBone('UEB1104', true)        
            self.SliderManip:SetGoal(0,-1,0)     
            self.SliderManip:SetSpeed(-1)         
            WaitFor(self.SliderManip)
            self:ShowBone('UEB1104', true)
            self.Closed = true
            self.NeedsCreateStateFirst = false
            ChangeState(self, self.BeforeCreateStateCalled)
        end,
    },

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  This interface is defined in PauseableProductionUnit.
    --#*  It is overrided here to deal with unit specific 
    --#*  animation/effects associated with pausing/unpausing 
    --#*  mass production.
    --#**
    RunFrom_UnpausedState_Main = function(self)
        if self.NeedsCreateStateFirst then 
            self.BeforeCreateStateCalled = self.UnpausedState
            ChangeState(self, self.CreateState) 
        else
            --# Play the "activate" sound
            local myBlueprint = self:GetBlueprint()
            if myBlueprint.Audio.Activate then
                self:PlaySound(myBlueprint.Audio.Activate)
            end

            --# Initiate the unit's ambient movement sound
            self:PlayUnitAmbientSound( 'ActiveLoop' )

            self.SliderManip:SetGoal(0,0,0)
            self.SliderManip:SetSpeed(3)
            --# Next line creates problem
            WaitFor(self.SliderManip)
        end
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
        if self.NeedsCreateStateFirst then 
            self.BeforeCreateStateCalled = self.PausedState
            ChangeState(self, self.CreateState) 
        else       
            --# Just effects
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self.SliderManip:SetGoal(0,-1,0)
            self.SliderManip:SetSpeed(3)
            WaitFor(self.SliderManip)
        end
    end,

}

TypeClass = UEB1104