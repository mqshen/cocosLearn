local city_frame_layer = nil
local op_btn_list = nil
local touch_screen_x, touch_screen_y = nil, nil
local touch_map_x, touch_map_y = nil, nil
local groundEvent_handler = nil --地表事件计时器

--local is_cz_npc_city = nil 	--是否出征NPC城市

local give_up_type = nil	--1 放弃领地 2 建造分城或要塞 3 拆除分城或要塞

local btn_pos_list = nil

local TAG_OPTION_UI = 999
local TAG_DETAIL_UI = 997

local UIUtil = require("game/utils/ui_util")
local is_entering_city = nil
local is_remving = nil

local m_strOwnerName = nil


--  用于确保可操作按钮在屏幕内的 屏幕像素位移
local m_f_minOffsetOpScreenX = nil 
local m_f_minOffsetOpScreenY = nil

local m_f_uiShowPosX = nil
local m_f_uiShowPosY = nil

local landDetailInfo = require("game/map/land_detail_info")
-- 记录山寨事件的信息
local m_valleyInfo = nil



local OP_TYPE_ENTER_CITY = 1        -- 进入主城
local OP_TYPE_BUILD_CITY = 2        -- 筑城
local OP_TYPE_EXPEDITION = 3        -- 出征
local OP_TYPE_RE_EXPEDITION = 4     -- 扫荡
local OP_TYPE_MOVE_DEFEND = 5       -- 驻守
local OP_TYPE_MOVE_REDEPLOY = 6     -- 调动
local OP_TYPE_MOVE_FARM = 7         -- 屯田
local OP_TYPE_MARK = 8              -- 标记
local OP_TYPE_DEMARK = 9            -- 取消标记
local OP_TYPE_DEGIVEUP = 10         -- 取消放弃
local OP_TYPE_GIVEUP = 11           -- 放弃
local OP_TYPE_MOVE_TRAINING = 12         -- 练兵



local function getMapCoordinateScreenPos(coorX,coorY,angle)
    if not angle then angle = map.getAngel() end
    local winSize = config.getWinSize()

    -- 屏幕中心点坐标
    local screenX_center = winSize.width/2
    local screenY_center = winSize.height/2
    
    -- 当前屏幕中心的 coordinate
    local center_coorX, center_coorY = map.touchInMap(winSize.width/2, winSize.height/2)
    local locationX, locationY = userData.getLocation()
    local locationXPos, locationYPos = userData.getLocationPos()
    

    local targetLos = {x= nil, y = nil}
    targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, coorX, coorY)

    local targetPoint = map.getInstance():convertToWorldSpace(cc.p(targetLos.x + 100 * map.getNorScale()   ,targetLos.y + 50* map.getNorScale()  ))
    -- local targetPoint = map.getInstance():convertToWorldSpace(cc.p(targetLos.x + 100 ,targetLos.y + 50))

    local screenXTarget,screenYTarget = config.countWorldSpace(targetPoint.x,targetPoint.y,angle)
    return screenXTarget,screenYTarget
end

local function finallyOffsetScreen(callback)

    if not city_frame_layer then return end

    local winSize = config.getWinSize()

    if m_f_minOffsetOpScreenX or m_f_minOffsetOpScreenY then 

        local cur_coordinate_screen_x,cur_coordinate_screen_y = getMapCoordinateScreenPos(touch_map_x,touch_map_y,map.getAngel())

        -- 当前屏幕中心的 coordinate
        local center_coorX, center_coorY = map.touchInMap(winSize.width/2, winSize.height/2)
        local center_screen_x,center_screen_y = getMapCoordinateScreenPos(center_coorX,center_coorY,map.getAngel())
        local center_offset_x = center_screen_x - winSize.width/2
        local center_screen_y = center_screen_y - winSize.height/2

        if not m_f_minOffsetOpScreenX then 
            m_f_minOffsetOpScreenX = 0
        end
        if not m_f_minOffsetOpScreenY then 
            m_f_minOffsetOpScreenY = 0
        end

        m_f_minOffsetOpScreenX = m_f_minOffsetOpScreenX - center_offset_x
        m_f_minOffsetOpScreenY = m_f_minOffsetOpScreenY - center_screen_y
    end
    if not m_f_minOffsetOpScreenX then 
        m_f_minOffsetOpScreenX = 0
    end
    if not m_f_minOffsetOpScreenY then 
        m_f_minOffsetOpScreenY = 0
    end

    if m_f_minOffsetOpScreenX == 0 and m_f_minOffsetOpScreenY == 0 then 
        callback()
        return 
    end

    

    -- 屏幕中心点坐标
    local screenX_center = winSize.width/2
    local screenY_center = winSize.height/2
    -- 当前屏幕中心的 coordinate
    local center_coorX, center_coorY = map.touchInMap(winSize.width/2, winSize.height/2)

    
    
    if m_f_minOffsetOpScreenX ~= 0 or m_f_minOffsetOpScreenY ~=0 then 
        
        local temp_offset_x = m_f_minOffsetOpScreenX
        local temp_offset_y = m_f_minOffsetOpScreenY
        m_f_minOffsetOpScreenY = nil
        m_f_minOffsetOpScreenX = nil

        local temp_widget = nil

        -- 操作按钮
        temp_widget = city_frame_layer:getWidgetByTag(999)
        if temp_widget then 
            temp_widget:setVisible(false)
        end

        -- 土地详情
        temp_widget = city_frame_layer:getWidgetByTag(998)
        if temp_widget then 
            temp_widget:setVisible(false)
        end

        -- 山脉信息
        temp_widget = city_frame_layer:getWidgetByTag(997)
        if temp_widget then 
            temp_widget:setVisible(false)
        end

        -- 地表事件
        temp_widget = city_frame_layer:getWidgetByTag(996)
        if temp_widget then 
            temp_widget:setVisible(false)
        end

        -- 城市信息
        temp_widget = city_frame_layer:getWidgetByTag(995)
        if temp_widget then 
            temp_widget:setVisible(false)
        end


        local function offsetUIPos()
            local sprite = mapData.getLoadedMapLayer(touch_map_x, touch_map_y)
            local tempPoint = sprite:convertToWorldSpace(cc.p(100,50))
            local pointX, pointY = config.countWorldSpace(tempPoint.x, tempPoint.y, map.getAngel())
            local show_pos_x = pointX
            local show_pos_y = pointY


            local temp_widget = nil

            -- 操作按钮
            temp_widget = city_frame_layer:getWidgetByTag(999)
            if temp_widget then 
                temp_widget:setVisible(true)
                temp_widget:setPosition(cc.p(show_pos_x + 50 * config.getgScale() ,show_pos_y - 10 * config.getgScale()))
            end

            -- 土地详情
            temp_widget = city_frame_layer:getWidgetByTag(998)
            if temp_widget then 
                temp_widget:setVisible(true)
                temp_widget:setPosition(cc.p(show_pos_x  ,show_pos_y))
            end

            -- 山脉信息
            temp_widget = city_frame_layer:getWidgetByTag(997)
            if temp_widget then 
                temp_widget:setVisible(true)
                temp_widget:setPosition(cc.p(show_pos_x  ,show_pos_y))
            end

            -- 地表事件
            temp_widget = city_frame_layer:getWidgetByTag(996)
            if temp_widget then 
                temp_widget:setVisible(true)

                local _tempPoint = sprite:convertToWorldSpace(cc.p(0,50))
                local _pointX, _pointY = config.countWorldSpace(_tempPoint.x, _tempPoint.y, map.getAngel())
                temp_widget:setPosition(cc.p(_pointX ,_pointY))
                
            end

            -- 城市信息
            temp_widget = city_frame_layer:getWidgetByTag(995)
            if temp_widget then 
                temp_widget:setVisible(true)
                temp_widget:setPosition(cc.p(show_pos_x  ,show_pos_y))
            end
            
        end
            
        
        mapController.setOpenMessage(false)
        mapController.setMapMessageDisposeState(false)

        mapController.locateCoordinate(center_coorX, center_coorY, function ( )
            mapController.setOpenMessage(true)
            mapController.setMapMessageDisposeState(true)

            offsetUIPos()

            mapController.selectGroundDisplay(touch_map_x,touch_map_y)
            if callback then 
                callback()
            end
        end,temp_offset_x,temp_offset_y)
    end

end


local function do_remove_self()
    if city_frame_layer then
        landDetailInfo.remove()
    	if timer then
    	    scheduler.remove(timer)
    	    timer = nil
    	end

        if groundEvent_handler then
            scheduler.remove(groundEvent_handler)
            groundEvent_handler = nil
        end
    	op_btn_list = nil
    	city_frame_layer:removeFromParentAndCleanup(true)
    	city_frame_layer = nil
    	touch_screen_x = nil
    	touch_screen_y = nil
    	touch_map_x = nil
        groundEvent_handler = nil
    	touch_map_y = nil
    	btn_pos_list = nil
    	give_up_type = nil
    	--is_cz_npc_city = nil
        is_remving = nil
        is_entering_city = nil
	    uiManager.remove_self_panel(uiIndexDefine.MAP_MESSAGE_UI)

        netObserver.removeObserver(VILLAGE_GET_INFO)

        m_strOwnerName = nil
        m_valleyInfo = nil

        m_f_minOffsetOpScreenX = nil
        m_f_minOffsetOpScreenY = nil
        m_f_uiShowPosX = nil
        m_f_uiShowPosY = nil
    end

end

local function hideEffect(callback,duration)
    if not city_frame_layer then return end
    if not duration then duration = 0.5 end
    local temp_detail_widget = city_frame_layer:getWidgetByTag(997)
    if not temp_detail_widget then 
        temp_detail_widget = city_frame_layer:getWidgetByTag(998)
    end
    local temp_op_widget = city_frame_layer:getWidgetByTag(999)
    local temp_ground_widget = city_frame_layer:getWidgetByTag(996)
    
    if temp_detail_widget then
        local finally = cc.CallFunc:create(function ( )
            temp_detail_widget:setVisible(false)
            if callback then callback() end

        end)
        temp_detail_widget:setVisible(true)
        local actionHide = CCFadeOut:create(duration)
        temp_detail_widget:runAction(animation.sequence({actionHide,finally}))
    end

    if temp_ground_widget then
        local finally = cc.CallFunc:create(function ( )
            temp_ground_widget:setVisible(false)
            if callback then callback() end
        end)
        temp_ground_widget:setVisible(true)
        local actionHide = CCFadeOut:create(duration)
        temp_ground_widget:runAction(animation.sequence({actionHide,finally}))
    end
    
    is_remving = true

    if not temp_op_widget then return end
    finally = cc.CallFunc:create(function ( )
        temp_op_widget:setVisible(false)
        
    end)
    temp_op_widget:setVisible(true)
    actionHide = CCFadeOut:create(duration)
    temp_op_widget:runAction(animation.sequence({actionHide,finally}))
end

local function remove_self()
    if is_remving  then return end
    if uiManager.isClearAll() then 
        do_remove_self()
        return
    end
    hideEffect(do_remove_self)
end

local function remove_immediately()
    if is_remving then 
        do_remove_self()
    end
end



local function dealwithTouchEvent(x,y)
    if not city_frame_layer then
	   return false
    end


    local coorX,coorY = map.touchInMap(x,y)
    if coorX == touch_map_x and coorY == touch_map_y then
        if armyListDetail then
            armyListDetail.set_land_pos(touch_map_x, touch_map_y)
        end
        return true
    end

    local hitTestDetailPanel = function(x,y)
        return landDetailInfo.dealwithTouchEvent(x,y)
    end

    local hitTestOpbtns = function(x,y)
        if not op_btn_list then return false end
        for k,v in pairs(op_btn_list) do 
            if v:hitTest(cc.p(x,y)) then return true end
        end
        return false
    end

    local hitTestGroundEvent = function ( x,y )
        local temp_ground_widget = city_frame_layer:getWidgetByTag(996)
        if not temp_ground_widget then return false end
        if temp_ground_widget:isVisible() and temp_ground_widget:hitTest(cc.p(x,y)) then return true end
        return false
    end

    if not hitTestDetailPanel(x,y) and not hitTestOpbtns(x,y) and not hitTestGroundEvent(x,y) then 
        remove_self()
    end
    
    return false
end

local function init_btn_pos()
    btn_pos_list = {}
    
end


-- -- 进入主城
local function enterCityDetailinfo(coorX, coorY)
    mapController.jump(coorX, coorY, true)
    mainOption.setSecondPanelVisible(false,false)
    mainScene.setBtnsVisible(false)
    remove_self()
    map.setAnchorPoint(0.5,0.5)
    map.setMlayerScale(map.getNorScale()*1.5)
    mainBuildScene.create(coorX, coorY)
    ObjectManager.setObjectLayerVisible(2)
    armyMark.setLineVisible(false)
    mapController.setResVisible(false)
    mapController.setCityShadow(true)
    mainOption.switchCityEffect(true,coorX * 10000 + coorY)
end



-- 跳转到城市中心点 然后进入主城
local function moveAndEnter(coorX, coorY)
    remove_self()
    mainOption.setSecondPanelVisible(false,false)
    mainScene.setBtnsVisible(false)
    ObjectManager.setObjectLayerVisible(2)
    armyMark.setLineVisible(false)

    local function finally()
        
        is_entering_city = false
        mapController.addSmokeAnimation()
        newGuideInfo.enter_next_guide()
        mainBuildScene.create(coorX, coorY)
    end
    
    is_entering_city = true
    mapController.setResVisible(false)
    mapController.setCityShadow(true)
    mapController.enterCity(coorX,coorY,finally)
end

local function common_cz_judge(armyOpType)
    local is_own_self = mapData.isSelfLand(touch_map_x, touch_map_y)
    if not is_own_self then
        local connect_state = mapData.getMapConnectState(touch_map_x, touch_map_y)
        if not connect_state then
        	tipsLayer.create(errorTable[1])
            -- mapController.addWarAvailablePos()
            if userData.isInNewBieProtection() then
                require("game/guide/shareGuide/picTipsManager")
                picTipsManager.create(2, mapController.addWarAvailablePos)
            end
        	return
        end
    end

    local guard_end_time = mapData.getGuard_end_timeData(touch_map_x, touch_map_y)
    if guard_end_time and guard_end_time > userData.getServerTime() then
        tipsLayer.create(errorTable[203])
        return
    end
    --当玩家攻击的无主或敌对目标处于免战，显示“目标处于免战状态，无法进行攻击”的提示 
-- 出征玩家自己的土地，不提示
    if landData.is_type_can_not_war(touch_map_x*10000+ touch_map_y) and userData.isNewBieTaskFinished() then
        tipsLayer.create(errorTable[203])
        return
    end
    
	local has_army = false
    for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
        local army_list = armyData.getAllArmyInCity(k)
        local army_nums = #army_list
        if army_nums > 0 then
            has_army = true
            break
        end
    end
    if not has_army then 
        tipsLayer.create(errorTable[119])
        return
    end


    local target_x = touch_map_x
    local target_y = touch_map_y

    local function finally()
        require("game/army/armyMove/armyMoveManager")
        armyMoveManager.enter_select(armyOpType, target_x, target_y)
    end

    remove_self()


    if armyOpType == armyOp.training and (not CCUserDefault:sharedUserDefault():getBoolForKey("map_clicked_army_training") ) then 
        require("game/guide/shareGuide/picTipsManager")
        picTipsManager.create(10,finally)
        CCUserDefault:sharedUserDefault():setBoolForKey("map_clicked_army_training",true)
    elseif armyOpType == armyOp.farm and (not CCUserDefault:sharedUserDefault():getBoolForKey("map_clicked_army_farm") ) then 
        require("game/guide/shareGuide/picTipsManager")
        picTipsManager.create(9,finally)
        CCUserDefault:sharedUserDefault():setBoolForKey("map_clicked_army_farm",true)
    elseif armyOpType == armyOp.chuzheng and (not CCUserDefault:sharedUserDefault():getBoolForKey("map_clicked_chuzheng_enemy") ) then 
        local relation = nil
        local buildingData = mapData.getBuildingData()

        if buildingData[target_x] and buildingData[target_x][target_y] and buildingData[target_x][target_y].relation then 
            relation = buildingData[target_x][target_y].relation
        end
        
        if relation and ( relation == mapAreaRelation.free_enemy or relation == mapAreaRelation.attach_enemy ) then
            require("game/guide/shareGuide/picTipsManager")
            picTipsManager.create(14,finally)
            CCUserDefault:sharedUserDefault():setBoolForKey("map_clicked_chuzheng_enemy",true)
        else
            finally()
        end
    else
        finally()
    end

    
end

local function czCallback(armyOpType)

    if userData.getUserGuardState() == userGuardState.guarding then 
        tipsLayer.create(errorTable[2025])
        return 
    end

    if armyOpType == armyOp.farm or armyOpType == armyOp.training then 
        local decreeCur,decreeMax = userData.getUserDecreeNum()
        if armyOpType == armyOp.farm and decreeCur < FARM_DECREE_DEDUCT  then
            tipsLayer.create(languagePack['decree_not_enough_tips'])
            return
        end

        if armyOpType == armyOp.training and decreeCur < TRAINING_DECREE_DEDUCT  then
            tipsLayer.create(languagePack['decree_not_enough_tips'])
            return
        end
    end
    
    local temp_city_info = Tb_cfg_world_city[touch_map_x*10000 + touch_map_y]
    if temp_city_info and temp_city_info.city_type == cityTypeDefine.npc_cheng then
        if userData.getUnion_id() == 0 then
            tipsLayer.create(errorTable[2])
        else
            common_cz_judge(armyOpType)
        end
    else
	   common_cz_judge(armyOpType)
    end
end

local function yjCallback()
    if userData.getUserGuardState() == userGuardState.guarding then 
        tipsLayer.create(errorTable[2025] )
        return 
    end


    local has_army = false
    for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
        local army_list = armyData.getAllArmyInCity(k)
        local army_nums = #army_list
        if army_nums > 0 then
            has_army = true
            break
        end
    end
    if not has_army then 
        tipsLayer.create(errorTable[119])
        return
    end

    
    local target_x = touch_map_x
    local target_y = touch_map_y
    local function finally()
        require("game/army/armyMove/armyMoveManager")
        armyMoveManager.enter_select(armyOp.yuanjun, target_x, target_y)
    end

    remove_self()

    if (not CCUserDefault:sharedUserDefault():getBoolForKey("map_clicked_army_yuanjun") ) then 
        require("game/guide/shareGuide/picTipsManager")
        picTipsManager.create(4,finally)
        CCUserDefault:sharedUserDefault():setBoolForKey("map_clicked_army_yuanjun",true)
    else
        finally()
    end
    
    
end

local function zzCallback()
    require("game/army/armyMove/armyMoveManager")
    armyMoveManager.enter_select(armyOp.zhuzha, touch_map_x, touch_map_y)
    remove_self()
end

local function xjCallback()
    -- if userData.getUserGuardState() == userGuardState.guarding then 
    --     tipsLayer.create(errorTable[2025] )
    --     return 
    -- end
    require("game/createCity/opCreateCity")
    opCreateCity.create(touch_map_x, touch_map_y)
    remove_self()
end

local function deal_with_giveup_lingdi()
    politics.requestDeleteLingdi(touch_map_x*10000 + touch_map_y)
    remove_self()
end

local function qxCallback()
    local protect_end_time = mapData.getProtect_end_timeData(touch_map_x, touch_map_y)
    if userCityData.getLandExtendedState(touch_map_x*10000 + touch_map_y) then
	   tipsLayer.create(errorTable[107])
    elseif protect_end_time and protect_end_time > userData.getServerTime() then
        -- 免战期不能放弃
        if landData.get_land_type(touch_map_x * 10000 + touch_map_y) == cityTypeDefine.npc_yaosai then 
            tipsLayer.create(errorTable[2004])
        else
            tipsLayer.create(errorTable[217])
        end
    else
        if landData.get_land_type(touch_map_x * 10000 + touch_map_y) == cityTypeDefine.npc_yaosai then 
            -- 兵营
            if Tb_cfg_world_city[touch_map_x*10000+touch_map_y].param >=NPC_FORT_TYPE_RECRUIT[1] and
                Tb_cfg_world_city[touch_map_x*10000+touch_map_y].param <=NPC_FORT_TYPE_RECRUIT[2] then
                alertLayer.create(errorTable[2006], {touch_map_x, touch_map_y}, deal_with_giveup_lingdi)
            -- 要塞
            else
                alertLayer.create(errorTable[2005], {touch_map_x, touch_map_y}, deal_with_giveup_lingdi)
            end
            
        else
            alertLayer.create(errorTable[3], {touch_map_x, touch_map_y}, deal_with_giveup_lingdi)
        end
    end
end

local function deal_with_cancel_giveup()
    if give_up_type == 1 then
        politics.requestCancelDeleteLingdi(touch_map_x * 10000 + touch_map_y)
    elseif give_up_type == 2 then
        politics.requestCancelBuildCity(touch_map_x * 10000 + touch_map_y)
    elseif give_up_type == 3 then
        politics.requestCancelDeleteCity(touch_map_x * 10000 + touch_map_y)
    end
    remove_self()
end


local function deal_with_mark_land()
    if userData.getUserMarkedLandCount() >= WORLD_MARK_NUM_MAX then 
        tipsLayer.create(languagePack["land_mark_fail_maxCountLimit"])
        return
    end
    Net.send(WORLD_MARK_CREATE,{touch_map_x*10000+touch_map_y})
    remove_self()
    tipsLayer.create(languagePack["land_mark_succeed_marked"])
end

local function deal_with_unmark_land()
    Net.send(WORLD_MARK_DELETE,{touch_map_x*10000+touch_map_y})
    remove_self()
    tipsLayer.create(languagePack["land_mark_succeed_unmarked"])
end
--1 放弃领地 2 建造分城或要塞 3 拆除分城或要塞
local function dealwithCancelClick(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        if give_up_type == 1 then
            deal_with_cancel_giveup()
        elseif give_up_type == 2 then
            alertLayer.create(errorTable[5], {}, deal_with_cancel_giveup)
        elseif give_up_type == 3 then
            deal_with_cancel_giveup()
        end
    end
end

local function dealwithOpBtnTouched(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
    	local select_index = tonumber(string.sub(sender:getName(),5))
    	if select_index == OP_TYPE_EXPEDITION then
    	    czCallback(armyOp.chuzheng)
        elseif select_index == OP_TYPE_RE_EXPEDITION then
            --免战期不能扫荡
            local protect_end_time = mapData.getProtect_end_timeData(touch_map_x, touch_map_y)
            if protect_end_time and protect_end_time > userData.getServerTime() and userData.isNewBieTaskFinished() then
                tipsLayer.create(errorTable[218])
                return
            end
            czCallback(armyOp.rake)
        elseif select_index == OP_TYPE_MOVE_FARM then
            czCallback(armyOp.farm)
        elseif select_index == OP_TYPE_MOVE_TRAINING then
            czCallback(armyOp.training)
    	elseif select_index == OP_TYPE_MOVE_DEFEND then
    	    yjCallback()
    	elseif select_index == OP_TYPE_MOVE_REDEPLOY  then
    	    zzCallback()
    	elseif select_index == OP_TYPE_ENTER_CITY then
            newGuideInfo.enter_next_guide()
            local temp_building_info = mapData.getBuildingData()
            local is_exist_in_view_data = false
            if temp_building_info and temp_building_info[touch_map_x] and temp_building_info[touch_map_x][touch_map_y] then
                is_exist_in_view_data = true
            end
            if is_exist_in_view_data and temp_building_info[touch_map_x][touch_map_y].belong_city and temp_building_info[touch_map_x][touch_map_y].belong_city ~= 0 then
                local target_x = math.floor(temp_building_info[touch_map_x][touch_map_y].belong_city / 10000)
                local target_y = temp_building_info[touch_map_x][touch_map_y].belong_city % 10000
                moveAndEnter(target_x, target_y)
            else
                moveAndEnter(touch_map_x, touch_map_y)
            end
            -- enterCityDetailinfo(touch_map_x, touch_map_y)
    	elseif select_index == OP_TYPE_BUILD_CITY then
    	    xjCallback()
    	elseif select_index == OP_TYPE_GIVEUP then
    	    -- qxCallback()

            if (not CCUserDefault:sharedUserDefault():getBoolForKey("map_clicked_giveup") ) then 
                require("game/guide/shareGuide/picTipsManager")
                picTipsManager.create(13,qxCallback)
                CCUserDefault:sharedUserDefault():setBoolForKey("map_clicked_giveup",true)
            else
                qxCallback()
            end

        elseif select_index == OP_TYPE_DEGIVEUP then
            dealwithCancelClick(sender, eventType)
        elseif select_index == OP_TYPE_DEMARK then 
            -- 取消标记
            deal_with_unmark_land()
        elseif  select_index == OP_TYPE_MARK then 
            -- 标记土地
            deal_with_mark_land()
    	end
    end
end

local function judgeBuildingOp(city_type,relation_info)
    local temp_chuzheng = false
    local temp_yuanjun = false
    local temp_zhuzha = false
    local cityInfo = landData.get_world_city_info(10000*touch_map_x+touch_map_y)
    --自己的要塞或者npc要塞或者军营才可以驻扎
    if relation_info == mapAreaRelation.own_self and (city_type == cityTypeDefine.yaosai or city_type == cityTypeDefine.npc_yaosai)
        and (cityInfo.state == cityState.normal or cityInfo.state == cityState.removing) then
	   temp_zhuzha = true
    end

    --自己，盟友，下属才可以援军
    if relation_info == mapAreaRelation.own_self or relation_info == mapAreaRelation.free_ally or relation_info == mapAreaRelation.free_underling then
	   temp_yuanjun = true
    end

    if isOwnLeague(city_type) then
    	--地图建筑（归属权归同盟）
    	if relation_info == mapAreaRelation.all_free or relation_info == mapAreaRelation.free_enemy or relation_info == mapAreaRelation.attach_enemy or relation_info == mapAreaRelation.attach_free then
    	    temp_chuzheng = true
    	end
    elseif isOwnPerson(city_type) then
    	--领地/个人建筑（归属权归个人）
    	if relation_info == mapAreaRelation.all_free or relation_info == mapAreaRelation.free_enemy or relation_info == mapAreaRelation.attach_enemy 
            or relation_info == mapAreaRelation.attach_free then
    	    temp_chuzheng = true
    	end
    	if (relation_info == mapAreaRelation.own_self or relation_info == mapAreaRelation.free_ally) and city_type == cityTypeDefine.lingdi then
    	    temp_chuzheng = true
    	end
    end
    return temp_chuzheng,temp_yuanjun,temp_zhuzha
end

local function set_give_up_type()

    local land_id = touch_map_x * 10000 + touch_map_y
    local temp_world_city_info = landData.get_world_city_info(land_id)
    if temp_world_city_info and temp_world_city_info.end_time ~= 0 and temp_world_city_info.state == cityState.removing and 
        (temp_world_city_info.city_type == cityTypeDefine.lingdi or ((temp_world_city_info.city_type == cityTypeDefine.player_chengqu or 
            temp_world_city_info.city_type == cityTypeDefine.npc_chengqu) and landData.own_land(land_id))
            ) then
        give_up_type = 1
        temp_end_time = temp_world_city_info.end_time
        all_time = FIELD_DEL_TIME
    end

    -- local temp_user_city_info = userCityData.getUserCityData(land_id)
    if temp_world_city_info then
        --现在分城或者要塞在建造中已经不能放弃
        -- if temp_world_city_info.state == cityState.building and 
        --     (temp_world_city_info.city_type == cityTypeDefine.fencheng or temp_world_city_info.city_type == cityTypeDefine.yaosai ) then
        --     give_up_type = 2
        --     temp_end_time = temp_world_city_info.end_time
        --     all_time = BRANCH_CITY_BUILD_TIME
        if temp_world_city_info.state == cityState.removing and 
            (temp_world_city_info.city_type == cityTypeDefine.fencheng or temp_world_city_info.city_type == cityTypeDefine.yaosai 
                or temp_world_city_info.city_type == cityTypeDefine.npc_yaosai) then
            give_up_type = 3
            temp_end_time = temp_world_city_info.end_time
            all_time = BRANCH_CITY_DEL_TIME
        end
    end
end

-- 是否是已经扩建的领地
local function isOwnExpandProper()
    local wid = touch_map_x*10000 + touch_map_y
    local worldCityInfo = allTableData[dbTableDesList.world_city.name][wid]
    if not worldCityInfo then return false end
    if worldCityInfo.belong_city == 0 then return false end
    local userCityInfo = userCityData.getUserCityData(worldCityInfo.belong_city)
    if not userCityInfo then return false end
    if userCityInfo.userid == userData.getUserId() then 
        return true
    end
    return false
end





local function isDurabilityInfoVisible()
    
    if landData.is_own_free(touch_map_x * 10000 + touch_map_y) then 
        --无主的
        --山
        local isMountain = mapData.getCityType(touch_map_x, touch_map_y)
        if isMountain then
            return false
        end
        --水
        local isWater = terrain.isWaterTerrain(touch_map_x, touch_map_y)
        if isWater then
            return false
        end
        return true
    else
        -- 有主的 

        -- 自己的土地
        local isSelfLand =  mapData.isSelfLand(touch_map_x , touch_map_y)
        if isSelfLand then return true end

        if landData.own_land(touch_map_x * 10000 + touch_map_y) then 
            return true
        end
        -- 同盟的
        local message = nil
        local relation = nil
        local buildingData = mapData.getBuildingData()
        if buildingData[touch_map_x] and buildingData[touch_map_x][touch_map_y] then
            message = buildingData[touch_map_x][touch_map_y]
        end

        if message then
            relation = mapData.getRelationship(message.userId,message.union_id,message.affilated_union_id)
        end
        if relation == mapAreaRelation.own_self then return true end
        if relation == mapAreaRelation.attach_same_higher then return true end
        if relation == mapAreaRelation.all_free and landData.is_type_npc_city(touch_map_x * 10000 + touch_map_y) then 
            -- 针对NPC城市
            return true
        end

        if relation == mapAreaRelation.free_ally and message.union_id and message.union_id == userData.getUnion_id() then
            return true
        end


        return false
    end
end

local function isOwnByUnion()
    local message = nil
    local buildingData = mapData.getBuildingData()
    if buildingData[touch_map_x] and buildingData[touch_map_x][touch_map_y] then
        message = buildingData[touch_map_x][touch_map_y]
    end

    if message then
        local relation = mapData.getRelationship(message.userId,message.union_id,message.affilated_union_id)
        if relation == mapAreaRelation.attach_higher_up or
            relation == mapAreaRelation.free_ally or 
            relation == mapAreaRelation.free_underling or  
            relation == mapAreaRelation.attach_same_higher then 
            return false 
        else
            return true 
        end
    else
        return true
    end
end


-- 是否是盟友的土地
local function detectUnionChuzheng()
    return isOwnByUnion()
end




local function getLandMarkedState()
    if userData.isLandMarked(touch_map_x * 10000 + touch_map_y) then 
        return OP_TYPE_DEMARK
    else
        return OP_TYPE_MARK
    end
end




local function getOpContent()
    local canOpList = {}

    --当是山寨的时候，只能扫荡
    local valleyData = mapData.getValleyData()
    if valleyData[touch_map_x*10000+touch_map_y] then
        table.insert(canOpList, OP_TYPE_RE_EXPEDITION)
        return canOpList
    end

    local message = nil
    local buildingData = mapData.getBuildingData()
    if buildingData[touch_map_x] and buildingData[touch_map_x][touch_map_y] then
	   message = buildingData[touch_map_x][touch_map_y]
    end
	local flag_tuntian = false
    local flag_saodang = false
    local flag_chuzheng = false

    if message and message.cityType == cityTypeDefine.player_chengqu then 
        -- 进入按钮
        -- 需要判断城区中心的归属  是自己的才能进入
        local temp_building_info = mapData.getBuildingData()
        local is_exist_in_view_data = false
        if temp_building_info and temp_building_info[touch_map_x] and temp_building_info[touch_map_x][touch_map_y] then
            is_exist_in_view_data = true
        end
        if is_exist_in_view_data and temp_building_info[touch_map_x][touch_map_y].belong_city and temp_building_info[touch_map_x][touch_map_y].belong_city ~= 0 then
            local target_x = math.floor(temp_building_info[touch_map_x][touch_map_y].belong_city / 10000)
            local target_y = temp_building_info[touch_map_x][touch_map_y].belong_city % 10000
            
            if temp_building_info[target_x] and temp_building_info[target_x][target_y] and
             temp_building_info[target_x][target_y].userId ~= 0 and 
             temp_building_info[target_x][target_y].userId == userData.getUserId() then 
                local worldCityInfo = landData.get_world_city_info(target_x * 10000 + target_y)
                if worldCityInfo and worldCityInfo.state == cityState.normal then 
                    table.insert(canOpList,OP_TYPE_ENTER_CITY)
                end
            end
        end

    end
    if message and message.relation and message.relation == mapAreaRelation.own_self then
        if message.cityType == cityTypeDefine.zhucheng or message.cityType == cityTypeDefine.fencheng or message.cityType == cityTypeDefine.yaosai 
           or message.cityType == cityTypeDefine.npc_yaosai then
            -- 进入按钮

            local worldCityInfo = landData.get_world_city_info(touch_map_x * 10000 + touch_map_y)
            if worldCityInfo and worldCityInfo.state == cityState.normal then 
                table.insert(canOpList,OP_TYPE_ENTER_CITY)
            end
        end
    end
    if message and message.relation then
        local temp_chuzheng,temp_yuanjun,temp_zhuzha = judgeBuildingOp(message.cityType, message.relation)
        local event = GroundEventData.getWorldEventByWid(touch_map_x*10000+touch_map_y )
        local newBieTask = event and not userData.isNewBieTaskFinished()
	    if (temp_chuzheng or newBieTask) and (not isOwnExpandProper() or newBieTask) and detectUnionChuzheng() then
            if mapData.isSelfLand(touch_map_x, touch_map_y) then 
                -- 屯田
                if userData.isNewBieTaskFinished() then
                    -- table.insert(canOpList,OP_TYPE_MOVE_FARM)
                    flag_tuntian = true
                end
                -- local protect_end_time = mapData.getProtect_end_timeData(touch_map_x, touch_map_y)
                -- if not protect_end_time or protect_end_time < userData.getServerTime() then
                    -- 扫荡
                    table.insert(canOpList,OP_TYPE_RE_EXPEDITION)
                    flag_saodang = true
                -- end
            else
                -- 出征
                table.insert(canOpList,OP_TYPE_EXPEDITION)
                flag_chuzheng = true
            end
	    end

        

    	if temp_yuanjun then
            table.insert(canOpList,OP_TYPE_MOVE_DEFEND)
    	end

    	if temp_zhuzha then
    	    table.insert(canOpList,OP_TYPE_MOVE_REDEPLOY)
    	end

        if flag_tuntian then 
            table.insert(canOpList,OP_TYPE_MOVE_FARM)
            table.insert(canOpList,OP_TYPE_MOVE_TRAINING)
        end
    	----0:无主的废墟， 1:玩家主城, 2：玩家领地, 3：玩家分城, 4:要塞,5:玩家城区, 6:码头,7:npc城区,8:npc城
    	if message.relation == mapAreaRelation.own_self then
            -- local protect_end_time = mapData.getProtect_end_timeData(touch_map_x, touch_map_y)
                
    	    if message.cityType == cityTypeDefine.zhucheng or message.cityType == cityTypeDefine.fencheng or message.cityType == cityTypeDefine.yaosai then
                -- 取消进入按钮
                -- table.insert(canOpList,OP_TYPE_ENTER_CITY)
    	    -- elseif message.cityType == cityTypeDefine.lingdi then
        		-- table.insert(canOpList,OP_TYPE_BUILD_CITY)
            elseif message.cityType == cityTypeDefine.player_chengqu or message.cityType == cityTypeDefine.lingdi or message.cityType == cityTypeDefine.npc_yaosai then
                local terInfo = landData.get_world_city_info(touch_map_x * 10000 + touch_map_y)
                if terInfo and terInfo.state == cityState.normal then
                    if message.cityType == cityTypeDefine.lingdi then
                        table.insert(canOpList,OP_TYPE_BUILD_CITY)
                    end
                    
                    

                    local user_city_info = userCityData.getUserCityData(touch_map_x*10000 + touch_map_y)
                    -- 增加判断是否已有扩建的领地
                    if not user_city_info and not isOwnExpandProper() then
                        table.insert(canOpList,OP_TYPE_GIVEUP)
                    end

                    if message.cityType == cityTypeDefine.player_chengqu and not landData.own_land(terInfo.belong_city)
                     then
                        table.insert(canOpList,OP_TYPE_GIVEUP)
                    end
                    if message.cityType == cityTypeDefine.npc_yaosai then 
                        table.insert(canOpList,OP_TYPE_GIVEUP)
                    end
                end
            elseif message.cityType == cityTypeDefine.npc_chengqu then
                table.insert(canOpList,OP_TYPE_GIVEUP)
            end
    	end
    else
        table.insert(canOpList,OP_TYPE_EXPEDITION)
    end
    set_give_up_type()
    if give_up_type ~= 0 then 
        table.insert(canOpList,OP_TYPE_DEGIVEUP)
    end

    table.insert(canOpList,getLandMarkedState())


    -- 过滤掉一下功能
    for k,v in pairs(canOpList) do 
        if v == OP_TYPE_MOVE_FARM then 
            if userData.isInNewBieProtection() and ( FUNC_OPEN_RENWON_NEED_FARM > userData.getRenownNums() ) then 
                table.remove(canOpList,k)
            end
        end
    end

    for k,v in pairs(canOpList) do 
        if v == OP_TYPE_MOVE_DEFEND then 
            if userData.isInNewBieProtection() and ( FUNC_OPEN_RENWON_NEED_RESIDE > userData.getRenownNums() ) then 
                table.remove(canOpList,k)
            end
        end
    end

    for k,v in pairs(canOpList) do 
        if v == OP_TYPE_MOVE_TRAINING then 
            if userData.isInNewBieProtection() and ( FUNC_OPEN_RENWON_NEED_TRAINING > userData.getRenownNums() ) then 
                table.remove(canOpList,k)
            end
        end
    end

    
    

    return canOpList
end

--各种附加条件
local function otherCondition( )
    -- 山寨
    local valleyData = mapData.getValleyData()
    if valleyData[touch_map_x*10000+touch_map_y] then
        return true
    end
    return false
end

-- （出征，援军，筑城，放弃/取消）等 按钮选项
local function createOptionUI(show_pos_x, show_pos_y)
    --山
    local isMountain = mapData.getCityType(touch_map_x, touch_map_y)
        if isMountain and not otherCondition( ) then
    	return
    end
    --水
    local isWater = terrain.isWaterTerrain(touch_map_x, touch_map_y)
        if isWater and not otherCondition( ) then
    	return
    end

    local canOpList = getOpContent()

    -- local can_op_nums = #canOpList
    -- if can_op_nums == 0 or can_op_nums > 6 then
    -- 	return
    -- end

    if not btn_pos_list then
	   init_btn_pos()
    end

    if not op_btn_list then
    	op_btn_list = {}
    end
	
    local temp_op_widget = GUIReader:shareReader():widgetFromJsonFile("test/landselected.json")
    temp_op_widget:setTag(999)
    temp_op_widget:setScale(config.getgScale())
    temp_op_widget:ignoreAnchorPointForPosition(false)
    temp_op_widget:setAnchorPoint(cc.p(0, 0.5))

    local temp_widget = city_frame_layer:getWidgetByTag(997)
    if not temp_detail_widget then 
        temp_detail_widget = city_frame_layer:getWidgetByTag(998)
    end

    temp_op_widget:setPosition(cc.p(show_pos_x  + 100 * config.getgScale() ,show_pos_y  ))
    

    local temp_btn = nil
    local temp_x, temp_y = 0, 0
    local panel_op = UIUtil.getConvertChildByName(temp_op_widget,"panel_op")
    panel_op:setBackGroundColorType(LAYOUT_COLOR_NONE)
    ------- 进入入口 根据 城池（主城|分城） 要塞  军营 适配不同的按钮资源
    temp_btn = UIUtil.getConvertChildByName(panel_op,"btn_" .. OP_TYPE_ENTER_CITY)
    local landType = landData.get_land_type(touch_map_x * 10000 + touch_map_y) 
    if landType then 
        if landType == cityTypeDefine.zhucheng or landType == cityTypeDefine.fencheng then 
            -- 城池
            temp_btn:loadTextureNormal(ResDefineUtil.ui_land_detail_op_btn_imgs[1], UI_TEX_TYPE_PLIST)
            temp_btn:loadTexturePressed(ResDefineUtil.ui_land_detail_op_btn_imgs[2], UI_TEX_TYPE_PLIST)
        elseif landType == cityTypeDefine.yaosai then 
            temp_btn:loadTextureNormal(ResDefineUtil.ui_land_detail_op_btn_imgs[3], UI_TEX_TYPE_PLIST)
            temp_btn:loadTexturePressed(ResDefineUtil.ui_land_detail_op_btn_imgs[4], UI_TEX_TYPE_PLIST)
        elseif landType == cityTypeDefine.npc_yaosai and Tb_cfg_world_city[touch_map_x*10000+touch_map_y] then 
            if Tb_cfg_world_city[touch_map_x*10000+touch_map_y].param >=NPC_FORT_TYPE_RECRUIT[1] and
                Tb_cfg_world_city[touch_map_x*10000+touch_map_y].param <=NPC_FORT_TYPE_RECRUIT[2] then
                -- npc军营
                temp_btn:loadTextureNormal(ResDefineUtil.ui_land_detail_op_btn_imgs[5], UI_TEX_TYPE_PLIST)
                temp_btn:loadTexturePressed(ResDefineUtil.ui_land_detail_op_btn_imgs[6], UI_TEX_TYPE_PLIST)
            else
                -- npc要塞
                temp_btn:loadTextureNormal(ResDefineUtil.ui_land_detail_op_btn_imgs[3], UI_TEX_TYPE_PLIST)
                temp_btn:loadTexturePressed(ResDefineUtil.ui_land_detail_op_btn_imgs[4], UI_TEX_TYPE_PLIST)
            end
        end
    end
    
    

    local panel_op = UIUtil.getConvertChildByName(temp_op_widget,"panel_op")
    for i=1,12 do
    	temp_btn = tolua.cast(panel_op:getChildByName("btn_" .. i), "Button")
    	temp_btn:setVisible(false)
    	temp_btn:setTouchEnabled(false)
    end


    for i, v in ipairs(canOpList) do
    	temp_btn = tolua.cast(panel_op:getChildByName("btn_" .. v), "Button")
    	

        if v == OP_TYPE_DEGIVEUP and give_up_type == 2 then
            temp_btn:loadTextureNormal(ResDefineUtil.quxiaojianzhu_weidianji, UI_TEX_TYPE_PLIST)
            temp_btn:loadTexturePressed(ResDefineUtil.quxiaojianzhu_dianji, UI_TEX_TYPE_PLIST)
        end

        --出征 或 扫荡 地表事件
        if v== OP_TYPE_EXPEDITION or v == OP_TYPE_RE_EXPEDITION then
            local event = GroundEventData.getWorldEventByWid(touch_map_x*10000+touch_map_y )
            if event then
                if event[1] == GROUND.FIELD_EVENT_THIEF then
                    tolua.cast(temp_btn:getChildByName("event_1"), "ImageView"):loadTexture("Remind_little_icon.png",UI_TEX_TYPE_PLIST)
                end
                tolua.cast(temp_btn:getChildByName("event_1"), "ImageView"):setVisible(true) 
            else
                tolua.cast(temp_btn:getChildByName("event_1"), "ImageView"):setVisible(false)   
            end
        end
    	temp_btn:setTouchEnabled(true)
    	temp_btn:setVisible(true)
    	temp_btn:addTouchEventListener(dealwithOpBtnTouched)
    	
    	table.insert(op_btn_list, temp_btn)
    end

    city_frame_layer:addWidget(temp_op_widget)

    temp_btn = tolua.cast(panel_op:getChildByName("btn_" .. OP_TYPE_MARK ), "Button")
    if temp_btn:isVisible() then 
        local label_marked_num = UIUtil.getConvertChildByName(temp_btn,"label_marked_num")
        -- local markedCount = userData.getUserMarkedLandCount()
        -- label_marked_num:setText( "（" .. markedCount.. "/" .. WORLD_MARK_NUM_MAX .. "）")
        -- if markedCount >= WORLD_MARK_NUM_MAX then 
        --     label_marked_num:setColor(ccc3(235,69,74))
        -- else
        --     label_marked_num:setColor(ccc3(255,255,255))
        -- end
        label_marked_num:setVisible(false)
    end


    ----------------[[ 调整下位置]]
    -- 城池（主城和分城）、要塞、军营（地块名称）/筑城 
    -- 出征/扫荡(己）/调动
    -- 驻守（己）/援军（友）
    -- 屯田
    -- 练兵


    -- 右边的 （ 进城 筑城按钮是固定的）
    local sort_indx_tab = {OP_TYPE_EXPEDITION,OP_TYPE_RE_EXPEDITION,OP_TYPE_MOVE_REDEPLOY,OP_TYPE_MOVE_DEFEND,OP_TYPE_MOVE_FARM,OP_TYPE_MOVE_TRAINING}
    local pos_y = 20
    local temp_btn = nil
    for i = 1,#sort_indx_tab do 
        temp_btn = UIUtil.getConvertChildByName(panel_op,"btn_" .. sort_indx_tab[i])
        if temp_btn:isVisible() then 
            temp_btn:setPositionY(pos_y)
            pos_y = pos_y - 58
        end
    end

    -- 下边的
    sort_indx_tab = {OP_TYPE_MARK,OP_TYPE_DEMARK,OP_TYPE_GIVEUP,OP_TYPE_DEGIVEUP}
    pos_y = -78

    for i = 1,#sort_indx_tab do 
        temp_btn = UIUtil.getConvertChildByName(panel_op,"btn_" .. sort_indx_tab[i])
        if temp_btn:isVisible() then 
            temp_btn:setPosition(cc.p(-103,pos_y))
            pos_y = pos_y - 50
        end
    end

end


local function checkViewBorderOffset()
    if not city_frame_layer then return end

    local winSize = config.getWinSize()

    local cur_coordinate_screen_x,cur_coordinate_screen_y = getMapCoordinateScreenPos(touch_map_x,touch_map_y,map.getAngel())

    


    local view_width_left = 0
    local view_width_right = 0
    local view_height_up = 0
    local view_height_down = 0

    local function changeViewSize(vl,vr,vu,vd)
        if vl and vl >view_width_left then 
            view_width_left = vl
        end
        if vr and vr >view_width_right then 
            view_width_right = vr
        end
        if vu and vu >view_height_up then 
            view_height_up = vu
        end
        if vd and vd >view_height_down then 
            view_height_down = vd
        end
        
    end
    local temp_widget = nil

    -- 操作按钮
    temp_widget = city_frame_layer:getWidgetByTag(999)
    if temp_widget then 
        changeViewSize(nil,200,#op_btn_list * 70 /2,#op_btn_list * 70 /2)
    end

    -- 土地详情
    temp_widget = city_frame_layer:getWidgetByTag(998)
    if temp_widget then 
        changeViewSize(370,nil,landDetailInfo.getViewSizeHeight()/2 + 50,landDetailInfo.getViewSizeHeight()/2 - 50)
    end

    -- 地表事件
    temp_widget = city_frame_layer:getWidgetByTag(996)
    if temp_widget then 
        changeViewSize(270,nil,130,130)
    end

    -- 山脉信息
    temp_widget = city_frame_layer:getWidgetByTag(997)
    if temp_widget then 
        changeViewSize(nil,nil,220,nil)
    end


    -- 城市介绍信息
    temp_widget = city_frame_layer:getWidgetByTag(995)
    if temp_widget then 
        changeViewSize(nil,nil,nil,250)
    end


    view_width_left = view_width_left * config.getgScale()
    view_width_right = view_width_right * config.getgScale()
    view_height_up = view_height_up * config.getgScale()
    view_height_down = view_height_down * config.getgScale()

    -- 暂时屏蔽上下左的检测
    view_width_left = 0
    view_height_down = 0
    view_height_up = 0

    local border_right = winSize.width 
    local border_left = 0
    local border_up =  winSize.height 
    local border_down = 0

    -- print(">>>winSize",winSize.width,winSize.height)
    -- print(">>viewSize ",view_width_left,view_width_right,view_height_down,view_height_up)
    -- print(">> cur_coordinate_screen ",cur_coordinate_screen_x,cur_coordinate_screen_y)
    if cur_coordinate_screen_x + view_width_right > border_right then 
        m_f_minOffsetOpScreenX = cur_coordinate_screen_x + view_width_right - border_right
    elseif cur_coordinate_screen_x - view_width_left < border_left then 
        m_f_minOffsetOpScreenX =  (cur_coordinate_screen_x - view_width_left ) - border_left 
    end

    if cur_coordinate_screen_y + view_height_up > border_up then 
        m_f_minOffsetOpScreenY = cur_coordinate_screen_y + view_height_up - border_up
    elseif cur_coordinate_screen_y - view_height_down< border_down then
        m_f_minOffsetOpScreenY = (cur_coordinate_screen_y - view_height_down ) - border_down 
    end
    
    -- print(">>>offset",m_f_minOffsetOpScreenX,m_f_minOffsetOpScreenY)
end

-- local function cz_guide_com( )
--     local connect_state = mapData.getMapConnectState(touch_map_x, touch_map_y) or mapData.getIsCanConnect(touch_map_x, touch_map_y)
--     if not connect_state then
--         return
--     end

--     local relation = mapData.getRelation(touch_map_x, touch_map_y)

--     -- config.dump(allTableData[dbTableDesList.task.name])
--     local task_id = nil
--     local is_completed = nil
--     for i, v in pairs(allTableData[dbTableDesList.task.name]) do
--         if 10102 == v.task_id then
--             task_id = true
--             if v.is_completed == 0 then
--                 is_completed = true
--             end
--         end
--     end

--     if not task_id or not is_completed then
--         return
--     end

--     if not mapData.getCityType( touch_map_x, touch_map_y) and not terrain.isWaterTerrain(touch_map_x, touch_map_y) and resourceData.resourceLevel(touch_map_x, touch_map_y) < 20 and
--     (not relation or mapAreaRelation.all_free == relation ) and CCUserDefault:sharedUserDefault():getStringForKey(userData.getUserId().."ID2001") ~= "" then
--         comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2003)
--     end
-- end

local function doShowEffect(duration)
    if not city_frame_layer then return end

    if not duration then duration = 0.1 end
    local temp_op_widget = city_frame_layer:getWidgetByTag(999)
    city_frame_layer:setVisible(true)

    local temp_detail_widget = city_frame_layer:getWidgetByTag(997)
    if not temp_detail_widget then 
        temp_detail_widget = city_frame_layer:getWidgetByTag(998)
    end

    if temp_detail_widget then
        temp_detail_widget:setVisible(true)
        local finally = cc.CallFunc:create(function ( )
            temp_detail_widget:setVisible(true)
            temp_detail_widget:setScale(1* config.getgScale())
            -- finallyOffsetScreen()
        end)
        local actionScale = CCScaleTo:create(duration,1 * config.getgScale())
        local actionShow = CCFadeIn:create(duration)
        local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)

        temp_detail_widget:setScale(0.8 * config.getgScale())
        
        temp_detail_widget:runAction(animation.sequence({scaleAndShow,finally}))
    end

    local temp_ground_widget = city_frame_layer:getWidgetByTag(996)
    if temp_ground_widget then
        local actionScale = CCScaleTo:create(duration,1 * config.getgScale())
        local actionShow = CCFadeIn:create(duration)
        local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)
        temp_ground_widget:setScale(0.8* config.getgScale())
        temp_ground_widget:setVisible(true)
        temp_ground_widget:runAction(scaleAndShow)
    end

    if not temp_op_widget then return end
    finally = cc.CallFunc:create(function ( )
        -- pass
        -- finallyOffsetScreen()
        -- cz_guide_com()
    end)
    local actionScale = CCScaleTo:create(duration,1 * config.getgScale())
    local actionShow = CCFadeIn:create(duration)
    local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)
    temp_op_widget:setScale(0.8* config.getgScale())
    temp_op_widget:setVisible(true)
    temp_op_widget:runAction(animation.sequence({scaleAndShow,finally}))
end

local function showEffect(duration)
    -- checkViewBorderOffset()
    -- finallyOffsetScreen(function()
    --     doShowEffect(duration)
    -- end)

    doShowEffect(duration)  
end
--针对需要向服务器请求的部分响应处理
local function set_belong_content(owner_name, owner_union_name, affilate_union_name,durability_cur,durability_max,army_recover_timestamp,durability_rate,occupiedInfo)
    if not city_frame_layer then return end
    landDetailInfo.setBelongInfo(owner_name, owner_union_name, affilate_union_name,durability_cur,durability_max,army_recover_timestamp,durability_rate,occupiedInfo)
    city_frame_layer:runAction(animation.sequence{cc.DelayTime:create(0.01),
            cc.CallFunc:create(function() 
                showEffect()
            end)
        }) 
end

-- 山寨等级 --> 守军强度 配置
local shanzhai_showLevel = {3,4,5,6,7}

-- 山寨事件
local function createValleyEventUI(packet )
    if packet == cjson.null then
        return
    end

    local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/dibiao_shijian.json")
    temp_widget:setTag(996)
    temp_widget:setScale(config.getgScale())
    temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(1, 0.5))

    local panel_defenderLv = UIUtil.getConvertChildByName(temp_widget,"panel_defenderLv")
    panel_defenderLv:setVisible(false)

    local end_time = packet[2]
    local left_count = packet[1]
    if m_valleyInfo then
        temp_widget:setPosition(cc.p(m_valleyInfo.x ,m_valleyInfo.y))
    end
    city_frame_layer:addWidget(temp_widget)

    local eventImage = tolua.cast(temp_widget:getChildByName("ImageView_548883"),"ImageView")
    local desLabel = tolua.cast(temp_widget:getChildByName("Panel_575017"),"Layout")
    local _richText = RichText:create()
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(desLabel:getSize().width, desLabel:getSize().height))
    desLabel:addChild(_richText)
    _richText:setPosition(cc.p(0,desLabel:getSize().height))
    _richText:setVerticalSpace(3)
    local re = nil 
    eventImage:loadTexture("sanzaidibiao_dibiaoshijian.png",UI_TEX_TYPE_PLIST)
    --战利品这三个字
    re = RichElementText:create(1, ccc3(248,198,53), 255, languagePack["zhanlipin"]..":",config.getFontName(), 18)
    _richText:pushBackElement(re)

    -- 战利品的说明
    if Tb_cfg_battle_drop[(m_valleyInfo.level+100)*100+1] then 
        for i, v in ipairs(Tb_cfg_battle_drop[(m_valleyInfo.level+100)*100+1].drops) do
            -- res_id = 
            if i ~= #Tb_cfg_battle_drop[(m_valleyInfo.level+100)*100+1].drops then
                re = RichElementText:create(1, ccc3(255,255,255), 255, clientConfigData.getDorpName(v[1]).."，",config.getFontName(), 18)
            else
                re = RichElementText:create(1, ccc3(255,255,255), 255, clientConfigData.getDorpName(v[1]).."\n",config.getFontName(), 18)
            end
            _richText:pushBackElement(re)
        end
    end

    -- 剩余这几个字
    re = RichElementText:create(1, ccc3(248,198,53), 255, languagePack["shengyu"]..":",config.getFontName(), 18)
    _richText:pushBackElement(re)

    -- 剩余次数
    re = RichElementText:create(1, ccc3(255,255,255), 255, left_count.."/"..Tb_cfg_village[m_valleyInfo.level].count,config.getFontName(), 18)
    _richText:pushBackElement(re)

    _richText:formatText()

    panel_defenderLv:setVisible(true)
    panel_defenderLv:setPositionY(_richText:getPositionY() - _richText:getRealHeight() - panel_defenderLv:getContentSize().height + 10)

    

    local level = 1
    if m_valleyInfo then 
        level = m_valleyInfo.level
    end
    local showLv = shanzhai_showLevel[level]
    local label_lv = UIUtil.getConvertChildByName(panel_defenderLv,"label_lv")
    local img_kulou = UIUtil.getConvertChildByName(panel_defenderLv,"img_kulou")
    label_lv:setText(languagePack['lv'] .. showLv )

    local armyCount = 1
    local cfgArmyCountInfo = Tb_cfg_army_count[level + 100]
    if cfgArmyCountInfo then 
        armyCount = cfgArmyCountInfo.count
    end

    local defender_army_count_txt = ""
    if armyCount > 1 then 
        defender_army_count_txt = " X" .. armyCount
    end
    if showLv >=  10 then 
        label_lv:setText(defender_army_count_txt)
        img_kulou:setVisible(true)
    else
        label_lv:setText(languagePack["lv"] .. showLv .. defender_army_count_txt)
        img_kulou:setVisible(false)
    end

    --背景
    local back_image = tolua.cast(temp_widget:getChildByName("ImageView_548880"),"ImageView")
    back_image:setSize(CCSize(back_image:getSize().width, back_image:getSize().height + panel_defenderLv:getSize().height - (desLabel:getSize().height  - _richText:getRealHeight())))

    local tempImage = tolua.cast(back_image:getChildByName("ImageView_548881"),"ImageView")
    local eventNameLabel = tolua.cast(tempImage:getChildByName("Label_548882"),"Label")
    eventNameLabel:setText(languagePack["shanzhai"].."Lv."..m_valleyInfo.level)

    local timeLabel = tolua.cast(temp_widget:getChildByName("Label_548886"),"Label")
    timeLabel:setText(commonFunc.format_time( end_time- userData.getServerTime(), true))
    if groundEvent_handler then
        scheduler.remove(groundEvent_handler)
        groundEvent_handler = nil
    end

    groundEvent_handler = scheduler.create(function ( )
        if end_time- userData.getServerTime() > 0 then
            timeLabel:setText(commonFunc.format_time( end_time- userData.getServerTime(), true))
        else
            if groundEvent_handler then
                scheduler.remove(groundEvent_handler)
                groundEvent_handler = nil
            end
            temp_widget:removeFromParentAndCleanup(true)
            temp_widget = nil
            mapController.removeAdditionWallNode(math.floor(m_valleyInfo.wid/10000),m_valleyInfo.wid%10000)
            mapData.setValleyDataNull(m_valleyInfo.wid)
            remove_self()
        end
    end, 1)
end

--地表事件
local function createGroundEventUI(show_pos_x,show_pos_y, event )
    local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/dibiao_shijian.json")
    temp_widget:setTag(996)
    temp_widget:setScale(config.getgScale())
    temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(1, 0.5))
    temp_widget:setPosition(cc.p(show_pos_x ,show_pos_y))
    city_frame_layer:addWidget(temp_widget)

    local panel_defenderLv = UIUtil.getConvertChildByName(temp_widget,"panel_defenderLv")
    panel_defenderLv:setVisible(false)

    local eventImage = tolua.cast(temp_widget:getChildByName("ImageView_548883"),"ImageView")
    local desLabel = tolua.cast(temp_widget:getChildByName("Panel_575017"),"Layout")
    local _richText = RichText:create()
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(desLabel:getSize().width, desLabel:getSize().height))
    desLabel:addChild(_richText)
    _richText:setPosition(cc.p(0,desLabel:getSize().height))

    local re = nil 

    if event[1] == GROUND.FIELD_EVENT_CARD then
        re = RichElementText:create(1, ccc3(255,255,255), 255, languagePack["ground_event_card"],config.getFontName(), 18)
        eventImage:loadTexture("kapai_dibiaoshijian.png",UI_TEX_TYPE_PLIST)
    elseif event[1] == GROUND.FIELD_EVENT_EXP then
        re = RichElementText:create(1, ccc3(255,255,255), 255, languagePack["ground_event_exp"],config.getFontName(), 18)
        eventImage:loadTexture("jingyanshu_dibiaoshijian.png",UI_TEX_TYPE_PLIST)
    elseif event[1] == GROUND.FIELD_EVENT_THIEF then
        re = RichElementText:create(1, ccc3(255,255,255), 255, languagePack["ground_event_thief"],config.getFontName(), 18)
        eventImage:loadTexture("niangshi_dibiaoshijian.png",UI_TEX_TYPE_PLIST)
    end
    _richText:pushBackElement(re)

    _richText:formatText()

    local back_image = tolua.cast(temp_widget:getChildByName("ImageView_548880"),"ImageView")
    back_image:setSize(CCSize(back_image:getSize().width, 10+back_image:getSize().height - (desLabel:getSize().height - _richText:getRealHeight())))

    local timeLabel = tolua.cast(temp_widget:getChildByName("Label_548886"),"Label")
    timeLabel:setText(commonFunc.format_time(event[4]+FIELD_EVENT_EXPIRATION_INTERVAL - userData.getServerTime(), true))
    if groundEvent_handler then
        scheduler.remove(groundEvent_handler)
        groundEvent_handler = nil
    end

    groundEvent_handler = scheduler.create(function ( )
        if event[4]+FIELD_EVENT_EXPIRATION_INTERVAL - userData.getServerTime() > 0 then
            timeLabel:setText(commonFunc.format_time(event[4]+FIELD_EVENT_EXPIRATION_INTERVAL - userData.getServerTime(), true))
        else
            if groundEvent_handler then
                scheduler.remove(groundEvent_handler)
                groundEvent_handler = nil
            end
            temp_widget:removeFromParentAndCleanup(true)
            temp_widget = nil
            remove_self()
        end
    end, 1)
end

local function createDetaiUI(show_pos_x,show_pos_y)
    landDetailInfo.create(touch_map_x,touch_map_y,city_frame_layer,show_pos_x,show_pos_y)
end



--isMulti 是不是多坐标关联
local function create(screen_x, screen_y, map_x, map_y, isMulti)    
    if is_entering_city then return end
    remove_immediately()

    if mainBuildScene.getThisCityid() then return end
    if city_frame_layer then
	   return
    end

    if not mapData.isInArea(map_x, map_y) then
	   return
    end

    local sprite = mapData.getLoadedMapLayer(map_x, map_y)
        if not sprite then
    	return
    end


    touch_map_x = map_x
    touch_map_y = map_y

    if not userData.isNewBieTaskFinished() then
        local tx,ty = math.floor(userData.getMainPos()/10000), userData.getMainPos()%10000
        if touch_map_x < tx -1 or touch_map_x > tx +1 or touch_map_y < ty -1 or touch_map_y > ty +1 then
            alertLayer.create(errorTable[303])
            return
        end
    end
    


    if isMulti then
        if Tb_cfg_world_join[touch_map_x * 10000 + touch_map_y] then
            touch_map_x = math.floor(Tb_cfg_world_join[touch_map_x * 10000 + touch_map_y].target_wid/10000)
            touch_map_y = Tb_cfg_world_join[touch_map_x * 10000 + touch_map_y].target_wid%10000
        end
    end
    
    
    -- 屯田CD 最短的部队
    local armyId = nil
    local lastDecreeEndTime = nil
    for i,v in pairs(allTableData[dbTableDesList.army.name]) do 
        if v.state == armyState.decreed and v.userid == userData.getUserId() and v.target_wid == ( touch_map_x*10000+touch_map_y ) then 
            if (not armyId) or (v.end_time < lastDecreeEndTime) then
                armyId = v.armyid
                lastDecreeEndTime = v.end_time
            end
        end
    end
    --[[
    if armyId then 
        armyListManager.dealWithSelectArmy(armyId)
    end
    --]]
    

    touch_screen_x = screen_x
    touch_screen_y = screen_y
    
    give_up_type = 0

    city_frame_layer = TouchGroup:create()
    local tempPoint = sprite:convertToWorldSpace(cc.p(100,50))
    local pointX, pointY = config.countWorldSpace(tempPoint.x, tempPoint.y, map.getAngel())
    local event = GroundEventData.getWorldEventByWid(touch_map_x*10000+touch_map_y )
    local valleyData= mapData.getValleyData()
    -- 地表事件
    if event then
        local _tempPoint = sprite:convertToWorldSpace(cc.p(0,50))
        local _pointX, _pointY = config.countWorldSpace(_tempPoint.x, _tempPoint.y, map.getAngel())
        createGroundEventUI(_pointX - 50 * config.getgScale(), _pointY, event)
    -- 山寨
    elseif valleyData[touch_map_x*10000+touch_map_y] then
        local _tempPoint = sprite:convertToWorldSpace(cc.p(0,50))
        local _pointX, _pointY = config.countWorldSpace(_tempPoint.x, _tempPoint.y, map.getAngel())
        _pointX = _pointX - 50 * config.getgScale()
        m_valleyInfo = {wid = touch_map_x*10000+touch_map_y, level = valleyData[touch_map_x*10000+touch_map_y], x=_pointX, y = _pointY}
        netObserver.addObserver(VILLAGE_GET_INFO,createValleyEventUI)
        Net.send(VILLAGE_GET_INFO,{touch_map_x*10000+touch_map_y})
        -- createValleyEventUI(_pointX, _pointY, valleyData[touch_map_x*10000+touch_map_y])
    else
        createDetaiUI(pointX, pointY)
        if not landDetailInfo.isInitedCompleted() then 
            city_frame_layer:setVisible(false)
        end
    end
    
    m_f_uiShowPosX = pointX
    m_f_uiShowPosY = pointY

    createOptionUI(pointX, pointY)
    uiManager.add_panel_to_layer(city_frame_layer, uiIndexDefine.MAP_MESSAGE_UI)
    city_frame_layer:setZOrder(-999)


    



    

    if city_frame_layer:isVisible() then
        showEffect()
    end


    


end

local function get_map_guide_pos_info(offset_index, is_show_sign)
    local main_city_pos = userData.getMainPos()
    local pos_x = math.floor(main_city_pos/10000)
    local pos_y = main_city_pos%10000
    local show_map_x = pos_x + guide_map_order[offset_index][1]
    local show_map_y = pos_y + guide_map_order[offset_index][2]
    local sprite = mapData.getLoadedMapLayer(pos_x, pos_y)

    local level_one_sprite_x, level_one_sprite_y = config.getMapSpritePos(sprite:getPositionX()+100, sprite:getPositionY()+50, 
                                                    pos_x, pos_y, show_map_x, show_map_y)
    local temp_world_point = sprite:getParent():convertToWorldSpace(cc.p(level_one_sprite_x, level_one_sprite_y))
    local result_point_x, result_point_y = config.countWorldSpace(temp_world_point.x, temp_world_point.y, map.getAngel())
   
   if is_show_sign then 
        --引导部分地块加上显示标示
        mapController.addTouchGround(show_map_x, show_map_y)
    end

    return ccp(result_point_x, result_point_y)
end

local function get_map_mask_area(temp_guide_id, is_show_sign)
    local main_city_pos = userData.getMainPos()
    local pos_x = math.floor(main_city_pos/10000)
    local pos_y = main_city_pos%10000
    local sprite = mapData.getLoadedMapLayer(pos_x, pos_y)

    if temp_guide_id == guide_id_list.CONST_GUIDE_1005 or temp_guide_id == guide_id_list.CONST_GUIDE_1032 
        or temp_guide_id == guide_id_list.CONST_GUIDE_1055 or temp_guide_id == guide_id_list.CONST_GUIDE_1082 then
        --local temp_pos, temp_show_size, temp_hit_size = CityName.getPosInfoByWid(main_city_pos)
        --return temp_pos, temp_show_size, temp_hit_size
        return get_map_guide_pos_info(9, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1014 then
        return get_map_guide_pos_info(1, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1041 then
        return get_map_guide_pos_info(2, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1047 then
        return get_map_guide_pos_info(3, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1066 then
        return get_map_guide_pos_info(4, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1072 then
        return get_map_guide_pos_info(2, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1096 then
        return get_map_guide_pos_info(6, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1101 then
        return get_map_guide_pos_info(7, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1105 then
        return get_map_guide_pos_info(8, is_show_sign), CCSizeMake(200, 100), CCSizeMake(200, 100)
    end
    
    --[[
    if temp_guide_id == guide_id_list.CONST_GUIDE_1005 or temp_guide_id == guide_id_list.CONST_GUIDE_207 then
        local temp_pos, temp_show_size, temp_hit_size = CityName.getPosInfoByWid(main_city_pos)
        return temp_pos, temp_show_size, temp_hit_size
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_57 then
        local level_one_x, level_one_y = mapData.getLevelOneLand(pos_x, pos_y, 1)
        local level_one_sprite_x, level_one_sprite_y = config.getMapSpritePos(sprite:getPositionX()+100, sprite:getPositionY()+50, 
                                                        pos_x, pos_y, level_one_x, level_one_y)
        local temp_world_point = sprite:getParent():convertToWorldSpace(cc.p(level_one_sprite_x, level_one_sprite_y))
        local result_point_x, result_point_y = config.countWorldSpace(temp_world_point.x, temp_world_point.y, map.getAngel())
        local temp_point = ccp(result_point_x, result_point_y)
        return temp_point, CCSizeMake(200, 100), CCSizeMake(100, 50)
    end
    --]]
end

local function get_guide_widget(temp_guide_id)
    if city_frame_layer then
        local temp_widget = city_frame_layer:getWidgetByTag(999)
        return temp_widget
    end

    return nil
end

local function getCurLandId()
    if not touch_map_x then return 0 end
    if not touch_map_y then return 0 end
    return touch_map_x*10000+ touch_map_y
end

local function disableTouchAndRemove()
    if not city_frame_layer then return end
    
    landDetailInfo.disableTouchAndRemove()

    

    local temp_op_widget = city_frame_layer:getWidgetByTag(999)
    
    if temp_op_widget then 
        local panel_op = UIUtil.getConvertChildByName(temp_op_widget,"panel_op")
        local temp_btn = nil
        for i=1,12 do
            temp_btn = tolua.cast(panel_op:getChildByName("btn_" .. i), "Button")
            temp_btn:setTouchEnabled(false)
        end
    end

    do_remove_self()
end

local function get_com_guide_widget(temp_guide_id)
    if not city_frame_layer then
        return nil
    end
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2003 then
        return  city_frame_layer:getWidgetByTag(TAG_OPTION_UI)
    end
    return nil
end

-- local function get_com_map_mask_area(temp_guide_id )
--     if com_guide_id_list.CONST_GUIDE_2002 == temp_guide_id then
--         local wid = mapController.getLevelOne()
--         local m,n = math.floor(wid/10000), wid%10000
--         layer = mapData.getLoadedMapLayer( m, n )
--         if layer then

--             -- local sprite = mapData.getLoadedMapLayer(pos_x, pos_y)
--             -- local level_one_sprite_x, level_one_sprite_y = config.getMapSpritePos(sprite:getPositionX()+100, sprite:getPositionY()+50, 
--                                                                                 -- pos_x, pos_y, m, n)
--             local temp_world_point = layer:getParent():convertToWorldSpace(cc.p(layer:getPositionX()+100, layer:getPositionY()+50))
--             local result_point_x, result_point_y = config.countWorldSpace(temp_world_point.x, temp_world_point.y, map.getAngel())
                               
--             return ccp(result_point_x, result_point_y), CCSizeMake(200, 100), CCSizeMake(200, 100)
--         end
--     end
--     return false
-- end

mapMessageUI = {
                    create = create,
                    remove_self = remove_self,
                    dealwithTouchEvent = dealwithTouchEvent,
                    set_belong_content = set_belong_content,
                    enterCityDetailinfo = enterCityDetailinfo,
                    get_guide_widget = get_guide_widget,
                    get_map_guide_pos_info = get_map_guide_pos_info,
                    get_map_mask_area = get_map_mask_area,
                    moveAndEnter = moveAndEnter,
                    getCurLandId = getCurLandId,
                    disableTouchAndRemove = disableTouchAndRemove,
                    get_com_guide_widget = get_com_guide_widget,
                    -- get_com_map_mask_area = get_com_map_mask_area,
}
