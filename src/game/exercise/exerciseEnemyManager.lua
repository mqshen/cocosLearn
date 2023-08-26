local m_layer = nil
local m_land_index = nil
local m_cfg_hero_list = nil

local function do_remove_self()
	if m_layer then
		if comGuideInfo then
			comGuideInfo.deal_with_guide_stop()
		end

		m_land_index = nil
		m_cfg_hero_list = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_ENEMY_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_ENEMY_UI, m_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not m_layer then
		return false
	end

	local temp_widget = m_layer:getWidgetByTag(999)
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

local function deal_with_next_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		do_remove_self()
		require("game/exercise/exerciseArmy/exerciseArmyManager")
		exerciseArmyManager.create()
	end
end

local function deal_with_icon_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getParent():getName(),6))
		if m_cfg_hero_list[select_index + 1] ~= cjson.null then
			require("game/cardDisplay/othersCardViewer")
			othersCardViewer.create(nil,m_cfg_hero_list[select_index + 1].heroid_u)

			if comGuideInfo then
				comGuideInfo.deal_with_guide_stop()
			end
		end
	end
end

local function init_event(temp_widget)
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local close_btn = tolua.cast(title_img:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)

	local next_btn = tolua.cast(temp_widget:getChildByName("next_btn"), "Button")
	next_btn:setTouchEnabled(true)
	next_btn:addTouchEventListener(deal_with_next_click)
end

local function init_army_info(temp_widget)
	local army_img = tolua.cast(temp_widget:getChildByName("army_img"), "ImageView")

	local hero_base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	local hero_panel, icon_img, hero_widget = nil
	local hero_hp = 0
	for i=1,3 do
		hero_panel = tolua.cast(army_img:getChildByName("hero_" .. i), "Layout")
		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		icon_img:addTouchEventListener(deal_with_icon_click)
		icon_img:setTouchEnabled(true)

		if m_cfg_hero_list[i+1] ~= cjson.null then
			hero_widget = hero_base_widget:clone()
			hero_widget:ignoreAnchorPointForPosition(false)
			hero_widget:setAnchorPoint(cc.p(0.5,0.5))
			cardFrameInterface.set_middle_card_info(hero_widget, m_cfg_hero_list[i+1].heroid_u, m_cfg_hero_list[i+1].heroid)
			icon_img:addChild(hero_widget)

			hero_hp = hero_hp + m_cfg_hero_list[i+1].hp
		end
	end

	local all_txt = tolua.cast(army_img:getChildByName("num_label"), "Label")
	all_txt:setText(hero_hp)
end

local function init_condition_info(temp_widget)
	local condition_panel = tolua.cast(temp_widget:getChildByName("condition_panel"), "Layout")
	local temp_hero_nums, temp_soldier_nums = exerciseData.get_exercise_army_condition(m_land_index)

	local hero_txt = tolua.cast(condition_panel:getChildByName("num_label_1"), "Label")
	hero_txt:setText(temp_hero_nums)
	local soldier_txt = tolua.cast(condition_panel:getChildByName("num_label_2"), "Label")
	soldier_txt:setText(temp_soldier_nums)
end 

local function init_reward_info(temp_widget)
	local reward_panel = tolua.cast(temp_widget:getChildByName("reward_panel"), "Layout")
	local reward_base = tolua.cast(reward_panel:getChildByName("res_base_panel"), "Layout")

	local temp_reward_list = exerciseData.get_exercise_land_reward(m_land_index)
	local reward_content, sign_img, name_txt, num_txt = nil, nil, nil, nil
	local temp_index = 0
	for k,v in pairs(temp_reward_list) do
		reward_content = reward_base:clone()
		reward_content:setPosition(cc.p(22 + temp_index * 220, 14))
		sign_img = tolua.cast(reward_content:getChildByName("sign_img"), "ImageView")
		sign_img:loadTexture(ResDefineUtil.ui_res_icon[v[1]],UI_TEX_TYPE_PLIST)
		name_txt = tolua.cast(reward_content:getChildByName("name_label"), "Label")
		name_txt:setText(rewardName[v[1]])
		num_txt = tolua.cast(reward_content:getChildByName("num_label"), "Label")
		num_txt:setText(v[2])
		--45 表示name_txt的x坐标41 + 两个文本的间距4
		num_txt:setPositionX(45 + name_txt:getContentSize().width)
		reward_content:setVisible(true)
		reward_panel:addChild(reward_content)
		temp_index = temp_index + 1
	end
end

local function create(hero_cfg_list)
	if m_layer then
		return
	end

	m_cfg_hero_list = hero_cfg_list

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_2.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_event(temp_widget)
	init_condition_info(temp_widget)
	init_army_info(temp_widget)
	init_reward_info(temp_widget)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.EXERCISE_ENEMY_UI)
	uiManager.showConfigEffect(uiIndexDefine.EXERCISE_ENEMY_UI, m_layer)
end

local function set_land_index(temp_index)
	if m_land_index then
		return
	end
	m_land_index = temp_index

	if comGuideInfo then
		comGuideInfo.deal_with_guide_stop()
	end

	if exerciseData.get_teach_phase() == 1 then
		if m_land_index == exerciseData.get_born_pos() then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3005)
		end
	end
	
	local temp_army_id = exerciseData.get_exercise_land_army_id(temp_index)
	exerciseOpRequest.request_next_land(temp_index)
	exerciseOpRequest.request_land_army(temp_army_id, 0)
end

local function get_guide_widget(temp_guide_id)
	if not m_layer then
		return nil
	end

	return m_layer:getWidgetByTag(999)
end

local function get_com_guide_widget(temp_guide_id)
	if not m_layer then
		return nil
	end

	return m_layer:getWidgetByTag(999)
end

exerciseEnemyManager = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						get_guide_widget = get_guide_widget,
						get_com_guide_widget = get_com_guide_widget,
						set_land_index = set_land_index
}