module("worldProData", package.seeall)
worldProContentType = {rate_type = 1, rank_type = 2, other_type = 3}
worldProProcessType = {unopen = 10, running = 0, finish = 1, over_time = 2}
worldProRewardType = {none = 0, all_server = 1, union = 2, player = 3}

local m_cache_process_info = nil

function get_world_pro_cfg_info(temp_cfg_id)
	return Tb_cfg_progress[temp_cfg_id]
end

function get_own_server_list()
	local result_list = {}
	for k,v in pairs(Tb_cfg_progress) do
		if v.progress_type == 0 then
			table.insert(result_list, k)
		end
	end

	table.sort(result_list)
	return result_list
end

function get_own_state_list()
	local result_list = {}
	for k,v in pairs(Tb_cfg_progress) do
		if v.progress_type == 1 then
			table.insert(result_list, k)
		end
	end

	table.sort(result_list)
	return result_list
end

local function is_in_table(temp_table, judge_value)
	for k,v in pairs(temp_table) do
		if v == judge_value then
			return true
		end
	end

	return false
end

-- 1 百分比类型；2 排行类型；3 类似首杀类型
function get_conditon_type(cfg_con_type)
	--[[
	public static final int CONDITION_OCCUPY_LAND_LEVEL_COUNT = 1;// 占领某等级土地数量   1,2,10 占领2级地10块
	public static final int CONDITION_OCCUPY_LAND_LEVEL_RATIO = 2;// 占领某等级土地比例
	public static final int CONDITION_ALL_OCCUPY_NATIONAL_CAPITAL = 3;// 全服占领国都
	public static final int CONDITION_ALL_OCCUPY_STATE_CAPITAL_COUNT = 4;// 全服占领州首府数量
	public static final int CONDITION_OCCUPY_NPC_CITY_COUNT = 5;// 被占领NPC城市数量
	public static final int CONDITION_ALL_KILL_THIEF = 6; // 全服消灭贼兵数
	public static final int CONDITION_ALL_UNION_MEMBER = 7; // 全服同盟数量
	public static final int CONDITION_ALL_PERSON_POWER = 8; // 全服个人势力值
	public static final int CONDITION_ALL_UNION_POWER = 9; // 全服同盟势力值
	public static final int CONDITION_STATE_FIRST_OCCUPY_STATE_CAPITAL = 10;// 州首次占领州首府
	public static final int CONDITION_STATE_OCCUPY_ALL_NPC_CITY = 11;// 全州所以城市被占领
	public static final int CONDITION_ALL_FIRST_OCCUPY_NATIONAL_CAPITAL = 12;// 全服首次占领国都
	public static final int CONDITION_ALL_FIRST_OCCUPY_CENTRAL_CAPITAL = 13;// 全服雍、兖、豫三州首府之一首次被占领
	public static final int CONDITION_ALL_FIRST_OCCUPY_STATE_LAND = 14;// 全服首次占领某州土地
	public static final int CONDITION_ALL_OCCUPY_ALL_CAPITAL = 15;// 全服全部州首府被一个同盟占领
	public static final int CONDITION_ALL_TIME_OVER = 16;// 全服时间到了触发   16,1,10个人排行榜前十     16,2,18同盟排行榜前十八
	5 8 9 11
	--]]

	local temp_rate_list = {1, 2, 3, 4, 5, 6, 7, 8, 9, 11}
	local temp_rank_list = {16}
	local temp_other_list = {10, 12, 13, 14, 15}

	if is_in_table(temp_rate_list, cfg_con_type) then
		return worldProContentType.rate_type
	end

	if is_in_table(temp_rank_list, cfg_con_type) then
		return worldProContentType.rank_type
	end

	if is_in_table(temp_other_list, cfg_con_type) then
		return worldProContentType.other_type
	end

	return 0
end

--上面分类属于进度类的在详情里面时有些还要显示列表
function is_show_rank_in_detail(cfg_con_type)
	local temp_rank_list = {5, 8, 9, 11}
	return is_in_table(temp_rank_list, cfg_con_type)
end

--详情里面显示列表的是否属于城市类型
function is_show_city_list(cfg_con_type)
	if cfg_con_type == 5 or cfg_con_type == 11 then
		return true
	else
		return false
	end
end

--针对进度类型的获取最大值
function get_rate_max_num(temp_cfg_info, temp_state_type)
	local temp_all_nums = 0
	if temp_cfg_info.condition[1] == 11 then
		local temp_city_list = stateData.getNpcCityInState(temp_state_type)
		temp_all_nums = #temp_city_list
	else
		temp_all_nums = temp_cfg_info.condition[3]
	end

	return temp_all_nums
end

--针对worldProContentType.rate_type区分是否是百分比类型的
function get_percent_condition_type(cfg_con_type)
	if cfg_con_type == 2 then
		return true
	else
		return false
	end
end

--针对worldProContentType.other_type的要区分是同盟为单位的还是个人 true 个人  false 同盟
function get_other_condition_type(cfg_con_type)
	if cfg_con_type == 14 then
		return true
	else
		return false
	end
end

function get_pre_process_cfg_id(temp_cfg_id)
	for k,v in pairs(Tb_cfg_progress) do
		if v.next_progress == temp_cfg_id then
			return k
		end
	end

	return nil
end

--[[
	public static final int ACTION_VILLAGE = 1;// 开启山寨
	public static final int ACTION_CARD = 2;// 开启卡包
	public static final int ACTION_FILED_EVENT_CARD = 3;// 地表事件卡包
	public static final int ACTION_FILED_EVENT_EXP = 4;// 地表事件经验书
	public static final int ACTION_FILED_EVENT_THIEF = 5;// 地表事件贼兵
	public static final int ACTION_HERO_MAX = 6;// 武将上限
	public static final int ACTION_CARD_UPGRADE_HERO = 7;// 卡包升级
	public static final int ACTION_COMBINE_CARD = 8;// 合并补充包
--]]

function get_spe_reward_show_info(spe_list, temp_finish_state)
	local icon_name, icon_des = nil, nil

	local temp_type = spe_list[1]
	if temp_type == 1 then
		icon_name = ResDefineUtil.world_process_res[11]
		if spe_list[2] == 1 then
			if temp_finish_state then
				icon_des = languagePack['kaiqied']
			else
				icon_des = languagePack['kaiqi']
			end
		else
			if temp_finish_state then
				icon_des = languagePack['gengxined']
			else
				icon_des = languagePack['gengxin']
			end
		end
	elseif temp_type == 2 then
		icon_name =  ResDefineUtil.world_process_res[10]
		if temp_finish_state then
			icon_des = languagePack['kaiqied']
		else
			icon_des = languagePack['kaiqi']
		end
	elseif temp_type == 3 then
	elseif temp_type == 4 then
	elseif temp_type == 5 then
	elseif temp_type == 6 then
		icon_name = ResDefineUtil.world_process_res[12]
		if temp_finish_state then
			icon_des = languagePack['tigaoed']
		else
			icon_des = languagePack['tigao']
		end
	elseif temp_type == 7 then
		icon_name = ResDefineUtil.world_process_res[10]
		if temp_finish_state then
			icon_des = languagePack['gengxined']
		else
			icon_des = languagePack['gengxin']
		end
	elseif temp_type == 8 then
		icon_name = ResDefineUtil.world_process_res[10]
		if temp_finish_state then
			icon_des = languagePack['gengxined']
		else
			icon_des = languagePack['gengxin']
		end
	end

	return icon_name, icon_des
end

function get_com_reward_decorate_des(temp_cfg_info)
	if temp_cfg_info.condition[1] == 16 then
		if temp_cfg_info.condition[2] == 1 then
			return languagePack['firstjiangli']
		else
			return languagePack['firstUnionjiangli']
		end
	else
		local temp_reward_type = temp_cfg_info.reward_type
		if temp_reward_type == worldProRewardType.all_server then
			return languagePack['quanfuhuode']
		elseif temp_reward_type == worldProRewardType.union then
			return languagePack['tongmenghuode']
		elseif temp_reward_type == worldProRewardType.player then
			return languagePack['huode']
		end
	end

	return " "
end

function get_spe_reward_des(spe_list)
	local temp_type = spe_list[1]
	if temp_type == 1 then
		if spe_list[2] == 1 then
			return languagePack['kaiqishanzhai']
		else
			return languagePack['tigaoshanzhai']
		end
	elseif temp_type == 2 then
		return languagePack['kaiqizhaomu'] .. Tb_cfg_card_extract[spe_list[2]].refresh_name
	elseif temp_type == 3 then
	elseif temp_type == 4 then
	elseif temp_type == 5 then
	elseif temp_type == 6 then
		return languagePack['beibaoshangxian'] .. spe_list[2]
	elseif temp_type == 7 then
		if spe_list[2] == 0 then
			return string.format(languagePack['zhaomudengjitigao'], languagePack['dibiaoshijianzhaomu'], spe_list[3])
		else
			return string.format(languagePack['zhaomudengjitigao'], Tb_cfg_card_extract[spe_list[2]].refresh_name, spe_list[3])
		end
	elseif temp_type == 8 then
		return languagePack['kabaohebing']
	end

	return " "
end

function get_pro_reward_state(temp_cfg_id)
	local temp_got_info = allTableData[dbTableDesList.user_stuff.name][userData.getUserId()].progress_reward
	local temp_got_list = stringFunc.anlayerOnespot(temp_got_info, ",", true)
	for k,v in pairs(temp_got_list) do
		if v == temp_cfg_id then
			return true
		end
	end

	return false
end

--该函数有使用前提，必须进度已经完成了在调用查看玩家自己是不是可以领取
function get_reward_obtain_state(temp_state_type, temp_cfg_id)
	local temp_cfg_info = get_world_pro_cfg_info(temp_cfg_id)
	local temp_sys_info = get_sys_pro_info(temp_state_type, temp_cfg_id)
	local temp_obtain_list = nil
	local temp_reward_type = temp_cfg_info.reward_type
	if temp_reward_type == worldProRewardType.none then
		return false
	elseif temp_reward_type == worldProRewardType.all_server then
		if temp_sys_info.state == worldProProcessType.finish then
			return userData.getRegTime() <= temp_sys_info.finish_time
		else
			return userData.getRegTime() <= temp_sys_info.end_time
		end
	elseif temp_reward_type == worldProRewardType.union then
		local temp_union_id = userData.getUnion_id()
		if temp_union_id == 0 then
			return false
		else
			temp_obtain_list = stringFunc.anlayerOnespot(temp_sys_info.reward, ",", true)
			if is_in_table(temp_obtain_list, temp_union_id) then
				local temp_join_time = allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()].join_time
				if temp_sys_info.state == worldProProcessType.finish then
					return temp_join_time <= temp_sys_info.finish_time
				else
					return temp_join_time <= temp_sys_info.end_time
				end
			end
		end
	elseif temp_reward_type == worldProRewardType.player then
		temp_obtain_list = stringFunc.anlayerOnespot(temp_sys_info.reward, ",", true)
		return is_in_table(temp_obtain_list, userData.getUserId())
	end

	return false
end

function get_sys_pro_info(state_id, temp_cfg_id)
	for k,v in pairs(m_cache_process_info) do
		if v.region == state_id and v.progress_id == temp_cfg_id then
			return m_cache_process_info[k]
		end
	end

	return nil
end

function get_running_id_for_tianxia()
	for k,v in pairs(m_cache_process_info) do
		if v.region == 0 then
			if v.state == worldProProcessType.running then
				return v.progress_id
			end
		end
	end

	return 0
end

function get_new_sign_state_for_tianxia()
	local temp_new_pro_id, temp_pro_id = 0, 0
	for k,v in pairs(m_cache_process_info) do
		if v.region == 0 then
			if v.state == worldProProcessType.finish or v.state == worldProProcessType.over_time then
				temp_pro_id = v.progress_id
				if get_reward_obtain_state(v.region, temp_pro_id) then
					if not get_pro_reward_state(temp_pro_id) then
						if temp_new_pro_id == 0 then
							temp_new_pro_id = temp_pro_id
						else
							if temp_new_pro_id > temp_pro_id then
								temp_new_pro_id = temp_pro_id
							end
						end
					end
				end
			end
		end
	end

	return temp_new_pro_id
end

function request_process_info(state_id)
	Net.send(PROGRESS_GET_INFO, {state_id})
end

function recieve_process_info(package)
	local temp_update_state = false
	for k,v in pairs(package) do
		m_cache_process_info[v.id] = v
		if v.region == 0 then
			temp_update_state = true
		end
	end

	if temp_update_state then
		if worldProStateManager then
			worldProStateManager.set_tianxia_new_sign_state()
		end
	end

	if worldProContentManager then
		worldProContentManager.reload_data(true)
	end
end

function request_obtain_reward(process_id)
	Net.send(PROGRESS_GET_REWARD, {process_id})
end

function receive_reward_info(package)
	if worldProContentManager then
		worldProContentManager.reload_data(false)
	end

	if worldProDetailManager then
		worldProDetailManager.deal_with_obtain_response()
	end

	if m_cache_process_info then
		local temp_cfg_info = worldProData.get_world_pro_cfg_info(m_cache_process_info[package[1]].progress_id)
		local temp_com_reward_list = temp_cfg_info.reward
		local temp_obtain_rate = package[2]/100
		local show_list = {}
		for k,v in pairs(temp_com_reward_list) do
			local show_name = clientConfigData.getDorpName(v[1])
			local show_num = clientConfigData.getDorpCount(v[1], v[2])
			local show_content = languagePack["huode"] .. show_name .. " " .. (show_num*temp_obtain_rate)

			table.insert(show_list, show_content)
		end

		if #show_list > 0 then
			taskTipsLayer.create(show_list)
		end
	end
end

function remove()
	m_cache_process_info = nil
	netObserver.removeObserver(PROGRESS_GET_INFO)
	netObserver.removeObserver(PROGRESS_GET_REWARD)
end

function create()
	m_cache_process_info = {}
	netObserver.addObserver(PROGRESS_GET_INFO, recieve_process_info)
	netObserver.addObserver(PROGRESS_GET_REWARD, receive_reward_info) 
end