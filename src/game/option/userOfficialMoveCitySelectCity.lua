module("UserOfficialMoveCitySelectCity", package.seeall)
-- 迁城确认界面
-- 类名 ：  UserOfficialMoveCitySelectCity
-- json名：  xuanzefencheng.json
-- 配置ID:	UI_USER_OFFICIAL_MOVE_CITY_SELECT_CITY


local cell_defautl_height,cell_defautl_width = nil,nil
local m_pMainLayer = nil
local tv_cityList = nil
local last_offset_y = nil
local state_is_scrolling = nil
local list_data = nil
local m_iSelectedIndx = nil
local function do_remove_self()
	if m_pMainLayer then 

		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        last_offset_y = nil
        tv_cityList = nil
        state_is_scrolling = nil
        m_iSelectedIndx = nil
        list_data = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_SELECT_CITY)
	end
end


function remove_self(closeEffect)
	if closeEffect then 
		do_remove_self()
		return 
	end
	uiManager.hideConfigEffect(uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_SELECT_CITY, m_pMainLayer, do_remove_self, 999)
end

function dealwithTouchEvent(x,y)
    if not m_pMainLayer then return false end

    local widget = m_pMainLayer:getWidgetByTag(999)
    if not widget then return false end
    if widget:hitTest(cc.p(x,y)) then 
        return false
    else
        remove_self()
        return true
    end
end


local function checkBtnState()
	if not m_pMainLayer then return end

	local widget = m_pMainLayer:getWidgetByTag(999)
	local btn_ok = uiUtil.getConvertChildByName(widget,"btn_ok")

	if not m_iSelectedIndx then 
		btn_ok:setBright(false)
	else
		btn_ok:setBright(true)
	end
end


local function tableviewScroll(view)
	if not m_pMainLayer then return end
	local instance = m_pMainLayer:getWidgetByTag(999)
    local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
    local img_drag_flag_up = uiUtil.getConvertChildByName(instance,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(instance,"down_img")

    if not last_offset_y then 
        
        last_offset_y = panel_list:getContentSize().height
        last_offset_y = last_offset_y - view:getContainer():getContentSize().height 
    end
    if math.abs(view:getContainer():getPositionY() - last_offset_y) > 5 then 
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


local function numberOfCellsInTableView()
    return #list_data
end

local function cellSizeForTable(table,idx)
    return cell_defautl_height,cell_defautl_width
end



local function setCellWidget(indx,cellWidget)

	local img_selected = uiUtil.getConvertChildByName(cellWidget,"img_selected")
	img_selected:setVisible(indx == m_iSelectedIndx)

    local wid = list_data[indx + 1]
    local coor_x = math.floor(wid / 10000)
    local coor_y = wid % 10000
    local cityInfo = landData.get_world_city_info(wid)
    local b_isBuilding = false
    local b_isRemving = false


    local label_name = uiUtil.getConvertChildByName(cellWidget,"label_name")
    local label_coordinate = uiUtil.getConvertChildByName(cellWidget,"label_coordinate")


    if cityInfo and cityInfo.state == cityState.normal then 
        label_name:setColor(ccc3(255,228,182))
        label_coordinate:setColor(ccc3(255,228,182))
    else
        label_name:setColor(ccc3(125,125,125))
        label_coordinate:setColor(ccc3(125,125,125))
    end
    label_name:setText(cityInfo.name)
    label_coordinate:setText("(" .. coor_x .. "," .. coor_y .. ")")

end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    
    if cell == nil then
        cell = CCTableViewCell:new()
        local cellLayer = TouchGroup:create()
        cellLayer:setTag(1)
        cell:addChild(cellLayer)

        local instance = m_pMainLayer:getWidgetByTag(999)
        local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
        local panel_item = uiUtil.getConvertChildByName(panel_list,"panel_item")
        cellWidget = panel_item:clone()
        cellWidget:setVisible(true)
        -- cellWidget:setTouchEnabled(true)
        cellLayer:addWidget(cellWidget)
        -- cellWidget:setPosition(cc.p(cellWidget:getSize().width/2,cellWidget:getSize().height/2))
        cellWidget:setPosition(cc.p(0,0))
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


local function refreshCell(indx)

    if not tv_cityList then return end
    
    local cell = tv_cityList:cellAtIndex(indx)
    if not cell then return end
    
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(indx,cellWidget)
    end  
end

local function refreshAllCell()
    if not list_data then return end
    for i = 1 ,#list_data do 
        refreshCell(i - 1)
    end
end



local function tableCellHightlight(table,cell)

    local idx = cell:getIdx()

    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")

    local btn_bg = uiUtil.getConvertChildByName(cellWidget,"btn_bg")
    btn_bg:setBright(true)

end
    
 

local function tableCellUnhightlight(table,cell)
    local idx = cell:getIdx()

    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
   	local btn_bg = uiUtil.getConvertChildByName(cellWidget,"btn_bg")
    btn_bg:setBright(false)
end


local function tableCellTouched(table,cell)
    local idx = cell:getIdx()
    
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")

    local wid = list_data[idx + 1]
    local cityInfo = landData.get_world_city_info(wid)
    

    if cityInfo.state == cityState.building then 
        -- TODOTK 中文收集
        tipsLayer.create('建造中的城市不能作为迁城目标')
        return 
    end

    if cityInfo.state == cityState.removing then 
        -- TODOTK 中文收集
        tipsLayer.create('放弃中的城市不能作为迁城目标')
        return 
    end

    m_iSelectedIndx = idx

    refreshAllCell()

    checkBtnState()
end

local function initCityListTBView()
	if not m_pMainLayer then return end
	if tv_cityList then 
		tv_cityList:reloadData()
		return 
	end
	local widget = m_pMainLayer:getWidgetByTag(999)
	local panel_list = uiUtil.getConvertChildByName(widget,"panel_list")
	local panel_item = uiUtil.getConvertChildByName(panel_list,"panel_item")

	tv_cityList = CCTableView:create(CCSizeMake(panel_list:getContentSize().width,panel_list:getContentSize().height))
 	panel_list:addChild(tv_cityList)
 	tv_cityList:setDirection(kCCScrollViewDirectionVertical)
 	tv_cityList:setVerticalFillOrder(kCCTableViewFillTopDown)
	tv_cityList:ignoreAnchorPointForPosition(false)
	tv_cityList:setAnchorPoint(cc.p(0.5,0.5))
	tv_cityList:setPosition(cc.p(panel_list:getContentSize().width/2,panel_list:getContentSize().height/2))
	tv_cityList:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tv_cityList:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tv_cityList:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tv_cityList:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    tv_cityList:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
    tv_cityList:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)
    tv_cityList:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
    tv_cityList:reloadData()

end


function reloadData()
	list_data = userCityData.getEffectCityList(false, true, false,true,true,false)

	initCityListTBView()
	checkBtnState()
end

function create()
	if m_pMainLayer then return end

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/xuanzefencheng.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))


	local panel_list = uiUtil.getConvertChildByName(widget,"panel_list")
	panel_list:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local panel_item = uiUtil.getConvertChildByName(panel_list,"panel_item")
	panel_item:setVisible(false)
	panel_item:setTouchEnabled(false)
	local img_drag_flag_up = uiUtil.getConvertChildByName(widget,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(widget,"down_img")
    img_drag_flag_down:setVisible(false)
    img_drag_flag_up:setVisible(false)
	cell_defautl_height = panel_item:getContentSize().height
	cell_defautl_width = panel_item:getContentSize().width

	m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_SELECT_CITY)

    reloadData()
    

    local btn_ok = uiUtil.getConvertChildByName(widget,"btn_ok")
    btn_ok:setTouchEnabled(true)
    btn_ok:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_BEGAN then 
        	if not m_iSelectedIndx then 
        		--TODOTK 中文收集
        		tipsLayer.create("请选择目标城市")
        	else
                local target_wid = list_data[m_iSelectedIndx + 1]
                local target_wid_info = landData.get_world_city_info(target_wid)
                local target_name = target_wid_info.name
        		do_remove_self()
        		require("game/option/userOfficialMoveCityConfirm")
        		UserOfficialMoveCityConfirm.create(target_wid,target_name)
        	end
        end
    end)

	uiManager.showConfigEffect(uiIndexDefine.UI_USER_OFFICIAL_MOVE_CITY_SELECT_CITY,m_pMainLayer)
end