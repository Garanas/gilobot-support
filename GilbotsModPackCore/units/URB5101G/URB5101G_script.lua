--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units/URB5101G/URB5101G_script.lua
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran T4 Pipeline Generator / Wall Piece Script
--#**
--#****************************************************************************
local CWallStructureUnit = import('/lua/cybranunits.lua').CWallStructureUnit
local EffectTemplate = import('/lua/EffectTemplates.lua')

    --# Static and constant variables declared here
local HeightToRaiseTowerDuringUpgrade = 0.3
local HeightToLowerTowerBeforeUpgrade = 0.1
--local ZOffsetToCentrePipeLine = -0.19
local ZOffsetToCentrePipeLine = -0.2
    
URB5101G = Class(CWallStructureUnit) {

    UpgradeEffects = {
        '/effects/emitters/unit_upgrade_ambient_01_emit.bp',
    },
    
        
    OnStopBeingBuilt = function(self,builder,layer)
        CWallStructureUnit.OnStopBeingBuilt(self,builder,layer)
        
        --# Don't let these be treated as static!
        self.UpgradeEffectsBag = false
    end,
    
    
     --# This runs when unit starts upgrading
    OnStartBuild = function(self, unitBeingBuilt, order)
        --# Stop another new unit from being built
        --# while we are already building one
        self:AddBuildRestriction(categories.BUILTBYT4WALL)
        self.PipeLine = unitBeingBuilt
        
        --# Call superclass version of method
        
        CWallStructureUnit.OnStartBuild(self, unitBeingBuilt, order)
        
        --# This was needed as it wouldn't go into upgrading state
        --# when doing this the second time, although order was still 'upgrade'.
        if self.HasUpgradedBefore then
            ChangeState(self, self.UpgradingState) 
        end
    end,
    
    

        
    --#*
    --#*  Gilbot-X says:        
    --#*   
    --#*  This is defined in the StructureUnit class.
    --#*  I override it to deal with my building effects. 
    --#*  The unit is not really upgrading, it is just
    --#*  building a pipeline unit.  Using the upgrade 
    --#*  mechanism stops the engine from letting the user
    --#*  be able to choose where to build the pipeline.
    --#**
    UpgradingState = State {
     
        --#*
        --#*  Bypass upgrade animation code.
        --#**
        Main = function(self)
            --# Use upgrade effects
            self:PlayUnitSound('UpgradeStart')
            self:AddUpgradeEffects()
            
            --# Save 4 position objects for raising the tower
            local loweredYPosition = self:GetPosition().y - HeightToLowerTowerBeforeUpgrade
            local raisedYPosition = loweredYPosition + HeightToRaiseTowerDuringUpgrade
            local correctedZPosition = self:GetPosition().z + ZOffsetToCentrePipeLine
            local currentHubEffectPosition = self:GetPosition() 
            local currentTowerPosition = self:GetPosition() 
    
            --# Adjust Z values of lowered/raised and 2 current positions
            --# because there is a Z-offset needed between the base and 
            --# the pipeline to have them centred on top of each other.
            currentHubEffectPosition.z = correctedZPosition
            currentTowerPosition.z = correctedZPosition
            --# Set heights of lowest position
            currentTowerPosition.y = loweredYPosition
            currentHubEffectPosition.y = loweredYPosition
                    
            --# Set tower to lowest position
            self.PipeLine:SetPosition(currentTowerPosition, true)
 
            --# This is a bit early but there were problems doing it later
            --# because the unit being built wanted to know it's builder's
            --# skirt size before it OnStopBuilt() was called!
            self.PipeLine:SetContainingStructure(self)
                    
            local fractionComplete = 0
            --# While still building the pipeline node...
            while fractionComplete < 1 do
                WaitTicks(1)
                fractionComplete = self.PipeLine:GetFractionComplete()
             
                --# Change height according to how much is built.
                --# First move coloured tower only
                if fractionComplete < 0.25 then 
                    currentTowerPosition.y = loweredYPosition + 
                        --# This will raise the tower to double the top position
                        (fractionComplete * 8 * HeightToRaiseTowerDuringUpgrade)
                    --# This value kept on resetting!!!
                    currentTowerPosition.z = correctedZPosition
                    self.PipeLine:SetPipeLineTowerOnlyPosition(currentTowerPosition, false)
                --# Then raise black prism only
                elseif fractionComplete < 0.75 then 
                    --# This will raise the hub effect to top position
                    currentHubEffectPosition.y = loweredYPosition + 
                        (fractionComplete - 0.25) * 2 * HeightToRaiseTowerDuringUpgrade
                    --# This value kept on resetting!!!
                    currentHubEffectPosition.z = correctedZPosition
                    self.PipeLine:SetHubOnlyPosition(currentHubEffectPosition)
                else
                    --# Finally lower the glowing outer tower
                    currentTowerPosition.y = loweredYPosition + 
                        --# Starting from twice the maximum tower raise, 
                        (2*HeightToRaiseTowerDuringUpgrade) 
                        --# Subtract up to once the tower raise, so you finish with a single tower raise.
                        - (4*(fractionComplete-0.75)*HeightToRaiseTowerDuringUpgrade)
                    --# This value kept on resetting!!!
                    currentTowerPosition.z = correctedZPosition
                    self.PipeLine:SetPipeLineTowerOnlyPosition(currentTowerPosition, false)
                end   
            end
            
            --# Make sure pipeline is in finished position
            currentTowerPosition.y = raisedYPosition
            self.PipeLine:SetPosition(currentTowerPosition, false)
            
            --# Does this mean we can go back into UpgradingState a second time?
            ChangeState(self, self.IdleState)
        end,
        
        --#*
        --#*  Need to kill animation effects and 
        --#*  don't allow another pipeline to be built.
        --#*  Give new pipeline a reference to its builder, 
        --#*  i.e. this unit.  We provide its skirt.
        --#**
        OnStopBuild = function(self, unitBuilding)
          LOG('T4 Pipeline Generator: UpgradingState: OnStopBuild Called')
          
            --# Destroy any old effects    
            self:DestroyUpgradeEffects()
            
            --# Allow unit to toggle things again
            --self:EnableDefaultToggleCaps()
            if unitBuilding:GetFractionComplete() == 1 then
                --# Gilbot-X says:
                --# This is from StructureUnit class
                NotifyUpgrade(self, unitBuilding)
                self:PlayUnitSound('UpgradeEnd')
                self.HasUpgradedBefore = true
            else
                --# Gilbot-X says:
                --# This is also my code.
                self:OnPipeLineKilled()
            end
            
            --# Call baseclass code last.
            CWallStructureUnit.OnStopBuild(self, unitBuilding)
        end,

        --#*
        --#*  Need to kill animation effects and 
        --#*  allow another pipeline to be built.
        --#**
        OnFailedToBuild = function(self)
            LOG('T4 Pipeline Generator: UpgradingState: OnFailedToBuild Called')
            
            --# Destroy any old effects    
            self:DestroyUpgradeEffects()
            self:PlayUnitSound('UpgradeFailed')
        
            --# Gilbot-X says:
            --# This is the GPG code from StructureUnit class
            --# that normally gets executed.
            CWallStructureUnit.OnFailedToBuild(self)
            
            --# Gilbot-X says:
            --# This is my code.
            --# Stop Animation thread as upgrade was stopped?
            self:OnPipeLineKilled()
                
            --# Gilbot-X says:
            --# This is the GPG code from StructureUnit class
            --# that normally gets executed.
            ChangeState(self, self.IdleState)
        end,

    },
    
    
    
    --#*
    --#*  Gilbot-X says:        
    --#*   
    --#*  I added this for common code when a pipeline dies
    --#*  or fails to build for some reason so we can build another.
    --#*  Also called by the pipeline itself from its OnKilled.
    --#**
    OnPipeLineKilled = function(self)
        self.PipeLine = nil
        self:RemoveBuildRestriction(categories.BUILTBYT4WALL)
    end,
            
            
            
    --#*
    --#*  Gilbot-X says:        
    --#*   
    --#*  I added this to deal with my building effects. 
    --#*  The unit is not really upgrading, it is just
    --#*  building a pipeline unit.  Using the upgrade 
    --#*  mechanism stops the engine from letting the user
    --#*  be able to choose where to build the pipeline.
    --#**
    DestroyUpgradeEffects = function(self)
        --# Destroy any old effects
        if self.UpgradeEffectsBag then
            for k, v in self.UpgradeEffectsBag do
                v:Destroy()
            end
            --# Setting it to false stops garbage collection 
            --# trying to destroy it when its already been destroyed
            self.UpgradeEffectsBag = false
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:        
    --#*   
    --#*  I added this to deal with my building effects. 
    --#*  The unit is not really upgrading, it is just
    --#*  building a pipeline unit.  Using the upgrade 
    --#*  mechanism stops the engine from letting the user
    --#*  be able to choose where to build the pipeline.
    --#**
    AddUpgradeEffects = function(self)
        
        --# Destroy any old effects
        self:DestroyUpgradeEffects()
        self.UpgradeEffectsBag = {}
        
        --# Add new effects
        for k, vEffect in self.UpgradeEffects do
            table.insert( self.UpgradeEffectsBag, 
              CreateAttachedEmitter( self, 'URB5101', self:GetArmy(), vEffect 
              ):ScaleEmitter(0.8))
        end
        
        --# Add new ambient upgrade effects
        for k, vEffect in EffectTemplate.UpgradeBoneAmbient do
            table.insert( self.UpgradeEffectsBag, 
              --CreateAttachedEmitter( self.PipeLine, 'UEBLA01', self:GetArmy(), vEffect
              --):ScaleEmitter(2))
              CreateAttachedEmitter( self.PipeLine, 0, self:GetArmy(), vEffect
              ):ScaleEmitter(2))
        end
    end,
    
    
}


TypeClass = URB5101G