do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /units/XEA0002/XEA0002_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  UEF Satellite Script
--#**
--#****************************************************************************

local PreviousVersion = XEA0002
XEA0002 = Class(PreviousVersion) {

    --# Warns the user that enhancement
    --# will not start until unit is still.
    IsSlowToStartEnhancing = true,
    UnitElevationOffset = 0,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This code runs when an enhancement is finished.
    --#*  Note: In FA code, Beam wepons cannot use damageMod
    --#*  to change their damage, so I have had to use
    --#*  copies of the weapons and enable the one with
    --#*  correct damage.    
    --#**
    CreateEnhancement = function(self, enh)
        if  enh == "BeamWeapon1Remove" or
            enh == "BeamWeapon2Remove" or 
            enh == "BeamWeapon3Remove" then return end

        --# Don't ignore any others            
        PreviousVersion.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if  enh == "BeamWeapon1" then
            --# Allow weapon to be used
            self:SetWeaponEnabledByLabel('OrbitalDeathLaserWeapon', true)
            self:AddCommandCap('RULEUCC_Attack')
            self:AddCommandCap('RULEUCC_RetaliateToggle')
        elseif  enh == "BeamWeapon2" then
            --# This gives the unit its ability
            self.UpgradeOnIdle = true
        elseif  enh == "VisionRadius1" or 
                enh == "VisionRadius2" or 
                enh == "VisionRadius3" then
            --# Update vision radius with extra bonus
            local oldVision = self:GetBlueprint().Intel.VisionRadius
            self:SetIntelRadius('Vision', 
                math.floor(oldVision* bp.VisionRadiusMultiplier)
            )
        elseif  enh == "VisionRadius1Remove" or 
                enh == "VisionRadius2Remove" or 
                enh == "VisionRadius3Remove" then
            --# restore vision radius from BP
            local oldVision = self:GetBlueprint().Intel.VisionRadius
            self:SetIntelRadius('Vision', oldVision)
        else
            WARN('UEF Satellite: Unknown enhancment.')
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This handles enhancement
    --#*  that needs a state change.
    --#**
    IdleState = State() {
        Main = function(self)
            PreviousVersion.IdleState.Main(self)
            if self.UpgradeOnIdle then 
                ChangeState(self, self.ClosingState)
            end
        end,
    },
    
    
    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  This function manipulates the open animation
    --#*  to give the effect of the unit closing up.
    --#**
    ClosingState = State() {
        Main = function(self)
            self:SetBusy(true)
            self:SetBlockCommandQueue(true)
            --# Slowly reset open animation
            --# but must be closed after a satellite launch
            if not self.OpenAnim then self.OpenAnim = CreateAnimator(self) end
            self.OpenAnim:PlayAnim('/units/XEA0002/xea0002_aopen02.sca', true):SetRate(-1)
            WaitSeconds(2)
            self.OpenAnim:PlayAnim('/units/XEA0002/xea0002_aopen02.sca', false):SetRate(-0.1)
            WaitFor(self.OpenAnim)
            self:ReplaceMeWithUpgradedUnit()
        end,
    },   
   
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  The weapon is now an enhancement.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        PreviousVersion.OnStopBeingBuilt(self, builder, layer)
            
        --# This weapon starts disbled and is enabled by an enhancement
        self:SetWeaponEnabledByLabel('OrbitalDeathLaserWeapon', false)
    end, 
   
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I changed the state name.
    --#**
    Open = function(self)
        ChangeState(self, self.LaunchingState)
    end,
   
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I block command queue until ready.
    --#**
    LaunchingState = State() {
        Main = function(self)
            --# Moving the unit's x or x position 
            --# now will look bad because of the launch 
            --# animation shows bits dropping off.
            --# Also, an enhancement will stop the
            --# animation.
            self:SetBusy(true)
            self:SetBlockCommandQueue(true)
            --# This is GPG code.
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim( '/units/XEA0002/xea0002_aopen01.sca' )
            self.Trash:Add( self.OpenAnim )
            WaitFor( self.OpenAnim )
            self.OpenAnim:PlayAnim( '/units/XEA0002/xea0002_aopen02.sca' )
            for k,v in self.HideBones do
                self:HideBone( v, true )
            end
            --# I added this.
            local elevation = self:GetElevation()
            while self:IsAlive() and elevation < 71 do
                --LOG('elevation=' .. repr(elevation))
                WaitSeconds(2)
                elevation = self:GetElevation()
            end
            --# Now we are high enough to take orders.
            self:SetBusy(false)
            self:SetBlockCommandQueue(false)
            ChangeState(self, self.IdleState)
        end,
    },  
   
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This provides the missing counterpart to SetElevation
    --#**
    GetElevation = function(self)
        --# Take readings needed to work out elevation
        local currentPosition = self:GetPosition()
        local surfaceHeight = GetSurfaceHeight(currentPosition.x, currentPosition.z) 
        --# Calculate the elevation reading
        local elevationReading = currentPosition.y - (surfaceHeight - self.UnitElevationOffset)
        return elevationReading
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions so that a fully enhanced unit
    --#*  can be replaced with the upgraded version of it.
    --#*  This means that double-clicking units will get
    --#*  all fully upgraded units - enahnced and prebuilt.
    --#**
    ReplaceMeWithUpgradedUnit = function(self)
        local pos = self:GetPosition()
        local qx, qy, qz, qw = unpack(self:GetOrientation())
        local newUnit =  CreateUnit('xea0002b', self:GetArmy(), pos.x, pos.y, pos.z , qx, qy, qz, qw, 'Air')
  
        --# Copy over enhancements
        local unitEnh = SimUnitEnhancements[self:GetEntityId()]
        if unitEnh then
            for k,v in unitEnh do
                newUnit:CreateEnhancement(v)
            end
        end
            
        --# Destroy this unit as it has been replaced
        self:Destroy()
    end,
}

TypeClass = XEA0002
end--(of non-destructive hook)