local m_layer = nil
local m_up_img = nil
local m_down_img = nil

local function do_remove_self()
	if m_layer then
		m_up_img = nil
		m_down_img = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.RANK_DES_UI)

		--[[
		if rankingManager then
			rankingManager.set_drag_state(true)
		end
		--]]
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.RANK_DES_UI, m_layer, do_remove_self)
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

local function organize_player_other_info(other_panel)
	local content_panel, num_txt = nil
	for i=1,5 do
		content_panel = tolua.cast(other_panel:getChildByName("content_" .. i), "Layout")
		num_txt = tolua.cast(content_panel:getChildByName("num_label"), "Label")
		if i == 1 then
			num_txt:setText("+" .. RANK_POWER_PER_FORT)
		elseif i == 2 then
			num_txt:setText("+" .. RANK_POWER_PER_BRANCH_CITY)
		elseif i == 3 then
			num_txt:setText("+" .. RANK_POWER_PER_NPC_FORT)
		elseif i == 4 then
			num_txt:setText("+" .. RANK_POWER_PER_NPC_RECRUIT)
		elseif i == 5 then
			num_txt:setText("+" .. RANK_POWER_PER_HARBOR)
		end
	end
end

local function organize_player_npc_info(npc_panel)
	local title_img = tolua.cast(npc_panel:getChildByName("title_img"), "ImageView")
	local type_txt = tolua.cast(title_img:getChildByName("type_label"), "Label")
	type_txt:setText(languagePack['name_defenderProper'])

	local base_content = tolua.cast(npc_panel:getChildByName("base_content"), "Layout")
	local temp_line, temp_column, max_num = 4, 3, 10
	local start_x, divide_x, divide_y = 26, 185, 36
	local temp_index, temp_content, name_txt, num_txt = nil, nil, nil, nil
	for i=1,temp_column do
		for j=1,temp_line do
			temp_index = (i-1)*temp_line + j
			if temp_index <= max_num then
				temp_content = base_content:clone()
				temp_content:setPosition(cc.p(start_x + (i-1) * divide_x, (temp_line - j)*divide_y))
				name_txt = tolua.cast(temp_content:getChildByName("name_label"), "Label")
				num_txt = tolua.cast(temp_content:getChildByName("num_label"), "Label")
				name_txt:setText(languagePack['name_defenderProper'] .. "Lv." .. temp_index)
				num_txt:setText(" +" .. RANK_POWER_NPC_SUBURB[temp_index * 2])
				temp_content:setVisible(true)
				npc_panel:addChild(temp_content)
			end
		end
	end
end

local function organize_player_land_info(land_panel)
	local title_img = tolua.cast(land_panel:getChildByName("title_img"), "ImageView")
	local type_txt = tolua.cast(title_img:getChildByName("type_label"), "Label")
	type_txt:setText(languagePack['ziyuandi'])

	local base_content = tolua.cast(land_panel:getChildByName("base_content"), "Layout")
	local temp_line, temp_column, max_num = 4, 3, 9
	local start_x, divide_x, divide_y = 26, 185, 36
	local temp_index, temp_content, name_txt, num_txt = nil, nil, nil, nil
	for i=1,temp_column do
		for j=1,temp_line do
			temp_index = (i-1)*temp_line + j
			if temp_index <= max_num then
				temp_content = base_content:clone()
				temp_content:setPosition(cc.p(start_x + (i-1) * divide_x, (temp_line - j)*divide_y))
				name_txt = tolua.cast(temp_content:getChildByName("name_label"), "Label")
				num_txt = tolua.cast(temp_content:getChildByName("num_label"), "Label")
				name_txt:setText(languagePack['ziyuandi'] .. "Lv." .. temp_index)
				num_txt:setText("+" .. RANK_POWER_WORLD_RES[temp_index * 2])
				temp_content:setVisible(true)
				land_panel:addChild(temp_content)
			end
		end
	end
end

local function organize_player_des(content_img)
	m_up_img = tolua.cast(content_img:getChildByName("up_img"), "ImageView")
    m_down_img = tolua.cast(content_img:getChildByName("down_img"), "ImageView")
    m_down_img:setVisible(true)
    breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)

	local temp_sv = tolua.cast(content_img:getChildByName("content_sv"), "ScrollView")
	temp_sv:setTouchEnabled(true)
	temp_sv:addEventListenerScrollView(deal_with_scroll_event)

	local player_panel = tolua.cast(temp_sv:getChildByName("self_panel"), "Layout")
	local des_txt = tolua.cast(player_panel:getChildByName("des_label"), "Label")
	des_txt:setText(languagePack['player_rank_des'])

	local land_panel = tolua.cast(player_panel:getChildByName("land_panel"), "Layout")
	organize_player_land_info(land_panel)
	local npc_panel = tolua.cast(player_panel:getChildByName("npc_panel"), "Layout")
	organize_player_npc_info(npc_panel)
	local other_panel = tolua.cast(player_panel:getChildByName("other_panel"), "Layout")
	organize_player_other_info(other_panel)

	temp_sv:setVisible(true)
end

local function organize_union_des(content_img)
	local union_panel = tolua.cast(content_img:getChildByName("union_panel"), "Layout")
	local des_txt = tolua.cast(union_panel:getChildByName("des_label"), "Label")
	des_txt:setText(languagePack['union_rank_des'])

	local land_panel = tolua.cast(union_panel:getChildByName("land_panel"), "Layout")
	local title_img = tolua.cast(land_panel:getChildByName("title_img"), "ImageView")
	local type_txt = tolua.cast(title_img:getChildByName("type_label"), "Label")
	type_txt:setText(languagePack['chengchi'])

	local base_content = tolua.cast(land_panel:getChildByName("base_content"), "Layout")
	local temp_line, temp_column = 4, 2
	local start_x, divide_x, divide_y = 26, 230, 36
	local temp_index, temp_content, name_txt, num_txt = nil, nil, nil, nil
	for i=1,temp_column do
		for j=1,temp_line do
			temp_index = (i-1)*temp_line + j + 2
			temp_content = base_content:clone()
			temp_content:setPosition(cc.p(start_x + (i-1) * divide_x, (temp_line - j)*divide_y))
			name_txt = tolua.cast(temp_content:getChildByName("name_label"), "Label")
			num_txt = tolua.cast(temp_content:getChildByName("num_label"), "Label")
			name_txt:setText(languagePack['chengchi'] .. "Lv." .. temp_index)
			num_txt:setText("+" .. RANK_POWER_NPC_CITY[temp_index * 2])
			temp_content:setVisible(true)
			land_panel:addChild(temp_content)
		end
	end

	union_panel:setVisible(true)
end

local function create(des_type)
	if m_layer then
		return
	end

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/rankDesUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

    local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")
    if des_type == 1 then
    	organize_player_des(content_img)
    else
    	organize_union_des(content_img)
    end

	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"), "Button")
	confirm_btn:addTouchEventListener(deal_with_confirm_click)
	confirm_btn:setTouchEnabled(true)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.RANK_DES_UI)
	uiManager.showConfigEffect(uiIndexDefine.RANK_DES_UI, m_layer)
end

rankingDesManager = {
					create = create,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent
}