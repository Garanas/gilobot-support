--#****************************************************************************
--#**
--#**  Hook File:  /units/URL0001/URL0001_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Cybran Commander Unit Script
--#**
--#****************************************************************************

local ACUKnowledge = import('/mods/GilbotsModPackCore/lua/ACUcommon.lua').ACUKnowledge

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
--local MakeAutoToggleController = 
--    import('/mods/GilbotsModPackCore/lua/autotoggle/autotogglecontroller.lua').MakeAutoToggleController
local MakeExtraAltOrdersUnit = 
    import('/mods/GilbotsModPackCore/lua/extraaltorders.lua').MakeExtraAltOrdersUnit
local MakeRemoteAdjacencyController = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencycontroller.lua').MakeRemoteAdjacencyController

--# Need this to skip over destructive functions in URL0001 base class
--# and inherit original  code from a couple functions from Unit.lua
local Unit =   
    import('/lua/sim/Unit.lua').Unit

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
    --MakeAutoToggleController(
        MakeRemoteAdjacencyController(URL0001)
    --)
    ,        
    removableAltOrdersListArg, 
    startingAltOrdersListArg
)
  
  
URL0001 = Class(BaseClass, ACUKnowledge) {


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
        self:AddBuildRestriction( categories.CYBRAN * (categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER))
  
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
    
    --# Add T4 Build Enhancement
    CreateEnhancement = function(self, enh)
        BaseClass.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if enh =='EngineeringThroughput' then
            local bp = self:GetBlueprint().Enhancements[enh]
            if not bp then return end
            local cat = ParseEntityCategory(bp.BuildableCategoryAdds)
            self:RemoveBuildRestriction(cat)
            if not Buffs['CybranACUT4BuildRate'] then
                BuffBlueprint {
                    Name = 'CybranACUT4BuildRate',
                    DisplayName = 'CybranCUT3BuildRate',
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
            Buff.ApplyBuff(self, 'CybranACUT4BuildRate')
        elseif enh =='EngineeringThroughputRemove' then
            local bp = self:GetBlueprint().Economy.BuildRate
            if not bp then return end
            self:RestoreBuildRestrictions()
            self:AddBuildRestriction( categories.CYBRAN * ( categories.BUILTBYTIER2COMMANDER + categories.BUILTBYTIER3COMMANDER + categories.BUILTBYTIER4COMMANDER) )
            if Buff.HasBuff( self, 'CybranACUT4BuildRate' ) then
                Buff.RemoveBuff( self, 'CybranACUT4BuildRate' )
            end
        elseif enh =='T3EngineeringRemove' or 
               enh =='AdvancedEngineeringRemove' then
            --# This part of the restriction is not added by base classes.
            self:AddBuildRestriction(categories.CYBRAN * categories.BUILTBYTIER4COMMANDER)
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to override this because OF GPG's bad coding.
    --#*  Their versions of these did not inherit base class
    --#*  code from unit.lua.
    --#**
    OnScriptBitSet = function(self, bit)
        if bit == 8 then --# cloak toggle
            self:StopUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionInactive()
            self:DisableUnitIntel('Cloak')
            self:DisableUnitIntel('RadarStealth')
            self:DisableUnitIntel('RadarStealthField')
            self:DisableUnitIntel('SonarStealth')
            self:DisableUnitIntel('SonarStealthField')          
        else
            Unit.OnScriptBitSet(self, bit)
        end
    end,

    OnScriptBitClear = function(self, bit)
        if bit == 8 then --# cloak toggle
            self:PlayUnitAmbientSound( 'ActiveLoop' )
            self:SetMaintenanceConsumptionActive()
            self:EnableUnitIntel('Cloak')
            self:EnableUnitIntel('RadarStealth')
            self:EnableUnitIntel('RadarStealthField')
            self:EnableUnitIntel('SonarStealth')
            self:EnableUnitIntel('SonarStealthField')
        else
            Unit.OnScriptBitClear(self, bit)
        end
    end,
}   
    
TypeClass = URL0001