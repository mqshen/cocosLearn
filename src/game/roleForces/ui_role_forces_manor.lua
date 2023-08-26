local UIRoleForcesManor = {}
local uiUtil = require("game/utils/ui_util")
local instance = nil

local item_height = 0
local item_width = 0
local list_tabel_view = nil
local manor_list = nil
-- 领地列表
-- 主城＞分城＞要塞＞空地
-- 等级由高到低



local function get_manor_lv(manor)
	local posY = manor.wid % 10000
	local posX = (manor.wid - posY)/10000
	return math.floor(resourceData.resourceLevel(posX, posY) / 10)
end



local function sort_ruler(MA,MB)
    local function getName(MSG)
        -- if  MSG.city_type == cityTypeDefine.npc_chengqu then 
        if landData.isChengqu(MSG.wid) then
            return landData.get_city_name_by_coordinate(MSG.wid)
        else
            return MSG.name
        end
    end    

    local typeA = MA.city_type
    local typeB = MB.city_type

    local nameA = getName(MA)
    local nameB = getName(MB)

    if not nameA or (nameA == "") then 
        typeA = cityTypeDefine.own_free
    end

    if not nameB or (nameB == "") then 
        typeB = cityTypeDefine.own_free
    end
    

	if typeA ~= typeB then 
		if cityTypeSortTable[typeA] < cityTypeSortTable[typeB] then 
			return true
		else
			return false
		end
	else 
		if get_manor_lv(MA) > get_manor_lv(MB) then 
			return true
		else
			return false
		end
	end
end

local function get_manor_list()
	local manor_list = {}
	for k ,v in pairs(allTableData[dbTableDesList.world_city.name]) do
   		if v.userid == userData.getUserId() then
   			table.insert(manor_list,v)
   		end
   	end
   	table.sort(manor_list,sort_ruler)
   	return manor_list
end

function UIRoleForcesManor.remove()
	if instance then 
		instance:removeFromParentAndCleanup(true)
		instance = nil
	end
	list_tabel_view = nil
	manor_list = nil
end

-- 获取军营个数
local function getArmyFortCount()
    local retCount = 0
    for k,v in ipairs(manor_list) do 
        if v.city_type == cityTypeDefine.npc_yaosai then 
            if Tb_cfg_world_city[v.wid].param >=NPC_FORT_TYPE_RECRUIT[1] and
                Tb_cfg_world_city[v.wid].param <=NPC_FORT_TYPE_RECRUIT[2] then
                -- 军营
                retCount = retCount + 1
            end
        end
    end
    return retCount
end
--获取要塞数
local function getFortCount()
	local retCount = 0
	for k,v in ipairs(manor_list) do 
		if v.city_type == cityTypeDefine.yaosai  then 
			retCount = retCount + 1
		elseif v.city_type == cityTypeDefine.npc_yaosai then 
            if Tb_cfg_world_city[v.wid].param >=NPC_FORT_TYPE_RECRUIT[1] and
                Tb_cfg_world_city[v.wid].param <=NPC_FORT_TYPE_RECRUIT[2] then
                -- 军营
            else
                retCount = retCount + 1
            end
        end
	end
	return retCount
end

--获取分城数
local function getTownCount()
	local retCount = 0
	for k,v in ipairs(manor_list) do 
		if v.city_type == cityTypeDefine.fencheng then 
			retCount = retCount + 1
		end
	end
	return retCount
end

--获取城区数
local function getCityProper()
    local retCount = 0
    for k,v in ipairs(manor_list) do 
        if landData.isChengqu(v.wid) then 
            retCount = retCount + 1
        end
    end
    return retCount
end

--获取玩家城区数
local function getPlayerCityProperCount()
    local retCount = 0
    for k,v in ipairs(manor_list) do 
        if v.city_type == cityTypeDefine.player_chengqu then 
            retCount = retCount + 1
        end
    end
    return retCount
end

local function getNpcCityProperCount()
    local retCount = 0
    for k,v in ipairs(manor_list) do 
        if landData.isNpcChengqu(v.wid) then 
            retCount = retCount + 1
        end
    end
    return retCount
end

--获取领地某个等级的个数
---- 要过滤掉主城
local function getManorLvCount(lv)
	local retCount = 0
	for k,v in ipairs(manor_list) do 
		local posY = v.wid % 10000
		local posX = (v.wid - posY)/10000
		if landData.get_land_type(v.wid) == cityTypeDefine.lingdi 
            and math.floor(resourceData.resourceLevel(posX, posY) / 10) == lv then 
			retCount = retCount + 1
		end
	end
	return retCount
end

function UIRoleForcesManor.updateData()
	if not instance then return end

end

function UIRoleForcesManor.reloadData()
	if not instance then return end
	if not list_tabel_view then return end
	list_tabel_view:reloadData()
	

    local img_count_content = uiUtil.getConvertChildByName(instance,"img_count_content")
    --要塞数 (包括 野外要塞)
    local label_count_fort = uiUtil.getConvertChildByName(img_count_content,"label_count_fort")
    label_count_fort:setText(getFortCount())
    --分城数
    local label_count_town = uiUtil.getConvertChildByName(img_count_content,"label_count_town")
    label_count_town:setText(getTownCount())

    -- 军营数
    local label_count_junying = uiUtil.getConvertChildByName(img_count_content,"label_count_junying")
    label_count_junying:setText(getArmyFortCount())
    local label_count_lv = nil
    local label_title = nil
    local tempCount = 0

    local tempIndex = 1
    for i=1, 12 do 
    	label_count_lv = uiUtil.getConvertChildByName(img_count_content,"label_count_lv_" .. i)
    	label_title = uiUtil.getConvertChildByName(img_count_content,"label_title_" .. i)
        label_count_lv:setVisible(false)
        label_title:setVisible(false)
    end


    -- if cityProperCount > 0 then
    --     label_title = uiUtil.getConvertChildByName(img_count_content,"label_title_" .. tempIndex)
    --     label_title:setVisible(true)
    --     label_title:setText(cityTypeName[cityTypeDefine.npc_chengqu])

    --     label_count_lv = uiUtil.getConvertChildByName(img_count_content,"label_count_lv_" .. tempIndex)
    --     label_count_lv:setVisible(true)
    --     label_count_lv:setText(getCityProper())

    --     tempIndex = tempIndex + 2
    -- end

    --城区数
    local cityProperCount = getPlayerCityProperCount()

    -- 个人城区，
    label_title = uiUtil.getConvertChildByName(img_count_content,"label_title_" .. tempIndex)
    label_title:setVisible(true)
    label_title:setText(languagePack["name_personalProper"])

    label_count_lv = uiUtil.getConvertChildByName(img_count_content,"label_count_lv_" .. tempIndex)
    label_count_lv:setVisible(true)
    label_count_lv:setText(cityProperCount)
    tempIndex = tempIndex + 1

    cityProperCount = getNpcCityProperCount()
    -- 守军城区，
    label_title = uiUtil.getConvertChildByName(img_count_content,"label_title_" .. tempIndex)
    label_title:setVisible(true)
    label_title:setText(languagePack["name_defenderProper"])

    label_count_lv = uiUtil.getConvertChildByName(img_count_content,"label_count_lv_" .. tempIndex)
    label_count_lv:setVisible(true)
    label_count_lv:setText(cityProperCount)
    tempIndex = tempIndex + 1


    for lv = 9, 1,-1 do 
        tempCount = getManorLvCount(lv)
        if tempCount > 0 then 
            label_title = uiUtil.getConvertChildByName(img_count_content,"label_title_" .. tempIndex)
            label_title:setVisible(true)
            label_title:setText(cityTypeName[cityTypeDefine.lingdi] .. " " .. languagePack["lv"] .. lv)

            label_count_lv = uiUtil.getConvertChildByName(img_count_content,"label_count_lv_" .. tempIndex)
            label_count_lv:setVisible(true)
            label_count_lv:setText(tempCount)
            tempIndex = tempIndex + 1
        end
    end
    

end

function UIRoleForcesManor.create(parent)
	if instance then return end
	instance = GUIReader:shareReader():widgetFromJsonFile("test/role_forces_manor.json")
	-- instance:setScale(config.getgScale())
	parent:addChild(instance)

	
	local list_panel = uiUtil.getConvertChildByName(instance,"list_panel")
	local temp_item_panel = uiUtil.getConvertChildByName(instance,"item_panel")
	temp_item_panel:setVisible(false)

	item_width = temp_item_panel:getSize().width
	item_height = temp_item_panel:getSize().height

	manor_list = get_manor_list()
	local function cellSizeForTable()
		return item_height,item_width
	end
	local function numberOfCellsInTableView()
		return #manor_list
	end

    local function tableCellTouched(table,cell)
        -- pass
    end

    local img_drag_flag_up = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_up")
    local img_drag_flag_down = uiUtil.getConvertChildByName(list_panel,"img_drag_flag_down")
    breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
	local function tableviewScroll(view)

	    if list_tabel_view:getContentOffset().y < 0 then 
	    	img_drag_flag_down:setVisible(true)
	    else
	    	img_drag_flag_down:setVisible(false)
	    end

	    if list_tabel_view:getContentOffset().y > -(#manor_list * 77 - list_panel:getSize().height) then 
	    	img_drag_flag_up:setVisible(true)
	    else
	    	img_drag_flag_up:setVisible(false)
	    end
	    
	end

	local function tableCellAtIndex(table, idx)
    	local cell = table:dequeueCell()
    	if nil == cell then
        	cell = CCTableViewCell:new()
        	local mlayer = TouchGroup:create()
        	mlayer:setTag(1)
        	cell:addChild(mlayer)

			local item_panel = temp_item_panel:clone()
			item_panel:setVisible(true)
			mlayer:addWidget(item_panel)
			item_panel:setVisible(true)
			item_panel:setTag(11)	
			item_panel:setPosition(cc.p(0,0))
    	end


    	local item_layer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    	if item_layer then
    		local item_layout = tolua.cast(item_layer:getWidgetByTag(11),"Layout")
			if item_layout then
				local label_name = uiUtil.getConvertChildByName(item_layout,"label_name")
				local label_type = uiUtil.getConvertChildByName(item_layout,"label_type")
				local label_pos = uiUtil.getConvertChildByName(item_layout,"label_pos")
				local label_durability = uiUtil.getConvertChildByName(item_layout,"label_durability")

				local posY = manor_list[idx + 1].wid % 10000
				local posX = (manor_list[idx + 1].wid - posY)/10000
				label_pos:setText("（" .. posX .. "," .. posY .. "）")

                local isChengqu = landData.isChengqu(manor_list[idx + 1].wid)
				local name = manor_list[idx + 1].name
                local lv = nil
                if isChengqu then 
                    name,lv = landData.get_city_name_lv_by_coordinate(manor_list[idx + 1].wid)
                end

                label_pos:setTouchEnabled(true)
                label_pos:addTouchEventListener(function(sender,eventType)
                    if eventType == TOUCH_EVENT_ENDED then 
                        local coor_x = posX
                        local coor_y = posY
                        
                        
                        require("game/uiCommon/op_locate_coordinate_confirm")
                        opLocateCoordinateConfirm.create(coor_x,coor_y,function()
                            UIRoleForcesMain.remove_self()
                        end)
                    end
                end)

                local img_pos_line = uiUtil.getConvertChildByName(item_layout,"img_pos_line")
                img_pos_line:setSize(CCSizeMake(label_pos:getSize().width- 30,2)) 

				if name and name~="" then
					label_name:setText(name)
					label_type:setText(landData.get_land_displayName(manor_list[idx + 1].wid,manor_list[idx + 1].city_type))
				else
                    label_name:setText(landData.get_land_displayName(manor_list[idx + 1].wid,cityTypeDefine.lingdi))
					label_type:setText("Lv." .. math.floor(resourceData.resourceLevel(posX, posY) / 10))
				end

                if isChengqu then 
                    label_type:setText(landData.get_land_displayName(manor_list[idx + 1].wid,cityTypeDefine.npc_chengqu))
                end

                
                if manor_list[idx + 1].city_type == cityTypeDefine.player_chengqu  then 
                    label_type:setText(landData.get_land_displayName(manor_list[idx + 1].wid,cityTypeDefine.player_chengqu))
                end
                
				local max_durable = manor_list[idx + 1].durability_max
				local current_durable = manor_list[idx + 1].durability_cur
				if manor_list[idx + 1].durability_time ~= 0 then
					local add_durable = userData.getIntervalData(manor_list[idx + 1].durability_time,2*24*60*60,max_durable)
					current_durable = current_durable + math.floor(add_durable)
					if current_durable > max_durable then
						current_durable = max_durable
					end
				end
				label_durability:setText( current_durable .. "/" .. max_durable)
				
			end
    	end
    	return cell
	end

   	list_tabel_view = CCTableView:create(CCSizeMake(list_panel:getSize().width,list_panel:getSize().height))
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
    
    -- if #manor_list > 6 then 
    -- 	list_tabel_view:setTouchEnabled(true)
    -- else
    -- 	list_tabel_view:setTouchEnabled(false)
    -- end


    UIRoleForcesManor.reloadData()
end

return UIRoleForcesManor