do--(start of non-destructive hook)
--#*****************************************************************************
--#**
--#**  Hook File: /lua/ui/game/construction.lua
--#**
--#**  Modded By: Gilbot-X
--#**
--#**  Last updated:  Dec 30th 2008, Gilbot-X 
--#** 
--#**  Summary: Original file contains 1949 lines of UI code for 
--#**           the build dialog that factories, construction units, 
--#**           and units that have upgrades and enhancements all 
--#**           have in one form or another.
--#**
--#*****************************************************************************

--#*  
--#*  Gilbot-X says:
--#*
--#*  I hooked this function to make sure that 
--#*  Enhancement icons can be placed under the mods folder.
--#**
function GetEnhancementPrefix(unitID, iconID)
    local factionPrefix = ''
    if string.sub(unitID, 2, 2) == 'a' then
        factionPrefix = 'aeon-enhancements/' 
    elseif string.sub(unitID, 2, 2) == 'e' then
        factionPrefix = 'uef-enhancements/'
    elseif string.sub(unitID, 2, 2) == 'r' then
        factionPrefix = 'cybran-enhancements/'
    elseif string.sub(unitID, 2, 2) == 's' then
        factionPrefix = 'seraphim-enhancements/'
    end
    local prefix = '/game/' .. factionPrefix .. iconID
    --# If it is a stock icon...
    if not DiskGetFileInfo('/textures/ui/common'..prefix..'_btn_up.dds') then
        --# return a path to shared icons
        local altPath =  '/mods/icons/'
        prefix = altPath .. factionPrefix .. iconID
    end
    return prefix
end


--#*  
--#*  Gilbot-X says:
--#*
--#*  I hooked this function to make sure that 
--#*  Enhancement icons can be placed under the mods folder.
--#**
function GetEnhancementTextures(unitID, iconID)
    local factionPrefix = ''
    if string.sub(unitID, 2, 2) == 'a' then
        factionPrefix = 'aeon-enhancements/' 
    elseif string.sub(unitID, 2, 2) == 'e' then
        factionPrefix = 'uef-enhancements/'
    elseif string.sub(unitID, 2, 2) == 'r' then
        factionPrefix = 'cybran-enhancements/'
    elseif string.sub(unitID, 2, 2) == 's' then
        factionPrefix = 'seraphim-enhancements/'
    end
    
    local prefix = '/game/' .. factionPrefix .. iconID
    --# If it is a stock icon...
    if DiskGetFileInfo('/textures/ui/common'..prefix..'_btn_up.dds') then
        return UIUtil.UIFile(prefix..'_btn_up.dds'),
            UIUtil.UIFile(prefix..'_btn_down.dds'),
            UIUtil.UIFile(prefix..'_btn_over.dds'),
            UIUtil.UIFile(prefix..'_btn_up.dds'),
            UIUtil.UIFile(prefix..'_btn_sel.dds')
    else
        --# return a path to shared icons
        local altPath =  '/mods/icons/'
        prefix = altPath .. factionPrefix .. iconID
        --# Bypass UIFile as these icons 
        --# are not skinabble!
        return prefix..'_btn_up.dds',
            prefix..'_btn_down.dds',
            prefix..'_btn_over.dds',
            prefix..'_btn_up.dds',
            prefix..'_btn_sel.dds'
    end
end

end--(of non-destructive hook)