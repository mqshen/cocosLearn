--同盟创建主界面
require("game/union/unionCreateData")
require("game/union/unionCreateUI")
require("game/union/unionJoin")
require("game/union/unionInviteNoUnion")

module("UnionCreateMainUI", package.seeall)
local m_pMainLayer = nil
local m_backPanel = nil
local m_pWidget = nil
local m_arrBtn = nil

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end
	return false
end

function unReadInviteData( flag )
	if m_pWidget then
		tolua.cast(m_pWidget:getChildByName("ImageView_218691_0"),"ImageView"):setVisible(flag) 
	end
end

local function removeTagData( )
	UnionJoin.remove_self()
	UnionInviteNoUnion.remove_self()
end

local function do_remove_self( )
	UnionCreateData.remove()
	if m_pMainLayer then
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end
		removeTagData()
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pWidget = nil
		m_arrBtn = nil
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.NO_UNION_UI)
	end
	
end
--todo ui界面管理重写后删除callback
function remove_self(callback)
    if not m_backPanel then return end
    local function callFunc( )
    	do_remove_self()
    	if callback then
    		callback()
    	end
    end
    uiManager.hideConfigEffect(uiIndexDefine.NO_UNION_UI,m_pMainLayer,callFunc,999,{m_backPanel:getMainWidget()})
    -- uiUtil.hideScaleEffect(m_backPanel:getMainWidget(),callFunc,uiUtil.DURATION_FULL_SCREEN_HIDE)
end

local function tagChange( index)
	local tagIndex = index or 1
	m_arrBtn[tagIndex]:setTouchEnabled(false)
	m_arrBtn[tagIndex]:setBright(false)
	m_arrBtn[tagIndex]:setTitleColor(ccc3(191,203,203))
	if tagIndex == 1 then
		m_backPanel:setColorVisible(true)
	else
		m_backPanel:setColorVisible(false)
	end

	if tagIndex == 3 then
		unReadInviteData(false)
	end

	for i=1, 3 do
		if i ~= tagIndex then
			m_arrBtn[i]:setTouchEnabled(true)
			m_arrBtn[i]:setBright(true)
			m_arrBtn[i]:setTitleColor(ccc3(109,109,109))
		end
	end
end

local function reload( index )
	if not m_pWidget then return end
	local tagIndex = index or 1
	tagChange( index)
	local panel = tolua.cast(m_pWidget:getChildByName("Panel_217494"),"Layout")
	removeTagData()
	panel:removeAllChildrenWithCleanup(true)
	if tagIndex == 1 then
		panel:addChild(UnionCreateUI.create())
	elseif tagIndex == 2 then
		panel:addChild(UnionJoin.create())
		UnionJoin.init()
	else
		panel:addChild(UnionInviteNoUnion.create())
		UnionInviteNoUnion.init()
	end
	UnionCreateData.setTagIndex(tagIndex)
end

function create(index )
	if m_pMainLayer then return end
	UnionCreateData.init()
	m_arrBtn = {}
	m_pMainLayer = TouchGroup:create()
	m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/alliance_create_main.json")
	m_pWidget:setTag(999)
	m_backPanel = UIBackPanel.new()
	local temp = m_backPanel:create(m_pWidget, remove_self, panelPropInfo[uiIndexDefine.NO_UNION_UI][2])
	-- m_pWidget:setTag(999)
	m_pMainLayer:addWidget(temp)
	local btn = nil
	for i=1, 3 do
		btn = tolua.cast(m_pWidget:getChildByName("btn_"..i),"Button")
		table.insert(m_arrBtn, btn)
		m_arrBtn[i]:addTouchEventListener(function ( sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				reload( i )
			end
		end)
	end
	unReadInviteData(false)
	reload(index)
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.NO_UNION_UI)
	uiManager.showConfigEffect(uiIndexDefine.NO_UNION_UI,m_pMainLayer,nil,999,{m_backPanel:getMainWidget()})
end