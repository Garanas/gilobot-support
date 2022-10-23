do--(start of non-destructive hook)
--#****************************************************************************
--#**  Summary  :  Seraphim Commander Script
--#****************************************************************************
local oldXSL0001 = XSL0001
XSL0001 = Class(oldXSL0001) {
    
    OnStartBuild = function(self, unitBeingBuilt, order)
   		--# FA version didn't call its own base class
        --# So we'll call it for them.
        SWalkingLandUnit.OnStartBuild(self, unitBeingBuilt, order)
        oldXSL0001.OnStartBuild(self, unitBeingBuilt, order)
    end,

    CreateEnhancement = function(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        
        if enh == 'RegenAura' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimACURegenAura',
                    DisplayName = 'SeraphimACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'ALWAYS',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            --#Add = bp.RegenPerSecond or 0.1,
                            --#Mult = 0,
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                    },
                }
                
            end
                
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.RegenThreadHandle = self:ForkThread(self.RegenBuffThread)
                        
        elseif enh == 'RegenAuraRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.RegenThreadHandle)
            
        elseif enh == 'AdvancedRegenAura' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            if self.RegenThreadHandle then
                if self.ShieldEffectsBag then
                    for k, v in self.ShieldEffectsBag do
                        v:Destroy()
                    end
		            self.ShieldEffectsBag = {}
		        end
                KillThread(self.RegenThreadHandle)
                
            end
            
            local bp = self:GetBlueprint().Enhancements[enh]
            if not Buffs['SeraphimAdvancedACURegenAura'] then
                BuffBlueprint {
                    Name = 'SeraphimAdvancedACURegenAura',
                    DisplayName = 'SeraphimAdvancedACURegenAura',
                    BuffType = 'COMMANDERAURA',
                    Stacks = 'ALWAYS',
                    Duration = 5,
                    Affects = {
                        RegenPercent = {
                            --#Add = bp.RegenPerSecond or 0.1,
                            --#Mult = 0,
                            Add = 0,
                            Mult = bp.RegenPerSecond or 0.1,
                            
                            Ceil = bp.RegenCeiling,
                            Floor = bp.RegenFloor,
                        },
                        MaxHealth = {
                            Add = 0,
                            Mult = bp.MaxHealthFactor or 1.0,
                        },                        
                    },
                }
            end
            
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 'XSL0001', self:GetArmy(), '/effects/emitters/seraphim_regenerative_aura_01_emit.bp' ) )
            self.AdvancedRegenThreadHandle = self:ForkThread(self.AdvancedRegenBuffThread)
            
        elseif enh == 'AdvancedRegenAuraRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            if self.ShieldEffectsBag then
                for k, v in self.ShieldEffectsBag do
                    v:Destroy()
                end
		        self.ShieldEffectsBag = {}
		    end
            KillThread(self.AdvancedRegenThreadHandle)
            
        --#Resource Allocation
        elseif enh == 'ResourceAllocation' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
        	if not Buffs['SeraACUResourceAllocation'] then
                BuffBlueprint {
                    Name = 'SeraACUResourceAllocation',
                    DisplayName = 'SeraACUResourceAllocation',
                    BuffType = 'SeraACUResourceAllocation',
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
            Buff.ApplyBuff(self, 'SeraACUResourceAllocation')
        elseif enh == 'ResourceAllocationRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            Buff.RemoveBuff(self,'SeraACUResourceAllocation',false)
        elseif enh == 'ResourceAllocationAdvanced' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            if not Buffs['SeraACUResourceAllocationAdvanced'] then
                BuffBlueprint {
                    Name = 'SeraACUResourceAllocationAdvanced',
                    DisplayName = 'SeraACUResourceAllocationAdvanced',
                    BuffType = 'SeraACUResourceAllocationAdvanced',
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
            Buff.ApplyBuff(self, 'SeraACUResourceAllocationAdvanced')
            Buff.RemoveBuff(self,'SeraACUResourceAllocation',false)
        elseif enh == 'ResourceAllocationAdvancedRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            Buff.RemoveBuff(self,'SeraACUResourceAllocationAdvanced',false)
        elseif enh =='AdvancedEngineering' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT2BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT2BuildRate',
                    DisplayName = 'SeraphimACUT2BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT2BuildRate')
        elseif enh =='T3Engineering' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['SeraphimACUT3BuildRate'] then
                BuffBlueprint {
                    Name = 'SeraphimACUT3BuildRate',
                    DisplayName = 'SeraphimCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'SeraphimACUT3BuildRate')
            if Buff.HasBuff( self, 'SeraphimACUT2BuildRate' ) then
                Buff.RemoveBuff( self, 'SeraphimACUT2BuildRate' )
            end
        elseif enh == 'BlastAttack' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
        	if not Buffs['SeraACUBlastAttack'] then
                BuffBlueprint {
                    Name = 'SeraACUBlastAttack',
                    DisplayName = 'SeraACUBlastAttack',
                    BuffType = 'SeraACUBlastAttack',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        Damage = {
                            Add =  bp.AdditionalDamage,
                            Mult = 1,
                            ByName = {
                            	ChronotronCannon = true,
                            },
                        },
                        MaxRadius = {
                            Add =  bp.NewMaxRadius,
                            Mult = 1,
                            ByName = {
                            	ChronotronCannon = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraACUBlastAttack')
        elseif enh == 'BlastAttackRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            if Buff.HasBuff( self, 'SeraACUBlastAttack' ) then
                Buff.RemoveBuff( self, 'SeraACUBlastAttack' )
            end
        elseif enh == 'RateOfFire' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
        	if not Buffs['SeraACURateOfFire'] then
                BuffBlueprint {
                    Name = 'SeraACURateOfFire',
                    DisplayName = 'SeraACURateOfFire',
                    BuffType = 'SeraACURateOfFire',
                    Stacks = 'ALWAYS',
                    Duration = -1,
                    Affects = {
                        RateOfFireBuf = {
                            Add =  bp.NewRateOfFire,
                            Mult = 1,
                            ByName = {
                            	ChronotronCannon = true,
                            },
                        },
                        MaxRadius = {
                            Add =  bp.NewMaxRadius,
                            Mult = 1,
                            ByName = {
                            	ChronotronCannon = true,
                            	OverCharge = true,
                            },
                        },
                    },
                }
            end
            Buff.ApplyBuff(self, 'SeraACURateOfFire')
        elseif enh == 'RateOfFireRemove' then
            SWalkingLandUnit.CreateEnhancement(self, enh)
            if Buff.HasBuff( self, 'SeraACURateOfFire' ) then
                Buff.RemoveBuff( self, 'SeraACURateOfFire' )
            end
        else
        	oldXSL0001.CreateEnhancement(self, enh)
        end
    end,

}

TypeClass = XSL0001
end--(of non-destructive hook)