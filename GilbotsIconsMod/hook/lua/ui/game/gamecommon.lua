do--(start of non-destructive hook)
--#*****************************************************************************
--#* Hook File: lua/ui/game/gamecommon.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : This function is called often.
--#*
--#*****************************************************************************

local UnitIconLocator = import('/mods/GilbotsIconsMod/locateUnitIcons.lua')

--#*  
--#*  Gilbot-X says:
--#*
--#*  I hooked this function to make sure that 
--#*  Unit icons can be placed under the mods folder.
--#**
local oldFileNameFn = GetUnitIconFileNames
function GetUnitIconFileNames(blueprint)
    local myIconID, myIconPath = UnitIconLocator.IsUnitFromMod(blueprint.Display.IconName)   
    if myIconID then
        local iconName = myIconPath .. '/icons/units/' .. myIconID .. "_icon.dds"
        local upIconName = iconName
        local downIconName = iconName
        local overIconName = iconName
             
        if DiskGetFileInfo(iconName) == false then
            WARN('Gilbot: IconsMod: GameCommon.lua: Icon for unit '.. iconName ..' could not be found, check your file path and icon names!')
            iconName = '/textures/ui/common/icons/units/default_icon.dds'
            upIconName = '/textures/ui/common/icons/units/default_icon.dds'
            downIconName = '/textures/ui/common/icons/units/default_icon.dds'
            overIconName = '/textures/ui/common/icons/units/default_icon.dds'
        end
        return iconName, upIconName, downIconName, overIconName
    else
        return oldFileNameFn(blueprint)
    end
end
   
   
end--(end of non-destructive hook)