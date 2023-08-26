local m_content_panel = nil

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

local function remove()
	if m_content_panel then
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

		exerciseArmyPosManager.remove()
		exerciseArmyScrollManager.remove()

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
		local hp_txt = cardFrameInterface.get_hp_txt(hero_widget, 2)
		hp_txt:setText("--")
		drag_widget:setVisible(true)

		if is_touch_army_area then
			exerciseArmyPosManager.set_selected_state(true)
		else
			if is_touch_scroll_area then
				exerciseArmyScrollManager.set_selected_state(true)
			end
		end
	end
end

--将武将增加到部队中
local function deal_with_add_hero_judge(target_pos_index)
	local function add_event()
		exerciseOpRequest.request_add_hero(selected_hero_id, target_pos_index)
	end

	local state_1 = exerciseArmyPosManager.check_add_hero(selected_hero_id, target_pos_index)
	if state_1 == 0 then
		add_event()
	elseif state_1 == 1 then
		tipsLayer.create(errorTable[500])
	elseif state_1 == 2 then
		tipsLayer.create(errorTable[20])
	elseif state_1 == 3 then
		tipsLayer.create(errorTable[110])
	elseif state_1 == 4 then
		tipsLayer.create(errorTable[21])
	elseif state_1 == 5 then
		tipsLayer.create(errorTable[201], nil, {numOrderList[1]})
	elseif state_1 == 6 then
		alertLayer.create(errorTable[25], nil, add_event)
	elseif state_1 == 7 then
		tipsLayer.create(errorTable[28])
	end
end

--将武将从部队中移出
local function deal_with_remove_hero_judge(src_pos_index)
	exerciseOpRequest.request_remove_hero(src_pos_index)
end

--将武将在部队之间切换
local function deal_with_switch_hero_judge(target_pos_index, src_pos_index)
	exerciseOpRequest.request_switch_hero(target_pos_index, src_pos_index)
end

local function on_touch_began(x,y)
	if is_moving or is_scrolling then
		return false
	end
	
	is_touch_scroll_area = false
	is_touch_army_area = false
	is_moving = false
	is_scrolling = false

	is_touch_army_area, selected_hero_id, start_x_in_card, start_y_in_card = exerciseArmyPosManager.judge_tb_for_army_area(x,y)
	if not is_touch_army_area then
		is_touch_scroll_area, selected_hero_id, start_x_in_card, start_y_in_card = exerciseArmyScrollManager.judge_tb_for_scroll_area(x, y)
	end

	if is_touch_scroll_area or is_touch_army_area then
		local point = m_content_panel:convertToNodeSpace(cc.p(x,y))
		start_touch_x = point.x
		start_touch_y = point.y
		exerciseArmyScrollManager.set_start_touch_pos(start_touch_x, start_touch_y)

		return true
	else
		return false
	end
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
			exerciseArmyScrollManager.deal_with_scroll(point.x)
		end
	end
end

local function on_touch_end(x,y)
	if is_touch_army_area then
		exerciseArmyPosManager.set_selected_state(false)
	else
		if is_touch_scroll_area then
			exerciseArmyScrollManager.set_selected_state(false)
		end
	end

	if is_scrolling then
		local point = m_content_panel:convertToNodeSpace(cc.p(x,y))
		exerciseArmyScrollManager.deal_with_stop_scroll(point.x, point.y)
		is_scrolling = false
	else
		if is_moving then
			if selected_hero_id ~= 0 then
				local is_in_army, src_pos_index = exerciseData.is_used_hero(selected_hero_id)
				local target_pos_index = exerciseArmyPosManager.deal_with_stop_drag(x, y)
				if target_pos_index == 0 then
					if is_touch_army_area then
						deal_with_remove_hero_judge(src_pos_index)
					end
				else
					if is_in_army then
						if src_pos_index ~= target_pos_index then
							deal_with_switch_hero_judge(target_pos_index, src_pos_index)
						end
					else
						deal_with_add_hero_judge(target_pos_index)
					end
				end
				drag_widget:setVisible(false)
			end
			is_moving = false
		else
			if selected_hero_id ~= 0 then
				require("game/cardDisplay/userCardViewer")
				userCardViewer.create(nil,selected_hero_id)
			end
		end
	end
end

local function on_touch_cancel(x,y)
	if is_touch_army_area then
		exerciseArmyPosManager.set_selected_state(false)
	else
		if is_touch_scroll_area then
			exerciseArmyScrollManager.set_selected_state(false)
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

local function create(parent_con)
	require("game/exercise/exerciseArmy/exerciseArmyPosManager")
	require("game/exercise/exerciseArmy/exerciseArmyScrollManager")
	m_content_panel = parent_con

	exerciseArmyPosManager.create(m_content_panel)
	exerciseArmyScrollManager.create(m_content_panel)

	local drag_layer = cc.LayerColor:create(cc.c4b(0,0,0,0),config.getWinSize().width, config.getWinSize().height)
	drag_layer:setTouchEnabled(true)
	drag_layer:registerScriptTouchHandler(onTouch,false, 0, false)
	m_content_panel:addChild(drag_layer)

	init_drag_widget_info()

	init_param_info()
end

local function deal_with_hero_change()
	exerciseArmyScrollManager.reset_widget_info()
end

--部队编成
exerciseArmySetManager = {
					create = create,
					remove = remove,
					deal_with_hero_change = deal_with_hero_change
}
