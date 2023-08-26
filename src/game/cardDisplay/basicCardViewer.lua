module("basicCardViewer",package.seeall)

local cardViewer = require("game/cardDisplay/cardViewer")
-- 类名    basicCardViewer
-- json名  wujikaxiangqing.json
-- ID 名   CARD_VIEWER_BASIC

local m_pMainLayer = nil
local m_fCallback = nil

local function do_remove_self()
	if m_pMainLayer then 
		if cardAddPoint then 
			cardAddPoint.remove_self() 
		end
		m_pMainLayer:getParent():setOpacity(150)
		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.CARD_VIEWER_BASIC)
        if m_fCallback and type(m_fCallback) == "function" then 
        	m_fCallback()
        end
        cardViewer.defaultCloseCallback()
	end
end

function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.CARD_VIEWER_BASIC,m_pMainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
	if cardViewer.dealwithTouchEvent(x,y,m_pMainLayer) then 
		return false
	else
		remove_self()
		return true
	end
end


-- bidList = {heroBid,heroBid,heroBid,heroBid,heroBid,heroBid}
function create(bidList,bid,callback,level)
	if m_pMainLayer then return end
	
	if not level then level = 1 end
	basicInfoOffset = {}
	basicInfoOffset.level = level

	m_pMainLayer = TouchGroup:create()
    cardViewer.setCardViewer2Layer( cardViewer.VIEW_TYPE_BASIC,bidList,bid,m_pMainLayer,remove_self,basicInfoOffset)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.CARD_VIEWER_BASIC)

    m_fCallback = callback

    uiManager.showConfigEffect(uiIndexDefine.CARD_VIEWER_BASIC,m_pMainLayer,function()
		m_pMainLayer:getParent():setOpacity(230)
	end)
end

