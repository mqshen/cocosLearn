UnionOfficialManagement = {}

local UnionOfficialAppoint = require("game/union/unionOfficialAppoint")
local UnionOfficialApplyOpen = require("game/union/unionOfficialApplyOpen")
local UnionOfficialApplyClose = require("game/union/unionOfficialApplyClose")
local UnionOfficialInvite = require("game/union/unionOfficialInvite")
local UnionOfficialDismiss = require("game/union/unionOfficialDismiss")
local UnionOfficialQuit = require("game/union/unionOfficialQuit")



local uiUtil = require("game/utils/ui_util")
local union_id = nil
local main_layer = nil
local selected_indx = nil
local isApplyOpen = nil
local mainPanel = nil

local function removeAllPanel()
    UnionOfficialAppoint.remove()
    UnionOfficialApplyOpen.remove()
    UnionOfficialApplyClose.remove()
    UnionOfficialInvite.remove()
    UnionOfficialDismiss.remove()
    UnionOfficialQuit.remove()
end
local function do_remove_self()
    if not main_layer then return end
    removeAllPanel()
    union_id = nil
    if mainPanel then 
        mainPanel:remove()
        mainPanel = nil
    end
    if main_layer then 
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UNION_OFFICIAL_MANAGEMENT)
    end

    UIUpdateManager.remove_prop_update(dbTableDesList.union_apply_notice.name, dataChangeType.update, UnionOfficialManagement.refreshNotice)

    selected_indx = nil
    isApplyOpen = nil
    --TODO 删除数据更新器
end

function UnionOfficialManagement.remove_self(closeEffect)
    if not main_layer then return end
    if not mainPanel then return end
    if closeEffect then
        do_remove_self()
        return
    end
    uiManager.hideConfigEffect(uiIndexDefine.UNION_OFFICIAL_MANAGEMENT,main_layer,do_remove_self,999,{mainPanel:getMainWidget()})
end




function UnionOfficialManagement.dealwithTouchEvent(x,y)
    return false
end

function UnionOfficialManagement.updateAppointList(package)
    if selected_indx ~= 1 then return end
    UnionOfficialAppointList.updateData(package)
end

function UnionOfficialManagement.switchApplyState()
    UnionOfficialData.requestSwitchAppllyState()
    isApplyOpen = not isApplyOpen
end
function UnionOfficialManagement.updateData(package,indx)
    if indx ~= selected_indx then return end
    if selected_indx == 1 then
        UnionOfficialAppoint.updateData(package[1])
        if package[2] == 1 then 
            isApplyOpen = true 
        else
            isApplyOpen = false
        end
    elseif selected_indx == 2 then
        if isApplyOpen then 
            UnionOfficialApplyOpen.updateData(package)
        end
    elseif selected_indx == 3 then
        UnionOfficialInvite.updateData(package)
    end
end

function UnionOfficialManagement.requestDataFromServer(indx)
    if selected_indx ~= indx then return end
    if indx == 1 then
        UnionOfficialAppoint.requestDataFromServer()
    elseif indx == 2 then 
        --TODO
        --UnionOfficialData.requestUnionApplyList()
    elseif indx == 3 then 
        UnionOfficialInvite.requestDataFromServer()
    end
end

function UnionOfficialManagement.setViewIndx(indx)
    if indx > 5 or indx < 1 then return end
    
    removeAllPanel()

    
    local mainWidget = main_layer:getWidgetByTag(999)
    local main_panel = uiUtil.getConvertChildByName(mainWidget,"main_panel")
    if indx == 1 then
        UnionOfficialAppoint.create(main_panel,mainWidget,union_id)
    elseif indx == 2 then 
        if isApplyOpen == true then 
            UnionOfficialApplyOpen.create(main_panel,mainWidget,union_id)
        else
            UnionOfficialApplyClose.create(main_panel,mainWidget,union_id)
        end
    elseif indx == 3 then 
        UnionOfficialInvite.create(main_panel,mainWidget,union_id)
    elseif indx == 4 then 
        UnionOfficialDismiss.create(main_panel,mainWidget,union_id)
    elseif indx == 5 then 
        UnionOfficialQuit.create(main_panel,mainWidget,union_id)
    end

    selected_indx = indx
    local temp_btn = nil
    for i = 1,5 do 
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_" .. i)
        if temp_btn:isVisible() then 
            temp_btn:setTouchEnabled(true)
            temp_btn:setBright(true)
            uiUtil.setBtnLabel(temp_btn,false)
        end
        if selected_indx == i then 
            temp_btn:setTouchEnabled(false)
            temp_btn:setBright(false)
            uiUtil.setBtnLabel(temp_btn,true)
        end
    end

    UnionOfficialManagement.refreshNotice()
end


--  非盟主或者非副盟主 ，解散同盟按钮不可见
function UnionOfficialManagement.autoAlginBtns()
    
    local mainWidget = main_layer:getWidgetByTag(999)
    local temp_btn = nil
    if userData.isUnionLeader() then 
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_4")
        temp_btn:setVisible(true)
        temp_btn:setPositionX(500)
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_5")
        temp_btn:setPositionX(637)
        temp_btn:setVisible(true)

        UnionOfficialManagement.setViewIndx(1)
        return
    end

    if userData.isUnionDeputyLeader() then 
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_4")
        temp_btn:setVisible(false)
        temp_btn:setPositionX(500)
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_5")
        temp_btn:setPositionX(500)
        temp_btn:setVisible(true)
        UnionOfficialManagement.setViewIndx(1)
        return 
    end

    -- 非管理成员
    for i = 1,5 do 
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_" .. i)
        temp_btn:setVisible(false)
        temp_btn:setTouchEnabled(false)
    end
    temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_5")
    temp_btn:setPositionX(93)
    temp_btn:setVisible(true)
    UnionOfficialManagement.setViewIndx(5)
end
function UnionOfficialManagement.create(unionID)
    if main_layer then return end
    union_id = unionID
    
    main_layer = TouchGroup:create()
    uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UNION_OFFICIAL_MANAGEMENT)

    local widget = GUIReader:shareReader():widgetFromJsonFile("test/union_manaer_main.json")
    
    widget:setTag(999)
    widget:setScale(config.getgScale())
    widget:ignoreAnchorPointForPosition(false)
    widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    
    mainPanel = UIBackPanel.new() 

    local title_name = panelPropInfo[uiIndexDefine.UNION_OFFICIAL_MANAGEMENT][2]
    local temp_widget= mainPanel:create(widget, UnionOfficialManagement.remove_self,title_name)
    main_layer:addWidget(temp_widget)
    

    local temp_btn = nil
    local img_notice = nil
    for i = 1,5 do 
        temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. i)
        
        if i == 2 then 
            img_notice = uiUtil.getConvertChildByName(temp_btn,"img_notice")
            img_notice:setVisible(false)
        end
        temp_btn:setTouchEnabled(true)
        temp_btn:addTouchEventListener(function (sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                UnionOfficialManagement.setViewIndx(i) 
            end
        end)
    end


    -- local back = tolua.cast(mWidget:getChildByName("ImageView_23592_0_0"),"ImageView" )
    -- local arrow = tolua.cast(mWidget:getChildByName("ImageView_209575"),"ImageView" )
    -- tolua.cast(mWidget:getChildByName("ImageView_209575_0"),"ImageView" ):setVisible(false)
    -- panel = tolua.cast(mWidget:getChildByName("Panel_31663"),"Layout")
    -- local back_ground = tolua.cast(back:getChildByName("Panel_891796"),"Layout")
    -- -- back_ground:setVisible(false)
    -- UIListViewSize.definedUIpanel(mainPanel ,back,panel, arrow, {back_ground})

    

    --TODO 添加数据更新器
    UnionOfficialManagement.autoAlginBtns()

    


    UIUpdateManager.add_prop_update(dbTableDesList.union_apply_notice.name, dataChangeType.update, UnionOfficialManagement.refreshNotice)

    uiManager.showConfigEffect(uiIndexDefine.UNION_OFFICIAL_MANAGEMENT,main_layer,nil,999,{mainPanel:getMainWidget()})
end

function UnionOfficialManagement.refreshNotice()
    if not main_layer then return end
    local widget = main_layer:getWidgetByTag(999)
    if not widget then return end
    local temp_btn = nil
    local img_notice = nil
    for i = 1,5 do 
        temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. i)
        if i == 2 then 
            img_notice = uiUtil.getConvertChildByName(temp_btn,"img_notice")
        end
        -- 申请
        if img_notice and i == 2 then 
            
            if selected_indx == 2  then
                -- 由于申请列表不会即时刷新，所以这里以已获取到的数据为依据
                if UnionOfficialApplyOpen.hasUnread()  then  
                    img_notice:setVisible(true)
                else
                    img_notice:setVisible(false)
                end
            else
                -- 这里以服务端的标志为依据
                if userData.hasNewUnionApply() then
                    img_notice:setVisible(true)
                else
                    img_notice:setVisible(false)
                end
            end
        end
    end
end
function UnionOfficialManagement.responeHandlerApplyItem(handlerFlag)
    UnionOfficialApplyOpen.responeHandlerApplyItem(handlerFlag)
end




