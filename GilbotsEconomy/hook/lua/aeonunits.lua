--#****************************************************************************
--#**
--#**  Hook File  :  /hook/lua/aeonunits.lua
--#**
--#**  Modded By :  Gilbot-X
--#**
--#**  Summary   :  Unit class generic definitions for Aeon faction.
--#**  
--#****************************************************************************

--#-------------------------------------------------------------
--#  MASS COLLECTION UNITS
--#-------------------------------------------------------------

local MakeSensitiveShieldUser = 
    import('/mods/GilbotsModPackCore/lua/autodefend/sensitiveshield.lua').MakeSensitiveShieldUser

--#* 
--#*  Gilbot-X says:
--#*
--#*  In the original aeonunits, when AMassCollectionUnit extends 
--#*  MassCollectionUnit it does not add any extra code.
--#*
--#*  In the original defaultunits.lua, when MassCollectionUnit extends StructureUnit
--#*  with some extra code which I have moved into GilbotMassCreationUnit.
--#*
--#*  I've also changed this so Aeon Mexes always pause production when upgrading.
--#**

local BaseClass = MakeSensitiveShieldUser(AMassCollectionUnit)
AMassCollectionUnit = Class(BaseClass) {

    --# This is required for the animation improvements
    --# but it occaisionally causes errors in FA because
    --# a new protection on calling WaitFor was introduced.
    --ActiveAnimationDoesNotUseInfiniteLoop = true,
    
    --# These units stop moving while upgrading.
    StopProductionWhileUpgrading = true,
    --# Another option.  If not set to true, then
    --# with the option above set, shields are always 
    --# on during an upgrade.
    MustDisableAutoDefendWhileUpgrading = true,
    
    --#* 
    --#*  Gilbot-X says:
    --#*
    --#*  This is called once our MeX is built and is ready to become
    --#*  active.  I always do my unit initilisation code here.
    --#**: 
    OnCreate = function(self)
        --# Call base class code first
        BaseClass.OnCreate(self)
        
        --# Get animation values from BP file
        self:GetAnimationSettings()
    end,
    
    
    --# The defaults are the values for the T1 MeX
    --# If the animations were made consistently, 
    --# we wouuldn't need this code.  In fact, 
    --# if I knew how to edit an animation file, 
    --# I would do that instead.  Maybe one day...
    PackedAtAnimationStart = true,
    UpgradesFromPacked = true,
    UnPackedAnimationFraction = 0.125,
    PackedUpAnimationFraction = 0,
    AnimationTurnTime = 0,
    AnimationTurnRate = 0,
    
    --# Get animation values from BP file
    GetAnimationSettings = function(self)
        local settings = self:GetBlueprint().Display.ActiveAnimationSettings
        if settings then 
            self.PackedAtAnimationStart = settings.PackedAtStart or false
            self.UpgradesFromPacked = settings.UpgradesFromPacked or false
            self.UnPackedAnimationFraction = settings.UnPackedFraction or 0
            self.PackedUpAnimationFraction = settings.PackedUpFraction or 0
            self.AnimationTurnTime = settings.TurnTime or 0
            self.AnimationTurnRate = settings.TurnRate or 0
            --# This is set based on animation settings
            self.IsPacked = self.PackedAtAnimationStart
        else
            WARN("AMassCollectionUnit: OnStopBeingBuilt: "..
                 "Could not find ActiveAnimationSettings in Blueprint file!") 
        end
        
    end,
    
    

    

    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  This function manipulates the open animation
    --#*  to give the effect of the unit packing/unpacking.
    --#*  This makes it look like the unit can change into a defensive position.
    --#*  Do not change the numerical values in these functions
    --#*  or the animation will lose its smoothness and appear to jump.
    --#*          
    --#*  This should play part of the animation but stop itself 
    --#*  in a position a certain fraction of the way through 
    --#*  where the Mex appears to be packed away.
    --#*  T1 animation starts and finishes packed, but 
    --#*  T2 and T3 animations start and finish in unpacked positions.
    --#*  Note: GPG version had code (that would never be reached) making it go backwards!!  
    --#*  IMO making it go backwards for one (part of) cycle actually looks worse.
    --#*
    --#**
    DoPackUpAnimation = function(self, isPackedRequested)
    
        --# This next line is just a safegaurd because
        --# a couple of cases this was running out of turn after an upgrade!
        --# Note: This code is not in the AutoPackUnit class because different units 
        --# use different animation manipulators to pack and unpack.
        --# The Aeon MeX uses its active animation.  Most units will use their 
        --# 'open' animation instead.       
        if not self.ActiveAnimationManipulator then
            WARN("Gilbot: Aeon MassCollectionUnit: DoPackUpAnimation: Called without ActiveAnimationManipulator!")
            return
        end
               
        --# Do we need to pack or unpack to acheive this?
        if isPackedRequested then 
            --# Sometimes this is enough to pack
            self:WaitUntilAnimationStart()

            --# Only do domething if we are not already packed
            if not self.PackedAtAnimationStart then 
                --# Play Part of Animation 
                self.ActiveAnimationManipulator:SetRate(self.AnimationTurnRate)
                while self.ActiveAnimationManipulator:GetAnimationTime() < self.AnimationTurnTime do
                    WaitTicks(1)
                end
                --# Stop animation at near enough right place
                self.ActiveAnimationManipulator:SetRate(0)
            end
              
        --# We are activating production, so perform unpack animation.
        else
            --# We are unpacking
            self.AnimationIsAtBeginning = false
        
            --# Always assume we were packed.  Play Part of Animation backwards...
            local startTime = self.ActiveAnimationManipulator:GetAnimationTime()
            local nowTime = startTime
            local timeDif = 0
            self.ActiveAnimationManipulator:SetRate(-1* self.AnimationTurnRate)
            while timeDif < self.AnimationTurnTime do 
                nowTime = self.ActiveAnimationManipulator:GetAnimationTime()
                timeDif = math.abs(nowTime - startTime)
                WaitTicks(2)
            end
              
            --# Stop animation at near enough right place
            self.ActiveAnimationManipulator:SetRate(0)
            
            --# Force animation into more exact down position specified in script
            --self.ActiveAnimationManipulator:SetAnimationFraction(self.UnPackedAnimationFraction)
            if not self.PackedAtAnimationStart then 
                self.ActiveAnimationManipulator:SetAnimationFraction(self.UnPackedAnimationFraction)
                if self.UnPackedAnimationFraction == 0 then 
                    self.AnimationIsAtBeginning = true
                end
            end
        end
    end,
  
}