local mini_map_layer = nil
local inputBoxX = nil
local inputBoxY = nil
local is_open_state = nil

local pos_open = nil
local isClick = nil
local isClickEnd = nil
local isClickBegin = nil

local touch_mapPos = {x=nil,y=nil}
local m_tableView = nil
local m_idx = nil
local m_arrOwnCityData = nil
local m_arrOwnLingdiData = nil
local m_arrNpcCityData = nil
local cityPanelTouch = nil
local layer_touch_ = nil
-- local back_image = nil
local m_layer_pos = nil

local m_iLastEditCoorX = nil
local m_iLastEditCoorY = nil
local scaleTime = 0.2
local image_table_ = nil
local isMove = nil

local StringUtil = require("game/utils/string_util")
local function do_remove_self()
	if mini_map_layer then
		MiniMapState.remove()
		if image_table_ then
			for i, v in pairs(image_table_) do
				v[1]:release()
			end
		end
		mini_map_layer:removeFromParentAndCleanup(true)
		mini_map_layer = nil
		is_open_state = nil
		m_layer_pos = nil
		MiniMapData.remove()
		isMove = nil
		last_x, last_y = nil, nil
		-- back_image = nil
		isClickEnd = nil
		image_table_ = nil
		isClickBegin = nil
		isClick = nil
		layer_touch_ = nil
		inputBoxX = nil
		inputBoxY = nil
		m_iLastEditCoorX = nil
		m_iLastEditCoorY = nil
		m_idx = nil
		map_width, map_height = nil, nil
		temp_sin_value, temp_cos_value = nil, nil
		positive_sin, positive_cos = nil, nil
		m_tableView = nil
		m_arrOwnCityData =nil
		m_arrNpcCityData = nil
		m_arrOwnLingdiData =nil
		cityPanelTouch = nil
		UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.remove, miniMapManager.reloadData)
    	UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.update, miniMapManager.reloadData)

    	-- UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.update, miniMapManager.set_map_player_related_color_ownCity)
    	-- UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.remove, miniMapManager.set_map_player_related_color_ownCity)
    	-- UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.add, miniMapManager.set_map_player_related_color_ownCity)

		uiManager.remove_self_panel(uiIndexDefine.UI_CITYLISTANDMAP)
		SmallMiniMap.miniMapButtonVisible(true )
		optionController.resetOptions()
	end
end

local function remove_self()
    if not mini_map_layer then return end
    uiManager.hideConfigEffect(uiIndexDefine.UI_CITYLISTANDMAP,mini_map_layer,do_remove_self)
    -- uiManager.hideScaleEffect(mini_map_layer,999,do_remove_self)
end
local function dealwithTouchEvent(x,y)	
    if not mini_map_layer then
		return false
    end

    local temp_widget = mini_map_layer:getWidgetByTag(999)
    if temp_widget:hitTest(cc.p(x,y)) then
		return false
    else
		remove_self()
		return true
    end
end

local function set_pos_txt(coor_x, coor_y)

	m_iLastEditCoorX = math.abs(tonumber(coor_x))
 	if inputBoxX then
 		inputBoxX:setText(m_iLastEditCoorX)
 	end
 	m_iLastEditCoorY = math.abs(tonumber(coor_y))
 	if inputBoxY then
 		inputBoxY:setText(m_iLastEditCoorY)
 	end
end

local function isTouchState(x,y  )
	local alpha = nil
	local point, posy = nil, nil
	for i, v in pairs(image_table_) do
		point = v[2]:convertToNodeSpace(cc.p(x,y))
		alpha = CCTextureDetect:sharedDetect():getAlpha(v[1], point.x+v[2]:getSize().width/2, v[2]:getContentSize().height - point.y-v[2]:getSize().height/2)
		if alpha.a ~= 0 then
			v[2]:setVisible(false)
			return i
		end
	end
	return false
end

--点击坐标转换成位置坐标
local function clickConvertToLocation( x,y )
	--1501*(x/w - y/h +0.5)
	--1501*(x/w + y/h -0.5)
	local temp_widget = mini_map_layer:getWidgetByTag(999)
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")
	local width,height = map_content_panel:getSize().width, map_content_panel:getSize().height
	local posX = 1501*(x/width-y/height + 0.5)
	local posY = 1501*(x/width+y/height - 0.5)
	return math.ceil(posX), math.ceil(posY)
end

--位置坐标转换成点击坐标
local function locationConvertToClick(coorX, coorY )
	local temp_widget = mini_map_layer:getWidgetByTag(999)
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")
	local width,height = map_content_panel:getSize().width, map_content_panel:getSize().height
	return height*(coorX+coorY)/1501, height/2*((coorY-coorX)/1501+1)
end

--地标应该跳的高度
local function getHeightPos(x,y )
	local temp_widget = mini_map_layer:getWidgetByTag(999)
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	local mark = tolua.cast(map_panel:getChildByName("ImageView_74821"), "ImageView")
	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")
	local touchPoint = map_content_panel:convertToNodeSpace(cc.p(x,y))

	local jumpHeight = 2*mark:getContentSize().height
	local _x, _y = clickConvertToLocation( touchPoint.x, touchPoint.y )
	if _x > 1501 or _x < 1 or _y > 1501 or _y < 1 then
		return false
	end
	local node = mark:getParent():convertToNodeSpace(cc.p(x,y))
	mark:setPosition(node)
	local worldPoint = mark:getParent():convertToWorldSpace(cc.p(mark:getPositionX(),mark:getPositionY()+jumpHeight))
	local nodePoint = map_content_panel:convertToNodeSpace(worldPoint)
	local new_coor_x,new_coor_y = clickConvertToLocation( nodePoint.x, nodePoint.y )
	-- local temp_world_point = nil
	if new_coor_x <= 1501 and new_coor_x >= 1 and new_coor_y <= 1501 and new_coor_y >= 1 then
		mark:setPosition(cc.p(mark:getPositionX(),mark:getPositionY()+jumpHeight))
		-- temp_world_point = mark:getParent():convertToWorldSpace(cc.p(mark:getPositionX(),mark:getPositionY()+jumpHeight))
		set_pos_txt(new_coor_x, new_coor_y)
	else
		local tempY
		if nodePoint.x < map_content_panel:getSize().width/2 then
			tempY = 0.5*nodePoint.x+map_content_panel:getSize().height/2 --75.5
		else
			tempY = -0.5*nodePoint.x+map_content_panel:getSize().height*3/2--226.5
		end
		worldPoint = map_content_panel:convertToWorldSpace(cc.p(0,tempY))
		local tempPoint = mark:getParent():convertToNodeSpace(worldPoint)
		mark:setPosition(cc.p(mark:getPositionX(), tempPoint.y))
		worldPoint = mark:getParent():convertToWorldSpace(cc.p(mark:getPositionX(),mark:getPositionY()))
		nodePoint = map_content_panel:convertToNodeSpace(worldPoint)
		new_coor_x,new_coor_y = clickConvertToLocation( nodePoint.x, nodePoint.y )
		set_pos_txt(new_coor_x, new_coor_y)
	end

	-- local stateid = isTouchState(worldPoint.x,worldPoint.y)
	-- if stateid then
	-- 	if image_table_[stateid] then
	-- 		image_table_[stateid][2]:setVisible(true)
	-- 	end
	-- end
	return true	
end

local function setMarkPos(coorX, coorY, iscity )
	if not mini_map_layer then return end
	if not coorX or not coorY then return end
	local temp_widget = mini_map_layer:getWidgetByTag(999)
	if not temp_widget then return end
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	local mark = tolua.cast(map_panel:getChildByName("ImageView_74821"), "ImageView")
	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")
	local convertPointX, convertPointY =locationConvertToClick(coorX, coorY )
	local worldPoint = map_content_panel:convertToWorldSpace(cc.p(convertPointX, convertPointY))
	local nodePoint = mark:getParent():convertToNodeSpace(worldPoint)
	mark:setPosition(nodePoint)

	if iscity then
		local cir = tolua.cast(map_panel:getChildByName("ImageView_548895"),"ImageView")
		cir:setPosition(nodePoint)
		cir:setVisible(true)
		cir:setScale(2)
		cityPanelTouch = false
		local action = animation.sequence({CCScaleTo:create(0.3,0.1), cc.CallFunc:create(function ( )
			cir:setVisible(false)
			cityPanelTouch = true
		end)})

		cir:runAction(action)
	end

	set_pos_txt(coorX, coorY)
end

local function touchCancel( x,y)
	if isClickBegin then
		isClickEnd = true
	end
	if isClickBegin then
		-- local temp_widget = mini_map_layer:getWidgetByTag(999)
		-- local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
		-- local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")
		-- local nodePoint = map_content_panel:convertToNodeSpace(cc.p(x,y))
		-- local new_coor_x,new_coor_y = clickConvertToLocation( nodePoint.x, nodePoint.y )
		-- if new_coor_x >= 1 and new_coor_x <= 1501 and new_coor_y >= 1 and new_coor_y <= 1501 then
		-- 	if stateData.stateInMap(new_coor_x, new_coor_y) ~= 0 then
		-- 		miniMapManager.changeStateMapAndWorldMap(1,new_coor_x, new_coor_y )
		-- 		return false
		-- 	end
		-- end
		local state = isTouchState(x,y)
		if state then
			miniMapManager.changeStateMapAndWorldMap(1,state )
			return false
		end
	end
	return true
end

local function touchBegin(x,y, mark )
	isClickBegin = true
	mini_map_layer:stopAllActions()
	if not isMove then
		local stateid = isTouchState(x,y)
		if stateid then
			if image_table_[stateid] then
				image_table_[stateid][2]:setVisible(true)
			end
		end
	end
	
	mini_map_layer:runAction(animation.sequence({cc.DelayTime:create(0.2), cc.CallFunc:create(function (  )
		if not isClickEnd then
			isClickBegin = false
			local temp_touch = mark:getParent():convertToNodeSpace(cc.p(x,y))
			touch_mapPos = { x = temp_touch.x, y = temp_touch.y}
			return getHeightPos(x,y)
		else
			isClickBegin = false
			isClickEnd = false
		end
	end)}))
end

local function deal_with_jump_click(eventType, x,y)
	if not mini_map_layer then return end
	local temp_widget = mini_map_layer:getWidgetByTag(999)
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	local mark = tolua.cast(map_panel:getChildByName("ImageView_74821"), "ImageView")
	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")

	if eventType == "began" then
		if not map_content_panel:hitTest(cc.p(x,y)) then
			return false
		end
	end

	if eventType == "ended" and not isClickEnd and touchCancel(x,y) then
		local tempPoint = mark:getParent():convertToWorldSpace(cc.p(mark:getPositionX(),mark:getPositionY()))
		-- local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "ImageView")
		local touch_pos = map_content_panel:convertToNodeSpace(cc.p(tempPoint.x,tempPoint.y))--map_panel:convertToNodeSpace(cc.p(x,y))
		local new_coor_x,new_coor_y = clickConvertToLocation( touch_pos.x,touch_pos.y )
		if new_coor_x >= 1 and new_coor_x <= 1501 and new_coor_y >= 1 and new_coor_y <= 1501 then
			-- mapController.jump(new_coor_x,new_coor_y)
			set_pos_txt(new_coor_x, new_coor_y)
		end
		for i, v in pairs(image_table_) do
			v[2]:setVisible(false)
		end
		isMove = false
		return true
	elseif eventType == "moved" and not isClickEnd and not isClickBegin then
		-- local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "ImageView")
		local temp_touch = mark:getParent():convertToNodeSpace(cc.p(x,y))
		local worldPoint = mark:getParent():convertToWorldSpace(cc.p(mark:getPositionX()+ temp_touch.x-touch_mapPos.x,mark:getPositionY()+ temp_touch.y-touch_mapPos.y))
		local nodePoint = map_content_panel:convertToNodeSpace(worldPoint)
		local new_coor_x,new_coor_y = clickConvertToLocation(nodePoint.x, nodePoint.y)
		if new_coor_x >= 1 and new_coor_x <= 1501 and new_coor_y >= 1 and new_coor_y <= 1501 then
			mark:setPosition(cc.p(mark:getPositionX()+ temp_touch.x-touch_mapPos.x,mark:getPositionY()+ temp_touch.y-touch_mapPos.y))
			set_pos_txt(new_coor_x, new_coor_y)
		end
		touch_mapPos = { x = temp_touch.x, y = temp_touch.y}
		if not isMove then
			for i, v in pairs(image_table_) do
				v[2]:setVisible(false)
			end
			isMove = true
		end
		return true
	elseif eventType == "began" then
		-- local temp_touch = mark:getParent():convertToNodeSpace(cc.p(x,y))
		-- touch_mapPos = { x = temp_touch.x, y = temp_touch.y}
		-- return getHeightPos(x,y)
		-- local stateid = isTouchState(x,y)
		-- if stateid then
		-- 	if image_table_[stateid] then
		-- 		image_table_[stateid][2]:setVisible(true)
		-- 	end
		-- end
		touchBegin(x,y,mark )
		return true
	end
	
end

local function set_map_player_related_color_ownCity( )
	-- if not mini_map_layer then return end
	-- local temp_widget = mini_map_layer:getWidgetByTag(999)
	-- local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	-- local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")

	-- local node = nil
	-- local lingdiX_layer = nil
	-- local lingdiY_layer = nil
	-- local layer = nil
	-- for i, v in ipairs(m_arrOwnCityData) do
 --        v:removeFromParentAndCleanup(true)
 --    end

 --    for i, v in ipairs(m_arrOwnLingdiData) do
 --        v:removeFromParentAndCleanup(true)
 --    end

 --    m_arrOwnCityData = {}
 --    m_arrOwnLingdiData = {}

	-- local function drawNode(color, wid, city_type)
 --        if city_type == cityTypeDefine.lingdi or city_type == cityTypeDefine.player_chengqu then
 --            layer = CCLayer:create()
	-- 		layer:setContentSize(CCSize(3,3))
	-- 		layer:ignoreAnchorPointForPosition(false)
	-- 		layer:setAnchorPoint(cc.p(0.5,0.5))
	-- 		lingdiX_layer = cc.LayerColor:create(color, 3, 1)
	-- 		layer:addChild(lingdiX_layer)
	-- 		lingdiX_layer:setPosition(cc.p(-1,0))

	-- 		lingdiY_layer = cc.LayerColor:create(color, 1, 3)
	-- 		layer:addChild(lingdiY_layer)
	-- 		lingdiY_layer:setPosition(cc.p(0,-1))
 --        else
 --            layer = cc.LayerColor:create(color, 3, 3)
 --            layer:ignoreAnchorPointForPosition(false)
	-- 		layer:setAnchorPoint(cc.p(0.5,0.5))
 --        end

 --        temp_pos_x, temp_pos_y = locationConvertToClick(math.floor(wid/10000), wid%10000)
	-- 	layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
 --        return layer
 --    end

 --    for i, v in pairs(allTableData[dbTableDesList.world_city.name]) do
 --        if v.city_type == cityTypeDefine.zhucheng then
 --            node = drawNode(cc.c4b(255,0,0,255), v.wid, v.city_type )
 --            map_content_panel:addChild(node,1)
 --            table.insert(m_arrOwnCityData,node)
 --        -- elseif v.city_type == cityTypeDefine.fencheng then
 --        --     node = drawNode(cc.c4b(83,62,190,255), v.wid, v.city_type )
 --        --     map_content_panel:addChild(node,1)
 --        --     table.insert(m_arrOwnCityData,node)
 --        -- elseif v.city_type == cityTypeDefine.yaosai then
 --        --     node = drawNode(cc.c4b(241,230,244,255), v.wid, v.city_type )
 --        --     map_content_panel:addChild(node,1)
 --        --     table.insert(m_arrOwnCityData,node)
 --        -- elseif v.city_type == cityTypeDefine.player_chengqu or v.city_type == cityTypeDefine.lingdi then
 --        --     node = drawNode(cc.c4b(40,214,0,255), v.wid, v.city_type )
 --        --     map_content_panel:addChild(node,0)
 --        --     table.insert(m_arrOwnLingdiData,node)
 --        end
 --    end
end

local function set_map_player_related_color()
	local temp_widget = mini_map_layer:getWidgetByTag(999)
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")

	local temp_pos_x, temp_pos_y = nil, nil 
	local layer = nil

	local capitalParam = {}
    for i, v in ipairs(REGION_CAPITAL_PARAM) do
    	if NPC_CAPITAL_PARAM ~= v then
       		capitalParam[v] = 1
       	end
    end

    m_layer_pos = Layout:create()
    m_layer_pos:setSize(CCSizeMake(1,1))
    map_content_panel:addChild(m_layer_pos,1)
	
	for i, v in pairs(Tb_cfg_world_city) do
		if capitalParam[v.param] then
			temp_pos_x, temp_pos_y = locationConvertToClick(math.floor(v.wid/10000), v.wid%10000)
			layer = ImageView:create()
			layer:loadTexture(ResDefineUtil.zoushoufu_001, UI_TEX_TYPE_PLIST)
			layer:ignoreAnchorPointForPosition(false)
			layer:setAnchorPoint(cc.p(0.5,0.5))
			layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
			m_layer_pos:addChild(layer,1)
			table.insert(m_arrNpcCityData,{wid = v.wid, node = layer})
		elseif v.param >=NPC_CITY_PARAM_GUAN_QIA[1] and v.param <= NPC_CITY_PARAM_GUAN_QIA[2] then
			temp_pos_x, temp_pos_y = locationConvertToClick(math.floor(v.wid/10000), v.wid%10000)
			layer = ImageView:create()
			layer:loadTexture(ResDefineUtil.guanqia_01, UI_TEX_TYPE_PLIST)
			layer:ignoreAnchorPointForPosition(false)
			layer:setAnchorPoint(cc.p(0.5,0.5))
			layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
			m_layer_pos:addChild(layer,1)
			-- table.insert(m_arrOwnCityData,layer)
			table.insert(m_arrNpcCityData,{wid = v.wid, node = layer})
		elseif NPC_CAPITAL_PARAM == v.param then
			temp_pos_x, temp_pos_y = locationConvertToClick(math.floor(v.wid/10000), v.wid%10000)
			layer = ImageView:create()
			layer:loadTexture(ResDefineUtil.guodou_001, UI_TEX_TYPE_PLIST)
			layer:ignoreAnchorPointForPosition(false)
			layer:setAnchorPoint(cc.p(0.5,0.5))
			layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
			m_layer_pos:addChild(layer,1)
			table.insert(m_arrNpcCityData,{wid = v.wid, node = layer})
			-- table.insert(m_arrOwnCityData,layer)
		end
	end

	local draw = function (color, wid, city_type)
        -- if city_type == cityTypeDefine.lingdi or city_type == cityTypeDefine.player_chengqu then
        --     layer = tolua.cast(lingdiPanel:clone(),"Layout")
        -- else
        --     layer = tolua.cast(layerPanel:clone(),"Layout")
        --     layer:setBackGroundColor(color)
        -- end
        layer = cc.LayerColor:create(color, 3, 3)
        temp_pos_x, temp_pos_y = locationConvertToClick(math.floor(wid/10000), wid%10000)
        layer:setAnchorPoint(cc.p(0.5,0.5))
        layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
        return layer
    end

	for i, v in pairs(allTableData[dbTableDesList.world_city.name]) do
        if v.city_type == cityTypeDefine.zhucheng then
        elseif v.city_type == cityTypeDefine.fencheng then
            node = draw(cc.c4b(83,62,190,255), v.wid, v.city_type )
            m_layer_pos:addChild(node,1)
        elseif v.city_type == cityTypeDefine.yaosai then
            node = draw(cc.c4b(241,230,244,255), v.wid, v.city_type )
            m_layer_pos:addChild(node,1)
        elseif v.city_type == cityTypeDefine.player_chengqu or v.city_type == cityTypeDefine.lingdi then
            node = draw(cc.c4b(40,214,0,255), v.wid, v.city_type )
            m_layer_pos:addChild(node,0)
        end
    end

	--主城
	temp_pos_x, temp_pos_y = locationConvertToClick(math.floor(userData.getMainPos()/10000), userData.getMainPos()%10000)
	layer = ImageView:create()--cc.LayerColor:create(cc.c4b(255,0,0,255), 3, 3)
	layer:loadTexture(ResDefineUtil.zhucheng_00001, UI_TEX_TYPE_PLIST)
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(cc.p(0.5,0.5))
	layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
	m_layer_pos:addChild(layer,1)
	-- table.insert(m_arrOwnCityData,layer)
end

local function changeStateMapAndWorldMap(index,stateid )
	local temp_widget = mini_map_layer:getWidgetByTag(999)
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")
	local Panel_big_item = tolua.cast(temp_widget:getChildByName("Panel_big_item"), "Layout")
	local Panel_small_item = tolua.cast(temp_widget:getChildByName("Panel_small_item"), "Layout")
	local Panel_scroll = tolua.cast(temp_widget:getChildByName("Panel_scroll"), "Layout")
	local label_state_name = tolua.cast(temp_widget:getChildByName("Label_state_name"), "Label")
	local mark_state = tolua.cast(temp_widget:getChildByName("mark_state"), "ImageView")
	local mark = tolua.cast(map_panel:getChildByName("ImageView_74821"), "ImageView")
	local back_image = tolua.cast(temp_widget:getChildByName("ImageView_1020067"), "ImageView")
	--后退按钮
	local back_Button = tolua.cast(temp_widget:getChildByName("Button_back"), "Button")
	
	-- 州地图
	if index == 1 then
		CCUserDefault:sharedUserDefault():setStringForKey("minimap_status", "state")
		label_state_name:setText(languagePack["xiaoditu"].."-"..stateData.getStateNameById(stateid)) 
		Panel_big_item:setVisible(false)
		Panel_small_item:setVisible(true)
		Panel_scroll:setVisible(true)
		MiniMapState.init(temp_widget, stateid)
		layer_touch_:setTouchEnabled(false)
		mark:setVisible(false)
		m_layer_pos:setVisible(false)
		back_image:setVisible(true)
		back_Button:setVisible(true)
		
		back_image:runAction(CCFadeIn:create(scaleTime))
		Panel_small_item:runAction(CCFadeIn:create(scaleTime))
		back_Button:runAction(animation.sequence({CCFadeIn:create(scaleTime), cc.CallFunc:create(function ( )
			back_Button:setTouchEnabled(true)
		end)}))
	else
		CCUserDefault:sharedUserDefault():setStringForKey("minimap_status", "all")
		label_state_name:setText(languagePack["xiaoditu"]) 
		Panel_big_item:setVisible(true)
		Panel_small_item:setVisible(false)
		Panel_scroll:setVisible(false)
		mark_state:setVisible(false)
		-- tolua.cast(back_image:getVirtualRenderer(),"CCSprite"):setGray(kCCSpriteEffectNone)
		m_layer_pos:setVisible(true)
		mark:setVisible(true)
		back_Button:setTouchEnabled(false)
		-- back_image:setVisible(false)
		back_image:runAction(animation.sequence({CCFadeOut:create(scaleTime),cc.CallFunc:create(function ( )
			back_image:setVisible(false)
			-- body
		end)}))

		Panel_small_item:runAction(animation.sequence({CCFadeOut:create(scaleTime),cc.CallFunc:create(function ( )
			Panel_small_item:setVisible(false)
			-- body
		end)}))

		back_Button:runAction(animation.sequence({CCFadeOut:create(scaleTime),cc.CallFunc:create(function ( )
			back_Button:setVisible(false)
			layer_touch_:setTouchEnabled(true)
			-- body
		end)}))

		if m_iLastEditCoorX and m_iLastEditCoorY then
			setMarkPos(m_iLastEditCoorX, m_iLastEditCoorY)
	    	set_pos_txt(m_iLastEditCoorX, m_iLastEditCoorY)
	    end
	end
end

local function create()
	require("game/option/miniMapState")
	require("game/option/miniMapData")
	optionController.removeOptions()
	m_arrOwnCityData = {}
	m_arrOwnLingdiData = {}
	m_arrNpcCityData = {}
	cityPanelTouch = true
	MiniMapData.init()
	MiniMapData.requestDataInBigMap()
	mini_map_layer = TouchGroup:create()
	SmallMiniMap.miniMapButtonVisible(false )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/miniMapUI.json")
    temp_widget:setTag(999)
    temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(0.5,0.5))
    temp_widget:setScale(config.getgScale())
    -- local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "ImageView")
    temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    local open_btn = tolua.cast(temp_widget:getChildByName("Button_308336"), "Button")
    open_btn:setTouchEnabled(true)
    open_btn:addTouchEventListener(function (sender, eventType  )
    	if eventType == TOUCH_EVENT_ENDED then
    		remove_self()
    	end
    end)

    -- 输入标题
    local panel = tolua.cast(temp_widget:getChildByName("coor_txt"),"Layout")
    local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    inputBoxX = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    inputBoxX:setAlignment(1)
    inputBoxX:setFontName(config.getFontName())
    inputBoxX:setFontSize(20*config.getgScale())
    inputBoxX:setFontColor(ccc3(255,255,255))
    -- inputBoxX:setMaxLength(4)
    inputBoxX:setInputMode(kEditBoxInputModeNumeric)
    temp_widget:addChild(inputBoxX)
    inputBoxX:setScale(1/config.getgScale())
    inputBoxX:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    inputBoxX:setAnchorPoint(cc.p(0,0))
    inputBoxX:registerScriptEditBoxHandler(function (strEventName,pSender)
        if strEventName == "began" then
        	inputBoxX:setText(" ")
        	inputBoxX:setInputMode(kEditBoxInputModeNumeric)
        elseif strEventName == "ended" then
            -- ignore
        elseif strEventName == "return" then
        	if StringUtil.isEmptyStr(inputBoxX:getText()) then 
        		inputBoxX:setText(m_iLastEditCoorX)
        	else
        		local num_coor_x = tonumber(inputBoxX:getText())
        		local num_coor_y = tonumber(inputBoxY:getText())
	        	
	        	if num_coor_x and num_coor_y then
	        		-- local cityInfo = landData.get_world_city_info(num_coor_x*10000+num_coor_y)
		        	-- if not cityInfo or (cityInfo.city_type ~= cityTypeDefine.zhucheng and cityInfo.city_type ~= cityTypeDefine.fencheng and
		        	-- 	cityInfo.city_type ~= cityTypeDefine.yaosai) then
			        -- 	refresh_cell(nil)
			        -- end
			        m_iLastEditCoorX = tonumber(inputBoxX:getText())
			    else
			    	inputBoxX:setText(m_iLastEditCoorX)
			    end
		        
		    end
        elseif strEventName == "changed" then
            -- ignore
            -- local num_coor_x = tonumber(inputBoxX:getText())
            -- if not num_coor_x then 
            -- 	inputBoxX:setText(" ")
            -- end
        end
    end)

    local panel = tolua.cast(temp_widget:getChildByName("coor_txt2"),"Layout")
    local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    inputBoxY = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    inputBoxY:setAlignment(1)
    inputBoxY:setFontName(config.getFontName())
    inputBoxY:setFontSize(20*config.getgScale())
    inputBoxY:setFontColor(ccc3(255,255,255))
    -- inputBoxY:setMaxLength(4)
    inputBoxY:setInputMode(kEditBoxInputModeNumeric)
    inputBoxY:setScale(1/config.getgScale())
    temp_widget:addChild(inputBoxY)
    inputBoxY:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    inputBoxY:setAnchorPoint(cc.p(0,0))
    inputBoxY:registerScriptEditBoxHandler(function (strEventName,pSender)
        if strEventName == "began" then
        	inputBoxY:setText(" ")
        elseif strEventName == "ended" then
            -- ignore
        elseif strEventName == "return" then
        	if StringUtil.isEmptyStr(inputBoxY:getText()) then 
        		inputBoxY:setText(m_iLastEditCoorY)
        	else
        		local num_coor_x = tonumber(inputBoxX:getText())
        		local num_coor_y = tonumber(inputBoxY:getText())
        		if num_coor_x and num_coor_y then 
		        	local cityInfo = landData.get_world_city_info(num_coor_x*10000+num_coor_y)
		        	if not cityInfo or (cityInfo.city_type ~= cityTypeDefine.zhucheng and cityInfo.city_type ~= cityTypeDefine.fencheng and
		        		cityInfo.city_type ~= cityTypeDefine.yaosai) then
			        	-- refresh_cell(nil)
			        end
			        m_iLastEditCoorY = num_coor_y
			    else
			    	inputBoxY:setText(m_iLastEditCoorY)
			    end
		    end
        elseif strEventName == "changed" then
            -- ignore
            -- local num_coor_y = tonumber(inputBoxY:getText())
            -- if not num_coor_y then 
            -- 	inputBoxY:setText(" ")
            -- end
        end
    end)

	local btn = tolua.cast(temp_widget:getChildByName("Button_87829"),"Button")
	btn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			if tonumber(inputBoxX:getText()) >=1 and tonumber(inputBoxX:getText()) <=1501
				and tonumber(inputBoxY:getText()) >=1 and tonumber(inputBoxY:getText()) <=1501 then
				mapController.jump(tonumber(inputBoxX:getText()),tonumber(inputBoxY:getText()))
				remove_self()
			else
				tipsLayer.create(errorTable[113])
			end
		end
	end)

    layer_touch_ = CCLayer:create()
    temp_widget:addChild(layer_touch_)
    layer_touch_:setTouchEnabled(true)
    layer_touch_:registerScriptTouchHandler(deal_with_jump_click, false, 0, false)

    mini_map_layer:addWidget(temp_widget)

    local winSize = config.getWinSize()
    local coorX, coorY  = map.touchInMap(winSize.width/2, winSize.height/2)
    if not coorX then
    	coorX = math.floor(userData.getMainPos()/10000)
    end

    if not coorY then
    	coorY = userData.getMainPos()%10000
    end

    set_pos_txt(coorX, coorY)

    setMarkPos(coorX, coorY)

	set_map_player_related_color()
	-- set_map_player_related_color_ownCity()

	-- local cityPanel = tolua.cast(temp_widget:getChildByName("ImageView_548874"),"ImageView" )
	-- tolua.cast(cityPanel:getChildByName("ImageView_548892"),"ImageView" ):setVisible(false)
	-- tolua.cast(cityPanel:getChildByName("ImageView_548893"),"ImageView" ):setVisible(false)
	local image_circel = tolua.cast(temp_widget:getChildByName("image_circel"),"ImageView")
	image_circel:setVisible(false)
	
	local map_panel = tolua.cast(temp_widget:getChildByName("map_panel"), "Layout")
	tolua.cast(map_panel:getChildByName("ImageView_548895"),"ImageView"):setVisible(false)

	local map_content_panel = tolua.cast(map_panel:getChildByName("map_content"), "Layout")
	local back_image = ImageView:create()
	-- back_image:setScale(1.6)
	back_image:loadTexture("test/res_single/Small_map_new.png",UI_TEX_TYPE_LOCAL)
	back_image:setAnchorPoint(cc.p(0,0))
	map_content_panel:addChild(back_image,-1)
	

	UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.remove, miniMapManager.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.update, miniMapManager.reloadData)

    local status = CCUserDefault:sharedUserDefault():getStringForKey("minimap_status")
    if stateData.stateInMap(coorX, coorY) ~= 0 and (status == "" or status == "state") then
    	changeStateMapAndWorldMap(1,stateData.stateInMap(coorX, coorY))
    else
    	changeStateMapAndWorldMap(2,0)
    end

    local back_Button = tolua.cast(temp_widget:getChildByName("Button_back"), "Button")
    back_Button:addTouchEventListener(function ( sender,eventType )
    	if eventType == TOUCH_EVENT_ENDED then
    		MiniMapState.remove(true)
    		miniMapManager.changeStateMapAndWorldMap(2)
    	end
    end)

    local temp_sprite = nil
    local textureRender = nil

    local  Panel_touch_state = tolua.cast(map_content_panel:getChildByName("Panel_touch_state"),"Layout")
    image_table_ = {}
    for i=1 , 13 do
	    temp_sprite = cc.Sprite:create("test/res_single/".."minimapq_"..i..".png")
		temp_sprite:setAnchorPoint(cc.p(0,0))
		textureRender = CCRenderTexture:create(temp_sprite:getContentSize().width,temp_sprite:getContentSize().height,kCCTexture2DPixelFormat_RGBA8888)
		textureRender:begin()
		temp_sprite:visit()
		textureRender:endToLua()
		-- tolua.cast(Panel_touch_state:getChildByName("minimapq_"..i),"ImageView"):setVisible(true)
		table.insert(image_table_, {textureRender:newCCImage(), tolua.cast(Panel_touch_state:getChildByName("minimapq_"..i),"ImageView")})
    end

    uiManager.add_panel_to_layer(mini_map_layer, uiIndexDefine.UI_CITYLISTANDMAP)
    uiManager.showConfigEffect(uiIndexDefine.UI_CITYLISTANDMAP,mini_map_layer)
end

local function updateNpcCityColor( )
	if m_arrNpcCityData then
		local npcData = MiniMapData.getWorldNpcCityData()
		for i, v in pairs(m_arrNpcCityData) do
			if npcData[v.wid] then
				tolua.cast(v.node:getVirtualRenderer(),"CCSprite"):setColor(npcData[v.wid].color)
			end
		end
		SmallMiniMap.setNpcCityColorWhenOpenMiniMap()
	end
end

local function closeMiniMap( )
	-- require("game/option/cityListAndMiniMap")
	-- CityListAndMiniMap.remove_self()
	-- if is_open_state and mini_map_layer then
	-- 	is_open_state = false
	-- 	-- update_widget_pos()
	-- end
end

local function updateChangeCityState( )
	-- body
end

miniMapManager = {
					create = create,
					remove_self = remove_self,
					updateChangeCityState = updateChangeCityState,
					setMarkPos = setMarkPos,
					closeMiniMap = closeMiniMap,
					dealwithTouchEvent = dealwithTouchEvent,
					reloadData = reloadData,
					set_map_player_related_color_ownCity = set_map_player_related_color_ownCity,
					changeStateMapAndWorldMap = changeStateMapAndWorldMap,
					set_pos_txt = set_pos_txt,
					updateNpcCityColor = updateNpcCityColor,
}