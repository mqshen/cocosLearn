module("opArmyMoveConfirmNewbie", package.seeall)


-- 部队出征 新手确认
-- 类名 ：  opArmyMoveConfirmNewbie
-- json名：  actionCheckUI_2.json
-- 配置ID:	UI_OP_ARMY_MOVE_CONFIRM_NEWBIE

local m_pMainlayer = nil


local function do_remove_self()
	
	if m_pMainlayer then

		m_pMainlayer:removeFromParentAndCleanup(true)
		m_pMainlayer = nil

		uiManager.remove_self_panel(uiIndexDefine.UI_OP_ARMY_MOVE_CONFIRM_NEWBIE)
	end

end


function remove_self()
	if m_pMainlayer then 
		uiManager.hideConfigEffect(uiIndexDefine.UI_OP_ARMY_MOVE_CONFIRM_NEWBIE, m_pMainlayer, do_remove_self)
	end
end

function dealwithTouchEvent(x,y)
	if not m_pMainlayer then
		return false
	end

	local mainWidget = m_pMainlayer:getWidgetByTag(999)
	if mainWidget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end


function create(callback)
	if m_pMainlayer then return end

	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/xinshouchuzhentis.json")
	mainWidget:setTag(999)
	mainWidget:setScale(config.getgScale())
	mainWidget:ignoreAnchorPointForPosition(false)
	mainWidget:setAnchorPoint(cc.p(0.5,0.5))
	mainWidget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2 + 50 * config.getgScale()))

	m_pMainlayer = TouchGroup:create()
	m_pMainlayer:addWidget(mainWidget)
	uiManager.add_panel_to_layer(m_pMainlayer, uiIndexDefine.UI_OP_ARMY_MOVE_CONFIRM_NEWBIE,999)
	uiManager.showConfigEffect(uiIndexDefine.UI_OP_ARMY_MOVE_CONFIRM_NEWBIE, m_pMainlayer)

	local btn_cancel = uiUtil.getConvertChildByName(mainWidget,"btn_cancel")
	btn_cancel:setTouchEnabled(true)
	btn_cancel:addTouchEventListener(function(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
			armyMoveManager.remove_self()
		end
	end)

	local btn_ok = uiUtil.getConvertChildByName(mainWidget,"btn_ok")
	btn_ok:setTouchEnabled(true)
	btn_ok:addTouchEventListener(function(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
			if callback then callback() end
		end
	end)


end