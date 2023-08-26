local m_layer = nil

local function do_remove_self()
	if m_layer then
		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.ZB_QUEUE_DES_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.ZB_QUEUE_DES_UI, m_layer, do_remove_self)
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

local function create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/zbQueueDesUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.ZB_QUEUE_DES_UI)
	uiManager.showConfigEffect(uiIndexDefine.ZB_QUEUE_DES_UI, m_layer)
end

zbQueueDesManager = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent

}