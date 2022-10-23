do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File :  /lua/sim/buff.lua
--#**
--#****************************************************************************


--# This hook file conflicts with Total Veterancy UI
--# so only apply code if TV UI is not in list of mods active.
local GetActiveModLocation = import('/Mods/GilbotsTotalVeterancyFix/modlocator.lua').GetActiveModLocation
local GilbotsModIsActive = GetActiveModLocation("12345678-2050-4bf6-9236-451244fa8029") --Gilbot-X's Mod Pack 2


--#*
--#*  Gilbot-X says:
--#*
--#*  Eni added two lines of code and a 
--#*  few log statements which are commented out.
--#*
--#*  GPG says: This function is a fire-and-forget.  
--#*  Apply this and it'll be applied over time if 
--#*  there is a duration.
--#**
function ApplyBuff(unit, buffName, instigator)

	--# Start with safety check
    if unit:IsDead() then return end
    
    --#LOG ('buf.apply:',buffName)
    instigator = instigator or unit

    --#buff = table of buff data
    local def = Buffs[buffName]
    --#LOG('*BUFF: FullBuffTable: ', repr(Buffs))
    --#LOG('*BUFF: BuffsTable: ', repr(def))
    if not def then
        error("*ERROR: Tried to add a buff that doesn\'t exist! Name: ".. buffName, 2)
        return
    end
    
    if def.EntityCategory then
        local cat = ParseEntityCategory(def.EntityCategory)
        if not EntityCategoryContains(cat, unit) then
            return
        end
    end
    
    if def.BuffCheckFunction then
        if not def:BuffCheckFunction(unit) then
        	--#LOG('return buff check')
            return
        end
    end
    
    local ubt = unit.Buffs.BuffTable
	
    --# Gilbot-X says: These next 2 lines are added
    if def.MinLevel and def.MinLevel > unit.VeteranLevel then return end
    if def.MaxLevel and def.MaxLevel < unit.VeteranLevel then return end
    
    
    if def.Stacks == 'REPLACE' and ubt[def.BuffType] then
        for key, bufftbl in unit.Buffs.BuffTable[def.BuffType] do
            RemoveBuff(unit, key, true)
        end
    end

    
    --# If add this buff to the list of buffs the 
    --# unit has becareful of stacking buffs.
    if not ubt[def.BuffType] then
        ubt[def.BuffType] = {}
    end
    
    if def.Stacks == 'IGNORE' and ubt[def.BuffType] and table.getsize(ubt[def.BuffType]) > 0 then
    	--#LOG('return Ignore')
        return
    end
    
    local data = ubt[def.BuffType][buffName]
    if not data then
        --# This is a new buff (as opposed to an additional one being stacked)
        data = {
            Count = 1,
            Trash = TrashBag(),
            BuffName = buffName,
        }
        ubt[def.BuffType][buffName] = data
    else
        --# This buff is already on the unit so stack another by incrementing the
        --# counts. data.Count is how many times the buff has been applied
        data.Count = data.Count + 1
        
    end
    
    local uaffects = unit.Buffs.Affects
    if def.Affects then
        for k,v in def.Affects do
            --# Don't save off 'instant' type affects like health and energy
            if k ~= 'Health' and k ~= 'Energy' then
                if not uaffects[k] then
                    uaffects[k] = {}
                end
                
                if not uaffects[k][buffName] then
                    --# This is a new affect.
                    local affectdata = { 
                        BuffName = buffName, 
                        Count = 1, 
                    }
                    for buffkey, buffval in v do
                        affectdata[buffkey] = buffval
                    end
                    uaffects[k][buffName] = affectdata
                else
                    --# This affect is already there, increment the count
                    uaffects[k][buffName].Count = uaffects[k][buffName].Count + 1
                end
            end
        end
    end
    
    --#If the buff has a duration, then 
    if def.Duration and def.Duration > 0 then
        local thread = ForkThread(BuffWorkThread, unit, buffName, instigator) 
        unit.Trash:Add(thread)
        data.Trash:Add(thread)
    end
    
    PlayBuffEffect(unit, buffName, data.Trash)
    
    ubt[def.BuffType][buffName] = data

    if def.OnApplyBuff then
        def:OnApplyBuff(unit, instigator)
    end
  
    --#LOG('*DEBUG: Applying buff :',buffName, ' to unit ',unit:GetUnitId())
    --#LOG('Buff = ',repr(ubt[def.BuffType][buffName]))
    --#LOG('Affects = ',repr(uaffects))
    BuffAffectUnit(unit, buffName, instigator, false)
end




--#*
--#*  Gilbot-X says:
--#*
--#*  Eni made massive changes to this function.  
--#*  I havent't changed anything except a little tyding.
--#*
--#*  GPG says: Function to affect the unit.  
--#*  Everytime you want to affect a new part of unit, add it in here.
--#*  afterRemove is a bool that defines if this buff is affecting after the removal of a buff.  
--#*  We reaffect the unit to make sure that buff type is recalculated accurately without the buff that was on the unit.
--#*  However, this doesn't work for stunned units because it's a fire-and-forget type buff, not a fire-and-keep-track-of type buff.
--#**
function BuffAffectUnit(unit, buffName, instigator, afterRemove)
    
    --# This is original code.
    local buffDef = Buffs[buffName]
    local buffAffects = buffDef.Affects
    --# We probably don't want to do this twice
    if buffDef.OnBuffAffect and not afterRemove then
        buffDef:OnBuffAffect(unit, instigator)
    end
    
    --# This for loop makes up the rest of the function.
    --# The behaviour is changed for some values of atype,
    --# and there are new atype values added.
    for atype, vals in buffAffects do
    
        --# The Health block has not 
        --# been changed in this mod.
        if atype == 'Health' then
        
            --# Note: With health we don't actually look at 
            --# the unit's table because it's an instant happening.  
            --# We don't want to overcalculate something as pliable as health.
            local health = unit:GetHealth()
            local val = ((buffAffects.Health.Add or 0) + health) * (buffAffects.Health.Mult or 1)
            local healthadj = val - health
            
            if healthadj < 0 then
                --# fixme: DoTakeDamage shouldn't be called directly
                local data = {
                    Instigator = instigator,
                    Amount = -1 * healthadj,
                    Type = buffDef.DamageType or 'Spell',
                    Vector = VDiff(instigator:GetPosition(), unit:GetPosition()),
                }
                unit:DoTakeDamage(data)
            else
                unit:AdjustHealth(instigator, healthadj)
                --#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed health to ', repr(val))
            end
        
        
        --# Gilbot-X says:  This block of code has been 
        --# reworked by the Total Veterancy mod
        elseif atype == 'MaxHealth' then
        
            --#local unitbphealth = unit:GetBlueprint().Defense.MaxHealth or 1
            if not unit.basehp then unit.basehp = unit:GetMaxHealth() end 
            
            local oldmax = unit:GetMaxHealth()
            local oldcurrent = unit:GetHealth()
        	
            local val = BuffCalculate(unit, buffName, 'MaxHealth', unit.basehp)
            val = math.ceil(val)
            
            unit:SetMaxHealth(val)
            unit:SetHealth(unit, val * oldcurrent/oldmax) 
            --#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max health to ', repr(val))
        
        
        --# Gilbot-X says:  This block of code has been reworked
        --# to merge the regen types together 
        elseif atype == 'Regen' or atype == 'RegenPercent' then
            
            local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
            local val = BuffCalculate(unit, buffName, 'Regen', bpregn)
            local regenperc, bool, exists = BuffCalculate(unit, buffName, 'RegenPercent', unit:GetMaxHealth())
            if exists then  
            	val = val +  regenperc
            end
        	unit:SetRegenRate(val)
            unit.Sync.RegenRate = val
            
            
        --# This is original FA code for RegenPercent
--[[ 
            #LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed regen rate to ', repr(val))
         elseif atype == 'RegenPercent' then
         
         	local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
             local val = BuffCalculate(unit, buffName, 'Regen', bpregn)
             LOG(val)
         	local val = val + BuffCalculate(unit, buffName, 'RegenPercent', unit:GetMaxHealth())
             unit:SetRegenRate(val)
             unit.Sync.RegenRate = val
             LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed regen rate to ', repr(val))
            local val = false
                
             if afterRemove then
                 #Restore normal regen value plus buffs so I don't break stuff. Love, Robert
                 local bpregn = unit:GetBlueprint().Defense.RegenRate or 0
                 val = BuffCalculate(unit, nil, 'Regen', bpregn)
             else
                 #Buff this sucka
                 val = BuffCalculate(unit, buffName, 'RegenPercent', unit:GetMaxHealth())
             end
             
             unit:SetRegenRate(val)
             unit.Sync.RegenRate = val 
]]

        --# Gilbot-X says:  This ShieldHP block 
        --# was added by the Total Veterancy mod
        elseif atype == 'ShieldHP' then
            
            local shield = unit:GetShield()
            if not shield then return end
            --# Calling GetHealth and GetMaxHealth will include any adjacency 
            --# bonus from the network by Gilbot-X 'Shield-Strength Enhancent' units.
            --# The variable ratiofull is how much HP the shield has out of its max value
            --# as a ratio (0 to 1) and will be the same with or without adjacency bonuses,
            --# as the adjacency bonus is a ()multiplication) factor and both health and 
            --# maxhealth get the same bonus value, so the adjacency bonuses
            --# are cancelled out when calculating ratioFull.            
            local ratioFull = shield:GetMaxHealth() / shield:GetHealth()
            --# SetHealth and SetMaxHealth should be used with values that 
            --# do not include my shield strength adjacency bonus.  The 
            --# adjacency bonuses are temporary (can be taken away if adjacency is broken).
            --# That is why bonus is added to return value when you call GetHealth and GetMaxHealth
            --# but it is not actually added to the base values set in the unit with SetHealth and SetMaxHealth.
            local newShieldMaxHealthWithoutAdjacencyBonus = math.ceil(BuffCalculate(unit, buffName, atype, shield.spec.ShieldMaxHealth))
            shield:SetMaxHealth(newShieldMaxHealthWithoutAdjacencyBonus)
            shield:SetHealth(shield, ratioFull*newShieldMaxHealthWithoutAdjacencyBonus)
            --# Gilbot-X: I change this line so my 
            --# adjacency shield strngth bonus is also counted
            --# along with whatever veterancy bonus we just gave.
            unit.ShieldMaxHPDisplay = shield:GetMaxHealth() 
            unit.Sync.ShieldMaxHP = self.ShieldMaxHPDisplay
            LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed shieldhealth to ', repr(shield:GetMaxHealth()))
            
            
        --# Gilbot-X says:  This ShieldRegen block 
        --# was added by the Total Veterancy mod
         elseif atype == 'ShieldRegen' then
            
            local shield = unit:GetShield()
            if not shield then return end
            local newRegenRate = BuffCalculate(unit, buffName, atype, shield.spec.ShieldRegenRate)
            unit.ShieldRegenRateDisplay = newRegenRate
            unit.Sync.ShieldRegen = unit.ShieldRegenRateDisplay
            shield:SetShieldRegenRate(newRegenRate)
            LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed shieldregen to ', repr(valregen))
            
            
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod
        elseif atype == 'Damage' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if wep.Label ~= 'DeathWeapon' and wep.Label ~= 'DeathImpact' then
                	if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                    local wepbp = wep:GetBlueprint()
	                    local val = BuffCalculate(unit, buffName, atype, wepbp.Damage)
	                    if val >= ( math.abs(val) + 0.5 ) then
	                        val = math.ceil(val)
	                    else
	                        val = math.floor(val)
	                    end
	                    wep.Damage = val
	                    --#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed damage to ', repr(val))
	                    
	                    if wepbp.NukeOuterRingDamage and wepbp.NukeInnerRingDamage then
					        unit.NukeOuterRingDamage = BuffCalculate(unit, buffName, atype, wepbp.NukeOuterRingDamage)
					        unit.NukeInnerRingDamage = BuffCalculate(unit, buffName, atype, wepbp.Damage)
				        end
	                end
                end
            end
        
        
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod
        elseif atype == 'DamageRadius' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                	local val = BuffCalculate(unit, buffName, atype, wepbp.DamageRadius)
                	wep.DamageRadius = val
                	--#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed AoE to ', repr(val))
                	
                	if wepbp.NukeOuterRingRadius and wepbp.NukeInnerRingRadius then
					    unit.NukeOuterRingRadius = (BuffCalculate(unit, buffName, atype, wepbp.NukeOuterRingRadius)+wepbp.NukeInnerRingRadius)/2
					    unit.NukeInnerRingRadius = (BuffCalculate(unit, buffName, atype, wepbp.NukeInnerRingRadius)+wepbp.NukeInnerRingRadius)/2  
				    end
                end
            end

            
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod
        elseif atype == 'MaxRadius' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                	local val = BuffCalculate(unit, buffName, atype, wepbp.MaxRadius)
                	--#LOG(wepbp.Label .. ' newRange:' .. val)
                	wep:ChangeMaxRadius(val)
                    --# rangeMod is added in hook of weapon.lua
                	wep.rangeMod = val / wepbp.MaxRadius
                end
                
                --#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed max radius to ', repr(val))
            end
		
        
        --# Gilbot-X says:  This RateOfFireBuf block 
        --# was added by the Total Veterancy mod
        --# It is for veterancy, not for adjacency bonuses.
        --# The buff for adjacency is below.
        elseif atype == 'RateOfFireBuf' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
				if not (wepbp.WeaponCategory == 'Death' or vals.ByName and not vals.ByName[wepbp.Label] ) then
                    local val = BuffCalculate(unit, buffName, atype, wepbp.RateOfFire)
                	--#LOG(wepbp.Label .. ' newRoF:' .. val)
                	if GilbotsModIsActive and wep.CanUpdateRateOfFireFromBonuses then
                        wep.RateOfFireVeterancyBonus = val
                        wep:UpdateRateOfFireFromBonuses()
                    else
                        wep.bufRoF = val
                	    wep:ChangeRateOfFire(val/wep.adjRoF)
                    end
                end
            end    
        
        
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod
        --# so that it isn't applied to air units
        --# but the code will not work as table.find
        --# cannot be usded to search categories.
        --# EntityCategoryContains m,ust be used instead.       
        elseif atype == 'MoveMult' then
            local UnitType = unit:GetBlueprint().Categories
            --#LOG(repr(UnitType))
            if not table.find(UnitType,'AIR') then
	            local val = BuffCalculate(unit, buffName, 'MoveMult', 1)
	            unit:SetSpeedMult(val)
	            unit:SetAccMult(val)
	            unit:SetTurnMult(val)
	            --#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed speed/accel/turn mult to ', repr(val))
            end
            
            
        --# Gilbot-X says:  This RateOfFireBuf block 
        --# was added by the Total Veterancy mod
        --# but for some reason was commented out.
--[[     elseif atype == 'Fuel' then
            local fuel = unit:GetBlueprint().Physics.FuelUseTime
            if unit:GetBlueprint().Physics.FuelUseTime then
                local val = BuffCalculate(unit, buffName, atype, unit:GetBlueprint().Physics.FuelUseTime)
                local ratio = unit:GetFuelRatio()
                unit:SetFuelUseTime(val)
                unit:SetFuelRatio(ratio)
                LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed flight time to ', repr(val), 'left time is ', repr (unit:GetFuelUseTime()))
            end
]]         

        --# The Stun block has not 
        --# been changed in this mod.
        elseif atype == 'Stun' and not afterRemove then
            unit:SetStunned(buffDef.Duration or 1, instigator)
            --#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed stunned for ', repr(buffDef.Duration or 1))
            if unit.Anims then
                for k, manip in unit.Anims do
                    manip:SetRate(0)
                end
            end
                
                
        --# The WeaponsEnable block has not 
        --# been changed in this mod.            
        elseif atype == 'WeaponsEnable' then
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                local val, bool = BuffCalculate(unit, buffName, 'WeaponsEnable', 0, true)
                wep:SetWeaponEnabled(bool)
            end

            
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod
        elseif atype == 'VisionRadius' then
        	local intelbp = unit:GetBlueprint().Intel
            local val
            if (intelbp.MaxVisionRadius and intelbp.MinVisionRadius) then
            	val = BuffCalculate(unit, buffName, 'VisionRadius', intelbp.MaxVisionRadius or 0)
            	unit.MaxVisionRadius = val
            	unit:SetIntelRadius('Vision', val)
            	 
            	val = BuffCalculate(unit, buffName, 'VisionRadius', intelbp.MinVisionRadius or 0)
            	unit.MinVisionRadius = val
            else
            	val = BuffCalculate(unit, buffName, 'VisionRadius', intelbp.VisionRadius or 0)
            	unit:SetIntelRadius('Vision', val)
            end
            --#LOG('*BUFF: Unit ', repr(unit:GetEntityId()), ' buffed Vison to ', repr(val))

            
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod
        elseif atype == 'RadarRadius' then
            local val = BuffCalculate(unit, buffName, 'RadarRadius', unit:GetBlueprint().Intel.RadarRadius or 0)
            if val <= 0 then
                unit:DisableIntel('Radar')
                return
            end
            if not unit:IsIntelEnabled('Radar') then
                unit:InitIntel(unit:GetArmy(),'Radar', val)
                unit:EnableIntel('Radar')
            else
                unit:SetIntelRadius('Radar', val)
                unit:EnableIntel('Radar')
            end
        
        
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod    
        elseif atype == 'OmniRadius' then
            local val = BuffCalculate(unit, buffName, 'OmniRadius', unit:GetBlueprint().Intel.OmniRadius or 0)
            if val <= 0 then
                unit:DisableIntel('Omni')
                return
            end            
            if not unit:IsIntelEnabled('Omni') then
                unit:InitIntel(unit:GetArmy(),'Omni', val)
                unit:EnableIntel('Omni')
            else
                unit:SetIntelRadius('Omni', val)
                unit:EnableIntel('Omni')
            end
               
               
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod
        --# to add syncing so UI can display it        
        elseif atype == 'BuildRate' then
            --# Original code
            local val = BuffCalculate(unit, buffName, 'BuildRate', unit:GetBlueprint().Economy.BuildRate or 1)
            unit:SetBuildRate( val )
            --# Sync added next line
            unit.Sync.BuildRate = val
            
            
        --# Gilbot-X says:  This EnergyProductionBuf block 
        --# was added by the Total Veterancy mod
        elseif atype == 'EnergyProductionBuf' then
            local val = BuffCalculate(unit, buffName, 'EnergyProductionBuf', unit:GetBlueprint().Economy.ProductionPerSecondEnergy or 0)
            unit.EnergyProdMod = val
            unit:UpdateProductionValues()

            
        --# Gilbot-X says:  This MassProductionBuf block 
        --# was added by the Total Veterancy mod
        elseif atype == 'MassProductionBuf' then
        	local val = BuffCalculate(unit, buffName, 'MassProductionBuf', unit:GetBlueprint().Economy.ProductionPerSecondMass or 0)
            unit.MassProdMod = val
            unit:UpdateProductionValues()
            
            
        --# Gilbot-X says:      
        --# The ADJACENCY block has not 
        --# been changed in this mod.
        --#### ADJACENCY BELOW --####
        elseif atype == 'EnergyActive' then
            local val = BuffCalculate(unit, buffName, 'EnergyActive', 1)
            unit.EnergyBuildAdjMod = val
            unit:UpdateConsumptionValues()
            --#LOG('*BUFF: EnergyActive = ' ..  val)
            
        elseif atype == 'MassActive' then
            local val = BuffCalculate(unit, buffName, 'MassActive', 1)
            unit.MassBuildAdjMod = val
            unit:UpdateConsumptionValues()
            --#LOG('*BUFF: MassActive = ' ..  val)
            
        elseif atype == 'EnergyMaintenance' then
            local val = BuffCalculate(unit, buffName, 'EnergyMaintenance', 1)
            unit.EnergyMaintAdjMod = val
            unit:UpdateConsumptionValues()
            --#LOG('*BUFF: EnergyMaintenance = ' ..  val)
            
        elseif atype == 'MassMaintenance' then
            local val = BuffCalculate(unit, buffName, 'MassMaintenance', 1)
            unit.MassMaintAdjMod = val
            unit:UpdateConsumptionValues()
            --#LOG('*BUFF: MassMaintenance = ' ..  val)
            
        elseif atype == 'EnergyProduction' then
            local val = BuffCalculate(unit, buffName, 'EnergyProduction', 1)
            unit.EnergyProdAdjMod = val
            unit:UpdateProductionValues()
            --#LOG('*BUFF: EnergyProduction = ' .. val)

        elseif atype == 'MassProduction' then
            local val = BuffCalculate(unit, buffName, 'MassProduction', 1)
            unit.MassProdAdjMod = val
            unit:UpdateProductionValues()
            --#LOG('*BUFF: MassProduction = ' .. val)
            
        elseif atype == 'EnergyWeapon' then
            local val = BuffCalculate(unit, buffName, 'EnergyWeapon', 1)
            for i = 1, unit:GetWeaponCount() do
                local wep = unit:GetWeapon(i)
                if wep:WeaponUsesEnergy() then
                    wep.AdjEnergyMod = val
                end
            end
            --#LOG('*BUFF: EnergyWeapon = ' ..  val)
         
         
        --# Gilbot-X says:  This block existed but
        --# was changed by the Total Veterancy mod.
        --# It is intended for setting ROF bonuses
        --# gained from adjacency, i.e. being built
        --# next to energy producing structures.
        --# The change just makes sure that the adjacency
        --# buff is combined with the veterancy buff.
        --# My mod pack doesn't use this buff anyway.        
        elseif atype == 'RateOfFire' then
            for i = 1, unit:GetWeaponCount() do
                --# This is orginal FA code
                local wep = unit:GetWeapon(i)
                local wepbp = wep:GetBlueprint()
                local weprof = wepbp.RateOfFire
                
                --# Set new rate of fire based on blueprint rate of fire
                local val = BuffCalculate(unit, buffName, 'RateOfFire', 1)
                if not GilbotsModIsActive then
                    --# This next line was removed by the mod
                    --local delay = 1 / wepbp.RateOfFire
                    --# This line was inserted by the mod
                    wep.adjRoF= val
                    --# The next line was changed by the mod
                    wep:ChangeRateOfFire(wep.bufRoF/wep.adjRoF)
                    --# This next line is what the line above used to be
                    --wep:ChangeRateOfFire( 1 / ( val * delay ) )
                end
                LOG(string.format('*BUFF: RateOfFire = %f (val:%f)', (wep.bufRoF/wep.adjRoF) ,val))
            end

            
        --# Gilbot-X says:  This Cloak block existed but
        --# was always commented out. It has not been 
        --# changed by the Total Veterancy mod   
--[[            
   CLOAKING is a can of worms.  Revisit later.
        elseif atype == 'Cloak' then
            
            local val, bool = BuffCalculate(unit, buffName, 'Cloak', 0)
            
            if unit:IsIntelEnabled('Cloak') then

                if bool then
                    unit:InitIntel(unit:GetArmy(), 'Cloak')
                    unit:SetRadius('Cloak')
                    unit:EnableIntel('Cloak')
            
                elseif not bool then
                    unit:DisableIntel('Cloak')
                end
            
            end
]] 

       
        elseif atype ~= 'Stun' then
            WARN("*WARNING: Tried to apply a buff with an unknown affect type of " .. atype .. " for buff " .. buffName)
        end
    end
end





--#*  
--#*  Gilbot-X says:
--#*  
--#*  Eni modded this to chnage the way that Mult is stacked
--#*  repeteadly with the Count.  Eni's version removes compound
--#*  interest on Mults that increase the base value. This will have 
--#*  little noticeable effect.  It will stop some buffs increasing 
--#*  exponentially, however values can still decrease exponentially.
--#*  Otherwise he just added an extra return value that indicates 
--#*  to the code calling this function.
--#*  
--#*  GPG says:  Calculates the buff from all the buffs of the same time the unit has.
--#**
function BuffCalculate(unit, buffName, affectType, initialVal, initialBool)
    
    --# Eni Added these
    local exists = false
    local divs = 1.0
    
    --# Original code
    local adds = 0
    local mults = 1.0
    local bool = initialBool or false
    local highestCeil = false
    local lowestFloor = false
    
    --# This was changed just to add the 'exists' in the list of returns 
    --# but since it is not set at this point, it has no affect
    if not unit.Buffs.Affects[affectType] then return initialVal, bool, exists end
    
    
    for k, v in unit.Buffs.Affects[affectType] do
    	--# This is added to 
        --# provide a way to signal 
        --# to calling code that the
        --# buff exists
        exists = true
        
        --# This is original code
    	if v.Add and v.Add ~= 0 then
            adds = adds + (v.Add * v.Count)
        end
     
        --# This was changed
        if v.Mult then
            for i=1, v.Count do
                --# This is replacement code.
                --# Normally it was all treated like divs
                --# but Eni decided that factors higher than 
                --# 1 should be treated differently.
            	if v.Mult >= 1 
                --# mults starts as 1.
                --# This has effect of adding 10% 
                --# of base value for each count so
                --# no compund interest is gained
                then mults = mults + (v.Mult-1)
                --# This is the normal way and
                --# only safe way to handle factors
                --# less than 1 (to avoid reaching zero)
                else divs = divs * v.Mult
                end
            end
        end
        
        --# The rest of this block 
        --# is unchanged
        if not v.Bool 
        then bool = false
        else bool = true
        end
        
        if v.Ceil and (not highestCeil or highestCeil < v.Ceil) then
            highestCeil = v.Ceil
        end
        
        if v.Floor and (not lowestFloor or lowestFloor > v.Floor) then
            lowestFloor = v.Floor
        end
    end
    
    --# GPG says: 
    --# Adds are calculated first, then the mults.  
    --# May want to expand that later.
    --# Gilbot-X says:  extra 'divs' added in next line. 
    local returnVal = (initialVal + adds) * mults * divs
    --# The next two lines are unchanged
    if lowestFloor and returnVal < lowestFloor then returnVal = lowestFloor end
    if highestCeil and returnVal > highestCeil then returnVal = highestCeil end 
    
    --#LOG('*BUFFCALC: Type:' .. affectType ..' initialVal:' ..  initialVal .. ' adds:' .. adds .. ' mults:' .. mults .. ' returnVal:' .. returnVal)
    --# Extra return value 'exists' added by TV mod
    return returnVal, bool, exists
end

end--(of non-destructive hook)