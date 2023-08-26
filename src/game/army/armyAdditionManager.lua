local army_addition_layer = nil
local m_is_army_state = nil
local m_army_id = nil
local m_base_hero_uid = nil
local m_middle_hero_uid = nil
local m_front_hero_uid = nil

local function do_remove_self()
	if army_addition_layer then
		m_army_id = nil
		m_is_army_state = nil
		m_base_hero_uid = nil
		m_middle_hero_uid = nil
		m_front_hero_uid = nil

		army_addition_layer:removeFromParentAndCleanup(true)
		army_addition_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.ARMY_ADDITION_UI)
	end
end

local function remove_self()
	if army_addition_layer then
		uiManager.hideConfigEffect(uiIndexDefine.ARMY_ADDITION_UI, army_addition_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not army_addition_layer then
		return false
	end

	local temp_widget = army_addition_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_close_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function set_cell_content(temp_panel, title_content, hero_content, tips_content, prop_type, prop_list)
	local name_txt = tolua.cast(temp_panel:getChildByName("name_label"), "Label")
	name_txt:setText(title_content)

	local prop_txt = nil
	for i=1,8 do
		prop_txt = tolua.cast(temp_panel:getChildByName("prop_" .. i), "Label")
		prop_txt:setVisible(false)
	end

	local hero_sign_txt = tolua.cast(temp_panel:getChildByName("hero_sign_label"), "Label")
	local hero_txt = tolua.cast(temp_panel:getChildByName("hero_label"), "Label")
	local tips_txt = tolua.cast(temp_panel:getChildByName("tips_label"), "Label")

	local content_lines = 0
	if prop_type == 0 then
		hero_sign_txt:setVisible(false)
		hero_txt:setVisible(false)
		content_lines = 2
		tips_txt:setText(tips_content)
	else
		tips_txt:setVisible(false)
		for i,v in ipairs(prop_list) do
			prop_txt = tolua.cast(temp_panel:getChildByName("prop_" .. i), "Label")
			prop_txt:setText(v)
			prop_txt:setVisible(true)
		end
		hero_txt:setText(hero_content)

		if #prop_list > 4 then
			content_lines = 3
		else
			content_lines = 2	
		end
	end

	if content_lines == 2 then
		hero_sign_txt:setPositionY(-110)
		hero_txt:setPositionY(-110)
		temp_panel:setSize(CCSize(660, 137))
	end
end

local function orgainze_arms_content()
	local temp_widget = army_addition_layer:getWidgetByTag(999)
	local arms_panel = tolua.cast(temp_widget:getChildByName("bz_panel"), "ImageView")
	local arms_type, prop_list, hero_content = nil, nil, nil
	if m_is_army_state then
		arms_type, prop_list, hero_content = armySpecialData.get_arms_addition_by_team(m_army_id)
	else
		arms_type, prop_list, hero_content = armySpecialData.get_arms_addition_by_heros(m_base_hero_uid, m_middle_hero_uid, m_front_hero_uid)
	end

	local title_content = nil
	if arms_type == 0 then
		title_content = languagePack["arms_title"]
	else
		title_content = languagePack["arms_title"] .. "-" .. heroTypeName[arms_type]

	end

	set_cell_content(arms_panel, title_content, hero_content, languagePack["arms_tips"], arms_type, prop_list)
end

local function orgainze_camp_content()
	local temp_widget = army_addition_layer:getWidgetByTag(999)
	local camp_panel = tolua.cast(temp_widget:getChildByName("zy_panel"), "ImageView")
	local camp_type, prop_list, hero_content = nil, nil, nil
	if m_is_army_state then
		camp_type, prop_list, hero_content = armySpecialData.get_camp_addition_by_team(m_army_id)
	else
		local temp_city_id = userData.getMainPos()
		camp_type, prop_list, hero_content = armySpecialData.get_camp_addition_by_heros(temp_city_id, m_base_hero_uid, m_middle_hero_uid, m_front_hero_uid)
		--演武的部队不计算阵营加成（策划需求）
		camp_type = 0
	end

	local title_content = nil
	if camp_type == 0 then
		title_content = languagePack["camp_title"]
	else
		title_content = languagePack["camp_title"] .. "-" .. countryNameDefine[camp_type]
	end

	if m_is_army_state then
		set_cell_content(camp_panel, title_content, hero_content, languagePack["camp_tips"], camp_type, prop_list)
	else
		set_cell_content(camp_panel, title_content, hero_content, languagePack["exercise_camp_tips"], camp_type, prop_list)
	end
end

local function orgainze_wj_group_content()
	local temp_widget = army_addition_layer:getWidgetByTag(999)
	local wj_group_panel = tolua.cast(temp_widget:getChildByName("wj_panel"), "ImageView")
	local wj_group_type, prop_list, hero_content = nil, nil, nil
	if m_is_army_state then
		wj_group_type, prop_list, hero_content = armySpecialData.get_group_addition_by_team(m_army_id)
	else
		wj_group_type, prop_list, hero_content = armySpecialData.get_group_addition_by_heros(m_base_hero_uid, m_middle_hero_uid, m_front_hero_uid)
	end

	local title_content = nil
	if wj_group_type == 0 then
		title_content = languagePack["wj_group_title"]
	else
		title_content = languagePack["wj_group_title"] .. "-" .. Tb_cfg_army_title[wj_group_type].title
	end

	set_cell_content(wj_group_panel, title_content, hero_content, languagePack["wj_group_tips"], wj_group_type, prop_list)
end

local function reset_layout()
	local temp_widget = army_addition_layer:getWidgetByTag(999)
	local bg_img = tolua.cast(temp_widget:getChildByName("bg_img"), "ImageView")
	local content_img = tolua.cast(temp_widget:getChildByName("content_img"), "ImageView")
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	local arms_panel = tolua.cast(temp_widget:getChildByName("bz_panel"), "ImageView")
	local camp_panel = tolua.cast(temp_widget:getChildByName("zy_panel"), "ImageView")
	local wj_group_panel = tolua.cast(temp_widget:getChildByName("wj_panel"), "ImageView")

	local frame_dis = 26 	--上下边框的间距
	local cell_dis = 0
	local wj_group_pos_y = frame_dis + wj_group_panel:getSize().height
	wj_group_panel:setPositionY(wj_group_pos_y)
	local camp_pos_y = wj_group_pos_y + cell_dis + camp_panel:getSize().height
	camp_panel:setPositionY(camp_pos_y)
	local arms_pos_y = camp_pos_y + cell_dis + arms_panel:getSize().height
	arms_panel:setPositionY(arms_pos_y)
	content_img:setSize(CCSize(content_img:getSize().width, arms_pos_y - frame_dis))
	content_img:setPositionY((arms_pos_y - frame_dis)/2 + frame_dis)

	local title_height = title_img:getSize().height
	local title_pos_y = arms_pos_y + cell_dis + title_height/2
	title_img:setPositionY(title_pos_y)
	close_btn:setPositionY(title_pos_y + title_height/2 + 7)

	local panel_height = title_pos_y + title_height/2 + frame_dis
	bg_img:setSize(CCSize(716, panel_height))
	--content_img:setSize(CCSize(666, panel_height))
	--title_img:setPositionY(panel_height - 30)
	--close_btn:setPositionY(panel_height)
	temp_widget:setSize(CCSize(716, panel_height))
end

local function orgainze_show_content()
	orgainze_arms_content()
	orgainze_camp_content()
	orgainze_wj_group_content()

	reset_layout()
end

local function create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/teamAdditionUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	close_btn:addTouchEventListener(deal_with_close_click)
	close_btn:setTouchEnabled(true)

	army_addition_layer = TouchGroup:create()
	army_addition_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(army_addition_layer, uiIndexDefine.ARMY_ADDITION_UI)
	uiManager.showConfigEffect(uiIndexDefine.ARMY_ADDITION_UI, army_addition_layer)
end

local function enter_addition_by_army(new_id)
	m_is_army_state = true
	m_army_id = new_id
	create()
	orgainze_show_content()
end

local function enter_addition_by_heros(hero_uid_1, hero_uid_2, hero_uid_3)
	m_is_army_state = false
	m_base_hero_uid = hero_uid_1
	m_middle_hero_uid = hero_uid_2
	m_front_hero_uid = hero_uid_3
	create()
	orgainze_show_content()
end

armyAdditionManager = {
						enter_addition_by_army = enter_addition_by_army,
						enter_addition_by_heros = enter_addition_by_heros,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent

}