local m_main_widget = nil
local m_army_index_pos = nil 		--下方用来表示部队选中索引的坐标相关部分

local function remove()
	--[[
	local left_btn = tolua.cast(m_main_widget:getChildByName("left_btn"), "Button")
	breathAnimUtil.stop_all_anim(left_btn)
	local right_btn = tolua.cast(m_main_widget:getChildByName("right_btn"), "Button")
	breathAnimUtil.stop_all_anim(right_btn)
	--]]

	m_army_index_pos = nil
	m_main_widget = nil
end

local function init_army_index_pos()
	m_army_index_pos = {}
	m_army_index_pos[1] = {49}
	m_army_index_pos[2] = {40, 60}
	m_army_index_pos[3] = {30, 49, 68}
	m_army_index_pos[4] = {20, 40, 60, 80}
	m_army_index_pos[5] = {11, 30, 49, 68, 87}
end

local function deal_with_hzb_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/army/armyAdditionManager")
		armyAdditionManager.enter_addition_by_army(armyWholeManager.get_army_id())
	end
end

local function deal_with_left_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		armyWholeManager.deal_with_index_change(false)
	end
end

local function deal_with_right_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		armyWholeManager.deal_with_index_change(true)
	end
end

local function deal_with_return_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		armyWholeManager.deal_with_return_event()
	end
end

local function deal_with_zb_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_army_id = armyWholeManager.get_army_id()
		local new_state = armyData.getTeamZbBtnState(temp_army_id)
		if new_state == 0 then
			newGuideInfo.enter_next_guide()
			cardAddSoldier.on_enter(temp_army_id)
		elseif new_state == 1 then
			tipsLayer.create(errorTable[213])
		elseif new_state == 2 then
			tipsLayer.create(errorTable[196])
		elseif new_state == 3 then
			tipsLayer.create(errorTable[187])
		end	
	end
end

local function deal_with_set_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		armyWholeManager.deal_with_enter_set()
	end
end

local function deal_with_change_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/army/armyExchange/armyExchangeManager")
		local own_city_id = math.floor(armyWholeManager.get_army_id()/10)
		armyExchangeManager.on_enter(own_city_id)
	end
end

local function set_title_content(temp_city_id, temp_army_index)
	local temp_army_id = armyWholeManager.get_army_id()

	local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")
	local title_img = tolua.cast(title_panel:getChildByName("title_img"), "ImageView")
	local city_name_txt = tolua.cast(title_img:getChildByName("city_name_label"), "Label")
	local show_city_name = landData.get_city_name_lv_by_coordinate(temp_city_id)
	local show_city_type = landData.get_land_displayName(temp_city_id, landData.get_city_type_by_id(temp_city_id))
	city_name_txt:setText(show_city_name .. "-" .. show_city_type)
	local army_name_txt = tolua.cast(title_img:getChildByName("army_name_label"), "Label")
	army_name_txt:setText(languagePack["budui"] .. numOrderList[temp_army_index])
	army_name_txt:setPositionX(city_name_txt:getPositionX() + city_name_txt:getContentSize().width + 5)
	title_img:setSize(CCSize(army_name_txt:getPositionX() + army_name_txt:getContentSize().width + 15, 40))
end

local function set_hzb_content()
	local temp_army_id = armyWholeManager.get_army_id()
	local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")

	local hzb_btn = tolua.cast(title_panel:getChildByName("hzb_btn"), "Button")
	local hao_img = tolua.cast(hzb_btn:getChildByName("h_light_img"), "ImageView")
	local zhen_img = tolua.cast(hzb_btn:getChildByName("z_light_img"), "ImageView")
	local bing_img = tolua.cast(hzb_btn:getChildByName("b_light_img"), "ImageView")

	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	local arms_state, camp_type, group_state = false, 0, false
	if temp_army_info then
		arms_state, camp_type, group_state = armySpecialData.get_addition_state_by_team(temp_army_id)
	end

	hzb_btn:loadTextures(ResDefineUtil.army_title_res[camp_type][1], ResDefineUtil.army_title_res[camp_type][2], "", UI_TEX_TYPE_PLIST)
	if arms_state then
		bing_img:loadTexture(ResDefineUtil.army_title_res[camp_type][5], UI_TEX_TYPE_PLIST)
	end
	if group_state then
		hao_img:loadTexture(ResDefineUtil.army_title_res[camp_type][4], UI_TEX_TYPE_PLIST)
	end

	if camp_type == 0 then
		zhen_img:setVisible(false)
	else
		zhen_img:loadTexture(ResDefineUtil.army_title_res[camp_type][3], UI_TEX_TYPE_PLIST)
		zhen_img:setVisible(true)
	end

	hao_img:setVisible(group_state)
	bing_img:setVisible(arms_state)

	local cost_txt = tolua.cast(hzb_btn:getChildByName("cost_num_label"), "Label")
	cost_txt:setText(armyData.getTeamCost(temp_army_id) .. "/" .. userCityData.getCityCostNums(math.floor(temp_army_id/10)))

	local soldier_img = tolua.cast(title_panel:getChildByName("soldier_img"), "ImageView")
	local speed_img = tolua.cast(title_panel:getChildByName("speed_img"), "ImageView")
	local destroy_img = tolua.cast(title_panel:getChildByName("destroy_img"), "ImageView")
	local hero_min_speed, temp_army_speed = armyData.getTeamSpeed(temp_army_id)
	local temp_army_hp = armyData.getTeamHp(temp_army_id)
	local temp_army_destroy = armyData.getTeamDestroy(temp_army_id)
	if temp_army_destroy == 0 then
		soldier_img:setVisible(false)
		speed_img:setVisible(false)
		destroy_img:setVisible(false)
	else
		local soldier_num_txt = tolua.cast(soldier_img:getChildByName("num_label"), "Label")
		soldier_num_txt:setText(temp_army_hp)

		local add_speed_num = temp_army_speed - hero_min_speed
		local speed_base_txt = tolua.cast(speed_img:getChildByName("base_label"), "Label")
		local speed_add_txt = tolua.cast(speed_img:getChildByName("add_label"), "Label")
		speed_base_txt:setText(math.floor(hero_min_speed/100))
		if add_speed_num > 0 then
			speed_add_txt:setText("+" .. math.floor(add_speed_num/100))
			speed_add_txt:setPositionX(speed_base_txt:getPositionX() + speed_base_txt:getContentSize().width)
			speed_add_txt:setVisible(true)
		else
			speed_add_txt:setVisible(false)
		end

		local destroy_num_txt = tolua.cast(destroy_img:getChildByName("num_label"), "Label")
		destroy_num_txt:setText(math.floor(temp_army_destroy/100))
	end
end

local function set_state_content()
	local temp_army_id = armyWholeManager.get_army_id()
	local icon_state_type = armyData.getTeamIconState(temp_army_id)
	local state_img = tolua.cast(m_main_widget:getChildByName("state_img"), "ImageView")
	if icon_state_type == 1 or icon_state_type == 2 or icon_state_type == 3 or icon_state_type == 4 then
		local sign_img = tolua.cast(state_img:getChildByName("sign_img"), "ImageView")
		sign_img:loadTexture(ResDefineUtil.army_icon_res[icon_state_type][1], UI_TEX_TYPE_PLIST)

		local pos_txt = tolua.cast(state_img:getChildByName("pos_label"), "Label")
		if icon_state_type == 3 or icon_state_type == 4 then
			local temp_army_info = armyData.getTeamMsg(temp_army_id)
			--pos_txt:setText(landData.get_city_name_lv_by_coordinate(temp_army_info.reside_wid))
			local temp_show_name = landData.get_city_name_lv_by_coordinate(temp_army_info.reside_wid)
			pos_txt:setText(temp_show_name)
			pos_txt:setVisible(true)
			sign_img:setPositionX(-66)
		else
			sign_img:setPositionX(0)
			pos_txt:setVisible(false)
		end

		if armyWholeManager.get_current_stage == 1 then
			state_img:setVisible(true)
		end
	else
		state_img:setVisible(false)
	end
end

local function set_op_content(current_city_id)
	local op_img = tolua.cast(m_main_widget:getChildByName("op_img"), "ImageView")
	local zb_btn = tolua.cast(op_img:getChildByName("zb_btn"), "Button")
	local num_txt = tolua.cast(zb_btn:getChildByName("num_label"), "Label")

	local temp_army_id = armyWholeManager.get_army_id()
	local temp_zb_btn_state = armyData.getTeamZbBtnState(temp_army_id)
	if temp_zb_btn_state == 0 then
		if armyData.getTeamZbState(temp_army_id) then
			num_txt:setText(languagePack["zhengbing_ing"])
			num_txt:setColor(ccc3(83, 18, 0))
		else
			local temp_leave_nums, all_queue_num = armyData.get_army_city_zb_queue_num(temp_army_id)
			--print("==================" .. temp_leave_nums .. "/" .. all_queue_num)
			if temp_leave_nums > 0 then
				num_txt:setColor(ccc3(83, 18, 0))
			else
				num_txt:setColor(ccc3(255, 0, 0))
			end
			num_txt:setText((all_queue_num - temp_leave_nums) .. "/" .. all_queue_num)
		end
	else
		num_txt:setText(" ")
	end
end

--设置下方显示部队索引的显示信息
local function set_index_show(temp_cur_index, temp_max_index)
	local army_sign_panel = tolua.cast(m_main_widget:getChildByName("army_sign_panel"), "Layout")
	local army_index_img = nil
	for i=1,5 do
		army_index_img = tolua.cast(army_sign_panel:getChildByName("com_" .. i), "ImageView")
		if i > temp_max_index then
			army_index_img:setVisible(false)
		else
			army_index_img:setPositionX(m_army_index_pos[temp_max_index][i])
			if i == temp_cur_index then
				army_index_img:setScale(1.4)
			else
				army_index_img:setScale(1)
			end
		end
	end
end

local function set_dir_show_state()
	local left_btn = tolua.cast(m_main_widget:getChildByName("left_btn"), "Button")
	local right_btn = tolua.cast(m_main_widget:getChildByName("right_btn"), "Button")

	local temp_left_state, temp_right_state = armyWholeManager.get_dir_show_state()
	left_btn:setTouchEnabled(temp_left_state)
	left_btn:setVisible(temp_left_state)
	right_btn:setTouchEnabled(temp_right_state)
	right_btn:setVisible(temp_right_state)
end

local function set_op_show_state(new_state)
	local op_img = tolua.cast(m_main_widget:getChildByName("op_img"), "ImageView")
	local zb_btn = tolua.cast(op_img:getChildByName("zb_btn"), "Button")
	local set_btn = tolua.cast(op_img:getChildByName("set_btn"), "Button")
	local change_btn = tolua.cast(op_img:getChildByName("change_btn"), "Button")

	zb_btn:setTouchEnabled(new_state)
	set_btn:setTouchEnabled(new_state)
	change_btn:setTouchEnabled(new_state)
	op_img:setVisible(new_state)

	local army_sign_panel = tolua.cast(m_main_widget:getChildByName("army_sign_panel"), "Layout")
	army_sign_panel:setVisible(new_state)
end

local function init_title_panel_info(scene_height)
	local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")
	title_panel:ignoreAnchorPointForPosition(false)
	title_panel:setAnchorPoint(cc.p(0,1))
	title_panel:setPosition(cc.p(0, scene_height))

	local hzb_btn = tolua.cast(title_panel:getChildByName("hzb_btn"), "Button")
	hzb_btn:setTouchEnabled(true)
	hzb_btn:addTouchEventListener(deal_with_hzb_click)
end

local function init_op_panel_info(scene_width, scene_height)
	local op_img = tolua.cast(m_main_widget:getChildByName("op_img"), "ImageView")
	--op_img:ignoreAnchorPointForPosition(false)
	--op_img:setAnchorPoint(cc.p(1,0))
	op_img:setPosition(cc.p(scene_width/2, scene_height/6))

	local zb_btn = tolua.cast(op_img:getChildByName("zb_btn"), "Button")
	zb_btn:addTouchEventListener(deal_with_zb_click)

	local set_btn = tolua.cast(op_img:getChildByName("set_btn"), "Button")
	set_btn:addTouchEventListener(deal_with_set_click)

	local change_btn = tolua.cast(op_img:getChildByName("change_btn"), "Button")
	change_btn:addTouchEventListener(deal_with_change_click)
end

local function init_btn_info(scene_width, scene_height)
	local left_btn = tolua.cast(m_main_widget:getChildByName("left_btn"), "Button")
	left_btn:setPosition(cc.p(0, scene_height/2))
	left_btn:addTouchEventListener(deal_with_left_click)
	breathAnimUtil.start_anim(left_btn, true, 76, 255, 1, 0, 99)

	local right_btn = tolua.cast(m_main_widget:getChildByName("right_btn"), "Button")
	right_btn:setPosition(cc.p(scene_width, scene_height/2))
	right_btn:addTouchEventListener(deal_with_right_click)
	breathAnimUtil.start_anim(right_btn, true, 76, 255, 1, 0, 99)

	local return_btn = tolua.cast(m_main_widget:getChildByName("return_btn"), "Button")
	return_btn:setPosition(cc.p(scene_width, scene_height))
	return_btn:addTouchEventListener(deal_with_return_click)
	return_btn:setTouchEnabled(true)
end

local function set_layout(scene_width, scene_height)
	init_title_panel_info(scene_height)
	init_op_panel_info(scene_width, scene_height)
	init_btn_info(scene_width, scene_height)

	local army_sign_panel = tolua.cast(m_main_widget:getChildByName("army_sign_panel"), "Layout")
	army_sign_panel:setPosition(cc.p(scene_width/2 - army_sign_panel:getContentSize().width/2, 0))

	local state_img = tolua.cast(m_main_widget:getChildByName("state_img"), "ImageView")
	state_img:setPosition(cc.p(scene_width/2, scene_height - 5))
end

local function create(temp_widget)
	m_main_widget = temp_widget

	init_army_index_pos()
end

local function update_title_show_content(temp_city_id, temp_army_index)
	set_title_content(temp_city_id, temp_army_index)
	set_hzb_content()
	set_state_content()
	set_op_content(temp_city_id)
end

local function deal_with_enter_set()
	set_dir_show_state()
	armyBaseManager.set_op_show_state(false)

	--local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")
	--local title_img = tolua.cast(title_panel:getChildByName("title_img"), "ImageView")
	--title_img:setVisible(false)

	local state_img = tolua.cast(m_main_widget:getChildByName("state_img"), "ImageView")
	state_img:setVisible(false)

	if not newGuideManager.get_guide_state() then
		local return_btn = tolua.cast(m_main_widget:getChildByName("return_btn"), "Button")
		return_btn:setTouchEnabled(false)
		return_btn:setVisible(false)
	end
end

local function deal_with_leave_set()
	set_dir_show_state()
	armyBaseManager.set_op_show_state(true)

	--local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")
	--local title_img = tolua.cast(title_panel:getChildByName("title_img"), "ImageView")
	--title_img:setVisible(true)

	local state_img = tolua.cast(m_main_widget:getChildByName("state_img"), "ImageView")
	local temp_army_id = armyWholeManager.get_army_id()
	local icon_state_type = armyData.getTeamIconState(temp_army_id)
	if icon_state_type == 1 or icon_state_type == 2 or icon_state_type == 3 or icon_state_type == 4 then
		state_img:setVisible(true)
	end

	if not newGuideManager.get_guide_state() then
		local return_btn = tolua.cast(m_main_widget:getChildByName("return_btn"), "Button")
		return_btn:setTouchEnabled(true)
		return_btn:setVisible(true)
	end
end

armyBaseManager = {
					create = create,
					remove = remove,
					set_layout = set_layout,
					set_index_show = set_index_show,
					set_dir_show_state = set_dir_show_state,
					set_op_show_state = set_op_show_state,
					update_title_show_content = update_title_show_content,
					deal_with_leave_set = deal_with_leave_set,
					deal_with_enter_set = deal_with_enter_set
}