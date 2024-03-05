---------------------------------------------------------------------------------------------------------------------------
require("timers")
require("notifications")
require("game_precache")
require("utility_functions")
require("shared")
require("game_default_vectors")

workTableWithNameAndActions = {}
needToRefundMana = false
needToWTFCount = 0
teamsTable = {}
oldHeroScaleTable = {}
teamsTable["badguys"] = DOTA_TEAM_BADGUYS
teamsTable["goodguys"] = DOTA_TEAM_GOODGUYS
teamsTable["allguys"] = "allguys"
useTestLinkApp = false

skillNeedToRemove = {}
scaleNeedToRemove = {}
---------------------------------------------------------------------------------------------------------------------------

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache(context)
	for _, Particle in pairs(g_ParticlePrecache) do
		PrecacheResource("particle", Particle, context)
	end

	for _, Sound in pairs(g_SoundPrecache) do
		PrecacheResource("soundfile", Sound, context)
	end
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
	CreateDummyCaster()
	GameRules:GetGameModeEntity():SetThink(BitsForTricksGameEvents, 4)
	GameRules:GetGameModeEntity():SetFreeCourierModeEnabled(true)
	GameRules:GetGameModeEntity():SetUseDefaultDOTARuneSpawnLogic(true)
	GameRules:GetGameModeEntity():SetTowerBackdoorProtectionEnabled(true)

    -- thanks Firetoad for the spectator mod fix
    GameRules:SetCustomGameTeamMaxPlayers(1, 14)
end

function CAddonTemplateGameMode:InitGameMode()
	print("Addon is loaded.")
	GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)
	ListenToGameEvent("player_chat", Dynamic_Wrap(CAddonTemplateGameMode, "OnChat"), self)
	ListenToGameEvent(
		"game_rules_state_change",
		Dynamic_Wrap(CAddonTemplateGameMode, "OnStateChanged"),
		CAddonTemplateGameMode
	)
end

function CAddonTemplateGameMode:OnStateChanged()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then
		Timers:CreateTimer(
			10.0,
			function()
				GetOriginalHeroesScale()
			end
		)
	end
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Делаем запрос к сайту и парсим данные
]]
function BitsForTricksGameEvents(playerId)
	local eventsTable = require("eventsList")
	local eventsNamesTable = require("eventsNamesList")
	if IsServer() then
		if useTestLinkApp == true then
			linkApp = "https://---.com"
		else
			linkApp = "https://---.com"
		end

		local steamIds = GetSteamsIds()
		local sendObj = CreateHTTPRequest("GET", linkApp .. "/dota2_show?players=" .. steamIds)    
        
        if sendObj == nil then 
            print("sendObj nil")
            return 5
        end

        sendObj:Send(
			function(result)
				stringFromResult = result["Body"]

				if ((stringFromResult ~= nil and stringFromResult ~= "") or (next(workTableWithNameAndActions))) then
					print(result["Body"]) 
					for matchOne in string.gmatch(stringFromResult, "[^;]+") do
						tempTable = {}
						for matchTwo in string.gmatch(matchOne, "[^|]+") do
							table.insert(tempTable, matchTwo)
						end
						table.insert(workTableWithNameAndActions, tempTable)
					end

					for key, eventInfoTable in pairs(workTableWithNameAndActions) do
						if #eventInfoTable >= 7 then
							if string.find(eventInfoTable[2], "add_spell") then
								if
									pcall(
										CustomAddAbility,
										eventsTable[eventInfoTable[2]],
										teamsTable[eventInfoTable[7]],
										eventsNamesTable[eventInfoTable[2]],
										eventInfoTable[4]
									)
								 then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "ability_on_position") then
								if
									pcall(
										DummyCastAbilityOnPosition,
										eventsTable[eventInfoTable[2]],
										eventsNamesTable[eventInfoTable[2]],
										eventInfoTable[4],
										teamsTable[eventInfoTable[7]]
									)
								 then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "random_tp") then
								if pcall(RandomTP, eventsNamesTable[eventInfoTable[2]], eventInfoTable[4], teamsTable[eventInfoTable[7]]) then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "change_scale") then
								if
									pcall(ChangeModelScale, eventsNamesTable[eventInfoTable[2]], eventInfoTable[4], teamsTable[eventInfoTable[7]])
								 then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "ability_on_target") then
								if
									pcall(
										DummyCastAbilityOnTarget,
										eventsTable[eventInfoTable[2]],
										teamsTable[eventInfoTable[7]],
										eventsNamesTable[eventInfoTable[2]],
										eventInfoTable[4]
									)
								 then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "ability_buff") then
								if
									pcall(
										CastBuffAbilities,
										eventsTable[eventInfoTable[2]],
										teamsTable[eventInfoTable[7]],
										eventsNamesTable[eventInfoTable[2]],
										eventInfoTable[4]
									)
								 then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "respawn_die_hero") then
								if
									pcall(
										RespawnHeroWhenDie,
										teamsTable[eventInfoTable[7]],
										eventsNamesTable[eventInfoTable[2]],
										eventInfoTable[4]
									)
								 then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "give_two_rapiers") then
								if pcall(GiveTwoRapiers, eventsNamesTable[eventInfoTable[2]], eventInfoTable[4], teamsTable[eventInfoTable[7]]) then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "need_wtf") then
								if pcall(EnableWTF, eventsNamesTable[eventInfoTable[2]], eventInfoTable[4]) then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "spawn_boss") then
								if pcall(SpawnBoss, eventsNamesTable[eventInfoTable[2]], eventInfoTable[4]) then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							elseif string.find(eventInfoTable[2], "respawn_alive_hero") then
								if
									pcall(
										RespawnHeroWhenAlive,
										teamsTable[eventInfoTable[7]],
										eventsNamesTable[eventInfoTable[2]],
										eventInfoTable[4]
									)
								 then
									table.remove(workTableWithNameAndActions, 1)
									print("Success")
									break
								else
									table.remove(workTableWithNameAndActions, 1)
									print("Failure")
									break
								end
							else
								table.remove(workTableWithNameAndActions, 1)
								print("The activation word was not found.")
							end
						else
							table.remove(workTableWithNameAndActions, 1)
							print("Error in ResultBody. Link app: " .. tostring(useTestLinkApp))
						end
					end
				end
			end
		)
	end
	return 5
end 

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция поиска steamIds всех игроков и записи в переменную
]]
function GetSteamsIds()
	local steamIdsTable = {}
    local resultOnEmpty = ""
    if useTestLinkApp == true then
        steamIdsTable[#steamIdsTable + 1] = "5645"
        resultOnEmpty = "5645"
    end

    local allHeroes = HeroList:GetAllHeroes()
    if allHeroes == nil then 
        print("allHeroes nil")
        return resultOnEmpty
    end

    if #allHeroes == 0 then 
        print("allHeroes 0")
        return resultOnEmpty
    end

	for i, hero in pairs(allHeroes) do
		if hero ~= nil and hero:IsRealHero() then
			local playerID = hero:GetPlayerID()
			local steamID = PlayerResource:GetSteamID(playerID)
			steamIdsTable[#steamIdsTable + 1] = tostring(steamID)
		end
	end

	return table.concat(steamIdsTable, ",")
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция телепорта в рандомную точку
]]
function RandomTP(eventName, donatorName, teamName)
	local allHeroes = HeroList:GetAllHeroes()
	ShowHud(eventName, donatorName, teamName)
	for k, hero in pairs(allHeroes) do
		if hero:GetTeamNumber() == teamName or teamName == "allguys" then
			hero:SetAbsOrigin(RandomVector(5000)) -- получили координаты, теперь меняем место героя на рандомную
			FindClearSpaceForUnit(hero, RandomVector(5000), false) --нужно чтобы герой не застрял
			hero:Stop() --приказываем ему остановиться, иначе он побежит назад к предыдущей точке
			ShowBlinkEffects(hero)
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция воспроизведения звука, партикла и перевода камеры при ТП 
]]
function ShowBlinkEffects(hero)
	local blinkEffect = "models/heroes/antimage_female/debut/particles/blink/antimage_debut_blink_sparkles.vpcf"
	local pfx = ParticleManager:CreateParticle(blinkEffect, PATTACH_WORLDORIGIN, hero)
	ParticleManager:SetParticleControl(pfx, 0, hero:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(pfx)
	PlayerResource:SetCameraTarget(hero:GetPlayerOwnerID(), hero)
	Timers:CreateTimer(
		0.1,
		function()
			PlayerResource:SetCameraTarget(hero:GetPlayerOwnerID(), nil)
			return nil
		end
	)
	EmitSoundOn("Hero_Antimage.Blink_out", hero)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция изменения размера модельки
]]
function ChangeModelScale(eventName, donatorName, teamName)
	local allHeroes = HeroList:GetAllHeroes()

	for k, hero in pairs(allHeroes) do
		if hero:GetTeamNumber() == teamName or teamName == "allguys" then
			if oldHeroScaleTable[hero] == nil then
				local heroScale = hero:GetModelScale()
				oldHeroScaleTable[hero] = heroScale
			end
			hero:SetModelScale(oldHeroScaleTable[hero] * 0.25)
			GainMoveSpeed(hero)
		end
	end

	ShowHud(eventName, donatorName, teamName)

	--Функция для поиска значений, запускались ли уже уменьшение на команду. Нужно для того, чтобы продлевать действие уменьшения
	local nameForTableKey = tostring(teamName)
	if scaleNeedToRemove[nameForTableKey] == nil then
		scaleNeedToRemove[nameForTableKey] = 1
	else
		local timeToStarts = scaleNeedToRemove[nameForTableKey]
		timeToStarts = timeToStarts + 1
		scaleNeedToRemove[nameForTableKey] = timeToStarts
	end
	---------------------------------------------------------------------

	Timers:CreateTimer(
		60.0,
		function()
			--Функция для поиска значений, запускались ли уже уменьшение на команду. Нужно для того, чтобы продлевать действие уменьшения
			local timeToStarts = scaleNeedToRemove[nameForTableKey]
			timeToStarts = timeToStarts - 1
			scaleNeedToRemove[nameForTableKey] = timeToStarts
			---------------------------------------------------------------------

			if scaleNeedToRemove[nameForTableKey] == 0 then
				if nameForTableKey == "allguys" then
					if scaleNeedToRemove[tostring(DOTA_TEAM_BADGUYS)] == nil then
						scaleNeedToRemove[tostring(DOTA_TEAM_BADGUYS)] = 0
					end
					if scaleNeedToRemove[tostring(DOTA_TEAM_GOODGUYS)] == nil then
						scaleNeedToRemove[tostring(DOTA_TEAM_GOODGUYS)] = 0
					end
					if scaleNeedToRemove[tostring(DOTA_TEAM_BADGUYS)] > 0 then
						teamName = DOTA_TEAM_GOODGUYS
					end
					if scaleNeedToRemove[tostring(DOTA_TEAM_GOODGUYS)] > 0 then
						teamName = DOTA_TEAM_BADGUYS
					end
					if (scaleNeedToRemove[tostring(DOTA_TEAM_BADGUYS)] > 0) and (scaleNeedToRemove[tostring(DOTA_TEAM_GOODGUYS)] > 0) then
						return nil
					end
				end

				for k, hero in pairs(allHeroes) do
					if hero:GetTeamNumber() == teamName or teamName == "allguys" then
						RemoveMoveSpeed(hero)
						hero:SetModelScale(oldHeroScaleTable[hero])
					end
				end
			end
			return nil
		end
	)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция изменения размера модельки
]]
function GetOriginalHeroesScale()
	local allHeroes = HeroList:GetAllHeroes()
	if next(oldHeroScaleTable) == nil then
		for k, hero in pairs(allHeroes) do
			local heroScale = hero:GetModelScale()
			oldHeroScaleTable[hero] = heroScale
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция добавления скорости
]]
function GainMoveSpeed(hero)
	local speedAbility = hero:AddAbility("movespeed")
	speedAbility:SetLevel(4)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция забирает скорость
]]
function RemoveMoveSpeed(hero)
	hero:RemoveAbility("movespeed")
	hero:RemoveModifierByName("modifier_movespeed")
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция добавления абилки на 30 сек и затем удаления
]]
function CustomAddAbility(abilityName, teamName, eventName, donatorName)
	if IsServer() then
		local allHeroes = HeroList:GetAllHeroes()
		for k, hero in pairs(allHeroes) do
			if hero:GetTeamNumber() == teamName or teamName == "allguys" then
				local ability = hero:FindAbilityByName(abilityName)
				if ability == nil then
					ability = hero:AddAbility(abilityName)
					ability:SetLevel(4)
					if ability == nil then
						print("ERROR! Ability is nil")
						return
					end
				end
				if hero:GetUnitName() == "npc_dota_hero_techies" and abilityName == "techies_land_mines" then
					prevAbilityLvl = ability:GetLevel()
					ability:SetLevel(4)
				end
				if ability:IsHidden() == true or ability:IsActivated() == false then
					ability:SetHidden(false)
					ability:SetActivated(true)
				end
			end
		end
		if abilityName == "techies_land_mines" then
			needToRefundMana = true
		end
		ShowHud(eventName, donatorName, teamName)

		--Функция для поиска значений, запускались ли уже умения на команду. Нужно для того, чтобы продлевать действие добавления скила
		local nameForTableKey = abilityName .. teamName
		if skillNeedToRemove[nameForTableKey] == nil then
			skillNeedToRemove[nameForTableKey] = 1
		else
			local timeToStarts = skillNeedToRemove[nameForTableKey]
			timeToStarts = timeToStarts + 1
			skillNeedToRemove[nameForTableKey] = timeToStarts
		end
		---------------------------------------------------------------------

		Timers:CreateTimer(
			90.0,
			function()
				--Функция для поиска значений, запускались ли уже умения на команду. Нужно для того, чтобы продлевать действие добавления скила
				local timeToStarts = skillNeedToRemove[nameForTableKey]
				timeToStarts = timeToStarts - 1
				skillNeedToRemove[nameForTableKey] = timeToStarts
				---------------------------------------------------------------------
				if skillNeedToRemove[nameForTableKey] == 0 then
					for k, hero in pairs(allHeroes) do
						if hero:GetTeamNumber() == teamName or teamName == "allguys" then
							if hero:GetUnitName() == "npc_dota_hero_techies" and abilityName == "techies_land_mines" then
								local ability = hero:FindAbilityByName(abilityName)
								ability:SetLevel(prevAbilityLvl)
							else
								local ability = hero:FindAbilityByName(abilityName)
								ability:SetHidden(true)
								ability:SetActivated(false)
							end
						end
					end

					if abilityName == "techies_land_mines" then
						needToRefundMana = false
					end
				end
				return nil
			end
		)
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция создания думика. Существо, которое будет кастовать скилы. Спрятано за картой, в координатах Vector(8000, -8000, 0) --Vector(-1000, -8400, 0)
]]
function CreateDummyCaster()
	if hDummyCaster == nil then
		hDummyCaster =
			CreateUnitByName("npc_dota_dummy_caster_reserve", Vector(8000, -8000, 0), true, nil, nil, DOTA_TEAM_CUSTOM_1)
		if hDummyCaster == nil then
			print("ERROR!  Dummy caster is nil.")
			return
		end
	end

	hDummyCaster:AddItemByName("item_aether_lens_2") --Даём aether_lens для увеличения дальности каста
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция создания думика Radiant. Существо, которое будет кастовать скилы. Спрятано за картой, в координатах Vector(-1000, -8400, 0)
]]
function CreateDummyCasterRadiant()
	if hDummyCasterRadiant == nil then
		hDummyCasterRadiant =
			CreateUnitByName("npc_dota_dummy_caster_reserve", Vector(-1000, -8401, 0), true, nil, nil, DOTA_TEAM_GOODGUYS)
		if hDummyCasterRadiant == nil then
			print("ERROR!  Dummy caster is nil.")
			return
		end
	end

	hDummyCasterRadiant:AddItemByName("item_aether_lens_2") --Даём aether_lens для увеличения дальности каста
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция создания думика Dire. Существо, которое будет кастовать скилы. Спрятано за картой, в координатах Vector(-1000, -8400, 0)
]]
function CreateDummyCasterDire()
	if hDummyCasterDire == nil then
		hDummyCasterDire =
			CreateUnitByName("npc_dota_dummy_caster_reserve", Vector(-1000, -8402, 0), true, nil, nil, DOTA_TEAM_BADGUYS)
		if hDummyCasterDire == nil then
			print("ERROR!  Dummy caster is nil.")
			return
		end
	end

	hDummyCasterDire:AddItemByName("item_aether_lens_2") --Даём aether_lens для увеличения дальности каста
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция для каста способностей. Для исключений, по типу мин течиса. 
]]
function DummyCastAbilityOnPositionReserve(dummyAbilityNameToCast, teamName)
	if IsServer() then
		local dummmyName = hDummyCaster
		--[[Выбираем какого думика использовать для определенной стороны. Не работает, т.к. думик даёт вижн
		if teamName == DOTA_TEAM_BADGUYS then
			dummmyName = hDummyCasterDire
		elseif teamName == "" then
			dummmyName = hDummyCasterRadiant
		elseif teamName == "allguys" then
			local dummmyName = hDummyCaster
		end]]
		local abilityToCast = dummmyName:FindAbilityByName(dummyAbilityNameToCast)
		if abilityToCast == nil then
			abilityToCast = dummmyName:AddAbility(dummyAbilityNameToCast)
			if abilityToCast == nil then
				print("ERROR! Ability is nil")
				return
			end
		end
		abilityToCast:SetLevel(4)

		local rndVector = GetRandomVectorFromDefaultVectors()
		rndVector.z = GetGroundHeight(rndVector, nil)
		dummmyName:CastAbilityOnPosition(rndVector, abilityToCast, -1)
		AddFOWViewer(DOTA_TEAM_GOODGUYS, rndVector, 500, 5, false)
		AddFOWViewer(DOTA_TEAM_BADGUYS, rndVector, 500, 5, false)
		abilityToCast:EndCooldown()
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция нахождения рандомного вектора из списка и прибавление к нему еще рандома
]]
function GetRandomVectorFromDefaultVectors()
	local resultingVector = GetRandomElement(g_DefaultVectors) + RandomVector(RandomFloat(0, 1000))
	return resultingVector
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция каста способности на позицию(санстрайк, блэкхол и т.д.)
]]
function DummyCastAbilityOnPosition(dummyAbilityNameToCast, eventName, donatorName, teamName)
	local firstExecutionsCount = 1
	local secondExecutionsFirstRandom = 1
	local secondExecutionsSecondRandom = 1
	local leadTime = 1
	local counter = 0
	ShowHud(eventName, donatorName, teamName)

	if dummyAbilityNameToCast == "undying_tombstone" then
		firstExecutionsCount = 2
		secondExecutionsFirstRandom = 1
		secondExecutionsSecondRandom = 1
		leadTime = 45
		if teamName == "allguys" then
			teamName = "random"
		end
	elseif dummyAbilityNameToCast == "bloodseeker_blood_bath" then
		firstExecutionsCount = 8
		secondExecutionsFirstRandom = 3
		secondExecutionsSecondRandom = 6
		leadTime = 45
	elseif dummyAbilityNameToCast == "faceless_void_chronosphere" then
		firstExecutionsCount = 6
		secondExecutionsFirstRandom = 2
		secondExecutionsSecondRandom = 5
		leadTime = 45
	elseif dummyAbilityNameToCast == "enigma_black_hole" then
		firstExecutionsCount = 6
		secondExecutionsFirstRandom = 2
		secondExecutionsSecondRandom = 5
		leadTime = 45
	elseif dummyAbilityNameToCast == "gyrocopter_call_down" then
		firstExecutionsCount = 8
		secondExecutionsFirstRandom = 3
		secondExecutionsSecondRandom = 6
		leadTime = 45
	elseif dummyAbilityNameToCast == "kunkka_torrent" then
		firstExecutionsCount = 8
		secondExecutionsFirstRandom = 4
		secondExecutionsSecondRandom = 6
		leadTime = 45
	elseif
		dummyAbilityNameToCast == "zuus_thundergods_wrath" or dummyAbilityNameToCast == "silencer_global_silence_datadriven"
	 then
		firstExecutionsCount = 1
		secondExecutionsFirstRandom = 1
		secondExecutionsSecondRandom = 1
		leadTime = 0
	elseif dummyAbilityNameToCast == "puck_dream_coil" or dummyAbilityNameToCast == "disruptor_kinetic_field" then
		firstExecutionsCount = 1
		secondExecutionsFirstRandom = 1
		secondExecutionsSecondRandom = 1
		leadTime = 0
	elseif dummyAbilityNameToCast == "techies_land_mines" then
		firstExecutionsCount = 5
		secondExecutionsFirstRandom = 1
		secondExecutionsSecondRandom = 1
		leadTime = 30
	end

	for i = 1, firstExecutionsCount do
		if dummyAbilityNameToCast == "puck_dream_coil" or dummyAbilityNameToCast == "disruptor_kinetic_field" then
			for _, hero in pairs(HeroList:GetAllHeroes()) do
				CreateDummyAtPositionAndCastAbilityAtPosition(dummyAbilityNameToCast, hero:GetOrigin(), teamName)
			end
		elseif dummyAbilityNameToCast == "techies_land_mines" then
			--CreateDummyAtPositionAndCastAbilityAtPosition(GetRandomElement({"techies_land_mines", "techies_stasis_trap"}), nil)
			DummyCastAbilityOnPositionReserve(GetRandomElement({"techies_land_mines", "techies_stasis_trap"}), teamName)
		else
			if teamName == "random" then
				CreateDummyAtPositionAndCastAbilityAtPosition(
					dummyAbilityNameToCast,
					nil,
					GetRandomElement({DOTA_TEAM_BADGUYS, DOTA_TEAM_GOODGUYS})
				)
			else
				CreateDummyAtPositionAndCastAbilityAtPosition(dummyAbilityNameToCast, nil, teamName)
			end
		end
	end
	Timers:CreateTimer(
		function()
			if counter < leadTime then
				for i = 1, RandomInt(secondExecutionsFirstRandom, secondExecutionsSecondRandom) do
					if dummyAbilityNameToCast == "techies_land_mines" then
						--[[CreateDummyAtPositionAndCastAbilityAtPosition(
							GetRandomElement({"techies_land_mines", "techies_stasis_trap"}),
							nil
						)]]
						DummyCastAbilityOnPositionReserve(GetRandomElement({"techies_land_mines", "techies_stasis_trap"}), teamName)
					else
						if teamName == "random" then
							CreateDummyAtPositionAndCastAbilityAtPosition(
								dummyAbilityNameToCast,
								nil,
								GetRandomElement({DOTA_TEAM_BADGUYS, DOTA_TEAM_GOODGUYS})
							)
						else
							CreateDummyAtPositionAndCastAbilityAtPosition(dummyAbilityNameToCast, nil, teamName)
						end
					end
				end
				counter = counter + 1
				return 2.0
			else
				return nil
			end
		end
	)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция создания думика и каста способности на позицию
]]
function CreateDummyAtPositionAndCastAbilityAtPosition(dummyAbilityNameToCast, vectorToCast, teamName)
	if IsServer() then
		if teamName == "allguys" then
			teamName = DOTA_TEAM_CUSTOM_1
		elseif teamName == DOTA_TEAM_BADGUYS then
			teamName = DOTA_TEAM_GOODGUYS
		elseif teamName == DOTA_TEAM_GOODGUYS then
			teamName = DOTA_TEAM_BADGUYS
		end
		local dummyCaster =
			CreateUnitByNameAsync(
			"npc_dota_dummy_caster",
			Vector(-1000, -8400, 0),
			false,
			nil,
			nil,
			teamName,
			function(unit)
				local abilityToCast = unit:FindAbilityByName(dummyAbilityNameToCast)
				if abilityToCast == nil then
					abilityToCast = unit:AddAbility(dummyAbilityNameToCast)
					abilityToCast:SetLevel(4)
					if abilityToCast == nil then
						print("ERROR! Ability is nil")
						return
					end
				end
				unit:AddItemByName("item_aether_lens_2")
				--Улучшаем способность(Аганим)
				if abilityToCast:GetLevel() < 1 then
					print("Ability was not upgraded")
					abilityToCast:UpgradeAbility(true)
				end
				----
				unit:SetContextThink(
					DoUniqueString("cast_ability"),
					function()
						if
							dummyAbilityNameToCast == "zuus_thundergods_wrath" or
								dummyAbilityNameToCast == "silencer_global_silence_datadriven"
						 then
							local rndVector = GetRandomVectorFromDefaultVectors()
							unit:CastAbilityOnPosition(rndVector, abilityToCast, -1) --Для проверки - на центр экрана спамим Vector(1600, -1700, 0) или Vector(0, 0, 0). Иначе RandomVector(5000)
							abilityToCast:EndCooldown()
							return nil
						elseif dummyAbilityNameToCast == "puck_dream_coil" or dummyAbilityNameToCast == "disruptor_kinetic_field" then
							unit:CastAbilityOnPosition(vectorToCast, abilityToCast, -1) --Для проверки - на центр экрана спамим Vector(1600, -1700, 0) или Vector(0, 0, 0). Иначе RandomVector(5000)
							abilityToCast:EndCooldown()
							return nil
						else
							local rndVector = GetRandomVectorFromDefaultVectors()
							rndVector.z = GetGroundHeight(rndVector, nil)
							PingOnMap(rndVector, DOTA_MINIMAP_EVENT_TEAMMATE_DIED)
							unit:CastAbilityOnPosition(rndVector, abilityToCast, -1)
							abilityToCast:EndCooldown()
							AddFOWViewer(DOTA_TEAM_GOODGUYS, rndVector, 500, 5, false)
							AddFOWViewer(DOTA_TEAM_BADGUYS, rndVector, 500, 5, false)
						end
					end,
					0
				)
				----\

				unit:SetContextThink(
					DoUniqueString("Remove_Self"),
					function()
						print("unit removed")
						unit:RemoveSelf()
					end,
					10
				)
				return unit
			end
		)
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция пинга по карте
]]
function PingOnMap(rndVectorPosition, minimapEvent)
	for playerId = 0, 9 do
		local player = PlayerResource:GetPlayer(playerId)
		if player ~= nil then
			if player:GetAssignedHero() then
				if (player:GetTeam() == DOTA_TEAM_GOODGUYS) or (player:GetTeam() == DOTA_TEAM_BADGUYS) then
					MinimapEvent(
						player:GetTeam(),
						player:GetAssignedHero(),
						rndVectorPosition.x,
						rndVectorPosition.y,
						minimapEvent,
						5.0
					)
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция каста способности на цель(стан ЦК и т.д.)
]]
function DummyCastAbilityOnTarget(dummyAbilityNameToCast, teamName, eventName, donatorName)
	local allHeroes = HeroList:GetAllHeroes()
	for k, hero in pairs(allHeroes) do
		if hero:GetTeamNumber() == teamName or teamName == "allguys" then
			StartItemCooldown("item_sphere", hero)
			CreateDummyAtPositionAndCastAbilityOnTarget(dummyAbilityNameToCast, hero)
		end
	end
	ShowHud(eventName, donatorName, teamName)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция создания думика и каста способности на цель
]]
function CreateDummyAtPositionAndCastAbilityOnTarget(dummyAbilityNameToCast, hero)
	if IsServer() then
		local dummyCaster =
			CreateUnitByNameAsync(
			"npc_dota_dummy_caster",
			hero:GetOrigin(),
			false,
			nil,
			nil,
			DOTA_TEAM_CUSTOM_1,
			function(unit)
				local abilityToCast = unit:FindAbilityByName(dummyAbilityNameToCast)
				if abilityToCast == nil then
					abilityToCast = unit:AddAbility(dummyAbilityNameToCast)
					if dummyAbilityNameToCast == "doom_bringer_doom" then
						abilityToCast:SetLevel(1)
					else
						abilityToCast:SetLevel(4)
					end
					if abilityToCast == nil then
						print("ERROR! Ability is nil")
						return
					end
				end
				unit:AddItemByName("item_aether_lens_2")
				--Улучшаем способность(Аганим)
				if abilityToCast:GetLevel() < 1 then
					print("Ability was not upgraded")
					abilityToCast:UpgradeAbility(true)
				end
				----
				unit:SetContextThink(
					DoUniqueString("cast_ability"),
					function()
						abilityToCast:EndCooldown()
						unit:SetCursorCastTarget(hero)
						abilityToCast:OnSpellStart()
					end,
					0
				)
				----\

				unit:SetContextThink(
					DoUniqueString("Remove_Self"),
					function()
						print("unit removed")
						unit:RemoveSelf()
					end,
					30
				)
				return unit
			end
		)
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция старта кулдауна у предмета
]]
function StartItemCooldown(itemName, hero)
	for itemSlot = 0, 5 do
		local item = hero:GetItemInSlot(itemSlot)
		if item ~= nil then
			local searchedItemName = item:GetName()
			if searchedItemName == itemName then
				item:StartCooldown(item:GetCooldown(0))
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция каста бафа на цель(Крутилка джагера и т.д.)
]]
function CastBuffAbilities(abilityNameToActivate, teamName, eventName, donatorName)
	if IsServer() then
		local allHeroes = HeroList:GetAllHeroes()
		for k, hero in pairs(allHeroes) do
			if hero:GetTeamNumber() == teamName or teamName == "allguys" then
				local ability = hero:FindAbilityByName(abilityNameToActivate)
				local getPrevMana = hero:GetMana()

				if ability == nil then
					ability = hero:AddAbility(abilityNameToActivate)
					ability:SetLevel(3)
					hero:CastAbilityImmediately(ability, hero:GetPlayerOwnerID())
					hero:SetMana(getPrevMana)
					ability:SetActivated(false)
					ability:SetHidden(true)
					ability:EndCooldown()
				elseif ability ~= nil and ability:IsActivated() == false then
					hero:CastAbilityImmediately(ability, hero:GetPlayerOwnerID())
					hero:SetMana(getPrevMana)
					ability:EndCooldown()
				else
					local oldAbilityLvl = ability:GetLevel()
					ability:SetLevel(3)
					hero:CastAbilityImmediately(ability, hero:GetPlayerOwnerID())
					hero:SetMana(getPrevMana)
					ability:SetLevel(oldAbilityLvl)
					ability:EndCooldown()
				end
			end
		end
	end

	ShowHud(eventName, donatorName, teamName)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция для возрождения героя
]]
function RespawnHeroWhenDie(teamName, eventName, donatorName)
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:GetTeamNumber() == teamName or teamName == "allguys" then
			if hero:IsAlive() == false then
				hero:RespawnHero(false, false)
			end
		end
	end
	ShowHud(eventName, donatorName, teamName)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция для респавна героя(Тп на фонтан)
]]
function RespawnHeroWhenAlive(teamName, eventName, donatorName)
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		if hero:GetTeamNumber() == teamName or teamName == "allguys" then
			if hero:IsAlive() == true then
				local initialVector = Vector(0,0)
				if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
					initialVector = Vector(-6977, -6334)
				elseif hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
					initialVector = Vector(6782, 6271)
				end
				initialVector.z = GetGroundHeight(initialVector, nil)
				hero:SetAbsOrigin(initialVector) -- получили координаты, теперь меняем место героя на рандомную
				FindClearSpaceForUnit(hero, initialVector, false) --нужно чтобы герой не застрял
				hero:Stop() --приказываем ему остановиться, иначе он побежит назад к предыдущей точке
				ShowBlinkEffects(hero)
			end
		end
	end
	ShowHud(eventName, donatorName, teamName)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция для выдачи двух рапир рандомно
]]
function GiveTwoRapiers(eventName, donatorName, teamName)
	local heroes = HeroList:GetAllHeroes()
	local badTeamTable = {}
	local goodTeamTable = {}

	for _, hero in pairs(heroes) do
		if hero:IsRealHero() and hero:GetTeamNumber() == DOTA_TEAM_BADGUYS then
			table.insert(badTeamTable, hero)
		elseif hero:IsRealHero() and hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
			table.insert(goodTeamTable, hero)
		end
	end

	if #heroes ~= 1 then
		if teamName == DOTA_TEAM_BADGUYS then
			GetRandomElement(badTeamTable):AddItemByName("item_rapier")
		elseif teamName == DOTA_TEAM_GOODGUYS then
			GetRandomElement(goodTeamTable):AddItemByName("item_rapier")
		elseif teamName == "allguys" then
			GetRandomElement(badTeamTable):AddItemByName("item_rapier")
			GetRandomElement(goodTeamTable):AddItemByName("item_rapier")
		end
	else
		GetRandomElement(heroes):AddItemByName("item_rapier")
	end
	ShowHud(eventName, donatorName, teamName)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция включающая WTF на 60 секунд
]]
function EnableWTF(eventName, donatorName)
	if needToWTFCount == 0 then
		Wtf()
	end
	needToWTFCount = needToWTFCount + 1
	ShowHud(eventName, donatorName, nil)
	Timers:CreateTimer(
		60.0,
		function()
			needToWTFCount = needToWTFCount - 1
			if needToWTFCount == 0 then
				Wtf()
			end
			return nil
		end
	)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция призыва Босса
]]
function SpawnBoss(eventName, donatorName)
	local vectorToSpawn = Vector(1600, -1700, 0)
	ShowHud(eventName, donatorName, nil)
	PingOnMap(vectorToSpawn, DOTA_MINIMAP_EVENT_HINT_LOCATION)
	AddFOWViewer(DOTA_TEAM_GOODGUYS, vectorToSpawn, 500, 5, false)
	local unitBoss = CreateUnitByName("npc_neutral_boss", vectorToSpawn, true, nil, nil, DOTA_TEAM_NEUTRALS)
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция печати таблиц(Для инфо).
]]
function PrintTable(t, indent, done)
	if type(t) ~= "table" then
		return
	end

	done = done or {}
	done[t] = true
	indent = indent or 0

	local l = {}
	for k, v in pairs(t) do
		table.insert(l, k)
	end

	table.sort(l)
	for k, v in ipairs(l) do
		-- Игнорируем FDesc
		if v ~= "FDesc" then
			local value = t[v]

			if type(value) == "table" and not done[value] then
				done[value] = true
				print(string.rep("\t", indent) .. tostring(v) .. ":")
				PrintTable(value, indent + 2, done)
			elseif type(value) == "userdata" and not done[value] then
				done[value] = true
				print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
				PrintTable((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
			else
				if t.FDesc and t.FDesc[v] then
					print(string.rep("\t", indent) .. tostring(t.FDesc[v]))
				else
					print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция вывода на экран HUDа на 5 сек.
]]
function ShowHud(infoText, userText, team)
	local teamText = ""
	local descriptionSecond = ""
	if team == DOTA_TEAM_BADGUYS then
		descriptionSecond = "#dota2_description_on_side_message"
		teamText = "#dota2_description_dire_side"
	elseif team == DOTA_TEAM_GOODGUYS then
		descriptionSecond = "#dota2_description_on_side_message"
		teamText = "#dota2_description_radiant_side"
	elseif team == "allguys" then
		descriptionSecond = ""
		teamText = ""
	elseif team == nil then
		descriptionSecond = "#dota2_description_on_all_players_message"
		teamText = ""
	end

	CustomGameEventManager:Send_ServerToAllClients(
		"AddHudOnScreen",
		{Event = '#'..infoText, User = userText, Team = teamText, DescriptionSecond = descriptionSecond}
	)
	for _, hero in pairs(HeroList:GetAllHeroes()) do
		ScreenShake(hero:GetAbsOrigin(), 5, 150, 1, 2000, 0, true)
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция сброса Cooldown
]]
function ResetAllAbilitiesCooldown(unit)
	local abilities = unit:GetAbilityCount()
	for i = 0, abilities - 1 do
		local ability = unit:GetAbilityByIndex(i)
		if ability and not ability:IsCooldownReady() then
			ability:EndCooldown()
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функция WTF
]]
function Wtf()
	if WTF_MODE then
		WTF_MODE = false
	else
		WTF_MODE = true
	end
	local cmdPlayer = Convars:GetCommandClient()
	local PlayerCount = PlayerResource:GetPlayerCount() - 1
	if WTF_MODE then
		Timers:CreateTimer(
			function()
				for i = 0, PlayerCount do
					if PlayerResource:IsValidPlayer(i) then
						local player = PlayerResource:GetPlayer(i)
						local hero = player:GetAssignedHero()

						hero:GiveMana(10000)
						for i = 0, hero:GetAbilityCount() - 1 do
							if hero:GetAbilityByIndex(i) ~= nil then
								hero:GetAbilityByIndex(i):EndCooldown()
								hero:GetAbilityByIndex(i):RefreshCharges()
							end
						end
						for i = 0, 6 do
							if hero:GetItemInSlot(i) ~= nil then
								hero:GetItemInSlot(i):EndCooldown()
							end
						end
					end
				end
				if WTF_MODE then
					return 1
				else
					return nil
				end
			end
		)
	end
end

---------------------------------------------------------------------------------------------------------------------------
--[[[
Функции для тестирования
]]
function CAddonTemplateGameMode:OnChat(event)
	if useTestLinkApp == true then
		if event.text == "debug" then
			self:EzDebug()
		end
		if event.text == "reload" then
			self:ReloadScripts()
		end
		if event.text == "launch" then
			self:Launch()
		end
		if event.text == "givevision" then
			self:GiveAllVision()
		end
		if event.text == "deletevision" then
			self:DeleteAllVision()
		end
		if event.text == "test" then
			self:TestEventFromGame()
		end
		if event.text == "craxe" then
			self:CreateAxe()
		end
		if event.text == "wtf" then
			Wtf()
		end
	end
	if event.text == "spawnbots" then
		self:EnableBots()
	end
	if event.text == "ChangeLinkToApp" then
		if useTestLinkApp == false then
			useTestLinkApp = true
			GameRules:SendCustomMessage("Using test link server!", DOTA_TEAM_GOODGUYS, 0)
		else
			useTestLinkApp = false
			GameRules:SendCustomMessage("Using prod link server!", DOTA_TEAM_GOODGUYS, 0)
		end
	end
end

function CAddonTemplateGameMode:Launch()
	SendToServerConsole("dota_launch_custom_game bits_for_tricks dota")
end

function CAddonTemplateGameMode:CreateAxe()
	SendToServerConsole("dota_create_unit axe enemy")
end

function CAddonTemplateGameMode:ReloadScripts()
	SendToServerConsole("script_reload")
	SendToServerConsole("cl_script_reload")
end

function CAddonTemplateGameMode:GiveAllVision()
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(true)
end

function CAddonTemplateGameMode:DeleteAllVision()
	GameRules:GetGameModeEntity():SetFogOfWarDisabled(false)
end

function CAddonTemplateGameMode:EzDebug()
	SendToServerConsole("dota_dev hero_maxlevel")
	SendToServerConsole("dota_dev player_givegold 99999")

	SendToServerConsole("dota_create_item travel 2")
	SendToServerConsole("dota_create_item skadi")
	SendToServerConsole("dota_create_item rapier")
	SendToServerConsole("dota_create_item rapier")
	SendToServerConsole("dota_create_item heart")
	SendToServerConsole("dota_create_item manta")

	SendToServerConsole("dota_dev hero_teleport")

	SendToServerConsole("dota_spawn_creeps")
	SendToServerConsole("dota_spawn_neutrals")
	SendToServerConsole("dota_create_unit meepo enemy")
	SendToServerConsole("dota_bot_give_level 25")
	SendToServerConsole("dota_bot_give_item heart")
end

function CAddonTemplateGameMode:EnableBots()
	if IsServer() then
		SendToServerConsole("sv_cheats 1; dota_bot_populate")
		GameRules:GetGameModeEntity():SetBotsAlwaysPushWithHuman(false)
		GameRules:GetGameModeEntity():SetBotsInLateGame(false)
		GameRules:GetGameModeEntity():SetBotsMaxPushTier(4)
		GameRules:GetGameModeEntity():SetBotThinkingEnabled(true)

		Timers:CreateTimer(
			2,
			function()
				for _, hero in pairs(HeroList:GetAllHeroes()) do
					hero:SetBotDifficulty(4)
				end
			end
		)
	end
end

function CAddonTemplateGameMode:TestEventFromGame()
end
