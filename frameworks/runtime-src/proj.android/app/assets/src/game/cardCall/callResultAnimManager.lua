local m_result_panel = nil
local m_bag_component = nil 		--右下角打开背包按钮
local m_bag_pos = nil 				--卡牌动画移入卡包的终点位置
local m_pos_list = nil
local m_widget_list = nil 			--获取卡牌后显示卡牌的组件列表
local m_tech_list = nil 			--技巧值转化动画图标列表
local m_show_nums = nil
local m_init_pos = nil 				--动画初始化出现的位置

local m_first_btn_state = nil 		--一次招募是否可以用
local m_second_btn_state = nil 		--N次招募是否可以用
local m_baodi_panel_state = nil 	--是否有保底显示

--特殊卡牌环绕
local m_three_star_anim_list = nil 	--3星动画效果列表
local m_four_star_anim_list = nil 	--4星动画效果列表
local m_last_three_star_index = nil
local m_last_four_star_index = nil  	--4星上一个显示的动画序列

--点击抽卡方式获取可招募卡牌动画
local m_is_play_refresh_anim = nil  	--是否正在播放动画
local m_bg_anim_finish = nil 			--招募卡牌的背景动画是否在播放
local m_is_play_clear_anim =nil 		--是否正在播放消失动画
local m_clear_timer = nil 				--消失位移动画时间
local m_call_bg_armature = nil 			--招募卡牌出现的时候底图发光特效
local m_call_finish_timer = nil 		--招募最后阶段时间间隔

--技巧值转化动画部分
local m_tech_txt = nil 					--技巧值文本
local m_tech_component = nil 			--技巧值增加文本
local m_tech_pos = nil 					--技巧值图标运动到的位置
local m_tech_init_y = nil 				--文本初始的Y坐标
local m_is_play_technic_anim = nil 		--是否正在播放技巧值转化动画
local m_technic_anim_phase = nil 		--技巧值转化动画所处的阶段，用来打断恢复用
local m_change_index_list = nil 		--当前动画转化的列表索引
local m_add_value = nil 				--增加的技巧值

--初始化时加个间隔，显示完成后在加载抽卡所需的那些动画
local m_init_timer = nil

----------------------------------
-- 清理相关处理
----------------------------------
local function reset_star_anim()
	for k,v in pairs(m_three_star_anim_list) do
		v:getAnimation():stop()
		v:setVisible(false)
	end

	for kk,vv in pairs(m_four_star_anim_list) do
		vv:getAnimation():stop()
		vv:setVisible(false)
	end

	m_last_three_star_index = 0
	m_last_four_star_index = 0
end

local function remove_high_quality_effect_related()
	reset_star_anim()

	m_three_star_anim_list = nil
	m_four_star_anim_list = nil
	m_last_three_star_index = nil
	m_last_four_star_index = nil

	m_pos_list = nil

	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/zhaomu_huanrao_diji.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/zhaomu_huanrao_gaoji.ExportJson")
end

local function remove_called_anim_related()
	m_call_bg_armature = nil
	if m_call_finish_timer then
		scheduler.remove(m_call_finish_timer)
		m_call_finish_timer = nil
	end

	m_is_play_refresh_anim = nil
	m_bg_anim_finish = nil

	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/zhaomu_chouka.ExportJson")
end

local function remove()
	if m_init_timer then
		scheduler.remove(m_init_timer)
		m_init_timer = nil
	end

	if m_clear_timer then
		scheduler.remove(m_clear_timer)
		m_clear_timer = nil
	end

	remove_high_quality_effect_related()
	remove_called_anim_related()

	C_E_AssistAnim.remove()

	m_show_nums = nil
	m_init_pos = nil
	m_first_btn_state = nil
	m_second_btn_state = nil
	m_baodi_panel_state = nil
	m_is_play_clear_anim = nil

	m_widget_list = nil
	m_bag_component = nil
	m_bag_pos = nil

	m_tech_list = nil
	m_tech_component = nil
	m_tech_txt = nil
	m_tech_pos = nil
	m_tech_init_y = nil
	m_is_play_technic_anim = nil
	m_technic_anim_phase = nil
	m_change_index_list = nil
	m_add_value = nil

	m_result_panel = nil
end

local function init_pos_info()
	m_pos_list = {}
	m_pos_list[1] = {{452,162}}
	m_pos_list[2] = {{344,162},{550,162}}
	m_pos_list[3] = {{452,162},{246,162},{659,162}}
	m_pos_list[4] = {{346,162},{554,162},{140,162},{759,162}}
	m_pos_list[5] = {{452,162},{246,162},{659,162},{33,162},{865,162}}
	m_pos_list[6] = {{447,91},{447,301},{234,91},{234,301},{663,301},{50,100}}
	m_pos_list[7] = {{447,302},{234,302},{663,302},{336,91},{552,91},{123,91},{759,91}}
	m_pos_list[8] = {{336,302},{552,302},{336,91},{552,91},{123,303},{123,91},{759,303},{759,91}}
	m_pos_list[9] = {{344,302},{560,302},{455,91},{242,91},{671,91},{131,302},{26,91},{767,302},{878,91}}
	m_pos_list[10] = {{436,292},{436,88},{240,292},{240,90},{635,292},{635,90},{46,291},{46,90},{832,291},{832,89}}
end

-----------------------------------
-- 大于3星的卡牌显示环绕特效
-----------------------------------
local function play_star_anim(hero_cfg_id, pos_x, pos_y)
	local card_quality = Tb_cfg_hero[hero_cfg_id].quality
	if card_quality < cardQuality.four_star then
		return
	end

	local show_armature = nil
	if card_quality == cardQuality.four_star then
		m_last_three_star_index = m_last_three_star_index + 1
		if m_last_three_star_index > #m_three_star_anim_list then
			show_armature = CCArmature:create("zhaomu_huanrao_diji")
			show_armature:setScale(2)
			table.insert(m_three_star_anim_list, show_armature)
			m_result_panel:addChild(show_armature, 2)
		else
			show_armature = m_three_star_anim_list[m_last_three_star_index]
		end
	else
		m_last_four_star_index = m_last_four_star_index + 1
		if m_last_four_star_index > #m_four_star_anim_list then
			show_armature = CCArmature:create("zhaomu_huanrao_gaoji")
			show_armature:setScale(2)
			table.insert(m_four_star_anim_list, show_armature)
			m_result_panel:addChild(show_armature, 2)
		else
			show_armature = m_four_star_anim_list[m_last_four_star_index]
		end
	end

	show_armature:setPosition(cc.p(pos_x + 70, pos_y + 100))
	show_armature:setVisible(true)
	show_armature:getAnimation():play("Animation1")
end

local function play_high_quality_anim()
	for i=1,m_show_nums do
		play_star_anim(callResultManager.get_card_cfg_id_by_idx(i), m_pos_list[m_show_nums][i][1], m_pos_list[m_show_nums][i][2])
	end
end



--------------------------------------
--点击刷卡获取卡的动画效果
--------------------------------------
local function deal_with_refresh_anim_finish()
	scheduler.remove(m_call_finish_timer)
	m_call_finish_timer = nil

	local card_panel, mask_sign = nil, nil
	for i=1,m_show_nums do
		card_panel = m_widget_list[i]
		mask_sign = tolua.cast(card_panel:getChildByName("mask_sign"), "Layout")
		mask_sign:setVisible(false)
	end

	m_is_play_refresh_anim = false
	play_high_quality_anim()
	newGuideInfo.enter_next_guide()

	callResultManager.change_technic_response()
end

local function play_refresh_third_anim(is_good_anim)
	local need_time_num = 0.1
	local scale_to = CCScaleTo:create(need_time_num, 1)

	local icon_con, mask_sign = nil, nil
	local temp_need_anim = nil
	for i=1,m_show_nums do
		temp_need_anim = true
		if is_good_anim then
			if not callResultManager.is_good_card_by_index(i) then
				temp_need_anim = false
			end
		end

		if temp_need_anim then
			icon_con = m_widget_list[i]
			icon_con:runAction(tolua.cast(scale_to:copy():autorelease(), "CCActionInterval"))
		end
	end
end

local function play_refresh_good_third_anim()
	play_refresh_third_anim(true)
end

local function play_refresh_common_third_anim()
	play_refresh_third_anim(false)
end

local function play_refresh_second_anim(is_good_anim)
	--[[
	local anim_start_bg_img = tolua.cast(m_result_panel:getChildByName("start_bg_img"), "ImageView")
	local bg_hide_time = 0.2
	local fade_out = CCFadeOut:create(bg_hide_time)
	local finish_call = cc.CallFunc:create(deal_with_refresh_anim_finish)
	local bg_seq = cc.Sequence:createWithTwoActions(fade_out, finish_call)
	anim_start_bg_img:runAction(bg_seq)
	--]]
	if m_call_finish_timer then
		scheduler.remove(m_call_finish_timer)
		m_call_finish_timer = nil
	end
	m_call_finish_timer = scheduler.create(deal_with_refresh_anim_finish, 0.2)

	local card_first_time = 0.1
	local scale_to = CCScaleTo:create(card_first_time, 1.05)

	local icon_con, mask_sign = nil, nil
	local temp_need_anim = nil
	for i=1,m_show_nums do
		icon_con = m_widget_list[i]
		temp_need_anim = true
		if is_good_anim then
			icon_con:setPosition(cc.p(m_pos_list[m_show_nums][i][1], m_pos_list[m_show_nums][i][2]))
			icon_con:setScale(1)
			icon_con:setVisible(true)

			if not callResultManager.is_good_card_by_index(i) then
				temp_need_anim = false
			end
		end

		if temp_need_anim then
			mask_sign = tolua.cast(icon_con:getChildByName("mask_sign"), "Layout")
			mask_sign:setColor(ccc3(255, 255, 255))
			mask_sign:setOpacity(128)
			mask_sign:setVisible(true)
			
			icon_con:runAction(tolua.cast(scale_to:copy():autorelease(), "CCActionInterval"))
		end
	end

	local fade_in = CCFadeIn:create(card_first_time)
	if m_first_btn_state then
		local btn_1 = tolua.cast(m_result_panel:getChildByName("btn_1"), "Button")
		btn_1:setOpacity(0)
		btn_1:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))
		btn_1:setVisible(true)
	end

	if m_second_btn_state then
		local btn_2 = tolua.cast(m_result_panel:getChildByName("btn_2"), "Button")
		btn_2:setOpacity(0)
		btn_2:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))
		btn_2:setVisible(true)
	end

	local fun_call = nil
	if is_good_anim then
		fun_call = cc.CallFunc:create(play_refresh_good_third_anim)
	else
		fun_call = cc.CallFunc:create(play_refresh_common_third_anim)
	end
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	local baodi_panel = tolua.cast(m_result_panel:getChildByName("baodi_panel"), "Layout")
	baodi_panel:runAction(temp_seq)
	if m_baodi_panel_state then
		baodi_panel:setVisible(true)
	end
end

local function play_refresh_good_second_anim()
	play_refresh_second_anim(true)
end

local function play_refresh_common_second_anim()
	play_refresh_second_anim(false)
end

local function play_refresh_common_anim()
	local first_time_num = 0.2
	local scale_to = CCScaleTo:create(first_time_num, 1)

	local icon_con = nil
	for i=1,m_show_nums do
		icon_con = m_widget_list[i]
		icon_con:setScale(0.1)
		icon_con:setVisible(true)

		local move_to = CCMoveTo:create(first_time_num, ccp(m_pos_list[m_show_nums][i][1], m_pos_list[m_show_nums][i][2]))
		local card_spawn = CCSpawn:createWithTwoActions(tolua.cast(scale_to:copy():autorelease(), "CCActionInterval"), move_to)
		icon_con:runAction(card_spawn)
	end
end

local function play_bg_first_anim(is_have_good_card)
	m_bg_anim_finish = true
	m_call_bg_armature:getAnimation():play("Animation1")
	m_call_bg_armature:setVisible(true)

	--[[
	local anim_start_bg_img = tolua.cast(m_result_panel:getChildByName("start_bg_img"), "ImageView")
	anim_start_bg_img:setRotation(-180)
	anim_start_bg_img:setScale(0.1)
	anim_start_bg_img:setOpacity(255)
	anim_start_bg_img:setVisible(true)

	local first_time_num = 0.2
	local rotate_to = CCRotateTo:create(first_time_num, 0)
	local scale_to = CCScaleTo:create(first_time_num, 2)
	local temp_spawn = CCSpawn:createWithTwoActions(rotate_to, scale_to)
	if is_have_good_card then
		anim_start_bg_img:runAction(temp_spawn)
	else
		local fun_call = cc.CallFunc:create(play_refresh_common_second_anim)
		local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
		anim_start_bg_img:runAction(temp_seq)
	end
	--]]

	--return anim_start_bg_img:convertToWorldSpace(cc.p(0, 0))
end

local function first_bg_anim_finish()
	cardCallListManager.set_show_state(false)

	local is_have_good_card = callResultManager.own_good_card_state()
	play_bg_first_anim(is_have_good_card)

	if is_have_good_card then
		C_E_AssistAnim.play_anim()
	else
		play_refresh_common_anim()
	end
end

local function on_frame_event( bone,evt,originFrameIndex,currentFrameIndex)
	if evt == "frame_7" then
		local is_have_good_card = callResultManager.own_good_card_state()
		if not is_have_good_card then
			play_refresh_common_second_anim()
		end
	elseif evt == "finish" then
		if m_bg_anim_finish then
			m_call_bg_armature:setVisible(false)
    		m_bg_anim_finish = false
    	end
    end
end

local function play_refresh_card_anim()
	--[[
	local anim_start_bg_img = tolua.cast(m_result_panel:getChildByName("start_bg_img"), "ImageView")
	if not anim_start_bg_img then
		anim_start_bg_img = ImageView:create()
		anim_start_bg_img:loadTexture(ResDefineUtil.card_extract_res[1], UI_TEX_TYPE_PLIST)
		anim_start_bg_img:setName("start_bg_img")
		anim_start_bg_img:setPosition(m_init_pos)
		m_result_panel:addChild(anim_start_bg_img)
	end
	--]]

	if not m_call_bg_armature then
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/zhaomu_chouka.ExportJson")

		m_call_bg_armature = CCArmature:create("zhaomu_chouka")
		m_call_bg_armature:setVisible(false)
		--m_call_bg_armature:setOpacity(128)
		m_call_bg_armature:setScale(4)
		m_call_bg_armature:setPosition(m_init_pos)
		m_call_bg_armature:getAnimation():setFrameEventCallFunc(on_frame_event)

		m_result_panel:addChild(m_call_bg_armature)
	end

	--anim_start_bg_img:setVisible(false)
	C_E_AssistAnim.play_begin_bg_anim(first_bg_anim_finish)
	m_is_play_refresh_anim = true
end

local function is_touch_enabled()
	if (m_is_play_refresh_anim or m_bg_anim_finish) or m_is_play_clear_anim or m_is_play_technic_anim then
		return false
	else
		return true
	end
end

--检测动画状态判断是否可以点击招募按钮
local function is_can_call_click()
	if m_is_play_clear_anim then
		return false
	end

	if m_is_play_refresh_anim then
		return false
	end

	return true
end

local function reset_anim_after_call_click()
	if m_bg_anim_finish then
		m_call_bg_armature:setVisible(false)
    	m_bg_anim_finish = false
	end

	if m_is_play_technic_anim then
		for k,v in pairs(m_change_index_list) do
			m_tech_list[v]:setVisible(false)
		end

		if m_technic_anim_phase == 1 then
			for k,v in pairs(m_change_index_list) do
				local change_sign_img = tolua.cast(m_widget_list[v]:getChildByName("change_sign_img"), "ImageView")
				change_sign_img:stopAllActions()
			end
		elseif m_technic_anim_phase == 2 then
			for k,v in pairs(m_change_index_list) do
				local tech_sign_img = m_tech_list[v]
				tech_sign_img:stopAllActions()
			end
		elseif m_technic_anim_phase == 3 then
			m_tech_txt:stopAllActions()
		elseif m_technic_anim_phase == 4 then
			m_tech_component:stopAllActions()
		end

		m_is_play_technic_anim = false
		m_technic_anim_phase = 0
	end
end

--------------------------------
--卡牌技巧值转化动画
--------------------------------
local function play_tech_finish()
	local fade_out = CCFadeOut:create(0.3)
	m_tech_component:runAction(fade_out)

	m_is_play_technic_anim = false
	m_technic_anim_phase = 0
end

local function play_tech_third_finish()
	for k,v in pairs(m_change_index_list) do
		m_tech_list[v]:setVisible(false)
	end

	local anim_time = 0.5
	local move_by = CCMoveBy:create(anim_time, ccp(0, 50))
	local fade_in = CCFadeIn:create(anim_time)
	local temp_spawn = CCSpawn:createWithTwoActions(move_by, fade_in)
	local fun_call = cc.CallFunc:create(play_tech_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)

	m_tech_component:setText("+" .. m_add_value)
	m_tech_component:setPositionY(m_tech_init_y)
	m_tech_component:setVisible(true)
	m_tech_component:runAction(temp_seq)

	m_technic_anim_phase = 4
end

local function play_tech_second_finish()
	local scale_need_time = 0.1
	local first_scale_to = CCScaleTo:create(scale_need_time, 1.5)
	local second_scale_to = CCScaleTo:create(scale_need_time, 1)
	local fun_call = cc.CallFunc:create(play_tech_third_finish)
	local temp_array = CCArray:create()
	temp_array:addObject(first_scale_to)
	temp_array:addObject(second_scale_to)
	temp_array:addObject(fun_call)
	local temp_seq = cc.Sequence:create(temp_array)
	m_tech_txt:runAction(temp_seq)

	m_technic_anim_phase = 3
end

local function play_tech_first_finish()
	local first_time_num = 0.5
	local scale_to = CCScaleTo:create(first_time_num, 0.1)
	local move_to = CCMoveTo:create(first_time_num, m_tech_pos)
	local temp_spawn = CCSpawn:createWithTwoActions(scale_to, move_to)

	for k,v in pairs(m_change_index_list) do
		local mask_sign = tolua.cast(m_widget_list[v]:getChildByName("mask_sign"), "Layout")
		mask_sign:setColor(ccc3(0, 0, 0))
		mask_sign:setOpacity(180)
		mask_sign:setVisible(true)

		local tech_sign_img = m_tech_list[v]
		tech_sign_img:setPosition(cc.p(m_pos_list[m_show_nums][v][1] + 70, m_pos_list[m_show_nums][v][2] + 98))
		tech_sign_img:setVisible(true)
		tech_sign_img:setScale(1)
		if k == 1 then
			local fun_call = cc.CallFunc:create(play_tech_second_finish)
			local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
			tech_sign_img:runAction(temp_seq)
		else
			tech_sign_img:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCActionInterval"))
		end
	end

	m_technic_anim_phase = 2
end

local function start_technic_anim(change_list, add_value)
	m_is_play_technic_anim = true
	m_change_index_list = change_list
	m_add_value = add_value

	local scale_to = CCScaleTo:create(0.1, 1)
	for k,v in pairs(m_change_index_list) do
		local change_sign_img = tolua.cast(m_widget_list[v]:getChildByName("change_sign_img"), "ImageView")
		change_sign_img:setScale(1.5)
		change_sign_img:setVisible(true)
		if k == 1 then
			local fun_call = cc.CallFunc:create(play_tech_first_finish)
			local temp_seq = cc.Sequence:createWithTwoActions(scale_to, fun_call)
			change_sign_img:runAction(temp_seq)
		else
			change_sign_img:runAction(tolua.cast(scale_to:copy():autorelease(), "CCActionInterval"))
		end
	end

	m_technic_anim_phase = 1
end

--------------------------------
--卡牌列表进入卡牌背包的动画
--------------------------------
local function deal_with_clear_finish()
	scheduler.remove(m_clear_timer)
	m_clear_timer = nil


	for i=1,m_show_nums do
		m_widget_list[i]:setVisible(false)
	end

	local need_time_num = 0.1
	local first_scale_to = CCScaleTo:create(need_time_num, 1.2)
	local second_scale_to = CCScaleTo:create(need_time_num, 1)
	local temp_seq = cc.Sequence:createWithTwoActions(first_scale_to, second_scale_to)
	m_bag_component:runAction(temp_seq)

	callResultManager.clear_anim_callback()
	m_is_play_clear_anim = false
end

local function play_enter_bag_anim()
	m_is_play_clear_anim = true
	reset_star_anim()

	local first_time_num = 0.2
	local scale_to = CCScaleTo:create(first_time_num, 0.1)
	local move_to = CCMoveTo:create(first_time_num, m_bag_pos)
	local temp_spawn = CCSpawn:createWithTwoActions(scale_to, move_to)

	local icon_con = nil
	for i=1,m_show_nums do
		m_widget_list[i]:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCActionInterval"))
	end
	
	if m_first_btn_state then
		local btn_1 = tolua.cast(m_result_panel:getChildByName("btn_1"), "Button")
		btn_1:setVisible(false)
	end

	if m_second_btn_state then
		local btn_2 = tolua.cast(m_result_panel:getChildByName("btn_2"), "Button")
		btn_2:setVisible(false)
	end

	local baodi_panel = tolua.cast(m_result_panel:getChildByName("baodi_panel"), "Layout")
	if m_baodi_panel_state then
		baodi_panel:setVisible(false)
	end

	m_clear_timer = scheduler.create(deal_with_clear_finish, first_time_num)
end

---------------------------
-- 卡牌内容显示相关
---------------------------
local function get_widget_by_index(idx)
	return m_widget_list[idx]
end

local function reset_widget_show()
	local hero_widget, mask_panel, changed_img = nil, nil, nil
	for k,v in pairs(m_widget_list) do
		mask_panel = tolua.cast(v:getChildByName("mask_sign"), "Layout")
		mask_panel:setVisible(false)
		changed_img = tolua.cast(v:getChildByName("change_sign_img"), "ImageView")
		changed_img:setVisible(false)

		hero_widget = tolua.cast(v:getChildByName("hero_icon"), "Layout")
		hero_widget:setTouchEnabled(false)

		v:setPosition(m_init_pos)
		v:setVisible(false)
	end
end

local function set_show_card_nums(new_nums, deal_with_card_click)
	m_show_nums = new_nums

	reset_star_anim()
	local temp_widget_nums = #m_widget_list
	if m_show_nums > temp_widget_nums then
		local icon_base = tolua.cast(m_result_panel:getChildByName("icon_base"), "Layout")
		local tech_base = tolua.cast(m_result_panel:getChildByName("technic_base"), "ImageView")
		local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
		for i=temp_widget_nums + 1,m_show_nums do
			local icon_panel = icon_base:clone()
			icon_panel:setName("hero_" .. i)
			local hero_widget = base_widget:clone()
			hero_widget:setName("hero_icon")
			hero_widget:addTouchEventListener(deal_with_card_click)
			icon_panel:addChild(hero_widget)
			m_result_panel:addChild(icon_panel, 1)
			table.insert(m_widget_list, icon_panel)

			local tech_img = tech_base:clone()
			m_result_panel:addChild(tech_img, 2)
			table.insert(m_tech_list, tech_img)
		end
	end

	reset_widget_show()
end

local function set_btn_show_state(state_1, state_2, state_3)
	m_first_btn_state = state_1
	m_second_btn_state = state_2
	m_baodi_panel_state = state_3
end

-------------------------------------
--初始化相关
-------------------------------------
local function init_param_info()
	m_show_nums = 0

	m_init_pos = ccp(520, 240) 	--实际是m_result_panel的中心点位置

	m_is_play_refresh_anim = false
	m_bg_anim_finish = false
	m_is_play_clear_anim = false
	m_is_play_technic_anim = false

	m_first_btn_state = false
	m_second_btn_state = false
	m_baodi_panel_state = false
	
	m_widget_list = {}
	m_tech_list = {}
end

local function init_high_quality_anim_related()
	init_pos_info()

	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/zhaomu_huanrao_diji.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/zhaomu_huanrao_gaoji.ExportJson")

	m_last_three_star_index = 0
	m_last_four_star_index = 0
	m_three_star_anim_list = {}
	m_four_star_anim_list = {}
end

local function init_finish_callback()
	require("game/ui_anim_effect/C_E_AssistAnim")
	C_E_AssistAnim.create()

	scheduler.remove(m_init_timer)
	m_init_timer = nil
end

local function set_bag_component(temp_com)
	m_bag_component = temp_com

	m_bag_pos = m_result_panel:convertToNodeSpace(m_bag_component:convertToWorldSpace(cc.p(0, 0)))
end

local function set_technic_component(temp_tech_txt, temp_com)
	m_tech_txt = temp_tech_txt
	m_tech_component = temp_com

	m_tech_init_y = m_tech_component:getPositionY()
	m_tech_pos = m_result_panel:convertToNodeSpace(m_tech_component:convertToWorldSpace(cc.p(0, -1 * m_tech_init_y)))
end

local function create(con_panel)
	m_result_panel = con_panel

	init_param_info()

	init_high_quality_anim_related()

	m_init_timer = scheduler.create(init_finish_callback, 0.5)
end

callResultAnimManager = {
							create = create,
							remove = remove,
							set_bag_component = set_bag_component,
							set_technic_component = set_technic_component,
							get_widget_by_index = get_widget_by_index,
							set_show_card_nums = set_show_card_nums,
							set_btn_show_state = set_btn_show_state,
							reset_star_anim = reset_star_anim,
							reset_widget_show = reset_widget_show,
							is_touch_enabled = is_touch_enabled,
							is_can_call_click = is_can_call_click,
							reset_anim_after_call_click = reset_anim_after_call_click,
							play_refresh_card_anim = play_refresh_card_anim,
							play_refresh_good_second_anim = play_refresh_good_second_anim,
							start_technic_anim = start_technic_anim,
							play_enter_bag_anim = play_enter_bag_anim
}