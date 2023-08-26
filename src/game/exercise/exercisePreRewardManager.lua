local m_layer = nil
local m_exercise_cfg_id = nil
local loginRewardHelper = nil

local function do_remove_self()
	if m_layer then
		m_exercise_cfg_id = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_PRE_REWARD_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_PRE_REWARD_UI, m_layer, do_remove_self)
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

local function init_event(temp_widget)
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local close_btn = tolua.cast(title_img:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)
end

local function init_reward_info(temp_widget)
	local reward_panel = tolua.cast(temp_widget:getChildByName("reward_panel"), "Layout")
	local reward_base = tolua.cast(reward_panel:getChildByName("reward_base_panel"), "Layout")

	local temp_reward_list = exerciseData.get_reward_list_by_exercise_id(m_exercise_cfg_id)
	local reward_content, icon_img, num_txt, receive_img = nil, nil, nil, nil
	local temp_index = 0
	for k,v in pairs(temp_reward_list) do
		reward_content = reward_base:clone()
		reward_content:setPosition(cc.p(32 + temp_index * 90, 16))
		receive_img = tolua.cast(reward_content:getChildByName("receive_img"), "ImageView")
		receive_img:setVisible(false)
		icon_img = tolua.cast(reward_content:getChildByName("icon_img"), "ImageView")
		icon_img:loadTexture(loginRewardHelper.getResIconByRewardType(v[1]),UI_TEX_TYPE_PLIST)
		num_txt = tolua.cast(reward_content:getChildByName("num_label"), "Label")
		num_txt:setText(v[2])
		reward_content:setVisible(true)
		reward_panel:addChild(reward_content)
		temp_index = temp_index + 1
	end
end

local function create(temp_cfg_id)
	if m_layer then
		return
	end

	if comGuideInfo then
		comGuideInfo.deal_with_guide_stop()
	end

	loginRewardHelper = require("game/daily/login_reward_helper")
	m_exercise_cfg_id = temp_cfg_id

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_3_1.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_event(temp_widget)
	init_reward_info(temp_widget)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.EXERCISE_PRE_REWARD_UI)
	uiManager.showConfigEffect(uiIndexDefine.EXERCISE_PRE_REWARD_UI, m_layer)
end

exercisePreRewardManager = {
							create = create,
							remove_self = remove_self,
							dealwithTouchEvent = dealwithTouchEvent

}