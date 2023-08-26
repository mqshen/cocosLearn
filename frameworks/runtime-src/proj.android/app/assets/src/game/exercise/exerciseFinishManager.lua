local m_layer = nil
local m_reward_nums = nil
local m_reward_rate = nil
local m_is_playing_anim = nil

local m_change_timer = nil
local m_change_times = nil 		--需要变化的次数
local m_update_times = nil 		--已经变化的次数
local m_disappear_state = nil 	--是否是点击下一次按钮触发的消失

local function do_remove_self()
	if m_layer then
		if m_change_timer then
			scheduler.remove(m_change_timer)
			m_change_timer = nil
		end

		m_change_times = nil
		m_update_times = nil

		m_reward_nums = nil
		m_reward_rate = nil
		m_is_playing_anim = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_FINISH_UI)

		if m_disappear_state then
			local temp_show_type = exerciseData.get_next_btn_show_type()
			if temp_show_type == 1 then
				exerciseOpRequest.request_next_exercise(exerciseData.get_next_exercise_id())
			elseif temp_show_type == 11 then
				require("game/exercise/exerciseDifficultManager")
				exerciseDifficultManager.create()
			elseif temp_show_type == 3 then
				--aaa
			elseif temp_show_type == 4 then
				--aaa
			elseif temp_show_type == 5 then
				--aaa
			end
		end
		m_disappear_state = nil
	end
end

local function remove_self()
	--[[
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_FINISH_UI, m_layer, do_remove_self)
	end
	--]]
	do_remove_self()
end

local function deal_with_anim_finish()
	m_is_playing_anim = false
	remove_self()
end

local function play_disappear_anim()
	m_is_playing_anim = true

	local temp_widget = m_layer:getWidgetByTag(999)
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	title_img:setVisible(false)
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	des_img:setVisible(false)

	local reward_content, num_txt = nil, nil
	for i=1,m_reward_nums do
		reward_content = tolua.cast(temp_widget:getChildByName("reward_" .. i), "Layout")
		num_txt = tolua.cast(reward_content:getChildByName("num_label"), "Label")
		num_txt:setVisible(false)
	end

	local scale_to = CCScaleTo:create(0.3, 0.2)
	--local move_to = CCMoveTo:create(1, temp_widget:convertToNodeSpace(mainOption.get_tool_btn_world_pos(2)))
	local move_to = CCMoveTo:create(0.5, mainOption.get_top_res_pos())
	local fun_call = cc.CallFunc:create(deal_with_anim_finish)

	local temp_array = CCArray:create()
	temp_array:addObject(scale_to)
	temp_array:addObject(move_to)
	temp_array:addObject(fun_call)
	local temp_seq = cc.Sequence:create(temp_array)
	temp_widget:runAction(temp_seq)
end

local function dealwithTouchEvent(x,y)
	if not m_layer then
		return false
	end

	if m_is_playing_anim then
		return false
	end

	local temp_widget = m_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		play_disappear_anim()
		return true
	end
end

local function deal_with_next_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if m_is_playing_anim then
			return
		end

		m_disappear_state = true
		play_disappear_anim()
	end
end

local function get_show_width()
	if m_reward_nums > 2 then
		return (m_reward_nums-1)*123 + 104
	else
		return 340
	end
end

local function get_pos_x_by_index(temp_index)
	if m_reward_nums == 1 then
		return 118
	elseif m_reward_nums == 2 then
		if temp_index == 1 then
			return 40
		else
			return 176
		end
	else
		return (temp_index-1)*123
	end
end

local function init_reward_info(temp_widget)
	local reward_base = tolua.cast(temp_widget:getChildByName("res_base_panel"), "Layout")
	local temp_base_width = reward_base:getContentSize().width
	local temp_reward_list = exerciseData.get_exercise_reward_list()
	m_reward_nums = #temp_reward_list

	local reward_content, icon_img, name_txt, num_txt, add_txt = nil, nil, nil, nil, nil
	local temp_name_width, temp_num_width, temp_space_num = nil, nil, nil
	for k,v in pairs(temp_reward_list) do
		reward_content = reward_base:clone()
		reward_content:setName("reward_" .. k)
		reward_content:ignoreAnchorPointForPosition(false)
		reward_content:setAnchorPoint(cc.p(0.5,0))
		reward_content:setPosition(cc.p(get_pos_x_by_index(k) + 52, 197))
		
		icon_img = tolua.cast(reward_content:getChildByName("res_img"), "ImageView")
		icon_img:loadTexture(ResDefineUtil.res_big_icon[v[1]], UI_TEX_TYPE_PLIST)
		name_txt = tolua.cast(reward_content:getChildByName("name_label"), "Label")
		name_txt:setText(rewardName[v[1]])
		num_txt = tolua.cast(reward_content:getChildByName("num_label"), "Label")
		num_txt:setText(v[2])
		add_txt = tolua.cast(reward_content:getChildByName("add_label"), "Label")
		if m_reward_rate ~= 1 then
			add_txt:setText("+" .. (m_reward_rate - 1) * v[2])
		end

		temp_name_width = name_txt:getContentSize().width
		temp_num_width = num_txt:getContentSize().width
		temp_space_num = (temp_base_width - (temp_name_width + temp_num_width))/2
		num_txt:setPositionX(temp_base_width - temp_space_num - temp_num_width)
		name_txt:setPositionX(temp_base_width - temp_space_num - temp_num_width)
		add_txt:setPositionX(temp_base_width - temp_space_num - temp_num_width)

		reward_content:setOpacity(0)
		reward_content:setScale(0.5)
		reward_content:setVisible(true)
		temp_widget:addChild(reward_content)
	end
end

local function init_title_info(temp_widget)
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local teach_img = tolua.cast(title_img:getChildByName("teach_img"), "ImageView")
	local free_img = tolua.cast(title_img:getChildByName("free_img"), "ImageView")
	if exerciseData.is_teach_type() then
		teach_img:setVisible(true)
		free_img:setVisible(false)
	else
		teach_img:setVisible(false)
		free_img:setVisible(true)
	end

	if m_reward_nums > 2 then
		title_img:setPositionX(get_show_width()/2)
	end

	--title_img:setOpacity(0)
end

local function init_des_info(temp_widget)
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")

	if exerciseData.is_teach_type() then
		local teach_tips_txt = tolua.cast(des_img:getChildByName("teach_tips_label"), "Label")
		teach_tips_txt:setVisible(true)
	else
		local free_panel = tolua.cast(des_img:getChildByName("free_panel"), "Layout")
		local num_txt_1 = tolua.cast(free_panel:getChildByName("num_label_1"), "Label")
		num_txt_1:setText(exerciseData.get_exercise_fight_num())

		if m_reward_rate == 1 then
			local sign_txt = tolua.cast(free_panel:getChildByName("sign_2"), "Label")
			sign_txt:setVisible(true)
			local num_txt_2 = tolua.cast(free_panel:getChildByName("num_label_2"), "Label")
			num_txt_2:setVisible(true)
		else
			local spe_img = tolua.cast(free_panel:getChildByName("spe_img"), "ImageView")
			if m_reward_rate == 3 then
				spe_img:loadTexture(ResDefineUtil.exercise_res[20], UI_TEX_TYPE_PLIST)
			end
		end
		
		free_panel:setVisible(true)
	end

	local next_btn = tolua.cast(des_img:getChildByName("next_btn"), "Button")
	local temp_show_type = exerciseData.get_next_btn_show_type()
	if temp_show_type == 1 or temp_show_type == 11 then
		next_btn:setTitleText(languagePack["next_exercise"])
	end
	next_btn:setTouchEnabled(true)
	next_btn:addTouchEventListener(deal_with_next_click)

	if m_reward_nums > 2 then
		des_img:setPositionX(get_show_width()/2)
	end

	--des_img:setOpacity(0)
end

local function deal_with_appear_finish()
	m_is_playing_anim = false
end

local function play_wave_num_anim()
	local temp_widget = m_layer:getWidgetByTag(999)
	local action_time = 0.6
	local move_by = CCMoveBy:create(action_time, ccp(0, 40))
	local fade_seq = cc.Sequence:createWithTwoActions(CCFadeIn:create(0.3), CCFadeOut:create(0.3))
	local temp_spawn = CCSpawn:createWithTwoActions(move_by, fade_seq)

	local reward_content, add_txt = nil, nil
	for i=1,m_reward_nums do
		reward_content = tolua.cast(temp_widget:getChildByName("reward_" .. i), "Layout")
		add_txt = tolua.cast(reward_content:getChildByName("add_label"), "Label")
		if i == 1 then
			local fun_call = cc.CallFunc:create(deal_with_appear_finish)
			local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
			add_txt:runAction(temp_seq)
		else
			add_txt:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCActionInterval"))
		end
		
		add_txt:setVisible(true)
	end
end

local function change_num_fun()
	m_update_times = m_update_times + 1

	local temp_widget = m_layer:getWidgetByTag(999)
	local temp_reward_list = exerciseData.get_exercise_reward_list()

	local reward_content, num_txt, temp_value = nil, nil, nil
	for k,v in pairs(temp_reward_list) do
		reward_content = tolua.cast(temp_widget:getChildByName("reward_" .. k), "Layout")
		num_txt = tolua.cast(reward_content:getChildByName("num_label"), "Label")
		temp_value = math.floor(v[2] + m_update_times * (m_reward_rate * v[2] - v[2])/m_change_times)
		num_txt:setText(temp_value)
	end

	if m_change_times == m_update_times then
		if m_change_timer then
			scheduler.remove(m_change_timer)
			m_change_timer = nil
		end

		play_wave_num_anim()
	end
end

local function deal_with_appear_2()
	local temp_widget = m_layer:getWidgetByTag(999)
	local left_anim = CCMoveBy:create(0.05, ccp(10,0))
	local right_anim = CCMoveBy:create(0.05, ccp(-10,0))
	local top_anim = CCMoveBy:create(0.05, ccp(0,10))
	local bottom_anim = CCMoveBy:create(0.05, ccp(0,-10))
	local temp_array = CCArray:create()
	temp_array:addObject(left_anim)
	temp_array:addObject(right_anim)
	temp_array:addObject(top_anim)
	temp_array:addObject(bottom_anim)
	--local temp_array = {left_anim,right_anim,top_anim,bottom_anim,left_anim:reverse(),right_anim:reverse(),top_anim:reverse(),bottom_anim:reverse()}
	local temp_seq = cc.Sequence:create(temp_array)
	temp_widget:runAction(temp_seq)

	m_change_timer = scheduler.create(change_num_fun, 0.1)
	m_change_times = 5
	m_update_times = 0
end

local function deal_with_appear_1()
	local temp_widget = m_layer:getWidgetByTag(999)
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	local free_panel = tolua.cast(des_img:getChildByName("free_panel"), "Layout")
	local spe_img = tolua.cast(free_panel:getChildByName("spe_img"), "ImageView")
	spe_img:setScale(4)

	local action_time = 0.4
	local scale_to = CCScaleTo:create(action_time, 1)
	local fade_in = CCFadeIn:create(action_time)
	local temp_spawn = CCSpawn:createWithTwoActions(scale_to, fade_in)
	local fun_call = cc.CallFunc:create(deal_with_appear_2)
	local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
	spe_img:runAction(temp_seq)
	spe_img:setVisible(true)
end

local function play_appear_anim(temp_widget)
	local action_time = 0.3
	local reward_spawn = CCSpawn:createWithTwoActions(CCFadeIn:create(action_time), CCScaleTo:create(action_time, 1))

	local reward_content = nil
	for i=1,m_reward_nums do
		reward_content = tolua.cast(temp_widget:getChildByName("reward_" .. i), "Layout")
		reward_content:runAction(tolua.cast(reward_spawn:copy():autorelease(), "CCActionInterval"))
	end

	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	title_img:runAction(CCFadeIn:create(action_time))
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	local fun_call = nil
	if m_reward_rate == 1 then
		fun_call = cc.CallFunc:create(deal_with_appear_finish)
	else
		fun_call = cc.CallFunc:create(deal_with_appear_1)
	end
	local temp_seq = cc.Sequence:createWithTwoActions(CCFadeIn:create(action_time), fun_call)
	des_img:runAction(temp_seq)
end

local function create()
	if m_layer then
		return
	end

	m_is_playing_anim = true
	m_disappear_state = false
	if exerciseData.is_teach_type() then
		m_reward_rate = 1
	else
		m_reward_rate = exerciseData.get_reward_rate_num()
	end

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_4.json")
	temp_widget:setTag(999)

	init_reward_info(temp_widget)
	init_title_info(temp_widget)
	init_des_info(temp_widget)
	if m_reward_nums > 2 then
		temp_widget:setSize(CCSizeMake(get_show_width(), temp_widget:getSize().height))
	end

	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.EXERCISE_FINISH_UI)
	--uiManager.showConfigEffect(uiIndexDefine.EXERCISE_FINISH_UI, m_layer)

	play_appear_anim(temp_widget)
end

exerciseFinishManager = {
							create = create,
							remove_self = remove_self,
							dealwithTouchEvent = dealwithTouchEvent
}