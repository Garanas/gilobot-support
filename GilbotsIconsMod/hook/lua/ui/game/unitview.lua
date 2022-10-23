do--(start of non-destructive hook)
--#*****************************************************************************
--#* Hook File: lua/ui/game/unitview.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Rollover unit view control
--#*
--#*****************************************************************************

local UnitIconLocator = import('/mods/GilbotsIconsMod/locateUnitIcons.lua')
 
--#*  
--#*  Gilbot-X says:
--#*
--#*  I hooked this function to make sure that 
--#*  Unit icons can be placed under the mods folder.
--#** 
local oldUpdateWindow = UpdateWindow
function UpdateWindow(info)
    --# Preserve original code
    oldUpdateWindow(info)
    
    --# My code runs afterwards.  It makes sure the
    --# window also displays textures when the dds files
    --# are stored under the mods folder.
    local myIconID, myIconPathPrefix = UnitIconLocator.IsUnitFromMod(info.blueprintId)   
    if myIconID
      and DiskGetFileInfo(myIconPathPrefix .. '/icons/units/' .. myIconID .. '_icon.dds') then
        controls.icon:SetTexture(myIconPathPrefix .. '/icons/units/' .. myIconID .. '_icon.dds')
    end
    --# If the selected unit was 
    --# building or attacking something, etc...
    if info.focus then
        --# We should do the same for that unit
        local myFocusIconID, myFocusIconIDPathPrefix = UnitIconLocator.IsUnitFromMod(info.focus.blueprintId) 
        if myFocusIconID
          and DiskGetFileInfo(myFocusIconIDPathPrefix .. '/icons/units/' .. myFocusIconID .. '_icon.dds') then
            controls.actionIcon:SetTexture(myFocusIconIDPathPrefix .. '/icons/units/' .. myFocusIconID .. '_icon.dds')
        end
    end
end


end--(of non-destructive hook)