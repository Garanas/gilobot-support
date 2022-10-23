--#****************************************************************************
--#**
--#**  Hook File:  /units/UEL0001/UEL0001_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  UEF Commander Unit Script
--#**
--#****************************************************************************

local ACUKnowledge = import('/mods/GilbotsModPackCore/lua/ACUcommon.lua').ACUKnowledge

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local MakeExtraAltOrdersUnit = 
    import('/mods/GilbotsModPackCore/lua/extraaltorders.lua').MakeExtraAltOrdersUnit
local MakeRemoteAdjacencyController = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencycontroller.lua').MakeRemoteAdjacencyController
    
--# These are the arguments to the imported function 
--# The values mean: true indicates it is a toggle, false for command
--# which determines if we use AddCommandCap or AddToggleCap to add it
local startingAltOrdersListArg = {
    RULEUTC_WeaponToggle = true,
    RULEUCC_Overcharge = false,
    RULEUCC_Capture = false,
    RULEUCC_Repair = false,
    RULEUCC_Reclaim = false,
    RULEUTC_ProductionToggle = true,
}
--# This is an ordered list.  
--# Last one in the list is first to be removed
--# if a seventh alt order is added.
--# The AT button (RULEUTC_WeaponToggle)
--# will go if an eight button is added.
--# I've never seen more than 8 buttons added
--# because FA will only put in 6 to fill
--# the 6 slots.  This unit adds two extra
--# buttons so must nominate at least two 
--# buttons for removal here. 
local removableAltOrdersListArg = {
    'RULEUTC_WeaponToggle',
    'RULEUTC_ProductionToggle',
}

--# Take the original version and apply these
--# imported functions to get our base class    
local BaseClass = MakeExtraAltOrdersUnit(
    MakeRemoteAdjacencyController(UEL0001),  
    removableAltOrdersListArg, 
    startingAltOrdersListArg
)
  

UEL0001 = Class(BaseClass, ACUKnowledge) {


    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# Call code from original version first.
        BaseClass.OnCreate(self)
       
        --# Added extra restriction
        --# Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.UEF * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER))
  
        --# Perform initialization in new 
        --# second base class 'ACUKnowledge'
        ACUKnowledge.InitializeKnowledge(self)
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this to make sure that 
    --#*  Auto-toggle and ResourceNetworks are not used 
    --#*  when ACU dies.
    --#*
    --#*  This function is defined in Unit.lua
    --#*  and ends by changing state to DeadState
    --#*  so I have to call my extra code before calling
    --#*  the base class code.
    --#**
    OnDestroy = function(self)
        --# Gilbot-X says:  
        --# I added this call so that Auto-toggle
        --# and ResourceNetworks are not used 
        --# when ACU dies.
        ACUKnowledge.CallBefore_OnDestroy(self) 
             
        --# Finally the rest is GPG code.
        BaseClass.OnDestroy(self)
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this because UEF ACU
    --#*  does not use AddCommandCap when creating drones
    --#*  so it circumvents my code in MakeExtraAltOrdersUnit
    --#*  unless I make these explict calls here.
    --#**
    NotifyOfPodDeath = function(self, pod)
        BaseClass.NotifyOfPodDeath(self, pod)
        --# Now we can treat this as an alt order being removed
        --LOG('NotifyOfPodDeath: Overrided version called with pod=' .. pod)
        --# Protect against redundant virtual button removals
        if self.CommandCapsAddedSinceCreation[pod].VisibleInMenu then
            --# Remove virtual button
            self.CommandCapsAddedSinceCreation[pod].EnabledForUnit = false
            self.CommandCapsAddedSinceCreation[pod].VisibleInMenu = false
            self:OnButtonRemoved()
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this because UEF ACU
    --#*  does not use AddCommandCap when creating drones
    --#*  so it circumvents my code in MakeExtraAltOrdersUnit
    --#*  unless I make these explict calls here.
    --#**
    CreateEnhancement = function(self, enh)
        --LOG('CreateEnhancement: Overrided version called with enh=' .. enh)
        --# Before adding pod, need to treat this
        --# as adding an alt order and maybe make
        --# space for the button before UI tries to add it
        if enh == 'LeftPod' or enh == 'RightPod' then
            --# Protect against redundant virtual button removals
            if (not self.CommandCapsAddedSinceCreation[enh])
              or (not self.CommandCapsAddedSinceCreation[enh].EnabledForUnit)
            then
                --# Remove extra button to make space if needed
                self:RemoveButtonFromViewIfNeedTo()
                --# Add virtual button
                self.CommandCapsAddedSinceCreation[enh]= {
                    EnabledForUnit=true,
                    VisibleInMenu=true,
                }
            end
        end
        
        --# I have to replace this because of my
        --# enhancement queue code.  Creation of 
        --# the shield is in a thread that waits 1 tick.
        --# This was trying to destrot the shield before
        --# it was created. Now I destroy the shield 
        --# after waiting 2 ticks.
        if enh=='ShieldGeneratorFieldRemove' then
            --# Skip base class version and call 
            --# the version it overrides.
            local Unit = import('/lua/sim/unit.lua').Unit
            Unit.CreateEnhancement(self, enh)
            --# Destroy shield only after we are
            --# sure it has already been created
            ForkThread(function()
                WaitTicks(2)
                self:DestroyShield()
                self:SetMaintenanceConsumptionInactive()
                self:RemoveToggleCap('RULEUTC_ShieldToggle')
            end)
        else
            --# Now the Pod's button will be added
            BaseClass.CreateEnhancement(self, enh)
        end
        
        --# Add T4 Build Enhancement
        if enh =='EngineeringThroughput' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['UEFACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'UEFACUT4BuildRate',
                    DisplayName = 'UEFCUT3BuildRate',
                    BuffType = 'ACUBUILDRATE',
                    Stacks = 'REPLACE',
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
            Buff.ApplyBuff(self, 'UEFACUT4BuildRate')
        elseif enh =='EngineeringThroughputRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.UEF * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
            if Buff.HasBuff( self, 'UEFACUT4BuildRate' ) then
                Buff.RemoveBuff( self, 'UEFACUT4BuildRate' )
            end
        elseif enh =='T3EngineeringRemove' or 
               enh =='AdvancedEngineeringRemove' then
            --# This part of the restriction is not added by base classes.
            self:AddBuildRestriction(categories.UEF * categories.BUILTBYTIER4COMMANDER)
        end
    end,
    
}   
    
TypeClass = UEL0001