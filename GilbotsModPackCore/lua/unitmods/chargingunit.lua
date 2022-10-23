--#****************************************************************************
--#**
--#**  New File :  /mods/GilbotsModPackCore/lua/unitmods/chargingunit.lua
--#**  
--#**  Author   :  Gilbot-X
--#**
--#**  Summary  :  Used by LABs for their charge ability
--#**
--#****************************************************************************

local DebugChargingUnitCode = false
local ChargingUnitLog = function(messageArg)
    if DebugChargingUnitCode then 
        if type(messageArg) == 'string' then
            LOG('ChargingUnit:' .. messageArg)
        end
    end
end
    
local NumberToStringWith2DPMax = 
    import('/mods/GilbotsModPackCore/lua/utils.lua').NumberToStringWith2DPMax
local BareBonesWeapon = 
    import('/lua/sim/defaultweapons.lua').BareBonesWeapon

--# This dummy weapon just makes the LAB
--# run straight at any opponents in its area
--# which should put it in range of its main weapon.
ChargingWeapon = Class(BareBonesWeapon) {        
    OnFire = function(self)	
        --# and no attack command in progress...
        if (not self.AttackCommand)
           or (self.AttackCommand and IsCommandDone(self.AttackCommand)) then
            local target = self:GetCurrentTarget()
            if target.IsUnit and target:IsAlive() then
                local targetPosition = target:GetPosition()
                local myPosition = self.unit:GetPosition()
                --# The function VDist3 returns the scalar distance between two 3D co-ordinates.
                local separation = VDist3(myPosition, targetPosition)
                if separation < 7 then IssueStop({self.unit}) end
                --# Disable this weapon so we fire 
                --# from the main weapons' range.  
                --self:SetWeaponEnabled(false)
                self.AttackCommand = IssueAttack({self.unit}, target)
                --# Debugging only
                ChargingUnitLog(
                    'OnFire: Issued Attack on '  .. repr(target:GetUnitId()) 
                ..  ' e=' .. target:GetEntityId() .. ' dist=' .. repr(separation)
                )
            end
        elseif self.AttackCommand and not IsCommandDone(self.AttackCommand) then
            ---# Debugging only
            ChargingUnitLog('OnFire: Attack in progress.')
        --# If no move command, in progress, then give one!!
        else
            WARN('OnFire: Not supposed to get here!')
        end        
    end,
    
    OnGotTarget = function(self)
        --# mainWeaponRange is set to the minimum range 
        --# of the main weapon
        local mainWeaponRange = 7
        local targetPosition = self:GetCurrentTargetPos() 
        local myPosition = self.unit:GetPosition()
        local separation = VDist3(myPosition, targetPosition)
        
        if separation > mainWeaponRange then        
            --# Work out how far we are from our target
            local disx,disz = 
                targetPosition.x - myPosition.x,
                targetPosition.z - myPosition.z
            --# Work out an offset that has the same 
            --# angle of approach, i.e. so we can move towards 
            --# target but stop 7 units in front of it.
            local p = disz / disx   
            local offsetx = math.pow((math.pow(mainWeaponRange,2) / (1+math.pow(p,2))),0.5)
            local offsetz = offsetx*p
            --# Make sure both values are positive
            if offsetz < 0 then offsetz = offsetz * -1 end
            
            --# Work out where we are moving 
            --# to by adding offsets to target's position
            --# taking care to add or subtract offset
            --# from coordinates depensing on which side 
            --# of the target we are on.  We don't want to 
            --# move further than we have to.
            local movex, movez = 
                targetPosition.x,
                targetPosition.z
            if myPosition.x < targetPosition.x  
            then movex = movex - offsetx
            else movex = movex + offsetx 
            end
            if myPosition.z < targetPosition.z  
            then movez = movez - offsetz
            else movez = movez + offsetz
            end
               
            --# Debugging only
            ChargingUnitLog('OnGotTarget:'
            ..' ME x=' .. NumberToStringWith2DPMax(myPosition.x) 
            ..   ' z=' .. NumberToStringWith2DPMax(myPosition.z)
            ..' TARGET x=' .. NumberToStringWith2DPMax(targetPosition.x) 
            ..       ' z=' .. NumberToStringWith2DPMax(targetPosition.z)
            ..' MOVE x=' .. NumberToStringWith2DPMax(movex) 
            ..     ' z=' .. NumberToStringWith2DPMax(movez)
            )
            
            --# Move close enough to target to fire main weapon
            self.MoveCommand = 
                IssueMove(
                    {self.unit},
                    Vector(movex,targetPosition.y,movez)
                )
        else
            --# Debugging only
            ChargingUnitLog('OnGotTarget: Found target already in range of main weapon:'
            ..  ' DIST=' .. NumberToStringWith2DPMax(separation) 
            )
        end
    end,

    OnLostTarget = function(self)
        IssueStop({self.unit})
        self.AttackCommand = nil
        self.MoveCommand = nil
        --# Debugging only
        ChargingUnitLog('OnLostTarget: called.') 
    end,
}
        
        
--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function MakeChargingUnit(baseClassArg)
    
    
local resultClass = Class(baseClassArg) {

    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is paused, remote-links are disabled.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnScriptBitSet = function(self, bit)
        if bit == 4 then --# production pause toggle
            self:SetWeaponEnabledByLabel('Charge', false)
        else
            --# Base class version will deal with shields etc.
            baseClassArg.OnScriptBitSet(self, bit)
        end
    end,

    --#*
    --#* Gilbot-X says:
    --#*
    --#* When production is unpaused, remote-links are re-established.
    --#* This is an override of functions defined in unit.lua but I 
    --#* have also hooked these functions in this mod.
    --#**
    OnScriptBitClear = function(self, bit)
        --# Gilbot-X says: I added this to call my code
        if bit == 4 then --# production pause toggle
            self:SetWeaponEnabledByLabel('Charge', true)
        else
            --# Base class version will deal with shields etc.
            baseClassArg.OnScriptBitClear(self, bit)
        end
    end,
    
    --#*
    --#*  Gilbot-X says:
    --#*
    --#*  This is required by my slider control.
    --#*  It must update whatever property, feature or variable that 
    --#*  the stat sliders declared in this unit's BP file were designed to adjust.
    --#*
    --#**
    DoStatValueUpdateFunction = function(self, statType, newStatValue)
        if statType == "RateOfFire" then 
            --# PD has only one weapon
            local gun = self:GetWeapon(1)
            --# Change the range
            gun:ChangeMaxRadius(newStatValue)
            --# Work out new rate of fire 
            --# Weapon rate of fire and max radius are inversly proportional 
            gun.RangeReductionRateOfFireBonus = gun:GetBlueprint().MaxRadius / newStatValue
            gun:UpdateRateOfFireFromBonuses()
        elseif statType == "ChargingRange" then 
            --# PD has only one weapon
            local gun = self:GetWeapon(2)
            --# Change the range
            gun:ChangeMaxRadius(newStatValue)
        end
    end,
}

return resultClass

end