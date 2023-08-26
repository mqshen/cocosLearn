local function getTeamMsg(teamId)
	return allTableData[dbTableDesList.army.name][teamId]
end

local function getAllTeamMsg( )
	return allTableData[dbTableDesList.army.name]
end

local function getAssaultTeamMsg(teamId)
	for i, v in pairs(allTableData[dbTableDesList.army_alert.name]) do
		if v.armyid == teamId then
			return v
		end
	end
	return false
end

local function getAllAssaultMsg()
	return allTableData[dbTableDesList.army_alert.name]
end

--根据行动点以及速度获取行动距离以及时间
local function getMoveShowInfo(from_pos, to_pos, speed)
	local src_x = math.floor(from_pos/10000)
	local src_y = from_pos%10000
	local dst_x = math.floor(to_pos/10000)
	local dst_y = to_pos%10000
	
	local distance = math.sqrt(math.pow(src_x - dst_x, 2) + math.pow(src_y - dst_y, 2))
	local need_time = math.floor(distance/speed * 3600 * 100)
	return distance, need_time
end

--判断部队是否可用，如果city_id为0则只检测部队以及卡牌状态，如果不为0则需要判断该部队是否可用在该城市行动
local function is_army_can_used(army_id, city_id)
	local army_info = getTeamMsg(army_id)
	if not army_info then
		return false
	end

	if army_info.state == armyState.normal or army_info.state == armyState.zhuzhaed then
		if army_info.base_heroid_u ~= 0 then
			if not heroData.is_hero_can_move(army_info.base_heroid_u) then
				return false
			end
		end

		if army_info.middle_heroid_u ~= 0 then
			if not heroData.is_hero_can_move(army_info.middle_heroid_u) then
				return false
			end
		end

		if army_info.front_heroid_u ~= 0 then
			if not heroData.is_hero_can_move(army_info.front_heroid_u) then
				return false
			end
		end

		if city_id ~= 0 and army_info.reside_wid ~= city_id then
			return false
		end

		return true
	else
		return false
	end
end

local function getCanUseNumInArmyList(army_list, city_id)
	local can_used_num = 0
	for i,v in ipairs(army_list) do
		if is_army_can_used(v, city_id) then
			can_used_num = can_used_num + 1
		end
	end

	return can_used_num
end

local function getMainOrBranchArmyList(city_id)
	local army_list = {}
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		local army_id = city_id * 10 + i
		local team_info = getTeamMsg(army_id)
		if team_info and team_info.base_heroid_u ~= 0 then
			table.insert(army_list, army_id)
		end
	end

	return army_list
end

local function fort_army_order_rule(army_id_a, army_id_b)
	local temp_army_a = getTeamMsg(army_id_a)
	local temp_army_b = getTeamMsg(army_id_b)
	if temp_army_a.reside_time <= temp_army_b.reside_time then
		return true
	else
		return false
	end
end

local function getFortArmyList(fort_id)
	local army_list = {}
	for k,v in pairs(allTableData[dbTableDesList.army.name]) do
		if v.reside_wid == fort_id and v.base_heroid_u ~= 0 then
			table.insert(army_list, k)
		end
	end

	table.sort(army_list, fort_army_order_rule)

	return army_list
end

local function getNpcYaosaiArmyList(city_id )
	local army_list = {}
	for k,v in pairs(allTableData[dbTableDesList.army.name]) do
		if v.reside_wid == city_id and v.base_heroid_u ~= 0 then
			table.insert(army_list, k)
		end
	end

	table.sort(army_list, fort_army_order_rule)

	return army_list
end

local function getStayFortArmyList(fort_id )
	local army_list = {}
	for k,v in pairs(allTableData[dbTableDesList.army.name]) do
		if v.reside_wid == fort_id and v.base_heroid_u ~= 0 and v.state == armyState.zhuzhaed then
			table.insert(army_list, k)
		end
	end

	-- table.sort(army_list, fort_army_order_rule)

	return army_list
end

--获取城市中
local function getAllArmyInCity(city_id)
	local new_type = landData.get_city_type_by_id(city_id)
	if new_type then
		if new_type == cityTypeDefine.yaosai then
			return getFortArmyList(city_id)
		elseif new_type == cityTypeDefine.npc_yaosai then
			return getNpcYaosaiArmyList(city_id )
		else
			return getMainOrBranchArmyList(city_id)
		end
	else
		return {}
	end
end

-- 检查目标要塞是否还有位置可调动
local function isHasResidePosInFort(fort_id)
	
	-- 已经驻扎在里边的
	local armyList = getAllArmyInCity(fort_id)
	local residedCount = 0
	for k,v in ipairs(armyList) do 
		if allTableData[dbTableDesList.army.name][v].state ~= 2 then 
			residedCount = residedCount + 1
		end
	end

	local resdingInCount = 0
	for k,v in pairs(allTableData[dbTableDesList.army.name]) do
		if v.target_wid == fort_id and v.state == 2 then
			resdingInCount = resdingInCount + 1
		end
	end
	

	local maxCount = 0
   	local city_info = userCityData.getUserCityData(fort_id)
   	if city_info then
   		maxCount = userCityData.getCityBuildEffectData(fort_id).reside_max
   	end
 --   	if city_info and city_info.city_type== cityTypeDefine.npc_yaosai then
 --   		if Tb_cfg_world_city[fort_id] then
 --   			local level = Tb_cfg_world_city[fort_id].param%10
 --   			if level == 0 then
 --   				level = 10
 --   			end
 --   			-- 野外兵营
 --   			if Tb_cfg_world_city[fort_id].param >= NPC_FORT_TYPE_RECRUIT[1] and Tb_cfg_world_city[fort_id].param <= NPC_FORT_TYPE_RECRUIT[2] then
 --   				maxCount = NPC_RECRUIT_RESIDE_MAX[level]
 --   			else
 --   				maxCount = NPC_FORT_RESIDE_MAX[level]
 --   			end
 --   		end
 --   	else
	-- 	local bid = cityBuildDefine.baolei
	--     local buildCfgInfo = Tb_cfg_build[bid]
	--     local blv = politics.getBuildLevel(fort_id, bid)
	--     local showBuildLevelId = bid*100 + blv
	--     if blv >= buildCfgInfo.max_level then
	--         showBuildLevelId = showBuildLevelId + 1
	--     end
	   	
	--    	if Tb_cfg_build_cost[showBuildLevelId] then 
	-- 	    for k,v in pairs(Tb_cfg_build_cost[showBuildLevelId].effect) do
	-- 	    	if v[1] == 112 then 
	-- 	    		maxCount = maxCount + v[2]
	-- 	    	end
	-- 	    end
	-- 	end
	-- end

	return maxCount > (resdingInCount + residedCount)
end

--获取城市队伍配置了军师或前锋的数量
local function getCountForMidAndCounsellor( city_wid)
	local qianfeng_count, junshi_count = 0, 0
	local army_id, team_info = nil, nil
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		army_id = city_wid * 10 + i
		team_info = getTeamMsg(army_id)
		if team_info then
			if team_info.front_heroid_u ~= 0 then
				qianfeng_count = qianfeng_count + 1
			end
			if team_info.counsellor_heroid_u ~= 0 then
				junshi_count = junshi_count + 1
			end
		end
	end
	return junshi_count, qianfeng_count
end

--获取有城市有武将的队伍
local function getArmyListInCity(city_wid)
	local army_list = {}
	for k,v in pairs(allTableData[dbTableDesList.army.name]) do
		if v.reside_wid == city_wid then
			if v.front_heroid_u ~= 0 or v.middle_heroid_u ~= 0 or v.base_heroid_u ~= 0 or v.counsellor_heroid_u ~= 0 then
				table.insert(army_list, v.armyid)
			end
		end
	end

	return army_list
end

--城市是否有创建部队
local function getChildArmyMaxNumInCity(city_id)
	local result_num = 0
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		local army_id = city_id * 10 + i
		local team_info = getTeamMsg(army_id)
		if team_info then
			result_num = i
		end
	end

	return result_num
end

local function isEquipCountryCardInArmy(army_id, new_country)
	local team_info = getTeamMsg(army_id)
	if not team_info then
		return false
	end

	if team_info.base_heroid_u ~= 0 then
		if heroData.get_hero_country(team_info.base_heroid_u) == new_country then
			return true
		end
	end

	if team_info.middle_heroid_u ~= 0 then
		if heroData.get_hero_country(team_info.middle_heroid_u) == new_country then
			return true
		end
	end

	if team_info.front_heroid_u ~= 0 then
		if heroData.get_hero_country(team_info.front_heroid_u) == new_country then
			return true
		end
	end

	if team_info.counsellor_heroid_u ~= 0 then
		if heroData.get_hero_country(team_info.counsellor_heroid_u) == new_country then
			return true
		end
	end

	return false
end

--城市中的部队是否有指定国家的卡片
local function isEquipCardForCountryInCity(city_id, new_country)
	local is_in_army = false
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		local army_id = city_id * 10 + i
		local temp_result = isEquipCountryCardInArmy(army_id, new_country)
		if temp_result then
			is_in_army = true
			break
		end
	end

	return is_in_army
end

--城市中是否有部队配备了前锋或者军师
local function isEquipCardForPosInCity(city_id)
	local is_have_qianfeng, is_have_junshi = false, false
	local army_id, team_info = nil, nil
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		army_id = city_id * 10 + i
		team_info = getTeamMsg(army_id)
		if team_info then
			if team_info.front_heroid_u ~= 0 then
				is_have_qianfeng = true
			end
			if team_info.counsellor_heroid_u ~= 0 then
				is_have_junshi = true
			end
		end
	end

	return is_have_qianfeng, is_have_junshi
end

--获取指定队伍指定位置的英雄ID
local function getHeroIdInTeamAndPos(team_id, pos_index)
	if pos_index < 0 or pos_index > 4 then
		return 0
	end

	local team_info = getTeamMsg(team_id)
	if team_info then
		if pos_index == 0 then
			return team_info.counsellor_heroid_u
		elseif pos_index == 1 then
			return team_info.base_heroid_u
		elseif pos_index == 2 then
			return team_info.middle_heroid_u
		elseif pos_index == 3 then
			return team_info.front_heroid_u
		end
	else
		return 0
	end
end
--获取某个英雄所处的队伍ID以及在队伍中的位置
local function getArmyIdAndPosByHero(hero_uid)
	local team_id = heroData.getHeroArmyId(hero_uid)
	if team_id == 0 then
		return 0, 0
	else
		local team_info = getTeamMsg(team_id)
		if team_info.counsellor_heroid_u == hero_uid then
			return team_id, 0
		elseif team_info.base_heroid_u == hero_uid then
			return team_id, 1
		elseif team_info.middle_heroid_u == hero_uid then
			return team_id, 2
		elseif team_info.front_heroid_u == hero_uid then
			return team_id, 3
		end
	end
end

--判断部队中是否有同类型的卡牌
local function isOriginalHeroInTeam(team_id, hero_id)
	local team_info = getTeamMsg(team_id)
	if not team_info then
		return false
	end

	local in_state = false
	local hero_info = nil
	if team_info.base_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.base_heroid_u)
		if hero_info.heroid == hero_id then
			in_state = true
		end
	end

	if team_info.middle_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.middle_heroid_u)
		if hero_info.heroid == hero_id then
			in_state = true
		end
	end

	if team_info.front_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.front_heroid_u)
		if hero_info.heroid == hero_id then
			in_state = true
		end
	end

	if team_info.counsellor_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.counsellor_heroid_u)
		if hero_info.heroid == hero_id then
			in_state = true
		end
	end

	return in_state
end

--策划设计的是卡片只能在所有部队中一张，原本以为是只能在一个部队中一张
local function isOriginalHeroEquiped(hero_uid)
	local hero_info = heroData.getHeroInfo(hero_uid)
	local hero_id = hero_info.heroid

	local in_state = false
	for k,v in pairs(allTableData[dbTableDesList.army.name]) do
		in_state = isOriginalHeroInTeam(k, hero_id)
		if in_state then
			break
		end
	end

	return in_state
end

local function getTeamHeroContent(teamId)
	local team_info = getTeamMsg(teamId)
	local show_hero_name = "default_hero"
	local show_hero_nums = 0
	if team_info.base_heroid_u ~= 0 then
		local temp_hero_info = heroData.getHeroInfo(team_info.base_heroid_u)
		show_hero_name = Tb_cfg_hero[temp_hero_info.heroid].name
		show_hero_nums = show_hero_nums + 1
	end

	if team_info.middle_heroid_u ~= 0 then
		show_hero_nums = show_hero_nums + 1
	end

	if team_info.front_heroid_u ~= 0 then
		show_hero_nums = show_hero_nums + 1
	end

	if team_info.counsellor_heroid_u ~= 0 then
		show_hero_nums = show_hero_nums + 1
	end

	local result = show_hero_name
	if show_hero_nums == 2 then
		result = result .. languagePack["deng"] .. languagePack["two"] .. languagePack["people"]
	elseif show_hero_nums == 3 then
		result = result .. languagePack["deng"] .. languagePack["three"] .. languagePack["people"]
	elseif show_hero_nums == 4 then
		result = result .. languagePack["deng"] .. languagePack["four"] .. languagePack["people"]
	end

	return result
end

local function getTeamSpeed(teamId)
	local team_info = getTeamMsg(teamId)
	if not team_info then
		return 0, 0
	end

	local min_speed, hero_speed = 0, 0

	if team_info.base_heroid_u ~= 0 then
		hero_speed = heroData.getHeroSpeed(team_info.base_heroid_u)
		if min_speed == 0 then
			min_speed = hero_speed
		else
			if min_speed > hero_speed then
				min_speed = hero_speed
			end
		end
	end

	if team_info.middle_heroid_u ~= 0 then
		hero_speed = heroData.getHeroSpeed(team_info.middle_heroid_u)
		if min_speed == 0 then
			min_speed = hero_speed
		else
			if min_speed > hero_speed then
				min_speed = hero_speed
			end
		end
	end

	if team_info.front_heroid_u ~= 0 then
		hero_speed = heroData.getHeroSpeed(team_info.front_heroid_u)
		if min_speed == 0 then
			min_speed = hero_speed
		else
			if min_speed > hero_speed then
				min_speed = hero_speed
			end
		end
	end

	return min_speed, team_info.speed
end

local function getTeamDestroy(teamId)
	local team_info = getTeamMsg(teamId)
	if not team_info then
		return 0
	end
	
	return heroData.getHeroDestroy(team_info.base_heroid_u) + heroData.getHeroDestroy(team_info.middle_heroid_u) + heroData.getHeroDestroy(team_info.front_heroid_u)
end

local function getTeamHp(teamId)
	local team_info = getTeamMsg(teamId)
	if not team_info then
		return 0
	end
	
	local all_hp = 0
	all_hp = all_hp + heroData.getHeroHp(team_info.base_heroid_u) + heroData.getHeroHp(team_info.middle_heroid_u) + heroData.getHeroHp(team_info.front_heroid_u)
	return all_hp
end

local function getTeamCost(teamId)
	local team_info = getTeamMsg(teamId)
	if not team_info then
		return 0
	end

	local all_cost = 0
	local hero_info = nil
	if team_info.base_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.base_heroid_u)
		all_cost = all_cost + Tb_cfg_hero[hero_info.heroid].cost/10
	end

	if team_info.middle_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.middle_heroid_u)
		all_cost = all_cost + Tb_cfg_hero[hero_info.heroid].cost/10
	end

	if team_info.front_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.front_heroid_u)
		all_cost = all_cost + Tb_cfg_hero[hero_info.heroid].cost/10
	end

	--策划说军师的cost不计入部队的cost和值
	--[[
	if team_info.counsellor_heroid_u ~= 0 then
		hero_info = heroData.getHeroInfo(team_info.counsellor_heroid_u)
		all_cost = all_cost + Tb_cfg_hero[hero_info.heroid].cost/10
	end
	--]]

	return all_cost
end

local function getTeamFightPower(teamId)
	local all_fight_num = 0
	local team_info = getTeamMsg(teamId)
	if team_info.base_heroid_u ~= 0 then
		all_fight_num = all_fight_num + heroData.getHeroFightPower(team_info.base_heroid_u)
	end

	if team_info.middle_heroid_u ~= 0 then
		all_fight_num = all_fight_num + heroData.getHeroFightPower(team_info.middle_heroid_u)
	end

	if team_info.front_heroid_u ~= 0 then
		all_fight_num = all_fight_num + heroData.getHeroFightPower(team_info.front_heroid_u)
	end

	if team_info.counsellor_heroid_u ~= 0 then
		all_fight_num = all_fight_num + heroData.getHeroFightPower(team_info.counsellor_heroid_u)
	end

	return all_fight_num
end

--获取部队是否能出征等的状态 0 可以调动；1 没有大营武将；2 部队或者卡牌状态不满足（体力单独提示）；3 体力不足
local function getTeamCanMoveState(teamId)
	local team_info = getTeamMsg(teamId)
	if team_info.base_heroid_u == 0 then
		return 1
	end

	if team_info.state ~= armyState.normal and team_info.state ~= armyState.zhuzhaed then
		return 2
	end

	local hero_info, hero_energy_num = nil, nil
	if team_info.base_heroid_u ~= 0 then
		hero_energy_num = heroData.getHeroEnergy(team_info.base_heroid_u)
		if hero_energy_num < userData.getHeroEneryMoveNeed() then
			return 3
		end
		hero_info = heroData.getHeroInfo(team_info.base_heroid_u)
		if hero_info.state == cardState.zhengbing or hero_info.hurt_end_time ~= 0 then
			return 2
		end
	end

	if team_info.middle_heroid_u ~= 0 then
		hero_energy_num = heroData.getHeroEnergy(team_info.middle_heroid_u)
		if hero_energy_num < userData.getHeroEneryMoveNeed() then
			return 3
		end
		hero_info = heroData.getHeroInfo(team_info.middle_heroid_u)
		if hero_info.state == cardState.zhengbing or hero_info.hurt_end_time ~= 0 then
			return 2
		end
	end

	if team_info.front_heroid_u ~= 0 then
		hero_energy_num = heroData.getHeroEnergy(team_info.front_heroid_u)
		if hero_energy_num < userData.getHeroEneryMoveNeed() then
			return 3
		end
		hero_info = heroData.getHeroInfo(team_info.front_heroid_u)
		if hero_info.state == cardState.zhengbing or hero_info.hurt_end_time ~= 0 then
			return 2
		end
	end

	if team_info.counsellor_heroid_u ~= 0 then
		hero_energy_num = heroData.getHeroEnergy(team_info.counsellor_heroid_u)
		if hero_energy_num < userData.getHeroEneryMoveNeed() then
			return 3
		end
		hero_info = heroData.getHeroInfo(team_info.counsellor_heroid_u)
		if hero_info.state == cardState.zhengbing or hero_info.hurt_end_time ~= 0 then
			return 2
		end
	end

	return 0
end

local function getTeamNeedZb(teamId)
	local team_info = getTeamMsg(teamId)
	if not team_info then
		return false
	end

	if team_info.front_heroid_u ~= 0 then
		if not heroData.isFullHp(team_info.front_heroid_u) then
			return true
		end
   	end

   	if team_info.middle_heroid_u ~= 0 then
   		if not heroData.isFullHp(team_info.middle_heroid_u) then
   			return true
   		end
   	end

   	if team_info.base_heroid_u ~= 0 then
   		if not heroData.isFullHp(team_info.base_heroid_u) then
   			return true
   		end
   	end

   	if team_info.counsellor_heroid_u ~= 0 then
   		if not heroData.isFullHp(team_info.counsellor_heroid_u) then
   			return true
   		end
   	end

   	return false
end

--获取部队是否有武将在征兵
local function getTeamZbState(teamId)
	local team_info = getTeamMsg(teamId)
	if not team_info then
		return false
	end

	if team_info.front_heroid_u ~= 0 then
   		if heroData.getHeroZbState(team_info.front_heroid_u) then
   			return true
   		end
   	end

   	if team_info.middle_heroid_u ~= 0 then
   		if heroData.getHeroZbState(team_info.middle_heroid_u) then
   			return true
   		end
   	end

   	if team_info.base_heroid_u ~= 0 then
   		if heroData.getHeroZbState(team_info.base_heroid_u) then
   			return true
   		end
   	end

   	if team_info.counsellor_heroid_u ~= 0 then
   		if heroData.getHeroZbState(team_info.counsellor_heroid_u) then
   			return true
   		end
   	end

   	return false
end

--获取部队中是否有武将重伤
local function getTeamHurtState(teamId)
	local team_info = getTeamMsg(teamId)

	if team_info.front_heroid_u ~= 0 then
   		if heroData.getHeroHurtState(team_info.front_heroid_u) then
   			return true
   		end
   	end

   	if team_info.middle_heroid_u ~= 0 then
   		if heroData.getHeroHurtState(team_info.middle_heroid_u) then
   			return true
   		end
   	end

   	if team_info.base_heroid_u ~= 0 then
   		if heroData.getHeroHurtState(team_info.base_heroid_u) then
   			return true
   		end
   	end

   	if team_info.counsellor_heroid_u ~= 0 then
   		if heroData.getHeroHurtState(team_info.counsellor_heroid_u) then
   			return true
   		end
   	end

   	return false
end

--获取部队中是否有武将疲劳
local function getTeamNoenergyState(teamId)
	local team_info = getTeamMsg(teamId)

	if team_info.front_heroid_u ~= 0 then
   		if heroData.getHeroNoenergyState(team_info.front_heroid_u) then
   			return true
   		end
   	end

   	if team_info.middle_heroid_u ~= 0 then
   		if heroData.getHeroNoenergyState(team_info.middle_heroid_u) then
   			return true
   		end
   	end

   	if team_info.base_heroid_u ~= 0 then
   		if heroData.getHeroNoenergyState(team_info.base_heroid_u) then
   			return true
   		end
   	end

   	if team_info.counsellor_heroid_u ~= 0 then
   		if heroData.getHeroNoenergyState(team_info.counsellor_heroid_u) then
   			return true
   		end
   	end

   	return false
end

--获取部队所在城市的征兵队列剩余数和最大数
local function get_army_city_zb_queue_num(temp_army_id)
	local team_info = getTeamMsg(temp_army_id)
	if not team_info then
		return 0, 0
	end

	local temp_city_id = nil
	local temp_army_state = team_info.state
	if temp_army_state == armyState.normal then
		temp_city_id = math.floor(temp_army_id/10)
	elseif temp_army_state == armyState.zhuzhaed then
		temp_city_id = team_info.reside_wid
	else
		return 0, 0
	end

	local leave_nums = userCityData.get_leave_zb_queue_in_city(temp_city_id)
	local all_queue_num = userCityData.get_all_zb_queue_num(temp_city_id)
	return leave_nums, all_queue_num
end

--获取城市中部队征兵按钮显示的状态
-- 0 可以进入征兵面板；1 未建造募兵所；2 部队配置问题；3 部队状态问题
local function getTeamZbBtnState(temp_army_id)
	local own_city_id = math.floor(temp_army_id/10)
	
	local team_info = getTeamMsg(temp_army_id)
	if not team_info then
		return 2
	end
	if team_info.base_heroid_u == 0 then
		return 2
	end

	if getTeamZbState(temp_army_id) then
		return 0
	end

	local effect_build_level = politics.getBuildLevel(own_city_id, cityBuildDefine.mubingsuo)
	if effect_build_level == 0 then
		return 1
	end

	local temp_army_state = team_info.state
	if temp_army_state == armyState.normal or temp_army_state == armyState.zhuzhaed then
		return 0
	else
		return 3
	end
end

--获取部队头像中部队状态显示相关
----行军，返回，驻守，待命，征兵，重伤，疲劳
local function getTeamIconState(temp_army_id)
	local temp_army_info = getTeamMsg(temp_army_id)
	if not temp_army_info then
		return 0
	end

	if getTeamZbState(temp_army_id) then
		return 5
	end

	local temp_army_state = temp_army_info.state
	if temp_army_state == armyState.normal or temp_army_state == armyState.zhuzhaed then
		if getTeamHurtState(temp_army_id) then
			return 6
		else
			if getTeamNoenergyState(temp_army_id) then
				return 7
			else
				if temp_army_state == armyState.zhuzhaed then
					return 4
				else
					return 0
				end
			end
		end
	elseif temp_army_state == armyState.returning then
		return 2
	elseif temp_army_state == armyState.yuanjuned then
		return 3
	else
		return 1
	end
end

--对于调动出去的部队要判断是在原城市还是在实际所在城市的状态
local function getTeamStateType(temp_army_id, temp_city_id)
	local temp_army_info = getTeamMsg(temp_army_id)
	if not temp_army_info then
		return 0
	end

	if temp_army_info.reside_wid == temp_city_id then
		return getTeamIconState(temp_army_id)
	else
		--调动
		return 8
	end
end

local function organizeHeroInfoInTeam(temp_team)
	local hero_id_info = ""
   	local army_count = 0

   	if temp_team.front_heroid_u ~= 0 then
   		hero_id_info = hero_id_info .. " " .. temp_team.front_heroid_u
   		army_count = army_count + heroData.getHeroHp(temp_team.front_heroid_u)
   	end

   	if temp_team.middle_heroid_u ~= 0 then
   		hero_id_info = hero_id_info .. " " .. temp_team.middle_heroid_u
   		army_count = army_count + heroData.getHeroHp(temp_team.middle_heroid_u)
   	end

   	if temp_team.base_heroid_u ~= 0 then
   		hero_id_info = hero_id_info .. " " .. temp_team.base_heroid_u
   		army_count = army_count + heroData.getHeroHp(temp_team.base_heroid_u)
   	end

   	if temp_team.counsellor_heroid_u ~= 0 then
   		hero_id_info = hero_id_info .. " " .. temp_team.counsellor_heroid_u
   		army_count = army_count + heroData.getHeroHp(temp_team.counsellor_heroid_u)
   	end

	return hero_id_info, army_count
end

local function is_show_ybb_guide_for_army(temp_army_id)
	local temp_army_info = getTeamMsg(temp_army_id)
	if not temp_army_info then
		return false
	end

	if getTeamZbState(temp_army_id) then
		return false
	end

	if temp_army_info.state ~= armyState.normal then
		return false
	end

	if armyData.getTeamZbBtnState(temp_army_id) ~= 0 then
		return false
	end

	return getTeamNeedZb(temp_army_id)
end

local function is_need_ybb_guide()
	local is_enough_task = false
	for k, v in pairs (allTableData[dbTableDesList.task.name]) do
		if v.task_id == 10302 then
			if v.is_completed == 0 then
				is_enough_task = true
			end
			break
		end
	end

	if not is_enough_task then
		return false
	end

	local temp_city_id = mainBuildScene.getThisCityid()
	return userData.getCityReserveForcesSoldierNum(temp_city_id) > 0
end

--关于刷新部分处理函数
local function dealWithEnterGameFinish()
	-- armyMark.organizeMarkInfo()
	-- UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.add, armyMark.organizeMarkInfo)
    -- UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.remove, armyMark.organizeMarkInfo)
	-- reportData.initBattleReportList()
end

--- 练兵收益（经验）
local function getArmyTrainingProfit(coorX,coorY,selectedArmyId)
	local __,landLv = landData.get_city_name_lv_by_coordinate(coorX * 10000 + coorY)
	if not landLv then return 0 end
	if TRAINING_FIELD_EXP[landLv] then return TRAINING_FIELD_EXP[landLv] end
	return 0
end

-- 获取屯田收益
-- 屯田中心 以及四周 总共九块地
-- return  retProfit = {k(木1石2铁3粮4),v}
local function getArmyDecreeProfit(coorX,coorY,selectedArmyId)

	local retProfit = {}
	retProfit[resType.wood] = 0
	retProfit[resType.stone] = 0
	retProfit[resType.iron] = 0
	retProfit[resType.food] = 0
	local tmpWid = nil
	local tmpWorldCityInfo = nil
	local profit_ratio = nil
	local profit_ratio_lv = nil

	local resOutPutTypeIndx = nil
	local resOutPutType = nil

	local landLv = nil

	for i = -1, 1 do 
		for j = -1, 1 do 
			tmpWid = (coorX + i) * 10000 + (coorY + j)
			tmpWorldCityInfo = landData.get_world_city_info(tmpWid)
			if i == 0 and j == 0 then 
				profit_ratio = FARM_CENTER_RES_RATIO
			else
				profit_ratio = FARM_AROUND_RES_RATIO
			end

			local worldCityInfo = landData.get_world_city_info(tmpWid)
			if worldCityInfo and worldCityInfo.city_type == 2 and worldCityInfo.userid == userData.getUserId() then 
				resOutPutTypeIndx = resourceData.resourceLevel(coorX + i, coorY + j)
				local lv = math.floor(resOutPutTypeIndx / 10)
		        profit_ratio_lv = FARM_FIELD_LEVEL_RATIO[lv]
		        for k,v in pairs(Tb_cfg_res_output[resOutPutTypeIndx].res_output) do 
					retProfit[v[1]] =  retProfit[v[1]] +  FARM_RES_TIME * math.floor( v[2] * profit_ratio / 100  * profit_ratio_lv / 100) 
				end
			end
		end
	end

	local city_build_effect_info = nil
	
	for k,v in pairs(allTableData[dbTableDesList.build_effect_city.name]) do
        if v.city_wid == math.floor( (selectedArmyId/10) ) then 
            city_build_effect_info = v
        end
    end

	if city_build_effect_info then 
		for k,v in ipairs(retProfit) do 
			if k == resType.wood then 
				retProfit[k] = v * (100 + city_build_effect_info.farm_wood_add) / 100
			elseif k == resType.stone then 
				retProfit[k] = v * (100 + city_build_effect_info.farm_stone_add) / 100
			elseif k == resType.iron then 
				retProfit[k] = v * (100 + city_build_effect_info.farm_iron_add) / 100
			elseif k == resType.food then 
				retProfit[k] = v * (100 + city_build_effect_info.farm_food_add ) / 100
			end
			retProfit[k] = math.floor(retProfit[k])
		end
	end
	return retProfit
end
armyData = {
				getTeamMsg = getTeamMsg,
				getMoveShowInfo = getMoveShowInfo,
				getChildArmyMaxNumInCity = getChildArmyMaxNumInCity,
				isEquipCardForCountryInCity = isEquipCardForCountryInCity,
				isEquipCardForPosInCity = isEquipCardForPosInCity,
				is_army_can_used = is_army_can_used,
				getAllArmyInCity = getAllArmyInCity,
				getCanUseNumInArmyList = getCanUseNumInArmyList,
				getAllTeamMsg = getAllTeamMsg,
				getAssaultTeamMsg = getAssaultTeamMsg,
				getAllAssaultMsg = getAllAssaultMsg,
				getHeroIdInTeamAndPos = getHeroIdInTeamAndPos,
				getArmyIdAndPosByHero = getArmyIdAndPosByHero,
				getTeamHeroContent = getTeamHeroContent,
				organizeHeroInfoInTeam = organizeHeroInfoInTeam,
				isOriginalHeroEquiped = isOriginalHeroEquiped,
				getTeamHp = getTeamHp,
				getTeamFightPower = getTeamFightPower,
				getTeamCanMoveState = getTeamCanMoveState,
				getTeamCost = getTeamCost,
				getTeamSpeed = getTeamSpeed,
				getTeamDestroy = getTeamDestroy,
				getTeamZbState = getTeamZbState,
				getTeamZbBtnState = getTeamZbBtnState,
				get_army_city_zb_queue_num = get_army_city_zb_queue_num,
				getTeamIconState = getTeamIconState,
				getTeamStateType = getTeamStateType,
				getArmyListInCity = getArmyListInCity,
				is_need_ybb_guide = is_need_ybb_guide,
				is_show_ybb_guide_for_army = is_show_ybb_guide_for_army,
				dealWithEnterGameFinish = dealWithEnterGameFinish,
				getCountForMidAndCounsellor = getCountForMidAndCounsellor,
				isHasResidePosInFort = isHasResidePosInFort,
				getArmyDecreeProfit = getArmyDecreeProfit,
				getArmyTrainingProfit = getArmyTrainingProfit,
				getStayFortArmyList = getStayFortArmyList
				}