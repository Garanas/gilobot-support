local TDFGaussCannonWeapon = import('/lua/terranweapons.lua').TDFGaussCannonWeapon
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher
local Buff = import('/lua/sim/Buff.lua')

local hasHEBI = false --# Flag signalant Enhancement avec Heavy Electron Bolter
local hasHEBII = false
local hasHEBI = false
local hasHEBIV = false
local hasHEBV = false

local PreviousVersion = UEL0201
UEL0201 = Class(PreviousVersion) {
    Weapons = {
        MainGun = Class(TDFGaussCannonWeapon) {},
		UpgradeGun = Class(TDFGaussCannonWeapon) {},
		MissileRack01 = Class(TSAMLauncher) {},
    },

    OnCreate = function(self)
		PreviousVersion.OnCreate(self)
			self:HideBone('RackMiniMissile', true)  
			self:HideBone('Turret01', true)  
    end,
	
    OnStopBeingBuilt = function(self, builder, layer)
        PreviousVersion.OnStopBeingBuilt(self,builder,layer)
	        self:SetWeaponEnabledByLabel('MainGun', true)
			self:SetWeaponEnabledByLabel('UpgradeGun', false)
	        self:SetWeaponEnabledByLabel('MissileRack01', false)  --# Sera activé via auto-upgrade
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
				hasHEBI = true    --# Signale HEB INSTALLÉ
				hasHEBII = false
				hasHEBIII = false
				hasHEBIV = false
				hasHEBV = false
                BuffBlueprint {
                    Name = 'UEFHEALTHBUFF',
                    DisplayName = 'UEFHEALTHBUFF',
                    BuffType = 'MAXHEALTH',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.5,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.5,
                        },
                    },
                }
            end
			Buff.ApplyBuff(self, 'UEFHEALTHBUFF')
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
				self:SetWeaponEnabledByLabel('MainGun', false)
				self:SetWeaponEnabledByLabel('UpgradeGun', true)
				self:ShowBone('Turret01', true)
				self:HideBone('Turret', true)
				self:HideBone('RackMiniMissile', true)
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
				local wep = self:GetWeaponByLabel('UpgradeGun')
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
				self:SetWeaponEnabledByLabel('MissileRack01', true)
				self:ShowBone('RackMiniMissile', true)
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
				local wep = self:GetWeaponByLabel('MissileRack01')
				local wep2 = self:GetWeaponByLabel('UpgradeGun')
				wep2:AddDamageMod(bpEnh.BolterIIIDamageMod)  
				wep:AddDamageMod(bpEnh.BolterIIDamageMod)  
				hasHEBI = true
				hasHEBII = true    --# Signale HEB INSTALLÉ
				hasHEBIII = true
				hasHEBIV = true
				hasHEBV = true
                BuffBlueprint {
                    Name = 'UEFHEALTHBUFFII',
                    DisplayName = 'UEFHEALTHBUFFII',
                    BuffType = 'MAXHEALTH',
                    Stacks = 'REPLACE',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 2.2,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.2,
                        },
                    },
                }
            end
			Buff.ApplyBuff(self, 'UEFHEALTHBUFFII')
		end
	end,
	
}

TypeClass = UEL0201