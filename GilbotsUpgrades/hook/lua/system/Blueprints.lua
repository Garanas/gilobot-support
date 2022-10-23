do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#** Hook File:  /lua/system/blueprints.lua
--#**
--#** Modded By:  Gilbot-X
--#**             Updated for FA on Nov 27 2008
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
    --# and was part of the 'Auto Toggle' mod.
    GiveDefaultsToMilitaryUpgradeAutoToggleUnits(all_blueprints.Unit)
    
    --# This function is defined below and makes
    --# LABs more useful by allowing weapon ROF and range changes
    GiveFiringRadiusSliderAndChargeWeaponToUnits(all_blueprints.Unit)
end
 
 
 
 
--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  for my AutoToggle units.
--#*  The Weapon toggle gets used with a new custom button 
--#*  to toggle ACU auto-toggle on and off.
--#**
function GiveDefaultsToMilitaryUpgradeAutoToggleUnits(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local autoToggleSettings = {
    
        --# Cpnstruction is for units that 
        --# upgrade or have enhancements
        ual0101 = {Construction=3}, --T1 Scout enhancements + upgrades
        url0101 = {Construction=3}, --T1 Scout upgrades
        url0101b= {Construction=3}, --T1 Scout upgrades
        xsl0101 = {Construction=3}, --T1 Scout enhancements + upgrades
        url0306 = {Construction=3}, --Deceiver upgrades
        url0306b= {Stealth = 4, Cloak=5},--New Deceiver upgrade has cloak
        xrl0302 = {Construction=3, Cloak=4}, --Firebeetle enhancements + upgrades
        xrl0302b= {Cloak=4},  --Firebeetle upgrade has cloak enhancement
        xea0002  = {Construction=4},--Satellite enhancements + upgrades
        xea0002b = {Construction=4},--Satellite enhancements + upgrades
        xea0002c = {Construction=4},--Satellite enhancements + upgrades
        ura0303  = {Stealth=3}, --Cybran ASF can upgrade 
        ura0303b = {Stealth=3}, --New Cybran ASF upgrade has stealth
    }
    
    --# Give each autotoggleunit the AT toggle button.
    for unitId, vSettingsTable in autoToggleSettings do
        --# Do a table merge, not an overrwite
        if not all_bps[unitId].AutoToggleSettings then
            all_bps[unitId].AutoToggleSettings = {}
        end
        for kType, vDefaultClass in vSettingsTable do
            all_bps[unitId].AutoToggleSettings[kType]=vDefaultClass
        end
    end
end


--#* 
--#*  Gilbot-X says:
--#* 
--#*  Called by GiveFiringRadiusSliderAndChargeWeaponToUnits
--#*  which is defined below. (Also from Upgrades2 mod).
--#**    
function AddRateOfFireSlider(bp)
    --# Do a table merge, not an overwrite
    if not bp.SliderAdjustableValues then bp.SliderAdjustableValues = {} end
    bp.SliderAdjustableValues.RateOfFire = {
        DisplayText = 'Main Weapon Range',
        BPDefaultValueLocation = {'Weapon', 1},
        BPDefaultValueName = 'MaxRadius',
        ResourceDrainID = nil,
        UpdateConsumptionImmediately = false,
        VariableNameInUnit = 'MainWeaponRange',
    }
    --# Put the Min and Max vals next to the default val
    bp.Weapon[1].MaxRadiusMax = bp.Weapon[1].MaxRadius
    --# This next line can be changed to decide how much 
    --# the range can be reduced and ROF increased.  This factor is 2.
    bp.Weapon[1].MaxRadiusMin = math.ceil(bp.Weapon[1].MaxRadius / 2)
end



--#* 
--#*  Gilbot-X says:
--#* 
--#*  This table is for a dummy weapon needed so LABs cab charge
--#*  at units that are out of range of their main weapon.
--#*  This table is only used by the function defined below it.
--#**
local chargingWeaponBP = {
    AboveWaterTargetsOnly = true,
    CollideFriendly = false,
    Damage = 1,
    DamageFriendly = false,
    DamageRadius = 1,
    DamageType = 'Normal',
    DisplayName = 'Charge',
    FireTargetLayerCapsTable = {
        Land = 'Land',
    },
    FiringTolerance = 2,
    Label = 'Charge',
    MaxRadius = 30,
    MaxRadiusMin = 18,
    MaxRadiusMax = 50,
    RangeCategory = 'UWRC_IndirectFire',
    TargetCheckInterval = 1,
    TargetPriorities = {
        'SPECIALHIGHPRI',
        'MOBILE',
        'STRUCTURE DEFENSE',
        'SPECIALLOWPRI',
        'ALLUNITS',
    },
    TargetRestrictDisallow = 'UNTARGETABLE',
    Turreted = false,
    WeaponCategory = 'Kamikaze',
}


--#* 
--#*  Gilbot-X says:
--#* 
--#*  Called by GiveFiringRadiusSliderAndChargeWeaponToUnits
--#*  which is defined below.  (Also from Upgrades2 mod).
--#**
function AddChargeWeaponAndSlider(bp)
    --# Do a table merge, not an overwrite
    if not bp.SliderAdjustableValues then bp.SliderAdjustableValues = {} end
    bp.SliderAdjustableValues.ChargingRange = {
        DisplayText = 'Charging Range',
        BPDefaultValueLocation = {'Weapon', 2},
        BPDefaultValueName = 'MaxRadius',
        ResourceDrainID = nil,
        UpdateConsumptionImmediately = false,
        VariableNameInUnit = 'ChargingRange', 
    }
    --# Add charging range weapon for LABs
    table.insert(bp.Weapon, 2, chargingWeaponBP)
    
    --# Add "Charge" order button to unit
    if not bp.General.ToggleCaps then bp.General.ToggleCaps = {} end
    bp.General.ToggleCaps.RULEUTC_ProductionToggle = true
    --# Use custom bitmap for order button
    if not bp.General.OrderOverrides then bp.General.OrderOverrides = {} end
    bp.General.OrderOverrides.RULEUTC_ProductionToggle = {
        bitmapId = 'charge',
        helpText = 'toggle_charge',
    }
end



--#* 
--#*  Gilbot-X says:
--#* 
--#*  I added this to make some T1 units more useful.
--#*  It adds a slider control for the main weapon.
--#*  You can double its rate of fire if you halve its range.
--#*  There is also a dummy weapon that achieves targeting
--#*  of units outside of the range of the units main weapons,
--#*  by causing the unit to advance towards it until it is in 
--#*  range. This significantly reduces micro-management.
--#**
function GiveFiringRadiusSliderAndChargeWeaponToUnits(all_bps) 

    --# Put all the unit blueprints for LABs into an array.
    local LABs = {
        all_bps['xsl0101'],
        all_bps['xsl0101b'],
    }
    local T1PDs = {
        --# Give to T1 PDs too
        all_bps['uab2101'],
        all_bps['ueb2101'],
        all_bps['urb2101'],
        all_bps['xsb2101'],
    }
    local Bombs = {
        all_bps['xrl0302'],
        all_bps['xrl0302b'],
    }
 
    for _, bp in T1PDs do
        AddRateOfFireSlider(bp)
    end
    
    --# LABs are mobile so they also get a charging range slider
    for _, bp in LABs do
        AddRateOfFireSlider(bp)
        AddChargeWeaponAndSlider(bp)
    end
    
    --# This unit gets an individual factor value of 1.5
    all_bps['ueb2101'].Weapon[1].MaxRadiusMin = 
        math.ceil(all_bps['ueb2101'].Weapon[1].MaxRadius / 1.5)
        
    --# Bombs get a charging range button and slider
    for _, bp in Bombs do
        AddChargeWeaponAndSlider(bp)
    end
end

end --(end of non-destructive hook)