module("UserOfficial", package.seeall)
-- 玩家内政
-- 类名 ：  UserOfficial
-- json名：  neizenjiem_001.json
-- 配置ID:	UI_USER_OFFICIAL

local m_pMainLayer = nil
local m_backPanel = nil
local m_iSelectedIndx = nil

local m_bIsSwitching = nil

local VIEW_TOTAL_INDX_NUM = 5
local VIEW_INDX_TAX = 1 -- 税收
local VIEW_INDX_TRADE = 2 -- 交易
local VIEW_INDX_MOVE_CITY = 3 -- 迁城
local VIEW_INDX_RANGER = 4 -- 流浪

local VIEW_INDX_STRONG_HOLD = 5 -- 坚守

local viewTitle = {}
viewTitle[VIEW_INDX_TAX] = languagePack['userOfficialTitle_tax']
viewTitle[VIEW_INDX_TRADE] = languagePack['userOfficialTitle_trade']
viewTitle[VIEW_INDX_STRONG_HOLD] = languagePack['userOfficialTitle_strongHold']
viewTitle[VIEW_INDX_MOVE_CITY] = languagePack['userOfficialTitle_moveCity']
viewTitle[VIEW_INDX_RANGER] = languagePack['userOfficialTitle_ranger']


local viewOfficialRanger = require("game/option/view_official_ranger")
local userOfficialGuard = require("game/option/userOfficialGuard")
local userOfficialMoveCity = require("game/option/userOfficialMoveCity")
local function do_remove_self()
	if m_pMainLayer then 

		TaxUI.remove_self()
		UIResourceTrade.remove_self()
		viewOfficialRanger.remove_self()
		userOfficialGuard.remove_self()
		userOfficialMoveCity.remove_self()
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end

		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil

        m_iSelectedIndx = nil
        m_bIsSwitching = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_USER_OFFICIAL)
	end
end


function remove_self(closeEffect)
	if closeEffect then 
		do_remove_self()
		return 
	end
	if m_backPanel then
    	uiManager.hideConfigEffect(uiIndexDefine.UI_USER_OFFICIAL, m_pMainLayer, do_remove_self, 999, {m_backPanel:getMainWidget()})
    end
end


local function checkTradeOpenState()
	return politics.getUserMarketNum() > 0
end



local function checkViewOpenState(indx)

end

function dealwithTouchEvent(x,y)
	return false
end


local function reloadData()
	if not m_pMainLayer then return end
end



local function createViewByIndx(indx,callback)
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)

	local panel_container = uiUtil.getConvertChildByName(mainWidget,"panel_container")

	local view = uiUtil.getConvertChildByName(panel_container,"view_" .. indx)
	if view then return end

	if indx == VIEW_INDX_TAX then 
		view = TaxUI.getInstance()
	elseif indx == VIEW_INDX_TRADE then 
		view = UIResourceTrade.getInstance()
	elseif indx == VIEW_INDX_RANGER then 
		view = viewOfficialRanger.getInstance()
	elseif indx == VIEW_INDX_STRONG_HOLD then 
		view = userOfficialGuard.getInstance()
	elseif indx == VIEW_INDX_MOVE_CITY then 
		view = userOfficialMoveCity.getInstance()
	else
		
	end

	if view then 
		view:ignoreAnchorPointForPosition(false)
		view:setAnchorPoint(cc.p(0.5, 0.5))
		view:setName("view_" .. indx)
		view:setPosition(cc.p(panel_container:getContentSize().width/2,panel_container:getContentSize().height/2))
		panel_container:addChild(view)
	end

end

local function setVisibleByIndx(indx,flag)
	if not m_pMainLayer then return end
	if not indx then return end
	createViewByIndx(indx)

	local mainWidget = m_pMainLayer:getWidgetByTag(999)

	local panel_container = uiUtil.getConvertChildByName(mainWidget,"panel_container")

	

	local view = uiUtil.getConvertChildByName(panel_container,"view_" .. indx)
	
	if not view then 
		if callback then 
			callback() 
		end
		return
	end

	if view and flag then 
		view:setPosition(cc.p(panel_container:getContentSize().width/2,panel_container:getContentSize().height/2))
		m_bIsSwitching = true
	end

	local function finally()
		if view and not flag then 
			view:setPosition(cc.p(10000,10000))
		end

		if view and flag then 
			m_bIsSwitching = false
		end
	end

    if indx == VIEW_INDX_TAX then 
		TaxUI.setEnabled(flag, finally)
	elseif indx == VIEW_INDX_TRADE then 
		UIResourceTrade.setEnabled(flag, finally)
	elseif indx == VIEW_INDX_RANGER then 
		viewOfficialRanger.setEnabled(flag,finally)
	elseif indx == VIEW_INDX_STRONG_HOLD then 
		userOfficialGuard.setEnabled(flag,finally)
	elseif indx == VIEW_INDX_MOVE_CITY then
		userOfficialMoveCity.setEnabled(flag,finally)
	else
		
	end
end

local function setSelectedOfficialByIndx(indx)
	if m_bIsSwitching then return  end

	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	
	
	if indx == m_iSelectedIndx then return end
	

	local oldSelectedIndx = m_iSelectedIndx
	m_iSelectedIndx = indx
	

	-- 按钮状态
	local panel_btns = uiUtil.getConvertChildByName(mainWidget,"panel_btns")
 	local btn_op = nil
 	for i =1, VIEW_TOTAL_INDX_NUM do 
 		btn_op = uiUtil.getConvertChildByName(panel_btns,"btn_op_" .. i)
 		btn_op:setBright(i ~= m_iSelectedIndx)
 	end

 	-- 标题  
 	local label_title = uiUtil.getConvertChildByName(mainWidget,"label_title")
 	label_title:setText(viewTitle[m_iSelectedIndx])

 	
 	-- 未开启提示
 	local label_tips = nil
 	for i = 1 ,VIEW_TOTAL_INDX_NUM do 
 		label_tips = uiUtil.getConvertChildByName(mainWidget,"label_tips_" .. i)
 		label_tips:setVisible(false)
 	end
 	


 	local flag_opened = true
 	-- 税收的限制
	if indx == VIEW_INDX_TAX then 
		if not userData.checkTaxOpenState() then 
			flag_opened = false
		end
	end
	-- 交易的限制
	if indx == VIEW_INDX_TRADE then 
		if not checkTradeOpenState() then 
	        flag_opened = false
	    end
	end

	setVisibleByIndx(oldSelectedIndx,false)
 	if flag_opened then 
 		setVisibleByIndx(m_iSelectedIndx,true)
 	else
 		label_tips = uiUtil.getConvertChildByName(mainWidget,"label_tips_" .. indx)
 		label_tips:setVisible(true)
 	end

end

function get_com_guide_widget(temp_guide_id)
    if not m_pMainLayer then
        return nil
    end

    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2008 then 
    	if m_iSelectedIndx == VIEW_INDX_TAX then 
    		if TaxUI then 
    			return TaxUI.getInstance()
    		end
    	end
    end

    return nil
end
function create( viewIndx )
	if m_pMainLayer then return end
    
    require("game/tax/taxUI")
	require("game/roleForces/ui_resource_trade")
    require("game/roleForces/ui_role_forces_ranger_confirm")
           
	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/neizenjiem_001.json")
	mainWidget:setTag(999)
	mainWidget:setTouchEnabled(true)
	m_backPanel = UIBackPanel.new()

	local titleName = panelPropInfo[uiIndexDefine.UI_USER_OFFICIAL][2]
	local all_widget = m_backPanel:create(mainWidget, remove_self, titleName, false, false)
	m_pMainLayer = TouchGroup:create()
	m_pMainLayer:addWidget(all_widget)

    
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_USER_OFFICIAL,999)
    uiManager.showConfigEffect(uiIndexDefine.UI_USER_OFFICIAL, m_pMainLayer, nil, 999, {all_widget})



 	-- 初始化按钮

 	local panel_btns = uiUtil.getConvertChildByName(mainWidget,"panel_btns")

 	local panel_container = uiUtil.getConvertChildByName(mainWidget,"panel_container")
 	panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)

 	local btn_op = nil
 	local label_tips = nil
 	for i =1, VIEW_TOTAL_INDX_NUM do 
 		btn_op = uiUtil.getConvertChildByName(panel_btns,"btn_op_" .. i)
 		btn_op:setTouchEnabled(true)
 		btn_op:addTouchEventListener(function(sender,eventType)
 			if eventType == TOUCH_EVENT_ENDED then 
 				
 				setSelectedOfficialByIndx(i)
 			end
 		end)
 		label_tips = uiUtil.getConvertChildByName(mainWidget,"label_tips_" .. i)
 		if label_tips then 
 			label_tips:setVisible(false)
 		end
 	end

 	if not viewIndx then viewIndx = 1 end
 	setSelectedOfficialByIndx(viewIndx)
 	m_bIsSwitching = false


end
