module("UITaxStatisticalInfo",package.seeall)
-- 税收统计信息
-- 类名 UITaxStatisticalInfo
-- json名 shuishoutongji.json
-- 配置ID UI_TAX_STATISTICAL_INFO


local m_pMainLayer = nil

local tv_cityList = nil
local cell_defautl_height = nil
local cell_defautl_width = nil


local list_data = nil
local function do_remove_self()
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UI_TAX_STATISTICAL_INFO)

		tv_cityList = nil
		cell_defautl_height = nil
		cell_defautl_width = nil
		list_data = nil
	end
end

function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.UI_TAX_STATISTICAL_INFO, m_pMainLayer, do_remove_self, 999)	
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



local function resetListData()
	list_data = {}
	local tmp_info = nil

	local selfCommonRes = politics.getSelfRes()

	tmp_info = {}
	tmp_info.name = languagePack['tax_source_type_building']
	tmp_info.tax_add = selfCommonRes.login_money_build_add
	table.insert(list_data,tmp_info)
	
	tmp_info = {}
	tmp_info.name = languagePack['tax_source_type_npc_city']
	tmp_info.tax_add = selfCommonRes.login_money_field_add 
	table.insert(list_data,tmp_info)
	
	
	
end

--[[
--
-- 目前NPC 城市 不会产出税收 只会增加NPC城区的税收比例 
local function resetListData()
	list_data = {}

	local tmp_list = nil
	local tmp_info = nil
	-- 主城
	tmp_list = userCityData.getEffectCityList(true, false, false,false,false,false)
	--主城的税收加成=初始税收+民居税收加成+仓库满级税收加成 
	for k,v in ipairs(tmp_list) do 
		tmp_info = {}
		tmp_info.wid = v
		tmp_info.name = landData.get_city_name_by_coordinate(v)
		tmp_info.type_name = cityTypeName[cityTypeDefine.zhucheng]
		tmp_info.tax_add = userCityData.getUserCityTax(v)
		table.insert(list_data,tmp_info)
	end
	-- 分城
	-- 分城税收加成=分城民居税收加成+分城仓库满级税收加成 
	tmp_list = userCityData.getEffectCityList(false, true, false,false,false,false)
	-- TODO 排序 税收高的排前边
	for k,v in ipairs(tmp_list) do 
		tmp_info = {}
		tmp_info.wid = v
		tmp_info.name = landData.get_city_name_by_coordinate(v)
		tmp_info.type_name =  cityTypeName[cityTypeDefine.fencheng]
		tmp_info.tax_add = userCityData.getUserCityTax(v)
		table.insert(list_data,tmp_info)
	end

	-- 守军城区
	-- 守军城区税收加成=该城池被玩家占领的城区税收加成之和 
	tmp_list = {}
	local temp_city_info = nil
	for k ,v in pairs(allTableData[dbTableDesList.world_city.name]) do
   		if (v.userid == userData.getUserId()) and landData.isNpcChengqu(v.wid)  then
			temp_city_info = Tb_cfg_world_city[v.wid]
			if not tmp_list[temp_city_info.belong_city] then
				tmp_list[temp_city_info.belong_city] = {}
				tmp_list[temp_city_info.belong_city].wid = temp_city_info.belong_city
				tmp_list[temp_city_info.belong_city].name = landData.get_city_name_by_coordinate(v.wid)
				tmp_list[temp_city_info.belong_city].type_name = " "
				tmp_list[temp_city_info.belong_city].tax_add = userCityData.getUserNpcCityPropTax(v.wid)
			else
				tmp_list[temp_city_info.belong_city].tax_add = tmp_list[temp_city_info.belong_city].tax_add + userCityData.getUserNpcCityPropTax(v.wid)
			end
			
			
   		end
   	end
	-- TODO 排序 税收高的排前边
	for k,v in pairs(tmp_list) do 
		table.insert(list_data,v)
	end
end
]]


local function reloadData()
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end
	
	resetListData()

    tv_cityList:reloadData()
end

local function tableCellTouched(table,cell)
    local idx = cell:getIdx()
    
	--[[
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    local btn_cell = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
	]]
   
end


local function cellSizeForTable(table,idx)
    return cell_defautl_height,cell_defautl_width
end



local function setCellWidget(indx,cellWidget)
	local data = list_data[indx + 1]
	if not data then return end

	local label_name = uiUtil.getConvertChildByName(cellWidget,"label_name")
	local label_type = uiUtil.getConvertChildByName(cellWidget,"label_type")
	local label_value = uiUtil.getConvertChildByName(cellWidget,"label_value")
	label_type:setVisible(false)

	label_name:setText(data.name)
	label_value:setText("+" ..  data.tax_add)

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


local function numberOfCellsInTableView()
    return #list_data
end


local function tableCellHightlight(table,cell)
	
	--[[
    local idx = cell:getIdx()

    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil
    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
	]]

end
    
 

local function tableCellUnhightlight(table,cell)
    --[[
	local idx = cell:getIdx()

    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    local cellWidget = nil

    cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
	]]
end


local function tableviewScroll(view)
	if not m_pMainLayer then return end
	local instance = m_pMainLayer:getWidgetByTag(999)
    local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
    local img_drag_flag_up = uiUtil.getConvertChildByName(instance,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(instance,"down_img")

    
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


local function init()
	if not m_pMainLayer then return end

	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end

	local btn_ok = uiUtil.getConvertChildByName(widget,"btn_ok")
	btn_ok:setTouchEnabled(true)
	btn_ok:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)
	
	--------------- 初始化列表
	if tv_cityList then return end

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
	breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)


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
	tv_cityList:setTouchEnabled(false)
end

function create()
	if m_pMainLayer then return end
	
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/shuishoutongji.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_TAX_STATISTICAL_INFO)
	
	init()
	reloadData()

	uiManager.showConfigEffect(uiIndexDefine.UI_TAX_STATISTICAL_INFO,m_pMainLayer)

end
