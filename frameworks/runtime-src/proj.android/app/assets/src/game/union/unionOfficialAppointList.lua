UnionOfficialAppointList = {}

local uiUtil = require("game/utils/ui_util")

local main_layer = nil
local list_tabel_view = nil
local list_data = nil
local selector_type = nil
local position_type = nil
local position_num = nil
function UnionOfficialAppointList.remove_self()
    if main_layer then 
        list_tabel_view = nil
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_UNION_APPOINT_LIST)
    end

    selector_type = nil
    position_type = nil
    position_num = nil
    list_data = nil
end


function UnionOfficialAppointList.dealwithTouchEvent(x,y)
    if not main_layer then return false end
    local widget = main_layer:getWidgetByTag(999)
    if not widget then return false end
    if widget:hitTest(cc.p(x,y)) then 
        return false
    else
        UnionOfficialAppointList.remove_self()
        return true
    end
end


function UnionOfficialAppointList.create(selectorType,positionType,positionNum)
    if main_layer then return end
    position_type = positionType
    position_num = positionNum
    selector_type = selectorType
    list_data = {}
    local widget = GUIReader:shareReader():widgetFromJsonFile("test/appointment_of_chief_q.json")
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

    main_layer = TouchGroup:create()
	main_layer:addWidget(widget)
	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_UNION_APPOINT_LIST)


    local btn_close = uiUtil.getConvertChildByName(widget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            UnionOfficialAppointList.remove_self()
        end
    end)

    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    
    item_width = 270
	item_height = 52

    local function cellSizeForTable()
		return item_height,item_width
	end
    
    local function numberOfCellsInTableView()
		return #list_data
	end
    
    local function tableCellTouched(table,cell)
        if selector_type == 1 then
            -- 禅让
            UnionOfficialData.requestUnionLeaderDemise(list_data[cell:getIdx()+1][1])
            UnionOfficialAppointList.remove_self()
        elseif selector_type == 2 then
            -- 任命
            UnionOfficialData.requestUnionLeaderAppointOfficial(
                list_data[cell:getIdx()+1][1],
                position_type,
                position_num
            )
            UnionOfficialAppointList.remove_self()
        else
            print("unknow what to do") 
        end
        
        
    end

    local function tableCellAtIndex(table, idx)
    	local cell = table:dequeueCell()
    	if nil == cell then
        	cell = CCTableViewCell:new()
        	local mlayer = TouchGroup:create()
        	mlayer:setTag(1)
        	cell:addChild(mlayer)
            
            local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/appointment_of_chief_q_cell.json")
	        tolua.cast(_pCell,"Layout")
	        mlayer:addWidget(_pCell)
	        _pCell:setTag(11)
    	end


    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_panel = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_panel then
                local btn_ok = uiUtil.getConvertChildByName(item_panel,"btn_ok")
                btn_ok:setTouchEnabled(false)
                
                local label_name = uiUtil.getConvertChildByName(item_panel,"label_name")
                label_name:setText(list_data[idx+1][2])
			end
    	end

    	return cell
	end

    
    list_tabel_view = CCTableView:create(true,CCSizeMake(list_panel:getSize().width,list_panel:getSize().height))
 	list_panel:addChild(list_tabel_view,4,4)
 	list_tabel_view:setDirection(kCCScrollViewDirectionVertical)
 	list_tabel_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	list_tabel_view:ignoreAnchorPointForPosition(false)
	list_tabel_view:setAnchorPoint(cc.p(0.5,0.5))
	list_tabel_view:setPosition(cc.p(list_panel:getSize().width/2,list_panel:getSize().height/2))
	list_tabel_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    list_tabel_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    list_tabel_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    list_tabel_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    list_tabel_view:reloadData()

    
    UnionOfficialData.requestUnionSimpleMemberList(selector_type)
end

function UnionOfficialAppointList.updateData(package)
    if not list_tabel_view then return end
    list_data = package
    list_tabel_view:reloadData()

    local widget = main_layer:getWidgetByTag(999)
    if not widget then return end
    local label_null = uiUtil.getConvertChildByName(widget,"label_null")
    if #list_data > 0 then 
        label_null:setVisible(false)
    else
        label_null:setVisible(true)
    end
end


