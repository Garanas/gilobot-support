do--(start of non-destructive hook)
--#****************************************************************************
--#**
--#**  Hook File:  /lua/ui/game/unitview.lua
--#**
--#**  Modded By:  Eni, updtaed by Gilbot-X
--#**
--#**  Summary  :  Overrided so that UI shows more:
--#**              Shields: HP, MaxHP, Regen rate
--#**              Health regen rate
--#**              Build Rate
--#**
--#****************************************************************************


--#*
--#*  Gilbot-X says:
--#*
--#*  Non-destructive override to initialise 
--#*  data members for new controls.
--#**
local OldCreateUI = CreateUI
function CreateUI()
	OldCreateUI()
    controls.vetXPBar = StatusBar(controls.bg, 0, 1, false, false, nil, nil, true)
	controls.vetXPText = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
	controls.shieldText = UIUtil.CreateText(controls.bg, '', 11, UIUtil.bodyFont)
	controls.Buildrate = UIUtil.CreateText(controls.bg, '', 12, UIUtil.bodyFont)
end


--#*
--#*  Gilbot-X says:
--#*
--#*  Non-destructive override to display 
--#*  new controls and set their text.
--#**
local OldUpdateWindow = UpdateWindow
function UpdateWindow(info)
	--# Perform code from original version 
    --# and any other mods active 
    OldUpdateWindow(info)
	
    
	if info.blueprintId ~= 'unknown' then
    	for index = 1, 5 do
            local i = index
            controls.vetIcons[i]:Hide()
        end
		
		controls.vetXPBar:Hide()
		controls.vetXPText:Hide()
		controls.Buildrate:Hide()
		controls.shieldText:Hide()
		
		if UnitData[info.entityId].LevelProgress  then
			local level = math.floor(UnitData[info.entityId].LevelProgress)
			local percent = UnitData[info.entityId].LevelProgress - level
			
			controls.vetXPBar:SetValue(percent)
			controls.vetXPText:SetText(string.format('Level %d', level))
			controls.vetXPText:Show()
			controls.vetXPBar:Show()
		end
		
		if info.health and UnitData[info.entityId].RegenRate then
            controls.health:SetText(string.format("%d / %d +%d/s", info.health, info.maxHealth,math.floor(UnitData[info.entityId].RegenRate)))
        end
		
		if info.shieldRatio > 0 and UnitData[info.entityId].ShieldMaxHP then
			controls.shieldText:Show()
			if UnitData[info.entityId].ShieldRegen then
				controls.shieldText:SetText(string.format("%d / %d +%d/s", math.floor(UnitData[info.entityId].ShieldMaxHP*info.shieldRatio), UnitData[info.entityId].ShieldMaxHP ,UnitData[info.entityId].ShieldRegen))            
        	else
	        	controls.shieldText:SetText(string.format("%d / %d", math.floor(UnitData[info.entityId].ShieldMaxHP*info.shieldRatio), UnitData[info.entityId].ShieldMaxHP ))            
	        end
        end
        
        if UnitData[info.entityId].BuildRate and UnitData[info.entityId].BuildRate >= 2 then
        	controls.Buildrate:SetText(string.format("Build Rate = %d",math.floor(UnitData[info.entityId].BuildRate)))
        	controls.Buildrate:Show()
        end
	else
		controls.vetXPBar:Hide()
		controls.vetXPText:Hide()
		controls.Buildrate:Hide()
	end
end

end --(end of non-destructive hook)