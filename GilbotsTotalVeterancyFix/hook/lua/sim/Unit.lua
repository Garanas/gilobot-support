do--(start of non-destructive hook)

local oldUnit=Unit
Unit = Class(oldUnit) {
    
    --#*
    --#*  A non-destructive override 
    --#*  that adds initialisation.
    --#*  Totally safe.
    --#**
	OnCreate = function(self)
    	oldUnit.OnCreate(self)
        
        --# Initialise class variables
    	local bp = self:GetBlueprint()
    	self.VeteranLevel = 0
    	self.xp = 0
    	self.XPnextLevel = bp.Economy.XPperLevel
    	self.LevelProgress = 0
        
    	--# Sync some Veterancy variables
        self.Sync.LevelProgress = self.LevelProgress
        if bp.Economy.BuildRate then self.Sync.BuildRate = bp.Economy.BuildRate end
        self.Sync.RegenRate = bp.Defense.RegenRate
    end, 

    
    --#*
    --#*  A non-destructive override 
    --#*  that just adds thread management
    --#*  and a new flag for the private use 
    --#*  of this mod.  Totally safe.
    --#**
	OnStopBeingBuilt = function(self, builder, layer)
        --# Use extra flag to set veterancy on new unit from the one that upgraded to it
        if builder.TVStructureUnitUpgrading then self:AddLevels(builder.LevelProgress) end
		--# Fork thread
        if self:GetBlueprint().Economy.xpTimeStep then self:ForkThread(self.XPOverTime) end
        --# Call original code
        oldUnit.OnStopBeingBuilt(self, builder, layer)
	end,
    

    --#
    --#*  New function added, 
    --#*  to be lunched as a thread when
    --#*  this unit is built.  
    --#*  It gives the unit XP
    --#*  points for being alive.
    --#**
	XPOverTime = function(self)
	    local waittime = self:GetBlueprint().Economy.xpTimeStep / 100
		WaitSeconds(waittime)
	    while not self:IsDead() do 
	        --#self:AddLevels(0.01)
	    	self:AddXP(self.XPnextLevel/100)	
			WaitSeconds(waittime)
	    end
    end,
    
    
    --#
    --#*  New function added, 
    --#*  to be lunched as a thread when
    --#*  this unit is building and thread 
    --#*  is killed when building stops.
    --#*  It gives the builder experience 
    --#*  points for building.
    --#**
    startBuildXPThread = function(self)
        local levelPerSecond = self:GetBlueprint().Economy.BuildXPLevelpSecond
		if not levelPerSecond then return end
        WaitSeconds(1)
	    while not self:IsDead() do 
	    	self:AddXP(self.XPnextLevel*levelPerSecond)	
			WaitSeconds(1)
	    end
    end,
    
    
    --#*
    --#*  A non-destructive override 
    --#*  that just adds thread management.
    --#*  Totally safe.
    --#**
    OnStartBuild = function(self, unitBeingBuilt, order)
   	    self.BuildXPThread = ForkThread(self.startBuildXPThread, self)
        oldUnit.OnStartBuild(self, unitBeingBuilt, order)
        --# set a flag for thid mod to use        
        if unitBeingBuilt:GetUnitId() == self:GetBlueprint().General.UpgradesTo and order == 'Upgrade' 
        then self.TVStructureUnitUpgrading = true
        else self.TVStructureUnitUpgrading = false
        end
    end,


    --#*
    --#*  A non-destructive override 
    --#*  that just adds thread management.
    --#*  Totally safe.
    --#**
    OnStopBuild = function(self, unitBeingBuilt)
        self.TVStructureUnitUpgrading = false
        KillThread(self.BuildXPThread)
        oldUnit.OnStopBuild(self, unitBeingBuilt)
    end,
    
    
    --#*
    --#*  A non-destructive override 
    --#*  that just adds thread management.
    --#*  Totally safe.
    --#**
    OnFailedToBuild = function(self)
        self.TVStructureUnitUpgrading = false
    	KillThread(self.BuildXPThread)
    	oldUnit.OnFailedToBuild(self)
    end,
    
        
    --#*
    --#*  A non-destructive override that is not actually 
    --#*  called from any lua files in here or the original.
    --#*  Its use is to manually set a veterancy level by
    --#*  adding the number of kills required to the AddKills 
    --#*  function, rather than directly setting veterancy
    --#*  without setting kills (with SetVeteranLevel).
    --#**
    SetVeterancy = function(self, veteranLevel)
        veteranLevel = veteranLevel or 0
        --# We handle values that are higher than 5.
        --# Base class can't handle them.
        if veteranLevel <= 5 then 
            return oldUnit.SetVeterancy(self, veteranLevel)
        else
            local bp = self:GetBlueprint()
            if bp.Veteran['Level'..veteranLevel] then
                self:AddKills(bp.Veteran['Level'..veteranLevel])
            else
                WARN('SetVeterancy called on ' .. self:GetUnitId() 
                 .. ' with veteran level ' .. veteranLevel 
                 .. ' which was not defined in its BP file. ' 
                 .. ' Veterancy level has not been set.'
                )
            end 
        end
    end, 
    

    --#*
    --#*  A DESTRUCTIVE override that is normally called from
    --#*  OnKilledUnit but is also called from AddXP here.
    --#*  Calls SetVeteran Level in original and here.
    --#**
    CheckVeteranLevel = function(self)
    	if not self.XPnextLevel then return end
        local bp = self:GetBlueprint()
        --#LOG('xp:' .. self.xp.. ' level at:' .. self.XPperLevel)
		while self.xp >= self.XPnextLevel do
            self.xp = self.xp - self.XPnextLevel
			self:SetVeteranLevel(self.VeteranLevel + 1)
			self.XPnextLevel = bp.Economy.XPperLevel * (1+ 0.1*self.VeteranLevel)
        end
        self.LevelProgress = self.xp / self.XPnextLevel + self.VeteranLevel
        self.Sync.LevelProgress = self.LevelProgress
    end,
    
    
    --#
    --#*  New function added, 
    --#*  was called from this file 
    --#*  in SetVeteranLevel above
    --#*  but now only called in defaultunits
    --#*  because it passes veterancy levels 
    --#*  from an upgrading structure to its 
    --#*  upgraded unit version.
    --#*  It ultimate does this by adding XP
    --#*  to the new unit based on the levels
    --#*  of the old unit.
    --#**
    AddLevels = function(self, levels)
		local bp = self:GetBlueprint()
		local curlevel = self.VeteranLevel
		local percent = self.LevelProgress - curlevel
		
		local xpAdd = 0
		if levels >= (1-percent) then
			xpAdd = self.XPnextLevel * (1-percent)
			levels=levels-(1-percent)
		else
			xpAdd =self.XPnextLevel * levels
			levels=0
		end
			
		while levels > 1 do
			levels=levels-1
			curlevel = curlevel +1
			xpAdd=xpAdd + bp.Economy.XPperLevel * (1+ 0.05*curlevel)
		end
		xpAdd=xpAdd + bp.Economy.XPperLevel * (1+ 0.05*(curlevel+1)) * levels
		self:AddXP(xpAdd)
    end,
    
    
    --#*
    --#*  A DESTRUCTIVE override that is normally called from
    --#*  AddKills and CheckVeteranLevel (and is here too).
    --#*  Set the veteran level to the level specified.
    --#**
    SetVeteranLevel = function(self, level)
        --#LOG(' ')
        --#LOG('*DEBUG: '.. self:GetBlueprint().Description .. ' VETERAN UP! LEVEL ', repr(level))
        local old = self.VeteranLevel
        self.VeteranLevel = level

        --# Apply default veterancy buffs
        local buffTypes = { 'Regen', 'Health', 'Damage','DamageArea','Range','Speed','Vision','OmniRadius','Radar','BuildRate','ResourceProduction','RateOfFire','Shield'}
        for k,bType in buffTypes do
            Buff.ApplyBuff( self, 'Veterancy' .. bType)
            --#Buff.ApplyBuff( self, 'Veterancy' .. bType .. level )
        end
        
        --# Get any overriding buffs if they exist
        local bp = self:GetBlueprint().Buffs
        --#Check for unit buffs
        
   		if bp then
        	for bLevel,bData in bp do
        		if (bLevel == 'Any' or bLevel == 'Level'..level) then
        			for bType,bValues in bData do
	        			local buffName = self:CreateUnitBuff(bLevel,bType,bValues)
	        			if buffName then
	        				Buff.ApplyBuff( self, buffName )
	                    end
        			end
        		end
        	end   		
        end

        self:GetAIBrain():OnBrainUnitVeterancyLevel(self, level)
        self:DoUnitCallbacks('OnVeteran')
    end,
    
    
    --#
    --#*  New function added, 
    --#*  to generate the new veterancy buffs
    --#*  called only from this file 
    --#*  in SetVeteranLevel above.
    --#**
    CreateUnitBuff = function(self, levelName, buffType, buffValues)
    	--# Generate a buff based on the unitId
        local buffName = self:GetUnitId() .. levelName .. buffType
        local buffMinLevel = nil
        local buffMaxLevel = nil
        if buffValues.MinLevel then buffMinLevel = buffValues.MinLevel end
        if buffValues.MaxLevel then buffMaxLevel = buffValues.MaxLevel end
        
        --# Create the buff if needed
        if not Buffs[buffName] then
        	--#LOG(buffName .. ': '..buffMinLevel.. ' - '..buffMaxLevel)
            BuffBlueprint {
             	MinLevel = buffMinLevel,
            	MaxLevel = buffMaxLevel,
                Name = buffName,
                DisplayName = buffName,
                BuffType = buffType,
                Stacks = buffValues.Stacks,
                --#self.BuffTypes[buffType].BuffStacks,
                Duration = buffValues.Duration,
                Affects = buffValues.Affects,
            }
        end
        
        --# Return the buffname so the buff can be applied to the unit
        return buffName
    end,
   
   
    --#*
    --#*  A DESTRUCTIVE override that allows 
    --#*  buff bonus and adj bonus at same time!!
    --#*  if self.EnergyProdMod is defined, it is used 
    --#*  instead of bp value before multiplying with 
    --#*  adjacency bonus factor.    
    --#**
  	UpdateProductionValues = function(self)
        local bpEcon = self:GetBlueprint().Economy
        if not bpEcon then return end
        self:SetProductionPerSecondEnergy( (self.EnergyProdMod or bpEcon.ProductionPerSecondEnergy or 0)* (self.EnergyProdAdjMod or 1) )
        self:SetProductionPerSecondMass( (self.MassProdMod or bpEcon.ProductionPerSecondMass or 0) * (self.MassProdAdjMod or 1) )
    end,
    
    
    --#
    --#*  New function added, 
    --#*  called only from this file 
    --#*  and from XEA0002_script.lua
    --#**
    AddXP = function(self,amount)
    	if not self.XPnextLevel then return end
    	self.xp = self.xp + amount
    	self:CheckVeteranLevel()
    end,
    
    
    --#
    --#*  A non-destructive override that makes sure when damage is 
    --#*  done, both the unit giving damage and the unit
    --#*  receiving damage get some XP (experience points)
    --#**
    DoTakeDamage = function(self, instigator, amount, vector, damageType)
    	if instigator and IsUnit(instigator) and not instigator:IsDead() then
	    	local preAdjHealth = self:GetHealth()
	    	local bp = self:GetBlueprint()
	    	if bp.Economy.xpPerHp then
		    	if amount>=preAdjHealth then
		    		instigator:AddXP(preAdjHealth*bp.Economy.xpPerHp)
		    	else
		    		instigator:AddXP(amount*bp.Economy.xpPerHp)
		    		self:AddXP(amount*bp.Economy.xpPerHp)
		    	end
	    	end
    	end
    	oldUnit.DoTakeDamage(self, instigator, amount, vector, damageType)
        
    end,
    
    
    --#
    --#*  New function added, 
    --#*  called only from Buff.lua lines 267 278
    --#**
 	GetShield = function(self)
        return self.MyShield or nil
    end,
}

end--(of non-destructive hook)