UIRoleForcesRangerConfirm = {}

local main_layer = nil
local uiUtil = require("game/utils/ui_util")
local timeUtil = require("game/utils/time_util")
local textEditbox = nil

local callback = nil

local StringUtil = require("game/utils/string_util")



local RANGER_CONFIRM_COUNT_DOWN_CD = 30
 -- 缓存住玩家点击完流浪后的时间戳
 -- 只有点取消流浪的时候 才会清理掉这个时间戳
local ranger_count_down_time_stamp = 0
local ranger_count_down_handler = nil

local function do_remove_self()
	
    if ranger_count_down_handler then 
		scheduler.remove(ranger_count_down_handler)
    	ranger_count_down_handler = nil
    	ranger_count_down_time_stamp = nil
    end

	if main_layer then 
		if textEditbox then  
			textEditbox:removeFromParentAndCleanup(true)
			textEditbox = nil
		end
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		callback = nil
		

		uiManager.remove_self_panel(uiIndexDefine.RANGER_CONFIRM)
	end
end


function UIRoleForcesRangerConfirm.remove_self()
    uiManager.hideScaleEffect(main_layer,999,do_remove_self,nil)
end

function UIRoleForcesRangerConfirm.dealwithTouchEvent(x,y)
	if not main_layer then return false end
	local temp_widget = main_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		return true
	end
end

local function onClickCloseBtn(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then 
		UIRoleForcesRangerConfirm.remove_self()
	end
end


-- 流浪倒计时
local function rangerCountDown()
	if (ranger_count_down_time_stamp - userData.getServerTime()) <=  0 then 
		ranger_count_down_time_stamp = nil
		if ranger_count_down_handler then 
			scheduler.remove(ranger_count_down_handler)
			ranger_count_down_handler = nil
		end
		UserOfficial.remove_self(true)
		do_remove_self()
		scene.remove_scene_not_login()
	else
		local widget = main_layer:getWidgetByTag(999) 
		local panel_count_down = uiUtil.getConvertChildByName(widget,"panel_count_down")
		local label_count_down = uiUtil.getConvertChildByName(panel_count_down,"label_count_down")
		local cd = ranger_count_down_time_stamp - userData.getServerTime() 
		label_count_down:setText(timeUtil.formatTime(cd))
	end
end

-- 结束流浪倒计时
local function rangerCountDownEnd()
	if ranger_count_down_handler then 
		scheduler.remove(ranger_count_down_handler)
		ranger_count_down_handler = nil
		ranger_count_down_time_stamp = nil
	end
end

-- 开始流浪倒计时
local function rangerCountDownBegin()
	rangerCountDownEnd()
	ranger_count_down_time_stamp = userData.getServerTime() + RANGER_CONFIRM_COUNT_DOWN_CD
	rangerCountDown()
	ranger_count_down_handler = scheduler.create(rangerCountDown, 1)
end

local function switchEditState(isEdit)
	local widget = main_layer:getWidgetByTag(999) 
	if not widget then return end

	textEditbox:setVisible(isEdit)

	local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
	edit_panel:setVisible(isEdit)

	local confirm_btn = uiUtil.getConvertChildByName(widget,"confirm_btn")
	confirm_btn:setVisible(isEdit)
	confirm_btn:setTouchEnabled(isEdit)

	local btn_cancel = uiUtil.getConvertChildByName(widget,"btn_cancel")
	btn_cancel:setVisible(isEdit)
	btn_cancel:setTouchEnabled(isEdit)
	
	if isEdit then 
		rangerCountDownEnd()
	else
		rangerCountDownBegin()
	end

	local close_btn = uiUtil.getConvertChildByName(widget,"close_btn")
	close_btn:setTouchEnabled(isEdit)
	close_btn:setVisible(isEdit)

	----------------相反的
	isEdit = not isEdit
	local panel_count_down = uiUtil.getConvertChildByName(widget,"panel_count_down")
	panel_count_down:setVisible(isEdit)
	local btn_cancel_confirm = uiUtil.getConvertChildByName(panel_count_down,"btn_cancel_confirm")
	btn_cancel_confirm:setTouchEnabled(isEdit)
	btn_cancel_confirm:setVisible(isEdit)

	
end

local function onClickBtnOK(sender,eventType) 
	if eventType == TOUCH_EVENT_ENDED then 
		if languagePack["ranger_confirm"] == StringUtil.DelS(textEditbox:getText()) then 
			if callback and type(callback) == "function" then 
				callback()
			end
			textEditbox:setText(" ")
			switchEditState(false)

		else
            tipsLayer.create(errorTable[154])
		end
	end
end



local function createViewWidget()

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/role_forces_ranger_confirm.json")
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

	main_layer:addWidget(widget)

	local close_btn = uiUtil.getConvertChildByName(widget,"close_btn")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(onClickCloseBtn)
	

	local btn_cancel = uiUtil.getConvertChildByName(widget,"btn_cancel")
	btn_cancel:setTouchEnabled(true)
	btn_cancel:addTouchEventListener(onClickCloseBtn)

	local confirm_btn = uiUtil.getConvertChildByName(widget,"confirm_btn")
	confirm_btn:setTouchEnabled(true)
	confirm_btn:addTouchEventListener(onClickBtnOK)
	local edit_panel = uiUtil.getConvertChildByName(widget,"edit_panel")
	local label_confirm = uiUtil.getConvertChildByName(widget,"label_confirm")
	local size_width = edit_panel:getSize().width
	local size_height = edit_panel:getSize().height
	--输入正文
	
	local editBoxSize = CCSizeMake(edit_panel:getContentSize().width*config.getgScale(),edit_panel:getContentSize().height*config.getgScale() )
	local rect = CCRectMake(9,9,2,2)

	textEditbox = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
	textEditbox:setAlignment(1)
	textEditbox:setFontName(config.getFontName())
	textEditbox:setFontSize(20*config.getgScale())
	textEditbox:setFontColor(ccc3(91,92,96))
	-- textEditbox:setMaxLength(4)
	-- textEditbox:setInputMode(kEditBoxInputModeNumeric)
	widget:addChild(textEditbox)
	textEditbox:setScale(1/config.getgScale())
	textEditbox:setPosition(cc.p(edit_panel:getPositionX(), edit_panel:getPositionY()))
	textEditbox:setAnchorPoint(cc.p(0,0))

	textEditbox:setText(languagePack['default_editor_tips'])
	textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
            
        if strEventName == "began" then
            textEditbox:setText(" ")    
        elseif strEventName == "return" then
            if StringUtil.DelS(textEditbox:getText()) == '' then
                textEditbox:setText(languagePack['default_editor_tips'])
            end
        end
    end)

	local panel_count_down = uiUtil.getConvertChildByName(widget,"panel_count_down")
	local btn_cancel_confirm = uiUtil.getConvertChildByName(panel_count_down,"btn_cancel_confirm")
	btn_cancel_confirm:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			switchEditState(true)
		end
	end)
end

function UIRoleForcesRangerConfirm.create(callback_t)
	if main_layer then return end
	callback = callback_t
	main_layer = TouchGroup:create()
	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.RANGER_CONFIRM)

	createViewWidget()
	switchEditState(true)
	uiManager.showScaleEffect(main_layer,999,nil,nil,uiUtil.uiShowScaleFrom)
end



