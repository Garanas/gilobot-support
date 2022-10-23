do--(start of nrn-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /units/XEB2402/XEB2402_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  UEF Sub Orbital Laser
--#**
--#****************************************************************************

local Unit = import('/lua/sim/unit.lua').Unit

XEB2402 = Class(TStructureUnit) {   

    --# Unchanged from original code
    DeathThreadDestructionWaitTime = 8,

    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.
    --#*  I removed the code that calls the launch.  
    --#**
    OnStopBeingBuilt = function(self)
        TStructureUnit.OnStopBeingBuilt(self)
        self.Satellites = {}
  
        --# Try using just one animator
        self.AnimManip = CreateAnimator(self)
        self.Trash:Add(self.AnimManip)
 
        --# You need to define this as true if
        --# you want the set-to-idle animation to run now
        if self.PlayAnimationWhenUnitIsBuilt then
            --# Wait till closing animation finishes 
            --# before allowing another to be built
            self:AddBuildRestriction(categories.SATELLITE * categories.UEF)
            --# You can build gain after closing is finished
            ChangeState(self, self.ClosingState)
        end
    end,

    
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.
    --#*  I call the code that does the launch from here
    --#*  instead of calling it from OnStopBeingBuilt.
    --#**
    OnStartBuild = function(self, unitBeingBuilt, order)
        --# This is GPG code, minus a call to change blinkig lights
        Unit.OnStartBuild(self, unitBeingBuilt, order)
        --# This is my code
        --# Play first animatiom that opens arms        
        self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen.sca', false ):SetRate(0.2)
        self:PlayUnitSound('MoveArms')
            
        local attachpos = self:GetPosition('Attachpoint01')
        unitBeingBuilt:SetPosition(attachpos, false)
        unitBeingBuilt:AttachTo(self, 'Attachpoint01')
    end,
    
    
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.
    --#*  I call the code that does the launch from here
    --#*  instead of calling it from OnStopBeingBuilt.
    --#**
    OnStopBuild = function(self, unitBeingBuilt, order)
        --# Call superclass version of method
        Unit.OnStopBuild(self, unitBeingBuilt, order)
        --# If an upgrade completed successfully...
        if unitBeingBuilt:GetFractionComplete() == 1 then
            self.SatelliteToLaunch = unitBeingBuilt
            self.Trash:Add(self.SatelliteToLaunch)
            table.insert(self.Satellites, self.SatelliteToLaunch)
            ChangeState(self, self.LaunchingState )
        end
    end,
            
            
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.  
    --#*  This function manipulates the open animation
    --#*  to give the effect of the unit opening launcher
    --#*  and then closing it again after.
    --#**
    LaunchingState = State() {

        Main = function(self)
            
            --# Wait before allowing another to be built
            self:AddBuildRestriction(categories.SATELLITE * categories.UEF)
            
            --# Wait for build arms to open into position
            WaitFor(self.AnimManip)
            
            --# Attach satellite to unit, play animation, release satellite
            --# Create satellite and attach to attachpoint bone
            local army = self:GetArmy()
            self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(0.06, -0.10, 1.90))
            self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(-0.06, -0.10, 1.90))
            self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(0.08, -0.5, 1.60))
            self.Trash:Add(CreateAttachedEmitter(self,'Tower_B04',army, '/effects/emitters/light_blue_blinking_01_emit.bp'):OffsetEmitter(-0.04, -0.5, 1.60))
            self.Trash:Add(CreateAttachedEmitter(self,'Attachpoint01',army, '/effects/emitters/structure_steam_ambient_01_emit.bp'):OffsetEmitter(0.7, -0.85, 0.35))
            self.Trash:Add(CreateAttachedEmitter(self,'Attachpoint01',army, '/effects/emitters/structure_steam_ambient_02_emit.bp'):OffsetEmitter(-0.7, -0.85, 0.35))
            self.Trash:Add(CreateAttachedEmitter(self,'ConstuctBeam01',army, '/effects/emitters/light_red_rotator_01_emit.bp'):ScaleEmitter( 2.00 ))
            self.Trash:Add(CreateAttachedEmitter(self,'ConstuctBeam02',army, '/effects/emitters/light_red_rotator_01_emit.bp'):ScaleEmitter( 2.00 ))
            
            --#Tell the satellite that we're its parent
            self.SatelliteToLaunch.Parent = self
            
            --# Play open animation
            self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen01.sca', false):SetRate(1)
            self:PlayUnitSound('LaunchSat')
            WaitFor(self.AnimManip )
			self.Trash:Add(CreateAttachedEmitter(self,'XEB2402',army, '/effects/emitters/uef_orbital_death_laser_launch_01_emit.bp'):OffsetEmitter(0.00, 0.00, 1.00))
			self.Trash:Add(CreateAttachedEmitter(self,'XEB2402',army, '/effects/emitters/uef_orbital_death_laser_launch_02_emit.bp'):OffsetEmitter(0.00, 2.00, 1.00))
            
            --# Release unit
            self.SatelliteToLaunch:DetachFrom()
            self.SatelliteToLaunch:Open()
            
            --# Satellite has launched
            --# Wait a couple seconds before
            --# resetting animation and allowing 
            --# to build another
            WaitSeconds(5)
 
            --# You can build gain after closing is finished
            ChangeState(self, self.ClosingState)
        end,
    },   
   
   
   
   --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.  
    --#*  This function manipulates the open animation
    --#*  to give the effect of the unit opening launcher
    --#*  and then closing it again after.
    --#**
    ClosingState = State() {

        Main = function(self)
            
            --# Slowly reset launch silo animation to lowered position 
            self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen01.sca', true):SetRate(-0.25)
            WaitSeconds(6)
            self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen01.sca', false):SetRate(-0.1)
            WaitFor(self.AnimManip)
            
            --# Build arms start closed when unit is built
            --# but must be closed after a satellite launch
            self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen.sca', true):SetRate(-0.25)
            WaitSeconds(12)
            self.AnimManip:PlayAnim('/units/XEB2402/XEB2402_aopen.sca', false):SetRate(-0.1)
            WaitFor(self.AnimManip)
            
            --# Allow another to be built
            self:RemoveBuildRestriction(categories.SATELLITE * categories.UEF)
            ChangeState( self, self.IdleState )
        end,
    },   
   
    
   
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.  
    --#*  This function kills all satellites built when it dies.
    --#**
    OnKilled = function(self, instigator, type, overkillRatio)
        --# When I die, kill all my satellites too
        for arrayIndex, vSatelliteUnit in self.Satellites do
            if vSatelliteUnit 
                and vSatelliteUnit:IsAlive() 
                and (not vSatelliteUnit.IsDying) then
                vSatelliteUnit:Kill()
            end
        end
        TStructureUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.  
    --#*  This function kills all satellites built when it dies.
    --#**
    OnDestroy = function(self)
        --# When I am destroyed, destroy all my satellites too
        for arrayIndex, vSatelliteUnit in self.Satellites do
            if vSatelliteUnit 
                and vSatelliteUnit:IsAlive() 
                and (not vSatelliteUnit.IsDying) then
                vSatelliteUnit:Kill()
            end
        end
        TStructureUnit.OnDestroy(self)
    end,
    
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that satellites are launched
    --#*  after this unit builds a satellite, as opposed to
    --#*  only doing it once straight away after it was built.  
    --#*  This function captures all launched satellites
    --#*  when this satellite controlling unit is captured.
    --#**
    OnCaptured = function(self, captor)
        if self and self:IsAlive() 
            and captor and captor:IsAlive() 
            and self:GetAIBrain() ~= captor:GetAIBrain() 
        then
        
            self:DoUnitCallbacks('OnCaptured', captor)
            local newUnitCallbacks = {}
            if self.EventCallbacks.OnCapturedNewUnit then
                newUnitCallbacks = self.EventCallbacks.OnCapturedNewUnit
            end
            local entId = self:GetEntityId()
            local unitEnh = SimUnitEnhancements[entId]
            local captorArmyIndex = captor:GetArmy()
            local captorBrain = false
            
            --# For campaigns:
            --# We need the brain to ignore army cap 
            --# when transfering the unit.
            --# do all necessary steps to set brain to ignore, 
            --# then un-ignore if necessary the unit cap
            if ScenarioInfo.CampaignMode then
                captorBrain = captor:GetAIBrain()
                SetIgnoreArmyUnitCap(captorArmyIndex, true)
            end
            
            --# Now deal with all our satellites
            local NewSatelliteTable = {}
            for arrayIndex, vSatelliteUnit in self.Satellites do
                if vSatelliteUnit 
                    and vSatelliteUnit:IsAlive() 
                    and (not vSatelliteUnit.IsDying) 
                then
                    vSatelliteUnit:DoUnitCallbacks('OnCaptured', captor)
                    local newSatUnitCallbacks = {}
                    if vSatelliteUnit.EventCallbacks.OnCapturedNewUnit then
                        newSatUnitCallbacks = vSatelliteUnit.EventCallbacks.OnCapturedNewUnit
                    end
                    local satId = self:GetEntityId()
                    local satEnh = SimUnitEnhancements[satId]
                    local sat = ChangeUnitArmy(vSatelliteUnit, captorArmyIndex)
            
                    --# Make sure satellite keeps its 
                    --# enhnacements after captured 
                    if satEnh then
                        for k,v in satEnh do
                            sat:CreateEnhancement(v)
                        end
                    end
                    for k,cb in newSatUnitCallbacks do
                        if cb then
                            cb(sat, captor)
                        end
                    end
                    
                    --# Put in new table
                    table.insert(NewSatelliteTable, sat)
                end
            end
        
          
            local newUnit = ChangeUnitArmy(self, captorArmyIndex)
            if newUnit then
                newUnit.Satellites = NewSatelliteTable
            end
                        
            if ScenarioInfo.CampaignMode and not captorBrain.IgnoreArmyCaps then
                SetIgnoreArmyUnitCap(captorArmyIndex, false)
            end
            
            if unitEnh then
                for k,v in unitEnh do
                    newUnit:CreateEnhancement(v)
                end
            end
            for k,cb in newUnitCallbacks do
                if cb then
                    cb(newUnit, captor)
                end
            end
        
        end
    end,

}
end--(of non-destructive hook)
TypeClass = XEB2402