local UnionOfficialApplyOpen = {}

local uiUtil = require("game/utils/ui_util")
local union_id = nil
local mainWidget = nil
local list_data = nil
local list_tabel_view = nil
local item_height = nil
local item_width = nil

local last_handling_apply_id = nil
local last_handling_apply_indx = nil
function UnionOfficialApplyOpen.remove()
    if mainWidget then 
        local list_id = UnionOfficialApplyOpen.getUnreadIdList()
        if #list_id ~= 0 then 
            Net.send(UNION_UPDATE_APPLICATION,{list_id})
        end
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    union_id = nil
    list_data = nil
    list_tabel_view = nil
    item_width = nil
    item_height = nil
    last_handling_apply_id = nil
    last_handling_apply_indx = nil


end

local function handlerApplyItem(indx,applyID,state)
    last_handling_apply_id = applyID
    last_handling_apply_indx = indx
    UnionOfficialData.requestHandlingAplly(applyID,state)
end

function UnionOfficialApplyOpen.responeHandlerApplyItem(handlerFlag)
    if not list_tabel_view then return end
    if not list_data then return end
    if not last_handling_apply_id then return end
    for i=1,#list_data do 
        if list_data[i][1] == last_handling_apply_id then
            if handlerFlag == 1 then 
                tipsLayer.create(errorTable[178],nil,{list_data[i][3]})
            else
                print(">>>>>>>>>>>> unknow what todo")
            end
        end
    end
    table.remove(list_data,last_handling_apply_indx)
    list_tabel_view:reloadData()
end

function UnionOfficialApplyOpen.create(mainPanel,pmainWidget,unionID)

    if mainWidget then return end
    list_data = {}
    union_id = unionID
    local widget = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_for_processing.json")
    mainWidget = widget
    pmainWidget:addChild(mainWidget)
    
    local listNoneTips = uiUtil.getConvertChildByName(mainWidget,"Label_544350_1")
    local listTitlePanel = uiUtil.getConvertChildByName(mainWidget,"Panel_555070")
    listNoneTips:setVisible(false)
    listTitlePanel:setVisible(false)
    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    
    item_width = 1060
	item_height = 77
   
    
    



    -- local img_main_bg = uiUtil.getConvertChildByName(widget,"img_main_bg")
    -- UIListViewSize.definedUIpanel(widget,img_main_bg,list_panel,nil,{})

    local function cellSizeForTable()
		return item_height,item_width
	end
    
    local function numberOfCellsInTableView()
        return #list_data
	end
    
    local function tableCellAtIndex(table, idx)
    	local cell = table:dequeueCell()
    	if nil == cell then
        	cell = CCTableViewCell:new()
        	local mlayer = TouchGroup:create()
        	mlayer:setTag(1)
        	cell:addChild(mlayer)

			local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_for_processing_cell.json")
	        tolua.cast(_pCell,"Layout")
	        mlayer:addWidget(_pCell)
	        _pCell:setTag(11)
    	end

    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_panel = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_panel then
                local label_name_official = uiUtil.getConvertChildByName(item_panel,"label_name_official")
                label_name_official:setText(list_data[idx + 1][3])
                local label_forces = uiUtil.getConvertChildByName(item_panel,"label_forces")
                label_forces:setText(list_data[idx + 1][4])

                local region_info = Tb_cfg_region[list_data[idx + 1][5]]
                local label_belong = uiUtil.getConvertChildByName(item_panel,"label_belong")
                if region_info then 
                    label_belong:setText(region_info.name)
                else
                    label_belong:setText("--")
                end

                local img_new = uiUtil.getConvertChildByName(item_panel,"img_new")
                if list_data[idx + 1][7] == 0 then 
                    img_new:setVisible(true)
                else
                    img_new:setVisible(false)
                end

                local btn_ok = uiUtil.getConvertChildByName(item_panel,"btn_ok")
                btn_ok:setTouchEnabled(true)
                btn_ok:addTouchEventListener(function (sender,eventType)
                    if eventType == TOUCH_EVENT_ENDED then
                        if userData.getAffilated_union_id() ~= 0 then 
                            tipsLayer.create(errorTable[89])
                            return
                        end
                        list_data[idx + 1][7] = 1
                        UnionOfficialManagement.refreshNotice()
                        img_new:setVisible(false)
                        Net.send(UNION_UPDATE_APPLICATION,{ {list_data[idx + 1][1]} })
                        handlerApplyItem(idx+1,list_data[idx + 1][1],1)
                    end
                end)

                local btn_cancel = uiUtil.getConvertChildByName(item_panel,"btn_cancel")
                btn_cancel:setTouchEnabled(true)
                btn_cancel:addTouchEventListener(function (sender,eventType)
                    if eventType == TOUCH_EVENT_ENDED then
                        if userData.getAffilated_union_id() ~= 0 then 
                            tipsLayer.create(errorTable[89])
                            return
                        end
                        --sender:setTouchEnabled(false)
                        list_data[idx + 1][7] = 1
                        UnionOfficialManagement.refreshNotice()
                        img_new:setVisible(false)
                        Net.send(UNION_UPDATE_APPLICATION, { {list_data[idx + 1][1]} })
                        handlerApplyItem(idx + 1,list_data[idx + 1][1],0) 
                    end
                end)

                local btn_official = uiUtil.getConvertChildByName(item_panel,"btn_official")
                btn_official:setTouchEnabled(true)
                btn_official:addTouchEventListener(function(sender,eventType)
                    if eventType == TOUCH_EVENT_ENDED then
                        UIRoleForcesMain.create(list_data[idx + 1][2]) 
                    end
                end)

                
			end
    	end
    	return cell
	end

    local img_drag_flag_up = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_down")
    img_drag_flag_up:setVisible(false)
    img_drag_flag_down:setVisible(false)

	breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
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

    local btn_close = uiUtil.getConvertChildByName(widget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            if userData.getAffilated_union_id() ~= 0 then 
                tipsLayer.create(errorTable[89])
                return
            end
            sender:setTouchEnabled(false)
            UnionOfficialManagement.switchApplyState()
        end
    end)

    UnionOfficialData.requestUnionApplyList()
end

function UnionOfficialApplyOpen.updateData(package)
    if not list_tabel_view then return end
    list_data = package
    list_tabel_view:reloadData()
    UnionOfficialManagement.refreshNotice()

    local listNoneTips = uiUtil.getConvertChildByName(mainWidget,"Label_544350_1")
    local listTitlePanel = uiUtil.getConvertChildByName(mainWidget,"Panel_555070")
    if #list_data > 0 then 
        listNoneTips:setVisible(false)
        listTitlePanel:setVisible(true)
    else
        listNoneTips:setVisible(true)
        listTitlePanel:setVisible(false)
    end

end

function UnionOfficialApplyOpen.hasUnread()
    if not mainWidget then return false end
    if not list_data then return false end
    for k,v in pairs(list_data) do 
        if v[7] == 0 then 
            return true
        end
    end
    return false
end

function UnionOfficialApplyOpen.getUnreadIdList()
    local ret = {}
    if not mainWidget then return ret end
    if not list_data then return ret end
    for k,v in pairs(list_data) do 
        if v[7] == 0 then 
            table.insert(ret,v[1])
        end
    end
    return ret
end
return UnionOfficialApplyOpen
