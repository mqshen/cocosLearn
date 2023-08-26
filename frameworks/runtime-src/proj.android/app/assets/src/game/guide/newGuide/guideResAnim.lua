local m_anim_layer = nil
local m_bg_layer = nil
local m_is_playing_anim = nil

local function remove_self()
	if m_anim_layer then
		m_is_playing_anim = nil

		m_anim_layer:removeFromParentAndCleanup(true)
		m_anim_layer = nil

		m_bg_layer:removeFromParentAndCleanup(true)
		m_bg_layer = nil

		newGuideInfo.enter_next_guide()

		--mainOption.show_res_in_top_panel(false)
	end
end

local function deal_with_anim_finish()
	remove_self()
end

local function play_anim()
	m_is_playing_anim = true
	local temp_widget = m_anim_layer:getWidgetByTag(999)
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	des_img:setVisible(false)

	local scale_to = CCScaleTo:create(0.3, 0.2)
	--local move_to = CCMoveTo:create(1, temp_widget:convertToNodeSpace(mainOption.get_tool_btn_world_pos(2)))
	local move_to = CCMoveTo:create(0.5, mainOption.get_top_res_pos())
	local fun_call = cc.CallFunc:create(deal_with_anim_finish)

	local temp_array = CCArray:create()
	temp_array:addObject(scale_to)
	temp_array:addObject(move_to)
	temp_array:addObject(fun_call)
	local temp_seq = cc.Sequence:create(temp_array)

	--local hero_panel = tolua.cast(temp_widget:getChildByName("icon_panel"), "Layout")
	temp_widget:runAction(temp_seq)
end


local function dealwithTouchEvent(x,y)
	if not m_anim_layer then
		return false
	end

	if not m_is_playing_anim then
		play_anim()
	end

	return true
end

local function deal_with_layer_touch(eventType, x, y)
	if eventType == "began" then
		return dealwithTouchEvent(x, y)
	else
		return true
	end
end

local function set_res_num(temp_widget)
	local temp_drop_id = 71901
	local res_list = Tb_cfg_battle_drop[temp_drop_id].drops
	local res_panel = tolua.cast(temp_widget:getChildByName("res_panel"), "Layout")
	local res_img, content_img, num_txt = nil, nil, nil
	for k,v in pairs(res_list) do
		res_img = tolua.cast(res_panel:getChildByName("img_" .. v[1]), "ImageView")
		content_img = tolua.cast(res_img:getChildByName("content_img"), "ImageView")
		num_txt = tolua.cast(content_img:getChildByName("num_label"), "Label")
		num_txt:setText(v[2])
	end
end

local function create()
	if m_anim_layer then
		return
	end

	mainOption.show_res_in_top_panel(true)
	
	m_is_playing_anim = false

	local win_size = config.getWinSize()
	m_bg_layer = cc.LayerColor:create(cc.c4b(14, 17, 24, 150), win_size.width, win_size.height)
	m_bg_layer:registerScriptTouchHandler(deal_with_layer_touch, false, layerPriorityList.guide_swallow_priority, true)
	m_bg_layer:setTouchEnabled(true)

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/guideResUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	set_res_num(temp_widget)

	m_anim_layer = TouchGroup:create()
	m_anim_layer:addWidget(temp_widget)
	newGuideManager.add_waiting_panel(m_bg_layer, m_anim_layer)
end

guideResAnim = {
					create = create,
					remove_self = remove_self
}