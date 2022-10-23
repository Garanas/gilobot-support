--#****************************************************************************
--#**
--#**  Hook File:  /units/UAB1104/UAB1104_script.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Aeon Mass Fabricator
--#**              This can be made into an autopack unit.
--#**              Modded because my autotoggle code was shutting 
--#**              off the unit before it had a chance to create its rotator.
--#**
--#****************************************************************************

local AMassFabricationUnit = import('/lua/aeonunits.lua').AMassFabricationUnit

UAB1104 = Class(AMassFabricationUnit) {

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Code that will be done after the unit 
    --#*  has been built but before the first state is changed
    --#*  in a structure unit that uses states.
    --#**
    DoBeforeAnyStateChanges = function(self)
        --# Gilbot-X:  
        --# I moved some lines of FA code here because
        --# autotoggle was shutting off the unit before it
        --# had a chance to create its rotator.
        self.Damaged = false
        self.Open = false
        self.AnimFinished = true
        self.RotFinished = true
        self.Clockwise = true
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
        self.Goal = Random(120,300)
        self.Rotator = CreateRotator(self, 'Axis', 'z', nil, 0, 50, 0)
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
        --# The rest of this override deals with effects.
        if self.AmbientEffects then
            self.AmbientEffects:Destroy()
            self.AmbientEffects = nil
        end
                    
        if not self.Open then
            self.Open = true
            self.AnimManip:PlayAnim(self:GetBlueprint().Display.AnimationOpen):SetRate(1)
            WaitFor(self.AnimManip)
        end

        --# Gilbot-X says:  
        --# I moved those 2 lines above from here because
        --# autotoggle was shutting off the unit before it
        --# had a chance to create its rotator.
        self.Rotator:SetSpinDown(false)
        
        
        --# Ambient effects
        self.AmbientEffects = 
            CreateEmitterAtEntity(self, self:GetArmy(),
                                  '/effects/emitters/aeon_t1_massfab_ambient_01_emit.bp')
        self.Trash:Add(self.AmbientEffects)

        self.Goal = Random(120,300)
      
        while not self:IsDead() do
            --# spin clockwise
            if not self.Clockwise then
                self.Rotator:SetTargetSpeed(self.Goal)
                self.Clockwise = true
            else
                self.Rotator:SetTargetSpeed(-self.Goal)
                self.Clockwise = false
            end
            WaitFor(self.Rotator)

            --# slow down to change directions
            self.Rotator:SetTargetSpeed(0)
            WaitFor(self.Rotator)
            self.Rotator:SetSpeed(0)
            self.Goal = Random(120,300)
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
        --# This override just deals with effects
        if self.AmbientEffects then
            self.AmbientEffects:Destroy()
            self.AmbientEffects = nil
        end
        
        if self.Open then
            if self.Clockwise == true then
                self.Rotator:SetSpinDown(true)
                self.Rotator:SetTargetSpeed(self.Goal)
            else
                self.Rotator:SetTargetSpeed(0)
                WaitFor(self.Rotator)
                self.Rotator:SetSpinDown(true)
                self.Rotator:SetTargetSpeed(self.Goal)
            end
            WaitFor(self.Rotator)
        end
        if self.Open then
            self.AnimManip:SetRate(-1)
            self.Open = false
            WaitFor(self.AnimManip)
        end
    end,

}

TypeClass = UAB1104