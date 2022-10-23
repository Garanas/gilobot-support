--#****************************************************************************
--#*                                                                             
--#*  New File  :  /lua/modlocator.lua                                       
--#*                                                                             
--#*  Author    : GPG Devs and Manimal                                              
--#*                                                                                                                                           
--#*  Revised   : Jan 6 2009, Gilbot-X                                                    
--#*                                                                             
--#*  Summary   : Mod location script.                                          
--#*                                                                                                                                                       
--#****************************************************************************

--# This local table makes sure that
--# we only look once for each mod 
--# and the result is cached.
local ModsAlreadyFound = {}

--#*
--#*  Given a MOD UID, returns mod location.
--#*
--#*  How to use:
--#*
--#*  local GetActiveModLocation = import('/Mods/GilbotsModPackCore/lua/modlocator.lua').GetActiveModLocation
--#*  local myModLocation =  GetActiveModLocation("edf9fefc-a091-457c-8781-e837710f3c6A")
--#*    or 
--#*  local Modpath = import('/Mods/GilbotsModPackCore/lua/modlocator.lua').GetActiveModLocation("edf9fefc-a091-457c-8781-e837710f3c6A")
--#**
function GetActiveModLocation(mod_Id)
    --# If the search wasn't done already...
    if not ModsAlreadyFound[mod_Id] then 
        --# Search list of active mods...
        for i, mod in __active_mods do
            if mod_Id == mod.uid then
                ModsAlreadyFound[mod_Id] = mod.location
                LOG("MANIMAL\'s MOD LOCATOR INFO:  Active Mod Found (name="..(mod.name or 'unknown')..", UID="..(mod.uid or 'none')..", location = "..mod.location..")  .")
                return mod.location
            end
        end
        --# If we got here then mod wasn't active.
        --# Use the empty string in cache list to
        --# indicate search was done but mod not active.
        ModsAlreadyFound[mod_Id] = ""
        --# Signal Failure to calling code
        LOG("MANIMAL\'s MOD LOCATOR WARNING:  Unable to get Mod Location ! Wrong or missing UID.")
    end
    --# If we are here, the search was done.
    --# Respond accordingly to whatever is in search result cache.
    if ModsAlreadyFound[mod_Id] == "" then return nil 
    else return ModsAlreadyFound[mod_Id] 
    end
end