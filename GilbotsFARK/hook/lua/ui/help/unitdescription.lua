--#****************************************************************************
--#**  Hook to file   :  lua/modules/ui/help/unitdescriptions.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Strings and images for the unit rollover System
--#**
--#**  Note- Adding entries to the global Description table 
--#**  is the best way to add descriptions without losing anyone elses.
--#**  It didn't work by copying the GPG file and inserting new definitions 
--#**  into the table definition - that overwrites the old table, which other
--#**  users would also do if we all hooked in the same way.  
--#**  When you use a hook, the new definitions object replaces the
--#**  old and all the definitions from previously loaded versions of the file are lost.
--#**  So I am not redefining Definitions, I am inserting new key/value pairs into it
--#**  where keys are strings.
--#**  
--#****************************************************************************
 


   
Description['ual0301b'] = "The F.A.R.K. has similar features to the SACU, but without offensive capabilities.  It cannot build by itself, but it assists, repairs, reclaims and captures.  It is smaller and faster than an SACU."
Description['ual0301b-efm'] = "<LOC Unit_Description_0168>Speeds up all engineering-related functions."
Description['ual0301b-sp'] = "<LOC Unit_Description_0170>FARK is sacrificed and its Mass is added to a structure. This destroys the FARK."
Description['ual0301b-tsg'] = "<LOC Unit_Description_0171> Creates a protective shield around the FARK."
Description['ual0301b-htsg'] = "<LOC Unit_Description_0172> Upgrades the FARK's protective shield. Requires Energy to run."
Description['ual0301b-sic'] = "<LOC Unit_Description_0174> Greatly increases the speed at which the FARK repairs itself."
Description['ual0301b-pqt'] = "<LOC Unit_Description_0175> Adds teleporter. Requires considerable Energy to activate."

