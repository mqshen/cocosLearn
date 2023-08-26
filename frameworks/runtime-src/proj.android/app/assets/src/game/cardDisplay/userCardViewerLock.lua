module("userCardViewerLock",package.seeall)

local cardViewer = require("game/cardDisplay/cardViewer")
-- 类名    userCardViewerLock
-- json名  wujikaxiangqing.json
-- ID 名   CARD_VIEWER_USER_LOCK

local m_pMainLayer = nil
local m_fCallback = nil
local m_fHeroCardUpdator = nil
local m_fHeroCardDeleted = nil
local m_fHeroCardAdded = nil
local m_fCardViewDispose = nil

local function dealWitHeroCardDeleted(packet)
	if m_fHeroCardDeleted then 
		m_fHeroCardDeleted(packet)
	end
end

-- 这个不需要处理
local function dealWitHeroCardAdded(packet)
	-- config.dump({...})
end
local function dealWithCardUpdate(packet)
	if m_fHeroCardUpdator then 
		m_fHeroCardUpdator(packet.heroid_u)
	end
end

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
        uiManager.remove_self_panel(uiIndexDefine.CARD_VIEWER_USER_LOCK)
        if m_fCallback and type(m_fCallback) == "function" then 
        	m_fCallback()
        end
        -- cardViewer.defaultCloseCallback()

        m_fHeroCardUpdator = nil
        m_fHeroCardDeleted = nil
        m_fHeroCardAdded = nil

	end
end

function remove_self()
	if m_pMainLayer then 
		UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, dealWithCardUpdate)
        UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.add, dealWitHeroCardAdded)
		UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.remove, dealWitHeroCardDeleted)
    end
	uiManager.hideConfigEffect(uiIndexDefine.CARD_VIEWER_USER_LOCK,m_pMainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
	if cardViewer.dealwithTouchEvent(x,y,m_pMainLayer) then 
		return false
	else
		remove_self()
		return true
	end
end


function create(uidList,uid,callback)
	if m_pMainLayer then return end


	m_pMainLayer = TouchGroup:create()
    
    m_fHeroCardUpdator,m_fHeroCardDeleted,m_fHeroCardAdded,m_fCardViewDispose = cardViewer.setCardViewer2Layer( cardViewer.VIEW_TYPE_USER_LOCK,uidList,uid,m_pMainLayer,remove_self)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.CARD_VIEWER_USER_LOCK)
    m_fCallback = callback

    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, dealWithCardUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.remove, dealWitHeroCardDeleted)
	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.add, dealWitHeroCardAdded)

	uiManager.showConfigEffect(uiIndexDefine.CARD_VIEWER_USER_LOCK,m_pMainLayer,function()
		m_pMainLayer:getParent():setOpacity(230)
	end)
end






