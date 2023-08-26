innerOptionRight = {}

local uiUtil = require("game/utils/ui_util")
local mainLayer = nil

local btn_return = nil
function innerOptionRight.do_remove_self()
    if btn_return then 
        btn_return:removeFromParentAndCleanup(true)
        btn_return = nil
    end
    if mainLayer then 
        mainLayer:removeFromParentAndCleanup(true)
        mainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.INNER_OPTION_RIGHT)
    end


    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, innerOptionRight.resetTaxBtn)
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.add, innerOptionRight.resetTaxBtn)
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.remove, innerOptionRight.resetTaxBtn)

    UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.update, innerOptionRight.updateTaxBtn)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.add, innerOptionRight.updateTaxBtn)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.remove, innerOptionRight.updateTaxBtn)

    UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.update, innerOptionRight.resetExpandBuildingBtn)
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, innerOptionRight.resetExpandBuildingBtn)

    -- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/btn_effect_shuishou.ExportJson")
end

function innerOptionRight.hideEffect(callback,duration)

    if not duration then duration = 1 end
    if btn_return then 
        uiUtil.hideScaleEffect(btn_return,function()
            if callback then callback() end
        end,duration)
    end
    
    if not mainLayer then return end
    
    local tempBtn = nil
    for i = 1,3 do 
        tempBtn = mainLayer:getWidgetByName("btn_right_down_" .. i)
        if tempBtn then 
            uiUtil.hideScaleEffect(tempBtn,nil,duration)
        end
    end

    for i = 1,2 do 
        tempBtn = mainLayer:getWidgetByName("btn_left_down_" .. i)
        if tempBtn then 
            uiUtil.hideScaleEffect(tempBtn,nil,duration)
        end
    end
end

function innerOptionRight.remove_self()
    if mainBuildScene.isQuitNeedEffect() then
        innerOptionRight.hideEffect(innerOptionRight.do_remove_self)
    else
        innerOptionRight.do_remove_self()
    end
end


function innerOptionRight.dealwithTouchEvent(x,y)
    return false
end


function innerOptionRight.showEffect(callback,duration)

    if not duration then duration = 1 end
    if btn_return then 
        uiUtil.showScaleEffect(btn_return,nil,duration,nil,nil,0)
    end
    
    if not mainLayer then return end
    
    local tempBtn = nil
    for i = 1,3 do 
        tempBtn = mainLayer:getWidgetByName("btn_right_down_" .. i)
        if tempBtn then 
            uiUtil.showScaleEffect(tempBtn,nil,duration,nil,nil,0)
        end
    end

    for i = 1,2 do 
        tempBtn = mainLayer:getWidgetByName("btn_left_down_" .. i)
        if tempBtn then 
            uiUtil.showScaleEffect(tempBtn,nil,duration,nil,nil,0)
        end
    end
end




local function initBtnReturn()
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    
    btn_return = uiUtil.getConvertChildByName(mainWidget,"btn_return")
    btn_return:removeFromParentAndCleanup(false)
    btn_return:setScale(config.getgScale())
    btn_return:ignoreAnchorPointForPosition(false)
    btn_return:setAnchorPoint(cc.p(1,1))
    btn_return:setPosition(cc.p(config.getWinSize().width - 0 * config.getgScale(),config.getWinSize().height - 21 * config.getgScale()))
    btn_return:setTouchEnabled(true)
    btn_return:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            --返回地图
            mainBuildScene.remove(true)
            newGuideInfo.enter_next_guide()
        end
    end)
    mainLayer:addWidget(btn_return)

end

local function autoOffsetRightdown()
    if not mainLayer then return end

    local tempBtn = nil

    local itemWidth = 140 * config.getgScale()
    local itemHeight = 90 * config.getgScale()

    local winSize = config.getWinSize()

    local posX = winSize.width - itemWidth/2 
    local posY = 50* config.getgScale() + itemHeight/2

    local visibleCount = 0
    for i = 3,1,-1 do 
        tempBtn = mainLayer:getWidgetByName("btn_right_down_" .. i)
        if tempBtn:isVisible() then 
            visibleCount = visibleCount + 1
        end
        tempBtn:setPosition(cc.p( posX - (visibleCount-1) * itemWidth ,posY) )
    end

end






local function initBtnsRightDown()
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local tempBtn = nil

    -- 内政
    -- btn_right_down_1
    tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_right_down_1")
    tempBtn:removeFromParentAndCleanup(false)
    tempBtn:setScale(config.getgScale())
    tempBtn:setVisible(false)
    tempBtn:setTouchEnabled(false)
    tempBtn:setName("btn_right_down_1")
    mainLayer:addWidget(tempBtn)
    tempBtn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            UIInternalAffairs.create()
        end
    end)
    -- 设施
    tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_right_down_2")
    tempBtn:removeFromParentAndCleanup(false)
    tempBtn:setScale(config.getgScale())
    tempBtn:setVisible(false)
    tempBtn:setTouchEnabled(false)
    tempBtn:setName("btn_right_down_2")
    mainLayer:addWidget(tempBtn)
    tempBtn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            require("game/buildScene/buildTreeManager")
            buildTreeManager.create() 
        end
    end)
    --堡垒
    tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_right_down_3")
    tempBtn:removeFromParentAndCleanup(false)
    tempBtn:setScale(config.getgScale())
    tempBtn:setVisible(false)
    tempBtn:setTouchEnabled(false)
    tempBtn:setName("btn_right_down_3")
    mainLayer:addWidget(tempBtn)
    tempBtn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            require("game/buildScene/buildMsgManager")
            buildMsgManager.showBuildMsg(cityBuildDefine.baolei)
        end
    end)

    -- local userCityInfo = userCityData.getUserCityData(mainBuildScene.getThisCityid())
    -- config.dump(userCityInfo)
    local wordCityInfo = landData.get_world_city_info(mainBuildScene.getThisCityid())
    if wordCityInfo then 
        if wordCityInfo.city_type == cityTypeDefine.zhucheng then 
            tempBtn = mainLayer:getWidgetByName("btn_right_down_1")
            tempBtn:setVisible(true)
            tempBtn:setTouchEnabled(true)
            tempBtn = mainLayer:getWidgetByName("btn_right_down_2")
            tempBtn:setVisible(true)
            tempBtn:setTouchEnabled(true)
        elseif wordCityInfo.city_type == cityTypeDefine.fencheng then 
            tempBtn = mainLayer:getWidgetByName("btn_right_down_2")
            tempBtn:setVisible(true)
            tempBtn:setTouchEnabled(true)
        elseif wordCityInfo.city_type == cityTypeDefine.yaosai then 
            tempBtn = mainLayer:getWidgetByName("btn_right_down_3")
            tempBtn:setVisible(true)
            tempBtn:setTouchEnabled(true)
        end

    end

    
    autoOffsetRightdown()

end


local function autoOffsetLeftdown()
    if not mainLayer then return end
    local tempBtn = nil
    local itemWidth = 89 * config.getgScale()
    local itemHeight = 90 * config.getgScale()
    local posX = itemWidth/2 + 20
    local posY = 50* config.getgScale() + itemHeight/2

    local visibleCount = 0
    for i = 1,2 do 
        tempBtn = mainLayer:getWidgetByName("btn_left_down_" .. i)
        if tempBtn:isVisible() then 
            visibleCount = visibleCount + 1
        end
        tempBtn:setPosition(cc.p( posX + (visibleCount-1) * itemWidth ,posY) )
    end
end


-- 左下角 按钮
-- 税收、扩建
local function initBtnsLeftDown()
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local tempBtn = nil
    local panel_effectContainer = nil
    --税收
    tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_left_down_1")
    tempBtn:removeFromParentAndCleanup(false)
    tempBtn:setScale(config.getgScale())
    tempBtn:setVisible(true)
    tempBtn:setTouchEnabled(true)
    tempBtn:setName("btn_left_down_1")
    mainLayer:addWidget(tempBtn)
    tempBtn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            require("game/tax/taxUI")
            TaxUI.create()
        end
    end)
    panel_effectContainer = uiUtil.getConvertChildByName(tempBtn,"panel_effectContainer")
    panel_effectContainer:setBackGroundColorType(LAYOUT_COLOR_NONE)
    --扩建
    tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_left_down_2")
    tempBtn:removeFromParentAndCleanup(false)
    tempBtn:setScale(config.getgScale())
    tempBtn:setVisible(true)
    tempBtn:setTouchEnabled(true)
    tempBtn:setName("btn_left_down_2")
    mainLayer:addWidget(tempBtn)
    tempBtn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
            -- 扩建
            if not BuildingExpand.getInstance() then
                BuildingExpand.create(mainBuildScene.getThisCityid())
            end
        end
    end)
    panel_effectContainer = uiUtil.getConvertChildByName(tempBtn,"panel_effectContainer")
    panel_effectContainer:setBackGroundColorType(LAYOUT_COLOR_NONE)
    


    autoOffsetLeftdown()

end








-- 税收按钮相关

function innerOptionRight.updateTaxBtn()
    if not mainLayer then return end

    local tempBtn = mainLayer:getWidgetByName("btn_left_down_1")


    local imgFlag = uiUtil.getConvertChildByName(tempBtn,"img_flag")
    imgFlag:setVisible(false)

    -- TODOTK 税收提示数字
    local labelNum = uiUtil.getConvertChildByName(imgFlag,"label_num")
    local taxCount = 0


    labelNum:setText(taxCount)
    labelNum:setVisible(false) -- 不显示次数 永远只有一次
    for i, v in pairs(allTableData[dbTableDesList.user_revenue.name]) do
        if v.userid == userData.getUserId() then
            if (#stringFunc.anlayerMsg(v.revenue_info)<REVENUE_COUNT_A_DAY and userData.getServerTime()-v.revenue_time > REVENUE_CD) 
                or os.date("%d", userData.getServerTime()) ~= os.date("%d", v.revenue_time) then
                imgFlag:setVisible(true)
                taxCount = 1
            end
        end
    end

    if not allTableData[dbTableDesList.user_revenue.name][userData.getUserId()] then
        imgFlag:setVisible(true)
        taxCount = 1
    end


    local panel_effectContainer = uiUtil.getConvertChildByName(tempBtn,"panel_effectContainer")
    panel_effectContainer:removeAllChildrenWithCleanup(true)


    if taxCount > 0 then 
        labelNum:setVisible(true)
        labelNum:setText(1)
        local armature = CCArmature:create("btn_effect_shuishou")
        armature:getAnimation():playWithIndex(0)
        armature:ignoreAnchorPointForPosition(false)
        armature:setAnchorPoint(cc.p(0.5, 0.5))
        panel_effectContainer:addChild(armature)
        armature:setPosition(cc.p(panel_effectContainer:getContentSize().width/2,panel_effectContainer:getContentSize().height/2 - 3 ))
    end

end


local function checkExpandBuildingAble()
    local m_pWid = mainBuildScene.getThisCityid()
    if not m_pWid then return false end
    
    local userCityData = userCityData.getUserCityData(m_pWid)
    if not userCityData then return false end

    local cityLevel = 0 
    if userCityData.city_type == cityTypeDefine.zhucheng then 
        cityLevel = politics.getBuildLevel(mainBuildScene.getThisCityid(), cityBuildDefine.chengzhufu)
    elseif userCityData.city_type == cityTypeDefine.fencheng then
        cityLevel = politics.getBuildLevel(mainBuildScene.getThisCityid(), cityBuildDefine.dudufu)
    end

    --TODOTK
    -- build_effect_city.city_extend_max 不为0 就行
    local cityExtendMaxCount = 0
    for k,v in pairs(allTableData[dbTableDesList.build_effect_city.name]) do
        if v.userid == userData.getUserId() and v.city_wid == m_pWid then 
            cityExtendMaxCount = v.city_extend_max
        end
    end
    if cityExtendMaxCount <= 0 then return false end
    -- local mainCityLvNeed = 5
    -- if cityLevel < mainCityLvNeed then return false end


    


    local mainCityType = mapData.getCityTypeData(math.floor(m_pWid/10000), m_pWid%10000)
    if not mainCityType or (mainCityType ~= cityTypeDefine.zhucheng and mainCityType ~= cityTypeDefine.fencheng) then 
        return false
    end

    if not map.getInstance() then return false end

    

    local extend_wid = {}

    if string.len(userCityData.extend_wids)>0 then
        extend_wid = stringFunc.anlayerOnespot(userCityData.extend_wids, ",", false)
    end
    if #extend_wid >= BUILD_EXPAND then return false end

    -- 扩建次数不够了
    if politics.getBuildingExpandAbleCount(mainBuildScene.getThisCityid()) <=0 then return false end

    return true

end
function innerOptionRight.resetExpandBuildingBtn()
    if not mainLayer then return end

    local  tempBtn = mainLayer:getWidgetByName("btn_left_down_2")
    tempBtn:setVisible(false)
    tempBtn:setTouchEnabled(false)
    if checkExpandBuildingAble() then 
        tempBtn:setVisible(true)
        tempBtn:setTouchEnabled(true)
    end

    local img_flag = uiUtil.getConvertChildByName(tempBtn,"img_flag")
    local label_num = uiUtil.getConvertChildByName(img_flag,"label_num")

    label_num:setText(politics.getBuildingExpandAbleCount(mainBuildScene.getThisCityid()))

    local panel_effectContainer = uiUtil.getConvertChildByName(tempBtn,"panel_effectContainer")
    panel_effectContainer:removeAllChildrenWithCleanup(true)


    local armature = CCArmature:create("btn_effect_shuishou")
    armature:getAnimation():playWithIndex(0)
    armature:ignoreAnchorPointForPosition(false)
    armature:setAnchorPoint(cc.p(0.5, 0.5))
    panel_effectContainer:addChild(armature)
    armature:setPosition(cc.p(panel_effectContainer:getContentSize().width/2,panel_effectContainer:getContentSize().height/2 - 3 ))


    -- local function animationCallFunc(armatureNode, eventType, name)
    --     if eventType == 1 then
    --         armatureNode:removeFromParentAndCleanup(true)
    --         armature = nil
    --     elseif eventType == 2 then 
    --         armatureNode:removeFromParentAndCleanup(true)
    --         armature = nil
    --     end
    -- end
    -- armature:getAnimation():setMovementEventCallFunc(animationCallFunc)

    

    autoOffsetLeftdown()
end

function innerOptionRight.resetTaxBtn()
    if not mainLayer then return end

    local  tempBtn = mainLayer:getWidgetByName("btn_left_down_1")
    tempBtn:setVisible(false)
    tempBtn:setTouchEnabled(false)
    if mainBuildScene.isInCity() then
        for i, v in pairs(allTableData[dbTableDesList.build.name]) do
            --民居
            if v.build_id_u%100 == 13 and v.level >=1 and userData.getMainPos() == mainBuildScene.getThisCityid() then
                tempBtn:setTouchEnabled(true)
                tempBtn:setVisible(true)
                innerOptionRight.updateTaxBtn()
            end
        end
    end


    autoOffsetLeftdown()
end



function innerOptionRight.create()
    if true then return end
    
    if not mainBuildScene.isInCity() then return end
    if mainLayer then return end

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/btn_effect_shuishou.ExportJson")
    


    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/inner_option_right.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setTouchEnabled(false)

    mainWidget:setAnchorPoint(cc.p(0.5,0.5))


    local posy = config.getWinSize().height/2 
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 + mainWidget:getContentSize().width/2 * config.getgScale()   ,posy))
    mainWidget:setScale(0.6 * config.getgScale())

    


   


    mainLayer = TouchGroup:create()
    mainLayer:addWidget(mainWidget)
    
    uiManager.add_panel_to_layer(mainLayer,uiIndexDefine.INNER_OPTION_RIGHT)


    initBtnReturn()

    initBtnsLeftDown()
    initBtnsRightDown()



    innerOptionRight.resetTaxBtn()
    innerOptionRight.resetExpandBuildingBtn()


    innerOptionRight.updateTaxBtn()

    innerOptionRight.showEffect()




    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.update, innerOptionRight.updateTaxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.add, innerOptionRight.updateTaxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.remove, innerOptionRight.updateTaxBtn)

    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, innerOptionRight.resetTaxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, innerOptionRight.resetTaxBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.remove, innerOptionRight.resetTaxBtn)


    UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.update, innerOptionRight.resetExpandBuildingBtn)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, innerOptionRight.resetExpandBuildingBtn)
    
    mainLayer:setVisible(true)
    mainWidget:setVisible(true)
end


function innerOptionRight.setEnable( flag )
    if not mainLayer then return end
    if mainLayer then
        local temp = mainLayer:getChildren()
        for i=0 , mainLayer:getChildrenCount()-1 do
            tolua.cast(temp:objectAtIndex(i),"Widget"):setEnabled(flag)
        end
    end

    if flag then 
        innerOptionRight.showEffect()
    else
        innerOptionRight.hideEffect()
    end

    btn_return:setTouchEnabled(true)
end

function innerOptionRight.get_guide_widget(temp_guide_id)
    if not mainLayer then
        return nil
    end

    --[[
    if temp_guide_id == guide_id_list.CONST_GUIDE_231 or temp_guide_id == guide_id_list.CONST_GUIDE_232 then
        return btn_return
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_10 or temp_guide_id == guide_id_list.CONST_GUIDE_209 then
        return mainLayer:getWidgetByName("btn_right_down_2")
    else
        return mainLayer:getWidgetByTag(999)
    end
    --]]

    if temp_guide_id == guide_id_list.CONST_GUIDE_1013 then
        return btn_return
    end

    return nil
end

return innerOptionRight