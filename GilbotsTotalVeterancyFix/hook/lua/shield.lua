do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/shield.lua
--#**
--#**  Modded By :  Eni, updayed by Gilbot-X
--#**
--#**  Summary   :  Changes to shields.
--#**               Modded to allow shields to do 2 things:
--#**               1/ Get max health when they are finished 
--#**               charging up (after having been off)
--#**               2/ When created, instantiate variables that
--#**               are used by Total Veterancy, for recording
--#**               experience points and for syncing buffed values
--#**               for the UI.
--#**
--#**  Note: 477 lines in original file.
--#**  
--#****************************************************************************

local ApplyClassChanges = 
    import('/Mods/GilbotsTotalVeterancyFix/modshield.lua').ApplyClassChanges

Shield = ApplyClassChanges(Shield)
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
UnitShield = ApplyClassChanges(UnitShield)

end--(of non-destructive hook)