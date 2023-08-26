local m_whole_layer = nil
local m_main_widget = nil
local m_callback = nil

local m_city_id = nil
local m_army_id = nil 				--当前部队的ID
local m_is_fort = nil 				--城市类型判断
local m_current_index = nil 		--当前显示的部队在城市中的位置索引
local m_max_index = nil 			--当前城市开放的部队数量
local m_set_left_index = nil 		--在部队配置界面上一个部队的位置索引
local m_set_right_index = nil 		--在部队配置界面下一个部队的位置索引

local m_current_stage = nil 		--当前所处阶段，1 初始阶段；2 部队配置阶段

local m_clear_res_timer = nil

local function deal_with_res_clear()
	scheduler.remove(m_clear_res_timer)
	m_clear_res_timer = nil

	local temp_texture_1 = CCTextureCache:sharedTextureCache():textureForKey(ResDefineUtil.army_set_res[1])
	if temp_texture_1 and temp_texture_1:retainCount() == 1 then
		CCTextureCache:sharedTextureCache():removeTextureForKey(ResDefineUtil.army_set_res[1])
	end

	cardTextureManager.remove_cache()
end

local function do_remove_self()
	armyBaseManager.remove()
	armyHeroManager.remove()
	if armySetManager then
		armySetManager.remove_self()
	end
	
	m_city_id = nil
	m_army_id = nil 
	m_is_fort = nil
	m_current_index = nil 
	m_max_index = nil 
	m_current_stage = nil
	m_set_left_index = nil
	m_set_right_index = nil

	m_main_widget = nil
	m_whole_layer:removeFromParentAndCleanup(true)
	m_whole_layer = nil

	if m_callback then
		m_callback()
		m_callback = nil
	end

	uiManager.remove_self_panel(uiIndexDefine.ARMY_OVERVIEW_UI)

	UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.add, armyWholeManager.dealWithHeroAdd)
	UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyWholeManager.dealWithHeroUpdate)
	UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.remove, armyWholeManager.dealWithHeroRemove)

	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.add, armyWholeManager.dealWithArmyAdd)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, armyWholeManager.dealWithArmyUpdate)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.remove, armyWholeManager.dealWithArmyRemove)

	UIUpdateManager.remove_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, armyWholeManager.dealWithEffectUpdate)

	if UICityListArmy then
		UICityListArmy.reloadData()
	end

	m_clear_res_timer = scheduler.create(deal_with_res_clear, 0.5)
end

local function remove_self()
	if m_whole_layer then
		uiManager.hideConfigEffect(uiIndexDefine.ARMY_OVERVIEW_UI, m_whole_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x, y)
	return false
end

local function set_component_layout(scene_width, scene_height)
	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	bg_img:loadTexture(ResDefineUtil.army_set_res[1], UI_TEX_TYPE_LOCAL)
	local temp_img_scale = scene_height/bg_img:getContentSize().height
	--bg_img:setScale(temp_img_scale/config.getgScale())
	bg_img:setScale(temp_img_scale)
	bg_img:setPosition(cc.p(scene_width/2, scene_height/2))
	--bg_img:setTouchEnabled(true)

	armyBaseManager.set_layout(scene_width, scene_height)
end

local function set_component_scale()
	local scale_num = config.getgScale()
	local scale_list = {{"title_panel", "Layout"}, {"hero_1", "Layout"}, {"hero_2", "Layout"}, {"hero_3", "Layout"},
								{"army_sign_panel", "Layout"}, {"op_img", "ImageView"}, {"left_btn", "Button"},
								{"right_btn", "Button"}, {"return_btn", "Button"}, {"state_img", "ImageView"}}

	local temp_component = nil
	for k,v in pairs(scale_list) do
		temp_component = tolua.cast(m_main_widget:getChildByName(v[1]), v[2])
		temp_component:setScale(scale_num)
	end
end

local function create()
	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/armySetUI.json")
	m_main_widget:setTag(999)
	m_main_widget:setSize(CCSizeMake(scene_width, scene_height))
	m_main_widget:setTouchEnabled(true)
	--m_main_widget:setScale(config.getgScale())
	--m_main_widget:ignoreAnchorPointForPosition(false)
	--m_main_widget:setAnchorPoint(cc.p(0,0))
	--m_main_widget:setPosition(cc.p(0,0))

	set_component_scale()

	armyBaseManager.create(m_main_widget)
	armyHeroManager.create(m_main_widget)

	set_component_layout(scene_width, scene_height)

	m_whole_layer = TouchGroup:create()
	m_whole_layer:addWidget(m_main_widget)

    uiManager.add_panel_to_layer(m_whole_layer, uiIndexDefine.ARMY_OVERVIEW_UI)
    --uiManager.showConfigEffect(uiIndexDefine.ARMY_OVERVIEW_UI, m_whole_layer)

    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.add, armyWholeManager.dealWithHeroAdd)
	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyWholeManager.dealWithHeroUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.remove, armyWholeManager.dealWithHeroRemove)

	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.add, armyWholeManager.dealWithArmyAdd)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, armyWholeManager.dealWithArmyUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.remove, armyWholeManager.dealWithArmyRemove)

	UIUpdateManager.add_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, armyWholeManager.dealWithEffectUpdate)
end

local function set_army_index(new_index)
	m_current_index = new_index
	m_is_fort, m_max_index = armyListCityShare.get_city_army_base_info(m_city_id)

	if m_current_index < 1 then
		m_current_index = 1
	end
	if m_current_index > m_max_index then
		m_current_index = m_max_index
	end

	m_set_left_index = 0
	m_set_right_index = 0
	local temp_army_list, temp_army_info = nil, nil

	if m_is_fort then
		temp_army_list = armyData.getAllArmyInCity(m_city_id)
		m_max_index = #temp_army_list
		m_army_id = temp_army_list[m_current_index]
	else
		m_army_id = m_city_id * 10 + m_current_index
	end

	for i=m_current_index-1,1,-1 do
		if m_is_fort then
			temp_army_info = armyData.getTeamMsg(temp_army_list[i])
		else
			temp_army_info = armyData.getTeamMsg(m_city_id*10 + i)
		end
		
		if temp_army_info then
			if temp_army_info.state == armyState.normal then
				m_set_left_index = i
				break
			end
		else
			m_set_left_index = i
			break
		end
	end

	for i=m_current_index+1,m_max_index do
		if m_is_fort then
			temp_army_info = armyData.getTeamMsg(temp_army_list[i])
		else
			temp_army_info = armyData.getTeamMsg(m_city_id*10 + i)
		end

		if temp_army_info then
			if temp_army_info.state == armyState.normal then
				m_set_right_index = i
				break
			end
		else
			m_set_right_index = i
			break
		end
	end

	armyBaseManager.set_dir_show_state()
	armyBaseManager.set_index_show(m_current_index, m_max_index)
	armyBaseManager.update_title_show_content(m_city_id, m_current_index)
	armyHeroManager.organize_show_content()

	if m_current_stage == 2 then
		armySetManager.on_enter(m_main_widget, m_army_id)
	end
end

local function get_dir_show_state()
	local temp_left_state, temp_right_state = false, false
	if m_current_stage == 1 then
		if m_current_index ~= 1 then
			temp_left_state = true
		end

		if m_current_index ~= m_max_index then
			temp_right_state = true
		end
	else
		if m_set_left_index ~= 0 then
			temp_left_state = true
		end

		if m_set_right_index ~= 0 then
			temp_right_state = true
		end
	end

	return temp_left_state, temp_right_state
end

local function deal_with_index_change(is_add)
	if is_add then
		if m_current_stage == 1 then
			set_army_index(m_current_index + 1)
		else
			if m_set_right_index ~= 0 then
				set_army_index(m_set_right_index)
			end
		end
	else
		if m_current_stage == 1 then
			set_army_index(m_current_index - 1)
		else
			if m_set_left_index ~= 0 then
				set_army_index(m_set_left_index)
			end
		end
	end
end

local function deal_with_enter_set()
	if armyHeroManager.is_play_anim() then
		return
	end

	local team_info = armyData.getTeamMsg(m_army_id)
	if team_info then
		if team_info.state ~= armyState.normal then
			tipsLayer.create(errorTable[142])
			return
		end
	end

	require("game/army/armyCityOverview/armySetManager")
	armySetManager.on_enter(m_main_widget, m_army_id)

	armyBaseManager.deal_with_enter_set()
	armyHeroManager.deal_with_enter_set()
	m_current_stage = 2
	--newGuideInfo.enter_next_guide()
end

local function deal_with_leave_set()
	armySetManager.on_leave()

	armyBaseManager.deal_with_leave_set()
	armyHeroManager.deal_with_leave_set()
	m_current_stage = 1
end

local function deal_with_return_event()
	if armyHeroManager.is_play_anim() then
		return
	end

	if m_current_stage == 1 then
		remove_self()
		if mainBuildScene.isInCity() then
			armyListInCityManager.update_army_info()
		end
		newGuideInfo.enter_next_guide()
	else
		deal_with_leave_set()
	end
end

local function get_current_stage()
	return m_current_stage
end

local function get_army_id()
	return m_army_id
end

local function on_enter(city_id, army_index, temp_callback)
	if m_whole_layer then
		return
	end
	require("game/army/armyCityOverview/armyBaseManager")
	require("game/army/armyCityOverview/armyHeroManager")

	create()
	m_current_stage = 1
	m_city_id = city_id
	m_callback = temp_callback
	set_army_index(army_index)

	armyBaseManager.set_op_show_state(true)

	if not newGuideManager.get_guide_state() then
		if armyData.getHeroIdInTeamAndPos(m_army_id, 1) == 0 then
			deal_with_enter_set()
		end
	end
end

local function dealWithHeroChange(change_hero_id, change_type)
	local hero_army_id = 0
	if change_type == dataChangeType.update then
		local hero_info = heroData.getHeroInfo(change_hero_id)
		if hero_info and hero_info.armyid == m_army_id then
			armyHeroManager.organize_show_content()
			armyBaseManager.update_title_show_content(m_city_id, m_current_index)
		end
	end
	
	if m_current_stage == 2 then
		armySetManager.deal_with_hero_change(hero_army_id, change_type)
	end
end

local function dealWithHeroAdd(packet)
	dealWithHeroChange(packet.heroid_u, dataChangeType.add)
end

local function dealWithHeroUpdate(packet)
	dealWithHeroChange(packet.heroid_u, dataChangeType.update)
end

local function dealWithHeroRemove(packet)
	dealWithHeroChange(packet, dataChangeType.remove)
end

local function dealWithArmyChange(temp_army_id, change_type)
	if temp_army_id == m_army_id then
		armyHeroManager.organize_show_content()
		if m_current_stage == 2 then
			armySetManager.deal_with_army_change(temp_army_id, change_type)
		end
		armyBaseManager.update_title_show_content(m_city_id, m_current_index)
	end
end

local function dealWithArmyAdd(packet)
	dealWithArmyChange(packet.armyid, dataChangeType.add)
end

local function dealWithArmyUpdate(packet)
	dealWithArmyChange(packet.armyid, dataChangeType.update)
end

local function dealWithArmyRemove(packet)
	dealWithArmyChange(packet, dataChangeType.remove)
end

local function dealWithEffectUpdate(packet)
	if packet.city_wid == math.floor(m_army_id/10) and packet.army_pos_front ~= nil then
		armyHeroManager.deal_with_build_change()
	end
end

local function get_guide_widget(temp_guide_id)
	return m_main_widget
end

local function get_com_guide_widget(temp_guide_id)
	return m_main_widget
end

armyWholeManager = {
					on_enter = on_enter,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent,
					get_guide_widget = get_guide_widget,
					get_com_guide_widget = get_com_guide_widget,
					deal_with_return_event = deal_with_return_event,
					deal_with_index_change = deal_with_index_change,
					deal_with_enter_set = deal_with_enter_set,
					get_army_id = get_army_id,
					get_current_stage = get_current_stage,
					get_dir_show_state = get_dir_show_state,
					dealWithHeroAdd = dealWithHeroAdd,
					dealWithHeroUpdate = dealWithHeroUpdate,
					dealWithHeroRemove = dealWithHeroRemove,
					dealWithArmyAdd = dealWithArmyAdd,
					dealWithArmyUpdate = dealWithArmyUpdate,
					dealWithArmyRemove = dealWithArmyRemove,
					dealWithEffectUpdate = dealWithEffectUpdate
}