--#****************************************************************************
--#**
--#**  New File:   /mods/GilbotsModPackCore/lua/unitmods/togglefactory.lua
--#**  Modded by:  Gilbot-X
--#**
--#**  Summary  :  
--#**     This is the code for factory units that have toggles
--#**     which set what toggles are switched on on the units they build.
--#**
--#****************************************************************************


--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeToggleFactoryUnit(baseClassArg)

local resultClass = Class(baseClassArg) {

    --# This flag gives us a quick way to test
    --# if a unit is inheriting this abstract class
    IsToggleFactory = true,

    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  I add to this function override to do some table initialisation.
    --#*  When I did it in OnStopBeingBuilt I got errors, so that was too late.
    --#**
    OnCreate = function(self)
        --# Next 2 lines are the only original GPG code
        --# that were in this function override.
        baseClassArg.OnCreate(self)
        
        self.BuildingUnit = false
        
        --# Gilbot-X says: (June 23rd 2007)
        --# Moved this inside function call because
        --# other factories were changing the state
        --# of the toggles - they were acting like 
        --# global variables!!
        self.ToggleList = {
            ShieldToggle =  { IsToggledOn = false, SetBitToActivate = true },
            WeaponToggle =  { IsToggledOn = true,  SetBitToActivate = false },
            StealthToggle = { IsToggledOn = true,  SetBitToActivate = false },
            IntelToggle =   { IsToggledOn = true,  SetBitToActivate = false },
            JammingToggle = { IsToggledOn = true,  SetBitToActivate = false },
            CloakToggle =   { IsToggledOn = true,  SetBitToActivate = false },
        }
    end,
    

    
    --# Call this from OnStopBuild this so we can control what intel/stealth/shield 
    --# toggles are set to when a unit is built
    PassOnTogglesToUnits = function(self)

        for k,v in self.ToggleList do 
            --# Now take care of cloaking
            local capsName = 'RULEUTC_' .. k
            --# Had to place a check here to stop errors
            --# happening when factories were under attack.
            if self.UnitBeingBuilt:IsAlive() 
                --# If the unit being built has this toggle
                and self.UnitBeingBuilt:TestToggleCaps(capsName)
                --# Don't set bit 1 on autotoggle units as it can cause errors
                and not (self.UnitBeingBuilt.IsAutoToggleUnit and (k=='WeaponToggle'))
            then 
                --# if it toggled on at the factory
                if v.IsToggledOn then
                    --# toggle it on at the unit being built
                    --LOG("Factory Toggles Mod: Switching on " .. capsName)
                    --# Note that this next line will do nothing if this toggle is already on
                    self.UnitBeingBuilt:SetScriptBit(capsName, v.SetBitToActivate)
                else
                    --# make sure it is toggled off at the unit being built
                    self.UnitBeingBuilt:SetScriptBit(capsName, not v.SetBitToActivate)
                end
            end
        end
        
        --# Doing this makes sure we get correct consumption values
        --# for units that use ResourceDrainBreakDown mod
        if self.UnitBeingBuilt.ResourceDrainBreakDown then
            --LOG("Factory Toggles Mod: This unit has resource consumption breakdown.")        
            self.UnitBeingBuilt:UpdateConsumptionValues() 
        end
        
        
    end,
        
        
        
    --#*    
    --#*  Gilbot-X says:
    --#*
    --#*  I override this function (which is originally defined 
    --#*  in Unit.lua) so factory can toggle how units are built.
    --#*
    --#**
    OnScriptBitSet = function(self, bit)
        if bit == 0 then     --# shield toggle
            self.ToggleList.ShieldToggle.IsToggledOn = 
            self.ToggleList.ShieldToggle.SetBitToActivate
        elseif bit == 1 then --# weapon toggle
            self.ToggleList.WeaponToggle.IsToggledOn =  
            self.ToggleList.WeaponToggle.SetBitToActivate    
        elseif bit == 2 then --# jamming toggle
            self.ToggleList.JammingToggle.IsToggledOn =  
            self.ToggleList.JammingToggle.SetBitToActivate
        elseif bit == 3 then --# intel toggle
            self.ToggleList.IntelToggle.IsToggledOn =  
            self.ToggleList.IntelToggle.SetBitToActivate
        elseif bit == 5 then --# stealth toggle
            self.ToggleList.StealthToggle.IsToggledOn =  
            self.ToggleList.StealthToggle.SetBitToActivate
        elseif bit == 8 then --# cloak toggle
            self.ToggleList.CloakToggle.IsToggledOn =  
            self.ToggleList.CloakToggle.SetBitToActivate
        else
            FactoryUnit.OnScriptBitSet(self,bit)
        end
    end,

    --#*    
    --#*  Gilbot-X says:
    --#*
    --#*  I override this function (which is originally defined 
    --#*  in Unit.lua) so factory can toggle how units are built.
    --#*
    --#**
    OnScriptBitClear = function(self, bit)
        if bit == 0 then     --# shield toggle
            self.ToggleList.ShieldToggle.IsToggledOn = not
            self.ToggleList.ShieldToggle.SetBitToActivate
        elseif bit == 1 then --# weapon toggle
            self.ToggleList.WeaponToggle.IsToggledOn = not
            self.ToggleList.WeaponToggle.SetBitToActivate    
        elseif bit == 2 then --# jamming toggle
            self.ToggleList.JammingToggle.IsToggledOn = not
            self.ToggleList.JammingToggle.SetBitToActivate
        elseif bit == 3 then --# intel toggle
            self.ToggleList.IntelToggle.IsToggledOn = not
            self.ToggleList.IntelToggle.SetBitToActivate
        elseif bit == 5 then --# stealth toggle
            self.ToggleList.StealthToggle.IsToggledOn = not
            self.ToggleList.StealthToggle.SetBitToActivate
        elseif bit == 8 then --# cloak toggle
            self.ToggleList.CloakToggle.IsToggledOn = not
            self.ToggleList.CloakToggle.SetBitToActivate
        else
           FactoryUnit.OnScriptBitClear(self,bit)
        end
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  Had to mod this to make sure factory toggles 
    --#*  are passed on to upgraded factory when a factory  
    --#*  completes its upgrade and destroys itself.
    --#**
    UpgradingState = State {
        
        --# Defer calls to super class version
        Main = baseClassArg.UpgradingState.Main,

        --# Gilbot-X says: 
        --# I overrided this to call my PassOnTogglesToUnits 
        --# function at the end of a successful upgrade.
        OnStopBuild = function(self, unitBuilding)
            import('/lua/sim/unit.lua').Unit.OnStopBuild(self, unitBuilding)
            self:EnableDefaultToggleCaps()
            if unitBuilding:GetFractionComplete() == 1 then
                NotifyUpgrade(self, unitBuilding)
                self:StopUpgradeEffects(unitBuilding)
                self:PlayUnitSound('UpgradeEnd')
                
                --# Gilbot-X says:  I added this next line so that when 
                --# factories upgrade they pass on toggles. 
                self:PassOnTogglesToUnits()
                
                --# Finally the rest is GPG code.
                self:Destroy()
            end
        end,

        --# Defer calls to super class version
        OnFailedToBuild = baseClassArg.UpgradingState.OnFailedToBuild,
        
    },
    
    
    
    --#-------------------------------------------------------------
    --#  Gilbot-X: The rest is GPG code with just two 
    --#  lines inserted by me that make calls to my code
    --#-------------------------------------------------------------
    
    OnStopBeingBuilt = function(self,builder,layer)
        local aiBrain = GetArmyBrain(self:GetArmy())
        aiBrain:ESRegisterUnitMassStorage(self)
        aiBrain:ESRegisterUnitEnergyStorage(self)
        local curEnergy = aiBrain:GetEconomyStoredRatio('ENERGY')
        local curMass = aiBrain:GetEconomyStoredRatio('MASS')
        if curEnergy > 0.11 and curMass > 0.11 then
            self:CreateBlinkingLights('Green')
            self.BlinkingLightsState = 'Green'
        else
            self:CreateBlinkingLights('Red')
            self.BlinkingLightsState = 'Red'
        end
        baseClassArg.OnStopBeingBuilt(self,builder,layer)
        
        --# Gilbot-X: I added this.
        --# so shield toggle starts ON by default on T1 factory.
        --# Upgraded factories get whatever the old factory had.
        --# T3 Quantum Gateway also starts with shield on by default.
        if EntityCategoryContains(categories.TECH1, self) or 
           EntityCategoryContains(categories.GATE, self) then
            self:SetScriptBit('RULEUTC_ShieldToggle', true)
            self:RequestRefreshUI()
        end
    end,

    
    OnPaused = function(self)
        --# When factory is paused take some action
        self:StopUnitAmbientSound( 'ConstructLoop' )
        baseClassArg.OnPaused(self)
    end,
    
    OnUnpaused = function(self)
        if self.BuildingUnit then
            self:PlayUnitAmbientSound( 'ConstructLoop' )
        end
        baseClassArg.OnUnpaused(self)
    end,
    
    ChangeBlinkingLights = function(self, state)
        local bls = self.BlinkingLightsState
        if state == 'Yellow' then
            if bls == 'Green' then
                self:CreateBlinkingLights('Yellow')
                self.BlinkingLightsState = state
            end
        elseif state == 'Green' then
            if bls == 'Yellow' then
                self:CreateBlinkingLights('Green')
                self.BlinkingLightsState = state
            elseif bls == 'Red' then
                local aiBrain = GetArmyBrain(self:GetArmy())
                local curEnergy = aiBrain:GetEconomyStoredRatio('ENERGY')
                local curMass = aiBrain:GetEconomyStoredRatio('MASS')
                if curEnergy > 0.11 and curMass > 0.11 then
                    if self:GetNumBuildOrders(categories.ALLUNITS) == 0 then
                        self:CreateBlinkingLights('Green')
                        self.BlinkingLightsState = state
                    else
                        self:CreateBlinkingLights('Yellow')
                        self.BlinkingLightsState = 'Yellow'
                    end
                end
            end
        elseif state == 'Red' then
            self:CreateBlinkingLights('Red')
            self.BlinkingLightsState = state
        end
    end,

    OnMassStorageStateChange = function(self, newState)
        if newState == 'EconLowMassStore' then
            self:ChangeBlinkingLights('Red')
        else
            self:ChangeBlinkingLights('Green')
        end
    end,

    OnEnergyStorageStateChange = function(self, newState)
        if newState == 'EconLowEnergyStore' then
            self:ChangeBlinkingLights('Red')
        else
            self:ChangeBlinkingLights('Green')
        end
    end,

    OnStartBuild = function(self, unitBeingBuilt, order )
        self:ChangeBlinkingLights('Yellow')
        baseClassArg.OnStartBuild(self, unitBeingBuilt, order )
        self.UnitBeingBuilt = unitBeingBuilt
        self.BuildingUnit = true
        if order ~= 'Upgrade' then
            ChangeState(self, self.BuildingState)
            self.BuildingUnit = false
        end
        self.FactoryBuildFailed = false
    end,

    OnStopBuild = function(self, unitBeingBuilt, order )
        baseClassArg.OnStopBuild(self, unitBeingBuilt, order )
        
        if not self.FactoryBuildFailed then
            if not EntityCategoryContains(categories.AIR, self.UnitBeingBuilt) then
                self:RollOffUnit()
            end
            self:StopBuildFx()
            self:ForkThread(self.FinishBuildThread, self.UnitBeingBuilt, order )
        end
        self.BuildingUnit = false
    end,

    FinishBuildThread = function(self, unitBeingBuilt, order )
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        local bp = self:GetBlueprint()
        local bpAnim = bp.Display.AnimationFinishBuildLand
        if bpAnim and EntityCategoryContains(categories.LAND, self.UnitBeingBuilt) then
            self.RollOffAnim = CreateAnimator(self):PlayAnim(bpAnim)
            self.Trash:Add(self.RollOffAnim)
            WaitTicks(1)
            WaitFor(self.RollOffAnim)
        end
        if self.UnitBeingBuilt:IsAlive() then
            self.UnitBeingBuilt:DetachFrom(true)
        end
        self:DetachAll(bp.Display.BuildAttachBone or 0)
        self:DestroyBuildRotator()
        
        if order ~= 'Upgrade' then
            ChangeState(self, self.RollingOffState)
        else
            self:SetBusy(false)
            self:SetBlockCommandQueue(false)
            --# Gilbot-X says:  I added this line call to my code
            LOG('PassOnTogglesToUnits called outside Upgrading state.')
            self:PassOnTogglesToUnits()
        end
    end,

    CheckBuildRestriction = function(self, target_bp)
        if self:CanBuild(target_bp.BlueprintId) then
            return true
        else
            return false
        end
    end,
    
    OnFailedToBuild = function(self)
        self.FactoryBuildFailed = true        
        baseClassArg.OnFailedToBuild(self)
        self:DestroyBuildRotator()
        self:StopBuildFx()
        ChangeState(self, self.IdleState)
    end,

    RollOffUnit = function(self)
        local spin, x, y, z = self:CalculateRollOffPoint()
        local units = { self.UnitBeingBuilt }
        self.MoveCommand = IssueMove(units, Vector(x, y, z))
    end,
    
    CalculateRollOffPoint = function(self)
        local bp = self:GetBlueprint().Physics.RollOffPoints
        local px, py, pz = unpack(self:GetPosition())
        if not bp then return 0, px, py, pz end
        local vectorObj = self:GetRallyPoint()
        local bpKey = 1
        local distance, lowest = nil
        for k, v in bp do
            distance = VDist2(vectorObj[1], vectorObj[3], v.X + px, v.Z + pz)
            if not lowest or distance < lowest then
                bpKey = k
                lowest = distance
            end
        end
        local fx, fy, fz, spin
        local bpP = bp[bpKey]
        local unitBP = self.UnitBeingBuilt:GetBlueprint().Display.ForcedBuildSpin
        if unitBP then
            spin = unitBP
        else
            spin = bpP.UnitSpin
        end
        fx = bpP.X + px
        fy = bpP.Y + py
        fz = bpP.Z + pz
        return spin, fx, fy, fz
    end,
    
    StartBuildFx = function(self, unitBeingBuilt)
        
    end,
    
    StopBuildFx = function(self)
        
    end,

    PlayFxRollOff = function(self)
    end,
    
    PlayFxRollOffEnd = function(self)
        if self.RollOffAnim then        
            self.RollOffAnim:SetRate(-1)
            WaitFor(self.RollOffAnim)
            self.RollOffAnim:Destroy()
            self.RollOffAnim = nil
        end
    end,
    
    CreateBuildRotator = function(self)
        if not self.BuildBoneRotator then
            local spin = self:CalculateRollOffPoint()
            local bp = self:GetBlueprint().Display
            self.BuildBoneRotator = CreateRotator(self, bp.BuildAttachBone or 0, 'y', spin, 10000)
            self.Trash:Add(self.BuildBoneRotator)
        end
    end,
    
    DestroyBuildRotator = function(self)
        if self.BuildBoneRotator then
            self.BuildBoneRotator:Destroy()
            self.BuildBoneRotator = nil
        end
    end,
    
    IdleState = State {

        Main = function(self)
            self:ChangeBlinkingLights('Green')
            self:SetBusy(false)
            self:SetBlockCommandQueue(false)
            self:DestroyBuildRotator()
        end,
    },

    BuildingState = State {

        Main = function(self)
            local bp = self:GetBlueprint()
            local bone = bp.Display.BuildAttachBone or 0
            self:DetachAll(bone)
            self.UnitBeingBuilt:AttachBoneTo(-2, self, bone)
            self:CreateBuildRotator()
            self:StartBuildFx(self.UnitBeingBuilt)
        end,
    },


    --# Changed in FA to call function defined after
    RollingOffState = State {
        Main = function(self)
            self:RolloffBody()
        end,
    },

    
    --# New in FA
    RolloffBody = function(self)
        self:SetBusy(true)
        self:SetBlockCommandQueue(true)
        self:PlayFxRollOff()
        --# Wait until unit has left the factory
        while self.UnitBeingBuilt:IsAlive() and self.MoveCommand 
          and not IsCommandDone(self.MoveCommand) do
            WaitSeconds(0.5)
        end
        self.MoveCommand = nil
        self:PlayFxRollOffEnd()
        self:SetBusy(false)
        self:SetBlockCommandQueue(false)
 
        --# Gilbot-X says:  I added this line call to my code
        self:PassOnTogglesToUnits()

        ChangeState(self, self.IdleState)
    end,
    
    
    --# This is added in FA so that unit being build dies when factory dies
    OnKilled = function(self, instigator, type, overkillRatio)
        baseClassArg.OnKilled(self, instigator, type, overkillRatio)
        if self.UnitBeingBuilt then
            self.UnitBeingBuilt:Destroy()
        end
    end,
}

return resultClass

end