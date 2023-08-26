local m_main_widget = nil
local m_teach_max_num = nil 	--教学演武的轮数
local m_is_teach = nil 			--是否是教学演武
local m_update_timer = nil 		--演武倒计时

local function remove_self()
	if m_update_timer then
		scheduler.remove(m_update_timer)
		m_update_timer = nil
	end

	m_is_teach = nil
	m_teach_max_num = nil
	m_main_widget = nil
end

local function deal_with_return_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if exerciseEffectManager and exerciseEffectManager.get_enter_state() then
			exerciseWholeManager.remove_self()
		end
	end
end

local function deal_with_tips_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if exerciseData.get_exercise_reward_state() then
			tipsLayer.create(errorTable[511])
			return
		end

		if exerciseData.is_teach_type() then
			exerciseEffectManager.deal_with_enter_guide()
		else
			exerciseEffectManager.deal_with_enter_free_guide(true)
		end
	end
end

local function deal_with_record_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/exercise/exerciseRecordManager")
		exerciseRecordManager.create()
	end
end

local function deal_with_teach_reward_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getName(),5))
		local temp_exercise_phase = exerciseData.get_teach_phase()
		if select_index < temp_exercise_phase then
			tipsLayer.create(errorTable[501])
		else
			if select_index == temp_exercise_phase then
				require("game/exercise/exerciseRewardManager")
				exerciseRewardManager.create()
			else
				require("game/exercise/exercisePreRewardManager")
				exercisePreRewardManager.create(10 + select_index)
			end
		end
	end
end

local function deal_with_reward_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/exercise/exerciseRewardManager")
		exerciseRewardManager.create()
	end
end

local function enter_next_for_free()
	require("game/exercise/exerciseDifficultManager")
	exerciseDifficultManager.create()
end

local function deal_with_next_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_show_type = exerciseData.get_next_btn_show_type()
		if temp_show_type == 1 then
			exerciseOpRequest.request_next_exercise(exerciseData.get_next_exercise_id())
		elseif temp_show_type == 2 then
		elseif temp_show_type == 3 then
			tipsLayer.create(errorTable[502])
		elseif temp_show_type == 10 then
		elseif temp_show_type == 11 then
			enter_next_for_free()
		elseif temp_show_type == 12 then
		elseif temp_show_type == 13 then
			alertLayer.create(errorTable[308], nil, enter_next_for_free)
		end
	end
end

local function deal_with_report_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		reportUI.create(4)
	end
end

local function set_component_layout()
	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	bg_img:loadTexture(ResDefineUtil.exercise_res[1], UI_TEX_TYPE_LOCAL)
	local temp_img_scale = scene_height/bg_img:getContentSize().height
	bg_img:setScale(temp_img_scale)
	bg_img:setPosition(cc.p(scene_width/2, scene_height/2))

	local black_img = tolua.cast(m_main_widget:getChildByName("black_img"), "ImageView")
	black_img:setScaleX(scene_width/black_img:getContentSize().width)
	black_img:setScaleY(scene_height/black_img:getContentSize().height)
	black_img:setPosition(cc.p(scene_width/2, scene_height/2))

	local scale_num = config.getgScale()
	local title_img = tolua.cast(m_main_widget:getChildByName("title_img"), "ImageView")
	title_img:setScale(scale_num)
	title_img:setPosition(cc.p(scene_width/2, scene_height))

	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	bottom_panel:setScale(scale_num)
	bottom_panel:ignoreAnchorPointForPosition(false)
	bottom_panel:setAnchorPoint(cc.p(0.5,0))
	bottom_panel:setPosition(cc.p(scene_width/2, 0))

	local des_txt = tolua.cast(bottom_panel:getChildByName("des_label"), "Label")
	breathAnimUtil.start_anim(des_txt, true, 76, 255, 1, 0)

	local lt_panel = tolua.cast(m_main_widget:getChildByName("lt_panel"), "Layout")
	lt_panel:setScale(scale_num)
	lt_panel:ignoreAnchorPointForPosition(false)
	lt_panel:setAnchorPoint(cc.p(0, 1))
	lt_panel:setPosition(cc.p(0, scene_height))
	local record_btn = tolua.cast(lt_panel:getChildByName("record_btn"), "Button")
	record_btn:addTouchEventListener(deal_with_record_click)
	local report_btn = tolua.cast(lt_panel:getChildByName("report_btn"), "Button")
	report_btn:addTouchEventListener(deal_with_report_click)

	local btn_panel = tolua.cast(m_main_widget:getChildByName("btn_panel"), "Layout")
	btn_panel:setScale(scale_num)
	btn_panel:ignoreAnchorPointForPosition(false)
	btn_panel:setAnchorPoint(cc.p(1,1))
	btn_panel:setPosition(cc.p(scene_width, scene_height))
	local return_btn = tolua.cast(btn_panel:getChildByName("return_btn"), "Button")
	return_btn:setTouchEnabled(true)
	return_btn:addTouchEventListener(deal_with_return_click)

	local tips_btn = tolua.cast(btn_panel:getChildByName("tips_btn"), "Button")
	tips_btn:setTouchEnabled(true)
	tips_btn:addTouchEventListener(deal_with_tips_click)
end

local function set_exercise_name()
	local title_img = tolua.cast(m_main_widget:getChildByName("title_img"), "ImageView")
	local content_txt = tolua.cast(title_img:getChildByName("content_label"), "Label")
	content_txt:setText(exerciseData.get_exercise_name())
end

local function set_base_info(is_init_state)
	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local teach_panel = tolua.cast(bottom_panel:getChildByName("teach_panel"), "Layout")
	local free_panel = tolua.cast(bottom_panel:getChildByName("free_panel"), "Layout")
	teach_panel:setVisible(m_is_teach)
	free_panel:setVisible(not m_is_teach)

	local lt_panel = tolua.cast(m_main_widget:getChildByName("lt_panel"), "Layout")
	local record_btn = tolua.cast(lt_panel:getChildByName("record_btn"), "Button")
	local report_btn = tolua.cast(lt_panel:getChildByName("report_btn"), "Button")
	if not is_init_state then
		lt_panel:setVisible(not m_is_teach)
	end
	record_btn:setTouchEnabled(not m_is_teach)
	report_btn:setTouchEnabled(not m_is_teach)
end

local function deal_with_cd_update()
	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local des_txt = tolua.cast(bottom_panel:getChildByName("des_label"), "Label")
	local temp_leave_time = exerciseData.get_cd_leave_time()
	if temp_leave_time > 0 then
		des_txt:setText(languagePack["exercise_tips_2"] .. commonFunc.format_time(temp_leave_time))
	else
		if m_update_timer then
			scheduler.remove(m_update_timer)
			m_update_timer = nil
		end

		local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
		local next_btn = nil
		if m_is_teach then
			local teach_panel = tolua.cast(bottom_panel:getChildByName("teach_panel"), "Layout")
			next_btn = tolua.cast(teach_panel:getChildByName("next_btn"), "Button")
		else
			local free_panel = tolua.cast(bottom_panel:getChildByName("free_panel"), "Layout")
			next_btn = tolua.cast(free_panel:getChildByName("next_btn"), "Button")
		end
		next_btn:setBright(true)

		des_txt:setVisible(false)
	end
end

local function set_tips_show_content()
	if m_update_timer then
		scheduler.remove(m_update_timer)
		m_update_timer = nil
	end

	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local des_txt = tolua.cast(bottom_panel:getChildByName("des_label"), "Label")
	des_txt:setVisible(false)
	--breathAnimUtil.stop_all_anim(des_txt)

	local next_btn = nil
	if m_is_teach then
		local teach_panel = tolua.cast(bottom_panel:getChildByName("teach_panel"), "Layout")
		next_btn = tolua.cast(teach_panel:getChildByName("next_btn"), "Button")
	else
		local free_panel = tolua.cast(bottom_panel:getChildByName("free_panel"), "Layout")
		next_btn = tolua.cast(free_panel:getChildByName("next_btn"), "Button")
	end

	local temp_show_type = exerciseData.get_next_btn_show_type()
	if temp_show_type == 1 then
		des_txt:setText(languagePack["exercise_tips_3"])
		next_btn:setBright(true)
	elseif temp_show_type == 2 then
		local show_info = exerciseData.get_exercise_tips()
		if show_info == "" then
			show_info = languagePack["exercise_tips_1"]
		end
		des_txt:setText(show_info)
		next_btn:setBright(false)
	elseif temp_show_type == 3 then
		deal_with_cd_update()
		m_update_timer = scheduler.create(deal_with_cd_update, 1)
		next_btn:setBright(false)
	elseif temp_show_type == 10 then
		des_txt:setText(languagePack["exercise_tips_4"])
		next_btn:setBright(false)
	elseif temp_show_type == 11 then
		des_txt:setText(languagePack["exercise_tips_3"])
		next_btn:setBright(true)
	elseif temp_show_type == 12 then
		des_txt:setText(languagePack["exercise_tips_1"])
		next_btn:setBright(false)
	elseif temp_show_type == 13 then
		des_txt:setText(languagePack["exercise_tips_1"])
		next_btn:setBright(true)
	end

	des_txt:setVisible(true)
	--breathAnimUtil.start_anim(des_txt, true, 76, 255, 1, 0)
end

local function enter_teach_type()
	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local teach_panel = tolua.cast(bottom_panel:getChildByName("teach_panel"), "Layout")
	local next_btn = tolua.cast(teach_panel:getChildByName("next_btn"), "Button")
	next_btn:setTouchEnabled(true)
	next_btn:addTouchEventListener(deal_with_next_click)

	local loading_bar = tolua.cast(teach_panel:getChildByName("loading_bar"), "LoadingBar")
	local all_width = loading_bar:getSize().width
	local start_pos = loading_bar:getPositionX() - all_width/2

	local state_base_img = tolua.cast(teach_panel:getChildByName("state_base_img"), "Layout")
	local pos_offset = 80
	local pro_panel = nil
	for i=1,m_teach_max_num do
		pro_panel = state_base_img:clone()
		pro_panel:setName("pro_" .. i)
		pro_panel:setPosition(cc.p(start_pos + all_width * i/m_teach_max_num - pos_offset, 40))
		pro_panel:setTouchEnabled(true)
		pro_panel:addTouchEventListener(deal_with_teach_reward_click)
		teach_panel:addChild(pro_panel)
	end

	state_base_img:setVisible(false)
end

local function leave_teach_type()
	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local teach_panel = tolua.cast(bottom_panel:getChildByName("teach_panel"), "Layout")
	local next_btn = tolua.cast(teach_panel:getChildByName("next_btn"), "Button")
	next_btn:setTouchEnabled(false)

	local pro_panel = nil
	for i=1,m_teach_max_num do
		pro_panel = tolua.cast(teach_panel:getChildByName("pro_" .. i), "Layout")
		pro_panel:setTouchEnabled(false)
	end
end

local function set_teach_show_content()
	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local teach_panel = tolua.cast(bottom_panel:getChildByName("teach_panel"), "Layout")

	local temp_exercise_phase = exerciseData.get_teach_phase()
	local pro_panel, common_img, finish_img, running_img, special_img = nil, nil, nil, nil, nil
	for i=1,m_teach_max_num do
		pro_panel = tolua.cast(teach_panel:getChildByName("pro_" .. i), "Layout")
		common_img = tolua.cast(pro_panel:getChildByName("common_img"), "ImageView")
		finish_img = tolua.cast(pro_panel:getChildByName("finish_img"), "ImageView")
		running_img = tolua.cast(pro_panel:getChildByName("running_img"), "ImageView")
		special_img = tolua.cast(pro_panel:getChildByName("special_img"), "ImageView")
		common_img:setVisible(false)
		finish_img:setVisible(false)
		running_img:setVisible(false)
		special_img:setVisible(false)
		breathAnimUtil.stop_all_anim(special_img)

		if i < temp_exercise_phase then
			finish_img:setVisible(true)
			--pro_panel:setTouchEnabled(false)
		else
			if i == temp_exercise_phase then
				running_img:setVisible(true)
				--pro_panel:setTouchEnabled(true)
			else
				common_img:setVisible(true)
				if exerciseData.get_exercise_special_state(i + 10) then
					special_img:setVisible(true)
					breathAnimUtil.start_anim(special_img, true, 76, 255, 1, 0)
				--else
					--common_img:setVisible(true)
				end
				--pro_panel:setTouchEnabled(false)
			end
		end
	end

	local loading_bar = tolua.cast(teach_panel:getChildByName("loading_bar"), "LoadingBar")
	--print("===================" .. temp_exercise_phase .. "/" .. m_teach_max_num)
	loading_bar:setPercent(100 * temp_exercise_phase / m_teach_max_num)

	--[[
	local next_btn = tolua.cast(teach_panel:getChildByName("next_btn"), "Button")
	if exerciseData.get_exercise_reward_state() then
		next_btn:setBright(true)
	else
		next_btn:setBright(false)
	end
	--]]

	set_tips_show_content()
end

local function enter_free_type()
	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local free_panel = tolua.cast(bottom_panel:getChildByName("free_panel"), "Layout")
	local reward_btn = tolua.cast(free_panel:getChildByName("reward_btn"), "Button")
	reward_btn:setTouchEnabled(true)
	reward_btn:addTouchEventListener(deal_with_reward_click)

	local next_btn = tolua.cast(free_panel:getChildByName("next_btn"), "Button")
	next_btn:setTouchEnabled(true)
	next_btn:addTouchEventListener(deal_with_next_click)
end

local function set_free_show_content()
	--[[
	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local free_panel = tolua.cast(bottom_panel:getChildByName("free_panel"), "Layout")
	local next_btn = tolua.cast(free_panel:getChildByName("next_btn"), "Button")
	if exerciseData.get_cd_leave_time() > 0 then
		next_btn:setBright(false)
	else
		next_btn:setBright(true)
	end
	--]]

	local bottom_panel = tolua.cast(m_main_widget:getChildByName("bottom_panel"), "Layout")
	local free_panel = tolua.cast(bottom_panel:getChildByName("free_panel"), "Layout")
	local num_txt = tolua.cast(free_panel:getChildByName("num_label"), "Label")
	num_txt:setText(exerciseData.get_exercise_count() .. languagePack["cishu"])

	set_tips_show_content()
end

local function create(temp_widget)
	m_main_widget = temp_widget
	m_is_teach = exerciseData.is_teach_type()
	m_teach_max_num = exerciseData.get_teach_nums()
 
	set_component_layout()

	set_exercise_name()
	set_base_info(true)
	if m_is_teach then
		enter_teach_type()
		set_teach_show_content()
	else
		enter_free_type()
		set_free_show_content()
	end
end

local function deal_with_change_exercise()
	if m_is_teach then
		if not exerciseData.is_teach_type() then
			m_is_teach = false
			set_base_info(false)
			leave_teach_type()
			enter_free_type()
		end
	end

	set_exercise_name()
	if m_is_teach then
		set_teach_show_content()
	else
		set_free_show_content()
	end
end

local function deal_with_change_cd_state()
	if m_is_teach then
		set_teach_show_content()
	else
		set_free_show_content()
	end
end

local function deal_with_count_update()
	if m_is_teach then
		set_teach_show_content()
	else
		set_free_show_content()
	end
end

exerciseBaseManager = {
						create = create,
						remove_self = remove_self,
						deal_with_change_exercise = deal_with_change_exercise,
						deal_with_change_cd_state = deal_with_change_cd_state,
						deal_with_count_update = deal_with_count_update
} 