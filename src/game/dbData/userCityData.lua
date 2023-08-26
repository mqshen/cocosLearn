local function getUserCityData(wid)
	return allTableData[dbTableDesList.user_city.name][wid]
end

local function getCityBuildEffectData(wid)
	return allTableData[dbTableDesList.build_effect_city.name][wid]
end

local function get_all_zb_queue_num(wid)
	local temp_init_queue = 0
	local temp_city_type = landData.get_city_type_by_id(wid)
    if temp_city_type == cityTypeDefine.zhucheng or temp_city_type == cityTypeDefine.fencheng then
        temp_init_queue = ARMY_QUEUE_INIT
    else
    	temp_init_queue = ARMY_QUEUE_OUTSIDE_INIT
    end

	local temp_city_effect = getCityBuildEffectData(wid)
	if temp_city_effect then
		return temp_init_queue + temp_city_effect.army_queue_add
	else
		return 0
	end
end

local function get_leave_zb_queue_in_city(wid)
	local temp_city_info = getUserCityData(wid)
	if temp_city_info then
		return temp_city_info.army_queue_cur
	else
		return 0
	end
end

local function sortEffectCityListRuler(idA,idB)
    local InfoA = landData.get_world_city_info(idA)--getUserCityData(idA)
    local InfoB = landData.get_world_city_info(idB)--getUserCityData(idB)

    if InfoA.city_type ~= InfoB.city_type then 
        if cityTypeSortTable[InfoA.city_type] < cityTypeSortTable[InfoB.city_type] then 
			return true
		else
			return false
		end
    else 
        if (InfoA.state == cityState.building) and (InfoB.state == cityState.building )then
            if InfoA.end_time < InfoB.end_time then
                return true
            elseif InfoA.end_time > InfoB.end_time then 
            	return false
            else
            	-- 以防end_time 是一致的
            	if idA > idB then 
            		return true
            	else
                	return false
                end
            end
        end
        if InfoA.state == cityState.building then
            return false
        end
        if InfoB.state == cityState.building then 
            return true
        end


        if #armyData.getArmyListInCity(idA) > #armyData.getArmyListInCity(idB) then 
       		return true
       	elseif #armyData.getArmyListInCity(idA) < #armyData.getArmyListInCity(idB) then 
       		return false
       	end
       	

       	if armyData.getChildArmyMaxNumInCity(idA) > armyData.getChildArmyMaxNumInCity(idB) then 
       		return true
       	elseif armyData.getChildArmyMaxNumInCity(idA) < armyData.getChildArmyMaxNumInCity(idB) then 
       		return false
       	end

       	


       	if getUserCityData(InfoA.wid).build_time < getUserCityData(InfoB.wid).build_time then
       		return true
       	elseif getUserCityData(InfoA.wid).build_time > getUserCityData(InfoB.wid).build_time then
       		return false
       	else
       		-- 以防build_time 是一致的
        	if idA > idB then 
        		return true
        	else
            	return false
            end
       	end
	end
end
--城市列表信息(有实际效果的，包括正常状态以及正在拆除的)
local function getEffectCityList(need_main_city, need_fencheng, need_fort,need_removing,need_buiding,need_npcyaosai)
	local city_list = {}
	local show_or_not = false
	for k,v in pairs(allTableData[dbTableDesList.world_city.name]) do
		show_or_not = false
		if v.city_type == cityTypeDefine.zhucheng then
			if need_main_city then
				show_or_not = true
			end
		elseif v.city_type == cityTypeDefine.fencheng then
			if need_fencheng then
				show_or_not = true
			end
		elseif v.city_type == cityTypeDefine.yaosai then
			if need_fort then
				show_or_not = true
			end
		elseif v.city_type == cityTypeDefine.npc_yaosai then
			if need_npcyaosai then
				show_or_not = true
			end
		end

		if show_or_not then
			if v.state == cityState.normal 
                or (need_removing and v.state == cityState.removing)
                or (need_buiding and v.state == cityState.building)
                then --策划说要把正在拆除的也显示出来

                --只有需要显示npc要塞和军营的时候才把他加入
                if v.city_type == cityTypeDefine.npc_yaosai and not need_npcyaosai then
                else
					table.insert(city_list, k)
				end
			end
		end
	end

    table.sort(city_list,sortEffectCityListRuler)
	return city_list
end

local function getEffectCityByindex(idx, need_main_city, need_fencheng, need_fort,need_removing,need_buiding, need_npcyaosai)
	local city_list  = getEffectCityList(need_main_city, need_fencheng, need_fort,need_removing,need_buiding, need_npcyaosai)
	if idx < 1 or idx > #city_list then
		return 0, "no exist"
	end

	local city_info = landData.get_world_city_info(city_list[idx]) --getUserCityData(city_list[idx])
	return city_list[idx], landData.get_land_displayName( city_info.wid,city_info.city_type)--cityTypeName[city_info.city_type]
end

--获取指定城市类型的现有数量(不包括正在建造的等)
local function getHaveNumsByType(new_type)
	local nums = 0
	for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
		if landData.get_city_type_by_id(k) == new_type then
			nums = nums + 1
		end
	end

	return nums
end

--获取指定城市类型的现有数量(包括所有值)
local function getAllNumByType(new_type)
	local nums = 0
	for k,v in pairs(allTableData[dbTableDesList.world_city.name]) do
		if v.city_type == new_type then
			nums = nums + 1
		end
	end

	return nums
end

--有部队的城市列表信息
local function getCityNumWithArmy()
	local all_nums = 0
	for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
		if v.state == cityState.normal and #armyData.getArmyListInCity(k) ~= 0 then
			all_nums = all_nums + 1
		end
	end
	return all_nums
end

local function getCityInfoWithArmyByindex(idx)
	local current_idx = 0
	for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
		if v.state == cityState.normal and #armyData.getArmyListInCity(k) ~= 0 then
			if current_idx == idx then
				return landData.get_world_city_info(k)
			end
			current_idx = current_idx + 1
		end
	end
	return nil
end

local function getCityCostNums(city_id)
	local all_cost_nums = ARMY_COST_MAX_INIT/10 + allTableData[dbTableDesList.build_effect_city.name][city_id].army_cost_max/10

	return all_cost_nums
end

--检测某个地块是否被扩建
local function getLandExtendedState(land_id)
	local result = false
	for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
		if v.city_type == cityTypeDefine.zhucheng or v.city_type == cityTypeDefine.fencheng then
			local extend_list = stringFunc.anlayerOnespot(v.extend_wids, ",", true)
			for kk,vv in pairs(extend_list) do
				if vv == land_id then
					result = true
					break
				end
			end
		end
	end

	return result
end

local function getCityHp(city_id)
	local result_num = 0
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		local army_id = city_id * 10 + i
		local team_info = armyData.getTeamMsg(army_id)
		if team_info then
			result_num = result_num + armyData.getTeamHp(army_id)
		end
	end

	return result_num
end


-- 玩家所占的 NPC城区 提供的税收
local function getUserNpcCityPropTax(wid)
	local ret = 0
	local temp_city_type = landData.get_city_type_by_id(wid)
	if temp_city_type ~= cityTypeDefine.npc_chengqu then return ret end

	local tmpWorldCityInfo = landData.get_world_city_info(wid)
	if not tmpWorldCityInfo then return ret end
	
	
	-- TODO
	--[[无法获取对应NPC城市的归属状态
	local belongWorldCityInfo = landData.get_world_city_info(tmpWorldCityInfo.belong_city)

	if not belongWorldCityInfo then return ret end
	local level = belongWorldCityInfo.param % 100
	if (userData.getUnion_id() ~=0) and
		(userData.getAffilated_union_id() == 0) and
		belongWorldCityInfo.union_id == userData.getUnion_id() then
		
		ret = NPC_SUBURB_LEVEL_MONEY[level] * (100 + NPC_SUBURB_MONEY_CITY_ADD) / 100
	else
		ret = NPC_SUBURB_LEVEL_MONEY[level]
	end
	]]
	
	-- 暂时以下边的代替
	local cfgBelongWorldCity = Tb_cfg_world_city[tmpWorldCityInfo.belong_city]		
	local level = cfgBelongWorldCity.param % 100;
	ret = NPC_SUBURB_LEVEL_MONEY[level]
	
	
	return ret
end

-- 玩家城市的税收加成 （只有主城 和 分城 有）
local function getUserCityTax(city_id)
	local ret = 0
	local userCityInfo = getUserCityData(city_id)
	if not userCityInfo then return ret end
	local temp_city_type = landData.get_city_type_by_id(city_id)
	if not (temp_city_type == cityTypeDefine.zhucheng or temp_city_type == cityTypeDefine.fencheng) then
		return ret
	end
	
	if userCityInfo.state == cityState.building then return ret end
	local tmp_v_a = 0
	local tmp_v_b = 0
	local buildEffectCity = allTableData[dbTableDesList.build_effect_city.name][city_id]
	if buildEffectCity then
		tmp_v_a = buildEffectCity.tax_max
		tmp_v_b = buildEffectCity.tax_add
	end
	

	local iExtendCount = 0
	if string.len(userCityInfo.extend_wids)>0 then
		local extend_wid = stringFunc.anlayerOnespot(userCityInfo.extend_wids, ",", false)
		iExtendCount = #extend_wid
	end
	ret = tmp_v_a + tmp_v_a * (tmp_v_b + iExtendCount * EXTEND_REVENUE_ADD) / 100
	
	return ret
end
userCityData = {
	getUserNpcCityPropTax = getUserNpcCityPropTax,
	getUserCityTax = getUserCityTax,
	getUserCityData = getUserCityData,
	getCityBuildEffectData = getCityBuildEffectData,
	get_all_zb_queue_num = get_all_zb_queue_num,
	get_leave_zb_queue_in_city = get_leave_zb_queue_in_city,
	getHaveNumsByType = getHaveNumsByType,
	getAllNumByType = getAllNumByType,
	getEffectCityList = getEffectCityList,
	getEffectCityByindex = getEffectCityByindex,
	getCityNumWithArmy = getCityNumWithArmy,
	getCityInfoWithArmyByindex = getCityInfoWithArmyByindex,
	getCityCostNums = getCityCostNums,
	getCityHp = getCityHp,
	getLandExtendedState = getLandExtendedState
}
