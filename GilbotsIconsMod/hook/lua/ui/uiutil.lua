do--(start of non-destructive hook)
--#*****************************************************************************
--#* Hook File: lua/modules/ui/uiutil.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Various utility functions to make UI scripts easier and more consistent
--#*
--#* Notes    : The argument filespec is the filename of format '/icons/units/*_icon.dds'
--#*****************************************************************************

local UnitIconLocator = import('/mods/GilbotsIconsMod/locateUnitIcons.lua')

--#*  
--#*  Gilbot-X says:
--#*
--#*  I hooked this function to make sure that 
--#*  Unit icons and other textures can be placed 
--#*  under the mods folder.
--#**
local oldUIFile = UIFile
function UIFile(filespec, useSkinsOnModTexturesArg)
    --# Check for icon files
    local result = UnitIconLocator.GetFileNameAndCheckExists(filespec)
    if result then return result end
    --# All FA texture filenames start with "/"
    --# so if the filename doesn't start with that, 
    --# it's probably a mod texture.
    local firstIndexOfSlash = string.find(filespec, "/")
    if firstIndexOfSlash~=1 then
        local guiTexture = filespec
        if useSkinsOnModTexturesArg then
            guiTexture = currentSkin() .. '/' .. guiTexture
        end
        --# Check for button textures
        result = CheckOtherFolder(guiTexture)
        if result then return result end
    end
    --# Stuff that isnt in mods.
    return oldUIFile(filespec)
end

--# This is not a hook, I added this.
--# It finds button textures in the mods folder.
function CheckOtherFolder(filespec)
    local texturesFolder = '/mods/textures/'	
    local fullPath = texturesFolder .. filespec
    if DiskGetFileInfo(fullPath) then return fullPath end
    LOG("Gilbot: Unable to find texture file in mod textures: ", fullPath)
    return nil
end
    

end--(of non-destructive hook)