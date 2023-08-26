local m_layer = nil
local m_diff_lv = nil 		--当前开放的难度

local function do_remove_self()
	if m_layer then
		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_DIFFICULT_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_DIFFICULT_UI, m_layer, do_remove_self)
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

local function deal_with_diff_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getParent():getName(),6))
		if select_index <= m_diff_lv then
			exerciseOpRequest.request_next_exercise(select_index)
			remove_self()
		end
	end
end

local function init_difficult_info(temp_widget)
	local diff_img = tolua.cast(temp_widget:getChildByName("diff_img"), "ImageView")
	local diff_panel, des_txt, touch_btn, touch_img = nil, nil

	for i=1,4 do
		diff_panel = tolua.cast(diff_img:getChildByName("diff_" .. i), "Layout")
		des_txt = tolua.cast(diff_panel:getChildByName("des_label"), "Label")
		des_txt:setText(exerciseData.get_exercise_des_info(i))
		if i > m_diff_lv then
			touch_img = tolua.cast(diff_panel:getChildByName("img_1"), "ImageView")
			touch_img:setTouchEnabled(true)
			touch_img:addTouchEventListener(deal_with_diff_click)
			GraySprite.create(diff_panel)
		else
			touch_btn = tolua.cast(diff_panel:getChildByName("touch_btn"), "Button")
			touch_btn:setTouchEnabled(true)
			touch_btn:addTouchEventListener(deal_with_diff_click)
		end
	end
end

local function deal_with_enter_guide()
	local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[4])
	if show_sign == 0 then
		newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3026)
		CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[4], 1)
	end
end

local function create()
	if m_layer then
		return
	end

	m_diff_lv = exerciseData.get_exercise_difficult()
	if m_diff_lv == 0 then
		m_diff_lv = nil
		return
	end

	deal_with_enter_guide()

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_11.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local close_btn = tolua.cast(title_img:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)

	init_difficult_info(temp_widget)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.EXERCISE_DIFFICULT_UI)
	uiManager.showConfigEffect(uiIndexDefine.EXERCISE_DIFFICULT_UI, m_layer)
end

exerciseDifficultManager = {
							create = create,
							remove_self = remove_self,
							dealwithTouchEvent = dealwithTouchEvent
}