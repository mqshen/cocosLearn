module("UIChatDefriend",package.seeall)

local main_layer = nil

local uiUtil = require("game/utils/ui_util")
local user_id = nil
local user_name = nil

function remove_self()
    if main_layer then
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_CHAT_DEFRIEND)
    end

    user_id = nil
    user_name = nil
end

function dealwithTouchEvent(x,y)
    if not main_layer then return false end

    local widget = main_layer:getWidgetByTag(999)
    if not widget then return false end
    if widget:hitTest(cc.p(x,y)) then 
        return false
    else
        remove_self()
        return true
    end
end


function create(userID,userName)
    if main_layer then return end
    user_id = userID 
    user_name = userName

    local widget = GUIReader:shareReader():widgetFromJsonFile("test/ui_chat_defriend.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    main_layer = TouchGroup:create()
    main_layer:addWidget(widget)
    uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_CHAT_DEFRIEND)

    local close_btn = uiUtil.getConvertChildByName(widget,"close_btn")
    close_btn:setTouchEnabled(true)
    close_btn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)

    local panel_label = uiUtil.getConvertChildByName(widget,"panel_label")

    local label_target_flag = uiUtil.getConvertChildByName(panel_label,"label_target_flag")
    

    local label_target_name = uiUtil.getConvertChildByName(panel_label,"label_target_name")
    label_target_name:setText(" ")
    label_target_name:setText("“"  .. userName .. "”")
    
    local panel_w = label_target_flag:getContentSize().width +  label_target_name:getContentSize().width
    panel_label:setContentSize(CCSize( panel_w,30))
    panel_label:setPosition(cc.p((443 -panel_w)/2, 220))
    local confirm_btn = uiUtil.getConvertChildByName(widget,"confirm_btn")
    confirm_btn:setTouchEnabled(true)
    confirm_btn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            --TODO 发送添加黑名单
            BlackNameListData.addUserByIdList({user_id})
            remove_self()
        end
    end)

end


