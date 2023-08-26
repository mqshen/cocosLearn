-- 建筑详情 by TK
local StringUtil = require("game/utils/string_util")

local m_pMainLayer = nil
local m_iCurBid = nil

local last_confirm_type = nil

local m_iShowBuildLevelId = nil
local m_bIsFullGraded = nil


local m_pBuildViewWidget = nil


local guide_temp_id = nil
local m_bOpenStateFinished = nil
local function do_remove_self()
    if m_pMainLayer then
        last_confirm_type = nil
        m_iCurBid = nil
        m_bIsFullGraded = nil

        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        
        m_pBuildViewWidget = nil
        guide_temp_id = nil
        m_bOpenStateFinished = nil
        UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, buildMsgManager.dealWithBuildUpdate)
        UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.remove, buildMsgManager.dealWithBuildRemove)
        UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.add, buildMsgManager.dealWithBuildAdd)
        UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update,buildMsgManager.dealWithWorldCityUpdate)
        uiManager.remove_self_panel(uiIndexDefine.BUILD_MSG_MANAGER)
    end
end


local function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.BUILD_MSG_MANAGER,m_pMainLayer,do_remove_self)
end

local function dealwithTouchEvent(x,y)
    if not m_pMainLayer then
        return false
    end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    local img_mainBg_2 = uiUtil.getConvertChildByName(mainWidget,"img_mainBg_2")
    if img_mainBg_2:hitTest(cc.p(x,y)) then
        return false
    else
        remove_self()
        return true
    end
end




-- 获取建筑开放的条件描述
local function getBuildingOpenPredition()
    if not m_iCurBid then return "unknow cur bid" end
    local curCid = mainBuildScene.getThisCityid()
    if not curCid then return "unknow cur cid" end

    local preditionText = nil

    local bidNeed = nil
    local bidLvNeed = nil

    local buildInfoCfg = nil

    local flagSplit = false

    for i, v in pairs(Tb_cfg_build[m_iCurBid].pre_condition) do
        bidNeed = v[1]
        bidLvNeed = v[2]

        buildInfoCfg = Tb_cfg_build[bidNeed]

    
        if buildInfoCfg then 
            if not preditionText then preditionText = languagePack["build_condition"] .. "：" end
            if flagSplit then 
                preditionText = preditionText .. "  "
            end
            preditionText = preditionText .. buildInfoCfg.name ..languagePack["lv"]..  bidLvNeed 
            if not flagSplit then flagSplit = true end
        else
            preditionText = preditionText .. "unknow cfg bid"
        end

    end

    if preditionText then 
        -- preditionText = preditionText .. languagePack["function_open"]
    else
        preditionText = "no limit to open build"
    end

    return preditionText
end

-- 检查建筑可建造的前置条件
local function isBuildingOpen()
    
    if not m_iCurBid then return false end
    local curCid = mainBuildScene.getThisCityid()
    if not curCid then return false end

    local bidNeed = nil
    local bidLvNeed = nil
    local buildInfo = nil

    local canBuild = true

    local buildInfoCfg = nil
    local cityInfo = userCityData.getUserCityData(curCid)
    local city_type = landData.get_city_type_by_id(curCid)
    for i, v in pairs(Tb_cfg_build[m_iCurBid].pre_condition) do
        bidNeed = v[1]
        bidLvNeed = v[2]

        if bidNeed == cityBuildDefine.chengzhufu then 
            if city_type == cityTypeDefine.zhucheng then 
                buildInfo = politics.getBuildInfo(curCid, cityBuildDefine.chengzhufu)
            elseif city_type == cityTypeDefine.fencheng then
                buildInfo = politics.getBuildInfo(curCid, cityBuildDefine.dudufu)
            else
                buildInfo = politics.getBuildInfo(curCid, bidNeed)
            end
        else
            buildInfo = politics.getBuildInfo(curCid, bidNeed)
        end
        

        if not buildInfo or buildInfo.level < bidLvNeed  then 
            canBuild = false 
        end
    end

    return canBuild
end



-- TODOTK
local function deal_with_request_send()
    if last_confirm_type == 1 then
        politics.requestBuildBuilding(m_iCurBid,mainBuildScene.getThisCityid())
    elseif last_confirm_type == 2 then
        politics.requestUpgradeBuilding(m_iCurBid,mainBuildScene.getThisCityid())
    elseif last_confirm_type == 3 then
        politics.requestDestructBuilding(m_iCurBid,mainBuildScene.getThisCityid())
    end

    --newGuideInfo.enter_next_guide()
end

local function op_confirm_info(new_type)
    last_confirm_type = new_type

    local max_quene_num = userData.getBuildingQueneNum()
    local building_num = politics.getBuildingBuildNumsInCity(mainBuildScene.getThisCityid(),1)
    if building_num >= max_quene_num then
        local temp_had_nums = politics.getBuildingBuildNumsInCity(mainBuildScene.getThisCityid(),2)
        if temp_had_nums >= BUILD_QUEUE_TMP_MAX then
            tipsLayer.create(errorTable[58])
        else
            -- 判断铜钱
            if gameUtilFunc.is_ennough_res(consumeType.common_money,BUILD_QUEUE_MONEY_COST[temp_had_nums+1]) then
                alertLayer.create(errorTable[97], {BUILD_QUEUE_MONEY_COST[temp_had_nums+1]}, deal_with_request_send)
            else
                tipsLayer.create(errorTable[1001])
            end
        end
    else
        newGuideInfo.enter_next_guide()
        deal_with_request_send()
    end
end




-- 建造也走升级的流程
local function onClickUpgrade(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        if not m_iCurBid then return end
        local curCid = mainBuildScene.getThisCityid()
        if not curCid then return end

        local buildInfo = politics.getBuildInfo(curCid, m_iCurBid)
        if buildInfo then
            if buildInfo.state == buildState.upgrade then
                tipsLayer.create(errorTable[53])
                return
            elseif buildInfo.state == buildState.demolition then
                tipsLayer.create(errorTable[54])
                return
            end
        end

        local buildCfgInfo = Tb_cfg_build[m_iCurBid]
        local curLv = politics.getBuildLevel(curCid, m_iCurBid)

        if curLv == buildCfgInfo.max_level then
            tipsLayer.create(errorTable[49])
            return
        end

        

        -- local cityInfo = userCityData.getUserCityData(curCid)
        -- if curLv == 0 then
        --     if cityInfo.build_area_cur + Tb_cfg_build_cost[m_iShowBuildLevelId].build_area + cityInfo.build_area_adding > cityInfo.build_area_max then
        --         -- 取消了面积限制
        --         -- tipsLayer.create(errorTable[50])
        --         -- return
        --     end
        -- else
        --     if cityInfo.build_area_cur + Tb_cfg_build_cost[m_iShowBuildLevelId].build_area - Tb_cfg_build_cost[m_iShowBuildLevelId-1].build_area + cityInfo.build_area_adding > cityInfo.build_area_max then
        --         --取消了面积限制
        --         -- tipsLayer.create(errorTable[50])
        --         -- return
        --     end
        -- end

        local isEnoughRes = true
        for k,v in pairs(Tb_cfg_build_cost[m_iShowBuildLevelId].res_cost) do
            if politics.getResNumsByType(v[1]) < v[2] then
                isEnoughRes = false
                break
            end
        end
        if not isEnoughRes then
            tipsLayer.create(errorTable[48])
            return
        end
        
        if curLv == 0 then
            if m_iCurBid == cityBuildDefine.jishi and politics.getUserMarketNum() >= 3 then
                alertLayer.create(errorTable[2044],nil,function()
                    op_confirm_info(1)
                end)
            else
                op_confirm_info(1)
            end
        else
            op_confirm_info(2)
        end
    end
end


local function deal_with_remove_fencheng_event()
    politics.requestDeleteBranchCity(mainBuildScene.getThisCityid())
end

local function deal_with_remove_yaosai_event()
    politics.requestDeleteFort(mainBuildScene.getThisCityid())
end

local function onClickRemoveCity()
    if not m_iCurBid then return end
    
    local city_type = landData.get_city_type_by_id(mainBuildScene.getThisCityid())
    -- 主城的城主府 代表流浪
    if m_iCurBid == cityBuildDefine.chengzhufu then
        if city_type == cityTypeDefine.zhucheng then
            -- if userData.isUnionLeader() or userData.isUnionDeputyLeader() then 
            --     tipsLayer.create(errorTable[152])
            --     return 
            -- end
            -- require("game/roleForces/ui_role_forces_ranger_confirm")
            -- UIRoleForcesRangerConfirm.create()
            return 
        end
    end
    
    
    if city_type == cityTypeDefine.fencheng then
        alertLayer.create(errorTable[59], nil, deal_with_remove_fencheng_event)
    elseif city_type == cityTypeDefine.yaosai then
        alertLayer.create(errorTable[109], nil, deal_with_remove_yaosai_event)
    end
    
    
end


local function checkNonForcedGuide()
    if guide_temp_id and guide_temp_id == com_guide_id_list.CONST_GUIDE_2011 then
        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2011)
    end
end



local function create()

    require("game/config/buildingEffectDefined")
    if m_pMainLayer then
        return
    end

    require("game/buildScene/buildTreeItem")


    local buildCfgInfo = Tb_cfg_build[m_iCurBid]

    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/neizhen_1.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5,0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))


    -- 初始化建筑描述 这个是固定的
    local panel_detail = uiUtil.getConvertChildByName(mainWidget,"panel_detail")
    local label_desc = uiUtil.getConvertChildByName(panel_detail,"label_desc")
    label_desc:setText(buildCfgInfo.description)
    

    local panel_buildView = uiUtil.getConvertChildByName(mainWidget,"panel_buildView")
    panel_buildView:setBackGroundColorType(LAYOUT_COLOR_NONE)
    

    local scaleValue = 1
    if Tb_cfg_build[m_iCurBid].area == 1 then
        scaleValue = 1.2
        m_pBuildViewWidget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_item_big.json")
    elseif Tb_cfg_build[m_iCurBid].area == 2 then
        scaleValue = 1.5
        m_pBuildViewWidget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_item_small_2.json")
    elseif Tb_cfg_build[m_iCurBid].area == 3 then
        scaleValue = 1.5
        m_pBuildViewWidget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_item_small.json")
    end

    if m_pBuildViewWidget then 
        m_pBuildViewWidget:setScale(scaleValue)
        BuildTreeItem.initItem(m_pBuildViewWidget,m_iCurBid)
        m_pBuildViewWidget:setPosition(cc.p(
            (panel_buildView:getContentSize().width - m_pBuildViewWidget:getContentSize().width * scaleValue)/2,
            (panel_buildView:getContentSize().height - m_pBuildViewWidget:getContentSize().height * scaleValue)/2))

    end

    panel_buildView:addChild(m_pBuildViewWidget)

    -- 关闭按钮
    local btnClose = uiUtil.getConvertChildByName(mainWidget,"btnClose")
    btnClose:setTouchEnabled(true)
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self()
        end
    end)

    -- 放弃拆除按钮
    local btn_abandon = uiUtil.getConvertChildByName(mainWidget,"btn_abandon")
    btn_abandon:setTouchEnabled(false)
    btn_abandon:setVisible(false)
    btn_abandon:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            onClickRemoveCity()      
        end
    end)

    -- 建造按钮
    local btn_build = uiUtil.getConvertChildByName(mainWidget,"btn_build")
    btn_build:setTouchEnabled(false)
    btn_build:setVisible(false)
    btn_build:addTouchEventListener(onClickUpgrade)

    -- 升级按钮 
    local btn_upgrade = uiUtil.getConvertChildByName(mainWidget,"btn_upgrade")
    btn_upgrade:setTouchEnabled(false)
    btn_upgrade:setVisible(false)
    btn_upgrade:addTouchEventListener(onClickUpgrade)

    --快速完成按钮
    local btn_quickComplete = uiUtil.getConvertChildByName(mainWidget,"btn_quickComplete")
    btn_quickComplete:setTouchEnabled(false)
    btn_quickComplete:setVisible(false)
    btn_quickComplete:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            local current_city_id = mainBuildScene.getThisCityid()
            local build_info = politics.getBuildInfo(current_city_id, m_iCurBid)
            local need_yuanbao_num = userData.getBuildFinishImmediatelyCostYuanbao(build_info.end_time - userData.getServerTime())
            if need_yuanbao_num > userData.getYuanbao() then
                alertLayer.create(errorTable[43])
            else
                -- local function done( )
                --     politics.requestOneDoneImmediately(build_info.build_id_u)
                -- end
                -- alertLayer.create(errorTable[44], {need_yuanbao_num}, done)
                politics.requestOneDoneImmediately(build_info.build_id_u)
                newGuideInfo.enter_next_guide()
            end

            --newGuideInfo.enter_next_guide()
        end
    end)

    m_bOpenStateFinished = false
    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.BUILD_MSG_MANAGER)
    uiManager.showConfigEffect(uiIndexDefine.BUILD_MSG_MANAGER,m_pMainLayer,function()
        m_bOpenStateFinished = true
        checkNonForcedGuide()
    end)


    
end
local function showPanelResConsume( )
    if not m_pMainLayer then return end

    local mainWidget =  m_pMainLayer:getWidgetByTag(999)

    if not mainWidget then return end
    


    local panel_consume = uiUtil.getConvertChildByName(mainWidget,"panel_consume")

    panel_consume:setVisible(true)

    local label_consumeType = uiUtil.getConvertChildByName(panel_consume,"label_consumeType")
    if curLv == 0 then 
        label_consumeType:setText(languagePack["jianzaoxuqiu"])
    else
        label_consumeType:setText(languagePack["shengjixuqiu"])
    end
    local res = nil
    local res_txt = nil
    
    local label_need_title = uiUtil.getConvertChildByName(panel_consume,"label_need_title")
    local label_need_time = uiUtil.getConvertChildByName(panel_consume,"label_need_time")
    label_need_time:setText(commonFunc.format_time(Tb_cfg_build_cost[m_iShowBuildLevelId].time_cost))

    local label_res_not_enough = uiUtil.getConvertChildByName(panel_consume,"label_res_not_enough")
    label_res_not_enough:setVisible(false)

    -- 不想改UI编辑器了 接手的家伙将就着看吧
    local label_need_wood = uiUtil.getConvertChildByName(panel_consume,"label_need_wood")
    local label_need_stone = uiUtil.getConvertChildByName(panel_consume,"label_need_stone")
    local label_need_iron = uiUtil.getConvertChildByName(panel_consume,"label_need_iron")

    local label_own_wood = uiUtil.getConvertChildByName(panel_consume,"label_own_wood")
    local label_own_stone = uiUtil.getConvertChildByName(panel_consume,"label_own_stone")
    local label_own_iron = uiUtil.getConvertChildByName(panel_consume,"label_own_iron")

    local tempNeedLabel = {}
    local tempOwnLabel = {}

    tempNeedLabel[1] = label_need_wood
    tempNeedLabel[2] = label_need_stone
    tempNeedLabel[3] = label_need_iron

    
    tempOwnLabel[1] = label_own_wood
    tempOwnLabel[2] = label_own_stone
    tempOwnLabel[3] = label_own_iron

    local all_res = {[1] = 1, [2] = 1, [3] = 1}

    local isFlagResNotEnough = false
    for i = 1, 3 do 
        tempNeedLabel[i]:setText( "- - -" )
    end

    local curOwn,maxOwn,AddSpeedOwn = nil,nil,nil
    for k,v in pairs(Tb_cfg_build_cost[m_iShowBuildLevelId].res_cost) do
        curOwn,maxOwn,AddSpeedOwn = politics.getResNumsByType(v[1])
        if v[2] > 0 then 
            tempNeedLabel[v[1]]:setText(v[2])
        end

        if curOwn < v[2] then
            tempNeedLabel[v[1]]:setColor(ccc3(194,72,66))
            isFlagResNotEnough = true
        else
            tempNeedLabel[v[1]]:setColor(ccc3(255,255,255))
        end
    end

    for i = 1, 3 do 
        curOwn,maxOwn,AddSpeedOwn = politics.getResNumsByType(i)
        tempOwnLabel[i]:setText( "/" .. curOwn)
    end

    for i = 1,3 do 
        tempOwnLabel[i]:setPositionX(tempNeedLabel[i]:getContentSize().width +tempNeedLabel[i]:getPositionX() + 3 )
    end

    if isFlagResNotEnough then 
        label_res_not_enough:setVisible(true)
        label_need_time:setVisible(false)
        label_need_title:setVisible(false)
    else
        label_res_not_enough:setVisible(false)
        label_need_time:setVisible(true)
        label_need_title:setVisible(true)
    end


    local btn_upgrade = uiUtil.getConvertChildByName(mainWidget,"btn_upgrade")
    local btn_quickComplete = uiUtil.getConvertChildByName(mainWidget,"btn_quickComplete")
    local btn_build = uiUtil.getConvertChildByName(mainWidget,"btn_build")

    local img_flag = nil
    if btn_upgrade:isVisible() then 
        btn_upgrade:setBright(not isFlagResNotEnough)
        img_flag = uiUtil.getConvertChildByName(btn_upgrade,"img_flag")
        GraySprite.create(img_flag,nil,not isFlagResNotEnough)
    end


    if btn_quickComplete:isVisible() then 
        btn_quickComplete:setBright(not isFlagResNotEnough)
        img_flag = uiUtil.getConvertChildByName(btn_quickComplete,"img_flag")
        GraySprite.create(img_flag,nil,not isFlagResNotEnough)
    end


    if btn_build:isVisible() then 
        btn_build:setBright(not isFlagResNotEnough)
        img_flag = uiUtil.getConvertChildByName(btn_build,"img_flag")
        GraySprite.create(img_flag,nil,not isFlagResNotEnough)
    end
end

-- 升级或者建造中
local function showPanelBuilding()
    if not m_pMainLayer then return end

    local mainWidget =  m_pMainLayer:getWidgetByTag(999)

    if not mainWidget then return end

    local panel_building = uiUtil.getConvertChildByName(mainWidget,"panel_building")
    panel_building:setVisible(true)

    local curLv = politics.getBuildLevel(mainBuildScene.getThisCityid(), m_iCurBid)

    local label_from = uiUtil.getConvertChildByName(panel_building,"label_from")
    label_from:setText(languagePack["lv"] .. curLv)

    local label_to = uiUtil.getConvertChildByName(panel_building,"label_to")
    label_to:setText(languagePack["lv"] .. curLv + 1)

    label_buildingType = uiUtil.getConvertChildByName(panel_building,"label_buildingType")

    if curLv == 0 then 
        label_buildingType:setText(languagePack["build_building"] )
    else
        label_buildingType:setText(languagePack["build_upgrading"])
    end

    local curCid = mainBuildScene.getThisCityid()
    local buildInfo = politics.getBuildInfo(curCid, m_iCurBid)

    local function cancelFun( )
        politics.requestCancelBuilding(buildInfo.build_id_u%100, mainBuildScene.getThisCityid())
    end


    local btn_cancelBuild = uiUtil.getConvertChildByName(panel_building,"btn_cancelBuild")
    btn_cancelBuild:setTouchEnabled(true)
    btn_cancelBuild:setVisible(true)
    btn_cancelBuild:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if buildInfo.state == buildState.upgrade then
                alertLayer.create(errorTable[45], nil, cancelFun)
            else
                cancelFun()
            end
        end
    end)


    -- 快速完成时所需的资源以及状态
    local label_res_not_enough = uiUtil.getConvertChildByName(panel_building,"label_res_not_enough")
    local label_cost = uiUtil.getConvertChildByName(panel_building,"label_cost")
    local label_cost_0 = uiUtil.getConvertChildByName(panel_building,"label_cost_0")
    local img_cost = uiUtil.getConvertChildByName(panel_building,"img_cost")

    local current_city_id = mainBuildScene.getThisCityid()
    local build_info = politics.getBuildInfo(current_city_id, m_iCurBid)
    local need_yuanbao_num = userData.getBuildFinishImmediatelyCostYuanbao(build_info.end_time - userData.getServerTime())
    label_cost:setText(need_yuanbao_num)
    local btn_quickComplete = uiUtil.getConvertChildByName(mainWidget,"btn_quickComplete")
    local btn_quickComplete_img_flag = uiUtil.getConvertChildByName(btn_quickComplete,"img_flag")

    if need_yuanbao_num > userData.getYuanbao() then
        btn_quickComplete:setBright(false)
        GraySprite.create(btn_quickComplete_img_flag)
        label_cost:setVisible(false)
        label_cost_0:setVisible(false)
        img_cost:setVisible(false)
        label_res_not_enough:setVisible(true)
    else
        btn_quickComplete:setBright(true) 
        GraySprite.create(btn_quickComplete_img_flag,nil,true)
        label_cost:setVisible(true)
        label_cost_0:setVisible(true)
        img_cost:setVisible(true)
        label_res_not_enough:setVisible(false)
    end
end


-- 正在放弃分成 或者要塞
local function showPanelAbandoning()
    if not m_pMainLayer then return end

    local mainWidget =  m_pMainLayer:getWidgetByTag(999)

    if not mainWidget then return end


    local panel_abandon = uiUtil.getConvertChildByName(mainWidget,"panel_abandon")
    panel_abandon:setVisible(true)

    local label_abandon = uiUtil.getConvertChildByName(panel_abandon,"label_abandon")


    local btn_cancel = uiUtil.getConvertChildByName(panel_abandon,"btn_cancel")
    btn_cancel:setVisible(true)
    btn_cancel:setTouchEnabled(true)

    btn_cancel:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
            local userCityInfo = userCityData.getUserCityData(mainBuildScene.getThisCityid())
            if userCityInfo then 
                politics.requestCancelDeleteCity(userCityInfo.city_wid)
            end
        end
    end)

end
local function showBuildingEffect()

    if not m_pMainLayer then return end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local panel_detail = uiUtil.getConvertChildByName(mainWidget,"panel_detail")
    local effectPanel = nil
    for i = 1,2 do 
        effectPanel = uiUtil.getConvertChildByName(panel_detail,"effect_panel_" .. i)
        effectPanel:setVisible(false)
    end
    local effectTitle = nil
    local effectFrom = nil
    local effectTo = nil

    local curLv = politics.getBuildLevel(mainBuildScene.getThisCityid(), m_iCurBid)
    local current_build_level_id = m_iCurBid * 100 + curLv
    for k, v in ipairs(Tb_cfg_build_cost[m_iShowBuildLevelId].effect) do
        effectPanel = uiUtil.getConvertChildByName(panel_detail,"effect_panel_" .. k)
        effectTitle = uiUtil.getConvertChildByName(effectPanel,"label_title")
        effectFrom = uiUtil.getConvertChildByName(effectPanel,"label_from")
        effectTo = uiUtil.getConvertChildByName(effectPanel,"label_to")

        effectTitle:setText(Tb_cfg_build_effect[v[1]].name)

        local function getRealValue(id, value)
            if value >=290000 and value <= 299999 then
                value = skillData.get_skill_effect(value, 10, 0, 0)[1]
                value = string.sub(value, string.find(value,"%d"), string.len(value))
            end
            
            --封禅台
            if id == 441 then
                value = string.format("%.1f",value/10)
            end

            if id == 431 then
                value = math.floor(value/100)
            end

            --城防建筑
            -- 警戒所
            if id == 661 then
                -- local info = landData.get_world_city_info(mainBuildScene.getThisCityid())
                -- local _level = curLv
                -- if curLv == 0 then
                --     _level = 1
                -- end
                -- if info.city_type == cityTypeDefine.yaosai then
                --     value = yaosaiConvertToLevel[_level]
                -- else
                --     value = cityConvertToLevel[_level]
                -- end
                -- if Tb_cfg_army[value*100+1] then
                --     print(Tb_cfg_hero_u[Tb_cfg_army[value*100+1].base_heroid_u].hp)
                --     -- value = --Tb_cfg_hero_u[Tb_cfg_army[value*100+1].base_heroid_u].level
                -- end

                -- Tb_cfg_army 太大 客户端没有存 策划单独给配置
                local _level = value % 10
                value = cfgbuildingDefenceTroops[_level]
                if not value then value = 0 end
            end

            if buildingEffectDefined[id] then
                value = buildingEffectDefined[id][1]..value..buildingEffectDefined[id][2]
            end
            return value
        end

        local effect_after = getRealValue(v[1], v[2])
        if m_bIsFullGraded then
            effectFrom:setText(effect_after )
            effectTo :setText("--")
        else
            if curLv == 0 then
                effectFrom:setText("--")
                effectTo:setText(effect_after)
            else
                local current_value = getRealValue(Tb_cfg_build_cost[current_build_level_id].effect[k][1],Tb_cfg_build_cost[current_build_level_id].effect[k][2])
                
                effectFrom:setText(current_value)
                effectTo:setText(effect_after)
            end
        end
        effectPanel:setVisible(true)
    end
end

-- 满级特效
local function showFullUpgradedEffect()
    if not m_pMainLayer then return end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    if not m_iCurBid then return end

    local buildCfgInfo = Tb_cfg_build[m_iCurBid]
    if not buildCfgInfo then return end

    local panel_detail = uiUtil.getConvertChildByName(mainWidget,"panel_detail")
    local effect_panel = uiUtil.getConvertChildByName(panel_detail,"effect_panel")


    if StringUtil.isEmptyStr(buildCfgInfo.description_max) then 
        effect_panel:setVisible(false)
    else
        effect_panel:setVisible(true)
    end
    local label_desc = uiUtil.getConvertChildByName(effect_panel,"label_desc")
    local label_state = uiUtil.getConvertChildByName(effect_panel,"label_state")

    label_desc:setText(buildCfgInfo.description_max)


    local img_flag = uiUtil.getConvertChildByName(effect_panel,"img_flag")
    if m_bIsFullGraded then 
        label_desc:setColor(ccc3(135,238,238))
        label_state:setColor(ccc3(135,238,238))
        label_state:setText(languagePack["actived"])
        GraySprite.create(img_flag,nil,true)
    else
        label_desc:setColor(ccc3(139,147,155))
        label_state:setColor(ccc3(139,147,155))
        label_state:setText(languagePack["unactived"])
        GraySprite.create(img_flag)
    end
end

-- 建筑详细信息面板自适应
local function autoSizeDetailPanel()
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local panel_detail = uiUtil.getConvertChildByName(mainWidget,"panel_detail")

    local effect_panel = uiUtil.getConvertChildByName(panel_detail,"effect_panel")

    local img_mainBg = uiUtil.getConvertChildByName(panel_detail,"img_mainBg")
    if effect_panel:isVisible() then 
        -- img_mainBg:setSize( CCSizeMake(560,170) )
    else
        -- img_mainBg:setSize( CCSizeMake(560,220) )
    end

    local img_splitLine = uiUtil.getConvertChildByName(panel_detail,"img_splitLine")
    local posY = img_splitLine:getPositionY()


    local effectPanelsHeight = 0
    local effectPanelBar = nil
    for i = 1,2 do 
        effectPanelBar = uiUtil.getConvertChildByName(panel_detail,"effect_panel_" .. i)
        if effectPanelBar:isVisible() then 
            effectPanelsHeight = effectPanelsHeight + 30
        end
    end
    if effect_panel:isVisible() then 
        posY = posY - (posY - effectPanelsHeight - 50)/2
    else
        posY = posY - (posY - effectPanelsHeight)/2

    end

    effectPanelBar = uiUtil.getConvertChildByName(panel_detail,"effect_panel_1")
    posY = posY - effectPanelBar:getContentSize().height
    effectPanelBar:setPositionY(posY)
    effectPanelBar = uiUtil.getConvertChildByName(panel_detail,"effect_panel_2")
    posY = posY - effectPanelBar:getContentSize().height
    effectPanelBar:setPositionY(posY)

end

local function autoSizeMainView()
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    -- 界面底部 是不是空的
    local isBottomViewEmpy = true

     -- 建造按钮
    local btn_build = uiUtil.getConvertChildByName(mainWidget,"btn_build")
    if btn_build:isVisible() then isBottomViewEmpy = false end

    -- 升级按钮 
    local btn_upgrade = uiUtil.getConvertChildByName(mainWidget,"btn_upgrade")
    if btn_upgrade:isVisible() then isBottomViewEmpy = false end

    --快速完成按钮
    local btn_quickComplete = uiUtil.getConvertChildByName(mainWidget,"btn_quickComplete")
    if btn_quickComplete:isVisible() then isBottomViewEmpy = false end

    local img_mainBg_1 = uiUtil.getConvertChildByName(mainWidget,"img_mainBg_1")
    local img_mainBg_2 = uiUtil.getConvertChildByName(mainWidget,"img_mainBg_2")


    -- TODOTK  界面大小也要调正  界面位置调整
    if isBottomViewEmpy then 
        img_mainBg_1:setSize(CCSizeMake(994,408))
        img_mainBg_2:setSize(CCSizeMake(884,420))
        -- mainWidget:setContentSize(CCSizeMake(850,388))
        
        mainWidget:setPosition(cc.p(config.getWinSize().width/2,config.getWinSize().height/2 - 50 * config.getgScale() ))
    else
        img_mainBg_1:setSize(CCSizeMake(994,500))
        img_mainBg_2:setSize(CCSizeMake(884,514))
        -- mainWidget:setContentSize(CCSizeMake(850,480))
        mainWidget:setPosition(cc.p(config.getWinSize().width/2,config.getWinSize().height/2 ))
    end

    
end




local function reloadData()
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end


    if m_pBuildViewWidget then 
        BuildTreeItem.initItem(m_pBuildViewWidget,m_iCurBid)
    end
    --建筑信息
    local buildCfgInfo = Tb_cfg_build[m_iCurBid]
    if not buildCfgInfo then return end
    --当前城市
    local curCid = mainBuildScene.getThisCityid()
    if not curCid then return end


    local buildInfo = politics.getBuildInfo(curCid, m_iCurBid)

    -- 当前等级
    local curLv = politics.getBuildLevel(mainBuildScene.getThisCityid(), m_iCurBid)

    --是否是最高等级
    if curLv >= buildCfgInfo.max_level then
        m_bIsFullGraded = true
    end

    
    local curBuildLvId = m_iCurBid * 100 + curLv
    local maxBuildLvId = m_iCurBid*100 + buildCfgInfo.max_level
    m_iShowBuildLevelId = m_iCurBid*100 + curLv
    
    if not m_bIsFullGraded then
        m_iShowBuildLevelId = m_iShowBuildLevelId + 1
    end


    -- 是否可以放弃（拆除）
    local isCanAbandon = false
    local userCityInfo = userCityData.getUserCityData(mainBuildScene.getThisCityid())


    -- 是否正在放弃分城或者要塞
    local function isCityDuringAbandon()
        -- if m_iCurBid ~= cityBuildDefine.chengzhufu and 
        --     m_iCurBid ~= cityBuildDefine.baolei and 
        --     m_iCurBid ~= cityBuildDefine.dudufu then 
        --     return false 
        -- end

        -- local city_type = landData.get_city_type_by_id(city_wid)
        -- if city_type ~= cityTypeDefine.fencheng and 
        --     city_type ~= cityTypeDefine.yaosai then 
        --     return false
        -- end

        local city_wid = userCityInfo.city_wid
        local worldCityInfo = landData.get_world_city_info(city_wid)
        if not worldCityInfo then return false end

        if worldCityInfo.state == cityState.removing then return true end

        return false

    end

    if m_iCurBid == cityBuildDefine.chengzhufu then
        -- -- 主城
        -- if userCityInfo.city_type == cityTypeDefine.fencheng then
        --     isCanAbandon = true
        -- else
        --     isCanAbandon = false
        -- end
        isCanAbandon = true
    elseif m_iCurBid == cityBuildDefine.baolei then
        isCanAbandon = true
    elseif m_iCurBid == cityBuildDefine.dudufu then 
        isCanAbandon = true
    end

    if curLv == 0 then 
        isCanAbandon = false 
    end

    if isCityDuringAbandon() then 
        isCanAbandon = false
    end
    -- 放弃拆除按钮
    local btn_abandon = uiUtil.getConvertChildByName(mainWidget,"btn_abandon")
    btn_abandon:setTouchEnabled(isCanAbandon)
    btn_abandon:setVisible(isCanAbandon)
    
    
    
    if m_iCurBid == cityBuildDefine.chengzhufu then
        local city_type = landData.get_city_type_by_id(mainBuildScene.getThisCityid())
        if city_type == cityTypeDefine.zhucheng then
            btn_abandon:loadTextureNormal("new_button_xiaoguanbi_1.png",UI_TEX_TYPE_PLIST)
            btn_abandon:loadTexturePressed("new_button_xiaoguanbi_2.png",UI_TEX_TYPE_PLIST)
            btn_abandon:loadTextureDisabled("new_button_xiaoguanbi_2.png",UI_TEX_TYPE_PLIST)
            btn_abandon:setTouchEnabled(false)
            btn_abandon:setVisible(false)
        else
            btn_abandon:loadTextureNormal("new_button_xiaoguanbi_3.png",UI_TEX_TYPE_PLIST)
            btn_abandon:loadTexturePressed("new_button_xiaoguanbi_4.png",UI_TEX_TYPE_PLIST)
            btn_abandon:loadTextureDisabled("new_button_xiaoguanbi_3.png",UI_TEX_TYPE_PLIST)
        end
    end
    
    



    -- 建筑名字
    local label_name = uiUtil.getConvertChildByName(mainWidget,"label_name")
    label_name:setText(buildCfgInfo.name)

    ----------------------------------------------------------------
    ------------- 建筑所处的各个状态调整 begin ---------------------
    ----------------------------------------------------------------
    --建筑未开启的状态

    local panel_unopen = uiUtil.getConvertChildByName(mainWidget,"panel_unopen")
    panel_unopen:setVisible(false)

    --已开启 但是未建造的状态
    --正在升级的状态
    -- 都显示需要消耗的内容
    local panel_consume = uiUtil.getConvertChildByName(mainWidget,"panel_consume")
    panel_consume:setVisible(false)

    --正在建造的状态
    local panel_building = uiUtil.getConvertChildByName(mainWidget,"panel_building")
    panel_building:setVisible(false)
    local btn_cancelBuild = uiUtil.getConvertChildByName(panel_building,"btn_cancelBuild")
    btn_cancelBuild:setTouchEnabled(false)
    btn_cancelBuild:setVisible(false)


    --正在放弃的状态
    local panel_abandon = uiUtil.getConvertChildByName(mainWidget,"panel_abandon")
    panel_abandon:setVisible(false)
    local btn_cancel = uiUtil.getConvertChildByName(panel_abandon,"btn_cancel")
    btn_cancel:setVisible(false)
    btn_cancel:setTouchEnabled(false)
    

    -- 建筑已满级的状态
    local panel_hightestLv = uiUtil.getConvertChildByName(mainWidget,"panel_hightestLv")
    panel_hightestLv:setVisible(false)




    -- 建造按钮
    local btn_build = uiUtil.getConvertChildByName(mainWidget,"btn_build")
    btn_build:setVisible(false)
    btn_build:setTouchEnabled(false)
    local btn_build_img_flag = uiUtil.getConvertChildByName(btn_build,"img_flag")
    

    -- 升级按钮 
    local btn_upgrade = uiUtil.getConvertChildByName(mainWidget,"btn_upgrade")
    btn_upgrade:setVisible(false)
    btn_upgrade:setTouchEnabled(false)
    
    --快速完成按钮
    local btn_quickComplete = uiUtil.getConvertChildByName(mainWidget,"btn_quickComplete")
    btn_quickComplete:setVisible(false)
    btn_quickComplete:setTouchEnabled(false)
    --------------------------------------------------------------
    ------------- 建筑所处的各个状态调整 end ---------------------
    --------------------------------------------------------------
    
    

    if not isBuildingOpen()  then
        if curLv == 0 then 
            -- 未达到开启条件 
            panel_unopen:setVisible(true)
            local label_tips = uiUtil.getConvertChildByName(panel_unopen,"label_tips")
            label_tips:setText(getBuildingOpenPredition())

            local img_tips = uiUtil.getConvertChildByName(panel_unopen,"img_tips")
            local posX = (panel_unopen:getContentSize().width - label_tips:getContentSize().width - 20)/2
            img_tips:setPositionX(posX)
            label_tips:setPositionX(posX + 15)

            btn_build:setVisible(true)
            btn_build:setTouchEnabled(false)
            btn_build:setBright(false)
            GraySprite.create(btn_build_img_flag)
        else
            -- 未达到开启条件 但是已经建造了
            showPanelResConsume()

            btn_upgrade:setVisible(true)
            btn_upgrade:setTouchEnabled(true)
            btn_upgrade:setBright(false)
            
            btn_upgrade:addTouchEventListener(function(sender,eventType)
                if eventType == TOUCH_EVENT_ENDED then 
                    tipsLayer.create(getBuildingOpenPredition())
                end
            end)
        end

    else
        if isCityDuringAbandon() then 
            showPanelAbandoning()
        else
            if curLv == 0 and not buildInfo then 
                -- 已开放 但是还未建造
                btn_build:setVisible(true)
                btn_build:setTouchEnabled(true)
                
                showPanelResConsume()
                
            else
                if buildState.normal == buildInfo.state then
                    --已建造 正常状态
                    if m_bIsFullGraded then 
                        -- 达到最高等级
                        panel_hightestLv:setVisible(true)
                    else
                        btn_upgrade:setVisible(true)
                        btn_upgrade:setTouchEnabled(true)

                        showPanelResConsume()
                        
                    end
                elseif buildState.upgrade == buildInfo.state then 
                    --正在升级 
                    btn_quickComplete:setVisible(true)
                    btn_quickComplete:setTouchEnabled(true)

                    showPanelBuilding()
                    
                
                end
            end
        end
    end
    


    showBuildingEffect()
    showFullUpgradedEffect()
    autoSizeDetailPanel()
    autoSizeMainView()


    if btn_quickComplete:isVisible()  then 
        if curLv == 1 or curLv == 2  then 
            if m_iCurBid == cityBuildDefine.chengzhufu then 
                local current_city_id = mainBuildScene.getThisCityid()
                local build_info = politics.getBuildInfo(current_city_id, m_iCurBid)
                local need_yuanbao_num = userData.getBuildFinishImmediatelyCostYuanbao(build_info.end_time - userData.getServerTime())
                if need_yuanbao_num <= userData.getYuanbao() then
                    guide_temp_id = com_guide_id_list.CONST_GUIDE_2011
                    if m_bOpenStateFinished then 
                        checkNonForcedGuide()
                    end
                end
            end
        end
    end

end

local function showBuildMsg(newBid)
    local buildCfgInfo = Tb_cfg_build[newBid]
    if not buildCfgInfo then return end

    m_iCurBid = newBid
    create()
    reloadData()

    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, buildMsgManager.dealWithBuildAdd)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, buildMsgManager.dealWithBuildUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.remove, buildMsgManager.dealWithBuildRemove)

    UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.update, buildMsgManager.dealWithWorldCityUpdate)

end


local function dealWithBuildAdd(packet)
    if mainBuildScene.getThisCityid() * 100 + m_iCurBid == packet.build_id_u then
        reloadData()
    end
end


local function dealWithBuildUpdate(packet)
    if mainBuildScene.getThisCityid() * 100 + m_iCurBid == packet.build_id_u then
        reloadData()
    end
end

local function dealWithWorldCityUpdate(packet)
    reloadData()
end

local function dealWithBuildRemove(packet)
    -- TODOTK 这个逻辑不会再跑了 建筑没有移除的概念了
    if mainBuildScene.getThisCityid() * 100 + m_iCurBid == packet then
        reloadData()
    end
end 

local function get_guide_widget(temp_guide_id)
    if not m_pMainLayer then
        return nil
    end

    return m_pMainLayer:getWidgetByTag(999)
end

local function get_com_guide_widget(temp_guide_id)
    if m_pMainLayer then
        return m_pMainLayer:getWidgetByTag(999)
    else
        return nil
    end
end

buildMsgManager = {
    showBuildMsg = showBuildMsg,
    remove_self = remove_self,
    dealwithTouchEvent = dealwithTouchEvent,
    get_guide_widget = get_guide_widget,
    get_com_guide_widget = get_com_guide_widget,
    dealWithBuildUpdate = dealWithBuildUpdate,
    dealWithBuildRemove = dealWithBuildRemove,
    dealWithBuildAdd = dealWithBuildAdd,

    dealWithWorldCityUpdate = dealWithWorldCityUpdate,
}
