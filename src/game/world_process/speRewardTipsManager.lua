module("speRewardTipsManager",package.seeall)

local m_pMainLayer = nil

local function do_remove_self()
	if m_pMainLayer then 
        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil

        uiManager.remove_self_panel(uiIndexDefine.UI_SPE_REWARD_DETAIL)
    end
end

function remove_self()
	if m_pMainLayer then
   		uiManager.hideConfigEffect(uiIndexDefine.UI_SPE_REWARD_DETAIL,m_pMainLayer,do_remove_self)
   	end
end

function dealwithTouchEvent(x,y)
    if not m_pMainLayer then
    	return false
    end
  
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if mainWidget:hitTest(cc.p(x,y)) then
        return false
    else
        remove_self()
        return true
    end
end

function create(icon_name,des_content)
	if m_pMainLayer then
		return
	end

    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/spe_jiangli_tips.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    local icon_img = tolua.cast(mainWidget:getChildByName("icon_img"), "ImageView")
    icon_img:loadTexture(icon_name, UI_TEX_TYPE_PLIST)
    local des_txt = tolua.cast(mainWidget:getChildByName("des_label"), "Label")
    des_txt:setText(des_content)

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_SPE_REWARD_DETAIL)
end