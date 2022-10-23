--#****************************************************************************
--#*
--#*  New File:   /mods/GilbotsModPackCore/lua/unitmods/structureunit.lua
--#*
--#*  Modded by:  Gilbot-X
--#*
--#*  Summary  :  
--#*     I added some code in CreateBlinkingLights.
--#*
--#*
--#****************************************************************************


--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function ModStructureUnit(baseClassArg)

local resultClass = Class(baseClassArg) {

    --#*
    --#* Gilbot-X says:
    --#*
    --#* I changed this so that when storgae units are built underwater
    --#* the blinking lights don't appear on the surface!
    --#*
    --#**
    CreateBlinkingLights = function(self, color)
        self:DestroyBlinkingLights()
        local bp = self:GetBlueprint().Display.BlinkingLights
        local bpEmitters = self:GetBlueprint().Display.BlinkingLightsFx
        if bp then
            local fxbp = bpEmitters[color]
            for k, v in bp do
                if type(v) == 'table' then
                    local fx = CreateAttachedEmitter(self, v.BLBone, self:GetArmy(), fxbp)
                    fx:OffsetEmitter(v.BLOffsetX or 0, 
                                    --# Added 0.015625 min y-offset here so 
                                    --# all blinking lights definitely visible.
                                    --# Note that UEF and Cybran Mass Storage
                                    --# swap Y and Z offsets when effects appear
                                    --# so they are also swapped in BP files.
                                    --# GPG, you have some shit programmers!!
                                    v.BLOffsetY or 0.015625,
                                    v.BLOffsetZ or 0)
                    fx:ScaleEmitter(v.BLScale or 1)
                    table.insert(self.FxBlinkingLightsBag, fx)
                    self.Trash:Add(fx)
                end
            end
        end
    end,

    UpgradingState = State {
        Main = function(self)
            self:StopRocking()
            local bp = self:GetBlueprint().Display
            self:DestroyTarmac()
            self:PlayUnitSound('UpgradeStart')
            self:DisableDefaultToggleCaps()
            if bp.AnimationUpgrade then
                local unitBuilding = self.UnitBeingBuilt
                self.AnimatorUpgradeManip = CreateAnimator(self)
                self.Trash:Add(self.AnimatorUpgradeManip)
                local fractionOfComplete = 0
                self:StartUpgradeEffects(unitBuilding)
                self.AnimatorUpgradeManip:PlayAnim(bp.AnimationUpgrade, false):SetRate(0)

                while fractionOfComplete < 1 and not (self:IsDead() or unitBuilding:IsDead()) do
                    fractionOfComplete = unitBuilding:GetFractionComplete()
                    self.AnimatorUpgradeManip:SetAnimationFraction(fractionOfComplete)
                    WaitTicks(1)
                end
                if not self:IsDead() then
                    self.AnimatorUpgradeManip:SetRate(1)
                end
            end
        end,

        OnStopBuild = baseClassArg.UpgradingState.OnStopBuild,
        OnFailedToBuild = baseClassArg.UpgradingState.OnFailedToBuild,
    },
    

    --#---------------------------------------------------------------------------------------------
    --#  Adjacency
    --#---------------------------------------------------------------------------------------------
   
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I removed adjacency code so that only units that extend the 
    --#*  AdjacencyStructureUnit class can be connected to networks and get bonuses.
    --#**
    OnAdjacentTo = function(self, adjacentUnit, triggerUnit) end,
    OnNotAdjacentTo = function(self, adjacentUnit) end,
    CreateAdjacentEffect = function(self, adjacentUnit) end,
    DestroyAdjacentEffects = function(self, adjacentUnit) end,
}

return resultClass

end