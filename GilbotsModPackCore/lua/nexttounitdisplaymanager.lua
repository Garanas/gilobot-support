--#****************************************************************************
--#**
--#**  New File:  /mods/GilbotsModPackCore/lua/nexttounitdisplaymanager.lua
--#**
--#**  Modded By:  Gilbot-X, with link to code from Goom
--#**
--#**  Summary  :  Overrided to add keymappings for slider controls
--#**              and autotoggle priority order changes
--#**
--#****************************************************************************
   
--# These variables are local to file
--# but used in more than one function instance     
local DisplayIsToggledOn = false
local DisplayTypeSelected = "AutoToggleDisplay"
local ManageDisplayThreadLaunched = {}


--#*
--#*  Gilbot-X says:
--#*
--#*  A list of function to be called from the 
--#*  ManageDisplay function (thread) to be run
--#*  as USER state code.
--#**
local AddDisplayToOnScreenUnits = {
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I created this display feature so that
    --#*  P,C can be displayed on all auto-toggle units.
    --#*  This is USER state code.
    --#**
    AutoToggleDisplay = function(onScreenUnitArrayArg)

        local UnitText = import('/mods/GilbotsModPackCore/lua/unittext.lua')

        local syncVar = 'AutoToggleDisplay'
        --# For each item in the onscreen unit sync list
        for _, vOnScreenEntityId in onScreenUnitArrayArg do
            --# Check that the Unit to display on already has display text synced...               
            if UnitData[vOnScreenEntityId] and UnitData[vOnScreenEntityId][syncVar] then
                --# It does, so Prepare arguments for call to USER State function
                local entryData = {
                    Text = UnitData[vOnScreenEntityId][syncVar],
                    Entity = vOnScreenEntityId,
                    Color ='ffffcccc', -- light pink
                    FontSize = 12,
                    SyncTextVariable = syncVar               
                }
                --# Call imported user state function
                --# to make the dispaly appear.
                UnitText.StartDisplay(entryData)
            end
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I created this display feature so that
    --#*  P,C can be displayed on all auto-toggle units.
    --#*  This is USER state code.
    --#**
    NetworkDisplayText = function(onScreenUnitArrayArg)
        local UnitText = import('/mods/GilbotsModPackCore/lua/unittext.lua')
        local syncVar = 'NetworkDisplayText'
        --# For each item in the onscreen unit sync list
        for _, vOnScreenEntityId in onScreenUnitArrayArg do
            --# Check that the Unit to display on already has display text synced...               
            if UnitData[vOnScreenEntityId] and UnitData[vOnScreenEntityId][syncVar] then
                --# It does, so Prepare arguments for call to USER State function
                local entryData = {
                    Text = UnitData[vOnScreenEntityId][syncVar],
                    Entity = vOnScreenEntityId,
                    Color ='ffccffff', -- light green blue
                    FontSize = 12,
                    SyncTextVariable = syncVar               
                }
                --# Call imported user state function
                --# to make the dispaly appear.
                UnitText.StartDisplay(entryData)
            end
        end
    end,
}
            

--#*
--#*  Gilbot-X says:
--#*
--#*  I created this to keep syncing list of units
--#*  on screen and to apply and remove the appropriate
--#*  on-unit displays, based on all toggles set.
--#*  This is USER state code.
--#**
local ManageDisplay = function()

    local OnScreenUnitsFile = import('/mods/GilbotsModPackCore/lua/onscreenunitdisplay.lua')
    local UnitText = import('/mods/GilbotsModPackCore/lua/unittext.lua')
    
    --# ArmyID is used twice, so cache 
    local myArmyId = GetFocusArmy()
    --# Make sure only one of these threads can run 
    --# (unless player is using chreats to change focus army ingame)
    ManageDisplayThreadLaunched[myArmyId] = true

    local GilbotUtils = import('/mods/GilbotsModPackCore/lua/utils.lua')
    local myACU = GilbotUtils.GetCommanderFromArmyId(myArmyId)
    
    --# This thread depends on ACU for syncing
    while myACU and (not myACU:IsDead()) do
        --# If the display is toggled on...
        if DisplayIsToggledOn then
            --# Send out Sync request
            OnScreenUnitsFile.SyncUnitsOnScreen()
            --# Wait For Sync to complete at end of beat
            WaitSeconds(0.5)
            --# This function will put the 
            --# display on eligible units
            AddDisplayToOnScreenUnits[DisplayTypeSelected](OnScreenUnitsFile.GetUnitsOnScreen())
        else
            --# Display is toggled off.
            --# Remove display from all units.
            UnitText.CancelDisplay()
            --# Allow this thread to be forked again.
            ManageDisplayThreadLaunched[myArmyId] = false
            --# Exit the thread.
            return
        end
        --# This should be alright with 
        --# the long wait time.
        WaitSeconds(1)
    end
    
    --# Without this, when ACU dies, text gets stuck there!
    if myACU:IsDead() then UnitText.CancelDisplay() end
end


--#*
--#*  Gilbot-X says:
--#*
--#*  This USER state function is called from Keymapping
--#*  and from UI button and menu components I added.
--#*  I created this so that auto-toggle priorities 
--#*  can be displayed on all auto-toggle units 
--#*  by pressing CTRL-* on the keyboard numberpad. 
--#*  Make sure that Num Lock is active on your keyboard.
--#**
ToggleDisplay = function(newDisplayTypeArg, overrideArg)

    local UnitText = import('/mods/GilbotsModPackCore/lua/unittext.lua')
    
    --# Initialise this table with an entry for each army
    --# if this is the first time it is being run
    if table.getsize(ManageDisplayThreadLaunched) < 1 then
        for k, v in GetArmiesTable() do
            table.insert(ManageDisplayThreadLaunched, false)
        end
    end
    
      --# This second optional arg can change what we are displaying
    if newDisplayTypeArg and (DisplayTypeSelected ~= newDisplayTypeArg) then 
        --# If we are doing a blind toggle, treat
        --# it being on with another type as same as being off
        if overrideArg == 'OFF'
        then DisplayIsToggledOn = false
        else DisplayIsToggledOn = true
             UnitText.CancelDisplay()
        end
        --# Replace display type.  
        --# Thread will pick up on this
        --# if/when running.
        DisplayTypeSelected = newDisplayTypeArg
    else
        --# Allow for optional override
        if overrideArg == 'ON' then 
           DisplayIsToggledOn = true
        elseif overrideArg == 'OFF' then 
           DisplayIsToggledOn = false
        else
            --# If it was toggled on...  then toggle it off...
            --# If it was toggled off... then toggle it back on...
            DisplayIsToggledOn = not DisplayIsToggledOn
        end    
    end
  
    
    --# Launch the thread if one is needed
    if DisplayIsToggledOn and 
      not ManageDisplayThreadLaunched[GetFocusArmy()] then
        ForkThread(ManageDisplay)
    end
end