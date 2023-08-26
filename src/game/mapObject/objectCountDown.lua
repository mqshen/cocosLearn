--地图上面的倒计时
-- objectCountDown.lua
module("ObjectCountDown", package.seeall)
local m_tCountDownData = nil
local m_schCity = nil --建城拆除，放弃领地的计时器
local m_timeLabel = nil
local select_army = nil

function init( )
	UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.add, ObjectCountDown.create)
	UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.remove, ObjectCountDown.create)
	UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.update, ObjectCountDown.create)

	UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.add, ObjectCountDown.create)
	UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.remove, ObjectCountDown.create)
	UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.update, ObjectCountDown.create)
	
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.add, ObjectCountDown.create)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.remove, ObjectCountDown.create)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, ObjectCountDown.create)


	m_tCountDownData = {}
	m_schCity = nil
	select_army = nil
	create()
	ObjectManager.addObjectCallBack(COUNTDOWN_OBJECT, resetPosWhenMove, resetPosWhenJump)
end


--  visible 优先级
--  优先级 A： 战间休息 》 其他类型 
--  优先级 B： CD时间倒序 
--  优先级A 》 优先级B
local function doSetime(widTable)
	local city = nil
	local war = nil
	local flagWar = nil
	local flagCity = nil
	local lastCityCD = nil -- 上一个CD时间
	local lastCityObj = nil
	for i ,v in pairs(widTable) do
		flagWar = false
		flagCity = false
		if v.warLeftTime then
			local warLeftTime = v.warLeftTime
			if select_army then
				for i, v in pairs(v.arr_war_leftTime) do
					if v[2] == select_army then
						warLeftTime = v[1]
					end
				end
				
			end

			local loadbar = nil
			war = v.object:getChildByName("loading_bg_0_0_0")
			loadbar = tolua.cast(war:getChildByName("loading_bar_0_0_0"),"LoadingBar")
			if warLeftTime - userData.getServerTime() > 0 then
				loadbar:setPercent(100*(1-(warLeftTime - userData.getServerTime())/v.warAllTime))
				tolua.cast(war:getChildByName("LabelAtlas_393924"),"LabelAtlas"):setStringValue(commonFunc.format_time(warLeftTime - userData.getServerTime(),true))
				flagWar = true
			else
				flagWar = false
				war:setVisible(false)
			end
		end

		if v.cityLeftTime then
			city = v.object:getChildByName("loading_bg_0")
			local cityLeftTime = v.cityLeftTime

			local function setCityTime()
				if cityLeftTime - userData.getServerTime() > 0 then
					city:setVisible(true)
					tolua.cast(city:getChildByName("Label_78708"),"LabelAtlas"):setStringValue(commonFunc.format_time(cityLeftTime - userData.getServerTime(),true))
					tolua.cast(city:getChildByName("loading_bar_0"),"LoadingBar"):setPercent(100*(1-(cityLeftTime - userData.getServerTime())/v.cityAlltime))
					flagCity = true
				else
					city:setVisible(false)
				end

				if cityLeftTime - userData.getServerTime() > 0 then
					lastCityCD = cityLeftTime - userData.getServerTime()
					lastCityObj = city
				end
			end
			
			if flagWar then 
				city:setVisible(false)
			else
				-- 只显示CD时间最短的
				if lastCityCD then 
					if (cityLeftTime - userData.getServerTime()) < lastCityCD then 
						city:setVisible(true)
						lastCityObj:setVisible(false)
						setCityTime()
					else
						city:setVisible(false)
					end
				else
					setCityTime()
				end

				if v.state == 1 then
					tolua.cast(city:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.button_icon_Cancel, UI_TEX_TYPE_PLIST)
				elseif v.state == 3 then
					tolua.cast(city:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.tudijianzhaotubiao_01, UI_TEX_TYPE_PLIST)
				elseif v.state == 4 then
					tolua.cast(city:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.button_icon_remove, UI_TEX_TYPE_PLIST)
				elseif v.state == 5 or v.state == 6 then
					tolua.cast(city:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.land_flag_decree, UI_TEX_TYPE_PLIST)
				end
				
				if select_army then
					for m, n in pairs(armyData.getAllTeamMsg() or {}) do
						if select_army == n.armyid and (n.state == armyState.decreed or n.state == armyState.training) then
							tolua.cast(city:getChildByName("Label_78708"),"LabelAtlas"):setStringValue(commonFunc.format_time(n.end_time - userData.getServerTime(),true))
							tolua.cast(city:getChildByName("loading_bar_0"),"LoadingBar"):setPercent(100*(1-(n.end_time - userData.getServerTime())/(n.end_time - n.begin_time)))
							
							tolua.cast(city:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.land_flag_decree, UI_TEX_TYPE_PLIST)
							return
						end
					end
				end
			end
		end
	end
end

local function setTime( )
	for i ,v in pairs(m_tCountDownData) do
		doSetime(v)
	end
end

function resetPosWhenMove( )
	local coorX, coorY = userData.getLocation()
	local posx,posy = userData.getLocationPos()
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	for i,vv in pairs(m_tCountDownData) do
		for k,v in pairs(vv) do 
			label_start_x = math.floor(i/10000)
			label_start_y = i%10000
			label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
			ObjectManager.setObjectPos(v.object, label_pos_x + 100, label_pos_y + 50)
		end
	end
end

function resetPosWhenJump(coorX, coorY )
	local label_pos_x, label_pos_y = nil, nil
	local label_start_x, label_start_y = nil, nil
	local posx,posy = userData.getLocationPos()
	for i,vv in pairs(m_tCountDownData) do
		for k,v in pairs(vv) do 
			label_start_x = math.floor(i/10000)
			label_start_y = i%10000
			label_pos_x, label_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, label_start_x,label_start_y  )
			ObjectManager.setObjectPos(v.object, label_pos_x + 100, label_pos_y + 50)
		end
	end
end



--index 1领地放弃 2 战间休息 3 建城  4 拆城  5屯田 6 练兵
local function addCountDownObejct(lefttime, alltime, wid, index, count, arr_war_leftTime)
	local flag = false
	local tempWidget = nil
	
	if not m_tCountDownData[wid] then 
		m_tCountDownData[wid] = {}
	end

	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local end_x = math.floor(wid/10000)
	local end_y = wid%10000
	local x, y = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, end_x,end_y  )



	if index == 1  or index ==3 or index == 4 then
		if not m_tCountDownData[wid][1] then
			m_tCountDownData[wid][1] = {}
		end
		flag = true
		m_tCountDownData[wid][1] = {cityLeftTime = lefttime, cityAlltime = alltime , object = nil, state = index}
		m_tCountDownData[wid][1].object = GUIReader:shareReader():widgetFromJsonFile("test/City_time_label.json")
		tempWidget = tolua.cast(m_tCountDownData[wid][1].object:getChildByName("loading_bg_0"),"ImageView")
		tempWidget:setVisible(true)
		tempWidget:setPositionY(40)
		if index == 1 then
			tolua.cast(tempWidget:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.button_icon_Cancel, UI_TEX_TYPE_PLIST)
		elseif index == 3 then
			tolua.cast(tempWidget:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.tudijianzhaotubiao_01, UI_TEX_TYPE_PLIST)
		elseif index == 4 then
			tolua.cast(tempWidget:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.button_icon_remove, UI_TEX_TYPE_PLIST)
		end

		tolua.cast(tempWidget:getChildByName("Label_78708"),"LabelAtlas"):setStringValue(commonFunc.format_time(lefttime - userData.getServerTime(),true))
		tolua.cast(tempWidget:getChildByName("loading_bar_0"),"LoadingBar"):setPercent(100*(1-(lefttime - userData.getServerTime())/alltime))

		if flag then
			m_tCountDownData[wid][1].object:setAnchorPoint(cc.p(0.5,0.5))
			ObjectManager.addObject(COUNTDOWN_OBJECT,m_tCountDownData[wid][1].object, true, x+100, y+50 )
		end
	elseif index == 5 or index == 6 then 
		local sub_indx = 0
		if index == 5 then 
			sub_indx = 3
		else
			sub_indx = 4
		end
		-- 只刷新CD 更短的
		if m_tCountDownData[wid][sub_indx] then
			if  m_tCountDownData[wid][sub_indx].cityLeftTime  > lefttime then
				m_tCountDownData[wid][sub_indx].cityLeftTime = lefttime
				m_tCountDownData[wid][sub_indx].cityAlltime = alltime
				m_tCountDownData[wid][sub_indx].state = index
			end
		end
		if not m_tCountDownData[wid][sub_indx] then
			flag = true
			m_tCountDownData[wid][sub_indx] = {}
			m_tCountDownData[wid][sub_indx] = {cityLeftTime = lefttime, cityAlltime = alltime , object = nil, state = index}
			m_tCountDownData[wid][sub_indx].object = GUIReader:shareReader():widgetFromJsonFile("test/City_time_label.json")
		end
		
		
		tempWidget = tolua.cast(m_tCountDownData[wid][sub_indx].object:getChildByName("loading_bg_0"),"ImageView")
		tempWidget:setVisible(true)
		tolua.cast(tempWidget:getChildByName("ImageView_78715"),"ImageView"):loadTexture(ResDefineUtil.land_flag_decree, UI_TEX_TYPE_PLIST)
		tempWidget:setPositionY(40)

		tolua.cast(tempWidget:getChildByName("Label_78708"),"LabelAtlas"):setStringValue(commonFunc.format_time(lefttime - userData.getServerTime(),true))
		tolua.cast(tempWidget:getChildByName("loading_bar_0"),"LoadingBar"):setPercent(100*(1-(lefttime - userData.getServerTime())/alltime))

		if flag then
			m_tCountDownData[wid][sub_indx].object:setAnchorPoint(cc.p(0.5,0.5))
			ObjectManager.addObject(COUNTDOWN_OBJECT,m_tCountDownData[wid][sub_indx].object, true, x+100, y+50 )
		end
	elseif index == 2 then
		if not m_tCountDownData[wid][2] then
			flag = true
			m_tCountDownData[wid][2] = {}
			m_tCountDownData[wid][2].object = GUIReader:shareReader():widgetFromJsonFile("test/City_time_label.json")
		end
		m_tCountDownData[wid][2].warLeftTime = lefttime
		m_tCountDownData[wid][2].warAllTime = alltime
		m_tCountDownData[wid][2].state = index
		m_tCountDownData[wid][2].count = count
		m_tCountDownData[wid][2].arr_war_leftTime = arr_war_leftTime
		
		tempWidget = tolua.cast(m_tCountDownData[wid][2].object:getChildByName("loading_bg_0_0_0"),"ImageView")
		tolua.cast(tempWidget:getChildByName("loading_bar_0_0_0"),"LoadingBar"):setPercent(100*(1-(lefttime - userData.getServerTime())/alltime))
		tolua.cast(tempWidget:getChildByName("LabelAtlas_393924"),"LabelAtlas"):setStringValue(commonFunc.format_time(lefttime - userData.getServerTime(),true))
		tempWidget:setVisible(true)

		local tempwidget = tolua.cast(m_tCountDownData[wid][2].object:getChildByName("Panel_386060"),"Layout")
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jiaozhan.ExportJson")
		local armature = CCArmature:create("jiaozhan")
		armature:getAnimation():playWithIndex(0)
		tempwidget:addChild(armature)
		armature:setPosition(cc.p(tempwidget:getContentSize().width/2+10,tempwidget:getContentSize().height/2+10))

		if flag then
			m_tCountDownData[wid][2].object:setAnchorPoint(cc.p(0.5,0.5))
			ObjectManager.addObject(COUNTDOWN_OBJECT,m_tCountDownData[wid][2].object, true, x+100, y+50 )
		end
	end
end

function removeObject( )
	if m_tCountDownData then
		for i ,vv in pairs(m_tCountDownData) do
			for k,v in pairs(vv) do 
				if v.object then
					v.object:removeFromParentAndCleanup(true)
				end
			end
		end
	end

	if m_schCity then
		scheduler.remove(m_schCity)
	end
	m_schCity = nil
	m_timeLabel = nil
	m_tCountDownData = {}
end

function create( )
	if m_tCountDownData then
		for i ,vv in pairs(m_tCountDownData) do
			for k,v in pairs(vv) do 
				if v.object then
					v.object:removeFromParentAndCleanup(true)
				end
			end
		end
	end

	if m_schCity then
		scheduler.remove(m_schCity)
	end
	m_schCity = nil
	m_timeLabel = nil
	m_tCountDownData = {}
	local flag = false
	--放弃领地
	for i ,v in pairs(allTableData[dbTableDesList.world_city.name]) do
		if v.end_time ~= 0 and v.userid == userData.getUserId() and 
		(v.city_type == cityTypeDefine.lingdi or v.city_type == cityTypeDefine.player_chengqu or v.city_type == cityTypeDefine.npc_chengqu or v.city_type == cityTypeDefine.npc_yaosai) and v.state == cityState.removing then
			flag = true
			addCountDownObejct(v.end_time, FIELD_DEL_TIME, v.wid, 1)
		end
	end

	--要塞或者分城
	for i ,v in pairs(allTableData[dbTableDesList.world_city.name]) do
		if (v.state == cityState.building or v.state == cityState.removing ) and v.userid == userData.getUserId() and (v.city_type == cityTypeDefine.fencheng or v.city_type == cityTypeDefine.yaosai) then
			if v.state == cityState.building then
				addCountDownObejct(v.end_time, BRANCH_CITY_BUILD_TIME, v.wid, 3)
			elseif v.state == cityState.removing then
				addCountDownObejct(v.end_time, BRANCH_CITY_DEL_TIME, v.wid, 4)
			end
			flag = true
		end
	end

	-- 屯田
	for i,v in pairs(allTableData[dbTableDesList.army.name]) do 
		if v.state == armyState.decreed and v.userid == userData.getUserId() then 
			addCountDownObejct(v.end_time,v.end_time - v.begin_time,v.target_wid,5)
		end
		flag = true
	end

	-- 练兵
	for i,v in pairs(allTableData[dbTableDesList.army.name]) do 
		if v.state == armyState.training and v.userid == userData.getUserId() then 
			addCountDownObejct(v.end_time,v.end_time - v.begin_time,v.target_wid,6)
		end
		flag = true
	end

	local warData = {}
	--战间休息
	for i ,v in pairs(allTableData[dbTableDesList.army.name]) do
		if v.state == armyState.sleeped and v.userid == userData.getUserId() then
			flag = true
			if not warData[v.target_wid] then
				warData[v.target_wid] = {}
			end
			table.insert(warData[v.target_wid], {v.end_time, v.armyid})
		end
	end

	for i, v in pairs(warData) do
		if #v > 1 then
			table.sort( v, function (a, b )
				return a[1] < b[1]
			end )
		end
		addCountDownObejct(v[1][1], WAIT_NEXT_FIGHT_INTERVAL, i, 2, #v, v)
	end

	setTime()
	if not m_schCity and flag then
		m_schCity = scheduler.create(setTime,1)
	end
end

function remove( )
	UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.add, ObjectCountDown.create)
	UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.remove, ObjectCountDown.create)
	UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.update, ObjectCountDown.create)

	UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.add, ObjectCountDown.create)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.remove, ObjectCountDown.create)
	UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.update, ObjectCountDown.create)

	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.add, ObjectCountDown.create)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.remove, ObjectCountDown.create)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, ObjectCountDown.create)

	for i ,vv in pairs(m_tCountDownData) do
		for k,v in pairs(vv) do 
			if v.object then
				v.object:removeFromParentAndCleanup(true)
			end
		end
	end

	if m_schCity then
		scheduler.remove(m_schCity)
	end
	select_army = nil
	m_tCountDownData = nil
	m_schCity = nil
	m_timeLabel = nil
end

function setSelectArmyId( armyid )
	select_army = armyid
end

function setReleaseLockArmy( )
	select_army = nil
end