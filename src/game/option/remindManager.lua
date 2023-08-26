local remind_layer = nil
local mail_count = 0
local battle_count = 0
local att_count = 0
local ground_count = 0
-- local bIsStarGame = true
local function remove()
    remind_layer = nil
    mail_count = 0
    battle_count = 0
    ground_count = 0
    att_count = 0
    UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.add, remindManager.updateAttack)
    UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.remove, remindManager.updateAttack)
    UIUpdateManager.remove_prop_update(dbTableDesList.mail_receive.name, dataChangeType.update, remindManager.unreadMessageUpdata)
    UIUpdateManager.remove_prop_update(dbTableDesList.mail_receive.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.remove_prop_update(dbTableDesList.mail_receive.name, dataChangeType.remove, remindManager.unreadMessageUpdata)

    UIUpdateManager.remove_prop_update(dbTableDesList.report_attack.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.remove_prop_update(dbTableDesList.report_attack.name, dataChangeType.update, remindManager.unreadMessageUpdata)
    UIUpdateManager.remove_prop_update(dbTableDesList.report_defend.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.remove_prop_update(dbTableDesList.report_defend.name, dataChangeType.update, remindManager.unreadMessageUpdata)



    UIUpdateManager.remove_prop_update(dbTableDesList.user_field_event_report.name, dataChangeType.update, remindManager.unreadMessageUpdata)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_field_event_report.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_field_event_report.name, dataChangeType.update, remindManager.unreadMessageUpdata)

end

local function updateChangeCityState(is_in_city)
    if not remind_layer then return end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    if is_in_city then
        temp:setVisible(false)
        
    else
        temp:setVisible(true)
    end
end

local function dealwithTouchEvent(x, y)
    if not remind_layer then return false end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    if not temp_left_widget then return end
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")


    for i = 1,5 do 
        local temp_btn = uiUtil.getConvertChildByName(temp,"btn_" .. i)
        if temp_btn:hitTest(cc.p(x,y)) then 
            mapMessageUI.disableTouchAndRemove()
        end
    end
    return false
end

-- 自适应按钮布局
-- 水平左对齐自适应
local function autoOffsetBtns()
    if not remind_layer then return end

    local temp_left_widget = remind_layer:getWidgetByTag(990)
    if not temp_left_widget then return end
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    local btn = nil

    local indxSort = {2,3,1,5} 
    local startPosX = 114
    for i = 1,#indxSort do 
        btn = tolua.cast(temp:getChildByName("btn_" .. indxSort[i]),"Button")
        if btn:isVisible() then 
            btn:setPositionX(startPosX)
            startPosX = startPosX + 76
        end
    end

end

--index 1 敌袭 2 战报 3 邮件 4 地表事件 5 手机绑定
local function setBtnOption(btn, count, index, callBack, page )
    if not remind_layer then return end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    if count > 0 then
        btn:setTouchEnabled(true)
        btn:setVisible(true)
        tolua.cast(btn:getChildByName("num_txt_"..index),"Label"):setText(count)
    else
        btn:setTouchEnabled(false)
        btn:setVisible(false)
    end
  
    btn:addTouchEventListener(function (sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if temp:isVisible() and count > 0 then
                if index ~= 1 then
                    btn:setTouchEnabled(false)
                    btn:setVisible(false)
                    autoOffsetBtns()
                end
                newGuideInfo.enter_next_guide()
                callBack(1,page)
            end
        end
    end)

    if index == 1 then 
        --由于更改了部队信息界面，现在已经可以在主界面中直接看到敌军来袭的信息，因此原来主UI左下方的敌袭提示图标不需要显示
        btn:setTouchEnabled(false)
        btn:setVisible(false)
    end
    autoOffsetBtns()
end

local function getUnreadMailCount( )
    local count = 0
    for i, v in pairs(allTableData[dbTableDesList.mail_receive.name]) do
        if v.read == 0 then
            count = count + 1
        end
    end
    return count
end

local function getUnreadReportCount( )
    local count = 0
    for i, v in pairs(allTableData[dbTableDesList.report_attack.name]) do
        if v.read == 0 then
            count = count + 1
        end
    end

    for i, v in pairs(allTableData[dbTableDesList.report_defend.name]) do
        if v.read == 0 then
            count = count + 1
        end
    end

    return count
end

-- 手机绑定
local function updateBinding( )
    if not remind_layer then return end
    if not config.ClientFuncisVisible(CLIENT_FUNC_PHONE_BIND) then return end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    local user_stuff = allTableData[dbTableDesList.user_stuff.name][userData.getUserId()]
    local dayOne = CCUserDefault:sharedUserDefault():getStringForKey("dayOne")
    local dayTwo = CCUserDefault:sharedUserDefault():getStringForKey("dayTwo")
    local dayThree = CCUserDefault:sharedUserDefault():getStringForKey("dayThree")

    if user_stuff.phone_time > 0 and user_stuff.phone_time+PHONE_BIND_COOL_DOWN > userData.getServerTime() then
        CCUserDefault:sharedUserDefault():setStringForKey("dayOne","")
        CCUserDefault:sharedUserDefault():setStringForKey("dayTwo","")
        CCUserDefault:sharedUserDefault():setStringForKey("dayThree","")
    end

    if userData.getShowRenownNums() > 2700 and (user_stuff.phone_time <=0 or user_stuff.phone_time+PHONE_BIND_COOL_DOWN < userData.getServerTime()) then
        if string.len(dayThree) > 0 then
            return
        end

        if string.len(dayTwo) > 0 and userData.getServerTime() < tonumber(dayTwo) then
            return
        end

        if string.len(dayOne) > 0 and userData.getServerTime() < tonumber(dayOne) then
            return
        end

        local btn = tolua.cast(temp:getChildByName("btn_5"),"Button")
        setBtnOption(btn, 1, 5, function ( )
            if string.len(dayOne) <= 0 then
                CCUserDefault:sharedUserDefault():setStringForKey("dayOne",tostring(userData.getServerTime()+3*24*3600))
            else
                if string.len(dayTwo) <= 0 then
                    CCUserDefault:sharedUserDefault():setStringForKey("dayTwo",tostring(userData.getServerTime()+7*24*3600))
                else
                    CCUserDefault:sharedUserDefault():setStringForKey("dayThree",tostring(userData.getServerTime()))
                end
            end
            BindingPhone.create()
        end)
    end
end

--邮件
local function updateMail()
    if mailManager.get_open_state() then
        return
    end

    if not remind_layer then return end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    local btn = tolua.cast(temp:getChildByName("btn_3"),"Button")
    local count =  getUnreadMailCount()
    setBtnOption(btn, count, 3, mailManager.on_enter)
    return count
end

--战报
local function updateBattle( )
    require("game/battle/reportUI")
    -- if reportUI.getInstance() then return end
    if not remind_layer then return end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    local btn = tolua.cast(temp:getChildByName("btn_2"),"Button")
    local count =  getUnreadReportCount()
    setBtnOption(btn, count, 2, reportUI.create, 0 )
    return count
end

--敌袭
--行军列表表现修改了，现在先做个空函数，后续直接删除就好了
local function dx_temp_fun()
    print("==================== dixi")
end

local function updateAttack( )
    if not remind_layer then return end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    local btn = tolua.cast(temp:getChildByName("btn_1"),"Button")
    local count = 0
    for i , v in pairs(armyData.getAllAssaultMsg()) do
        if v.id then
            count = count + 1
        end
    end

    if count > att_count then
        LSound.playMusic("main_bgm4")
        LSound.playSound(musicSound["sys_alarm"])
    end
    att_count = count
    setBtnOption(btn, count, 1, dx_temp_fun)
end

--地表事件提示
local function updateGroundEvent( )
    -- require("game/battle/reportUI")
    -- if reportUI.getInstance() then return end
    if not remind_layer then return end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    local btn = tolua.cast(temp:getChildByName("btn_4"),"Button")
    local count = 0
    for i, v in pairs(GroundEventData.getWorldEventLog()) do
        if v.report_id then
            count = 1
            break
        end
    end
    
    -- 地表事件移到聊天信息框里了
    count = 0
    setBtnOption(btn, count, 4, GroundEventDescribe.create)
    return count
end

local function unreadMessageUpdata( )
    local temp_mail = updateMail( )
    local temp_battle = updateBattle( )
    local temp_groundEvent = updateGroundEvent()

    if not mail_count then
        mail_count = 0
    end

    if not battle_count then
        battle_count = 0 
    end

    if not ground_count then
        ground_count = 0
    end
    
    if (temp_mail and temp_mail > mail_count) or (temp_battle and temp_battle > battle_count)
    or (temp_groundEvent and temp_groundEvent > ground_count) then
        LSound.playSound(musicSound["sys_ring"])
    end
    mail_count = temp_mail
    ground_count = temp_groundEvent
    battle_count = temp_battle
end

local function hideEffect(duration)
    if not remind_layer then return end
    if not duration then duration = 0.5 end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    uiUtil.hideScaleEffect(temp_left_widget,nil,duration)
end
local function showEffect(duration)
    if not remind_layer then return end
    if not duration then duration = 0.5 end
    local temp_left_widget = remind_layer:getWidgetByTag(990)
    uiUtil.showScaleEffect(temp_left_widget,nil,duration,nil,nil)
end

local function create(parent_layer)
    UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.add, remindManager.updateAttack)
    UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.remove, remindManager.updateAttack)
    UIUpdateManager.add_prop_update(dbTableDesList.mail_receive.name, dataChangeType.update, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.mail_receive.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.mail_receive.name, dataChangeType.remove, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.report_attack.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.report_attack.name, dataChangeType.update, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.report_defend.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.report_defend.name, dataChangeType.update, remindManager.unreadMessageUpdata)

    UIUpdateManager.add_prop_update(dbTableDesList.user_field_event_report.name, dataChangeType.update, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.user_field_event_report.name, dataChangeType.add, remindManager.unreadMessageUpdata)
    UIUpdateManager.add_prop_update(dbTableDesList.user_field_event_report.name, dataChangeType.update, remindManager.unreadMessageUpdata)
    
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.update, remindManager.changeTaxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.add, remindManager.changeTaxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.remove, remindManager.changeTaxBtn)

    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, remindManager.taxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, remindManager.taxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.remove, remindManager.taxBtn)

    remind_layer = parent_layer


	local temp_left_widget = GUIReader:shareReader():widgetFromJsonFile("test/remindLeftbar.json")
    temp_left_widget:setTag(990)
    temp_left_widget:ignoreAnchorPointForPosition(false)
    temp_left_widget:setAnchorPoint(cc.p(0,0))
    temp_left_widget:setScale(config.getgScale())
    temp_left_widget:setPosition(cc.p(0, 0))
    remind_layer:addWidget(temp_left_widget)

    local temp = tolua.cast(temp_left_widget:getChildByName("Panel_376128"),"Layout")
    local btnTable = {1,2,3,5}
    for i,v in pairs(btnTable) do
        tolua.cast(temp:getChildByName("btn_"..v),"Button"):setVisible(false)
        tolua.cast(temp:getChildByName("btn_"..v),"Button"):setTouchEnabled(false)
    end



    -- if bIsStarGame then
        updateMail( )
        updateBattle( )
        updateAttack( )
        updateGroundEvent()
        updateBinding()
    -- end
    -- bIsStarGame = false
end

local function get_guide_widget()
    if remind_layer then
        return remind_layer:getWidgetByTag(990)
    else
        return nil
    end
end

remindManager = {
					create = create,
                    remove = remove,
                    get_guide_widget = get_guide_widget,
                    updateAttack = updateAttack,
                    updateChangeCityState = updateChangeCityState,
                    unreadMessageUpdata = unreadMessageUpdata,
                    updateGroundEvent = updateGroundEvent,
                    hideEffect = hideEffect,
                    showEffect = showEffect,
                    dealwithTouchEvent = dealwithTouchEvent,
}