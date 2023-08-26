local m_layer = nil
local m_open_state = nil
local m_cfg_hero_list = nil

local function do_remove_self()
	if m_layer then
		m_open_state = nil
		m_cfg_hero_list = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_RECORD_ENEMY_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_RECORD_ENEMY_UI, m_layer, do_remove_self)
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

local function deal_with_icon_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getParent():getName(),6))
		if m_cfg_hero_list[select_index + 1] ~= cjson.null then
			require("game/cardDisplay/othersCardViewer")
			othersCardViewer.create(nil,m_cfg_hero_list[select_index + 1].heroid_u)
		end
	end
end

local function init_event(temp_widget)
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local close_btn = tolua.cast(title_img:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)
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


local function create(hero_cfg_list)
	if m_layer then
		return
	end

	m_cfg_hero_list = hero_cfg_list

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_2_1.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_event(temp_widget)
	init_army_info(temp_widget)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.EXERCISE_RECORD_ENEMY_UI)
	uiManager.showConfigEffect(uiIndexDefine.EXERCISE_RECORD_ENEMY_UI, m_layer)
end

local function set_army_id(temp_army_id)
	if m_open_state then
		return
	end

	m_open_state = true
	exerciseOpRequest.request_land_army(temp_army_id, 1)
end

exerciseRecordEnemyManager = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						set_army_id = set_army_id
}