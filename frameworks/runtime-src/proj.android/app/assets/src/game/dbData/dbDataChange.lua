allTableData = nil
initOrNot = false
dataChangeType = {add = 1, update = 2, remove = 3}
eventListenerType = {initTeamComplete = 1}

--数据库表信息描述相关
dbTableDesList = {
					anchor_state 		= 	{name = "Tb_anchor_state", key_index = "anchor_wid"},
					battle_report 		= 	{name = "Tb_battle_report", key_index = "battle_id"},
					build 				= 	{name = "Tb_build", key_index = "build_id_u"},
					build_effect_city	=	{name = "Tb_build_effect_city", key_index = "city_wid"},
					chat_disable 		= 	{name = "Tb_chat_disable", key_index = "userid"},
					hero_timer 			= 	{name = "Tb_hero_timer", key_index = "heroid_u"},
					pay_record 			= 	{name = "Tb_pay_record", key_index = "id"},
					state_cron 			= 	{name = "Tb_state_cron", key_index = "state_id"},
					army 				= 	{name = "Tb_army", key_index = "armyid"},
					army_alert 			= 	{name = "Tb_army_alert", key_index = "id"},
					hero 				= 	{name = "Tb_hero", key_index = "heroid_u"},
					sys_state 			= 	{name = "Tb_sys_state", key_index = "state_id"},
					sys_param 			= 	{name = "Tb_sys_param", key_index = "param_id"},
					sys_progress 		= 	{name = "Tb_sys_progress", key_index = "id"},
					sys_user_config 	= 	{name = "Tb_sys_user_config", key_index = "id"},
					world_city 			= 	{name = "Tb_world_city", key_index = "wid"},
					world_mark			=	{name = "Tb_world_mark", key_index = "mark_id"},
					sys_world_no_born 	= 	{name = "Tb_sys_world_no_born", key_index = "wid"},
					sys_world_res 		= 	{name = "Tb_sys_world_res", key_index = "wid"},
					sys_activity 		= 	{name = "Tb_activity_id", key_index = "activity_id"},
					union_info 			= 	{name = "Tb_union_info", key_index = "union_id"},
					user 				= 	{name = "Tb_user", key_index = "userid"},
					activity  			=  	{name = "Tb_activity",key_index = "activity_id_u"},
					user_city 			= 	{name = "Tb_user_city", key_index = "city_wid"},
					user_res 			= 	{name = "Tb_user_res", key_index = "userid"},
					user_skill 			= 	{name = "Tb_user_skill", key_index = "skill_id_u"},
					user_farm			=	{name = "Tb_user_farm",key_index = "user_id"},
					user_consume		=	{name = "Tb_user_consume",key_index = "userid"},
					user_card_extract 	= 	{name = "Tb_user_card_extract", key_index = "extract_id_u"},
					sys_card_extract	=	{name = "Tb_sys_card_extract", key_index = "extract_id_u"},
					sys_card_extract_combine	=	{name = "Tb_sys_card_extract_combine", key_index = "extract_id_u"},
					sys_card_extract_param	=	{name = "Tb_sys_card_extract_param", key_index = "extract_id"},
					user_card_newly 	= 	{name = "Tb_user_card_newly", key_index = "userid"},
					user_item 			= 	{name = "Tb_user_item", key_index = "userid"},
					user_union_attr 	=   {name = "Tb_user_union_attr", key_index = "user_id"},
					user_stuff 			= 	{name = "Tb_user_stuff", key_index = "userid"},
					user_guard 			= 	{name = "Tb_user_guard", key_index = "user_id"},
					task 				=   {name = "Tb_task", key_index = "task_id_u"},
					-- message_unread 		= 	{name = "Tb_message_unread", key_index = "userid"},
					report_attack 		=   {name = "Tb_battle_report_attack", key_index = "battle_id"},
					report_defend 		=   {name = "Tb_battle_report_defend", key_index = "battle_id"},
					user_world_event 	=   {name = "Tb_user_field_event", key_index = "userid"},
					union_invite 		= 	{name = "Tb_union_invite", key_index = "invite_id"},
					union_apply_notice 	= 	{name = "Tb_union_apply_notice", key_index = "userid"},
					user_revenue 		= 	{name = "Tb_user_revenue", key_index = "userid"},
					mail_receive        =   {name = "Tb_mail_receive", key_index = "id"},
					user_field_event_report =   {name = "Tb_user_field_event_report", key_index = "report_id"},
					user_login			=	{name = "Tb_user_login",key_index = "userid"},
					user_login_reward	=	{name = "Tb_user_login_reward",key_index = "userid"},
					user_exercise 		= 	{name = "Tb_user_exercise", key_index = "user_id"},
					user_exercise_land	=	{name = "Tb_user_exercise_land", key_index = "id"},
					user_exercise_record	=	{name = "Tb_user_exercise_record", key_index = "id"},
					game_log            =   {name = "Tb_game_log",key_index = "log_id"},
					battle_report_exersice = {name = "Tb_battle_report_exersice", key_index = "battle_id"},
				}

--刷新前数据状态记录，有些需要根据转变的过程做一些处理
--TODO 该部分现在先在更新时统一在整理一遍吧，后续需要保存的数据多了在根据数据变化类型进行部分刷新
dbRecordDesList = {}
dbRecordDesList[dbTableDesList.army.name] = {"armyid", "state", "front_heroid_u", "target_wid"}

recordTableData = {}

local function organize_record_data()
	for k,v in pairs(dbRecordDesList) do
		recordTableData[k] = {}
	end

	for k,v in pairs(dbRecordDesList) do
		for kk,vv in pairs(allTableData[k]) do
			recordTableData[k][kk] = {}
			for kkk,vvv in pairs(v) do
				recordTableData[k][kk][vvv] = vv[vvv]
			end
		end
	end
end

--初始值根据上面描述信息创建，后面对于数据的操作要依赖这个表头，如果存在该表可以操作，如果不存在不能操作
local function init_table_data(tempTableData)
	for k,v in pairs(dbTableDesList) do
		tempTableData[v.name] = {}
	end
end

local function get_key_index_by_table_name(table_name)
	for k,v in pairs(dbTableDesList) do
		if v.name == table_name then
			return v.key_index
		end
	end
	print("未找到对应表：" .. table_name)
	return ""
end

--解析收到的数据包打印所用
local temp_result = ""
local function print_table_content(temp_value)
	if type(temp_value) == "number" then
		--io.write(temp_value)
		temp_result = temp_result .. temp_value
	elseif type(temp_value) == "string" then
		--io.write(string.format("%q",temp_value))
		temp_result = temp_result .. temp_value
	elseif type(temp_value) == "table" then
		--io.write("{\n")
		temp_result = temp_result .. "{\n"
		for k,v in pairs(temp_value) do
			--io.write(" ",k," = ")
			temp_result = temp_result .. " " .. k .. " = "
			print_table_content(v)
			--io.write(",\n")
			temp_result = temp_result .. ",\n"
		end
		--io.write("}\n")
		temp_result = temp_result .. "}\n"
	else
		error("change error")
	end
end

--数据改变处理函数
--[[
{
 	{
 			1,
 			Tb_user,
 			{
 				userid = 7,
 				affilated_union_id = 1,
				}
		},

 	{
 			2,
 			Tb_user,
 			{
				 state = 0,
				 affilated_union_id = 0,
				 dominion_add = 833,
				 city_wid = 7620750,
				 yuan_bao_cur = 0,
				 land_count = 1,
				 dominion_time = 1386054231,
				 passport = abc,
				 password = ,
				 login_time = 1386145589,
				 off_time = 0,
				 union_id = 7,
				 dominion_cur = 20000,
				 yuan_bao_paid = 0,
				 userid = 8,
				 reg_time = 1386054231,
				}
		},

 	{
 			3,
 			Tb_sys_army,
 			76207501,
		}
}
]]

local function addData(change_name,change_data)
	if not allTableData[change_name] then
		print("该表数据未初始化：" .. change_name)
		return
	end

	local table_uid = get_key_index_by_table_name(change_name)
	local temp_index = change_data[table_uid]
	allTableData[change_name][temp_index] = change_data
end

local function updateData(change_name,change_data)
	if not allTableData[change_name] then
		print("该表数据未初始化：" .. change_name)
		return
	end

	if change_data == cjson.null then
		return
	end

	local table_uid = get_key_index_by_table_name(change_name)
	local temp_index = change_data[table_uid]
	local temp_table = allTableData[change_name][temp_index]
	if(temp_table == nil) then
		print("更新数据不存在:" .. change_name .. "  " .. temp_index)
		allTableData[change_name][temp_index] = change_data
	else
		for k,v in pairs(change_data) do
			if v ~= nil then
				temp_table[k] = v
			end
		end
	end
end

local function delData(change_name,change_data)
	if not allTableData[change_name] then
		print("该表数据未初始化：" .. change_name)
		return
	end
	
	allTableData[change_name][change_data] = nil
end

local function test_data()
	for k1,v1 in pairs(allTableData) do
		print(k1)
		for k2,v2 in pairs(v1) do
			print(" ",k2)
			for k3,v3 in pairs(v2) do
				print("    ",k3,v3)
			end
		end 
	end
end

local function deal_with_pro_update(packet)
	for i = 1,#packet do
		local temp_table = packet[i]
		local change_state = temp_table[1]
		local change_name = temp_table[2]
		local change_data = temp_table[3]

		--任务等待所有更新完成再一起刷新
		if change_name == "Tb_task" then
			task_flag = true
		else
			UIUpdateManager.call_prop_update(change_name,change_state,change_data)
		end
	end

	dbDataChange.organize_record_data()

	if task_flag then
		TaskData.taskUpdate()
		mainOption.taskTips()
	end
	--test_data()
end

local function changeData( packet )
	if not allTableData then
		allTableData = {}
		init_table_data(allTableData)
	end

	local task_flag = false
	for i = 1,#packet do
		local temp_table = packet[i]
		local change_state = temp_table[1]
		local change_name = temp_table[2]
		local change_data = temp_table[3]

		if change_state == dataChangeType.add then
			addData(change_name,change_data)
		elseif change_state == dataChangeType.update then
			updateData(change_name,change_data)
		elseif change_state == dataChangeType.remove then
			delData(change_name,change_data)
		end
		print("更改类型：" .. change_name .. " &&&&& " .. change_state)
		--UIUpdateManager.call_prop_update(change_name,change_state,change_data)
	end

	deal_with_pro_update(packet)
end

local function organize_temp_data(tempTableData, change_name,change_data)
	if not tempTableData[change_name] then
		return
	end

	if change_data == cjson.null then
		return
	end

	local table_uid = get_key_index_by_table_name(change_name)
	local temp_index = change_data[table_uid]
	local temp_table = tempTableData[change_name][temp_index]
	if(temp_table == nil) then
		tempTableData[change_name][temp_index] = change_data
	else
		for k,v in pairs(change_data) do
			if v ~= nil then
				temp_table[k] = v
			end
		end
	end
end

--检测两个表是否一样，只针对单一数据的表，嵌套表的不处理
local function is_same_pro_table(a_table, b_table)
	for k,v in pairs(a_table) do
		if not b_table[k] then
			return false
		else
			if v ~= b_table[k] then
				return false
			end
		end
	end

	for k,v in pairs(b_table) do
		if not a_table[k] then
			return false
		else
			if v ~= a_table[k] then
				return false
			end
		end
	end

	return true
end

local function set_user_data(packet)
	local change_packet = nil
	if initOrNot then
		local tempTableData = {}
		init_table_data(tempTableData)
		for first_k,first_v in pairs(packet) do
			for second_k,second_v in pairs(first_v[2]) do
				organize_temp_data(tempTableData, first_v[1], second_v)
			end
		end

		change_packet = {}
		for k,v in pairs(allTableData) do
			for kk,vv in pairs(v) do
				if not tempTableData[k][kk] then
					table.insert(change_packet,{3, k, kk})
				end
			end
		end

		for k,v in pairs(tempTableData) do
			for kk,vv in pairs(v) do
				if allTableData[k][kk] then
					if not is_same_pro_table(vv, allTableData[k][kk]) then
						table.insert(change_packet, {2, k, vv})
					end
				else
					table.insert(change_packet, {1, k, vv})
				end
			end
		end
	end
	
	allTableData = {}
	init_table_data(allTableData)
	for first_k,first_v in pairs(packet) do
		for second_k,second_v in pairs(first_v[2]) do
			organize_temp_data(allTableData, first_v[1], second_v)
		end
	end

	if change_packet then
		deal_with_pro_update(change_packet)
	end

	initOrNot = true
end

dbDataChange = {
					--init_table_data = init_table_data,
					organize_record_data = organize_record_data,
					set_user_data = set_user_data,
					addData = addData,
					updateData = updateData,
					delData = delData,
					changeData = changeData
				}


--[[
关于数据变化引起的UI显示需要刷新的方案
一 具体玩家数据变化引起的刷新
	1 以实际中存储的玩家数据整体为单位，或者说以一个数据表为单位，检测条件去刷新
	2 以单个具体的数据位单位进行刷新
针对两种分析：第一种具体一个数值的变化就会引起刷新，可能改数值不需要刷新面板（
			例如user表中自身联盟进行的变化，此时检测到改行数据变化可能会去刷新元宝等显示面板）
			第二种相对刷新更具体，但需要的框架会相当冗余，可读性变差
二 事件驱动方式的刷新
	某些操作会引起多种数据同时改变（可能是同一项的多个属性，也可能是多个项改变），此时为防止多次刷新造成的负担，需要定义一个对应事件，
接受到该事件时统一刷新一下显示界面

数据改变的形式初步确定为三种：增加数据，更新数据，删除数据

注意：实际应用中，尤其是开始开发过程中 这两种刷新的方案必然会存在很多耦合，需要在具体处理过程中自己考虑那种更合适
]]

--[[
具体实现过程中增加需要考虑的问题
2014.1.22
	在数据改变方式上有些不同的情况：大部分是指在数据更新时去调用对应处理函数  而在增加/删除数据时不需要
]]


--针对第一种刷新需要的代码框架
local prop_update_ui = {}

local function add_prop_update(name,update_type,update_fun)
	if not prop_update_ui[name] then
		prop_update_ui[name] = {}
	end

	if not prop_update_ui[name][update_type] then
		prop_update_ui[name][update_type] = {}
	end

	local is_in_list = false
	for i,v in ipairs(prop_update_ui[name][update_type]) do
		if v == update_fun then
			is_in_list = true
			break
		end
	end
	if not is_in_list then
		table.insert(prop_update_ui[name][update_type],update_fun)
	end
end
local function remove_prop_update(name,update_type,update_fun)
	if not prop_update_ui[name] then
		return
	end

	if not prop_update_ui[name][update_type] then
		return
	end

	for i,v in ipairs(prop_update_ui[name][update_type]) do
		if v == update_fun then
			table.remove(prop_update_ui[name][update_type],i)
			break
		end
	end
end
local function call_prop_update(name,update_type,update_data)
	if not prop_update_ui[name] then
		return
	end

	if not prop_update_ui[name][update_type] then
		return
	end

	for i,v in ipairs(prop_update_ui[name][update_type]) do
		v(update_data)
	end
end



--针对第二种刷新机制所需代码框架
local event_update_ui = {}

local function add_event_update(event_type, update_fun)
	if not event_update_ui[event_type] then
		event_update_ui[event_type] = {}
	end

	local is_in_list = false
	for i,v in ipairs(event_update_ui[event_type]) do
		if v == update_fun then
			is_in_list = true
			break
		end
	end
	if not is_in_list then
		table.insert(event_update_ui[event_type], update_fun)
	end
end
local function remove_event_update(event_type, update_fun)
	if not event_update_ui[event_type] then
		return
	end

	for i,v in ipairs(event_update_ui[event_type]) do
		if v == update_fun then
			table.remove(event_update_ui[event_type],i)
			break
		end
	end
end
local function call_event_update(event_type)
	if not event_update_ui[event_type] then
		return
	end

	for i,v in ipairs(event_update_ui[event_type]) do
		v()
	end
end

local function deal_with_a_1_1()
	print(1)
end

local function deal_with_a_1_2()
	print(2)
end

local function deal_with_a_1_3()
	print(3)
end

local function test()
	add_prop_update("a",1,deal_with_a_1_1)
	add_prop_update("a",1,deal_with_a_1_2)
	add_prop_update("a",1,deal_with_a_1_3)
	test_fun()
	remove_prop_update("a",1,deal_with_a_1_2)
	test_fun()
	print("---------------------------")
end

UIUpdateManager = {add_prop_update = add_prop_update,
					remove_prop_update = remove_prop_update,
					call_prop_update = call_prop_update,
					add_event_update = add_event_update,
					remove_event_update = remove_event_update,
					call_event_update = call_event_update,
					test = test
					}
