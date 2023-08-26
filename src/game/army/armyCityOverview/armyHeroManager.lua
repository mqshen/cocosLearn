local m_main_widget = nil
local m_widget_list = nil 			--部队各个位置组件的列表
local m_soldier_list_in_scene = nil --场景中的部队列表
local m_pos_list = nil 				--部队中卡牌显示位置坐标信息
local m_soldier_offset_y = nil 		--部队出现位置相对于卡牌的偏移值
local m_default_color = nil 		--兵力文本默认颜色
local m_need_anim_list = nil 		--预备兵引导
local m_anim_finish_state = nil 	--用来标示是否已经有了触发动画结束的状态

local m_time_state = nil 			--卡牌上显示倒计时的含义
local m_timer = nil

local m_is_playing_anim = nil

local function remove()
	if m_timer then
		scheduler.remove(m_timer)
		m_timer = nil
	end

	for k,v in pairs(m_soldier_list_in_scene) do
		if v ~= 0 then
			v:removeFromParentAndCleanup(true)
		end
	end
	m_soldier_list_in_scene = nil

	m_is_playing_anim = nil
	m_pos_list = nil
	m_time_state = nil
	m_default_color = nil
	m_need_anim_list = nil
	m_anim_finish_state = nil

	m_soldier_offset_y = nil
	m_widget_list = nil
	m_main_widget = nil
end

local function init_card_panel_pos()
	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	m_pos_list = {}
	m_pos_list[1] = {scene_width * 0.22, scene_height * 0.3}
	m_pos_list[2] = {scene_width * 0.45, scene_height * 0.41}
	m_pos_list[3] = {scene_width * 0.67, scene_height * 0.52}
end

local function deal_with_icon_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getParent():getName(),6))
		local temp_army_id = armyWholeManager.get_army_id()
		local hero_uid = armyData.getHeroIdInTeamAndPos(temp_army_id, select_index)
		if hero_uid == 0 then
			if select_index == 1 or select_index == 2 then
				armyWholeManager.deal_with_enter_set()
			else
				local army_owned_city_id = math.floor(temp_army_id/10)
				local army_owned_index = temp_army_id%10
				local temp_army_nums, temp_qianfeng_nums = buildData.get_army_param_info(army_owned_city_id)
				if temp_qianfeng_nums >= army_owned_index then
					armyWholeManager.deal_with_enter_set()
				end
			end
		else
			require("game/cardDisplay/userCardViewer")
			userCardViewer.create(nil,hero_uid)
		end
	end
end

local function organize_pos_base_content(hero_index, icon_img, is_unopen, army_index)
	local add_sign_1 = tolua.cast(icon_img:getChildByName("add_sign_1"), "ImageView")
	local add_sign_2 = tolua.cast(icon_img:getChildByName("add_sign_2"), "ImageView")
	local unopen_sign_1 = tolua.cast(icon_img:getChildByName("unopen_sign"), "ImageView")
	local unopen_sign_2 = tolua.cast(icon_img:getChildByName("cond_label"), "Label")

	if is_unopen then
		add_sign_1:setVisible(false)
		add_sign_2:setVisible(false)
		unopen_sign_1:setVisible(true)
		unopen_sign_2:setText(Tb_cfg_build[cityBuildDefine.dianjiangtai].name .. "Lv." .. army_index .. languagePack["function_open"])
		unopen_sign_2:setVisible(true)
	else
		local is_need_anim = false
		if hero_index == 3 then
			local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[10])
			if show_sign == 0 then
				if armyData.getHeroIdInTeamAndPos(armyWholeManager.get_army_id(), hero_index) == 0 then
					is_need_anim = true
				else
					CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[10], 1)
				end
			end
		end

		if is_need_anim then
			add_sign_1:setVisible(false)
			add_sign_2:setVisible(false)
			unopen_sign_1:setVisible(true)
			unopen_sign_2:setText(Tb_cfg_build[cityBuildDefine.dianjiangtai].name .. "Lv." .. army_index .. languagePack["function_open"])
			unopen_sign_2:setVisible(true)

			local function deal_with_second_anim_finish()
				local temp_need_time = 0.3
			    local light_img = nil
			    for i=1,2 do
		            light_img = tolua.cast(icon_img:getChildByName("light_" .. i), "ImageView")
		            breathAnimUtil.start_anim(light_img, false, 0, 128, temp_need_time, 1)

		            light_img:setScale(1)
		            if i == 1 then
		            	light_img:runAction(CCScaleTo:create(temp_need_time, 1.4))
		            else
		            	light_img:runAction(CCScaleTo:create(temp_need_time, 1.05))
		            end
		            light_img:setVisible(true)
		        end
			end

			local function deal_with_first_anim_finish()
				add_sign_1:runAction(CCFadeIn:create(0.4))
				local fun_call_2 = cc.CallFunc:create(deal_with_second_anim_finish)
				local temp_seq_2 = cc.Sequence:createWithTwoActions(CCFadeIn:create(0.4), fun_call_2)
				add_sign_2:runAction(temp_seq_2)
				add_sign_1:setVisible(true)
				add_sign_2:setVisible(true)
			end

			local temp_spawn_1 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.4, 1.8), CCFadeOut:create(0.4))
			unopen_sign_1:runAction(temp_spawn_1)
			local temp_spawn_2 = CCSpawn:createWithTwoActions(CCScaleTo:create(0.4, 1.1), CCFadeOut:create(0.4))
			local fun_call_1 = cc.CallFunc:create(deal_with_first_anim_finish)
			local temp_seq_1 = cc.Sequence:createWithTwoActions(temp_spawn_2, fun_call_1)
			unopen_sign_2:runAction(temp_seq_1)

			CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[10], 1)
		else
			add_sign_1:setVisible(true)
			add_sign_2:setVisible(true)
			unopen_sign_1:setVisible(false)
			unopen_sign_2:setVisible(false)
		end
	end
end

local function organize_soldier_hp_content(soldier_img, hero_uid)
	if hero_uid == 0 then
		soldier_img:setVisible(false)
	else
		local hero_info = heroData.getHeroInfo(hero_uid)
		if hero_info.state == cardState.zhengbing then
			local own_hp_txt = tolua.cast(soldier_img:getChildByName("own_hp_label"), "Label")
			local add_hp_txt = tolua.cast(soldier_img:getChildByName("add_hp_label"), "Label")
			own_hp_txt:setText(hero_info.hp)
			add_hp_txt:setText("+" .. hero_info.hp_adding)
			add_hp_txt:setPositionX(own_hp_txt:getPositionX() + own_hp_txt:getContentSize().width)

			soldier_img:setVisible(true)
		else
			soldier_img:setVisible(false)
		end
	end
end

local function organize_hero_content(hero_widget, hero_uid, index)
	local is_need_timer = false
	if m_soldier_list_in_scene[index] ~= 0 then
		m_soldier_list_in_scene[index]:removeFromParentAndCleanup(true)
	end

	if hero_uid == 0 then
		cardFrameInterface.reset_middle_card_info(hero_widget)
		hero_widget:setVisible(false)
		m_soldier_list_in_scene[index] = 0
	else		
		local hero_info = heroData.getHeroInfo(hero_uid)
		cardFrameInterface.set_middle_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid))
		local show_tips_type = heroData.get_hero_state_in_army(hero_uid)
		cardFrameInterface.set_hero_state(hero_widget, 2, show_tips_type)
		hero_widget:setVisible(true)
		
		local show_time_num = 0
		if show_tips_type == heroStateDefine.zengbing then
			m_time_state[index] = 1
			show_time_num = hero_info.hp_end_time - userData.getServerTime()
		elseif show_tips_type == heroStateDefine.hurted then
			m_time_state[index] = 2
			show_time_num = hero_info.hurt_end_time - userData.getServerTime()
		elseif show_tips_type == heroStateDefine.no_energy then
			m_time_state[index] = 3
			show_time_num = heroData.get_hero_energy_moveAble_timeLeft(hero_uid)
		end

		if show_time_num > 0 then
			cardFrameInterface.set_hero_tips_content(hero_widget, 2, commonFunc.format_time(show_time_num), true)
			is_need_timer = true
		end

		local param_table = {}
		param_table.position = index
		param_table.heroid = heroData.getHeroOriginalId(hero_uid)
		param_table.army = hero_info.hp
		local show_batchnode = BattleArmyPos.returnOneArmyPos(param_table)
		if armyWholeManager.get_current_stage() == 1 then
			show_batchnode:setPosition(cc.p(m_pos_list[index][1], m_pos_list[index][2] - m_soldier_offset_y))
		else
			show_batchnode:setPosition(cc.p(m_pos_list[index][1], m_pos_list[3][2] - m_soldier_offset_y))
		end
		m_main_widget:addChild(show_batchnode, -1)
		m_soldier_list_in_scene[index] = show_batchnode
	end

	return is_need_timer
end

local function update_time_content()
	local temp_army_id = armyWholeManager.get_army_id()
	local hero_panel, icon_img, hero_widget = nil, nil, nil
	local hero_uid, hero_info, show_time_num = nil, nil, nil
	local current_time = userData.getServerTime()
	for k,v in pairs(m_time_state) do
		if v ~= 0 then
			hero_panel = m_widget_list[k]
			icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
			hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")
			hero_uid = armyData.getHeroIdInTeamAndPos(temp_army_id, k)
			hero_info = heroData.getHeroInfo(hero_uid)

			show_time_num = 0
			if v == 1 then
				show_time_num = hero_info.hp_end_time - current_time
			elseif v == 2 then
				show_time_num = hero_info.hurt_end_time - current_time
			elseif v == 3 then
				show_time_num = heroData.get_hero_energy_moveAble_timeLeft(hero_uid)
			end

			if show_time_num > 0 then
				cardFrameInterface.set_hero_tips_content(hero_widget, 2, commonFunc.format_time(show_time_num), true)
			else
				cardFrameInterface.set_hero_tips_content(hero_widget, 2, commonFunc.format_time(0), false)
			end
		end
	end
end

local function organize_show_content()
	local temp_army_id = armyWholeManager.get_army_id()
	local army_owned_city_id = math.floor(temp_army_id/10)
	local army_owned_index = temp_army_id%10
	local temp_army_nums, temp_qianfeng_nums = buildData.get_army_param_info(army_owned_city_id)
	
	m_time_state = {0, 0, 0}
	local hero_panel, icon_img, hero_widget, soldier_img = nil, nil, nil, nil
	local hero_uid, is_need_timer = 0, false
	for i=1,3 do
		hero_panel = m_widget_list[i]
		hero_uid = armyData.getHeroIdInTeamAndPos(temp_army_id, i)

		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		if i == 3 and temp_qianfeng_nums < army_owned_index then
			organize_pos_base_content(i, icon_img, true, army_owned_index)
		else
			organize_pos_base_content(i, icon_img, false, army_owned_index)
		end

		hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")
		if organize_hero_content(hero_widget, hero_uid, i) then
			is_need_timer = true
		end

		soldier_img = tolua.cast(hero_panel:getChildByName("soldier_img"), "ImageView")
		organize_soldier_hp_content(soldier_img, hero_uid)
	end

	if is_need_timer then
		if not m_timer then
			m_timer = scheduler.create(update_time_content, 1)
		end
	else
		if m_timer then
			scheduler.remove(m_timer)
			m_timer = nil
		end
	end
end

local function create(temp_widget)
	require("game/battle/battleArmyPos")
	m_main_widget = temp_widget
	init_card_panel_pos()
	m_soldier_list_in_scene = {0, 0, 0}
	m_soldier_offset_y = 50
	m_is_playing_anim = false

	m_widget_list = {}
	local hero_base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	local hero_panel, icon_img, hero_widget = nil, nil, nil
	for i=1,3 do
		hero_panel = tolua.cast(m_main_widget:getChildByName("hero_" .. i), "Layout")
		hero_panel:setPosition(cc.p(m_pos_list[i][1], m_pos_list[i][2]))

		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		icon_img:addTouchEventListener(deal_with_icon_click)
		icon_img:setTouchEnabled(true)

		hero_widget = hero_base_widget:clone()
		hero_widget:ignoreAnchorPointForPosition(false)
		hero_widget:setAnchorPoint(cc.p(0.5,0.5))
		hero_widget:setName("hero_icon")
		icon_img:addChild(hero_widget)

		table.insert(m_widget_list, hero_panel)
	end
end

local function deal_with_build_change()
	local temp_army_id = armyWholeManager.get_army_id()
	local army_owned_city_id = math.floor(temp_army_id/10)
	local army_owned_index = temp_army_id%10
	local temp_army_nums, temp_qianfeng_nums = buildData.get_army_param_info(army_owned_city_id)
	
	local hero_panel, icon_img = nil, nil
	for i=1,3 do
		hero_panel = m_widget_list[i]

		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		if i == 3 and temp_qianfeng_nums < army_owned_index then
			organize_pos_base_content(i, icon_img, true, army_owned_index)
		else
			organize_pos_base_content(i, icon_img, false, army_owned_index)
		end
	end
end

local function deal_with_zb_anim_finish()
	for i=1,3 do
		local hero_panel = m_widget_list[i]
		local icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		local hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")
		local hp_txt = cardFrameInterface.get_hp_txt(hero_widget, 2)
		hp_txt:setColor(m_default_color)
	end

	newGuideInfo.enter_next_guide()
	m_anim_finish_state = false
end

local function play_zb_anim(index)
	local hero_panel = m_widget_list[index]
	local icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
	local hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")
	local hp_txt = cardFrameInterface.get_hp_txt(hero_widget, 2)
	if not m_default_color then
		local temp_color = hp_txt:getColor()
		m_default_color = ccc3(temp_color.r, temp_color.g, temp_color.b)
	end
	hp_txt:setColor(ccc3(0,255,0))

	local first_scale_to = CCScaleTo:create(0.1, 6)
	local second_scale_to = CCScaleTo:create(0.4, 1)
	local temp_seq = nil
	if m_anim_finish_state then
		temp_seq = cc.Sequence:createWithTwoActions(first_scale_to, second_scale_to)
	else
		local fun_call = cc.CallFunc:create(deal_with_zb_anim_finish)
		local temp_array = CCArray:create()
		temp_array:addObject(first_scale_to)
		temp_array:addObject(second_scale_to)
		temp_array:addObject(fun_call)
		temp_seq = cc.Sequence:create(temp_array)
		m_anim_finish_state = true
	end

	hp_txt:runAction(temp_seq)
end

local function play_zb_guide_anim()
	if m_main_widget then
		play_zb_anim(1)
		play_zb_anim(2)
	end
end

local function play_ybb_anim()
	if not m_need_anim_list then
		return
	end
	
	for k,v in pairs(m_need_anim_list) do
		play_zb_anim(v)
	end

	m_need_anim_list = nil
end

local function set_anim_list(temp_list)
	m_need_anim_list = temp_list
end

local function on_enter_anim_finish()
	local hero_panel, icon_img = nil, nil
	for i=1,3 do
		hero_panel = m_widget_list[i]
		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		icon_img:setTouchEnabled(false)
	end

	m_is_playing_anim = false
	newGuideInfo.enter_next_guide()
end

local function play_enter_anim(move_index)
	local temp_move_time = 0.2

	local hero_panel = m_widget_list[move_index]
	local move_to_1 = CCMoveTo:create(temp_move_time, ccp(m_pos_list[move_index][1], m_pos_list[3][2]))
	if move_index == 2 then
		local fun_call = cc.CallFunc:create(on_enter_anim_finish)
		local temp_seq = cc.Sequence:createWithTwoActions(move_to_1, fun_call)
		hero_panel:runAction(temp_seq)
	else
		hero_panel:runAction(move_to_1)
	end
	
	if m_soldier_list_in_scene[move_index] ~= 0 then
		local move_to_2 = CCMoveTo:create(temp_move_time, ccp(m_pos_list[move_index][1], m_pos_list[3][2] - m_soldier_offset_y))
		m_soldier_list_in_scene[move_index]:runAction(move_to_2)
	end
end

local function deal_with_enter_set()
	m_is_playing_anim = true
	play_enter_anim(1)
	play_enter_anim(2)
end

local function on_leave_anim_finish()
	local hero_panel, icon_img = nil, nil
	for i=1,3 do
		hero_panel = m_widget_list[i]
		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		icon_img:setTouchEnabled(true)
	end

	m_is_playing_anim = false
	newGuideInfo.enter_next_guide()
end

local function play_leave_anim(move_index)
	local temp_move_time = 0.2

	local hero_panel = m_widget_list[move_index]
	local move_to_1 = CCMoveTo:create(temp_move_time, ccp(m_pos_list[move_index][1], m_pos_list[move_index][2]))
	if move_index == 2 then
		local fun_call = cc.CallFunc:create(on_leave_anim_finish)
		local temp_seq = cc.Sequence:createWithTwoActions(move_to_1, fun_call)
		hero_panel:runAction(temp_seq)
	else
		hero_panel:runAction(move_to_1)
	end
	
	if m_soldier_list_in_scene[move_index] ~= 0 then
		local move_to_2 = CCMoveTo:create(temp_move_time, ccp(m_pos_list[move_index][1], m_pos_list[move_index][2] - m_soldier_offset_y))
		m_soldier_list_in_scene[move_index]:runAction(move_to_2)
	end
end

local function deal_with_leave_set()
	m_is_playing_anim = true
	play_leave_anim(1)
	play_leave_anim(2)
end

local function is_play_anim()
	return m_is_playing_anim
end

armyHeroManager = {
					create = create,
					remove = remove,
					organize_show_content = organize_show_content,
					is_play_anim = is_play_anim,
					play_zb_guide_anim = play_zb_guide_anim,
					set_anim_list = set_anim_list,
					play_ybb_anim = play_ybb_anim,
					deal_with_enter_set = deal_with_enter_set,
					deal_with_leave_set = deal_with_leave_set,
					deal_with_build_change = deal_with_build_change
}