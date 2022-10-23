local oldURL0001 = URL0001
URL0001 = Class(oldURL0001) {
    
    CreateEnhancement = function(self, enh)
        CWalkingLandUnit.CreateEnhancement(self, enh)
        
        local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            
        if enh == 'ResourceAllocation' then
        	if not Buffs['CybranACUTResourceAllocation'] then
                BuffBlueprint {
                    Name = 'CybranACUTResourceAllocation',
                    DisplayName = 'CybranACUTResourceAllocation',
                    BuffType = 'CybranACUTResourceAllocation',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MassProductionBuf = {
                            Add =  bp.ProductionPerSecondMass,
                            Mult = 1,
                        },
                        EnergyProductionBuf = {
                            Add = bp.ProductionPerSecondEnergy,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'CybranACUTResourceAllocation')    
        
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'CybranACUTResourceAllocation',false)
        
        elseif enh == 'CloakingGenerator' then
            self.StealthEnh = false
			self.CloakEnh = true 
            self:EnableUnitIntel('Cloak')
            if not Buffs['CybranACUCloakBonus'] then
               BuffBlueprint {
                    Name = 'CybranACUCloakBonus',
                    DisplayName = 'CybranACUCloakBonus',
                    BuffType = 'ACUCLOAKBONUS',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                    },
                } 
            end
            if Buff.HasBuff( self, 'CybranACUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranACUCloakBonus' )
            end  
            Buff.ApplyBuff(self, 'CybranACUCloakBonus')                		
        elseif enh == 'CloakingGeneratorRemove' then
            self:RemoveToggleCap('RULEUTC_CloakToggle')
            self:DisableUnitIntel('Cloak')
            self.CloakEnh = false 
            if Buff.HasBuff( self, 'CybranACUCloakBonus' ) then
                Buff.RemoveBuff( self, 'CybranACUCloakBonus' )
            end     
                     
        #T2 Engineering
        elseif enh =='AdvancedEngineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT2BuildRate',
                    DisplayName = 'CybranACUT2BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'CybranACUT2BuildRate')
        elseif enh =='AdvancedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            if Buff.HasBuff( self, 'CybranACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'CybranACUT2BuildRate' )
            end
            
        #T3 Engineering
        elseif enh =='T3Engineering' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT3BuildRate',
                    DisplayName = 'CybranCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate,
                            Mult = 1,
                        },
                        MaxHealth = {
                            Add = bp.NewHealth,
                            Mult = 1.0,
                        },
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'CybranACUT3BuildRate')
            if Buff.HasBuff( self, 'CybranACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'CybranACUT2BuildRate' )
            end
        elseif enh =='T3EngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'CybranACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'CybranACUT3BuildRate' )
            end
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        elseif enh =='CoolingUpgrade' then
        	if not Buffs['CybranACUCoolingUpgrade'] then
                BuffBlueprint {
                    Name = 'CybranACUCoolingUpgrade',
                    DisplayName = 'CybranACUCoolingUpgrade',
                    BuffType = 'CybranACUCoolingUpgrade',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        MaxRadius = {
                            Add =  bp.NewMaxRadius,
                            Mult = 1,
                            ByName = {
                            	RightRipper = true,
                            	OverCharge = true,
                            	MLG = true,
                            },
                        },
                        RateOfFireBuf = {
                            Add =  bp.NewRateOfFire,
                            Mult = 1,
                            ByName = {
                            	RightRipper = true,
                            	OverCharge = true,
                            	MLG = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'CybranACUCoolingUpgrade')
        elseif enh == 'CoolingUpgradeRemove' then
            if Buff.HasBuff( self, 'CybranACUCoolingUpgrade' ) then
                Buff.RemoveBuff( self, 'CybranACUCoolingUpgrade' )
            end
		else
        	oldURL0001.CreateEnhancement(self, enh)
        end             
    end,
}   
    
TypeClass = URL0001
