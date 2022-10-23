--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/timebasedmasscollectionunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Used by MeX so that mass output increases over time.
--#*            It is code from my Exponential Mass Extractors mod.
--#*
--#*****************************************************************************

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local MakeTimeBasedOutputUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/timebasedoutputunit.lua').MakeTimeBasedOutputUnit


--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeTimeBasedOutputMassCollectionUnit(baseClassArg)
    --# Setup baseclass
    local BaseClass = MakeTimeBasedOutputUnit(baseClassArg)
    
local resultClass = Class(BaseClass) {

    --# These next few variables are added by the Exponential Mass mod
    --# All production is (base value from BP) * ProductionPercentageIncrease
    ProductionUpdateSeconds = 30,   --  Move up to 60 seconds?
        
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This function consists of code added by the Exponential Mass mod
    --#**
    UpdateActiveAnimation = function(self)
            
        --# The bonus factor is the ratio increase of production rate 
        --# rounded to 1 dp with this bit of maths
        local increaseRatio = (math.floor(10 * self.ProductionPercentageIncrease['Aggregate'])) /10
        
        --# Apply a animation increase effect here only if 
        --# the animation rate can increase by at least 0.1!
        if increaseRatio - self.ActiveAnimationRate > 0.1 then
            
            --# Keep this as a linear function or make it logarithmic?
            self.ActiveAnimationRate = increaseRatio
            
            --# This stops the animations from going so fast 
            --# that they just look like the Mex is vibrating!!
            if self.ActiveAnimationRate > self.ActiveAnimationMaxRate then 
                self.ActiveAnimationRate = self.ActiveAnimationMaxRate 
            end
            --# Only update anim speed now if we are neither paused not upgrading
            if not self.IsProductionPaused and not self:IsUnitState('Upgrading') then
                self:PauseActiveAnimation(false)
            end
        end
          
    end,
    
}

return resultClass

end--(of function definition)