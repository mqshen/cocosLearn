--该部分是针对部队编成管理界面中部队显示部分管理的代码，只针对该部分服务，所以其他的地方不要用这个类中的方法
local m_army_id = nil
local m_select_widget = nil

local m_widget_list = nil	--部队中英雄显示列表

local function remove()
	m_army_id = nil
	m_select_widget = nil
	m_widget_list = nil
end

local function judge_tb_for_army_area(x, y)
	local is_touch_army_area = false
	local selected_hero_id = 0
	local start_x_in_card, start_y_in_card = 0, 0

	for k,v in pairs(m_widget_list) do
		if v:hitTest(cc.p(x, y)) then
			if v:isVisible() then
				m_select_widget = v
				selected_hero_id = exerciseData.get_hero_by_index(k)
				local temp_point = v:convertToNodeSpace(cc.p(x,y))
				start_x_in_card = temp_point.x
				start_y_in_card = temp_point.y
			end
			is_touch_army_area = true
			break
		end
	end

	return is_touch_army_area, selected_hero_id, start_x_in_card, start_y_in_card
end

local function deal_with_stop_drag(x, y)
	local target_pos_index = 0
	for k,v in pairs(m_widget_list) do
		if v:hitTest(cc.p(x, y)) then
			target_pos_index = k
			break
		end
	end
	return target_pos_index
end

local function set_selected_state(new_state)
	if m_select_widget then
		if new_state then
			m_select_widget:setOpacity(100)
		else
			m_select_widget:setOpacity(255)
			m_select_widget = nil
		end
	end
end

--[[进行硬件条件检测 0 可以配置；1 位置未开放（包含部队不可以以及部分部队位置不可以）；2 武将对应的国家殿未建立
					3 部队处于非正常状态；4 部队中已经有同样武将；5 COST超出上限；6 移入的对应位置的武将的兵力数大于100
					7 目标位置的武将正在征兵
--]]
local function check_add_hero(hero_uid, add_pos)
	local temp_land_index = exerciseMapManager.get_select_land_index()
	local temp_hero_nums, temp_soldier_nums = exerciseData.get_exercise_army_condition(temp_land_index)

	if add_pos > temp_hero_nums then
		return 1
	end
	
	if exerciseData.is_used_same_hero(hero_uid) then
		return 4
	end

	
	if add_pos ~= 0 then
		local show_cost_num, max_cost_num = exerciseData.get_sum_cost_in_exercise()
		local old_hero_uid = exerciseData.get_hero_by_index(add_pos)

		local new_cost = show_cost_num + heroData.getHeroCost(hero_uid)
		if old_hero_uid ~= 0 then
			new_cost = new_cost - heroData.getHeroCost(old_hero_uid)
		end

		if new_cost > max_cost_num then
			return 5
		end
	end

	return 0
end

local function create(temp_widget)
	m_widget_list = {}

	local hero_panel, icon_img, hero_widget = nil, nil, nil
	for i=1,3 do
		hero_panel = tolua.cast(temp_widget:getChildByName("hero_" .. i), "Layout")
		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")

		table.insert(m_widget_list, hero_widget)
	end
end

exerciseArmyPosManager = {
						create = create,
						remove = remove,
						set_selected_state = set_selected_state,
						judge_tb_for_army_area = judge_tb_for_army_area,
						deal_with_stop_drag = deal_with_stop_drag,
						check_add_hero = check_add_hero
}