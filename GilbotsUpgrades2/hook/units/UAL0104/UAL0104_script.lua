local AAASonicPulseBatteryWeapon = import('/lua/aeonweapons.lua').AAASonicPulseBatteryWeapon

local hasHEBI = false --# Flag signalant Enhancement avec Heavy Electron Bolter
local hasHEBII = false
local hasHEBI = false
local hasHEBIV = false
local hasHEBV = false

local PreviousVersion = UAL0104
UAL0104 = Class(PreviousVersion) {

    Weapons = {
        AAGun = Class(AAASonicPulseBatteryWeapon) {},
		AAGun01 = Class(AAASonicPulseBatteryWeapon) {},
    },

    OnCreate = function(self)
        PreviousVersion.OnCreate(self)
			self:HideBone('Turret_Barrel01', true)  
			--#self:HideBone('Turret_Barrel_Recoil01', true)
			--#self:HideBone('Turret_Barrel02', true)
			--#self:HideBone('Turret_Barrel_Recoil02', true)
    end,
	
    OnStopBeingBuilt = function(self, builder, layer)
        PreviousVersion.OnStopBeingBuilt(self,builder,layer)
	        self:SetWeaponEnabledByLabel('AAGun', true)
			self:SetWeaponEnabledByLabel('AAGun01', false)  --# Sera activé via auto-upgrade
			--#self:SetWeaponEnabledByLabel('Main01GunUpgrade02', false)
       self.WeaponsEnabled = true
	   self:AddUnitCallback(self.OnVeteran, 'OnVeteran') --# Ajouter 1 Trigger pour lancer Enhancement
    end,
	
	--#Level#
	OnVeteran = function ( self )
        local bp = self:GetBlueprint()
		local enh = 'VeterancyI'
		local bpEnh = bp.ExpeWars_Enhancement[enh]
		if not bpEnh then return end
        local bpEnhEAVLevel = bpEnh.EnabledAtVeterancyLevel
		if bpEnhEAVLevel and bpEnhEAVLevel > 0 and ( self.VeteranLevel == bpEnhEAVLevel ) then
			if enh =='VeterancyI' then
				local wep = self:GetWeaponByLabel('AAGun')
				wep:ChangeMaxRadius(bpEnh.NewMaxRadius or 40)
				hasHEBI = true    --# Signale HEB INSTALLÉ
				hasHEBII = false
				hasHEBIII = false
				hasHEBIV = false
				hasHEBV = false
			end
		end		
		--######################
        local bp = self:GetBlueprint()
		local enh = 'VeterancyII'
		local bpEnh = bp.ExpeWars_Enhancement[enh]
		if not bpEnh then return end
        local bpEnhEAVLevel = bpEnh.EnabledAtVeterancyLevel
		--# ADDS MY CUSTOM ENHANCEMENT !
		if bpEnhEAVLevel and bpEnhEAVLevel > 0 and ( self.VeteranLevel == bpEnhEAVLevel ) then
			if enh =='VeterancyII' then
				local wep = self:GetWeaponByLabel('AAGun')
				wep:ChangeRateOfFire(bp.NewRateOfFire or 1.9)
				hasHEBI = true
				hasHEBII = true    --# Signale HEB INSTALLÉ
				hasHEBIII = false
				hasHEBIV = false
				hasHEBV = false
			end
		end
		--######################
        local bp = self:GetBlueprint()
		local enh = 'VeterancyIII'
		local bpEnh = bp.ExpeWars_Enhancement[enh]
		if not bpEnh then return end
        local bpEnhEAVLevel = bpEnh.EnabledAtVeterancyLevel
		--# ADDS MY CUSTOM ENHANCEMENT !
		if bpEnhEAVLevel and bpEnhEAVLevel > 0 and ( self.VeteranLevel == bpEnhEAVLevel ) then
			if enh =='VeterancyIII' then
				local wep = self:GetWeaponByLabel('AAGun')
    		    wep:AddDamageMod(bpEnh.BolterDamageMod)       
				hasHEBI = true
				hasHEBII = true    --# Signale HEB INSTALLÉ
				hasHEBIII = true
				hasHEBIV = false
				hasHEBV = false
			end
		end
		--#######################
        local bp = self:GetBlueprint()
		local enh = 'VeterancyIV'
		local bpEnh = bp.ExpeWars_Enhancement[enh]
		if not bpEnh then return end
        local bpEnhEAVLevel = bpEnh.EnabledAtVeterancyLevel
		--# ADDS MY CUSTOM ENHANCEMENT !
		if bpEnhEAVLevel and bpEnhEAVLevel > 0 and ( self.VeteranLevel == bpEnhEAVLevel ) then
			if enh =='VeterancyIV' then
				local wep = self:GetWeaponByLabel('AAGun01')
				self:SetWeaponEnabledByLabel('AAGun01', true)
				wep:ChangeMaxRadius(bpEnh.NewMaxRadius or 40)
				self:SetWeaponEnabledByLabel('AAGun', false)
				self:ShowBone('Turret_Barrel01', true)
				self:HideBone('Turret_Barrel', true)
				hasHEBI = true
				hasHEBII = true    --# Signale HEB INSTALLÉ
				hasHEBIII = true
				hasHEBIV = true
				hasHEBV = false
			end
		end
		--#######################
        local bp = self:GetBlueprint()
		local enh = 'VeterancyV'
		local bpEnh = bp.ExpeWars_Enhancement[enh]
		if not bpEnh then return end
        local bpEnhEAVLevel = bpEnh.EnabledAtVeterancyLevel
		--# ADDS MY CUSTOM ENHANCEMENT !
		if bpEnhEAVLevel and bpEnhEAVLevel > 0 and ( self.VeteranLevel == bpEnhEAVLevel ) then
			if enh =='VeterancyV' then
				local wep = self:GetWeaponByLabel('AAGun01')
				wep:AddDamageMod(bpEnh.BolterIIDamageMod)   
				wep:ChangeMaxRadius(bpEnh.NewMaxRadius or 45)
				wep:ChangeRateOfFire(bp.NewRateOfFire or 1.9)
				hasHEBI = true
				hasHEBII = true    --# Signale HEB INSTALLÉ
				hasHEBIII = true
				hasHEBIV = true
				hasHEBV = true
			end
		end
	end,
	
}


TypeClass = UAL0104