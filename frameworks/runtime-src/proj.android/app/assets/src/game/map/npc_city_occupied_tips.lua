module("NpcCityOccupiedTips", package.seeall)
-- 玩家内政
-- 类名 ：  NpcCityOccupiedTips
-- json名：  shouzhanjiangl_3.json
-- 配置ID:	UI_NPC_CITY_OCCUPIED_TIPS




local function do_remove_self()

    if m_pMainLayer then
        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_NPC_CITY_OCCUPIED_TIPS)
    end

    
end

function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.UI_NPC_CITY_OCCUPIED_TIPS,m_pMainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
    if not m_pMainLayer then return false end

    local widget = m_pMainLayer:getWidgetByTag(999)
    if not widget then return false end
    if widget:hitTest(cc.p(x,y)) then 
        return false
    else
        remove_self()
        return true
    end
end

function create( viewIndx )
	if m_pMainLayer then return end
    
   
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/shouzhanjiangl_3.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_NPC_CITY_OCCUPIED_TIPS)



    local btn_close = uiUtil.getConvertChildByName(widget,"btn_close")
	btn_close:setTouchEnabled(true)
	btn_close:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			remove_self()
		end
	end)

	-- TODOTK   NPC_CITY_OCCUPY_DURIBILITY_RATIO
	-- for i = 1,3 do 
	-- 	local label_rate = uiUtil.getConvertChildByName(widget,"label_rate_" .. i )
	-- 	label_rate:setText(math.floor(NPC_CITY_OCCUPY_KILL_REWARD_RATIO[i] / 100))
	-- end

    uiManager.showConfigEffect(uiIndexDefine.UI_NPC_CITY_OCCUPIED_TIPS,m_pMainLayer)


end