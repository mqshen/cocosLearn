local input_name_layer = nil
local m_edit_box = nil

local create_type = nil --1 分城；2 要塞
local touch_map_x, touch_map_y = nil, nil

local function do_remove_self()
	if input_name_layer then
		touch_map_x = nil
		touch_map_y = nil
		create_type = nil

		m_edit_box = nil
		input_name_layer:removeFromParentAndCleanup(true)
		input_name_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.INPUT_CITYNAME_INFO)
	end
end

local function remove_self()
	if input_name_layer then
		uiManager.hideConfigEffect(uiIndexDefine.INPUT_CITYNAME_INFO, input_name_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not input_name_layer then
		return false
	end

	local temp_widget = input_name_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_cancel_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function get_default_name()
	local temp_front_name, temp_own_nums = nil, nil
	if create_type == 1 then
		temp_front_name = languagePack['cityTypeName_fencheng']
		temp_own_nums = userCityData.getAllNumByType(cityTypeDefine.fencheng)
	else
		temp_front_name = languagePack['cityTypeName_yaosai']
		temp_own_nums = userCityData.getAllNumByType(cityTypeDefine.yaosai)
	end

	local default_name = temp_front_name .. (temp_own_nums + 1)
	return default_name
end

local function deal_with_confirm_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local new_name = m_edit_box:getText()
		if new_name == "" then
			--tipsLayer.create(errorTable[159])
			--return
			new_name = get_default_name()
		end

		if stringFunc.get_str_length(new_name) > 6 then
			tipsLayer.create(errorTable[158])
			return
		end

		if create_type == 1 then
			politics.requestNewBranchCity(touch_map_x*10000 + touch_map_y, new_name)
		else
			politics.requestNewFort(touch_map_x*10000 + touch_map_y, new_name)
		end
		remove_self()
		createCityManager.remove_self()
	end
end

local function init_edit_box(temp_widget)
	local name_bg_img = tolua.cast(temp_widget:getChildByName("input_bg_img"), "ImageView")
	local temp_scale = config.getgScale()
	local temp_size = CCSizeMake(name_bg_img:getSize().width*temp_scale, name_bg_img:getSize().height*temp_scale)
    local temp_rect = CCRectMake(9,9,2,2)
    m_edit_box = CCEditBox:create(temp_size, CCScale9Sprite:createWithSpriteFrameName(ResDefineUtil.Enter_the_name_plate,temp_rect))
    m_edit_box:setFontName(config.getFontName())
    m_edit_box:setFontSize(20*temp_scale)
    m_edit_box:setFontColor(ccc3(255,255,255))
   	name_bg_img:addChild(m_edit_box)
    m_edit_box:setScale(1/temp_scale)
    m_edit_box:setAlignment(1)
    m_edit_box:setPlaceHolder(languagePack["city_create_default"])
    --m_edit_box:setPosition(cc.p(titlePanel:getPositionX(), titlePanel:getPositionY()))
    --m_edit_box:setAnchorPoint(cc.p(0,0))

    -- 暂时注释掉，后续会加入默认名称
    --local tips_sign_img = tolua.cast(temp_widget:getChildByName("tips_sign_img"), "ImageView")
    --local tips_txt = tolua.cast(temp_widget:getChildByName("tips_label"), "Label")
    --tips_sign_img:setVisible(false)
    --tips_txt:setVisible(false)
end

local function init_show_content(temp_widget)
	local content_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")
	local name_txt = tolua.cast(content_panel:getChildByName("content_2"), "Label")
	local pos_txt = tolua.cast(content_panel:getChildByName("content_4"), "Label")
	local type_txt = tolua.cast(content_panel:getChildByName("content_6"), "Label")
	name_txt:setText(landData.get_city_name_by_coordinate(touch_map_x * 10000 + touch_map_y))
	pos_txt:setText("(" .. touch_map_x .. "," .. touch_map_y .. ")")
	if create_type == 1 then
		type_txt:setText(languagePack['cityTypeName_fencheng'])
	else
		type_txt:setText(languagePack['cityTypeName_yaosai'])
	end

	for i=2,6 do
		local pre_content,cur_content = nil
		if i == 3 then
			cur_content = tolua.cast(content_panel:getChildByName("content_" .. i), "ImageView")
		else
			cur_content = tolua.cast(content_panel:getChildByName("content_" .. i), "Label")
		end

		if i == 4 then
			pre_content = tolua.cast(content_panel:getChildByName("content_" .. (i - 1)), "ImageView")
		else
			pre_content = tolua.cast(content_panel:getChildByName("content_" .. (i - 1)), "Label")
		end
		
		cur_content:setPositionX(pre_content:getPositionX() + pre_content:getContentSize().width)
	end
end

local function init_btn_content(temp_widget)
	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"), "Button")
	confirm_btn:setTouchEnabled(true)
	confirm_btn:addTouchEventListener(deal_with_confirm_click)

	local cancel_btn = tolua.cast(temp_widget:getChildByName("cancel_btn"), "Button")
	cancel_btn:setTouchEnabled(true)
	cancel_btn:addTouchEventListener(deal_with_cancel_click)
end

local function create(new_type, pos_x, pos_y)
	if input_name_layer then
		return
	end

	create_type = new_type
	touch_map_x = pos_x
	touch_map_y = pos_y

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/createCityName.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_edit_box(temp_widget)
	init_show_content(temp_widget)
	init_btn_content(temp_widget)

	input_name_layer = TouchGroup:create()
	input_name_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(input_name_layer, uiIndexDefine.INPUT_CITYNAME_INFO)
	uiManager.showConfigEffect(uiIndexDefine.INPUT_CITYNAME_INFO, input_name_layer)
end

inputCityNameInfo = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent
}