local m_layer = nil
local loginRewardHelper = nil

local function do_remove_self()
	if m_layer then
		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_REWARD_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_REWARD_UI, m_layer, do_remove_self)
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

local function deal_with_tips_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/exercise/exerciseFightDesManager")
		exerciseFightDesManager.create()
	end
end

local function init_event(temp_widget)
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local close_btn = tolua.cast(title_img:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)

	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"), "Button")
	confirm_btn:setTouchEnabled(true)
	confirm_btn:addTouchEventListener(deal_with_close_click)

	if not exerciseData.is_teach_type() then
		local condition_panel = tolua.cast(temp_widget:getChildByName("condition_panel"), "Layout")
		local tips_btn = tolua.cast(condition_panel:getChildByName("tips_btn"), "Button")
		tips_btn:setTouchEnabled(true)
		tips_btn:addTouchEventListener(deal_with_tips_click)
	end
end

local function init_condition_info(temp_widget)
	local condition_panel = tolua.cast(temp_widget:getChildByName("condition_panel"), "Layout")
	local content_txt = tolua.cast(condition_panel:getChildByName("content_label"), "Label")
	local temp_win_info = exerciseData.get_exercise_win_condition()
	for k,v in pairs(temp_win_info) do
		if v[2] == 0 then
			content_txt:setText(languagePack["condition_1"])
		else
			content_txt:setText(languagePack["condition_2"])
		end
		break
	end

	if not exerciseData.is_teach_type() then
		local con_panel = tolua.cast(condition_panel:getChildByName("con_panel"), "Layout")
		local num_txt_1 = tolua.cast(con_panel:getChildByName("num_label_1"), "Label")
		local num_txt_2 = tolua.cast(con_panel:getChildByName("num_label_2"), "Label")
		num_txt_1:setText(exerciseData.get_exercise_fight_num())
		num_txt_2:setText("X" .. exerciseData.get_reward_rate_num())
	end
end

local function init_reward_info(temp_widget)
	local reward_panel = tolua.cast(temp_widget:getChildByName("reward_panel"), "Layout")
	local reward_base = tolua.cast(reward_panel:getChildByName("reward_base_panel"), "Layout")

	local temp_rate = 1
	if not exerciseData.is_teach_type() then
		temp_rate = exerciseData.get_reward_rate_num()
	end

	local temp_reward_list = exerciseData.get_exercise_reward_list()
	local reward_content, icon_img, num_txt, receive_img = nil, nil, nil, nil
	local temp_index = 0
	for k,v in pairs(temp_reward_list) do
		reward_content = reward_base:clone()
		reward_content:setPosition(cc.p(32 + temp_index * 90, 16))
		receive_img = tolua.cast(reward_content:getChildByName("receive_img"), "ImageView")
		receive_img:setVisible(exerciseData.get_exercise_reward_state())
		icon_img = tolua.cast(reward_content:getChildByName("icon_img"), "ImageView")
		icon_img:loadTexture(loginRewardHelper.getResIconByRewardType(v[1]),UI_TEX_TYPE_PLIST)
		num_txt = tolua.cast(reward_content:getChildByName("num_label"), "Label")
		num_txt:setText(v[2] * temp_rate)
		reward_content:setVisible(true)
		reward_panel:addChild(reward_content)
		temp_index = temp_index + 1
	end
end

local function set_layout(temp_widget)
	local temp_offset = 64

	local bg_img = tolua.cast(temp_widget:getChildByName("bg_img"), "ImageView")
	local area_panel = tolua.cast(bg_img:getChildByName("area_panel"), "Layout")
	area_panel:setSize(CCSizeMake(area_panel:getSize().width, area_panel:getSize().height - temp_offset))
	bg_img:setSize(CCSizeMake(bg_img:getSize().width, bg_img:getSize().height - temp_offset))

	local content_bg_img = tolua.cast(temp_widget:getChildByName("content_bg_img"), "ImageView")
	content_bg_img:setSize(CCSizeMake(content_bg_img:getSize().width, content_bg_img:getSize().height - temp_offset))

	local condition_panel = tolua.cast(temp_widget:getChildByName("condition_panel"), "Layout")
	local con_panel = tolua.cast(condition_panel:getChildByName("con_panel"), "Layout")
	con_panel:setVisible(false)
	local tips_btn = tolua.cast(condition_panel:getChildByName("tips_btn"), "Button")
	tips_btn:setPositionY(tips_btn:getPositionY() - temp_offset)
	tips_btn:setVisible(false)
	local content_txt = tolua.cast(condition_panel:getChildByName("content_label"), "Label")
	content_txt:setPositionY(content_txt:getPositionY() - temp_offset)
	local title_com = tolua.cast(condition_panel:getChildByName("title_bg_img"), "ImageView")
	title_com:setPositionY(title_com:getPositionY() - temp_offset)
	condition_panel:setSize(CCSizeMake(condition_panel:getSize().width, condition_panel:getSize().height - temp_offset))

	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	title_img:setPositionY(title_img:getPositionY() - temp_offset)

	temp_widget:setSize(CCSizeMake(temp_widget:getSize().width, temp_widget:getSize().height - temp_offset))
end

local function create()
	if m_layer then
		return
	end

	if comGuideInfo then
		comGuideInfo.deal_with_guide_stop()
	end
	
	loginRewardHelper = require("game/daily/login_reward_helper")

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_3.json")
	temp_widget:setTag(999)
	if exerciseData.is_teach_type() then
		set_layout(temp_widget)
	end

	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_event(temp_widget)
	init_condition_info(temp_widget)
	init_reward_info(temp_widget)

	--临时屏蔽该按钮显示
	--local condition_panel = tolua.cast(temp_widget:getChildByName("condition_panel"), "Layout")
	--local tips_btn = tolua.cast(condition_panel:getChildByName("tips_btn"), "Button")
	--tips_btn:setVisible(false)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.EXERCISE_REWARD_UI)
	uiManager.showConfigEffect(uiIndexDefine.EXERCISE_REWARD_UI, m_layer)
end

exerciseRewardManager = {
							create = create,
							remove_self = remove_self,
							dealwithTouchEvent = dealwithTouchEvent

}