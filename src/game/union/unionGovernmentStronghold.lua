---同盟治所	据点

local UnionGovernmentStronghold = {}

local uiUtil = require("game/utils/ui_util")


local item_height = nil
local item_width = nil
local union_id = nil
local listData = nil
local listDataCount = nil
local list_tabel_view = nil
local count_list_tabel_view = nil


local manorTypeName = {}
manorTypeName[1] = languagePack["guodu"] 
manorTypeName[2] = languagePack["zhoufu"]
manorTypeName[3] = languagePack["guanqia"]
manorTypeName[4] = languagePack["chengchi"]

local isRemoving = nil
local mainWidget = nil
function UnionGovernmentStronghold.remove()
    if not mainWidget then return end
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end

    item_height = nil
    item_width = nil
    union_id = nil
    listData = nil
    list_tabel_view = nil
    count_list_tabel_view = nil
    listDataCount = nil
end




function UnionGovernmentStronghold.create(mainPanel,pmainWidget,unionId)
    if mainWidget then return end
    listData = {}

    union_id = unionId

    local widget = GUIReader:shareReader():widgetFromJsonFile("test/alliance_government_stronghold.json")
    mainWidget = widget
    pmainWidget:addChild(mainWidget)

    local listNoneTips = uiUtil.getConvertChildByName(mainWidget,"Label_544350")
    local listTitlePanel = uiUtil.getConvertChildByName(mainWidget,"Panel_555067")
    listNoneTips:setVisible(false)
    listTitlePanel:setVisible(false)


    local list_panel = uiUtil.getConvertChildByName(widget,"list_panel")
    local img_drag_flag_down = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_down")
    local img_drag_flag_up = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_up")
    img_drag_flag_down:setVisible(false)
    img_drag_flag_up:setVisible(false)
    item_width = 828
	item_height = 77
   

    local img_main_bg = uiUtil.getConvertChildByName(widget,"img_main_bg")
    local img_count = uiUtil.getConvertChildByName(widget,"img_count")
    UIListViewSize.definedUIpanel(widget,img_main_bg,list_panel,nil,{img_count})



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

			local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/alliance_government_stronghold_cell.json")
	        tolua.cast(_pCell,"Layout")
	        mlayer:addWidget(_pCell)
	        _pCell:setTag(11)
         
    	end

        
    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_panel = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_panel then
				--[[
                ：0据点名、1类型（1首府、2据点、3关卡）、2所在州、3、城市wid（xy坐标自己解析）、4当前耐久、5总耐久、6等级（这个你用不上）
                ]]
                local detailInfo = listData[idx + 1]
                if not detailInfo then return end
                local label_name = uiUtil.getConvertChildByName(item_panel,"label_name")
                label_name:setText(detailInfo[1])

                local label_type = uiUtil.getConvertChildByName(item_panel,"label_type")
                local label_belong = uiUtil.getConvertChildByName(item_panel,"label_belong")

                local type_value = detailInfo[2]
                if type_value == 1 then 
                    label_type:setText(languagePack["union_country_city"])
                    label_name:setColor(ccc3(213,87,84))
                    label_type:setColor(ccc3(213,87,84))
                    label_belong:setColor(ccc3(213,87,84))
                elseif type_value == 2 then 
                    label_type:setText(languagePack["union_capital"])
                    label_name:setColor(ccc3(255,158,99))
                    label_type:setColor(ccc3(255,158,99))
                    label_belong:setColor(ccc3(255,158,99))
                elseif type_value == 3 then
                    label_type:setText(languagePack["union_stronghold"])
                    label_name:setColor(ccc3(239,230,162))
                    label_type:setColor(ccc3(239,230,162))
                    label_belong:setColor(ccc3(239,230,162))
                elseif type_value == 4 then 
                    label_type:setText(languagePack["union_checkpoint"])
                    label_name:setColor(ccc3(245,245,245))
                    label_type:setColor(ccc3(245,245,245))
                    label_belong:setColor(ccc3(245,245,245))
                else
                    label_type:setText("--")
                end

                local region_info = Tb_cfg_region[detailInfo[3]]
                
                if region_info then 
                    label_belong:setText(region_info.name)
                else
                    label_belong:setText("--")
                end

                local label_pos = uiUtil.getConvertChildByName(item_panel,"label_pos")
                local posY = detailInfo[4] % 10000
				local posX = (detailInfo[4] - posY)/10000
                label_pos:setText("（" .. posX .. "," .. posY .. "）")

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
                -- local label_durability = uiUtil.getConvertChildByName(item_panel,"label_durability")
                -- label_durability:setText(detailInfo[5] .. "/" .. detailInfo[6])
            end
    	end
    	return cell
	end

    local function tableviewScroll(view)
        if not list_tabel_view then return end
        local img_drag_flag_up = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_up")
        local img_drag_flag_down = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_down")
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
   


    listDataCount = {}

    local function cellSizeForTableCount(...)
        return 57,218
    end

    local function numberOfCellsInTableViewCount(...)
        return #listDataCount
    end

    local function tableCellAtIndexCount(table, idx)
        local cell = table:dequeueCell()
        if nil == cell then
            cell = CCTableViewCell:new()
            local mlayer = TouchGroup:create()
            mlayer:setTag(1)
            cell:addChild(mlayer)

            local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/alliance_government_stronghold_cell_1.json")
            tolua.cast(_pCell,"Layout")
            mlayer:addWidget(_pCell)
            _pCell:setTag(11)
         
        end


        local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
        if item_layer then
            local item_panel = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
            local dataInfo = nil
            if item_panel then
                dataInfo = listDataCount[idx + 1]
                local img_guodu = uiUtil.getConvertChildByName(item_panel,"img_guodu")
                local img_zhoufu = uiUtil.getConvertChildByName(item_panel,"img_zhoufu")
                local img_chengci = uiUtil.getConvertChildByName(item_panel,"img_chengci")
                local img_guanqia = uiUtil.getConvertChildByName(item_panel,"img_guanqia")

                local label_type = uiUtil.getConvertChildByName(item_panel,"label_type") 
                local label_level = uiUtil.getConvertChildByName(item_panel,"label_level")
                local label_count = uiUtil.getConvertChildByName(item_panel,"label_count")
                local img_line = uiUtil.getConvertChildByName(item_panel,"img_line")

                img_line:setVisible(true)
                label_type:setVisible(true)

                img_guodu:setVisible(false)
                img_zhoufu:setVisible(false)
                img_chengci:setVisible(false)
                img_guanqia:setVisible(false)
                
                if dataInfo["manorFirstFlag"] == false then 
                    img_line:setVisible(false)
                    label_type:setVisible(false)
                else
                    if dataInfo["manorType"] == 1 then 
                        img_guodu:setVisible(true)
                    elseif dataInfo["manorType"] == 2 then 
                        img_zhoufu:setVisible(true)
                    elseif dataInfo["manorType"] == 3 then 
                        img_guanqia:setVisible(true)
                    elseif dataInfo["manorType"] == 4 then 
                        img_chengci:setVisible(true)
                    end
                end

                label_type:setText(manorTypeName[dataInfo["manorType"]])
                label_level:setText(languagePack["lv"] .. dataInfo["manorLevel"])
                label_count:setText(dataInfo["manorCount"])

            end
        end
        return cell
    end

    local count_list_panel = uiUtil.getConvertChildByName(widget,"count_list_panel")

    local img_main_bg = uiUtil.getConvertChildByName(widget,"img_main_bg")
    local img_count = uiUtil.getConvertChildByName(widget,"img_count")
    UIListViewSize.definedUIpanel(widget,img_main_bg,count_list_panel,nil,{img_count})


    local function tableviewScrollCount(view)
        if not count_list_tabel_view then return end
        local img_drag_flag_up = uiUtil.getConvertChildByName(count_list_panel,"img_drag_flag_up")
        local img_drag_flag_down = uiUtil.getConvertChildByName(count_list_panel,"img_drag_flag_down")
        if count_list_tabel_view:getContentOffset().y < 0 then 
            img_drag_flag_down:setVisible(true)
        else
            img_drag_flag_down:setVisible(false)
        end

        if count_list_tabel_view:getContentOffset().y > -(numberOfCellsInTableViewCount() * 57 - count_list_panel:getSize().height) then 
            img_drag_flag_up:setVisible(true)
            img_drag_flag_up:setPositionY(count_list_panel:getSize().height - 8)
        else
            img_drag_flag_up:setVisible(false)
        end
        
    end

    
    count_list_tabel_view = CCTableView:create(true,CCSizeMake(count_list_panel:getSize().width,count_list_panel:getSize().height))
    count_list_panel:addChild(count_list_tabel_view)
    count_list_tabel_view:setDirection(kCCScrollViewDirectionVertical)
    count_list_tabel_view:setVerticalFillOrder(kCCTableViewFillTopDown)
    count_list_tabel_view:ignoreAnchorPointForPosition(false)
    count_list_tabel_view:setAnchorPoint(cc.p(0.5,0.5))
    count_list_tabel_view:setPosition(cc.p(count_list_panel:getSize().width/2,count_list_panel:getSize().height/2))
    count_list_tabel_view:registerScriptHandler(cellSizeForTableCount,CCTableView.kTableCellSizeForIndex)
    count_list_tabel_view:registerScriptHandler(tableCellAtIndexCount,CCTableView.kTableCellSizeAtIndex)
    count_list_tabel_view:registerScriptHandler(numberOfCellsInTableViewCount,CCTableView.kNumberOfCellsInTableView)
    count_list_tabel_view:registerScriptHandler(tableviewScrollCount,CCTableView.kTableViewScroll)
    

    UnionData.requestGovernmentStrongholdList(union_id)

    return temp_widget
end


function UnionGovernmentStronghold.updateData(package)
    if not mainWidget then return end
    -- for k,v in pairs(package) do 
    --     print("\n\n=======================================",k,v,#v)
    --     for kk,vv in pairs(v) do 
    --         print(">>>>> ",kk,vv)
    --     end
    -- end
    if #package == 0 then 
        package[1] = {}
        package[2] = {}
        package[3] = {}
        package[4] = {}
        package[5] = {}

    end
    listData = package[1]
    -- table.sort(listData,function(itemA,itemB)
    --    if itemA[3] < itemB[3] then 
    --        return true
    --    else
    --        return false
    --    end
    -- end)

    
    for k,v in pairs(NPC_CITY_LEVELS[1]) do
        if not package[2][v] then 
            package[2][v] = 0
        end
    end
    for k,v in pairs(NPC_CITY_LEVELS[2]) do
        if not package[3][v] then 
            package[3][v] = 0
        end
    end
    for k,v in pairs(NPC_CITY_LEVELS[3]) do
        if not package[4][v] then 
            package[4][v] = 0
        end
    end
    for k,v in pairs(NPC_CITY_LEVELS[4]) do
        if not package[5][v] then 
            package[5][v] = 0
        end
    end
    



    listDataCount = {}
    local countInfo = nil

    --TODOTK 以下代码待优化
    local subCount = 0
    -- 国都 
    for k,v in pairs(NPC_CITY_LEVELS[1]) do
        if package[2][v] then 
            countInfo = {} 
            countInfo["manorType"] = 1
            countInfo["manorLevel"] = v
            countInfo["manorCount"] = package[2][v]
            countInfo["manorFirstFlag"] = (subCount == 0)
            subCount = subCount + 1
            table.insert(listDataCount,countInfo)
        end
    end

    subCount = 0
    --州府信息
    for k,v in pairs(NPC_CITY_LEVELS[2]) do
        if package[3][v] then 
            countInfo = {} 
            countInfo["manorType"] = 2
            countInfo["manorLevel"] = v
            countInfo["manorCount"] = package[3][v]
            countInfo["manorFirstFlag"] = (subCount == 0)
            subCount = subCount + 1
            table.insert(listDataCount,countInfo)
        end
    end

    subCount = 0
    --城池信息
    for k,v in pairs(NPC_CITY_LEVELS[4]) do
        if package[5][v] then 
            countInfo = {} 
            countInfo["manorType"] = 4
            countInfo["manorLevel"] = v
            countInfo["manorCount"] = package[5][v]
            countInfo["manorFirstFlag"] = (subCount == 0)
            subCount = subCount + 1
            table.insert(listDataCount,countInfo)
        end
    end
    
    subCount = 0
    --关卡信息
    for k,v in pairs(NPC_CITY_LEVELS[3]) do
        if package[4][v] then 
            countInfo = {} 
            countInfo["manorType"] = 3
            countInfo["manorLevel"] = v
            countInfo["manorCount"] = package[4][v]
            countInfo["manorFirstFlag"] = (subCount == 0)
            subCount = subCount + 1
            table.insert(listDataCount,countInfo)
        end
    end
  
    
  

    list_tabel_view:reloadData()
    count_list_tabel_view:reloadData()

    local listNoneTips = uiUtil.getConvertChildByName(mainWidget,"Label_544350")
    local listTitlePanel = uiUtil.getConvertChildByName(mainWidget,"Panel_555067")
    if #listData > 0 then 
        listNoneTips:setVisible(false)
        listTitlePanel:setVisible(true)
    else
        listNoneTips:setVisible(true)
        listTitlePanel:setVisible(false)
    end
end



return UnionGovernmentStronghold
