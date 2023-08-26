local tCannotWar = {}
local tViewData = {}

local function setCannotWarMarkVisible( wid, flag)
	if tViewData[wid] then
		-- tolua.cast(tViewData[wid],"Widget")
		if flag then
			-- 如果上面有援军，那么不显示
			local yuanjunNode = MapNodeData.getYuanjunNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.YUANJUN)] --mapData.getObject().zhuzhaNode:getChildByTag(mapData.getTagFunction(math.floor(wid/10000), wid%10000))
			-- 如果上面有屯田，那么不显示
			local tuntianNode = MapNodeData.getFarmingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.FARMING)]

			local trainingNode = MapNodeData.getTrainingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.TRAINING)]
			if yuanjunNode or tuntianNode or trainingNode then
			else
				tolua.cast(tViewData[wid]:getChildByName("mianzhan"),"ImageView"):setVisible(flag)
			end
		else
			tolua.cast(tViewData[wid]:getChildByName("mianzhan"),"ImageView"):setVisible(flag)
		end
	end
end

local function removeCannotWarMark( coorX, coorY )
	-- local m_pRoot = map.getSightLand()
	-- local sightWidget = m_pRoot:getWidgetByTag(mapData.getTagFunction(coorX, coorY))
	if tViewData[coorX*10000+coorY] then
		-- tolua.cast(tViewData[coorX*10000+coorY],"Widget")
		tolua.cast(tViewData[coorX*10000+coorY]:getChildByName("mianzhan"),"ImageView"):setVisible(false)
	end
end

local function countCannotWarTime( coorX, coorY, leftTime)
	local function removeCannotWar( )
		removeCannotWarMark(coorX, coorY)
		if tCannotWar[coorX*10000+coorY] then
			scheduler.remove(tCannotWar[coorX*10000+coorY].funId)
			tCannotWar[coorX*10000+coorY] = nil
		end
	end
	tCannotWar[coorX*10000+coorY] = {leftTime = leftTime -userData.getServerTime(), funId = nil}
	tCannotWar[coorX*10000+coorY].funId = scheduler.create(removeCannotWar, tCannotWar[coorX*10000+coorY].leftTime)
end

local function getCannotWarTime( wid )
	if tCannotWar[wid] then
		return tCannotWar[wid].leftTime
	end
end

local function removeAllSchedulerWarTime( )
	for i,v in pairs(tCannotWar) do
		scheduler.remove(v.funId)
	end
	tCannotWar = {}
end

local function setViewPosWhenMove( )
	local sprite = nil
	for i, v in pairs(tViewData) do
		sprite = mapData.getLoadedMapLayer(math.floor(i/10000), i%10000)
		if sprite then
			ObjectManager.setObjectPos(v,sprite:getPositionX(), sprite:getPositionY() )
		end
	end
end

local function removeAll( )
	-- local m_pRoot = map.getSightLand()
	-- m_pRoot:clear()
	for i, v in pairs(tViewData) do
		-- v:removeFromParentAndCleanup(true)
		MapObjectPool.pushSprite("test/not_war_panel.json", v)
	end
	tViewData = {}
	removeAllSchedulerWarTime()
end

local function removeByWid( coorX, coorY )
	if tViewData[coorX*10000+coorY] then
		if tCannotWar[coorX*10000+coorY] then
			scheduler.remove(tCannotWar[coorX*10000+coorY].funId)
			tCannotWar[coorX*10000+coorY] = nil
		end
		MapObjectPool.pushSprite("test/not_war_panel.json", tViewData[coorX*10000+coorY])
		tViewData[coorX*10000+coorY] = nil
	end
end

local function create(coorX, coorY )
	local sprite = mapData.getLoadedMapLayer(coorX, coorY)
	if not sprite then return end
	removeByWid(coorX, coorY)
	if not mapData.isInArea(coorX,coorY) then return end

	local protect_end_time = mapData.getProtect_end_timeData(coorX,coorY)

	if not protect_end_time or protect_end_time == 0 then return end

	local widget = nil--GUIReader:shareReader():widgetFromJsonFile("test/sight_view_label.json")

	local isadd = false
	local city_type = nil
	local buildingData =mapData.getBuildingData()
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].cityType then
		city_type = buildingData[coorX][coorY].cityType
	end

	if protect_end_time and protect_end_time > userData.getServerTime() and city_type and city_type ~= cityTypeDefine.zhucheng
		and city_type ~= cityTypeDefine.player_chengqu and city_type ~= cityTypeDefine.fencheng 
		and city_type ~= cityTypeDefine.yaosai and city_type ~= cityTypeDefine.npc_yaosai then
		widget = MapObjectPool.popSprite("game/script_json/not_war_panel", "lua")--GUIReader:shareReader():widgetFromJsonFile("test/sight_view_label.json")
		isadd = true
		local area = {}
		for i = coorX-1, coorX+1 do
			for j=coorY-1, coorY+1 do
				area[i*10000+j] = 1
			end
		end 

		local data = armyData.getAllTeamMsg()
		local flag = true
		for i, v in pairs(data) do
			if v.state == armyState.decreed and area[v.target_wid] then
				tolua.cast(widget:getChildByName("mianzhan"),"ImageView"):setVisible(false)
				flag = false
			end
		end
		if flag then
			tolua.cast(widget:getChildByName("mianzhan"),"ImageView"):setVisible(true)
		end
		countCannotWarTime(coorX, coorY, protect_end_time)
	end

	if isadd then
		ObjectManager.addObject(VIEW_INFO,widget, true, sprite:getPositionX(), sprite:getPositionY(), false, true )
		tViewData[coorX*10000+ coorY] = widget
	end
	ObjectManager.addObjectCallBack(VIEW_INFO, setViewPosWhenMove, setViewPosWhenMove)
end

local function reloadAll( )
	removeAll()
	local buildingData =mapData.getBuildingData()
	local area = mapData.getArea()
	for i = area.row_up, area.row_down do
		for m = area.col_left, area.col_right do
			if buildingData[i] and buildingData[i][m] and buildingData[i][m].protect_end_time then
				create(i,m)
			end
		end
	end
end

local function getMapLandInfoArr( )
	return tViewData
end

MapLandInfo = {
				create = create,
				removeByWid = removeByWid,
				removeAll = removeAll,
				reloadAll = reloadAll,
				getCannotWarTime = getCannotWarTime,
				setCannotWarMarkVisible = setCannotWarMarkVisible,
				getMapLandInfoArr = getMapLandInfoArr
}