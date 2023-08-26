local m_content_panel = nil

local m_army_id = nil 	--当前选中的部队ID
local m_city_id = nil 	--当前显示的城市部队配置

local selected_hero_id = nil
local start_x_in_card, start_y_in_card = nil, nil 	--开始选中卡片时选中的卡片中的坐标点
local start_touch_x, start_touch_y = nil, nil 		--开始选中的坐标（相对于WIDGET中的位置,采用这个是在移动时计算位移值获取一层组件就好了）
local is_touch_scroll_area, is_touch_army_area = nil, nil
local is_moving, is_scrolling = nil, nil

local drag_widget = nil
local m_drag_icon_x, m_drag_icon_y = nil, nil 	--拖动卡牌的位置坐标

local MOVE_SENSITIVE_DIS = nil

local function init_param_info()
	selected_hero_id = 0
	start_x_in_card = 0
	start_y_in_card = 0

	start_touch_x = 0
	start_touch_y = 0

	is_touch_scroll_area = false
	is_touch_army_area = false

	is_moving = false
	is_scrolling = false

	MOVE_SENSITIVE_DIS = 5
end

local function remove_self()
	if m_content_panel then
		m_army_id = nil
		m_city_id = nil
		selected_hero_id = nil
		start_x_in_card = nil
		start_y_in_card = nil
		start_touch_x = nil
		start_touch_y = nil
		is_touch_scroll_area = nil
		is_touch_army_area = nil
		is_moving = nil
		is_scrolling = nil
		MOVE_SENSITIVE_DIS = nil

		armyPosManager.remove()
		armyScrollManager.remove()

		drag_widget = nil
		m_drag_icon_x = nil
		m_drag_icon_y = nil
		m_content_panel = nil
	end
end

local function init_drag_widget_info()
	drag_widget = Layout:create()
	drag_widget:setTouchEnabled(false)
	drag_widget:setVisible(false)
	local content_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	content_widget:setName("hero_icon")
	drag_widget:addChild(content_widget)
	local light_img = ImageView:create()
	light_img:loadTexture(ResDefineUtil.Card_light_n, UI_TEX_TYPE_PLIST)
	light_img:setAnchorPoint(cc.p(0,0))
	drag_widget:addChild(light_img)
	drag_widget:setScale(config.getgScale())

	m_drag_icon_x = math.floor((light_img:getContentSize().width - content_widget:getContentSize().width)/2)
	m_drag_icon_y = math.floor((light_img:getContentSize().height - content_widget:getContentSize().height)/2)
	content_widget:setPosition(cc.p(m_drag_icon_x, m_drag_icon_y))
	m_content_panel:addChild(drag_widget, 1)
end

local function deal_with_move(current_x, current_y)
	if selected_hero_id == 0 then
		return
	end

	local scale_value = config.getgScale()
	local temp_offset_x = (m_drag_icon_x + start_x_in_card) * scale_value
	local temp_offset_y = (m_drag_icon_y + start_y_in_card) * scale_value
	drag_widget:setPosition(cc.p(current_x - temp_offset_x, current_y - temp_offset_y))

	if not drag_widget:isVisible() then
		local hero_widget = tolua.cast(drag_widget:getChildByName("hero_icon"), "Layout")
		cardFrameInterface.set_middle_card_info(hero_widget, selected_hero_id, heroData.getHeroOriginalId(selected_hero_id))
		drag_widget:setVisible(true)

		if is_touch_army_area then
			armyPosManager.set_selected_state(true)
		else
			if is_touch_scroll_area then
				armyScrollManager.set_selected_state(true)
			end
		end
	end
end

--检测是否点击在空白区域
local function deal_with_touch_space(x, y)
	if newGuideManager.get_guide_state() then
		return
	end

	if armyScrollManager.is_touch_widget(x, y) then
		return
	end

	local touch_componment_list = {{"title_panel", "Layout"}, {"hero_1", "Layout"}, {"hero_2", "Layout"}, {"hero_3", "Layout"}, {"left_btn", "Button"}, {"right_btn", "Button"}}
	local temp_component = nil
	local is_touch_space = true
	for k,v in pairs(touch_componment_list) do
		temp_component = tolua.cast(m_content_panel:getChildByName(v[1]), v[2])
		if temp_component:isVisible() and temp_component:hitTest(cc.p(x, y)) then
			is_touch_space = false
			break
		end
	end

	if is_touch_space then
		armyWholeManager.deal_with_return_event()
	end
end

--将武将增加到部队中
local function deal_with_add_hero_judge(target_army_id, target_pos_index)
	if newGuideManager.get_guide_state() then
		if not newGuideInfo.is_can_move_card(target_pos_index) then
			newGuideInfo.play_special_anim()
			
			return
		end
	end

	local function add_event()
		armyOpRequest.requestAddHero(m_city_id, selected_hero_id, target_army_id, target_pos_index)
		newGuideInfo.enter_next_guide()
	end

	local state_1 = armyPosManager.check_add_hero(selected_hero_id, target_pos_index)
	if state_1 == 0 then
		add_event()
	elseif state_1 == 1 then
		tipsLayer.create(errorTable[22])
	elseif state_1 == 2 then
		tipsLayer.create(errorTable[20])
	elseif state_1 == 3 then
		tipsLayer.create(errorTable[110])
	elseif state_1 == 4 then
		tipsLayer.create(errorTable[21])
	elseif state_1 == 5 then
		tipsLayer.create(errorTable[201], nil, {numOrderList[target_army_id%10]})
	elseif state_1 == 6 then
		require("game/army/armyCityOverview/soldierDissolveManager")
		local temp_hero_id = armyData.getHeroIdInTeamAndPos(target_army_id, target_pos_index)
		soldierDissolveManager.on_enter(temp_hero_id, add_event)
		--alertLayer.create(errorTable[25], nil, add_event)
	elseif state_1 == 7 then
		tipsLayer.create(errorTable[28])
	end
end

--将武将从部队中移出
local function deal_with_remove_hero_judge(src_army_id, src_pos_index)
	local team_info = armyData.getTeamMsg(src_army_id)
	if team_info.state ~= armyState.normal then
		tipsLayer.create(errorTable[23])
		return
	end

	local hero_info = heroData.getHeroInfo(selected_hero_id)
	if hero_info.state == cardState.zhengbing then
		tipsLayer.create(errorTable[24])
		return
	end

	local function remove_event()
		armyOpRequest.requestRemoveHero(m_city_id, src_army_id, src_pos_index)
	end

	if hero_info.hp > HERO_HP_INIT_IN_ARMY then
		require("game/army/armyCityOverview/soldierDissolveManager")
		soldierDissolveManager.on_enter(selected_hero_id, remove_event)
		--alertLayer.create(errorTable[25], nil, remove_event)
	else
		remove_event()
	end
end

--将武将在部队之间切换
local function deal_with_switch_hero_judge(target_army_id, target_pos_index, src_army_id, src_pos_index)
	local src_city_id = math.floor(src_army_id/10)
	local target_city_id = math.floor(target_army_id/10)
	if src_city_id ~= target_city_id then
		tipsLayer.create(errorTable[211])
		return
	end

	local src_army_info = armyData.getTeamMsg(src_army_id)
	if src_army_info and src_army_info.state ~= armyState.normal then
		tipsLayer.create(errorTable[27])
		return
	end

	local target_army_info = armyData.getTeamMsg(target_army_id)
	if target_army_info and target_army_info.state ~= armyState.normal then
		tipsLayer.create(errorTable[27])
		return
	end

	local src_hero_info = heroData.getHeroInfo(selected_hero_id)
	local src_hero_cost = Tb_cfg_hero[src_hero_info.heroid].cost/10
	if src_hero_info.state == cardState.zhengbing then
		tipsLayer.create(errorTable[28])
		return
	end

	local target_hero_uid = armyData.getHeroIdInTeamAndPos(target_army_id, target_pos_index)
	local target_hero_info = nil
	local target_hero_cost = 0
	if target_hero_uid ~= 0 then
		target_hero_info = heroData.getHeroInfo(target_hero_uid)
		target_hero_cost = Tb_cfg_hero[target_hero_info.heroid].cost/10
		if target_hero_info.state == cardState.zhengbing then
			tipsLayer.create(errorTable[28])
			return
		end
	end

	if target_army_id ~= src_army_id then
		--交换后的COST检测
		local src_cost_nums = userCityData.getCityCostNums(m_city_id)
		local new_src_cost = armyData.getTeamCost(src_army_id)
		if src_pos_index ~= 0 then
			new_src_cost = new_src_cost - src_hero_cost + target_hero_cost
		end
		if new_src_cost > src_cost_nums then
			--tipsLayer.create(errorTable[26])
			tipsLayer.create(errorTable[201], nil, {numOrderList[src_army_id%10]})
			return
		end

		if target_army_info then
			local target_cost_nums = userCityData.getCityCostNums(math.floor(target_army_id/10))
			local new_target_cost = armyData.getTeamCost(target_army_id)
			if target_pos_index ~= 0 then
				new_target_cost = new_target_cost - target_hero_cost + src_hero_cost
			end
			if new_target_cost > target_cost_nums then
				--tipsLayer.create(errorTable[26])
				tipsLayer.create(errorTable[201], nil, {numOrderList[target_army_id%10]})
				return
			end
		end
	else
		local src_cost_nums = userCityData.getCityCostNums(m_city_id)
		local new_src_cost = armyData.getTeamCost(src_army_id)
		if src_pos_index == 0 then
			new_src_cost = new_src_cost - target_hero_cost + src_hero_cost
		end
		if target_pos_index == 0 then
			new_src_cost = new_src_cost - src_hero_cost + target_hero_cost
		end

		if new_src_cost > src_cost_nums then
			--tipsLayer.create(errorTable[26])
			tipsLayer.create(errorTable[201], nil, {numOrderList[src_army_id%10]})
			return
		end
	end

	local function switch_event()
		armyOpRequest.requestSwitchHero(m_city_id, target_army_id, target_pos_index, src_army_id, src_pos_index)
	end

	if target_pos_index == 0 and src_pos_index ~= 0 then
		alertLayer.create(errorTable[29], nil, switch_event)
		return
	end

	switch_event()
end

local function on_touch_began(x,y)
	if is_moving or is_scrolling then
		return false
	end

	if armyScrollManager and armyScrollManager.is_play_anim() then
		return false
	end
	
	is_touch_scroll_area = false
	is_touch_army_area = false
	is_moving = false
	is_scrolling = false

	is_touch_army_area, selected_hero_id, start_x_in_card, start_y_in_card = armyPosManager.judge_tb_for_army_area(x,y)
	if not is_touch_army_area then
		is_touch_scroll_area, selected_hero_id, start_x_in_card, start_y_in_card = armyScrollManager.judge_tb_for_scroll_area(x, y)
	end

	if is_touch_scroll_area or is_touch_army_area then
		local point = m_content_panel:convertToNodeSpace(cc.p(x,y))
		start_touch_x = point.x
		start_touch_y = point.y
		armyScrollManager.set_start_touch_pos(start_touch_x, start_touch_y)

		newGuideInfo.stop_special_anim()
		return true
	else
		deal_with_touch_space(x, y)
		return false
	end

	--return true
end

local function on_touch_move(x,y)
	local point = m_content_panel:convertToNodeSpace(cc.p(x,y))

	if is_moving == false and is_scrolling == false then
		local move_x_distance = point.x - start_touch_x
		local move_y_distance = point.y - start_touch_y
		local move_distance = math.sqrt((math.pow(move_x_distance,2) + math.pow(move_y_distance,2)))
		--判定滑动的敏感范围 判定移动卡片的敏感范围
		if move_distance >= MOVE_SENSITIVE_DIS/config.getgScale() then
			if is_touch_scroll_area then
				local angle = math.deg(math.asin(move_y_distance/move_distance))
				if angle >= -30 and angle <= 30 then
					if not newGuideManager.get_guide_state() then
						is_scrolling = true
					end
				else
					is_moving = true
				end
			end

			if is_touch_army_area then
				is_moving = true
			end
		end
	end

	if is_moving then
		deal_with_move(point.x, point.y)
	else
		if is_scrolling then
			armyScrollManager.deal_with_scroll(point.x)
		end
	end
end

local function on_touch_end(x,y)
	if is_touch_army_area then
		armyPosManager.set_selected_state(false)
	else
		if is_touch_scroll_area then
			armyScrollManager.set_selected_state(false)
		end
	end

	if is_scrolling then
		local point = m_content_panel:convertToNodeSpace(cc.p(x,y))
		armyScrollManager.deal_with_stop_scroll(point.x, point.y)
		is_scrolling = false

		newGuideInfo.play_special_anim()
	else
		if is_moving then
			if selected_hero_id ~= 0 then
				local src_army_id, src_pos_index = armyData.getArmyIdAndPosByHero(selected_hero_id)
				local target_army_id, target_pos_index = armyPosManager.deal_with_stop_drag(x, y)
				if target_army_id == 0 then
					if is_touch_army_area then
						deal_with_remove_hero_judge(src_army_id, src_pos_index)
					end

					newGuideInfo.play_special_anim()
				else
					if src_army_id == 0 then
						deal_with_add_hero_judge(target_army_id, target_pos_index)
					else
						if src_army_id ~= target_army_id or src_pos_index ~= target_pos_index then
							deal_with_switch_hero_judge(target_army_id, target_pos_index, src_army_id, src_pos_index)
						end

						newGuideInfo.play_special_anim()
					end
				end
				drag_widget:setVisible(false)
			else
				newGuideInfo.play_special_anim()
			end
			is_moving = false
		else
			if selected_hero_id ~= 0 and (not newGuideManager.get_guide_state()) then
				require("game/cardDisplay/userCardViewer")
				userCardViewer.create(nil,selected_hero_id)
			else
				--deal_with_touch_space(x, y)
			end

			newGuideInfo.play_special_anim()
		end
	end
end

local function on_touch_cancel(x,y)
	if is_touch_army_area then
		armyPosManager.set_selected_state(false)
	else
		if is_touch_scroll_area then
			armyScrollManager.set_selected_state(false)
		end
	end

	if is_scrolling then
		is_scrolling = false
	else
		if is_moving then
			is_moving = false
			drag_widget:setVisible(false)
		end
	end
end

local function onTouch(eventType, x, y)
	if armyWholeManager.get_current_stage() ~= 2 then
		return false
	end

	if eventType == "began" then
		 return on_touch_began(x,y)
	elseif eventType == "moved" then
		on_touch_move(x,y)
	elseif eventType == "ended" then
		on_touch_end(x,y)
	elseif eventType == "cancelled" then
		on_touch_cancel(x, y)
	end

	return true
end

local function get_selected_army_id()
	return m_army_id
end

local function enter_formation_for_army(temp_army_id)
	m_army_id = temp_army_id
	m_city_id = math.floor(m_army_id/10)
	init_param_info()

	armyScrollManager.set_city_id(m_city_id)
	armyPosManager.set_army_id(m_army_id)
end

local function on_enter(parent_con, temp_army_id)
	if not m_content_panel then
		require("game/army/armyCityOverview/armyPosManager")
		require("game/army/armyCityOverview/armyScrollManager")
		m_content_panel = parent_con

		armyPosManager.create(m_content_panel)
		armyScrollManager.create(m_content_panel)

		local drag_layer = cc.LayerColor:create(cc.c4b(0,0,0,0),config.getWinSize().width, config.getWinSize().height)
		drag_layer:registerScriptTouchHandler(onTouch,false, 0, false)
		drag_layer:setTouchEnabled(true)
		m_content_panel:addChild(drag_layer)

		init_drag_widget_info()
	end

	enter_formation_for_army(temp_army_id)
end

local function on_leave()
	local temp_army_info = armyData.getTeamMsg(m_army_id)
	if temp_army_info then
		if temp_army_info.base_heroid_u == 0 then
			tipsLayer.create(errorTable[214])
		end
	else
		tipsLayer.create(errorTable[214])
	end

	armyScrollManager.deal_with_leave_set()
end

local function deal_with_hero_change(change_hero_uid, change_type)
	armyScrollManager.reset_widget_info()
end

local function deal_with_army_change(temp_army_id, change_type)
	armyScrollManager.reset_widget_info()
end

--部队编成
armySetManager = {
					on_enter = on_enter,
					on_leave = on_leave,
					enter_formation_for_army = enter_formation_for_army,
					remove_self = remove_self,
					get_selected_army_id = get_selected_army_id,
					deal_with_hero_change = deal_with_hero_change,
					deal_with_army_change = deal_with_army_change
}
