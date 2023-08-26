--根据城市ID设置显示内容
local function get_city_army_base_info(city_id)
	local temp_world_city_info = landData.get_world_city_info(city_id)
	local is_fort = true
	if temp_world_city_info.city_type == cityTypeDefine.zhucheng or temp_world_city_info.city_type == cityTypeDefine.fencheng then
		is_fort = false
	end

	local city_build_effect_info = userCityData.getCityBuildEffectData(city_id)
	local open_army_num, show_army_num = 0, 0
	if is_fort then
		open_army_num = city_build_effect_info.reside_max
		show_army_num = open_army_num
	else
		open_army_num = city_build_effect_info.army_max
		if open_army_num < ARMY_MAX_NUMS_IN_CITY then
			show_army_num = open_army_num + 1
		else
			show_army_num = open_army_num
		end
	end

	return is_fort, open_army_num, show_army_num
end

local function set_unhero_content(army_widget, is_fort, idx, open_army_num)
	--local ditu_img = tolua.cast(army_widget:getChildByName("ditu_img"), "ImageView")
	--ditu_img:loadTexture(ResDefineUtil.army_icon_res[10][2], UI_TEX_TYPE_PLIST)

	local own_hero_panel = tolua.cast(army_widget:getChildByName("own_hero_panel"), "Layout")
	local unown_hero_panel = tolua.cast(army_widget:getChildByName("unown_hero_panel"), "Layout")

	local first_txt = tolua.cast(unown_hero_panel:getChildByName("unopen_sign"), "Label")
	local second_txt = tolua.cast(unown_hero_panel:getChildByName("unopen_label"), "Label")
	if is_fort then
		first_txt:setVisible(false)
		second_txt:setPositionY(67)
		second_txt:setColor(ccc3(166,166,166))
		second_txt:setText(languagePack["weizhushou"])
	else
		if idx > open_army_num then
			first_txt:setVisible(true)
			second_txt:setPositionY(52)
			second_txt:setColor(ccc3(207, 72, 75))
			second_txt:setText(Tb_cfg_build[cityBuildDefine.jiaochang].name .. "Lv." .. idx .. languagePack["kaifang"])
		else
			first_txt:setVisible(false)
			second_txt:setPositionY(67)
			second_txt:setColor(ccc3(166,166,166))
			second_txt:setText(languagePack["weipeizhi"])
		end
	end

	own_hero_panel:setVisible(false)
	unown_hero_panel:setVisible(true)
end

--is_fort_state 用来区分显示当前部队的城市是否是要塞,调动到要塞中的部队在原城市中要灰化（策划新需求）
local function set_hero_content(army_widget, temp_army_id, temp_city_id, is_gray)
	local own_hero_panel = tolua.cast(army_widget:getChildByName("own_hero_panel"), "Layout")
	local unown_hero_panel = tolua.cast(army_widget:getChildByName("unown_hero_panel"), "Layout")

	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	local icon_img = tolua.cast(own_hero_panel:getChildByName("icon_img"), "ImageView")
	local hero_widget = tolua.cast(icon_img:getChildByName("hero_widget"), "Layout")
	local hero_uid = temp_army_info.base_heroid_u
	cardFrameInterface.set_small_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid), false)

	local soldier_num_txt = tolua.cast(own_hero_panel:getChildByName("num_label"), "Label")
	soldier_num_txt:setText(armyData.getTeamHp(temp_army_id))

	--local ditu_img = tolua.cast(army_widget:getChildByName("ditu_img"), "ImageView")
	local state_img = tolua.cast(own_hero_panel:getChildByName("state_img"), "ImageView")
	local icon_state_type = armyData.getTeamStateType(temp_army_id, temp_city_id)
	if icon_state_type == 0 then
		--ditu_img:loadTexture(ResDefineUtil.army_icon_res[10][2], UI_TEX_TYPE_PLIST)
		state_img:setVisible(false)
	else
		state_img:loadTexture(ResDefineUtil.army_icon_res[icon_state_type][1], UI_TEX_TYPE_PLIST)
		state_img:setVisible(true)
		--ditu_img:loadTexture(ResDefineUtil.army_icon_res[icon_state_type][2], UI_TEX_TYPE_PLIST)
	end

	if is_gray then
		if temp_army_info.reside_wid ~= temp_city_id then
			GraySprite.create(army_widget)
		end
	end

	own_hero_panel:setVisible(true)
	unown_hero_panel:setVisible(false)
end

local function set_city_army_content(army_widget, city_id, idx, open_army_num)
	local temp_army_id = city_id * 10 + idx
	local team_info = armyData.getTeamMsg(temp_army_id)
	if team_info and team_info.base_heroid_u ~= 0 then
		set_hero_content(army_widget, temp_army_id, city_id, true)
	else
		set_unhero_content(army_widget, false, idx, open_army_num)
	end
end

local function set_fort_army_content(army_widget, temp_army_id, temp_city_id)
	if temp_army_id == 0 then
		set_unhero_content(army_widget, true, nil, nil)
	else
		set_hero_content(army_widget, temp_army_id, temp_city_id, true)
	end
end

--设置城市中部队内容，实际分布情况（例如进入城市里面显示的那种）
local function set_city_id(temp_widget, city_id, is_city_inner)
	local is_fort, open_army_num, show_army_num = get_city_army_base_info(city_id)
	local fort_army_list = nil
	if is_fort then
		fort_army_list = armyData.getAllArmyInCity(city_id)
	end

	local army_widget = nil
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		army_widget = tolua.cast(temp_widget:getChildByName("army_" .. i), "Layout")
		if i > show_army_num then
			army_widget:setVisible(false)
		else
			if is_fort then
				if fort_army_list[i] then
					set_fort_army_content(army_widget, fort_army_list[i], city_id)
				else
					set_fort_army_content(army_widget, 0, city_id)
				end
			else
				set_city_army_content(army_widget, city_id, i, open_army_num)
			end

			army_widget:setVisible(true)
		end
	end
end

local function set_army_index_content(army_widget, show_index)
	local idx_img = tolua.cast(army_widget:getChildByName("index_img"), "ImageView")
	local idx_txt = tolua.cast(idx_img:getChildByName("num_label"), "Label")
	idx_txt:setText(show_index)
end

--设置城市选择部队的显示情况，例如出征选择等
local function set_army_move_content(temp_widget, city_id, is_need_touch)
	local temp_army_list = armyData.getAllArmyInCity(city_id)
	local is_fort = get_city_army_base_info(city_id)

	local army_widget, own_hero_panel, icon_img, temp_army_id = nil, nil, nil, nil
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		army_widget = tolua.cast(temp_widget:getChildByName("army_" .. i), "Layout")
		if i > #temp_army_list then
			if is_need_touch then
				army_widget:setTouchEnabled(false)
			end
			army_widget:setVisible(false)
		else
			temp_army_id = temp_army_list[i]
			if is_fort then
				set_army_index_content(army_widget, i)
			else
				set_army_index_content(army_widget, temp_army_id%10)
			end

			set_hero_content(army_widget, temp_army_id, city_id, false)

			if is_need_touch then
				army_widget:setTouchEnabled(true)
			end
			army_widget:setVisible(true)

			if not armyData.is_army_can_used(temp_army_id, city_id) then
				own_hero_panel = tolua.cast(army_widget:getChildByName("own_hero_panel"), "Layout")
				icon_img = tolua.cast(own_hero_panel:getChildByName("icon_img"), "ImageView")
				GraySprite.create(icon_img)
			end
		end
	end

	temp_widget:setVisible(true)
end

local function set_army_touch_state(temp_widget, city_id, new_state)
	local is_fort, open_army_num, show_army_num = nil, nil, nil
	local fort_army_list = nil
	if new_state then
		is_fort, open_army_num, show_army_num = get_city_army_base_info(city_id)
		fort_army_list = armyData.getAllArmyInCity(city_id)
	end
	local army_widget = nil
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		army_widget = tolua.cast(temp_widget:getChildByName("army_" .. i), "Layout")
		if new_state then
			if i <= open_army_num then
				if is_fort then
					if i <= #fort_army_list then
						army_widget:setTouchEnabled(true)
					else
						army_widget:setTouchEnabled(false)
					end
				else
					army_widget:setTouchEnabled(true)
				end
			else
				army_widget:setTouchEnabled(false)
			end
		else
			army_widget:setTouchEnabled(false)
		end
	end
end

local function deal_with_city_army_click(temp_city_id, select_index,callback)
	local temp_is_fort= get_city_army_base_info(temp_city_id)
	local temp_army_id = nil
	if temp_is_fort then
		local temp_army_list = armyData.getAllArmyInCity(temp_city_id)
		temp_army_id = temp_army_list[select_index]
	else
		temp_army_id = temp_city_id * 10 + select_index
	end

	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	if temp_army_info then
		if temp_army_info.reside_wid == temp_city_id then
			newGuideInfo.enter_next_guide()
			require("game/army/armyCityOverview/armyWholeManager")
			armyWholeManager.on_enter(temp_city_id, select_index)
		else
			tipsLayer.create(errorTable[305])
		end
	else
		newGuideInfo.enter_next_guide()
		require("game/army/armyCityOverview/armyWholeManager")
		armyWholeManager.on_enter(temp_city_id, select_index,callback)
	end
end

local function create(army_click_event)
	local temp_widget = Layout:create()
	local show_width, show_height = 210, 140
	--temp_widget:setBackGroundColorType(LAYOUT_COLOR_SOLID)
	local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyOverviewUI.json")
	local hero_base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
	local army_widget, hero_widget, hero_panel, icon_img, idx_img, idx_txt = nil, nil, nil, nil, nil, nil
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		army_widget = base_widget:clone()
		army_widget:setName("army_" .. i)
		army_widget:setPosition(cc.p((i-1) * show_width, 0))
		idx_img = tolua.cast(army_widget:getChildByName("index_img"), "ImageView")
		idx_txt = tolua.cast(idx_img:getChildByName("num_label"), "Label")
		idx_txt:setText(i)

		hero_panel = tolua.cast(army_widget:getChildByName("own_hero_panel"), "Layout")
		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		hero_widget = hero_base_widget:clone()
		hero_widget:ignoreAnchorPointForPosition(false)
		hero_widget:setAnchorPoint(cc.p(0.5,0.5))
		hero_widget:setName("hero_widget")
		icon_img:addChild(hero_widget)
		if army_click_event then
			army_widget:addTouchEventListener(army_click_event)
		end
		temp_widget:addChild(army_widget)
	end

	temp_widget:setSize(CCSize(ARMY_MAX_NUMS_IN_CITY * show_width, show_height))
	return temp_widget
end


local function show_army_hero_noEnergy_count_down(temp_widget,city_id)
	if not temp_widget then return end
	if not city_id then return end
	local armyIdList = armyData.getAllArmyInCity(city_id)
	if not armyIdList then return end

	for i = 1, ARMY_MAX_NUMS_IN_CITY do 
		
		local army_widget = tolua.cast(temp_widget:getChildByName("army_" .. i), "Layout")
		local own_hero_panel = tolua.cast(army_widget:getChildByName("own_hero_panel"), "Layout")
		local unown_hero_panel = tolua.cast(army_widget:getChildByName("unown_hero_panel"), "Layout")

		local temp_army_id = armyIdList[i]
		local temp_army_info = armyData.getTeamMsg(temp_army_id)
		local icon_img = tolua.cast(own_hero_panel:getChildByName("icon_img"), "ImageView")
		local hero_widget = tolua.cast(icon_img:getChildByName("hero_widget"), "Layout")
		--cardFrameInterface.set_small_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid), false)

		local count_down_cd = 0
		local show_tips_type = nil
		
		local hero_uid = nil
		for ii = 1,3 do 
			hero_uid = armyData.getHeroIdInTeamAndPos(temp_army_id, ii)
			show_tips_type = heroData.get_hero_state_in_army(hero_uid)
			if temp_army_info and temp_army_info.state == armyState.normal and show_tips_type == heroStateDefine.no_energy then 
				local tmp = heroData.get_hero_energy_moveAble_timeLeft(hero_uid)
				if tmp > count_down_cd then 
					count_down_cd = tmp
				end
			end
		end

		if count_down_cd > 0 then
			cardFrameInterface.set_center_txt_tips(hero_widget, commonFunc.format_time(count_down_cd), true)
		else
			cardFrameInterface.set_center_txt_tips(hero_widget, commonFunc.format_time(count_down_cd), false)
		end
	end
end
armyListCityShare = {
						create = create,
						set_city_id = set_city_id,
						set_army_touch_state = set_army_touch_state,
						show_army_hero_noEnergy_count_down = show_army_hero_noEnergy_count_down,
						get_city_army_base_info = get_city_army_base_info,
						set_army_move_content = set_army_move_content,
						deal_with_city_army_click = deal_with_city_army_click
}
