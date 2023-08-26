local m_main_widget = nil
local m_fight_anim = nil

local function remove()
	m_main_widget = nil
	m_fight_anim:getAnimation():stop()
	m_fight_anim = nil
end

local function deal_with_hzb_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/army/armyAdditionManager")
		local base_hero_uid = exerciseData.get_hero_by_index(1)
		local middle_hero_uid = exerciseData.get_hero_by_index(2)
		local front_hero_uid = exerciseData.get_hero_by_index(3)
		armyAdditionManager.enter_addition_by_heros(base_hero_uid, middle_hero_uid, front_hero_uid)
	end
end

local function update_anim_state()
	local temp_land_index = exerciseMapManager.get_select_land_index()
	local temp_hero_nums = exerciseData.get_exercise_army_condition(temp_land_index)

	if exerciseData.get_hero_nums_in_army() == temp_hero_nums then
		if not m_fight_anim:isVisible() then
			m_fight_anim:getAnimation():playWithIndex(0)
        	m_fight_anim:setVisible(true)
		end
	else
		if m_fight_anim:isVisible() then
			m_fight_anim:getAnimation():stop()
			m_fight_anim:setVisible(false)
		end
	end
end

local function set_hzb_content()
	local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")
	local hzb_btn = tolua.cast(title_panel:getChildByName("hzb_btn"), "Button")

	local show_cost_num, max_cost_num = exerciseData.get_sum_cost_in_exercise()
	local cost_txt = tolua.cast(hzb_btn:getChildByName("cost_num_label"), "Label")
	cost_txt:setText(show_cost_num .. "/" .. max_cost_num)

	local equip_hero_nums = exerciseData.get_hero_nums_in_army()
	local temp_land_index = exerciseMapManager.get_select_land_index()
	local temp_hero_nums, temp_soldier_nums = exerciseData.get_exercise_army_condition(temp_land_index)
	local soldier_img = tolua.cast(title_panel:getChildByName("soldier_img"), "ImageView")
	local soldier_num_txt = tolua.cast(soldier_img:getChildByName("num_label"), "Label")
	soldier_num_txt:setText(equip_hero_nums*temp_soldier_nums)
	
	local hao_img = tolua.cast(hzb_btn:getChildByName("h_light_img"), "ImageView")
	local zhen_img = tolua.cast(hzb_btn:getChildByName("z_light_img"), "ImageView")
	local bing_img = tolua.cast(hzb_btn:getChildByName("b_light_img"), "ImageView")

	local temp_city_id = userData.getMainPos()
	local base_hero_uid = exerciseData.get_hero_by_index(1)
	local middle_hero_uid = exerciseData.get_hero_by_index(2)
	local front_hero_uid = exerciseData.get_hero_by_index(3)
	local arms_state, camp_type, group_state = armySpecialData.get_addition_state_by_heros(temp_city_id, base_hero_uid, middle_hero_uid, front_hero_uid)
	--演武的部队不计算阵营加成（策划需求）
	local camp_state = false

	hzb_btn:loadTextures(ResDefineUtil.army_title_res[camp_type][1], ResDefineUtil.army_title_res[camp_type][2], "", UI_TEX_TYPE_PLIST)
	if arms_state then
		bing_img:loadTexture(ResDefineUtil.army_title_res[camp_type][5], UI_TEX_TYPE_PLIST)
	end
	if group_state then
		hao_img:loadTexture(ResDefineUtil.army_title_res[camp_type][4], UI_TEX_TYPE_PLIST)
	end

	hao_img:setVisible(group_state)
	zhen_img:setVisible(camp_state)
	bing_img:setVisible(arms_state)
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

local function init_fight_anim()
	local fight_btn = tolua.cast(m_main_widget:getChildByName("fight_btn"), "Button")
	local scale_value = config.getgScale()

    m_fight_anim = CCArmature:create("35_renwu")
    m_fight_anim:setScale(scale_value)
    m_fight_anim:setPosition(cc.p(fight_btn:getPositionX() - (fight_btn:getSize().width/2 - 8)*scale_value, fight_btn:getPositionY() + fight_btn:getSize().height/2*scale_value))
    m_fight_anim:setVisible(false)
    m_main_widget:addChild(m_fight_anim)
end

local function create(temp_widget, scene_width, scene_height)
	m_main_widget = temp_widget

	init_title_panel_info(scene_height)
	set_hzb_content()

	init_fight_anim()
	update_anim_state()
end

exerciseArmyBaseManager = {
					create = create,
					remove = remove,
					set_hzb_content = set_hzb_content,
					update_anim_state = update_anim_state
}