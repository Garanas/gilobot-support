do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/shield.lua
--#**
--#**  Modded By :  Gilbot-X
--#**
--#**  Summary   :  Shield for units and structures.
--#**
--#**  Note: 477 lines in original file so if you get an error 
--#**  subtract 477 from the line number it gives you to find 
--#**  where it is in this hook file.
--#**  
--#****************************************************************************


local ShieldClassChanges = 
    import('/Mods/GilbotsModPackCore/lua/unitmods/shieldchanges.lua')
local ApplyGeneralChanges = 
    ShieldClassChanges.ApplyGeneralChanges
local ApplyDomeShieldOffsetChanges = 
    ShieldClassChanges.ApplyDomeShieldOffsetChanges

Shield = ApplyDomeShieldOffsetChanges(ApplyGeneralChanges(Shield))
AntiArtilleryShield = ApplyGeneralChanges(AntiArtilleryShield)
--#*
--#*  This class also needs to be overriden
--#*  to add similar code changes, because
--#*  although UnitShield does extend the Shield 
--#*  class, because they are defined in the same
--#*  file, hooking Shield will not update the base
--#*  class of UnitShield, as it will still point to 
--#*  the GPG version.  This is an example of GPG
--#*  making modding more difficult, just because they
--#*  felt it was more convenient for them to have
--#*  these class definitions in the same file.   
--#**
UnitShield = ApplyGeneralChanges(UnitShield)

end --(of non-destructive hook)