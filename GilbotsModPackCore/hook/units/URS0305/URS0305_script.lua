--#****************************************************************************
--#*
--#*  Hook File:  /units/URB3202/URB3202_script.lua
--#*
--#*  Modded By:  Gilbot-X
--#*
--#*  Summary  :  Cybran Long Range Sonar Script
--#*
--#*  
--#****************************************************************************

local MakeAdjacencyUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencyunit.lua').MakeAdjacencyUnit
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit
local CSeaUnit = 
    import('/lua/cybranunits.lua').CSeaUnit
local BaseClass = 
    MakeRemoteAdjacencyBeamUnit(MakeAdjacencyUnit(CSeaUnit))
    
URB3302 = Class(BaseClass) {

    --# Dont let pipelines connect to us, 
    --# rather we must connect to them so
    --# we don't get beams left over.
    IsNotRemoteAdjacencyReceiver = true,

    --#*
    --#* Gilbot-X says:
    --#*
    --#* I added this.
    --#*
    --#**
    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
        
        --# Gilbot-X says: 
        --# This is for my Maintenance Consumption Breakdown Mod
        --# which keep tracks of which / how many types of resource 
        --# consuming abilities are currently active in the unit.
        self.EnabledResourceDrains.Intel= true
    end,

    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from CheckIfEligibleForRemoteAdjacency in this class.
    --#*
    --#*  If these units are in one of each other's ranges 
    --#*  then return that range or false if out of range
    --#**
    CheckUnitLayerandTypeAcceptable = function(self, nearbyUnitArg)
        
        --# Only connect to units in specified layers
        local nearbyUnitLayer = nearbyUnitArg:GetCurrentLayer() 
        
        --# Connect to all sub and seabed and remote pipelines on water and land
        if nearbyUnitLayer == 'Water' or nearbyUnitLayer == 'Land' then 
            if not (nearbyUnitArg.IsRemoteAdjacencyUnit and nearbyUnitArg.IsPipeLineUnit) then
                return false
            end
        end       
        --# Check for flags on units that explicitly disallow remote connections
        if nearbyUnitArg.IsNotRemoteAdjacencyReceiver then 
            return false
        end
        if not nearbyUnitArg.IsAdjacencyUnit then 
            return false
        end
        --# Notify calling code of the following:
        --# The proposed unit type is acceptable
        return true
    end,
    
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* This was in the FA code, I haven't touched it.
    --#*
    --#**
    TimedSonarTTIdleEffects = {
        {
            Bones = {
                'Plunger',
            },
            Type = 'SonarBuoy01',
        },
    }, 
      
    --#*
    --#* Gilbot-X says:
    --#*
    --#* This was in the FA code, I haven't touched it.
    --#*
    --#**
    CreateIdleEffects = function(self)
        BaseClass.CreateIdleEffects(self)
        self.TimedSonarEffectsThread = self:ForkThread(self.TimedIdleSonarEffects)
    end,
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* This was in the FA code, I haven't touched it.
    --#*
    --#**
    TimedIdleSonarEffects = function( self )
        local layer = self:GetCurrentLayer()
        local army = self:GetArmy()
        local pos = self:GetPosition()
        
        if self.TimedSonarTTIdleEffects then
            while not self:IsDead() do
                for kTypeGroup, vTypeGroup in self.TimedSonarTTIdleEffects do
                    local effects = self.GetTerrainTypeEffects( 'FXIdle', layer, pos, vTypeGroup.Type, nil )
                    
                    for kb, vBone in vTypeGroup.Bones do
                        for ke, vEffect in effects do
                            emit = CreateAttachedEmitter(self,vBone,army,vEffect):ScaleEmitter(vTypeGroup.Scale or 1)
                            if vTypeGroup.Offset then
                                emit:OffsetEmitter(vTypeGroup.Offset[1] or 0, 
                                                   vTypeGroup.Offset[2] or 0,
                                                   vTypeGroup.Offset[3] or 0)
                            end
                        end
                    end                    
                end
                WaitSeconds( 6.0 )                
            end
        end
    end,
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* This was in the FA code, I haven't touched it.
    --#*
    --#**
    DestroyIdleEffects = function(self)
        self.TimedSonarEffectsThread:Destroy()
        BaseClass.DestroyIdleEffects(self)
    end,     

    --#*
    --#* Gilbot-X says:
    --#*
    --#* I added this.
    --#*
    --#**
    OnMotionHorzEventChange = function( self, new, old )
        --# This is how the baseclass version starts
        if self:IsDead() then return end
        --# Base class deals with effects and sounds
        BaseClass.OnMotionHorzEventChange( self, new, old )
        
        --# When we stop....
        if new == 'Stopped' then
            --# If it was on (false=on)
            if not self:GetScriptBit('RULEUTC_ProductionToggle') then
                --# Switch it back on
                self:OnRemoteAdjacencyUnpaused()
            end
            self:AddToggleCap('RULEUTC_ProductionToggle')
        --# When we start moving
        elseif old == 'Stopped' then
            --# If it was on (false = om) 
            if not self:GetScriptBit('RULEUTC_ProductionToggle') then
                --# Switch all remote links off immediately
                self:OnRemoteAdjacencyPaused()
            end
            self:RemoveToggleCap('RULEUTC_ProductionToggle')
        end
    end,    
    
    
    
    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is paused, remote-links are disabled.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnRemoteAdjacencyPaused = function(self)
        --# Record state
        self.IsRemoteAdjacencyPaused = true
        --# These next two lines go together
        self:CleanUpRemoteAdjacency()
        --# These next two lines go together
        self.EnabledResourceDrains.Production = false
        self:UpdateConsumptionValues()
    end,
}

TypeClass = URB3302