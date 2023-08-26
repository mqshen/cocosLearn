-- User agreement
-- 用户协议
local UserAgreement = {}
local UserAgreementTag = 8524
function UserAgreement.create( )
	local page_data = {}
	local page_index = 1
	local layer = TouchGroup:create()
	local layout = Layout:create()
	layout:setSize(CCSize(configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height))
	layout:setContentSize(CCSize(configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height))
	layout:setTouchEnabled(true)
	cc.Director:getInstance():getRunningScene():addChild(layer,UserAgreementTag,UserAgreementTag)

	layer:addWidget(layout)

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/yonghuxieyi_01.json")
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	widget:setScale(configBeforeLoad.getgScale())
	layout:addChild(widget)

	local back = tolua.cast(widget:getChildByName("Panel_963146"), "Layout")
	back:setSize(CCSize(configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height))
	back:setScale(1/configBeforeLoad.getgScale())
	back:setAnchorPoint(cc.p(0.5,0.5))
	back:setPosition(cc.p(widget:getSize().width/2, widget:getSize().height/2))

	local panel = tolua.cast(widget:getChildByName("content_panel"), "Layout")
	local m_scrollViewLayer = CCLayer:create()

	local scrollView =CCScrollView:create()
    scrollView:setViewSize(CCSizeMake(panel:getSize().width,panel:getSize().height))
    scrollView:setContainer(m_scrollViewLayer)
    scrollView:updateInset()
    scrollView:setDirection(kCCScrollViewDirectionVertical)
    scrollView:setClippingToBounds(true)
    scrollView:setBounceable(true)
    panel:addChild(scrollView)

 	require("game/login/agreement")
    local pageDisplay = function (  page)
    	local label_page = tolua.cast(widget:getChildByName("label_page"), "Label")
    	label_page:setText(page.."/"..#userAgreementText)
	    for i, v in pairs(page_data) do
	    	v[1]:setVisible(i==page)
	    	if i == page then
	    		m_scrollViewLayer:setContentSize(CCSizeMake(panel:getSize().width, v[2]))
	    		v[1]:setPosition(cc.p(0,v[2]))
	    		scrollView:setContentOffset(cc.p(0,panel:getSize().height-v[2]))
	    	end
	    end
    	if page_data[page] then
    		
    	else
			page_data[page] = {}
			local label = CCLabelTTF:create(userAgreementText[page],config.getFontName(), 20, CCSize(panel:getSize().width, 0), kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			label:setColor(ccc3(255,228,182))
			label:setAnchorPoint(cc.p(0,1))
			table.insert(page_data[page], label)
			m_scrollViewLayer:setContentSize(CCSizeMake(panel:getSize().width, label:getContentSize().height))
		   	m_scrollViewLayer:addChild(label)
		   	label:setPosition(cc.p(0,label:getContentSize().height))
	    	scrollView:setContentOffset(cc.p(0,panel:getSize().height-label:getContentSize().height))
	    	table.insert(page_data[page], label:getContentSize().height)
    	end
    end

    local Button_forward = tolua.cast(widget:getChildByName("Button_forward"), "Button")
    Button_forward:addTouchEventListener(function ( sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then
			if page_index < #userAgreementText then
				page_index = page_index + 1
				pageDisplay(page_index)
			end
		end
    end)

    local Button_back = tolua.cast(widget:getChildByName("Button_back"), "Button")
    Button_back:addTouchEventListener(function ( sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then
			if page_index > 1 then
				page_index = page_index - 1
				pageDisplay(page_index)
			end
		end
    end)

    local Button_agree = tolua.cast(widget:getChildByName("Button_agree"), "Button")
    Button_agree:addTouchEventListener(function ( sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then
			layer:removeFromParentAndCleanup(true)
			local uid = sdkMgr:sharedSkdMgr():getPropStr("UID")
	    	uid = string.gsub(uid,"@","")
			CCUserDefault:sharedUserDefault():setStringForKey("userAgreement_"..uid, configBeforeLoad.getUserAgreementVers() or "",true)
		end
    end)

    local Button_reject = tolua.cast(widget:getChildByName("Button_reject"), "Button")
    Button_reject:addTouchEventListener(function ( sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then
			layer:removeFromParentAndCleanup(true)
			EndGameUI.create(languageBeforeLogin["rejectAgreement"], function (  )
                 		configBeforeLoad.exitGame()
                	end, function ( )
                		EndGameUI.remove_self()
                		local uid = sdkMgr:sharedSkdMgr():getPropStr("UID")
                		uid = string.gsub(uid,"@","")
						CCUserDefault:sharedUserDefault():setStringForKey("userAgreement_"..uid, configBeforeLoad.getUserAgreementVers() or "", true)
                	end, languageBeforeLogin["no"], languageBeforeLogin["yes"])
		end
    end)

    local label_page = tolua.cast(widget:getChildByName("label_page"), "Label")
    label_page:setText("1/"..#userAgreementText)

    -- layer:runAction(animation.sequence({cc.DelayTime:create(0.1),cc.CallFunc:create(function ( )
	    pageDisplay(1)
    -- end)}))
end

return UserAgreement