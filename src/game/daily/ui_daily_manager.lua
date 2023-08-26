module("UIDailyManager",package.seeall)
-- 日常管理
-- 类名 UIDailyManager
-- json名 huodong.json
-- 配置ID UI_DAILY_MANAGER


local uiDailyFirstPay = require("game/daily/ui_daily_first_pay")
local uiDailyLogin = require("game/daily/ui_daily_login")
local uiDailyDevelop = require("game/daily/ui_daily_develop")
local uiDailyForcesFunds = require("game/daily/ui_daily_forces_funds")

local cell_defautl_height,cell_defautl_width = nil,nil
local last_offset_y = nil
local state_is_scrolling = nil
local list_data = nil
local m_tbActivityList = nil

local m_pMainLayer = nil
local m_iSelectedIndx = nil




local m_bIsDailyFirstLoginLogic -- 是否走首日登陆的逻辑

local function do_remove_self()
	if m_pMainLayer then 
		uiDailyDevelop.remove()
		uiDailyLogin.remove()
		uiDailyFirstPay.remove()
		uiDailyForcesFunds.remove()

		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UI_DAILY_MANAGER)

		m_iSelectedIndx = nil

		m_tbActivityList = nil

		if m_fCallback then 
			m_fCallback()
			m_fCallback = nil
		end
		
		m_bIsDailyFirstLoginLogic = nil
	end
end



function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.UI_DAILY_MANAGER, m_pMainLayer, do_remove_self, 999)	
end


function dealwithTouchEvent(x,y)
	if not m_pMainLayer then return false end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return false end
	if widget:hitTest(cc.p(x,y)) then 
		return false
	else
		if not m_bIsDailyFirstLoginLogic then 
			remove_self()
		end
		return true
	end
end


function update_show_level(is_most_above)
	if not m_pMainLayer then return end

	if m_tbActivityList then 
		m_tbActivityList:setTouchEnabled(is_most_above)
	end

	if uiDailyLogin and uiDailyLogin.update_show_level then
		uiDailyLogin.update_show_level(is_most_above)
	end
end




local function getViewWidgetByIndx(indx)
	
	if not indx then return end
	
	local activityInfo = list_data[indx]

	local widget = nil
	if activityInfo.activity_type == DailyDataModel.ACTIVITY_TYPE_FIRST_PAY then
		widget = uiDailyFirstPay.getInstance()
	elseif activityInfo.activity_type == DailyDataModel.ACTIVITY_TYPE_DAILY_LOGIN then 
		widget = uiDailyLogin.getInstance()
	elseif activityInfo.activity_type == DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS then
		widget = uiDailyForcesFunds.getInstance()
	else
		widget = uiDailyDevelop.getInstance() 
	end
	
	if not m_pMainLayer then return widget end
	if not widget:getParent() then
		local mainWidget = m_pMainLayer:getWidgetByTag(999)
		local panel_detail = uiUtil.getConvertChildByName(mainWidget,"panel_detail")
		panel_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)
		panel_detail:addChild(widget)
	end
	
	return widget
end

-- 设置对应的 活动信息
local function reloadActivityDetailView()
	if not m_pMainLayer then return end
	if not m_iSelectedIndx then return end
	
	local activityInfo = list_data[m_iSelectedIndx]
	if activityInfo.activity_type == DailyDataModel.ACTIVITY_TYPE_FIRST_PAY then
		uiDailyFirstPay.reloadData(activityInfo)
	elseif activityInfo.activity_type == DailyDataModel.ACTIVITY_TYPE_DAILY_LOGIN then
		uiDailyLogin.reloadData(activityInfo)
	elseif activityInfo.activity_type == DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS then
		uiDailyForcesFunds.reloadData(activityInfo,false)
	else
		uiDailyDevelop.reloadData(activityInfo)
	end

end




-- 隐藏
local function hideSelectedView()
	if not m_pMainLayer then return end
	if not m_iSelectedIndx then return end
	

	getViewWidgetByIndx(m_iSelectedIndx):setPosition(cc.p(999999,999999))
	
end


-- 显示
local function showSelectedView()
	if not m_pMainLayer then return end
	if not m_iSelectedIndx then return end
	

	getViewWidgetByIndx(m_iSelectedIndx):setPosition(cc.p(0,0))

end

-- 选择活动
local function setViewByIndx(indx)
	if not m_pMainLayer then return end
	if not indx then return end

	if m_iSelectedIndx == indx then return end
	
	hideSelectedView()
	m_iSelectedIndx = indx 
	showSelectedView()
	
	-- 阅读
	local activityInfo = list_data[indx]
	DailyDataModel.readActivityInfo(activityInfo.activity_id)
	
	reloadActivityDetailView()
end



--刷新左边的活动列表
local function reloadActivityList()
	if not m_pMainLayer then return end
	
    list_data = DailyDataModel.getDailyActivityList()

	if m_tbActivityList then
        m_tbActivityList:reloadData()
    end
end

------------------------- 初始化 左侧活动列表  begin
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

    if m_tbActivityList:getContentOffset().y < 0 then 
        img_drag_flag_down:setVisible(true)
    else
        img_drag_flag_down:setVisible(false)
    end

    if m_tbActivityList:getContentOffset().y > -(#list_data * cell_defautl_height - panel_list:getSize().height) then 
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
	
	local activityInfo = list_data[indx + 1]
	
	local type_url = DailyDataModel.TYPE_RES_URL[activityInfo.activity_type]
	local img_type = uiUtil.getConvertChildByName(cellWidget,"img_type")
	img_type:loadTexture(type_url, UI_TEX_TYPE_PLIST)
	
	
	
	local img_red_circle = uiUtil.getConvertChildByName(cellWidget,"img_red_circle")
	img_red_circle:setVisible(DailyDataModel.checkActivityNotificationById(activityInfo.activity_id))
	
	local img_selected = uiUtil.getConvertChildByName(cellWidget,"img_selected")
	local img_unselected = uiUtil.getConvertChildByName(cellWidget,"img_unselected")
	img_unselected:setVisible(not (m_iSelectedIndx == (indx + 1)))
	img_selected:setVisible(m_iSelectedIndx == (indx + 1))
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


local function refreshCell(indx)

    if not m_tbActivityList then return end
    
    local cell = m_tbActivityList:cellAtIndex(indx)
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


end
    
 

local function tableCellUnhightlight(table,cell)
    local idx = cell:getIdx()

    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
   	
end


local function tableCellTouched(table,cell)
    local idx = cell:getIdx()
    
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")

	setViewByIndx(idx + 1)
	refreshAllCell()
end


local function initActivityListView()
	local widget = m_pMainLayer:getWidgetByTag(999)
	local panel_list = uiUtil.getConvertChildByName(widget,"panel_list")
	local panel_item = uiUtil.getConvertChildByName(panel_list,"panel_item")


    panel_list:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_item:setVisible(false)
    panel_item:setTouchEnabled(false)
    panel_item:setBackGroundColorType(LAYOUT_COLOR_NONE)
    local img_drag_flag_up = uiUtil.getConvertChildByName(widget,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(widget,"down_img")
    img_drag_flag_down:setVisible(false)
    img_drag_flag_up:setVisible(false)
    breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
    cell_defautl_height = panel_item:getContentSize().height
    cell_defautl_width = panel_item:getContentSize().width


	m_tbActivityList = CCTableView:create(CCSizeMake(panel_list:getContentSize().width,panel_list:getContentSize().height))
 	panel_list:addChild(m_tbActivityList)
 	m_tbActivityList:setDirection(kCCScrollViewDirectionVertical)
 	m_tbActivityList:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_tbActivityList:ignoreAnchorPointForPosition(false)
	m_tbActivityList:setAnchorPoint(cc.p(0.5,0.5))
	m_tbActivityList:setPosition(cc.p(panel_list:getContentSize().width/2,panel_list:getContentSize().height/2))
	m_tbActivityList:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    m_tbActivityList:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_tbActivityList:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_tbActivityList:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    m_tbActivityList:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
    m_tbActivityList:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)
    m_tbActivityList:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
end


------------------------- 初始化 左侧活动列表  end






local function init(activityType)
	initActivityListView()
	
	reloadActivityList()
	
	local indx = 1
	for k,v in ipairs(list_data) do 
		if v.activity_type == activityType then
			indx = k
		end
	end

	for k,v in ipairs(list_data) do 
		if DailyDataModel.checkActivityNotificationById(v.activity_id) then
			indx = k
			break
		end
	end


	setViewByIndx(indx)
	refreshAllCell()
end


function onDbdataPayInfoChannged(package)
	if not m_pMainLayer then return end
	
	local activityInfo = list_data[m_iSelectedIndx]
	local lst_selected_activity_type = nil
	if activityInfo then 
		lst_selected_activity_type = activityInfo.activity_type
	end

	hideSelectedView()

	DailyDataModel.orgnizeActivityList()
	reloadActivityList()

	

	m_iSelectedIndx = nil
	local tmp_indx = 1
	if lst_selected_activity_type then
		for k,v in pairs(list_data) do 
			if v.activity_type == lst_selected_activity_type then
				tmp_indx = k
				break
			end
		end
	end
	setViewByIndx(tmp_indx)
	
	refreshAllCell()
end


function create(activityType,callback, isInDailyFirstLoginLogic)
	if m_pMainLayer then return end
	
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/huodong.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_DAILY_MANAGER)
	

	local btn_close = uiUtil.getConvertChildByName(widget,"btn_close")
	btn_close:setVisible(true)
	btn_close:setTouchEnabled(true)
	btn_close:addTouchEventListener(function(sender,eventType) 
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)
	
	m_fCallback = callback

	m_bIsDailyFirstLoginLogic = isInDailyFirstLoginLogic

	init(activityType)

	uiManager.showConfigEffect(uiIndexDefine.UI_DAILY_MANAGER,m_pMainLayer,function()
		if m_bIsDailyFirstLoginLogic then
			if activityType == DailyDataModel.ACTIVITY_TYPE_DAILY_LOGIN then
				require("game/daily/ui_login_reward_detail")
            	UIDailyLoginRewardDetail.create(nil,function()
					uiDailyLogin.showEffectReceiveTodayReward()		
				end)
				m_bIsDailyFirstLoginLogic = false
			end
		end
	end)
	
	
end

