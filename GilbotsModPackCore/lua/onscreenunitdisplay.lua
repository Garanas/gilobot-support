--#****************************************************************************
--#**
--#**  New File:  /mods/GilbotsModPackCore/lua/onscreenunitdisplay.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Gets a list of entity IDs of units onscreen
--#**            
--#****************************************************************************

local GilbotUtils = 
    import('/mods/GilbotsModPackCore/lua/utils.lua')

--#*
--#*  Gilbot-X says:
--#*
--#*  SIM callback function that forwards call to an 
--#*  ACU function.  The ACU is required to sync data 
--#*  that cannot be synced through selected units.
--#*  This is the 2nd part of of the round trip.
--#*  The 3rd part is the function in ACUCommon.lua.
--#**
GiveSIMScreenBoundsCallback = function(data)
    local myACU = GilbotUtils.GetFocusArmyACU()
    if myACU then
        myACU:ReceiveACUMessage_SyncOnScreenUnitEntityList(data.ScreenBounds, data.ZoomedOutTooFar)
    end
end


--#*
--#*  Gilbot-X says:
--#*
--#*  This is a USER state function that gets data from USER state
--#*  and passes it to SIM callback function, which in turn 
--#*  must forward the call to an ACU function so the ACU 
--#*  can sync data back to USER state, completing the round trip.
--#*  This is the 1st part of of the round trip.
--#**
function SyncUnitsOnScreen()

    --# Get camera 
    local cam = GetCamera("WorldCamera")    
    local cameraFocusPosition = cam:GetFocusPosition()
    local zoomOffset = cam:GetTargetZoom() / 2
    local zoomedOutTooFarArg = false
    --# If the zoom is set to more than 100
    --# Then we are zoomed out too far to see the display
    --# Note that this will reduce CPU cycles when zooming 
    --# out but also stop us from seeing displays on air units.
    if zoomOffset > 50 then zoomedOutTooFarArg = true end
    local cameraRegionRect = 
        Rect( math.floor(cameraFocusPosition.x - zoomOffset),
              math.floor(cameraFocusPosition.z - zoomOffset),
              math.ceil(cameraFocusPosition.x + zoomOffset),
              math.ceil(cameraFocusPosition.z + zoomOffset)
        )

    --# Perform this so we get updated list
    --# of units onscreen in the sync from SIM
    --# Invoke sim side code.
    SimCallback( 
      {  
        Func='GiveSIMScreenBounds',
        Args={ 
            ScreenBounds= cameraRegionRect,
            ZoomedOutTooFar = zoomedOutTooFarArg
        }
      }
    )
end


    
--#*
--#*  Gilbot-X says:
--#*
--#*  This is a USER state function that represents the 4th and
--#*  final part of the loop. It Gets the data synced from SIM
--#*  by ACU and copies it back to USER state, completing the round trip.
--#**
function GetUnitsOnScreen()

    --# Get Entity ID of this army's ACU
    local myACUEntityId = repr((GetFocusArmy() -1) * 1048576)

    --# This is what the caller is after
    local returnList = {}
    --# If sync data from ACU is available... 
    if UnitData[myACUEntityId].UnitsOnScreenEntityList then
        --# Search through Synced table to make 
        --# an array of unit entity IDs.
        for k, vEntry in UnitData[myACUEntityId].UnitsOnScreenEntityList do
            if vEntry.WithinCameraBoundsNow then
                table.insert(returnList, vEntry.EntityId)
            end
        end
    else
        WARN("No sync found for ACU[".. myACUEntityId .."].UnitsOnScreenEntityList")
    end
    --LOG('Units onscreen: ' .. repr(returnList))
    --# Return what the caller is after
    return returnList, UnitData[myACUEntityId].UnitsOnScreenEntityList
end