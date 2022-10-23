--#****************************************************************************
--#**
--#**  Hook File:  /units/UAL0001/UAL0001_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Aeon Commander Unit Script
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
    MakeRemoteAdjacencyController(UAL0001),
    removableAltOrdersListArg, 
    startingAltOrdersListArg
)
  
  
UAL0001 = Class(BaseClass, ACUKnowledge) {


    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# Original code
        BaseClass.OnCreate(self)
      
        --# Added extra restriction
        --# Restrict what enhancements will enable later
        self:AddBuildRestriction( categories.AEON * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER))
  
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
    
    CreateEnhancement = function(self, enh)
        
        --# I have to replace this because of my
        --# enhancement queue code.  Creation of 
        --# the shield is in a thread that waits 1 tick.
        --# This was trying to destrot the shield before
        --# it was created. Now I destroy the shield 
        --# after waiting 2 ticks.
        if enh=='ShieldHeavyRemove' then
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
            --# Now the base class version will run
            BaseClass.CreateEnhancement(self, enh)
        end
        
        local bp = self:GetBlueprint().Enhancements[enh]
        if enh =='EngineeringThroughput' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['AeonACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'AeonACUT4BuildRate',
                    DisplayName = 'AeonCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'AeonACUT4BuildRate')
        elseif enh =='EngineeringThroughputRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.AEON * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
            if Buff.HasBuff( self, 'AeonACUT4BuildRate' ) then
                Buff.RemoveBuff( self, 'AeonACUT4BuildRate' )
            end
        elseif enh =='T3EngineeringRemove' or 
               enh =='AdvancedEngineeringRemove' then
            --# This part of the restriction is not added by base classes.
            self:AddBuildRestriction(categories.AEON * categories.BUILTBYTIER4COMMANDER)
        end
    end,
}   
    
TypeClass = UAL0001