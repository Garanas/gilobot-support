--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/asfweapon.lua
--#**  
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Used by ASFs for their main weapon
--#**
--#****************************************************************************

local DefaultProjectileWeapon = import('/lua/sim/DefaultWeapons.lua').DefaultProjectileWeapon

--#*
--#*  Gilbot-X says:
--#*
--#*  This weapon class will stop the weapon from
--#*  firing at air units that are too high for it.
--#**
ASFProjectileWeapon = Class(DefaultProjectileWeapon) {

    --# Check if target has higher elevation 
    --# than our max elevation plus a margin...
    IsTargetTooHigh = function(self)
        local targetPosition = self:GetCurrentTargetPos() 
        if type(targetPosition.x) == 'number' then 
            local surfaceHeight = GetSurfaceHeight(targetPosition.x, targetPosition.z) 
            local elevationReading = targetPosition.y - surfaceHeight
            if elevationReading > 40 
            then --LOG('Target Too High: '  .. repr(elevationReading))
                 return true
            else return false
            end
        --# Target is probably 
        --# lost or destroyed so
        --# return it is too high so
        --# target will be reset.       
        else return true
        end
    end,
            
    --# Weapon is in idle state when it 
    --# does not have a target and is done 
    --# with any animations or unpacking.
    IdleState = State {
        --# These are inherited from base state
        WeaponWantEnabled = DefaultProjectileWeapon.IdleState.WeaponWantEnabled,
        WeaponAimWantEnabled = DefaultProjectileWeapon.IdleState.WeaponAimWantEnabled,

        --# Overrided just for 
        --# debugging purposes
        Main = function(self)
            local bp = self:GetBlueprint()
            if bp.WeaponUnpacks == true then 
                WARN('Gilbot: ASF Weapon on ' .. repr(self.unit.DebugId) ..' unpacks. Update your weapon scripts.')
            end
            --# Perform normal code
            DefaultProjectileWeapon.IdleState.Main(self)
        end,

        --# I ndebugging, it turned out that
        --# OnGotTarget was getting called outside 
        --# of this state.  So maybe the ASFs will still
        --# fly above their max elevation?
        OnGotTarget = function(self)
            if self:IsTargetTooHigh() then
                --# Don't target this unit
                self:ResetTarget() 
                --# Need to stop unit from flying in 
                --# attack pattern around target
                self.unit:SetElevation(self.unit:GetBlueprint().Physics.Elevation)
                IssueStop({self.unit})
                self.unit:GetNavigator():AbortMove()
            else
                DefaultProjectileWeapon.IdleState.OnGotTarget(self)
            end
        end,

        --# This does get called. It chages our state.
        OnFire = DefaultProjectileWeapon.IdleState.OnFire(self),
    },
    
    RackSalvoFiringState = State {
        --# These are inherited from base state
        WeaponWantEnabled = DefaultProjectileWeapon.IdleState.WeaponWantEnabled,
        WeaponAimWantEnabled = DefaultProjectileWeapon.IdleState.WeaponAimWantEnabled,

        Main = function(self)
            if self:IsTargetTooHigh() then
                --# Don't target this unit
                --LOG('ASF: RackSalvoFiringState: Resetting Target.')
                self:ResetTarget() 
                --# Need to stop unit from flying in 
                --# attack pattern around target
                self.unit:SetElevation(self.unit:GetBlueprint().Physics.Elevation)
                IssueStop({self.unit})
                self.unit:GetNavigator():AbortMove()
                self.HaltFireOrdered = false
                ChangeState(self, self.IdleState)
            else
                --# Proceed as normal and fire weapon.
                DefaultProjectileWeapon.RackSalvoFiringState.Main(self)
            end
        end,
        RenderClockThread = DefaultProjectileWeapon.RackSalvoFiringState.RenderClockThread,
        OnLostTarget = DefaultProjectileWeapon.RackSalvoFiringState.OnLostTarget,
        OnHaltFire = DefaultProjectileWeapon.RackSalvoFiringState.OnHaltFire,
    },
}