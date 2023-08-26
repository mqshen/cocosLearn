local loginUserCenter = {}

local main_layer = nil
-- local uiUtil = require("game/utils/ui_util")
local inputBoxX = nil

function loginUserCenter.remove()
	if main_layer then 
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		inputBoxX = nil
	end
end


local function deal_with_confirm_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_widget = main_layer:getWidgetByTag(999)
		-- local name_txt = uiUtil.getConvertChildByName(temp_widget,"name_label")
		local name_content = inputBoxX:getText()
		if name_content == "" then
			tipsLayer.create("账号不能为空")
			return
		end

		local pw_txt =  tolua.cast(temp_widget:getChildByName("pw_label"),"Label")--uiUtil.getConvertChildByName(temp_widget,"pw_label")
		local pw_content = ""

		-- CCUserDefault:sharedUserDefault():setStringForKey("name", name_content)
		-- CCUserDefault:sharedUserDefault():setStringForKey("code", pw_content)
		Login.setAccountInfo(name_content,pw_content)
		sender:setTouchEnabled(false)
		-- loginUserCenter.remove()
		-- loginGUI.createEnterGame()
		-- Connect.connect_service_filter()
		loginUserCenter.remove()
		scene.remove()
    end
end


function loginUserCenter.create()
	if main_layer then return end
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_user_center.json")
	temp_widget:setTag(999)
	temp_widget:setScale(configBeforeLoad.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))

	main_layer = TouchGroup:create()
	main_layer:addWidget(temp_widget)
 	loginGUI.add_login_content(main_layer)



 	-- local userName = CCUserDefault:sharedUserDefault():getStringForKey("name")
 	local userName, userCode = Login.getAccountInfo()

 	local panel = tolua.cast(temp_widget:getChildByName("Panel_612106"),"Layout")
	local editBoxSize = CCSizeMake(panel:getContentSize().width*configBeforeLoad.getgScale(),panel:getContentSize().height*configBeforeLoad.getgScale() )
    local rect = CCRectMake(14,14,2,2)
    inputBoxX = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("main_interface_of_city_information_base.png",rect))
    inputBoxX:setAlignment(1)
    inputBoxX:setFontName(configBeforeLoad.getFontName())
    inputBoxX:setFontSize(30*configBeforeLoad.getgScale())
    inputBoxX:setFontColor(ccc3(255,255,255))
    panel:addChild(inputBoxX)
    inputBoxX:setScale(1/configBeforeLoad.getgScale())
    -- inputBoxX:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    inputBoxX:setAnchorPoint(cc.p(0,0))

    if userName then
    	inputBoxX:setText(userName)
    end

	-- local userCode = CCUserDefault:sharedUserDefault():getStringForKey("code")

	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"),"Button")--uiUtil.getConvertChildByName(temp_widget,"confirm_btn")
	confirm_btn:setTouchEnabled(true)
	confirm_btn:addTouchEventListener(deal_with_confirm_click)
end



return loginUserCenter