--发送邮件界面
module("SendMailUI", package.seeall)
local m_pMainLayer = nil
local m_iUserId = nil
local m_pLabel = nil
local m_gm = nil
local m_server_gm = nil
local m_debug_gm = nil
local m_port_gm = nil

local m_bIsToAllUnion = nil
function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		--if not ReceiverChooseUI.getInstance() then
			remove_self()
		--end
		return true
	end
end

function remove_self( )
	if m_pMainLayer then
		newMailData.remove_with_send_mail()

		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		m_iUserId = nil
		m_bIsToAllUnion = nil
		m_pLabel = nil
		m_gm = nil
		m_server_gm = nil
		m_port_gm = nil
		m_debug_gm = nil
		uiManager.remove_self_panel(uiIndexDefine.SEND_MAIL_UI)
	end
end

-- function remove_self( )
--     uiManager.hideConfigEffect(uiIndexDefine.SEND_MAIL_UI,m_pMainLayer,do_remove_self)
-- end

function setReceiverId(userid, userName , isToAllUnionMember)
	m_iUserId = userid
	if m_pLabel then
		m_pLabel:setText(userName)
	end
	m_bIsToAllUnion = isToAllUnionMember

	if m_bIsToAllUnion then
		m_pLabel:setTouchEnabled(false)
	else
		m_pLabel:setTouchEnabled(true)
	end
end


-- isToAllUnionMember 是否是给全盟成员发送的邮件
function create(text,title,userid, userName,isTargetNotVariable,isToAllUnionMember)
	if m_pMainLayer then return end

	newMailData.create_with_send_mail()
	m_gm = {}
	m_server_gm = {}
	m_debug_gm = {}
	m_port_gm = {}
	m_pMainLayer = TouchGroup:create()
	-- uiManager.getBasicLayer():addChild(m_pMainLayer)
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Mail_program_interface.json")
	widget:setTag(999)
	m_pMainLayer:addWidget(widget)
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	widget:setScale(config.getgScale())

	--收件人名字
	-- m_pLabel = --tolua.cast(widget:getChildByName("Label_58678"),"Label")
	local panel = tolua.cast(widget:getChildByName("Panel_251725"),"Layout")
    local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    m_pLabel = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    m_pLabel:setFontName(config.getFontName())
    m_pLabel:setFontSize(22*config.getgScale())
    m_pLabel:setFontColor(ccc3(255,243,195))
    m_pLabel:setPlaceHolder(languagePack["qingshurushoujianren"]..languagePack["maohao"])
    m_pLabel:setPlaceholderFontSize(22*config.getgScale())
    m_pLabel:setPlaceholderFontColor(ccc3(120,120,120))
    -- m_pLabel:setMaxLength(8)
    widget:addChild(m_pLabel,2,2)
    m_pLabel:setScale(1/config.getgScale())
    m_pLabel:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    m_pLabel:setAnchorPoint(cc.p(0,0))

    if isTargetNotVariable then 
        m_pLabel:setTouchEnabled(false)
    end
	--关闭按钮
	local closeBtn = tolua.cast(widget:getChildByName("close_btn"),"Button")
	closeBtn:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				remove_self()
			end
		end)

	--盟友按钮
	local unionMemberBtn = tolua.cast(widget:getChildByName("Button_51149"),"Button")
	unionMemberBtn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			require("game/mail/receiverChooseUI")
			ReceiverChooseUI.on_enter()
		end
	end)

	if userid or userName then
		setReceiverId(userid, userName )
		unionMemberBtn:setTouchEnabled(false)
		unionMemberBtn:setVisible(false)
	end

	if isToAllUnionMember then
		setReceiverId(0,languagePack['mail_title_name_all_unionMember'],true)
	end
	-- --好友按钮
	-- local friendBtn = tolua.cast(widget:getChildByName("Button_51149_0"),"Button")
	-- friendBtn:setTitleText(languagePack["haoyou"])
	-- friendBtn:addTouchEventListener(function ( sender, eventType )
	-- 	if eventType == TOUCH_EVENT_ENDED then
	-- 		-- ReceiverChooseUI.create()
	-- 	end
	-- end)

	local textDetail = tolua.cast(widget:getChildByName("Label_24542_0_0_0_0"),"Label")
	if text then
		textDetail:setText(text)
	else
		textDetail:setText("")
	end


    -- 输入标题
    local panel = tolua.cast(widget:getChildByName("Panel_58626"),"Layout")
    local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    local EditName = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    EditName:setFontName(config.getFontName())
    EditName:setFontSize(22*config.getgScale())
    EditName:setFontColor(ccc3(255,255,255))
    EditName:setPlaceHolder(languagePack["qingshuruyoujianbiaoti"]..languagePack["maohao"])
    EditName:setPlaceholderFontSize(22*config.getgScale())
    EditName:setPlaceholderFontColor(ccc3(120,120,120))
    -- EditName:setMaxLength(MAIL_TITLE_LENGTH_PLAYER)
    widget:addChild(EditName,2,2)
    EditName:setScale(1/config.getgScale())
    EditName:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    EditName:setAnchorPoint(cc.p(0,0))
    if title then
    	EditName:setText(title)
    end

    --输入正文
    rect = CCRectMake(9,9,2,2)
    local sprite = CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect)
    sprite:setOpacity(0)
    local textEditbox = CCEditBox:create(CCSize(textDetail:getSize().width*config.getgScale(),textDetail:getSize().height*config.getgScale()),sprite )
    textEditbox:setVertocalType(1)
    textEditbox:setDoAnimation(false)
    textEditbox:setFontName(config.getFontName())	
    textEditbox:setFontSize(22*config.getgScale())
    textEditbox:setFontColor(ccc3(255,255,255))
    textEditbox:setPlaceHolder(languagePack["qingshuruzhengwen"]..languagePack["maohao"])
    textEditbox:setPlaceholderFontSize(22*config.getgScale())
    textEditbox:setPlaceholderFontColor(ccc3(120,120,120))
    -- textEditbox:setMaxLength(200)
    textEditbox:setScale(1/config.getgScale())
    textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
		if strEventName == "began" then
			textDetail:setVisible(false)
			textEditbox:setText(textDetail:getStringValue())
		elseif strEventName == "ended" then
		elseif strEventName == "return" then
			if textEditbox:getText() ~= "" then
				textDetail:setText(textEditbox:getText())
				textEditbox:setText(" ")
				textDetail:setVisible(true)
 			end
		elseif strEventName == "changed" then
		end
	end)
    widget:addChild(textEditbox,2,2)
    textEditbox:setAnchorPoint(cc.p(0,1))
    textEditbox:setPosition(cc.p(textDetail:getPositionX(), textDetail:getPositionY()))

    -- if text then
    -- 	textEditbox:setText(" ")
    -- else
    -- 	textDetail:setColor(ccc3(120,120,120)) 
    -- 	textDetail:setText(languagePack["qingshuruzhengwen"]..languagePack["maohao"])
    -- end
    local gm_str = {"-g10-sanguo-1","-g10-sanguo-2","-g10-sanguo-3"}
    local gm_server_str = {"-g10-sanguo-4","-g10-sanguo-5","-g10-sanguo-6"}
    local gm_debug_str = {"-g10-sanguo-7","-g10-sanguo-8","-g10-sanguo-9"}
    local gm_port_str = {"-g10-sanguo-10","-g10-sanguo-11","-g10-sanguo-12"}

	--发送按钮
	local sendBtn = tolua.cast(widget:getChildByName("action_btn"),"Button")
	sendBtn:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				if m_pLabel:getText() == gm_str[1] then
					table.insert(m_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_str[2] then
					table.insert(m_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_str[3] then
					table.insert(m_gm, m_pLabel:getText())
				else
					m_gm = {}
					-- CCUserDefault:sharedUserDefault():setStringForKey("update_address", "")
				end

				if m_pLabel:getText() == gm_server_str[1] then
					table.insert(m_server_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_server_str[2] then
					table.insert(m_server_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_server_str[3] then
					table.insert(m_server_gm, m_pLabel:getText())
				else
					m_server_gm = {}
					-- CCUserDefault:sharedUserDefault():setStringForKey("SERVER_IP", "")
				end

				if m_pLabel:getText() == gm_debug_str[1] then
					table.insert(m_debug_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_debug_str[2] then
					table.insert(m_debug_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_debug_str[3] then
					table.insert(m_debug_gm, m_pLabel:getText())
				else
					m_debug_gm = {}
				end

				if m_pLabel:getText() == gm_port_str[1] then
					table.insert(m_port_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_port_str[2] then
					table.insert(m_port_gm, m_pLabel:getText())
				elseif m_pLabel:getText() == gm_port_str[3] then
					table.insert(m_port_gm, m_pLabel:getText())
				else
					m_port_gm = {}
					-- CCUserDefault:sharedUserDefault():setStringForKey("LOGIN_PORT", "")
				end

				local flag = true
				for i, v  in ipairs(m_gm) do
					if v ~= gm_str[i] then
						flag = false
					end
				end

				for i, v  in ipairs(m_server_gm) do
					if v ~= gm_server_str[i] then
						flag = false
					end
				end

				for i, v  in ipairs(m_debug_gm) do
					if v ~= gm_debug_str[i] then
						flag = false
					end
				end

				for i, v  in ipairs(m_port_gm) do
					if v ~= gm_port_str[i] then
						flag = false
					end
				end

				if flag and #m_gm==3 then
					local address = EditName:getText()
					if EditName:getText() == "" then
						address = UPDATE_ADDR
					elseif EditName:getText() == "1" then
						address = UPDATE_ADDR_TEST
					elseif EditName:getText() == "2" then
						address = UPDATE_ADDR_TEST_2
					end
					CCUserDefault:sharedUserDefault():setStringForKey("update_address", address, true)
				end

				if flag and #m_server_gm==3 then
					CCUserDefault:sharedUserDefault():setStringForKey("SERVER_IP", EditName:getText(), true)
				end

				if flag and #m_debug_gm==3 then
					CCUserDefault:sharedUserDefault():setStringForKey("DEBUG_MODE", EditName:getText(), true)
				end

				if flag and #m_port_gm==3 then
					CCUserDefault:sharedUserDefault():setInterForKey("LOGIN_PORT", EditName:getText(), true)
				end

				if m_pLabel:getText() == "" then
					tipsLayer.create(languagePack["shoujianrenbunengweikong"])
					return
				end

				if m_pLabel:getText() == userData.getUserName() then
					tipsLayer.create(languagePack["bunenggeiziji"])
					return
				end
				
				if textDetail:getStringValue() == "" then
					tipsLayer.create(languagePack["zhengwenbunengweikong"])
					return
				end
				
				if stringFunc.get_str_length(EditName:getText()) > MAIL_TITLE_LENGTH_PLAYER then
					tipsLayer.create(errorTable[509], nil, {MAIL_TITLE_LENGTH_PLAYER})
					return
				end

				if m_bIsToAllUnion then
					if userData.isAbleSendUnionMail() then
						newMailData.requestSendUnionMail(userData.getUnion_id(),EditName:getText(),textDetail:getStringValue())	
					else
						-- TODO 需要异常提示
						print(">>>>>>>>>>>>>>  user unable access union mail ")
					end
				else
					newMailData.requestSendMail(EditName:getText(),textDetail:getStringValue(), m_iUserId,m_pLabel:getText())
				end
				
				
			end
		end)
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.SEND_MAIL_UI)
	-- uiManager.showConfigEffect(uiIndexDefine.SEND_MAIL_UI, m_pMainLayer)
end
