local m_share_guide_obj = nil 		--引导显示相关类实例

local m_touch_group = nil
local m_bg_layer = nil

local m_guide_id = nil
local m_last_guide_id = nil 		--上一个引导ID
local m_last_leave_id = nil

local m_wait_state = nil
local m_is_began_correct_area = nil

local m_is_loading_ui = nil
local m_report_nums = nil 					--最后两次出征引导到达产生战报的计数

local function remove()
	if m_touch_group then
		m_share_guide_obj:remove()
		m_share_guide_obj = nil

		m_guide_id = nil
		m_last_guide_id = nil
		m_last_leave_id = nil
		m_is_loading_ui = nil
		m_report_nums = nil
		m_wait_state = nil
		m_is_began_correct_area = nil

		m_bg_layer = nil
		m_touch_group = nil

		UIUpdateManager.remove_prop_update(dbTableDesList.report_attack.name, dataChangeType.add, newGuideInfo.deal_with_report_update)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.add, newGuideInfo.deal_with_call_add)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_world_event.name, dataChangeType.update, newGuideInfo.update_word_event)
		UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, newGuideInfo.deal_with_army_update)
	end
end

local function is_need_dialog_anim(temp_dialog_id)
	local temp_need_anim = nil

	if m_last_guide_id == 0 then
		temp_need_anim = true
	else
		local last_guide_info = guide_cfg_info[m_last_guide_id]
		if last_guide_info.dialog_id == 0 then
			temp_need_anim = true
		else
			local temp_dialog_info = dialog_cfg_info[temp_dialog_id]
			local last_dialog_info = dialog_cfg_info[last_guide_info.dialog_id]
			if last_dialog_info.npc_state == temp_dialog_info.npc_state then
				if temp_dialog_info.npc_state == 0 then
					temp_need_anim = false
				else
					if temp_dialog_info.icon_name == last_dialog_info.icon_name then
						temp_need_anim = false
					else
						temp_need_anim = true
					end
				end
			else
				temp_need_anim = true
			end
		end
	end

	return temp_need_anim
end

local function create()
	if m_touch_group then
		return
	end

	m_guide_id = 0
	m_last_guide_id = 0
	m_last_leave_id = 0
	m_is_loading_ui = false
	m_report_nums = 0

	local win_size = config.getWinSize()
	m_bg_layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 128), win_size.width, win_size.height)
	newGuideManager.add_content_panel(m_bg_layer)

	m_share_guide_obj = guideShowShare.new()
	local temp_widget = m_share_guide_obj:create(1)

    m_touch_group = TouchGroup:create()
    m_touch_group:addWidget(temp_widget)
	newGuideManager.add_content_panel(m_touch_group)

	m_share_guide_obj:reset_componment()

	UIUpdateManager.add_prop_update(dbTableDesList.report_attack.name, dataChangeType.add, newGuideInfo.deal_with_report_update)
	UIUpdateManager.add_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.add, newGuideInfo.deal_with_call_add)
	UIUpdateManager.add_prop_update(dbTableDesList.user_world_event.name, dataChangeType.update, newGuideInfo.update_word_event)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, newGuideInfo.deal_with_army_update)
end

local function stop_special_anim()
	local temp_widget = m_touch_group:getWidgetByTag(999)
	local finger_img = tolua.cast(temp_widget:getChildByName("finger_img"), "ImageView")
	finger_img:stopAllActions()
	finger_img:setVisible(false)
end

local function play_army_set_anim()
	local temp_widget = m_touch_group:getWidgetByTag(999)
	local finger_img = tolua.cast(temp_widget:getChildByName("finger_img"), "ImageView")

	local mask_img_1 = tolua.cast(temp_widget:getChildByName("mask_img_1"), "ImageView")
	local mask_img_2 = tolua.cast(temp_widget:getChildByName("mask_img_2"), "ImageView")

	local first_pos_x = mask_img_1:getPositionX() + 48
	local first_pos_y = mask_img_1:getPositionY() - 40

	local second_pos_x = mask_img_2:getPositionX() + 48
	local second_pos_y = mask_img_2:getPositionY() - 40

	finger_img:setPosition(cc.p(first_pos_x, first_pos_y))
	local move_to_1 = CCMoveTo:create(1.2, ccp(second_pos_x, second_pos_y))
	local move_to_2 = CCMoveTo:create(0.05, ccp(first_pos_x, first_pos_y))
	local temp_seq = cc.Sequence:createWithTwoActions(move_to_1, move_to_2)
	local temp_repeat = CCRepeatForever:create(temp_seq)
	finger_img:runAction(temp_repeat)
	finger_img:setVisible(true)
end

local function play_zb_special_anim()
	local temp_widget = m_touch_group:getWidgetByTag(999)
	local finger_img = tolua.cast(temp_widget:getChildByName("finger_img"), "ImageView")

	local hit_img = tolua.cast(temp_widget:getChildByName("hit_img"), "ImageView")

	local first_pos_x = hit_img:getPositionX() - hit_img:getSize().width/2 + 48
	local first_pos_y = hit_img:getPositionY() - 40

	local second_pos_x = hit_img:getPositionX() + hit_img:getSize().width/2 + 48
	local second_pos_y = hit_img:getPositionY() - 40

	finger_img:setPosition(cc.p(first_pos_x, first_pos_y))
	local move_to_1 = CCMoveTo:create(1.5, ccp(second_pos_x, second_pos_y))
	local move_to_2 = CCMoveTo:create(0.05, ccp(first_pos_x, first_pos_y))
	local temp_seq = cc.Sequence:createWithTwoActions(move_to_1, move_to_2)
	local temp_repeat = CCRepeatForever:create(temp_seq)
	finger_img:runAction(temp_repeat)
	finger_img:setVisible(true)
end

local function play_special_anim()
	if m_guide_id == guide_id_list.CONST_GUIDE_1009 or m_guide_id == guide_id_list.CONST_GUIDE_1090 
		or m_guide_id == guide_id_list.CONST_GUIDE_1036 or m_guide_id == guide_id_list.CONST_GUIDE_1121 then
		play_army_set_anim()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1058 or m_guide_id == guide_id_list.CONST_GUIDE_1059 then
		play_zb_special_anim()
	end
end

local function deal_with_enter_guide_event()
	if m_guide_id == guide_id_list.CONST_GUIDE_1025 then
		BattleAnimationController.addFirstGuideLine()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1026 then
		BattleAnimationController.addSecondGuideLine()
	end

	play_special_anim()
end

local function load_guide_info()
	m_wait_state = false
	m_share_guide_obj:reset_componment()
	m_share_guide_obj:reset_param()
	
	local temp_guide_info = guide_cfg_info[m_guide_id]
	if temp_guide_info.bg_state == 0 then
		m_bg_layer:setVisible(false)
	else
		m_bg_layer:setVisible(true)
	end

	local temp_dialog_id = temp_guide_info.dialog_id
	if temp_dialog_id ~= 0 then
		m_share_guide_obj:set_dialog_info(temp_dialog_id, is_need_dialog_anim(temp_dialog_id))
	end

	m_share_guide_obj:set_guide_id(m_guide_id)

	newGuideManager.set_stencil(m_share_guide_obj:get_stencil())
	newGuideManager.set_visible(true)

	deal_with_enter_guide_event()

	m_is_loading_ui = false
end

--[[
	说明 地图》手指》框选
	确认手指动画和框选效果是互斥的，所以用一个定位的列去标示位置
	地图配置的话出现的为手指点击效果，但是该情况只读取手指的方向配置，位置信息由地图部分获取
	目前针对配置的可穿透处理的情况也是只有一个可穿透区域，获取方式参照上方规则
	关于说明文字出现的区域也是跟随上面规则的 
	如果框选的有多个只取第一个作为参考对象
--]]
local function set_guide_id(temp_id)
	print("=====================" .. temp_id)
	--CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	m_is_loading_ui = true

	m_last_guide_id = m_guide_id
	m_guide_id = temp_id

	local temp_guide_info = guide_cfg_info[m_guide_id]
	if temp_guide_info.wait_ui_load == 0 then
		load_guide_info()
	end
end

local function is_can_move_card(new_pos)
	local move_state = true
	if m_guide_id == guide_id_list.CONST_GUIDE_1009 or m_guide_id == guide_id_list.CONST_GUIDE_1090 then
		if new_pos ~= 1 then
			move_state = false
		end
	end

	if m_guide_id == guide_id_list.CONST_GUIDE_1036 or m_guide_id == guide_id_list.CONST_GUIDE_1121 then
		if new_pos ~= 2 then
			move_state = false
		end
	end

	return move_state
end

local function is_can_second_fight()
	local main_city_id = userData.getMainPos()
	local city_x = math.floor(main_city_id/10000)
	local city_y = main_city_id%10000

	local temp_team_info = armyData.getTeamMsg(main_city_id * 10 + 1)
	if temp_team_info.state == armyState.normal then
		return mapData.isSelfLand(city_x + guide_map_order[7][1], city_y + guide_map_order[7][2])
	else
		return true
	end
end

--哎，真是蛋疼的东西，非强制引导里面有些需要强制引导，跟原来的设计都有冲突，算了先这样吧
--现在的东西在wait_ui_load， ui_wait_state这两个字段配置不合理的情况下会出现死循环，没时间改了
local function deal_with_ui_loaded(ui_index)
	if not newGuideInfo.is_in_guide_state() then
		return
	end

	local temp_guide_info = guide_cfg_info[m_guide_id]
	if m_is_loading_ui then
		if uiIndexDefine[temp_guide_info.ui_id_name] == ui_index then
			load_guide_info()
			return
		end
	end

	--因为战报动画的UI加载有些时间上的差距，所以进入下一步的引导由其他地方触发
	if ui_index == uiIndexDefine.BATTLA_ANIMATION_UI then
		return
	end

	local next_guide_info = guide_cfg_info[temp_guide_info.next_guide_id]
	--临时方案，针对卡引导的情况
	if temp_guide_info.hit_state == 9 then
		if uiIndexDefine[next_guide_info.ui_id_name] == ui_index then
			newGuideInfo.enter_next_guide()
		end
	else
		if not m_wait_state then
			return
		end
		
		if uiIndexDefine[next_guide_info.ui_id_name] == ui_index then
			set_guide_id(temp_guide_info.next_guide_id)
			m_wait_state = false
		end
	end
end

--进入下一个指引前需要的特殊处理
local function deal_with_leave_guide_event()
	if m_last_leave_id == m_guide_id then
		return
	end

	m_share_guide_obj:stop_finger_anim()

	local main_city_id = userData.getMainPos()
	local city_x = math.floor(main_city_id/10000)
	local city_y = main_city_id%10000

	if m_guide_id == guide_id_list.CONST_GUIDE_1004 then
		require("game/guide/newGuide/guideCardAnim")
		guideCardAnim.play_get_card_anim(INIT_HERO)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1005 or m_guide_id == guide_id_list.CONST_GUIDE_1032 
		or m_guide_id == guide_id_list.CONST_GUIDE_1055 or m_guide_id == guide_id_list.CONST_GUIDE_1082 then
		--mapMessageUI.moveAndEnter(city_x, city_y)
		mapController.touchGroundCallback(city_x, city_y, 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1014 then
		mapController.touchGroundCallback(city_x + guide_map_order[1][1], city_y + guide_map_order[1][2], 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1041 then
		mapController.touchGroundCallback(city_x + guide_map_order[2][1], city_y + guide_map_order[2][2], 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1047 then
		mapController.touchGroundCallback(city_x + guide_map_order[3][1], city_y + guide_map_order[3][2], 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1066 then
		mapController.touchGroundCallback(city_x + guide_map_order[4][1], city_y + guide_map_order[4][2], 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1072 then
		mapController.touchGroundCallback(city_x + guide_map_order[2][1], city_y + guide_map_order[2][2], 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1096 then
		mapController.touchGroundCallback(city_x + guide_map_order[6][1], city_y + guide_map_order[6][2], 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1101 then
		mapController.touchGroundCallback(city_x + guide_map_order[7][1], city_y + guide_map_order[7][2], 0 , 0)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1105 then
		if is_can_second_fight() then
			mapController.touchGroundCallback(city_x + guide_map_order[8][1], city_y + guide_map_order[8][2], 0 , 0)
		end
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1025 then
		BattleAnimationController.removeFirstGuideLine()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1026 then
		BattleAnimationController.removeSecondGuideLine()
		BattleAnalyse.analyseAnimation()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1051 then
		BattleAnalyse.analyseAnimation()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1027 then
		require("game/guide/newGuide/guideTipsManager")
		guideTipsManager.create(1)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1028 then
		require("game/guide/newGuide/guideCardAnim")
		guideCardAnim.play_get_card_anim(100039)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1052 then
		--刷贼兵资源
		require("game/guide/newGuide/guideResAnim")
		guideResAnim.create()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1063 then
		require("game/guide/newGuide/guideWaitingManager")
		guideWaitingManager.create(guide_waiting_list.ZHENGBING)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1045 then
		require("game/guide/newGuide/guideTipsManager")
		guideTipsManager.create(2)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1070 then
		detailReport.remove_self()
		reportUI.remove_self()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1087 then
		buildMsgManager.remove_self()
		buildTreeManager.remove_self()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1110 then
		require("game/guide/newGuide/guideCreateRoleAnim")
		guideCreateRoleAnim.create()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1111 then
		require("game/guide/newGuide/guideTargetAnim")
		guideTargetAnim.create()
	end

	m_share_guide_obj:stop_alpha_anim()

	m_last_leave_id = m_guide_id
end

local function deal_with_zb_guide()
	if m_guide_id == guide_id_list.CONST_GUIDE_1058 then
		if cardAddSoldier.is_enough_zb_guide(1) then
			newGuideInfo.enter_next_guide()
		else
			play_special_anim()
		end
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1059 then
		if cardAddSoldier.is_enough_zb_guide(2) then
			newGuideInfo.enter_next_guide()
		else
			play_special_anim()
		end
	end
end

local function deal_with_guide_finish()
	if m_guide_id == guide_id_list.CONST_GUIDE_1113 then
		mainOption.setTaskTipsVisible(true)
		userData.dailyFirstLogin(true)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_3004 then
		local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[2])
		if show_sign == 0 then
			comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2014)
			CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[2], 1)
		end
	elseif m_guide_id == guide_id_list.CONST_GUIDE_3006 then
		comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2015)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_3007 then
		exerciseWholeManager.deal_with_select_guide()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_3034 then
		reportUI.removeUnForceGuide()
	end
	

	--[[
	local main_city_id = userData.getMainPos()
	local city_x = math.floor(main_city_id/10000)
	local city_y = main_city_id%10000
	mapController.setOpenMessage(false)
	mapController.locateCoordinate(city_x, city_y,function() 
					mapController.setOpenMessage(true)
				end)
	--]]
end

local function deal_with_touch_began(x, y)
	--[[
		hit_state含义  	0 点击任意地方都会消失触发下一条引导（吞噬）；
						1 点击第一块引导区域，穿透处理并且触发下一条引导
						2 点击第一块引导区域，穿透处理但是不触发下一条引导 例如：抽卡刷新列表
						3 可以点击任意地方，不触发下一条引导（不吞噬）例如：出身卡牌选择
						4 点击第一块引导区域，不穿透但触发下一条引导（吞噬）例如：选择出征地块

						9 临时类型，特殊处理按钮相关的吧，穿透但不触发
	--]]

	if m_guide_id == 0 then
		return false
	end

	if m_share_guide_obj:is_playing_anim() then
		return true
	end
	
	if m_wait_state then
		return true
	end
	
	if m_is_loading_ui then
		return true
	end
	
	local tunshi_result = nil
	local temp_widget = m_touch_group:getWidgetByTag(999)
	local temp_hit_img = tolua.cast(temp_widget:getChildByName("hit_img"), "ImageView")

	local temp_guide_info = guide_cfg_info[m_guide_id]
	local temp_hit_state = temp_guide_info.hit_state
	if temp_hit_state == 0 then
		tunshi_result = true
		m_is_began_correct_area = true
	elseif temp_hit_state == 1 then
		if temp_hit_img:isVisible() and temp_hit_img:hitTest(cc.p(x, y)) then
			tunshi_result = false
			m_is_began_correct_area = true
		else
			tunshi_result = true
			m_is_began_correct_area = false
		end
	elseif temp_hit_state == 2 then
		if temp_hit_img:isVisible() and temp_hit_img:hitTest(cc.p(x, y)) then
			tunshi_result = false
			m_is_began_correct_area = true

			--征兵的特殊动画管理特殊处理
			if m_guide_id == guide_id_list.CONST_GUIDE_1058 or m_guide_id == guide_id_list.CONST_GUIDE_1059 then
				stop_special_anim()
			end
		else
			tunshi_result = true
			m_is_began_correct_area = false
		end
	elseif temp_hit_state == 3 then
		tunshi_result = false
		m_is_began_correct_area = false
	elseif temp_hit_state == 4 then
		if temp_hit_img:isVisible() and temp_hit_img:hitTest(cc.p(x, y)) then
			m_is_began_correct_area = true
		else
			m_is_began_correct_area = false
		end
		tunshi_result = true
	elseif temp_hit_state == 9 then
		if temp_hit_img:isVisible() and temp_hit_img:hitTest(cc.p(x, y)) then
			tunshi_result = false
		else
			tunshi_result = true
		end
		m_is_began_correct_area = false
	end

	return tunshi_result
end

local function deal_with_touch_ended(x, y)
	if m_guide_id == 0 then
		return
	end

	if m_share_guide_obj:is_playing_anim() then
		return
	end

	if m_wait_state then
		if BattleAnimationController and BattleAnimationController.getInstance() then
			if BattleAnimationController.cannotTouchWhenNewGuide(x, y) then
				tipsLayer.create(errorTable[510])
			end
		end
		return
	end

	if m_is_loading_ui then
		return
	end

	if not m_is_began_correct_area then
		return
	end

	local is_next_state = nil
	local temp_widget = m_touch_group:getWidgetByTag(999)
	local temp_hit_img = tolua.cast(temp_widget:getChildByName("hit_img"), "ImageView")

	local temp_guide_info = guide_cfg_info[m_guide_id]
	local temp_hit_state = temp_guide_info.hit_state
	if temp_hit_state == 0 then
		is_next_state = true
	elseif temp_hit_state == 1 then
		if temp_hit_img:isVisible() and temp_hit_img:hitTest(cc.p(x, y)) then
			is_next_state = true
		else
			is_next_state = false
		end
	elseif temp_hit_state == 2 then
		is_next_state = false
	elseif temp_hit_state == 3 then
		is_next_state = false
	elseif temp_hit_state == 4 then
		is_next_state = true
	elseif temp_hit_state == 9 then
		is_next_state = false
	end

	if is_next_state then
		newGuideManager.set_visible(false)
		if temp_guide_info.next_guide_id == 0 then
			deal_with_leave_guide_event()
			deal_with_guide_finish()
			m_guide_id = 0
		else
			if temp_guide_info.ui_wait_state == 0 then
				deal_with_leave_guide_event()
				set_guide_id(temp_guide_info.next_guide_id)
			else
				m_wait_state = true
				deal_with_leave_guide_event()
			end
		end
	end

	--因为增兵部分的控件不能注册TOUCH事件（执行会报错），所以对于增兵的引导要特殊处理
	deal_with_zb_guide()
end

--前面已经触发了进入下一个的等待状态，玩家做某个操作触发出来，统一处理为如果当前指引的下一个指引等于我要触发的，则显示下一个指引
local function enter_next_guide()
	if not newGuideInfo.is_in_guide_state() then
		return
	end

	local temp_guide_info = guide_cfg_info[m_guide_id]
	if temp_guide_info.next_guide_id == 0 then
		newGuideManager.set_visible(false)
		deal_with_leave_guide_event()
		m_guide_id = 0
		return
	end

	if m_wait_state then
		set_guide_id(temp_guide_info.next_guide_id)
		m_wait_state = false
	else
		newGuideManager.set_visible(false)
		if temp_guide_info.ui_wait_state == 0 then
			deal_with_leave_guide_event()
			set_guide_id(temp_guide_info.next_guide_id)
		else
			m_wait_state = true
			deal_with_leave_guide_event()
		end
	end
end

--直接播放战报动画的回调
local function enter_battle_anim()
	if m_guide_id == guide_id_list.CONST_GUIDE_1044 then
		BattleAnalyse.analyseAnimation()
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1017 or m_guide_id == guide_id_list.CONST_GUIDE_1050 then
		enter_next_guide()
	end
end

local function deal_with_report_update(packet)
	if m_guide_id == guide_id_list.CONST_GUIDE_1017 then
		OpenBattleAnimation.create(true, false, enter_battle_anim)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1044 then
		OpenBattleAnimation.create(true, false, enter_battle_anim)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1050 then
		OpenBattleAnimation.create(true, false, enter_battle_anim)
	elseif m_guide_id == guide_id_list.CONST_GUIDE_1069 then
		require("game/guide/newGuide/guideTipsManager")
		guideTipsManager.create(4)
	elseif m_guide_id > guide_id_list.CONST_GUIDE_1104 then
		require("game/guide/newGuide/guideTipsManager")
		if m_report_nums == 0 then
			guideTipsManager.create(7)
		elseif m_report_nums == 1 then
			guideTipsManager.create(8)
		end
		m_report_nums = m_report_nums + 1
	end
end

local function deal_with_call_add(packet)
	if m_guide_id == guide_id_list.CONST_GUIDE_1075 then
		require("game/guide/newGuide/guideCallAnim")
		guideCallAnim.create()
	end
end

local function deal_with_army_update(packet)
	if m_guide_id == guide_id_list.CONST_GUIDE_1099 and m_wait_state then
		local temp_army_id = userData.getMainPos() * 10 + 2
		local temp_army_info = armyData.getTeamMsg(temp_army_id)
		if temp_army_info.state == armyState.normal and (not guideExpAnim.is_playing()) then
			enter_next_guide()
		end
	end
end

--地表事件监听
local function update_word_event(packet)
	if m_guide_id == guide_id_list.CONST_GUIDE_1099 then
		require("game/guide/newGuide/guideExpAnim")
		guideExpAnim.create()
	end
end

local function enter_for_interrupt(temp_guide_phase)
	if temp_guide_phase == 7 then
		m_report_nums = 1
	end
	set_guide_id(guide_exit_game_list[temp_guide_phase])
end

local function is_in_guide_state()
	if m_guide_id then
		if m_guide_id == 0 then
			return false
		else
			return true
		end
	else
		return false
	end
end

newGuideInfo = {
					create = create,
					remove = remove,
					set_guide_id = set_guide_id,
					enter_for_interrupt = enter_for_interrupt,
					is_in_guide_state = is_in_guide_state,
					is_can_move_card = is_can_move_card,
					enter_next_guide = enter_next_guide,
					play_special_anim = play_special_anim,
					stop_special_anim = stop_special_anim,
					deal_with_touch_began = deal_with_touch_began,
					deal_with_touch_ended = deal_with_touch_ended,
					deal_with_ui_loaded = deal_with_ui_loaded,
					deal_with_report_update = deal_with_report_update,
					enter_battle_anim = enter_battle_anim,
					deal_with_call_add = deal_with_call_add,
					update_word_event = update_word_event,
					deal_with_army_update = deal_with_army_update
}