-- bindingPhone.lua
-- 手机绑定
module("BindingPhone", package.seeall)
local main_layer = nil
local bingdingTime = nil
local confirm_btn = nil
local onBingding = nil
local bingdingHandler = nil
local inputBoxX = nil

local function updateBinding( )
    local user_stuff = allTableData[dbTableDesList.user_stuff.name][userData.getUserId()]
    if user_stuff.phone_time and bingdingTime ~= user_stuff.phone_time and user_stuff.phone_time+PHONE_BIND_COOL_DOWN > userData.getServerTime() then
        tipsLayer.create(languagePack['bingding'])
    end
end

local function do_remove_self(  )
    if main_layer then
        -- UIUpdateManager.remove_prop_update(dbTableDesList.user_stuff.name, dataChangeType.add, updateBinding)
        -- UIUpdateManager.remove_prop_update(dbTableDesList.user_stuff.name, dataChangeType.update, updateBinding)
        netObserver.removeObserver(PHONE_BIND_SEND_VERIFY_CODE)
        netObserver.removeObserver(PHONE_BIND_CHECK_VERIFY_CODE)
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        bingdingTime = nil
        confirm_btn = nil
        onBingding = nil
        inputBoxX = nil
        scheduler.remove(bingdingHandler)
        bingdingHandler = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_PHONE_BINDING)
    end
end

function remove_self( )
    uiManager.hideConfigEffect(uiIndexDefine.UI_PHONE_BINDING,main_layer,do_remove_self)
end

function dealwithTouchEvent(x,y)
	if not main_layer then
		return false
	end

	local temp_widget = main_layer:getWidgetByTag(999)

	if temp_widget and temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function setCountDownState( )
    scheduler.remove(bingdingHandler)
    bingdingHandler = nil
    confirm_btn:setBright(true)
    local label = tolua.cast(confirm_btn:getChildByName("Label_165184_0_0"),"Label")
    local Label_time = tolua.cast(confirm_btn:getChildByName("Label_time"),"Label")
    local time_ = nil
    local time_local = CCUserDefault:sharedUserDefault():getStringForKey("bingdinglimit")
    if time_local ~= "" and userData.getServerTime() - tonumber(time_local) < 60 then
        time_ = 60 - (userData.getServerTime() - tonumber(time_local))
        Label_time:setText(time_)
        confirm_btn:setBright(false)
        Label_time:setVisible(true)
        label:setVisible(false)
        inputBoxX:setText(CCUserDefault:sharedUserDefault():getStringForKey("phoneNum"))
    end

    if time_ then
        onBingding = true
        bingdingHandler = scheduler.create(function (  )
            time_ = time_ - 1
            Label_time:setText(time_)
            confirm_btn:setBright(false)
            Label_time:setVisible(true)
            label:setVisible(false)
            if time_ <= 0 then
                scheduler.remove(bingdingHandler)
                onBingding = false
                confirm_btn:setBright(true)
                Label_time:setVisible(false)
                label:setVisible(true)
            end
        end,1)
    else
        Label_time:setVisible(false)
        label:setVisible(true)
    end
end

local function receiveSEND_VERIFY_CODE(package )
    if tostring(package) == "false" then
        tipsLayer.create(languagePack['yanzhengshibai'])
    else
        CCUserDefault:sharedUserDefault():setStringForKey("bingdinglimit", userData.getServerTime())
        CCUserDefault:sharedUserDefault():setStringForKey("phoneNum",inputBoxX:getText())
        setCountDownState( )
    end
end

local function receiveCHECK_VERIFY_CODE( package )
    if tostring(package) == "false" then
        tipsLayer.create(languagePack['shuruyanzhengcuowu'])
    else
        commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,PHONE_BIND_REWARD[1][2])
        remove_self()
        HelpUI.remove_self()
        tipsLayer.create(languagePack['bingding'])
    end
end

function create( )
	if main_layer then 
		remove_self()
	end
    -- bingdingTime = allTableData[dbTableDesList.user_stuff.name][userData.getUserId()].phone_time
    -- UIUpdateManager.add_prop_update(dbTableDesList.user_stuff.name, dataChangeType.add, updateBinding)
    -- UIUpdateManager.add_prop_update(dbTableDesList.user_stuff.name, dataChangeType.update, updateBinding)
    netObserver.addObserver(PHONE_BIND_SEND_VERIFY_CODE,receiveSEND_VERIFY_CODE)
    netObserver.addObserver(PHONE_BIND_CHECK_VERIFY_CODE,receiveCHECK_VERIFY_CODE)

	main_layer = TouchGroup:create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shoujibangding.json")
    temp_widget:setTag(999)
    -- temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(0.5,0.5))
    temp_widget:setScale(config.getgScale())
    temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_PHONE_BINDING)

    --
    local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"),"Button")
    close_btn:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)


    -- 输入标题
    local panel = tolua.cast(temp_widget:getChildByName("Panel_phone"),"Layout")
    local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    -- 输入手机号
    inputBoxX = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    inputBoxX:setFontName(config.getFontName())
    inputBoxX:setFontSize(18*config.getgScale())
    inputBoxX:setFontColor(ccc3(255,213,110))
    inputBoxX:setInputMode(kEditBoxInputModeNumeric)
    temp_widget:addChild(inputBoxX,5,5)
    inputBoxX:setScale(1/config.getgScale())
    inputBoxX:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    inputBoxX:setAnchorPoint(cc.p(0,0))

    -- 输入验证码
    panel = tolua.cast(temp_widget:getChildByName("Panel_sn"),"Layout")
    local inputsn = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    inputsn:setFontName(config.getFontName())
    inputsn:setFontSize(18*config.getgScale())
    inputsn:setFontColor(ccc3(255,213,110))
    inputsn:setInputMode(kEditBoxInputModeNumeric)
    temp_widget:addChild(inputsn,5,5)
    inputsn:setScale(1/config.getgScale())
    inputsn:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    inputsn:setAnchorPoint(cc.p(0,0))


    -- 获取验证码
    local phone_number = nil--inputBoxX:getText()
    local sec_phone_num = nil
    confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"),"Button")
    confirm_btn:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
            phone_number = inputBoxX:getText()
            sec_phone_num = string.sub(phone_number, 2,2)
            if string.len(phone_number) == 11 and tonumber(phone_number) then
                if not string.sub(phone_number, 1,1) == 1 --[[or (sec_phone_num~= '3' and sec_phone_num~= '4' and sec_phone_num~= '5' and sec_phone_num~= '8')]] then
                    tipsLayer.create(languagePack['youxiaoshuzi'])
                    return
                end
                if not onBingding then
            	    Net.send(PHONE_BIND_SEND_VERIFY_CODE,{inputBoxX:getText()})
                else
                    tipsLayer.create(languagePack['zhengzaiyanzheng'])
                end
            else
                tipsLayer.create(languagePack['youxiaoshuzi'])
            end
        end
    end)

    -- 验证手机号
    local confirm_btn_phone = tolua.cast(temp_widget:getChildByName("confirm_btn_phone"),"Button")
    confirm_btn_phone:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
            if string.len(inputsn:getText()) > 0 then
            	Net.send(PHONE_BIND_CHECK_VERIFY_CODE,{inputBoxX:getText(),inputsn:getText()})
            else
                tipsLayer.create(languagePack['yanzhengmawuxiao'])
            end
        end
    end)

    local reward = tolua.cast(temp_widget:getChildByName("label_num"),"Label")
    reward:setText(PHONE_BIND_REWARD[1][2])
    setCountDownState( )

    uiManager.showConfigEffect(uiIndexDefine.UI_PHONE_BINDING, main_layer)
end