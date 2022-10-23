do --(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/terrannunits.lua
--#**  Modded By :  Gilbot-X
--#**
--#**  Summary   :  Unit class generic overrides for UEF faction
--#**
--#**  Note: 397 lines in original file so if you get an error 
--#**  subtract 397 from the line number it gives you to find 
--#**  where it is in this hook file
--#**  
--#****************************************************************************

--#-------------------------------------------------------------
--#  MASS COLLECTION UNITS
--#-------------------------------------------------------------

local MakeDamageLimitationSystemUser = 
    import('/mods/GilbotsModPackCore/lua/autodefend/dls.lua').MakeDamageLimitationSystemUser

--#* 
--#*  Gilbot-X says:
--#*
--#*  In the original terranunits, when TMassCollectionUnit extends 
--#*  MassCollectionUnit it does not add any extra code.
--#*
--#*  In the original defaultunits.lua, when MassCollectionUnit extends StructureUnit
--#*  with some extra code which I have moved into GilbotMassCreationUnit.
--#**

local BaseClass = MakeDamageLimitationSystemUser(TMassCollectionUnit)
TMassCollectionUnit = Class(BaseClass) {}

end --(of non-destructive hook)