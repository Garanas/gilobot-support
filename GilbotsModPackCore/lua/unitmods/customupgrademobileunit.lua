--#****************************************************************************
--#**
--#**  Hook File:  /mods/GilbotsModPackCore/lua/unitmods/customupgrademobileunit.lua
--#**  
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Common code for my mobile units that upgrade.  
--#**
--#****************************************************************************

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeCustomUpgradeMobileUnit(   baseClassArg, 
                                        customUpgradeBoneArg, 
                                        scaleArg)

--# Define the class to return                                        
local resultClass = Class(baseClassArg) {

    CustomUpgradeEffects = {
        EffectBP = {'/effects/emitters/unit_upgrade_ambient_01_emit.bp'},
        Bone = customUpgradeBoneArg,
        Scale = scaleArg,
    },
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my 'Stat Slider' mod when enhancements
    --#*  are used that can change whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#**
    OnStopBeingBuilt = function(self, builder, layer)
        --# Do superclass version first
        baseClassArg.OnStopBeingBuilt(self, builder, layer)
        
        --# Declare non-static member variables here
        self.CustomUpgradeEffectsBag = false

        --# Upgrade costs less than building the new
        --# upgraded unit from scratch.  We take into
        --# aacount the mass and energy used to make this unit.        
        local bpEcon = self:GetBlueprint().Economy
        self.UpgradeDiscountAmounts = {
            Energy = (bpEcon.BuildCostEnergy*0.6), 
            Mass = (bpEcon.BuildCostMass*0.9),
        }
    end,
     

    
    --# This runs when unit starts upgrading
    OnStartBuild = function(self, unitBeingBuilt, order)
        
        --# Units with weapons that unpack may need to repack
        --# weapon before they can upgrade.
        if self.PreparingToUpgradeState and self.NotReadyToUpgrade then
            IssueStop({self})
            IssueClearCommands({self})
            ChangeState(self, self.PreparingToUpgradeState)
            return
        end
        
        --# Units that fly or hover need to land
        --# and hover effects may need to be cancelled.
        if self.GetIntoUpgradePosition then 
            self:GetIntoUpgradePosition()
        end
        --# Added this because when upgrading I have no animation
        --# and when enhancing, effect is too large
        self:CreateCustomUpgradeEffects()
        --# Call superclass version of method
        baseClassArg.OnStartBuild(self, self,unitBeingBuilt, order)
        
        --# If building from a new unit BP then turn it to face our way
        --# so it doesn't look like a separate unit
        if unitBeingBuilt:GetUnitId() == self:GetBlueprint().General.UpgradesTo then
            --# Make sure unit we are ugrading to has same orientation
            unitBeingBuilt:SetOrientation(self:GetOrientation(), true)
            self:MakeUpgradedUnitMirrorMyPosition(unitBeingBuilt)
        end
    end,
    
    --# Added this because when upgrading I have no animation
    --# and when enhancing, effect is too large
    CreateCustomUpgradeEffects = function(self)
          --# Remove any old effects
        self:DestroyCustomUpgradeEffects()
        --# Add new effects
        self.CustomUpgradeEffectsBag = {}
        for k, v in self.CustomUpgradeEffects.EffectBP do
            table.insert( 
                self.CustomUpgradeEffectsBag, 
                CreateAttachedEmitter( 
                    self, 
                    self.CustomUpgradeEffects.Bone, 
                    self:GetArmy(), 
                    v ):ScaleEmitter(self.CustomUpgradeEffects.Scale))
        end
    end,
        
    --# This runs when unit finishes upgrading
    OnStopBuild = function(self, unitBeingBuilt)
        --# Do this first
        self:DestroyCustomUpgradeEffects()
        --# Call superclass version of method
        baseClassArg.OnStopBuild(self,unitBeingBuilt)
        
        --# If an upgrade completed successfully...
        if unitBeingBuilt:GetUnitId() == self:GetBlueprint().General.UpgradesTo
        and unitBeingBuilt:GetFractionComplete() == 1 then
            --# The upgraded version should have
            --# the same toggle states as this one            
            if self.PassOnToggleStates then
                self:PassOnToggleStates(unitBeingBuilt)
            end
            self:PassOnVeterancy(unitBeingBuilt) 
            --# If we don't do this, we keep the
            --# upgrading version and have two units!
            self:Destroy()
        end
    end,
    

    --# Clean up any custom upgrading effects
    DestroyCustomUpgradeEffects = function(self)
        --# Destroy any old effects
        if self.CustomUpgradeEffectsBag then
            for k, v in self.CustomUpgradeEffectsBag do
                v:Destroy()
            end
            --# Setting it to false stops garbage collection 
            --# trying to destroy it when its already been destroyed
            self.CustomUpgradeEffectsBag = false
        end
    end,
    
    --# Clean up any custom upgrading effects when destroyed
    OnDestroy = function(self)
        self:DestroyCustomUpgradeEffects()
        baseClassArg.OnDestroy(self)
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I hooked these functions so that a fully enhanced unit
    --#*  can be replaced with the upgraded version of it.
    --#*  This means that double-clicking units will get
    --#*  all fully upgraded units - enahnced and prebuilt.
    --#**
    ReplaceMeWithUpgradedUnit = function(self)
        local pos = self:GetPosition()
        local qx, qy, qz, qw = unpack(self:GetOrientation())
        local newUnit =  CreateUnit(self:GetBlueprint().General.UpgradesTo, self:GetArmy(), pos.x, pos.y, pos.z, qx, qy, qz, qw)
        self:MakeUpgradedUnitMirrorMyPosition(newUnit)  
        self:PassOnVeterancy(newUnit)         
        --# Destroy this unit as it has been replaced
        self:Destroy()
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I moved code here because units that hover 
    --#*  need to land.  UAL0101 overrides this.
    --#**
    MakeUpgradedUnitMirrorMyPosition = function(self, unitBeingBuilt)
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#* 
    --#*  I moved code here because combat units
    --#*  need to pass on veterancy once they have 
    --#   finished creating the new unit.
    --#**
    PassOnVeterancy = function(self, unitBeingBuilt)
        --# Pass on any veterancy
        local unitKills = self:GetStat('KILLS', 0).Value
        if unitKills and unitKills > 0 then
            LOG('MakeUpgradedUnitMirrorMyPosition: Passing on kills=' .. repr(unitKills))
            unitBeingBuilt:SetStat('KILLS', unitKills)
        end
    end,
}

return resultClass

end