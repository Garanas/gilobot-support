do--(start of non-destructive hook)

--#*
--#*  Gilbot-X says:
--#*  
--#*  Eni's Total Veteancy 1.17 code. 
--#*  I haven't made any changes.
--#**
local function TotalVeterancyMods(all_bps)
	
	--#parameters for customisation
	local scalling = (1/2)
	local evenkills = 4
	
	--#base values calculated from cost to compare
	--#t1(Mantis)=64  t2(Rhino)= 238 t3(Loyalist)=603 Monkeylord=17480
	local ACUbaseValue = 750 
	local SCUbaseValue = 1100  --#11k if calculated by cost
	
	--#dropdown code for lobby not working
	--#if ScenarioInfo.Options.XPFormular == "3/4" then
	--#	LOG('is set')
	--#else
	--#	LOG('not set')
	--#end
	
	local once = true
    for id,bp in all_bps.Unit do
		if bp.Defense.RegenRate == nil then
    		bp.Defense.RegenRate = 0
		end
		local RegenMod = 0.9*(50 - 1 / (0.00000060257 * bp.Defense.MaxHealth + 0.020016))
        bp.Defense.RegenRate = bp.Defense.RegenRate + RegenMod
        
--         local regenVal
--         if bp.Buffs and bp.Buffs.Regen and bp.Buffs.Regen.Level1 then
--         	regenVal = bp.Buffs.Regen.Level1
--         else
--         	regenVal = 1
--         end
--         
--         if not bp.Buffs then
--         	bp.Buffs = {}
--         end
--         
--         if not bp.Buffs.Any then
--         	bp.Buffs.Any = {}
--         end
--         
--         if not bp.Buffs.Any.VETERANCYREGEN then
--         	bp.Buffs.Any.VETERANCYREGEN = {
-- 	    		Stacks = 'ALWAYS',
-- 			    Duration = -1,
-- 			    Affects = {
-- 			        Regen = {
-- 			            Add = regenVal,
-- 			            Mult = 1,
-- 			        },
-- 	    		},
--     		}
--         end
        
        --# Override for ACUs and SCUs
        if bp.Economy and not bp.Economy.xpBaseValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and bp.Economy.BuildTime and table.find(bp.Categories,'COMMAND') then
        	bp.Economy.xpBaseValue = ACUbaseValue
        end
        if bp.Economy and not bp.Economy.xpBaseValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and bp.Economy.BuildTime and table.find(bp.Categories,'SUBCOMMANDER') then
        	bp.Economy.xpBaseValue = SCUbaseValue
        end
                
        --#calculate xp depending on xpBaseValue of from cost if no base value is set.
        --#old values are not overwriten
        if bp.Economy and not bp.Economy.xpValue and bp.Economy.BuildCostMass and bp.Economy.BuildCostEnergy and bp.Economy.BuildTime and (not table.find(bp.Categories,'UNTARGETABLE') or bp.Economy.xpBaseValue) then
        	bp.Economy.xpValue = math.pow((bp.Economy.xpBaseValue or (bp.Economy.BuildCostMass + bp.Economy.BuildCostEnergy/200 + bp.Economy.BuildTime/25)),scalling)
        	--#if bp.Description then LOG(bp.Description .. ' ' .. bp.Economy.xpValue) end
        end
        
        --#calculate xp per level dependind on own value and kills per level set.
        if bp.Economy and not bp.Economy.XPperLevel and bp.Economy.xpValue then 
        	bp.Economy.XPperLevel = bp.Economy.xpValue * evenkills
        end
        if bp.Economy and bp.Defense and not bp.Economy.xpPerHp and bp.Economy.xpValue and bp.Defense.MaxHealth then 
        	bp.Economy.xpPerHp = bp.Economy.xpValue / bp.Defense.MaxHealth
        end
        
    end
end
   
   
   
--#*
--#*  A non-destructive override 
--#*  that calls Eni's Total Veteancy 
--#*  1.17 code. Totally safe.
--#**
local oldModBP = ModBlueprints
function ModBlueprints(all_bps)
    --# Run original code and other 
    --# mods already applied first
    oldModBP(all_bps)
    --# Then call extra code added by this mod
    TotalVeterancyMods(all_bps)
end

    
end--(of non-destructive hook)