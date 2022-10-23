#****************************************************************************
#**  Summary  :  UEF Commander Script
#****************************************************************************
local oldUEL0001 = UEL0001
UEL0001 = Class(oldUEL0001) {    
    CreateEnhancement = function(self, enh)
        TWalkingLandUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        
        if enh =='AdvancedEngineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT2BuildRate',
                    DisplayName = 'UEFACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'UEFACUT2BuildRate')
        elseif enh =='AdvancedEngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
            if Buff.HasBuff( self, 'UEFACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'UEFACUT2BuildRate' )
            end
        elseif enh =='T3Engineering' then
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT3BuildRate',
                    DisplayName = 'UEFCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        BuildRate = {
                            Add =  bp.NewBuildRate - self:GetBlueprint().Economy.BuildRate,
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
            Buff.ApplyBuff(self, 'UEFACUT3BuildRate')
            if Buff.HasBuff( self, 'UEFACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'UEFACUT2BuildRate' )
            end
        elseif enh =='T3EngineeringRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            if Buff.HasBuff( self, 'UEFACUT3BuildRate' ) then
                Buff.RemoveBuff( self, 'UEFACUT3BuildRate' )
            end
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER) )
        
        elseif enh =='DamageStablization' then
        	if not Buffs['UEFACUDamageStablization'] then
                BuffBlueprint {
                    Name = 'UEFACUDamageStablization',
                    DisplayName = 'UEFACUDamageStablization',
                    BuffType = 'ACUREGEN',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Regen = {
                            Add = bp.NewRegenRate,
                            Mult = 1.0,
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UEFACUDamageStablization')
        elseif enh =='DamageStablizationRemove' then
            Buff.RemoveBuff(self,'UEFACUDamageStablization',false) 
        
        elseif enh =='HeavyAntiMatterCannon' then
        	if not Buffs['UefACUHeavyAntiMatterCannon'] then
                BuffBlueprint {
                    Name = 'UefACUHeavyAntiMatterCannon',
                    DisplayName = 'UefACUHeavyAntiMatterCannon',
                    BuffType = 'UefACUHeavyAntiMatterCannon',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Damage = {
                            Add =  bp.ZephyrDamageMod,
                            Mult = 1,
                            ByName = {
                            	RightZephyr = true,
                            },
                        },
                        MaxRadius = {
                            Add =  bp.NewMaxRadius,
                            Mult = 1,
                            ByName = {
                            	RightDisruptor = true,
                            	OverCharge = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'UefACUHeavyAntiMatterCannon')
        elseif enh =='HeavyAntiMatterCannonRemove' then
            Buff.RemoveBuff(self,'UefACUHeavyAntiMatterCannon',false) 
        
        #ResourceAllocation              
        elseif enh == 'ResourceAllocation' then
        	if not Buffs['UefACUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'UefACUResourceAllocation',
                    DisplayName = 'UefACUResourceAllocation',
                    BuffType = 'UefACUResourceAllocation',
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
            Buff.ApplyBuff(self, 'UefACUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            Buff.RemoveBuff(self,'UefACUResourceAllocation',false)
        else
        	oldUEL0001.CreateEnhancement(self, enh)
        end
    end,
    
    

}
TypeClass = UEL0001