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
 
--# AEON
Description['ual0106'] = "Fast, lightly armored assault bot. Fires a short-range sonic weapon which fires faster at shorter ranges and can also be upgraded to fire even faster. A personal shield can also be added to the unit."
Description['ual0106b'] = "This T2 version of the Flare has 3 times the original firing rate on its sonic weapon.  It also has a limited personal shield."
Description['ual0106-gilbot/rof1'] = "Increases Rate-Of-Fire of main weapon."
Description['ual0106-gilbot/rof2'] = "Increases Rate-Of-Fire of main weapon again."
Description['ual0106-gilbot/rof3'] = "Increases Rate-Of-Fire of main weapon again."
Description['ual0106-ptsg'] = "Creates a personal shield. Requires energy to run."

Description['ual0101'] = "Fast, lightly armored reconnaissance vehicle. Armed with a laser and a state-of-the-art sensor suite.  Laser can be upgraded to fire faster and inflict more damage. A speed upgrade can also be added."
Description['ual0101b'] = "This T2 version of the Spirit has upgraded firing rate and damage for its laser, and a speed upgrade."
Description['ual0101-gilbot/rfb1'] = "Increases Rate-Of-Fire of main weapon."
Description['ual0101-gilbot/rfb2'] = "Increases Rate-Of-Fire of main weapon again."
Description['ual0101-gilbot/rfb3'] = "Increases Rate-Of-Fire of main weapon again."
Description['ual0101-gilbot/spe'] = "Increases the scout's max speed."
Description['ual0101-gilbot/dam1'] = "Increases the damage inflicted per shot by the scout's main weapon."
Description['ual0101-gilbot/dam2'] = "Increases the damage inflicted per shot by the scout's main weapon again."
Description['ual0101-gilbot/dam3'] = "Increases the damage inflicted per shot by the scout's main weapon again."

Description['ual0103-gilbot/ran1'] = "Increases Range of the artillery weapon."
Description['ual0103-gilbot/ran2'] = "Increases Range of the artillery weapon again."
Description['uab2302-gilbot/aran1'] = "Increases Range of the artillery weapon."
Description['uab2302-gilbot/aran2'] = "Increases Range of the artillery weapon again."


--# UEF
Description['uel0106'] = "The primary role of the Mech Marine is direct fire support. This lightly armored ground unit sacrifices damage potential and staying power for superior speed and maneuverability.  Its weapon power can be upgraded and then a personal shield added."
Description['uel0106b'] = "This T2 version of the a Mech Marine has twice the original firing rate on its machine gun weapon.  They also have a limited personal shield."
Description['uel0106-gilbot/rof1'] = "Increases Rate-Of-Fire of main weapon."
Description['uel0106-gilbot/rof2'] = "Increases Rate-Of-Fire of main weapon again."
Description['uel0106-psg'] = "Creates a personal shield. Requires energy to run."
Description['uel0106-gilbot/vet1'] = "Increases this unit's veterancy level."
Description['uel0106-gilbot/vet2'] = "Increases this unit's veterancy level."
Description['uel0106-gilbot/vet3'] = "Increases this unit's veterancy level."

Description['uel0103-gilbot/ran1'] = "Increases Range of the artillery weapon."
Description['uel0103-gilbot/ran2'] = "Increases Range of the artillery weapon again."
Description['ueb2302-gilbot/aran1'] = "Increases Range of the artillery weapon."
Description['ueb2302-gilbot/aran2'] = "Increases Range of the artillery weapon again."
Description['ueb2302-gilbot/aran3'] = "Increases Range of the artillery weapon again to its maximum."

Description['uel0101'] = "Fast, lightly armored reconnaissance vehicle. Armed with a machine gun and a state-of-the-art sensor suite.  Machine gun can be upgraded to fire faster and inflict more damage. A speed upgrade can also be added."
Description['uel0101b'] = "This T2 version of the Snoop has upgraded firing rate and damage for its machine gun, and a speed upgrade."
Description['uel0101-gilbot/rfb1'] = "Increases Rate-Of-Fire of main weapon."
Description['uel0101-gilbot/rfb2'] = "Increases Rate-Of-Fire of main weapon again."
Description['uel0101-gilbot/rfb3'] = "Increases Rate-Of-Fire of main weapon again."
Description['uel0101-gilbot/spb'] = "Increases the scout's max speed."
Description['uel0101-gilbot/dam1'] = "Increases the damage inflicted per shot by the scout's main weapon."
Description['uel0101-gilbot/dam2'] = "Increases the damage inflicted per shot by the scout's main weapon again."
Description['uel0101-gilbot/dam3'] = "Increases the damage inflicted per shot by the scout's main weapon again."

Description['xea0002-gilbot/satv1'] = "This satellite can be used for bot espionage and defense.  It flies so high that it cannot be targeted directly by the enemy.  The only way to destroy it is to destroy its control tower.  It has upgrade paths for increasing visual field, and for adding and upgrading a beam weapon that can attack structures and ground units."
Description['xea0002-gilbot/satv1'] = "Increased the surveillance area of the satellite camera."
Description['xea0002-gilbot/satv2'] = "Increased the surveillance area of the satellite camera again."
Description['xea0002-gilbot/satv3'] = "Increased the surveillance area of the satellite camera to maximum."
Description['xea0002-gilbot/satw1'] = "Enables weaponery on the satellite for firing at ground targets."
Description['xea0002-gilbot/satw2'] = "Increases the damage inflicted on ground targets by the satellite's beam weapon."
Description['xea0002-gilbot/satw3'] = "Increases the damage inflicted on ground targets by the satellite's beam weapon to maximum."
Description['xea0002b'] = "This upgraded defense satellite has level 2 enhanced weaponery.  Its weaponery can be upgraded again to the level 3 maximum."
Description['xea0002b-gilbot/satv1'] = "Increased the surveillance area of the satellite camera."
Description['xea0002b-gilbot/satv2'] = "Increased the surveillance area of the satellite camera again."
Description['xea0002b-gilbot/satv3'] = "Increased the surveillance area of the satellite camera to maximum."
Description['xea0002b-gilbot/satw1'] = "Enables weaponery on the satellite for firing at ground targets."
Description['xea0002b-gilbot/satw2'] = "Increases the damage inflicted on ground targets by the satellite's beam weapon."
Description['xea0002b-gilbot/satw3'] = "Increases the damage inflicted on ground targets by the satellite's beam weapon to maximum."
Description['xea0002c'] = "This upgraded defense satellite has the maximum level 3 enhanced weaponery."
Description['xea0002c-gilbot/satv1'] = "Increased the surveillance area of the satellite camera."
Description['xea0002c-gilbot/satv2'] = "Increased the surveillance area of the satellite camera again."
Description['xea0002c-gilbot/satv3'] = "Increased the surveillance area of the satellite camera to maximum."
Description['xea0002c-gilbot/satw1'] = "Enables weaponery on the satellite for firing at ground targets."
Description['xea0002c-gilbot/satw2'] = "Increases the damage inflicted on ground targets by the satellite's beam weapon."
Description['xea0002c-gilbot/satw3'] = "Increases the damage inflicted on ground targets by the satellite's beam weapon to maximum."


--# CYBRAN
Description['url0106'] = "Lightly armored strike bot. Provides direct-fire support against low-end units. Weapon fires faster at shorter ranges and can also be upgraded to fire even faster.  A cloak upgrade is available but cloaking does not work while the unit is moving or firing."
Description['url0106b'] = "This T2 version of the Hunter has three times the original firing rate on its laser weapon.  It also cloaks itself while unit is neither moving nor firing, although that ability consumes energy to run."
Description['url0106-gilbot/rof1'] = "Increases Rate-Of-Fire of main weapon."
Description['url0106-gilbot/rof2'] = "Increases Rate-Of-Fire of main weapon again."
Description['url0106-pcg'] = "Activates personal cloak ability. Requires energy to run. Only cloaks while unit is neither moving nor firing."

Description['url0103-gilbot/ran1'] = "Increases Range of the artillery weapon."
Description['url0103-gilbot/ran2'] = "Increases Range of the artillery weapon again."
Description['urb2302-gilbot/aran1'] = "Increases Range of the artillery weapon."
Description['urb2302-gilbot/aran2'] = "Increases Range of the artillery weapon again."
Description['urb2302-gilbot/aran3'] = "Increases Range of the artillery weapon again to its maximum."
Description['urb2302-gilbot/arof1'] = "Increases Rate-Of-Fire of the artillery weapon."
Description['urb2302-gilbot/arof2'] = "Increases Rate-Of-Fire of the artillery weapon again."
Description['urb2302-gilbot/arof3'] = "Increases Rate-Of-Fire of the artillery weapon again to its maximum."

Description['url0101b'] = "This upgraded version of the Mole can reclaim anything, including resources in the environment, wreckage, and unprotected enemy units."
Description['url0101c'] = "This upgraded version of the Mole can capture as well as reclaim."
Description['xrl0302b'] = "This upgraded version of the Fire Beetle packs a nuclear punch."
Description['xrl0302-pcg'] = "Activates personal cloak ability. Requires energy to run. Only cloaks while unit is neither moving nor firing."
Description['xrl0302b-pcg'] = "Activates personal cloak ability. Requires energy to run. Only cloaks while unit is neither moving nor firing."
Description['xrl0302-gilbot/nka'] = "Upgrades the detonation to a nuclear blast."
Description['xrl0302-emp'] = "Upgrades the detonation to an EMP blast that imobilizes enemy units."
Description['xrl0302-gilbot/stu'] = "Upgrades the detonation to an EMP blast that imobilizes enemy units."
Description['xrl0302-gilbot/fla'] = "Upgrades the detonation to a distracting flare blast."

Description['url0401-gilbot/bmb'] = "Modifies the muzzle of the Scathis so that it can fire crawling bombs.  The bombs land without any upgrades active, but if they land somewhere reasonably safe you might have the time to upgrade them.  The firing rate of the Scathis decreases significantly with this upgrade active."
Description['url0401-gilbot/thft'] = "Modifies the muzzle of the Scathis so that it can fire a lethal mix of upgraded capturing scouts, along with crawling bombs with EMP and Flare enhancements already activated.  The bombs are there to give the capturing scouts time to do their job.  The firing rate of the Scathis decreases significantly with this upgrade active."    
Description['url0401-gilbot/scth'] = "By default the muzzle of the Scathis fires heavy proton artillery shells at a high ballistic arc and at a rapid rate.  The rate can be decreased with a slider control if you need to conserve energy."
Description['url0401-gilbot/scth1'] = "By default the muzzle of the Scathis fires heavy proton artillery shells at a high ballistic arc and at a rapid rate.  The rate can be decreased with a slider control if you need to conserve energy."
Description['url0401-gilbot/scth2'] = "Increases the maximum rate of fire of the heavy proton artillery shell cannons.  The rate can still be decreased with a slider control if you need to conserve energy."
Description['url0401-gilbot/scth3'] = "Increases the maximum rate of fire of the heavy proton artillery shell cannons agin, up to the maximum value possible.  The rate can still be decreased with a slider control if you need to conserve energy."
   
--# SERAPHIM
Description['xsl0101'] = "Light, fast mobile reconnaissance unit. When stationary, deploys cloaking and stealth fields. Weapon fires faster at shorter ranges and can also be upgraded to fire even faster.  Another upgrade increases the damage inflicted per shot. An armour upgrade is also available."
Description['xsl0101b'] = "This T2 version of the Selen has twice times the original firing rate on its weapon, does more damage per shot, and also has toughened armour."
Description['xsl0101-gilbot/rof'] = "Increases Rate-Of-Fire of main weapon."
Description['xsl0101-gilbot/dam'] = "Increases damage inflicted by each shot of the main weapon."
Description['xsl0101-gilbot/arm'] = "An electrically activated chemical reaction toughens the armour by a factor of 3."

Description['xsl0103-gilbot/ran1'] = "Increases Range of the artillery weapon."
Description['xsl0103-gilbot/ran2'] = "Increases Range of the artillery weapon again."
Description['xsb2302-gilbot/aran1'] = "Increases Range of the artillery weapon."
Description['xsb2302-gilbot/aran2'] = "Increases Range of the artillery weapon again."
Description['xsb2302-gilbot/aran3'] = "Increases Range of the artillery weapon again to its maximum."
