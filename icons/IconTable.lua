--[[

Gilbot-X says:

If you are adding new units then you need to put 
the unit's unit icon (*_icon.dds) file into this 
folder in your FA "My Documents" mod directory:

    "/mods/icons/units/[myfolder]"

Where [myfolder] is the name of a folder you
create to put your icons in so they are easy to find.

You also need to add an entry into the table directly
below, for the unit's unit icon (*_icon.dds) file.

In the table below, more than one unit id can point 
to the same icon... i.e., the two entries

    xal0208b = 'myfolder/xal0208',
    xal0208c = 'myfolder/xal0208',

will mean that two new units with ids 'xal0208b' 
and 'xal0208c' will both use the icon file 

  '/mods/icons/units/myfolder/xal0208_icon.dds'.

You do not have to specify the full path or '_icon.dds' extension 
in the table below, as that is done automatically by my code.

]]

--#*
--#*  Put entries in here when you 
--#*  create a new unit icon texture.
--#*
--#**
NewIconsTable = {
    --#
    --# Gilbot Mods
    --#
    --# Gilbot-X's Pipelines
    gab5101 = 'gilbots/gab5101',
    gab5201 = 'gilbots/gab5201',
    gab5301 = 'gilbots/gab5301',
    geb5101 = 'gilbots/geb5101',
    geb5201 = 'gilbots/geb5201',
    geb5301 = 'gilbots/geb5301',
    gab5101b = 'gilbots/gab5101',
    gab5201b = 'gilbots/gab5201',
    gab5301b = 'gilbots/gab5301',
    geb5101b = 'gilbots/geb5101',
    geb5201b = 'gilbots/geb5201',
    geb5301b = 'gilbots/geb5301',
    grb5101 = 'gilbots/grb5101',
    grb5201 = 'gilbots/grb5201',
    grb5301 = 'gilbots/grb5301',
    grb5301b = 'gilbots/grb5301',
    urb5101g = 'gilbots/urb5101g',
    --# Gilbot-X's Aeon FARK
    ual0301b = 'gilbots/ual0301b',
    --#
    --# 4th Dimension
    --#
    --# 4th Dimension Aeon Units
    uab2306 = '4d/uab2306',  --T2 Annihilator	
    ual0108 = '4d/ual0108',  --T1 Artemis Assault Walker
    ual0204 = '4d/ual0204',  --T2 Predator
    ual0302 = '4d/ual0302',  --T3 Ultra Heavy Tank	
    ual0402 = '4d/ual0402',  --T4 Overlord
    --# 4th Dimension UEF Units
    ueb2201_a = '4d/ueb2201_a',  --T2 Deployable Point Defense
    ueb2201_b = '4d/ueb2201_b',  --T2 Deployable Point Defense
    ueb2201_c = '4d/ueb2201_c',  --T2 Deployable Point Defense 
    uel0108 = '4d/uel0108',  --T1 Medium Tank
    uel0302 = '4d/uel0302',  --T3 Dog Bot
    uel0305 = '4d/uel0305',  --T3 Ultra Heavy Tank
    uel0308 = '4d/uel0308',  --T3 Mobile SAM
    uel0402 = '4d/uel0402',  --T4 Rampage
    --# 4th Dimension Cybran Units
    ura0106 = '4d/ura0106',  --T1 Mosquito Gunship
    ura0305 = '4d/ura0305',  --T3 Retribution
    urb2306 = '4d/urb2306',  --T3 Heavy Microwave Turret
    url0102 = '4d/url0102',  --T1 Cutter
    url0204 = '4d/url0204',  --T2 Termite
    url0302 = '4d/url0302',  --T3 Chimera
    url0305 = '4d/url0305',  --T3 HellHound
    url0403 = '4d/url0403',  --T4 Mobile Arty
    --#
    --# Experimental Wars
    --#
    --# Experimental Wars Aeon Units 
	uase0001 =  'ew/uase0001',  --T1 Experimental Spaceship
	uabse0001 =	'ew/uabse0001', --T2 orbital defense
	ual0305	=   'ew/ual0305',	 --T3 Heavy Hover Tank
	ual0311	=   'ew/ual0311',   --T3 EMP Missile Launcher
	uab2310	=   'ew/uab2310',   --T4 Point Defense
	ual0302	=   'ew/ual0302',   --T3 SACU	
	ual5001	=   'ew/ual5001',   --T2 Mobile Air Staging Platform
    --(1.8 Units)
    uab5201 =   'ew/uab5201',   --T1 Air Staging Platform 
    ual0108 =   'ew/ual0108',   --T2 Mobile Torpedo Launcher
    ualew0001 = 'ew/ualew0001', --T4 Hover Tank
    uas0301 =   'ew/uas0301',   --T3 Sub Battleship
    --# Experimental Wars UEF Units  
	uese0001 =	'ew/uese0001',  --T1 Experimental Spaceship
	uebse0001 =	'ew/uebse0001', --T2 orbital defense
	uea0401 =	'ew/uea0401',   --T4 Spaceship
	uea0402 =	'ew/uea0402',   --T4 Transport
	uea0110 =	'ew/uea0110',   --T2 Support Bomber
	uel0206 =	'ew/uel0206',   --T2 Artillery Tank
	ueb4205 =	'ew/ueb4205',   --T1 Shield Generator
    uea0306 =   'ew/uea0306',   --T3 Fighter/Bomber
    --(1.8 Units)
    ueb5201 =   'ew/ueb5201',   --T1 Air Staging Platform 
    uel0108 =   'ew/uel0108',   --T1 Deployable Medium Tank
    uelew0001 = 'ew/uelew0001', --T4 Tank
    --# Experimental Wars Cybran Units 
	urse0001  = 'ew/urse0001',  --T1 Experimental Spaceship
	urbse0001 = 'ew/urbse0001', --T2 orbital defense
	urb4401	=   'ew/urb4401',   --T4 AntiNuke structure
	url0302	=   'ew/url0302',   --T3 SACU
	url0311	=   'ew/url0311',   --T3 Missiler Bot
	ura0110	=   'ew/ura0110',   --T2 Support Bomber
	urb5001	=   'ew/urb5001',   --T3 Stealth Field Generator
    --(1.8 Units)
    ura0205 =   'ew/ura0205',   --T2 EMP Bomber
    urb5201 =   'ew/urb5201',   --T1 Air Staging Platform 
    url0206 =   'ew/url0206',   --T1 Amphibious Tank
    urlew0001 = 'ew/urlew0001', --T4 Missile Launcher Bot
    --# Experimental Wars Seraphim Units      
	xsse0001 =  'ew/xsse0001',  --T1 Experimental Spaceship
	xsbse0001 = 'ew/xsbse0001', --T2 orbital defense
	xsb2306	= 'ew/xsb2306',     --T3 Point Defense
	xsa0306	= 'ew/xsa0306',     --T3 Gunship
	xsl0206	= 'ew/xsl0206',     --T2 AntiSub Hovercraft
    xsl0302	= 'ew/xsl0302',     --T3 SACU
    xsl0310	= 'ew/xsl0310',     --T3 Mobile Nuke Launcher
    --(1.8 Units)
    xsb5201 =   'ew/xsb5201',   --T1 Air Staging Platform 
    xsl0110 =   'ew/xsl0110',   --T1 Mobile Shield
    xslew0001 = 'ew/urlew0001', --T4 Assault Bot
    
    --#
    --# Hawk's Black Ops
    --#
    --# Hawk's Aeon Units
    xab5102 =  'hawks/xab5102',--T1 Air Staging Platform
    xab5205 =  'hawks/xab5205',--T3 Air Staging Platform
    xaa0401 =  'hawks/xaa0401',-- artemis
    xas0308 =  'hawks/xas0308',-- t3 frigate
    dalk003 =  'hawks/dalk003',-- T3 Mobile AA
    xab2210 =  'hawks/blackops',-- T2 Naval Mine
    xal0310 =  'hawks/blackops',-- Aeon T3 hover tank
    --# Hawk's UEF Units
    xeb5102 =  'hawks/xeb5102',-- T1 Air Staging Platform
    xeb5205 =  'hawks/xeb5205',-- T3 Air Staging Platform
    xel0307 =  'hawks/xel0307',-- juggie
    xel0308 =  'hawks/xel0308',--rapier
    xel0109 =  'hawks/xel0109',-- avenger
    xel0109b = 'hawks/xel0109b',-- avenger
    xel0109c = 'hawks/xel0109c',-- avenger
    xel0401 =  'hawks/xel0401',-- goliath
    xes0306 =  'hawks/xes0306',-- T3 frigate
    xes0402 =  'hawks/xes0402',-- bismarck
    xea0003 =  'hawks/xea0003',-- hellfire sat
    delk002 =  'hawks/delk002',-- T3 Mobile AA
    xeb2210 =  'hawks/blackops',-- T2 Naval Mine
    --# Hawk's Cybran Units
    ura0409 =  'hawks/ura0409',-- garg
    xrb5102 =  'hawks/xrb5102',-- T1 Air Staging Platform
    xrb5205 =  'hawks/xrb5205',-- T3 Air Staging Platform
    xrl0110 =  'hawks/xrl0110',-- hydra
    xrl0205 =  'hawks/xrl0205',-- scorpion
    xrl0007 =  'hawks/xrl0205',-- scorpion egg
    xrl0308 =  'hawks/xrl0308',-- Basilisk
    xrl0308b = 'hawks/xrl0308b',-- Basilisk
    xrl0308c = 'hawks/xrl0308c',-- Basilisk
    xrb4401 =  'hawks/xrb4401',-- cloak field gen
    xrs0306 =  'hawks/xrs0306',-- T3 frigate
    xrs0402 =  'hawks/xrs0402',-- Seadragon
    drlk001 =  'hawks/drlk001',-- T3 Mobile AA
    drlk005 =  'hawks/drlk001',-- T3 Mobile AA egg
    xrb2210 =  'hawks/blackops',-- T2 Naval Mine
    xrl0011 =  'hawks/blackops',-- Cybran hailfire egg
    --# Hawk's Seraphim Units
    xsb2402 =  'hawks/xsb2402',-- rift gate
    xsb0405 =  'hawks/xsb0405',-- lambda field gen
    xsb5104 =  'hawks/xsb5104',-- T1 Air Staging Platform
    xsb5205 =  'hawks/xsb5205',-- T3 Air Staging Platform
    xss0306 =  'hawks/xss0306',-- T3 Frigate
    xss0401 =  'hawks/xss0401',-- T4 Dreadnought
    xsb0004 =  'hawks/xsb0004',-- Dreadnaught naval fac
    dslk004 =  'hawks/dslk004',-- T3 Mobile AA
    xsl0310 =  'hawks/xsl0310',-- New rift gate unit
    xsb2210 =  'hawks/blackops',-- T2 Naval Mine
    xsa0001 =  'hawks/blackops',-- Seraphim Attack drone
    xsa0002 =  'hawks/blackops',-- Seraphim repair drone
}


--[[

Gilbot-X says:

If your new unit needs to use an icon already in FA,
You just need to add an entry into the table below to
map your unit's ID to the fA unit icon (*_icon.dds) file.
More than one unit id can point to the same icon... 
i.e., the entries

    ual0101b = 'ual0101',
    ual0101c = 'ual0101',

mean that two new units with ids 'ual0101b' and 'ual0101c' 
will both use the icon file 'ual0101_icon.dds' in FA.
You do not have to specify the '_icon.dds' extension 
as that is done automatically by my code.


]]

--#*
--#*  Put entries in here when you 
--#*  create a new unit that uses
--#*  an icon texture already found in FA.
--#*  
--#**
ReusedIconsTable = {
    --# Gilbot-X's scout upgrades
    ual0101b = 'ual0101',
    ual0101c = 'ual0101',
    uel0101b = 'uel0101',
    url0101b = 'url0101',  
    url0101c = 'url0101',  
    --# Gilbot-X's LAB upgrades
    ual0106b = 'ual0106',
    uel0106b = 'uel0106',
    url0106b = 'url0106',
    xsl0101b = 'xsl0101',
    --# Gilbot-X's T3 Mobile AA
    uel0111b = 'uel0111',
    uel0111c = 'uel0111',
    --# Gilbot-X's T4 Powergens
    uab1301b = 'uab1301',
    uec1901b = 'uec1901',
    urb1201b = 'urb1201',
    urb1301b = 'urb1301',
    xsb1301b = 'xsb1301',
    --# Gilbot-X's T3 UEF mobile shield
    uel0307b = 'uel0307',
    --# Gilbot-X's T2 UEF sniper tank
    uel0103b = 'uel0103',
    --# Gilbot-X's Aeon Shield strengthener
    uac1401b = 'uac1401',
    --# Gilbot-X's Seraphim Resource Network Unifier
    xsc1501b = 'xsc1501',
    --# Gilbot-X's Cybran Mobile CloakField Generator
    url0306b = 'url0306', 
    --# Gilbot-X's Cybran Crawling Bombs
    xrl0302b = 'xrl0302',  --T2 Crawling Bomb
    --# Gilbot-X's Cybran ASF Untargetable Upgrade
    ura0303b = 'ura0303',
    --# Gilbot-X's Upgraded UEF Satellite
    xea0002b = 'xea0002',
    xea0002c = 'xea0002',
    --# Gilbot-X's Extra Engineering Drone
    xea3204b = 'xea3204',
    --# Gilbot-X's Auto Toggle Controller Nodes
    uac1501b = 'uac1501',
    uec1301b = 'uec1301',
    urc1101b = 'urc1101',
    xsc1301b = 'xsc1301',
    --# Legion Darath's Commando Mech
    ldcm    = 'uel0106',
     --# Experimental Wars 
    xsl0405	= 'xsl0401',--T4 Assault Bot (Transportable)  
	ual0405	= 'ual0401',--T4 GC (Transportable)  
	url0405	= 'url0402',--T4 Monkeylord (Transportable) 
	xrl0405	= 'xrl0403',--T4 Megalith (Transportable)    
    --# Hawk's Black Ops
    uaa0309 =  'uaa0104',--T3 Air Transport
    ura0309 =  'ura0104',--T3 Air Transport
    xsa0309 =  'xsa0104',--T3 Air Transport
    xab2306 =  'uab2303',-- Aeon T3 PD
    xrb2306 =  'urb4201',-- Cybran T3 pd
    xsa0310 =  'xsa0203',-- T3 Seraphim gunship??
    xrl0307 =  'url0304',-- Cybran hailfire
    xrs0304 =  'urs0202',-- Cybran Reaper
    xrs0305 =  'urs0203',-- Cybran Missile Sub
    xrl0006 =  'url0303',-- Cybran Loyalist egg
    xrl0008 =  'url0306',-- deciever egg
    xrl0009 =  'xrl0302',-- firebeetle egg
    xrl0010 =  'url0203',-- wagner egg
    xsa0003 =  'xsa0203',-- rift gate unit
    xsl0002 =  'xsl0201',-- rift gate unit
    xsl0003 =  'xsl0202',-- rift gate unit
    xsl0004 =  'xsl0111',-- rift gate unit
    xsl0005 =  'xsl0303',-- rift gate unit
    xsl0006 =  'xsl0103',-- rift gate unit
    xsl0007 =  'xsl0401',-- rift gate unit
}