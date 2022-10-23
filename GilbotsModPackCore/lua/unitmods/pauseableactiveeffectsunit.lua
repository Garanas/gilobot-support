--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/pauseableactiveeffectsunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : Used by HCPPs, Seon Shield Strength enhancer,
--#*            and Seraphim Resorce Network Unifier.  Effects are linked to
--#*            production output or resource consumption and effects only
--#*            run when unit is active.
--#*
--#*****************************************************************************

--# This allows dynamic class extension:
--# a class can be used on more than one base class
--# so that various classes can be created with it.
local MakePauseableProductionUnit = 
    import('/mods/GilbotsModPackCore/lua/unitmods/pauseableproductionunit.lua').MakePauseableProductionUnit


--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakePauseableActiveEffectsUnit(baseClassArg)

local BaseClass = MakePauseableProductionUnit(baseClassArg)  
local resultClass = Class(BaseClass) {


    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnCreate so I could 
    --#*  do variable initialization at this time.
    --#** 
    OnCreate = function(self)
        --# Perform original class version first
        BaseClass.OnCreate(self)
    
        --# Get settings from unit blueprint file
        self.ActiveEffectsSettings = self:GetBlueprint().Display.PauseableActiveEffects
        --# Safety check
        if not self.ActiveEffectsSettings then 
            WARN('PauseableActiveEffects not found in BP.') 
            return 
        end
        
        --# Ad to the BP effect settings, keys that tell us current values
        --# of settings that increase as the unit output increases.
        self.ActiveEffectsSettings.CurrentLODCutoff = 
            self.ActiveEffectsSettings.LODCutoff 
        for kLayer, vEffectTable in self.ActiveEffectsSettings.Layers do 
            --# These values allow a 25-fold increase in effect scale
            self.ActiveEffectsSettings.Layers[kLayer].CurrentScale = vEffectTable.Scale
        end
    end,
    

    


    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  What to do when we start producing energy.  
    --#*  This happens when unit's production is unpaused
    --#*  and it has whatever other conditions it needs 
    --#*  to execute production.
    --#**
    OnActive = function(self)
        --# Call base class code first
        BaseClass.OnActive(self)
        --# Add smoke/bubble effect
        self:AddActiveEffects()
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  What to do when we stop producing energy.  
    --#*  This happens when unit's production is paused
    --#*  or it doesn't have whatever other conditions 
    --#*  it needs to execute production.
    --#**
    OnInactive = function(self)
        --# Call base class code first
        BaseClass.OnInactive(self)
        --# Remove smoke/bubble effects
        self:DestroyActiveEffects()
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Recalculate what smoke/bubble effects this unit needs when producing.
    --#*  Then call function to add them.
    --#**
    UpdateActiveEffects = function(self)
        --# A safety check to make sure that effects are active / were created.
        if not self.ActiveEffectsBag then return end
        if not self.ActiveEffectIncreaseMultiplier then return end
        if self:IsThisUnitCloaked() then return end
        
        --# Apply a animation increase effect here only if 
        --# the animation rate can increase by at least 0.1!
        local layer = self:GetCurrentLayer() 
        local newVal = self.ActiveEffectsSettings.Layers[layer].Scale *         
                       self.ActiveEffectIncreaseMultiplier
        
        --# Update effect scale to new value
        self.ActiveEffectsSettings.Layers[layer].CurrentScale = newVal 
     
        --# Applying a cap stops the effects getting too big.
        if self.ActiveEffectsSettings.Layers[layer].ScaleCap and 
          self.ActiveEffectsSettings.Layers[layer].CurrentScale > 
          self.ActiveEffectsSettings.Layers[layer].ScaleCap 
        then 
            self.ActiveEffectsSettings.Layers[layer].CurrentScale = 
              self.ActiveEffectsSettings.Layers[layer].ScaleCap
        end
          
        --# We won't see the effect if we don't update the LOD cutoff for the effect.
        self.ActiveEffectsSettings.CurrentLODCutoff = 
            self.ActiveEffectsSettings.LODCutoff + 
              (20 *
                  (self.ActiveEffectsSettings.Layers[layer].CurrentScale / 
                   self.ActiveEffectsSettings.Layers[layer].Scale)
              )
              --# Under 25 fold max increase, 
              --# These values give a max LOD cutoff of 550 
              --# which is reasonable
      
        --# Only update effects if we are not paused 
        if not self.IsProductionPaused then
            self:AddActiveEffects()
        end
        
    end,

    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Add smoke/bubble effects if unit is not cloaked.
    --#*  This is safe to call more than once in a row, i.e. it is state independent.
    --#**
    AddActiveEffects = function(self)
        
        --# Clean up any previous effects.
        self:DestroyEffects()
        
        --# Don't produce smoke effects if this unit is cloaked.
        if self:IsThisUnitCloaked() then return end
        
        --# Add effects for air or water depending on layer.
        local layer = self:GetCurrentLayer() 
        for unusedArrayIndex1, vEffect in self.ActiveEffectsSettings.Layers[layer].Effects do
            for unusedArrayIndex2, vBone in self.ActiveEffectsSettings.Bones do
                    table.insert(self.ActiveEffectsBag, 
                                 CreateAttachedEmitter(
                                     self, vBone, self:GetArmy(), vEffect
                                 ):ScaleEmitter(self.ActiveEffectsSettings.Layers[layer].CurrentScale
                                    ):OffsetEmitter(self.ActiveEffectsSettings.Offset.x,
                                                 self.ActiveEffectsSettings.Offset.y,
                                                 self.ActiveEffectsSettings.Offset.z
                                      ):SetEmitterParam('LODCutoff', 
                                                       self.ActiveEffectsSettings.CurrentLODCutoff))
            end
        end
     
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Destroy all effects.  
    --#*  This is safe to call more than once,
    --#*  i.e. it is state independent.
    --#**
    DestroyEffects = function(self)
        self:DestroyActiveEffects()
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  Destroy active effects only.  
    --#*  This is safe to call more than once,
    --#*  i.e. it is state independent.
    --#**
    DestroyActiveEffects = function(self)
        if self.ActiveEffectsBag then 
            for keys,values in self.ActiveEffectsBag do
                values:Destroy()
            end
        end
        self.ActiveEffectsBag = {}
    end,    
      
      
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called from unit.lua when a unit gains or loses a cloak effect.
    --#*  This is where the unit toggles any effects that conflict with the cloak effect.
    --#**
    OnCloakEffectEnabled = function(self, cloakEffectIsNowEnabled)
        if cloakEffectIsNowEnabled then
            self:DestroyEffects()
        else
            --# Cloak is off so switch back on the effects if any
            if not (self:BeenDestroyed() or self:IsDead())
            then self:ResumeEffects() end
        end
    end,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is called by OnCloakEffectEnabled.  Classes that extend thsi will override
    --#*  it so that it switches on the appropriate effect that matches the unit's state.
    --#**
    ResumeEffects = function(self)
        --# If we are paused then
        if self.IsProductionPaused then 
            --# Only DLS units have effects
            if self.IsDamageLimitationSystemUser then
                self:AddDSLEffects()
            end
        --# if unpaused, we all have the 
        --# smoke/bubble effect to re-enable.
        else
            self:UpdateActiveEffects()
        end
    end,

    
}



return resultClass

end