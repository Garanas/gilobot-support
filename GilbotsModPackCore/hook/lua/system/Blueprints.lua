do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#** Hook File:  /lua/system/blueprints.lua
--#**
--#** Modded By:  Gilbot-X
--#**             Updated for FA on Dec 11 2008
--#**
--#** Changes:
--#**    Cloak effect code added. 
--#**    Exponential Hydrocarbon Power Plants (HCPP) code added.
--#**    Factory Toggles code added.
--#**    Auto-toggle code added.
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
    --# and was part of the 'Transparent Cloak' mod.
    for id,bp in all_blueprints.Unit do
        --# This function is defined below
        --# as part of cloak effect mod
        ExtractCloakMeshBlueprint(bp)
    end
    
    --# This function is defined below
    --# for improving Mex animations
    ModMassExtractorAnimations(all_blueprints.Unit)
    
    --# This function is defined below
    --# for my seabed economy
    AllowStructuresToBeBuiltOnWaterOrOnSeabed(all_blueprints.Unit)
    
    --# This function is defined below
    --# and was part of the 'Factory Toggles' mod.
    GiveAllTogglesToFactories(all_blueprints.Unit)
    
    --# These functions are defined below
    --# and are part of my 'Auto Toggle' code.
    GiveDefaultsToAutoToggleUnits(all_blueprints.Unit)
    ModATControllers(all_blueprints.Unit)
     
    --# These functions are defined below
    --# for the 'Resource Network' code.
    GiveDirectFireOverlayToRemotePipelines(all_blueprints.Unit)
    ModACUs(all_blueprints.Unit)
    GiveRemoteAdjacencyToSonar(all_blueprints.Unit)
    
    --# This function is defined below
    --# and for the 'Stat Sliders' code.
    GiveExtraOverlayToCounterIntelFieldUnits(all_blueprints.Unit)
    
    --# This function is defined below 
    --# and is just a preference I have
    DontShowLifeBarsOnWalls(all_blueprints.Unit)
    
    --# This function is defined below 
    --# and allows 4th Dimension tarmacs to be used
    --ChangeTarmacs(all_blueprints.Unit)
    
    --# This function is defined below 
    --# and allows 4th Dimension large trees to be used
    MakeTreesBigger(all_blueprints.Prop)
    
     --# This function is defined below 
    --# and makes wreckage take longer to reclaim
    ModWreckage(all_blueprints.Unit)
    
    --# This function is defined below and makes
    --# SACUs more useful as they are needed to build T4 units
    ExperimentalsNotPartOfT3EngineeringSuite(all_blueprints.Unit)

    --# This function is used to make certain planes
    --# untargettable by certain types of AA.
    GiveT1AAStealthToT3ASFs(all_blueprints.Unit)
end
    
   


--#*
--#*  Gilbot-X says:
--#*
--#*  This is called to change wreckage to 
--#*  those used in 4th Dimension mod.
--#*  It makes it slower to reclaim and it 
--#*  provides less mass.
--#**    
function ModWreckage(all_bps) 
    for id,bp in all_bps do   
        if bp.Wreckage then
            --bp.Wreckage.MassMult = bp.Wreckage.MassMult * 0.4
            bp.Wreckage.ReclaimTimeMultiplier = 8
        end
    end
end
   
--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  I prefer that walls don't show lifebars.
--#*  You can still check the HP of a wall when selecting
--#*  it and looking at the units details panel in the UI.
--#**
function GiveRemoteAdjacencyToSonar(all_bps) 

    --# Put all the unit blueprints for walls into an array.
    local sonarUnits = {
        all_bps['urb3102'], 
        all_bps['urb3202'],
        all_bps['urs0305'],
    }
    for arrayIndex, bp in sonarUnits do
        bp.AdjacencySettings = {
            AdjacencyExtensionDistance = 20,
            AdjacencyExtensionDistanceMin = 10,
            AdjacencyExtensionDistanceMax = 20,
        }
        bp.SliderAdjustableValues = {
            AdjacencyExtensionDistance = {
                DisplayText = 'Adjacency range',
                BPDefaultValueLocation = {'AdjacencySettings'},
                BPDefaultValueName = 'AdjacencyExtensionDistance',
                ResourceDrainID = 'Production',
                UpdateConsumptionImmediately = true,
            },
        }
        bp.Weapon = {
            {
                Label = 'AdjacencyRange',
                MaxRadius = 20,
                RangeCategory = 'UWRC_DirectFire',
                DummyWeapon = true,
            },
        }
        bp.Economy.ResourceDrainBreakDown = {
            Adjacency = {
                Energy = 10,
                Mass = 0,
            },
            Intel = {
                Energy = bp.Economy.MaintenanceConsumptionPerSecondEnergy,
                Mass = 0,
            },
        }
        --# Add order buttons
        if not bp.General.ToggleCaps then bp.General.ToggleCaps = {} end
        bp.General.ToggleCaps.RULEUTC_ProductionToggle = true
        --# Use custom bitmap for order button
        if not bp.General.OrderOverrides then bp.General.OrderOverrides = {} end
        bp.General.OrderOverrides.RULEUTC_ProductionToggle = {
            bitmapId = 'remote-adjacency',
            helpText = 'toggle_remote_adjacency',
        }
        table.insert(bp.Categories, 'OVERLAYDIRECTFIRE')
    end
end


--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  I prefer that walls don't show lifebars.
--#*  You can still check the HP of a wall when selecting
--#*  it and looking at the units details panel in the UI.
--#**
function DontShowLifeBarsOnWalls(all_bps) 

    --# Put all the unit blueprints for walls into an array.
    local walls = {
        all_bps['uab5101'], 
        all_bps['ueb5101'], 
        all_bps['urb5101'],
        all_bps['xsb5101'], 
    }
    
    --# Give each factory these 6 toggles.
    for arrayIndex, bp in walls do
        bp.LifeBarRender = false
    end
end




--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  for my mod Factory Toggles.
--#*  Each factory unit gets 6 toggles
--#*  that can be used to set intel/shield etc
--#*  on units coming out of the factory.
--#**
function GiveAllTogglesToFactories(all_bps) 

    --# Put all the unit blueprints for factories into an array.
    local factories = {
        all_bps['uab0101'], all_bps['uab0102'], all_bps['uab0103'], 
        all_bps['uab0201'], all_bps['uab0202'], all_bps['uab0203'],
        all_bps['uab0301'], all_bps['uab0302'], all_bps['uab0303'], all_bps['uab0304'],
        
        all_bps['ueb0101'], all_bps['ueb0102'], all_bps['ueb0103'], 
        all_bps['ueb0201'], all_bps['ueb0202'], all_bps['ueb0203'],
        all_bps['ueb0301'], all_bps['ueb0302'], all_bps['ueb0303'], all_bps['ueb0304'],
        
        all_bps['urb0101'], all_bps['urb0102'], all_bps['urb0103'], 
        all_bps['urb0201'], all_bps['urb0202'], all_bps['urb0203'],
        all_bps['urb0301'], all_bps['urb0302'], all_bps['urb0303'], all_bps['urb0304'],
        
        all_bps['xsb0101'], all_bps['xsb0102'], all_bps['xsb0103'], 
        all_bps['xsb0201'], all_bps['xsb0202'], all_bps['xsb0203'],
        all_bps['xsb0301'], all_bps['xsb0302'], all_bps['xsb0303'], all_bps['xsb0304'],
    }
    
    --# Give each factory these 6 toggles.
    for arrayIndex, bp in factories do
        bp.General.ToggleCaps = {
            RULEUTC_CloakToggle = true,
            RULEUTC_StealthToggle = true,
            RULEUTC_IntelToggle = true,
            RULEUTC_ShieldToggle = true,
            RULEUTC_JammingToggle = true,
            RULEUTC_WeaponToggle = true,
        }
    end
end




--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  for my AutoToggle units.
--#*  The Weapon toggle gets used with a new custom button 
--#*  to toggle ACU auto-toggle on and off.
--#**
function GiveDefaultsToAutoToggleUnits(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local autoToggleSettings = {
    
        --# AEON UNITS
        --# Mex
        uab1103 = {Construction=2},
        uab1202 = {Construction=2},
        --# Mass fabs
        uab1104 = {Production=1},
        uab1303 = {Production=1}, 
        --# Radar towers
        uab3101 = {Intel=3, Construction=2},
        uab3201 = {Intel=3, Construction=2},
        uab3104 = {Intel=3},
        --# Stationary Sonar
        uab3102 = {Intel=3, Construction=2}, 
        uab3202 = {Intel=3, Construction=2},
        --# Stealth Tower 
        uab4203 = {Stealth=4},
        --# Shield Generators
        uab4202 = {Shield=5},
        uab4301 = {Shield=5},
        --# Engineers
        ual0105 = {Construction=6},
        ual0208 = {Construction=6},
        ual0309 = {Construction=6},
        ual0301 = {Construction=6},
        --# Mobile Units
        ual0307 = {Shield=3},     -- Mobile Shield Generator
        uaa0310 = {Shield=3},     -- Czar
        uac1401b= {Production=3}, -- Shield Strength Enhancer
        uas0305 = {Intel=3},      -- T3 Mobile Sonar
        
        
        --# UEF UNITS
        --# Mex
        ueb1103 = {Construction=2},
        ueb1202 = {Construction=2},
        --# Mass fabs
        ueb1104 = {Production=1},
        ueb1303 = {Production=1},         
        --# Radar towers
        ueb3101 = {Intel=3, Construction=2},
        ueb3201 = {Intel=3, Construction=2},
        ueb3104 = {Intel=3},
        --# Stationary Sonar
        ueb3102 = {Intel=3, Construction=2}, 
        ueb3202 = {Intel=3, Construction=2},
        --# Stealth Tower 
        ueb4203 = {Stealth=4},
        --# Shield Generators
        ueb4202 = {Shield=5, Construction=2},
        ueb4301 = {Shield=5},
        --# Engineering Station
        xeb0204 = {Construction=4},  --Tower
        xea3204 = {Construction=6},  --Pods
        --# Engineers
        uel0105 = {Construction=6},  --T1 Engineer
        uel0208 = {Construction=6},  --T2 Engineer
        xel0209 = {Construction=6},  --T2 Field Engineer
        uel0309 = {Construction=6},  --T3 Engineer
        uel0301 = {Construction=6},  --SCU
        uea0001 = {Construction=6},  --ACU Shoulder Pod
        uea0003 = {Construction=6},  --ACU Shoulder Pod
        --# Mobile Units
        uel0307 = {Shield=3},   -- Mobile Shield Generator
        xes0205 = {Shield=3},   -- Shield Boat
        ues0305 = {Intel=3},    -- T3 Mobile Sonar
        
        --# CYBRAN UNITS
        --# HCPP
        urb1102 = {Stealth=4, Cloak=3},
        --# Mex
        urb1103 = {Stealth=1, Construction=2},
        urb1202 = {Stealth=1, Construction=2},
        urb1302 = {Stealth=1},
        --# Mass fabs
        urb1104 = {Production=1},
        urb1303 = {Production=1}, 
        --# Radar towers
        urb3101 = {Intel=3, Construction=2},
        urb3201 = {Intel=3, Construction=2},
        urb3104 = {Intel=3},
        --# Stationary Sonar
        urb3102 = {Intel=3}, 
        urb3202 = {Intel=3},
        --# Stealth Tower 
        urb4203 = {Stealth=4},
        --# Shield Generators
        urb4202 = {Shield=5, Construction=2},
        urb4204 = {Shield=5, Construction=2},
        urb4205 = {Shield=5, Construction=2},
        urb4206 = {Shield=5, Construction=2},
        urb4207 = {Shield=5},
        --# Engineering Station
        xrb0304 = {Construction=4},  
        --# Engineers
        url0105 = {Construction=6},
        url0208 = {Construction=6},
        url0309 = {Construction=6},
        url0301 = {Construction=6},        
        --# Mobile Units
        url0101 = {Cloak=3},    -- Cloak on T1 Land Scout
        url0306 = {Stealth=4},  -- Mobile Stealth Field Generator
        xrs0205 = {Stealth=3},  -- Stealth Sub Killer boat
        xrs0205 = {Stealth=4},  -- Stealth Field boat
        ura0303 = {Stealth=2},  -- Stealth ASF
        urs0305 = {Intel=3},    -- T3 Mobile Sonar
        
        --# SERAPHIM UNITS
        --# Mex
        xsb1103 = {Construction=2},
        xsb1202 = {Construction=2},
        --# Mass fabs
        xsb1104 = {Production=1},
        xsb1303 = {Production=1},         
        --# Radar towers
        xsb3101 = {Intel=3, Construction=2},
        xsb3201 = {Intel=3, Construction=2},
        xsb3104 = {Intel=3},
        --# Stationary Sonar
        xsb3102 = {Intel=3, Construction=2}, 
        xsb3202 = {Intel=3, Construction=2},
        --# Stealth Tower 
        xsb4203 = {Stealth=4},
        --# Shield Generators
        xsb4202 = {Shield=5, Construction=2},
        xsb4301 = {Shield=5},
        --# Engineers
        xsl0105 = {Construction=6},
        xsl0208 = {Construction=6},
        xsl0309 = {Construction=6},
        xsl0301 = {Construction=6},
        --# Mobile Units
        xsl0307 = {Shield=5},      -- Mobile Shield Generator
        xsc1501b= {Production=3},  -- T3 Resource Network Unifier
    }
    
    --# Give each autotoggleunit the AT toggle button.
    for unitId, vSettingsTable in autoToggleSettings do
        all_bps[unitId].AutoToggleSettings = vSettingsTable
    end
end



--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me for my remote Pipeline units.
--#*  The direct fire weapon overlay allowsplayers to see the range 
--#*  of remote adjacency for the selected pipeline. 
--#**
function AllowStructuresToBeBuiltOnWaterOrOnSeabed(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local UnitBPSeabedList = {
        all_bps['gab5101b'], all_bps['gab5201b'], all_bps['gab5301b'], 
        all_bps['geb5101b'], all_bps['geb5201b'], all_bps['geb5301b'], 
        all_bps['uab1101'], all_bps['ueb1101'], all_bps['urb1101'], all_bps['xsb1101'],
        all_bps['uab1104'], all_bps['ueb1104'], all_bps['urb1104'], all_bps['xsb1104'],
        all_bps['uab1105'], all_bps['ueb1105'], all_bps['urb1105'], all_bps['xsb1105'],
        all_bps['uab1106'], all_bps['ueb1106'], all_bps['urb1106'], all_bps['xsb1106'],
    }
    --# Put all units that autotoggle will work on into an array
    local UnitBPWaterList = {
        all_bps['gab5101'], all_bps['gab5201'], all_bps['gab5301'], 
        all_bps['geb5101'], all_bps['geb5201'], all_bps['geb5301'], 
        all_bps['grb5101'], all_bps['grb5201'], all_bps['grb5301'], all_bps['grb5301b'], 
        all_bps['urb5101g'],
    }

    --# Give each remote pipeline a direct fire weapon
    for arrayIndex, bp in UnitBPSeabedList do
        bp.Physics.BuildOnLayerCaps.LAYER_Seabed = true
         bp.General.Icon = 'amph'
    end
    --# Give each remote pipeline a direct fire weapon
    for arrayIndex, bp in UnitBPWaterList do
        bp.Physics.BuildOnLayerCaps.LAYER_Water = true
         bp.General.Icon = 'amph'
    end
    
    local UnitBPSeaIconList = {
        all_bps['gab5101b'], all_bps['gab5201b'], all_bps['gab5301b'], 
        all_bps['geb5101b'], all_bps['geb5201b'], all_bps['geb5301b'], 
    }
    --# Give each remote pipeline a direct fire weapon
    for arrayIndex, bp in UnitBPSeaIconList do
        bp.General.Icon = 'sea'
    end
    --# Put all units that we will work on into an array
    local T1Pipelines = {
        all_bps['grb5101'], all_bps['geb5101'], all_bps['gab5101'], 
    }
     --# Give each remote pipeline a direct fire weapon
    for arrayIndex, bp in T1Pipelines do
        bp.Physics.MaxGroundVariation = 1000
    end
    

end




--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me for my remote Pipeline units.
--#*  The direct fire weapon overlay allowsplayers to see the range 
--#*  of remote adjacency for the selected pipeline. 
--#**
function GiveDirectFireOverlayToRemotePipelines(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local remotePipelineUnits = {
        all_bps['gab5201b'], all_bps['gab5301b'], 
        all_bps['geb5201b'], all_bps['geb5301b'], 
        all_bps['gab5201'], all_bps['gab5301'], 
        all_bps['geb5201'], all_bps['geb5301'], 
        all_bps['grb5201'], all_bps['grb5301'], all_bps['grb5301b'],
    }

    --# Give each remote pipeline a direct fire weapon
    for arrayIndex, bp in remotePipelineUnits do
        
        --# Make sure BP has a weapon table
        if not bp.Weapon then bp.Weapon = {} end
        --# Just make sure we start at maximum setting
        bp.AdjacencySettings.AdjacencyExtensionDistance =
            bp.AdjacencySettings.AdjacencyExtensionDistanceMax
        local newWeaponBp = {
            Label = 'AdjacencyRange',
            DummyWeapon = true,
            RangeCategory = 'UWRC_DirectFire',
            MaxRadius = bp.AdjacencySettings.AdjacencyExtensionDistance,
        }
        table.insert(bp.Weapon, newWeaponBp)
        table.insert(bp.Categories, 'OVERLAYDIRECTFIRE')
        bp.General.SelectionPriority = 4
        
        --# Add order buttons
        if not bp.General.ToggleCaps then bp.General.ToggleCaps = {} end
        bp.General.ToggleCaps.RULEUTC_ProductionToggle = true
        --# Use custom butmap for order button
        if not bp.General.OrderOverrides then bp.General.OrderOverrides = {} end
        bp.General.OrderOverrides.RULEUTC_ProductionToggle = {
            bitmapId = 'remote-adjacency',
            helpText = 'toggle_remote_adjacency',
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
function ModACUs(all_bps) 
    --# Put all ACU BPs into an array
    local ACUs = {
        all_bps['uel0001'],
        all_bps['url0001'], 
        all_bps['xsl0001'], 
        all_bps['ual0001'],
    }
    
    --# For each faction's ACU
    for arrayIndex, bp in ACUs do
        --# Add custom AT and Adj order buttons
        if not bp.General.ToggleCaps then bp.General.ToggleCaps = {} end
        bp.General.ToggleCaps.RULEUTC_ProductionToggle = true
        --# Use custom butmap for order button
        if not bp.General.OrderOverrides then bp.General.OrderOverrides = {} end
        bp.General.OrderOverrides.RULEUTC_ProductionToggle = {
            bitmapId = 'remote-adjacency',
            helpText = 'toggle_remote_adjacency_acu',
        }
        --# Protect ACU T3 Engineering Suite 
        --# upgrade from accidental downgrades to the T2 version
        bp.Enhancements.T3Engineering.CannotDowngradeToPrerequisites = true
    end
end
    
    
    
--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me for my AT units.
--#*
--#**
function ModATControllers(all_bps) 
    
    local ATControllers = {
        all_bps['uac1501b'],
        all_bps['uec1301b'],
        all_bps['urc1101b'], 
        all_bps['xsc1301b'], 
    }
    
    --# For each faction's ACU
    for arrayIndex, bp in ATControllers do

        --# Add custom AT and Adj order buttons
        if not bp.General.ToggleCaps then bp.General.ToggleCaps = {} end
        bp.General.ToggleCaps.RULEUTC_WeaponToggle = true
        --# Give each ACU a different tooltip for its AT toggle button
        --# because its purpose is different in the ACU
        if not bp.General.OrderOverrides then bp.General.OrderOverrides = {} end
        bp.General.OrderOverrides.RULEUTC_WeaponToggle = {
            bitmapId = 'auto-toggle',
            helpText = 'toggle_auto_toggle_controller',
        }
    
        --# Give each AT Controller slider 
        --# controls to adjust thresholds for C=3
        --# and the override for massfabs
        bp.SliderAdjustableValues = {
            AutoToggleClass3Threshold = {
                DisplayText = 'AT Class 3 Threshold',
                BPDefaultValueLocation = {'AutoToggleThresholds'},
                BPDefaultValueName = 'Class3',
                ResourceDrainID = nil,
                UpdateConsumptionImmediately = false,
            },
            AutoToggleMassFabThreshold = {
                DisplayText = 'AT MassFab Threshold',
                BPDefaultValueLocation = {'AutoToggleThresholds'},
                BPDefaultValueName = 'MassFabs',
                ResourceDrainID = nil,
                UpdateConsumptionImmediately = false,
            },
            EnergyReserve = {
                DisplayText = 'AT Energy Reserve',
                BPDefaultValueLocation = {'AutoToggleThresholds'},
                BPDefaultValueName = 'EnergyReserve',
                ResourceDrainID = nil,
                UpdateConsumptionImmediately = false,
            },
            MassReserve = {
                DisplayText = 'AT Mass Reserve',
                BPDefaultValueLocation = {'AutoToggleThresholds'},
                BPDefaultValueName = 'MassReserve',
                ResourceDrainID = nil,
                UpdateConsumptionImmediately = false,
            },
        }
        
        --# Set default, min and max for sliders
        bp.AutoToggleThresholds = {
            Class3 = 0.50,
            Class3Min = 0.25,
            Class3Max = 0.90,
            MassFabs = 0.5,
            MassFabsMin = 0.05,
            MassFabsMax = 0.99,
            EnergyReserve = 100,
            EnergyReserveMin = 0,
            EnergyReserveMax = 5000,
            MassReserve = 30,
            MassReserveMin = 0,
            MassReserveMax = 200,
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
function GiveExtraOverlayToCounterIntelFieldUnits(all_bps) 

    --# Give each remote pipeline a direct fire weapon
    for unitId, bp in all_bps do
        --# Do it for units with stealth field.  This appears red
        if bp.Intel.RadarStealthFieldRadius > 0 then 
            if not bp.Weapon then bp.Weapon = {} end
            local newDummyDirectFireWeaponBp = {
                MaxRadius = bp.Intel.RadarStealthFieldRadius,
                Label = 'RadarStealthFieldRadius',
                RangeCategory = 'UWRC_DirectFire',
                DummyWeapon = true,
            }
            table.insert(bp.Weapon, newDummyDirectFireWeaponBp)
            table.insert(bp.Categories, 'OVERLAYDIRECTFIRE')
        end
        --# Now do it for units with cloak field.  This appears yellow
        if bp.Intel.CloakFieldRadius > 0 then 
            if not bp.Weapon then bp.Weapon = {} end
            local newDummyIndirectFireWeaponBp = {
                MaxRadius = bp.Intel.CloakFieldRadius,
                Label = 'CloakFieldRadius',
                RangeCategory = 'UWRC_IndirectFire',
                DummyWeapon = true,
            }
            table.insert(bp.Weapon, newDummyIndirectFireWeaponBp)
            table.insert(bp.Categories, 'OVERLAYINDIRECTFIRE')
        end
    end
end


--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by Covert Jaguar 
--#*  for his mod Transparent Cloak Effect.
--#*  Each unit gets a new blueprint mesh table 
--#*  (name has a _cloak suffix) that points to
--#*  a semitransparent mesh normally used for 
--#*  formation previews.
--#**
function ExtractCloakMeshBlueprint(bp)
    local meshid = bp.Display.MeshBlueprint
    if not meshid then return end

    local meshbp = original_blueprints.Mesh[meshid]
    if not meshbp then return end

    local shadername = 'UnitFormationPreview'

    local cloakmeshbp = table.deepcopy(meshbp)
    if cloakmeshbp.LODs then
        for i,lod in cloakmeshbp.LODs do
            lod.ShaderName = shadername
        end
    end
    cloakmeshbp.BlueprintId = meshid .. '_cloak'
    bp.Display.CloakMeshBlueprint = cloakmeshbp.BlueprintId
    MeshBlueprint(cloakmeshbp)
end

        
        

--#*
--#*  Gilbot-X says:
--#*
--#*  Mass production of mass extractors increases over time.
--#*  Makes holding mass extractors more important relative to 
--#*  mass fabricators and makes game more territorial.
--#** 
function ModMassExtractorAnimations(all_bps) 

    local mexunits = {
        TECH1 = {all_bps['uab1103'], all_bps['ueb1103'], all_bps['urb1103'], all_bps['xsb1103'],},
        TECH2 = {all_bps['uab1202'], all_bps['ueb1202'], all_bps['urb1202'], all_bps['xsb1202'],},
        TECH3 = {all_bps['uab1302'], all_bps['ueb1302'], all_bps['urb1302'], all_bps['xsb1302'],},
    }
    
    --# Rename inconsistently named blueprint key 
    --# that points to animation files
    for techId, techGroup in mexunits do
        for unusedArrayIndex, bp in techGroup do
            local faction = string.upper(bp.General.FactionName)
            if faction == "UEF" then
                --# Rename inconsistently named blueprint key 
                --# that points to animation files
                bp.Display.AnimationActivate = bp.Display.AnimationOpen
                
            elseif faction == "CYBRAN" then
                --# Rename inconsistently named blueprint key 
                --# that points to animation files
                bp.Display.AnimationActivate = bp.Display.AnimationOpen
            end
        end
    end
    
end
    
    
--#*
--#*  Gilbot-X says:
--#*
--#*  This is called by ModMassExtractors above
--#*  to stop T2 and T3 Mass extractors from being built
--#*  (that's a mod option).
--#**    
function RemoveBuiltByCategories(bp) 
    local newCategories = {}
    for k,v in bp.Categories do
        if not (
          string.find(v, 'BUILTBY') 
          and (
              string.find(v, 'ENGINEER') 
           or string.find(v, 'COMMANDER')
          ) 
        )              
        then
            table.insert(newCategories, v)
        else 
            --LOG("Exponential Mass mod: Removed cat " .. v)
        end
    end
    bp.Categories= newCategories
end
    

    
--#*
--#*  Gilbot-X says:
--#*
--#*  This is called to change tree sizes to 
--#*  those used in 4th Dimension mod.
--#**    
function MakeTreesBigger(all_bps) 
    for id,bp in pairs(all_bps) do
        if bp.ScriptClass == 'Tree' then
            bp.Display.UniformScale = bp.Display.UniformScale * 2.0
            bp.SizeX = bp.SizeX * 2 
            bp.SizeY = bp.SizeY * 2
            bp.SizeZ = bp.SizeZ * 2     	    
        end
         if bp.ScriptClass == 'TreeGroup' then
            bp.Display.UniformScale = bp.Display.UniformScale * 1.5
            bp.SizeX = bp.SizeX * 1.3 
            bp.SizeY = bp.SizeY * 1.3
            bp.SizeZ = bp.SizeZ * 1.3
        end
    end
end
        
    
--#*
--#*  Gilbot-X says:
--#*
--#*  This is called to change tarmacs to 
--#*  those used in 4th Dimension mod.
--#**    
function ChangeTarmacs(all_bps) 
    for id,bp in all_bps do
        local civilian = 0
        if bp.Display.Tarmacs then 
            for i,v in pairs(bp.Categories) do 
                if v == 'CIVILIAN' then 
                    civilian = 1
                end
            end
            for i,v in pairs(bp.Categories) do 
                if v == 'UEF' and civilian == 0 then 
                    bp.Display.Tarmacs[1].Length = bp.Display.Tarmacs[1].Length * 2
                    bp.Display.Tarmacs[1].Width = bp.Display.Tarmacs[1].Width * 2
                    bp.Display.Tarmacs[1].FadeOut = 900
                end 
                if v == 'CYBRAN' and civilian == 0 then
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar12x_cybran_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar12x_01_albedo_cybran.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar12x_01_normals'
                        end
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar6x_cybran_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar6x_01_albedo_cybran.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar6x_01_normals'
                    end
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar8x_cybran_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar8x_01_albedo_cybran.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar8x_01_normals'
                    end
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar10x_cybran_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar10x_01_albedo_cybran.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar10x_01_normals'
                    end
                    bp.Display.Tarmacs[1].Length = bp.Display.Tarmacs[1].Length * 2
                    bp.Display.Tarmacs[1].Width = bp.Display.Tarmacs[1].Width * 2 
                    bp.Display.Tarmacs[1].FadeOut = 900    
                end     
                if v == 'AEON' and civilian == 0 then
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar12x_aeon_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar12x_01_albedo_aeon.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar12x_01_normals'
                    end
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar6x_aeon_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar6x_01_albedo_aeon.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar6x_01_normals'
                    end
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar8x_aeon_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar8x_01_albedo_aeon.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar8x_01_normals'
                    end
                    if bp.Display.Tarmacs[1].Albedo == 'Tarmacs/Tar10x_aeon_01_albedo'
                        then bp.Display.Tarmacs[1].Albedo = '/mods/4th_Dimension_195/hook/env/Common/decals/Tarmacs/Tar10x_01_albedo_aeon.dds'
                            bp.Display.Tarmacs[1].Normal = 'Tarmacs/Tar10x_01_normals'
                    end
                    bp.Display.Tarmacs[1].Length = bp.Display.Tarmacs[1].Length * 2
                    bp.Display.Tarmacs[1].Width = bp.Display.Tarmacs[1].Width * 2 
                    bp.Display.Tarmacs[1].FadeOut = 900    
                end 
            end
        end  
    end        
end 


--#*
--#*  Gilbot-X says:
--#*
--#*  This is called to make sure 
--#*  experimentals can only be built by SACUs
--#*  or an upgraded ACU 
--#**    
function ExperimentalsNotPartOfT3EngineeringSuite(all_bps) 
    --# Give all ACUs and SACUs T4 Category
    table.insert(all_bps['xsl0001'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER SERAPHIM')
    table.insert(all_bps['xsl0301'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER SERAPHIM')
    table.insert(all_bps['ual0001'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER AEON')
    table.insert(all_bps['ual0301'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER AEON')
    table.insert(all_bps['uel0001'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER UEF')
    table.insert(all_bps['uel0301'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER UEF')
    table.insert(all_bps['url0001'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER CYBRAN')
    table.insert(all_bps['url0301'].Economy.BuildableCategory,'BUILTBYTIER4COMMANDER CYBRAN')
    
    local experimentalList = {}
    for id,bp in all_bps do
        for i,v in pairs(bp.Categories) do 
            if v == 'EXPERIMENTAL' then
                experimentalList[id] = bp
            end
        end
    end
    for id,bp in experimentalList do
        ChangeT3BuiltByCategoriesToT4(bp)
    end
end

    
--#*
--#*  Gilbot-X says:
--#*
--#*  This is called by ExperimentalsNotPartOfT3EngineeringSuite above
--#*  to stop T4 units from being built by T3 Engineers
--#**    
function ChangeT3BuiltByCategoriesToT4(bp) 
    local newCategories = {}
    for k,v in bp.Categories do
        if  string.find(v, 'BUILTBYTIER3ENGINEER') then
            --table.insert(newCategories, 'BUILTBYTIER4COMMANDER')
        elseif string.find(v, 'BUILTBYTIER3COMMANDER') then
            table.insert(newCategories, 'BUILTBYTIER4COMMANDER')
        else 
            table.insert(newCategories, v)
        end
    end
    bp.Categories= newCategories
end



--#* 
--#*  Gilbot-X says:
--#* 
--#*  AA stealth prevents certain planes from
--#*  being targetted by certain types of AA unit.
--#*  Units must be built with it as categories
--#*  cannot be added.  If a unit adds this as
--#*  an enhancement or upgrade then there must
--#*  be a unit replacement.  Must force planes to
--#*  land for this in that case, or have a more
--#*  expensive version that can be built in factories. 
--#**
function GiveT1AAStealthToT3ASFs(all_bps) 
    local T1AAUnits = {
        all_bps['uab2104'], 
        all_bps['ueb2104'],
        all_bps['urb2104'],
        all_bps['xsb2104'],
        all_bps['ual0104'], 
        all_bps['uel0104'],
        all_bps['url0104'],
        all_bps['xsl0104'],
    }
    local T2AAUnits = {
        all_bps['uab2204'], 
        all_bps['ueb2204'],
        all_bps['urb2204'],
        all_bps['xsb2204'],
        all_bps['ual0205'], 
        all_bps['uel0205'],
        all_bps['url0205'],
        all_bps['xsl0205'],
    }
    local T1T2AAAirUnits = {
        all_bps['uaa0102'], 
        all_bps['uea0102'],
        all_bps['ura0102'],
        all_bps['xsa0102'],
        all_bps['dea0202'],
        all_bps['dra0202'],
        all_bps['xsa0202'],
        all_bps['xaa0202'],
    }

    --# Apply targetting restriction to Air Units
    --# So they cannot attack space ships
    for unitId, bp in T1T2AAAirUnits do
        --# Do it for units with stealth field.  This appears red
        for arrayIndex, weaponBp in bp.Weapon do
            if weaponBp.TargetRestrictDisallow then
                --# Append to the existing field.
                weaponBp.TargetRestrictDisallow = 
                    weaponBp.TargetRestrictDisallow .. ',SPACESHIPS'
            else
                --# Add this field to unit.
                weaponBp.TargetRestrictDisallow = 'SPACESHIPS'
            end
        end
    end
    
    --# Apply targetting restriction to AA units
    for unitId, bp in T1AAUnits do
        --# Do it for units with stealth field.  This appears red
        for arrayIndex, weaponBp in bp.Weapon do
            if weaponBp.TargetRestrictDisallow then
                weaponBp.TargetRestrictDisallow = 
                    weaponBp.TargetRestrictDisallow .. ',T1AASTEALTH,SPACESHIPS'
            end
        end
    end
    --# Apply targetting restriction to AA units
    for unitId, bp in T2AAUnits do
        --# Do it for units with stealth field.  This appears red
        for arrayIndex, weaponBp in bp.Weapon do
            if weaponBp.TargetRestrictDisallow then
                weaponBp.TargetRestrictDisallow = 
                    weaponBp.TargetRestrictDisallow .. ',T2AASTEALTH,SPACESHIPS'
            end
        end
    end
    
    --# Gilbot-X says:
    --# I left this here just as an example.
    local T1AAStealthAirUnits = {
        --all_bps['ura0303'], --# Cybran T3 ASF
    }
    --# Give the planes this new ability
    for unitId, bp in T1AAStealthAirUnits do
        table.insert(bp.Categories, 'T1AASTEALTH')
    end
end

end --(end of non-destructive hook)