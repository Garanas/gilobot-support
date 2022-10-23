--#****************************************************************************
--#**
--#**  Hook File:  /units/UAL0105/UAL0105_script.lua
--#**
--#**  Author(s):  Gilbot-X
--#**
--#**  Summary  :  Aeon T1 Engineer Script
--#**
--#****************************************************************************

local AConstructionUnit = import('/lua/aeonunits.lua').AConstructionUnit
local ADFChronoDampener = import('/lua/aeonweapons.lua').ADFChronoDampener
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')

UAL0105 = Class(AConstructionUnit) {

    OnCreate = function(self)
        AConstructionUnit.OnCreate(self)
        self:SetWeaponEnabledByLabel('ChronoDampener', false)
    end,
    
    Weapons = {
        ChronoDampener = Class(ADFChronoDampener) {
            --FxMuzzleFlash = EffectTemplate.AChronoDampener,
            --FxMuzzleFlashScale = 6,
        },
    },
    
    CreateEnhancement = function(self, enh)
        AConstructionUnit.CreateEnhancement(self, enh)
        local bp = self:GetBlueprint().Enhancements[enh]
        if not bp then return end
        if enh == 'Teleporter' then
            self:AddCommandCap('RULEUCC_Teleport')
        elseif enh == 'TeleporterRemove' then
            self:RemoveCommandCap('RULEUCC_Teleport')
        elseif enh == 'ChronoDampener' then
            self:SetWeaponEnabledByLabel('ChronoDampener', true)
        elseif enh == 'ChronoDampenerRemove' then
            self:SetWeaponEnabledByLabel('ChronoDampener', false)
        end
    end,
    
    
    BuildMassExtractor = function(self, position)
    
        --# This is adapted from code from the
        --# MassCollectionUnit class in defaultunits.lua.
        --# First put all mass deposits into a table.
        local markers = ScenarioUtils.GetMarkers()
        for k, v in pairs(markers) do
            if(v.type == 'MASS') then
                table.insert(massDeposits, v)
            end
        end
        
        --# X, Y and Z positions of MeX must be less 
        --# than 1 unit from each of the marker's postion coordinates
        local myPosition = self:GetPosition()
        
        --# Sort the list by proximity with this engineer
        
        --# Move through sorted list, looking at closest deposit first
        for k, vMassDeposit in massDeposits do
            --# Check its position with ACU to see if there is a MeX there
            local massDepositPosition = vMassDeposit.position
            
            --# If we haven't got a mex there already then
            --# Build a MeX there        
            if true then
                IssueBuildMobile({self}, massDepositPosition, 'uab1103', {})
                break
            end
        end
    end,
    
}

TypeClass = UAL0105