--显示出来的草地 1
--丘陵 2
--水和沙地 3
--水和沙地边缘 4
--网格 5
--资源 6
--扩建 7
--建筑batchnode 8
--山脉 9
--活动的时候的山城 10
--援军 11
--战争迷雾 12
--战争迷雾过渡 13
--
mapElement = {
	GRASS = 1,
	QIULING = 2,
	WATER = 3,
	SANDEAGE = 4,
	WATEREAGE = 5,
	GRID = 6,
	RES = 7,
	EXPAND = 8,
	BUILDING = 9,
	BETWEENNODE = 10,
	MOUNTAIN = 11,
	ADDITION = 12,
	YUANJUN = 13,
	FARMING = 14,	
	FOG = 15,
	FOGEAGE = 16,
	TRAINING = 17,
}

module("mapData", package.seeall)
local buildingData = {} --建筑的数据，包括类型，归属
local area = {row_up = nil, row_down = nil, col_left = nil, col_right = nil} --加载了数据的范围
local mapArea = {row_up = nil, row_down = nil, col_left = nil, col_right = nil} --加载的地图范围
local objectArray = {}
local m_touchLayer = nil
local m_rootLayer = nil
local size = 1501
local cityComponentData = {} --城市装饰建筑数据
local smokeData = {}
-- local flagColorData = {}
local clippingResData = {} --需要被挖掉的资源的数据
local fieldArmyData = {} --视野部队信息(同盟视野)
local m_userInfoInMap = {}
local m_totalCount = 0
local m_defendFireData = {}

local des = {"a","b", "c", "d", "e", "f", "g","h","i","j","k","l","m","n","o","p","q","r","s","t",
                "u","v","w","x","y","z","A","B"}
local m_terrain = {"b1","b2","b3","b4","B1","B2","B3","B4","B5","B6",
                    "B7","B8","B9","b1#","b2#","b3#","b4#","B1#","B2#","B3#","B4#","B5#","B6#",
                    "B7#","B8#","B9#","8","9"}
local pngToData = {}
for i,v in ipairs(des) do
    pngToData[v] = m_terrain[i]
end

local valleyData = {} --山寨的数据
local refreshTimer = nil

--地图的对象 node:地型，building:建筑， layer:底层， city:山脉，后期会加入城市, capital:洛阳, cover:遮挡层，测试,
		-- waterEdge:水的边缘  resLayer：资源, mountainLayer:丘陵, grassTran:山和陆地的过渡, water:水
		--gridNode:网格, relationNode:关系网格, level1ResNode:一级资源地, fogLayer:迷雾
		--zhuzhaNode :驻扎的图 
-- function setObject(node, building,layer, city, waterEdge, resLayer, mountainLayer,water,gridNode,fogLayer,additionwallBatchNode,grass,expand,zhuzha)
-- 	objectArray = { batchNode = node, building = building,layer = layer, city = city,
-- 					waterEdge = waterEdge, resLayer = resLayer, mountainLayer =mountainLayer,
-- 					water = water,gridNode = gridNode,
-- 					--[[level1ResNode = level1ResNode,]] 
-- 					fogLayer = fogLayer, additionWall = additionwallBatchNode, 
-- 					grass = grass, expand = expand,zhuzhaNode = zhuzha}
-- end

function setObject( layer, grass,resLayer, building, zhuzha, animationNode,newGuideNode,armyPassNode )
	objectArray = {grass = grass, resLayer = resLayer, building = building, zhuzha = zhuzha, animationNode = animationNode, newGuideNode = newGuideNode, 
				layer = layer, armyPassNode = armyPassNode}
end

function getObject( )
	return objectArray
end

function setRootLayer( layer )
	m_rootLayer = layer
end

function getRootLayer(  )
	return m_rootLayer
end

--点击的地块
function setTouchLayer( layer )
	m_touchLayer = layer
end

function getTouchLayer( )
	return m_touchLayer
end

--获取已经加载网络的区域
function getArea( )
	return area
end

function setMapArea(row_up, row_down, col_left, col_right )
	mapArea.row_up = (row_up < 1 and 1) or row_up
	mapArea.row_down = (row_down > size and size) or row_down
	mapArea.col_left = (col_left < 1 and 1) or col_left
	mapArea.col_right = (col_right > size and size) or col_right
end

function getMapArea( )
	return mapArea
end

--获取空的纹理
function getEmptyRect( )
	return CCRectMake(4000,4000,400,220)
end

--记录所有要运行烟囱冒烟的数据
function setSmokeData(wid,parentTag,view)
	if not smokeData[wid] then
		smokeData[wid] = {}
	end
	table.insert(smokeData[wid], {parentTag = parentTag, view = view})
end

--获取烟雾的数据
function getSmokeData( )
	return smokeData
end

--根据wid删除烟雾数据
function deleteSmokeDataByWid( wid )
	smokeData[wid] = {}
end

--删除所有烟雾数据
function deleteAllSmokeData( )
	smokeData = {}
end

--服务器传过来的地表数据
function setBuildingData( message)
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		m_totalCount = m_totalCount + 1
	end
	buildingData[message.x][message.y] = { coorX = message.x, coorY = message.y, cityType = message.cityType, union_id = message.union_id,
											affilated_union_id = message.affilated_union_id, userId = message.userId, relation = message.relation}
end

function setCity_typeBuildingData( message)
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].cityType then
		buildingData[message.x][message.y].cityType = nil
	end
	buildingData[message.x][message.y].cityType = message.cityType
end

local function setBelong_cityData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].belong_city then
		buildingData[message.x][message.y].belong_city = nil
	end
	buildingData[message.x][message.y].belong_city = message.belong_city
end

local function setUnion_idBuildingData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].union_id then
		buildingData[message.x][message.y].union_id = nil
	end
	buildingData[message.x][message.y].union_id = message.union_id
end

local function setAffilated_union_idBuildingData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].affilated_union_id then
		buildingData[message.x][message.y].affilated_union_id = nil
	end
	buildingData[message.x][message.y].affilated_union_id = message.affilated_union_id
end

local function setUserIdBuildingData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].userId then
		buildingData[message.x][message.y].userId = nil
	end

	if not buildingData[message.x][message.y].cityName then
		buildingData[message.x][message.y].cityName = nil
	end
	buildingData[message.x][message.y].userId = message.userId
	buildingData[message.x][message.y].cityName = message.name
end

local function setRelationBuildingData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].relation then
		buildingData[message.x][message.y].relation = nil
	end

	buildingData[message.x][message.y].relation = message.relation
end

local function setViewInfoData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].view_info then
		buildingData[message.x][message.y].view_info = {}
	end

	for i, v in pairs(buildingData[message.x][message.y].view_info) do
		--更新
		if v.armyid == message.armyid and message.state ~= 0 then
			buildingData[message.x][message.y].view_info[i] = message
			return
		--删除
		elseif v.armyid == message.armyid and message.state == 0 then
			table.remove(buildingData[message.x][message.y].view_info,i)
			return
		end
	end

	--增加
	if message.state ~= 0 then
		table.insert(buildingData[message.x][message.y].view_info, message)
	end

	-- if not buildingData[message.x][message.y].view_info then
	-- 	buildingData[message.x][message.y].view_info = nil
	-- end
	-- buildingData[message.x][message.y].view_info = message.view_info
	-- buildingData[message.x][message.y].userInfo = message.userInfo
end

local function setCityFacade( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].viewStr then
		buildingData[message.x][message.y].viewStr = nil
	end
	buildingData[message.x][message.y].viewStr = message.viewStr
end

local function setFogBuildingData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	local joinWid = Tb_cfg_world_join[message.x*10000+message.y]
	if joinWid and joinWid.wid ~= joinWid.target_wid then return end
	
	if message.fog == 1 then
		if joinWid and joinWid.wid == joinWid.target_wid then
			
			for i,v in pairs(worldJoinList[joinWid.target_wid]) do
				-- if v.target_wid == message.x*10000+message.y then
					WarFogData.insertFogEgdeData(math.floor(v/10000),v%10000)
				-- end
			end
			-- for i,v in pairs(Tb_cfg_world_join) do
			-- 	if v.target_wid == message.x*10000+message.y then
			-- 		WarFogData.insertFogEgdeData(math.floor(v.wid/10000),v.wid%10000)
			-- 	end
			-- end
		else
			WarFogData.insertFogEgdeData(message.x,message.y)
		end
	end
end

local function setWallTypeData(message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].wallStr then
		buildingData[message.x][message.y].wallStr = nil
	end
	buildingData[message.x][message.y].wallStr = message.wallStr
end

local function setProtect_end_timeData( message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].protect_end_time then
		buildingData[message.x][message.y].protect_end_time = nil
	end
	buildingData[message.x][message.y].protect_end_time = message.protect_end_time
end

local function setGuard_end_timeData(message )
	if not mapData.isInArea(message.x,message.y) then return end
	if not buildingData[message.x] then
		buildingData[message.x] = {}
	end

	if not buildingData[message.x][message.y] then
		buildingData[message.x][message.y] = {}
		m_totalCount = m_totalCount + 1
	end

	if not buildingData[message.x][message.y].guard_end_time then
		buildingData[message.x][message.y].guard_end_time = nil
	end
	buildingData[message.x][message.y].guard_end_time = message.guard_end_time
end

function setCityComponentData(coorX,coorY,parent, child, viewstr )
	if not cityComponentData[coorX*10000+coorY] then
		cityComponentData[coorX*10000+coorY] = {}
	end
	table.insert(cityComponentData[coorX*10000+coorY], {parentTag =parent, childTag = child, view = viewstr})
	-- if math.floor(child/10000) <= size and math.floor(child/10000) >= 1 and child%10000 <= size and child%10000 >= 1 then
	-- 	if not clippingResData[child] then
	-- 		clippingResData[child] = 1
			-- mapController.removeClippingRes(math.floor(child/10000), child%10000)
	-- 	else
	-- 		clippingResData[child] = clippingResData[child] + 1
	-- 	end
	-- end

end

local function removeAllUserInfoInMap( )
	m_userInfoInMap = {}
end

--设置当前屏幕玩家的信息
function setUserInfoInMap(message )
	m_userInfoInMap[message.userid] = {userid = message.userid, union_id = message.union_id, affilated_union_id = message.affilated_union_id}
end

function getUserInfoInMap( userid )
	return m_userInfoInMap[userid]
end

function getClippingResData(coorX, coorY )
	return clippingResData[coorX*10000+coorY]
end

function getCityComponentData( coorX,coorY )
	return cityComponentData[coorX*10000+coorY]
end

--清空建筑数据
function deleteAllBuildingData( )
	buildingData = {}
	m_totalCount = 0
end

function deleteBuildingDataByArea( xBegin, xEnd, yBegin, yEnd )
	for i = xBegin, xEnd do
		for j = yBegin, yEnd do
			if buildingData[i] and buildingData[i][j] then
				deleteBuildingData(i,j)
			end
		end
	end
end

--删除某点建筑数据
function deleteBuildingData(coorX, coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] then
		buildingData[coorX][coorY] = nil
	end
end

function getBuildingData( )
	return buildingData
end

function getUserIdByWid( coorX, coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].userId then
		return buildingData[coorX][coorY].userId
	end
	return false
end

function isSelfLand(coorX, coorY)
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].userId then
		if buildingData[coorX][coorY].userId == userData.getUserId() then
			return true
		else
			return false
		end
	else
		return false
	end
end

function getLandOwnerInfo( coorX, coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].userId then
		return buildingData[coorX][coorY].userId
	else
		return false
	end
end

function getRelation( coorX,coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].relation then
		return buildingData[coorX][coorY].relation
	else
		return false
	end
end

function getBuildingView(coorX,coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].viewStr then
		return buildingData[coorX][coorY].viewStr
	else
		return false
	end
end

function getBuildingWall( coorX,coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].wallStr then
		return buildingData[coorX][coorY].wallStr
	else
		return false
	end
end

function getCityTypeData(coorX,coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].cityType then
		return buildingData[coorX][coorY].cityType
	else
		return false
	end
end

function getViewInfoData( coorX,coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].view_info then
		return buildingData[coorX][coorY].view_info
	else
		return false
	end
end

function getProtect_end_timeData(coorX,coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].protect_end_time then
		return buildingData[coorX][coorY].protect_end_time
	else
		return false
	end
end

function getGuard_end_timeData( coorX,coorY )
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].guard_end_time then
		return buildingData[coorX][coorY].guard_end_time
	else
		return false
	end
end

function getFieldArmyMsgByArmyId( armyid )
	if fieldArmyData[armyid] then
		return fieldArmyData[armyid]
	else
		return false
	end
end

function getFieldArmyMsg( )
	return fieldArmyData
end

local function setFieldArmyMsg(message )
	if not fieldArmyData[message.armyid] then
		fieldArmyData[message.armyid]= {}
	end

	fieldArmyData[message.armyid] = message
end

local function setFieldArmyMsgNullById( armyid )
	fieldArmyData[armyid] = nil
end

local function setFieldArmyMsgNull(  )
	fieldArmyData = {}
end


local function check_connect_state(temp_relation)
	if not temp_relation then return false end
	if temp_relation == mapAreaRelation.own_self or temp_relation == mapAreaRelation.free_ally or temp_relation == mapAreaRelation.free_underling then
		return true
	end
	return false
end
local function judge_connect_state(coorX, coorY)
	local is_connect = false
	for i=-1,1 do
		for j=-1,1 do
			if not (i == 0 and j == 0) then
				local temp_relation = getRelation(coorX + i, coorY + j)
				if check_connect_state(temp_relation) then 
					is_connect = true
					break
				end
				if not is_connect and Tb_cfg_world_join[(coorX + i)*10000 + coorY + j] then
					for k,v in pairs(worldJoinList[Tb_cfg_world_join[(coorX + i)*10000 + coorY + j].target_wid]) do
						local temp_x = math.floor(v/10000)
						local temp_y = v%10000
						temp_relation = getRelation(temp_x, temp_y)
						if check_connect_state(temp_relation) then 
							is_connect = true
							break
						end
					end
				end
			end
		end
	end

	return is_connect
end

--获取是否与可借地块连接状态
function getMapConnectState(coorX, coorY)
	if Tb_cfg_world_join[coorX*10000 + coorY] then
		local connect_state = false
		for k,v in pairs(worldJoinList[Tb_cfg_world_join[coorX*10000 + coorY].target_wid]) do
			local temp_x = math.floor(v/10000)
			local temp_y = v%10000
		 	connect_state = judge_connect_state(temp_x, temp_y)
		 	if connect_state then
		 		break
		 	end
		 end
		 return connect_state
	else
		return judge_connect_state(coorX, coorY)
	end
end

--获取是否可以借地块连接状态或者是自己人的土地
function getIsCanConnect(coorX, coorY)
	-- local valleyData = mapData.getValleyData()
    if not Tb_cfg_world_join[coorX*10000+coorY] and mapData.getCityType(coorX, coorY) and not valleyData[coorX*10000+coorY] then
        return false
    end

    if not Tb_cfg_world_join[coorX*10000+coorY] and terrain.isWaterTerrain(coorX, coorY) then
        return false
    end

    local first = getMapConnectState(coorX, coorY)
	local second = check_connect_state(getRelation(coorX, coorY))
	return first or second
end

--查找指定地块附近的一个一级地块 
--return_sign 0 表示返回相对偏移，1 表示返回具体坐标
function getLevelOneLand(coorX, coorY, return_sign)
	local temp_x, tmep_y = 0, 0
	for i=-2,2 do
		for j=-2,2 do
			if i == -2 or i == 2 or j == -2 or j == 2 then
				local res_level = math.floor(resourceData.resourceLevel(coorX + i, coorY + j)/10)
				if res_level == 1 then
					if return_sign == 0 then
						temp_x = i
						temp_y = j
					else
						temp_x = coorX + i
						temp_y = coorY + j
					end
					break
				end
			end
		end
	end
	
	return temp_x, temp_y
end

--删除某点加载的地图数据
function deleteLoadedMapData(coorX, coorY )
	if loadMapData[coorX] and loadMapData[coorX][coorY] then
		loadMapData[coorX][coorY] = nil
	end
end

--删除所有加载的地图数据
function deleteAllLoadedMapData( )
	loadMapData = {}
end

-- 设置山寨数据
function setValleyDataNull( wid )
	valleyData[wid] = nil
end

--获取山寨的数据
function getValleyData ( )
	return valleyData
end

--显示出来的草地 1
--丘陵 2
--水和沙地 3
--水和沙地边缘 4
--网格 5
--资源 6
--建筑batchnode 7
--山脉 8
--活动的时候的山城 9
--战争迷雾 10
--战争迷雾过渡 11

function getTagFunction( i,j,nodeType)
	-- return i*10000-j
	return nodeType*100000000+i*10000-j
end

function getRealWid(tag )
	return tag%100000000
end

--获取地图对象
function getLoadedMapLayer( coorX, coorY )
	local sprite
	local spr_type = ""
	local spriteNode = nil
	-- if terrain.returnTerrain(coorX, coorY) =="1" or terrain.returnTerrain(coorX, coorY) =="a41" or 
	-- 	 terrain.returnTerrain(coorX, coorY) =="a11" or terrain.returnTerrain(coorX, coorY) =="a21" or 
		 -- terrain.returnTerrain(coorX, coorY) =="a31" or resourceData.resourceLevel(coorX, coorY) == 11 then
	if terrain.returnTerrain(coorX, coorY) =="1" or resourceData.resourceLevel(coorX, coorY) == 11 then 
		spriteNode = MapNodeData.getWaterNode()[mapData.getTagFunction(coorX,coorY,mapElement.WATER)]
		if spriteNode then
			sprite= MapNodeData.getWaterNode()[mapData.getTagFunction(coorX,coorY,mapElement.WATER)][1] --objectArray.water:getChildByTag(mapData.getTagFunction(coorX,coorY))
			spr_type = "water"
		end
	else--terrain.returnTerrain(coorX, coorY) =="0" then
		spriteNode = MapNodeData.getSurfaceNode()[mapData.getTagFunction(coorX,coorY,mapElement.FOG)]
		if spriteNode then
			sprite= MapNodeData.getSurfaceNode()[mapData.getTagFunction(coorX,coorY,mapElement.FOG)][1]--objectArray.batchNode:getChildByTag(mapData.getTagFunction(coorX,coorY))
			spr_type = "node"
		end
	end
	if sprite then
		tolua.cast(sprite,"CCSprite")
		return sprite, spr_type
	end
	return nil
end

 -- 1	 自己	 	 	 可出征（打NPC）、可援军、完全共享连地，无法再度占领	 
 -- 3	 盟友，全正常状态	 	 		 
 -- 2	 敌对	 	 	 可出征、可占领，不可援军，不可使用目标的地进行连地	 
 -- 5	 盟友，但附属于不同的上级同盟	 	 		 
 -- 4	 盟友，但附属于同一个上级同盟	 	 	 不可出征（那就更不能占领了）、不可援军，不可使用目标的地进行连地	 
 -- 6	 无关系，但附属于同一个上级同盟	 	 		 
 -- 7	 自己的上级	 	 		 
 -- 8	 自己的下级	 	 	 不可出征（那就更不能占领了）、可援军，可使用他的地进行连地

 --0 无主 1 自己 2 自由状态-盟友 3 自由状态-下属 4 自由状态-敌对 5 附属状态-上级 6 附属状态-同上级 7 附属状态-敌对 8 附属状态-无主
function getRelationship( userId, union_id, affilated_union_id)
	local playerId = userData.getUserId()
	local player_union_id = userData.getUnion_id()
	local player_affilated_union_id = userData.getAffilated_union_id()

	--没归属
	if userId == 0 then
		if player_affilated_union_id == 0 then
			return mapAreaRelation.all_free
		else
			return mapAreaRelation.attach_free
		end
	end

	--自己的
	if userId == playerId then
		return mapAreaRelation.own_self
	end

	if player_affilated_union_id == 0 then
		if affilated_union_id == 0 then
			if player_union_id == union_id then
				if player_union_id ~= 0 and union_id ~= 0 then
					return mapAreaRelation.free_ally			--自己没有上属同盟，选择地没有上属同盟，我们是一个同盟的
				else
					return mapAreaRelation.free_enemy
				end
			else
				return mapAreaRelation.free_enemy			--自己没有上属同盟，选择地没有上属同盟，我们不是一个同盟的
			end
		else
			if affilated_union_id == player_union_id then
				return mapAreaRelation.free_underling			--自己没有上属同盟，选择地有上属同盟且是我的同盟ID
			else
				return mapAreaRelation.free_enemy				--自己没有上属同盟，选择地有上属同盟，他的上属同盟不是我的同盟
			end
		end
	else
		if player_affilated_union_id == union_id then
			return mapAreaRelation.attach_higher_up
		else
			if player_affilated_union_id == affilated_union_id then
				return mapAreaRelation.attach_enemy
			else
				return mapAreaRelation.attach_enemy
			end
		end
	end
end

function getRelationshipBetweenPlayer(oneuserId, oneunion_id, oneaffilated_union_id  ,userId, union_id, affilated_union_id)
	local playerId = oneuserId
	local player_union_id = oneunion_id
	local player_affilated_union_id = oneaffilated_union_id

	--没归属
	if userId == 0 then
		if player_affilated_union_id == 0 then
			return mapAreaRelation.all_free
		else
			return mapAreaRelation.attach_free
		end
	end

	--自己的
	if userId == playerId then
		return mapAreaRelation.own_self
	end

	if player_affilated_union_id == 0 then
		if affilated_union_id == 0 then
			if player_union_id == union_id then
				if player_union_id ~= 0 and union_id ~= 0 then
					return mapAreaRelation.free_ally			--自己没有上属同盟，选择地没有上属同盟，我们是一个同盟的
				else
					return mapAreaRelation.free_enemy
				end
			else
				return mapAreaRelation.free_enemy			--自己没有上属同盟，选择地没有上属同盟，我们不是一个同盟的
			end
		else
			if affilated_union_id == player_union_id then
				return mapAreaRelation.free_underling			--自己没有上属同盟，选择地有上属同盟且是我的同盟ID
			else
				return mapAreaRelation.free_enemy				--自己没有上属同盟，选择地有上属同盟，他的上属同盟不是我的同盟
			end
		end
	else
		if player_affilated_union_id == union_id then
			return mapAreaRelation.attach_higher_up
		else
			if player_affilated_union_id == affilated_union_id then
				return mapAreaRelation.attach_enemy
			else
				return mapAreaRelation.attach_enemy
			end
		end
	end
end

function getUnionRelationShip( unionid)
	local playerId = userData.getUserId()
	local player_union_id = userData.getUnion_id()
	local player_affilated_union_id = userData.getAffilated_union_id()

	if player_affilated_union_id  == 0 and unionid == 0 then
		return mapAreaRelation.all_free
	end

	if player_affilated_union_id  == 0 and unionid == player_union_id then
		return mapAreaRelation.free_ally
	end

	if player_affilated_union_id  == 0 and unionid ~= player_union_id then
		return mapAreaRelation.free_enemy
	end

	if player_affilated_union_id  ~= 0 and unionid == player_affilated_union_id and unionid ~=0 then
		return mapAreaRelation.attach_higher_up
	end

	if player_affilated_union_id  ~= 0 and unionid ~= player_union_id and unionid ~=0 then
		return mapAreaRelation.attach_enemy
	end

	if player_affilated_union_id  ~= 0 and unionid == 0 then
		return mapAreaRelation.attach_free
	end
	return mapAreaRelation.all_free
end

--是否在已经加载了数据的区域
function isInArea(coorX, coorY )
	if not area.row_up then return false end
	if coorX >= area.row_up and coorX <= area.row_down and coorY >= area.col_left and coorY <= area.col_right then
		return true
	else
		return false
	end
end

--是否需要向服务器请求地图信息
function isNeedMapData(coorX, coorY )
	if not area.row_up then return true end
	local rangeX, rangeY = config.getAddNetMapTimes()
	local row_up = (coorX - rangeX < 1 and 1) or coorX - rangeX
	local row_down = (coorX + rangeX > size and size) or coorX + rangeX
	local col_left = (coorY - rangeY < 1 and 1) or coorY - rangeY
	local col_right = (coorY + rangeY > size and size) or coorY + rangeY
	if math.abs(area.row_up - row_up) > rangeX/2 or math.abs(row_down - area.row_down) > rangeX/2 or math.abs(col_left -area.col_left) >rangeY/2 or math.abs(col_right - area.col_right) >rangeY/2 then
		return true
	else
		return false
	end 
end

--是否是山脉
function getCityType( x, y)
	-- local str = string.sub(mapTypeData, (coorX-1)*1501+coorY, (coorX-1)*1501+coorY)
	-- if not str or str=="C" or pngToData[str] == "8" then
	-- 	return false
	-- else
	-- 	return pngToData[str]
	-- end
	-- return mapTypeData[coorX*10000+coorY]

	local mountainType = function (coorX, coorY )
		if coorX < 1 or coorX > 1501 or coorY < 1 or coorY > 1501 then
			return false
		end

		local ter = string.sub(mapAllData,(coorX-1)*1501+coorY, (coorX-1)*1501+coorY)
		if not ter then
			return false
		end
		ter = string.byte(ter)+1
		return string.sub(worldMountainMapTable, ter, ter) 
	end

	local isInMountainArea = function (str, squrare )
		if str and (str == "2" or str == "3") then
			if squrare and squrare == 3 then
				if str == "3" then
					return true
				else
					return false
				end
			else
				return true
			end
		else
			return false
		end
	end

	
	local la = mountainType(x,y)

	if not la then
		return false
	elseif la == "0" then

		-- return false
		-- 右边1
		local right1 = mountainType( x, y-1)
		-- 下边1
		local down1 = mountainType(x-1,y)
		-- 右下1
		local right1Down1 = mountainType(x-1,y-1)

		-- 右边2
		local right2 = mountainType(x, y-2)
		--右2下1
		local right2Down1 = mountainType(x-1, y-2)
		--右2下2
		local right2Down2 = mountainType(x-2, y-2)
		--右1下2
		local right1Down2 = mountainType(x-2, y-1)
		--下2
		local down2 = mountainType(x-2, y)

		if isInMountainArea(right1) or isInMountainArea(down1) or isInMountainArea(right1Down1) or isInMountainArea(right2,3)
			or isInMountainArea(right2Down1,3) or isInMountainArea(right2Down2,3) or isInMountainArea(right1Down2,3)
			or isInMountainArea(down2,3) then
			
			return true
		else
			return false
		end
	else
		return la
	end
end

--请求地图信息
function requestMapData(coorX, coorY,isCity )
	local addMapTimesX, addMapTimesY = config.getAddNetMapTimes()
	local row_up = (coorX - addMapTimesX > 0 and coorX - addMapTimesX) or 1
	local row_down = (coorX + addMapTimesX <size and coorX + addMapTimesX) or size
	local col_left = (coorY - addMapTimesY  >0 and coorY - addMapTimesY) or 1
	local col_right = (coorY + addMapTimesY  < size and coorY + addMapTimesY) or size

	if not isCity then
		Net.send(GET_WORLD_INFO_CMD, {row_up, row_down, col_left, col_right})
	else
		Net.send(ENTER_CITY_CMD, {row_up, row_down, col_left, col_right})
	end
	-- loadingLayer.create(5)
	area = {row_up = row_up, row_down = row_down, col_left = col_left, col_right = col_right}
end

function deleteCityComponentData(  )
	cityComponentData = {}
end

function removeAllRelationData()
	-- local temp =objectArray.resLayer:getChildren()
	local temp_need_remove = {}
	local tagwid = nil
	local tag_table = {}
	local up, down, left, right = getMapArea().row_up, getMapArea().row_down, 
									getMapArea().col_left, getMapArea().col_right
	local tagX, tagY = nil,nil
	for i ,v in pairs(MapNodeData.getResourceNode()) do
		if v[1]:getChildrenCount() > 0 then
			tagwid = mapData.getRealWid(i )
			tagX = math.floor(tagwid/10000)+1
			tagY = tagX*10000-tagwid--math.floor(tagwid/10000), tagwid%10000
			if tagX < up or tagX > down
				or tagY < left or tagY > right then
				table.insert(temp_need_remove, v)
				table.insert(tag_table, i)
			end
		end
	end

	for i, v in ipairs(temp_need_remove) do
		MapNodeData.removeResourceNode(tag_table[i])
	end

	temp_need_remove = nil

	removeAllDefendFireData()
	MapNodeData.removeAllBuildingNode()
	MapNodeData.removeAllBetweenMountainNode()

	MapNodeData.removeAllYuanjunNode()
	
	mapController.removeSmoke()
	deleteCityComponentData()
	deleteAllSmokeData()
	deleteAllClippingResData()
end

function removeRelationDataInArea(xBegin, xEnd, yBegin, yEnd )
	local temp_need_remove = {}
	local tagwid = nil
	local tag_table = {}
	local up, down, left, right = xBegin, xEnd, yBegin, yEnd
	local tagX, tagY = nil,nil
	for i ,v in pairs(MapNodeData.getResourceNode()) do
		if v[1]:getChildrenCount() > 0 then
			tagwid = mapData.getRealWid(i )
			tagX = math.floor(tagwid/10000)+1
			tagY = tagX*10000-tagwid
			if tagX >= up and tagX <= down
				and tagY >= left and tagY <= right then
				v[1]:removeAllChildrenWithCleanup(true)
				if v[2] == "land_ground_1.png" or v[2] == "land_ground_2.png" or v[2] == "land_ground_3.png" or
					v[2] == "land_ground_4.png" or v[2] == "land_ground_5.png" or v[2] == "land_ground_6.png" or
					v[2] == "land_ground_7.png" or v[2] == "land_ground_8.png" or v[2] == "land_ground_9.png" then
					table.insert(temp_need_remove, v)
					table.insert(tag_table, i)
				end
			end
		end
	end

	local tempMapLayer = nil
	local locationX, locationY = nil, nil
	local res = nil
	for i, v in ipairs(temp_need_remove) do
		MapNodeData.removeResourceNode(tag_table[i])
		tagwid = mapData.getRealWid(tag_table[i] )
		tagX = math.floor(tagwid/10000)+1
		tagY = tagX*10000-tagwid
		res = resourceData.resourceLevel(tagX,tagY)
		if res then
			tempMapLayer = mapData.getLoadedMapLayer(tagX, tagY)
			if tempMapLayer then
				locationX, locationY = config.getMapSpritePos(tempMapLayer:getPositionX(),tempMapLayer:getPositionY(), tagX, tagY, tagX, tagY)
				mapController.addRes( locationX, locationY, tagX, tagY )
			end
		end
	end

	temp_need_remove = nil

	for i = xBegin, xEnd do
		for j = yBegin, yEnd do
			removeAllBuilding(i,j)
			mapController.removeAdditionWallNode(i,j)
		end
	end

	-- MapNodeData.removeAllYuanjunNode()
	
	mapController.removeSmoke()
	deleteAllSmokeData()
end

function removeDataOverArea( )
	local count = m_totalCount

	if count > 1000 then
		for i,v in pairs(buildingData) do
			for m , n in pairs(v) do
				if not landData.get_world_city_info(i*10000+m) then
					buildingData[i][m] = nil
					removeAllBuilding(i,m  )
					mapController.removeAdditionWallNode(i,m)
					m_totalCount = m_totalCount -1
					if m_totalCount < 0 then
						m_totalCount = 0
					end
				end
			end
		end
	end
end

function deleteAllClippingResData()
	clippingResData = {}
end

function removeCityComponentByWid( x,y )
	cityComponentData[x*10000+y] = nil
end

function removeDefendFireData( x,y )
	if m_defendFireData[x*10000+y] then
		for i, v in pairs(m_defendFireData[x*10000+y]) do
			v:removeFromParentAndCleanup(true)
		end
	end
	m_defendFireData[x*10000+y] = nil
end

function removeAllDefendFireData( )
	for i, v in pairs(m_defendFireData) do
		for k, m in pairs(v) do
			m:removeFromParentAndCleanup(true)
		end
	end
	m_defendFireData = {}
end

function insertDefendFireData(data,wid )
	if not m_defendFireData[wid] then
		m_defendFireData[wid] = {}
	end
	table.insert(m_defendFireData[wid], data)
end

function removeAllBuilding(x,y  )
	if cityComponentData[x*10000+y] then
		for i, v in pairs(cityComponentData[x*10000+y]) do
			MapNodeData.removeBuildingNode(v.parentTag)
			MapNodeData.removeBetweenMountainNode(v.parentTag)
		end
	end
	
	mapController.setLevel5animationVisible(x*10000+y, true )
	removeDefendFireData( x,y )

	removeCityComponentByWid(x,y)
	deleteSmokeDataByWid(x*10000+y)
end

local function addHiddenRes(x,y )
	local tempMapLayer = nil
	local locationX, locationY = nil, nil
	--把原本删除的资源地加上
	for i=x-1, x+1 do
		for j=y-1, y+1 do
			local res = resourceData.resourceLevel(i,j)
			if res then
				-- local tempMapLayer = MapNodeData.getResourceNode()[mapData.getTagFunction(i,j, mapElement.RES)]
				MapNodeData.removeResourceNode(mapData.getTagFunction(i,j, mapElement.RES))
				tempMapLayer = mapData.getLoadedMapLayer(i, j)
				if tempMapLayer then
					locationX, locationY = config.getMapSpritePos(tempMapLayer:getPositionX(),tempMapLayer:getPositionY(), i,j, i,j)
					mapController.addRes( locationX, locationY, i, j )
					mapController.addRelationLand(i,j)
				end
				-- if res ~= 12 and res ~= 11 and res ~= 36 then
				-- 	 --mapData.getObject().resLayer:getChildByTag(mapData.getTagFunction(i,j))
				-- 	if tempMapLayer then
				-- 		local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("land_"..res..".png")
				-- 		if spriteFrame then
				-- 			local texture = spriteFrame:getRect()
				-- 			tempMapLayer:setTextureRect(texture)
				-- 		end
				-- 	end
				-- end
			end
		end
	end
end

local function frameFuncRefresh( refreshTable )
	local count = #refreshTable[1] + #refreshTable[2]+ #refreshTable[3]
	if count <= 0 then return end
	local funcIndex = 1
	local funcType = 1
	local countIndex = 0
	if map.getInstance() then
		local timerIndex = nil
		for i=1, 100 do
			if not refreshTimer[i] then
				timerIndex = i
				break
			end
		end

		refreshTimer[timerIndex] = scheduler.create(function ( )
			countIndex = countIndex + 1
			if countIndex > count then
				scheduler.remove(refreshTimer[timerIndex])
				refreshTimer[timerIndex] = nil
			end

			if refreshTable[funcType][funcIndex] then
			else
				funcType = funcType + 1
				funcIndex = 1
				if not refreshTable[funcType] then
					return
				end
				
				if not refreshTable[funcType][funcIndex] then
					if funcType == 3 then
						return
					end
					funcType = funcType + 1
					funcIndex = 1
				end
			end
			if refreshTable[funcType][funcIndex] then
				refreshTable[funcType][funcIndex][1](refreshTable[funcType][funcIndex][2], refreshTable[funcType][funcIndex][3])
				funcIndex = funcIndex + 1
			end
		end,0.05)

		-- local action = function ( )
		-- 	return cc.CallFunc:create(function ( )
		-- 		if refreshTable[funcType][funcIndex] then
		-- 		else
		-- 			funcType = funcType + 1
		-- 			funcIndex = 1
		-- 			if not refreshTable[funcType] then
		-- 				return
		-- 			end
					
		-- 			if not refreshTable[funcType][funcIndex] then
		-- 				if funcType == 3 then
		-- 					return
		-- 				end
		-- 				funcType = funcType + 1
		-- 				funcIndex = 1
		-- 			end
		-- 		end
		-- 		if refreshTable[funcType][funcIndex] then
		-- 			refreshTable[funcType][funcIndex][1](refreshTable[funcType][funcIndex][2], refreshTable[funcType][funcIndex][3])
		-- 			funcIndex = funcIndex + 1
		-- 		end
		-- 	end)
		-- end

		-- local actionTable = {}
		-- for i=1, count do
		-- 	table.insert(actionTable, cc.DelayTime:create(0.05))
		-- 	table.insert(actionTable, action())
		-- end
		-- map.getInstance():runAction(animation.sequence(actionTable))
	end
end

--服务器发送过来请求的区域地图信息
-- city_type;// 0:系统保留，请不要使用 1:玩家主城, 2：领地, 3：玩家分城, 4:要塞
-- 							// ,6:码头,7:村庄,8:npc城
-- [ [userid,unionid,affiliate...], [xBegin,yBegin,xEnd,yEnd,"101010..."] 
-- , [x,y,city_type,userid,name,belong_city,protect_end_time, guard_end_time...] ,[x,y,"fadace"...],
-- [[armyid,state,userid,user_name,union_name,wid_from,wid_to,begin_time,end_time],[...]]  ]
-- [x,y,level] 山寨
--当citytype是分城或者要塞，且在外观的字段找不到坐标，或者是"",或者是废墟的外观。则是正在分城或者要塞建设中
-- view_info:1，免战，2：分城建设中，3：要塞建设中，5：驻扎 6：援军,7:等待下一场战斗，示例：1,endtime;5,userid;"
function reciveData(packet )
	local userId
	local union_id
	local affilated_union_id
	local relation
	local city_type
	local belong_city = nil
	local x
	local y
	local protect_end_time = nil
	local userInfo = {}
	local cityFacade = {} --建筑外观
	local xBegin = nil
	local xEnd = nil
	local yBegin = nil
	local yEnd = nil
	local guard_end_time = nil

	local isFarming = false
	local isTraining = false

	if packet[2] ~= cjson.null then
		xBegin = packet[2][1]
		xEnd = packet[2][3]
		yBegin = packet[2][2]
		yEnd = packet[2][4]
	end

	removeDataOverArea( )
	removeAllUserInfoInMap( )
	BuildCityAnimation.removeAll()
	deleteBuildingDataByArea( xBegin, xEnd, yBegin, yEnd )
	WarFogData.deleteStencilByArea()
	removeRelationDataInArea(xBegin, xEnd, yBegin, yEnd )

	--把要塞和分城选出来
	local yaosaiAndfencheng = {}



	if packet[1] ~= cjson.null then
		for i=1, table.getn(packet[1]),3 do
			userInfo[packet[1][i]] = {packet[1][i+1], packet[1][i+2]}
			setUserInfoInMap({userid =packet[1][i], union_id = packet[1][i+1], affilated_union_id=packet[1][i+2] })
		end
	end

	if packet[3] ~= cjson.null then
		
		for i=1, table.getn(packet[3]), 8 do
			x = packet[3][i]
			y = packet[3][i+1]
			city_type = packet[3][i+2]
			if city_type == cityTypeDefine.yaosai then
				yaosaiAndfencheng[x*10000+y] = packet[3][i+2]
			elseif city_type == cityTypeDefine.fencheng then
				yaosaiAndfencheng[x*10000+y] = packet[3][i+2]
			end			
			userId = packet[3][i+3]
			belong_city = packet[3][i+5]
			protect_end_time = packet[3][i+6]
			guard_end_time = packet[3][i+7]
			setCity_typeBuildingData({x=x,y=y,cityType=city_type})
			setBelong_cityData({x=x,y=y,belong_city=belong_city})
			setProtect_end_timeData({x=x,y=y,protect_end_time=protect_end_time})
			setGuard_end_timeData({x=x,y=y,guard_end_time=guard_end_time})
			setUserIdBuildingData({x=x,y=y,userId=userId, name = packet[3][i+4]})

			if userInfo[userId] or userId == 0 or cityTypeDefine.npc_cheng == city_type then
				-- 当是归属个人的时候
				if userInfo[userId] and cityTypeDefine.npc_cheng ~= city_type then
					union_id = userInfo[userId][1]
					affilated_union_id = userInfo[userId][2]
					setRelationBuildingData({x=x, y=y, relation= getRelationship(userId,union_id,
								 affilated_union_id)})
				else
					union_id = userId
					affilated_union_id = 0--userInfo[userId][2]
					setRelationBuildingData({x=x, y=y, relation= getUnionRelationShip(union_id)})
				end
				setUnion_idBuildingData({x=x,y=y,union_id= union_id})
				setAffilated_union_idBuildingData({x=x,y=y,affilated_union_id= affilated_union_id})
			end
			mapController.addRelationLand(x,y)
		end
		isFarming = true
		isTraining = true
		-- MapFarming.createAll( )
		-- MapTraining.createAll()
	end

	local fog = nil
	if packet[2] ~= cjson.null then
		local count = 0
		for i=packet[2][1], packet[2][3] do
			for v=packet[2][2], packet[2][4] do
				count = count + 1
				fog = tonumber(string.sub(packet[2][5],count,count))
				setFogBuildingData({x=i,y=v,fog = fog})
				if fog == 1 then
					mapController.setLevel5animationVisible(i*10000+v,true)
				else
					-- mapController.setLevel5animationVisible(i*10000+v,false)
					MapNodeData.removeLevel5AnimationNode( i*10000+v )
				end
			end
		end
	end

	local view = nil
	local wall = nil
	if packet[4] ~= cjson.null then
		for i=1, table.getn(packet[4]),3 do
			if string.len(packet[4][i+2])>0 then
				view,wall = CityComponentType.changeIndexWithServer(packet[4][i+2])
				setCityFacade({x=packet[4][i],y=packet[4][i+1],viewStr=view})
				setWallTypeData({x=packet[4][i],y=packet[4][i+1],wallStr = wall})
				mapController.addBuilding(packet[4][i], packet[4][i+1],view, wall)
				if yaosaiAndfencheng[packet[4][i]*10000+packet[4][i+1]] and packet[4][i+2] ~= CityComponentType.getRuinsView()  then
					yaosaiAndfencheng[packet[4][i]*10000+packet[4][i+1]] = nil
				end
				BuildCityAnimation.create(packet[4][i]*10000+packet[4][i+1])
			end
		end
		local coorX,coorY = nil,nil
		for i, v in pairs(yaosaiAndfencheng) do
			coorX, coorY = math.floor(i/10000),i%10000
			view = CityComponentType.setBuildingDeleteOrBuildFacade(v)
			setCityFacade({x=coorX,y=coorY,viewStr=view})
			setWallTypeData({x=coorX,y=coorY,wallStr = "~"})
			mapController.addBuilding(coorX,coorY,view,"~")
			BuildCityAnimation.create(i)
		end
	end

	-- [[armyid,state,userid,user_name,union_name,wid_from,wid_to,begin_time,end_time],[armyid,0]]
	
	if packet[5] ~= cjson.null and packet[5] then
		for i, v in pairs(getFieldArmyMsg()) do
			-- 敌袭应该由服务器推送删除
			if not armyData.getAssaultTeamMsg(i) then
				armyMark.armyRemove(i)
			end
		end
		setFieldArmyMsgNull()
		for m,n in ipairs(packet[5]) do
			for i=1, table.getn(n), 9 do
				setFieldArmyMsg({wid_from = n[i+5], wid_to = n[i+6], begin_time = n[i+7], end_time = n[i+8],
							armyid= n[i], userid = n[i+2], user_name = n[i+3], union_name=n[i+4],
							state = n[i+1],
							relation = getRelationship(n[i+2],userInfo[n[i+2]][1], userInfo[n[i+2]][2])} )

				-- zhuzhaed = 5, yuanjuned = 6, sleeped
				if n[i+1] == armyState.zhuzhaed or n[i+1] == armyState.yuanjuned or n[i+1] == armyState.sleeped then
					-- n[i+1] == armyState.decreed or n[i+1] == armyState.training then
					setViewInfoData({x = math.floor(n[i+5]/10000), y= n[i+5]%10000, state = n[i+1], userid = n[i+2], armyid = n[i], 
						relation = getRelationship(n[i+2],userInfo[n[i+2]][1], userInfo[n[i+2]][2]) })
				end

				if n[i+1] == armyState.decreed then
					isFarming = true
				end

				if n[i+1] == armyState.training then
					isTraining = true
				end
			end
		end
		armyMark.armyUnionUpdate(getFieldArmyMsg() )
	end

	for i, v in pairs(valleyData) do
		mapController.removeAdditionWallNode(math.floor(i/10000),i%10000)
	end
	valleyData = {}
	-- 当level是0的时候代表删除该wid的山寨
	if packet[6] ~= cjson.null and packet[6] then
		local wid = nil
		local level = nil
		local x, y = nil, nil
		for i=1, table.getn(packet[6]),3 do
			-- for i=1, table.getn(n), 3 do
				x, y = packet[6][i], packet[6][i+1]
				wid = x*10000+y
				level = packet[6][i+2]
				if level == 0 then
					mapController.removeAdditionWallNode(x,y)
					if valleyData[wid] then
						valleyData[wid] = nil
					end
				else
					valleyData[wid] = level
					mapController.addAdditionWall(x,y,valley_image_cfg[level], x,y)
				end
			-- end
		end
	end

	mapController.removeFog()
	armyListManager.dealWithOtherArmyUpdate()
	setMapLandInfoIfMyself()
	-- MapResidence.removeAll()
	-- MapLandInfo.removeAll()
	-- CityName.removeAll()

	local refreshTable = {[1] = {}, [2] = {}, [3] = {}}
	local temp_area = mapData.getArea()
	local protect_end_time = nil
	local city_type = nil
	local citynameData = {}
	local landInfo = {}
	local mapYuanjun = {}
	local war_status = {}
	for i, v in pairs(CityName.getCityNameArr()) do
		citynameData[i] = 1
	end

	for i, v in pairs(MapLandInfo.getMapLandInfoArr()) do
		landInfo[i] = 1
	end

	for i, v in pairs(MapArmyWarStatus.getMapLandInfoArr()) do
		war_status[i] = 1
	end

	local tagwid = nil
	local tagX = nil
	local tagY = nil
	for i, v in pairs(MapNodeData.getYuanjunNode()) do
		tagwid = mapData.getRealWid(i )
		tagX = math.floor(tagwid/10000)+1
		tagY = tagX*10000-tagwid
		mapYuanjun[tagX*10000+tagY] = 1
	end

	for i = temp_area.row_up, temp_area.row_down do
		for m = temp_area.col_left, temp_area.col_right do
			if buildingData[i] and buildingData[i][m] then
				if buildingData[i][m].cityType and buildingData[i][m].cityName and string.len(buildingData[i][m].cityName)>0 then
					table.insert(refreshTable[1], {CityName.create, i, m})
					citynameData[i*10000+m] = nil
				end

				protect_end_time = buildingData[i][m].protect_end_time
				city_type = buildingData[i][m].cityType
				if buildingData[i][m].view_info then
					table.insert(refreshTable[2], {MapArmyWarStatus.create, i, m})
					war_status[i*10000+m] = nil
				end

				if protect_end_time and protect_end_time > userData.getServerTime() and city_type and city_type ~= cityTypeDefine.zhucheng
						and city_type ~= cityTypeDefine.player_chengqu and city_type ~= cityTypeDefine.fencheng 
						and city_type ~= cityTypeDefine.yaosai and city_type ~= cityTypeDefine.npc_yaosai then
						table.insert(refreshTable[2], {MapLandInfo.create, i, m})
						landInfo[i*10000+m] = nil
				end

				if MapResidence.isYuanjun(buildingData[i][m].view_info) then
					table.insert(refreshTable[3], {MapResidence.create, i, m})
					-- mapYuanjun[i*10000+m] = nil
					for k=-1, 1 do
						for v = -1, 1 do
							-- mapYuanjun[i*10000+m] = nil
							if MapResidence.isCanYuanjun(mapData.getLandOwnerInfo(i+k,m+v),i+k,m+v) then
								mapYuanjun[(i+k)*10000+m+v] = nil
							end
						end
					end
				end
			end
		end
	end


	if isTraining then
		MapTraining.createAll()
	end

	if isFarming then
		MapFarming.createAll( )
	end

	-- 把已经不存在的cityname删除
	for i, v in pairs(citynameData) do
		CityName.removeByWid( math.floor(i/10000), i%10000 )
	end

	-- 把已经不存在的maplandInfo里面的东西删除
	for i, v in pairs(landInfo) do
		MapLandInfo.removeByWid( math.floor(i/10000), i%10000 )
	end

	for i, v in pairs(war_status) do
		MapArmyWarStatus.removeByWid( math.floor(i/10000), i%10000 )
	end

	-- 把已经不存在的援军删除
	for i, v in pairs(mapYuanjun) do
		MapResidence.remove(i)
	end

	loadingLayer.remove()
	map.run3DAction(20)
	mapController.cityToTouchInfo()

	frameFuncRefresh( refreshTable )

	if not newGuideManager.get_guide_state() then 
		cityMsg.reloadData()
	end
	SmallMiniMap.setNpcCityColor()
end

--服务器推送某些地图信息的改变
-- city_type;// 0:系统保留，请不要使用 1:玩家主城, 2：领地, 3：玩家分城, 4:要塞
-- 							// ,6:码头,7:村庄,8:npc城
-- [ [userid,unionid,affiliate...], [xBegin,yBegin,xEnd,yEnd,"101010..."] 
-- , [x,y,city_type,userid,name, belong_city...] ,[x,y,"fadace"...] 
-- [[armyid,state,userid,user_name,union_name,wid_from,wid_to,begin_time,end_time,guard_end_time],[...]] ]
-- [x, y, level] 山寨
-- view_info:1，免战，3：分城建设中，4：要塞建设中，5：驻扎 6：援军,7:等待下一场战斗，示例：1,endtime;5,userid;"
function recivePostMapData(packet)
	local userId
	local union_id
	local affilated_union_id
	local relation
	local city_type
	local belong_city = nil
	local protect_end_time = nil
	local guard_end_time = nil
	local x
	local y
	local userInfo = {}
	local cityFacade = {} --建筑外观
	local isReloadZhuzha = false
	local isTraining = false
	local isFarming = false
	-- mapController.removeAllBuilding()
	
	-- removeAllRelationData()
	-- cityComponentData = {}
	-- mainCityData = {}
	-- additionComponentData = {}
	--把要塞和分城选出来
	local yaosaiAndfencheng = {}
	local viewInfo_wid = {}
	if packet[1] ~= null then
		for i=1, table.getn(packet[1]),3 do
			userInfo[packet[1][i]] = {packet[1][i+1], packet[1][i+2]}
			setUserInfoInMap({userid =packet[1][i], union_id = packet[1][i+1], affilated_union_id=packet[1][i+2] })
		end

		-- 每次关系有更新都要刷新视野内部队的关系状态
		if #packet[1] >0 then
			local widx, widy = nil, nil
			local last_relation = nil
			local isFresh = nil
			for i , v in pairs(getFieldArmyMsg()) do
				if userInfo[v.userid] then
					last_relation = v.relation
					v.relation = getRelationship(v.userid,userInfo[v.userid][1], userInfo[v.userid][2])
					if last_relation ~= v.relation then
						isFresh = true
						viewInfo_wid[v.wid_from] = 1
					end
					widx, widy = math.floor(v.wid_from/10000), v.wid_from%10000
					if buildingData[widx] and buildingData[widx][widy] and  buildingData[widx][widy].view_info then
						setViewInfoData({x = widx, y= widy, state = v.state, userid = v.userid, armyid = v.armyid, 
							relation = getRelationship(v.userid,userInfo[v.userid][1], userInfo[v.userid][2]) })
					end
				end
			end

			if isFresh then
				armyListManager.dealWithOtherArmyUpdate()
			end
		end
	end

	local view = nil
	local wall = nil
	-- if packet[4] ~= cjson.null and table.getn(packet[4]) > 0 then
	-- 	mapController.removeAllBuilding()
	-- 	for i,v in pairs(buildingData) do
	-- 		for m,n in pairs(v) do
	-- 			removeAllBuilding(i,m)
	-- 		end
	-- 	end
	-- end


	if packet[2] ~= cjson.null and table.getn(packet[2])>0 then
		-- MapLandInfo.removeAll()
		-- CityName.removeAll()
		WarFogData.deleteStencilByArea()
		local fog = nil
		-- mapController.removeAllBuilding()
		-- for i,v in pairs(buildingData) do
		-- 	for m,n in pairs(v) do
		-- 		removeAllBuilding(i,m)
		-- 	end
		-- end
		
		local count = 0
		for i=packet[2][1], packet[2][3] do
			for v=packet[2][2], packet[2][4] do
				count = count + 1
				fog = tonumber(string.sub(packet[2][5],count,count))
				setFogBuildingData({x=i,y=v,fog = fog})
				if fog == 1 then
					mapController.setLevel5animationVisible(i*10000+v,true)
				else
					-- mapController.setLevel5animationVisible(i*10000+v,false)
					MapNodeData.removeLevel5AnimationNode( i*10000+v )
				end
			end
		end
		mapController.removeFog()
		-- WarFog.addWarFog()
		-- setMapLandInfoIfMyself()
	end

	local old_city_type = nil
	local cityDisplayNameData = {}
	if packet[3] ~= cjson.null and table.getn(packet[3])>0 then
		isReloadZhuzha = true
		for i=1, table.getn(packet[3]), 8 do
			x = packet[3][i]
			y = packet[3][i+1]
			city_type = packet[3][i+2]
			userId = packet[3][i+3]
			belong_city = packet[3][i+5]
			protect_end_time = packet[3][i+6]
			guard_end_time = packet[3][i+7]
			old_city_type = getCityTypeData(x, y ) 
			cityDisplayNameData[x*10000+y] = 1
			--当以前是主城或者分城但是现在不是的时候，要把以前隐藏的资源地显示出来
			if old_city_type and (old_city_type == cityTypeDefine.fencheng or old_city_type == cityTypeDefine.zhucheng) and 
				city_type ~= cityTypeDefine.fencheng and city_type ~= cityTypeDefine.zhucheng then
				addHiddenRes(x,y)
			end

			if old_city_type and (old_city_type == cityTypeDefine.fencheng or old_city_type == cityTypeDefine.yaosai) and
				city_type ~= cityTypeDefine.fencheng and city_type ~= cityTypeDefine.yaosai then
				if getBuildingView(x,y) == CityComponentType.getFengchengView() or getBuildingView(x,y) == CityComponentType.getYaosaiView() then
					removeAllBuilding(x,y)
					BuildCityAnimation.removeAnimationByWid(x*10000+y)
				end
			end

			if city_type == cityTypeDefine.yaosai then
				yaosaiAndfencheng[x*10000+y] = packet[3][i+2]
			elseif city_type == cityTypeDefine.fencheng then
				yaosaiAndfencheng[x*10000+y] = packet[3][i+2]
			end	
			-- if cityTypeDefine.npc_cheng == city_type then
				-- setUserIdBuildingData({x=x,y=y,userId=0, name = packet[3][i+4]})
			-- elseif cityTypeDefine.npc_chengqu ~= city_type --[[and cityTypeDefine.lingdi ~= city_type]] then
				setUserIdBuildingData({x=x,y=y,userId=userId, name = packet[3][i+4]})
			-- end
			setCity_typeBuildingData({x=x,y=y,cityType=city_type})
			setBelong_cityData({x=x,y=y,belong_city=belong_city})
			setProtect_end_timeData({x=x,y=y,protect_end_time=protect_end_time})
			setGuard_end_timeData({x=x,y=y,guard_end_time=guard_end_time})
			mapController.addDefendFire( x, y )
			viewInfo_wid[x*10000+y] = 1
			if userInfo[userId] or userId == 0 or cityTypeDefine.npc_cheng == city_type then
				if userInfo[userId] then
					union_id = userInfo[userId][1]
					affilated_union_id = userInfo[userId][2]
					setRelationBuildingData({x=x, y=y, relation= getRelationship(userId,union_id,
									 affilated_union_id)})
				elseif userId == 0 and cityTypeDefine.npc_cheng ~= city_type then
					union_id = 0
					affilated_union_id = 0
					setRelationBuildingData({x=x, y=y, relation= getRelationship(userId,union_id,
									 affilated_union_id)})
				else
					union_id = userId
					affilated_union_id = 0
					setRelationBuildingData({x=x, y=y, relation= getUnionRelationShip(union_id)})
				end
				setUnion_idBuildingData({x=x,y=y,union_id= union_id})
				setAffilated_union_idBuildingData({x=x,y=y,affilated_union_id= affilated_union_id})
				mapController.addRelationLand(x, y)
				mapController.changeFlagColor(x, y)
			end
		end
		isTraining = true
		isFarming = true
		-- MapFarming.createAll( )
		-- MapTraining.createAll()
		BuildingExpand.reload()
	end

	-- if packet[4] ~= cjson.null and table.getn(packet[4])>0 then
	-- 	local isFlag = false
	-- 	isReloadZhuzha =true
	-- 	for i=1, table.getn(packet[4]), 3 do
	-- 		local temp = {}
	-- 		for j=1, table.getn(packet[4][i+2]),2 do
	-- 			if packet[4][i+2][j] ~= 1 then
	-- 				temp[packet[4][i+2][j+1]] = {union_id = userInfo[packet[4][i+2][j+1]][1],
	-- 											affilated_union_id = userInfo[packet[4][i+2][j+1]][2],
	-- 											relation = getRelationship(packet[4][i+2][j+1],userInfo[packet[4][i+2][j+1]][1], userInfo[packet[4][i+2][j+1]][2]) }
	-- 			end
	-- 		end
	-- 		setViewInfoBuildingData({x=packet[4][i],y=packet[4][i+1],view_info=packet[4][i+2],
	-- 									userInfo = temp })
	-- 		MapLandInfo.create(packet[4][i],packet[4][i+1])
	-- 	end
	-- end

	if packet[4] ~= cjson.null then
		for i=1, table.getn(packet[4]),3 do
			isReloadZhuzha = true
			if string.len(packet[4][i+2])>0 then
				view,wall = CityComponentType.changeIndexWithServer(packet[4][i+2])
				removeAllBuilding(packet[4][i],packet[4][i+1])
				setCityFacade({x=packet[4][i],y=packet[4][i+1],viewStr=view})
				setWallTypeData({x=packet[4][i],y=packet[4][i+1],wallStr = wall})
				mapController.addBuilding(packet[4][i], packet[4][i+1],view, wall)
				if yaosaiAndfencheng[packet[4][i]*10000+packet[4][i+1]] and packet[4][i+2] ~= CityComponentType.getRuinsView()  then
					yaosaiAndfencheng[packet[4][i]*10000+packet[4][i+1]] = nil
				end
				BuildCityAnimation.create(packet[4][i]*10000+packet[4][i+1])
			--如果是空，就是要删除原先的东西
			elseif string.len(packet[4][i+2])==0 then
				removeAllBuilding(packet[4][i],packet[4][i+1])
				setCityFacade({x=packet[4][i],y=packet[4][i+1],viewStr=nil})
				setWallTypeData({x=packet[4][i],y=packet[4][i+1],wallStr = nil})
				BuildCityAnimation.removeAnimationByWid(packet[4][i]*10000+packet[4][i+1])
			end
		end
		local coorX,coorY = nil,nil
		--如果是增量更新，那么需要对比外观才能确定是否是分城或者要塞建筑中
		for i, v in pairs(yaosaiAndfencheng) do
			isReloadZhuzha = true
			coorX, coorY = math.floor(i/10000),i%10000
			if not getBuildingView(coorX, coorY) or getBuildingView(coorX, coorY) == CityComponentType.getRuinsView() then
				removeAllBuilding(coorX,coorY)
				view = CityComponentType.setBuildingDeleteOrBuildFacade(v)
				setCityFacade({x=coorX,y=coorY,viewStr=view})
				setWallTypeData({x=coorX,y=coorY,wallStr = "~"})
				mapController.addBuilding(coorX,coorY,view,"~")
				BuildCityAnimation.create(i)
			end
		end
	end


	-- [[armyid,state,userid,user_name,union_name,wid_from,wid_to,begin_time,end_time],[armyid,0]]
	local temp_data = nil
	if packet[5] ~= cjson.null and packet[5] and table.getn(packet[5]) > 0 then
		for m,n in ipairs(packet[5]) do
			for i=1, table.getn(n), 9 do
				isReloadZhuzha = true
				isTraining = true
				isFarming = true
				if n[i+1] == 0 then
					if not armyData.getTeamMsg(n[i]) then
						temp_data = getFieldArmyMsgByArmyId(n[i])
						if temp_data then
							--删除
							setViewInfoData({x = math.floor(temp_data.wid_from/10000), y= temp_data.wid_from%10000, state = 0 
								})
							viewInfo_wid[temp_data.wid_from] = 1
						end
						setFieldArmyMsgNullById(n[i])
						-- 敌袭应该由服务器推送删除
						if not armyData.getAssaultTeamMsg(n[i]) then
							armyMark.armyRemove(n[i])
						end
					end
				else
					setFieldArmyMsg({wid_from = n[i+5], wid_to = n[i+6], begin_time = n[i+7], end_time = n[i+8],
							armyid= n[i], userid = n[i+2], user_name = n[i+3], union_name=n[i+4],
							state = n[i+1],
							relation = getRelationship(n[i+2],userInfo[n[i+2]][1], userInfo[n[i+2]][2])} )
					setViewInfoData({x = math.floor(n[i+5]/10000), y= n[i+5]%10000, state = n[i+1], userid = n[i+2], armyid = n[i], 
							relation = getRelationship(n[i+2],userInfo[n[i+2]][1], userInfo[n[i+2]][2]) })
					-- 敌袭应该由服务器推送删除
					if not armyData.getAssaultTeamMsg(n[i]) then
						armyMark.armyRemove(n[i])
					end
					armyMark.armyUnionUpdate({[1] = getFieldArmyMsgByArmyId(n[i])} )
					viewInfo_wid[n[i+5]] = 1
				end
			end
		end
		armyListManager.dealWithOtherArmyUpdate()
	end

	-- valleyData = {}
	-- 当level是0的时候代表删除该wid的山寨
	if packet[6] ~= cjson.null and packet[6] then
		local wid = nil
		local level = nil
		local x, y = nil, nil
		for i=1, table.getn(packet[6]),3 do
			-- for i=1, table.getn(n), 3 do
				x, y = packet[6][i], packet[6][i+1]
				wid = x*10000+y
				level = packet[6][i+2]
				if level == 0 then
					mapController.removeAdditionWallNode(x,y)
					if valleyData[wid] then
						valleyData[wid] = nil
					end
				else
					valleyData[wid] = level
					mapController.addAdditionWall(x,y,valley_image_cfg[level], x,y)
				end
			-- end
		end
	end

	--刷新援军改变
	if isReloadZhuzha then
		MapResidence.createAll()
	end

	if isTraining then
		MapTraining.createAll()
	end

	if isFarming then
		MapFarming.createAll( )
	end

	local refreshTable = {[1] = {}, [2] = {}, [3] = {}}
	for i, v in pairs(viewInfo_wid) do
		-- MapLandInfo.create(math.floor(i/10000), i%10000)
		-- CityName.create(math.floor(i/10000),i%10000 )
		table.insert(refreshTable[1], {CityName.create, math.floor(i/10000),i%10000})
		table.insert(refreshTable[2], {MapLandInfo.create, math.floor(i/10000),i%10000})
		table.insert(refreshTable[2], {MapArmyWarStatus.create, math.floor(i/10000),i%10000})
	end

	for i, v in pairs(cityDisplayNameData) do
		if not viewInfo_wid[i] then
			-- CityName.create(math.floor(i/10000),i%10000 )
			table.insert(refreshTable[1], {CityName.create, math.floor(i/10000),i%10000})
		end
	end

	frameFuncRefresh( refreshTable )
	SmallMiniMap.setNpcCityColor()
end

--自己的部队无论在是否在视野内都应该知道是否在战斗
function setMapLandInfoIfMyself()
	local armyInfo = armyData.getAllTeamMsg()
	local coorX = nil
	local coorY = nil

	for i,v in pairs(armyInfo) do
		-- m_oldArmydata[v.armyid] = {}
		-- for k,p in pairs(v) do
		-- 	m_oldArmydata[v.armyid][k] = p
		-- end
		coorX = math.floor(v.target_wid/10000)
		coorY = v.target_wid%10000
		if mapData.isInArea(coorX,coorY) then
			if v.state == armyState.sleeped or v.state == armyState.zhuzhaed or v.state == armyState.yuanjuned then
				setViewInfoData({x = coorX, y= coorY, state = v.state, userid =userData.getUserId() , armyid = v.armyid, 
							relation = mapAreaRelation.own_self })
			end
		end
	end
end

function setSelfArmyRemove( army_id )
	local oldArmydata = recordTableData[dbTableDesList.army.name][army_id]
	if oldArmydata then
		local coorX = math.floor(oldArmydata.target_wid/10000)
		local coorY = oldArmydata.target_wid%10000
		setViewInfoData({x = coorX, y= coorY, state = 0, userid =userData.getUserId(),armyid = oldArmydata.armyid})
		-- MapLandInfo.create(coorX, coorY)
		MapArmyWarStatus.create(coorX, coorY)
		CityName.reloadAll( )
		MapResidence.createAll()
	end
end

function setSelfArmyUpdate( packet )
	local oldArmydata = recordTableData[dbTableDesList.army.name][packet.armyid]--m_oldArmydata[packet.armyid]
	local coorX = nil
	local coorY = nil
	local armydata = armyData.getTeamMsg(packet.armyid)
	if (oldArmydata.state == armyState.sleeped or oldArmydata.state == armyState.zhuzhaed or oldArmydata.state == armyState.yuanjuned)
		and (armydata.state ~= armyState.sleeped and armydata.state ~= armyState.zhuzhaed and armydata.state ~= armyState.yuanjuned) then
		coorX = math.floor(oldArmydata.target_wid/10000)
		coorY = oldArmydata.target_wid%10000
		setViewInfoData({x = coorX, y= coorY, state = 0, userid =userData.getUserId(),armyid = oldArmydata.armyid})
		-- MapLandInfo.create(coorX, coorY)
		MapArmyWarStatus.create(coorX, coorY)
		MapResidence.createAll()
	end



	if armydata.state == armyState.sleeped or armydata.state == armyState.zhuzhaed or armydata.state == armyState.yuanjuned then
		coorX = math.floor(armydata.target_wid/10000)
		coorY = armydata.target_wid%10000
		setViewInfoData({x = coorX, y= coorY, state = armydata.state, userid =userData.getUserId() , armyid = armydata.armyid, 
							relation = mapAreaRelation.own_self })
		-- MapLandInfo.create(coorX, coorY)
		MapArmyWarStatus.create(coorX, coorY)
	end
	if (oldArmydata.state == armyState.yuanjuned and armydata.state ~= armyState.yuanjuned) or armydata.state == armyState.yuanjuned then
		MapResidence.createAll()
	end
	CityName.reloadAll( )
	-- for i ,v in pairs(packet) do
	-- 	m_oldArmydata[packet.armyid][i] = v
	-- end
end

function initData( )
	MapFarming.init()
	MapTraining.init()
	netObserver.addObserver(NOTIFY_WORLD_VIEW_CMD,reciveData)
	netObserver.addObserver(NOTIFY_WORLD_VIEW_CHANGE_CMD,recivePostMapData)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.remove, mapData.setSelfArmyRemove)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, mapData.setSelfArmyUpdate)
	refreshTimer = {}
	-- for i=1, 100 do
		-- refreshTimer[i] = {}
	-- end
end

--析构
function remove( )
	netObserver.removeObserver(NOTIFY_WORLD_VIEW_CMD)
	netObserver.removeObserver(NOTIFY_WORLD_VIEW_CHANGE_CMD)
	buildingData = {}
	cityComponentData = {}
	clippingResData = {}
	fieldArmyData = {}
	m_userInfoInMap = {}
	m_defendFireData = {}
	smokeData = {}
	valleyData = {}
	MapFarming.removeData()
	MapTraining.removeData()
	MapNodeData.remove()
	m_totalCount = 0
	-- m_oldArmydata = {}
	objectArray = nil
	m_touchLayer = nil
	m_rootLayer = nil
	mapController.remove()
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.remove, mapData.setSelfArmyRemove)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, mapData.setSelfArmyUpdate)
	if refreshTimer then
		for i=1,100 do
			if refreshTimer[i] then
				scheduler.remove(refreshTimer[i])
			end
		end
	end
	refreshTimer = nil
end
