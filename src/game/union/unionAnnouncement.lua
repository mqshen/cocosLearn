--同盟公告编辑界面
module("UnionAnnouncement", package.seeall)

local StringUtil = require("game/utils/string_util")
local noText_color = ccc3(130,130,130)
local text_color = ccc3(255,243,195)
local m_pMainLayer = nil

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

function remove_self( )
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.ANNOUNCEMENT_EDIT_UI)
	end
end

function create(text )
	if m_pMainLayer then return end
    if StringUtil.isEmptyStr(text) then 
        text = languagePack["union_notice_default"]
    end
	local strText = text
	m_pMainLayer = TouchGroup:create()
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.ANNOUNCEMENT_EDIT_UI)
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Allied_Edit_bulletin.json")
	m_pMainLayer:addWidget(widget)
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local closeBtn = tolua.cast(widget:getChildByName("close_btn"),"Button")
	closeBtn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)

	local panel = tolua.cast(widget:getChildByName("Panel_228945"),"Layout")
    local textDetail = tolua.cast(widget:getChildByName("Label_228946"),"Label")

	--发布按钮
	local sendBtn = tolua.cast(widget:getChildByName("btn_ok"),"Button")
	sendBtn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			local retStr = ""
			if textDetail:getStringValue() ~= languagePack["union_notice_default"] then
				retStr =  textDetail:getStringValue()
			end
			UnionData.requestEditAnnouncement(retStr)
		end
	end)

    local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(5,5,466,70)
    local textEditbox = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName(ResDefineUtil.small_not_reading_frame_y_0,rect))
    textEditbox:setVertocalType(1)
    textEditbox:setDoAnimation(false)
    textEditbox:setFontName(config.getFontName())
    textEditbox:setFontSize(22*config.getgScale())
    textEditbox:setFontColor(ccc3(255,243,195))
    -- EditName:setPlaceHolder(languagePack["qingshuruyoujianbiaoti"]..languagePack["maohao"])
    -- EditName:setPlaceholderFontSize(22*config.getgScale())
    -- EditName:setPlaceholderFontColor(ccc3(255,255,255))
    -- textEditbox:setMaxLength(150)
    widget:addChild(textEditbox,2,2)
    textEditbox:setScale(1/config.getgScale())
    textEditbox:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    textEditbox:setAnchorPoint(cc.p(0,0))

    local function setTextColor( str )
    	if not str then return end
    	textDetail:setText(str)
    	if str == languagePack["union_notice_default"] then
    		textDetail:setColor(noText_color)
    	else
    		textDetail:setColor(text_color)
    	end
    end
    
    if strText then
    	setTextColor( strText )
    end

    textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
		if strEventName == "began" then
			textDetail:setVisible(false)
            if languagePack["union_notice_default"] ~= textDetail:getStringValue() then 
                textEditbox:setText(textDetail:getStringValue())
            end
		elseif strEventName == "ended" then
		elseif strEventName == "return" then
			if textEditbox:getText() ~= "" then
				textDetail:setText(textEditbox:getText())
				textDetail:setColor(text_color)
				textEditbox:setText(" ")
				textDetail:setVisible(true)
				setTextColor(textDetail:getStringValue())
			end
		elseif strEventName == "changed" then
		end
	end)
end