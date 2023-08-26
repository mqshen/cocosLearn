--部队交换辅助管理部分，主要控制拖动开始结束检测以及内容刷新
local m_bg_img = nil 				--所有内容显示的总组件索引
local m_city_id = nil 				--城市ID
local m_army_nums, m_front_nums = nil, nil --城市开放的部队数量，前锋数量
local m_began_widget_list = nil 	--能够初始拖动的部分
local m_ended_widget_list = nil 	--能够接收拖动释放的部分

local m_select_widget = nil
local m_touch_army_index, m_touch_hero_index = nil, nil 	--开始选中的部队索引以及卡牌在部队中的索引
local m_start_x_in_card, m_start_y_in_card = nil, nil		--开始选中卡片时选中的卡片中的坐标点

local function remove()
	m_city_id = nil
	m_army_nums = nil
	m_front_nums = nil
	m_began_widget_list = nil
	m_ended_widget_list = nil
	m_touch_army_index = nil
	m_touch_hero_index = nil
	m_start_x_in_card = nil
	m_start_y_in_card = nil

	m_select_widget = nil
	m_bg_img = nil
end

local function get_selected_hero_uid()
	return armyData.getHeroIdInTeamAndPos(m_city_id*10 + m_touch_army_index, m_touch_hero_index)
end

local function get_began_touch_info()
	return m_touch_army_index, m_touch_hero_index
end

local function get_offset_in_card()
	return m_start_x_in_card, m_start_y_in_card
end

local function judge_touch_began_area(x, y)
	m_touch_army_index, m_touch_hero_index, m_start_x_in_card, m_start_y_in_card = 0, 0, 0, 0

	local is_touch_enable_area = false
	local temp_point = nil
	for k,v in pairs(m_began_widget_list) do
		if v:hitTest(cc.p(x, y)) then
			m_select_widget = v
			m_touch_hero_index = tonumber(string.sub(v:getParent():getName(), 6))
			m_touch_army_index = tonumber(string.sub(v:getParent():getParent():getName(), 6))
			temp_point = v:convertToNodeSpace(cc.p(x,y))
			m_start_x_in_card = temp_point.x + v:getContentSize().width/2
			m_start_y_in_card = temp_point.y + v:getContentSize().height/2
			is_touch_enable_area = true
			break
		end
	end

	return is_touch_enable_area
end

local function judeg_touch_ended_area(x, y)
	local is_touch_enable_area, touch_army_index, touch_hero_index = false, 0, 0
	for k,v in pairs(m_ended_widget_list) do
		if v:hitTest(cc.p(x, y)) then
			touch_hero_index = tonumber(string.sub(v:getParent():getName(), 6))
			touch_army_index = tonumber(string.sub(v:getParent():getParent():getName(), 6))
			is_touch_enable_area = true
			break
		end
	end

	return is_touch_enable_area, touch_army_index, touch_hero_index
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

local function set_hzb_content(temp_army_id, temp_army_widget)
	local title_panel = tolua.cast(temp_army_widget:getChildByName("title_panel"), "Layout")

	local hzb_btn = tolua.cast(title_panel:getChildByName("hzb_btn"), "Button")
	local hao_img = tolua.cast(hzb_btn:getChildByName("h_light_img"), "ImageView")
	local zhen_img = tolua.cast(hzb_btn:getChildByName("z_light_img"), "ImageView")
	local bing_img = tolua.cast(hzb_btn:getChildByName("b_light_img"), "ImageView")

	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	local arms_state, camp_type, group_state = false, 0, false
	local icon_state_type = 0
	if temp_army_info then
		arms_state, camp_type, group_state = armySpecialData.get_addition_state_by_team(temp_army_id)
		icon_state_type = armyData.getTeamStateType(temp_army_id, m_city_id)
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

	local left_img = tolua.cast(title_panel:getChildByName("left_img"), "ImageView")
	local right_img = tolua.cast(title_panel:getChildByName("right_img"), "ImageView")
	local state_img = tolua.cast(title_panel:getChildByName("state_img"), "ImageView")
	if icon_state_type == 0 then
		left_img:setVisible(false)
		right_img:setVisible(false)
		state_img:setVisible(false)
	else
		left_img:setVisible(true)
		right_img:setVisible(true)
		state_img:loadTexture(ResDefineUtil.army_icon_res[icon_state_type][1], UI_TEX_TYPE_PLIST)
		state_img:setVisible(true)
	end

	local cost_txt = tolua.cast(hzb_btn:getChildByName("cost_num_label"), "Label")
	cost_txt:setText(armyData.getTeamCost(temp_army_id) .. "/" .. userCityData.getCityCostNums(m_city_id))

	local speed_panel = tolua.cast(title_panel:getChildByName("speed_panel"), "Layout")
	local destroy_panel = tolua.cast(title_panel:getChildByName("destroy_panel"), "Layout")
	local hero_min_speed, temp_army_speed = armyData.getTeamSpeed(temp_army_id)
	local temp_army_destroy = armyData.getTeamDestroy(temp_army_id)
	if temp_army_destroy == 0 then
		speed_panel:setVisible(false)
		destroy_panel:setVisible(false)
	else
		local add_speed_num = temp_army_speed - hero_min_speed
		local speed_base_txt = tolua.cast(speed_panel:getChildByName("base_label"), "Label")
		local speed_add_txt = tolua.cast(speed_panel:getChildByName("add_label"), "Label")
		speed_base_txt:setText(math.floor(hero_min_speed/100))
		if add_speed_num > 0 then
			speed_add_txt:setText("+" .. math.floor(add_speed_num/100))
			speed_add_txt:setPositionX(speed_base_txt:getPositionX() + speed_base_txt:getContentSize().width)
			speed_add_txt:setVisible(true)
		else
			speed_add_txt:setVisible(false)
		end

		local destroy_num_txt = tolua.cast(destroy_panel:getChildByName("num_label"), "Label")
		destroy_num_txt:setText(math.floor(temp_army_destroy/100))
	end
end

-- unopen_type 0 没有英雄 1 部队未开放 2 前锋未开放
local function set_unhero_content(hero_panel, unopen_type, temp_army_index)
	local hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
	local unhero_img = tolua.cast(hero_panel:getChildByName("unhero_img"), "ImageView")
	local info_img = tolua.cast(hero_panel:getChildByName("info_img"), "ImageView")

	local first_txt = tolua.cast(unhero_img:getChildByName("unopen_sign"), "Label")
	local second_txt = tolua.cast(unhero_img:getChildByName("unopen_label"), "Label")
	if unopen_type == 0 then
		first_txt:setVisible(false)
		second_txt:setPositionY(0)
		second_txt:setColor(ccc3(166,166,166))
		second_txt:setText(languagePack["weipeizhi"])
		table.insert(m_ended_widget_list, hero_img)
	else
		first_txt:setVisible(true)
		second_txt:setPositionY(-14)
		second_txt:setColor(ccc3(131, 57, 45))
		if unopen_type == 1 then
			second_txt:setText(Tb_cfg_build[cityBuildDefine.jiaochang].name .. "Lv." .. temp_army_index .. languagePack["kaifang"])
		else
			second_txt:setText(Tb_cfg_build[cityBuildDefine.dianjiangtai].name .. "Lv." .. temp_army_index .. languagePack["kaifang"])
		end
	end

	hero_img:setVisible(false)
	unhero_img:setVisible(true)
	info_img:setVisible(false)
end

local function set_hero_content(hero_panel, temp_army_id, hero_uid)
	local hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
	local unhero_img = tolua.cast(hero_panel:getChildByName("unhero_img"), "ImageView")
	local info_img = tolua.cast(hero_panel:getChildByName("info_img"), "ImageView")

	local hero_widget = tolua.cast(hero_img:getChildByName("hero_widget"), "Layout")
	cardFrameInterface.set_small_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid), false)
	local show_tips_type = heroData.get_hero_state_in_army(hero_uid)
	cardFrameInterface.set_hero_state(hero_widget, 3, show_tips_type)

	local cost_txt = tolua.cast(info_img:getChildByName("cost_label"), "Label")
	cost_txt:setText(heroData.getHeroCost(hero_uid))

	local hp_txt = tolua.cast(info_img:getChildByName("soldier_label"), "Label")
	hp_txt:setText(heroData.getHeroHp(hero_uid))

	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	if temp_army_info.state == armyState.normal then
		if show_tips_type == heroStateDefine.zengbing then
			GraySprite.create(hero_img)
		else
			table.insert(m_began_widget_list, hero_img)
		end
	else
		GraySprite.create(hero_img)
	end

	table.insert(m_ended_widget_list, hero_img)
	hero_img:setVisible(true)
	unhero_img:setVisible(false)
	info_img:setVisible(true)
end

local function set_army_pos_content(temp_army_index, temp_army_id, temp_army_widget)
	local hero_panel = nil
	local show_type, hero_uid = nil, nil
	for i=1,3 do
		hero_panel = tolua.cast(temp_army_widget:getChildByName("hero_" .. i), "Layout")
		show_type = 0
		if temp_army_index > m_army_nums then
			show_type = 1
		else
			if i == 3 and temp_army_index > m_front_nums then
				show_type = 2
			end
		end

		if show_type == 0 then
			hero_uid = armyData.getHeroIdInTeamAndPos(temp_army_id, i)
			if hero_uid == 0 then
				set_unhero_content(hero_panel, show_type, temp_army_index)
			else
				set_hero_content(hero_panel, temp_army_id, hero_uid)
			end
		else
			set_unhero_content(hero_panel, show_type, temp_army_index)
		end
	end
end

local function set_content_type(temp_army_widget, is_open)
	local title_panel = tolua.cast(temp_army_widget:getChildByName("title_panel"), "Layout")
	title_panel:setVisible(is_open)

	local hero_panel = nil
	for i=1,3 do
		hero_panel = tolua.cast(temp_army_widget:getChildByName("hero_" .. i), "Layout")
		hero_panel:setVisible(is_open)
	end

	local unopen_index_txt = tolua.cast(temp_army_widget:getChildByName("index_label"), "Label")
	unopen_index_txt:setVisible(not is_open)
	local unopen_txt = tolua.cast(temp_army_widget:getChildByName("unopen_label"), "Label")
	unopen_txt:setVisible(not is_open)
end

local function organize_army_info_by_index(index)
	local temp_army_id = m_city_id * 10 + index
	local army_widget = tolua.cast(m_bg_img:getChildByName("army_" .. index), "Layout")
	if index > m_army_nums then
		set_content_type(army_widget, false)
	else
		set_content_type(army_widget, true)
		set_hzb_content(temp_army_id, army_widget)
		set_army_pos_content(index, temp_army_id, army_widget)
	end
end

local function organize_all_army_info()
	m_army_nums, m_front_nums = buildData.get_army_param_info(m_city_id)
	m_began_widget_list = {}
	m_ended_widget_list = {}

	for i=1,ARMY_MAX_NUMS_IN_CITY do
		organize_army_info_by_index(i)
	end
end

local function create(temp_parent, temp_city_id)
	m_bg_img = temp_parent
	m_city_id = temp_city_id

	organize_all_army_info()
end

exchangeDragManager = {
						create = create,
						remove = remove,
						judge_touch_began_area = judge_touch_began_area,
						judeg_touch_ended_area = judeg_touch_ended_area,
						get_selected_hero_uid = get_selected_hero_uid,
						get_began_touch_info = get_began_touch_info,
						get_offset_in_card = get_offset_in_card,
						set_selected_state = set_selected_state,
						organize_all_army_info = organize_all_army_info
}