do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#** Hook File:  /lua/system/blueprints.lua
--#**
--#** Modded By:  Gilbot-X
--#**             Updated for FA on Dec 11 2008
--#**
--#** Changes:
--#**    Exponential Hydrocarbon Power Plants (HCPP) code added.
--#**    Exponential Mass Extractors code added.
--#**   
--#*********************************************************************

    
--#* 
--#*  Gilbot-X says:
--#* 
--#*  ModBlueprints is called once 
--#*  at the start of every game. 
--#*  This gives us a hook to modify the 
--#*  blueprint values for all units.
--#**
local OldModBlueprints = ModBlueprints
function ModBlueprints(all_blueprints)
    --# Do any previously defined code first
    OldModBlueprints(all_blueprints)
    
    --# This function is defined below
    --# and was part of the 'Exponential HCPP' mod.
    ModHCPPs(all_blueprints.Unit)
    
    --# This function is defined below
    --# and was part of the 'Exponential Mass' mod.
    ModMassExtractors(all_blueprints.Unit)
    
    --# This function is defined below
    --# and was part of the 'Auto Pack' mod.
    GiveExtraToggleToAutoPackUnits(all_blueprints.Unit)
    
    --# This function is defined below 
    --# and makes teching up more expensive so T1 units
    --# are used more.
    MakeTechingUpMoreExpensive(all_blueprints.Unit)
end
    
   



--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  for my AutoPack units.
--#*  The Weapon toggle gets used with a new custom button 
--#*  to toggle autopack on and off.
--#**
function GiveExtraToggleToAutoPackUnits(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local autoPackUnits = {
        --# AEON Sensitive Shield
        all_bps['uab1102'], --# HCPP
        all_bps['uab1103'], all_bps['uab1202'], all_bps['uab1302'], --Mass extractors
 
        --# UEF DLS
        all_bps['ueb1102'], --# HCPP
        all_bps['ueb1103'], all_bps['ueb1202'], all_bps['ueb1302'], --Mass extractors
    }
    
    --# Give each factory these 6 toggles.
    for arrayIndex, bp in autoPackUnits do
        --# Give two order buttons
        if not bp.General.ToggleCaps then bp.General.ToggleCaps = {} end
        bp.General.ToggleCaps.RULEUTC_ProductionToggle = true   
        bp.General.ToggleCaps.RULEUTC_WeaponToggle = true
        --# Override the button on the weapon toggle to give it the AP button
        if not bp.General.OrderOverrides then bp.General.OrderOverrides = {} end
        bp.General.OrderOverrides.RULEUTC_WeaponToggle = {
            bitmapId = 'auto-pack',
            helpText = 'toggle_auto_pack',
        }
    end
end



--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me for my remote Pipeline units.
--#*  The direct fire weapon overlay allowsplayers to see the range 
--#*  of remote adjacency for the selected pipeline. 
--#**
function MakeTechingUpMoreExpensive(all_bps) 
    --# Put all units that autotoggle will work on into an array
    local ACUs = {
        all_bps['uel0001'],
        all_bps['url0001'], 
        all_bps['xsl0001'], 
        all_bps['ual0001'],
    }
    --# For each ACU faction
    for arrayIndex, bp in ACUs do
        --# Make it more expensive to upgrade from 
        --# tech1 to tech2 engineering suite
        bp.Enhancements.AdvancedEngineering.BuildCostEnergy = 
            bp.Enhancements.AdvancedEngineering.BuildCostEnergy * 2
        --# Make it more expensive to upgrade from 
        --# tech2 to tech3 engineering suite
        bp.Enhancements.T3Engineering.BuildCostEnergy = 
            bp.Enhancements.T3Engineering.BuildCostEnergy * 4
    end
    
    --# Put all the unit blueprints for factories into arrays
    --# according 2 tech level.  Exclude quantum gateways.
    local T1factories = {
        all_bps['uab0101'], all_bps['uab0102'], all_bps['uab0103'], 
        all_bps['ueb0101'], all_bps['ueb0102'], all_bps['ueb0103'], 
        all_bps['urb0101'], all_bps['urb0102'], all_bps['urb0103'], 
        all_bps['xsb0101'], all_bps['xsb0102'], all_bps['xsb0103'],
    }
    local T2factories = {
        all_bps['uab0201'], all_bps['uab0202'], all_bps['uab0203'],
        all_bps['ueb0201'], all_bps['ueb0202'], all_bps['ueb0203'],
        all_bps['urb0201'], all_bps['urb0202'], all_bps['urb0203'],
        all_bps['xsb0201'], all_bps['xsb0202'], all_bps['xsb0203'],
    }
    local T3factories = { 
        all_bps['uab0301'], all_bps['uab0302'], all_bps['uab0303'],
        all_bps['ueb0301'], all_bps['ueb0302'], all_bps['ueb0303'], 
        all_bps['urb0301'], all_bps['urb0302'], all_bps['urb0303'], 
        all_bps['xsb0301'], all_bps['xsb0302'], all_bps['xsb0303'], 
    }
    
    --# Make it harder to build Tech1 factories
    for arrayIndex, bp in T1factories do
        bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy*3
        bp.Economy.BuildCostMass = bp.Economy.BuildCostMass*2
    end

    --# Make it harder to tech up factories from Tech1 to Tech2
    for arrayIndex, bp in T2factories do
        bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy*6
        bp.Economy.BuildCostMass = bp.Economy.BuildCostMass*2
    end
    
    --# Make it harder to tech up factories from Tech2 to Tech3
    for arrayIndex, bp in T3factories do
        bp.Economy.BuildCostEnergy = bp.Economy.BuildCostEnergy*12
        bp.Economy.BuildCostMass = bp.Economy.BuildCostMass*2
    end
end


    
--#* 
--#*  Gilbot-X says:
--#* 
--#*  Bonuses on hydrocarbon plant increase over time.
--#*  Makes holding hydrocarbon plant more important and
--#*  makes game more territorial.
--#** 
function ModHCPPs(all_bps)     
    --# To haved the same values as GPG blueprints,
    --# use these settings:
    --# T1Start = 100,
    --# ..otherwise use your own to get the balance you like.
    --#
    local modSettings = {
        --# T1
        T1Start = 100,
        T1Cap = 5000,
        --# All GrowthConstants: These are constants in exponential formula.
        T1GrowthConstant = 1.02,
        --T1GrowthConstant = 1.05 -- use this one for testing
        

    }
    
    local hydrocarbonunits = {
        all_bps['uab1102'], 
        all_bps['ueb1102'],
        all_bps['urb1102'],
        all_bps['xsb1102'],
    }
    
    for id,bp in hydrocarbonunits do
        --# Add OutputModifier to BP according to tech level
        if not bp.Economy.EnergyProductionGrowthConstant then 
            bp.Economy.EnergyProductionGrowthConstant = modSettings.T1GrowthConstant 
        end
        --# Check user has not set anything in BP themselves
        if not bp.Economy.MaxProductionPerSecondEnergy then
            --# Blueprints ony need one of AutoUpgradeAt or MaxProductionPerSecondEnergy
            bp.Economy.MaxProductionPerSecondEnergy = modSettings.T1Cap  
        end
    end
    
end
        
        

--#*
--#*  Gilbot-X says:
--#*
--#*  Mass production of mass extractors increases over time.
--#*  Makes holding mass extractors more important relative to 
--#*  mass fabricators and makes game more territorial.
--#** 
function ModMassExtractors(all_bps) 

--[[

To have the same values as GPG blueprints, use these settings:
    T1Start = 2,
    T2Start = 6,
    T3Start = 12,
..otherwise use your own to get the balance you like.
  
Giving them all the same start value stops the production jumping when a unit upgrades because the production is based on base production level * factor.  Problem is, newly built T2 and T3 MeX become the same as a T1!!  Therefore I use BuildOnlyTech1 stop them from being built directly - you have to upgrade to get them!  In effect those units just lend their appearance to mark the level of production so the enemy has some idea.  There is code in my MassCollectionUnit class in the defaultunits hook that just doesn't pass on the % increase if the jump in starting values will cause a crazy jump in production, in which case the % increase is lost and the T2 made from an old T1 has the same production as a freshly built T2.  Its a bit of a context-sensitive safeguard in that it guesses whether or not you intended for the % increase to be passed on.

]]

    local modSettings = {
        AutoUpgradeTech1 = true,
        AutoUpgradeTech2 = true,
        BuildOnlyTech1 = false,
        --# T1
        T1Start = 2,
        T1CanUpgradeFrom = 2, --# can upgrade straight away
        T1Cap = 12,
        --# T2
        T2Start = 12,
        T2CanUpgradeFrom = 15, --# NB: setting to false means no manual upgrade possible 
        T2Cap = 30,
        --# T3
        T3Start = 30,
        T3Cap = 100,
        --# All GrowthConstants: These are constants in exponential formula.
        T1GrowthConstant = 1.05, -- This starts quite slow
        T2GrowthConstant = 1.03, -- This is moderate
        T3GrowthConstant = 1.01, -- 1.02 was way too fast!!
    }
    
    local mexunits = {
        TECH1 = {all_bps['uab1103'], all_bps['ueb1103'], all_bps['urb1103'], all_bps['xsb1103'],},
        TECH2 = {all_bps['uab1202'], all_bps['ueb1202'], all_bps['urb1202'], all_bps['xsb1202'],},
        TECH3 = {all_bps['uab1302'], all_bps['ueb1302'], all_bps['urb1302'], all_bps['xsb1302'],},
    }
    
    for unusedArrayIndex, bp in mexunits.TECH1 do
        --# This next line allows us to restrict upgrades
        --# by (perhaps conditionally) removing the upgrade from the build menu
        bp.Economy.BuildableCategory = {
            'BUILTBYTECH1MASSFAB' .. string.upper(bp.General.FactionName),
        }

        --# Add MassProductionGrowthConstant to BP according to tech level
        if not bp.Economy.MassProductionGrowthConstant then
            bp.Economy.MassProductionGrowthConstant = modSettings.T1GrowthConstant 
        end
        --# Set AllowManualUpgradeAt key in BP according to tech level
        if not bp.Economy.AllowManualUpgradeAt then 
            bp.Economy.AllowManualUpgradeAt = modSettings.T1CanUpgradeFrom 
        end
        
        --# Check user has not set anything in BP themselves
        if not bp.Economy.AutoUpgradeAt and 
           not bp.Economy.MaxProductionPerSecondMass then
            --# Blueprints ony need one of AutoUpgradeAt or MaxProductionPerSecondMass
            if modSettings.AutoUpgradeTech1 then
                bp.Economy.AutoUpgradeAt = modSettings.T1Cap 
            else
                bp.Economy.MaxProductionPerSecondMass = modSettings.T1Cap  
            end
        end
    end
        
    for unusedArrayIndex, bp in mexunits.TECH2 do
        --# These next 2 line allows us to restrict upgrades
        --# by (perhaps conditionally) removing the upgrade from the build menu
        table.insert(bp.Categories, 'BUILTBYTECH1MASSFAB' .. string.upper(bp.General.FactionName))
        bp.Economy.BuildableCategory = {
            'BUILTBYTECH2MASSFAB' .. string.upper(bp.General.FactionName) ,
        }
        --# Add MassProductionGrowthConstant to BP according to tech level
        if not bp.Economy.MassProductionGrowthConstant then
            bp.Economy.MassProductionGrowthConstant = modSettings.T2GrowthConstant 
        end
        --# Set AllowManualUpgradeAt key in BP according to tech level
        if not bp.Economy.AllowManualUpgradeAt then 
            bp.Economy.AllowManualUpgradeAt = modSettings.T2CanUpgradeFrom 
        end
        
        --# Check user has not set anything in BP themselves
        if not bp.Economy.AutoUpgradeAt and 
           not bp.Economy.MaxProductionPerSecondMass then
            --# Blueprints ony need one of AutoUpgradeAt or MaxProductionPerSecondMass
            if modSettings.AutoUpgradeTech2 then
                bp.Economy.AutoUpgradeAt = modSettings.T2Cap  
            else
                bp.Economy.MaxProductionPerSecondMass = modSettings.T2Cap  
            end
        end
        
        if modSettings.BuildOnlyTech1 then
            bp.Economy.ProductionPerSecondMass = modSettings.T1Start
            RemoveBuiltByCategories(bp)
        else
            bp.Economy.ProductionPerSecondMass = modSettings.T2Start
        end
    end
    
        
    for unusedArrayIndex, bp in mexunits.TECH3 do
        --# This next line allows us to restrict upgrades
        --# by (perhaps conditionally) removing the upgrade from the build menu
        table.insert(bp.Categories, 'BUILTBYTECH2MASSFAB' .. string.upper(bp.General.FactionName))
        --# Add MassProductionGrowthConstant to BP according to tech level
        if not bp.Economy.MassProductionGrowthConstant then
            bp.Economy.MassProductionGrowthConstant = modSettings.T3GrowthConstant 
        end
        --# T3 is highest level so put cap on instead of autoupgrade
        if not bp.Economy.MaxProductionPerSecondMass then 
            bp.Economy.MaxProductionPerSecondMass = modSettings.T3Cap  
        end
        --# See comments on similar block of code above
        if modSettings.BuildOnlyTech1 then
            bp.Economy.ProductionPerSecondMass = modSettings.T1Start
            RemoveBuiltByCategories(bp)
        else
            bp.Economy.ProductionPerSecondMass = modSettings.T3Start
        end
    end
    

    for techId, techGroup in mexunits do
        for unusedArrayIndex, bp in techGroup do
            local faction = string.upper(bp.General.FactionName)
            if faction == "AEON" then
                --# This is for the auto-defend ability
                bp.General.ToggleCaps.RULEUTC_ShieldToggle = false  
            end
        end
    end
    
end

end --(end of non-destructive hook)