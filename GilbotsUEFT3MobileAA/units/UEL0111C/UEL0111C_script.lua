--#****************************************************************************
--#**
--#**  New File :  /mods/../units/UEL0111C/UEL0111C_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  UEF T3 Mobile SAM Launcher Script
--#**
--#****************************************************************************

local TLandUnit = import('/lua/terranunits.lua').TLandUnit
--# Weapon from UEF Missile launcher UEL0111
local TIFCruiseMissileUnpackingLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileUnpackingLauncher

UEL0111C = Class(TLandUnit) {
    Weapons = {
        MissileRack01 = Class(TIFCruiseMissileUnpackingLauncher) 
        {
            FxMuzzleFlash = {'/effects/emitters/terran_mobile_missile_launch_01_emit.bp'},
        },
    },
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Safety against Null animator.
    --#**  
    OnCreate = function( self )
        TLandUnit.OnCreate(self)
        if not self.OpenAnim then
            self.OpenAnim = CreateAnimator(self)
            self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(0)
            self.Trash:Add(self.OpenAnim)
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Unpack weapon after failed built, 
    --#*  because the weapon was packed when built.
    --#**   
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do Baseclass code first
        TLandUnit.OnStopBeingBuilt(self, builder, layer)
        --# Main weapon must be disabled if packed.
        self:SetWeaponEnabledByLabel('MissileRack01', false)
        --# Unpack Weapon.
        ChangeState(self, self.WeaponUnpackingState)
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Unpack weapon when built or after upgrade, 
    --#*  because the weapon was packed in those situations.
    --#**
    WeaponUnpackingState = State {
        Main = function(self)
            --# Make sure animator is not nil
            if not self.OpenAnim then
                self.OpenAnim = CreateAnimator(self)
                self.Trash:Add(self.OpenAnim)
            end
            --# Now do animation.
            self.NotReadyToUpgrade = true
            self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(0.5)
            --# Wait for animation to finish.
            WaitFor(self.OpenAnim)
            --# Once weapon is unpacked, enable it.
            self:SetWeaponEnabledByLabel('MissileRack01', true)
            ChangeState(self, self.IdleState)
        end
    },
}

TypeClass = UEL0111C