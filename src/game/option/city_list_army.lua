module("UICityListArmy", package.seeall)

-- 城外城市部队信息
-- 类名： UICityListArmy
-- ID名： UI_CITYLIST_ARMY
-- json名： chengshirkou.json


local m_pMainLayer = nil
local m_backPanel = nil
local city_list_tv = nil



local city_list_army_img_city_type_url_a = ResDefineUtil.city_list_army_img_city_type_url_a
local city_list_army_img_city_type_url_b = ResDefineUtil.city_list_army_img_city_type_url_b

local tb_cache_city_list = nil


local schedulerHandler = nil

local function disposeSchedulerHandler()
	if schedulerHandler then 
		scheduler.remove(schedulerHandler)
		schedulerHandler = nil
	end
end

local function do_remove_self()
	if m_pMainLayer then 
		disposeSchedulerHandler()
		if city_list_tv then 
            city_list_tv:removeFromParentAndCleanup(true)
            city_list_tv = nil
        end

		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end
        tb_cache_city_list = nil

		m_pMainLayer:getParent():setOpacity(150)
		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_CITYLIST_ARMY)

        UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, UICityListArmy.reloadData)
        UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, UICityListArmy.reloadData)
	end
end

function remove_self()
	if m_backPanel then
    	uiManager.hideConfigEffect(uiIndexDefine.UI_CITYLIST_ARMY, m_pMainLayer, do_remove_self, 999, {m_backPanel:getMainWidget()})
    end
end




local function refreshAllArmyHeroTimerCountdown()
	if not m_pMainLayer then return end
	if not tb_cache_city_list then return end
	if #tb_cache_city_list == 0 then return end
	for i = 1,#tb_cache_city_list do 
		local indx = i - 1
		local cell = city_list_tv:cellAtIndex(indx)
    	if not cell then return end
    
    	local cellWidget = nil
    	local cellLayer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    	if cellLayer then
        	cellWidget = tolua.cast(cellLayer:getWidgetByTag(1),"Layout")
			local panel_army = uiUtil.getConvertChildByName(cellWidget,"panel_army")
            local armyList = uiUtil.getConvertChildByName(panel_army,"armyList")
			local city_id = tb_cache_city_list[i]
            armyListCityShare.show_army_hero_noEnergy_count_down(armyList,city_id)
    	end 

	end
end

local function updateScheduler()
	refreshAllArmyHeroTimerCountdown()
end

local function activeSchedulerHandler()
	disposeSchedulerHandler()
	schedulerHandler = scheduler.create(updateScheduler,1)
end


local function checkArmyHeroTimer()
	disposeSchedulerHandler()
	if not m_pMainLayer then return end
	if not tb_cache_city_list then return end
	if #tb_cache_city_list == 0 then return end

	local isNeedTimer = false
	
	local armyList = armyData.getAllTeamMsg()
	local hero_uid = nil
	local show_tips_type = nil
	for k,v in pairs(armyList) do 
		for i = 1,3 do 
			hero_uid = armyData.getHeroIdInTeamAndPos(k, i)
			show_tips_type = heroData.get_hero_state_in_army(hero_uid)
			if show_tips_type == heroStateDefine.no_energy then 
				isNeedTimer = true
				break
			end
		end
	end
	
	if isNeedTimer then 
		activeSchedulerHandler()
	end
end

function reloadData()
    if not city_list_tv then return end
    if not uiManager.is_most_above_layer(uiIndexDefine.UI_CITYLIST_ARMY) then return end
    city_list_tv:reloadData() 
	checkArmyHeroTimer()
end


local function getCityList()
    tb_cache_city_list = userCityData.getEffectCityList(true, true, true,true,false,true)
end

local function localFetchCityInfo(idx)
    local city_info = landData.get_world_city_info(tb_cache_city_list[idx])
    return tb_cache_city_list[idx], landData.get_land_displayName( city_info.wid,city_info.city_type)
end

function dealwithTouchEvent(x,y)
	return false
	-- if not m_pMainLayer then return false end

	-- local mainWidget = m_pMainLayer:getWidgetByTag(999)
	-- if mainWidget:hitTest(cc.p(x,y)) then 
	-- 	return false
	-- else
	-- 	remove_self()
	-- 	return true
	-- end
end

local function tableCellTouched(table,cell)
    local temp_id,temp_name = localFetchCityInfo(cell:getIdx()+1)
    local temp_x = math.floor(temp_id/10000)
    local temp_y = temp_id%10000
    
    remove_self()
    
    mapController.jump(temp_x,temp_y)
    mapMessageUI.moveAndEnter(temp_x,temp_y)
end



local function cellSizeForTable(table,idx)
    return 300, 1140
end

local function numberOfCellsInTableView(table)
    return #tb_cache_city_list
end


local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = CCTableViewCell:new()
        local mlayer = TouchGroup:create()
        local widget = GUIReader:shareReader():widgetFromJsonFile("test/chengshirkou.json")
        widget:setVisible(true)
        -- widget:setTouchEnabled(true)
        widget:setPosition(cc.p(0,0))
        mlayer:addWidget(widget)
        widget:setTag(1)
        cell:addChild(mlayer)
        mlayer:setTag(123)

        local img_flag_arrow = uiUtil.getConvertChildByName(widget,"img_flag_arrow")
        breathAnimUtil.start_scroll_dir_anim(img_flag_arrow,img_flag_arrow)
        -- 部队列表
        local panel_army = uiUtil.getConvertChildByName(widget,"panel_army")
        -- panel_army:setTouchEnabled(true)
        panel_army:setBackGroundColorType(LAYOUT_COLOR_NONE)
        panel_army:removeAllChildrenWithCleanup(true)

        local armyList = armyListCityShare.create(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then
                local select_index = tonumber(string.sub(sender:getName(),6))
                local temp_id,temp_name = localFetchCityInfo(cell:getIdx()+1)
                -- require("game/army/armyCityOverview/armyWholeManager")
                -- do_remove_self()
                -- armyWholeManager.on_enter(temp_id,select_index,function()
                --     UICityListArmy.create()
                -- end)
                
                armyListCityShare.deal_with_city_army_click(temp_id,select_index)
            end
        end)
        -- armyList:setTouchEnabled(true)
        panel_army:addChild(armyList)
        armyList:setName("armyList")
        
    end
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
        if layer:getWidgetByTag(1) then
            local widget = tolua.cast(layer:getWidgetByTag(1),"Layout")
            local panel_city_detail = uiUtil.getConvertChildByName(widget,"panel_city_detail")
            local label_city_name = uiUtil.getConvertChildByName(panel_city_detail,"label_city_name")
            local label_pos = uiUtil.getConvertChildByName(panel_city_detail,"label_pos")
            

            local temp_id,temp_name = localFetchCityInfo(idx + 1)
            local coorX = math.floor(temp_id/10000)
            local coorY = temp_id % 10000 
            -- label_city_name:setText(landData.get_city_name_by_coordinate(temp_id) 
            local cityName = nil
            local cityInfo = userCityData.getUserCityData(temp_id)
            if cityInfo.state == cityState.building then 
                local cityInfo = landData.get_world_city_info(temp_id)
                if cityInfo and cityInfo.name ~= "" then 
                    cityName = cityInfo.name
                else
                    cityName = landData.get_city_name_by_coordinate(temp_id)
                end
            else
                cityName = landData.get_city_name_by_coordinate(temp_id)
            end

            local img_city_type = uiUtil.getConvertChildByName(widget,"img_city_type")
            local city_type = landData.get_land_type(temp_id)
            if city_type == cityTypeDefine.npc_yaosai then 
                if Tb_cfg_world_city[temp_id] and Tb_cfg_world_city[temp_id].param >=NPC_FORT_TYPE_RECRUIT[1] and
                    Tb_cfg_world_city[temp_id].param <=NPC_FORT_TYPE_RECRUIT[2] then
                    -- city_type = city_type
                else
                    city_type = 4
                end
            end
            if city_list_army_img_city_type_url_a[city_type] then 
                img_city_type:loadTexture(city_list_army_img_city_type_url_a[city_type], UI_TEX_TYPE_LOCAL)
            end
            img_city_type = uiUtil.getConvertChildByName(panel_city_detail,"img_city_type")
            if city_list_army_img_city_type_url_b[city_type] then 
                img_city_type:loadTexture(city_list_army_img_city_type_url_b[city_type], UI_TEX_TYPE_PLIST)
            end

            

            -- 城市信息
            label_city_name:setText(cityName)
            label_pos:setText(coorX .. "," .. coorY)

            local panel_army_detail = uiUtil.getConvertChildByName(widget,"panel_army_detail")
            local label_durability = uiUtil.getConvertChildByName(panel_army_detail,"label_durability")
            local label_soldier_num = uiUtil.getConvertChildByName(panel_army_detail,"label_soldier_num")
            local label_consume = uiUtil.getConvertChildByName(panel_army_detail,"label_consume")
            -- 耐久度信息
            local durability_cur,durability_max = landData.getDurabilityInfo(coorX , coorY)
            label_durability:setText(durability_cur .. "/" .. durability_max)

            -- 维持消耗
            local cityMessage = userCityData.getUserCityData(temp_id)
            label_consume:setText( languagePack["liangshi"] .. cityMessage.food_cost .. "/" .. languagePack["xiaoshi"])

            -- 兵力值
            local totalSoldierNum = 0
            for k,v in pairs(armyData.getAllArmyInCity(temp_id)) do 
                totalSoldierNum = totalSoldierNum + armyData.getTeamHp(v)
            end
            label_soldier_num:setText(totalSoldierNum)

            local panel_army = uiUtil.getConvertChildByName(widget,"panel_army")
            local armyList = uiUtil.getConvertChildByName(panel_army,"armyList")
            armyListCityShare.set_city_id(armyList, temp_id)
            armyListCityShare.set_army_touch_state(armyList,temp_id,true)
        end
    end
    return cell
end

function create()
	if m_pMainLayer then return end
    if uiManager.isClearAll() then 
        return
    end


    getCityList()

 	local viewWidth = 1136
 	local viewHeight = 580
 	local mainWidget = Layout:create()
 	-- mainWidget:setBackGroundColorType(LAYOUT_COLOR_SOLID)
 	mainWidget:setTag(999)
	mainWidget:setTouchEnabled(true)
	mainWidget:setSize(CCSize(viewWidth, viewHeight))

	local titleName = panelPropInfo[uiIndexDefine.UI_CITYLIST_ARMY][2]

    m_backPanel = UIBackPanel.new()
	local all_widget = m_backPanel:create(mainWidget, remove_self, titleName, false, true)
	m_pMainLayer = TouchGroup:create()
	m_pMainLayer:addWidget(all_widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_CITYLIST_ARMY,999)
    uiManager.showConfigEffect(uiIndexDefine.UI_CITYLIST_ARMY, m_pMainLayer, nil, 999, {all_widget})


    local listPanel = Layout:create()
    listPanel:setSize(CCSize(viewWidth - 10, viewHeight))
    -- listPanel:setBackGroundColorType(LAYOUT_COLOR_SOLID)
    mainWidget:addChild(listPanel)
    listPanel:setPositionX(5)
    UIListViewSize.definedUIpanel(mainWidget,nil,listPanel,nil,{})

    city_list_tv = CCTableView:create(true,CCSizeMake(listPanel:getContentSize().width,listPanel:getContentSize().height))
    listPanel:addChild(city_list_tv)
    city_list_tv:setDirection(kCCScrollViewDirectionVertical)
    city_list_tv:setVerticalFillOrder(kCCTableViewFillTopDown)
    city_list_tv:ignoreAnchorPointForPosition(false)
    city_list_tv:setAnchorPoint(cc.p(0.5,0.5))
    city_list_tv:setPosition(cc.p(listPanel:getContentSize().width/2,listPanel:getContentSize().height/2))
   
    city_list_tv:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    city_list_tv:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    city_list_tv:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    city_list_tv:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    --city_list_tv:reloadData()


    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, UICityListArmy.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, UICityListArmy.reloadData)

    -- UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.update, UICityListArmy.reloadData)
	
	reloadData()
end
