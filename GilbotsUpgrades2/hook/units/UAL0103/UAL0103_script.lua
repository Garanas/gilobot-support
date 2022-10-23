do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /mods/.../units/UAL0103/UAL0103_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Mod of the Aeon T1 Mobile Artillery
--#**
--#****************************************************************************

local PreviousVersion = UAL0103
UAL0103 = Class(PreviousVersion) {
    
   --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide weapons upgrades
    --#*  for Experimental Wars Veterancy code,
    --#*  and to add the Charging Dummy Weapon.
    --#**
    Weapons = {
        MainGun = PreviousVersion.Weapons.MainGun,
        MainGunUpgrade01 = Class(AIFMortarWeapon) {
            FxMuzzleFlash = {
                '/effects/emitters/aeon_mortar_flash_01_emit.bp',
                '/effects/emitters/aeon_mortar_flash_02_emit.bp',
            },
        },
    },
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for mods:
    --#*  Initialisation for Experimental Wars Veterancy code.
    --#**
    OnCreate = function(self)
		PreviousVersion.OnCreate(self)
        self:HideBone('Turret_Barrel01', true)  
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for mods:
    --#*  Initialisation for Customupgrade unit code
    --#*  Initialisation for Experimental Wars Veterancy code.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        PreviousVersion.OnStopBeingBuilt(self, builder, layer)
        
        --# Initialisation for Experimental Wars Veterancy code.
        self:SetWeaponEnabledByLabel('MainGunUpgrade01', false)
        self:AddUnitCallback(self.OnVeteran, 'OnVeteran')
        
        --# Initialisation for Customupgrade unit code
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my 'Experimental Wars mod veterancy.
    --#*  It is called via a callback we set, whenever a new
    --#*  veterancy level has been reached.
    --#**
    OnVeteran = function(self)
        local bp = self:GetBlueprint().ExpeWars_Enhancement[self.VeteranLevel]
		if not bp then return end
        --# Perform standrad processing
        self:ApplyEWVeteranBuff(bp)
	end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for enhancments.
    --#**
    CreateEnhancement = function(self, enh)
        PreviousVersion.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        --# Get the unit's only weapon
        local gun = self:GetWeapon(1)
        --# and the original value for its range.
        local originalValue = gun:GetBlueprint().MaxRadius
            
        if  enh == "MaxWeaponRadius1" or 
            enh == "MaxWeaponRadius2" then
            --# Update weapon with extra bonus
            gun:ChangeMaxRadius(originalValue*bp.MaxWeaponRadiusMultiplier)
        
        elseif  enh == "MaxWeaponRadius1Remove" or 
                enh == "MaxWeaponRadius2Remove" then
            --# Revert the weapon to original value
            gun:ChangeMaxRadius(originalValue)
        end
    end,
}

TypeClass = UAL0103



end --(of non-destructive hook)