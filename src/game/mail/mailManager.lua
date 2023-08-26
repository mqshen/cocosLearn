--邮件主界面
module("mailManager", package.seeall)



--[[
require("game/mail/mailData")
require("game/mail/inboxAndOutboxUI")
require("game/mail/mailText")

require("game/mail/receiverChooseUI")

local m_pMainLayer = nil
local m_backPanel = nil
local m_arrBtn = nil

local function tagChange( index)
	local tagIndex = index or 1
	m_arrBtn[tagIndex]:setTouchEnabled(false)
	m_arrBtn[tagIndex]:setBright(false)
	m_arrBtn[tagIndex]:setTitleColor(ccc3(191,203,203))

	for i=1, 3 do
		if i ~= tagIndex then
			m_arrBtn[i]:setTouchEnabled(true)
			m_arrBtn[i]:setBright(true)
			m_arrBtn[i]:setTitleColor(ccc3(109,109,109))
		end
	end
end

function setLayerVisible(flag )
	-- if m_pMainLayer then
	-- 	m_pMainLayer:setVisible(flag)
	-- end
end





--生成收件箱界面或者发件箱界面
function addUI( index)
	if not m_pMainLayer then return end
	local tagIndex = index or 1
	local widget = m_pMainLayer:getWidgetByTag(999)
	local panel = tolua.cast(widget:getChildByName("Panel_58484"),"Layout")
	local top_arrow = tolua.cast(widget:getChildByName("ImageView_372345"),"ImageView")
	local down_arrow = tolua.cast(widget:getChildByName("ImageView_241680"),"ImageView")
	panel:removeAllChildrenWithCleanup(true)
	tagChange( tagIndex)
	InboxAndOutboxUI.remove_self()
	-- if tagIndex == 1 then
		panel:addChild(InboxAndOutboxUI.create(tagIndex,panel,top_arrow,down_arrow))
	-- elseif tagIndex == 2 then
		-- panel:addChild(InboxAndOutboxUI.create(2,panel))
	-- end
end

function dealWithMailChange()
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	local label_null = uiUtil.getConvertChildByName(widget,"label_null")

	if #MailData.getMailNums() > 0 then 
		label_null:setVisible(false)
	else
		label_null:setVisible(true)
	end
end

function getInstance( )
	return m_pMainLayer
end
--]]



local m_main_layer = nil
local m_main_widget = nil
local m_backPanel = nil
local m_is_open_state = nil

local m_old_height = nil 		--工程默认底图高度
local m_divide_height = nil 	--内容上下框边距

local function do_remove_self( )
	if m_main_layer then
		mailDetailManager.remove_self()
		mailListManager.remove_self()
		newMailData.remove_with_mail_list()
		m_is_open_state = nil
		m_main_widget = nil

		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end

		m_main_layer:removeFromParentAndCleanup(true)
		m_main_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.MAIL_MAIN_UI)

		UIUpdateManager.remove_prop_update(dbTableDesList.mail_receive.name, dataChangeType.add, newMailData.deal_with_receive_new_mail)
	end
end

function remove_self()
    if m_backPanel then
    	uiManager.hideConfigEffect(uiIndexDefine.MAIL_MAIN_UI, m_main_layer, do_remove_self, 999, {m_backPanel:getMainWidget()})
    end
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	return false
end

function deal_with_tab_change(new_index)
	local old_index = mailListManager.get_selected_tab()
	if new_index == old_index then
		return
	end

	local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")
	local temp_btn = nil
	if old_index ~= 0 then
		temp_btn = tolua.cast(title_panel:getChildByName("btn_" .. old_index), "Button")
		temp_btn:setTouchEnabled(true)
		temp_btn:setBright(true)
		temp_btn:setTitleColor(ccc3(109,109,109))
	end

	temp_btn = tolua.cast(title_panel:getChildByName("btn_" .. new_index), "Button")
	temp_btn:setTouchEnabled(false)
	temp_btn:setBright(false)
	temp_btn:setTitleColor(ccc3(191,203,203))
	
	mailListManager.set_selected_tab(new_index)
end

local function deal_with_tab_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local current_index = tonumber(string.sub(sender:getName(),5))
		deal_with_tab_change(current_index)
	end
end

local function deal_with_write_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/mail/sendMailUI")
		SendMailUI.create()
	end
end

function update_no_mail_state(new_state)
	local left_panel = tolua.cast(m_main_widget:getChildByName("left_panel"), "Layout")
	local right_panel = tolua.cast(m_main_widget:getChildByName("right_panel"), "Layout")
	local tips_txt = tolua.cast(m_main_widget:getChildByName("tips_label"), "Label")
	
	left_panel:setVisible(not new_state)
	right_panel:setVisible(not new_state)
	tips_txt:setVisible(new_state)
end

local function init_title_info()
	local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")
	local temp_btn = nil
	for i=1,3 do
		temp_btn = tolua.cast(title_panel:getChildByName("btn_" .. i), "Button")
		temp_btn:setTouchEnabled(true)
		temp_btn:addTouchEventListener(deal_with_tab_click)
	end

	local write_btn = tolua.cast(title_panel:getChildByName("write_btn"), "Button")
	write_btn:setTouchEnabled(true)
	write_btn:addTouchEventListener(deal_with_write_click)
end

local function init_content_layout()
	local bg_img = tolua.cast(m_main_widget:getChildByName("first_bg_img"), "ImageView")
	local left_panel = tolua.cast(m_main_widget:getChildByName("left_panel"), "Layout")
	local right_panel = tolua.cast(m_main_widget:getChildByName("right_panel"), "Layout")

	local new_panel_height = bg_img:getSize().height - m_divide_height * 2
	local panel_y_offset = bg_img:getSize().height - m_old_height
	left_panel:setSize(CCSize(left_panel:getSize().width, new_panel_height))
	left_panel:setPositionY(left_panel:getPositionY() - panel_y_offset)

	right_panel:setSize(CCSize(right_panel:getSize().width, new_panel_height))
	right_panel:setPositionY(right_panel:getPositionY() - panel_y_offset)

	local tips_txt = tolua.cast(m_main_widget:getChildByName("tips_label"), "Label")
	tips_txt:setPositionY(left_panel:getPositionY() + left_panel:getSize().height/2)

	require("game/mail/mailListManager")
	mailListManager.create(left_panel)

	require("game/mail/mailDetailManager")
	mailDetailManager.create(right_panel)
end

function update_new_state_show()
	local title_panel = tolua.cast(m_main_widget:getChildByName("title_panel"), "Layout")

	local com_new_index, sys_new_index = newMailData.get_mail_list_new_state()
	local sign_img = tolua.cast(title_panel:getChildByName("new_sign_1"), "ImageView")
	if com_new_index == 0 then
		sign_img:setVisible(false)
	else
		sign_img:setVisible(true)
	end

	sign_img = tolua.cast(title_panel:getChildByName("new_sign_2"), "ImageView")
	if sys_new_index == 0 then
		sign_img:setVisible(false)
	else
		sign_img:setVisible(true)
	end
end

function create()
	if m_main_layer then
		return
	end

	m_divide_height = 19 + 9

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/mainMailUI.json")
	m_backPanel = UIBackPanel.new()
	local show_widget = m_backPanel:create(m_main_widget, remove_self, panelPropInfo[uiIndexDefine.MAIL_MAIN_UI][2], false, true)

	local bg_img = tolua.cast(m_main_widget:getChildByName("first_bg_img"), "ImageView")
	m_old_height = bg_img:getSize().height
	local bg_panel = tolua.cast(m_main_widget:getChildByName("second_bg_panel"), "Layout")
	UIListViewSize.definedUIpanel(m_main_widget, bg_img, bg_panel)

	init_title_info()
	init_content_layout()

	update_new_state_show()

	m_main_layer = TouchGroup:create()
	m_main_layer:addWidget(show_widget)
	uiManager.add_panel_to_layer(m_main_layer, uiIndexDefine.MAIL_MAIN_UI)
	uiManager.showConfigEffect(uiIndexDefine.MAIL_MAIN_UI, m_main_layer, nil, 999, {show_widget})

	UIUpdateManager.add_prop_update(dbTableDesList.mail_receive.name, dataChangeType.add, newMailData.deal_with_receive_new_mail)
	
	local com_new_index, sys_new_index = newMailData.get_mail_list_new_state()
	if sys_new_index == 0 then
		deal_with_tab_change(1)
	else
		deal_with_tab_change(2)
	end
end

function get_open_state()
	return m_is_open_state
end

-- 需要先请求完相关数据在显示
function on_enter()
	if m_is_open_state then
		return
	end

	m_is_open_state = true
	--require("game/mail/newMailData")
	newMailData.create_with_mail_list()
end