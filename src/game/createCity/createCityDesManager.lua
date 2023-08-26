local m_layer = nil
local m_up_img = nil
local m_down_img = nil

local function do_remove_self()
	if m_layer then
		m_up_img = nil
		m_down_img = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.CREATE_CITY_DES_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.CREATE_CITY_DES_UI, m_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not m_layer then
		return false
	end

	local temp_widget = m_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_confirm_click(sender, eventType) 
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function deal_with_scroll_event(sender, eventType)
    if eventType == SCROLLVIEW_EVENT_SCROLLING then
    	m_up_img:setVisible(true)
	    m_down_img:setVisible(true)
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_TOP then
		m_up_img:setVisible(false)
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
    	m_down_img:setVisible(false)
    end
end

local function organize_fort_info(fort_panel, current_renown)
	local base_content = tolua.cast(fort_panel:getChildByName("base_content"), "Layout")
	local max_num = 0
	for k,v in pairs(Tb_cfg_fort_renown) do
		max_num = max_num + 1
	end
	local temp_column = 2
	local temp_line = 0
	if max_num%2 == 0 then
		temp_line = max_num/2
	else
		temp_line = math.floor(max_num/2) + 1
	end

	local start_x, divide_x, divide_y = 26, 244, 30
	local temp_index, temp_show_renown, temp_content, num_txt_1, num_txt_2 = nil, nil, nil, nil, nil
	for i=1,temp_column do
		for j=1,temp_line do
			temp_index = (i-1)*temp_line + j
			if temp_index <= max_num then
				temp_content = base_content:clone()
				temp_content:setPosition(cc.p(start_x + (i-1) * divide_x, (temp_line - j)*divide_y))
				num_txt_1 = tolua.cast(temp_content:getChildByName("num_label_1"), "Label")
				num_txt_2 = tolua.cast(temp_content:getChildByName("num_label_2"), "Label")
				temp_show_renown = math.floor(Tb_cfg_fort_renown[temp_index].renown/100)
				if temp_show_renown > current_renown then
					num_txt_1:setColor(ccc3(128, 128, 127))
					num_txt_2:setColor(ccc3(128, 128, 127))
				else
					num_txt_1:setColor(ccc3(125, 187, 139))
					num_txt_2:setColor(ccc3(125, 187, 139))
				end

				num_txt_1:setText(temp_index)
				num_txt_2:setText(temp_show_renown)
				temp_content:setVisible(true)
				fort_panel:addChild(temp_content)
			end
		end
	end

	local des_panel = tolua.cast(fort_panel:getChildByName("des_panel"), "Layout")
	des_panel:setPositionY(divide_y * temp_line)

	local temp_panel_height = divide_y * temp_line + des_panel:getContentSize().height
	fort_panel:setSize(CCSizeMake(fort_panel:getSize().width, temp_panel_height))

	return temp_panel_height
end

local function organize_city_info(city_panel, current_renown)
	local base_content = tolua.cast(city_panel:getChildByName("base_content"), "Layout")
	local max_num = 0
	for k,v in pairs(Tb_cfg_city_renown) do
		max_num = max_num + 1
	end
	local temp_column = 2
	local temp_line = 0
	if max_num%2 == 0 then
		temp_line = max_num/2
	else
		temp_line = math.floor(max_num/2) + 1
	end

	local start_x, divide_x, divide_y = 26, 244, 30
	local temp_index, temp_show_renown, temp_content, num_txt_1, num_txt_2 = nil, nil, nil, nil, nil
	for i=1,temp_column do
		for j=1,temp_line do
			temp_index = (i-1)*temp_line + j
			if temp_index <= max_num then
				temp_content = base_content:clone()
				temp_content:setPosition(cc.p(start_x + (i-1) * divide_x, (temp_line - j)*divide_y))
				num_txt_1 = tolua.cast(temp_content:getChildByName("num_label_1"), "Label")
				num_txt_2 = tolua.cast(temp_content:getChildByName("num_label_2"), "Label")
				temp_show_renown = math.floor(Tb_cfg_city_renown[temp_index].renown/100)
				if temp_show_renown > current_renown then
					num_txt_1:setColor(ccc3(128, 128, 127))
					num_txt_2:setColor(ccc3(128, 128, 127))
				else
					num_txt_1:setColor(ccc3(125, 187, 139))
					num_txt_2:setColor(ccc3(125, 187, 139))
				end

				num_txt_1:setText(temp_index)
				num_txt_2:setText(temp_show_renown)
				temp_content:setVisible(true)
				city_panel:addChild(temp_content)
			end
		end
	end

	local des_panel = tolua.cast(city_panel:getChildByName("des_panel"), "Layout")
	des_panel:setPositionY(divide_y * temp_line)

	local temp_panel_height = divide_y * temp_line + des_panel:getContentSize().height
	city_panel:setSize(CCSizeMake(city_panel:getSize().width, temp_panel_height))

	return temp_panel_height
end

local function organize_des_info(content_img)
	m_up_img = tolua.cast(content_img:getChildByName("up_img"), "ImageView")
    m_down_img = tolua.cast(content_img:getChildByName("down_img"), "ImageView")
    m_down_img:setVisible(true)
    breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)

	local temp_sv = tolua.cast(content_img:getChildByName("content_sv"), "ScrollView")
	temp_sv:setTouchEnabled(true)
	temp_sv:addEventListenerScrollView(deal_with_scroll_event)

	local current_renown = userData.getShowRenownNums()
	local city_panel = tolua.cast(temp_sv:getChildByName("city_panel"), "Layout")
	local city_show_height = organize_city_info(city_panel, current_renown)
	local fort_panel = tolua.cast(temp_sv:getChildByName("fort_panel"), "Layout")
	local fort_show_height = organize_fort_info(fort_panel, current_renown)
	
	fort_panel:setPositionY(city_show_height)
	temp_sv:setInnerContainerSize(CCSizeMake(temp_sv:getContentSize().width, fort_show_height + city_show_height))
	--temp_sv:jumpToTop()
	m_up_img:setVisible(false)
end

local function create()
	if m_layer then
		return
	end

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/createCityDesUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

    local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")
    organize_des_info(content_img)

	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"), "Button")
	confirm_btn:addTouchEventListener(deal_with_confirm_click)
	confirm_btn:setTouchEnabled(true)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.CREATE_CITY_DES_UI)
	uiManager.showConfigEffect(uiIndexDefine.CREATE_CITY_DES_UI, m_layer)
end

createCityDesManager = {
					create = create,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent
}