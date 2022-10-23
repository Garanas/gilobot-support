do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /units/UAB1102/UAB1102_script.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Aeon Hydrocarbon Power Plant Script
--#**
--#**              Original file has 40 lines.
--#**
--#****************************************************************************

local HydroCarbonPowerPlant = 
    import('/mods/GilbotsModPackCore/lua/unitmods/hcpp.lua').HydroCarbonPowerPlant
local MakeSensitiveShieldUser = 
    import('/mods/GilbotsModPackCore/lua/autodefend/sensitiveshield.lua').MakeSensitiveShieldUser
local BaseClass = MakeSensitiveShieldUser(HydroCarbonPowerPlant)

UAB1102 = Class(BaseClass) {

    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Initialisation.
    --#**
    OnCreate = function(self)
        --# Call base class version first
        BaseClass.OnCreate(self)
        
        --# Unit starts with unpacking animation automatically unpacking it
        self.AnimationFile = '/Units/UAB1102/UAB1102_Aopen.sca'
        --# This is not an 'ActiveAnimation unit' but it does pack/unpack,
        --# so we need to create the animation manipulator here.
        self.AnimationManipulator = CreateAnimator(self)
        self.Trash:Add(self.AnimationManipulator)
        
        --# This is the only unit that defines this in its
        --# OnCreate function.  The AMassCollectionUnit class
        --# sets it according to settings in BP files.
        self.IsPacked = true
    end,
    
    
    

    --#* 
    --#*  Gilbot-X says:
    --#* 
    --#*  This function manipulates the open animation
    --#*  to give the effect of the unit packing/unpacking.
    --#*  This makes it look like the unit can change into a defensive position.
    --#*  Do not change the numerical values in these functions
    --#*  or the animation will lose its smoothness and appear to jump.
    --#**
    DoPackUpAnimation = function(self, isPackedRequested)
        --# Do we need to pack or unpack to acheive this?
        if isPackedRequested then 
            --# We are deactivating production, so perform pack animation
            --# The three numerical values below must not be changed.
            self.AnimationManipulator:PlayAnim(self.AnimationFile, true):SetRate(-0.5)
            WaitSeconds(4.9)
            self.AnimationManipulator:PlayAnim(self.AnimationFile, false):SetRate(-0.1)
            WaitFor(self.AnimationManipulator)
        else
            --# We are activating production, so perform unpack animation.
            --# This numerical value can be changed.
            self.AnimationManipulator:PlayAnim(self.AnimationFile, false):SetRate(0.2)
            WaitFor(self.AnimationManipulator)
        end
    end,
    

}

TypeClass = UAB1102
end --(of non-destructive hook)