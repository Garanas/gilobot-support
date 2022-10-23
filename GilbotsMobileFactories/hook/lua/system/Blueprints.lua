do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#** Hook File:  /lua/system/blueprints.lua
--#**
--#** Modded By:  Gilbot-X
--#**
--#** Changes:
--#**    Gives extra button to mobile factories. 
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
    --# to give extra button to mobile factories.
    GiveExtraToggleToMobileFactoryUnits(all_blueprints.Unit)
    
    --# This function is defined below and allows some UEF factories 
    --# to build flying engineering drones, like those built by the Kennel.
    AllowUEFMobileFactoriesToBuildEngineeringPods(all_blueprints.Unit)
end
    

--#* 
--#*  Gilbot-X says:
--#* 
--#*  This was written by me
--#*  for my AutoPack units.
--#*  The Weapon toggle gets used with a new custom button 
--#*  to toggle autopack on and off.
--#**
function GiveExtraToggleToMobileFactoryUnits(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local MobileFactoryUnitsWithTransportStorage = {
        all_bps['uas0303'], 
        all_bps['urs0303'],
        all_bps['xss0303'],
        all_bps['ues0401'],
        all_bps['uaa0310'],
    }
    
    --# Give each factory these 6 toggles.
    for _, bp in MobileFactoryUnitsWithTransportStorage do 
        --# Give two order buttons
        if not bp.General.ToggleCaps then bp.General.ToggleCaps = {} end
        bp.General.ToggleCaps.RULEUTC_ProductionToggle = true   
        --# Override the button on the weapon toggle to give it the AP button
        if not bp.General.OrderOverrides then bp.General.OrderOverrides = {} end
        bp.General.OrderOverrides.RULEUTC_ProductionToggle = {
                bitmapId = 'dock',
                helpText = 'toggle_dock_on_build',
        }
    end
end



  
--#* 
--#*  Gilbot-X says:
--#* 
--#*  Allow factories to build flying engineering
--#*  drones, like those built by the Kennel.
--#**
function AllowUEFMobileFactoriesToBuildEngineeringPods(all_bps) 

    --# Put all units that autotoggle will work on into an array
    local UEFMobileFactoryUnits = {
        all_bps['ues0401'], -- T4 Sub Aircraft Carrier
        all_bps['uel0401'], -- T4 Fatboy
    } 
    --# Give each autotoggleunit the AT toggle button.
    for _, bp in UEFMobileFactoryUnits do
        --# Add order buttons
        table.insert(bp.Economy.BuildableCategory,'BUILTBYPODFACTORY')
    end
end    
    

end --(end of non-destructive hook)