--#****************************************************************************
--#**
--#**  New File:  /units/XEA0002C/XEA0002C_script.lua
--#**  
--#**  Modded BY:  Gilbot-X
--#**
--#**  Summary  :  UEF Upgraded Defense Satellite Script
--#**
--#****************************************************************************

local Unit = 
    import('/lua/sim/unit.lua').Unit
local TAirUnit = 
    import('/lua/terranunits.lua').TAirUnit
local TOrbitalDeathLaserBeamWeapon = 
    import('/lua/terranweapons.lua').TOrbitalDeathLaserBeamWeapon

XEA0002C = Class(TAirUnit) {
   
    --# Warns the user that enhancement
    --# will not start until unit is still.
    IsSlowToStartEnhancing = true,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This unit is a weapon enhancement.
    --#**
    OnCreate = function(self)
        Unit.OnCreate(self)
        --# This is GPG code that uses animation to open satellite
        for k,v in self.HideBones do self:HideBone(v, true) end
        self.OpenAnim = CreateAnimator(self)
        self.Trash:Add(self.OpenAnim )
        self.OpenAnim:PlayAnim('/units/XEA0002/xea0002_aopen02.sca')
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This unit is a weapon enhancement.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        Unit.OnStopBeingBuilt(self, builder, layer)
        --# This is the enhancement I represent
        Unit.CreateEnhancement(self, 'BeamWeapon3')
    end, 

    
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
            enh == "BeamWeapon1" or
            enh == "BeamWeapon2" or
            enh == "BeamWeapon3" or
            enh == "BeamWeapon3Remove" then return end

        --# Don't ignore any others            
        TAirUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
    
        if  enh == "VisionRadius1" or 
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
            WARN('Upgraded UEF Satellite: Unknown enhancment.')
        end
    end,
    
     --# Not changed from GPG code
    DestroyNoFallRandomChance = 1.1,
    --# Not changed from GPG code
    HideBones = { 'Shell01', 'Shell02', 'Shell03', 'Shell04', },
    --# Not changed from GPG code
    Weapons = {
        OrbitalDeathLaserWeapon = Class(TOrbitalDeathLaserBeamWeapon){},
    },
    --# Not changed from GPG code
    OnKilled = function(self, instigator, type, overkillRatio)
        if self.IsDying then 
            return 
        end
        
        local wep = self:GetWeaponByLabel('OrbitalDeathLaserWeapon')
        for k, v in wep.Beams do
            v.Beam:Disable()
        end      
        
        self.IsDying = true
        self.Parent:Kill(instigator, type, 0)
        
        TAirUnit.OnKilled(self, instigator, type, overkillRatio)        
    end,
    --# Not changed from GPG code
    OnDamage = function()
    end,
}
TypeClass = XEA0002C