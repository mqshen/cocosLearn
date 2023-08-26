--邮件发送时盟友和好友选择界面
module("ReceiverChooseUI", package.seeall)
local m_layer = nil
local m_tableView = nil

local m_is_open_state = nil

function getInstance( )
	return m_layer
end

function dealwithTouchEvent(x,y)
	if not m_layer then
		return false
	end

	local temp_widget = m_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function cellSizeForTable(table,idx)
    return 54, 275
end

local function getUnionMember()
	local ret = {}
	if userData.isAbleSendUnionMail() then 
		local info = {}
		info.userid = 0
		info.userName = languagePack['mail_title_name_all_unionMember']
		info.isTypeAll = true
		table.insert(ret,info)
	end
	
	local allMembers = newMailData.getUnionMember()
	for i = 1,#allMembers do
		table.insert(ret,allMembers[i])
	end
	return ret
end
local function tableCellTouched( table,cell )
	local idx = cell:getIdx()
	local info = getUnionMember()[idx+1]
	remove_self()
	
	SendMailUI.setReceiverId(info.userid, info.userName,info.isTypeAll)
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
    	cell = CCTableViewCell:new()
    	local layer = TouchGroup:create()
		local widget = GUIReader:shareReader():widgetFromJsonFile("test/Mail_program_interface_0_0.json")
	    tolua.cast(widget,"Layout")
	    layer:addWidget(widget)
	    widget:setTag(1)
	    cell:addChild(layer)
	    layer:setTag(123)
    end

    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	local widget = layer:getWidgetByTag(1)
    	if widget then
			local label = tolua.cast(UIHelper:seekWidgetByName(widget,"Label_58681"),"Label")
    		label:setText(getUnionMember()[idx+1].userName)
			if getUnionMember()[idx+1].isTypeAll then
				label:setColor(ccc3(255,213,110))
			else
				label:setColor(ccc3(207,194,162))
			end
    	end
    end
	
    return cell
end

local function numberOfCellsInTableView(table)
	return #getUnionMember()
end

local function scrollViewDidScroll(table)
	local temp_widget = m_layer:getWidgetByTag(999)
	local down_img = tolua.cast(temp_widget:getChildByName("down_img"), "ImageView")
	local up_img = tolua.cast(temp_widget:getChildByName("up_img"), "ImageView")
	if table:getContentOffset().y < 0 then
		down_img:setVisible(true)
	else
		down_img:setVisible(false)
	end

	if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
		up_img:setVisible(true)
	else
		up_img:setVisible(false)
	end
end

function do_remove_self()
	if m_layer then
		newMailData.remove_with_union_member()
		
		m_is_open_state = nil
		m_tableView = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.RECEIVER_CHOOSE_UI)
	end
end

function remove_self( )
    uiManager.hideConfigEffect(uiIndexDefine.RECEIVER_CHOOSE_UI,m_layer,do_remove_self)
end

function create()
	if m_layer then
		return
	end

	local show_cell_nums = #getUnionMember()

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/Mail_program_interface_0.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	--关闭按钮
	local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"),"Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(function (sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then
				remove_self()
			end
		end)

	if show_cell_nums == 0 then
		local none_txt = tolua.cast(temp_widget:getChildByName("none_label"), "Label")
		none_txt:setVisible(true)
	else
		local up_img = tolua.cast(temp_widget:getChildByName("up_img"), "ImageView")
	    local down_img = tolua.cast(temp_widget:getChildByName("down_img"), "ImageView")
	    breathAnimUtil.start_scroll_dir_anim(up_img, down_img)

	    local content_panel = tolua.cast(temp_widget:getChildByName("content_panel"),"Layout")
		m_tableView = CCTableView:create(CCSizeMake(content_panel:getSize().width,content_panel:getSize().height))
		content_panel:addChild(m_tableView)
		--m_tableView:setPosition(cc.p(content_panel:getPositionX(),content_panel:getPositionY()))
		m_tableView:setDirection(kCCScrollViewDirectionVertical)
		m_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
		m_tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
		m_tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
		m_tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
		m_tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
		m_tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	end

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.RECEIVER_CHOOSE_UI)
	uiManager.showConfigEffect(uiIndexDefine.RECEIVER_CHOOSE_UI, m_layer)
	if show_cell_nums ~= 0 then
		m_tableView:reloadData()
	end
end

function on_enter()
	if m_is_open_state then
		return
	end

	m_is_open_state = true
	newMailData.create_with_union_member()
end
