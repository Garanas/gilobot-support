--#****************************************************************************
--#**
--#**  Hook File:  /mods/GilbotsModPackCore/lua/unitmods/cloakfieldunit.lua
--#**  
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Common code for my units that generate cloakfields.  
--#**
--#****************************************************************************

local IntelFieldBoundsForRadius = 
    import('/mods/GilbotsModPackCore/lua/intelfieldbounds.lua').IntelFieldBoundsForRadius

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeCloakFieldUnit(baseClassArg)

--# Define the class to return                                        
local resultClass = Class(baseClassArg) {

    --# Quick way to test unit 
    --# type from other files.
    IsCloakFieldUnit = true,
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  A quick override to instantiate
    --#*  a member variable.
    --#**
    OnCreate = function(self)
        baseClassArg.OnCreate(self)
        
        --# Have one place where we can query 
        --# our cloakfied radius
        self.GetCloakFieldRadiusCache = 
            self:GetBlueprint().Intel.CloakFieldRadius
        --# Only need to do this at start and when 
        --# intel radius may have changed.
        self:UpdateIntelRadiusGroup()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my slider control.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were 
    --#*  designed to adjust.
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        if statType == 'CloakFieldRadius' then 
            --# These fields do not take decimal values
            newStatValue = math.floor(newStatValue)
            self:SetIntelRadius('CloakField', newStatValue)
            self.GetCloakFieldRadiusCache = newStatValue
            self:UpdateIntelRadiusGroup()
        end
    end,
        
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I moved code into here to make debugging easier.
    --#**
    UpdateIntelRadiusGroup = function(self)
        --# Note: 
        --# I had to store cloakfield radius in GetCloakFieldRadiusCache
        --# because self:GetIntelRadius('CloakField') doesn't work, 
        --# it always returns 0 regardless of the blueprint or any 
        --# calls to SetIntelRadius('CloakField').
        --# These values are always whole numbers 
        local intelRadius = 
            self.GetCloakFieldRadiusCache
        
        
        --# The size of the cloakfield only changes when
        --# its radius increases past another multiple of 4.
        if intelRadius<4 then 
            WARN('Invalid unit ' .. self.DebugId 
              .. ' intelRadius of cloakfield cannot be less than 4 units.'
            )
            return
        elseif intelRadius<8 then 
            intelRadius = 4
            self.IntelRadiusGroup = 'From4To7'
        elseif intelRadius<12 then 
            intelRadius = 8
            self.IntelRadiusGroup = 'From8To11'
        elseif intelRadius<16 then 
            intelRadius = 12 
            self.IntelRadiusGroup = 'From12To15'
        elseif intelRadius<20 then 
            intelRadius = 16
            self.IntelRadiusGroup = 'From16To19'
        elseif intelRadius<24 then 
            intelRadius = 20 
            self.IntelRadiusGroup = 'From20To23'
        elseif intelRadius<28 then 
            intelRadius = 24 
            self.IntelRadiusGroup = 'From24To27'
        elseif intelRadius<32 then 
            intelRadius = 28 
            self.IntelRadiusGroup = 'From28To31'
        elseif intelRadius<36 then 
            intelRadius = 32 
            self.IntelRadiusGroup = 'From32To35'
        else WARN('CloakFields with radius above 32 are not supported.')
        end
        
        --# Give feedback to user
        if not self:IsBeingBuilt() then
            --# This dummy weapon indicates the range
            local weapon = self:GetWeaponByLabel('CloakFieldRadius')
            if weapon then weapon:ChangeMaxRadius(intelRadius) end
            --# Let user know exactly which range this was rounded to         
            self:FlashMessage("Cloakfield radius=".. repr(intelRadius), 2)
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I added this to be forked as a thread  
    --#*  by a cloak field unit from EnableIntel.
    --#**
    CloakEffectControlThread = function(self)
        while self:IsAlive() do
            --# In the elapsed time we might have been marked 
            --# as being in a cloak feild
            WaitSeconds(self.CloakUpdatePeriod)
            --# Units with an active CloakField mark other units that they cloak
            self:GiveCloakEffectToUnitsInRange()
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I moved code into here to make debugging easier.
    --#**
    UpdateOGridPositions = function(self)
        local SAB =         
            IntelFieldBoundsForRadius[self.IntelRadiusGroup].SourceAreaBounds
        local SRB =         
            IntelFieldBoundsForRadius[self.IntelRadiusGroup].SearchRectangleBounds
            
        --# OGrid position is based on unit position
        self.OGridPosition = self:GetPosition()
        --# Round down to nearest unit of distance
        self.OGridPosition.x = math.floor(self.OGridPosition.x)
        self.OGridPosition.z = math.floor(self.OGridPosition.z)
        
        --# Round down to nearest even number, as OGrids are 2x2
        self.OGridPosition.x = self.OGridPosition.x - math.mod(self.OGridPosition.x, SAB.XLength)
        self.OGridPosition.z = self.OGridPosition.z - math.mod(self.OGridPosition.z, SAB.ZLength)
  
        --# Patterns is centred 2 units to right of us
        self.OGridPosition.x =  self.OGridPosition.x + SAB.XStart
        self.OGridPosition.z =  self.OGridPosition.z + SAB.ZStart
        
        --# Define search rectangle used for
        --# fetching units to test if they are in range
        self.CloakFieldSearchRect = Rect(
            self.OGridPosition.x - SRB.XOffsetWest,
            self.OGridPosition.z - SRB.ZOffsetNorth, 
            self.OGridPosition.x + SRB.XOffsetEast, 
            self.OGridPosition.z + SRB.ZOffsetSouth
        )   
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  This runs inside a loop forked as thread.
    --#*  It makes units in its intelRadius eligible for cloak effects.
    --#**
    GiveCloakEffectToUnitsInRange = function(self)

        --# Update instance variables
        --# for where we are and where we search
        self:UpdateOGridPositions()
    
        --# Get units whose centres are in intelRadius, 
        --# this will include all unit sthat should be cloaked,
        --# plus some others we wil filter out next.
        local UnitsInSearchRect = 
            GetUnitsInRect(self.CloakFieldSearchRect)
        
        --# Mark each one except for ourselves
        for num, unit in UnitsInSearchRect do
            --# Perform safety check
            if unit:IsAlive() 
                --# Don't mark ourself
                and unit:GetEntityId() ~= self:GetEntityId()   
                --# This is one of our units, not theirs!!
                and (self:GetArmy() == unit:GetArmy()) 
                --# Defer to function call for neatness 
                and self:IsUnitInMyCloakFieldArea(unit) 
            then
                --# Mark the unit
                unit.InCloakField = true
        
                --# ACU marks units that it is already monitoring
                if not unit.IsRegisteredInCloakEffectUnitTable then
                    local myCommander = self:GetMyCommander()
                    --# If commander is alive...
                    if myCommander then
                        --# ACU will monitor this unit and switch off cloak effect
                        --# when it is not being marked anymore
                        myCommander:ReceiveACUMessage_RegisterUnit(unit, 'CloakEffectUnit')
                    end
                end
            end
        end
        
        --# Do this for safety
        self.OGridPosition = nil
        self.CloakFieldSearchRect = nil
        
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  You would assume that cloak is applied to units
    --#*  within a radius of the cloak field orogin, but
    --#*  this is not the case.  Units are cloaked if they are 
    --#*  anywhere inside one of the O-Grids that are in a
    --#*  pattern focused on the top left corner of the O-Grid
    --#*  that has the unit position of the cloak field source.
    --#*  The shape is not the closest approximation of a circle.
    --#**
    IsUnitInMyCloakFieldArea = function(self, unit)
        
        --# Note position of unit so we can work out 
        --# if it is close enough to be cloaked
        local unitPosition = unit:GetPosition()
        
        --# Is the unit within any of the rectangular 
        --# bounded areas where the cloak field covers?
        for k, vRect in IntelFieldBoundsForRadius[self.IntelRadiusGroup].EffectAreaBounds do
            if  (unitPosition.x >= (self.OGridPosition.x - vRect.XOffsetWest)) and 
                (unitPosition.z >= (self.OGridPosition.z - vRect.ZOffsetNorth)) and
                (unitPosition.x < (self.OGridPosition.x + vRect.XOffsetEast)) and 
                (unitPosition.z < (self.OGridPosition.z + vRect.ZOffsetSouth)) 
            then
                --# Unit is in a cloaked area
                return true
            end
        end      
        
        --# If we got this far, then
        --# Unit is not in cloaked area
        return false
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that the cloakfield thread will
    --#*  be killed when the unit dies. It probably would have been
    --#*  cleaned up eventually anyway.  
    --#**
    OnKilled = function(self, instigator, type, overkillRatio)
        --# Cloak Effect management thread needs to be killed if one exists
        if self.CloakEffectControlThreadHandle then
            KillThread(self.CloakEffectControlThreadHandle)
            self.CloakEffectControlThreadHandle = nil
        end
        baseClassArg.OnKilled(self, instigator, type, overkillRatio)
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that the cloakfield thread will only
    --#*  run while the cloakfield is on.
    --#**
    EnableIntel = function(self, intel)
        --# IN FA baseclass version is just an empty template
        baseClassArg.EnableIntel(self, intel)
        --# Cloak field turned on and 
        --# we have energy to run it
        --LOG('CFU: EnableIntel called on ' .. intel)
        if intel == 'CloakField' then 
            --# Start using transparent mesh
            --# unless we were already in cloakfield of 
            --# another cloakfield unit.
            self.HasOwnCloakEnabled= true
            if not self.InCloakField then
                self:UpdateCloakEffect() 
            end
            --# Launch thread that cloaks nearby units.
            if not self.CloakEffectControlThreadHandle then
                self.CloakEffectControlThreadHandle = 
                    ForkThread(self.CloakEffectControlThread, self)
            end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I overrided this so that the cloakfield thread will only
    --#*  run while the cloakfield is on.
    --#**
    DisableIntel = function(self, intel)
        --# IN FA baseclass version is just an empty template
        baseClassArg.DisableIntel(self, intel)
        --# Cloak field turned off or
        --# we don't have energy to run it
        --LOG('CFU: DisableIntel called on ' .. intel)
        if intel == 'CloakField' then
            --# Stop using transparent mesh
            --# unless we are in cloakfield of 
            --# another cloakfield unit.
            self.HasOwnCloakEnabled= false
            if not self.InCloakField then
                self:UpdateCloakEffect() 
            end
            --# Kill thread that cloaks nearby units.
            if self.CloakEffectControlThreadHandle then
                --# Stop putting cloak effect on other units
                KillThread(self.CloakEffectControlThreadHandle)
                self.CloakEffectControlThreadHandle = nil
            end
        end
        
        --# Debugging only
        if false then
            self:UpdateOGridPositions()
            LOG('OldCFU: X=' .. repr(self.OGridPosition.x) 
                   ..  ' Z=' .. repr(self.OGridPosition.z) 
            )
            --# Do this for safety
            self.OGridPosition = nil
            self.CloakFieldSearchRect = nil
        end
    end,
}

return resultClass

end