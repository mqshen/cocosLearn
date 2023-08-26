local m_army_list_layer = nil
local m_simple_widget = nil 		--部队信息简化版显示

local m_simple_tb = nil
local m_show_max_num = nil 		--屏幕中显示的列表个数
local m_simple_cell_width = nil
local m_simple_cell_height = nil
local m_simple_dir_height = nil
local m_simple_list = nil 		--所有部队ID列表
local m_selected_id = nil 		--选中的部队ID，这个用来标示列表单元的选中状态

--[[
驻守 原来的 援军
待命 原来的 驻扎
--]]

local function remove_self()
	if m_army_list_layer then
		armyListDetail.remove_self(true)

		m_simple_tb = nil
		m_show_max_num = nil
		m_simple_cell_width = nil
		m_simple_cell_height = nil
		m_simple_dir_height = nil
		m_simple_list = nil
		m_simple_widget = nil
		m_selected_id = nil

		m_army_list_layer:removeFromParentAndCleanup(true)
		m_army_list_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.ARMY_LIST_UI)

		UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, armyListManager.dealWithSelfArmyUpdate)
		UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyListManager.dealWithSelfHeroUpdate)

		UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.add, armyListManager.dealWithEnemyChange)
		UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.update, armyListManager.dealWithEnemyChange)
		UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.remove, armyListManager.dealWithEnemyChange)
	end
end

local function dealwithTouchEvent(x,y)
	if m_simple_tb and  not m_simple_tb:isVisible() then return false end
	if m_simple_widget then
		local touch_panel = tolua.cast(m_simple_widget:getChildByName("touch_panel"), "Layout")
		if touch_panel and touch_panel:hitTest(cc.p(x,y)) then 
			mapMessageUI.disableTouchAndRemove()
		end
	end
	return false
end

local function set_city_cell_selected(cell, new_state)
	local temp_layer = tolua.cast(cell:getChildByTag(123), "TouchGroup")
    local cell_widget = tolua.cast(temp_layer:getWidgetByTag(1), "Layout")

    local common_bg_img = tolua.cast(cell_widget:getChildByName("unselect_bg_img"), "ImageView")
	local selecte_bg_img = tolua.cast(cell_widget:getChildByName("select_bg_img"), "ImageView")
    if new_state then
    	selecte_bg_img:setVisible(true)
    	common_bg_img:setVisible(false)
    else
    	selecte_bg_img:setVisible(false)
    	common_bg_img:setVisible(true)
    end
end

local function show_cell_content(cell_widget, idx)
	local temp_army_id = m_simple_list[idx+1][1]
	local temp_own_type = m_simple_list[idx+1][2]

	local common_bg_img = tolua.cast(cell_widget:getChildByName("unselect_bg_img"), "ImageView")
	local selecte_bg_img = tolua.cast(cell_widget:getChildByName("select_bg_img"), "ImageView")
	local state_bg = tolua.cast(cell_widget:getChildByName("state_bg"), "ImageView")
	local sign_img = tolua.cast(cell_widget:getChildByName("sign_img"), "ImageView")
	local name_txt = tolua.cast(cell_widget:getChildByName("name_label"), "Label")

	local temp_army_info = nil
	if temp_own_type == 1 then
		temp_army_info = armyData.getTeamMsg(temp_army_id)
		common_bg_img:loadTexture(ResDefineUtil.army_list_res[4], UI_TEX_TYPE_PLIST)
		selecte_bg_img:loadTexture(ResDefineUtil.army_list_res[14], UI_TEX_TYPE_PLIST)
		state_bg:loadTexture(ResDefineUtil.army_list_res[2], UI_TEX_TYPE_PLIST)
		local show_name_content = heroData.getHeroName(temp_army_info.base_heroid_u)
		name_txt:setText(show_name_content)

		local temp_state = temp_army_info.state
		if temp_state == armyState.chuzhenging or temp_state == armyState.zhuzhaing 
			or temp_state == armyState.yuanjuning or temp_state == armyState.returning 
		 then
			sign_img:loadTexture(ResDefineUtil.army_list_res[7], UI_TEX_TYPE_PLIST)
		elseif temp_state == armyState.zhuzhaed then
			sign_img:loadTexture(ResDefineUtil.army_list_res[10], UI_TEX_TYPE_PLIST)
		elseif temp_state == armyState.yuanjuned then
			sign_img:loadTexture(ResDefineUtil.army_list_res[9], UI_TEX_TYPE_PLIST)
		elseif temp_state == armyState.sleeped then
			sign_img:loadTexture(ResDefineUtil.army_list_res[8], UI_TEX_TYPE_PLIST)
		elseif temp_state == armyState.decreed or temp_state == armyState.training then
			sign_img:loadTexture(ResDefineUtil.army_list_res[16], UI_TEX_TYPE_PLIST)
		end
	else
		common_bg_img:loadTexture(ResDefineUtil.army_list_res[5], UI_TEX_TYPE_PLIST)
		selecte_bg_img:loadTexture(ResDefineUtil.army_list_res[15], UI_TEX_TYPE_PLIST)
		state_bg:loadTexture(ResDefineUtil.army_list_res[3], UI_TEX_TYPE_PLIST)
		name_txt:setText(languagePack["wenhao"])
		sign_img:loadTexture(ResDefineUtil.army_list_res[7], UI_TEX_TYPE_PLIST)
	end
end

local function simple_tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/armySimplifyCell.json")
	    new_widget:setTag(1)
	    local new_layer = TouchGroup:create()
	    new_layer:setTag(123)
	    new_layer:addWidget(new_widget)
	    cell = CCTableViewCell:new()
	    cell:addChild(new_layer)
	end

	if m_selected_id == m_simple_list[idx+1][1] then
		set_city_cell_selected(cell, true)
	else
		set_city_cell_selected(cell, false)
	end
    
    local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local cell_widget = cell_layer:getWidgetByTag(1)
    show_cell_content(cell_widget, idx)
    
    return cell
end

local function simple_tableCellTouched(table,cell)
	local idx = cell:getIdx()
	local temp_army_id = m_simple_list[idx+1][1]
	armyMark.setTouchArmy(temp_army_id)
	ObjectCountDown.setSelectArmyId(temp_army_id)
end

local function simple_cellSizeForTable(table,idx)
    return m_simple_cell_height, m_simple_cell_width
end

local function simple_numberOfCellsInTableView(table)
	return #m_simple_list
end

local function simple_tableCellHighlight(table, cell)
	set_city_cell_selected(cell, true)
end

local function simple_tableCellUnhighlight(table, cell)
	set_city_cell_selected(cell, false)
end

local function scrollViewDidScroll(view)
	if #m_simple_list <= m_show_max_num then
		return
	end

    local up_img = tolua.cast(m_simple_widget:getChildByName("up_img"), "ImageView")
	local down_img = tolua.cast(m_simple_widget:getChildByName("down_img"), "ImageView")
    if view:getContentOffset().y < 0 then
    	down_img:setVisible(true)
    else
    	down_img:setVisible(false)
    end

	if view:getContentSize().height + view:getContentOffset().y > view:getViewSize().height then
		up_img:setVisible(true)
	else
		up_img:setVisible(false)
	end
end

local function reload_simple_data()
	m_simple_list = armyListAssist.get_simple_show_list()
	m_simple_tb:reloadData()

	local temp_nums = #m_simple_list
	local up_img = tolua.cast(m_simple_widget:getChildByName("up_img"), "ImageView")
	local down_img = tolua.cast(m_simple_widget:getChildByName("down_img"), "ImageView")
	local touch_panel = tolua.cast(m_simple_widget:getChildByName("touch_panel"), "Layout")
	local temp_default_height = m_simple_dir_height * 2 + m_simple_cell_height * m_show_max_num
	if temp_nums > m_show_max_num then
		up_img:setVisible(false)
		down_img:setVisible(true)

		touch_panel:setSize(CCSizeMake(m_simple_cell_width, m_simple_cell_height * m_show_max_num))
		touch_panel:setPositionY(m_simple_dir_height)
		touch_panel:setTouchEnabled(true)

		m_simple_tb:setBounceable(true)
	else
		up_img:setVisible(false)
		down_img:setVisible(false)

		if temp_nums == 0 then
			touch_panel:setTouchEnabled(false)
		else
			touch_panel:setSize(CCSizeMake(m_simple_cell_width, m_simple_cell_height * temp_nums))
			touch_panel:setPositionY(m_simple_dir_height + m_simple_cell_height * (m_show_max_num - temp_nums))
			touch_panel:setTouchEnabled(true)
		end

		m_simple_tb:setBounceable(false)
	end

	-- if mainOption.getIsIncity() then
	-- 	touch_panel:setTouchEnabled(false)
	-- else
	-- 	touch_panel:setTouchEnabled(true)
	-- end

	-- if touch_panel:isTouchEnabled() then 
	-- 	if not mainOption.getIsIncity() then 
	-- 		touch_panel:setTouchEnabled(false)
	-- 	end
	-- end
	if mainOption.getIsIncity() then
		touch_panel:setTouchEnabled(false)
	end
end

local function create()
	require("game/army/armyListAssist")
	require("game/army/armyListDetail")
	if m_army_list_layer then
		reload_simple_data()
		return
	end

	m_show_max_num = 6
	m_simple_cell_width = 140
	m_simple_cell_height = 50
	m_simple_dir_height = 16
	m_selected_id = 0

	local temp_max_height = m_simple_dir_height * 2 + m_simple_cell_height * m_show_max_num
	m_simple_widget = GUIReader:shareReader():widgetFromJsonFile("test/simpleTVUI.json")
	m_simple_widget:setSize(CCSizeMake(m_simple_cell_width, temp_max_height))
	m_simple_widget:ignoreAnchorPointForPosition(false)
	m_simple_widget:setAnchorPoint(cc.p(0, 1))
	m_simple_widget:setScale(config.getgScale())
	m_simple_widget:setPosition(cc.p(0, config.getWinSize().height - mainOption.get_top_height()))

	local up_img = tolua.cast(m_simple_widget:getChildByName("up_img"), "ImageView")
	local down_img = tolua.cast(m_simple_widget:getChildByName("down_img"), "ImageView")
	up_img:setPosition(cc.p(m_simple_cell_width/2, temp_max_height - m_simple_dir_height/2))
	down_img:setPosition(cc.p(m_simple_cell_width/2, m_simple_dir_height/2))
	local guodu_img = tolua.cast(m_simple_widget:getChildByName("detail_guodu_img"), "ImageView")
	guodu_img:setVisible(false)

	local init_size = CCSizeMake(m_simple_cell_width, m_simple_cell_height * m_show_max_num)
	local content_panel = tolua.cast(m_simple_widget:getChildByName("content_panel"), "Layout")
	content_panel:setSize(init_size)
	m_simple_tb = CCTableView:create(true, init_size)
	content_panel:addChild(m_simple_tb)
	m_simple_tb:setDirection(kCCScrollViewDirectionVertical)
	m_simple_tb:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_simple_tb:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	m_simple_tb:registerScriptHandler(simple_tableCellHighlight, CCTableView.kTableCellHighLight)
	m_simple_tb:registerScriptHandler(simple_tableCellUnhighlight, CCTableView.kTableCellUnhighLight)
    m_simple_tb:registerScriptHandler(simple_tableCellTouched,CCTableView.kTableCellTouched)
    m_simple_tb:registerScriptHandler(simple_cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_simple_tb:registerScriptHandler(simple_tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_simple_tb:registerScriptHandler(simple_numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

	m_army_list_layer = TouchGroup:create()
	m_army_list_layer:addWidget(m_simple_widget)
	uiManager.add_panel_to_layer(m_army_list_layer, uiIndexDefine.ARMY_LIST_UI)

	reload_simple_data()
	armyListDetail.create(m_army_list_layer)

	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, armyListManager.dealWithSelfArmyUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyListManager.dealWithSelfHeroUpdate)

	UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.add, armyListManager.dealWithEnemyChange)
	UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.update, armyListManager.dealWithEnemyChange)
	UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.remove, armyListManager.dealWithEnemyChange)
end

local function change_show_state(new_state)
	if m_simple_tb then
		m_army_list_layer:setVisible(new_state)
		m_simple_tb:setTouchEnabled(new_state)
	end

	if m_simple_widget then
		local touch_panel = tolua.cast(m_simple_widget:getChildByName("touch_panel"), "Layout")
		if mainOption.getIsIncity() then
			touch_panel:setTouchEnabled(false)
		else
			touch_panel:setTouchEnabled(true)
		end
	end
end

local function show_effect(action_time)
	if not m_simple_widget then
		return
	end

	--在城内是不显示的
	if mainBuildScene.getThisCityid() then 
		return 
	end
	--[[
	local function deal_with_show_finish()
		change_show_state(true)
	end

	
	local fun_call = cc.CallFunc:create(deal_with_show_finish)
	local fade_in = CCFadeIn:create(action_time)
	local temp_array = CCArray:create()
	temp_array:addObject(fade_in)
	temp_array:addObject(fun_call)
	local temp_seq = cc.Sequence:create(temp_array)
	m_simple_widget:runAction(temp_seq)
	--]]
	change_show_state(true)

	armyListDetail.show_effect(action_time)
end

local function hide_effect(action_time)
	if not m_simple_widget then
		return
	end

	--[[
	local function deal_with_hide_finish()
		change_show_state(false)
	end

	
	local fun_call = cc.CallFunc:create(deal_with_hide_finish)
	local fade_out = CCFadeOut:create(action_time)
	local temp_array = CCArray:create()
	temp_array:addObject(fade_out)
	temp_array:addObject(fun_call)
	local temp_seq = cc.Sequence:create(temp_array)
	m_simple_widget:runAction(temp_seq)
	--]]

	change_show_state(false)

	armyListDetail.hide_effect(action_time)
end

local function dealWithSelfArmyUpdate(packet)
	reload_simple_data()
	armyListDetail.deal_with_self_army_update(packet.armyid)
end

local function dealWithSelfHeroUpdate(packet)
	local temp_army_id, temp_pos = armyData.getArmyIdAndPosByHero(packet.heroid_u)
	if temp_army_id ~= 0 then
		armyListDetail.deal_with_self_army_update(temp_army_id)
	end
end

local function dealWithEnemyChange(packet)
	reload_simple_data()
	armyListDetail.deal_with_enemy_army_update()
end

local function dealWithOtherArmyUpdate()
	if m_army_list_layer then
		reload_simple_data()
		armyListDetail.deal_with_other_army_update()
	end
end

-- new_army_id 0 标示清理选中状态；其他表示选中新部队
local function set_new_selected_army_id(new_army_id)
	local temp_old_index, temp_new_index = nil, nil
	for k,v in pairs(m_simple_list) do
		if v[1] == m_selected_id then
			temp_old_index = k - 1
		elseif v[1] == new_army_id then
			temp_new_index = k - 1
		end
	end

	local cell = nil
	if temp_old_index then
		cell = m_simple_tb:cellAtIndex(temp_old_index)
		set_city_cell_selected(cell, false)
		m_selected_id = 0
	end

	if temp_new_index then
		cell = m_simple_tb:cellAtIndex(temp_new_index)
		set_city_cell_selected(cell, true)
		m_selected_id = new_army_id
	end
end

local function dealWithSelectArmy(army_id)
	local army_info = armyListAssist.get_info_by_army_id(army_id)
	if army_info then
		armyListDetail.set_army_info(army_info)

		set_new_selected_army_id(army_id)
	end
end

armyListManager = {
					create = create,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent,
					show_effect = show_effect,
					hide_effect = hide_effect,
					change_show_state = change_show_state,
					set_new_selected_army_id = set_new_selected_army_id,
					dealWithSelectArmy = dealWithSelectArmy,
					dealWithSelfArmyUpdate = dealWithSelfArmyUpdate,
					dealWithSelfHeroUpdate = dealWithSelfHeroUpdate,
					dealWithEnemyChange = dealWithEnemyChange,
					dealWithOtherArmyUpdate = dealWithOtherArmyUpdate
}