--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/areacommands.lua
--#**  Author(s):  Goom
--#**
--#**  Summary  :  Area Commands mod code
--#**
--#****************************************************************************
    
local mouseStartWorldPos = false
local mouseEndWorldPos = false
local marker = false
local currentCommand = false
local commandTable = {
	{"Attack", "ffff0000"}, --Red #**This needs to be changed; at the moment it attacks off radar
	{"ReclaimOnce", "ffffff00"}, --Yellow
	{"RepairOnce", "ff0000ff"},  --Blue
	{"GuardMobileUnits", "ff00ff00"}, --Green
        {"RepairAndRebuildStructures", "ff88ccee"}, --Light Grey
        {"RepairMobileUnitsInArea", "ff111111"}, --Dark Grey
}
local commandTableindex = false
local currentRepairZones = {
    Mobile={},
    Structure={},
}
local drawingThread = false
local drawingPoints = {}


--#*
--#*  Gilbot-X says:
--#*      
--#*  This is imported and called from the hook of gamemain.lua
--#** 
function Init()
    IN_AddKeyMapTable({['X'] = {action =  'ui_lua import("/mods/GilbotsModPackCore/lua/areacommands.lua").DragFunction()'},})
    import('/lua/ui/game/gamemain.lua').AddBeatFunction(ShowAreas)
end



--#*
--#*  Gilbot-X says:
--#*      
--#*  This is function is passed as an argument in the function Init() above.
--#** 
function ShowAreas()
    if IsKeyDown('Shift') then
        SimCallback({Func = 'DrawRectangle', Args = {rebuildAreas = true, nil, FadeTime = 0.5}})
    end
end



--#*
--#*  Gilbot-X says:
--#*      
--#*  This is imported and called from simcallbacks.lua
--#*  as a sim callback.
--#** 
function DrawRectangle(args)
    if args.rebuildAreas == true then
        --# Rebuild areas are shown in blue when you hold shift
        for i, area in currentRepairZones.Mobile do
            drawingPoints = 
                InsertRectangleDrawingPoints(drawingPoints, commandTable[6][2], area)
        end
        for i, area in currentRepairZones.Structure do
            drawingPoints = 
                InsertRectangleDrawingPoints(drawingPoints, commandTable[5][2], area)
        end
    else
        drawingPoints = 
            InsertRectangleDrawingPoints(drawingPoints, args.color, args.corners)
    end
    
    if not drawingThread then
        drawingThread = ForkThread(function()
            while table.getsize(drawingPoints) > 0 do
                local dirtyTable = {}
                for i, line in drawingPoints do
                    if GetGameTimeSeconds() - line.time > args.FadeTime then
                        table.insert(dirtyTable, i)
                    else
                        local alpha = STR_itox(math.floor(math.max((1 - ((GetGameTimeSeconds() - line.time)/args.FadeTime))*255, 20)))
                        DrawLine(line.start, line.finish, alpha..line.color)
                    end
                end
                for _, index in dirtyTable do
                    table.remove(drawingPoints, index)
                end
                WaitSeconds(.2)
            end
            drawingThread = false
        end)
    end
end



function InsertRectangleDrawingPoints(drawingPoints, colourArg, cornersArg)
    local startTime = GetGameTimeSeconds()
    local left = math.min(cornersArg[1][1], cornersArg[2][1])
    local top = math.min(cornersArg[1][3], cornersArg[2][3])
    local right = math.max(cornersArg[1][1], cornersArg[2][1])
    local bottom = math.max(cornersArg[1][3], cornersArg[2][3])
    table.insert(drawingPoints, {start = VECTOR3(left, GetTerrainHeight(left, top), top), 
                                    finish = VECTOR3(right, GetTerrainHeight(right, top), top), 
                                    color = string.sub(colourArg,3,8), time = startTime})
    table.insert(drawingPoints, {start = VECTOR3(right, GetTerrainHeight(right, top), top), 
                                    finish = VECTOR3(right, GetTerrainHeight(right, bottom), bottom), 
                                    color = string.sub(colourArg,3,8), time = startTime})
    table.insert(drawingPoints, {start = VECTOR3(right, GetTerrainHeight(right, bottom), bottom), 
                                    finish = VECTOR3(left, GetTerrainHeight(left, bottom), bottom), 
                                    color = string.sub(colourArg,3,8), time = startTime})
    table.insert(drawingPoints, {start = VECTOR3(left, GetTerrainHeight(left, bottom), bottom), 
                                          finish = VECTOR3(left, GetTerrainHeight(left, top), top), 
                                          color = string.sub(colourArg,3,8), time = startTime})
                                     
    return drawingPoints
end                                     
                                            

--#*
--#*  Gilbot-X says:
--#*      
--#*  This is function is passed as an argument in the function Init() above.
--#** 
function DragFunction()
    if GetSelectedUnits() then
        if not commandTableindex or table.getn(commandTable) <= commandTableindex then
            commandTableindex = 1
        else
            commandTableindex = commandTableindex + 1
        end
        currentCommand = commandTable[commandTableindex][1]

        if not marker then
            local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
            marker = Bitmap(GetFrame(0))
            local mouseStartScreenPos = GetMouseScreenPos()
            mouseStartWorldPos = GetMouseWorldPos()
            marker.Left:Set(mouseStartScreenPos[1])
            marker.Top:Set(mouseStartScreenPos[2])
            marker:DisableHitTest()
            marker:SetAlpha(0.2)
            marker:SetNeedsFrameUpdate(true)
            marker.OnFrame = function(self)
                local currentMousePos = GetMouseScreenPos()
                marker.Right:Set(GetMouseScreenPos()[1])
                marker.Bottom:Set(GetMouseScreenPos()[2])
            end
            local worldview = import('/lua/ui/game/worldview.lua').viewLeft
            local oldHandleEvent = worldview.HandleEvent
            worldview.HandleEvent = function(self, event)
                if event.Type == 'ButtonPress' then
                    worldview.HandleEvent = oldHandleEvent
                    if event.Modifiers.Left then
                        GiveCommand()
                        return true
                    else
                        marker:Destroy()
                        marker = false					
                        commandTableindex = false
                        currentCommand = false
                        return true
                    end 
                end
            end
        end
        marker:SetSolidColor(commandTable[commandTableindex][2])
    end
end


--#*
--#*  Gilbot-X says:
--#*      
--#*  This is function is called in the function DragFunction above.
--#** 
function GiveCommand()
    if marker then
        marker:Destroy()
        marker = false
        mouseEndWorldPos = GetMouseWorldPos()
        SimCallback({ Func = 'DrawRectangle', 
                      Args = {
                          corners = {mouseStartWorldPos, 
                          mouseEndWorldPos}, 
                          color = commandTable[commandTableindex][2], 
                          FadeTime = 8
                      }
                    }
        )
        SimCallback({ Func = 'AreaCommandCallback',
                      Args = {Start = mouseStartWorldPos,
                              End = mouseEndWorldPos,
                              Army = GetFocusArmy(),
                              Command = currentCommand,
                      },
                    }, true
        )
        commandTableindex = false
        currentCommand = false
    end
end



--#*
--#*  Gilbot-X says:
--#*      
--#*  This is used in the functions below.
--#** 
local ReferencePosition = nil
local ProximitySortFunction = function(unit1, unit2)
    local dist1 = VDist2(
        ReferencePosition[1], 
        ReferencePosition[3], 
        unit1:GetPosition()[1], 
        unit1:GetPosition()[3]
    )
    local dist2 = VDist2(
        ReferencePosition[1], 
        ReferencePosition[3], 
        unit2:GetPosition()[1], 
        unit2:GetPosition()[3]
    )
    return dist1 < dist2
end

                

--#*
--#*  Gilbot-X says:
--#*      
--#*  This is imported and called from simcallbacks.lua
--#*  as a sim callback.
--#** 
function AreaCommand(Data, Units)
    if Units then
        local left = math.min(Data.Start[1], Data.End[1])
        local top = math.min(Data.Start[3], Data.End[3])
        local right = math.max(Data.Start[1], Data.End[1])
        local bottom = math.max(Data.Start[3], Data.End[3])
        local rectangle = Rect(left, top, right, bottom)
        
        if Data.Command == 'Attack' then
            local AllUnits = GetUnitsInRect(rectangle)
            if AllUnits then
                --# Put all units that need attacking into a table
                local attackTable = {}
                for i, unit in AllUnits do
                    if IsEnemy(Data.Army, unit:GetArmy()) then
                        table.insert(attackTable, unit)
                    end
                end
                
                --# Remove any old watch thread
                RemoveAreaThreads(Units)
            
                --# Sort those units by proximity
                ReferencePosition = Units[1]:GetPosition() 
                table.sort(attackTable, ProximitySortFunction)
                
                --# Issue Commands one at a time
                for i, unit in attackTable do
                    IssueAttack(Units, unit)
                end
            end
            
        elseif Data.Command == 'GuardMobileUnits' then
        
            local AllUnits = GetUnitsInRect(rectangle)
            if AllUnits[1] then
                local unitsToGuard = EntityCategoryFilterDown(categories.MOBILE, AllUnits)
                local numberOfUnitsToGuard = table.getn(unitsToGuard)
                --# The next line caps the number of units guarded
                --numberOfUnitsToGuard = math.min(numberOfUnitsToGuard,5)
                
                --# Remove any old watch thread
                RemoveAreaThreads(Units)
                
                for k, vGuarder in Units do
                    --# The next block doesn't work as TestCommandCaps 
                    --# always returns false with RULEUCC_Guard
                    --if not vGuarder:TestCommandCaps('RULEUCC_Guard') then
                    --    WARN('Not a guarder!!')
                    --end
                    IssueClearCommands({vGuarder})
                    for i = 1, numberOfUnitsToGuard do
                        if IsAlly(Data.Army, unitsToGuard[i]:GetArmy())  
                        then
                            IssueGuard({vGuarder}, unitsToGuard[i])
                        end
                    end
                end
            end
            
        elseif Data.Command == 'RepairOnce' then
            local AllUnitsInRect = GetUnitsInRect(rectangle)
            if AllUnitsInRect then
            
                --# Put all selected units that can repair into a table
                local repairables = {}
                for k, vUnit in AllUnitsInRect do
                    if IsAlly(Data.Army, vUnit:GetArmy()) 
                      and vUnit:GetHealth() < vUnit:GetMaxHealth() then
                        table.insert(repairables, vUnit)
                    end
                end
                
                --# Put all units that need repairing into a table
                local repairers = EntityCategoryFilterDown(categories.REPAIR, Units)
                
                --# Remove any old watch thread
                RemoveAreaThreads(repairers)
            
                --# Sort units we will repair by distance if we will issue more than one command  
                if repairers[1] and repairables[2] then 
                    ReferencePosition = repairers[1]:GetPosition()
                    table.sort(repairables, ProximitySortFunction) 
                end
                
                --# Issue the commands one by one
                for unusedIndex1, unitIssuingRepairCommand in repairers do
                    for unusedIndex2, repairableUnit in repairables do
                        IssueRepair({unitIssuingRepairCommand}, repairableUnit)
                    end
                end
                
            end
            
        elseif Data.Command == 'ReclaimOnce' then
        
       
            --# Put all units that need repairing into a table
            local reclaimers = EntityCategoryFilterDown(categories.RECLAIM, Units)
            
            local ents = GetEntitiesInRect(rectangle)
            local reclaimables = {}
            if reclaimers[1] and ents and ents[1] then
            
                --# Remove any old watch thread
                RemoveAreaThreads(reclaimers)
                    
                --# Put all entities that need reclaiming into a table
                for k,vEntity in ents do
                    if (vEntity.MassReclaim and vEntity.MassReclaim > 0) 
                      or (vEntity.EnergyReclaim and vEntity.EnergyReclaim > 0) then
                        table.insert(reclaimables, vEntity)
                    end
                end
                
                --# Sort units we will repair by distance if we will issue more than one command
                ReferencePosition = reclaimers[1]:GetPosition()                
                table.sort(reclaimables, ProximitySortFunction)
                
                --# Issue the commands one by one
                for i, reclaimableEntity in reclaimables do
                    IssueReclaim(reclaimers, reclaimableEntity)
                end
            end
            
        elseif Data.Command == 'RepairAndRebuildStructures' then
        
            --# Put all units that need repairing into a table
            local repairers = EntityCategoryFilterDown(categories.REPAIR, Units)
              
            --# Move engineer to the centre of the guard area
            IssueMove(repairers, 
              {
                (right+left)/2, 
                GetTerrainHeight((right+left)/2, (top+bottom)/2), 
                (top+bottom)/2
              }
            )
            
            --# Remove any old watch thread
            RemoveAreaThreads(repairers)
                
            --# Give each engineer a watch thread
            for i, repairerUnit in repairers do
                
                --# Create new thread
                repairerUnit.RebuildThread = repairerUnit:ForkThread(RebuildStructureThread, rectangle)
                currentRepairZones.Structure[repairerUnit:GetEntityId()] = {Data.Start, Data.End}
                
                --# Replace OnKilled so it removes its entry from our table
                local oldKilled = repairerUnit.OnKilled
                repairerUnit.oldKilled = repairerUnit.OnKilled
                repairerUnit.OnKilled = function(self, instigator, type, overkillRatio)
                    currentRepairZones.Structure[self:GetEntityId()] = nil
                    oldKilled(self, instigator, type, overkillRatio)
                end
            end
            
      elseif Data.Command == 'RepairMobileUnitsInArea' then
        
            --# Put all units that need repairing into a table
            local repairers = EntityCategoryFilterDown(categories.REPAIR, Units)
              
            --# Move engineer to the centre of the guard area
            IssueMove(repairers, 
              {
                (right+left)/2, 
                GetTerrainHeight((right+left)/2, (top+bottom)/2), 
                (top+bottom)/2
              }
            )
            
            --# Remove any old watch thread
            RemoveAreaThreads(repairers)
                
            --# Give each engineer a watch thread
            for i, repairerUnit in repairers do
               
                --# Create new thread
                repairerUnit.RebuildThread = 
                    repairerUnit:ForkThread(RebuildMobileThread, rectangle)
                currentRepairZones.Mobile[repairerUnit:GetEntityId()] = {Data.Start, Data.End}
                
                --# Replace OnKilled so it removes its entry from our table
                local oldKilled = repairerUnit.OnKilled
                repairerUnit.oldKilled = repairerUnit.OnKilled
                repairerUnit.OnKilled = function(self, instigator, type, overkillRatio)
                    currentRepairZones.Mobile[self:GetEntityId()] = nil
                    oldKilled(self, instigator, type, overkillRatio)
                end
            end
            
        end
    end
end


--#*
--#*  Gilbot-X says:
--#*      
--#*  This is function is called in the function AreaCommand above.
--#** 
RemoveAreaThreads = function(unitListArg)
    --# Remove any old watch thread
    for k, vUnit in unitListArg do
        if vUnit.RebuildThread then
            vUnit.IsRepairing = nil
            currentRepairZones.Structure[vUnit:GetEntityId()] = nil
            currentRepairZones.Mobile[vUnit:GetEntityId()] = nil
            vUnit.OnKilled = vUnit.oldKilled
            KillThread(vUnit.RebuildThread)
            vUnit.RebuildThread = false
        end
    end
end
 


 
--#*
--#*  Gilbot-X says:
--#*      
--#*  This is function is called in the two functions below.
--#** 
IsAlreadyBusy = function(repairerArg)
 
    --# Check if we have been marked as free
    if not repairerArg.IsRepairing then return false end
 
    --# Are we doing nothing?
    if repairerArg:IsUnitState('Immobile') then 
        WARN('UnitState is Immobile')
        repairerArg.IsRepairing = nil
        return false
    end
    
    --# Are we doing nothing?
    if repairerArg:IsUnitState('Enhancing') then 
        --WARN('UnitState is Enhancing')
        repairerArg.IsRepairing = nil
        return false
    end
    
    --# Are we not building or repairing?
    if not (
           repairerArg:IsUnitState('Repairing') 
        or repairerArg:IsUnitState('Building')
    )
    then
        --WARN('We arent in building, repairing state anymore.')
        repairerArg.IsRepairing = nil
        return false
    end
    
    --# I sthe unit we are building or repairing dead or finished?
    local targetUnit = GetUnitById(repairerArg.IsRepairing)  
    if not targetUnit or targetUnit:BeenDestroyed() 
      or targetUnit:IsDead() 
      or targetUnit:GetHealth() == targetUnit:GetMaxHealth() then
        repairerArg.IsRepairing = nil
        return false
    end
    
    --# Must still be repairing or building
    return true
end
  

  

--#*
--#*  Gilbot-X says:
--#*      
--#*  This is function is called in the function AreaCommand above.
--#** 
RebuildStructureThread = function(repairerArg, Area)
    local structuresWeAreAlreadyGuarding = {}
    while repairerArg:IsAlive() do
        
        --# Don't issue a new order until last one is complete
        if not IsAlreadyBusy(repairerArg) then  
        
            local AllUnits = GetUnitsInRect(Area)
            --# Filter to only structures
            local AllStructures = {}
            if AllUnits then
                AllStructures = EntityCategoryFilterDown(categories.STRUCTURE, AllUnits)
            end
            
            --# Filter out enemy structures and add new ones to our list
            for unusedArrayIndex, vUnit in AllStructures do
                if vUnit:IsAlive() 
                  and IsAlly(repairerArg:GetArmy(), vUnit:GetArmy()) 
                then 
                    local entityId = vUnit:GetEntityId()
                    if not structuresWeAreAlreadyGuarding[entityId] 
                    then
                        structuresWeAreAlreadyGuarding[entityId] = 
                        {
                            vUnit, 
                            vUnit:GetBlueprint().BlueprintId, 
                            vUnit:GetPosition()
                        }
                    end
                end
            end
            
            --# Repair or rebuild units we are guarding
            local exitLoop = false
            for kEntityId, unitData in structuresWeAreAlreadyGuarding do
                if exitLoop == true then
                    --WARN('exitLoop skipping ' .. repr(kEntityId))
                elseif not (unitData and unitData[1]) then
                    --WARN('Found nil entry for ' 
                    --  .. repr(kEntityId) 
                    --  .. 'in structuresWeAreAlreadyGuarding'
                    --)
                    --# This marks entry for replacement when entityId gets recycled
                    structuresWeAreAlreadyGuarding[kEntityId] = nil
                elseif unitData[1]:IsAlive() then
                    --# Do repairs
                    if unitData[1]:GetHealth() < unitData[1]:GetMaxHealth() then
                        --# This works for FARKs etc.
                        IssueRepair({repairerArg}, unitData[1])
                        repairerArg.IsRepairing = unitData[1]:GetEntityId()
                        exitLoop = true
                        
                        --# Wait and check state status, fix if necessary
                        WaitTicks(1)
                        --# Record state
                        if not (
                             repairerArg:IsUnitState('Building') 
                          or repairerArg:IsUnitState('Repairing')
                        )
                        then
                            --WARN('repairerArg:IsUnitState not Repairing, Building '
                            --  .. 'after structure repair issued')
                            repairerArg:SetUnitState('Repairing', true)
                        end
                    end
                else
                    --# Prevent an upgrading unit from being rebuilt because
                    --# you get a build preview mesh staying on the upgraded unit
                    if unitData[1].UnitBeingBuilt and
                        unitData[1].UnitBeingBuilt:GetUnitId() == 
                        unitData[1]:GetBlueprint().General.UpgradesTo 
                    then
                        --# Upgrade detected so don't rebuild
                        WARN('Dead or destroyed Unit was upgrading')
                        --# Remove entry (doesn't destroy unit)
                        structuresWeAreAlreadyGuarding[kEntityId] = nil
                    else
                        --# Rebuild. Tested this, it does work for SACUs.
                        local isRebuilder = true
                        --for j, v in repairerArg:GetBlueprint().Categories do
                        --    if v == 'REBUILDER' then isRebuilder = true end
                        --end
                        if isRebuilder and repairerArg:CanBuild(unitData[2]) then
                            --# This only works if the engineer is 
                            --# allowed to build the unit that died
                            --# so it doesn't work like a guard command on a FARK 
                            IssueBuildMobile({repairerArg}, unitData[3], unitData[2], {})
                            exitLoop = true
                            structuresWeAreAlreadyGuarding[kEntityId] = nil
                            
                            --# Wait until we start building so we can get the entity ID
                            --# for the new object
                            while not repairerArg.UnitBeingBuilt do
                                WaitTicks(1)
                            end
                            --# Keep references
                            structuresWeAreAlreadyGuarding[repairerArg.UnitBeingBuilt:GetEntityId()] = 
                                repairerArg.UnitBeingBuilt
                            repairerArg.IsRepairing = repairerArg.UnitBeingBuilt:GetEntityId() 
                            
                            --# Record state
                            if not (
                                 repairerArg:IsUnitState('Building') 
                              or repairerArg:IsUnitState('Repairing')
                            )
                            then
                                WARN('repairerArg:IsUnitState not Repairing, Building '
                                  .. 'after structure rebuild issued')
                                    repairerArg:SetUnitState('Building',true)
                            end
                        end
                    end
                end
            end
        end
        
        WaitSeconds(2)
        
    end
end

          
            
            
--#*
--#*  Gilbot-X says:
--#*      
--#*  This is function is called in the function AreaCommand above.
--#** 
RebuildMobileThread = function(repairerArg, Area)

    while not (repairerArg:BeenDestroyed() or repairerArg:IsDead()) do
        
        --# Don't issue a new order until last one is complete
        if not IsAlreadyBusy(repairerArg) then  
        
            local mobileUnitsNowInGuardArea = {}
            local AllUnits = GetUnitsInRect(Area)

            --# Filter to only structures
            if AllUnits then
                mobileUnitsNowInGuardArea = EntityCategoryFilterDown(categories.MOBILE, AllUnits)
            end
          
            --# Repair or rebuild units we are guarding
            for i, vUnit in mobileUnitsNowInGuardArea do
                if vUnit:IsAlive() and
                    IsAlly(repairerArg:GetArmy(), vUnit:GetArmy()) 
                then
                    --# Do repairs
                    if vUnit:GetHealth() < vUnit:GetMaxHealth() then
                        --# This works for FARKs etc.
                        IssueRepair({repairerArg}, vUnit)
                        repairerArg.IsRepairing = vUnit:GetEntityId()
                        
                        --# Wait and check state status, fix if necessary
                        WaitTicks(3)
                        --# Record state
                        if not (
                             repairerArg:IsUnitState('Building') 
                          or repairerArg:IsUnitState('Repairing')
                        )
                        then
                            --WARN('repairerArg:IsUnitState not Repairing, Building '
                            --  .. 'after mobile repair issued')
                            repairerArg:SetUnitState('Repairing', true)
                        end
                    end
                end
            end
        end
        
        WaitSeconds(2)
        
    end
end