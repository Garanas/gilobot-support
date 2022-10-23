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
    GiveDefaultsToMilitaryUpgrade2AutoToggleUnits(all_blueprints.Unit)
    
    --# This function is defined below and makes
    --# LABs more useful by allowing weapon ROF and range changes
    GiveFiringRadiusSliderAndChargeWeaponToUnits2(all_blueprints.Unit)
end
 
 
 
 
--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  for my AutoToggle units.
--#*  The Weapon toggle gets used with a new custom button 
--#*  to toggle ACU auto-toggle on and off.
--#**
function GiveDefaultsToMilitaryUpgrade2AutoToggleUnits(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local autoToggleSettings = {
        --# LABs
        ual0106 = {Shield=3, Construction=3},   
        uel0106 = {Shield=3, Construction=3},   
        url0106 = {Cloak=3, Construction=3}, 
        ual0106b = {Shield=3},   
        uel0106b = {Shield=3},   
        url0106b = {Cloak=3},
    }
    
    --# Give each AT unit the default priority class.
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
--#*  I added this to make some T1 units more useful.
--#*  It adds a slider control for the main weapon.
--#*  You can double its rate of fire if you halve its range.
--#*  There is also a dummy weapon that achieves targeting
--#*  of units outside of the range of the units main weapons,
--#*  by causing the unit to advance towards it until it is in 
--#*  range. This significantly reduces micro-management.
--#**
function GiveFiringRadiusSliderAndChargeWeaponToUnits2(all_bps) 

    --# Put all the unit blueprints for LABs into an array.
    local LABs = {
        all_bps['ual0106'],
        all_bps['ual0106b'],
        all_bps['uel0106'],
        all_bps['uel0106b'],
        all_bps['url0106'], 
        all_bps['url0106b'], 
    }
      
    --# LABs are mobile so they also get a charging range slider
    for arrayIndex, bp in LABs do
        AddRateOfFireSlider(bp)
        AddChargeWeaponAndSlider(bp)
    end
end

end --(end of non-destructive hook)