--#*****************************************************************************
--#* New File : /mods/GilbotsModPackCore/lua/unitmods/masscollectionunit.lua
--#*
--#* Modded By: Gilbot-X
--#*
--#* Summary  : This is used to change GPG's MassCollectionUnit class.
--#*            I put all the code for that class here, with my additions.
--#*            The extra code is code from my Exponential Mass Extractors mod.
--#*            It also allows for upgrade to be blocked until certain 
--#*            conditions are met.
--#*            
--#*
--#*****************************************************************************

--# Import these to construct a 'previous' base class.
--# Note that this must be a destructive hook
--# because we have to move code from one function 
--# to another, and that cannot be done non-destructively
--# because we would need to access the base class
--# of the previous version, which we can't do.
local StructureUnit = 
    import('/lua/defaultunits.lua').StructureUnit
local MakeAdjacencyStructureUnit = 
    import('/mods/GilbotsModPackCore/lua/adjacency/adjacencystructureunit.lua').MakeAdjacencyStructureUnit

--# This is a base class we can use when we 
--# need to call base class versions of code.
local PreviousBaseClassGuess = MakeAdjacencyStructureUnit(StructureUnit)

--# This function is called to create the class 
--# so this class can add its 
--# code to different base classes.
function ModMassCollectionUnit(baseClassArg)

local resultClass = Class(baseClassArg) {
    
    --#*
    --#*  Gilbot-X says:
    --#*      
    --#*  I overrided OnStopBeingBuilt so I could 
    --#*  register our position so that engineers can
    --#*  automatically build mexes on the nearest 
    --#*  unoccupied mass deposit.
    --#** 
    OnStopBeingBuilt = function(self,builder,layer)
        --# Register with ACU 
        local myCommander = self:GetMyCommander() 
        if myCommander then myCommander:ReceiveACUMessage_RegisterUnit(self, 'MassExtractor') end       
        --# Perform original class version after
        PreviousBaseClassGuess.OnStopBeingBuilt(self,builder,layer)
    end,

    --#*
    --#*  Gilbot-X says:  
    --#* 
    --#*  This function was altered in FA to add the UpgradeWatcher
    --#**
    OnStopBuild = function(self, unitbuilding, order)
        PreviousBaseClassGuess.OnStopBuild(self, unitbuilding, order)
        self:RemoveCommandCap('RULEUCC_Stop')
        if self.UpgradeWatcher then
            KillThread(self.UpgradeWatcher)
            self:SetConsumptionPerSecondMass(0)
            --# Gilbot-X: I added this next line
            self:SetMassMaintenanceConsumptionOverride(0)
            self:SetProductionPerSecondMass(self:GetBlueprint().Economy.ProductionPerSecondMass or 0)
        end  
    end,
    
    --#*
    --#*  GPG says:  
    --#* 
    --#*  New for FA
    --#*  band-aid on lack of multiple separate resource requests per unit...  
    --#*  if mass econ is depleted, take all the mass generated and use it for the upgrade
    --#**
    WatchUpgradeConsumption = function(self)
        --# This code was in an override of OnStartBuild in FA
        --# but I had to move it because of our PreparingToUpgradeState
        --# defined in PauseableProductionUnit.
        self:AddCommandCap('RULEUCC_Stop')
        local massConsumption = self:GetConsumptionPerSecondMass()
        local massProduction = self:GetProductionPerSecondMass()

        while true do
            local fraction = self:GetResourceConsumed()
            --# if we're not getting our full request of energy and mass met...
            if fraction ~= 1 then
               --#check to see if our aiBrain has energy but no mass
               local aiBrain = self:GetAIBrain()
               if aiBrain then
                   local massStored = aiBrain:GetEconomyStored( 'MASS' )
                   if massStored <= 1 then
                       self:SetConsumptionPerSecondMass(massConsumption - massProduction)
                       self:SetProductionPerSecondMass(0)
                   end
               end  
            elseif not self:IsPaused() then
               self:SetConsumptionPerSecondMass(massConsumption)
               self:SetProductionPerSecondMass(massProduction)
            end
            WaitSeconds(0.2)
        end
    end, 
}

return resultClass

end