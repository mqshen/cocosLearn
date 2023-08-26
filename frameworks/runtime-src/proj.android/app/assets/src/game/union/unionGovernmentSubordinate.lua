---同盟治所	下属

local UnionGovernmentSubordinate = {}

local uiUtil = require("game/utils/ui_util")

local union_id = nil

local listData = nil
local list_tabel_view = nil

local mainWidget = nil

function UnionGovernmentSubordinate.remove()
    if not mainWidget then return end
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    item_height = nil
    item_width = nil
    union_id = nil
    listData = {}
    list_tabel_view = nil
end



function UnionGovernmentSubordinate.create(mainPanel,pmainWidget,unionId)
    if mainWidget then return end
    listData = {}
    union_id = unionId

    local widget = GUIReader:shareReader():widgetFromJsonFile("test/alliance_government_subordinate_members.json")
    mainWidget = widget
    pmainWidget:addChild(mainWidget)


    local listNoneTips = uiUtil.getConvertChildByName(mainWidget,"Label_544350_0")
    local listTitlePanel = uiUtil.getConvertChildByName(mainWidget,"Panel_555068")
    listNoneTips:setVisible(false)
    listTitlePanel:setVisible(false)

    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    
    item_width = 1060
	item_height = 77
   

    local img_main_bg = uiUtil.getConvertChildByName(widget,"img_main_bg")
    local img_drag_flag = uiUtil.getConvertChildByName(widget,"img_drag_flag")
    local img_count = uiUtil.getConvertChildByName(widget,"img_count")
    UIListViewSize.definedUIpanel(widget,img_main_bg,list_panel,img_drag_flag,{img_count})

    local function cellSizeForTable()
		return item_height,item_width
	end
    
    local function numberOfCellsInTableView()
		return #listData
	end
    
    local function tableCellAtIndex(table, idx)
    	local cell = table:dequeueCell()
    	if nil == cell then
        	cell = CCTableViewCell:new()
        	local mlayer = TouchGroup:create()
        	mlayer:setTag(1)
        	cell:addChild(mlayer)

			local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/alliance_government_subordinate_cell.json")
	        tolua.cast(_pCell,"Layout")
	        mlayer:addWidget(_pCell)
	        _pCell:setTag(11)
         
    	end


    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_panel = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_panel then
                local detailInfo = listData[idx + 1]
                local userID = detailInfo[1]
                local userName = detailInfo[2]
                local belongState = detailInfo[3]
                local mainCityCoordinate = detailInfo[4]
                local curRebel = detailInfo[5]
                local maxRebel = detailInfo[6]
                
                local btn_official_0 = uiUtil.getConvertChildByName(item_panel,"btn_official_0")
                btn_official_0:setTouchEnabled(true)
                btn_official_0:addTouchEventListener(function (sender,eventType)
                    if eventType == TOUCH_EVENT_ENDED then
                       UIRoleForcesMain.create(userID) 
                    end
                end)

                local label_name = uiUtil.getConvertChildByName(item_panel,"label_name")
                label_name:setText(userName)

                local region_info = Tb_cfg_region[belongState]
                local label_belong = uiUtil.getConvertChildByName(item_panel,"label_belong")
                if region_info then 
                    
                    label_belong:setText(region_info.name)
                else
                    label_belong:setText("--")
                end
                
                local label_pos = uiUtil.getConvertChildByName(item_panel,"label_pos")
                local posY = mainCityCoordinate % 10000
				local posX = (mainCityCoordinate - posY)/10000
                label_pos:setText("（" .. posX .. "," .. posY .. "）")

                -- local label_progress_1 = uiUtil.getConvertChildByName(item_panel,"label_progress_1")
                -- label_progress_1:setText(curRebel .. "/" .. maxRebel)

                -- local label_progress_2 = uiUtil.getConvertChildByName(item_panel,"label_progress_2")
                -- if maxRebel > 0 then 
                --     label_progress_2:setText("（" .. math.floor(curRebel * 100/maxRebel) .. "%" .. "）")
                -- else
                --     label_progress_2:setText("（0%）")
                -- end

                label_pos:setTouchEnabled(true)
                label_pos:addTouchEventListener(function(sender,eventType)
                    if eventType == TOUCH_EVENT_ENDED then 
                        local coor_x_t = posX
                        local coor_y_t = posY
                        
                        require("game/uiCommon/op_locate_coordinate_confirm")
                        opLocateCoordinateConfirm.create(coor_x_t,coor_y_t,function()
                            UnionGovernment.remove_self()
                            UnionMainUI.remove_self()
                        end)
                    end
                end)
                local img_pos_line = uiUtil.getConvertChildByName(item_panel,"img_pos_line")
                img_pos_line:setSize(CCSizeMake(label_pos:getSize().width- 30,2)) 
			end
    	end
    	return cell
	end
	
	local img_drag_flag_up = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_down")
    local function tableviewScroll(view)
        if not list_tabel_view then return end
        
        if list_tabel_view:getContentOffset().y < 0 then 
            img_drag_flag_down:setVisible(true)
        else
            img_drag_flag_down:setVisible(false)
        end

        if list_tabel_view:getContentOffset().y > -(numberOfCellsInTableView() * 77 - list_panel:getSize().height) then 
            img_drag_flag_up:setVisible(true)
            img_drag_flag_up:setPositionY(list_panel:getSize().height - 8)
        else
            img_drag_flag_up:setVisible(false)
        end
        
    end

	breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)

    list_tabel_view = CCTableView:create(true,CCSizeMake(list_panel:getSize().width,list_panel:getSize().height))
 	list_panel:addChild(list_tabel_view)
 	list_tabel_view:setDirection(kCCScrollViewDirectionVertical)
 	list_tabel_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	list_tabel_view:ignoreAnchorPointForPosition(false)
	list_tabel_view:setAnchorPoint(cc.p(0.5,0.5))
	list_tabel_view:setPosition(cc.p(list_panel:getSize().width/2,list_panel:getSize().height/2))
	-- list_tabel_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    list_tabel_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    list_tabel_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    list_tabel_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    list_tabel_view:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
    list_tabel_view:reloadData()


    UnionData.requestGovernmentSubordinateList(union_id)

    return temp_widget
end


function UnionGovernmentSubordinate.updateData(package)
    if not list_tabel_view then return end
    listData = package 
    list_tabel_view:reloadData()

    local listNoneTips = uiUtil.getConvertChildByName(mainWidget,"Label_544350_0")
    local listTitlePanel = uiUtil.getConvertChildByName(mainWidget,"Panel_555068")
    if #listData > 0 then 
        listNoneTips:setVisible(false)
        listTitlePanel:setVisible(true)
    else
        listNoneTips:setVisible(true)
        listTitlePanel:setVisible(false)
    end

end

return UnionGovernmentSubordinate

