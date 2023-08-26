module("exerciseData", package.seeall)

function get_exercise_info()
	return allTableData[dbTableDesList.user_exercise.name][userData.getUserId()]
end

--玩家数据获取
function get_exercise_id()
	return allTableData[dbTableDesList.user_exercise.name][userData.getUserId()].cur_exercise_id
end

function get_exercise_coordinate()
	return allTableData[dbTableDesList.user_exercise.name][userData.getUserId()].cur_coordinate
end

function get_exercise_count()
	local temp_exercise_info = get_exercise_info()
	if temp_exercise_info.exercise_count == 0 then
		if commonFunc.is_in_today(temp_exercise_info.last_refrsh_time) then
			return 0
		else
			return 1
		end
	else
		return temp_exercise_info.exercise_count
	end
end

function get_exercise_tips()
	local temp_exercise_id = get_exercise_id()
	return Tb_cfg_exercise[temp_exercise_id].exercise_tips
end

function get_exercise_name()
	local temp_exercise_id = get_exercise_id()
	return Tb_cfg_exercise[temp_exercise_id].exercise_name
end

function get_next_exercise_id()
	local temp_exercise_id = get_exercise_id()
	return Tb_cfg_exercise[temp_exercise_id].next_exercise_id
end

function get_exercise_fight_num()
	return allTableData[dbTableDesList.user_exercise.name][userData.getUserId()].cur_fight_count
end

function get_reward_rate_range()
	local fight_nums_list = {}
	local reward_rate_list = {}
	for k,v in pairs(EXERSICE_REWARD_RATIO) do
	 	if k%2 == 0 then
	 		table.insert(reward_rate_list, v)
	 	else
	 		table.insert(fight_nums_list, v)
	 	end
	end

	table.insert(reward_rate_list, 100)

	return fight_nums_list, reward_rate_list
end

function get_reward_rate_num()
	local temp_fight_nums = get_exercise_fight_num()
	if temp_fight_nums == 0 then
		return 0
	end

	local fight_nums_list, reward_rate_list = get_reward_rate_range()
	local reward_index = commonFunc.get_sequene_range_in_list(temp_fight_nums, fight_nums_list)
	return reward_rate_list[reward_index]/100
end

--获取部队指定位置武将
function get_hero_by_index(pos_index)
	local temp_exercise_info = get_exercise_info()
	if pos_index == 1 then
		return temp_exercise_info.base_heroid_u
	elseif pos_index == 2 then
		return temp_exercise_info.middle_heroid_u
	else
		return temp_exercise_info.front_heroid_u
	end
end

--是否已经有同样的卡牌(配置ID相同)在自己的部队中
function is_used_same_hero(hero_uid)
	local judge_cfg_id = heroData.getHeroOriginalId(hero_uid)
	local temp_hero_uid = nil
	local same_or_not = false
	for i=1,3 do
		temp_hero_uid = get_hero_by_index(i)
		if temp_hero_uid ~= 0 then
			if heroData.getHeroOriginalId(temp_hero_uid) == judge_cfg_id then
				same_or_not = true
				break
			end
		end
	end

	return same_or_not
end

--检测卡牌是否拖动到部队中
function is_used_hero(hero_uid)
	local is_in_army, temp_index = false, 0
	local temp_hero_uid = nil
	for i=1,3 do
		temp_hero_uid = get_hero_by_index(i)
		if temp_hero_uid == hero_uid then
			is_in_army = true
			temp_index = i
			break
		end
	end

	return is_in_army, temp_index
end

function get_sum_cost_in_exercise()
	local hero_uid = nil
	local show_cost_nums = 0
	for i=1,3 do
		hero_uid = get_hero_by_index(i)
		if hero_uid ~= 0 then
			show_cost_nums = show_cost_nums + heroData.getHeroCost(hero_uid)
		end
	end
	
	local temp_exercise_id = get_exercise_id()
	return show_cost_nums, Tb_cfg_exercise[temp_exercise_id].army_cost/10
end

function get_hero_nums_in_army()
	local hero_uid = nil
	local result_num = 0
	for i=1,3 do
		hero_uid = get_hero_by_index(i)
		if hero_uid ~= 0 then
			result_num = result_num + 1
		end
	end

	return result_num
end

--配置表数据获取
--是否是教学演武
function is_teach_type()
	local temp_exercise_id = get_exercise_id()
	return Tb_cfg_exercise[temp_exercise_id].exercise_type == 0
end

--获取教学演武的总轮数
function get_teach_nums()
	local result_num = 0
	for k,v in pairs(Tb_cfg_exercise) do
		if v.exercise_type == 0 then
			result_num = result_num + 1
		end
	end

	return result_num
end

--获取演武是不是需要特殊显示（针对教学演武）
function get_exercise_special_state(temp_cfg_id)
	return Tb_cfg_exercise[temp_cfg_id].special_reward == 1
end

--获取当前演武的阶段数（针对教学演武）
function get_teach_phase()
	return get_exercise_id() - 10
end

--获取当前演武进度状态(是否已经完成)
function get_exercise_reward_state()
	local temp_reward_state = allTableData[dbTableDesList.user_exercise.name][userData.getUserId()].exercise_reward_state
	return temp_reward_state == 2
end

function get_exercise_reward_list()
	local temp_reward_info = allTableData[dbTableDesList.user_exercise.name][userData.getUserId()].exercise_reward
	return stringFunc.anlayerMsg(temp_reward_info)
end

function get_reward_list_by_exercise_id(temp_exercise_id)
	local temp_drop_id = (EXERSICE_DROP + temp_exercise_id) * 100 + 1
	return Tb_cfg_battle_drop[temp_drop_id].drops
end

function get_exercise_des_info(exercise_id)
	return Tb_cfg_exercise[exercise_id].exercise_desc
end

function get_exercise_win_condition()
	local temp_exercise_id = get_exercise_id()
	local temp_win_info = Tb_cfg_exercise[temp_exercise_id].win_condition
	return stringFunc.anlayerMsg(temp_win_info)
end

--是否处于CD期间
function get_cd_leave_time()
	local temp_time_num = allTableData[dbTableDesList.user_exercise.name][userData.getUserId()].next_time
	return temp_time_num - userData.getServerTime()
end

--获取已经打过的演武列表
function get_exercise_difficult()
	local temp_history_info = allTableData[dbTableDesList.user_exercise.name][userData.getUserId()].exercise_history
	local temp_history_list = stringFunc.anlayerMsg(temp_history_info)

	local temp_difficult_lv = 0
	local temp_history_lv = nil
	for k,v in pairs(temp_history_list) do
		temp_history_lv = v[1]
		if temp_history_lv >= 1 and temp_history_lv <= 4 then
			if temp_history_lv > temp_difficult_lv then
				temp_difficult_lv = temp_history_lv
			end
		end
	end

	return temp_difficult_lv
end

--[[
	教学模式：1 可以开始下一轮；2 没有打完该轮演武；3 处于CD中
	自由模式：10 打完该轮没有次数了；11 打完该轮有次数；12 没有打完该轮没有次数了；13 没有打完该轮有次数
--]]
function get_next_btn_show_type()
	if is_teach_type() then
		if get_exercise_reward_state() then
			if exerciseData.get_cd_leave_time() > 0 then
				return 3
			else
				return 1
			end
		else
			return 2
		end
	else
		if get_exercise_reward_state() then
			if exerciseData.get_exercise_count() == 0 then
				return 10
			else
				return 11
			end
		else
			if exerciseData.get_exercise_count() == 0 then
				return 12
			else
				return 13
			end
		end
	end
end


--获取地图格子基础样式
function get_born_pos()
	return Tb_cfg_exercise[get_exercise_id()].born_coordinate
end

function get_exercise_land_info(land_index)
	local land_id = userData.getUserId() * 100 + land_index
	return allTableData[dbTableDesList.user_exercise_land.name][land_id]
end

function get_exercise_land_reward(land_index)
	local temp_land_info = get_exercise_land_info(land_index)
	local temp_reward_info = temp_land_info.reward
	return stringFunc.anlayerMsg(temp_reward_info)
end

function get_exercise_land_army_id(land_index)
	local temp_land_info = get_exercise_land_info(land_index)
	return temp_land_info.army_id
end

function get_exercise_land_army_type(land_index)
	local temp_land_info = get_exercise_land_info(land_index)
	local temp_type = temp_land_info.hero_type

	local front_type = temp_type%10
	local middle_type = (math.floor(temp_type/10))%10
	local base_type = math.floor(temp_type/100)

	return base_type, middle_type, front_type
end

--地块是否被攻打下，在调用前应该已经判断过该地块一定要有部队
function is_land_finished(land_index)
	local temp_land_info = get_exercise_land_info(land_index)
	local temp_type = temp_land_info.land_type
	return temp_type == 3 or temp_type == 4
end

function is_city_land(land_index)
	local temp_land_info = get_exercise_land_info(land_index)
	local temp_type = temp_land_info.land_type
	return temp_type == 2 or temp_type == 4
end

function get_land_all_durability(land_index)
	local temp_army_cfg_info = get_exercise_army_cfg_info(land_index)
	return temp_army_cfg_info.durability
end

function get_land_durability(land_index)
	local temp_land_info = get_exercise_land_info(land_index)
	return temp_land_info.durability
end

function is_land_can_attack(land_pos_x, land_pos_y, map_line, map_column)
	local land_index = (land_pos_y - 1) * map_column + land_pos_x
	local temp_army_id = get_exercise_land_army_id(land_index)
	if temp_army_id == 0 then
		return -1
	end

	if is_land_finished(land_index) then
		return -2
	end

	if get_born_pos() == land_index then
		return 0
	end

	local offset_list = {{-1, -1}, {-1, 0}, {-1, 1}, {0, 1}, {1, 1}, {1, 0}, {1, -1}, {0, -1}}
	for k,v in pairs(offset_list) do
		local temp_x = land_pos_x + v[1]
		local temp_y = land_pos_y + v[2]
		if temp_x >=1 and temp_x <= map_column and temp_y >=1 and temp_y <= map_line then
			local new_index = (temp_y - 1) * map_column + temp_x
			local new_army_id = get_exercise_land_army_id(new_index)
			if new_army_id ~= 0 and is_land_finished(new_index) then
				return 0
			end
		end
	end

	return -3
end

function get_exercise_army_cfg_info(land_index)
	local temp_army_cfg_id = get_exercise_id() * 100 + land_index
	return Tb_cfg_exercise_army[temp_army_cfg_id]
end

function get_exercise_cfg_hero_hp(land_index, hero_index)
	local temp_army_cfg_info = get_exercise_army_cfg_info(land_index)
	if hero_index == 1 then
		return temp_army_cfg_info.base_hero_hp
	elseif hero_index == 2 then
		return temp_army_cfg_info.middle_hero_hp
	elseif hero_index == 3 then
		return temp_army_cfg_info.front_hero_hp
	else
		return 0
	end
end

--获取部队类型
function get_exercise_army_type(land_index)
	local temp_army_cfg_id = get_exercise_id() * 100 + land_index
	return Tb_cfg_exercise_army[temp_army_cfg_id].army_type
end

function get_exercise_army_condition(land_index)
	local temp_base_hp = get_exercise_cfg_hero_hp(land_index, 1)
	local temp_middle_hp = get_exercise_cfg_hero_hp(land_index, 2)
	local temp_front_hp = get_exercise_cfg_hero_hp(land_index, 3)

	local temp_hero_nums = 0
	if temp_base_hp ~= 0 then
		temp_hero_nums = temp_hero_nums + 1
	end
	if temp_middle_hp ~= 0 then
		temp_hero_nums = temp_hero_nums + 1
	end
	if temp_front_hp ~= 0 then
		temp_hero_nums = temp_hero_nums + 1
	end

	return temp_hero_nums, temp_base_hp
end

--演武战绩相关
function get_exercise_record_sum_info()
	local temp_exercise_info = get_exercise_info()
	local temp_diff_list = nil
	if temp_exercise_info.exercise_statistic == "" then
		temp_diff_list = {}
	else
		temp_diff_list = stringFunc.anlayerMsg(temp_exercise_info.exercise_statistic)
	end

	return temp_exercise_info.exercise_total, temp_exercise_info.win_count, temp_diff_list
end

function get_exercise_record_army_list()
	local temp_army_list = {}
	for k,v in pairs(allTableData[dbTableDesList.user_exercise_record.name]) do
		table.insert(temp_army_list, k)
	end

	table.sort(temp_army_list)
	return temp_army_list
end

function get_exercise_record_army_info(temp_id)
	return allTableData[dbTableDesList.user_exercise_record.name][temp_id]
end