UIRoleForcesEditIntro = {}
local uiUtil = require("game/utils/ui_util")
local main_layer = nil

local user_id = nil
local uiIndex = uiIndexDefine.ROLE_FORCES_EDIT_INTRO
local textEditbox = nil
local function do_remove_self()
	if main_layer then
		if textEditbox then  
			textEditbox:removeFromParentAndCleanup(true)
			textEditbox = nil
		end
		
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		user_id = nil

		uiManager.remove_self_panel(uiIndex)
	end
end
function UIRoleForcesEditIntro.remove_self()
    if not main_layer then return end
    uiManager.hideConfigEffect(uiIndex,main_layer,do_remove_self)
end
function UIRoleForcesEditIntro.dealwithTouchEvent(x,y)
	if not main_layer then return false end
	local temp_widget = main_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		return true
	end
end

local function dealWithClickBtnOK(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local widget = main_layer:getWidgetByTag(999)
		local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
		local label_content = uiUtil.getConvertChildByName(edit_panel,"label_content")
		local str = ""
		if config.getPlatFormInfo() == kTargetWindows then
			str = textEditbox:getText()
		else
			str = label_content:getStringValue()
		end

            
        local strUtil = require("game/utils/string_util")
        print(strUtil.utfstrlen(str))
		if languagePack["role_forces_edit_intro"] ~= str then 
			Net.send(USER_SET_INTRODUCATION, {str})
		end
		UIRoleForcesEditIntro.remove_self()
	end
end

local function dealWithClickBtnClose(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then
		UIRoleForcesEditIntro.remove_self()
	end
end

function UIRoleForcesEditIntro.create()
	if main_layer then return end
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/role_forces_edit_intro.json")
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

	main_layer = TouchGroup:create()
	main_layer:addWidget(widget)

	uiManager.add_panel_to_layer(main_layer, uiIndex)

	local close_btn = uiUtil.getConvertChildByName(widget,"close_btn")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(dealWithClickBtnClose)

	local btn_ok = uiUtil.getConvertChildByName(widget,"btn_ok")
	btn_ok:setTouchEnabled(true)
	btn_ok:addTouchEventListener(dealWithClickBtnOK)


	local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
	local label_content = uiUtil.getConvertChildByName(edit_panel,"label_content")
	label_content:setText(languagePack["role_forces_edit_intro"])
	local size_width = edit_panel:getSize().width
	local size_height = edit_panel:getSize().height
	--输入正文
	local rect = CCRectMake(9,9, 2 , 2)
    local sprite = CCScale9Sprite:createWithSpriteFrameName(ResDefineUtil.small_not_reading_frame_y_0,rect)
    sprite:setOpacity(0)
    textEditbox = CCEditBox:create(CCSize(size_width*config.getgScale(),size_height*config.getgScale()),sprite )
    textEditbox:setFontName(config.getFontName())	
    textEditbox:setFontSize(22*config.getgScale())
    textEditbox:setFontColor(ccc3(255,255,255))
    textEditbox:setPlaceHolder(languagePack["role_forces_edit_intro"])
    textEditbox:setPlaceholderFontSize(22*config.getgScale())
    textEditbox:setPlaceholderFontColor(ccc3(255,255,255))
    textEditbox:setMaxLength(100)
    textEditbox:setScale(1/config.getgScale())
    textEditbox:setText(" ")
    textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
		if strEventName == "began" then
            --[[
			if config.getPlatFormInfo() == kTargetWindows then
				label_content:setVisible(false)
			end
            ]]
            label_content:setVisible(false)
		elseif strEventName == "ended" then
			-- ignore
		elseif strEventName == "return" then
			if textEditbox:getText() ~= "" then
				label_content:setText(textEditbox:getText())
				textEditbox:setText(" ")
				label_content:setVisible(true)
			end
		elseif strEventName == "changed" then
			-- ignore
		end
	end)
    edit_panel:addChild(textEditbox)
    textEditbox:setPosition(cc.p(0, size_height))
    textEditbox:setAnchorPoint(cc.p(0,1))
    uiManager.showConfigEffect(uiIndex,main_layer)
end

function UIRoleForcesEditIntro.show(user_id_t)
	UIRoleForcesEditIntro.create()
	user_id = user_id_t
end


