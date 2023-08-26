local ranking_layer = nil
local temp_widget = nil
local m_backPanel = nil

local show_content_tb = nil
local last_selected_index = nil

local player_order_list = nil
local player_self_index = nil
local union_order_list = nil
local union_self_index = nil

local m_is_in_player_list = nil 		--自己是否在玩家排行榜中
local m_is_in_union_list = nil 			--同盟是否在同盟排行榜中

local touch_response_area = nil
local is_open_state = nil

local m_pos_timer = nil 				--定位跳转所需

local function do_remove_self()
	if m_pos_timer then
		scheduler.remove(m_pos_timer)
		m_pos_timer = nil
	end
	
	if ranking_layer then
		temp_widget = nil
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end
		
		player_order_list = nil
		player_self_index = nil
		union_order_list = nil
		union_self_index = nil
		m_is_in_player_list = nil
		m_is_in_union_list = nil

		touch_response_area = nil
		is_open_state = nil

		last_selected_index = nil
		show_content_tb = nil
		ranking_layer:removeFromParentAndCleanup(true)
		ranking_layer = nil

    	uiManager.remove_self_panel(uiIndexDefine.RANKING_UI)
	end
end

local function remove_self(closeEffect)
	if m_pos_timer then
		scheduler.remove(m_pos_timer)
		m_pos_timer = nil
	end
	
	if closeEffect then
		do_remove_self()
		return
	end
    if m_backPanel then
    	uiManager.hideConfigEffect(uiIndexDefine.RANKING_UI, ranking_layer, do_remove_self, 999,{m_backPanel:getMainWidget()})
    end
end

local function dealwithTouchEvent(x,y)
	return false
end

local function is_response_touch_end()
	if uiManager:getLastMoveState() then
		return false
	end

	local content_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")
	local touch_pos = content_panel:convertToNodeSpace(uiManager.getLastPoint())

	return touch_response_area:containsPoint(touch_pos)
end

local function set_drag_state(new_state)
	if not show_content_tb then
		return
	end

	if new_state then
		show_content_tb:setTouchEnabled(true)
	else
		show_content_tb:setTouchEnabled(false)
	end
end

local function update_show_level(is_most_above)
	set_drag_state(is_most_above)
end

local function is_in_player_page()
	if last_selected_index == 1 then
		return true
	else
		return false
	end
end

local function show_cell_content(cell_widget, idx)
	local show_order = idx + 1

	local function deal_with_name_click(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
			if is_in_player_page() then
				local player_info = player_order_list[show_order]
				UIRoleForcesMain.create(player_info.user_id)
			else
				local union_info = union_order_list[show_order]
				UnionUIJudge.create(union_info.union_id)
			end
			--set_drag_state(false)
		end
	end

	local content_1 = tolua.cast(cell_widget:getChildByName("content_1"), "Label")
	local content_2 = tolua.cast(cell_widget:getChildByName("content_2"), "ImageView")
	local name_txt = tolua.cast(content_2:getChildByName("name_label"), "Label")
	local self_or_not = false
	if is_in_player_page() then
		if idx == player_self_index then
			self_or_not = true
		end
	else
		if idx == union_self_index then
			self_or_not = true
		end
	end

	local content_3 = tolua.cast(cell_widget:getChildByName("content_3"), "Label")
	local content_4 = tolua.cast(cell_widget:getChildByName("content_4"), "Label")
	local content_5 = tolua.cast(cell_widget:getChildByName("content_5"), "Label")
	local content_6 = tolua.cast(cell_widget:getChildByName("content_6"), "Label")
	-- 所属州
	local content_7 = tolua.cast(cell_widget:getChildByName("content_7"), "Label")
	local self_img = tolua.cast(cell_widget:getChildByName("self_img"), "ImageView")
	self_img:setVisible(self_or_not)

	--前3名的显示特殊处理
	local rank_img = tolua.cast(cell_widget:getChildByName("rank_img"), "ImageView")
	content_1:setVisible(false)
	rank_img:setVisible(false)

	if is_in_player_page() then
		local player_info = player_order_list[show_order]
		if self_or_not and (not m_is_in_player_list) then
			--content_1:setText(idx .. "+")
			content_1:setText(languagePack["weishangbang"])
			content_1:setVisible(true)
		else
			content_1:setText(show_order)
			content_1:setVisible(true)
			
			--[[
			策划说个人的不需要特殊显示了，哎
			if show_order > 3 then
				content_1:setText(show_order)
				content_1:setVisible(true)
			else
				rank_img:loadTexture(ResDefineUtil.rank_list_res[show_order], UI_TEX_TYPE_PLIST)
				rank_img:setVisible(true)
			end
			--]]
		end
		
		name_txt:setText(player_info.name)
		content_3:setText(player_info.branch_city_count)
		content_4:setText(player_info.fort_count)
		content_5:setText(player_info.land_count)
		content_6:setText(player_info.power)
		content_7:setText(stateData.getStateNameById(player_info.region))
	else
		local union_info = union_order_list[show_order]
		if self_or_not and (not m_is_in_union_list) then
			--content_1:setText(idx .. "+")
			content_1:setText(languagePack["weishangbang"])
			content_1:setVisible(true)
		else
			if show_order > 3 then
				content_1:setText(show_order)
				content_1:setVisible(true)
			else
				rank_img:loadTexture(ResDefineUtil.rank_list_res[show_order], UI_TEX_TYPE_PLIST)
				rank_img:setVisible(true)
			end
		end
		
		name_txt:setText(union_info.name)
		content_3:setText(stateData.getStateNameById(union_info.region))
		content_4:setText(union_info.total_member)
		content_5:setText(union_info.total_npc_city)
		content_6:setText(union_info.power)
		content_7:setText(languagePack["lv"] .. union_info.level)
	end

	if self_or_not then
		name_txt:setColor(ccc3(255, 243, 195))
		content_2:setTouchEnabled(false)
	else
		name_txt:setColor(ccc3(194, 245, 187))
		content_2:addTouchEventListener(deal_with_name_click)
		content_2:setTouchEnabled(true)
	end
end

local function tableCellTouched(table,cell)
end

local function cellSizeForTable(table,idx)
    return 78, 1098
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/rankingCell.json")
	    new_widget:setTag(1)
	    local new_layer = TouchGroup:create()
	    new_layer:setTag(123)
	    new_layer:addWidget(new_widget)
	    cell = CCTableViewCell:new()
	    cell:addChild(new_layer)
	end
    
    local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local cell_widget = cell_layer:getWidgetByTag(1)
    show_cell_content(cell_widget, idx)

    return cell
end

local function numberOfCellsInTableView(table)
	if is_in_player_page() then
		return #player_order_list
	else
		return #union_order_list
	end
end

local function reload_data()
	show_content_tb:reloadData()
end

local function deal_with_des_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/ranking/rankingDesManager")
		--local errorIndx = 0
		if is_in_player_page() then
			rankingDesManager.create(1)
			--errorIndx = 173
		else
			rankingDesManager.create(2)
			--errorIndx = 174
		end

		--set_drag_state(false)
		--alertLayer.create(errorTable[errorIndx])
	end
end

local function deal_with_jump_finish()
	if m_pos_timer then
		scheduler.remove(m_pos_timer)
		m_pos_timer = nil
	end

	local self_order_index = nil
	if is_in_player_page() then
		self_order_index = player_self_index
	else
		self_order_index = union_self_index
	end

	local cell = show_content_tb:cellAtIndex(self_order_index)
	if cell then
		local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
	    local cell_widget = cell_layer:getWidgetByTag(1)
	    local self_img = tolua.cast(cell_widget:getChildByName("self_img"), "ImageView")
		local fade_out = CCFadeOut:create(0.2)
		local fade_in = CCFadeIn:create(0.2)
		local temp_seq = cc.Sequence:createWithTwoActions(fade_out, fade_in)
		self_img:runAction(CCRepeat:create(temp_seq, 2))
	end
end

local function gotoSelfPosition()
	if m_pos_timer then
		return
	end

	local self_order_index = nil
	if is_in_player_page() then
		self_order_index = player_self_index
	else
		self_order_index = union_self_index
	end

	if self_order_index == -1 then
		return
	end

	local init_offset_y = show_content_tb:getViewSize().height - show_content_tb:getContentSize().height
	local new_offset_y = nil
	if self_order_index <= 2 then
		new_offset_y = init_offset_y
	else
		new_offset_y = init_offset_y + (self_order_index - 2) * 78
		if new_offset_y < init_offset_y then
			new_offset_y = init_offset_y
		else
			if new_offset_y > 0 then
				new_offset_y = 0
			end
		end
	end
	
	--这个接口是后面加的，需要重新打包，未避免IOS审核不过加入条件判断
	if show_content_tb.stop_deaccelerate_scrolling then
		show_content_tb:stop_deaccelerate_scrolling()
	end
	show_content_tb:setContentOffsetInDuration(cc.p(0, new_offset_y), 0.5)

	if m_pos_timer then
		scheduler.remove(m_pos_timer)
		m_pos_timer = nil
	end
	m_pos_timer = scheduler.create(deal_with_jump_finish, 0.5)
end

local function set_self_img_content()
	local self_pos_img = tolua.cast(temp_widget:getChildByName("self_pos_img"), "ImageView")
	local first_txt = tolua.cast(self_pos_img:getChildByName("sign_label"), "Label")
	local second_txt = tolua.cast(self_pos_img:getChildByName("pos_label"), "Label")
	local is_show_second = true

	local temp_order_index = nil
	if is_in_player_page() then
		if m_is_in_player_list then
			first_txt:setText(languagePack["wodepaiming"])
			temp_order_index = player_self_index + 1
			second_txt:setText(temp_order_index)
		else
			first_txt:setText(languagePack['weishangbang'])
			is_show_second = false
		end
	else
		if m_is_in_union_list then
			first_txt:setText(languagePack["benmengpaiming"])
			temp_order_index = union_self_index + 1
			second_txt:setText(temp_order_index)
		else
			if userData.getUnion_id() == 0 then
				first_txt:setText(languagePack["jiarutongmeng"])
			else
				first_txt:setText(languagePack['weishangbang'])
			end
			is_show_second = false
		end
	end

	second_txt:setVisible(is_show_second)

	if is_show_second then
		first_txt:setPositionX(-37)
	else
		first_txt:setPositionX(0)
	end
end

local function deal_with_tab_changed(new_index)
	if last_selected_index == new_index then
		return
	end

	local temp_tab_con = tolua.cast(temp_widget:getChildByName("tab_con"), "Layout")
	local temp_select_page, temp_common_img, temp_select_img, temp_content_txt = nil, nil, nil 
	if last_selected_index ~= 0 then
		temp_select_page = tolua.cast(temp_tab_con:getChildByName("tab_" .. last_selected_index), "Layout")
		temp_common_img = tolua.cast(temp_select_page:getChildByName("common_img"), "ImageView")
		temp_select_img = tolua.cast(temp_select_page:getChildByName("selected_img"), "ImageView")
		temp_content_txt = tolua.cast(temp_select_page:getChildByName("content_label"), "Label")
		temp_content_txt:setColor(ccc3(109, 109, 109))
		temp_common_img:setVisible(true)
		temp_select_img:setVisible(false)
	end

	last_selected_index = new_index
	temp_select_page = tolua.cast(temp_tab_con:getChildByName("tab_" .. last_selected_index), "Layout")
	temp_common_img = tolua.cast(temp_select_page:getChildByName("common_img"), "ImageView")
	temp_select_img = tolua.cast(temp_select_page:getChildByName("selected_img"), "ImageView")
	temp_content_txt = tolua.cast(temp_select_page:getChildByName("content_label"), "Label")
	temp_content_txt:setColor(ccc3(191, 203, 203))
	temp_common_img:setVisible(false)
	temp_select_img:setVisible(true)

	local gr_content = tolua.cast(temp_widget:getChildByName("gr_title"), "Layout")
	local gr_sign_img = tolua.cast(gr_content:getChildByName("sign_img"), "ImageView")
	local tm_content = tolua.cast(temp_widget:getChildByName("tm_title"), "Layout")
	local tm_sign_img = tolua.cast(tm_content:getChildByName("sign_img"), "ImageView")
	if is_in_player_page() then
		gr_content:setVisible(true)
		tm_content:setVisible(false)
		gr_sign_img:setTouchEnabled(true)
		tm_sign_img:setTouchEnabled(false)
	else
		gr_content:setVisible(false)
		tm_content:setVisible(true)
		gr_sign_img:setTouchEnabled(false)
		tm_sign_img:setTouchEnabled(true)
	end

	reload_data()

	set_self_img_content()
end

local function deal_with_self_pos_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if is_in_player_page() then
			gotoSelfPosition()
		else
			if userData.getUnion_id() == 0 then
				do_remove_self()
				UnionUIJudge.create(0)
			else
				gotoSelfPosition()
			end
		end
	end
end

local function on_change_tab_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local new_index = tonumber(string.sub(sender:getName(),5))
		deal_with_tab_changed(new_index)
	end
end

local function create()
	last_selected_index = 0
	
	temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/rankingUI.json")
	temp_widget:setTag(999)
	m_backPanel = UIBackPanel.new()
	local all_widget = m_backPanel:create(temp_widget, remove_self, panelPropInfo[uiIndexDefine.RANKING_UI][2], false, true)
	ranking_layer = TouchGroup:create()
	ranking_layer:addWidget(all_widget)

	local self_pos_img = tolua.cast(temp_widget:getChildByName("self_pos_img"), "ImageView")
	self_pos_img:setTouchEnabled(true)
	self_pos_img:addTouchEventListener(deal_with_self_pos_click)

	local temp_tab_con = tolua.cast(temp_widget:getChildByName("tab_con"), "Layout")
	local temp_tab_btn, selected_sign_img = nil, nil
	for i=1,2 do
		temp_tab_btn = tolua.cast(temp_tab_con:getChildByName("tab_" .. i), "Layout")
		selected_sign_img = tolua.cast(temp_tab_btn:getChildByName("selected_img"), "ImageView")
		selected_sign_img:setVisible(false)
		temp_tab_btn:setTouchEnabled(true)
		temp_tab_btn:addTouchEventListener(on_change_tab_click)
	end

	local gr_content = tolua.cast(temp_widget:getChildByName("gr_title"), "Layout")
	local gr_sign_img = tolua.cast(gr_content:getChildByName("sign_img"), "ImageView")
	local tm_content = tolua.cast(temp_widget:getChildByName("tm_title"), "Layout")
	local tm_sign_img = tolua.cast(tm_content:getChildByName("sign_img"), "ImageView")
	gr_sign_img:addTouchEventListener(deal_with_des_click)
	tm_sign_img:addTouchEventListener(deal_with_des_click)

	local bg_img = tolua.cast(temp_widget:getChildByName("bg_img"), "ImageView")
	local content_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")
	UIListViewSize.definedUIpanel(temp_widget, bg_img, content_panel)
    
	show_content_tb = CCTableView:create(CCSizeMake(content_panel:getSize().width,content_panel:getSize().height))
	content_panel:addChild(show_content_tb)
	show_content_tb:setDirection(kCCScrollViewDirectionVertical)
	show_content_tb:setVerticalFillOrder(kCCTableViewFillTopDown)
    show_content_tb:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    show_content_tb:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    show_content_tb:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    show_content_tb:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    touch_response_area = show_content_tb:boundingBox()

    deal_with_tab_changed(1)

    uiManager.add_panel_to_layer(ranking_layer, uiIndexDefine.RANKING_UI)
    uiManager.showConfigEffect(uiIndexDefine.RANKING_UI, ranking_layer, nil, 999, {all_widget})
end

local function organize_player_list(packet)
	player_order_list = {}

	local self_order = packet[2]
	local self_data = packet[3]
	local all_list_num = packet[4]
	local order_data = packet[5]

	for k,v in pairs(order_data) do
		player_order_list[v[1] + 1] = v[2]
	end

	if self_order == -1 then
		if self_data == cjson.null then
			player_self_index = -1
		else
			player_order_list[all_list_num + 1] = self_data
			player_self_index = all_list_num
		end
	else
		player_self_index = self_order
		m_is_in_player_list = true
	end
end

local function organize_union_list(packet)
	union_order_list = {}

	local self_order = packet[2]
	local self_data = packet[3]
	local all_list_num = packet[4]
	local order_data = packet[5]

	for k,v in pairs(order_data) do
		union_order_list[v[1] + 1] = v[2]
	end

	if self_order == -1 then
		if self_data == cjson.null then
			union_self_index = -1
		else
			union_order_list[all_list_num + 1] = self_data
			union_self_index = all_list_num
		end
	else
		union_self_index = self_order
		m_is_in_union_list = true
	end

	create()
end

local function on_enter()
	if is_open_state then
		return
	end

	is_open_state = true
	m_is_in_player_list = false
	m_is_in_union_list = false

	require("game/ranking/rankingData")
    rankingData.create()
end

local function getInstance()
	return ranking_layer
end

rankingManager = {
				on_enter = on_enter,
				remove_self = remove_self,
				dealwithTouchEvent = dealwithTouchEvent,
				update_show_level = update_show_level,
				--set_drag_state = set_drag_state,
				organize_player_list = organize_player_list,
				organize_union_list = organize_union_list,
				getInstance = getInstance,
}
