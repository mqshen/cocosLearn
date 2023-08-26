local function request_land_army(temp_army_id, open_type)
	Net.send(EXERCISE_GET_ARMY_INFO,{temp_army_id, open_type})
end

local function request_next_land(land_index)
	Net.send(EXERCISE_NEXT_ARMY, {land_index})
end

local function receive_land_army(package)
	heroDataOthers.cacheArmyHeroListOfExercise(package[2])
	if package[1] == 0 then
		if exerciseEnemyManager then
			exerciseEnemyManager.create(package[2])
		end
	else
		if exerciseRecordEnemyManager then
			exerciseRecordEnemyManager.create(package[2])
		end
	end
	
	-- heroDataOthers.testShow()
end

local function request_switch_hero(Pos1, Pos2 )
	Net.send(EXERCISE_SWITCH_HERO, {Pos1, Pos2})
end

local function request_remove_hero(pos)
	Net.send(EXERCISE_REMOVE_HERO, {pos})
end

local function request_add_hero(hero_uid, target_pos)
	Net.send(EXERCISE_ADD_HERO, {hero_uid, target_pos})
end

local function request_fight()
	Net.send(EXERCISE_FIGHT, {})
end

local function receive_fight_result(package)
	if exerciseWholeManager then
		exerciseWholeManager.deal_with_fight_finish(package)
	end
end

local function request_next_exercise(next_id)
	Net.send(EXERCISE_NEXT, {next_id})
end

local function receive_next_exercise(package)
	if exerciseWholeManager then
		exerciseWholeManager.start_new_exercise()
	end
end

local function create()
	netObserver.addObserver(EXERCISE_GET_ARMY_INFO, receive_land_army)
	netObserver.addObserver(EXERCISE_FIGHT, receive_fight_result)
	netObserver.addObserver(EXERCISE_NEXT, receive_next_exercise)
end

local function remove()
	netObserver.removeObserver(EXERCISE_GET_ARMY_INFO)
	netObserver.removeObserver(EXERCISE_FIGHT)
	netObserver.removeObserver(EXERCISE_NEXT)
end

exerciseOpRequest = {
						create = create,
						remove = remove,
						request_land_army = request_land_army,
						request_next_land = request_next_land,
						request_add_hero = request_add_hero,
						request_remove_hero = request_remove_hero,
						request_switch_hero = request_switch_hero,
						request_fight = request_fight,
						request_next_exercise = request_next_exercise
}