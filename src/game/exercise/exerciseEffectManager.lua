local m_main_widget = nil
local m_map_widget = nil
local m_is_enter_finish = nil 	--是否进入动画播放完成

local function remove()
	m_map_widget = nil
	m_main_widget = nil
end

local function deal_with_enter_guide()
	if exerciseData.is_teach_type() then
		if exerciseData.get_exercise_reward_state() then
			return
		end

		local temp_exercise_phase = exerciseData.get_teach_phase()
		if temp_exercise_phase == 1 then
			local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[2])
			if show_sign == 0 then
				newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3001)
			else
				if not exerciseData.get_exercise_reward_state() then
					comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2014)
				end
			end
		elseif temp_exercise_phase == 2 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3008)
		elseif temp_exercise_phase == 3 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3010)
		elseif temp_exercise_phase == 4 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3012)
		elseif temp_exercise_phase == 5 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3014)
		elseif temp_exercise_phase == 6 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3016)
		elseif temp_exercise_phase == 7 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3018)
		elseif temp_exercise_phase == 8 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3020)
		elseif temp_exercise_phase == 9 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3022)
		elseif temp_exercise_phase == 10 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3024)
		end
	end
end

local function deal_with_enter_free_guide(force_or_not)
	if exerciseData.is_teach_type() then
		return
	end

	if force_or_not then
		newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3027)
	else
		local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[5])
		if show_sign == 0 then
			newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3027)
			CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[5], 1)
		end
	end
end

local function deal_with_third_anim_finish()
	deal_with_enter_guide()
	m_is_enter_finish = true
end

local function deal_with_second_anim_finish()
	exerciseMapManager.init_map_show_info()

	local fade_in = CCFadeIn:create(0.5)

	local black_img = tolua.cast(m_main_widget:getChildByName("black_img"), "ImageView")
	black_img:setVisible(true)
	black_img:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))

	local title_img = tolua.cast(m_main_widget:getChildByName("title_img"), "ImageView")
	title_img:setVisible(true)
	title_img:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))

	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	bottom_panel:setVisible(true)
	bottom_panel:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))

	local btn_panel = tolua.cast(m_main_widget:getChildByName("btn_panel"), "Layout")
	btn_panel:setVisible(true)
	btn_panel:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))

	local temp_fun = cc.CallFunc:create(deal_with_third_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, temp_fun)
	local lt_panel = tolua.cast(m_main_widget:getChildByName("lt_panel"), "Layout")
	if not exerciseData.is_teach_type() then
		lt_panel:setVisible(true)
	end
	lt_panel:runAction(temp_seq)
end

local function deal_with_first_anim_finish()
	m_map_widget:setVisible(true)
end

local function play_enter_anim()
	local temp_orbit = CCOrbitCamera:create(0.5, 1, 0, 0, -30, 90, 0)
	local fun_call_1 = cc.CallFunc:create(deal_with_first_anim_finish)
	local fun_call_2 = cc.CallFunc:create(deal_with_second_anim_finish)
	local temp_array = CCArray:create()
	temp_array:addObject(temp_orbit)
	temp_array:addObject(fun_call_1)
	temp_array:addObject(temp_orbit:reverse())
	temp_array:addObject(fun_call_2)
	local temp_seq = cc.Sequence:create(temp_array)
	m_map_widget:runAction(temp_seq)
end

local function create(temp_widget)
	m_main_widget = temp_widget
	m_map_widget = exerciseMapManager.get_map_widget()

	m_is_enter_finish = false
end

local function get_enter_state()
	return m_is_enter_finish
end

exerciseEffectManager = {
							create = create,
							remove = remove,
							play_enter_anim = play_enter_anim,
							get_enter_state = get_enter_state,
							deal_with_enter_guide = deal_with_enter_guide,
							deal_with_enter_free_guide = deal_with_enter_free_guide
}