--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsIconsMod/locateUnitIcons.lua
--#**  
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Allow unit icons to be shared between mods
--#**              and allow multiple units to share the same
--#**              icon without having to copy and rename it.
--#**              Allows original SC and FA unit icons to be
--#**              reused without having to copy and rename them.
--#**
--#****************************************************************************

local myIconsAddedByModsPath = "/mods" --# Gilbot-X warns: FA code adds '/icons/units/' to whatever path you specify here.
local myReusedIconsPath = "/textures/ui/common"
local myIconsTablePath = myIconsAddedByModsPath .. '/Icons/IconTable.lua'
local myIconsTableFile = import(myIconsTablePath)
local myNewIconsTable = myIconsTableFile.NewIconsTable
local myReusedIconsTable = myIconsTableFile.ReusedIconsTable

--#*
--#*  Gilbot-X says:
--#*
--#*  This function is called here from GetFileNameAndCheckExists (below)
--#*  and also from the 3 ui files that I have hooked in this mod.
--#**
function IsUnitFromMod(bpid)
    local iconIdResult, pathPrefixResult = nil, nil
    for kUnitId, vMappedIconTarget in myNewIconsTable do
        if kUnitId == bpid then
            if iconIdResult then WARN('Gilbot: IsUnitFromMod: Duplicate icon for ' .. kUnitId) end
            iconIdResult = vMappedIconTarget 
            pathPrefixResult = myIconsAddedByModsPath
        end
    end
    for kUnitId, vMappedIconTarget in myReusedIconsTable do
        if kUnitId == bpid then
            if iconIdResult then WARN('Gilbot: IsUnitFromMod: Duplicate icon for ' .. kUnitId) end
            iconIdResult = vMappedIconTarget 
            pathPrefixResult = myReusedIconsPath
        end
    end
    return iconIdResult, pathPrefixResult
end

--#*
--#*  Gilbot-X says:
--#*
--#*  This function is called from my hook of file /lua/ui/uiutil.lua
--#*  The argument filespec is the filename of format '/icons/units/*_icon.dds'
--#**
function GetFileNameAndCheckExists(filespec)
    if not filespec then return end
    local iconPath = nil
    for myUnitId, myIconID in myNewIconsTable do
        if string.find(filespec, myUnitId .. '_icon') then
            if iconPath then WARN('Gilbot: GetFileNameAndCheckExists: Duplicate icon for ' .. myUnitId) end
            iconPath = myIconsAddedByModsPath .. string.gsub(filespec, myUnitId, myIconID,1)
        end
    end
    for myUnitId, myIconID in myReusedIconsTable do
        if string.find(filespec, myUnitId .. '_icon') then
            if iconPath then WARN('Gilbot: GetFileNameAndCheckExists: Duplicate icon for ' .. myUnitId) end
            iconPath = myReusedIconsPath .. string.gsub(filespec, myUnitId, myIconID,1)
        end
    end
    if iconPath then       
        if DiskGetFileInfo(iconPath) then
            return iconPath
        else
            WARN('Gilbot: Mod icon file '.. repr(iconPath) 
            ..' could not be found, check your icon names in addedUnitTable.lua!')
        end
        return nil        
    end
end