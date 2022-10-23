
local oldAIBrain = AIBrain
AIBrain = Class(oldAIBrain) {

    OnCreateHuman = function(self, planName)
        oldAIBrain.OnCreateHuman(self, planName)
        self:InitializeEconomyState()
    end,

    InitializeEconomyState = function(self)
        -- This is called very early, so ensure stats exist
        self:SetArmyStat('Economy_Ratio_Mass',0.0)
        self:SetArmyStat('Economy_Ratio_Energy',0.0)

        if not self.EconStateUnits then
            self.EconStateUnits = {
                MassStorage = {},
                EnergyStorage = {},
            }
        end
        self.EconMassStorageState = nil
        self.EconEnergyStorageState = nil
        self.EconStorageTrigs = {}

        self:SetArmyStatsTrigger('Economy_Ratio_Mass','EconLowMassStore','LessThan',0.1)
        self:SetArmyStatsTrigger('Economy_Ratio_Energy','EconLowEnergyStore','LessThan',0.1)
    end,

    ESRegisterUnitMassStorage = function(self, unit)
        if not self.EconStateUnits then
            self.EconStateUnits = {
                MassStorage = {},
                EnergyStorage = {},
            }
        end
        table.insert(self.EconStateUnits.MassStorage, unit)
    end,

    ESRegisterUnitEnergyStorage = function(self, unit)
        if not self.EconStateUnits then
            self.EconStateUnits = {
                MassStorage = {},
                EnergyStorage = {},
            }
        end
        table.insert(self.EconStateUnits.EnergyStorage, unit)
    end,

    ESUnregisterUnit = function(self, unit)
        for k, v in self.EconStateUnits do
            for i, j in v do
                if j == unit then
                    table.remove(self.EconStateUnits[k], i)
                end
            end
        end
    end,

    ESMassStorageUpdate = function(self, newState)
        if self.EconMassStorageState != newState then
            for k, v in self.EconStateUnits.MassStorage do
                if not v:IsDead() then
                    v:OnMassStorageStateChange(newState)
                else
                    table.remove(self.EconStateUnits.MassStorage, k)
                end
            end
            if newState == 'EconLowMassStore' then
                if not self.EconStorageTrigs['EconMidMassStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Mass','EconMidMassStore','GreaterThanOrEqual',0.11)
                    self.EconStorageTrigs['EconMidMassStore'] = true
                end
            elseif newState == 'EconMidMassStore' then
                if not self.EconStorageTrigs['EconLowMassStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Mass','EconLowMassStore','LessThan',0.1)
                    self.EconStorageTrigs['EconLowMassStore'] = true
                end
                if not self.EconStorageTrigs['EconFullMassStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Mass','EconFullMassStore','GreaterThanOrEqual',0.9)
                    self.EconStorageTrigs['EconFullMassStore'] = true
                end
            elseif newState == 'EconFullMassStore' then
                if not self.EconStorageTrigs['EconMidMassStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Mass','EconMidMassStore','LessThan',0.89)
                    self.EconStorageTrigs['EconMidMassStore'] = true
                end
            end
            self.EconMassStorageState = newState
            return true
        end
        return false
    end,

    ESEnergyStorageUpdate = function(self, newState)
        if self.EconEnergyStorageState != newState then
            for k, v in self.EconStateUnits.EnergyStorage do
                if not v:IsDead() then
                    v:OnEnergyStorageStateChange(newState)
                else
                    table.remove(self.EconStateUnits.EnergyStorage, k)
                end
            end
            if newState == 'EconLowEnergyStore' then
                if not self.EconStorageTrigs['EconMidEnergyStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Energy','EconMidEnergyStore','GreaterThanOrEqual',0.11)
                    self.EconStorageTrigs['EconMidEnergyStore'] = true
                end
            elseif newState == 'EconMidEnergyStore' then
                if not self.EconStorageTrigs['EconLowEnergyStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Energy','EconLowEnergyStore','LessThan',0.1)
                    self.EconStorageTrigs['EconLowEnergyStore'] = true
                end
                if not self.EconStorageTrigs['EconFullEnergyStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Energy','EconFullEnergyStore','GreaterThanOrEqual',0.9)
                    self.EconStorageTrigs['EconFullEnergyStore'] = true
                end
            elseif newState == 'EconFullEnergyStore' then
                if not self.EconStorageTrigs['EconMidEnergyStore'] then
                    self:SetArmyStatsTrigger('Economy_Ratio_Energy','EconMidEnergyStore','LessThan',0.89)
                    self.EconStorageTrigs['EconMidEnergyStore'] = true
                end
            end
            self.EconMassStorageState = newState
            return true
        end
        return false
    end,

}