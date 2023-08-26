local create_city_layer = nil
local touch_map_x, touch_map_y = nil, nil

local function do_remove_self()
	if create_city_layer then
		touch_map_x = nil
		touch_map_y = nil
		create_city_layer:removeFromParentAndCleanup(true)
		create_city_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.OP_CREATE_CITY)
	end
end

local function remove_self()
	if create_city_layer then
		uiManager.hideConfigEffect(uiIndexDefine.OP_CREATE_CITY, create_city_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not create_city_layer then
		return false
	end

	local temp_widget = create_city_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_close_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function get_jump_pos(map_pos_x, map_pos_y)
	local temp_widget = create_city_layer:getWidgetByTag(999)
	local old_screen_y = math.floor(config.getWinSize().height/2)

	local old_left_screen_x = math.floor((config.getWinSize().width - temp_widget:getContentSize().width * config.getgScale())/2)
	local old_left_map_x, old_left_map_y = map.touchInMap(old_left_screen_x, old_screen_y)
	if old_left_map_x == nil or old_left_map_y == nil then
		return map_pos_x, map_pos_y
	end

	local old_center_screen_x = math.floor(config.getWinSize().width/2)
	local old_center_map_x, old_center_map_y = map.touchInMap(old_center_screen_x, old_screen_y)
	if old_center_map_x == nil or old_center_map_y == nil then
		return map_pos_x, map_pos_y
	end

	local new_map_x = old_center_map_x + (map_pos_x - old_left_map_x)
	local new_map_y = old_center_map_y + (map_pos_y - old_left_map_y)
	if new_map_x > 1501 or new_map_x <1 or new_map_y >1501 or new_map_y <1 then
		return map_pos_x, map_pos_y
	else
		return new_map_x, new_map_y
	end
end

--周围8格都是自己的土地才可以建
local function get_create_fc_state_by_area( )
	local is_can_create = false
	for i=-1,1 do
		for j=-1,1 do
			if not (i == 0 and j == 0) then
				local temp_relation = mapData.getRelation(touch_map_x + i, touch_map_y + j)
				if temp_relation then
					if temp_relation == mapAreaRelation.own_self then
						local temp_type = mapData.getCityTypeData(touch_map_x + i, touch_map_y + j)
						if temp_type ~= cityTypeDefine.lingdi then
							return false
						else
							is_can_create = true
						end
					else
						return false
					end
				else
					return false
				end
			end
		end
	end
	return is_can_create
end

--周围8格都没有正在拆除才能建城
local function get_create_fc_state_by_state( )
	local is_can_create = true
	local cityInfo = nil
	for i=-1,1 do
		for j=-1,1 do
			-- if not (i == 0 and j == 0) then
				cityInfo = landData.get_world_city_info((touch_map_x + i)*10000+touch_map_y + j)
				if cityInfo and cityInfo.state == cityState.removing then
					return false
				end
			-- end
		end
	end
	return is_can_create
end

local function deal_with_tips_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/createCity/createCityDesManager")
		createCityDesManager.create()
	end
end

local function deal_with_create_fc(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local is_create = get_create_fc_state_by_area()
		if not is_create then
			--[[
			local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[1])
			if show_sign == 0 then
				require("game/guide/shareGuide/picTipsManager")
				picTipsManager.create(1)

				CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[1], 1)
			else
				tipsLayer.create(errorTable[197])
			end
			--]]

			require("game/guide/shareGuide/picTipsManager")
			picTipsManager.create(1)

			return
		end

		local is_right_state = get_create_fc_state_by_state( )
		if not is_right_state then
			tipsLayer.create(errorTable[198])
			return
		end

		local current_fc_nums = userCityData.getHaveNumsByType(cityTypeDefine.fencheng)
		if current_fc_nums >= #_Tb_cfg_city_renown then
			tipsLayer.create(errorTable[13])
			return
		end

		local need_nums = math.floor(Tb_cfg_city_renown[current_fc_nums + 1].renown / 100)
		local own_nums = userData.getShowRenownNums()
		if need_nums > own_nums then
			tipsLayer.create(errorTable[11], nil, {need_nums})
			return
		end

		require("game/createCity/createCityManager")
		createCityManager.create(1, touch_map_x, touch_map_y)
		remove_self()
	end
end

local function deal_with_create_ys(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local current_ys_nums = userCityData.getHaveNumsByType(cityTypeDefine.yaosai)
		if current_ys_nums >= #_Tb_cfg_fort_renown then
			tipsLayer.create(errorTable[98])
			return
		end

		local need_nums = math.floor(Tb_cfg_fort_renown[current_ys_nums + 1].renown / 100)
		local own_nums = userData.getShowRenownNums()
		if need_nums > own_nums then
			tipsLayer.create(errorTable[12], nil, {need_nums})
			return
		end

		require("game/createCity/createCityManager")
		createCityManager.create(2, touch_map_x, touch_map_y)
		remove_self()
	end
end

local function init_fc_show_info(temp_widget)
	local fencheng_btn = tolua.cast(temp_widget:getChildByName("fc_btn"), "Button")
	fencheng_btn:setTouchEnabled(true)
	fencheng_btn:addTouchEventListener(deal_with_create_fc)

	local is_enough_area = get_create_fc_state_by_area()
	if not is_enough_area then
		local build_img = tolua.cast(fencheng_btn:getChildByName("build_img"), "ImageView")
		GraySprite.create(build_img)
	end
end

local function init_ys_show_info(temp_widget)
	local yaosai_btn = tolua.cast(temp_widget:getChildByName("ys_btn"), "Button")
	yaosai_btn:setTouchEnabled(true)
	yaosai_btn:addTouchEventListener(deal_with_create_ys)
end

local function create(map_x, map_y)
	if create_city_layer then
		return
	end

	if CityListOwnedAndMarked then 
		CityListOwnedAndMarked.closeDirectlly()
	end
	
	touch_map_x = map_x
	touch_map_y = map_y

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/newBuildUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(1,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width, config.getWinSize().height/2))

	init_fc_show_info(temp_widget)
	init_ys_show_info(temp_widget)

	local tips_btn = tolua.cast(temp_widget:getChildByName("tips_btn"), "Button")
	tips_btn:setTouchEnabled(true)
	tips_btn:addTouchEventListener(deal_with_tips_click)

	--[[
	local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)
	--]]

	create_city_layer = TouchGroup:create()
	create_city_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(create_city_layer, uiIndexDefine.OP_CREATE_CITY)
	uiManager.showConfigEffect(uiIndexDefine.OP_CREATE_CITY, create_city_layer)

	mapController.jump(get_jump_pos(touch_map_x, touch_map_y))
	mapController.selectGroundDisplay(touch_map_x, touch_map_y)
end

opCreateCity = {
					create = create,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent
}