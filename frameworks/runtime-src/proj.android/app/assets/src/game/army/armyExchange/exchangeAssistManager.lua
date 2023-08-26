local m_content_panel = nil

local m_city_id = nil 	--当前显示的城市部队配置
local start_touch_x, start_touch_y = nil, nil 		--开始选中的坐标（相对于WIDGET中的位置,采用这个是在移动时计算位移值获取一层组件就好了）
local is_moving = nil
local drag_widget = nil

local MOVE_SENSITIVE_DIS = nil

local function remove_self()
	if m_content_panel then
		exchangeDragManager.remove()
		m_city_id = nil

		start_touch_x = nil
		start_touch_y = nil
		is_moving = nil
		MOVE_SENSITIVE_DIS = nil

		drag_widget = nil
		m_content_panel = nil
	end
end

local function init_drag_widget_info()
	drag_widget = Layout:create()
	drag_widget:setTouchEnabled(false)
	drag_widget:setVisible(false)
	local content_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
	content_widget:setName("hero_icon")
	drag_widget:addChild(content_widget)
	drag_widget:setScale(config.getgScale())
	--local light_img = ImageView:create()
	--light_img:loadTexture(ResDefineUtil.Card_light_n, UI_TEX_TYPE_PLIST)
	--light_img:setAnchorPoint(cc.p(0,0))
	--drag_widget:addChild(light_img)

	--local icon_pos_x = math.floor((light_img:getContentSize().width - content_widget:getContentSize().width)/2)
	--local icon_pos_y = math.floor((light_img:getContentSize().height - content_widget:getContentSize().height)/2)
	--content_widget:setPosition(cc.p(icon_pos_x, icon_pos_y))
	m_content_panel:addChild(drag_widget, 1)
end

local function deal_with_move(current_x, current_y)
	local offset_x, offset_y = exchangeDragManager.get_offset_in_card()
	drag_widget:setPosition(cc.p(current_x - offset_x, current_y - offset_y))
	--drag_widget:setPosition(cc.p(current_x, current_y))
	if not drag_widget:isVisible() then
		local temp_hero_uid = exchangeDragManager.get_selected_hero_uid()
		local hero_widget = tolua.cast(drag_widget:getChildByName("hero_icon"), "Layout")
		cardFrameInterface.set_small_card_info(hero_widget, temp_hero_uid, heroData.getHeroOriginalId(temp_hero_uid))
		drag_widget:setVisible(true)

		exchangeDragManager.set_selected_state(true)
	end
end

--将武将在部队之间切换
local function deal_with_switch_hero_judge(src_army_index, src_pos_index, target_army_index, target_pos_index)
	local src_army_id = m_city_id * 10 + src_army_index
	local target_army_id = m_city_id * 10 + target_army_index

	local target_army_info = armyData.getTeamMsg(target_army_id)
	if target_army_info and target_army_info.state ~= armyState.normal then
		tipsLayer.create(errorTable[27])
		return
	end

	local src_hero_uid = armyData.getHeroIdInTeamAndPos(src_army_id, src_pos_index)
	local src_hero_info = heroData.getHeroInfo(src_hero_uid)
	local src_hero_cost = Tb_cfg_hero[src_hero_info.heroid].cost/10

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

	local city_cost_nums = userCityData.getCityCostNums(m_city_id)
	local new_src_cost = armyData.getTeamCost(src_army_id)
	if target_army_id ~= src_army_id then
		--交换后的COST检测
		if src_pos_index ~= 0 then
			new_src_cost = new_src_cost - src_hero_cost + target_hero_cost
		end
		if new_src_cost > city_cost_nums then
			tipsLayer.create(errorTable[201], nil, {numOrderList[src_army_index]})
			return
		end

		if target_army_info then
			local new_target_cost = armyData.getTeamCost(target_army_id)
			if target_pos_index ~= 0 then
				new_target_cost = new_target_cost - target_hero_cost + src_hero_cost
			end
			if new_target_cost > city_cost_nums then
				tipsLayer.create(errorTable[201], nil, {numOrderList[target_army_id%10]})
				return
			end
		end
	else
		if src_pos_index == 0 then
			new_src_cost = new_src_cost - target_hero_cost + src_hero_cost
		end
		if target_pos_index == 0 then
			new_src_cost = new_src_cost - src_hero_cost + target_hero_cost
		end

		if new_src_cost > city_cost_nums then
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
	if is_moving then
		return false
	end
	
	is_moving = false
	if exchangeDragManager.judge_touch_began_area(x, y) then
		local point = m_content_panel:convertToNodeSpace(cc.p(x,y))
		start_touch_x = point.x
		start_touch_y = point.y

		return true
	else
		return false
	end
end

local function on_touch_move(x,y)
	local point = m_content_panel:convertToNodeSpace(cc.p(x,y))

	if is_moving then
		deal_with_move(point.x, point.y)
	else
		local move_x_distance = point.x - start_touch_x
		local move_y_distance = point.y - start_touch_y
		local move_distance = math.sqrt((math.pow(move_x_distance,2) + math.pow(move_y_distance,2)))
		--判定滑动的敏感范围 判定移动卡片的敏感范围
		if move_distance >= MOVE_SENSITIVE_DIS/config.getgScale() then
			is_moving = true
		end
	end
end

local function on_touch_end(x,y)
	if not is_moving then
		return
	end

	drag_widget:setVisible(false)
	exchangeDragManager.set_selected_state(false)
	is_moving = false

	local is_response, target_army_index, target_pos_index = exchangeDragManager.judeg_touch_ended_area(x, y)
	if not is_response then
		return
	end

	local src_army_index, src_pos_index = exchangeDragManager.get_began_touch_info()

	if src_army_index == target_army_index and src_pos_index == target_pos_index then
		return
	end	

	deal_with_switch_hero_judge(src_army_index, src_pos_index, target_army_index, target_pos_index)
end

local function on_touch_cancel(x,y)
	if is_moving then
		drag_widget:setVisible(false)
		exchangeDragManager.set_selected_state(false)
		is_moving = false
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
		on_touch_cancel(x,y)
	end

	return true
end

local function init_param_info()
	start_touch_x = 0
	start_touch_y = 0

	is_moving = false

	MOVE_SENSITIVE_DIS = 5
end

local function create(parent_con, temp_city_id)
	require("game/army/armyExchange/exchangeDragManager")

	m_content_panel = parent_con
	m_city_id = temp_city_id
	init_param_info()

	local bg_img = tolua.cast(m_content_panel:getChildByName("bg_img"), "ImageView")
	exchangeDragManager.create(bg_img, temp_city_id)

	local drag_layer = cc.LayerColor:create(cc.c4b(0,0,0,0),config.getWinSize().width, config.getWinSize().height)
	drag_layer:setTouchEnabled(true)
	drag_layer:registerScriptTouchHandler(onTouch,false, 0, false)
	m_content_panel:addChild(drag_layer)

	init_drag_widget_info()
end

local function deal_with_content_update()
	if exchangeDragManager then
		exchangeDragManager.organize_all_army_info()
	end
end

--部队编成
exchangeAssistManager = {
					create = create,
					remove_self = remove_self,
					deal_with_content_update = deal_with_content_update
}