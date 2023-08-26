--在野同盟提示
module("NoUnionTipsUI", package.seeall)
local m_pMainLayer = nil
function do_remove_self(  )
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UNION_TIPS)
	end
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

function remove_self( )
	if not m_pMainLayer then return end
	uiManager.hideConfigEffect(uiIndexDefine.UNION_TIPS,m_pMainLayer,do_remove_self)
	-- uiManager.hideScaleEffect(m_pMainLayer,999,do_remove_self)
end

function create( )
	if m_pMainLayer then return end
	m_pMainLayer = TouchGroup:create()
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/tongmeng_zaiye.json")
	m_pMainLayer:addWidget(widget)
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UNION_TIPS)

	local closeBtn = tolua.cast(widget:getChildByName("Button_483354"),"Button")
	closeBtn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)
	uiManager.showConfigEffect(uiIndexDefine.UNION_TIPS,m_pMainLayer)
	-- uiManager.showScaleEffect(m_pMainLayer,999,nil,uiUtil.uiShowEffectDuration)
end