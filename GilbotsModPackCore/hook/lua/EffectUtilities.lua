--#****************************************************************************
--#**
--#**  Hook File:  /lua/EffectUtilities.lua
--#**  Author(s):  Gordon Duclos Modded by Gilbot-X
--#**
--#**  Summary  :  Effect Utility functions for scripts.
--#**
--#**  Notes    :  Original file in FA version has 1353 lines.
--#****************************************************************************

local ApplyPositionCorrection = 
    import('/mods/GilbotsModPackCore/lua/positioncorrections.lua').ApplyPositionCorrection

    
--#*
--#*  Gilbot-X says:
--#*
--#*  This was replaced to choose one of three functions.
--#*  each of the three functions creates adjacency beam effects,
--#*  but are tailored to what units are being connected (normal or pipeline).
--#**
function CreateAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )

    --# This is needed for safety.  Units get beams up to a second after adjacency
    --# is given, which gives them enough time to be destroyed.  If either are 
    --# destroyed then we should abort creating beams between them.
    if unit:BeenDestroyed() or adjacentUnit:BeenDestroyed() then return end

    --# If remotely linking the Cybran HARMs to a specialist sonar unit...
    local unitLayer = unit:GetCurrentLayer()
    local adjacentUnitLayer = adjacentUnit:GetCurrentLayer()
    if unitLayer == 'Sub' or adjacentUnitLayer == 'Sub' then 
        return CreateWaterToSubAdjacencyBeams(unit, adjacentUnit, AdjacencyBeamsBag)
    end
        
    --# If we are creating an effect between two pipeline units..
    if unit.IsPipeLineUnit and adjacentUnit.IsPipeLineUnit then
       --# This has a scaled down effect.
        return CreatePipelineToPipelineAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )
      
    --# If we are creating an effect between two normal units..
    elseif (not unit.IsPipeLineUnit) and (not adjacentUnit.IsPipeLineUnit) then
        --# If both are T1 PD or AA
        if unit.IsOffsetStructure and adjacentUnit.IsOffsetStructure then
            --# The distance between them is tiny.
            return CreatePDToPDAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )
        else
            --# This has the full effect that GPG created.
            return CreateUnitToUnitAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )
        end
     
    --# If we are creating an effect between 1 pipeline unit and one normal unit ..
    elseif adjacentUnit.IsPipeLineUnit then
        return CreateUnitToPipelineAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )
    else
        return CreateUnitToPipelineAdjacencyBeams( adjacentUnit, unit, AdjacencyBeamsBag )
    end
    
end
    
    

--#*
--#*  Gilbot-X says:
--#*
--#*  This creates a beam effect with 3 connected line segments.
--#*  This gets called when two normal structures are linked to each other
--#*  or when a T1 pipileline and a normal structure are linked.
--#*
--#*  There are two sections of modded (added) code in 
--#*  this function override.  If you scroll down, they are clearly marked.
--#*
--#**
function CreateUnitToUnitAdjacencyBeams(unit, adjacentUnit, AdjacencyBeamsBag)

    local info = {
        Unit = adjacentUnit,
        Trash = TrashBag(),
    }
    
    table.insert(AdjacencyBeamsBag, info)
    
    local uBp = unit:GetBlueprint()
    local aBp = adjacentUnit:GetBlueprint()
    local army = unit:GetArmy()
    local faction = uBp.General.FactionName

    --# Determine which effects we will be using
    local emitterNodeEffects = {}  
    local nodeMesh = nil
    local beamEffect = nil
    local numNodes = 0
    local nodeList = {}
    local validAdjacency = true

    local unitPos = unit:GetPosition()
    local adjPos = adjacentUnit:GetPosition()
    
    --# Create hub start/end and all midpoint nodes
    local unitHub = {
        entity = Entity{},
        pos = unitPos,
    }
    local adjacentHub = {
        entity = Entity{},
        pos = adjPos,
    }

    --# For Size4 units, separation is 
    --# exactly 2 if they are side by side
    --# but just over 2.2 if slight overlap
    --# and just over 2.8 if diagonally adjacent 
    local unitSeparation = 
        util.GetDistanceBetweenTwoVectors(unitHub.pos, adjacentHub.pos)
        
    --# I added this because T1 AA and PD join really close!
    if faction == 'Aeon' then
        nodeMesh = '/effects/entities/aeonadjacencynode/aeonadjacencynode_mesh'
        if unitSeparation < 2.2
        then 
          numNodes = 0
          --# Use faintest beam
          beamEffect = '/effects/emitters/adjacency_aeon_beam_01_emit.bp'
        else 
          numNodes = 3 
          beamEffect = '/effects/emitters/adjacency_aeon_beam_0' .. util.GetRandomInt(1,3) .. '_emit.bp'
        end
    elseif faction == 'Cybran' then
        nodeMesh = '/effects/entities/cybranadjacencynode/cybranadjacencynode_mesh'
        beamEffect = '/effects/emitters/adjacency_cybran_beam_01_emit.bp'
        if unitSeparation < 3
        then numNodes = 0
        else numNodes = 2 end
    elseif faction == 'UEF' then
        nodeMesh = '/effects/entities/uefadjacencynode/uefadjacencynode_mesh'
        beamEffect = '/effects/emitters/adjacency_uef_beam_01_emit.bp'
        if unitSeparation < 2.5
        then numNodes = 0
        else numNodes = 2 end
    elseif faction == 'Seraphim' then
        nodeMesh = '/effects/entities/seraphimadjacencynode/seraphimadjacencynode_mesh'
        table.insert( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient01 )
        if unitSeparation < 2.5 then
            numNodes = 1
        else
            numNodes = 3
            table.insert( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient02 )
            table.insert( emitterNodeEffects, EffectTemplate.SAdjacencyAmbient03 )
        end
    end
    
    --# Using intermediate nodes looks crap if two structures are not on same layer
    local unitLayer = unit:GetCurrentLayer()
    local adjacentUnitLayer = adjacentUnit:GetCurrentLayer()
    if  unitLayer ~=  adjacentUnitLayer or 
        (faction == 'Cybran' and unitLayer ~= 'Land') then
        numNodes=0
    end
    
    local spec = {
        Owner = unit,
    }

    if numNodes > 0 then
        for i = 1, numNodes do
            local node = {
                entity = Entity(spec),
                pos = {0,0,0},
                mesh = nil,
            }
            node.entity:SetVizToNeutrals('Intel')
            node.entity:SetVizToEnemies('Intel')
            table.insert( nodeList, node )
        end
    end
   

    local verticalOffset = 0.05

    --# These affect positions of hubs along units
    --# As far as I can see there is no rule
    --# governing a mandatory relationship between 
    --# SizeX and SkirtSizeX or 
    --# SizeZ and SkirtSizeZ.    
    local uBpSizeX = uBp.SizeX * 0.5
    local uBpSizeZ = uBp.SizeZ * 0.5
    local aBpSizeX = aBp.SizeX * 0.5
    local aBpSizeZ = aBp.SizeZ * 0.5

    --# To Determine positioning, need to use the bounding box or skirt size
    local uBpSkirtX = uBp.Physics.SkirtSizeX * 0.5
    local uBpSkirtZ = uBp.Physics.SkirtSizeZ * 0.5
    local aBpSkirtX = aBp.Physics.SkirtSizeX * 0.5
    local aBpSkirtZ = aBp.Physics.SkirtSizeZ * 0.5	

    --# Correction for custom units
    unitSkirtCentrePos = ApplyPositionCorrection(unit, unitPos)
    adjSkirtCentrePos  = ApplyPositionCorrection(adjacentUnit, adjPos)
    
    --# Get edge corner positions, { TOP, LEFT, BOTTOM, RIGHT }
    local unitSkirtBounds = {
        unitSkirtCentrePos.z - uBpSkirtZ,
        unitSkirtCentrePos.x - uBpSkirtX,
        unitSkirtCentrePos.z + uBpSkirtZ,
        unitSkirtCentrePos.x + uBpSkirtX,
    }
    local adjacentSkirtBounds = {
        adjSkirtCentrePos.z - aBpSkirtZ,
        adjSkirtCentrePos.x - aBpSkirtX,
        adjSkirtCentrePos.z + aBpSkirtZ,
        adjSkirtCentrePos.x + aBpSkirtX,
    }

    
    --# This section will displace the beam attach points on the two units connecting
    --# Unit bottom or top skirt is aligned to adjacent unit
    if (unitSkirtBounds[3] == adjacentSkirtBounds[1]) or (unitSkirtBounds[1] == adjacentSkirtBounds[3]) then
	
        local sharedSkirtLower = unitSkirtBounds[4] - (unitSkirtBounds[4] - adjacentSkirtBounds[2])
        local sharedSkirtUpper = unitSkirtBounds[4] - (unitSkirtBounds[4] - adjacentSkirtBounds[4])
        local sharedSkirtLen = sharedSkirtUpper - sharedSkirtLower

        --# Depending on shared skirt bounds, determine the position of unit hub
        --# Find out how many times the shared skirt fits into the unit hub shared skirt
        local numAdjSkirtsOnUnitSkirt = (uBpSkirtX * 2) / sharedSkirtLen
        local numUnitSkirtsOnAdjSkirt = (aBpSkirtX * 2) / sharedSkirtLen
        
        --# Z-offset, offset adjacency hub positions the proper direction
        if unitSkirtBounds[3] == adjacentSkirtBounds[1] then
            if not unit.AttachBeamToCentre then 
                unitHub.pos[3] = unitHub.pos[3] + uBpSizeZ 
            end
            if not adjacentUnit.AttachBeamToCentre then             
                adjacentHub.pos[3] = adjacentHub.pos[3] - aBpSizeZ
            end
        else --# unitSkirtBounds[1] == adjacentSkirtBounds[3]
            if not unit.AttachBeamToCentre then 
                unitHub.pos[3] = unitHub.pos[3] - uBpSizeZ
            end
            if not adjacentUnit.AttachBeamToCentre then 
                adjacentHub.pos[3] = adjacentHub.pos[3] + aBpSizeZ
            end
        end    
		
        --# X-offset, Find the shared adjacent x position range			
        --# If we have more than skirt on this section, then we need to adjust the x position of the unit hub 
        if numAdjSkirtsOnUnitSkirt > 1 or numUnitSkirtsOnAdjSkirt < 1 then
            local uSkirtLen = (unitSkirtBounds[4] - unitSkirtBounds[2]) * 0.5           --# Unit skirt length			
            local uGridUnitSize = (uBpSizeX * 2) / uSkirtLen                            --# Determine one grid of adjacency along that length
            local xoffset = math.abs(unitSkirtBounds[2] - adjacentSkirtBounds[2]) * 0.5 --# Get offset of the unit along the skirt
            if not unit.AttachBeamToCentre then 
                unitHub.pos[1] = (unitHub.pos[1] - uBpSizeX) + (xoffset * uGridUnitSize) + (uGridUnitSize * 0.5) 
            end
        end
		
        --# If we have more than skirt on this section, then we need to adjust the x position of the adjacent hub 
        if numUnitSkirtsOnAdjSkirt > 1  or numAdjSkirtsOnUnitSkirt < 1 then
            local aSkirtLen = (adjacentSkirtBounds[4] - adjacentSkirtBounds[2]) * 0.5   --# Adjacent unit skirt length			
            local aGridUnitSize = (aBpSizeX * 2) / aSkirtLen  --# Determine one grid of adjacency along that length ??
            local xoffset = math.abs(adjacentSkirtBounds[2] - unitSkirtBounds[2]) * 0.5	--# Get offset of the unit along the adjacent unit
            if not adjacentUnit.AttachBeamToCentre then 
                adjacentHub.pos[1] = (adjacentHub.pos[1] - aBpSizeX) + (xoffset * aGridUnitSize) + (aGridUnitSize * 0.5) 
            end
        end			

    --# Unit right or top left is aligned to adjacent unit
    elseif (unitSkirtBounds[4] == adjacentSkirtBounds[2]) or (unitSkirtBounds[2] == adjacentSkirtBounds[4]) then
    
        local sharedSkirtLower = unitSkirtBounds[3] - (unitSkirtBounds[3] - adjacentSkirtBounds[1])
        local sharedSkirtUpper = unitSkirtBounds[3] - (unitSkirtBounds[3] - adjacentSkirtBounds[3])
        local sharedSkirtLen = sharedSkirtUpper - sharedSkirtLower

        --# Depending on shared skirt bounds, determine the position of unit hub
        --# Find out how many times the shared skirt fits into the unit hub shared skirt
        local numAdjSkirtsOnUnitSkirt = (uBpSkirtX * 2) / sharedSkirtLen
        local numUnitSkirtsOnAdjSkirt = (aBpSkirtX * 2) / sharedSkirtLen
                
        --# X-offset
        if (unitSkirtBounds[4] == adjacentSkirtBounds[2]) then
            if not unit.AttachBeamToCentre then 
                unitHub.pos[1] = unitHub.pos[1] + uBpSizeX
            end
            if not adjacentUnit.AttachBeamToCentre then 
                adjacentHub.pos[1] = adjacentHub.pos[1] - aBpSizeX
            end
        else --# unitSkirtBounds[2] == adjacentSkirtBounds[4]  
            if not unit.AttachBeamToCentre then         
                unitHub.pos[1] = unitHub.pos[1] - uBpSizeX
            end
            if not adjacentUnit.AttachBeamToCentre then 
                adjacentHub.pos[1] = adjacentHub.pos[1] + aBpSizeX
            end
        end
        
        --# Z-offset, Find the shared adjacent x position range			
        --# If we have more than skirt on this section, then we need to adjust the x position of the unit hub 
        if numAdjSkirtsOnUnitSkirt > 1 or numUnitSkirtsOnAdjSkirt < 1 then
            local uSkirtLen = (unitSkirtBounds[3] - unitSkirtBounds[1]) * 0.5           --# Unit skirt length			
            local uGridUnitSize = (uBpSizeZ * 2) / uSkirtLen                            --# Determine one grid of adjacency along that length
            local zoffset = math.abs(unitSkirtBounds[1] - adjacentSkirtBounds[1]) * 0.5 --# Get offset of the unit along the skirt
            if not unit.AttachBeamToCentre then 
                unitHub.pos[3] = (unitHub.pos[3] - uBpSizeZ) + (zoffset * uGridUnitSize) + (uGridUnitSize * 0.5) 
            end
        end
        
        --# If we have more than skirt on this section, then we need to adjust the x position of the adjacent hub 
        if numUnitSkirtsOnAdjSkirt > 1 or numAdjSkirtsOnUnitSkirt < 1 then
            local aSkirtLen = (adjacentSkirtBounds[3] - adjacentSkirtBounds[1]) * 0.5   --# Adjacent unit skirt length			
            local aGridUnitSize = (aBpSizeZ * 2) / aSkirtLen                            --# Determine one grid of adjacency along that length ??
            local zoffset = math.abs(adjacentSkirtBounds[1] - unitSkirtBounds[1]) * 0.5	--# Get offset of the unit along the adjacent unit
            if not adjacentUnit.AttachBeamToCentre then 
                adjacentHub.pos[3] = (adjacentHub.pos[3] - aBpSizeZ) + (zoffset * aGridUnitSize) + (aGridUnitSize * 0.5) 
            end
        end				
    end

    
    
    
    if numNodes > 0 then
        --# Setup our midpoint positions
        if faction == 'Aeon' or faction == 'Seraphim' then
            local DirectionVec = util.GetDifferenceVector( unitHub.pos, adjacentHub.pos )
            local Dist = util.GetDistanceBetweenTwoVectors( unitHub.pos, adjacentHub.pos )
            local PerpVec = util.Cross( DirectionVec, Vector(0,0.35,0) )
            local segmentLen = 1 / (numNodes + 1)
    
            if util.GetRandomInt(0,1) == 1 then
                PerpVec[1] = -PerpVec[1]
                PerpVec[2] = -PerpVec[2]
                PerpVec[3] = -PerpVec[3]
            end
    
            local offsetMul = 0.15
    
            for i = 1, numNodes do
                local segmentMul = i * segmentLen
    
                if segmentMul <= 0.5 then
                    offsetMul = offsetMul + 0.12
                else
                    offsetMul = offsetMul - 0.12
                end
    
                nodeList[i].pos = {
                    unitHub.pos[1] - (DirectionVec[1] * segmentMul) - (PerpVec[1] * offsetMul),
                    nil,
                    unitHub.pos[3] - (DirectionVec[3] * segmentMul) - (PerpVec[3] * offsetMul),
                }
            end
    
            
        elseif faction == 'Cybran' then
            if (unitPos[1] == adjPos[1]) or (unitPos[3] == adjPos[3]) then
                local Dist = util.GetDistanceBetweenTwoVectors( unitHub.pos, adjacentHub.pos )
                local DirectionVec = util.GetScaledDirectionVector( unitHub.pos, adjacentHub.pos, util.GetRandomFloat(0.35, Dist * 0.48) )
                DirectionVec[2] = 0
                local PerpVec = util.Cross( DirectionVec, Vector(0,util.GetRandomFloat(0.2, 0.35),0) )
    
                if util.GetRandomInt(0,1) == 1 then
                    PerpVec[1] = -PerpVec[1]
                    PerpVec[2] = -PerpVec[2]
                    PerpVec[3] = -PerpVec[3]
                end
    
                --# Initialize 2 midpoint segments
                nodeList[1].pos = { unitHub.pos[1] - DirectionVec[1], unitHub.pos[2] - DirectionVec[2], unitHub.pos[3] - DirectionVec[3] }
                nodeList[2].pos = { adjacentHub.pos[1] + DirectionVec[1], adjacentHub.pos[2] + DirectionVec[2], adjacentHub.pos[3] + DirectionVec[3] }
    
                --# Offset beam positions
                nodeList[1].pos[1] = nodeList[1].pos[1] - PerpVec[1]
                nodeList[1].pos[3] = nodeList[1].pos[3] - PerpVec[3]
                nodeList[2].pos[1] = nodeList[2].pos[1] + PerpVec[1]
                nodeList[2].pos[3] = nodeList[2].pos[3] + PerpVec[3]
    
                unitHub.pos[1] = unitHub.pos[1] - PerpVec[1]
                unitHub.pos[3] = unitHub.pos[3] - PerpVec[3]
                adjacentHub.pos[1] = adjacentHub.pos[1] + PerpVec[1]
                adjacentHub.pos[3] = adjacentHub.pos[3] + PerpVec[3]		
            else
                --# Unit bottom skirt is on top skirt of adjacent unit
                if (unitSkirtBounds[3] == adjacentSkirtBounds[1]) then
                        nodeList[1].pos[1] = unitHub.pos[1]
                        nodeList[2].pos[1] = adjacentHub.pos[1]
                        nodeList[1].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) - (util.GetRandomFloat(0, 1))
                        nodeList[2].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) + (util.GetRandomFloat(0, 1))
                elseif (unitSkirtBounds[1] == adjacentSkirtBounds[3]) then
                        nodeList[1].pos[1] = unitHub.pos[1]
                        nodeList[2].pos[1] = adjacentHub.pos[1]
                        nodeList[1].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) + (util.GetRandomFloat(0, 1))
                        nodeList[2].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) - (util.GetRandomFloat(0, 1))
                elseif (unitSkirtBounds[4] == adjacentSkirtBounds[2]) then
                        nodeList[1].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) - (util.GetRandomFloat(0, 1))
                        nodeList[2].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) + (util.GetRandomFloat(0, 1))
                        nodeList[1].pos[3] = unitHub.pos[3]
                        nodeList[2].pos[3] = adjacentHub.pos[3]
                elseif (unitSkirtBounds[2] == adjacentSkirtBounds[4]) then
                        nodeList[1].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) + (util.GetRandomFloat(0, 1))
                        nodeList[2].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) - (util.GetRandomFloat(0, 1))
                        nodeList[1].pos[3] = unitHub.pos[3]
                        nodeList[2].pos[3] = adjacentHub.pos[3]
                else
                    --###########################################################
                    --# Gilbot-X: I added this to make sure any relative position 
                    --# between two units is valid.
                    --#
                    --# If the x-separation between the units is less 
                    --# than their z-separation then treat as if 
                    --# unit bottom skirt is on top skirt of adjacent unit
                    if math.abs(unitPos[1] - adjPos[1]) < math.abs(unitPos[3] - adjPos[3]) then 
                        --# If unit is north of adjacent unit
                        if unitPos[3] < adjPos[3] then
                            --# so connector goes N-NE-N
                            --# or connector goes N-NW-N
                            nodeList[1].pos[1] = unitHub.pos[1]
                            nodeList[2].pos[1] = adjacentHub.pos[1]
                            nodeList[1].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) - (util.GetRandomFloat(0, 1))
                            nodeList[2].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) + (util.GetRandomFloat(0, 1))
                        else
                            --# so connector goes S-SE-S
                            --# or connector goes S-SW-S
                            nodeList[1].pos[1] = unitHub.pos[1]
                            nodeList[2].pos[1] = adjacentHub.pos[1]
                            nodeList[1].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) + (util.GetRandomFloat(0, 1))
                            nodeList[2].pos[3] = ((unitHub.pos[3] + adjacentHub.pos[3]) * 0.5) - (util.GetRandomFloat(0, 1))
                        end
                    else
                        --# treat as if unit right skirt is on left skirt of adjacent unit
                        --# (so connector goes right-up-right)
                        --#
                        --# If unit is to the left of adjacent unit
                        if unitPos[1] < adjPos[1] then
                            --# so connector goes E-NE-E
                            --# or connector goes E-SE-E
                            nodeList[1].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) - (util.GetRandomFloat(0, 1))
                            nodeList[2].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) + (util.GetRandomFloat(0, 1))
                            nodeList[1].pos[3] = unitHub.pos[3]
                            nodeList[2].pos[3] = adjacentHub.pos[3]
                        else
                            --# so connector goes W-NW-W
                            --# or connector goes W-SW-W
                            nodeList[1].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) + (util.GetRandomFloat(0, 1))
                            nodeList[2].pos[1] = ((unitHub.pos[1] + adjacentHub.pos[1]) * 0.5) - (util.GetRandomFloat(0, 1))
                            nodeList[1].pos[3] = unitHub.pos[3]
                            nodeList[2].pos[3] = adjacentHub.pos[3]
                        end
                    end
                    --# End of Gilbot-X mod part 1 of 2
                    --###########################################################		
                end
            end
           
    
           
        elseif faction == 'UEF' then
        
            if (unitPos[1] == adjPos[1]) or (unitPos[3] == adjPos[3]) then
                local DirectionVec = util.GetScaledDirectionVector( unitHub.pos, adjacentHub.pos, 0.35 )
                DirectionVec[2] = 0
                local PerpVec = util.Cross( DirectionVec, Vector(0,0.35,0) )
                
                if util.GetRandomInt(0,1) == 1 then
                    PerpVec[1] = -PerpVec[1]
                    PerpVec[2] = -PerpVec[2]
                    PerpVec[3] = -PerpVec[3]
                end
    
                --# Initialize 2 midpoint segments
                for k, v in nodeList do
                    v.pos = util.GetMidPoint( unitHub.pos, adjacentHub.pos )
                end
    
                --# Offset beam positions
                nodeList[1].pos[1] = nodeList[1].pos[1] - PerpVec[1]
                nodeList[1].pos[3] = nodeList[1].pos[3] - PerpVec[3]
                nodeList[2].pos[1] = nodeList[2].pos[1] + PerpVec[1]
                nodeList[2].pos[3] = nodeList[2].pos[3] + PerpVec[3]
    
                unitHub.pos[1] = unitHub.pos[1] - PerpVec[1]
                unitHub.pos[3] = unitHub.pos[3] - PerpVec[3]
                adjacentHub.pos[1] = adjacentHub.pos[1] + PerpVec[1]
                adjacentHub.pos[3] = adjacentHub.pos[3] + PerpVec[3]
            
            else			    		    
                --# Unit bottom skirt is on top skirt of adjacent unit
                if (unitSkirtBounds[3] == adjacentSkirtBounds[1]) or (unitSkirtBounds[1] == adjacentSkirtBounds[3]) then
                        nodeList[1].pos[1] = unitHub.pos[1]
                        nodeList[2].pos[1] = adjacentHub.pos[1]
                        nodeList[1].pos[3] = (unitHub.pos[3] + adjacentHub.pos[3]) * 0.5
                        nodeList[2].pos[3] = (unitHub.pos[3] + adjacentHub.pos[3]) * 0.5
    
                --# Unit right skirt is on left skirt of adjacent unit
                elseif (unitSkirtBounds[4] == adjacentSkirtBounds[2]) or (unitSkirtBounds[2] == adjacentSkirtBounds[4]) then
                        nodeList[1].pos[1] = (unitHub.pos[1] + adjacentHub.pos[1]) * 0.5
                        nodeList[2].pos[1] = (unitHub.pos[1] + adjacentHub.pos[1]) * 0.5
                        nodeList[1].pos[3] = unitHub.pos[3]
                        nodeList[2].pos[3] = adjacentHub.pos[3]
                else
                    --###########################################################
                    --# Gilbot-X: I added this to make sure any relative position 
                    --# between two units is valid.
                    --# If the x-separation between the units is less 
                    --# than their z-separation then treat as if 
                    --# unit bottom skirt is on top skirt of adjacent unit
                    if math.abs(unitPos[1] - adjPos[1]) < math.abs(unitPos[3] - adjPos[3]) then 
                        --# (so connector goes up-right-up)
                        nodeList[1].pos[1] = unitHub.pos[1]
                        nodeList[2].pos[1] = adjacentHub.pos[1]
                        nodeList[1].pos[3] = (unitHub.pos[3] + adjacentHub.pos[3]) * 0.5
                        nodeList[2].pos[3] = (unitHub.pos[3] + adjacentHub.pos[3]) * 0.5  
                    else
                        --# treat as if unit right skirt is on left skirt of adjacent unit
                        --# (so connector goes right-up-right)
                        nodeList[1].pos[1] = (unitHub.pos[1] + adjacentHub.pos[1]) * 0.5
                        nodeList[2].pos[1] = (unitHub.pos[1] + adjacentHub.pos[1]) * 0.5
                        nodeList[1].pos[3] = unitHub.pos[3]
                        nodeList[2].pos[3] = adjacentHub.pos[3]
                    end
                    --# End of Gilbot-X mod part 2 of 2
                    --###########################################################	
                end
            end			
        end
    end
    
    
    --# Gilbot-X: 
    --# I added this to support adjacency at sea.
    local getHeightFunction = GetSurfaceHeight
    if unitLayer == 'Seabed' then 
        getHeightFunction = GetTerrainHeight 
    end
    unitHub.pos[2] = getHeightFunction(unitHub.pos[1], unitHub.pos[3]) + verticalOffset

    getHeightFunction = GetSurfaceHeight
    if adjacentUnitLayer == 'Seabed' then 
        getHeightFunction = GetTerrainHeight 
    end
    adjacentHub.pos[2] = getHeightFunction(adjacentHub.pos[1], adjacentHub.pos[3]) + verticalOffset

    --# This only happens if layers are the same
    --# Offset intermediate node positions above the ground at current positions 
    --# surface height or terrain height depending on layer both units are on
    for k, v in nodeList do
        v.pos[2] = getHeightFunction(v.pos[1], v.pos[3]) + verticalOffset
    end
    
    --# Create a couple of props to add a cooler look to the beams
    for k, v in nodeList do
        local tempMesh = v.entity:SetMesh(nodeMesh, false)
        v.mesh = true
    end

    --# Add emitter node effects (for Seraphin only I think)
    if faction == 'Seraphim' and numNodes > 0 then
        for i = 1, numNodes do
            if emitterNodeEffects[i] ~= nil and table.getn(emitterNodeEffects[i]) ~= 0 then
                for k, vEmit in emitterNodeEffects[i] do
                    emit = CreateAttachedEmitter( nodeList[i].entity, 0, army, vEmit )
                    info.Trash:Add(emit)
                    unit.Trash:Add(emit)
                end
            end
        end
    end
    
    --# Insert start and end points into our list
    table.insert(nodeList, 1, unitHub )
    table.insert(nodeList, adjacentHub )

    --# Warp everything to its final position
    for i = 1, numNodes + 2 do
        Warp( nodeList[i].entity, nodeList[i].pos )
        info.Trash:Add(nodeList[i].entity)
        unit.Trash:Add(nodeList[i].entity)
    end

    --# Attach beams to the adjacent unit
    for i = 1, numNodes + 1 do
        if nodeList[i].mesh ~= nil then
            local vec = util.GetDirectionVector(
                Vector(
                    nodeList[i].pos[1], 
                    nodeList[i].pos[2], 
                    nodeList[i].pos[3]
                ), 
                Vector(
                    nodeList[i+1].pos[1], 
                    nodeList[i+1].pos[2], 
                    nodeList[i+1].pos[3]
                )
            )
            nodeList[i].entity:SetOrientation( OrientFromDir(vec), true)
        end
        --# Seraphim don't use beameffect in FA they put radiating effect on nodes
        if beamEffect then
            local beam = AttachBeamEntityToEntity( nodeList[i].entity, -1, 
                                                   nodeList[i+1].entity, -1, army, beamEffect  )
            info.Trash:Add(beam)
            unit.Trash:Add(beam)
        end
    end
    

    
   
end


--#*
--#*  Gilbot-X says:
--#*
--#*  This is a simpler version of CreateAdjacencyBeams that gives
--#*  a single straight-segment beam to link pipelines for all 3 factions.
--#*
--#*  This gets called from the pipeline class 
--#*  when two pipelines are linked to each other.
--#*
--#**
function CreatePipelineToPipelineAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )

    local info = {
        Unit = adjacentUnit,
        Trash = TrashBag(),
    }
    table.insert(AdjacencyBeamsBag, info)
    
    local faction = unit:GetBlueprint().General.FactionName

      --# Determine which effects we will be using
    local beamEffect = nil
    
    --# Give Seraphim the Aeon Beam for now
    if faction == 'Aeon' or faction == 'Seraphim' then
        beamEffect = '/effects/emitters/adjacency_aeon_beam_01_emit.bp'
    elseif faction == 'Cybran' then
        beamEffect = '/effects/emitters/adjacency_cybran_beam_01_emit.bp'
    elseif faction == 'UEF' then
        beamEffect = '/effects/emitters/adjacency_uef_beam_01_emit.bp'
    end
    
    --# Draw the beam between this node and the next.
    local beam = AttachBeamEntityToEntity( unit.HubEffect.entity, -1, 
                                           adjacentUnit.HubEffect.entity, -1, unit:GetArmy(), beamEffect  )
    info.Trash:Add(beam)
    unit.Trash:Add(beam)

end


--#*
--#*  Gilbot-X says:
--#*
--#*  This is a simpler version of CreateAdjacencyBeams that gives
--#*  a single straight-segment beam to link pipelines for all 3 factions.
--#*
--#*  This gets called from the pipeline class 
--#*  when two pipelines are linked to each other.
--#*
--#**
function CreateUnitToPipelineAdjacencyBeams( normalUnit, pipeLineUnit, AdjacencyBeamsBag )

    local info = {
        Unit = pipeLineUnit,
        Trash = TrashBag(),
    }
    
    table.insert(AdjacencyBeamsBag, info)
    
    local faction = normalUnit:GetBlueprint().General.FactionName

    --# Determine which effects we will be using
    local beamEffect = nil
    
    --# Give Seraphim the Aeon Beam for now
    if faction == 'Aeon' or faction == 'Seraphim' then
        beamEffect = '/effects/emitters/adjacency_aeon_beam_01_emit.bp'
    elseif faction == 'Cybran' then
        beamEffect = '/effects/emitters/adjacency_cybran_beam_01_emit.bp'
    elseif faction == 'UEF' then
        beamEffect = '/effects/emitters/adjacency_uef_beam_01_emit.bp'
    end
    
    --# Create hub start/end
    local adjacentHub = pipeLineUnit.HubEffect
      
    --# Draw the beam between this node and the next.
    local beam = AttachBeamEntityToEntity( normalUnit, -1, 
                                           adjacentHub.entity, -1, normalUnit:GetArmy(), beamEffect  )
    info.Trash:Add(beam)
    normalUnit.Trash:Add(beam)
end



--#*
--#*  Gilbot-X says:
--#*
--#*  This is a simpler version of CreateAdjacencyBeams that gives
--#*  a single straight-segment beam to link pipelines for all 3 factions.
--#*
--#*  This gets called from the pipeline class 
--#*  when two pipelines are linked to each other.
--#*
--#**
function CreatePDToPDAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )

    local faction1 = unit:GetBlueprint().General.FactionName
    local faction2 = adjacentUnit:GetBlueprint().General.FactionName
    local beamEffect = nil
    
    --# Determine which effects we will be using
    --# Seraphim get no beam but effect on each PD
    if faction1 == 'Seraphim' and faction2 == 'Seraphim' then
        return
    elseif faction1 == 'Aeon' or faction2 == 'Aeon' then
        beamEffect = '/effects/emitters/adjacency_aeon_beam_01_emit.bp'
    elseif faction1 == 'Cybran' or faction2 == 'Cybran' then
        beamEffect = '/effects/emitters/adjacency_cybran_beam_01_emit.bp'
    elseif faction1 == 'UEF' or faction2 == 'UEF' then 
        beamEffect = '/effects/emitters/adjacency_uef_beam_01_emit.bp'
    end
    
    local info = {
      Unit = adjacentUnit,
      Trash = TrashBag(),
    }
    table.insert(AdjacencyBeamsBag, info)
    
    --# Select appropriate bone so that beam is visisble
    local unitBone, adjacentUnitBone = 0, 0
    if unit.IsT1PDorAA then unitBone='Turret' end 
    if adjacentUnit.IsT1PDorAA then adjacentUnitBone='Turret' end 
    
    --# Draw the beam between this node and the next.
    local beam = AttachBeamEntityToEntity( unit, unitBone, 
                                           adjacentUnit, adjacentUnitBone, 
                                           unit:GetArmy(), beamEffect  )
    info.Trash:Add(beam)
    unit.Trash:Add(beam)

end

--#*
--#*  Gilbot-X says:
--#*
--#*  This is a simpler version of CreateAdjacencyBeams that gives
--#*  a single straight-segment beam to link pipelines for all 3 factions.
--#*
--#*  This gets called from the pipeline class 
--#*  when two pipelines are linked to each other.
--#*
--#**
function CreateWaterToSubAdjacencyBeams( unit, adjacentUnit, AdjacencyBeamsBag )

    local faction1 = unit:GetBlueprint().General.FactionName
    local faction2 = adjacentUnit:GetBlueprint().General.FactionName
    local beamEffect = nil
    
    --# Determine which effects we will be using
    --# Seraphim get no beam but effect on each PD
    if faction1 == 'Seraphim' and faction2 == 'Seraphim' then
        return
    --# Give Cybran precedence
    elseif faction1 == 'Cybran' or faction2 == 'Cybran' then
        beamEffect = '/effects/emitters/adjacency_cybran_beam_01_emit.bp'
    elseif faction1 == 'Aeon' or faction2 == 'Aeon' then
        beamEffect = '/effects/emitters/adjacency_aeon_beam_01_emit.bp'
    elseif faction1 == 'UEF' or faction2 == 'UEF' then 
        beamEffect = '/effects/emitters/adjacency_uef_beam_01_emit.bp'
    end
    
    local info = {
      Unit = adjacentUnit,
      Trash = TrashBag(),
    }
    table.insert(AdjacencyBeamsBag, info)
    
    --# Select appropriate bone so that beam is visisble
    local unitBone, adjacentUnitBone = 0, 0
    
    --# Draw the beam between this node and the next.
    local beam = AttachBeamEntityToEntity( unit, unitBone, 
                                           adjacentUnit, adjacentUnitBone, 
                                           unit:GetArmy(), beamEffect  )
    info.Trash:Add(beam)
    unit.Trash:Add(beam)

end