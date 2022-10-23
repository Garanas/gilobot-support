do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /units/UAA0310/UAA0310_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Aeon T1 Hover Tank
--#**
--#****************************************************************************

PreviousVersion = UAL0201
UAL0201 = Class(PreviousVersion) {
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide weapons upgrades
    --#*  for Experimental Wars Veterancy code.
    --#**
    Weapons = {
        MainGun = PreviousVersion.Weapons.MainGun,
		MainGun02 = Class(ADFDisruptorCannonWeapon) {},
		MainGun03 = Class(ADFDisruptorCannonWeapon) {},
    },
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for mods:
    --#*  Initialisation for Experimental Wars Veterancy code.
    --#**
    OnCreate = function(self)
        PreviousVersion.OnCreate(self)
        self:HideBone('Object05', true)  
        self:HideBone('Object07', true)  
        self:HideBone('Object06', true)  
        self:HideBone('Turret05', true)  
    end,
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is overrided to provide support for mods:
    --#*  Initialisation for Experimental Wars Veterancy code.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        PreviousVersion.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('MainGun02', false)
        self:SetWeaponEnabledByLabel('MainGun03', false)
	    self:AddUnitCallback(self.OnVeteran, 'OnVeteran')
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
    
    --# This is the T1 Aeon Light (Hover) Tank.
    --# This was originally added to make it slower on water
    --# but why not make it faster on water!! 
    --# Water has uniform height so should be faster to 
    --# navigate for a hover vehicle
    OnLayerChange = function(self, new, old)
        PreviousVersion.OnLayerChange(self, new, old)
        if( old ~= 'None' ) then
            if( new == 'Land' ) then
           	self:SetSpeedMult(1)
            elseif( new == 'Water' ) then
                self:SetSpeedMult(1.3)
            end
     	end
    end,
    
}
TypeClass = UAL0201

end --(of non-destructive hook)