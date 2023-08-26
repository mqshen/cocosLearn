local m_move_layer = nil
local m_main_widget = nil
local m_army_widget = nil
local m_city_tb = nil

local m_op_type = nil 			--选择进行的操作
local m_bIsDecree = nil 		-- 是否是屯田
local m_bIsSaoDang = nil 		-- 是否扫荡
local m_map_x = nil
local m_map_y = nil

local m_select_city_id = nil 		--选中的城市ID
local m_select_cell_index = nil 	--选中的城市在TABLEVIEW中的索引
local m_cell_height = nil 			--城市单元格高度
local m_cell_max_num = nil 			--同屏显示的最多单元格数

local m_city_list = nil
local m_army_list = nil
local m_is_playing_anim = nil

local function do_remove_self()
	if m_move_layer then
		m_city_tb = nil

		m_op_type = nil
		m_bIsDecree = nil
		m_bIsSaoDang = nil
		m_map_x = nil
		m_map_y = nil

		m_cell_height = nil
		m_cell_max_num = nil

		m_select_city_id = nil
		m_select_cell_index = nil

		m_city_list = nil
		m_army_list = nil
		m_is_playing_anim = nil

		m_army_widget = nil
		m_main_widget = nil
		m_move_layer:removeFromParentAndCleanup(true)
		m_move_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.ARMY_SELECT_UI)

		ArmyMarchLine.remove()

		optionController.resetOptions()
	end
end

local function remove_self()
	if m_move_layer then
		uiManager.hideConfigEffect(uiIndexDefine.ARMY_SELECT_UI, m_move_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if m_is_playing_anim then
		return false
	end

	local city_panel = tolua.cast(m_main_widget:getChildByName("city_panel"), "Layout")
	local touch_img = tolua.cast(city_panel:getChildByName("touch_img"), "Layout")
	if touch_img:hitTest(cc.p(x, y)) then
		return false
	end

	local army_panel = tolua.cast(m_main_widget:getChildByName("army_panel"), "Layout")
	if army_panel:hitTest(cc.p(x, y)) then
		return false
	end

	local des_img = tolua.cast(m_main_widget:getChildByName("des_img"), "ImageView")
	if des_img:hitTest(cc.p(x, y)) then
		return false
	end

	remove_self()
	return true
end

local function deal_with_close_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function draw_move_line()
	ArmyMarchLine.remove()
	ArmyMarchLine.create({start_wid = m_select_city_id, end_wid = m_map_x * 10000 + m_map_y})
end

local function set_des_show_state(new_state)
	if m_main_widget then
		local des_img = tolua.cast(m_main_widget:getChildByName("des_img"), "ImageView")
		des_img:setVisible(new_state)
	end
end

local function is_dangerous(temp_army_index)
	--新手引导期间不判断难度
	if not userData.isNewBieTaskFinished() then
		return false
	end

	local move_dis = armyData.getMoveShowInfo(m_select_city_id, m_map_x*10000 + m_map_y, 1)
	local res_level = math.floor(resourceData.resourceLevel(m_map_x, m_map_y)/10)
	local army_fight_power = armyData.getTeamFightPower(m_army_list[temp_army_index])
	local cmp_param = (landFightPower[res_level][1] + landFightPower[res_level][2]*(1+move_dis/NPC_FORCES_DISTANCE_PARAM)) /army_fight_power
	-- local cmp_param = (landFightPower[res_level][1] + landFightPower[res_level][2]*(1+move_dis * NPC_FORCES_DISTANCE_PARAM)) /army_fight_power
	
	local diff_value = commonFunc.get_sequene_range_in_list(cmp_param, fightPowerCMP)
	return diff_value == 4
end

local function set_select_city_id()
	armyListCityShare.set_army_move_content(m_army_widget, m_select_city_id, true)
	m_army_list = armyData.getAllArmyInCity(m_select_city_id)

	local army_panel = tolua.cast(m_main_widget:getChildByName("army_panel"), "Layout")
	if m_op_type == armyOp.chuzheng or m_op_type == armyOp.rake then
		local btn_panel = tolua.cast(army_panel:getChildByName("btn_panel"), "Layout")
		local sign_img = nil
		for i=1,ARMY_MAX_NUMS_IN_CITY do
			sign_img = tolua.cast(btn_panel:getChildByName("img_" .. i), "ImageView")
			if i > #m_army_list then
				sign_img:setVisible(false)
			else
				if armyData.is_army_can_used(m_army_list[i], m_select_city_id) then
					if is_dangerous(i) then
						sign_img:setVisible(true)
					else
						sign_img:setVisible(false)
					end
				else
					sign_img:setVisible(false)
				end
			end
		end
	end

	local content_img = tolua.cast(army_panel:getChildByName("content_img"), "ImageView")
	content_img:setSize(CCSizeMake(210 * #m_army_list + 35 * 2, content_img:getSize().height))
	army_panel:setSize(CCSizeMake(210 * #m_army_list + 35 * 2, army_panel:getSize().height))

	local des_img = tolua.cast(m_main_widget:getChildByName("des_img"), "ImageView")
	local no_army_img = tolua.cast(des_img:getChildByName("no_army_img"), "ImageView")
	local select_army_img = tolua.cast(des_img:getChildByName("select_army_img"), "ImageView")
	if armyData.getCanUseNumInArmyList(m_army_list, m_select_city_id) == 0 then
		no_army_img:setVisible(true)
		select_army_img:setVisible(false)
	else
		no_army_img:setVisible(false)
		select_army_img:setVisible(true)
	end
end

local function set_city_cell_selected(cell, new_state)
	local temp_layer = tolua.cast(cell:getChildByTag(123), "TouchGroup")
    local cell_widget = tolua.cast(temp_layer:getWidgetByTag(1), "Layout")

    local city_selected_sign = tolua.cast(cell_widget:getChildByName("select_img"), "ImageView")
    if new_state then
    	city_selected_sign:setVisible(true)
    	--cell:setPositionX(25)
    else
    	city_selected_sign:setVisible(false)
    	--cell:setPositionX(0)
    end
end

local function city_tableCellTouched(table,cell)
	local new_index = cell:getIdx()
	if m_select_cell_index == new_index then
		return
	end

	local last_cell = m_city_tb:cellAtIndex(m_select_cell_index)
	if last_cell then
		set_city_cell_selected(last_cell, false)
	end

	set_city_cell_selected(cell, true)
	m_select_cell_index = new_index
	m_select_city_id = m_city_list[m_select_cell_index + 1][1]
	set_select_city_id()

	draw_move_line()
end

local function city_cellSizeForTable(table,idx)
    return m_cell_height, 428
end

local function city_tableCellAtIndex(table, idx)
    local temp_cell = table:dequeueCell()
    if temp_cell == nil then
        temp_cell = CCTableViewCell:new()
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyCityCell.json")
		new_widget:setTag(1)
		local new_layer = TouchGroup:create()
		new_layer:setTag(123)
	    new_layer:addWidget(new_widget)
	    temp_cell:addChild(new_layer)
	end

	if m_select_cell_index == idx then
		set_city_cell_selected(temp_cell, true)
	else
		set_city_cell_selected(temp_cell, false)
	end

	local cell_content_info = m_city_list[idx + 1]
    
    local temp_layer = tolua.cast(temp_cell:getChildByTag(123), "TouchGroup")
    local cell_widget = tolua.cast(temp_layer:getWidgetByTag(1), "Layout")

    local type_img = tolua.cast(cell_widget:getChildByName("type_img"), "ImageView")
    type_img:loadTexture(ResDefineUtil.city_list_army_img_city_type_url_c[cell_content_info[2]], UI_TEX_TYPE_PLIST)

    --[[
    local type_img = tolua.cast(cell_widget:getChildByName("type_img"), "ImageView")
    local icon_img = tolua.cast(type_img:getChildByName("content_img"), "ImageView")
    local current_city_type = cell_content_info[2]
    if current_city_type == cityTypeDefine.zhucheng then
    	type_img:loadTexture(ResDefineUtil.army_move_city_type_res[4], UI_TEX_TYPE_PLIST)
    	icon_img:loadTexture(ResDefineUtil.army_move_city_type_res[1], UI_TEX_TYPE_PLIST)
    	icon_img:setScale(0.7)
    	icon_img:setPositionY(0)
    elseif current_city_type == cityTypeDefine.fencheng then
    	type_img:loadTexture(ResDefineUtil.army_move_city_type_res[4], UI_TEX_TYPE_PLIST)
    	icon_img:loadTexture(ResDefineUtil.army_move_city_type_res[2], UI_TEX_TYPE_PLIST)
    	icon_img:setScale(0.7)
    	icon_img:setPositionY(0)
    elseif current_city_type == cityTypeDefine.yaosai or current_city_type == cityTypeDefine.npc_yaosai then
    	type_img:loadTexture(ResDefineUtil.army_move_city_type_res[5], UI_TEX_TYPE_PLIST)
    	icon_img:loadTexture(ResDefineUtil.army_move_city_type_res[3], UI_TEX_TYPE_PLIST)
    	icon_img:setScale(0.8)
    	icon_img:setPositionY(10)
    end
    --]]

    --local type_txt = tolua.cast(cell_widget:getChildByName("type_label"), "Label")
    --type_txt:setText(landData.get_land_displayName( cell_content_info[1] ,current_city_type))

    local name_txt = tolua.cast(cell_widget:getChildByName("name_label"), "Label")
	name_txt:setText(cell_content_info[3])

	local dis_txt = tolua.cast(cell_widget:getChildByName("dis_label"), "Label")
	dis_txt:setText(string.format("%0.1f", cell_content_info[4]))
	
	local num_txt = tolua.cast(cell_widget:getChildByName("num_label"), "Label")
	num_txt:setText(cell_content_info[5] .. "/" .. cell_content_info[6])

    return temp_cell
end

local function city_numberOfCellsInTableView(table)
	return #m_city_list
end

local function order_rule(city_a, city_b)
	if city_a[4] < city_b[4] then
		return true
	else
		return false
	end
end

local function calculate_city_select_index()
	if #m_city_list > 0 then
		if m_select_city_id == 0 then
			m_select_city_id = m_city_list[1][1]
			m_select_cell_index = 0
		else
			local is_exist = false
			for k,v in pairs(m_city_list) do
				if m_select_city_id == v[1] then
					is_exist = true
					m_select_cell_index = k - 1
					break
				end
			end

			if not is_exist then
				m_select_city_id = m_city_list[1][1]
				m_select_cell_index = 0
			end
		end
	else
		m_select_city_id = 0
		m_select_cell_index = -1
	end
end

local function organize_city_list_content()
	m_city_list = {}
	local temp_target_pos = m_map_x*10000 + m_map_y
	for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
		if m_op_type == armyOp.yuanjun or k ~= temp_target_pos then
			local army_list = armyData.getAllArmyInCity(k)
			local army_nums = #army_list
			if army_nums > 0 then
				local content_list = {}
				content_list[1] = k
				content_list[2] = landData.get_city_type_by_id(k)
				content_list[3] = landData.get_city_name_by_coordinate(k)
				local move_dis = armyData.getMoveShowInfo(k, temp_target_pos, 1)
				content_list[4] = move_dis
				content_list[5] = armyData.getCanUseNumInArmyList(army_list, k)
				content_list[6] = army_nums
				table.insert(m_city_list, content_list)
			end
		end
	end

	table.sort(m_city_list, order_rule)
end

local function init_frame_city_info()
	local city_panel = tolua.cast(m_main_widget:getChildByName("city_panel"), "Layout")
	local content_panel = tolua.cast(city_panel:getChildByName("content_panel"), "Layout")
	m_city_tb = CCTableView:create(CCSizeMake(content_panel:getContentSize().width,content_panel:getContentSize().height))
	content_panel:addChild(m_city_tb)
	m_city_tb:setDirection(kCCScrollViewDirectionVertical)
	m_city_tb:setVerticalFillOrder(kCCTableViewFillTopDown)
    m_city_tb:registerScriptHandler(city_tableCellTouched,CCTableView.kTableCellTouched)
    m_city_tb:registerScriptHandler(city_cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_city_tb:registerScriptHandler(city_tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_city_tb:registerScriptHandler(city_numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
end

local function deal_with_army_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getName(),6))
		if not armyData.is_army_can_used(m_army_list[select_index], m_select_city_id) then
			require("game/army/armyMove/armyLineupManager")
  			armyLineupManager.on_enter(m_army_list[select_index], true,armyData.getTeamStateType(m_army_list[select_index], m_select_city_id))
			return
		end

		local move_dis = armyData.getMoveShowInfo(m_select_city_id, m_map_x*10000 + m_map_y, 1)
		if move_dis > ARMY_MOVE_DISTANCE_MAX then
			tipsLayer.create(errorTable[7], nil, {ARMY_MOVE_DISTANCE_MAX})
			return
		end

		newGuideInfo.enter_next_guide()
		require("game/army/armyMove/opArmyMoveConfirm")
		opArmyMoveConfirm.create(m_army_list[select_index], m_select_city_id, m_map_x, m_map_y, m_op_type)
		--remove_self()
	end
end

local function init_frame_army_info()
	require("game/army/armyCityOverview/armyListCityShare")

	local army_panel = tolua.cast(m_main_widget:getChildByName("army_panel"), "Layout")

	m_army_widget = armyListCityShare.create(deal_with_army_click)
	m_army_widget:ignoreAnchorPointForPosition(false)
    m_army_widget:setAnchorPoint(cc.p(0,0))
    m_army_widget:setPosition(cc.p(35, 10))
    army_panel:addChild(m_army_widget)
end

local function deal_with_animation_finished()
	local des_img = tolua.cast(m_main_widget:getChildByName("des_img"), "ImageView")
	breathAnimUtil.start_anim(des_img, true, 128, 255, 1, 0)

	m_is_playing_anim = false
end

local function is_need_show_dangerous()
	local temp_need_state = true
	if m_op_type ~= armyOp.chuzheng and m_op_type ~= armyOp.rake then
		temp_need_state = false
	else
		local temp_land_index = m_map_x*10000 + m_map_y
		if GroundEventData.getWorldEventByWid(temp_land_index) then
			temp_need_state = false
		else
			local landType = landData.get_land_type(temp_land_index)
			if landData.is_type_npc_city(temp_land_index) 
				or landType == cityTypeDefine.npc_yaosai
				or landType == cityTypeDefine.npc_chengqu 
				or 
				(landData.isLandOwnByEnemy(temp_land_index)   
					and
				 	(landType == cityTypeDefine.zhucheng or 
				  	 landType == cityTypeDefine.yaosai or 
					 landType == cityTypeDefine.lingdi or 
					 landType == cityTypeDefine.fencheng or
					 landType == cityTypeDefine.player_chengqu or
					 landType == cityTypeDefine.matou or
					 landType == cityTypeDefine.npc_chengqu )
				 )
				then
				temp_need_state = false
			end
		end
	end

	return temp_need_state
end

local function set_layout(scene_width, scene_height)
	local temp_scale_num = config.getgScale()
	local city_panel = tolua.cast(m_main_widget:getChildByName("city_panel"), "Layout")
	city_panel:ignoreAnchorPointForPosition(false)
	city_panel:setAnchorPoint(cc.p(1,1))
	city_panel:setScale(temp_scale_num)
	city_panel:setPosition(cc.p(scene_width, scene_height - 10 * temp_scale_num))

	local army_panel = tolua.cast(m_main_widget:getChildByName("army_panel"), "Layout")
	army_panel:ignoreAnchorPointForPosition(false)
	army_panel:setAnchorPoint(cc.p(0.5, 0))
	army_panel:setScale(temp_scale_num)
	local temp_army_pos_y = 0
	if userData.isNewBieTaskFinished() then
		--temp_army_pos_y = (-1 * army_panel:getSize().height + 30) * temp_scale_num
		temp_army_pos_y = scene_height*14/200
	else
		temp_army_pos_y = scene_height*14/100
	end
	army_panel:setPosition(cc.p(scene_width/2, temp_army_pos_y))

	local btn_panel = tolua.cast(army_panel:getChildByName("btn_panel"), "Layout")
	btn_panel:setVisible(is_need_show_dangerous())

	local des_img = tolua.cast(m_main_widget:getChildByName("des_img"), "ImageView")
	des_img:setScale(temp_scale_num)
	local temp_des_pos_y = temp_army_pos_y
	des_img:setPosition(cc.p(scene_width/2, temp_des_pos_y))

	if userData.isNewBieTaskFinished() then
		m_is_playing_anim = true
		local action_times = 0.2
		local fade_in = CCFadeIn:create(action_times)
		local move_to = CCMoveTo:create(action_times, ccp(scene_width/2, scene_height*14/100))
		local temp_spawn = CCSpawn:createWithTwoActions(fade_in,move_to)
		army_panel:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCActionInterval"))
		local fun_call = cc.CallFunc:create(deal_with_animation_finished)
		local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
		des_img:runAction(temp_seq)
	else
		deal_with_animation_finished()
	end
end

local function create()
	if m_move_layer then
		return
	end

	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyMoveUI.json")
	m_main_widget:setSize(CCSizeMake(scene_width, scene_height))
	m_main_widget:setTouchEnabled(true)
	m_main_widget:setTag(999)

	set_layout(scene_width, scene_height)
	init_frame_city_info()
	init_frame_army_info()

    m_move_layer = TouchGroup:create()
    m_move_layer:addWidget(m_main_widget)
	uiManager.add_panel_to_layer(m_move_layer, uiIndexDefine.ARMY_SELECT_UI)
end

local function hide_army_panel()
	local army_panel = tolua.cast(m_main_widget:getChildByName("army_panel"), "Layout")

	armyListCityShare.set_army_touch_state(m_army_widget, m_select_city_id, false)
	army_panel:setVisible(false)
end

local function load_data()
	organize_city_list_content()
	calculate_city_select_index()

	local army_panel = tolua.cast(m_main_widget:getChildByName("army_panel"), "Layout")
	if m_select_city_id == 0 then
		hide_army_panel()
	else
		set_select_city_id()
		army_panel:setVisible(true)
	end

	m_city_tb:reloadData()

	local city_panel = tolua.cast(m_main_widget:getChildByName("city_panel"), "Layout")
	local touch_img = tolua.cast(city_panel:getChildByName("touch_img"), "ImageView")
	if #m_city_list > m_cell_max_num then
		touch_img:setPositionY(0)
		touch_img:setSize(CCSizeMake(touch_img:getSize().width, city_panel:getSize().height))

		m_city_tb:setBounceable(true)
	else
		local touch_pos_y = 60 + (m_cell_max_num - #m_city_list) * m_cell_height
		touch_img:setPositionY(touch_pos_y)
		touch_img:setSize(CCSizeMake(touch_img:getSize().width, city_panel:getSize().height - touch_pos_y))

		m_city_tb:setBounceable(false)
	end
end

local function enter_select(new_op_type, coorX, coorY)
	newGuideInfo.enter_next_guide()
	m_op_type = new_op_type
	m_bIsDecree = (new_op_type == armyOp.farm)
	m_bIsSaoDang = (new_op_type == armyOp.rake)
	m_map_x = coorX
	m_map_y = coorY

	m_select_city_id = 0
	m_select_cell_index = -1

	m_cell_height = 90
	m_cell_max_num = 2

	mapController.setOpenMessage(false)
	mapController.locateCoordinate(m_map_x, m_map_y,function() 
					mapController.setOpenMessage(true)
				end)

	create()
	load_data()

	--第一次加载的时候CELL都是创建出来的，所以设置位置是无效的
	if m_select_cell_index ~= -1 then
		local current_cell = m_city_tb:cellAtIndex(m_select_cell_index)
		set_city_cell_selected(current_cell, true)

		draw_move_line()
	end

	optionController.removeOptions()
end

local function get_guide_widget(temp_guide_id) 
	return m_main_widget
end

armyMoveManager = {
				enter_select = enter_select,
				remove_self = remove_self,
				do_remove_self = do_remove_self,
				get_guide_widget = get_guide_widget,
				dealwithTouchEvent = dealwithTouchEvent,
				set_des_show_state = set_des_show_state
}