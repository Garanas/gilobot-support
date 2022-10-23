--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/units/GRB5301B/GRB5301B_script.lua
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Experimental Cybran Pipeline Script
--#**
--#****************************************************************************
local MakeRemoteAdjacencyBeamUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/remoteadjacencybeamunit.lua').MakeRemoteAdjacencyBeamUnit
local PipeLineUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/pipelines.lua').PipeLineUnit
local BaseClass = MakeRemoteAdjacencyBeamUnit(PipeLineUnit)

GRB5301B = Class(BaseClass) {

    OnlyConnectToOtherRemoteAdjacencyUnits = true,

    OnCreate = function(self)
        --# Call superclass version
        BaseClass.OnCreate(self)
        
        --# Gilbot-X says: 
        --# This is for my Maintenance Consumption Breakdown Mod
        --# which keep tracks of which / how many types of resource 
        --# consuming abilities are currently active in the unit.
        self.EnabledResourceDrains.Shield= true
    end,
    
    

    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to be called 
    --#*  from AddExtendedAdjacencyToNearbyUnits below.
    --#*  It is to save on repeated code.
    --#**
    GetSkirtBounds = function(self, myposition)
        
        --# Don't recalculate, as structures don't move!
        if not self.MySkirtBounds then
            --# This can only be done if we have reference to a
            --# living containing unit (of type urb5101b).
            if not self.ContainingStructure or self.ContainingStructure:BeenDestroyed() then
                WARN("Adjacency mod: self.ContainingStructure not found for GRB5301B.")
            else
                --# Call base class version with our containing class
                self.MySkirtBounds =
                    BaseClass.GetSkirtBounds(
                        self.ContainingStructure
                    )
            end
        end
        
        --# return value just in case a copy is needed.
        --# Might make calling code easier to read.        
        return self.MySkirtBounds
    end,

    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to confirm that 
    --#*  self.ContainingStructure was being set by the unit 
    --#*  building this.
    --#**
    SetContainingStructure = function(self, containingStructure)
       
        --# Record what was sent!!
        self.ContainingStructure = containingStructure
 
        LOG('Adjacency mod: Setting self.ContainingStructure: ' 
            .. ' entity=' .. self.ContainingStructure:GetEntityId()
            .. ' unitid=' .. self.ContainingStructure:GetUnitId())
        
        --# Do this now and we'll have a record of our skirt bounds
        --# even if there is a problem later with the reference to the  
        --# ContainingStructure.
        self:GetSkirtBounds()
    
    end,
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I added this function to allow advanced resource allocator
    --#*  to create a pipeline when this one dies.
    --#**
    OnKilled = function(self, instigator, type, overkillRatio)
        --# Notify parent that we are dead and
        --# they can build another one of us
        if self.ContainingStructure and 
          not (self.ContainingStructure:BeenDestroyed() or  
               self.ContainingStructure:IsDead())
        then 
            self.ContainingStructure:OnPipeLineKilled()
        end
        
        --# Call base class version to finish killing unit
        BaseClass.OnKilled(self, instigator, type, overkillRatio)
    end,
}


TypeClass = GRB5301B