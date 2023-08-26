local m_layer = nil
local m_main_widget = nil 		--部队信息简化版显示

local m_show_table_view = nil
local m_show_max_num = nil 		--屏幕中显示的列表个数
local m_cell_width = nil
local m_cell_height = nil
local m_dir_height = nil
local m_guodu_height = nil 		--下方显示过度区域高度
local m_content_list = nil 		--所有部队ID列表

local m_click_army_id = nil 	--点击左侧列表中的ID 点击地块是这个值为空
local m_pos_x = nil
local m_pos_y = nil

local m_update_timer = nil
local m_update_list = nil

local m_touch_response_area = nil

local function remove_self(is_force)
	if m_update_timer then
		scheduler.remove(m_update_timer)
		m_update_timer = nil
	end

	if m_layer then
		m_click_army_id = nil
		m_pos_x = nil
		m_pos_y = nil
		m_show_table_view = nil
		m_show_max_num = nil
		m_cell_width = nil
		m_cell_height = nil
		m_dir_height = nil
		m_guodu_height = nil
		m_content_list = nil
		m_update_list = nil
		m_touch_response_area = nil

		if m_main_widget then
			m_main_widget:removeFromParentAndCleanup(true)
			m_main_widget = nil
		end

		if is_force then
			m_layer = nil
		else
			armyListManager.set_new_selected_army_id(0)
		end
	end
end

local function deal_with_animation_finished()
	remove_self(false)
end

local function play_appear_anim()
	local temp_time_num = 0.2
	local move_to = CCMoveTo:create(temp_time_num, ccp(config.getWinSize().width, config.getWinSize().height - SmallMiniMap.get_top_height()))
	local fade_in = CCFadeIn:create(temp_time_num)
	local temp_spawn = CCSpawn:createWithTwoActions(move_to,fade_in)
	m_main_widget:runAction(temp_spawn)
end

local function play_disappear_anim()
	local temp_time_num = 0.2
	local move_to = CCMoveTo:create(temp_time_num, ccp(config.getWinSize().width + m_cell_width * config.getgScale(), config.getWinSize().height - SmallMiniMap.get_top_height()))
	local fade_out = CCFadeOut:create(temp_time_num)
	local temp_spawn = CCSpawn:createWithTwoActions(move_to,fade_out)
	local fun_call = cc.CallFunc:create(deal_with_animation_finished)
	local temp_sep = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
	m_main_widget:runAction(temp_sep)
end

local function show_effect(action_time)
	if not m_main_widget then
		return
	end

	local fade_in = CCFadeIn:create(action_time)
	m_main_widget:runAction(fade_in)
end

local function hide_effect(action_time)
	if not m_main_widget then
		return
	end

	local fade_out = CCFadeOut:create(action_time)
	m_main_widget:runAction(fade_out)
end

-- 0 没有不对具体内容；1 点击到部队内容上面；2 点击到外面
local function deal_with_touch_click(x,y)
	if m_main_widget then
		local touch_panel = tolua.cast(m_main_widget:getChildByName("touch_panel"), "Layout")
		if not touch_panel:hitTest(cc.p(x, y)) then
			remove_self(false)
		end
	end
end

local function is_response_touch_end()
	if uiManager:getLastMoveState() then
		return false
	end

	local content_panel = tolua.cast(m_main_widget:getChildByName("content_panel"), "Layout")
	local touch_pos = content_panel:convertToNodeSpace(uiManager.getLastPoint())

	return m_touch_response_area:containsPoint(touch_pos)
end

local function set_pos_show_position(pos_panel, is_show_btn)
	if is_show_btn then
		pos_panel:setPositionY(50)
	else
		pos_panel:setPositionY(32)
	end
end

local function update_cell_content(idx)
	local cell = m_show_table_view:cellAtIndex(idx)
	if not cell then
		return
	end

	local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local cell_widget = cell_layer:getWidgetByTag(1)
    
    local temp_army_id = m_content_list[idx+1][1]
	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	local army_state = temp_army_info.state

	if army_state == armyState.chuzhenging or army_state == armyState.zhuzhaing or army_state == armyState.yuanjuning then
		if userData.getServerTime() - temp_army_info.begin_time > ARMY_MOVE_CANCEL_INTERVAL then
   			local return_btn = tolua.cast(cell_widget:getChildByName("return_btn"), "Button")
   			return_btn:setBright(false)
   			return_btn:setTitleColor(ccc3(51,51,50))
   			--return_btn:setTouchEnabled(false)
   			--return_btn:setVisible(false)

   			--local pos_panel = tolua.cast(cell_widget:getChildByName("pos_panel"), "Layout")
   			--set_pos_show_position(pos_panel, false)
   		end
	end

	local icon_widget = tolua.cast(cell_widget:getChildByName("icon_widget"), "Layout")
	local hero_panel = tolua.cast(icon_widget:getChildByName("own_hero_panel"), "Layout")
	local icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
	local hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")

	if army_state == armyState.decreed or army_state == armyState.training then
		cardFrameInterface.set_center_txt_tips(hero_widget,commonFunc.format_time(temp_army_info.end_time - userData.getServerTime()),true)
	else
		cardFrameInterface.set_center_txt_tips(hero_widget,"",false)
	end
end

local function update_call_back()
	for k,v in pairs(m_update_list) do
		update_cell_content(v)
	end
end

local function add_update_index(new_index)
	local is_exist = false
	for k,v in pairs(m_update_list) do
		if v == new_index then
			is_exist = true
			break
		end
	end

	if not is_exist then
		table.insert(m_update_list, new_index)
	end
end

--[[
local function set_state_info(con_img, new_state, own_type)
	local bg_img = tolua.cast(con_img:getChildByName("bg_img"), "ImageView")
	local sign_img = tolua.cast(con_img:getChildByName("sign_img"), "ImageView")
	local name_txt = tolua.cast(con_img:getChildByName("name_label"), "Label")

	if own_type == 1 then
		bg_img:loadTexture(ResDefineUtil.army_list_res[2], UI_TEX_TYPE_PLIST)
	elseif own_type == 2 then
		bg_img:loadTexture(ResDefineUtil.army_list_res[1], UI_TEX_TYPE_PLIST)
	else
		bg_img:loadTexture(ResDefineUtil.army_list_res[3], UI_TEX_TYPE_PLIST)
	end

	if new_state == armyState.chuzhenging or new_state == armyState.zhuzhaing 
		or new_state == armyState.yuanjuning or new_state == armyState.returning 
		 then
		sign_img:loadTexture(ResDefineUtil.army_list_res[7], UI_TEX_TYPE_PLIST)
	elseif new_state == armyState.zhuzhaed or new_state == armyState.decreed then
		sign_img:loadTexture(ResDefineUtil.army_list_res[10], UI_TEX_TYPE_PLIST)
	elseif new_state == armyState.yuanjuned then
		sign_img:loadTexture(ResDefineUtil.army_list_res[9], UI_TEX_TYPE_PLIST)
	elseif new_state == armyState.sleeped then
		sign_img:loadTexture(ResDefineUtil.army_list_res[8], UI_TEX_TYPE_PLIST)
	end

	if own_type == 1 then
		name_txt:setColor(ccc3(71, 209, 92))
		name_txt:setText(armySpecialData.get_army_state_name(new_state, false))
	elseif own_type == 2 then
		name_txt:setColor(ccc3(71, 146, 207))
		name_txt:setText(armySpecialData.get_army_state_name(new_state, false))
	elseif own_type == 3 then
		name_txt:setColor(ccc3(248, 94, 80))
		name_txt:setText(armySpecialData.get_army_state_name(new_state, true))
	end
end
--]]

local function set_pos_info(con_panel, start_pos, end_pos)
    local from_img = tolua.cast(con_panel:getChildByName("from_img"), "ImageView")
    local from_txt = tolua.cast(from_img:getChildByName("from_label"), "Label")
    local to_img = tolua.cast(con_panel:getChildByName("to_img"), "ImageView")
    local to_txt = tolua.cast(to_img:getChildByName("to_label"), "Label")
    local dir_img = tolua.cast(con_panel:getChildByName("dir_img"), "ImageView")

    local is_show_start = true
    if start_pos == end_pos then
    	is_show_start = false
    end

    --dir_img:setVisible(is_show_start)

    if is_show_start then
    	local start_x = math.floor(start_pos/10000)
	    local start_y = start_pos%10000
	    local function deal_with_from_click(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
				mapController.setOpenMessage(false)
				mapController.locateCoordinate(start_x, start_y,function() 
					mapController.setOpenMessage(true)
				end)
			end
		end

		from_img:addTouchEventListener(deal_with_from_click)
    	from_img:setTouchEnabled(true)
    	from_txt:setText(start_x .. "," .. start_y)
    else
    	from_img:setTouchEnabled(false)
    	from_txt:setText(languagePack["wenhao_english"] .. "," .. languagePack["wenhao_english"])
    end

	local end_x = math.floor(end_pos/10000)
	local end_y = end_pos%10000
	local function deal_with_to_click(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
			mapController.setOpenMessage(false)
			mapController.locateCoordinate(end_x, end_y,function() 
				mapController.setOpenMessage(true)
			end)
		end
	end

    to_img:addTouchEventListener(deal_with_to_click)
    to_img:setTouchEnabled(true)
    to_txt:setText(end_x .. "," .. end_y)
end

local function reset_icon_info(icon_img, other_panel)
	icon_img:setVisible(false)
	other_panel:setVisible(false)

	local player_btn = tolua.cast(other_panel:getChildByName("player_btn"), "Button")
	local union_btn = tolua.cast(other_panel:getChildByName("union_btn"), "Button")
	player_btn:setTouchEnabled(false)
	union_btn:setTouchEnabled(false)
end

local function get_self_state_res(temp_army_id, temp_army_state)
	if armyData.getTeamZbState(temp_army_id) then
		return ResDefineUtil.army_icon_res[5][1]
	end

	if temp_army_state == armyState.zhuzhaed then
		return ResDefineUtil.army_state_res[5]
	elseif temp_army_state == armyState.yuanjuned then
		return ResDefineUtil.army_state_res[4]
	elseif temp_army_state == armyState.decreed then
		return ResDefineUtil.army_state_res[3]
	elseif temp_army_state == armyState.training then 
		return ResDefineUtil.army_state_res[6]
	elseif temp_army_state == armyState.sleeped then
		return ResDefineUtil.army_state_res[2]
	else
		return ResDefineUtil.army_state_res[1]
	end
end

local function get_friend_state_res(temp_army_state)
	if temp_army_state == armyState.zhuzhaed then
		return ResDefineUtil.army_state_res[15]
	elseif temp_army_state == armyState.yuanjuned then
		return ResDefineUtil.army_state_res[14]
	elseif temp_army_state == armyState.sleeped then
		return ResDefineUtil.army_state_res[12]
	else
		return ResDefineUtil.army_state_res[1]
	end
end

local function get_enemy_state_res(temp_army_state)
	if temp_army_state == armyState.zhuzhaed then
		return ResDefineUtil.army_state_res[25]
	elseif temp_army_state == armyState.yuanjuned then
		return ResDefineUtil.army_state_res[24]
	elseif temp_army_state == armyState.sleeped then
		return ResDefineUtil.army_state_res[22]
	else
		return ResDefineUtil.army_state_res[1]
	end
end

local function set_self_icon_info(cell_widget, temp_army_id)
	local function deal_with_player_click(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
			require("game/army/armyMove/armyLineupManager")
			armyLineupManager.on_enter(temp_army_id, true)
		end
	end

	local icon_widget = tolua.cast(cell_widget:getChildByName("icon_widget"), "Layout")
	local ditu_img = tolua.cast(icon_widget:getChildByName("ditu_img"), "ImageView")
	ditu_img:loadTexture(ResDefineUtil.army_bg_res[2], UI_TEX_TYPE_PLIST)

	local hero_panel = tolua.cast(icon_widget:getChildByName("own_hero_panel"), "Layout")
	local icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
	local other_widget = tolua.cast(icon_img:getChildByName("other_icon"), "Layout")
	local hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")

	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	local hero_uid = temp_army_info.base_heroid_u
	cardFrameInterface.set_small_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid), false)
	
	local state_img = tolua.cast(hero_panel:getChildByName("state_img"), "ImageView")
	state_img:loadTexture(get_self_state_res(temp_army_id, temp_army_info.state), UI_TEX_TYPE_PLIST)

	local soldier_num_txt = tolua.cast(hero_panel:getChildByName("num_label"), "Label")
	soldier_num_txt:setText(armyData.getTeamHp(temp_army_id))

	icon_img:addTouchEventListener(deal_with_player_click)
	icon_img:setTouchEnabled(true)

	other_widget:setVisible(false)
	hero_widget:setVisible(true)
end

local function set_other_icon_info(cell_widget, player_name, temp_army_state, is_enemy)
	local function deal_with_player_click(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
			UIRoleForcesMain.create(nil, player_name)
		end
	end


	local icon_widget = tolua.cast(cell_widget:getChildByName("icon_widget"), "Layout")
	local ditu_img = tolua.cast(icon_widget:getChildByName("ditu_img"), "ImageView")

	local hero_panel = tolua.cast(icon_widget:getChildByName("own_hero_panel"), "Layout")
	local icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
	local hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")
	local other_widget = tolua.cast(icon_img:getChildByName("other_icon"), "Layout")
	local other_bg_img = tolua.cast(other_widget:getChildByName("bg_img"), "ImageView")
	local state_img = tolua.cast(hero_panel:getChildByName("state_img"), "ImageView")
	if is_enemy then
		other_bg_img:loadTexture(ResDefineUtil.army_bg_res[5], UI_TEX_TYPE_PLIST)
		ditu_img:loadTexture(ResDefineUtil.army_bg_res[3], UI_TEX_TYPE_PLIST)

		state_img:loadTexture(get_enemy_state_res(temp_army_state), UI_TEX_TYPE_PLIST)
	else
		other_bg_img:loadTexture(ResDefineUtil.army_bg_res[4], UI_TEX_TYPE_PLIST)
		ditu_img:loadTexture(ResDefineUtil.army_bg_res[1], UI_TEX_TYPE_PLIST)

		state_img:loadTexture(get_friend_state_res(temp_army_state), UI_TEX_TYPE_PLIST)
	end

	local name_txt = tolua.cast(other_widget:getChildByName("name_label"), "Label")
	name_txt:setText(player_name)

	local soldier_num_txt = tolua.cast(hero_panel:getChildByName("num_label"), "Label")
	soldier_num_txt:setText("????")

	icon_img:addTouchEventListener(deal_with_player_click)
	icon_img:setTouchEnabled(true)

	other_widget:setVisible(true)
	hero_widget:setVisible(false)
end

local function reset_op_info(return_btn, immediate_btn)
	return_btn:setTitleColor(ccc3(83,18,0))
	return_btn:setTouchEnabled(false)
	return_btn:setVisible(false)

	immediate_btn:setTouchEnabled(false)
	immediate_btn:setVisible(false)
end

local function organize_self_content(cell_widget, idx)
	local temp_army_id = m_content_list[idx+1][1]
	local temp_army_info = armyData.getTeamMsg(temp_army_id)
	local army_state = temp_army_info.state

	set_self_icon_info(cell_widget, temp_army_id)

	local pos_panel = tolua.cast(cell_widget:getChildByName("pos_panel"), "Layout")
	if army_state == armyState.returning then
		set_pos_info(pos_panel, temp_army_info.target_wid, temp_army_info.reside_wid)
	elseif army_state == armyState.zhuzhaed then
		set_pos_info(pos_panel, math.floor(temp_army_id/10), temp_army_info.target_wid)
	else
		set_pos_info(pos_panel, temp_army_info.reside_wid, temp_army_info.target_wid)
	end

	local return_btn = tolua.cast(cell_widget:getChildByName("return_btn"), "Button")
	local immediate_btn = tolua.cast(cell_widget:getChildByName("immediate_btn"), "Button")
	reset_op_info(return_btn, immediate_btn)
	
	local is_show_btn = false
	if army_state == armyState.returning then
		local function return_atonce_event()
			armyOpRequest.requestBackAtOnce(temp_army_id)
		end

		local function deal_with_immediate_click(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
				if userData.getYuanbao() < ARMY_BACK_IMMEDIATELY_COST_YUANBAO then
					alertLayer.create(errorTable[16])
				else
					-- alertLayer.create(errorTable[18], {ARMY_BACK_IMMEDIATELY_COST_YUANBAO}, return_atonce_event)
					return_atonce_event()
				end
			end
		end

		immediate_btn:setTouchEnabled(true)
		immediate_btn:addTouchEventListener(deal_with_immediate_click)
		immediate_btn:setVisible(true)
		is_show_btn = true
	elseif army_state == armyState.sleeped or army_state == armyState.zhuzhaed or army_state == armyState.yuanjuned then
		local function deal_with_return_click(sender, eventType)
    		if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
    			if armyData.getTeamZbState(temp_army_id) then
    				tipsLayer.create(errorTable[310])
    			else
    				alertLayer.create(errorTable[302], {}, function ( )
						armyOpRequest.requestBack(temp_army_id)
					end)
    			end
    		end
    	end
		return_btn:setTouchEnabled(true)
		return_btn:addTouchEventListener(deal_with_return_click)
		return_btn:setBright(not armyData.getTeamZbState(temp_army_id))
		return_btn:setVisible(true)
		is_show_btn = true
	elseif  army_state == armyState.decreed then
		return_btn:setTouchEnabled(true)
		return_btn:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then 
				-- armyOpRequest.requestBack(temp_army_id)
				alertLayer.create(errorTable[302], {}, function ( )
					armyOpRequest.requestBack(temp_army_id)
				end)
			end
		end)
		return_btn:setVisible(true)
		add_update_index(idx)
		update_cell_content(idx)
		is_show_btn = true
	elseif  army_state == armyState.training then
		return_btn:setTouchEnabled(true)
		return_btn:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then 
				alertLayer.create(errorTable[2014], {}, function ( )
					armyOpRequest.requestBack(temp_army_id)
				end)
			end
		end)
		return_btn:setVisible(true)
		add_update_index(idx)
		update_cell_content(idx)
		is_show_btn = true
	elseif army_state == armyState.chuzhenging or army_state == armyState.zhuzhaing or army_state == armyState.yuanjuning then
		local function cancel_move_event()
			if  landData.get_land_type( temp_army_info.reside_wid ) == cityTypeDefine.yaosai  
				and army_state == armyState.zhuzhaing 
				and (not armyData.isHasResidePosInFort(temp_army_info.reside_wid)) then 
				tipsLayer.create(languagePack["army_move_tips_cannot_reside"])
				return 
			end
			armyOpRequest.requestCancel(temp_army_id)
		end

		local function deal_with_second_return_click(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED and is_response_touch_end() then
				if userData.getServerTime() - temp_army_info.begin_time <= ARMY_MOVE_CANCEL_INTERVAL then
					if userData.isInNewBieProtection() then 
						alertLayer.create(errorTable[2007], {}, cancel_move_event)
					else
						alertLayer.create(errorTable[17], {}, cancel_move_event)
					end
				else
					tipsLayer.create(errorTable[307], nil, {ARMY_MOVE_CANCEL_INTERVAL/60})
				end
			end
		end

		if userData.getServerTime() - temp_army_info.begin_time <= ARMY_MOVE_CANCEL_INTERVAL then
			add_update_index(idx)
			return_btn:setBright(true)
		else
			return_btn:setBright(false)
			return_btn:setTitleColor(ccc3(51,51,50))
		end

		return_btn:setTouchEnabled(true)
		return_btn:addTouchEventListener(deal_with_second_return_click)
		return_btn:setVisible(true)
		is_show_btn = true
	end

	set_pos_show_position(pos_panel, is_show_btn)
end

local function organize_field_other_content(cell_widget, idx)
	local temp_army_id = m_content_list[idx+1][1]
	local temp_army_own = m_content_list[idx+1][2]

	local temp_army_info = nil
	local pos_panel = tolua.cast(cell_widget:getChildByName("pos_panel"), "Layout")
	--区分敌袭与其他的
	if temp_army_own == 3 then
		if m_content_list[idx+1][3] then
			temp_army_info = armyData.getAssaultTeamMsg(temp_army_id)
			set_pos_info(pos_panel, temp_army_info.from_wid, temp_army_info.to_wid)
		else
			temp_army_info = mapData.getFieldArmyMsgByArmyId(temp_army_id)
			set_pos_info(pos_panel, temp_army_info.wid_from, temp_army_info.wid_to)
		end
		set_other_icon_info(cell_widget, temp_army_info.user_name, temp_army_info.state, true)
	else
		temp_army_info = mapData.getFieldArmyMsgByArmyId(temp_army_id)
		set_pos_info(pos_panel, temp_army_info.wid_from, temp_army_info.wid_to)
		set_other_icon_info(cell_widget, temp_army_info.user_name, temp_army_info.state, false)
	end

	local return_btn = tolua.cast(cell_widget:getChildByName("return_btn"), "Button")
	local immediate_btn = tolua.cast(cell_widget:getChildByName("immediate_btn"), "Button")
	reset_op_info(return_btn, immediate_btn)

	set_pos_show_position(pos_panel, false)
end

local function show_cell_content(cell_widget, idx)
	local temp_own_type = m_content_list[idx+1][2]

	if temp_own_type == 1 then
		organize_self_content(cell_widget, idx)
	else
		organize_field_other_content(cell_widget, idx)
	end	
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyComplexCell.json")
		local immediate_btn = tolua.cast(new_widget:getChildByName("immediate_btn"), "Button")
		local gold_txt = tolua.cast(immediate_btn:getChildByName("label_gold"), "Label")
		gold_txt:setText(ARMY_BACK_IMMEDIATELY_COST_YUANBAO)

		local icon_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyOverviewUI.json")
		local ditu_img = tolua.cast(icon_widget:getChildByName("ditu_img"), "ImageView")
		ditu_img:setPositionY(66)

		local unhero_panel = tolua.cast(icon_widget:getChildByName("unown_hero_panel"), "Layout")
		unhero_panel:setVisible(false)
		local index_img = tolua.cast(icon_widget:getChildByName("index_img"), "ImageView")
		index_img:setVisible(false)

		local hero_panel = tolua.cast(icon_widget:getChildByName("own_hero_panel"), "Layout")
		local icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")

		local hero_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
		hero_widget:ignoreAnchorPointForPosition(false)
		hero_widget:setAnchorPoint(cc.p(0.5,0.5))
		--hero_widget:setPosition(cc.p(-1, 4))
		hero_widget:setName("hero_icon")
		icon_img:addChild(hero_widget)

		local other_widget = GUIReader:shareReader():widgetFromJsonFile("test/otherArmyUI.json")
		other_widget:ignoreAnchorPointForPosition(false)
		other_widget:setAnchorPoint(cc.p(0.5,0.5))
		--hero_widget:setPosition(cc.p(-1, 4))
		other_widget:setName("other_icon")
		icon_img:addChild(other_widget)

		icon_widget:setName("icon_widget")
		icon_widget:setPosition(cc.p(0, 10))
		new_widget:addChild(icon_widget)
	    new_widget:setTag(1)
	    local new_layer = TouchGroup:create() 
	    new_layer:setTag(123)
	    new_layer:addWidget(new_widget)
	    cell = CCTableViewCell:new()
	    cell:addChild(new_layer)
	end
    
    local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local cell_widget = cell_layer:getWidgetByTag(1)
    show_cell_content(cell_widget, idx)
    
    return cell
end

local function tableCellTouched(table,cell)
	--print("==============" .. cell:getIdx())
end

local function cellSizeForTable(table,idx)
    return m_cell_height, m_cell_width
end

local function numberOfCellsInTableView(table)
	return #m_content_list
end

local function scrollViewDidScroll(view)
	if #m_content_list <= m_show_max_num then
		return
	end
	
    local up_img = tolua.cast(m_main_widget:getChildByName("up_img"), "ImageView")
	local down_img = tolua.cast(m_main_widget:getChildByName("down_img"), "ImageView")
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

local function reload_data()
	if not m_update_timer then
		m_update_timer = scheduler.create(update_call_back, 1)
	end

	m_update_list = {}
	m_show_table_view:reloadData()

	local temp_nums = #m_content_list
	local up_img = tolua.cast(m_main_widget:getChildByName("up_img"), "ImageView")
	local down_img = tolua.cast(m_main_widget:getChildByName("down_img"), "ImageView")
	local guodu_img = tolua.cast(m_main_widget:getChildByName("detail_guodu_img"), "ImageView")
	local touch_panel = tolua.cast(m_main_widget:getChildByName("touch_panel"), "Layout")
	if temp_nums > m_show_max_num then
		up_img:setVisible(false)
		down_img:setVisible(true)
		guodu_img:setVisible(true)

		touch_panel:setSize(CCSizeMake(m_cell_width, m_cell_height * m_show_max_num))
		touch_panel:setPositionY(m_dir_height)
		touch_panel:setTouchEnabled(true)

		m_show_table_view:setBounceable(true)
	else
		up_img:setVisible(false)
		down_img:setVisible(false)
		guodu_img:setVisible(false)

		touch_panel:setSize(CCSizeMake(m_cell_width, m_cell_height * temp_nums))
		touch_panel:setPositionY(m_dir_height + m_cell_height * (m_show_max_num - temp_nums))
		touch_panel:setTouchEnabled(true)

		m_show_table_view:setBounceable(false)
	end
end

local function init_widget()
	if m_main_widget then
		return
	end
	
	if CityListOwnedAndMarked then 
		CityListOwnedAndMarked.closeDirectlly()
	end

	m_show_max_num = 2
	m_cell_width = 378
	m_cell_height = 150
	m_dir_height = 16
	m_guodu_height = 56

	local temp_max_height = m_dir_height * 2 + m_cell_height * m_show_max_num
	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/simpleTVUI.json")
	m_main_widget:setSize(CCSizeMake(m_cell_width, temp_max_height))
	m_main_widget:ignoreAnchorPointForPosition(false)
	m_main_widget:setAnchorPoint(cc.p(1, 1))
	m_main_widget:setScale(config.getgScale())
	m_main_widget:setPosition(cc.p(config.getWinSize().width + m_cell_width*config.getgScale(), config.getWinSize().height - SmallMiniMap.get_top_height()))

	local up_img = tolua.cast(m_main_widget:getChildByName("up_img"), "ImageView")
	local down_img = tolua.cast(m_main_widget:getChildByName("down_img"), "ImageView")
	up_img:setPosition(cc.p(m_cell_width/2, temp_max_height - m_dir_height/2))
	down_img:setPosition(cc.p(m_cell_width/2, m_dir_height/2))
	local guodu_img = tolua.cast(m_main_widget:getChildByName("detail_guodu_img"), "ImageView")
	guodu_img:setPosition(cc.p(m_cell_width/2, m_guodu_height/2))

	local init_size = CCSizeMake(m_cell_width, m_cell_height * m_show_max_num)
	local content_panel = tolua.cast(m_main_widget:getChildByName("content_panel"), "Layout")
	content_panel:setSize(init_size)
	m_show_table_view = CCTableView:create(init_size)
	content_panel:addChild(m_show_table_view)
	m_show_table_view:setDirection(kCCScrollViewDirectionVertical)
	m_show_table_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_show_table_view:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    m_show_table_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    m_show_table_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_show_table_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_show_table_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    m_touch_response_area = m_show_table_view:boundingBox()

	m_layer:addWidget(m_main_widget)

	play_appear_anim()

	breathAnimUtil.start_scroll_dir_anim(up_img, down_img)
end

-- 点击具体部队显示的信息
local function set_army_info(army_info)
	if m_main_widget then
		return
	end
	
	if m_click_army_id == army_info[1] then
		return
	end

	m_click_army_id = army_info[1]
	init_widget()

	m_content_list = {army_info}
	reload_data()
end

local function detect_is_need_show_army(pos_x, pos_y)
	if m_pos_x == pos_x and m_pos_y == pos_y then
		return false
	end

	local m_content_list = armyListAssist.get_list_in_pos(pos_x, pos_y)
	if #m_content_list == 0 then
		return false
	end
	return true
end
-- 点击地块，需要自己组织该地块上的部队信息
local function set_land_pos(pos_x, pos_y,needLocate)
	--if m_main_widget then
		--remove_self(false)
	--end

	if m_pos_x == pos_x and m_pos_y == pos_y then
		return false
	end

	m_content_list = armyListAssist.get_list_in_pos(pos_x, pos_y)
	if #m_content_list == 0 then
		if m_main_widget then
			remove_self(false)
		end

		return false
	end

	m_pos_x = pos_x
	m_pos_y = pos_y
	if needLocate then 
		mapController.locateCoordinate(m_pos_x, m_pos_y,nil,100 * config.getgScale(),0)
	end

	if not m_main_widget then
		init_widget()
	end
	
	reload_data()

	return true
end

local function create(con_layer)
	m_layer = con_layer
end

local function deal_with_self_army_update(new_id)
	if not m_main_widget then
		return
	end

	if m_click_army_id then
		if m_click_army_id == new_id then
			local temp_army_info = armyData.getTeamMsg(new_id)
			if temp_army_info.state == armyState.normal then
				remove_self(false)
			else
				reload_data()
			end
		end
	else
		m_content_list = armyListAssist.get_list_in_pos(m_pos_x, m_pos_y)
		if #m_content_list == 0 then
			remove_self(false)
		else
			reload_data()
		end
	end
end

--敌袭
local function deal_with_enemy_army_update()
	if not m_main_widget then
		return
	end

	if m_click_army_id then
		local temp_army_info = armyData.getAssaultTeamMsg(m_click_army_id)
		if temp_army_info then
			reload_data()
		else
			remove_self(false)
		end
	else
		m_content_list = armyListAssist.get_list_in_pos(m_pos_x, m_pos_y)
		if #m_content_list == 0 then
			remove_self(false)
		else
			reload_data()
		end
	end
end

--视野内他人部队信息改变
local function deal_with_other_army_update()
	if not m_main_widget then
		return
	end

	if m_click_army_id then
		local temp_army_info = mapData.getFieldArmyMsgByArmyId(m_click_army_id)
		if temp_army_info then
			reload_data()
		else
			remove_self(false)
		end
	else
		m_content_list = armyListAssist.get_list_in_pos(m_pos_x, m_pos_y)
		if #m_content_list == 0 then
			remove_self(false)
		else
			reload_data()
		end
	end
end

armyListDetail = {
					create = create,
					remove_self = remove_self,
					deal_with_touch_click = deal_with_touch_click,
					set_army_info = set_army_info,
					set_land_pos = set_land_pos,
					detect_is_need_show_army = detect_is_need_show_army,
					show_effect = show_effect,
					hide_effect = hide_effect,
					play_disappear_anim = play_disappear_anim,
					deal_with_self_army_update = deal_with_self_army_update,
					deal_with_enemy_army_update = deal_with_enemy_army_update,
					deal_with_other_army_update = deal_with_other_army_update
}
