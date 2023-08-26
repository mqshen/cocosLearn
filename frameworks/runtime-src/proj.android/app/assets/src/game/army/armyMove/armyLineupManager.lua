local army_lineup_layer = nil
local show_army_id = nil
local show_army_state = nil

local m_time_state = nil 			--卡牌上显示倒计时的含义  1征兵 2重伤 3 疲劳
local m_timer = nil

local function do_remove_self()
	if army_lineup_layer then
		if m_timer then
			scheduler.remove(m_timer)
			m_timer = nil
		end

		show_army_id = nil
		show_army_state = nil
		army_lineup_layer:removeFromParentAndCleanup(true)
		army_lineup_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.ARMY_LIENUP_UI)
		if armyMoveManager then
			armyMoveManager.set_des_show_state(true)
		end
	end
end

local function remove_self()
	if army_lineup_layer then
		uiManager.hideConfigEffect(uiIndexDefine.ARMY_LIENUP_UI, army_lineup_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not army_lineup_layer then
		return false
	end

	local temp_widget = army_lineup_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_close_click(sender, eventType) 
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function set_unhero_content(hero_panel, is_only_unset, temp_army_index)
	local hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
	local unhero_img = tolua.cast(hero_panel:getChildByName("unhero_img"), "ImageView")

	local first_txt = tolua.cast(unhero_img:getChildByName("unopen_sign"), "Label")
	local second_txt = tolua.cast(unhero_img:getChildByName("unopen_label"), "Label")
	if is_only_unset then
		first_txt:setVisible(false)
		second_txt:setPositionY(0)
		second_txt:setColor(ccc3(166,166,166))
		second_txt:setText(languagePack["weipeizhi"])
	else
		first_txt:setVisible(true)
		second_txt:setPositionY(-14)
		second_txt:setColor(ccc3(207, 72, 75))
		second_txt:setText(Tb_cfg_build[cityBuildDefine.dianjiangtai].name .. "Lv." .. temp_army_index .. languagePack["kaifang"])
	end

	hero_img:setVisible(false)
	unhero_img:setVisible(true)
end

local function set_hero_content(hero_panel, hero_uid)
	

	local hero_widget = tolua.cast(hero_img:getChildByName("hero_widget"), "Layout")
	cardFrameInterface.set_small_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid), false)
	local show_tips_type = heroData.get_hero_state_in_army(hero_uid)
	cardFrameInterface.set_hero_state(hero_widget, 3, show_tips_type)
	
	hero_img:setVisible(true)
	unhero_img:setVisible(false)
end

local function organize_hero_content(hero_widget, hero_uid, index)
	local is_need_timer = false
	
	local hero_info = heroData.getHeroInfo(hero_uid)
	cardFrameInterface.set_small_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid), false)
	show_tips_type = heroData.get_hero_state_in_army(hero_uid)
	cardFrameInterface.set_hero_state(hero_widget, 3, show_tips_type)

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

	if show_time_num ~= 0 then
		cardFrameInterface.set_hero_tips_content(hero_widget, 2, commonFunc.format_time(show_time_num), true)
		is_need_timer = true
	end

	return is_need_timer
end

local function update_time_content()
	if not army_lineup_layer then return end
	local temp_widget = army_lineup_layer:getWidgetByTag(999)
	local hero_panel, icon_img, hero_widget = nil, nil, nil
	local hero_uid, hero_info, show_time_num = nil, nil, nil
	local current_time = userData.getServerTime()
	for i = 1, 3 do 
		for k,v in pairs(m_time_state) do
			if v ~= 0 then
				hero_panel = tolua.cast(temp_widget:getChildByName("hero_" .. i), "ImageView")
				hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
				hero_widget = hero_img:getChildByName("hero_widget")
				hero_uid = armyData.getHeroIdInTeamAndPos(show_army_id, i)

				if hero_uid ~= 0 then
					show_tips_type = heroData.get_hero_state_in_army(hero_uid)
					cardFrameInterface.set_hero_state(hero_widget, 3, show_tips_type)

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
						cardFrameInterface.set_center_txt_tips(hero_widget, commonFunc.format_time(show_time_num), true)
					else
						cardFrameInterface.set_center_txt_tips(hero_widget, commonFunc.format_time(show_time_num), false)
					end
				end
			end
		end
	end
end

local function organize_show_content(temp_widget,show_army_id)
	local army_info = armyData.getTeamMsg(show_army_id)
	local temp_army_nums, temp_front_nums = buildData.get_army_param_info(math.floor(show_army_id/10))

	m_time_state = {0, 0, 0}

	local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
	local hero_panel, hero_img, unhero_img, hero_widget = nil, nil, nil, nil
	local hero_uid, show_tips_type = nil, nil
	local is_need_timer = false
	for i=1,3 do
		hero_panel = tolua.cast(temp_widget:getChildByName("hero_" .. i), "ImageView")

		hero_uid = armyData.getHeroIdInTeamAndPos(show_army_id, i)
		if hero_uid == 0 then
			if i == 3 and show_army_id%10 > temp_front_nums then
				set_unhero_content(hero_panel, false, show_army_id%10)
			else
				set_unhero_content(hero_panel, true, 0)
			end
		else
			hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
			unhero_img = tolua.cast(hero_panel:getChildByName("unhero_img"), "ImageView")
			unhero_img:setVisible(false)
			hero_widget = base_widget:clone()
			hero_widget:ignoreAnchorPointForPosition(false)
			hero_widget:setAnchorPoint(cc.p(0.5,0.5))
			hero_img:addChild(hero_widget)
			hero_widget:setName("hero_widget")
			if organize_hero_content(hero_widget,hero_uid,i) then 
				is_need_timer = true
			end
			
		end
	end

	local hero_min_speed, temp_army_speed = armyData.getTeamSpeed(show_army_id)
	local speed_txt = tolua.cast(temp_widget:getChildByName("speed_label"), "Label")
	speed_txt:setText(math.floor(temp_army_speed/100))

	local temp_army_destroy = armyData.getTeamDestroy(show_army_id)
	local destroy_txt = tolua.cast(temp_widget:getChildByName("destroy_label"), "Label")
	destroy_txt:setText(math.floor(temp_army_destroy/100))

	local people_label = tolua.cast(temp_widget:getChildByName("people_label"), "Label")
	people_label:setText(armyData.getTeamHp(show_army_id))

	if is_need_timer then
		if not m_timer then
			m_timer = scheduler.create(update_time_content, 1)
		end
		update_time_content()
	else
		if m_timer then
			scheduler.remove(m_timer)
			m_timer = nil
		end
	end
end


local function createWidget()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/armySimpleUI.json")
	
	local img_tips = uiUtil.getConvertChildByName(temp_widget,"img_tips")
  	img_tips:setVisible(true)
  	local label_tips = uiUtil.getConvertChildByName(img_tips,"label_tips")
  	if show_army_state == 0  then
  		-- 非法状态
  		img_tips:setVisible(false)
  	elseif show_army_state == 1 or show_army_state == 2 or show_army_state == 3 or show_army_state == 4 or show_army_state == 8 then
  		-- 行军状态
  		label_tips:setText(languagePack['army_cannot_move_tips_not_in_city'])
  	elseif show_army_state == 5 then
  		label_tips:setText(languagePack['army_cannot_move_tips_zhengbing'])
  	elseif show_army_state == 6 then
  		label_tips:setText(languagePack['army_cannot_move_tips_hurt'])
  	elseif show_army_state == 7 then
  		label_tips:setText(languagePack['army_cannot_move_tips_no_engergy'])
  	else
  		img_tips:setVisible(false)
  	end
	return temp_widget
end

local function create(is_center)
	
	local temp_widget = createWidget()
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))

	if is_center then
		temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	else
		temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height*3/5))
	end

	-- local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	-- close_btn:addTouchEventListener(deal_with_close_click)
	-- close_btn:setTouchEnabled(true)

	local img_tips = uiUtil.getConvertChildByName(temp_widget,"img_tips")
	-- local temp_army_pos_y = scene_height*14/200
	local pt = temp_widget:convertToNodeSpace(cc.p( 0, config.getWinSize().height * 80/640))
	img_tips:setPositionY(pt.y)
	
	breathAnimUtil.start_anim(img_tips, true, 128, 255, 1, 0)
	
	army_lineup_layer = TouchGroup:create()
	army_lineup_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(army_lineup_layer, uiIndexDefine.ARMY_LIENUP_UI)
	uiManager.showConfigEffect(uiIndexDefine.ARMY_LIENUP_UI, army_lineup_layer)
end

local function fetchWidgetView(army_id)
	local temp_widget = createWidget()
	organize_show_content(temp_widget,army_id)

	return temp_widget
end



local function on_enter(army_id, is_center,army_state)
	if army_lineup_layer then
		return
	end
	show_army_id = army_id
	show_army_state = army_state
	create(is_center)
	local temp_widget = army_lineup_layer:getWidgetByTag(999)
	organize_show_content(temp_widget,show_army_id)
	if armyMoveManager then
		armyMoveManager.set_des_show_state(false)
	end
end

armyLineupManager = {
						on_enter = on_enter,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						organize_show_content = organize_show_content,
						fetchWidgetView = fetchWidgetView,
}
