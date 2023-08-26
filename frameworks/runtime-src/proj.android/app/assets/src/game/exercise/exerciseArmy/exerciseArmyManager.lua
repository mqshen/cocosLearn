local m_whole_layer = nil
local m_main_widget = nil

local function do_remove_self()
	exerciseArmyBaseManager.remove()
	exerciseArmyHeroManager.remove()
	exerciseArmySetManager.remove()

	m_main_widget = nil
	m_whole_layer:removeFromParentAndCleanup(true)
	m_whole_layer = nil

	uiManager.remove_self_panel(uiIndexDefine.EXERCISE_ARMY_OVERVIEW_UI)

	UIUpdateManager.remove_prop_update(dbTableDesList.user_exercise.name, dataChangeType.update, exerciseArmyManager.deal_with_exercise_update)
end

local function remove_self()
	if m_whole_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_ARMY_OVERVIEW_UI, m_whole_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x, y)
	return false
end

local function deal_with_return_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function deal_with_fight_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_base_uid = exerciseData.get_hero_by_index(1)
		if temp_base_uid == 0 then
			tipsLayer.create(errorTable[506])
		else
			remove_self()
			exerciseOpRequest.request_fight()
		end
	end
end

local function set_component_layout(scene_width, scene_height)
	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	bg_img:loadTexture(ResDefineUtil.army_set_res[2], UI_TEX_TYPE_LOCAL)
	local temp_img_scale = scene_height/bg_img:getContentSize().height
	bg_img:setScale(temp_img_scale)
	bg_img:setPosition(cc.p(scene_width/2, scene_height/2))

	local fight_btn = tolua.cast(m_main_widget:getChildByName("fight_btn"), "Button")
	fight_btn:setPosition(cc.p(scene_width, scene_height/2))
	fight_btn:addTouchEventListener(deal_with_fight_click)
	fight_btn:setTouchEnabled(true)
	local money_txt = tolua.cast(fight_btn:getChildByName("money_label"), "Label")
	money_txt:setText(EXERSICE_MONEY_COST)
	tolua.cast(money_txt:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)

	local return_btn = tolua.cast(m_main_widget:getChildByName("return_btn"), "Button")
	return_btn:setPosition(cc.p(scene_width, scene_height))
	return_btn:addTouchEventListener(deal_with_return_click)
	return_btn:setTouchEnabled(true)
end

local function set_component_scale()
	local scale_num = config.getgScale()
	local scale_list = {{"title_panel", "Layout"}, {"hero_1", "Layout"}, {"hero_2", "Layout"}, {"hero_3", "Layout"},
								{"fight_btn", "Button"}, {"return_btn", "Button"}}

	local temp_component = nil
	for k,v in pairs(scale_list) do
		temp_component = tolua.cast(m_main_widget:getChildByName(v[1]), v[2])
		temp_component:setScale(scale_num)
	end
end

local function deal_with_enter_guide()
	if exerciseData.get_teach_phase() == 5 then
		if exerciseData.get_exercise_coordinate() == exerciseData.get_born_pos() then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3015)
		end
	end
end

local function create()
	if m_whole_layer then
		return
	end

	require("game/exercise/exerciseArmy/exerciseArmyBaseManager")
	require("game/exercise/exerciseArmy/exerciseArmyHeroManager")
	require("game/exercise/exerciseArmy/exerciseArmySetManager")

	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_5.json")
	m_main_widget:setTag(999)
	m_main_widget:setSize(CCSizeMake(scene_width, scene_height))
	m_main_widget:setTouchEnabled(true)

	set_component_layout(scene_width, scene_height)
	set_component_scale()

	exerciseArmyBaseManager.create(m_main_widget, scene_width, scene_height)
	exerciseArmyHeroManager.create(m_main_widget)
	exerciseArmySetManager.create(m_main_widget)

	m_whole_layer = TouchGroup:create()
	m_whole_layer:addWidget(m_main_widget)

    uiManager.add_panel_to_layer(m_whole_layer, uiIndexDefine.EXERCISE_ARMY_OVERVIEW_UI)

    UIUpdateManager.add_prop_update(dbTableDesList.user_exercise.name, dataChangeType.update, exerciseArmyManager.deal_with_exercise_update)

    deal_with_enter_guide()
end

local function deal_with_exercise_update(package)
	if package.front_heroid_u or package.middle_heroid_u or package.base_heroid_u then
		exerciseArmyBaseManager.set_hzb_content()
		exerciseArmyBaseManager.update_anim_state()
		exerciseArmyHeroManager.organize_show_content()
		exerciseArmySetManager.deal_with_hero_change()
	end
end

local function get_guide_widget(temp_guide_id)
	return m_main_widget
end

exerciseArmyManager = {
					create = create,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent,
					get_guide_widget = get_guide_widget,
					deal_with_exercise_update = deal_with_exercise_update
}