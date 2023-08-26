local function sort_ruler_1(a_army, b_army)
	local a_army_info = armyData.getTeamMsg(a_army[1])
	local b_army_info = armyData.getTeamMsg(b_army[1])

	if a_army_info.begin_time == b_army_info.begin_time then
		return a_army[1] < b_army[1]
	else
		return a_army_info.begin_time < b_army_info.begin_time
	end
end

local function sort_ruler_2(a_army, b_army)
	local a_army_info = armyData.getAssaultTeamMsg(a_army[1])
	local b_army_info = armyData.getAssaultTeamMsg(b_army[1])

	if a_army_info.end_time == b_army_info.end_time then
		return a_army[1] < b_army[1]
	else
		return a_army_info.end_time < b_army_info.end_time
	end
end

local function sort_ruler_3(a_army, b_army)
	local a_army_info, b_army_info = nil, nil
	if a_army[2] == 1 then
		a_army_info = armyData.getTeamMsg(a_army[1])
	else
		a_army_info = mapData.getFieldArmyMsgByArmyId(a_army[1])
	end

	if b_army[2] == 1 then
		b_army_info = armyData.getTeamMsg(b_army[1])
	else
		b_army_info = mapData.getFieldArmyMsgByArmyId(b_army[1])
	end

	if a_army_info.state == b_army_info.state then
		if a_army_info.begin_time == b_army_info.begin_time then
			return a_army[1] < b_army[1]
		else
			return a_army_info.begin_time > b_army_info.begin_time
		end
	else
		return a_army_info.state < b_army_info.state
	end
end

--该部分值显示自己的非正常状态的部队以及敌袭的部队
local function get_simple_show_list()
	local self_move_list = {}
	local self_static_list = {}
	local army_state = nil
	for k,v in pairs(armyData.getAllTeamMsg()) do
		army_state = v.state
		if army_state ~= armyState.normal then
			if army_state == armyState.chuzhenging or army_state == armyState.zhuzhaing 
				or army_state == armyState.yuanjuning or army_state == armyState.returning 
				 then
				table.insert(self_move_list, {k, 1})
			else
				table.insert(self_static_list, {k, 1})
			end
		end
	end

	local enemy_move_list = {}
	local temp_army_info = nil
	for k,v in pairs(armyData.getAllAssaultMsg()) do
		table.insert(enemy_move_list, {v.armyid, 3})
	end

	table.sort(self_move_list, sort_ruler_1)
	table.sort(enemy_move_list, sort_ruler_2)
	table.sort(self_static_list, sort_ruler_3)

	local temp_result_list = {}

	for k,v in pairs(self_move_list) do
		table.insert(temp_result_list, v)
	end
	
	for k,v in pairs(enemy_move_list) do
		table.insert(temp_result_list, v)
	end

	for k,v in pairs(self_static_list) do
		table.insert(temp_result_list, v)
	end

	return temp_result_list
end

-- 具体内容的含义  部队ID；部队所属（自己，友军，敌军）；是否属于敌袭
local function get_list_in_pos(pos_x, pos_y)
	local self_static_list = {}
	local army_state = nil
	local pos_coor = pos_x * 10000 + pos_y
	for k,v in pairs(armyData.getAllTeamMsg()) do
		if v.target_wid == pos_coor then
			army_state = v.state
			if army_state == armyState.training or army_state == armyState.zhuzhaed or army_state == armyState.yuanjuned or army_state == armyState.sleeped or army_state == armyState.decreed then
				table.insert(self_static_list, {k, 1, false})
			end
		end
	end

	local friend_static_list = {}
	local enemy_static_list = {}
	for kk,vv in pairs(mapData.getFieldArmyMsg()) do
		army_state = vv.state
		if army_state == armyState.zhuzhaed or army_state == armyState.yuanjuned or army_state == armyState.sleeped
		or army_state == armyState.decreed or army_state == armyState.training then
			if vv.wid_to == pos_coor then
				if vv.relation == mapAreaRelation.free_enemy or vv.relation == mapAreaRelation.attach_enemy then
					table.insert(enemy_static_list, {kk, 3, false})
				else
					table.insert(friend_static_list, {kk, 2, false})
				end
			end
		end
	end

	table.sort(self_static_list, sort_ruler_3)
	table.sort(friend_static_list, sort_ruler_3)
	table.sort(enemy_static_list, sort_ruler_3)

	local temp_result_list = {}

	for k,v in pairs(self_static_list) do
		table.insert(temp_result_list, v)
	end

	for k,v in pairs(friend_static_list) do
		table.insert(temp_result_list, v)
	end

	for k,v in pairs(enemy_static_list) do
		table.insert(temp_result_list, v)
	end

	return temp_result_list
end

--通过部队ID获取行军列表右侧需要的相关数据
local function get_info_by_army_id(army_id)
	for k,v in pairs(armyData.getAllTeamMsg()) do
		if k == army_id then
			return {army_id, 1, false}
		end
	end

	for k,v in pairs(armyData.getAllAssaultMsg()) do
		if v.armyid == army_id then
			return {army_id, 3, true}
		end
	end

	for k,v in pairs(mapData.getFieldArmyMsg()) do
		if k == army_id then
			if v.relation == mapAreaRelation.free_enemy or v.relation == mapAreaRelation.attach_enemy then
				return {army_id, 3, false}
			else
				return {army_id, 2, false}
			end
		end
	end

	return nil
end

armyListAssist = {
					get_simple_show_list = get_simple_show_list,
					get_list_in_pos = get_list_in_pos,
					get_info_by_army_id = get_info_by_army_id
}