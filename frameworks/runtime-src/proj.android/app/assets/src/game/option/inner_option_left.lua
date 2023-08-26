innerOptionLeft = {}

local tableInsert = table.insert

local uiUtil = require("game/utils/ui_util")
local mainWidget = nil

local buidlingQueueTV = nil

local isEnable = nil




local function clearBuildQueueItem()
    if not mainWidget then return end
    local temp_panel_queueItem = nil
    for i = 1,10 do 
        temp_panel_queueItem = mainWidget:getChildByName("free_" .. i)
        if temp_panel_queueItem then 
            temp_panel_queueItem:removeFromParentAndCleanup(true)
        end
    end
    for i = 1,10 do 
        temp_panel_queueItem = mainWidget:getChildByName("temp_" .. i)
        if temp_panel_queueItem then 
            temp_panel_queueItem:removeFromParentAndCleanup(true)
        end
    end
end

local function reloadBuildQueueNum()
    if not mainWidget then return end
    if not mainWidget then return end

    local img_queue_head_1 = uiUtil.getConvertChildByName(mainWidget,"img_queue_head_1")
    local img_queue_head_2 = uiUtil.getConvertChildByName(mainWidget,"img_queue_head_2")
    local panel_queueItem = uiUtil.getConvertChildByName(mainWidget,"panel_queueItem")
    local tab_freeQueue = politics.getBuildingBuildListInCity(mainBuildScene.getThisCityid(),1)
    local tab_tempQueue = politics.getBuildingBuildListInCity(mainBuildScene.getThisCityid(),2)

    local label_num = uiUtil.getConvertChildByName(img_queue_head_1,"label_num")
    label_num:setText(#tab_freeQueue .. "/" .. userData.getBuildingQueneNum())
    label_num = uiUtil.getConvertChildByName(img_queue_head_2,"label_num")
    label_num:setText(#tab_tempQueue)

end
local function updateCellTimer(widget,msg)
    if not widget then return end
    if not msg then return end

    local imgS1 = nil
    local imgS2 = nil
    local imgM1 = nil
    local imgM2 = nil
    local imgH1 = nil
    local imgH2 = nil
    local hour,min,sec = 0,0,0
    local endCountDown = 0

    local progressBar = nil

   
    progressBar = uiUtil.getConvertChildByName(widget,"progress_bar")
    local atlas_label_cd = uiUtil.getConvertChildByName(widget,"atlas_label_cd")

    local needTimeNUm= 0
    local build_base_id = msg.build_id_u%100
    if msg.state == buildState.upgrade then
        local show_build_level_id = build_base_id*100 + msg.level + 1
        needTimeNUm = Tb_cfg_build_cost[show_build_level_id].time_cost
    else
        if build_base_id == cityBuildDefine.chengzhufu then
            needTimeNUm = BRANCH_CITY_DEL_TIME
        elseif build_base_id == cityBuildDefine.baolei then
            needTimeNUm = FORT_DEL_TIME
        else
            needTimeNUm = BUILD_DEGRADE_TIME  --拆除现在统一都是5分钟
        end
    end

    local endCountDown = msg.end_time - userData.getServerTime()
    if endCountDown > 0 then
        progressBar:setPercent(100 - 100 * endCountDown/needTimeNUm)
    else
        progressBar:setPercent(100)
    end

    -- hour,min,sec = commonFunc.for_time_h_m_s(endCountDown)
    
    atlas_label_cd:setStringValue(commonFunc.format_time(endCountDown,true))
    
end


function innerOptionLeft.reloadData()
    
    if not mainWidget then return end
    local img_queue_head_1 = uiUtil.getConvertChildByName(mainWidget,"img_queue_head_1")
    local img_queue_head_2 = uiUtil.getConvertChildByName(mainWidget,"img_queue_head_2")
    local panel_queueItem = uiUtil.getConvertChildByName(mainWidget,"panel_queueItem")
    panel_queueItem:setVisible(false)
    img_queue_head_1:setVisible(false)
    img_queue_head_2:setVisible(false)
    local tab_freeQueue = politics.getBuildingBuildListInCity(mainBuildScene.getThisCityid(),1)
    local tab_tempQueue = politics.getBuildingBuildListInCity(mainBuildScene.getThisCityid(),2)

    local label_num = uiUtil.getConvertChildByName(img_queue_head_1,"label_num")
    label_num:setText(#tab_freeQueue .. "/" .. userData.getBuildingQueneNum())
    label_num = uiUtil.getConvertChildByName(img_queue_head_2,"label_num")
    label_num:setText(#tab_tempQueue)
    clearBuildQueueItem()

    local temp_panel_queueItem = nil

    local function cloneQueueItem(info)
        temp_panel_queueItem = panel_queueItem:clone()
        temp_panel_queueItem:setVisible(true)
        mainWidget:addChild(temp_panel_queueItem)

        local btn_quickComplete = uiUtil.getConvertChildByName(temp_panel_queueItem,"btn_quickComplete")
        btn_quickComplete:setTouchEnabled(true)
        btn_quickComplete:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                local need_yuanbao_num = userData.getBuildFinishImmediatelyCostYuanbao(info.end_time - userData.getServerTime())
                if need_yuanbao_num > userData.getYuanbao() then
                    alertLayer.create(errorTable[43])
                else
                    local function done( )
                        politics.requestOneDoneImmediately(info.build_id_u)
                    end
                    alertLayer.create(errorTable[44], {need_yuanbao_num}, done)
                end
            end
        end)


        local label_name = uiUtil.getConvertChildByName(temp_panel_queueItem,"label_name")
        label_name:setText(Tb_cfg_build[info.build_id_u%100].name)
        local label_lv = uiUtil.getConvertChildByName(temp_panel_queueItem,"label_lv")
        
        local label_removing = uiUtil.getConvertChildByName(temp_panel_queueItem,"label_removing")
        label_removing:setVisible(false)
        if info.state == 1 then
        --建造
            if info.level == 0 then
                -- title:setText(Tb_cfg_build[msg.build_id_u%100].name..languagePack["lv"].."1"..languagePack["jianzhuzhong"])
                label_lv:setText(languagePack["lv"] .. 1)
        --升级
            else
                -- title:setText(Tb_cfg_build[msg.build_id_u%100].name..languagePack["lv"]..(msg.level+1)..languagePack["shengjizhong"])
                label_lv:setText(languagePack["lv"] .. (info.level+1))
            end
        --降级
        elseif info.state == buildState.demolition then
            -- title:setText(Tb_cfg_build[msg.build_id_u%100].name..languagePack["lv"]..msg.level..languagePack["chaichuzhong"])
            label_lv:setText(languagePack["lv"] .. info.level)
            label_removing:setVisible(true)
        end

        if label_removing:isVisible() then 
            label_name:setPositionY(35)
            label_lv:setPositionY(35)
            label_removing:setPositionY(15)
        else
            label_name:setPositionY(25)
            label_lv:setPositionY(25)
        end
    end
        

    -- local city_panel = uiUtil.getConvertChildByName(mainWidget,"city_panel")
    local pos_y = mainWidget:getContentSize().height
    local split_y = 2
    if #tab_tempQueue ~= 0 or #tab_freeQueue ~= 0 then 
        img_queue_head_1:setVisible(true)
        pos_y = pos_y - img_queue_head_1:getContentSize().height/2 
        img_queue_head_1:setPositionY(pos_y)
        pos_y = pos_y - img_queue_head_1:getContentSize().height/2 - 1
    end
    -- pos_y = pos_y - city_panel:getContentSize().height - split_y
    if #tab_freeQueue ~= 0 then 
        
        for i,v in ipairs(tab_freeQueue) do 
            cloneQueueItem(v)
            pos_y = pos_y  - temp_panel_queueItem:getContentSize().height  - split_y
            temp_panel_queueItem:setPosition(cc.p(0, pos_y ))
            temp_panel_queueItem:setName("free_" .. i)
            updateCellTimer(temp_panel_queueItem,v)
        end 
    end
    if #tab_tempQueue ~= 0 then 
        img_queue_head_2:setVisible(true)
        pos_y = pos_y - img_queue_head_2:getContentSize().height/2 
        img_queue_head_2:setPositionY(pos_y)
        pos_y = pos_y - img_queue_head_2:getContentSize().height/2  - 1
        for i,v in ipairs(tab_tempQueue) do 
            cloneQueueItem(v)
            pos_y = pos_y  - temp_panel_queueItem:getContentSize().height  - split_y
            temp_panel_queueItem:setPosition(cc.p(0, pos_y ))
            temp_panel_queueItem:setName("temp_" .. i)
            updateCellTimer(temp_panel_queueItem,v)
        end 
    end
end

local function dealWithBuildUpdate()
    innerOptionLeft.reloadData()
end




local function registBuildingUpdate()
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, dealWithBuildUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, dealWithBuildUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.remove, dealWithBuildUpdate)
end
local function unregistBuildingUpdate()
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.add, dealWithBuildUpdate)
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, dealWithBuildUpdate)
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.remove, dealWithBuildUpdate)
end



function innerOptionLeft.dealwithTouchEvent(x,y)
    return false
end



local function expandCityListView(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        require("game/option/cityListOption")
	    cityListOption.create()
    end
end

local function showCityOverview(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        cityMsg.create()
    end
end




local function disposeSchedulerHandler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
    end
end

local function updateScheduler()
    if not mainWidget then return end
    local temp_panel_queueItem = nil
    

    local tab_freeQueue = politics.getBuildingBuildListInCity(mainBuildScene.getThisCityid(),1)
    local tab_tempQueue = politics.getBuildingBuildListInCity(mainBuildScene.getThisCityid(),2)
    
    for i,v in ipairs(tab_freeQueue) do 
        temp_panel_queueItem = mainWidget:getChildByName("free_" .. i)
        updateCellTimer(temp_panel_queueItem,v)
    end

    for i,v in ipairs(tab_tempQueue) do 
        temp_panel_queueItem = mainWidget:getChildByName("temp_" .. i)
        updateCellTimer(temp_panel_queueItem,v)
    end

    reloadBuildQueueNum()
end

local function activeSchedulerHandler()
    disposeSchedulerHandler()
    schedulerHandler = scheduler.create(updateScheduler,1)
end



function innerOptionLeft.do_remove_self()
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
        uiManager.remove_self_panel(uiIndexDefine.INNER_OPTION_LEFT)
    end
    unregistBuildingUpdate()

    disposeSchedulerHandler()

    isEnable = nil
end

function innerOptionLeft.hideEffect(callback,duration)
    if not mainWidget then return end
    if not duration then duration = 0.3 end

    local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
    end)
    local actionHide = CCFadeOut:create(duration)
    mainWidget:runAction(animation.sequence({actionHide,finally}))

end

function innerOptionLeft.remove_self()
    if mainBuildScene.isQuitNeedEffect() then
        innerOptionLeft.hideEffect(innerOptionLeft.do_remove_self)
    else
        innerOptionLeft.do_remove_self()
    end
end



function innerOptionLeft.showEffect(callback)
    if not mainBuildScene.isInCity() then return end
    if not mainWidget then return end

    if not mainWidget then return end
    mainWidget:setVisible(true)

    -- mainWidget:setScale(0.8 * config.getgScale())

    local actionShow = CCFadeIn:create(0.3)
    mainWidget:runAction(animation.sequence({actionShow}))
end

function innerOptionLeft.create(mainLayer)
    if not mainBuildScene.isInCity() then return end
    if mainWidget then 
        innerOptionLeft.do_remove_self()
    end

    mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/chengnei_2.json")
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0,1))
    mainWidget:setPosition(cc.p(0, config.getWinSize().height - 120 * config.getgScale()))
    mainWidget:setZOrder(999)

    mainLayer:addWidget(mainWidget)
    

    -- local city_panel = uiUtil.getConvertChildByName(mainWidget,"city_panel")
    -- local label_name = uiUtil.getConvertChildByName(city_panel,"label_name")
    -- label_name:setText(landData.get_city_name_by_coordinate(mainBuildScene.getThisCityid()))
    -- city_panel:setTouchEnabled(true)
    -- city_panel:addTouchEventListener(expandCityListView)

    -- local cityOverviewPanel = uiUtil.getConvertChildByName(mainWidget,"city_overview_panel")
    -- local btnOverview = uiUtil.getConvertChildByName(cityOverviewPanel,"btnOverview")
    -- btnOverview:setTouchEnabled(true)
    -- btnOverview:addTouchEventListener(showCityOverview)


    -- isEnable = true

    -- initBuildingQueue()

    

    innerOptionLeft.reloadData()

    -- updateScheduler()
    
    registBuildingUpdate()

    activeSchedulerHandler()

    -- reloadCityDetailInfo()

    mainWidget:setVisible(true)
    innerOptionLeft.showEffect()
end



function innerOptionLeft.getWidth()
    if not mainWidget then return 0 end
    return mainWidget:getContentSize().width
end

function innerOptionLeft.getPosX()
    if not mainWidget then return 0 end
    return mainWidget:getPositionX() + mainWidget:getPositionX()
end


function innerOptionLeft.setEnable( flag )
    
    if flag then 
        innerOptionLeft.showEffect()
    else
        innerOptionLeft.hideEffect()
    end
end

return innerOptionLeft
