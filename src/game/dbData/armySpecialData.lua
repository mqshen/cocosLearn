--兵种加成判断 返回为兵种类型以及改兵种的个数（只限制在有生效的前提下，不然都返回0， 0）
local function get_team_arms_distribution(base_hero_uid, middle_hero_uid, front_hero_uid)
	if base_hero_uid == 0 and middle_hero_uid == 0 and front_hero_uid == 0 then
		return 0, nil
	end
	
	local arms_list = {}
	arms_list[heroType.archer] = {}
	arms_list[heroType.spearman] = {}
	arms_list[heroType.sowar] = {}

	local temp_type = heroData.get_hero_type(base_hero_uid)
	if temp_type ~= 0 then
		table.insert(arms_list[temp_type], base_hero_uid)
	end

	temp_type = heroData.get_hero_type(middle_hero_uid)
	if temp_type ~= 0 then
		table.insert(arms_list[temp_type], middle_hero_uid)
	end

	temp_type = heroData.get_hero_type(front_hero_uid)
	if temp_type ~= 0 then
		table.insert(arms_list[temp_type], front_hero_uid)
	end

	for k,v in pairs(arms_list) do
		if #v >= 2 then
			return k, v
		end
	end

	return 0, nil
end

local function get_arms_addition_by_heros(base_hero_uid, middle_hero_uid, front_hero_uid)
	local new_type, hero_list = get_team_arms_distribution(base_hero_uid, middle_hero_uid, front_hero_uid)
	if new_type == 0 then
		return new_type, nil, nil
	end

	local new_num = #hero_list
	local skill_id = 0
	if new_type == heroType.archer then
		if new_num == 2 then
			skill_id = BU_DUI_GONG_2
		else
			skill_id = BU_DUI_GONG_3
		end
	elseif new_type == heroType.spearman then
		if new_num == 2 then
			skill_id = BU_DUI_QIANG_2
		else
			skill_id = BU_DUI_QIANG_3
		end
	elseif new_type == heroType.sowar then
		if new_num == 2 then
			skill_id = BU_DUI_QI_2
		else
			skill_id = BU_DUI_QI_3
		end
	end

	local des_list = skillData.get_skill_effect(skill_id, 1, 0, 0)
	local hero_content = heroData.get_name_conent_for_hero_list(hero_list)
	return new_type, des_list, hero_content
end

local function get_arms_addition_by_team(team_id)
	local temp_army_info = armyData.getTeamMsg(team_id)
	if not temp_army_info then
		return 0, nil, nil
	end

	local base_hero_uid = temp_army_info.base_heroid_u
	local middle_hero_uid = temp_army_info.middle_heroid_u
	local front_hero_uid = temp_army_info.front_heroid_u

	return get_arms_addition_by_heros(base_hero_uid, middle_hero_uid, front_hero_uid)
end

--阵营加成判断 返回为阵营类型以及改阵营的个数（只限制在有生效的前提下，不然都返回0， 0）
local function get_team_camp_distribution(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)
	if base_hero_uid == 0 and middle_hero_uid == 0 and front_hero_uid == 0 then
		return 0, nil, nil
	end

	local camp_num_list = {}
	camp_num_list[countryType.han] = {}
	camp_num_list[countryType.wei] = {}
	camp_num_list[countryType.shu] = {}
	camp_num_list[countryType.wu] = {}
	camp_num_list[countryType.qun] = {}

	local temp_type = heroData.get_hero_country(base_hero_uid)
	if temp_type ~= 0 then
		table.insert(camp_num_list[temp_type], base_hero_uid)
	end

	temp_type = heroData.get_hero_country(middle_hero_uid)
	if temp_type ~= 0 then
		table.insert(camp_num_list[temp_type], middle_hero_uid)
	end

	temp_type = heroData.get_hero_country(front_hero_uid)
	if temp_type ~= 0 then
		table.insert(camp_num_list[temp_type], front_hero_uid)
	end

	for k,v in pairs(camp_num_list) do
		if #v >= 2 then
			local country_dian_level = politics.getBuildLevel(temp_city_id, cityBuildDefine.handian + k - 1)
			if country_dian_level > 0 then
				return k, v, country_dian_level
			end
		end
	end

	return 0, nil, nil
end

local function get_camp_addition_by_heros(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)
	local new_type, hero_list, country_dian_level = get_team_camp_distribution(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)
	if new_type == 0 then
		return new_type, nil, nil
	end
	
	local build_type = cityBuildDefine.handian + new_type - 1
	local skill_id = Tb_cfg_build_cost[build_type*100 + country_dian_level].effect[1][2]

	local base_num = 0
	if #hero_list == 2 then
		base_num = GUO_JIA_JIA_CHENG_2
	else
		base_num = GUO_JIA_JIA_CHENG_3
	end
	local des_list = skillData.get_skill_effect(skill_id, 1, 0, base_num)
	local hero_content = heroData.get_name_conent_for_hero_list(hero_list)
	return new_type, des_list, hero_content
end

local function get_camp_addition_by_team(team_id)
	local temp_army_info = armyData.getTeamMsg(team_id)
	if not temp_army_info then
		return 0, nil, nil
	end

	local temp_city_id = math.floor(team_id/10)
	local base_hero_uid = temp_army_info.base_heroid_u
	local middle_hero_uid = temp_army_info.middle_heroid_u
	local front_hero_uid = temp_army_info.front_heroid_u
	return get_camp_addition_by_heros(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)
end

--武将组合加成
local function get_team_title_id(base_hero_uid, middle_hero_uid, front_hero_uid)
	if base_hero_uid == 0 and middle_hero_uid == 0 and front_hero_uid == 0 then
		return 0, nil
	end

	local hero_id_list = {}
	table.insert(hero_id_list, heroData.getHeroOriginalId(base_hero_uid))
	table.insert(hero_id_list, heroData.getHeroOriginalId(middle_hero_uid))
	table.insert(hero_id_list, heroData.getHeroOriginalId(front_hero_uid))
	table.sort(hero_id_list)
	
	local s_index = hero_id_list[1] .. hero_id_list[2] .. hero_id_list[3]
	if armyTitleList[s_index] then
		local hero_list = {}
		if base_hero_uid ~= 0 then
			table.insert(hero_list, base_hero_uid)
		end

		if middle_hero_uid ~= 0 then
			table.insert(hero_list, middle_hero_uid)
		end

		if front_hero_uid ~= 0 then
			table.insert(hero_list, front_hero_uid)
		end

		return armyTitleList[s_index], hero_list
	else
		return 0, nil
	end
end

local function get_group_addition_by_heros(base_hero_uid, middle_hero_uid, front_hero_uid)
	local title_id, hero_list = get_team_title_id(base_hero_uid, middle_hero_uid, front_hero_uid)
	if title_id == 0 then
		return 0, nil, nil
	end

	local des_list = skillData.get_skill_effect(Tb_cfg_army_title[title_id].skill_id, 1, 0, 0)
	local hero_content = heroData.get_name_conent_for_hero_list(hero_list)
	return title_id, des_list, hero_content
end

local function get_group_addition_by_team(team_id)
	local temp_army_info = armyData.getTeamMsg(team_id)
	if not temp_army_info then
		return 0, nil, nil
	end

	local base_hero_uid = temp_army_info.base_heroid_u
	local middle_hero_uid = temp_army_info.middle_heroid_u
	local front_hero_uid = temp_army_info.front_heroid_u
	return get_group_addition_by_heros(base_hero_uid, middle_hero_uid, front_hero_uid)
end

local function get_addition_state_by_heros(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)
	local arms_state, group_state = true, true

	local arms_type = get_team_arms_distribution(base_hero_uid, middle_hero_uid, front_hero_uid)
	if arms_type == 0 then
		arms_state = false
	end

	local camp_type = get_team_camp_distribution(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)

	local title_id = get_team_title_id(base_hero_uid, middle_hero_uid, front_hero_uid)
	if title_id == 0 then
		group_state = false
	end

	return arms_state, camp_type, group_state
end

--部队中各个加成是否存在的判断
local function get_addition_state_by_team(team_id)
	local temp_army_info = armyData.getTeamMsg(team_id)
	if not temp_army_info then
		return false, false, false
	end

	local temp_city_id = math.floor(team_id/10)
	local base_hero_uid = temp_army_info.base_heroid_u
	local middle_hero_uid = temp_army_info.middle_heroid_u
	local front_hero_uid = temp_army_info.front_heroid_u
	return get_addition_state_by_heros(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)
end

local function get_army_state_name(army_state, is_enemy)
	if army_state == armyState.normal then
		return languagePack["daiming"]
	elseif army_state == armyState.chuzhenging then
		if is_enemy then
			return languagePack["dixi"]
		else
			return languagePack["chuzheng"]
		end
	elseif army_state == armyState.zhuzhaing then
		return languagePack["zhuzha"]
	elseif army_state == armyState.decreed then
		return languagePack["tuntian"]
	elseif army_state == armyState.yuanjuning then
		return languagePack["zhushou"]
	elseif army_state == armyState.returning then
		return languagePack["fanhui"]
	elseif army_state == armyState.zhuzhaed then
		return languagePack["zhuzha"]
	elseif army_state == armyState.yuanjuned then
		return languagePack["zhushou"]
	elseif army_state == armyState.sleeped then
		return languagePack["zhanjianxiuxi"]
	end

	return " "
end

armySpecialData = {
					get_arms_addition_by_team = get_arms_addition_by_team,
					get_arms_addition_by_heros = get_arms_addition_by_heros,
					get_camp_addition_by_team = get_camp_addition_by_team,
					get_camp_addition_by_heros = get_camp_addition_by_heros,
					get_group_addition_by_team = get_group_addition_by_team,
					get_group_addition_by_heros = get_group_addition_by_heros,
					get_addition_state_by_team = get_addition_state_by_team,
					get_addition_state_by_heros = get_addition_state_by_heros,
					get_army_state_name = get_army_state_name
}