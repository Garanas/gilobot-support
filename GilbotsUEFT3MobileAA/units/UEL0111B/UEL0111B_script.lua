--#****************************************************************************
--#**
--#**  New File :  /mods/../units/UEL0111B/UEL0111B_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  UEF T3 Mobile SAM Launcher Script
--#**
--#****************************************************************************

local TLandUnit = 
    import('/lua/terranunits.lua').TLandUnit
local MakeCustomUpgradeMobileUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua').MakeCustomUpgradeMobileUnit

--# Apply common code for my mobile units that have 
--# an upgrade. The arguments indicate which bone to   
--# centre the effect on, and the scale of the effect.
local BaseClass = MakeCustomUpgradeMobileUnit(TLandUnit, 'UEL0111', 2)

--# Weapon from UEF Missile launcher UEL0111
local TIFCruiseMissileUnpackingLauncher = import('/lua/terranweapons.lua').TIFCruiseMissileUnpackingLauncher

UEL0111B = Class(BaseClass) {
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
        BaseClass.OnCreate(self)
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
        BaseClass.OnStopBeingBuilt(self, builder, layer)
        --# Main weapon must be disabled if packed.
        self:SetWeaponEnabledByLabel('MissileRack01', false)
        --# Unpack Weapon.
        ChangeState(self, self.WeaponUnpackingState)
    end,
    
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Unpack weapon after failed upgrade, 
    --#*  because the weapon was packed in an upgrade.
    --#**   
    OnFailedToBuild = function(self)
        --# Do Baseclass code first
        BaseClass.OnFailedToBuild(self)
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
            --# If our previous state was PreparingToUpgradeState
            --# then we would go back to that if we didn't call this:
            ChangeState(self, self.IdleState)
        end
    },
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by code in customupgrademobileunit.lua
    --#*  This unit needs to pack its weapon before upgrading, or
    --#*  the effects look jumpy.
    --#**
    PreparingToUpgradeState = State {
        Main = function(self)
            self:SetWeaponEnabledByLabel('MissileRack01', false)
            --# Don't pack until open animation finished
            WaitFor(self.OpenAnim)
            --# For safety
            if not self.OpenAnim then
                self.OpenAnim = CreateAnimator(self)
                self.Trash:Add(self.OpenAnim)
            end
            --# Play open animation backwards to pack
            self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, true):SetRate(-0.5)
            WaitSeconds(6)
            self.OpenAnim:PlayAnim(self:GetBlueprint().Display.AnimationOpen, false):SetRate(-0.5)
            WaitFor(self.OpenAnim)
            
            --# Now we are ready to upgrade so let's try again!
            self.NotReadyToUpgrade = false
            local upgradeBPName = self:GetBlueprint().General.UpgradesTo or false
            if upgradeBPName then 
                IssueUpgrade({self}, upgradeBPName )  
            end
        end,
    },
    
}

TypeClass = UEL0111B