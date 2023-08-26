local innerMainTools = {}
local uiUtil = require("game/utils/ui_util")
local mainWidget = nil

local m_pArmatureTax = nil
local m_pArmatureBuildExpand = nil

local m_bLockSwitchCity = nil



local m_bIsNpcYaosai = nil
local m_bIsNpcJunying = nil

local m_bIsSwitchBtnInited = false

local function registBuildingUpdate()
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, innerMainTools.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, innerMainTools.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.remove, innerMainTools.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.update, innerMainTools.reloadData)

    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.update, innerMainTools.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.add, innerMainTools.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.remove, innerMainTools.reloadData)

   

    
    UIUpdateManager.add_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, innerMainTools.reloadData)

    UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, innerMainTools.reloadData)
    
end
local function unregistBuildingUpdate()
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.add, innerMainTools.reloadData)
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, innerMainTools.reloadData)
    UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.remove, innerMainTools.reloadData)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.update, innerMainTools.reloadData)


    UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.add, innerMainTools.reloadData)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.update, innerMainTools.reloadData)
    UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.remove, innerMainTools.reloadData)


    UIUpdateManager.remove_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, innerMainTools.reloadData)
    
    UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, innerMainTools.reloadData)
end



local btn_return = nil
local panel_building_options = nil
local m_pbtn_city_switch_right = nil
local m_pbtn_city_switch_left = nil
local panel_city_name = nil

local schedulerHandler = nil

local function disposeSchedulerHandler()
	if schedulerHandler then 
		scheduler.remove(schedulerHandler)
		schedulerHandler = nil
	end
end


function innerMainTools.remove()
	disposeSchedulerHandler()

    if panel_city_name then 
        panel_city_name:removeFromParentAndCleanup(true)
        panel_city_name = nil
    end

    if panel_building_options then 
        panel_building_options:removeFromParentAndCleanup(true)
        panel_building_options = nil
    end

    if btn_return then 
        btn_return:removeFromParentAndCleanup(true)
        btn_return = nil
    end

    if m_pbtn_city_switch_left then 
        m_pbtn_city_switch_left:removeFromParentAndCleanup(true)
        m_pbtn_city_switch_left = nil
    end
    if m_pbtn_city_switch_right then 
        m_pbtn_city_switch_right:removeFromParentAndCleanup(true)
        m_pbtn_city_switch_right = nil
    end
    m_pArmatureTax = nil
    m_pArmatureBuildExpand = nil

    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil

        m_bLockSwitchCity = nil
    end

    m_bIsNpcYaosai = nil
    m_bIsNpcJunying = nil

    unregistBuildingUpdate()
    -- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/btn_effect_shuishou.ExportJson")
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




local function updateScheduler()
	if not armyListInCityManager.getInstance() then return end
	armyListCityShare.show_army_hero_noEnergy_count_down(armyListInCityManager.getInstance(),mainBuildScene.getThisCityid())
end



local function activeSchedulerHandler()
	disposeSchedulerHandler()
	schedulerHandler = scheduler.create(updateScheduler,1)
end


local function checkArmyHeroTimer()
	disposeSchedulerHandler()
	if not mainBuildScene.getThisCityid()  or (not mainOption.getIsIncity())  then 
        return 
    end
	if not mainWidget then return end
	
	local city_id = mainBuildScene.getThisCityid()
	local armyIdList = armyData.getArmyListInCity(city_id)

	local isNeedTimer = false
	
	local hero_uid = nil
	local show_tips_type = nil
	for k,v in pairs(armyIdList) do 
		local temp_army_info = armyData.getTeamMsg(v)
		if temp_army_info then
			for i = 1,3 do 
				hero_uid = armyData.getHeroIdInTeamAndPos(v, i)
				show_tips_type = heroData.get_hero_state_in_army(hero_uid)
				if show_tips_type == heroStateDefine.no_energy then 
					isNeedTimer = true
					break
				end
			end
		end
	end
	
	if isNeedTimer then 
		activeSchedulerHandler()
	end
end

function innerMainTools.reloadData()
    if not mainWidget then return end
    -- if not mainWidget:isVisible() then return end

    if not mainBuildScene.getThisCityid()  or (not mainOption.getIsIncity())  then 
        -- mainWidget:setVisible(false)
        return 
    end

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/btn_effect_shuishou.ExportJson")
    

    local panel_main = uiUtil.getConvertChildByName(mainWidget,"panel_main")
    local panel_detail_1 = uiUtil.getConvertChildByName(panel_main,"panel_detail_1")
    local panel_detail_2 = uiUtil.getConvertChildByName(panel_main,"panel_detail_2")
    local panel_detail_3 = uiUtil.getConvertChildByName(panel_main,"panel_detail_3") -- 预备兵

    local label_coin = uiUtil.getConvertChildByName(panel_main,"label_coin")
    local label_gold = uiUtil.getConvertChildByName(panel_main,"label_gold")
    -- local label_area = uiUtil.getConvertChildByName(panel_detail_1,"label_area")
    local label_durability = uiUtil.getConvertChildByName(panel_detail_1,"label_durability")
    local label_soldierForces = uiUtil.getConvertChildByName(panel_detail_1,"label_soldierForces")
    local label_MaintainConsumption = uiUtil.getConvertChildByName(panel_detail_2,"label_MaintainConsumption")


    local yuanbao_nums = userData.getYuanbao()
    local money_nums = 0
    local selfCommonRes = politics.getSelfRes()
    if selfCommonRes then
        money_nums = selfCommonRes.money_cur
    end
    label_gold:setText(commonFunc.common_gold_show_content(yuanbao_nums))
    label_coin:setText(commonFunc.common_coin_show_content(money_nums))


    local data = userCityData.getUserCityData(mainBuildScene.getThisCityid())
    if data then
        -- label_area:setText(data.build_area_cur.."/"..data.build_area_max)    
    end

    local coor_x = math.floor(mainBuildScene.getThisCityid()/10000)
    local coor_y = mainBuildScene.getThisCityid()%10000
    local durability_cur,durability_max = landData.getDurabilityInfo(coor_x , coor_y)
    label_durability:setText(durability_cur .. "/" .. durability_max)

    -- local selfCommonRes = politics.getSelfRes()
    -- labelTaxNum:setText(selfCommonRes.login_money)

    local cityMessage = userCityData.getUserCityData(mainBuildScene.getThisCityid())
    label_MaintainConsumption:setText( languagePack["liangshi"] .. cityMessage.food_cost .. "/" .. languagePack["xiaoshi"])


    local totalSoldierNum = 0
    local temp_army_info = nil
    for k,v in pairs(armyData.getAllArmyInCity(mainBuildScene.getThisCityid())) do 
        temp_army_info = armyData.getTeamMsg(v)
        if temp_army_info then 
            if temp_army_info.state == armyState.normal 
                or
                ( 
                 (temp_army_info.state == armyState.zhuzhaed 
                   or temp_army_info.state == armyState.yuanjuned 
                   or temp_army_info.state == armyState.zhuzhaing
                   or temp_army_info.state == armyState.yuanjuning)
                   and 
                   temp_army_info.target_wid == mainBuildScene.getThisCityid()
                )
            then
                totalSoldierNum = totalSoldierNum + armyData.getTeamHp(v)
            end
        end
    end

    label_soldierForces:setText(totalSoldierNum)

    -- if panel_detail_3:isVisible() then 
    --     -- 预备兵
    --     local label_num = uiUtil.getConvertChildByName(panel_detail_3,"label_num")
    --     -- local cur_num = userData.getCityReserveForcesSoldierNum()
    --     -- local userCityData = userCityData.getUserCityData(mainBuildScene.getThisCityid())
    --     -- print(">>>>>>>>>>>>>>> userCityData",cur_num)
    --     -- local max_num = userCityData.redif_max
    --     label_num:setText(100 .. "/" .. 100)
    -- end

    local panel_options = uiUtil.getConvertChildByName(mainWidget,"panel_options")
    local tmp_btn = nil

    -- 税收按钮
    -- tmp_btn = uiUtil.getConvertChildByName(panel_options,"btn_op_5")
    -- tmp_btn:setVisible(false)
    -- tmp_btn:setTouchEnabled(false)
    -- if mainBuildScene.isInCity() then
    --     for i, v in pairs(allTableData[dbTableDesList.build.name]) do
    --         --民居
    --         if v.build_id_u%100 == 13 and v.level >=1 and userData.getMainPos() == mainBuildScene.getThisCityid() then
    --             tmp_btn:setTouchEnabled(true)
    --             tmp_btn:setVisible(true)
    --         end
    --     end
    -- end
    -- local imgFlag = uiUtil.getConvertChildByName(tmp_btn,"img_flag")
    -- imgFlag:setVisible(false)
    -- local labelNum = uiUtil.getConvertChildByName(imgFlag,"label_num")
    -- local taxCount = 0
    -- labelNum:setText(taxCount)
    -- labelNum:setVisible(false) -- 不显示次数 永远只有一次
    -- for i, v in pairs(allTableData[dbTableDesList.user_revenue.name]) do
    --     if v.userid == userData.getUserId() then
    --         if (#stringFunc.anlayerMsg(v.revenue_info)<REVENUE_COUNT_A_DAY and userData.getServerTime()-v.revenue_time > REVENUE_CD) 
    --             or os.date("%d", userData.getServerTime()) ~= os.date("%d", v.revenue_time) then
    --             imgFlag:setVisible(true)
    --             taxCount = 1
    --         end
    --     end
    -- end

    -- if not allTableData[dbTableDesList.user_revenue.name][userData.getUserId()] then
    --     imgFlag:setVisible(true)
    --     taxCount = 1
    -- end
    -- local panel_effectContainer = uiUtil.getConvertChildByName(tmp_btn,"panel_effectContainer")

    -- if not m_pArmatureTax then 
    --     m_pArmatureTax = CCArmature:create("btn_effect_shuishou")
    --     m_pArmatureTax:getAnimation():playWithIndex(0)
    --     m_pArmatureTax:ignoreAnchorPointForPosition(false)
    --     m_pArmatureTax:setAnchorPoint(cc.p(0.5, 0.5))
    --     panel_effectContainer:addChild(m_pArmatureTax)
    --     m_pArmatureTax:setPosition(cc.p(panel_effectContainer:getContentSize().width/2,panel_effectContainer:getContentSize().height/2 - 3 ))
    -- end

    -- if taxCount > 0 then 
    --     labelNum:setVisible(true)
    --     labelNum:setText(1)
    --     m_pArmatureTax:setVisible(true)
    -- else
    --     m_pArmatureTax:setVisible(false)
    -- end

    -- -- 内政按钮
    -- local  tempBtn = uiUtil.getConvertChildByName(panel_options,"btn_op_3")
    -- tempBtn:setVisible(true)
    -- tempBtn:setTouchEnabled(true)


    -- 扩建
    local tempBtn = uiUtil.getConvertChildByName(panel_building_options,"btn_op_3")
    local panel_effectContainer = uiUtil.getConvertChildByName(tempBtn,"panel_effectContainer")
    if panel_effectContainer then 
        panel_effectContainer:setBackGroundColorType(LAYOUT_COLOR_NONE)
    end
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
    if not m_pArmatureBuildExpand then 
        m_pArmatureBuildExpand = CCArmature:create("btn_effect_shuishou")
        m_pArmatureBuildExpand:getAnimation():playWithIndex(0)
        m_pArmatureBuildExpand:ignoreAnchorPointForPosition(false)
        m_pArmatureBuildExpand:setAnchorPoint(cc.p(0.5, 0.5))
        panel_effectContainer:addChild(m_pArmatureBuildExpand)
        m_pArmatureBuildExpand:setPosition(cc.p(panel_effectContainer:getContentSize().width/2,panel_effectContainer:getContentSize().height/2 - 3 ))
    end
    m_pArmatureBuildExpand:setVisible(true)

    


    -- local pos_y = 90
    -- for i = 3,3 do 
    --     tempBtn = uiUtil.getConvertChildByName(panel_options,"btn_op_" .. i)
    --     if tempBtn:isVisible() then 
    --         tempBtn:setPositionY(pos_y)
    --         pos_y = pos_y + 70
    --     end
    -- end


    local label_name = uiUtil.getConvertChildByName(panel_city_name,"label_name")
    local wid = mainBuildScene.getThisCityid()
    local cityName = ""
    local cityInfo = userCityData.getUserCityData(wid)
    if cityInfo.state == cityState.building then 
        local cityInfo = landData.get_world_city_info(wid)
        if cityInfo and cityInfo.name ~= "" then 
            cityName = cityInfo.name
        else
            cityName = landData.get_city_name_by_coordinate(wid)
        end
    else
        cityName = landData.get_city_name_by_coordinate(wid)
    end

    label_name:setText(cityName)
    local btn_tips = uiUtil.getConvertChildByName(panel_city_name,"btn_tips")
    -- btn_tips:setVisible(m_bIsNpcYaosai)


    local function onClickName( )
        if m_bIsNpcJunying then 
            alertLayer.create(errorTable[2003])
        elseif m_bIsNpcYaosai then
            alertLayer.create(errorTable[2002])
        else
            require("game/option/ui_city_intro")
            UICityIntro.create(landData.get_land_type(mainBuildScene.getThisCityid()))
        end
    end
    btn_tips:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            onClickName()
        end
    end)

    panel_city_name:setTouchEnabled(true)
    panel_city_name:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            onClickName()
        end
    end)

	checkArmyHeroTimer()
end


--根据服务器返回刷新预备兵数量
local function refreshRedif(packet )
    if mainWidget then
        local panel_main = uiUtil.getConvertChildByName(mainWidget,"panel_main")
        local panel_detail_3 = uiUtil.getConvertChildByName(panel_main,"panel_detail_3")
        local label_num = uiUtil.getConvertChildByName(panel_detail_3,"label_num")
        local cur = packet[1]
        local level = 1
        if Tb_cfg_world_city[mainBuildScene.getThisCityid()] then
            level = Tb_cfg_world_city[mainBuildScene.getThisCityid()].param%100
        end

        local max = NPC_RECRUIT_REDIF_MAX[level]
        label_num:setText(cur.."/"..max)
    end
end

function innerMainTools.hideEffect(duration,closeEffect)
    if not mainWidget then return end
    if not duration then duration = 0.5 end
    -- if closeEffect then duration = 0 end

    mainWidget:setVisible(true)
    uiUtil.hideScaleEffect(mainWidget,function()
        mainWidget:setVisible(false)
        
    end,duration)

    panel_city_name:setVisible(true)
    uiUtil.hideScaleEffect(panel_city_name,function()
        panel_city_name:setVisible(false)
        local btn_tips = uiUtil.getConvertChildByName(panel_city_name,"btn_tips")
        btn_tips:setTouchEnabled(false)
    end,duration)

    btn_return:setVisible(true)
    btn_return:setTouchEnabled(false)
    uiUtil.hideScaleEffect(btn_return,function()
        btn_return:setVisible(false)
        local panel_options = uiUtil.getConvertChildByName(mainWidget,"panel_options")
        for i = 1,2 do 
            tmp_btn = uiUtil.getConvertChildByName(panel_options,"btn_op_" .. i)
            tmp_btn:setTouchEnabled(false)
        end
    end,duration)

    uiUtil.hideScaleEffect(panel_building_options,function()
        panel_building_options:setTouchEnabled(false)
        for i = 1,3 do 
            tmp_btn = uiUtil.getConvertChildByName(panel_building_options,"btn_op_" .. i)
            tmp_btn:setTouchEnabled(false)
        end
    end,7/24,0.8 )

    netObserver.removeObserver(GET_NPC_RECRUIT_INFO_CMD)
end
function innerMainTools.showEffect(duration,closeEffect)
    if not mainWidget then return end
    if not duration then duration = 0.5 end
    -- if closeEffect then duration = 0 end
    mainWidget:setVisible(true)
    uiUtil.showScaleEffect(mainWidget,nil,duration,nil,nil,0)


    
    panel_city_name:setVisible(true)
    uiUtil.showScaleEffect(panel_city_name,function()
        panel_city_name:setVisible(true)
        local btn_tips = uiUtil.getConvertChildByName(panel_city_name,"btn_tips")
        btn_tips:setTouchEnabled(true)
    end,duration)


    btn_return:setVisible(true)
    btn_return:setTouchEnabled(false)
    uiUtil.showScaleEffect(btn_return,function()
        btn_return:setTouchEnabled(true)
        btn_return:setVisible(true)
        local panel_options = uiUtil.getConvertChildByName(mainWidget,"panel_options")
        for i = 1,2 do 
            tmp_btn = uiUtil.getConvertChildByName(panel_options,"btn_op_" .. i)
            if tmp_btn:isVisible() then
                tmp_btn:setTouchEnabled(true)
            end
        end
    end,duration)


    uiUtil.showScaleEffect(panel_building_options,function()
        panel_building_options:setTouchEnabled(true)
        for i = 1,3 do 
            tmp_btn = uiUtil.getConvertChildByName(panel_building_options,"btn_op_" .. i)
            if tmp_btn:isVisible() then
                tmp_btn:setTouchEnabled(true)
            end
        end
    end,7/24,0.8 )

    netObserver.addObserver(GET_NPC_RECRUIT_INFO_CMD, refreshRedif)
    Net.send(GET_NPC_RECRUIT_INFO_CMD, {mainBuildScene.getThisCityid()})
end

local function getCityList()
    return userCityData.getEffectCityList(true, true, true,true,false,true)
end

local function resetCitySwitchBtn(isInCity,closeEffect)

    if not mainWidget then return end

    local btn_city_switch_right = m_pbtn_city_switch_right
    local btn_city_switch_left = m_pbtn_city_switch_left

    btn_city_switch_left:setTouchEnabled(false)
    btn_city_switch_left:setVisible(false)
    btn_city_switch_right:setTouchEnabled(false)
    btn_city_switch_right:setVisible(false)

    if not isInCity then return end


    local curCidIndx = 0
    local curCid = mainBuildScene.getThisCityid()

    local cityList = getCityList()

    for k,v in ipairs(cityList) do 
        if v == curCid then 
            curCidIndx = k
        end
    end
    
    if #cityList == 1 then 
        btn_city_switch_left:setTouchEnabled(false)
        btn_city_switch_left:setVisible(false)
        btn_city_switch_right:setTouchEnabled(false)
        btn_city_switch_right:setVisible(false)
        return
    end
    if curCidIndx > 1 and curCidIndx < #cityList then 
        btn_city_switch_left:setTouchEnabled(true)
        btn_city_switch_left:setVisible(true)
        btn_city_switch_right:setTouchEnabled(true)
        btn_city_switch_right:setVisible(true)
    elseif curCidIndx == 1 then 
        btn_city_switch_right:setTouchEnabled(true)
        btn_city_switch_right:setVisible(true)
    elseif curCidIndx == #cityList then
        btn_city_switch_left:setTouchEnabled(true)
        btn_city_switch_left:setVisible(true)
    else
        btn_city_switch_left:setTouchEnabled(false)
        btn_city_switch_left:setVisible(false)
        btn_city_switch_right:setTouchEnabled(false)
        btn_city_switch_right:setVisible(false)
    end

   

    
end


local function resetMaintoolView(isInCity,closeEffect)
    if not mainWidget then return end

    local panel_main = uiUtil.getConvertChildByName(mainWidget,"panel_main")
    local btn_b_op_1 = uiUtil.getConvertChildByName(panel_building_options,"btn_op_1")
    local btn_b_op_2 = uiUtil.getConvertChildByName(panel_building_options,"btn_op_2")
    local btn_b_op_3 = uiUtil.getConvertChildByName(panel_building_options,"btn_op_3")
    btn_b_op_1:setVisible(false)
    btn_b_op_1:setTouchEnabled(false)
    btn_b_op_2:setVisible(false)
    btn_b_op_2:setTouchEnabled(false)
    btn_b_op_3:setVisible(false)
    btn_b_op_3:setTouchEnabled(false)
    panel_building_options:setTouchEnabled(false)

    
    local panel_options = uiUtil.getConvertChildByName(mainWidget,"panel_options")
    local btn_op_1 = uiUtil.getConvertChildByName(panel_options,"btn_op_1")
    local btn_op_2 = uiUtil.getConvertChildByName(panel_options,"btn_op_2")
    btn_op_1:setVisible(false)
    btn_op_1:setTouchEnabled(false)
    btn_op_2:setVisible(false)
    btn_op_2:setTouchEnabled(false)
    btn_op_2:setPositionY(btn_op_1:getPositionY())

    if closeEffect and (not isInCity) then 
        mainWidget:setVisible(false)
        btn_return:setTouchEnabled(false)
        btn_return:setVisible(false)
        return 
    end

    
    mainWidget:setVisible(true)
    local panel_detail_1 = uiUtil.getConvertChildByName(panel_main,"panel_detail_1")
    local panel_detail_2 = uiUtil.getConvertChildByName(panel_main,"panel_detail_2")
    local panel_detail_3 = uiUtil.getConvertChildByName(panel_main,"panel_detail_3")

    local land_id = mainBuildScene.getThisCityid()
    local isFort = landData.get_land_type(land_id) ==  cityTypeDefine.yaosai -- 是否是要塞
    m_bIsNpcYaosai = landData.get_land_type(land_id) == cityTypeDefine.npc_yaosai
    if Tb_cfg_world_city[land_id] and Tb_cfg_world_city[land_id].param >=NPC_FORT_TYPE_RECRUIT[1] and
        Tb_cfg_world_city[land_id].param <=NPC_FORT_TYPE_RECRUIT[2] then
        m_bIsNpcJunying = true
    else
        m_bIsNpcJunying = false
    end

    
    panel_building_options:setTouchEnabled(true)

    if isFort or m_bIsNpcYaosai then 
        panel_detail_1:setVisible(true)
        panel_detail_2:setVisible(false)
        if m_bIsNpcJunying then 
            panel_detail_3:setVisible(true)
            panel_detail_3:setPositionX(600)
        else
            panel_detail_3:setVisible(false)
        end

        if m_bIsNpcYaosai then 
            panel_detail_1:setPositionX(702 + 120)
        else
            panel_detail_1:setPositionX(702 - 50)
        end
        btn_op_2:setVisible(true and not m_bIsNpcYaosai)
        btn_op_2:setTouchEnabled(true and not m_bIsNpcYaosai)
        

        btn_b_op_2:setVisible(true and (not m_bIsNpcYaosai))
        btn_b_op_2:setTouchEnabled(true and (not m_bIsNpcYaosai))
    else
        panel_detail_1:setVisible(true)
        panel_detail_2:setVisible(true)
        panel_detail_3:setVisible(false)
        if m_bIsNpcYaosai then 
            panel_detail_1:setPositionX(482 + 120)
            panel_detail_2:setPositionX(785 + 120)
        else
            panel_detail_1:setPositionX(482)
            panel_detail_2:setPositionX(785)
        end
        btn_op_1:setVisible(true and not m_bIsNpcYaosai)
        btn_op_1:setTouchEnabled(true and not m_bIsNpcYaosai)

        btn_b_op_1:setVisible(true and (not m_bIsNpcYaosai))
        btn_b_op_1:setTouchEnabled(true and (not m_bIsNpcYaosai))
    end


    

    if isInCity then 
        innerMainTools.showEffect(nil,closeEffect)
    else
        innerMainTools.hideEffect(nil,closeEffect)
    end
end

function innerMainTools.changeInCityState(isInCity,closeEffect)
    if not mainWidget then return end
    
    resetMaintoolView(isInCity,closeEffect)
    resetCitySwitchBtn(isInCity,closeEffect)
    innerMainTools.reloadData()
end

-- indxDirection  -1 向左  1 向右
local function switchCity(indxDirection)
    if m_bLockSwitchCity then return end

    if not indxDirection then return end
    if indxDirection == 0 then return end

    local curCidIndx = 0
    local curCid = mainBuildScene.getThisCityid()

    local cityList = getCityList()

    for k,v in ipairs(cityList) do 
        if v == curCid then 
            curCidIndx = k
        end
    end

    local newCidIndx = curCidIndx + indxDirection

    if not cityList[newCidIndx] then return end


    m_bLockSwitchCity = true

    local jumpCid = cityList[newCidIndx]
    local jumpCoorX = math.floor(jumpCid / 10000)
    local jumpCoorY = math.floor(jumpCid % 10000)

    
    mainBuildScene.remove(false)
    mainBuildScene.setThisCityid(jumpCid)
    mapMessageUI.enterCityDetailinfo(jumpCoorX,jumpCoorY)


    
    
    if innerOptionLeft then 
        innerOptionLeft.reloadData()
    end
    
    
    innerMainTools.changeInCityState(true,false)
    armyListInCityManager.effectLoadingNewCityArmyInfo(jumpCid,curCid,function()
        m_bLockSwitchCity = false
    end)


    --- 
    uiUtil.showScaleEffect(panel_building_options,function()
        --pass
    end,7/24,0.8)
    
end

local function initCitySwitchBtn(mainLayer)
    if not mainWidget then return end

    m_pbtn_city_switch_right = uiUtil.getConvertChildByName(mainWidget,"btn_city_switch_right")
    m_pbtn_city_switch_left = uiUtil.getConvertChildByName(mainWidget,"btn_city_switch_left")

    m_pbtn_city_switch_left:removeFromParentAndCleanup(false)
    m_pbtn_city_switch_left:setScale(config.getgScale())
    m_pbtn_city_switch_left:ignoreAnchorPointForPosition(false)
    m_pbtn_city_switch_left:setAnchorPoint(cc.p(0,0.5))
    m_pbtn_city_switch_left:setPosition(cc.p( 15 * config.getgScale(),config.getWinSize().height/2))
    mainLayer:addWidget(m_pbtn_city_switch_left)
    m_pbtn_city_switch_left:setZOrder(9999)
    m_pbtn_city_switch_right:removeFromParentAndCleanup(false)
    m_pbtn_city_switch_right:setScale(config.getgScale())
    m_pbtn_city_switch_right:ignoreAnchorPointForPosition(false)
    m_pbtn_city_switch_right:setAnchorPoint(cc.p(1,0.5))
    m_pbtn_city_switch_right:setPosition(cc.p(config.getWinSize().width - 15 * config.getgScale(),config.getWinSize().height/2))
    m_pbtn_city_switch_right:setZOrder(9999)
    mainLayer:addWidget(m_pbtn_city_switch_right)


    m_pbtn_city_switch_left:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            switchCity(-1)
        end
    end)

    m_pbtn_city_switch_right:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            switchCity(1)
        end
    end)

    m_pbtn_city_switch_right:setTouchEnabled(false)
    m_pbtn_city_switch_left:setTouchEnabled(false)
    
    breathAnimUtil.start_scroll_dir_anim(m_pbtn_city_switch_left,m_pbtn_city_switch_right)
end


function innerMainTools.create(mainLayer)
    if not mainLayer then return end
    
    m_bLockSwitchCity = false

    if mainWidget then 
        innerMainTools.remove()
    end
    

    mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/chengnei_1.json")
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(1,0))
    mainWidget:setScale(config.getgScale())
    mainWidget:setPosition(cc.p(config.getWinSize().width, 0))
    mainLayer:addWidget(mainWidget)
    mainWidget:setTouchEnabled(true)
    local panel_main = uiUtil.getConvertChildByName(mainWidget,"panel_main")
    
    local payBtn = tolua.cast(panel_main:getChildByName("Button_pay"),"Button")
    payBtn:setTouchEnabled(true)
    payBtn:addTouchEventListener(function ( sender,eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if mainBuildScene.isInCity() then
                PayUI.create()
            end
        end
    end)

    local yuanbao = tolua.cast(panel_main:getChildByName("ImageView_475820_1_0"),"ImageView")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/yufu_texiao.ExportJson")

    local effect = CCArmature:create("yufu_texiao")--ImageView:create()
    effect:getAnimation():playWithIndex(0)
    yuanbao:addChild(effect)
    
    local panel_options = uiUtil.getConvertChildByName(mainWidget,"panel_options")
    panel_options:setBackGroundColorType(LAYOUT_COLOR_NONE)

    local tmp_btn = nil
    local panel_effectContainer = nil
    for i = 1,2 do 
        tmp_btn = uiUtil.getConvertChildByName(panel_options,"btn_op_" .. i)
        tmp_btn:setTouchEnabled(false)
        panel_effectContainer = uiUtil.getConvertChildByName(tmp_btn,"panel_effectContainer")
        if panel_effectContainer then 
            panel_effectContainer:setBackGroundColorType(LAYOUT_COLOR_NONE)
        end
        tmp_btn:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                
                cityMsg.create()
            end
        end)
    end


    panel_city_name = uiUtil.getConvertChildByName(mainWidget,"panel_city_name")
    panel_city_name:removeFromParentAndCleanup(false)
    panel_city_name:setScale(config.getgScale())
    panel_city_name:ignoreAnchorPointForPosition(false)
    panel_city_name:setAnchorPoint(cc.p(0.5,1))
    panel_city_name:setPosition(cc.p(config.getWinSize().width/2,config.getWinSize().height - 130 * config.getgScale()))
    mainLayer:addWidget(panel_city_name)
    panel_city_name:setVisible(false)




    btn_return = uiUtil.getConvertChildByName(mainWidget,"btn_return")
    btn_return:removeFromParentAndCleanup(false)
    btn_return:setScale(config.getgScale())
    btn_return:ignoreAnchorPointForPosition(false)
    btn_return:setAnchorPoint(cc.p(1,1))
    btn_return:setPosition(cc.p(config.getWinSize().width - 0 * config.getgScale(),config.getWinSize().height --[[- 21 * config.getgScale()]]))
    btn_return:setTouchEnabled(false)
    btn_return:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            --返回地图
            newGuideInfo.enter_next_guide()
            mainBuildScene.remove(true)
        end
    end)
    mainLayer:addWidget(btn_return)


    panel_building_options = uiUtil.getConvertChildByName(mainWidget,"panel_building_options")
    panel_building_options:removeFromParentAndCleanup(false)
    mainLayer:addWidget(panel_building_options)
    panel_building_options:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_building_options:ignoreAnchorPointForPosition(false)
    panel_building_options:setAnchorPoint(cc.p(1,0.5))
    panel_building_options:setScale(config.getgScale())
    panel_building_options:setPosition(cc.p( config.getWinSize().width * 3/4 ,config.getWinSize().height /2 ))


    local function dealWithClickBuildingOp(indx)
        if indx == 1 then 
            -- 设施
            newGuideInfo.enter_next_guide()
            require("game/buildScene/buildTreeManager")
            buildTreeManager.create()
        elseif indx == 2 then 
            -- 堡垒
            require("game/buildScene/buildMsgManager")
            buildMsgManager.showBuildMsg(cityBuildDefine.baolei)
        elseif indx == 3 then 
            -- 扩建
            if not BuildingExpand.getInstance() then
                BuildingExpand.create(mainBuildScene.getThisCityid())
            end
        end
    end
    for i = 1,3 do 
        tmp_btn = uiUtil.getConvertChildByName(panel_building_options,"btn_op_" .. i)
        tmp_btn:setTouchEnabled(false)
        tmp_btn:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                dealWithClickBuildingOp(i)
            end
        end)
    end

    
    panel_building_options:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
            local tmp_btn = nil
            for i = 1,3 do 
                tmp_btn = uiUtil.getConvertChildByName(panel_building_options,"btn_op_" .. i)
                if tmp_btn:isVisible() then 
                    dealWithClickBuildingOp(i)
                    break
                end
            end
        end
    end)





    initCitySwitchBtn(mainLayer)

    innerMainTools.changeInCityState(false,true)

    registBuildingUpdate()

    return mainWidget:getContentSize().height
end

function innerMainTools.get_guide_widget(temp_guide_id)
    if temp_guide_id == guide_id_list.CONST_GUIDE_1083 then
        if mainWidget then 
            for i = 1,2 do 
                local tmp_btn = uiUtil.getConvertChildByName(panel_building_options,"btn_op_" .. i)
                if tmp_btn:isVisible() then 
                    return tmp_btn
                end
            end
        end
    else
        return btn_return
    end
end

function innerMainTools.get_com_guide_widget(temp_guide_id)
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2022 then 
        return panel_building_options
    end
end

return innerMainTools 
