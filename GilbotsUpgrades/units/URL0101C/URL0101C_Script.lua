--#****************************************************************************
--#**
--#**  New File :  /mods/.../units/URL0101C/URL0101C_script.lua
--#**
--#**  Modded By:  Gilbot-X
--#**
--#**  Summary  :  Cybran Advanced Land Scout Script
--#**
--#****************************************************************************

local CWalkingLandUnit = import('/lua/cybranunits.lua').CWalkingLandUnit
local Entity = import('/lua/sim/Entity.lua').Entity
local BareBonesWeapon = import('/lua/sim/defaultweapons.lua').BareBonesWeapon

local BaseClass = CWalkingLandUnit 


URL0101C = Class(BaseClass) {
    OnStopBeingBuilt = function(self,builder,layer)
        BaseClass.OnStopBeingBuilt(self,builder,layer)
        --#entity used for radar
        local bp = self:GetBlueprint()
        self.RadarEnt = Entity {}
        self.Trash:Add(self.RadarEnt)
        self.RadarEnt:InitIntel(self:GetArmy(), 'Radar', bp.Intel.RadarRadius)
        self.RadarEnt:EnableIntel('Radar')
        self.RadarEnt:AttachBoneTo(-1, self, 0)
        --#antena spinner
        CreateRotator(self, 'Spinner', 'y', nil, 90, 5, 90)
        --#enable cloaking economy
        --#self:SetMaintenanceConsumptionActive()
        self:SetMaintenanceConsumptionInactive()
        self:SetScriptBit('RULEUTC_CloakToggle', true)
        self:RequestRefreshUI()
    end,
    
    Weapons = {        
        Capture = Class(BareBonesWeapon) {        
			
            OnFire = function(self)			
                if self.MoveCommand and not IsCommandDone(self.MoveCommand) then
                    local target = self:GetCurrentTarget()
                    self.CaptureCommand = IssueCapture({self.unit}, target)
                    --LOG('OnFire: Issued Capture on '  .. repr(target:GetUnitId()) 
                    --..  ' e=' .. target:GetEntityId()
                    --)
                elseif self.CaptureCommand and not IsCommandDone(self.MoveCommand) then
                    --# Just do nothing until capture command is done!
                else
                    local pos = self:GetCurrentTargetPos() 
                    --# Kill the AutoTarget Thread if it is not already dead
                    self.MoveCommand = IssueMove({self.unit}, pos)
                    --LOG('OnFire: Issued Move to' 
                    --..  ' x='  .. repr(pos.x)
                    --..  ' z=' ..  repr(pos.z)
                    --)
                end
			end,
            
            OnGotTarget = function(self)
                --BareBonesWeapon.OnGotTarget(self)
                local pos = self:GetCurrentTargetPos() 
                --# Move close enough to target to issue capture
                self.MoveCommand = IssueMove({self.unit},pos)
            end,
        
            OnLostTarget = function(self)
                --LOG('Lost the target.')
                --BareBonesWeapon.OnLostTarget(self)
            end,
        },
    },
    
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my slider control.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#*
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        if statType == "Range" then 
            --# PD has only one weapon
            local gun = self:GetWeapon(1)
            --# Change the range
            gun:ChangeMaxRadius(newStatValue)
        end
    end,
    
}	

TypeClass = URL0101C