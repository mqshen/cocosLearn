module("BlackNameListManager", package.seeall)
-- 类名 设置  BlackNameListManager
-- json文件  heimingdan.json
--ID  UI_BLACK_NAME_LIST_MANAGER

local m_pMainLayer = nil

local cell_defautl_height,cell_defautl_width = 54,740
local list_data = nil

local selected_uid_list = nil
local last_offset_y = nil

local cache_name_list_data_from_server = nil -- {uid = uname}





function removeData()
    cache_name_list_data_from_server = nil
end

local function do_remove_self()
    if m_pMainLayer then 
        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        list_data = nil
        selected_uid_list = nil

        last_offset_y = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_BLACK_NAME_LIST_MANAGER)

        UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, BlackNameListManager.updateDBData)
    end
end
function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.UI_BLACK_NAME_LIST_MANAGER,m_pMainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
    if not m_pMainLayer then return false end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return false end

    if mainWidget:hitTest(cc.p(x,y)) then 
        return false 
    else
        remove_self()
        return true 
    end
end


local function checkBtnState()

end


local function isInSelectedList(uid)
	if not selected_uid_list then return false end

	for k,v in pairs(selected_uid_list) do 
		if uid == v then return true end
	end

	return false
end

local function addSelectedUser(uid)
	table.insert(selected_uid_list,uid)
	BlackNameListManager.refreshAllCell()
	checkBtnState()
end

local function rmSelectedUser(uid)
	for k,v in pairs(selected_uid_list) do 
		if v == uid then table.remove(selected_uid_list,k) end
	end
	BlackNameListManager.refreshAllCell()
	checkBtnState()
end


local function setCellWidget(indx,cellWidget)

	local label_name = uiUtil.getConvertChildByName(cellWidget,"label_name")
	local selector = uiUtil.getConvertChildByName(cellWidget,"selector")

    local vo = list_data[indx + 1]
	
    label_name:setText(vo.name)
	
    local uid = vo.userid

	if isInSelectedList(uid) then 
		selector:setSelectedState(true)
	else
		selector:setSelectedState(false)
	end

	selector:addEventListenerCheckBox(function(sender,eventType)
		if eventType == CHECKBOX_STATE_EVENT_SELECTED then 
			addSelectedUser(uid)
		else
			rmSelectedUser(uid)
		end
	end)

	local btn_name = uiUtil.getConvertChildByName(cellWidget,"btn_name")
	btn_name:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
            UIRoleForcesMain.create(uid)
		end
	end)
end

local function refreshCell(indx)

    if not tv_userList then return end
    
    local cell = tv_userList:cellAtIndex(indx)
    if not cell then return end
    
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(indx,cellWidget)
    end  
end

function refreshAllCell()
    if not list_data then return end
    for i = 1 ,#list_data do 
        refreshCell(i - 1)
    end
end





local function tableCellHightlight(table,cell)

    -- local idx = cell:getIdx()

    -- local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    -- local cellWidget = nil
    -- cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")

  

end
    
 

local function tableCellUnhightlight(table,cell)
    -- local idx = cell:getIdx()

    -- local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    -- local cellWidget = nil
    -- cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
end

local function tableCellTouched(table,cell)
    local idx = cell:getIdx()
    
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
end
local function cellSizeForTable(table,idx)
    return cell_defautl_height,cell_defautl_width
end

local function numberOfCellsInTableView()
    return #list_data
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
        cellLayer:addWidget(cellWidget)
        cellWidget:setPosition(cc.p(0,0))
        cellWidget:setTag(10)
	end
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(idx,cellWidget)
    end
    
    return cell
end





function reloadData()
	list_data = BlackNameListData.getBlackList()

	if not selected_uid_list then 
		selected_uid_list = {}
	end

	if tv_userList then 
		tv_userList:reloadData()
	end

	checkBtnState()

    local instance = m_pMainLayer:getWidgetByTag(999)
    if not instance then return end
    local label_null = uiUtil.getConvertChildByName(instance,"label_null")
    local btn_remove = uiUtil.getConvertChildByName(instance,"btn_remove")
    if #list_data > 0 then
        label_null:setVisible(false)
        btn_remove:setVisible(true)
        btn_remove:setTouchEnabled(true)
    else
        label_null:setVisible(true)
        btn_remove:setVisible(false)
        btn_remove:setTouchEnabled(false)
    end
end

function updateDBData()
    if not m_pMainLayer then return end
    reloadData()
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


    if tv_userList:getContentOffset().y < 0 then 
        img_drag_flag_down:setVisible(true)
    else
        img_drag_flag_down:setVisible(false)
    end

    if tv_userList:getContentOffset().y > -(#list_data * cell_defautl_height - panel_list:getSize().height) then 
        img_drag_flag_up:setVisible(true)
    else
        img_drag_flag_up:setVisible(false)
    end
end



function create()
    if m_pMainLayer then return end
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/heimingdan.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setTouchEnabled(true)
    mainWidget:setAnchorPoint(cc.p(0.5,0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))


    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    
    uiManager.add_panel_to_layer(m_pMainLayer,uiIndexDefine.UI_BLACK_NAME_LIST_MANAGER)



    -- 关闭
    local btn_close = uiUtil.getConvertChildByName(mainWidget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self()
        end
    end)


   	local panel_list = uiUtil.getConvertChildByName(mainWidget,"panel_list")
   	panel_list:setBackGroundColorType(LAYOUT_COLOR_NONE)
   	local panel_item = uiUtil.getConvertChildByName(panel_list,"panel_item")
   	panel_item:setBackGroundColorType(LAYOUT_COLOR_NONE)
   	panel_item:setVisible(false)
    local img_drag_flag_up = uiUtil.getConvertChildByName(mainWidget,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(mainWidget,"down_img")
    breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
    tv_userList = CCTableView:create(CCSizeMake(panel_list:getContentSize().width,panel_list:getContentSize().height))
 	panel_list:addChild(tv_userList)
 	tv_userList:setDirection(kCCScrollViewDirectionVertical)
 	tv_userList:setVerticalFillOrder(kCCTableViewFillTopDown)
	tv_userList:ignoreAnchorPointForPosition(false)
	tv_userList:setAnchorPoint(cc.p(0.5,0.5))
	tv_userList:setPosition(cc.p(panel_list:getContentSize().width/2,panel_list:getContentSize().height/2))
	tv_userList:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tv_userList:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tv_userList:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tv_userList:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    tv_userList:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
    tv_userList:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)
    tv_userList:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
    -- tv_userList:reloadData()

    reloadData()


    local btn_remove = uiUtil.getConvertChildByName(mainWidget,"btn_remove")
    btn_remove:setTouchEnabled(true)
    btn_remove:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		if not selected_uid_list or #selected_uid_list == 0 then 
    			-- TODOTK 可能要加个提示语
    			return 
    		end

            local uid = selected_uid_list[1]
            local strName = ""
            for k,v in pairs(list_data) do 
                if v.userid == uid then 
                    strName = v.name
                end
            end
            
            if #selected_uid_list > 1 then 
                strName = strName .. languagePack["list_and_so_on"]
            end
            
            alertLayer.create(errorTable[2027],{strName},function()
                BlackNameListData.delUserByIdList(selected_uid_list)
                remove_self()
            end)

    		
    	end
    end)

    uiManager.showConfigEffect(uiIndexDefine.UI_BLACK_NAME_LIST_MANAGER,m_pMainLayer)

    UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, BlackNameListManager.updateDBData)
end

