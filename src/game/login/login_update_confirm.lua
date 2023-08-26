local loginUpdateConfirm = {}

local main_layer = nil
local main_widget = nil
local uiUtil = require("game/utils/ui_util")


function loginUpdateConfirm.remove()
    if main_widget then 
        comAlertConfirm.remove_self()
        main_widget = nil
    end
    if main_layer then
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
    end
end

function loginUpdateConfirm.create(param)
    if main_layer then 
        loginUpdateConfirm.remove()
    end

    main_layer = TouchGroup:create()

    main_widget = comAlertConfirm.fetchOnlyWidget(param)


    main_widget:setTag(999)
    main_widget:setScale(config.getgScale())
    main_widget:ignoreAnchorPointForPosition(false)
    main_widget:setAnchorPoint(cc.p(0.5,0.5))
    main_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_layer:addWidget(main_widget)


    cc.Director:getInstance():getRunningScene():addChild(main_layer)


    local btn_cancel = uiUtil.getConvertChildByName(main_widget,"btn_cancel")
    local btn_ok = uiUtil.getConvertChildByName(main_widget,"btn_ok")


    btn_ok:addTouchEventListener(function(sender,eventType) 
        if eventType == TOUCH_EVENT_ENDED then
            if not param or
                not param.callback or 
                type(param.callback) ~= "function" then 
                loginUpdateConfirm.remove()
                return 
            end
            sender:setTouchEnabled(false)
            local temp_call_back = param.callback
            loginUpdateConfirm.remove()
            temp_call_back()
        end
    end)

    btn_cancel:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            loginUpdateConfirm.remove()
        end
    end)

end


return loginUpdateConfirm