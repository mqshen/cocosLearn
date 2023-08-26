-- helpUI.lua
module("HelpUI", package.seeall)
local main_layer = nil
local function do_remove_self(  )
    if main_layer then
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_HELP_UI)
    end
end

function remove_self( )
    uiManager.hideConfigEffect(uiIndexDefine.UI_HELP_UI,main_layer,do_remove_self)
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

function create( )
    if not config.ClientFuncisVisible(CLIENT_FUNC_CUSTOMER_SERVICE) and 
        not config.ClientFuncisVisible(CLIENT_FUNC_GAME_SPRITE) and 
        not config.ClientFuncisVisible(CLIENT_FUNC_PHONE_BIND) then
        tipsLayer.create("敬请期待")
        return
    end

	if main_layer then 
		remove_self()
	end
	main_layer = TouchGroup:create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/youxibangzhu.json")
    temp_widget:setTag(999)
    -- temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(0.5,0.5))
    temp_widget:setScale(config.getgScale())
    temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_HELP_UI)

    --客服中心
    local customer = tolua.cast(temp_widget:getChildByName("confirm_btn_1"),"Button")
    if config.ClientFuncisVisible(CLIENT_FUNC_CUSTOMER_SERVICE) then
        customer:setVisible(true)
        customer:setTouchEnabled(true)
        customer:addTouchEventListener(function (sender, eventType  )
            if eventType == TOUCH_EVENT_ENDED then
                if configBeforeLoad.getDebugEnvironment() then
                    gmManager.create()
                    return
                end
                Net.send(USER_GET_CUSTOMER_SERVICE_TOKEN,{})
                netObserver.addObserver(USER_GET_CUSTOMER_SERVICE_TOKEN,function (package )
                    netObserver.removeObserver(USER_GET_CUSTOMER_SERVICE_TOKEN)
                    if configBeforeLoad.getDebugEnvironment() then
                        sdkMgr:sharedSkdMgr():ntOpenDevGMSite("stzb",package)
                    else
                        sdkMgr:sharedSkdMgr():ntOpenGMSite("stzb",package)
                    end
                end)
            end
        end)
    else
        customer:setVisible(false)
        customer:setTouchEnabled(false)
    end

    --游戏精灵
    local gameSprite = tolua.cast(temp_widget:getChildByName("confirm_btn_2"),"Button")
    if config.ClientFuncisVisible(CLIENT_FUNC_GAME_SPRITE) then
        gameSprite:setVisible(true)
        gameSprite:setTouchEnabled(true)
        gameSprite:addTouchEventListener(function (sender, eventType  )
            if eventType == TOUCH_EVENT_ENDED then
                remove_self()
                GameSpriteMainUI.create()
                -- BattleLoadingUI.create()
            end
        end)
    else
        gameSprite:setVisible(false)
        gameSprite:setTouchEnabled(false)
    end

    local binding = tolua.cast(temp_widget:getChildByName("confirm_btn_3"),"Button")
    local user_stuff = allTableData[dbTableDesList.user_stuff.name][userData.getUserId()]
    if user_stuff.phone_time and user_stuff.phone_time+PHONE_BIND_COOL_DOWN > userData.getServerTime() then
        binding:setVisible(false)
        binding:setTouchEnabled(false)
    else
        if config.ClientFuncisVisible(CLIENT_FUNC_PHONE_BIND) then
            binding:setVisible(true)
            binding:setTouchEnabled(true)
            --手机绑定
            binding:addTouchEventListener(function (sender, eventType  )
                if eventType == TOUCH_EVENT_ENDED then
                    BindingPhone.create()
                    -- BonusUI.create()
                end
            end)
        else
            binding:setVisible(false)
            binding:setTouchEnabled(false)
        end
    end

    --关闭按钮
    local btn_close = tolua.cast(temp_widget:getChildByName("btn_close"),"Button")
    btn_close:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)
    
    uiManager.showConfigEffect(uiIndexDefine.UI_HELP_UI, main_layer)
end