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
 



Description['UEL0111B'] = "This mobile SAM launcher was designed to protect UEF's advancing armies from T3 and T4 air assaults at the front line."

