local function getAllHero()
	return allTableData[dbTableDesList.hero.name]
end

--获取拥有卡牌的总数
local function getHeroNums()
	local result_num = 0
	for k,v in pairs(allTableData[dbTableDesList.hero.name]) do
		result_num = result_num + 1
	end

	return result_num
end

local function getHeroInfo(hero_uid)
	local temp_hero_info = allTableData[dbTableDesList.hero.name][hero_uid]
	if temp_hero_info then
		return temp_hero_info
	else
		return heroDataOthers.getHeroInfo(hero_uid)
		-- return false
	end
end

local function getHeroOriginalId(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		return hero_info.heroid
	else
		return 0
	end
end

local function get_hero_country(hero_uid)
	local hero_id = getHeroOriginalId(hero_uid)
	if hero_id == 0 then
		return 0
	else
		return Tb_cfg_hero[hero_id].country 
	end
end

local function get_hero_type(hero_uid)
	local hero_id = getHeroOriginalId(hero_uid)
	if hero_id == 0 then
		return 0
	else
		return Tb_cfg_hero[hero_id].hero_type
	end
end

local function getHeroCost(hero_uid)
	local hero_id = getHeroOriginalId(hero_uid)
	if hero_id == 0 then
		return 0
	else
		return Tb_cfg_hero[hero_id].cost/10
	end
end

local function getHeroName(hero_uid)
	local hero_id = getHeroOriginalId(hero_uid)
	if hero_id == 0 then
		return " "
	else
		return Tb_cfg_hero[hero_id].name
	end
end

local function getHeroArmyId(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		return hero_info.armyid
	else
		return 0
	end
end

local function getHeroMaxHp(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		local own_city_id = math.floor(hero_info.armyid/10)
	    local by_level = politics.getBuildLevel(own_city_id, cityBuildDefine.bingying)
	    if by_level ~= 0 then
	        return hero_info.level * 100 + Tb_cfg_build_cost[cityBuildDefine.bingying*100 + by_level].effect[1][2]
	    else
	    	return hero_info.level * 100
	    end
	else
		return 0
	end
end

local function getHeroHp(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		return hero_info.hp
	else
		return 0
	end
end

local function isFullHp(hero_uid)
	return getHeroMaxHp(hero_uid) == getHeroHp(hero_uid)
end

local function getHeroSpeed(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		local basic_hero_info = Tb_cfg_hero[hero_info.heroid]
		return basic_hero_info.speed_base + hero_info.speed_add
	else
		return 0
	end
end

local function getHeroDestroy(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		local basic_hero_info = Tb_cfg_hero[hero_info.heroid]
		return basic_hero_info.destroy_base + hero_info.destroy_add
	else
		return 0
	end
end

local function getHeroEnergy(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		local current_energy = hero_info.energy + math.floor(userData.getIntervalData(hero_info.energy_time,1,hero_info.energy_add))
		if current_energy > HERO_ENERGY_MAX then
			current_energy = HERO_ENERGY_MAX
		end
		return current_energy
	else
		return 0
	end
end

local function getHeroZbState(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		return hero_info.state == cardState.zhengbing
	else
		return false
	end
end

local function getHeroHurtState(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		return hero_info.hurt_end_time ~= 0
	else
		return false
	end
end

local function getHeroNoenergyState(hero_uid)
	return getHeroEnergy(hero_uid) < userData.getHeroEneryMoveNeed()
end

local function get_name_conent_for_hero_list(hero_list)
	local result = ""
	for i,v in ipairs(hero_list) do
		local hero_id = getHeroOriginalId(v)
		if i == 1 then
			result = Tb_cfg_hero[hero_id].name
		else
			result = result .. "," .. Tb_cfg_hero[hero_id].name
		end
	end

	return result
end



local function getHeroSkillList(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if hero_info then
		return stringFunc.anlayerMsg(hero_info.skill)
	else
		return nil
	end
end

local function is_hero_can_move(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if not hero_info then
		return false
	end

	if hero_info.armyid == 0 then
		return false
	end

	local current_energy = getHeroEnergy(hero_uid)
	if current_energy < userData.getHeroEneryMoveNeed() then
		return false
	end

	if hero_info.hp_end_time ~= 0 and hero_info.hp_end_time > userData.getServerTime() then
		return false
	end

	if hero_info.hurt_end_time ~= 0 then
		return false
	end

	return true
end

--办公室中卡牌需要显示的状态
local function get_hero_state_in_office(hero_uid, current_city_id)
	local hero_info = getHeroInfo(hero_uid)
	if not hero_info then
		return 0
	end

	if hero_info.armyid ~= 0 then
		return heroStateDefine.inarmy
	end	

	if getHeroEnergy(hero_uid) < userData.getHeroEneryMoveNeed() then
		return heroStateDefine.no_energy
	end

	if hero_info.hurt_end_time ~= 0 then
		return heroStateDefine.hurted
	end
	
	return 0
end

-- 获取武将满足恢复到满足出征的体力所需的时间
local function get_hero_energy_moveAble_timeLeft(hero_uid)
	local current_energy = getHeroEnergy(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if current_energy < userData.getHeroEneryMoveNeed() then
		return math.floor( (userData.getHeroEneryMoveNeed() - current_energy) / hero_info.energy_add )
	else
		return 0
	end
end
--部队中的卡牌需要显示的武将状态
local function get_hero_state_in_army(hero_uid)
	local hero_info = getHeroInfo(hero_uid)
	if not hero_info then
		return 0
	end
	local team_info = armyData.getTeamMsg(hero_info.armyid)
	if not team_info then
		return 0
	end

	if team_info.state == armyState.normal or team_info.state == armyState.zhuzhaed then
		if hero_info.hp_end_time ~= 0 and hero_info.hp_end_time > userData.getServerTime() then
			return heroStateDefine.zengbing
		end
	end

	if getHeroEnergy(hero_uid) < userData.getHeroEneryMoveNeed() then
		return heroStateDefine.no_energy
	end

	if hero_info.hurt_end_time ~= 0 then
		return heroStateDefine.hurted
	end

	return 0
end


-- 基础武将属性等级

--武将属性=基础值+（等级-1）*成长率
local function get_basic_prop_info_by_lv(hero_id,prop_index,lv)
	local basic_hero_info = Tb_cfg_hero[hero_id]
	if not basic_hero_info then
		return 0
	end

	local show_value = 0
	if prop_index == heroPorpDefine.attack then
		show_value = basic_hero_info.attack_base + (lv - 1) * basic_hero_info.attack_grow
	elseif prop_index == heroPorpDefine.defence then
		show_value = basic_hero_info.defence_base + (lv - 1) * basic_hero_info.defence_grow
	elseif prop_index == heroPorpDefine.intel then
		show_value = basic_hero_info.intel_base + (lv - 1) * basic_hero_info.intel_grow
	elseif prop_index == heroPorpDefine.speed then
		show_value = basic_hero_info.speed_base + (lv - 1) * basic_hero_info.speed_grow
	elseif prop_index == heroPorpDefine.destroy then
		show_value = basic_hero_info.destroy_base + (lv - 1) * basic_hero_info.destroy_grow
	elseif prop_index == heroPorpDefine.hit then
		show_value = basic_hero_info.hit_range + (lv - 1) * basic_hero_info.attack_grow
	end
	if prop_index ~= heroPorpDefine.hit then
		show_value = show_value/100
	end

	show_value = math.floor(show_value)
	return show_value
end



local function get_basic_prop_info(hero_uid, hero_id, prop_index)
	local basic_hero_info = Tb_cfg_hero[hero_id]
	if not basic_hero_info then
		return 0
	end

	local hero_info = getHeroInfo(hero_uid)

	local show_value = 0
	if prop_index == heroPorpDefine.attack then
		if hero_info then
			show_value = basic_hero_info.attack_base + hero_info.attack_add
		else
			show_value = basic_hero_info.attack_base
		end
	elseif prop_index == heroPorpDefine.defence then
		if hero_info then
			show_value = basic_hero_info.defence_base + hero_info.defence_add
		else
			show_value = basic_hero_info.defence_base
		end
	elseif prop_index == heroPorpDefine.intel then
		if hero_info then
			show_value = basic_hero_info.intel_base + hero_info.intel_add
		else
			show_value = basic_hero_info.intel_base
		end
	elseif prop_index == heroPorpDefine.speed then
		if hero_info then
			show_value = basic_hero_info.speed_base + hero_info.speed_add
		else
			show_value = basic_hero_info.speed_base
		end
	elseif prop_index == heroPorpDefine.destroy then
		if hero_info then
			show_value = basic_hero_info.destroy_base + hero_info.destroy_add
		else
			show_value = basic_hero_info.destroy_base
		end
	elseif prop_index == heroPorpDefine.hit then
		show_value = basic_hero_info.hit_range
	end
	
	if prop_index ~= heroPorpDefine.hit then
		show_value = show_value/100
	end

	return show_value
end

local function getSoldierConvertNums(soldier_nums)
	-- if soldier_nums >= 2000 and soldier_nums <= 3999 then
	-- 	return (soldier_nums - 2000)/2 + 2000
	-- end

	-- if soldier_nums >= 4000 and soldier_nums <= 5999 then
	-- 	return (soldier_nums - 4000)/3 + 3000
	-- end

	-- if soldier_nums >= 6000 and soldier_nums <= 9999 then
	-- 	return (soldier_nums - 6000)/4 + 3666
	-- end

	-- if soldier_nums >= 10000 and soldier_nums <= 19999 then
	-- 	return (soldier_nums - 10000)/10 + 4666
	-- end

	-- if soldier_nums >= 20000 and soldier_nums <= 49999 then
	-- 	return (soldier_nums - 20000)/50 + 5666
	-- end

	-- if soldier_nums >= 50000 and soldier_nums <= 299999 then
	-- 	return (soldier_nums - 50000)/100 + 6266
	-- end

	-- if soldier_nums >= 300000 then
	-- 	return 7765
	-- end

	return BATTLE_HP_DISCOUNT_PARAM[1] * soldier_nums / (soldier_nums + BATTLE_HP_DISCOUNT_PARAM[2])
end

local function getHeroFightPower(hero_uid)
	local hero_id = getHeroOriginalId(hero_uid)
	local attack_value = get_basic_prop_info(hero_uid, hero_id, heroPorpDefine.attack)
	local defence_value = get_basic_prop_info(hero_uid, hero_id, heroPorpDefine.defence)
	local intel_value = get_basic_prop_info(hero_uid, hero_id, heroPorpDefine.intel)
	local bwh_value = (attack_value + defence_value + intel_value) * fightPowerParam.bwh_xs

	local hit_value = get_basic_prop_info(hero_uid, hero_id, heroPorpDefine.hit)
	local speed_value = get_basic_prop_info(hero_uid, hero_id, heroPorpDefine.speed)
	local fuzhu_value = hit_value * fightPowerParam.dis_xs + speed_value * fightPowerParam.speed_xs
	
	local hp_value = getHeroHp(hero_uid)
	local soldier_value = getSoldierConvertNums(hp_value) * fightPowerParam.soldier_xs

	local skill_value = 0
	local hero_skill_list = getHeroSkillList(hero_uid)
	for k,v in pairs(hero_skill_list) do
		local skill_id = v[1]
		local skill_level = v[2]
		if skill_id ~= 0 then
			local skill_quality = Tb_cfg_skill[skill_id].skill_quality
			skill_value = skill_value + skill_quality * skillQualityParam[skill_quality][1] + skill_level * skillQualityParam[skill_quality][2]
		end
	end

	local result_value = bwh_value + fuzhu_value + soldier_value + skill_value
	return result_value
end


-- 武将是否已经配点
local function isHeroAllocatedPoint(hero_uid)
	local hero_info = heroData.getHeroInfo(hero_uid)
	if not hero_info then return false end
	
	local basic_hero_info = Tb_cfg_hero[hero_info.heroid]
    local growup_num, had_add_num, show_value = 0
    for i=1,4 do
        if i == heroPorpDefine.attack then
            growup_num = basic_hero_info.attack_grow
            had_add_num = hero_info.attack_add - (hero_info.level - 1) * growup_num
        elseif i == heroPorpDefine.defence then
            growup_num = basic_hero_info.defence_grow
            had_add_num = hero_info.defence_add - (hero_info.level - 1) * growup_num
        elseif i == heroPorpDefine.intel then
            growup_num = basic_hero_info.intel_grow
            had_add_num = hero_info.intel_add - (hero_info.level - 1) * growup_num
        elseif i == heroPorpDefine.speed then
            growup_num = basic_hero_info.speed_grow
            had_add_num = hero_info.speed_add - (hero_info.level - 1) * growup_num
		end
		if had_add_num > 0 then return true end    
    end
	
	return false
end
heroData = {
			getAllHero = getAllHero,
			getHeroNums = getHeroNums,
			getHeroInfo = getHeroInfo,
			getHeroOriginalId = getHeroOriginalId,
			get_hero_country = get_hero_country,
			get_hero_type = get_hero_type,
			getHeroName = getHeroName,
			getHeroCost = getHeroCost,
			get_name_conent_for_hero_list = get_name_conent_for_hero_list,
			getHeroHp = getHeroHp,
			getHeroMaxHp = getHeroMaxHp,
			isFullHp = isFullHp,
			getHeroSpeed = getHeroSpeed,
			getHeroDestroy = getHeroDestroy,
			getHeroEnergy = getHeroEnergy,
			getHeroArmyId = getHeroArmyId,
			getHeroZbState = getHeroZbState,
			getHeroHurtState = getHeroHurtState,
			getHeroNoenergyState = getHeroNoenergyState,
			get_hero_state_in_army = get_hero_state_in_army,
			get_hero_state_in_office = get_hero_state_in_office,
			getHeroSkillList = getHeroSkillList,
			getHeroFightPower = getHeroFightPower,
			get_basic_prop_info = get_basic_prop_info,
			get_basic_prop_info_by_lv = get_basic_prop_info_by_lv,
			is_hero_can_move = is_hero_can_move,
			get_hero_energy_moveAble_timeLeft = get_hero_energy_moveAble_timeLeft,
			isHeroAllocatedPoint = isHeroAllocatedPoint,
}
