--#****************************************************************************
--#** Hook File:  /lua/UserMusic.lua
--#**
--#** Modded By:  Gilbot-X, based on work by Duncane
--#**
--#** Summary  :  This mod adds randomness to the order of tracks played.
--#****************************************************************************


local BattleCueIndex = Random(1, table.getn(BattleCues))
local PeaceCueIndex = Random(1, table.getn(PeaceCues))
local RandomTrackOrdering = true


function StartBattleMusic()
    if Music then
        StopSound(Music,true) --# true means stop immediately
        Music = false
    end
    
    Music = PlaySound( BattleCues[BattleCueIndex] )
    
    --#########################
    --# MOD START
    if RandomTrackOrdering then
        --# Gilbot-X says:
        --# This adds randomness to which track is selected
        --# but means some tracks might get played more than others
        BattleCueIndex = Random(1, table.getn(BattleCues))
    else
        BattleCueIndex = math.mod(BattleCueIndex,table.getn(BattleCues)) + 1
    end
    --# MOD FINISH
    --#########################
    BattleStart = GameTick()
    
    if musicThread then KillThread(musicThread) end
    musicThread = ForkThread(
        function ()
            while GameTick() - LastBattleNotify < PeaceTimer do
                WaitSeconds(1)
            end
            musicThread = false --# clear musicThread so that StartPeaceMusic doesn't kill us.
            StartPeaceMusic(true)
        end
    )
end




function StartPeaceMusic()
    BattleStart = 0
    BattleEventCounter = 0
    LastBattleNotify = GameTick()

    if musicThread then KillThread(musicThread) end
    musicThread = ForkThread(
        function()
            if Music then
                StopSound(Music) 
                WaitFor(Music)
                Music = false
            end

            WaitSeconds(3)

            Music = PlaySound( PeaceCues[PeaceCueIndex] )
            
            --#########################
            --# MOD START
            if RandomTrackOrdering then
                --# Gilbot-X says:
                --# This adds randomness to which track is selected
                --# but means some tracks might get played more than others
                PeaceCueIndex = Random(1, table.getn(PeaceCues))
            else
                PeaceCueIndex = math.mod(PeaceCueIndex,table.getn(PeaceCues)) + 1
            end
            --# MOD FINISH
            --#########################
        end
    )
end