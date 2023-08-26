module("othersCardViewer",package.seeall)

local cardViewer = require("game/cardDisplay/cardViewer")
-- 类名    othersCardViewer
-- json名  wujikaxiangqing.json
-- ID 名   CARD_VIEWER_OTHERS

local m_pMainLayer = nil
local m_fCallback = nil



local m_fCardViewDispose = nil




local function do_remove_self()
	if m_pMainLayer then 
		if m_fCardViewDispose then 
			m_fCardViewDispose()
			m_fCardViewDispose = nil
		end

		if cardAddPoint then 
			cardAddPoint.remove_self() 
		end
		m_pMainLayer:getParent():setOpacity(150)
		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.CARD_VIEWER_OTHERS)
        if m_fCallback and type(m_fCallback) == "function" then 
        	m_fCallback()
        end
        cardViewer.defaultCloseCallback()

	end
end

function remove_self()
	
	uiManager.hideConfigEffect(uiIndexDefine.CARD_VIEWER_OTHERS,m_pMainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
	if cardViewer.dealwithTouchEvent(x,y,m_pMainLayer) then 
		return false
	else
		remove_self()
		return true
	end
end


-- uidList = {heroUid,heroUid,heroUid,heroUid,heroUid}
function create(uidList,uid,callback)
	if m_pMainLayer then return end
	m_pMainLayer = TouchGroup:create()
    
    _m_fHeroCardUpdator,_m_fHeroCardDeleted,_m_fHeroCardAdded,m_fCardViewDispose = cardViewer.setCardViewer2Layer( cardViewer.VIEW_TYPE_OTHERS,uidList,uid,m_pMainLayer,remove_self)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.CARD_VIEWER_OTHERS)

    m_fCallback = callback


	uiManager.showConfigEffect(uiIndexDefine.CARD_VIEWER_OTHERS,m_pMainLayer,function()
		m_pMainLayer:getParent():setOpacity(230)
	end)

end







