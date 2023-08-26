
local m_pMainLayer = nil


local function do_remove_self()
	if m_pMainLayer then 
		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_CARD_TIPS_INTRO)
	end
end

function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.UI_CARD_TIPS_INTRO,m_pMainLayer,do_remove_self)
end

local function dealwithTouchEvent(x,y)
    if not m_pMainLayer then return false end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return false end
    if mainWidget:hitTest(cc.p(x,y)) then 
        return false
    else
        remove_self()
        return true
    end
end

function show()
	if m_pMainLayer then return end
	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/card_tips_intro.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    mainWidget:setTouchEnabled(true)

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_CARD_TIPS_INTRO)
    uiManager.showConfigEffect(uiIndexDefine.CARD_HERO_GROW_DETAIL,m_pMainLayer)
end




CARD_TIPS_INTRO = {
    show = show,
    remove_self = remove_self,
    dealwithTouchEvent = dealwithTouchEvent,
}