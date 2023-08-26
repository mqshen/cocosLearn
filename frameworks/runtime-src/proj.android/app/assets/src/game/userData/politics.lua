local function getBuildLevel(city_id, build_cfg_id)
	local build_id = build_cfg_id
	--城主府和都督府特殊处理
	if city_id ~= userData.getMainPos() and build_id == 10 then
		build_id = 12
	end
	local build_info = allTableData[dbTableDesList.build.name][city_id*100 + build_id]
	if build_info then
		return build_info.level
	else
		return 0
	end
end

local function getBuildInfo(city_id, build_cfg_id)
	return allTableData[dbTableDesList.build.name][city_id*100 + build_cfg_id]
end

--获取该区域的建筑面积
function getAreaAtIndex(index , Cityid)
	local level = nil
	local area = 0
	for i, v in ipairs(buildingInclude[index].id) do
		level = politics.getBuildLevel(Cityid, v) 
		if level > 0 then
			area = area + Tb_cfg_build_cost[v*100+level].build_area
		end
	end
	return area
end

local function isEnoughPreCondition(city_id, build_cfg_id)
	local is_enough = true
	for i, v in pairs(Tb_cfg_build[build_cfg_id].pre_condition) do
		if v[2] >politics.getAreaAtIndex(v[1] , city_id) then
			is_enough = false
		end
	end

	return is_enough
end

--获取玩家自己集市的数量
local function getUserMarketNum()
	local ret_num = 0
	for k ,v in pairs(allTableData[dbTableDesList.world_city.name]) do
   		if v.userid == userData.getUserId() and 
   			(v.city_type == cityTypeDefine.zhucheng or 
   				v.city_type == cityTypeDefine.fencheng) then
   			 if getBuildInfo(v.wid,cityBuildDefine.jishi) then
   			 	ret_num = ret_num + 1
   			 end
   		end
   	end
   	return ret_num
end

local function organizePreCondition(city_id, build_cfg_id)
	local show_content = ""
	--[[
	local pre_build_id, pre_build_level, current_level = nil, nil
	for k,v in pairs(Tb_cfg_build[build_cfg_id].pre_condition) do
	 	pre_build_id = v[1]
	 	pre_build_level = v[2]
	 	current_level = getBuildLevel(city_id, pre_build_id)
	 	if current_level < pre_build_level then
	 		if show_content == "" then
	 			show_content = Tb_cfg_build[pre_build_id].name .. " " .. pre_build_level .. languagePack["ji"]
	 		else
	 			show_content = show_content .. ", " .. Tb_cfg_build[pre_build_id].name .. " " .. pre_build_level .. languagePack["ji"]
	 		end
	 	end
	end
	--]]

	return show_content
end

local function getFinishBuildListInCity(city_id)
	local build_list = {}
	for k,v in pairs(allTableData[dbTableDesList.build.name]) do
		local build_city_id = math.floor(k/100)
		local build_id = k%100
		if build_city_id == city_id and v.state == 0 then
			table.insert(build_list, v)
		end
	end
	return build_list
end

-- queueType nil 获取所有队列
-- queueType 1 获取免费队列
-- queueType 2 获取临时队列
local function getBuildingBuildListInCity(city_id,queueType)
	local build_list = {}
	for k,v in pairs(allTableData[dbTableDesList.build.name]) do
		local build_city_id = math.floor(k/100)
		local build_id = k%100

		if build_city_id == city_id and v.state ~= 0 then
			if not queueType then 
				table.insert(build_list, v)
			else
				if queueType == 1 and v.queue == 1 then 
					table.insert(build_list, v)
				end
				if queueType == 2 and v.queue == 2 then 
					table.insert(build_list, v)
				end	
			end
		end
	end
	return build_list
end

--获取区域的建筑队列数
local function getBuildingQueueInArea( city_id, areaIndex )
	local num = 0
	for k,v in pairs(allTableData[dbTableDesList.build.name]) do
		local build_city_id = math.floor(k/100)
		local build_id = k%100
		if build_city_id == city_id and v.state ~= 0 then
			if buildingInArea[build_id] == areaIndex then
				num = num + 1
			end
		end
	end
	return num
end
-- queueType nil 获取所有队列
-- queueType 1 获取免费队列
-- queueType 2 获取临时队列
local function getBuildingBuildNumsInCity(city_id,queueType)
	local building_num = 0
	for k,v in pairs(allTableData[dbTableDesList.build.name]) do
		local build_city_id = math.floor(k/100)
		local build_id = k%100
		if build_city_id == city_id and v.state ~= 0 then
			if not queueType then 
				building_num = building_num + 1
			else
				if queueType == 1 and v.queue == 1 then 
					building_num = building_num + 1
				end

				if queueType == 2 and v.queue == 2 then 
					building_num = building_num + 1
				end
			end
		end
	end
	return building_num
end

local function getBuildListInCity(city_id)
	local build_list = {}
	local build_nums = 0
	for k,v in pairs(allTableData[dbTableDesList.build.name]) do
		local build_city_id = math.floor(k/100)
		local build_id = k%100
		if build_city_id == city_id then
			build_list[build_id] = v
			build_nums = build_nums + 1
		end
	end
	return build_list, build_nums
end

--向服务器请求城市的具体信息
local function requestPolitics( id )
	--loadingLayer.create()
	--Net.send(BUILDING_INFO_OF_CITY,{id})
end

--设置城市信息
-- public Integer build_id_u;
-- 	public Integer city_wid;
-- 	public Integer build_id;
-- 	public Integer level;
-- 	public Byte state;// 0:正常, 1：升级, 2：降级
-- 	public Integer end_time;
local function receivePolitices( packet )
end

--建筑升级请求
local function requestUpgradeBuilding(id,wid )
	Net.send(BUILDING_UPGRADE, {wid,id})
end

--拆除建筑请求
local function requestDestructBuilding(id,wid )
	Net.send(BUILDING_DEGRADE, {wid,id})
end

--修建建筑请求
local function requestBuildBuilding(id,wid )
	Net.send(BUILDING_BUILD, {wid,id})
end

--取消建筑升级,建造，拆除请求
local function requestCancelBuilding(id,wid )
	Net.send(BUILDING_CANCEL, {wid,id})
end

local function receiveMsgAfterBuildingChange(packet)
end

--立即完成建筑
local function requestDoneImmediately(wid )
	Net.send(BUILDING_FINISH_IMMEDIATELY,{wid})
end

--单个建筑立即完成
local function requestOneDoneImmediately( iBuildIdU )
	Net.send(BUILDING_FINISH_IMMEDIATELY_ONE,{iBuildIdU})
end

local function receiveDoneImmediately(packet)
	print("立即完成收到回复")
end

--发送获取资源的请求
local function requestResources( )
	--Net.send(RESOURCE_GET_INFO,{})
end

local function getSelfRes()
	return allTableData[dbTableDesList.user_res.name][userData.getUserId()]
end

local function getResNumsByType(new_type)
	local self_res = politics.getSelfRes()
	local res_cur_nums, res_max_nums, res_last_time, res_add_speed = 0, 0, 0, 0
	if new_type == resType.wood then
		res_cur_nums = self_res.wood_cur
		res_max_nums = self_res.wood_max
		res_last_time = self_res.wood_time
		res_add_speed = self_res.wood_add
	elseif new_type == resType.stone then
		res_cur_nums = self_res.stone_cur
		res_max_nums = self_res.stone_max
		res_last_time = self_res.stone_time
		res_add_speed = self_res.stone_add
	elseif new_type == resType.iron then
		res_cur_nums = self_res.iron_cur
		res_max_nums = self_res.iron_max
		res_last_time = self_res.iron_time
		res_add_speed = self_res.iron_add
	elseif new_type == resType.food then
		res_cur_nums = self_res.food_cur
		res_max_nums = self_res.food_max
		res_last_time = self_res.food_time
		res_add_speed = self_res.food_add - self_res.food_cost
	end

	if res_cur_nums < res_max_nums then
		res_cur_nums = res_cur_nums + math.floor(userData.getIntervalData(res_last_time,3600,res_add_speed))
		if res_cur_nums > res_max_nums then
			res_cur_nums = res_max_nums
		end
	end
	if res_cur_nums < 0 then
		res_cur_nums = 0
	end

	return res_cur_nums, res_max_nums, res_add_speed
end

-- public Integer userid;
	
-- 	public Integer money_cur;
-- 	public Integer wood_cur;
-- 	public Integer stone_cur;
-- 	public Integer iron_cur;
-- 	public Integer food_cur;
-- 	public Integer wood_max;
-- 	public Integer stone_max;
-- 	public Integer iron_max;
-- 	public Integer food_max;
-- 	public Integer wood_add;
-- 	public Integer stone_add;
-- 	public Integer iron_add;
-- 	public Integer food_add;// 每小时产量
-- 	public Integer wood_time;
-- 	public Integer stone_time;
-- 	public Integer iron_time;
-- 	public Integer food_time;
-- 	public Integer food_cost;// 每小时消耗
--返回资源信息
local function receiveResources(packet )
	--dbDataChange.updateData(dbTableDesList.user_res.name, packet)
end

--请求建立分城
local function requestNewBranchCity(wid, show_name)
	Net.send(WORLD_BUILD_BRANCH_CITY, {wid, show_name})
end

--接受建立分城服务器返回
local function receiveNewBranchCity( packet)
	LSound.playSound(musicSound["city_build"])
	print(">>>>>>>>>>>>>>>>receiveNewBranchCity")
end

--请求建立要塞
local function requestNewFort(wid, show_name)
	Net.send(WORLD_BUILD_FORT, {wid, show_name})
end

--接受建立要塞服务器返回
local function receiveNewFort( packet )
	LSound.playSound(musicSound["city_build"])
	print(">>>>>>>>>>>>>>>>>>>>>>receiveNewFort")
end

--请求拆除分城
local function requestDeleteBranchCity(wid )
	Net.send(WORLD_DELETE_BRANCH_CITY,{wid})
end

--接收服务器拆除分城返回
local function receiveDeleteBranchCity( packet )
	print(">>>>>>>>>>>>>>>>>>>>>>receiveDeleteBranchCity")
end

--请求拆除要塞
local function requestDeleteFort(wid )
	Net.send(WORLD_DELETE_FORT,{wid})
end

--接收服务器拆除要塞返回
local function receiveDeleteFort( packet )
	print(">>>>>>>>>>>>>>>>>>>>>>receiveDeleteFort")
end

--请求取消建分城或者要塞
local function requestCancelBuildCity( wid )
	Net.send(WORLD_CANCEL_BUILD_CITY_FORT,{wid})
end

--收到服务器取消建分城或要塞
local function receiveCancelBuildCity( packet )
	print(">>>>>>>>>>>>>>>>>>>>>>receiveCancelBuildCity")
end

--请求取消拆除分城或要塞
local function requestCancelDeleteCity( wid )
	Net.send(WORLD_CANCEL_DEL_CITY_FORT, {wid})
end

--收到服务器取消拆分城或要塞
local function receiveCancelDeleteCity( wid )
	print(">>>>>>>>>>>>>>>>>>>>>>receiveCancelDeleteCity")
end

--请求放弃领地
local function requestDeleteLingdi( wid )
	Net.send(WORLD_DESERT_FIELD,{wid})
end

--收到服务器放弃领地返回信息
local function receiveDeleteLingdi( packet )
	print(">>>>>>>>>>>>>>>>>>>>>>receiveDeleteLingdi")
end

--请求取消放弃领地
local function requestCancelDeleteLingdi( wid )
	Net.send(WORLD_CANCEL_DESERT_FIELD, {wid})
end

--收到服务器返回取消放弃领地信息
local function receiveCancelDeleteLingdi( packet )
	print(">>>>>>>>>>>>>>>>>>>>>>receiveCancelDeleteLingdi")
end

local function remove( )
	netObserver.removeObserver(BUILDING_FINISH_IMMEDIATELY_ONE)
	--netObserver.removeObserver(BUILDING_INFO_OF_CITY)
	netObserver.removeObserver(BUILDING_BUILD)
	netObserver.removeObserver(BUILDING_UPGRADE)
	netObserver.removeObserver(BUILDING_DEGRADE)
	netObserver.removeObserver(BUILDING_CANCEL)
	--netObserver.removeObserver(RESOURCE_GET_INFO)
	netObserver.removeObserver(WORLD_BUILD_BRANCH_CITY)
	netObserver.removeObserver(WORLD_BUILD_FORT)
	netObserver.removeObserver(WORLD_DELETE_BRANCH_CITY)
	netObserver.removeObserver(WORLD_DELETE_FORT)
	netObserver.removeObserver(WORLD_CANCEL_BUILD_CITY_FORT)
	netObserver.removeObserver(WORLD_CANCEL_DEL_CITY_FORT)
	netObserver.removeObserver(WORLD_DESERT_FIELD)
	netObserver.removeObserver(WORLD_CANCEL_DESERT_FIELD)
end

local function initData( )
	netObserver.addObserver(BUILDING_FINISH_IMMEDIATELY_ONE,receiveDoneImmediately)
	--netObserver.addObserver(BUILDING_INFO_OF_CITY,receivePolitices)
	netObserver.addObserver(BUILDING_BUILD,receiveMsgAfterBuildingChange)
	netObserver.addObserver(BUILDING_UPGRADE,receiveMsgAfterBuildingChange)
	netObserver.addObserver(BUILDING_DEGRADE,receiveMsgAfterBuildingChange)
	netObserver.addObserver(BUILDING_CANCEL,receiveMsgAfterBuildingChange)
	--netObserver.addObserver(RESOURCE_GET_INFO, receiveResources)
	netObserver.addObserver(WORLD_BUILD_BRANCH_CITY, receiveNewBranchCity)
	netObserver.addObserver(WORLD_BUILD_FORT, receiveNewFort)
	netObserver.addObserver(WORLD_DELETE_BRANCH_CITY, receiveDeleteBranchCity)
	netObserver.addObserver(WORLD_DELETE_FORT, receiveDeleteFort)
	netObserver.addObserver(WORLD_CANCEL_BUILD_CITY_FORT, receiveCancelBuildCity)
	netObserver.addObserver(WORLD_CANCEL_DEL_CITY_FORT, receiveCancelDeleteCity)
	netObserver.addObserver(WORLD_DESERT_FIELD,receiveDeleteLingdi)
	netObserver.addObserver(WORLD_CANCEL_DESERT_FIELD,receiveCancelDeleteLingdi)
end

-- 获取还没播特效的建筑ID列表
-- 建筑升级完成 建造完成后需要播放特效
-- 特效状态：0正常、1建造完成、 2升级完成
local function getBuildingIdsNeedEffectByCity(city_id)
	local listIds = {}
	local build_city_id = nil
	-- local build_id = nil
	for k,v in pairs(allTableData[dbTableDesList.build.name]) do
		build_city_id = math.floor(k/100)
		-- build_id = k%100
		if build_city_id == city_id and v.effect_state ~= 0 then
			table.insert(listIds,v.build_id_u)
		end
	end
	return listIds
end


-- 获取土地可扩建次数
local function getBuildingExpandAbleCount(wid)
	local retCount = 0
	local userCityData = userCityData.getUserCityData(wid)
	if not userCityData then return retCount end
	local extend_wid = {}

	if string.len(userCityData.extend_wids)>0 then
		extend_wid = stringFunc.anlayerOnespot(userCityData.extend_wids, ",", false)
	end

	local cityExtendMaxCount = 0
    for k,v in pairs(allTableData[dbTableDesList.build_effect_city.name]) do
        if v.userid == userData.getUserId() and v.city_wid == wid then 
            cityExtendMaxCount = v.city_extend_max
        end
    end
    local countLeft = cityExtendMaxCount - #extend_wid
    if countLeft < 0 then countLeft = 0 end
    return countLeft

	-- local retCount = 0
	-- local userCityData = userCityData.getUserCityData(wid)
	-- if not userCityData then return retCount end
	-- local extend_wid = {}

	-- if string.len(userCityData.extend_wids)>0 then
	-- 	extend_wid = stringFunc.anlayerOnespot(userCityData.extend_wids, ",", false)
	-- end

	-- if #extend_wid >= BUILD_EXPAND then return retCount end

	-- local cityLevel = nil

	-- if userCityData.city_type == cityTypeDefine.zhucheng then 
	-- 	cityLevel = politics.getBuildLevel(mainBuildScene.getThisCityid(), cityBuildDefine.chengzhufu)
	-- 	for k = #extend_wid + 1, #CITY_EXTEND_CHENG_ZHU_FU_LEVEL do 
	-- 		if CITY_EXTEND_CHENG_ZHU_FU_LEVEL[k] <= cityLevel then 
	-- 			retCount = retCount + 1
	-- 		end
	-- 	end
	-- 	return retCount
	-- elseif userCityData.city_type == cityTypeDefine.fencheng then 
	-- 	cityLevel = politics.getBuildLevel(mainBuildScene.getThisCityid(), cityBuildDefine.dudufu)
	-- 	for k = #extend_wid + 1, #CITY_EXTEND_CHENG_ZHU_FU_LEVEL do 
	-- 		if CITY_EXTEND_CHENG_ZHU_FU_LEVEL[k] <= cityLevel then 
	-- 			retCount = retCount + 1
	-- 		end
	-- 	end
	-- 	return retCount
	-- else
	-- 	return retCount
	-- end
end

politics = {
				initData = initData,
				--requestPolitics = requestPolitics,
				requestUpgradeBuilding = requestUpgradeBuilding,
				requestCancelDestructBuilding = requestCancelDestructBuilding,
				requestDestructBuilding = requestDestructBuilding,
				requestBuildBuilding = requestBuildBuilding,
				requestCancelBuilding = requestCancelBuilding,
				requestDoneImmediately = requestDoneImmediately,
				--requestResources = requestResources,
				getSelfRes = getSelfRes,
				getResNumsByType = getResNumsByType,
				requestNewBranchCity = requestNewBranchCity,
				requestNewFort = requestNewFort,
				requestDeleteBranchCity = requestDeleteBranchCity,
				requestDeleteFort = requestDeleteFort,
				requestCancelBuildCity = requestCancelBuildCity,
				requestCancelDeleteCity = requestCancelDeleteCity,
				requestDeleteLingdi = requestDeleteLingdi,
				requestCancelDeleteLingdi = requestCancelDeleteLingdi,
				getBuildInfo = getBuildInfo,
				getBuildLevel = getBuildLevel,
				isEnoughPreCondition = isEnoughPreCondition,
				organizePreCondition = organizePreCondition,
				getBuildListInCity = getBuildListInCity,
				getFinishBuildListInCity = getFinishBuildListInCity,
				getBuildingBuildListInCity = getBuildingBuildListInCity,
				getBuildingBuildNumsInCity = getBuildingBuildNumsInCity,
				getAreaAtIndex = getAreaAtIndex,
				requestOneDoneImmediately= requestOneDoneImmediately,
				getBuildingQueueInArea = getBuildingQueueInArea,
				getUserMarketNum = getUserMarketNum,
				getBuildingIdsNeedEffectByCity = getBuildingIdsNeedEffectByCity,
				getBuildingExpandAbleCount = getBuildingExpandAbleCount,
}
