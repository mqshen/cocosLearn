--城市名字显示在地图上方
module("CityName", package.seeall)
local m_tName = {}
-- TODOTK 此效果要抽离出来
local isWidgetEffect = false
local widget_scale_diff = 0.15
local widget_handler = {}

local function removeHandler( coorX, coorY )
	if widget_handler[coorX*10000+coorY] then
		scheduler.remove(widget_handler[coorX*10000+coorY])
		widget_handler[coorX*10000+coorY] = nil
	end
end

function getCityNameArr( )
	return m_tName
end

function removeAll( )
	for i, v in pairs(m_tName) do
		-- v[1]:removeFromParentAndCleanup(true)
		MapObjectPool.pushSprite(v[3], v[1])
		removeHandler( math.floor(i/10000), i%10000 )
	end
	m_tName = {}
	isWidgetEffect =false
	widget_handler = {}
end

function removeByWid( coorX, coorY )
	if m_tName[coorX*10000+coorY] then
		-- m_tName[coorX*10000+coorY][1]:removeFromParentAndCleanup(true)
		MapObjectPool.pushSprite(m_tName[coorX*10000+coorY][3], m_tName[coorX*10000+coorY][1])
		m_tName[coorX*10000+coorY] = nil
		removeHandler( coorX, coorY )
	end
end

function showByWid(coorX,coorY,needEffect)
	if m_tName[coorX*10000+coorY] then
		m_tName[coorX*10000+coorY][1]:setVisible(true)
		if needEffect then 
			uiUtil.showScaleEffect(m_tName[coorX*10000+coorY][1],nil,0.2)	
		end
	end
end

function hideByWid(coorX,coorY,needEffect)
	if m_tName[coorX*10000+coorY] then
		if needEffect then 
			uiUtil.hideScaleEffect(m_tName[coorX*10000+coorY][1],function()
				m_tName[coorX*10000+coorY][1]:setVisible(false)
			end,0.2)
		else
			m_tName[coorX*10000+coorY][1]:setVisible(false)
		end
	end
end

function setPosWhenMove( )
	local sprite = nil
	for i, v in pairs(m_tName) do
		sprite = mapData.getLoadedMapLayer(math.floor(i/10000), i%10000)
		if sprite then
			ObjectManager.setObjectPos(v[1],sprite:getPositionX()+v[2], sprite:getPositionY()+80 )
			-- if mainBuildScene.getRootLayer() then
			-- 	v[1]:setVisible(false)
			-- end
		end
	end
end

function getPosInfoByWid(coor_wid)
	if m_tName[coor_wid] then
		local sprite = mapData.getLoadedMapLayer(math.floor(coor_wid/10000), coor_wid%10000)
		if sprite then
			local point = map.getInstance():convertToWorldSpace(cc.p(sprite:getPositionX()+100,sprite:getPositionY()+100))
			local px, py = config.countWorldSpace(point.x, point.y, map.getAngel())
			local scale_value = map.getInstance():getScale()*config.scaleIn3D(px, py, map.getAngel()) /config.getgScale()
			local area_size = m_tName[coor_wid][1]:getSize()
			area_size = CCSize(area_size.width * scale_value, area_size.height * scale_value)
			local area_pos = m_tName[coor_wid][1]:convertToWorldSpace(cc.p(area_size.width/2, area_size.height/2))

			-- 实际测试发现这个区域左下角会有些点击误差，所以把可点击区域放小一点，后续相关同学在查原因吧
			local hit_size = CCSize(area_size.width, area_size.height)
			return area_pos, area_size, hit_size
		end
	end

	return nil, nil
end

local function getColor( relation)
	if relation == mapAreaRelation.free_enemy or relation == mapAreaRelation.attach_enemy then
		return "red",1
	elseif relation == mapAreaRelation.own_self then
		return "green",3
	else
		return "blue",2
	end
end

local function getIfspecailCity( coorX, coorY)
	local buildingData =mapData.getBuildingData()
	if not buildingData[coorX] or not buildingData[coorX][coorY] or not buildingData[coorX][coorY].view_info then return false end
	local viewInfo = buildingData[coorX][coorY].view_info
	-- if not buildingData[coorX] or not buildingData[coorX][coorY] or not buildingData[coorX][coorY].userInfo then return false end
	-- local userInfo = buildingData[coorX][coorY].userInfo
	local count = 0
	local color = nil
	local flag = nil
	local tempName = nil
	local temp = nil
	if viewInfo then
		for i,n in pairs(viewInfo) do
			if n.state == armyState.zhuzhaed then
				flag = true
				count = count + 1
				color = getColor(n.relation)
				if color == "green" then
					for k,v in pairs(armyData.getAllTeamMsg()) do
						if v.state == armyState.zhuzhaed and v.reside_wid == coorX*10000+coorY then
							if not temp or v.reside_time < temp then
								temp = v.reside_time
								tempName = Tb_cfg_hero[allTableData[dbTableDesList.hero.name][v.base_heroid_u].heroid].name
							end
						end
					end
				end
			end
		end
		return flag, color, count, tempName
	end
	return false
end

local function regHandler( coorX, coorY, protect_end_time )
	removeHandler(coorX,coorY )
	widget_handler[coorX*10000+coorY]=scheduler.create(function ( )
		removeByWid(coorX,coorY)
		local temp_area = mapData.getArea()
		if coorX >= temp_area.row_up and coorX <= temp_area.row_down and coorY >=temp_area.col_left and coorY<= temp_area.col_right then
			create(coorX, coorY)
		end
	end, protect_end_time - userData.getServerTime())
end

function create(coorX, coorY )
	local sprite = mapData.getLoadedMapLayer(coorX, coorY)
	if not sprite then return end
	-- 清理重复的
	removeByWid(coorX, coorY)


	-- 非法检查
	local buildingData =mapData.getBuildingData()
	if not buildingData[coorX] then return end
	if not buildingData[coorX][coorY] then return end
	if not buildingData[coorX][coorY].cityType then return end
	if not buildingData[coorX][coorY].cityName then return end

	if string.len(buildingData[coorX][coorY].cityName) == 0  then return end

	-- 土地类型
	local buildingMessage = buildingData[coorX][coorY]
	local cityType = buildingData[coorX][coorY].cityType
	if cityType == cityTypeDefine.lingdi then return end
	if cityType == cityTypeDefine.own_free  then return end


	-- 名字
	local affilated_union_id =buildingData[coorX][coorY].affilated_union_id
	local cityName = landData.get_city_name_by_coordinate(coorX*10000+coorY)
	if cityType == cityTypeDefine.zhucheng then 
		cityName = cityName 
	end



	local layoutType = nil -- 1 NPC城 2玩家自己的 3其他玩家的
	local jsonName = nil
	local widget = nil 
	if cityType == cityTypeDefine.npc_cheng or cityType == cityTypeDefine.matou or cityType == cityTypeDefine.npc_yaosai then
		-- widget = MapObjectPool.popSprite("test/City_NPC_name.json")--GUIReader:shareReader():widgetFromJsonFile("test/City_NPC_name.json")
		widget = MapObjectPool.popSprite("game/script_json/City_NPC_name","lua")
		jsonName = "game/script_json/City_NPC_name"
		layoutType = 1
		widget:setAnchorPoint(cc.p(0,0))
		widget:setSize(CCSize(320,48))
		local label_name = uiUtil.getConvertChildByName(widget,"label_name")
		label_name:setPosition(cc.p(50,28))
	else
		if mapData.isSelfLand(coorX,coorY) then
			-- widget = MapObjectPool.popSprite("test/City_player_name.json")--GUIReader:shareReader():widgetFromJsonFile("test/City_player_name.json")
			widget = MapObjectPool.popSprite("game/script_json/City_player_name","lua")
			jsonName = "game/script_json/City_player_name"
			layoutType = 2
			widget:setAnchorPoint(cc.p(0,0))
			widget:setSize(CCSize(132,41))
			local label_name = uiUtil.getConvertChildByName(widget,"label_name")
			label_name:setPosition(cc.p(64,20))
		else
			-- widget = MapObjectPool.popSprite("test/City_player_name_other.json")--GUIReader:shareReader():widgetFromJsonFile("test/City_player_name_other.json")
			widget = MapObjectPool.popSprite("game/script_json/City_player_name_other","lua")
			jsonName = "game/script_json/City_player_name_other"
			layoutType = 3
			widget:setAnchorPoint(cc.p(0,0))
			widget:setSize(CCSize(250,36))
			local label_name = uiUtil.getConvertChildByName(widget,"label_name")
			label_name:setPosition(cc.p(40,16))
		end
	end

	-- local mount = cc.Sprite:createWithSpriteFrameName("hill2.png")
	-- widget:addChild(mount)
	
	if layoutType == 2 or layoutType == 3 then
		if layoutType == 2 then
			local btn_enterCity = uiUtil.getConvertChildByName(widget,"btn_enterCity")
			local city = landData.get_world_city_info(coorX*10000+coorY)
			if city then 
				if btn_enterCity then 
					if buildingMessage.relation == mapAreaRelation.own_self and city
						and (city.state == cityState.normal or city.state == cityState.removing)
			    	    and (buildingMessage.cityType == cityTypeDefine.zhucheng 
			    	    	or buildingMessage.cityType == cityTypeDefine.fencheng 
			    	    	or buildingMessage.cityType == cityTypeDefine.yaosai ) then 
						btn_enterCity:setVisible(true)
					else
						btn_enterCity:setVisible(false)
					end

					if city.state == cityState.building then 
						btn_enterCity:setVisible(true)
					end
				end
			end
		end

		local img_army_num = uiUtil.getConvertChildByName(widget,"img_army_num")
		local armyCount = 0

		if layoutType == 2 then		
			local label_num = uiUtil.getConvertChildByName(img_army_num,"label_num")
			armyCount = #armyData.getStayFortArmyList(coorX*10000+coorY)
			label_num:setText(armyCount)
		else
			for i, v in pairs(mapData.getFieldArmyMsg()) do
				if v.wid_to == coorX*10000+coorY and v.wid_from == v.wid_to and v.state == armyState.zhuzhaed then
					armyCount = 1
					break
				end
			end
		end

		if cityType == cityTypeDefine.yaosai and armyCount > 0 then 
			img_army_num:setVisible(true)
		else
			img_army_num:setVisible(false)
		end
	end

	local img_name_bg = uiUtil.getConvertChildByName(widget,"img_bg")
	local label_name = uiUtil.getConvertChildByName(widget,"label_name")
	label_name:setPositionX(label_name:getPositionX() + 10)
	cityName = cityName 
	label_name:setText(cityName)


	

	if layoutType == 1 then 
		-- NPC城的
		-- pass
	else
		-- 是否沦陷
		local img_lunxian = uiUtil.getConvertChildByName(widget,"img_lunxian")
		if affilated_union_id and affilated_union_id ~= 0 then 
			img_lunxian:setVisible(true)
		else
			img_lunxian:setVisible(false)
		end

		if layoutType == 2 then 
			-- 自己的
			local btn_enterCity = uiUtil.getConvertChildByName(widget,"btn_enterCity")
			if cityType == cityTypeDefine.zhucheng then 
				btn_enterCity:loadTextureNormal(ResDefineUtil.cityNameImgFlag["self_zhucheng_1"],UI_TEX_TYPE_PLIST)
				btn_enterCity:loadTexturePressed(ResDefineUtil.cityNameImgFlag["self_zhucheng_2"],UI_TEX_TYPE_PLIST)
			elseif cityType == cityTypeDefine.fencheng then
				btn_enterCity:loadTextureNormal(ResDefineUtil.cityNameImgFlag["self_fencheng_1"],UI_TEX_TYPE_PLIST)
				btn_enterCity:loadTexturePressed(ResDefineUtil.cityNameImgFlag["self_fencheng_2"],UI_TEX_TYPE_PLIST)
			elseif cityType == cityTypeDefine.yaosai then
				btn_enterCity:loadTextureNormal(ResDefineUtil.cityNameImgFlag["self_yaosai_1"],UI_TEX_TYPE_PLIST)
				btn_enterCity:loadTexturePressed(ResDefineUtil.cityNameImgFlag["self_yaosai_2"],UI_TEX_TYPE_PLIST)
			else
				-- error
			end
			label_name:setColor(ccc3(254,244,206))
		else
			-- 别人的
			local img_flag = uiUtil.getConvertChildByName(widget,"img_flag")
			if cityType == cityTypeDefine.zhucheng then 
				img_flag:loadTexture(ResDefineUtil.cityNameImgFlag["other_zhucheng"],UI_TEX_TYPE_PLIST)
			elseif cityType == cityTypeDefine.fencheng then 
				img_flag:loadTexture(ResDefineUtil.cityNameImgFlag["other_fencheng"],UI_TEX_TYPE_PLIST)
			elseif cityType == cityTypeDefine.yaosai then 
				img_flag:loadTexture(ResDefineUtil.cityNameImgFlag["other_yaosai"],UI_TEX_TYPE_PLIST)
			else
				-- error
			end

			if buildingMessage.relation then 
				if buildingMessage.relation == mapAreaRelation.free_enemy 
					or buildingMessage.relation == mapAreaRelation.attach_enemy then
					-- 敌对
					label_name:setColor(ccc3(255,96,75))
				elseif buildingMessage.relation == mapAreaRelation.free_ally then 
					-- 盟友
					label_name:setColor(ccc3(144,193,204))
				elseif buildingMessage.relation == mapAreaRelation.free_underling then 
					-- 下属
					label_name:setColor(ccc3(255,241,143))
				elseif buildingMessage.relation == mapAreaRelation.attach_higher_up 
					or  buildingMessage.relation == mapAreaRelation.attach_same_higher  then 
					-- 上级
					label_name:setColor(ccc3(206,143,190))
				end
			end
		end
	end


	local width = label_name:getPositionX()+label_name:getContentSize().width+30
	if cityType == cityTypeDefine.npc_cheng or cityType == cityTypeDefine.matou or cityType == cityTypeDefine.npc_yaosai then
		width = width + 30
	end
	if width < 100 then width = 100 end

	--免战
	local img_mianzhan = uiUtil.getConvertChildByName(widget,"ImageView_mianzhan")
	if img_mianzhan then
		local protect_end_time = mapData.getProtect_end_timeData(coorX,coorY)
		if not protect_end_time or protect_end_time == 0 or protect_end_time < userData.getServerTime() then
			img_mianzhan:setVisible(false)
		else
			
			regHandler( coorX, coorY, protect_end_time )
			img_mianzhan:setVisible(true)
			img_mianzhan:setPositionX(label_name:getPositionX()+label_name:getContentSize().width)
			width = img_mianzhan:getPositionX() + img_mianzhan:getSize().width+10
		end
	end

	img_name_bg:setSize(CCSizeMake(width, img_name_bg:getSize().height))
	widget:setSize(CCSizeMake(width, widget:getSize().height))
	widget:setAnchorPoint(cc.p(0.5,0))


	

	m_tName[coorX*10000+ coorY] = {widget, 100, jsonName}
	
	ObjectManager.addObject(CITY_NAME,widget, true, sprite:getPositionX()+100, sprite:getPositionY()+80, false, true )
	ObjectManager.addObjectCallBack(CITY_NAME, setPosWhenMove, setPosWhenMove)
	
	if mapMessageUI.getCurLandId() == (coorX*10000+ coorY) then 
		widget:setVisible(false)
	end
end

local function effectWidget(widget) -- 按下的效果
    if isWidgetEffect then return end
    for i=0, widget:getChildren():count()-1 do
		local tempLayout = tolua.cast(widget:getChildren():objectAtIndex(i),"Widget")
		tempLayout:setScaleX(tempLayout:getScaleX() - widget_scale_diff) -- 缩小
        tempLayout:setScaleY(tempLayout:getScaleY() - widget_scale_diff) -- 缩小
	end
        -- widget:setScaleX(widget:getScaleX() - widget_scale_diff) -- 缩小
        -- widget:setScaleY(widget:getScaleY() - widget_scale_diff) -- 缩小
   	isWidgetEffect = true
end

local function closeEffectWidget(widget) -- 取消的效果
    if not isWidgetEffect then return end
    for i=0, widget:getChildren():count()-1 do
	    local tempLayout = tolua.cast(widget:getChildren():objectAtIndex(i),"Widget")
	    tempLayout:setScaleX(tempLayout:getScaleX() + widget_scale_diff) -- 缩小
    	tempLayout:setScaleY(tempLayout:getScaleY() + widget_scale_diff) -- 缩小
	end
        -- widget:setScaleX(widget:getScaleX() + widget_scale_diff) -- 还原
        -- widget:setScaleY(widget:getScaleY() + widget_scale_diff) -- 还原
    isWidgetEffect = false
end 

local function ptinwidget(widget)
    local pt = widget:getTouchMovePos()
    tolua.cast(pt, "CCPoint") 
    return widget:hitTest(pt)
end

local function touchBegan(widget )
	if mainBuildScene.getThisCityid() then 
		return 
	end
	effectWidget(widget)
end

local function touchMoved(widget  )
	if mainBuildScene.getThisCityid() then 
		return 
	end
	if not ptinwidget(widget) then 
		closeEffectWidget(widget)
	else
		effectWidget(widget)
	end
end

local function touchCancel( widget )
	closeEffectWidget(widget)
end

local lastState = false
local function touchEnded( widget,wid )
	lastState = not lastState
	-- mainOption.switchCityEffect(lastState,wid)
 --    if true then return end

	if mainBuildScene.getThisCityid() then 
		return 
	end
	closeEffectWidget(widget)
	armyListManager.change_show_state(false)
	mapMessageUI.moveAndEnter(math.floor(wid/10000), wid%10000)
end

function touchEvent( eventType, wid )
	local widget = m_tName[wid][1]
	if widget and (not widget:isVisible()) then 
		return 
	end
	if eventType == "began" then
		touchBegan(widget )
	elseif eventType == "cancelled" then
		touchCancel( widget )
	elseif eventType == "moved" then
		touchMoved(widget  )
	elseif eventType == "ended" then
		touchEnded( widget, wid )
	end
end

function reloadAll( )
	removeAll()
	local buildingData =mapData.getBuildingData()
	local area = mapData.getArea()
	for i = area.row_up, area.row_down do
		for m = area.col_left, area.col_right do
			if buildingData[i] and buildingData[i][m] and buildingData[i][m].cityType and buildingData[i][m].cityName
			and string.len(buildingData[i][m].cityName)>0 then
				create(i,m)
			end
		end
	end

	-- for i, v in pairs(buildingData) do
	-- 	for m,n in pairs(v) do
	-- 		if buildingData[i][m].cityType and buildingData[i][m].cityName then
	-- 			create(i,m)
	-- 		end
	-- 	end
	-- end
end