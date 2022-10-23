local Buff = import('/lua/sim/Buff.lua')

local hasHEBI = false 
local hasHEBII = false
local hasHEBI = false
local hasHEBIV = false
local hasHEBV = false

local PreviousVersion = URL0107
URL0107 = Class(PreviousVersion) {
    Weapons = {
        LaserArms = PreviousVersion.Weapons.LaserArms,
		LaserArms01 = Class(CDFLaserHeavyWeapon) {},
		LaserArms02 = Class(CDFLaserHeavyWeapon) {},
    },
    OnCreate = function(self)
        PreviousVersion.OnCreate(self)
        self:HideBone('Torso08', true)
        self:HideBone('UpLeg01', true)  
        self:HideBone('UpLeg02', true)  
        self:HideBone('UpLeg03', true)  
        self:HideBone('UpLeg04', true)  
        self:HideBone('Turret_Barrel02', true)  
        --# This next block is also in base class
        --# Repeat this because we hid lots of bones
        if self:GetBlueprint().General.BuildBones then
            self:SetupBuildBones()
        end
    end,
	
    OnStopBeingBuilt = function(self, builder, layer)
        PreviousVersion.OnStopBeingBuilt(self,builder,layer)
        self:SetWeaponEnabledByLabel('LaserArms', true)
        self:SetWeaponEnabledByLabel('LaserArms01', false)
        self:SetWeaponEnabledByLabel('LaserArms02', false)  --# Sera activé via auto-upgrade
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
			self:ShowBone('UpLeg01', true)
			self:ShowBone('UpLeg02', true)
			self:ShowBone('UpLeg03', true)
			self:ShowBone('UpLeg04', true)
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
				self:SetWeaponEnabledByLabel('LaserArms', false)
				self:SetWeaponEnabledByLabel('LaserArms02', true)
				self:ShowBone('Turret_Barrel02', true)
				self:HideBone('Turret_Barrel', true)
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
				local wep = self:GetWeaponByLabel('LaserArms02')
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
				self:SetWeaponEnabledByLabel('LaserArms02', false)
				self:SetWeaponEnabledByLabel('LaserArms01', true)
				self:HideBone('Torso', true)
				self:ShowBone('Torso08', true)
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
				local wep = self:GetWeaponByLabel('LaserArms01')
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

TypeClass = URL0107