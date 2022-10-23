--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/adjacency/pipelines.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Definition of pipeline units common to all factions.
--#**
--#**
--#**  I started this by looking at the code from Lakitrid
--#**  from his PipeLines mod in summer 2007, but now there aren't many 
--#**  similarities left between my version and his.
--#** 
--#****************************************************************************


--# These are new files I created.
local ApplyPositionCorrection = 
    import('/mods/GilbotsModPackCore/lua/positioncorrections.lua').ApplyPositionCorrection
local GilbotUtils = 
    import('/mods/GilbotsModPackCore/lua/utils.lua')
local ResourceNetwork = 
    import('/mods/GilbotsModPackCore/lua/adjacency/resourcenetwork.lua').ResourceNetwork

--# Load the version of defaultunits.lua that I hook in this mod.
local AdjacencyStructureUnit = 
    import('/lua/defaultunits.lua').AdjacencyStructureUnit
local Entity = 
    import('/lua/sim/Entity.lua').Entity



--#*
--#*  T1 Version
--#*  
--#*  These must be build with touching skirts to pass on adjacency
--#*  to other T1 pipes and structures.  Unlike most structures, T1 
--#*  pipes can connect to remote pipelines (T2 and above).
--#*  Because they can receive remote connects, the main remote 
--#*  connection code is kept in this class.
--#*
--#*  Many functions from AdjacencyStructureUnit class are overrided 
--#*  just to stop base class code from being called, because 
--#*  we want pipelines to just conduct energy, not to receive bonuses themselves.
--#*
--#***
PipeLineUnit = Class(AdjacencyStructureUnit) {
    
    --# All units that are only ever built on land need this
    LandBuiltHiddenBones = {'Floatation'},
    
    --# This constant shared variable provides a convenient means 
    --# of testing any object to see if it uses this class.
    IsPipeLineUnit = true,
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Overrided to perform initialisation: 
    --#*  Code that creates the hub node (effect) is called.
    --#*  Beams connect to the centre of the hub node rather 
    --#*  than the centre of the unit mesh itself.
    --#**
    OnCreate = function(self)
        --# Perform base class initialisation first
        AdjacencyStructureUnit.OnCreate(self)
        
        --# Create a graphic to go on top of unit mesh. It looks better.
        self:CreateHubNode()
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  Create a 'hub' graphic effect to go on top 
    --#*  of the tower (unit mesh).
    --#*
    --#*  Beams connect to the centre of the hub node rather 
    --#*  than the centre of the unit mesh itself.
    --#**
    CreateHubNode = function(self)
  
        --# Create the entity 
        self.HubEffect = {
            entity = Entity({Owner = self,}),
            pos = {x=0, y=0, z=0},
        }
 
        local myBP = self:GetBlueprint()
        
        --# Determine which effects we will be using
        local faction = myBP.General.FactionName    
        local nodeMesh = myBP.Display.HubEffect.MeshPath
        local scale= myBP.Display.HubEffect.Scale
        local offsets = myBP.Display.HubEffect.Offsets
 
        --# Work out where to put the effect.
        local myPosition = self:GetPosition()
            
        --# The Mesh is 0.3 above the ground surface
        --# and offsets in BP files were relative to ground surface
        self.HubEffect.pos.x = myPosition.x + offsets.x
        self.HubEffect.pos.y = myPosition.y + offsets.y
        self.HubEffect.pos.z = myPosition.z + offsets.z
        
        --# Make node meshes visible and scale
        self.HubEffect.entity:SetMesh(nodeMesh, false)
        if scale then self.HubEffect.entity:SetDrawScale(scale) end 
       
        --# Don't let these nodes appear on intel.
        self.HubEffect.entity:SetVizToNeutrals('Intel')
        self.HubEffect.entity:SetVizToEnemies('Intel')
    
        --# Garbage collection
        self.Trash:Add(self.HubEffect.entity)
        
        --# Warp everything to its final position
        Warp(self.HubEffect.entity, {self.HubEffect.pos.x, 
                                     self.HubEffect.pos.y, 
                                     self.HubEffect.pos.z} )
      
    end,
    
    
   
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  I override this so that we can move the tower (unit mesh)
    --#*  without moving the extra graphic (effect) on top of unit mesh.
    --#**
    SetPipeLineTowerOnlyPosition = function(self, positionArg, immediateOption)
        --# Call superclass to move us.
        AdjacencyStructureUnit.SetPosition(
            self, {positionArg.x, positionArg.y, positionArg.z}, immediateOption
        )
    end,
   
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  I override this so that when the tower (unit mesh) is moved,
    --#*  we move the graphic (effect) on top of unit mesh.
    --#**
    SetPosition = function(self, positionArg, immediateOption)
        --# Call superclass to move us.
        self:SetPipeLineTowerOnlyPosition(positionArg, immediateOption)
        
        --# Move the effect
        self:SetHubOnlyPosition(positionArg)
    end,
    
    
    
    --#*
    --#*  Gilbot-X says:
    --#*  
    --#*  I override this so that we can move the hub 
    --#*  (graphic effect) without moving the tower (unit mesh)
    --#**
    SetHubOnlyPosition = function(self, positionArg)
        --# Work out where to put the effect.
        local offsets = self:GetBlueprint().Display.HubEffect.Offsets
            
        --# The Mesh is 0.3 above the ground surface
        --# and offsets in BP files were relative to ground surface
        if not self.HubEffect then WaitSeconds(1) end
        if not self.HubEffect then 
            WARN('Adjacency:  No hub effect after waiting a second.') 
        end
  
        self.HubEffect.pos.x = positionArg.x + offsets.x
        self.HubEffect.pos.y = positionArg.y + offsets.y
        self.HubEffect.pos.z = positionArg.z + offsets.z
        
        --# Warp everything to its final position
        Warp(self.HubEffect.entity, {self.HubEffect.pos.x, 
                                     self.HubEffect.pos.y, 
                                     self.HubEffect.pos.z} )
    end,
    
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I override this function defined in the AdjacencyStructureUnit
    --#*  class (the function is called by ResourceNetwork objects) 
    --#*  because pipeline units cannot have a custom name set.
    --#**
    SetNetwork = function(self, networkArg)
        --# Store the network reference set
        --# but don't do anything else
        self.MyNetwork = networkArg
    end,
    
    --#*
    --#*  Gilbot-X says: 
    --#*     
    --#*  I override the first function (defined in the 
    --#*  AdjacencyStructureUnit class and called by ResourceNetwork objects) 
    --#*  and the remaining functions (defined in my hook of Unit.lua)
    --#*  because pipeline units cannot have a custom name set.
    DisplayNetworkNumbers = nil,
    SetCustomName= nil,
    GetCustomName= nil,
    ClearCustomName=nil,
    FlashMessage=nil,
    
         
} --(end of PipeLineUnit class)