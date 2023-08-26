local function get_extract_card_info(extract_uid)
	return allTableData[dbTableDesList.user_card_extract.name][extract_uid]
end

local function get_sys_extract_card_info(extract_cfg_id)
	for k,v in pairs(allTableData[dbTableDesList.sys_card_extract.name]) do
		if v.extract_id == extract_cfg_id then
			return v
		end
	end
	return nil
end

local function get_extract_card_level(extract_cfg_id)
	local result_level = 0
	for k,v in pairs(allTableData[dbTableDesList.sys_card_extract_param.name]) do
		if k == extract_cfg_id then
			result_level = v.hero_level
			break
		end
	end

	if result_level == 0 then
		result_level = Tb_cfg_card_extract[extract_cfg_id].hero_level
	end

	return result_level
end

local function get_share_package_see_state(extract_cfg_id)
	local temp_see_content = CCUserDefault:sharedUserDefault():getStringForKey(recordLocalInfo[8])
	if temp_see_content == "" then
		return false
	else
		local temp_see_list = stringFunc.anlayerOnespot(temp_see_content, ",", true)
		for k,v in pairs(temp_see_list) do
			if v == extract_cfg_id then
				return true
			end
		end
	end

	return false
end

local function record_share_package_see(temp_see_content)
	local old_see_content = CCUserDefault:sharedUserDefault():getStringForKey(recordLocalInfo[8])
	if old_see_content ~= temp_see_content then
		if mainOption then
			mainOption.refreshCardTips()
		end

		CCUserDefault:sharedUserDefault():setStringForKey(recordLocalInfo[8], temp_see_content)
	end
end

local function get_half_state(extract_uid)
	local temp_extract_info = get_extract_card_info(extract_uid)
	return temp_extract_info.half_price
end

local function sort_ruler_1(a_id, b_id)
	local a_extract_info = get_extract_card_info(a_id)
	local b_extract_info = get_extract_card_info(b_id)

	if a_extract_info.is_new == 1 then
		if b_extract_info.is_new ~= 1 then
			return true
		end
	else
		if b_extract_info.is_new == 1 then
			return false
		end
	end

	local a_extract_cfg_info = Tb_cfg_card_extract[a_extract_info.refresh_way_id]
	local b_extract_cfg_info = Tb_cfg_card_extract[b_extract_info.refresh_way_id]

	if a_extract_cfg_info.priority == b_extract_cfg_info.priority then
		if a_extract_info.got_time == b_extract_info.got_time then
			if a_extract_info.refresh_way_id == b_extract_info.refresh_way_id then
				return a_id < b_id
			else
				return a_extract_info.refresh_way_id < b_extract_info.refresh_way_id
			end
		else
			return a_extract_info.got_time < b_extract_info.got_time
		end
	else
		return a_extract_cfg_info.priority < b_extract_cfg_info.priority
	end
end

local function sort_ruler_2(a_cfg_id, b_cfg_id)
	local a_extract_cfg_info = Tb_cfg_card_extract[a_cfg_id]
	local b_extract_cfg_info = Tb_cfg_card_extract[b_cfg_id]

	if a_extract_cfg_info.priority == b_extract_cfg_info.priority then
		return a_cfg_id < b_cfg_id
	else
		return a_extract_cfg_info.priority < b_extract_cfg_info.priority
	end
end

--已经生成唯一ID的用户数据
local function is_used_refresh_by_id(temp_id)
	local used_state = false
	for k,v in pairs(allTableData[dbTableDesList.user_card_extract.name]) do
		if v.refresh_way_id == temp_id then
			used_state = true
			break
		end
	end

	return used_state
end

local function is_sys_extract_by_id(temp_id)
	local temp_state = false
	for k,v in pairs(allTableData[dbTableDesList.sys_card_extract.name]) do
		if v.extract_id == temp_id then
			temp_state = true
			break
		end
	end

	return temp_state
end

--获取可用抽卡方式列表，根据标签页分别存储在不同的列表中
local function get_update_time_node(extract_uid, current_time)
	local temp_extract_info = get_extract_card_info(extract_uid)
	local temp_extract_cfg_info = Tb_cfg_card_extract[temp_extract_info.refresh_way_id]

	local free_node_time, end_node_time = 0, 0
	if temp_extract_cfg_info.free_count == 0 then
		if temp_extract_cfg_info.free_interval_cd ~= 0 then
			if temp_extract_info.free_time ~= 0 then
				if current_time - temp_extract_info.free_time < temp_extract_cfg_info.free_interval_cd then
					free_node_time = temp_extract_info.free_time + temp_extract_cfg_info.free_interval_cd
				end
			end
		end
	else
		if temp_extract_cfg_info.free_interval_cd ~= 0 then
			if temp_extract_info.used_count_free >= temp_extract_cfg_info.free_count then
				if current_time - temp_extract_info.free_time < temp_extract_cfg_info.free_interval_cd then
					free_node_time = temp_extract_info.free_time + temp_extract_cfg_info.free_interval_cd
				end
			end
		end
	end

	end_node_time = temp_extract_info.end_time

	return free_node_time, end_node_time
end

local function add_time_to_list(free_node_time, end_node_time, update_time_list)
	local is_free_in_list, is_end_in_list = false, false
	for i,v in ipairs(update_time_list) do
		if v == free_node_time then
			is_free_in_list = true
		end
		if v == end_node_time then
			is_end_in_list = true
		end
	end

	if (not is_free_in_list) and free_node_time ~= 0 then
		table.insert(update_time_list, free_node_time)
	end

	if (not is_end_in_list) and end_node_time ~= 0 then
		table.insert(update_time_list, end_node_time)
	end
end

--返回是否正常开放，在第一个返回值为false的时候检测第二个是否属于当日次数用完的情况
local function get_valid_state_for_u(temp_extract_u, temp_extract_cfg)
	if temp_extract_u.end_time ~= 0 and userData.getServerTime() >= temp_extract_u.end_time then
		return false, false
	end

	if temp_extract_cfg.total_count ~= 0 and temp_extract_cfg.total_count <= temp_extract_u.used_count_total then
		return false, false
	end

	if temp_extract_cfg.daily_count ~= 0 then
		if commonFunc.is_in_today(temp_extract_u.used_time) then
			if temp_extract_cfg.daily_count <= temp_extract_u.used_count_daily then
				return false, true
			end
		else
			temp_extract_u.used_count_daily = 0
		end
	end

	return true, false
end

local function get_valid_state_for_sys(temp_cfg_id, temp_end_time)
	if not is_used_refresh_by_id(temp_cfg_id) then
		if temp_end_time > userData.getServerTime() then
			return true
		end
	end

	return false
end

local function get_valid_state_for_cfg(temp_cfg_id, temp_extract_cfg)
	if (not is_used_refresh_by_id(temp_cfg_id)) and (not is_sys_extract_by_id(temp_cfg_id)) then
		if temp_extract_cfg.always_show == 1 then
			return 1, 0
		else
			if temp_extract_cfg.condition_available == "" then
				if temp_extract_cfg.begin_time ~= "" and temp_extract_cfg.end_time ~= "" then
					local start_time = commonFunc.get_time_by_data(temp_extract_cfg.begin_time)
					local end_time = commonFunc.get_time_by_data(temp_extract_cfg.end_time)
					local current_time = userData.getServerTime()
					if current_time >= start_time and current_time <= end_time then
						return 0, end_time
					end
				else
					return 0, 0
				end
			end
		end
	end

	return 2, 0
end

-- 该函数只获取user_card_extract表中is_new状态为1的抽卡方式相关的一些信息，用来处理获取新抽卡方式时播放动画
local function get_extract_new_info()
	local result_list = {}
	local is_valid = nil
	for k,v in pairs(allTableData[dbTableDesList.user_card_extract.name]) do
		local temp_extract_cfg = Tb_cfg_card_extract[v.refresh_way_id]

		is_valid = get_valid_state_for_u(v, temp_extract_cfg)
		if is_valid then
			if v.is_new == 1 then
				table.insert(result_list, v.refresh_way_id)
			end
		end
	end

	for k,v in pairs(allTableData[dbTableDesList.sys_card_extract.name]) do
		is_valid = get_valid_state_for_sys(v.extract_id, v.end_time)
		if is_valid then
			if not get_share_package_see_state(v.extract_id) then
				table.insert(result_list, v.extract_id)
			end
		end
	end

	for kk,vv in pairs(Tb_cfg_card_extract) do
		is_valid = get_valid_state_for_cfg(kk, vv)
		if is_valid == 0 then
			if not get_share_package_see_state(kk) then
				table.insert(result_list, kk)
			end
		end
	end

	return result_list
end

local function get_card_call_list()
	local current_time = userData.getServerTime()

	local temp_update_time_list = {}	--需要刷新的时间节点列表
	local temp_actived_list = {}
	local temp_daily_none_list = {} 	--日常次数使用完成的列表
	local is_valid, is_daily_nothing = nil, nil
	for k,v in pairs(allTableData[dbTableDesList.user_card_extract.name]) do
		local temp_extract_cfg = Tb_cfg_card_extract[v.refresh_way_id]

		is_valid, is_daily_nothing = get_valid_state_for_u(v, temp_extract_cfg)
		if is_valid then
			table.insert(temp_actived_list, k)

			local temp_free_node_time, temp_end_node_time = get_update_time_node(k, current_time)
			add_time_to_list(temp_free_node_time, temp_end_node_time, temp_update_time_list)
		else
			if is_daily_nothing then
				table.insert(temp_daily_none_list, k)
			end
		end
	end

	local temp_unopen_list = {}
	local temp_share_list = {}
	for k,v in pairs(allTableData[dbTableDesList.sys_card_extract.name]) do
		is_valid = get_valid_state_for_sys(v.extract_id, v.end_time)
		if is_valid then
			table.insert(temp_share_list, v.extract_id)
			add_time_to_list(0, v.end_time, temp_update_time_list)
		end
	end

	--[[
		约定内容：如果 condition_available 不为空，则服务器保证如果满足这个条件则该卡包一定在上面那个有UID的表内，
		如果条件不满足则在列表中也不会显示；如果condition_available为空而且该卡包未在生成的uid列表中，则卡包根据
		是否配置begin_time,end_time来确定显示方式。注释约定2015.04.03
	--]]
	local show_end_time = nil
	for kk,vv in pairs(Tb_cfg_card_extract) do
		is_valid, show_end_time = get_valid_state_for_cfg(kk, vv)
		if is_valid == 0 then
			table.insert(temp_share_list, kk)
			if show_end_time ~= 0 then
				add_time_to_list(0, show_end_time, temp_update_time_list)
			end
		elseif is_valid == 1 then
			table.insert(temp_unopen_list, kk)
		end
	end

	table.sort(temp_actived_list, sort_ruler_1)
	table.sort(temp_daily_none_list, sort_ruler_1)
	table.sort(temp_unopen_list, sort_ruler_2)
	table.sort(temp_share_list, sort_ruler_2)

	local temp_call_list = {}
	local temp_share_content = ""

	--引导期间激活的卡包 排序在 活动卡包之前
	if newGuideManager.get_guide_state() then
		for k,v in pairs(temp_actived_list) do
			table.insert(temp_call_list, {v, cardCallType.actived})
		end

		for k,v in pairs(temp_share_list) do
			table.insert(temp_call_list, {v, cardCallType.share})
			temp_share_content = temp_share_content .. v .. ","
		end
	else
		for k,v in pairs(temp_share_list) do
			table.insert(temp_call_list, {v, cardCallType.share})
			temp_share_content = temp_share_content .. v .. ","
		end
		
		for k,v in pairs(temp_actived_list) do
			table.insert(temp_call_list, {v, cardCallType.actived})
		end
	end

	for k,v in pairs(temp_daily_none_list) do
		table.insert(temp_call_list, {v, cardCallType.no_daily})
	end
	
	for k,v in pairs(temp_unopen_list) do
		table.insert(temp_call_list, {v, cardCallType.unopen})
	end

	table.sort(temp_update_time_list)

	return temp_update_time_list, temp_call_list, temp_share_content
end

--[[
当激活新的刷卡方式或当前有免费刷卡次数时，会在按钮上出现一个带数字的红点，
数字表示新激活的刷卡方式数量+免费次数。
当玩家点击（点击即可，不需要成功刷卡，）新增的刷卡方式后数值会相应减少，数值为0时红点不会显示
--]]
local function get_free_nums_for_uid(extract_uid, current_time)
	local temp_extract_info = get_extract_card_info(extract_uid)
	local temp_extract_cfg_info = Tb_cfg_card_extract[temp_extract_info.refresh_way_id]

	local free_nums, all_nums = 0, 0
	if temp_extract_cfg_info.free_count == 0 then
		if temp_extract_cfg_info.free_interval_cd ~= 0 then
			if temp_extract_info.free_time == 0 then
				if current_time - temp_extract_info.got_time >= temp_extract_cfg_info.free_interval_cd then
					free_nums = 1
					all_nums = 1
				end
			else
				if current_time - temp_extract_info.free_time >= temp_extract_cfg_info.free_interval_cd then
					free_nums = 1
					all_nums = 1
				end
			end
		end
	else
		free_nums = temp_extract_cfg_info.free_count - temp_extract_info.used_count_free
		all_nums = temp_extract_cfg_info.free_count
		if free_nums <= 0 then
			if temp_extract_cfg_info.free_interval_cd == 0 then
				free_nums = 0
			else
				if current_time - temp_extract_info.free_time >= temp_extract_cfg_info.free_interval_cd then
					free_nums = 1
				else
					free_nums = 0
				end
			end
		end
	end

	return free_nums, all_nums
end

--获取活动刷新的免费次数（未生成真正的抽卡UID）
local function get_free_nums_for_cfg_id(extract_cfg_id)
	local temp_extract_cfg_info = Tb_cfg_card_extract[extract_cfg_id]

	local free_nums, all_nums = 0, 0
	if temp_extract_cfg_info.free_count == 0 then
		if temp_extract_cfg_info.free_interval_cd == 0 then
			free_nums = 0
		else
			local start_time = 0
			local temp_sys_extract_info = get_sys_extract_card_info(extract_cfg_id)
			if temp_sys_extract_info then
				start_time = temp_sys_extract_info.got_time
			else
				if temp_extract_cfg_info.begin_time ~= "" then
					start_time = commonFunc.get_time_by_data(temp_extract_cfg_info.begin_time)
				end
			end

			if start_time ~= 0 then
				local temp_free_time_interval = userData.getServerTime() - start_time
				if temp_free_time_interval >= temp_extract_cfg_info.free_interval_cd then
					free_nums = 1
					all_nums = 1
				else
					free_nums = 0
				end
			end
		end
	else
		free_nums = temp_extract_cfg_info.free_count
		all_nums = temp_extract_cfg_info.free_count
	end

	return free_nums, all_nums
end

local function get_new_extract_nums()
	local current_time = userData.getServerTime()

	local temp_num = 0
	local is_own_new_state, is_share_new_state = false, false
	local actived_new_nums = 0
	local is_valid = nil
	for k,v in pairs(allTableData[dbTableDesList.user_card_extract.name]) do
		local temp_extract_cfg = Tb_cfg_card_extract[v.refresh_way_id]

		is_valid = get_valid_state_for_u(v, temp_extract_cfg)
		if is_valid then
			temp_num = get_free_nums_for_uid(k, current_time)
			if temp_num == 0 then
				if v.is_new == 1 then
					actived_new_nums = actived_new_nums + 1
				end
			else
				actived_new_nums = actived_new_nums + temp_num
			end

			if v.is_new == 1 then
				is_own_new_state = true
			end
		end
	end

	local share_new_nums = 0
	for k,v in pairs(allTableData[dbTableDesList.sys_card_extract.name]) do
		is_valid = get_valid_state_for_sys(v.extract_id, v.end_time)
		if is_valid then
			temp_num = get_free_nums_for_cfg_id(v.extract_id)
			if temp_num == 0 then
				if not get_share_package_see_state(v.extract_id) then
					share_new_nums = share_new_nums + 1
					is_share_new_state = true
				end
			else
				share_new_nums = share_new_nums + temp_num
			end
		end
	end

	for kk,vv in pairs(Tb_cfg_card_extract) do
		is_valid = get_valid_state_for_cfg(kk, vv)
		if is_valid == 0 then
			temp_num = get_free_nums_for_cfg_id(kk)
			if temp_num == 0 then
				if not get_share_package_see_state(kk) then
					share_new_nums = share_new_nums + 1
					is_share_new_state = true
				end
			else
				share_new_nums = share_new_nums + temp_num
			end
		end

	end

	return is_own_new_state, is_share_new_state, actived_new_nums, share_new_nums
end

local function get_call_res_icon(cost_type)
	if cost_type == consumeType.yuanbao then
		return ResDefineUtil.ui_card_country[6]
	elseif cost_type == consumeType.common_money then
		return ResDefineUtil.ui_card_country[7]
	end
end

local function get_call_res_name(cost_type)
	if cost_type == consumeType.yuanbao then
		return languagePack["jin"]
	elseif cost_type == consumeType.common_money then
		return languagePack["tongqian"]
	end
end

local function get_call_res_nums(cost_type)
	if cost_type == consumeType.yuanbao then
		return userData.getYuanbao()
	elseif cost_type == consumeType.common_money then
		return politics.getSelfRes().money_cur
	end
end

cardCallData = {
					get_extract_card_info = get_extract_card_info,
					get_sys_extract_card_info = get_sys_extract_card_info,
					record_share_package_see = record_share_package_see,
					get_share_package_see_state = get_share_package_see_state,
					get_extract_card_level = get_extract_card_level,
					get_half_state = get_half_state,
					get_card_call_list = get_card_call_list,
					get_extract_new_info = get_extract_new_info,
					get_new_extract_nums = get_new_extract_nums,
					get_free_nums_for_uid = get_free_nums_for_uid,
					get_free_nums_for_cfg_id = get_free_nums_for_cfg_id,
					get_call_res_icon = get_call_res_icon,
					get_call_res_name = get_call_res_name,
					get_call_res_nums = get_call_res_nums
}