--该部分用来管理地块相关数据的获取
local function get_world_city_info(city_id)
	return allTableData[dbTableDesList.world_city.name][city_id]
end

local function get_city_lv_by_id(city_id)
	local temp_world_city_info = get_world_city_info(city_id)
	if temp_world_city_info then
		return temp_world_city_info.param%100
	else
		return nil
	end
end

local function get_city_type_by_id(city_id)
	local temp_world_city_info = get_world_city_info(city_id)
	if temp_world_city_info then
		return temp_world_city_info.city_type
	else
		return nil
	end
end

-- 土地是否无主
local function is_own_free(land_id)
	local coor_x = math.floor(land_id/10000)
	local coor_y = land_id%10000
	local landMsg = nil
	local buildingData = mapData.getBuildingData()
	if buildingData[coor_x] and buildingData[coor_x][coor_y] then
        landMsg = buildingData[coor_x][coor_y]
    end
    if landMsg and 
    	( (landMsg.userId and landMsg.userId ~= 0) or 
    		(landMsg.union_id and landMsg.union_id ~= 0) )then
    	return false
    else
    	return true
    end
end



-- TODO目前无主的土地无法获取土地类型
-- 
local function get_land_type(land_id)
	local ret_type = nil


	-- 土地是有主的
	local temp_city_info = Tb_cfg_world_city[land_id]
	if temp_city_info then
		ret_type = temp_city_info.city_type
	end

	local coor_x = math.floor(land_id/10000)
	local coor_y = land_id%10000
	local temp_building_info = mapData.getBuildingData()
	local is_exist_in_view_data = false
	if temp_building_info and temp_building_info[coor_x] and temp_building_info[coor_x][coor_y] then
		is_exist_in_view_data = true
	end

	if is_exist_in_view_data and temp_building_info[coor_x][coor_y] then 
		ret_type = temp_building_info[coor_x][coor_y].cityType
	end

	--读取自己的地块信息
	local temp_world_city_info = get_world_city_info(land_id)
	if temp_world_city_info then
		ret_type = temp_world_city_info.city_type
	end

	return ret_type
end

--因为现在城市类型和名字不是一一对应，所以做接口统一处理
local function get_land_displayName( wid, land_type )
	if land_type == cityTypeDefine.npc_yaosai then
		return Tb_cfg_world_city[wid].name
	else
		return cityTypeName[land_type]
	end
end

local function get_land_type_name(land_id)
	local land_type = get_land_type(land_id)

	if not land_type then 
		return landData.get_city_name_by_coordinate(land_id) 
	end
	return get_land_displayName( land_id, land_type )
end


--是否自己的领地
local function own_land( land_id )
	local coor_x, coor_y = math.floor(land_id/10000), land_id%10000
	local message = nil
    local buildingData = mapData.getBuildingData()
    if buildingData[coor_x] and buildingData[coor_x][coor_y] then
        message = buildingData[coor_x][coor_y]
    end

    if message then
    	if message.cityType then
    		if message.cityType == cityTypeDefine.npc_cheng or message.cityType == cityTypeDefine.npc_chengqu then
    			return false
       		end
    	else
    		return false
    	end

        local relation = mapData.getRelationship(message.userId,message.union_id,message.affilated_union_id)
        if relation == mapAreaRelation.own_self then
            return true
        else
            return false 
        end
    else
        return false
    end
end

--  无主或敌对的个人目标
local function is_type_assailable_land(land_id)
	local coor_x, coor_y = math.floor(land_id/10000), land_id%10000
	local message = nil
    local buildingData = mapData.getBuildingData()
    if buildingData[coor_x] and buildingData[coor_x][coor_y] then
        message = buildingData[coor_x][coor_y]
    end

    if message then
        local relation = mapData.getRelationship(message.userId,message.union_id,message.affilated_union_id)
        if relation == mapAreaRelation.all_free or
            relation == mapAreaRelation.free_enemy or mapAreaRelation.attach_enemy then 
            return true
        else
            return false 
        end
    else
        return true
    end
end

--  免战
local function is_type_can_not_war(land_id)
	local coor_x, coor_y = math.floor(land_id/10000), land_id%10000
	local message = nil
	local protect_time = nil
    local buildingData = mapData.getBuildingData()
    if buildingData[coor_x] and buildingData[coor_x][coor_y] then
        message = buildingData[coor_x][coor_y]
    end
    protect_time = mapData.getProtect_end_timeData(coor_x,coor_y)

    if message and protect_time and protect_time > userData.getServerTime() then
    	-- if message.view_info then
    		-- for i=1, table.getn(message.view_info), 2 do
    			-- if message.view_info[i] == 1 then
    				if not message.relation or (message.relation and message.relation ~= mapAreaRelation.own_self) then
    					return true
    				else
    					return false
    				end
    			-- end
    		-- end
        -- else
        --     return false 
        -- end
    else
        return false
    end
end

-- 是否是主城
local function is_type_main_city(land_id)
	local land_type = get_land_type(land_id)
	if land_type == cityTypeDefine.zhucheng then 
		return true 
	end 
	return false
end


-- 是否是npc 城市
local function is_type_npc_city(land_id)
	local land_type = get_land_type(land_id)
	if land_type == cityTypeDefine.npc_cheng then 
		return true 
	end 
    return false
end

-- 是否是关卡
local function is_type_guan_qia(land_id)
	if true then return true end
end

-- 判断土地是否是城区 （玩家 城区 npc 城区）
local function isChengqu(land_id)
	--首先读取系统配置相关的判定显示
	local temp_city_info = Tb_cfg_world_city[land_id]
	if temp_city_info then
		if temp_city_info.city_type == cityTypeDefine.npc_chengqu then
			return true
		end
	end

	local coor_x = math.floor(land_id/10000)
	local coor_y = land_id%10000
	local temp_building_info = mapData.getBuildingData()
	local is_exist_in_view_data = false
	if temp_building_info and temp_building_info[coor_x] and temp_building_info[coor_x][coor_y] then
		is_exist_in_view_data = true
	end
	
	if is_exist_in_view_data and temp_building_info[coor_x][coor_y].cityType then
		local city_type =temp_building_info[coor_x][coor_y].cityType
		if city_type == cityTypeDefine.player_chengqu then
			return true
		end
	end

	return false
end

-- 是否是玩家城区
local function isPlayerChengqu(land_id)

	--首先读取系统配置相关的判定显示
    local temp_city_info = Tb_cfg_world_city[land_id]
    if temp_city_info then
        if temp_city_info.city_type == cityTypeDefine.player_chengqu then
            return true
        end
    end

    local landInfo = allTableData[dbTableDesList.world_city.name][land_id]
    if landInfo and landInfo.city_type == cityTypeDefine.player_chengqu then return true end


    local coor_x = math.floor(land_id/10000)
    local coor_y = land_id%10000
    local temp_building_info = mapData.getBuildingData()
    local is_exist_in_view_data = false
    if temp_building_info and temp_building_info[coor_x] and temp_building_info[coor_x][coor_y] then
        is_exist_in_view_data = true
    end
    
    if is_exist_in_view_data and temp_building_info[coor_x][coor_y].cityType then
        local city_type =temp_building_info[coor_x][coor_y].cityType
        if city_type == cityTypeDefine.player_chengqu then
            return true
        end
    end


	
end


-- 是否是玩家的主城的城区
local function isUserPlayerChengqu(land_id)
   

    local coor_x = math.floor(land_id/10000)
    local coor_y = land_id%10000
    local temp_building_info = mapData.getBuildingData()
    local is_exist_in_view_data = false
    if temp_building_info and temp_building_info[coor_x] and temp_building_info[coor_x][coor_y] then
        is_exist_in_view_data = true
    end
    

    if is_exist_in_view_data and temp_building_info[coor_x][coor_y].belong_city and temp_building_info[coor_x][coor_y].belong_city ~= 0 then
		local belong_city =temp_building_info[coor_x][coor_y].belong_city 
		local landInfo = get_world_city_info(land_id)
		if belong_city == userData.getMainPos() then
			return true
		end
	end

    return false
end

local function isNpcChengqu(land_id)
    --首先读取系统配置相关的判定显示
    local temp_city_info = Tb_cfg_world_city[land_id]
	if temp_city_info then
		if temp_city_info.city_type == cityTypeDefine.npc_chengqu then
			return true
		end
	end

    return false
end

local function get_city_name_lv_by_coordinate(land_id)
	local ret_name = "default_name"
	local ret_lv = nil

	--首先读取系统配置相关的判定显示
	local temp_city_info = Tb_cfg_world_city[land_id]
	if temp_city_info then
		if temp_city_info.city_type == cityTypeDefine.npc_cheng then
			local city_level = temp_city_info.param%100
			-- if city_level == 0 then
			-- 	city_level = 10
			-- end
			-- return temp_city_info.name , city_level
			return temp_city_info.name , nil
		--npc城的城郊
		elseif temp_city_info.city_type == cityTypeDefine.npc_chengqu then
			return Tb_cfg_world_city[temp_city_info.belong_city].name.."-"..languagePack["jiaoqu"],nil
		else
			return temp_city_info.name , nil
		end
	end

	local coor_x = math.floor(land_id/10000)
	local coor_y = land_id%10000
	local temp_building_info = mapData.getBuildingData()
	local is_exist_in_view_data = false
	if temp_building_info and temp_building_info[coor_x] and temp_building_info[coor_x][coor_y] then
		is_exist_in_view_data = true
	end
	--读取服务器传递过来的名称信息
	if is_exist_in_view_data and temp_building_info[coor_x][coor_y].cityName and temp_building_info[coor_x][coor_y].cityName ~= "" then
		return temp_building_info[coor_x][coor_y].cityName
	end

	if is_exist_in_view_data and temp_building_info[coor_x][coor_y].belong_city and temp_building_info[coor_x][coor_y].belong_city ~= 0 then
		local belong_city =temp_building_info[coor_x][coor_y].belong_city 
		if temp_building_info[math.floor(belong_city/10000)] and temp_building_info[math.floor(belong_city/10000)][belong_city%10000]
			and temp_building_info[math.floor(belong_city/10000)][belong_city%10000].cityName then
			return temp_building_info[math.floor(belong_city/10000)][belong_city%10000].cityName.."-"..languagePack["jiaoqu"],
			math.floor(resourceData.resourceLevel(math.floor(belong_city/10000), belong_city%10000)/10)
		end
	end

	--读取自己的地块信息
	local temp_world_city_info = get_world_city_info(land_id)
	if temp_world_city_info then
		--策划需求2014.7.2要把领地也显示成资源地的样式
		if temp_world_city_info.city_type == cityTypeDefine.lingdi then
			local old_res_level = math.floor(resourceData.resourceLevel(coor_x, coor_y)/10)
			ret_name = languagePack["ziyuandi"] 
			ret_lv = old_res_level
		else
			if temp_world_city_info.name ~= "" then
				ret_name = temp_world_city_info.name
			else
				ret_name = landData.get_land_displayName(land_id,temp_world_city_info.city_type) --cityTypeName[temp_world_city_info.city_type]
			end
		end
	else
		local is_mountain = mapData.getCityType(coor_x, coor_y)
		if is_mountain then
			ret_name = languagePack["shan"]
		else
			local is_water = terrain.isWaterTerrain(coor_x, coor_y)
			if is_water then
				ret_name = languagePack["shui"]
			else
				local res_level = math.floor(resourceData.resourceLevel(coor_x, coor_y)/10)
				ret_name = languagePack["ziyuandi"] 
				ret_lv = res_level
			end
		end
	end

	return ret_name, ret_lv
end

local function get_city_name_by_coordinate(land_id)
	local ret_name, ret_lv = get_city_name_lv_by_coordinate(land_id)
	if nil == ret_lv then 
		return ret_name
	else
		return ret_name .. languagePack["lv"] .. ret_lv 
	end
end

--
local function get_city_name_when_happened( land_id)
	local coor_x, coor_y = math.floor(land_id/10000), land_id%10000
	local is_mountain = mapData.getCityType(coor_x, coor_y)
	local isResources = false
	if is_mountain then
		show_name = languagePack["shan"]
	else
		local is_water = terrain.isWaterTerrain(coor_x, coor_y)
		if is_water then
			show_name = languagePack["shui"]
		else
			local temp_city_info = Tb_cfg_world_city[land_id]
			if temp_city_info then
				if temp_city_info.city_type == cityTypeDefine.npc_cheng then
					local city_level = temp_city_info.param%100
					-- if city_level == 0 then
					-- 	city_level = 10
					-- end
					-- return temp_city_info.name , city_level
					return temp_city_info.name
				--npc城的城郊
				elseif temp_city_info.city_type == cityTypeDefine.npc_chengqu then
					return Tb_cfg_world_city[temp_city_info.belong_city].name.."-"..languagePack["jiaoqu"],nil
				else
					return temp_city_info.name 
				end
			end
			local res_level = math.floor(resourceData.resourceLevel(coor_x, coor_y)/10)
			show_name = languagePack["ziyuandi"] .. "(Lv " .. res_level .. ")"
			isResources = res_level
		end
	end

	return show_name,isResources
end

-- 获取土地的耐久度
local function getDurabilityInfo(touch_map_x,touch_map_y)
	local land_id = touch_map_x * 10000 + touch_map_y
	local durability_cur = 0
	local durability_max = 0
	local manorInfo = nil	


	local add_durable = 0
	local durability_time = nil

	-- 先读配置的数据
	local cfgManorInfo = Tb_cfg_world_city[land_id]
	if cfgManorInfo then 
		durability_cur = cfgManorInfo.durability_cur
		durability_max = cfgManorInfo.durability_max 

		add_durable = userData.getIntervalData(0,2*24*60*60,durability_max)
		durability_cur = durability_cur + math.floor(add_durable)
		if durability_cur > durability_max then
			durability_cur = durability_max
		end
	end

	-- 读取玩家的数据
	
 	manorInfo = landData.get_world_city_info(land_id)
   	if manorInfo then
   		durability_time = manorInfo.durability_time
   		durability_cur = manorInfo.durability_cur
		durability_max = manorInfo.durability_max
	end
	
	
	if durability_time  then 
		add_durable = userData.getIntervalData(manorInfo.durability_time,2*24*60*60,durability_max)
		durability_cur = durability_cur + math.floor(add_durable)
		if durability_cur > durability_max then
			durability_cur = durability_max
		end
	end
	if durability_cur == 0 and durability_max == 0 then 
		local is_mountain = mapData.getCityType(touch_map_x, touch_map_y)
    	local is_water = terrain.isWaterTerrain(touch_map_x, touch_map_y)
    	if is_mountain or is_water then 
    		return durability_cur,durability_max
    	else
    		local landMsg = nil
    		local buildingData = mapData.getBuildingData()
    		if buildingData[touch_map_x] and buildingData[touch_map_x][touch_map_y] then
		        landMsg = buildingData[touch_map_x][touch_map_y]
		    end
		    if landMsg and 
		    	( (landMsg.userId and landMsg.userId ~= 0) or 
		    		(landMsg.union_id and landMsg.union_id ~= 0) )then
		    	--他人土地
		    	if landMsg.userId ~= userData.getUserId() then 
		    		durability_cur,durability_max = 0,0
		    	end
		    else
		    	--无主土地
		    	durability_cur,durability_max = 1,1
		    end
		end
	end

	return durability_cur,durability_max
end



-- 土地是否被敌方占领
local function isLandOwnByEnemy(land_id)
	local coor_x, coor_y = math.floor(land_id/10000), land_id%10000
	local message = nil
    local buildingData = mapData.getBuildingData()
    if buildingData[coor_x] and buildingData[coor_x][coor_y] then
        message = buildingData[coor_x][coor_y]
    end

    if message then
        local relation = mapData.getRelationship(message.userId,message.union_id,message.affilated_union_id)
        if relation == 4 or
            relation == 7 then 
            return true
        else
            return false 
        end
    else
        return false
    end
end


-- 土地配置的守军数
local function getLandCfgDefenderArmyCount(coorX,coorY)
	-- iParam 如果是npc守军，则直接用Tb_world_city的param字段；如果是资源地则直接是资源地等级；如果是贼兵则21~50；如果是npc城防守军，则80+level；如果是玩家城防守军，则50~79，如果是山寨100~200
	local cfgWorldCity = Tb_cfg_world_city[coorX * 10000 + coorY]

	local cfgArmyCountInfo = nil
	if cfgWorldCity then 
		cfgArmyCountInfo = Tb_cfg_army_count[cfgWorldCity.param]
		if cfgArmyCountInfo then 
			return cfgArmyCountInfo.count
		end
	else
		local resourceLevel = resourceData.resourceLevel(coorX,coorY)
		resourceLevel = math.floor(resourceLevel/10)
		cfgArmyCountInfo = Tb_cfg_army_count[resourceLevel]
		if cfgArmyCountInfo then 
			return cfgArmyCountInfo.count
		end
	end

	return 0
end


landData = {
				get_world_city_info = get_world_city_info,
				get_city_type_by_id = get_city_type_by_id,
				get_city_lv_by_id = get_city_lv_by_id,
				get_city_name_by_coordinate = get_city_name_by_coordinate,
				get_city_name_when_happened = get_city_name_when_happened,
				get_city_name_lv_by_coordinate = get_city_name_lv_by_coordinate,
				getDurabilityInfo = getDurabilityInfo,
				isChengqu = isChengqu,
                isPlayerChengqu = isPlayerChengqu,
                isNpcChengqu = isNpcChengqu,
				is_type_main_city = is_type_main_city,
				is_type_assailable_land = is_type_assailable_land,
				is_type_npc_city = is_type_npc_city,
				is_type_guan_qia = is_type_guan_qia,
				get_land_type = get_land_type,
				get_land_type_name = get_land_type_name,
				is_own_free = is_own_free,
				isLandOwnByEnemy = isLandOwnByEnemy,
				own_land = own_land,
				is_type_can_not_war = is_type_can_not_war,
				isUserPlayerChengqu = isUserPlayerChengqu,
				get_land_displayName= get_land_displayName,
				getLandCfgDefenderArmyCount = getLandCfgDefenderArmyCount,
}
