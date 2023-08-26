local m_main_img = nil
local m_is_in_call_page = nil 		--是否在当前页面操作

local m_free_or_end_time_list = nil --出现免费或者消失的需要刷新的时间节点
local m_call_list = nil
local m_share_content = nil 		--记录当前打开的共享卡包组成的字符串

local m_update_list = nil 		--需要刷新的
local m_update_timer = nil

local m_high_star_list = nil 	--高星抽卡方式动画
local m_high_timer = nil

local m_select_id = nil 		--选中的抽卡ID
local m_select_type = nil 		--选中的抽卡类型

local ColorUtil = nil

local function set_show_state(new_state)
	m_main_img:setVisible(new_state)

	m_select_id = 0
	m_select_type = 0
	m_is_in_call_page = new_state
end

local function remove()
	cardCallData.record_share_package_see(m_share_content)
	m_free_or_end_time_list = nil
	m_call_list = nil
	m_share_content = nil

	m_select_id = nil
	m_select_type = nil

	ColorUtil = nil

	m_main_img = nil
end

local function stop_update_timer()
	if m_update_timer then
		scheduler.remove(m_update_timer)
		m_update_timer = nil
	end
	m_update_list = nil

	if m_high_timer then
		scheduler.remove(m_high_timer)
		m_high_timer = nil
	end
	m_high_star_list = nil

	UIUpdateManager.remove_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.add, cardCallListManager.dealWithListChange)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.update, cardCallListManager.dealWithListChange)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.remove, cardCallListManager.dealWithListChange)
    UIUpdateManager.remove_prop_update(dbTableDesList.sys_card_extract.name, dataChangeType.add, cardCallListManager.dealWithListChange)
    UIUpdateManager.remove_prop_update(dbTableDesList.sys_card_extract.name, dataChangeType.update, cardCallListManager.dealWithListChange)
    UIUpdateManager.remove_prop_update(dbTableDesList.sys_card_extract.name, dataChangeType.remove, cardCallListManager.dealWithListChange)
end

local function update_sv_state(new_state)
	local temp_sv = tolua.cast(m_main_img:getChildByName("content_sv"), "ScrollView")
	temp_sv:setTouchEnabled(new_state)
end

local function organize_content_layout(cell_content, temp_leave_state, temp_time_state)
	local three_pos_1, three_pos_2, three_pos_3 = -83, -113, -141
	local two_pos_1, two_pos_2 = -100, -130

	local leave_nums_txt = tolua.cast(cell_content:getChildByName("leave_label"), "Label")
	local cost_sign_img = tolua.cast(cell_content:getChildByName("sign_img"), "ImageView")
	local cost_txt = tolua.cast(cell_content:getChildByName("res_label"), "Label")
	local time_txt = tolua.cast(cell_content:getChildByName("time_label"), "Label")

	if temp_leave_state then
		if temp_time_state then
			leave_nums_txt:setPositionY(three_pos_1)
			cost_sign_img:setPositionY(three_pos_2 + 2)
			cost_txt:setPositionY(three_pos_2)
			time_txt:setPositionY(three_pos_3)
		else
			leave_nums_txt:setPositionY(two_pos_1)
			cost_sign_img:setPositionY(two_pos_2 + 2)
			cost_txt:setPositionY(two_pos_2)
		end
	else
		if temp_time_state then
			cost_sign_img:setPositionY(two_pos_1 + 1)
			cost_txt:setPositionY(two_pos_1)
			time_txt:setPositionY(two_pos_2)
		else
			cost_sign_img:setPositionY(three_pos_2 + 2)
			cost_txt:setPositionY(three_pos_2)
		end
	end
end

local function set_time_content_2(cell_content, temp_refresh_info, idx)
	local end_time = 0
	local show_time_content = languagePack["xiaoshidaoji"]
	local temp_sys_extract_info = cardCallData.get_sys_extract_card_info(temp_refresh_info.refresh_way_id)
	if temp_sys_extract_info then
		if temp_sys_extract_info.end_time ~= 0 then
			end_time = temp_sys_extract_info.end_time
			local temp_parent_id = temp_refresh_info.parent_extract_id
			if temp_parent_id ~= 0 then
				show_time_content = languagePack["hebingdaoji"] .. "[" .. Tb_cfg_card_extract[temp_parent_id].refresh_name .. "]"
			end
		end
	else
		if temp_refresh_info.end_time ~= "" then
			end_time = commonFunc.get_time_by_data(temp_refresh_info.end_time)
		end
	end

	if end_time == 0 then
		return false
	end
	
	local show_time_nums = end_time - userData.getServerTime()
	local time_txt = tolua.cast(cell_content:getChildByName("time_label"), "Label")
	time_txt:setText(commonFunc.format_time(show_time_nums) .. show_time_content)
	time_txt:setVisible(true)

	table.insert(m_update_list, {idx, show_time_nums, show_time_content})

	return true
end

local function set_txt_color_by_star(temp_txt, temp_refresh_info)
	temp_txt:setColor(ColorUtil.getHeroColor(temp_refresh_info.color_type))
end

local function set_leave_num_txt(cell_content, is_daily_type, used_num, all_num, temp_refresh_info)
	local leave_nums_txt = tolua.cast(cell_content:getChildByName("leave_label"), "Label")
	local leave_num = all_num - used_num
	if is_daily_type then
		leave_nums_txt:setText(languagePack["dailycishu"] .. " " .. leave_num .. "/" .. all_num)
	else
		leave_nums_txt:setText(languagePack["shengyucishu"] .. " " .. leave_num .. "/" .. all_num)
	end
	set_txt_color_by_star(leave_nums_txt, temp_refresh_info)
	leave_nums_txt:setVisible(true)
end

local function set_bg_show_info(cell_content, temp_refresh_info, is_show_star)
	local temp_name_img = tolua.cast(cell_content:getChildByName("name_img"), "ImageView")
	local name_pic = temp_refresh_info.name_img .. ".png"
	temp_name_img:loadTexture(name_pic, UI_TEX_TYPE_PLIST)

	local icon_img = tolua.cast(cell_content:getChildByName("icon_img"), "ImageView")
	local hero_cfg_id = temp_refresh_info.img_hero_id
	local res_img_name = "gameResources/card/card_" .. hero_cfg_id .. ".png"
	icon_img:loadTexture(res_img_name, UI_TEX_TYPE_LOCAL)
	cardTextureManager.add_new_card_file(res_img_name)
	if Tb_cfg_hero_rect[hero_cfg_id] then
		local show_rect_info = Tb_cfg_hero_rect[hero_cfg_id][3]
		if type(show_rect_info) == "table" then
			icon_img:setTextureRect(CCRectMake(show_rect_info[1], show_rect_info[2], show_rect_info[3], show_rect_info[4]))
			icon_img:setScale(show_rect_info[5])
		else
			icon_img:setTextureRect(CCRectMake(0,0,193,452))
			icon_img:setScale(1)
		end
	else
		icon_img:setTextureRect(CCRectMake(0,0,193,452))
		icon_img:setScale(1)
	end

	if is_show_star then
		if #temp_refresh_info.refresh_word == 2 then
			local star_img = tolua.cast(cell_content:getChildByName("star_img"), "ImageView")
			local star_txt = tolua.cast(star_img:getChildByName("star_label"), "Label")
			local max_star_num = temp_refresh_info.refresh_word[2]
			set_txt_color_by_star(star_txt, temp_refresh_info)

			local temp_content = temp_refresh_info.refresh_word[1] .. "-" .. temp_refresh_info.refresh_word[2] .. languagePack["heroCardLvName"]
			local temp_level = cardCallData.get_extract_card_level(temp_refresh_info.refresh_way_id)
			if temp_level ~= 1 then
				temp_content = temp_content .. "(" .. temp_level .. languagePack['ji'] .. ")"
			end
			
			star_txt:setText(temp_content)
			star_img:setVisible(true)
		end
	end
end

local function set_cost_txt_content(cost_sign_img, cost_txt, show_content, is_need_sign)
	cost_txt:ignoreAnchorPointForPosition(false)
	cost_txt:setText(show_content)

	if is_need_sign then
		cost_txt:setAnchorPoint(cc.p(0, 0.5))
		cost_txt:setTextHorizontalAlignment(kCCTextAlignmentLeft)

		local temp_sign_width = cost_sign_img:getContentSize().width
		local temp_txt_width = cost_txt:getContentSize().width
		local show_pos_x = temp_sign_width + (196 - (temp_sign_width + temp_txt_width))/2 - 196/2
		cost_sign_img:setPositionX(show_pos_x)
		cost_txt:setPositionX(show_pos_x)
	else
		cost_txt:setAnchorPoint(cc.p(0.5,0.5))
		cost_txt:setPositionX(5)
		cost_txt:setTextHorizontalAlignment(kCCTextAlignmentCenter)
	end
	
	cost_txt:setVisible(true)
end

local function set_time_content_1(cell_content, temp_extract_data, temp_refresh_info, idx) 
	local is_show_time, time_nums, time_type_content = nil, nil, nil
	if temp_extract_data.end_time == 0 then
		if temp_refresh_info.free_interval_cd == 0 then
			is_show_time = false
		else
			local leave_time_num = 0
			if temp_extract_data.free_time == 0 then
				leave_time_num = temp_refresh_info.free_interval_cd - (userData.getServerTime() - temp_extract_data.got_time)
			else
				leave_time_num = temp_refresh_info.free_interval_cd - (userData.getServerTime() - temp_extract_data.free_time)
			end
			
			if leave_time_num <= 0 then
				is_show_time = false
			else
				if temp_refresh_info.free_count == 0 then
					is_show_time = true
					time_nums = leave_time_num
					time_type_content = languagePack["xiacimianfei"]
				else
					if temp_refresh_info.free_count - temp_extract_data.used_count_free > 0 then
						is_show_time = false
					else
						is_show_time = true
						time_nums = leave_time_num
						time_type_content = languagePack["xiacimianfei"]
					end
				end
			end
		end
	else
		is_show_time = true
		time_nums = temp_extract_data.end_time - userData.getServerTime()
		time_type_content = languagePack["xiaoshidaoji"]

		local temp_sys_extract_info = cardCallData.get_sys_extract_card_info(temp_refresh_info.refresh_way_id)
		if temp_sys_extract_info then
			local temp_parent_id = temp_refresh_info.parent_extract_id
			if temp_parent_id ~= 0 then
				time_type_content = languagePack["hebingdaoji"] .. "[" .. Tb_cfg_card_extract[temp_parent_id].refresh_name .. "]"
			end
		end
	end

	if is_show_time then
		local time_txt = tolua.cast(cell_content:getChildByName("time_label"), "Label")
		time_txt:setText(commonFunc.format_time(time_nums) .. time_type_content)
		time_txt:setVisible(true)

		table.insert(m_update_list, {idx, time_nums, time_type_content})
	end

	return is_show_time
end

local function set_corner_state(spe_sign_panel, is_unopen, temp_refresh_info)
	local unopen_img = tolua.cast(spe_sign_panel:getChildByName("tips_sign_img"), "ImageView")
	local lv_img = tolua.cast(spe_sign_panel:getChildByName("lv_img"), "ImageView")
	local ex_img = tolua.cast(spe_sign_panel:getChildByName("ex_img"), "ImageView")
	unopen_img:setVisible(false)
	lv_img:setVisible(false)
	ex_img:setVisible(false)

	if is_unopen then
		unopen_img:setVisible(true)
		spe_sign_panel:setVisible(true)
	else
		if temp_refresh_info.parent_extract_id == 0 then
			local temp_level = cardCallData.get_extract_card_level(temp_refresh_info.refresh_way_id)
			if temp_level ~= 1 then
				local lv_label_atlas = tolua.cast(lv_img:getChildByName("lv_label_atlas"), "LabelAtlas")
				lv_label_atlas:setStringValue(temp_level)
				lv_img:setVisible(true)
				spe_sign_panel:setVisible(true)
			end
		else
			ex_img:setVisible(true)
			spe_sign_panel:setVisible(true)
		end
	end 

	spe_sign_panel:setVisible(true)
end

local function show_cell_content_1(cell_widget, idx)
	local temp_call_info = m_call_list[idx]
	local temp_extract_uid = temp_call_info[1]
	local temp_extract_data = cardCallData.get_extract_card_info(temp_extract_uid)
	local temp_refresh_info = Tb_cfg_card_extract[temp_extract_data.refresh_way_id]
	local temp_leave_state, temp_time_state = false, false

	if temp_refresh_info.animate == 1 then
		table.insert(m_high_star_list, idx)
	end

	local cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")

	local spe_sign_panel = tolua.cast(cell_content:getChildByName("spe_sign_panel"), "Layout")
	set_corner_state(spe_sign_panel, false, temp_refresh_info)

	if temp_refresh_info.total_count == 0 then
		if temp_refresh_info.daily_count ~= 0 then
			set_leave_num_txt(cell_content, true, temp_extract_data.used_count_daily, temp_refresh_info.daily_count, temp_refresh_info)
			temp_leave_state = true
		end
	else
		set_leave_num_txt(cell_content, false, temp_extract_data.used_count_total, temp_refresh_info.total_count, temp_refresh_info)
		temp_leave_state = true
	end

	local cost_sign_img = tolua.cast(cell_content:getChildByName("sign_img"), "ImageView")
	local cost_txt = tolua.cast(cell_content:getChildByName("res_label"), "Label")
	local leave_free_num, all_free_num = cardCallData.get_free_nums_for_uid(temp_extract_uid, userData.getServerTime())

	if temp_extract_data.is_new == 1 or leave_free_num > 0 then
		local new_sign_img = tolua.cast(cell_content:getChildByName("new_sign_img"), "ImageView")
		new_sign_img:setVisible(true)
	end

	if leave_free_num > 0 then
		set_txt_color_by_star(cost_txt, temp_refresh_info)
		--cost_txt:setColor(ccc3(240, 197, 91))
		set_cost_txt_content(cost_sign_img, cost_txt, languagePack["mianfeicishu"] .. " " .. leave_free_num .. "/" .. all_free_num, false)
	else
		local cost_type = temp_refresh_info.refresh_cost[1][1]
		cost_sign_img:loadTexture(cardCallData.get_call_res_icon(cost_type), UI_TEX_TYPE_PLIST)
		cost_sign_img:setVisible(true)
		local half_state = (temp_extract_data.half_price == 1)
		local need_num = temp_refresh_info.refresh_cost[1][2]
		if half_state then
			need_num = need_num/2
		end
		local own_num = cardCallData.get_call_res_nums(cost_type)
		if own_num >= need_num then
			--cost_txt:setColor(ccc3(240, 197, 91))
			set_txt_color_by_star(cost_txt, temp_refresh_info)
		else
			cost_txt:setColor(ccc3(255, 0, 0))
		end
		local temp_show_content = cardCallData.get_call_res_name(cost_type) .. need_num
		if half_state then
			temp_show_content = temp_show_content .. languagePack["half_price"]
		end
		set_cost_txt_content(cost_sign_img, cost_txt, temp_show_content, true)
	end

	set_bg_show_info(cell_content, temp_refresh_info, true)

	temp_time_state = set_time_content_1(cell_content, temp_extract_data, temp_refresh_info, idx)

	organize_content_layout(cell_content, temp_leave_state, temp_time_state)
end

local function show_cell_content_2(cell_widget, idx)
	local temp_call_info = m_call_list[idx]
	local temp_extract_cfg_id = temp_call_info[1]
	local temp_refresh_info = Tb_cfg_card_extract[temp_extract_cfg_id]
	local temp_leave_state = false

	if temp_refresh_info.animate == 1 then
		table.insert(m_high_star_list, idx)
	end

	local cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")

	local spe_sign_panel = tolua.cast(cell_content:getChildByName("spe_sign_panel"), "Layout")
	set_corner_state(spe_sign_panel, false, temp_refresh_info)

	if temp_refresh_info.total_count == 0 then
		if temp_refresh_info.daily_count ~= 0 then
			set_leave_num_txt(cell_content, true, 0, temp_refresh_info.daily_count, temp_refresh_info)
			temp_leave_state = true
		end
	else
		set_leave_num_txt(cell_content, false, 0, temp_refresh_info.total_count, temp_refresh_info)
		temp_leave_state = true	
	end

	local cost_sign_img = tolua.cast(cell_content:getChildByName("sign_img"), "ImageView")
	local cost_txt = tolua.cast(cell_content:getChildByName("res_label"), "Label")
	local leave_free_num, all_free_num = cardCallData.get_free_nums_for_cfg_id(temp_extract_cfg_id)
	if leave_free_num > 0 then
		set_txt_color_by_star(cost_txt, temp_refresh_info)
		--cost_txt:setColor(ccc3(240, 197, 91))
		set_cost_txt_content(cost_sign_img, cost_txt, languagePack["mianfeicishu"] .. " " .. leave_free_num .. "/" .. all_free_num, false)
	else
		local cost_type = temp_refresh_info.refresh_cost[1][1]
		cost_sign_img:loadTexture(cardCallData.get_call_res_icon(cost_type), UI_TEX_TYPE_PLIST)
		cost_sign_img:setVisible(true)
		local need_num = temp_refresh_info.refresh_cost[1][2]
		local own_num = cardCallData.get_call_res_nums(cost_type)
		if own_num >= need_num then
			--cost_txt:setColor(ccc3(240, 197, 91))
			set_txt_color_by_star(cost_txt, temp_refresh_info)
		else
			cost_txt:setColor(ccc3(255, 0, 0))
		end
		set_cost_txt_content(cost_sign_img, cost_txt, cardCallData.get_call_res_name(cost_type) .. need_num, true)
	end

	local new_sign_img = tolua.cast(cell_content:getChildByName("new_sign_img"), "ImageView")
	if leave_free_num > 0 then
		new_sign_img:setVisible(true)
	else
		if not cardCallData.get_share_package_see_state(temp_extract_cfg_id) then
			new_sign_img:setVisible(true)
		end
	end

	set_bg_show_info(cell_content, temp_refresh_info, true)

	local temp_time_state = set_time_content_2(cell_content, temp_refresh_info, idx)
	organize_content_layout(cell_content, temp_leave_state, temp_time_state)
end

local function show_cell_content_3(cell_widget, idx)
	local temp_call_info = m_call_list[idx]
	local temp_extract_uid = temp_call_info[1]
	local temp_extract_data = cardCallData.get_extract_card_info(temp_extract_uid)
	local temp_refresh_info = Tb_cfg_card_extract[temp_extract_data.refresh_way_id]
	local temp_leave_state, temp_time_state = false, false

	local cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")

	local spe_sign_panel = tolua.cast(cell_content:getChildByName("spe_sign_panel"), "Layout")
	set_corner_state(spe_sign_panel, false, temp_refresh_info)

	local cost_txt = tolua.cast(cell_content:getChildByName("res_label"), "Label")
	cost_txt:setColor(ccc3(255, 0, 0))
	set_cost_txt_content(nil, cost_txt, languagePack["dailycishu"] .. " 0/" .. temp_refresh_info.daily_count, false)

	local time_txt = tolua.cast(cell_content:getChildByName("time_label"), "Label")
	time_txt:setText(languagePack["daily_reset"])
	time_txt:setVisible(true)
	
	set_bg_show_info(cell_content, temp_refresh_info, true)

	--local unused_sign = tolua.cast(cell_content:getChildByName("unused_panel"), "Layout")
	--unused_sign:setVisible(true)

	--GraySprite.create(cell_content, {"res_label", "star_label"})

	organize_content_layout(cell_content, false, true)
end

local function show_cell_content_4(cell_widget, idx)
	local temp_call_info = m_call_list[idx]
	local temp_extract_cfg_id = temp_call_info[1]
	local temp_refresh_info = Tb_cfg_card_extract[temp_extract_cfg_id]

	local cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")

	local spe_sign_panel = tolua.cast(cell_content:getChildByName("spe_sign_panel"), "Layout")
	set_corner_state(spe_sign_panel, true, temp_refresh_info)

	local cost_txt = tolua.cast(cell_content:getChildByName("res_label"), "Label")
	cost_txt:setColor(ccc3(255, 0, 0))
	set_cost_txt_content(nil, cost_txt, temp_refresh_info.condition_name, false)

	set_bg_show_info(cell_content, temp_refresh_info, true)

	local unused_sign = tolua.cast(cell_content:getChildByName("unused_panel"), "Layout")
	unused_sign:setVisible(true)

	GraySprite.create(cell_content, {"res_label", "tips_sign_img", "star_label"})

	organize_content_layout(cell_content, false, false)
end

local function update_call_back()
	if not m_is_in_call_page then
		return
	end

	local cell_widget, cell_content, time_txt = nil, nil, nil
	for k,v in pairs(m_update_list) do
		cell_widget = cardCallAnimManager.get_cell_by_index(v[1])
		cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")
		time_txt = tolua.cast(cell_content:getChildByName("time_label"), "Label")
		v[2] = v[2] - 1
		if v[2] < 0 then
			v[2] = 0
		end

		time_txt:setText(commonFunc.format_time(v[2]) .. v[3])
	end

	if #m_free_or_end_time_list ~= 0 then
		if userData.getServerTime() > m_free_or_end_time_list[1] then
			cardCallListManager.reload_new_data()
		end
	end
end

local function update_high_anim()
	if #m_high_star_list == 0 then
		return
	end

	local move_by = CCMoveBy:create(1.5, ccp(0, -785))

	local cell_widget, cell_content, high_star_area_panel, high_star_sign_img = nil, nil, nil, nil
	for k,v in pairs(m_high_star_list) do
		cell_widget = cardCallAnimManager.get_cell_by_index(v)
		cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")
		high_star_area_panel = tolua.cast(cell_content:getChildByName("high_star_area_panel"), "Layout")
		high_star_sign_img = tolua.cast(high_star_area_panel:getChildByName("content_img"), "ImageView")
		high_star_sign_img:setPositionY(620)
		high_star_sign_img:runAction(tolua.cast(move_by:copy():autorelease(), "CCActionInterval"))
		high_star_area_panel:setVisible(true)
	end
end

local function deal_with_call_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		newGuideInfo.enter_next_guide()
		
		local show_index = tonumber(string.sub(sender:getName(), 5))
		if m_select_type == cardCallType.share then
			if cardOpRequest.judge_call_card_condition(m_select_id, 0, show_index-1) then
				cardOpRequest.request_call_card(m_select_id, 0, show_index-1)
			end
		else
			local temp_extract_data = cardCallData.get_extract_card_info(m_select_id)
			if cardOpRequest.judge_call_card_condition(temp_extract_data.refresh_way_id, m_select_id, show_index-1) then
				cardOpRequest.request_call_card(temp_extract_data.refresh_way_id, m_select_id, show_index-1)
			end
		end
	end
end

local function deal_with_ex_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_refresh_info = nil
		if m_select_type == cardCallType.share then
			temp_refresh_info = Tb_cfg_card_extract[m_select_id]
		else
			local temp_extract_data = cardCallData.get_extract_card_info(m_select_id)
			temp_refresh_info = Tb_cfg_card_extract[temp_extract_data.refresh_way_id]
		end

		local parent_name = "[" .. Tb_cfg_card_extract[temp_refresh_info.parent_extract_id].refresh_name .. "]"
		--local parent_name = "【" .. Tb_cfg_card_extract[1052].refresh_name .. "】"
		alertLayer.create(errorTable[507], {parent_name})
	end
end

local function organize_call_type_info(cell_widget)
	local temp_call_img = tolua.cast(cell_widget:getChildByName("call_img"), "ImageView")
	local baodi_panel = tolua.cast(temp_call_img:getChildByName("baodi_panel"), "Layout")
	local btn_1 = tolua.cast(temp_call_img:getChildByName("btn_1"), "Button")
	local btn_2 = tolua.cast(temp_call_img:getChildByName("btn_2"), "Button")
	callWayManager.set_baodi_show_content(m_select_id, m_select_type, baodi_panel)
	callWayManager.set_way_show_content(m_select_id, m_select_type, btn_1, btn_2, 1)

	local temp_refresh_info = nil
	if m_select_type == cardCallType.share then
		temp_refresh_info = Tb_cfg_card_extract[m_select_id]
	elseif m_select_type == cardCallType.actived then
		local temp_extract_data = cardCallData.get_extract_card_info(m_select_id)
		temp_refresh_info = Tb_cfg_card_extract[temp_extract_data.refresh_way_id]
	end

	local ex_btn = tolua.cast(temp_call_img:getChildByName("ex_btn"), "Button")
	local temp_not_ex_state = (temp_refresh_info.parent_extract_id == 0)
	ex_btn:setTouchEnabled(not temp_not_ex_state)
	ex_btn:setVisible(not temp_not_ex_state)

	if temp_not_ex_state then
		baodi_panel:setPositionY(120)
	else
		if baodi_panel:isVisible() then
			local temp_offset = 24
			baodi_panel:setPositionY(120 - 24)
			if btn_2:isVisible() then
				btn_1:setPositionY(btn_1:getPositionY() - temp_offset)
			end
			--btn_2:setPositionY(btn_2:getPositionY() - temp_offset)
		end
	end
end

--选中单元格子时的判断，如果选中卡牌列表按钮部分则打开卡牌列表
--未开放的单元格子点击无效，其他的打开招募部分列表
local function deal_with_cell_click(sender, eventType)
	--TOUCH_EVENT_BEGAN,
    --TOUCH_EVENT_MOVED,
    --TOUCH_EVENT_ENDED,
    --TOUCH_EVENT_CANCELED
	if eventType == TOUCH_EVENT_ENDED then
		if cardCallAnimManager.get_anim_state() then
			return
		end

		local show_index = tonumber(string.sub(sender:getName(), 6))
		local temp_call_id = m_call_list[show_index][1]
		local temp_call_type = m_call_list[show_index][2]
		local cell_widget = cardCallAnimManager.get_cell_by_index(show_index)
		local cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")
		local card_list_img = tolua.cast(cell_content:getChildByName("list_com_img"), "ImageView")
		if card_list_img:hitTest(uiManager.getLastPoint()) then
			if newGuideManager.get_guide_state() then
				return
			end
			require("game/cardDisplay/cardPacketManager")
			local temp_call_cfg_id = nil
			if temp_call_type == cardCallType.actived or temp_call_type == cardCallType.no_daily then
				local temp_extract_data = cardCallData.get_extract_card_info(temp_call_id)
				temp_call_cfg_id = temp_extract_data.refresh_way_id
			else
				temp_call_cfg_id = temp_call_id
			end
			cardPacketManager.enter_packet_overview(temp_call_cfg_id)
			--update_sv_state(false)
		else
			if m_select_id == temp_call_id and m_select_type == temp_call_type then
				return
			end

			if temp_call_type == cardCallType.no_daily then
				tipsLayer.create(errorTable[230])
				return
			elseif temp_call_type == cardCallType.unopen then
				return
			end

			m_select_id = temp_call_id
			m_select_type = temp_call_type

			newGuideInfo.enter_next_guide()
			local temp_sv = tolua.cast(m_main_img:getChildByName("content_sv"), "ScrollView")
			cardCallAnimManager.play_extrace_way_anim(temp_sv, show_index)
			organize_call_type_info(cell_widget)
		end
	end
end

local function stop_refresh_type_anim()
	cardCallAnimManager.set_new_anim_state(false)
end

local function play_new_get_anim()
	cardCallAnimManager.set_new_anim_state(true)

	local cell_widget, cell_content, new_light_img = nil, nil, nil
	local is_need_anim = nil
	local temp_index, temp_need_time = 1, 0.5
	local scale_to_1 = CCScaleTo:create(temp_need_time/2, 1.01)
	local scale_to_2 = CCScaleTo:create(temp_need_time/2, 1)
	local scale_seq = cc.Sequence:createWithTwoActions(scale_to_1, scale_to_2)
	for k,v in pairs(m_call_list) do
		is_need_anim = false
	    if v[2] == cardCallType.share then
			if not cardCallData.get_share_package_see_state(v[1]) then
				is_need_anim = true
			end
		elseif v[2] == cardCallType.actived then
			local temp_extract_data = cardCallData.get_extract_card_info(v[1])
			if temp_extract_data.is_new == 1 then
				is_need_anim = true
			end
		end

		if is_need_anim then
			cell_widget = cardCallAnimManager.get_cell_by_index(k)
			cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")
			new_light_img = tolua.cast(cell_content:getChildByName("new_light_img"), "ImageView")

			new_light_img:setVisible(true)
			breathAnimUtil.start_anim(new_light_img, false, 0, 128, temp_need_time, 1)
			if temp_index == 1 then
				local fun_call = cc.CallFunc:create(stop_refresh_type_anim)
				local temp_seq = cc.Sequence:createWithTwoActions(scale_seq, fun_call)
				cell_widget:runAction(temp_seq)
			else
				cell_widget:runAction(tolua.cast(scale_seq:copy():autorelease(), "CCActionInterval"))
			end

			temp_index = temp_index + 1
		end
	end
end

--重新获取抽卡列表时获取旧有的的选中方式在新列表中的位置
local function get_select_index()
	if m_select_id == 0 then
		return 0
	end

	local result_index = 0
	for k,v in pairs(m_call_list) do
		if v[1] == m_select_id and v[2] == m_select_type then
			result_index = k
			break
		end
	end

	if result_index == 0 then
		m_select_id = 0
		m_select_type = 0
	end

	return result_index
end

local function organize_call_list_info()
	m_update_list = {}
	m_high_star_list = {}
	for k,v in pairs(m_call_list) do
		local cell_widget = cardCallAnimManager.get_cell_by_index(k)
		cell_widget:setTouchEnabled(true)
	    if v[2] == cardCallType.share then
	    	show_cell_content_2(cell_widget, k)
		elseif v[2] == cardCallType.actived then
			show_cell_content_1(cell_widget, k)
		elseif v[2] == cardCallType.no_daily then
			show_cell_content_3(cell_widget, k)
		elseif v[2] == cardCallType.unopen then
			show_cell_content_4(cell_widget, k)
		end
	end

	if m_update_timer then
		scheduler.remove(m_update_timer)
		m_update_timer = nil
	end
	m_update_timer = scheduler.create(update_call_back, 1)

	if m_high_timer then
		scheduler.remove(m_high_timer)
		m_high_timer = nil
	end
	m_high_timer = scheduler.create(update_high_anim, 3.5)
end

--该函数重新加载所有数据
local function reload_new_data()
	if not m_is_in_call_page then
		return
	end

	m_free_or_end_time_list, m_call_list, m_share_content = cardCallData.get_card_call_list()
	local temp_select_index = get_select_index()
	cardCallAnimManager.set_cell_list_related_info(temp_select_index, #m_call_list)

	local temp_sv = tolua.cast(m_main_img:getChildByName("content_sv"), "ScrollView")
	cardCallAnimManager.reset_list_layout_info(temp_sv, deal_with_cell_click, deal_with_call_click, deal_with_ex_click)

	organize_call_list_info()

	if m_select_id ~= 0 then
		local cell_widget = cardCallAnimManager.get_cell_by_index(temp_select_index)
		organize_call_type_info(cell_widget)
	end

	local left_img = tolua.cast(m_main_img:getChildByName("left_img"), "ImageView")
	left_img:setVisible(false)
	local right_img = tolua.cast(m_main_img:getChildByName("right_img"), "ImageView")
	if #m_call_list > 5 then
		right_img:setVisible(true)
	else
		right_img:setVisible(false)
	end
end

--[[
local function reload_current_data()
	if not m_is_in_call_page then
		return
	end

	organize_call_list_info()
	
	if m_select_id ~= 0 then
		local temp_select_index = get_select_index()
		local cell_widget = cardCallAnimManager.get_cell_by_index(temp_select_index)
		organize_call_type_info(cell_widget)
	end
end
--]]

local function return_to_call_state()
	set_show_state(true)

	reload_new_data()
end

local function deal_with_scroll_event(sender, eventType)
    if eventType == SCROLLVIEW_EVENT_SCROLLING then
    	if cardCallAnimManager.get_anim_state() then
    		return
    	end

    	if newGuideManager.get_guide_state() then
    		return
    	end

    	local left_img = tolua.cast(m_main_img:getChildByName("left_img"), "ImageView")
    	left_img:setVisible(true)
	    local right_img = tolua.cast(m_main_img:getChildByName("right_img"), "ImageView")
	    right_img:setVisible(true)

    	if m_select_id == 0 then
    		return
    	end

    	local temp_sv = tolua.cast(m_main_img:getChildByName("content_sv"), "ScrollView")
    	cardCallAnimManager.clear_selected_state(temp_sv)

    	m_select_id = 0
    	m_select_type = 0
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_LEFT then
    	local left_img = tolua.cast(m_main_img:getChildByName("left_img"), "ImageView")
		left_img:setVisible(false)
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_RIGHT then
    	local right_img = tolua.cast(m_main_img:getChildByName("right_img"), "ImageView")
    	right_img:setVisible(false)
    end
end

local function create(con_img)
	m_main_img = con_img
	m_select_id = 0
	m_select_type = 0
	m_is_in_call_page = true

	ColorUtil = require("game/utils/color_util")

	local temp_sv = tolua.cast(m_main_img:getChildByName("content_sv"), "ScrollView")
	temp_sv:addEventListenerScrollView(deal_with_scroll_event)

	local left_img = tolua.cast(m_main_img:getChildByName("left_img"), "ImageView")
	local right_img = tolua.cast(m_main_img:getChildByName("right_img"), "ImageView")
	breathAnimUtil.start_scroll_dir_anim(left_img, right_img)

    reload_new_data()
    
    UIUpdateManager.add_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.add, cardCallListManager.dealWithListChange)
    UIUpdateManager.add_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.update, cardCallListManager.dealWithListChange)
    UIUpdateManager.add_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.remove, cardCallListManager.dealWithListChange)

    UIUpdateManager.add_prop_update(dbTableDesList.sys_card_extract.name, dataChangeType.add, cardCallListManager.dealWithListChange)
    UIUpdateManager.add_prop_update(dbTableDesList.sys_card_extract.name, dataChangeType.update, cardCallListManager.dealWithListChange)
    UIUpdateManager.add_prop_update(dbTableDesList.sys_card_extract.name, dataChangeType.remove, cardCallListManager.dealWithListChange)

    if newGuideManager.get_guide_state() then
    	temp_sv:setBounceEnabled(false)
    end
end

local function dealWithListChange(packet)
	reload_new_data()
end

cardCallListManager = {
						create = create,
						remove = remove,
						stop_update_timer = stop_update_timer,
						set_show_state = set_show_state,
						return_to_call_state = return_to_call_state,
						--reload_current_data = reload_current_data,
						reload_new_data = reload_new_data,
						play_new_get_anim = play_new_get_anim,
						dealWithListChange = dealWithListChange
}