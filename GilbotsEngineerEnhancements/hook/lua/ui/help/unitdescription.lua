--#****************************************************************************
--#**  Hook to file   :  lua/ui/help/unitdescriptions.lua
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
 
Description['ual0105-pqt'] = "Adds teleporter. Requires considerable Energy to activate."
Description['ual0105-cd'] = "Adds a small chronodampener weapon that slows down nearby enemies. Requires Energy to fire."
Description['ual0208-pqt'] = "Adds teleporter. Requires considerable Energy to activate."
Description['ual0309-pqt'] = "Adds teleporter. Requires considerable Energy to activate."

Description['url0105-psg'] = "Hides the engineer from radar. Requires Energy to run."
Description['url0105-pcg'] = "Cloaks the engineer from optical sensors.  Requires Energy to run."
Description['url0105-ras'] = "Adds resource generation to the engineer."
Description['url0105-gilbot/recl'] = "Allows engineer to extract more mass when reclaiming resources from the environment."
Description['url0105-gilbot/rebd'] = "Allows the engineer to rebuild any destroyed T1 structures faster from wreckage, also using less mass and energy to do it."

Description['url0208-psg'] = "Hides the engineer from radar. Requires Energy to run."
Description['url0208-pcg'] = "Cloaks the engineer from optical sensors.  Requires Energy to run."
Description['url0309-psg'] = "Hides the engineer from radar. Requires Energy to run."
Description['url0309-pcg'] = "Cloaks the engineer from optical sensors.  Requires Energy to run."

Description['uel0105-gilbot/spe'] = "Increases this engineers top speed."
Description['uel0208-gilbot/spe'] = "Increases this engineers top speed."
Description['xel0209-gilbot/spe'] = "Increases this engineers top speed."
Description['xel0209-psg'] = "Creates a personal shield for the engineer. Requires energy to run."
Description['xel0209-sgf'] = "Creates a bubble shield around the engineer which can offer temporary protection for the unit it is building. Requires energy to run."
Description['uel0309-gilbot/spe'] = "Increases this engineers top speed."
Description['uel0208-isb'] = "Adds resource generation to the engineer."

Description['xsl0105-efm'] = "Doubles this engineer's build rate."
Description['xsl0208-efm'] = "Doubles this engineer's build rate."
Description['xsl0309-efm'] = "Doubles this engineer's build rate."
