module("CityListOwnedAndMarked", package.seeall)


-- 城市列表以及 标记的土地列表

local instanceParentLayout = nil
local instance = nil

local state_is_showed = nil
local state_is_switching = nil
local state_is_scrolling = nil
local last_offset_y = nil

local tv_cityList = nil

local list_data = nil

local cell_defautl_height = 50
local cell_defautl_width = 241

function getShowState()
    return state_is_showed
end

function remove()
	if not instance then return end
    tv_cityList:removeFromParentAndCleanup(true)
    instance:removeFromParentAndCleanup(true)
    UIUpdateManager.remove_prop_update(dbTableDesList.world_mark.name, dataChangeType.add, CityListOwnedAndMarked.dbDataChange)
    UIUpdateManager.remove_prop_update(dbTableDesList.world_mark.name, dataChangeType.remove, CityListOwnedAndMarked.dbDataChange)
    UIUpdateManager.remove_prop_update(dbTableDesList.world_mark.name, dataChangeType.update, CityListOwnedAndMarked.dbDataChange)

    tv_cityList = nil
    instance = nil
    state_is_showed = nil
end

function checkTouchState(x,y)
    if not instance then return end
    if not instance:hitTest(cc.p(x,y)) then 
        CityListOwnedAndMarked.closeDirectlly()
    end
end


function checkNonforcedGuide2012CanActive()
    if state_is_showed then return false end
    return true
end
local isInNonforcedGuide = false
function setIsInNonforceGuide(flag)
    local lastState = isInNonforcedGuide
    isInNonforcedGuide = flag

    if isInNonforcedGuide then 
        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2013)
    else
        if comGuideInfo then 
            comGuideInfo.deal_with_guide_stop()
        end
    end

end

function getIsInNonforceGuide()
    return isInNonforcedGuide
end


local function tableCellTouched(table,cell)
    -- local idx = cell:getIdx()
    -- print(">>>>>>>>tableCellTouched ",idx)
end

local function cellSizeForTable(table,idx)
    return cell_defautl_height,cell_defautl_width
end


local function setCellWidget(indx,cellWidget)
    

    local btn_delete = uiUtil.getConvertChildByName(cellWidget,"btn_delete")
    local img_cityType = uiUtil.getConvertChildByName(cellWidget,"img_cityType")
    local label_name = uiUtil.getConvertChildByName(cellWidget,"label_name")
    local label_pos = uiUtil.getConvertChildByName(cellWidget,"label_pos")

    local cacheInfo = list_data[indx + 1]
    local wid = cacheInfo.data.wid
    local cityName = "unknow"
    if cacheInfo.flag_type == 1 then 
        btn_delete:setVisible(false)
        btn_delete:setTouchEnabled(false)
        local city_type = landData.get_land_type(wid)
        img_cityType:loadTexture(ResDefineUtil.city_list_army_img_city_type_url_c[city_type], UI_TEX_TYPE_PLIST)


        local cityInfo = landData.get_world_city_info(wid)
        if cityInfo then 
            if cityInfo.state == cityState.building then 
                
                if cityInfo and cityInfo.name ~= "" then 
                    cityName = cityInfo.name
                else
                    cityName = landData.get_city_name_by_coordinate(wid)
                end
            else
                cityName = landData.get_city_name_by_coordinate(wid)
            end
        else
            local buildingData =mapData.getBuildingData()
            local coor_x = math.floor(wid / 10000)
            local coor_y = wid % 10000
            if buildingData[coor_x] and buildingData[coor_x][coor_y] and buildingData[coor_x][coor_y].cityType and buildingData[coor_x][coor_y].cityName then
                cityName = buildingData[coor_x][coor_y].cityName
            end
        end
    else
        btn_delete:setVisible(true)
        btn_delete:setTouchEnabled(true)
        img_cityType:loadTexture(ResDefineUtil.ui_land_mark_flag_a, UI_TEX_TYPE_PLIST)


        cityName = cacheInfo.data.world_city_name
        if cityName == "" then 
            cityName = landData.get_city_name_by_coordinate(wid)
        end
    end

    label_name:setText(cityName)
    label_pos:setText("（" .. math.floor(wid/10000) .. "，" .. wid%10000 ..  "）")

    cellWidget:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_BEGAN then 
            state_is_scrolling = false
            return true
        elseif eventType == TOUCH_EVENT_ENDED then
            if state_is_scrolling then return end 

            SmallMiniMap.deleteNonforceGuide2012()
            
            CityListOwnedAndMarked.closeDirectlly(0)

            local pos_x = math.floor(wid/10000)
            local pos_y = wid%10000
            local m_content_list = {}
            require("game/army/armyListAssist")
            m_content_list = armyListAssist.get_list_in_pos(pos_x, pos_y)
            
            
            if #m_content_list == 0 then
                mapController.locateCoordinate(pos_x,pos_y)
            else
                mapController.setLocateScreenOffset(100 * config.getgScale(),0)
                mapController.locateCoordinate(pos_x,pos_y,function()
                    mapController.setLocateScreenOffset(0,0)
                end,100 * config.getgScale(),0)
            end

            

            state_is_scrolling = false
        end
    end)

    
    
    btn_delete:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		Net.send(WORLD_MARK_DELETE,{wid})
            tipsLayer.create(languagePack["land_mark_succeed_unmarked"])
    	end
    end)

    
    
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    
    if cell == nil then
        cell = CCTableViewCell:new()
        local cellLayer = TouchGroup:create()
        cellLayer:setTag(1)
        cell:addChild(cellLayer)

        local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
        local btn_item = uiUtil.getConvertChildByName(panel_list,"btn_item")
        cellWidget = btn_item:clone()
        cellWidget:setVisible(true)
        cellWidget:setTouchEnabled(true)
        cellLayer:addWidget(cellWidget)
        cellWidget:setPosition(cc.p(cellWidget:getSize().width/2,cellWidget:getSize().height/2))
        cellWidget:setTag(10)
        -- tolua.cast(cellWidget,"Layout")
	end
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(idx,cellWidget)
    end
    
    return cell
end



local function numberOfCellsInTableView()
    if state_is_showed then 
    	return #list_data
    else
    	return 0
    end
end


local function tableviewScroll(view)
    local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
    local img_drag_flag_up = uiUtil.getConvertChildByName(instance,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(instance,"down_img")

    if not last_offset_y then 
        
        last_offset_y = panel_list:getContentSize().height
        last_offset_y = last_offset_y - view:getContainer():getContentSize().height 
    end
    if math.abs(view:getContainer():getPositionY() - last_offset_y) > 1 then 
        state_is_scrolling = true
    end
    
    last_offset_y = view:getContainer():getPositionY()


    if tv_cityList:getContentOffset().y < 0 then 
        img_drag_flag_down:setVisible(true)
    else
        img_drag_flag_down:setVisible(false)
    end

    if tv_cityList:getContentOffset().y > -(#list_data * cell_defautl_height - panel_list:getSize().height) then 
        img_drag_flag_up:setVisible(true)
    else
        img_drag_flag_up:setVisible(false)
    end
end

local function createCityListTableView()
	if not instance then return end
	if tv_cityList then return end

	local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
    local up_img = uiUtil.getConvertChildByName(instance,"up_img")
    local down_img = uiUtil.getConvertChildByName(instance,"down_img")
    up_img:setVisible(false)
    down_img:setVisible(false)

    local btn_item = uiUtil.getConvertChildByName(panel_list,"btn_item")
    btn_item:setVisible(false)
    btn_item:setTouchEnabled(false)

    local img_drag_flag_up = uiUtil.getConvertChildByName(instance,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(instance,"down_img")
    breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
    tv_cityList = CCTableView:create(CCSizeMake(panel_list:getContentSize().width,panel_list:getContentSize().height))
 	panel_list:addChild(tv_cityList)
 	tv_cityList:setDirection(kCCScrollViewDirectionVertical)
 	tv_cityList:setVerticalFillOrder(kCCTableViewFillTopDown)
	tv_cityList:ignoreAnchorPointForPosition(false)
	tv_cityList:setAnchorPoint(cc.p(0.5,0.5))
	tv_cityList:setPosition(cc.p(panel_list:getContentSize().width/2,panel_list:getContentSize().height/2))
	-- tv_cityList:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tv_cityList:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tv_cityList:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tv_cityList:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    -- tv_cityList:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
    -- tv_cityList:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)
    tv_cityList:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
    tv_cityList:reloadData()
end


local function getMaxSizeHeight()
    local wordPos = instanceParentLayout:convertToWorldSpaceAR(cc.p(0,0))
    local maxHeight = (wordPos.y  - 100) / config.getgScale()
    
    if maxHeight <=0 then 
        maxHeight = 200
    end
    
    return maxHeight 
end

local function autoSizeHeight()

    if not instance then return end

    local size_w = 260
    
    local size_h = (#list_data * cell_defautl_height + 65)  
    local max_h = getMaxSizeHeight()
    if size_h > max_h then 
        size_h = max_h
    end
    -- local view_size_w = size_w * config.getgScale()
    -- local view_size_h = size_h * config.getgScale()
    local view_size_w = size_w 
    local view_size_h = size_h 
    -- instance:setContentSize(CCSizeMake(size_w,size_h))
    instance:setSize(CCSize(view_size_w ,view_size_h))
    instance:ignoreAnchorPointForPosition(false)
    instance:setAnchorPoint(cc.p(1,1))
    instance:setPosition(cc.p(instanceParentLayout:getContentSize().width,instanceParentLayout:getContentSize().height))
    local last_pos_y = instance:getContentSize().height
    
    local img_main_bg = uiUtil.getConvertChildByName(instance,"img_main_bg")
    local img_bottom = uiUtil.getConvertChildByName(instance,"img_bottom")
    local panel_head = uiUtil.getConvertChildByName(instance,"panel_head")
    local up_img = uiUtil.getConvertChildByName(instance,"up_img")
    local down_img = uiUtil.getConvertChildByName(instance,"down_img")
    local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")

    img_main_bg:setSize(CCSize(view_size_w, view_size_h))
    img_main_bg:setPositionY(last_pos_y)


    panel_head:ignoreAnchorPointForPosition(false)
    panel_head:setAnchorPoint(cc.p(0,1))
    panel_head:setPosition(cc.p(0,last_pos_y))

    last_pos_y = last_pos_y - panel_head:getSize().height - up_img:getSize().height/2

    up_img:setPosition(cc.p(138,last_pos_y))

    -- panel_list:setContentSize(CCSizeMake(240,view_size_h - panel_head:getContentSize().height - 20))
    panel_list:setSize(CCSize(240,view_size_h - panel_head:getContentSize().height - 15))
    panel_list:ignoreAnchorPointForPosition(false)
    panel_list:setAnchorPoint(cc.p(0.5,1))
    panel_list:setPositionY(view_size_h - panel_head:getSize().height )
    panel_list:setPositionX(138)

    -- tv_cityList:setContentSize(CCSizeMake(panel_list:getContentSize().width,panel_list:getContentSize().height))
    tv_cityList:setViewSize(CCSize(panel_list:getContentSize().width,panel_list:getContentSize().height))
    tv_cityList:ignoreAnchorPointForPosition(false)
    tv_cityList:setAnchorPoint(0.5,1)
    tv_cityList:setPosition(cc.p(panel_list:getContentSize().width/2,panel_list:getContentSize().height))
end


local function markedCityListSortRuler(markInfoA,markInfoB)
    if markInfoA.city_type ~= markInfoB.city_type then 
        if cityTypeSortTable[markInfoA.city_type] < cityTypeSortTable[markInfoB.city_type] then 
            return true
        else
            return false
        end
    else 
        return false
    end
end



local function reloadData()

	if not instance then return end
	if not tv_cityList then return end
    
    if not state_is_showed then return end

    local owned_city_list = userCityData.getEffectCityList(true, true, true,true,true,true)

    local marked_city_list = userData.getUserMarkedLandList()

    table.sort(marked_city_list,markedCityListSortRuler)
    

    list_data = {}

    for k,v in pairs(owned_city_list) do 
        local item = {}
        local dataInfo = {}
        dataInfo.wid = v
        item.flag_type = 1
        item.data = dataInfo
        table.insert(list_data,item)
    end

    for k,v in pairs(marked_city_list) do 
        local item = {}
        item.flag_type = 2
        item.data = v
        table.insert(list_data,item)
    end


    autoSizeHeight()

	tv_cityList:reloadData()
end




local function setCellEnable(indx,flag)
	if not tv_cityList then return end
    
    local cell = tv_cityList:cellAtIndex(indx)
    if not cell then return end
    
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        cellWidget:setTouchEnabled(flag)
        local btn_delete = uiUtil.getConvertChildByName(cellWidget,"btn_delete")
        btn_delete:setTouchEnabled(flag)
    end

end
local function setEnable(flag)
	if not instance then return end
	
	

	instanceParentLayout:setVisible(flag)
	instanceParentLayout:setTouchEnabled(flag)

	instance:setVisible(flag)
	instance:setTouchEnabled(flag)


	tv_cityList:setTouchEnabled(flag)

	state_is_showed = flag
	


	for i = 1 ,#list_data do 
        setCellEnable(i - 1,flag)
    end



end


local function doShowEffect(callback)
    if not instance then return end

    if uiManager.isClearAll() then
        if callback then callback() end
        return 
    end
    instance:setPosition(
        ccp(instanceParentLayout:getContentSize().width * 2,
            instanceParentLayout:getContentSize().height)
        )
    local action = animation.sequence(
        {
        CCMoveTo:create(0.3,ccp(instanceParentLayout:getContentSize().width,instanceParentLayout:getContentSize().height) ),
        cc.CallFunc:create(function()
            if callback then 
                callback()
            end
        end)
        }
    )
    instance:runAction(action)

end

local function showEffect()
    if state_is_switching then return end
    state_is_switching = true

	setEnable(true)
	reloadData()

    

    doShowEffect(function()
        state_is_switching = false
        SmallMiniMap.activeNonforcedGuide(com_guide_id_list.CONST_GUIDE_2013)
    end)
end


local function doHideEffect(callback,duration)
    if not instance then return end
    if not duration then duration = 0.3 end
    if uiManager.isClearAll() then 
        if callback then callback() end
    end
    local action = animation.sequence(
        {
            CCMoveTo:create(duration,ccp(instanceParentLayout:getContentSize().width * 2,instanceParentLayout:getContentSize().height) ),
            cc.CallFunc:create(function()
                if callback then 
                    callback()
                end
            end)
        }
    )
    instance:runAction(action)

end

local function hideEffect(duration)
    if state_is_switching then return end
	state_is_switching = true

    setIsInNonforceGuide(false)
    
    
    
    doHideEffect(function()
        setEnable(false)
        state_is_switching = false
        SmallMiniMap.deactiveNonforcedGuide(com_guide_id_list.CONST_GUIDE_2013)
    end)
end

function closeDirectlly(duration)
    if state_is_switching then return end
    if not state_is_showed then return end
    hideEffect(duration)
end
function switchShowState()
	if not instance then return end
	if state_is_switching then return end
	if state_is_showed then 
		hideEffect()
	else
		showEffect()
	end
end

function changeInCityState(isIncity)
    if not instance then return end
    if isIncity then 
        hideEffect()
    end
end




function dbDataChange()
    reloadData()
end


function getInstance()
    return instance
end

function create(parentContainer)
	if instance then return end

	state_is_showed = false
	state_is_switching = false


	parentContainer:setBackGroundColorType(LAYOUT_COLOR_NONE)

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/dingwei_01.json")
	parentContainer:addChild(widget)

    widget:ignoreAnchorPointForPosition(false)
    widget:setAnchorPoint(cc.p(1,1))
    widget:setPosition(cc.p(parentContainer:getContentSize().width,parentContainer:getContentSize().height))

	local panel_list = uiUtil.getConvertChildByName(widget,"panel_list")
	panel_list:setBackGroundColorType(LAYOUT_COLOR_NONE)


	instance = widget
	instanceParentLayout = parentContainer

	list_data = {}
	createCityListTableView()

	setEnable(false)



    UIUpdateManager.add_prop_update(dbTableDesList.world_mark.name, dataChangeType.add, CityListOwnedAndMarked.dbDataChange)
    UIUpdateManager.add_prop_update(dbTableDesList.world_mark.name, dataChangeType.remove, CityListOwnedAndMarked.dbDataChange)
    UIUpdateManager.add_prop_update(dbTableDesList.world_mark.name, dataChangeType.update, CityListOwnedAndMarked.dbDataChange)

end