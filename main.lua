local mod = RegisterMod("Boss Rush Wave Indicator", 1)

local wave = 0  --this number keeps track of what boss rush wave you are on

local inBossRush = false
local waveChanged = false

function mod:checkBossRush()
	local room = Game():GetRoom()
	if room:GetType() == RoomType.ROOM_BOSSRUSH then
		inBossRush = true

		--reset stats for the counter if the player re-enters bossrush and it isn't complete
		if not room:IsAmbushDone() then
			wave = 0
		end

	else
		inBossRush = false
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.checkBossRush)

function mod:update()
	if inBossRush then
		if waveChanged then
			wave = wave + 1
			waveChanged = false
			
			local subtext =
			{
				[1] = "Boss Rush start!",
				[8] = "Halfway there!",
				[15] = "Final wave!",
			}
			
			local hud = Game():GetHUD()
			if wave <= 15 then
				hud:ShowItemText("Wave ".. wave, subtext[wave])
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.update)


mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc) -- Check for new waves
	local room = Game():GetRoom()
    if inBossRush and room:IsAmbushActive() then
		if npc.CanShutDoors and npc:IsBoss()
        and not npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_NO_TARGET)
        and not npc.SpawnerEntity
		then
            local preventCounting
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity:ToNPC() and entity:CanShutDoors() and entity:IsBoss()
                and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT | EntityFlag.FLAG_NO_TARGET)
                and not npc.SpawnerEntity and entity.FrameCount ~= npc.FrameCount then
                    preventCounting = true
                    break
                end
            end

            if not preventCounting then
                waveChanged = true
            end
        end
	end
end)

function mod:saveData()
	if wave > 0 and wave <= 15 then
		mod:SaveData(wave-1)
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveData)

function mod:loadData()
	if mod:HasData() then
		wave = math.floor(mod:LoadData())
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.loadData)
