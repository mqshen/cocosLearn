--[[
该文件主要针对同步服务器配置数据再次处理所需
ConfigData.lua
是由服务器的配置文件转化生成的，所以一般看起来比较反人类（没有注释），有些值可能客户端需要的时候还需要二次加工

配置文件：
服务器传送的都是基本数据（可以简单理解成字符串），有些我们使用的时候要转化成table等等
--]]
--[[
ui_priority UI的装载层
com_guide_priority 非强制引导层次
guide_swallow_priority 指引中用来吞噬点击的层
guide_priority 真正的指引显示层
pos_priority 主要用来获取是否滑动以及最终位置获取
map_priority 地图层
global_priority 全局的touch监听，一定要最高优先级，不能有其他触摸高于他
--]]
layerPriorityList = {ui_priority = -129, ui_assist_priority = -130, com_guide_priority = -130, 
					guide_swallow_priority = -130, guide_priority = -131, pos_priority = -132, 
					guide_tool_priority = -133, map_object =0 ,map_priority = 1, global_priority = -999}

fightPowerParam = {bwh_xs = 10, dis_xs = 3, speed_xs = 5, soldier_xs = 15}
skillQualityParam = {}
skillQualityParam[1] = {50, 10}
skillQualityParam[2] = {75, 15}
skillQualityParam[3] = {75, 23}
skillQualityParam[4] = {80, 33}
skillQualityParam[5] = {90, 45}
skillQualityParam[6] = {100, 60}

-- landFightPower = {{2300,3450},{11500,13800},{14950,31050},{11500,69000},{77625,129375},{52900,349600},{80500,379500},{115000,402500},{201250,431250}}
-- landFightPower = {{4000,1000},{15000,10000},{17200,25800},{21250,63750},{28000,112000},{46800,213200},{52700,257300},{52800,277200},{52500,297500}}
landFightPower = {{4000,1000},{15000,10000},{17200,25800},{21250,63750},{27000,108000},{34200,155800},{38590,188410},{38400,201600},{38400,217600}}

--评价区间
fightPowerCMP = {1, 1.5, 2}

--出生选择武将显示描述
--[[
born_card_des_list = {
	languagePack["born_card_des_1"], 
	languagePack["born_card_des_2"], 
	languagePack["born_card_des_3"]
}
--]]

ARMY_MOVE_MAX_DISTANCE = 300 				--部队出征的最大格子数
ARMY_MAX_NUMS_IN_CITY = 5 					--城市中可以拥有的最大部队数量

skillOpenLvList = nil 						--卡牌技能开发的等级表

BUILD_EXPAND = 9                            --可扩建领地数

skillDetailList = {}
armyTitleList = {}

cardExtractPacket = {}
worldJoinList = {}

--获取掉落数量
local function getDorpCount(iResIdU, count )
	local iResId = iResIdU%100
	if iResId == dropType.RES_ID_RENOWN then
		return math.floor(count/100)
	else
		return count
	end
end

--获取掉落名字
local function getDorpName( iResIdU )
	local iResId = iResIdU%100
	if iResId == dropType.RES_ID_HERO then
		return Tb_cfg_hero[math.floor(iResIdU/100)].name
	elseif iResId == dropType.RES_ID_SKILL then
		return Tb_cfg_skill[math.floor(iResIdU/1000)].name
	elseif iResId == dropType.RES_ID_CARD_EXTRACT then
		return Tb_cfg_card_extract[math.floor(iResIdU/100)].refresh_name
	else
		return rewardName[iResIdU%100]
	end
end

local function process_config_data()
	require("game/dbData/ConfigData")
	-- TODOTK delete
	local SKILL_GRID_OPEN = { { 5,'5,3000;', },{ 15,'5,3000;', },{ 60,'5,3000;', }, }
	skillOpenLvList = {}
	table.insert(skillOpenLvList, 1)
	for k,v in pairs(SKILL_GRID_OPEN) do
		if #skillOpenLvList < 3 then
			table.insert(skillOpenLvList, v[1])
		end
	end
end

--返回关系对应的颜色
local function getRelationColor( relation)
	if relation == mapAreaRelation.free_enemy or relation == mapAreaRelation.attach_enemy then
		return "red"
	elseif relation == mapAreaRelation.own_self then
		return "green"
	else
		return "blue"
	end
end

--配置表相关处理
local function cfg_data_secondary_operation(data_table, child_list)
	for k,v in pairs(data_table) do
		for kk,vv in pairs(child_list) do
			v[vv] = stringFunc.anlayerMsg(v[vv])
		end
		data_table[k] = v
	end
end

local function cfg_data_rework(data_table, child_list)
	for k,v in pairs(data_table) do
		for kk,vv in pairs(child_list) do
			v[vv[1]] = stringFunc.anlayerOnespot(v[vv[1]], vv[2], vv[3])
		end
		data_table[k] = v
	end
end

--特殊处理找到某个技能对应的具体效果ID
local function deal_with_skill_detail()
	for k,v in pairs(Tb_cfg_skill_detail) do
		local temp_skill_id = math.floor(k/100)
		if not skillDetailList[temp_skill_id] then
			skillDetailList[temp_skill_id] = {}
		end
		table.insert(skillDetailList[temp_skill_id], k)
	end
end

--特殊处理部队称号部分
local function deal_with_army_title()
	for k,v in pairs(Tb_cfg_army_title) do
		local s_index = v.heroid_3 .. v.heroid_2 .. v.heroid_1
		armyTitleList[s_index] = k
	end
end

--特殊处理任务完成数量不符
local function deal_with_task_amount( )
	local temp_ = nil
	local condi = nil
	for k,v in pairs(Tb_cfg_task) do
		temp_ = stringFunc.anlayerOnespot(v.conditions,";", false)
		--任意一个
		-- if temp_[1] == "0" or temp_[1] == "2" then
			-- condi = stringFunc.anlayerOnespot(temp_[2],",", false)
			-- v.amounts = {condi[3]}
		-- elseif temp_[1] =="1" then
			v.amounts = {}
			for m, n in ipairs(temp_) do
				if m ~= 1 then
					condi = stringFunc.anlayerOnespot(n,",", false)
					table.insert(v.amounts, condi[2])
				end
			end
			Tb_cfg_task[k] = v
		-- end
	end
end

local function deal_with_progress()
	for k,v in pairs(Tb_cfg_progress) do
		if v["reward"] ~= "" then
			v["reward"] = stringFunc.anlayerMsg(v["reward"])
		end

		if v["reward_ratio"] ~= "" then
			v["reward_ratio"] = stringFunc.anlayerMsg(v["reward_ratio"])
		end

		if v["action"] ~= "" then
			v["action"] = stringFunc.anlayerMsg(v["action"])
		end

		if v['condition'] ~= "" then
			v['condition'] = stringFunc.anlayerOnespot(v['condition'], ",", true)
		end

		Tb_cfg_progress[k] = v
	end
end

local function deal_with_card_extract()
	for k,v in pairs(Tb_cfg_card_extract) do
		v["refresh_cost"] = stringFunc.anlayerMsg(v["refresh_cost"])
		if v["refresh_n"] ~= 0 then
			v["refresh_cost_n"] = stringFunc.anlayerMsg(v["refresh_cost_n"])
		end
		
		if v["quality_appear"] ~= "" then
			v["quality_appear"] = stringFunc.anlayerMsg(v["quality_appear"])
		end

		v["refresh_word"] = stringFunc.anlayerOnespot(v["refresh_word"], ",", true)
		Tb_cfg_card_extract[k] = v
	end
end

local function deal_with_card_extract_prob()
	local refresh_type, card_id = nil, nil
	for k,v in pairs(Tb_cfg_card_prob) do
	 	refresh_type = math.floor(k/1000000)
	 	card_id = k%1000000
	 	if not cardExtractPacket[refresh_type] then
	 		cardExtractPacket[refresh_type] = {}
	 	end
	 	table.insert(cardExtractPacket[refresh_type], card_id)
	end
end

local function deal_with_world_join()
	for k,v in pairs(Tb_cfg_world_join) do
		if not worldJoinList[v.target_wid] then
			worldJoinList[v.target_wid] = {}
		end

		table.insert(worldJoinList[v.target_wid], k)
	end
end

local function deal_with_card_extract_res()
	local temp_content = "\""
	for k,v in pairs(Tb_cfg_card_extract) do
		temp_content = temp_content .. v.name_img .. ".png\", \""
	end
	print(temp_content)
end

--卡牌头像需要特殊处理
local function deal_with_hero_rect()
	for k,v in pairs(Tb_cfg_hero_rect) do
		local temp_small = stringFunc.anlayerMsg(v.rect1)
		local small_x = temp_small[1][1]
		local small_y = temp_small[1][2]
		local small_width = temp_small[1][3]
		local small_height = temp_small[1][4]
		local small_scale = temp_small[1][5]
		small_y = 480 - small_y
		-- small_x = small_x + small_width/2
		-- small_y = small_y + small_height/2
		small_scale = small_scale/100

		small_width = small_width/small_scale
		small_height = small_height/small_scale

		-- small_x = small_x - small_width/2
		-- small_y = small_y - small_height/2

		v[1] = {small_x, small_y, small_width, small_height, small_scale}

		local temp_middle = stringFunc.anlayerMsg(v.rect2)
		local middle_x = temp_middle[1][1]
		local middle_y = temp_middle[1][2]
		local middle_width = temp_middle[1][3]
		local middle_height = temp_middle[1][4]
		local middle_scale = temp_middle[1][5]
		middle_y = 480 - middle_y
		-- middle_x = middle_x + middle_width/2
		-- middle_y = middle_y + middle_height/2
		middle_scale = middle_scale/100

		middle_width = middle_width/middle_scale
		middle_height = middle_height/middle_scale

		-- middle_x = middle_x - middle_width/2
		-- middle_y = middle_y - middle_height/2

		v[2] = {middle_x, middle_y, middle_width, middle_height, middle_scale}

		if v.rect3 == "" then
			v[3] = v.rect3
		else
			local temp_call_card_info = stringFunc.anlayerMsg(v.rect3)
			local call_x = temp_call_card_info[1][1]
			local call_y = temp_call_card_info[1][2]
			local call_width = temp_call_card_info[1][3]
			local call_height = temp_call_card_info[1][4]
			local call_scale = temp_call_card_info[1][5]
			call_y = 480 - call_y
			-- call_x = call_x + call_width/2
			-- call_y = call_y + call_height/2
			call_scale = call_scale/100

			call_width = call_width/call_scale
			call_height = call_height/call_scale

			-- call_x = call_x - call_width/2
			-- call_y = call_y - call_height/2

			v[3] = {call_x, call_y, call_width, call_height, call_scale}
		end

		if v.rect4 == "" then
			v[4] = v.rect4
		else
			local temp_call_card_info = stringFunc.anlayerMsg(v.rect4)
			local call_x = temp_call_card_info[1][1]
			local call_y = temp_call_card_info[1][2]
			local call_width = temp_call_card_info[1][3]
			local call_height = temp_call_card_info[1][4]
			local call_scale = temp_call_card_info[1][5]
			call_y = 480 - call_y
			-- call_x = call_x 
			call_scale = call_scale/100

			call_width = call_width/call_scale
			call_height = call_height/call_scale

			v[4] = {call_x, call_y, call_width, call_height, call_scale}
		end

		Tb_cfg_hero_rect[k] = v
	end
end


local function parseActivityConditions(str_conditions)
	ret = stringFunc.stringSplit(str_conditions, "#", 1, string.len(str_conditions))
	local tmp = nil
	local cdt = nil
	local tmp_tb = nil
	for k,v in pairs(ret) do 
		if k == 1 then
			ret[k] = tonumber(v)
		else
			tmp = stringFunc.anlayerOnespot(v,";",false)
			
			tmp_tb = {}
			for m,n in ipairs(tmp) do 
				cdt = stringFunc.anlayerOnespot(n,",",true)
				table.insert(tmp_tb , cdt)
			end
			ret[k] = tmp_tb
		end
	end
	return ret
end

local function parseActivityRewards(str_rewards)
	ret = stringFunc.stringSplit(str_rewards, "#", 1, string.len(str_rewards))
	local tmp = nil
	local cdt = nil
	local tmp_tb = nil
	for k,v in pairs(ret) do 
		tmp = stringFunc.anlayerOnespot(v,";",false)
		tmp_tb = {}
		for m,n in ipairs(tmp) do 
			cdt = stringFunc.anlayerOnespot(n,",",true)
			table.insert(tmp_tb , cdt)
		end
		ret[k] = tmp_tb
	end
	return ret
end


local function parseActivityData()
	for k,v in pairs(Tb_cfg_activity) do 
		v.conditions = parseActivityConditions( v.conditions)
		v.rewards = parseActivityRewards( v.rewards)
		Tb_cfg_activity[k] = v
	end
end

--有些表示服务器用的，现在客户端没用到，先注释掉，或许客户端如果需要在打开
local function process_tb_cfg()
	--require("game/dbData/cfg/Tb_cfg_army")
	require("game/dbData/cfg/Tb_cfg_army_count")
	require("game/dbData/cfg/Tb_cfg_army_title")
	--require("game/dbData/cfg/Tb_cfg_battle_drop")
	--require("game/dbData/cfg/Tb_cfg_battle_drop_hero")
	require("game/dbData/cfg/Tb_cfg_build")
	require("game/dbData/cfg/Tb_cfg_build_cost")
	require("game/dbData/cfg/Tb_cfg_build_effect")
	-- require("game/dbData/cfg/Tb_cfg_build_area")
	require("game/dbData/cfg/Tb_cfg_card_extract")
	require("game/dbData/cfg/Tb_cfg_card_prob")
	require("game/dbData/cfg/Tb_cfg_city_renown")
	require("game/dbData/cfg/Tb_cfg_fort_renown")
	require("game/dbData/cfg/Tb_cfg_hero")
	require("game/dbData/cfg/Tb_cfg_hero_level")
	require("game/dbData/cfg/Tb_cfg_hero_rect")
	--require("game/dbData/cfg/Tb_cfg_hero_u")
	require("game/dbData/cfg/Tb_cfg_npc_add")
	--require("game/dbData/cfg/Tb_cfg_param")
	require("game/dbData/cfg/Tb_cfg_region")
	require("game/dbData/cfg/Tb_cfg_res_output")
	require("game/dbData/cfg/Tb_cfg_skill")
	require("game/dbData/cfg/Tb_cfg_skill_detail")
	require("game/dbData/cfg/Tb_cfg_skill_effect")
	require("game/dbData/cfg/Tb_cfg_skill_learn")
	require("game/dbData/cfg/Tb_cfg_skill_research")
	require("game/dbData/cfg/Tb_cfg_skill_level")
	require("game/dbData/cfg/Tb_cfg_skill_prob")
	require("game/dbData/cfg/Tb_cfg_battle_drop")
	require("game/dbData/cfg/Tb_cfg_village")
	require("game/dbData/cfg/Tb_cfg_activity")
	
	--require("game/dbData/cfg/Tb_cfg_skill_random")
	require("game/dbData/cfg/Tb_cfg_task")
	require("game/dbData/cfg/Tb_cfg_union_level")
	--require("game/dbData/cfg/Tb_cfg_union_official")
	require("game/dbData/cfg/Tb_cfg_world_anchor")
	require("game/dbData/cfg/Tb_cfg_world_city")
	require("game/dbData/cfg/Tb_cfg_world_join")
	require("game/dbData/cfg/Tb_cfg_login_reward")
	require("game/dbData/cfg/Tb_cfg_client_mini_map_region")
	require("game/dbData/cfg/Tb_cfg_client_mini_map_name")
	require("game/dbData/cfg/Tb_cfg_npc_city_occupy_reward")

	require("game/dbData/cfg/Tb_cfg_progress")

	require("game/dbData/cfg/Tb_cfg_exercise")
	require("game/dbData/cfg/Tb_cfg_exercise_army")
	require("game/dbData/cfg/Tb_cfg_goods")
	require("game/dbData/cfg/Tb_cfg_region_connection")
	deal_with_hero_rect()
	deal_with_skill_detail()
	deal_with_army_title()
	deal_with_task_amount()
	deal_with_card_extract()
	deal_with_card_extract_prob()
	deal_with_world_join()
	deal_with_progress()

	--deal_with_card_extract_res()

	cfg_data_secondary_operation(Tb_cfg_build, {"pre_condition"})
	cfg_data_secondary_operation(Tb_cfg_build_cost, {"effect", "res_cost"})
	--cfg_data_secondary_operation(Tb_cfg_card_extract, {"refresh_cost", "recruit_cost"})
	cfg_data_secondary_operation(Tb_cfg_hero, {"recruit_cost","awake_cost"})
	cfg_data_secondary_operation(Tb_cfg_res_output, {"res_output"})
	cfg_data_secondary_operation(Tb_cfg_skill_prob, {"prob", "prob_ex"})
	cfg_data_secondary_operation(Tb_cfg_task, {"rewards"})
	cfg_data_secondary_operation(Tb_cfg_battle_drop, {"drops"})
	cfg_data_secondary_operation(Tb_cfg_login_reward,{"rewards"})
	cfg_data_secondary_operation(Tb_cfg_npc_city_occupy_reward,{"drops"})
	cfg_data_secondary_operation(Tb_cfg_client_mini_map_name,{"pos"})
	-- cfg_data_secondary_operation(Tb_cfg_activity,{"rewards"})
	cfg_data_rework(Tb_cfg_client_mini_map_region,{
		{"pos", ",", true},
		{"left_up_pos", ",", true},
		})

	cfg_data_rework(Tb_cfg_skill_research,{
		{"improve_heroid",",",true},
		{"improve_quality",",",true},
		{"improve_country",",",true},
		{"improve_type",",",true},
		{"allow_type",",",true},
		{"allow_country",",",true},
		{"allow_quality",",",true},
		})
	cfg_data_rework(Tb_cfg_skill_learn, {{"learn", ";", true}})
	cfg_data_rework(Tb_cfg_task, {{"condition_name", ";", false}})
	parseActivityData()
end

clientConfigData = {
						process_config_data = process_config_data,
						process_tb_cfg = process_tb_cfg,
						getDorpCount = getDorpCount,
						getDorpName = getDorpName,
						getRelationColor = getRelationColor
					}