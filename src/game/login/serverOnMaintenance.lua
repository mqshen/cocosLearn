-- serverOnMaintenance
-- 服务器维护的弹出通知
local ServerOnMaintenance = {}
function ServerOnMaintenance.create()
	local layer = TouchGroup:create()
	local layout = Layout:create()
	layout:setSize(CCSize(configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height))
	layout:setContentSize(CCSize(configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height))
	layout:setTouchEnabled(true)

	layer:addWidget(layout)
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/serverOnMaintenance.json")
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	widget:setScale(configBeforeLoad.getgScale())
	layout:addChild(widget)

	local text = tolua.cast(widget:getChildByName("Label_589931"),"Label")
	text:setText(languageBeforeLogin["serverMaintenance"])

	local btn = tolua.cast(widget:getChildByName("Button_939294"),"Button")
	btn:setTouchEnabled(true)
	btn:addTouchEventListener(function ( sender,eventType )
		if eventType == TOUCH_EVENT_ENDED then
			layer:removeFromParentAndCleanup(true)
		end
	end)
	return layer
end

return ServerOnMaintenance