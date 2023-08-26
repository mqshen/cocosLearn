local tool_show_layer = nil
local guide_touch_group = nil

local current_guide_id = nil

local m_tool_state = nil

local function remove_self()
	if guide_touch_group then
		current_guide_id = nil

		guide_touch_group:removeFromParentAndCleanup(true)
		guide_touch_group = nil
	end
end

local function remove()
	if tool_show_layer then
		remove_self()

		tool_show_layer:removeFromParentAndCleanup(true)
		tool_show_layer = nil
	end

	m_tool_state = nil
end

local function deal_with_close_click(sender, eventType) 
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function is_force_guide()
	local temp_widget = guide_touch_group:getWidgetByTag(999)
	local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")
	local type_img = tolua.cast(content_img:getChildByName("type_img"), "ImageView")
	local select_cb = tolua.cast(type_img:getChildByName("select_cb"), "CheckBox")

	return select_cb:getSelectedState()
end

local function organize_ui_mask()
	local temp_guide_info = nil
	if is_force_guide() then
		temp_guide_info = guide_cfg_info[current_guide_id]
	else
		temp_guide_info = com_guide_cfg_info[current_guide_id]
	end

	local temp_main_class = uiPanelInfo.get_main_class_by_index(uiIndexDefine[temp_guide_info.ui_id_name])
	local ui_widget = nil
	if is_force_guide() then
		ui_widget = temp_main_class.get_guide_widget(current_guide_id)
	else
		ui_widget = temp_main_class.get_com_guide_widget(current_guide_id)
	end

	local temp_widget = guide_touch_group:getWidgetByTag(999)
	local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")

	local pos_panel, x_txt, y_txt, w_txt, h_txt = nil, nil, nil, nil, nil
	for i=1,4 do
		pos_panel = tolua.cast(content_img:getChildByName("pos_" .. i), "Layout")
		if i == 1 then
			x_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		elseif i == 2 then
			y_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		elseif i == 3 then
			w_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		elseif i == 4 then
			h_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		end
	end

	local op_img = tolua.cast(content_img:getChildByName("op_img"), "ImageView")
	local select_cb = tolua.cast(op_img:getChildByName("select_cb"), "CheckBox")

	local pos_x = tonumber(x_txt:getStringValue())
	local pos_y = tonumber(y_txt:getStringValue())
	local show_w = tonumber(w_txt:getStringValue())
	local show_h = tonumber(h_txt:getStringValue())
	local is_left_top_align = select_cb:getSelectedState()

	local ui_refer_list = stringFunc.anlayerOnespot(temp_guide_info.ui_mask_reference, ";", false)
	local mask_widget = ui_widget
	if ui_refer_list[1] ~= "self" then
		local ui_path_list = stringFunc.anlayerOnespot(ui_refer_list[1], "/", false)
		for i,v in ipairs(ui_path_list) do
			mask_widget = mask_widget:getChildByName(v)
		end
	end

	local mask_pos = nil
	if is_left_top_align then
		mask_pos = mask_widget:convertToWorldSpaceAR(cc.p(pos_x, pos_y))
	else
		mask_pos = mask_widget:convertToWorldSpace(cc.p(pos_x, pos_y))
	end

	local pos_img = tolua.cast(temp_widget:getChildByName("show_img"), "ImageView")
	pos_img:setPosition(temp_widget:convertToNodeSpace(mask_pos))
	pos_img:setSize(CCSize(show_w + 36*2, show_h + 38*2))
	pos_img:setVisible(true)
end

local function init_pos_info()
	local temp_guide_info = nil
	if is_force_guide() then
		temp_guide_info = guide_cfg_info[current_guide_id]
	else
		temp_guide_info = com_guide_cfg_info[current_guide_id]
	end

	if temp_guide_info.ui_id_name == "" then
		return false
	end

	local temp_main_class = uiPanelInfo.get_main_class_by_index(uiIndexDefine[temp_guide_info.ui_id_name])
	if not temp_main_class then
		return false
	end

	local ui_widget = nil
	if is_force_guide() then
		ui_widget = temp_main_class.get_guide_widget(current_guide_id)
	else
		ui_widget = temp_main_class.get_com_guide_widget(current_guide_id)
	end
	if not ui_widget then
		return false
	end

	if temp_guide_info.ui_mask_reference == "" then
		return false
	end

	local ui_pos_list = stringFunc.anlayerMsg(temp_guide_info.ui_mask_pos)

	local temp_widget = guide_touch_group:getWidgetByTag(999)
	local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")

	local pos_panel, x_txt, y_txt, w_txt, h_txt = nil, nil, nil, nil, nil
	for i=1,4 do
		pos_panel = tolua.cast(content_img:getChildByName("pos_" .. i), "Layout")
		if i == 1 then
			x_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		elseif i == 2 then
			y_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		elseif i == 3 then
			w_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		elseif i == 4 then
			h_txt = tolua.cast(pos_panel:getChildByName("num_label"), "TextField")
		end
	end

	x_txt:setText(ui_pos_list[1][1])
	y_txt:setText(ui_pos_list[1][2])
	w_txt:setText(ui_pos_list[1][3])
	h_txt:setText(ui_pos_list[1][4])

	local op_img = tolua.cast(content_img:getChildByName("op_img"), "ImageView")
	local select_cb = tolua.cast(op_img:getChildByName("select_cb"), "CheckBox")
	if ui_pos_list[1][5] == 1 then
		select_cb:setSelectedState(true)
	else
		select_cb:setSelectedState(false)
	end

	organize_ui_mask()
	return true
end

local function deal_with_load_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_widget = guide_touch_group:getWidgetByTag(999)
		local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")
		local id_txt = tolua.cast(content_img:getChildByName("id_label"), "TextField")
		local input_content = id_txt:getStringValue()
		if input_content ~= "" then
			current_guide_id = tonumber(input_content)
			local is_need_ui_mask = init_pos_info()
			if not is_need_ui_mask then
				current_guide_id = 0
			end
		end
	end
end

local function deal_with_add_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if current_guide_id == 0 then
			return
		end

		local temp_panel = sender:getParent()
		local num_txt = tolua.cast(temp_panel:getChildByName("num_label"), "TextField")
		local current_content = num_txt:getStringValue()
		if current_content == "" then
			num_txt:setText("0")
		else
			local current_value = tonumber(current_content)
			current_value = current_value + 1
			num_txt:setText(current_value)
		end

		organize_ui_mask()
	end
end

local function deal_with_dec_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if current_guide_id == 0 then
			return
		end

		local temp_panel = sender:getParent()
		local num_txt = tolua.cast(temp_panel:getChildByName("num_label"), "TextField")
		local current_content = num_txt:getStringValue()
		if current_content == "" then
			num_txt:setText("0")
		else
			local current_value = tonumber(current_content)
			current_value = current_value - 1
			num_txt:setText(current_value)
		end

		organize_ui_mask()
	end
end

local function deal_with_top_cb_click(sender, eventType)
	local temp_widget = guide_touch_group:getWidgetByTag(999)
	local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")
	if eventType == CHECKBOX_STATE_EVENT_SELECTED then
		content_img:setPositionY(temp_widget:getContentSize().height - content_img:getContentSize().height/2)
	else
		content_img:setPositionY(content_img:getContentSize().height/2)
	end
end

local function create()
	if guide_touch_group then
		return
	end

	if not tool_show_layer then
		tool_show_layer = CCLayer:create()
		tool_show_layer:setTouchEnabled(true)
		cc.Director:getInstance():getRunningScene():addChild(tool_show_layer, GUIDE_TOOL_SCENE)
	end

	current_guide_id = 0

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/guideToolUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local pos_img = tolua.cast(temp_widget:getChildByName("show_img"), "ImageView")
	pos_img:setVisible(false)

	local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")

	local top_sign_img = tolua.cast(content_img:getChildByName("pos_panel"), "ImageView")
	local top_select_cb = tolua.cast(top_sign_img:getChildByName("select_cb"), "CheckBox")
	top_select_cb:setTouchEnabled(true)
	top_select_cb:setSelectedState(false)
	top_select_cb:addEventListenerCheckBox(deal_with_top_cb_click)

	local pos_panel, add_btn, dec_btn = nil, nil, nil
	for i=1,4 do
		pos_panel = tolua.cast(content_img:getChildByName("pos_" .. i), "Layout")
		add_btn = tolua.cast(pos_panel:getChildByName("add_btn"), "Button")
		add_btn:addTouchEventListener(deal_with_add_click)
		add_btn:setTouchEnabled(true)
		dec_btn = tolua.cast(pos_panel:getChildByName("dec_btn"), "Button")
		dec_btn:addTouchEventListener(deal_with_dec_click)
		dec_btn:setTouchEnabled(true)
	end

	local load_btn = tolua.cast(content_img:getChildByName("load_btn"), "Button")
	load_btn:addTouchEventListener(deal_with_load_click)
	load_btn:setTouchEnabled(true)

	local close_btn = tolua.cast(content_img:getChildByName("close_btn"), "Button")
	close_btn:addTouchEventListener(deal_with_close_click)
	close_btn:setTouchEnabled(true)

	guide_touch_group = TouchGroup:create()
	guide_touch_group:addWidget(temp_widget)
	tool_show_layer:addChild(guide_touch_group)
end

local function deal_with_ui_loaded()
	remove_self()

	create()
end

local function is_show_state()
	if guide_touch_group then
		return true
	else
		return false
	end
end

local function get_state()
	return m_tool_state
end

local function set_state(new_state)
	m_tool_state = new_state
end

simpleGuideTool = {
						remove = remove,
						is_show_state = is_show_state,
						get_state = get_state,
						set_state = set_state,
						deal_with_ui_loaded = deal_with_ui_loaded
}