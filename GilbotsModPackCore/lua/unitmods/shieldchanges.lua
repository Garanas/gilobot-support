--#****************************************************************************
--#**
--#**  New File :   /mods/GilbotsModPackCore/lua/modshield.lua
--#**
--#**  Modded By :  Gilbot-X
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

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function ApplyGeneralChanges(baseClassArg)

--# Now add any other changes
--# that need to be done regardless
--# of what other mods are running.
local resultClass = Class(baseClassArg) {

    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I overrided this to allow X and Z offsets.
    --#*  My pipeline units need those offsets.
    --#**
     OnCreate = function(self,spec)
        --# Perform code from original version 
        --# and any other mods active 
        baseClassArg.OnCreate(self, spec)
        --# Update what the user sees.
        self:DoSyncForUI()
    end,
    

    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I overrided this to use the shield strength adjacency bonus.
    --#**
    GetHealth = function(self)
        return math.floor((baseClassArg.GetHealth(self) * (self.Owner.ShieldStrengthMod or 1)))
    end,
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I overrided this to use the shield strength adjacency bonus.
    --#**
    GetMaxHealth = function(self)
        return math.floor((baseClassArg.GetMaxHealth(self) * (self.Owner.ShieldStrengthMod or 1)))
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I added this so when I increase shield max health
    --#*  as part of an upgrade, the health and regenrate also get updated
    --#*  in a way that is proportional.  If before increasing MaxHealth 
    --#*  the shield's helath was 10 HP off of its Max, then this function makes
    --#*  sure that it is still just 10 HP off Max after Max increases.
    --#
    --#*  Regenrate is also changed so that the shield takes the same amount of 
    --#*  time to regenerate from empty.  If MaxHealth is doubled, the RegenRate 
    --#*  is also doubled.
    --#*
    --#*  Caution: The new value for max health that is passed as an argument
    --#*  must not include the adjacency bonus, so it must be calculated
    --#*  from a base value obtained from the BP, shieldspec or otherwise.
    --#**
    SetMaxHealthAndRegenRate = function(self, newMaxHealthWithoutAdjacencyBonus)
        --# First we work out if shield was more or less 
        --# at full health before we change its max health.
        local myShieldHealthWasPrettyMuchFull = false
        local oldHealthWithoutAdjacencyBonus    = baseClassArg.GetHealth(self) 
        local oldMaxHealthWithoutAdjacencyBonus = baseClassArg.GetMaxHealth(self)
        local tolerance = 5        
        --# Give a bit of tolerance. So if shield is within 5 HP of maximum health...
        if baseClassArg.GetHealth(self) >= (oldMaxHealthWithoutAdjacencyBonus-tolerance) then
            myShieldHealthWasPrettyMuchFull = true
        end
        
        --# Now set max health just as original base version does
        baseClassArg.SetMaxHealth(self, newMaxHealthWithoutAdjacencyBonus)
        
        --# If the shield is not enabled, and its health was almost full, then ...
        if (not self:IsOn()) and myShieldHealthWasPrettyMuchFull then
            --# Set it's health to the new maximum (it stays full).               
            baseClassArg.SetHealth(self, self, newMaxHealthWithoutAdjacencyBonus)
        
        --# otherwise just add the extra HP points to health
        else
            local extraHP = newMaxHealthWithoutAdjacencyBonus - oldMaxHealthWithoutAdjacencyBonus 
            baseClassArg.SetHealth(self, self, oldHealthWithoutAdjacencyBonus+extraHP)
        end
        
        --# Change RegenRate so it takes a similar amount of time to regenerate
        --# the shield to full health (while it is on).
        local increaseFactor = newMaxHealthWithoutAdjacencyBonus / oldMaxHealthWithoutAdjacencyBonus
        self.RegenRate = math.floor(self.RegenRate * increaseFactor)
        
        --# Update what the user sees.
        self:DoSyncForUI()
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I added this so when I increase shield max health
    --#*  as part of an upgrade, the ALT-S display is also updated. 
    --#**
    DoSyncForUI = function(self)
        --# Update sync for unitview interface
        self.Owner.ShieldMaxHPDisplay = self:GetMaxHealth()
        self.Owner.ShieldRegenRateDisplay = self.RegenRate
        self.Owner.Sync.ShieldMaxHP = self.Owner.ShieldMaxHPDisplay
        self.Owner.Sync.ShieldRegen = self.Owner.ShieldRegenRateDisplay
        --# Update sync for ALT-S hotkey
        local shieldStrengthMessage = {}
        shieldStrengthMessage["1"] = 'Shield HP Max=' .. repr(self:GetMaxHealth())
        shieldStrengthMessage["2"] = 'Shield HP=' .. repr(self:GetHealth())
        shieldStrengthMessage["3"] = 'Shield Regen=' .. repr(self.RegenRate)
        self.Owner.Sync.ShieldStrengthMessage = shieldStrengthMessage
    end,
    
}

--# Now return the class we were given  
--# with our changes applied
return resultClass

end--(of class changing function)





--# This is needed by some code I had to copy and paste below
local Entity = import('/lua/sim/Entity.lua').Entity

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function ApplyDomeShieldOffsetChanges(baseClassArg)

--# Now add any other changes
--# that need to be done regardless
--# of what other mods are running.
local resultClass = Class(baseClassArg) {


    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I overrided this to allow X and Z offsets.
    --#*  My pipeline units need those offsets.
    --#**
    OnCreate = function(self,spec)
        --LOG('ApplyDomeShieldOffsetChanges: OnCreate called in Gilbot ModShield')
        --# Perform code from original version 
        --# and any other mods active 
        baseClassArg.OnCreate(self, spec)
        --LOG('ApplyDomeShieldOffsetChanges: Code in OnCreate after shield state change running.')
        --# Add code that sets offsets according
        --# to additional values I added to spec
        self:SetOffset(spec.ShieldXOffset or 0, 
                       spec.ShieldVerticalOffset, 
                       spec.ShieldZOffset or 0
        )
        --self:AttachBoneTo(-1, spec.Owner, -1)
    end,
    
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I added this to allow X and Z offsets.
    --#*  It is called by my hook of OnCreate above. 
    --#**
    SetOffset = function(self, x , y, z)
        self.ShieldXOffset = x
        self.ShieldVerticalOffset = y
        self.ShieldZOffset = z
    end,
    
    --#*
    --#*  Gilbot-X says:  
    --#*
    --#*  I overrided this to allow X and Z offsets.
    --#**
    CreateShieldMesh = function(self)
        --# This is FA code
        self:SetCollisionShape( 'Sphere', 0, 0, 0, self.Size/2)
        self:SetMesh(self.MeshBp)
        --# I changed this next line to allow x and z offsets
        self:SetParentOffset(
          Vector(
            self.ShieldXOffset or 0,
            self.ShieldVerticalOffset,
            self.ShieldZOffset or 0
          )
        )
        --# This is FA code
        self:SetDrawScale(self.Size)
        if self.MeshZ == nil then
            --# This is FA code
            self.MeshZ = Entity { Owner = self.Owner }
            self.MeshZ:SetMesh(self.MeshZBp)
            Warp( self.MeshZ, self.Owner:GetPosition() )
            self.MeshZ:SetDrawScale(self.Size)
            self.MeshZ:AttachBoneTo(-1,self.Owner,-1)
            
            --# Gilbot-X says: 
            --# I changed this to allow for x and z offsets
            self.MeshZ:SetParentOffset(
              Vector(
                self.ShieldXOffset,
                self.ShieldVerticalOffset,
                self.ShieldZOffset
              )
            )
            
            --# The rest is FA code
            self.MeshZ:SetVizToFocusPlayer('Always')
            self.MeshZ:SetVizToEnemies('Intel')
            self.MeshZ:SetVizToAllies('Always')
            self.MeshZ:SetVizToNeutrals('Intel')
        end
    end,
}

--# Now return the class we were given  
--# with our changes applied
return resultClass

end--(of class changing function)