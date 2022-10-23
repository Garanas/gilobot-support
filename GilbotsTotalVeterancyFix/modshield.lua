--#****************************************************************************
--#**
--#**  New File :   /mods/GilbotsTotalVeterancyFix/modshield.lua
--#**
--#**  Modded By :  Eni, updayed by Gilbot-X
--#**
--#**  Summary   :  Code changes for shield units and structures.
--#**               Modded to allow shields to do 2 things:
--#**               1/ Get max health when they are finished 
--#**               charging up (after having been off)
--#**               2/ When created, instantiate variables that
--#**               are used by Total Veterancy, for recording
--#**               experience points and for syncing buffed values
--#**               for the UI.
--#**  
--#****************************************************************************

--# This hook file conflicts with Total Veterancy UI
--# so only apply code if TV UI is not in list of mods active.
local GetActiveModLocation = import('/Mods/GilbotsTotalVeterancyFix/modlocator.lua').GetActiveModLocation
local GilbotsModIsActive = GetActiveModLocation("12345678-2050-4bf6-9236-451244fa8029") --Gilbot-X's Mod Pack 2

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function ApplyClassChanges(baseClassArg)

local BaseClass = nil
local resultClass = nil

--# Do safety check for mod compatibility
if GilbotsModIsActive then BaseClass = baseClassArg else
LOG('TV ModShield: GilbotsModIsActive=' .. repr(GilbotsModIsActive))        
BaseClass = Class(baseClassArg) {
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  A non-destructive override to instantiate 
    --#*  this mod's added class instance variables 
    --#*  before they are used and sync data for UI.
    --#**
	OnCreate = function(self, spec)
        LOG('TV ModShield withot Gilbot Pack active: Code in OnCreate before base class reached')
        --# Perform code from original version 
        --# and any other mods active 
        baseClassArg.OnCreate(self, spec)
        LOG('TV ModShield withot Gilbot Pack active: Code in OnCreate after base class reached')
        --# This is already called 
        --# in Gilbot-X's Mods Pack 2
        self:DoSyncForUI()
   	end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I added this to support this mod's
    --#*  changes to the UI, where shield
    --#*  health and regenrates are displayed.
    --#**
    DoSyncForUI = function(self,spec)
        LOG('TV ModShield withot Gilbot Pack active: Syncing shield HP ' .. self:GetMaxHealth() .. ' and regenrate=' .. repr(self.RegenRate))
        self.Owner.ShieldMaxHPDisplay = self:GetMaxHealth()
        self.Owner.ShieldRegenRateDisplay = self.RegenRate
        self.Owner.Sync.ShieldMaxHP = self.Owner.ShieldMaxHPDisplay
        self.Owner.Sync.ShieldRegen = self.Owner.ShieldRegenRateDisplay
   	end,
}
end

--# Now add any other changes
--# that need to be done regardless
--# of what other mods are running.
resultClass = Class(BaseClass) {


    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I added this to instantiate this mod's added
    --#*  class instance variables before they are used.
    --#**
    InitialiseTotalVeterancyVariables = function(self,spec)
    	self.spec = spec
    	if spec.Owner
        then self.XPperDamage = spec.Owner:GetBlueprint().Economy.xpValue /spec.ShieldMaxHealth /2 
        else self.XPperDamage = 0 
        end
   	end,

    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  A non-destructive override to instantiate 
    --#*  this mod's added class instance variables 
    --#*  before they are used and sync data for UI.
    --#**
	OnCreate = function(self, spec)
        --LOG('TV ModShield: Code in OnCreate before base class reached')
        --# Initialise this mod's class instance variables 
    	self:InitialiseTotalVeterancyVariables(spec)
        --# Perform code from original version 
        --# and any other mods active 
        BaseClass.OnCreate(self, spec)
        --LOG('TV ModShield: Code in OnCreate after base class reached')
   	end,
   	
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  A non-destructive override to force
    --#*  shields to have max health after coming back on.
    --#**
   	ChargingUp = function(self, curProgress, time)
        --# Perform code from original version 
        --# and any other mods active 
        BaseClass.ChargingUp(self, curProgress, time)
        --# Give the shield full HP when switched on
        self:SetHealth(self,self:GetMaxHealth()) 
    end,
}

--# Now return the class we were given  
--# with our changes applied
return resultClass

end--(of class changing function)