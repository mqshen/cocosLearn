local m_map_widget = nil
local m_armature_file_list = nil

local m_dir_list = nil 
local m_city_list = nil 
local m_boss_list = nil
local m_finish_list = nil
local m_enemy_list = nil

local m_army_offset_list = nil 		--部队相对所在格子的偏移

local m_map_line = nil
local m_map_column = nil

local m_select_land_index = nil

local m_anim_timer = nil 		--地图动画播放
local m_anim_list = nil 		--可以播放动画的列表

local function reset_enemy_info()
	if m_enemy_list then
		for k,v in pairs(m_enemy_list) do
			for i=1,3 do
				if v[i] ~= 0 then
					v[i]:getAnimation():stop()
					v[i]:removeFromParentAndCleanup(true)
				end
			end
		end

		m_enemy_list = nil
	end
end

local function remove_resource()
	local temp_file_name = nil
	for k,v in pairs(m_armature_file_list) do
		temp_file_name = "gameResources/battle/" .. v .. ".ExportJson"
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(temp_file_name)
	end

	m_armature_file_list = nil
end

local function remove_self()
	reset_enemy_info()

	if m_anim_timer then
		scheduler.remove(m_anim_timer)
		m_anim_timer = nil
	end
	m_anim_list = nil

	m_dir_list = nil
	m_city_list = nil
	m_boss_list = nil
	m_finish_list = nil

	m_army_offset_list = nil

	m_map_line = nil
	m_map_column = nil
	m_select_land_index = nil

	m_map_widget = nil
end

local function deal_with_land_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if exerciseEffectManager then
			if not exerciseEffectManager.get_enter_state() then
				return
			end
		else
			return
		end

		local point = sender:convertToNodeSpace(uiManager.getLastPoint())
		--相对于1，1坐标系中组件的左下角
		local relative_x = point.x - 0
		local relative_y = point.y - 150
		--print("============== temp_point " .. relative_x .. "/" .. relative_y)
		local coor_x = math.floor(1 + relative_x/200 - (relative_y-50)/100)
		local coor_y = math.floor(1 + relative_x/200 + (relative_y-50)/100)

		if coor_x >=1 and coor_x <= m_map_column and coor_y >=1 and coor_y <= m_map_line then
			local temp_op_type = exerciseData.is_land_can_attack(coor_x, coor_y, m_map_line, m_map_column)
			if temp_op_type == 0 then
				require("game/exercise/exerciseEnemyManager")
				m_select_land_index = (coor_y-1)*m_map_column + coor_x
				exerciseEnemyManager.set_land_index(m_select_land_index)
			elseif temp_op_type == -1 then
				tipsLayer.create(errorTable[503])
			elseif temp_op_type == -2 then
				tipsLayer.create(errorTable[504])
			elseif temp_op_type == -3 then
				tipsLayer.create(errorTable[505])
			end
		end
	end
end

local function get_select_land_index()
	return m_select_land_index
end

local function play_win_first_anim_finish()
	local left_anim = CCMoveBy:create(0.03, ccp(10,0))
	local right_anim = CCMoveBy:create(0.03, ccp(-10,0))
	local top_anim = CCMoveBy:create(0.03, ccp(0,10))
	local bottom_anim = CCMoveBy:create(0.03, ccp(0,-10))
	local temp_array = CCArray:create()
	temp_array:addObject(left_anim)
	temp_array:addObject(right_anim)
	temp_array:addObject(top_anim)
	temp_array:addObject(bottom_anim)
	--local temp_array = {left_anim,right_anim,top_anim,bottom_anim,left_anim:reverse(),right_anim:reverse(),top_anim:reverse(),bottom_anim:reverse()}
	local temp_seq = cc.Sequence:create(temp_array)
	m_map_widget:getParent():runAction(temp_seq)
end

local function play_win_anim()
	for k,v in pairs(m_finish_list) do
		if v[2] == m_select_land_index then
			v[1]:setScale(2)
			local scale_to = CCScaleTo:create(0.08, 1)
			local fun_call = cc.CallFunc:create(play_win_first_anim_finish)
			local temp_seq = cc.Sequence:createWithTwoActions(scale_to, fun_call)
			v[1]:runAction(temp_seq)
			break
		end
	end
end

local function stop_dir_anim()
	for k,v in pairs(m_dir_list) do
		v[1]:stopAllActions()
	end
end

local function play_dir_anim(temp_dir_img, start_x, start_y)
	local end_x = start_x
	local end_y = start_y + 20

	local move_to_1 = CCMoveTo:create(0.5, ccp(end_x, end_y))
	local move_to_2 = CCMoveTo:create(0.5, ccp(start_x, start_y))
	local temp_seq = cc.Sequence:createWithTwoActions(move_to_1, move_to_2)
	local temp_repeat = CCRepeatForever:create(temp_seq)
	temp_dir_img:runAction(temp_repeat)
end

local function reset_table_info(temp_table)
	for k,v in pairs(temp_table) do
		v[1]:setVisible(false)
		v[2] = 0
		v[3] = 0
		v[4] = 0
	end
end

local function reset_map_componment()
	reset_table_info(m_dir_list)
	reset_table_info(m_boss_list)
	reset_table_info(m_city_list)
	reset_table_info(m_finish_list)

	stop_dir_anim()
end

--重置可变的组件显示状态（战胜标示，可以征战状态）
local function reset_active_componment()
	reset_table_info(m_dir_list)
	reset_table_info(m_finish_list)

	stop_dir_anim()
end

--show_type 1 boss字样；2 城市；3 方向指引；4 打下地块
local function set_army_componment_info(show_type, land_index, parent_con, show_pos_x, show_pos_y, show_order)
	local temp_pool_list, temp_base_name = nil, nil
	if show_type == 1 then
		temp_pool_list = m_boss_list
		temp_base_name = "boss_base_img"
	elseif show_type == 2 then
		temp_pool_list = m_city_list
		temp_base_name = "city_base_img"
	elseif show_type == 3 then
		temp_pool_list = m_dir_list
		temp_base_name = "dir_base_img"
	elseif show_type == 4 then
		temp_pool_list = m_finish_list
		temp_base_name = "done_base_img"
	end

	if not temp_base_name then
		return
	end

	local temp_type_sign = nil
	for k,v in pairs(temp_pool_list) do
		if v[2] == 0 then
			temp_type_sign = v[1]
			v[2] = land_index
			v[3] = show_pos_x
			v[4] = show_pos_y
			break
		end
	end

	if not temp_type_sign then
		local base_sign = tolua.cast(parent_con:getChildByName(temp_base_name), "ImageView")
		temp_type_sign = base_sign:clone()
		temp_type_sign:setVisible(false)
		table.insert(temp_pool_list, {temp_type_sign, land_index, show_pos_x, show_pos_y})
		parent_con:addChild(temp_type_sign, show_order)
	end

	temp_type_sign:setPosition(cc.p(show_pos_x, show_pos_y))
	temp_type_sign:setVisible(true)

	if show_type == 3 then
		play_dir_anim(temp_type_sign, show_pos_x, show_pos_y)
	end
end

local function create_qizhi_armature(hero_type, is_boss)
	if is_boss then
		if hero_type == 0 then
			return m_armature_file_list[4]
		elseif hero_type == heroType.archer then
			return m_armature_file_list[5]
		elseif hero_type == heroType.spearman then
			return m_armature_file_list[7]
		else
			return m_armature_file_list[6]
		end
	else
		if hero_type == 0 then
			return m_armature_file_list[8]
		elseif hero_type == heroType.archer then
			return m_armature_file_list[9]
		elseif hero_type == heroType.spearman then
			return m_armature_file_list[11]
		else
			return m_armature_file_list[10]
		end
	end
end

local function create_common_armature_name(hero_type)
	if hero_type == heroType.archer then
		return m_armature_file_list[1]
	elseif hero_type == heroType.spearman then
		return m_armature_file_list[3]
	else
		return m_armature_file_list[2]
	end
end

local function init_enemy_base_show_info(land_index, parent_con, temp_pos_x, temp_pos_y)
	local temp_armature_list = {}
	local temp_base_type, temp_middle_type, temp_front_type = exerciseData.get_exercise_land_army_type(land_index)

	if temp_base_type ~= 0 then
		local temp_base_armature = CCArmature:create(create_common_armature_name(temp_base_type))
		--temp_base_armature:setVisible(false)
		temp_base_armature:setPosition(cc.p(temp_pos_x + m_army_offset_list[3][1], temp_pos_y -150 + m_army_offset_list[3][2]))
		temp_base_armature:setScale(1.2)
		parent_con:addChild(temp_base_armature)
		temp_armature_list[3] = temp_base_armature
	else
		temp_armature_list[3] = 0
	end

	if temp_middle_type ~= 0 then
		local temp_middle_armature = CCArmature:create(create_common_armature_name(temp_middle_type))
		--temp_middle_armature:setVisible(false)
		temp_middle_armature:setPosition(cc.p(temp_pos_x + m_army_offset_list[2][1], temp_pos_y -150 + m_army_offset_list[2][2]))
		temp_middle_armature:setScale(1.2)
		parent_con:addChild(temp_middle_armature)
		temp_armature_list[2] = temp_middle_armature
	else
		temp_armature_list[2] = 0
	end

	local temp_army_type = exerciseData.get_exercise_army_type(land_index)
	local temp_front_armature = CCArmature:create(create_qizhi_armature(temp_front_type, temp_army_type == 2))
	--temp_front_armature:setVisible(false)
	temp_front_armature:setPosition(cc.p(temp_pos_x + m_army_offset_list[1][1], temp_pos_y -150 + m_army_offset_list[1][2]))
	temp_front_armature:setScale(1.2)
	parent_con:addChild(temp_front_armature)
	temp_armature_list[1] = temp_front_armature

	m_enemy_list[land_index] = temp_armature_list
end

local function set_enemy_show_state(land_index, is_die)
	if not m_enemy_list[land_index] then
		return
	end

	if is_die then
		for i=1,3 do
			if m_enemy_list[land_index][i] ~= 0 then
				m_enemy_list[land_index][i]:getAnimation():play("die")
			end
		end
	else
		table.insert(m_anim_list, land_index)
	end
end

local function play_anim_by_index(temp_index)
	if not m_enemy_list[temp_index] then
		return
	end

	for i=1,3 do
		if m_enemy_list[temp_index][i] ~= 0 then
			m_enemy_list[temp_index][i]:getAnimation():play("move")
		end
	end
end

local function play_anim_fun()
	local temp_move_nums = #m_anim_list
	if temp_move_nums == 0 then
		return
	end

	if temp_move_nums == 1 then
		play_anim_by_index(m_anim_list[1])
		return
	end

	if temp_move_nums == 2 then
		play_anim_by_index(m_anim_list[1])
		play_anim_by_index(m_anim_list[2])
		return
	end

	math.randomseed(os.time())
	local first_index = math.random(temp_move_nums)
	local temp_half = math.floor(temp_move_nums/2)
	local second_index = 0
	if first_index + temp_half > temp_move_nums then
		second_index = first_index - temp_half
	else
		second_index = first_index + temp_half
	end

	--[[
	while(true)
	do
		local temp_random_index = math.random(temp_move_nums)
		if temp_random_index ~= first_index then
			second_index = temp_random_index
			break
		end
	end
	--]]

	play_anim_by_index(m_anim_list[first_index])
	play_anim_by_index(m_anim_list[second_index])
end

local function set_city_show_state(land_index, is_finished)
	for k,v in pairs(m_city_list) do
		if v[2] == land_index then
			local content_txt = tolua.cast(v[1]:getChildByName("content_label"), "Label")
			local loading_bar = tolua.cast(v[1]:getChildByName("bar"), "LoadingBar")
			local loading_bg_img = tolua.cast(v[1]:getChildByName("bar_bg_img"), "ImageView")

			if is_finished then
				loading_bg_img:setVisible(false)
				loading_bar:setVisible(false)
				content_txt:setVisible(false)
			else
				local cur_dur = exerciseData.get_land_durability(land_index)
				local all_dur = exerciseData.get_land_all_durability(land_index)
				content_txt:setText(cur_dur .. "/" .. all_dur)
				loading_bar:setPercent(math.floor(100*cur_dur/all_dur))
				loading_bg_img:setVisible(true)
				loading_bar:setVisible(true)
				content_txt:setVisible(true)
			end
			--v[1]:setVisible(true)
			break
		end
	end
end

local function init_land_base_info(i, j)
	local land_index = (i - 1) * m_map_column + j
	local temp_army_id = exerciseData.get_exercise_land_army_id(land_index)

	local land_panel = tolua.cast(m_map_widget:getChildByName("land_panel"), "Layout")
	local temp_panel = tolua.cast(land_panel:getChildByName("panel_" .. j .. "_" .. i), "Layout")
	local top_img = tolua.cast(temp_panel:getChildByName("top_img"), "ImageView")
	local bottom_img = tolua.cast(temp_panel:getChildByName("bottom_img"), "ImageView")

	if temp_army_id == 0 then
		top_img:setVisible(false)
		bottom_img:setVisible(false)
	else
		top_img:setVisible(true)
		bottom_img:setVisible(true)

		local army_panel = tolua.cast(m_map_widget:getChildByName("army_panel"), "Layout")
		local show_pos_x = temp_panel:getPositionX() + 100
		local show_pos_y = temp_panel:getPositionY() + 50
		if exerciseData.is_city_land(land_index) then
			set_army_componment_info(2, land_index, army_panel, show_pos_x, show_pos_y, 1)
		else
			init_enemy_base_show_info(land_index, army_panel, temp_panel:getPositionX(), temp_panel:getPositionY())
			if exerciseData.get_exercise_army_type(land_index) == 2 then
				set_army_componment_info(1, land_index, army_panel, show_pos_x, show_pos_y, 1)
			end
		end
	end
end

local function organize_map_base_info()
	reset_map_componment()
	reset_enemy_info()
	m_enemy_list = {}
	
	for i=1,m_map_line do
		for j=1,m_map_column do
			init_land_base_info(i, j)
		end
	end
end

local function organize_dir_by_index(i, j)
	if exerciseData.is_land_can_attack(j, i, m_map_line, m_map_column) ~= 0 then
		return
	end

	local land_index = (i - 1) * m_map_column + j
	local land_panel = tolua.cast(m_map_widget:getChildByName("land_panel"), "Layout")
	local temp_panel = tolua.cast(land_panel:getChildByName("panel_" .. j .. "_" .. i), "Layout")
	local army_panel = tolua.cast(m_map_widget:getChildByName("army_panel"), "Layout")
	local show_pos_x = temp_panel:getPositionX() + 100
	local show_pos_y = temp_panel:getPositionY() + 50 + 60
	set_army_componment_info(3, land_index, army_panel, show_pos_x, show_pos_y, 3)
end

local function organize_dir_show_info()
	if exerciseData.get_exercise_reward_state() then
		return
	end

	for i=1,m_map_line do
		for j=1,m_map_column do
			organize_dir_by_index(i, j)
		end
	end
end

local function organize_finish_by_index(i, j)
	local land_index = (i - 1) * m_map_column + j
	local temp_army_id = exerciseData.get_exercise_land_army_id(land_index)
	if temp_army_id == 0 then
		return
	end

	local land_panel = tolua.cast(m_map_widget:getChildByName("land_panel"), "Layout")
	local temp_panel = tolua.cast(land_panel:getChildByName("panel_" .. j .. "_" .. i), "Layout")
	local top_img = tolua.cast(temp_panel:getChildByName("top_img"), "ImageView")
	local bottom_img = tolua.cast(temp_panel:getChildByName("bottom_img"), "ImageView")
	local army_panel = tolua.cast(m_map_widget:getChildByName("army_panel"), "Layout")

	local base_pos_x = temp_panel:getPositionX()
	local base_pos_y = temp_panel:getPositionY()
	if exerciseData.is_land_finished(land_index) then
		top_img:loadTexture(ResDefineUtil.exercise_res[11], UI_TEX_TYPE_PLIST)
		bottom_img:loadTexture(ResDefineUtil.exercise_res[10], UI_TEX_TYPE_PLIST)

		if exerciseData.is_city_land(land_index) then
			set_city_show_state(land_index, true)
		else
			set_enemy_show_state(land_index, true)
		end

		set_army_componment_info(4, land_index, army_panel, base_pos_x + 100, base_pos_y + 50, 2)
	else
		top_img:loadTexture(ResDefineUtil.exercise_res[13], UI_TEX_TYPE_PLIST)
		bottom_img:loadTexture(ResDefineUtil.exercise_res[12], UI_TEX_TYPE_PLIST)

		if exerciseData.is_city_land(land_index) then
			set_city_show_state(land_index, false)
		else
			set_enemy_show_state(land_index, false)
		end
	end
end

local function organize_finish_show_info()
	m_anim_list = {}

	for i=1,m_map_line do
		for j=1,m_map_column do
			organize_finish_by_index(i, j)
		end
	end
end

local function add_armature_file()
	m_armature_file_list = {
		"exercise_base_archer", "exercise_base_cavalry", "exercise_base_infantry",
		"exercise_front_single_BOSS","exercise_front_archer_BOSS", "exercise_front_cavalry_BOSS", "exercise_front_infantry_BOSS",
		"exercise_front_single_normal", "exercise_front_archer_normal", "exercise_front_cavalry_normal", "exercise_front_infantry_normal",
		}

	local temp_file_name = nil
	for k,v in pairs(m_armature_file_list) do
		temp_file_name = "gameResources/battle/" .. v .. ".ExportJson"
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(temp_file_name)
	end
end

local function random_map_style()
	math.randomseed(os.time())
	local show_type = math.random(2)
	if show_type == 1 then
		local whole_change_img = tolua.cast(m_map_widget:getChildByName("whole_change_img"), "ImageView")
		whole_change_img:setVisible(false)
	end
end

local function create(parent_con)
	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height
	add_armature_file()

	m_dir_list = {}
	m_boss_list = {}
	m_city_list = {}
	m_finish_list = {}
	m_enemy_list = {}
	m_map_line = 4
	m_map_column = 4
	m_select_land_index = 0
	m_army_offset_list = {{75, 199}, {99, 209}, {123, 219}}

	m_map_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_10.json")
	m_map_widget:setScale(config.getgScale())
	m_map_widget:ignoreAnchorPointForPosition(false)
	m_map_widget:setAnchorPoint(cc.p(0.5,0.5))
	m_map_widget:setPosition(cc.p(scene_width/2, scene_height*3/5))
	m_map_widget:setVisible(false)
	random_map_style()
	parent_con:addChild(m_map_widget)

	local land_panel = tolua.cast(m_map_widget:getChildByName("land_panel"), "Layout")
	land_panel:setTouchEnabled(true)
	land_panel:addTouchEventListener(deal_with_land_click)

	local army_panel = tolua.cast(m_map_widget:getChildByName("army_panel"), "Layout")
	local city_base_img = tolua.cast(army_panel:getChildByName("city_base_img"), "ImageView")
	city_base_img:loadTexture(ResDefineUtil.exercise_res[14], UI_TEX_TYPE_PLIST)
end

local function init_map_show_info()
	organize_map_base_info()
	organize_finish_show_info()
	organize_dir_show_info()

	m_anim_timer = scheduler.create(play_anim_fun, 3)
end

local function deal_with_change_exercise()
	organize_map_base_info()
	organize_finish_show_info()
	organize_dir_show_info()
end

local function deal_with_land_update()
	reset_active_componment()
	organize_finish_show_info()
	organize_dir_show_info()
end

local function get_com_guide_pos()
	for k,v in pairs(m_dir_list) do
		if v[2] ~= 0 then
			return v[1]:getParent():convertToWorldSpace(cc.p(v[3], v[4]-60))
		end
	end

	return ccp(0, 0)
end

local function get_map_widget()
	return m_map_widget
end

exerciseMapManager = {
						create = create,
						remove_self = remove_self,
						remove_resource = remove_resource,
						get_select_land_index = get_select_land_index,
						play_win_anim = play_win_anim,
						get_com_guide_pos = get_com_guide_pos,
						get_map_widget = get_map_widget,
						init_map_show_info = init_map_show_info,
						deal_with_change_exercise = deal_with_change_exercise,
						deal_with_land_update = deal_with_land_update
}