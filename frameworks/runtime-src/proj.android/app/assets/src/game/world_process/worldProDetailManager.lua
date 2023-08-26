local m_layer = nil
local m_main_widget = nil
local m_state_type = nil
local m_cfg_id = nil

local m_up_img = nil
local m_down_img = nil

local m_end_time = nil
local m_update_timer = nil

local ColorUtil = nil
local loginRewardHelper = nil

local function do_remove_self()
	if m_layer then
		if m_update_timer then
			scheduler.remove(m_update_timer)
			m_update_timer = nil
		end

		ColorUtil = nil
		loginRewardHelper = nil

		m_up_img = nil
		m_down_img = nil

		m_end_time = nil
		m_cfg_id = nil
		m_state_type = nil

		m_main_widget = nil
		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.WORLD_PROCESS_DETAIL_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.WORLD_PROCESS_DETAIL_UI, m_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not m_layer then
		return false
	end

	if m_main_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_obtain_click(sender, eventType) 
	if eventType == TOUCH_EVENT_ENDED then
		local temp_sys_info = worldProData.get_sys_pro_info(m_state_type, m_cfg_id)
		worldProData.request_obtain_reward(temp_sys_info.id)
	end
end

local function deal_with_scroll_event(sender, eventType)
    if eventType == SCROLLVIEW_EVENT_SCROLLING then
    	m_up_img:setVisible(true)
	    m_down_img:setVisible(true)
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_TOP then
		m_up_img:setVisible(false)
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
    	m_down_img:setVisible(false)
    end
end

local function organize_condition_info(condition_panel, temp_cfg_info, temp_sys_info, temp_got_state)
	local content_txt = tolua.cast(condition_panel:getChildByName("des_label"), "Label")
	local state_img = tolua.cast(condition_panel:getChildByName("state_img"), "ImageView")
	content_txt:ignoreContentAdaptWithSize(true)
	content_txt:setTextAreaSize(CCSize(content_txt:getContentSize().width, 0))
	content_txt:setText(temp_cfg_info.detail_desc)
	local add_height = content_txt:getContentSize().height - 27
	if add_height > 0 then
		local title_bg_img = tolua.cast(condition_panel:getChildByName("title_bg_img"), "ImageView")
		title_bg_img:setPositionY(title_bg_img:getPositionY() + add_height)
		condition_panel:setSize(CCSize(condition_panel:getSize().width, condition_panel:getSize().height + add_height))
		state_img:setPositionY(state_img:getPositionY() + add_height)
	end
	
	local temp_process_type = temp_sys_info.state
	local temp_finish_state = false
	if temp_process_type == worldProData.worldProProcessType.finish then
		state_img:loadTexture(ResDefineUtil.world_process_res[32], UI_TEX_TYPE_PLIST)
		state_img:setVisible(true)
		temp_finish_state = true
	elseif temp_process_type == worldProData.worldProProcessType.over_time then
		state_img:loadTexture(ResDefineUtil.world_process_res[31], UI_TEX_TYPE_PLIST)
		state_img:setVisible(true)
		temp_finish_state = true
	end

	local tips_txt = tolua.cast(condition_panel:getChildByName("tips_label"), "Label")
	if temp_finish_state then
		if temp_cfg_info.result_desc == "" then
			tips_txt:setVisible(false)
		else
			tips_txt:setText(temp_cfg_info.result_desc)
			--tips_txt:setVisible(true)
		end
	else
		tips_txt:setVisible(false)
	end

	return temp_finish_state
end

local function organize_com_rank_info(rank_panel, temp_sys_info)
	local temp_rank_list = stringFunc.anlayerOnespot(string.sub(temp_sys_info.record, 2, -2), ",", false)
	local all_nums = #temp_rank_list
	local show_lines = nil
	if all_nums%2 == 0 then
		show_lines = all_nums/2
	else
		show_lines = math.floor(all_nums/2) + 1
	end

	local base_panel = tolua.cast(rank_panel:getChildByName("base_panel"), "Layout")
	local temp_index, temp_show_content = nil, nil
	local rank_icon, name_txt = nil, nil
	for i=1,2 do
		for j=1,show_lines do
			temp_index = (i-1) * show_lines + j
			if temp_index <= all_nums then
				rank_icon = base_panel:clone()
				rank_icon:setPosition(cc.p(20 + (i-1) * 288, (show_lines - j) * 30))
				name_txt = tolua.cast(rank_icon:getChildByName("label_3"), "Label")
				temp_show_content = string.format(languagePack['shijiejindupaiming'], temp_index, string.sub(temp_rank_list[temp_index], 2, -2))
				name_txt:setText(temp_show_content)
				name_txt:setVisible(true)
				rank_icon:setVisible(true)
				rank_panel:addChild(rank_icon)
			end
		end
	end

	rank_panel:setSize(CCSize(rank_panel:getSize().width, show_lines * 30))
end

local function organize_city_rank_info(rank_panel, temp_sys_info)
	local temp_rank_list = stateData.getNpcCityInState(m_state_type)
	local temp_occupy_list = stringFunc.anlayerOnespot(string.sub(temp_sys_info.record, 2, -2), ",", false)

	local function get_occupy_state(temp_city_id)
		for k,v in pairs(temp_occupy_list) do
			if k%2 == 1 then
				if tonumber(v) == temp_city_id then
					return true, string.sub(temp_occupy_list[k+1], 2, -2)
				end
			end
		end

		return false, languagePack['weizhanling']
	end

	local all_nums = #temp_rank_list
	local show_lines = nil
	if all_nums%2 == 0 then
		show_lines = all_nums/2
	else
		show_lines = math.floor(all_nums/2) + 1
	end

	local base_panel = tolua.cast(rank_panel:getChildByName("base_panel"), "Layout")
	local temp_index, temp_world_city_info, occupy_or_not, occupy_union_name = nil, nil, nil, nil
	local rank_icon, name_txt, state_txt = nil, nil, nil
	for i=1,2 do
		for j=1,show_lines do
			temp_index = (i-1) * show_lines + j
			if temp_index <= all_nums then
				rank_icon = base_panel:clone()
				rank_icon:setPosition(cc.p(20 + (i-1) * 288, (show_lines - j) * 30))
				temp_world_city_info = Tb_cfg_world_city[temp_rank_list[temp_index]]
				name_txt = tolua.cast(rank_icon:getChildByName("label_1"), "Label")
				name_txt:setText(temp_world_city_info.name .. "(Lv." .. (temp_world_city_info.param%100) .. ")")
				name_txt:setVisible(true)
				state_txt = tolua.cast(rank_icon:getChildByName("label_2"), "Label")
				occupy_or_not, occupy_union_name = get_occupy_state(temp_rank_list[temp_index])
				if not occupy_or_not then
					state_txt:setColor(ccc3(125, 187, 139))
				end
				state_txt:setText(occupy_union_name)
				state_txt:setVisible(true)
				rank_icon:setVisible(true)
				rank_panel:addChild(rank_icon)
			end
		end
	end

	rank_panel:setSize(CCSize(rank_panel:getSize().width, show_lines * 30))
end

local function organize_rank_show_info(rank_panel, temp_cfg_info, temp_sys_info)
	local city_or_not = worldProData.is_show_city_list(temp_cfg_info.condition[1])
	if temp_cfg_info.progress_type == 0 then
		if city_or_not then
			rank_panel:setVisible(false)
			return false
		else
			organize_com_rank_info(rank_panel, temp_sys_info)
			rank_panel:setVisible(true)
			return true
		end
	else
		if city_or_not then
			organize_city_rank_info(rank_panel, temp_sys_info)
		else
			organize_com_rank_info(rank_panel, temp_sys_info)
		end

		rank_panel:setVisible(true)
		return true
	end
end

local function organize_rate_show_info(rate_panel, temp_cfg_info, temp_sys_info)
	local temp_all_nums = worldProData.get_rate_max_num(temp_cfg_info, m_state_type)
	local temp_finish_nums = temp_sys_info.value
	local temp_process_type = temp_sys_info.state

	local temp_percent_state = worldProData.get_percent_condition_type(temp_cfg_info.condition[1])
	if temp_percent_state then
		temp_finish_nums = temp_finish_nums/100
	end

	if temp_finish_nums > temp_all_nums then
		temp_finish_nums = temp_all_nums
	end

	local temp_rate_num = math.floor(temp_finish_nums/temp_all_nums * 100)
	local num_txt = tolua.cast(rate_panel:getChildByName("num_label"), "Label")
	num_txt:setText(temp_rate_num .. "%")
	tolua.cast(num_txt:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)

	local loading_bar_1 = tolua.cast(rate_panel:getChildByName("loading_bar_1"), "LoadingBar")
	local loading_bar_2 = tolua.cast(rate_panel:getChildByName("loading_bar_2"), "LoadingBar")
	loading_bar_1:setVisible(false)
	loading_bar_2:setVisible(false)
	if temp_process_type == worldProData.worldProProcessType.over_time then
		loading_bar_2:setPercent(temp_rate_num)
		loading_bar_2:setVisible(true)
	else
		loading_bar_1:setPercent(temp_rate_num)
		loading_bar_1:setVisible(true)
	end

	rate_panel:setVisible(true)
end

local function organize_other_show_info(other_panel, temp_cfg_info, temp_sys_info)
	local is_player_condition = worldProData.get_other_condition_type(temp_cfg_info.condition[1])
	local temp_process_type = temp_sys_info.state

	local title_txt = tolua.cast(other_panel:getChildByName("sign_label"), "Label")
	local content_txt = tolua.cast(other_panel:getChildByName("content_label"), "Label")
	if is_player_condition then
		title_txt:setText(languagePack['dachengshili'])
	else
		title_txt:setText(languagePack['dachengtongmeng'])
	end

	if temp_process_type == worldProData.worldProProcessType.running then
		if is_player_condition then
			content_txt:setText(languagePack['zanwushilidacheng'])
		else
			content_txt:setText(languagePack['zanwutongmengdacheng'])
		end
	else
		if temp_sys_info.record == "" then
			if is_player_condition then
				content_txt:setText(temp_cfg_info.name .. languagePack['yijingjieshu'] .. "," .. languagePack['zanwushilidacheng'])
			else
				content_txt:setText(temp_cfg_info.name .. languagePack['yijingjieshu'] .. "," .. languagePack['zanwutongmengdacheng'])
			end
		else
			if is_player_condition then
				local show_list = stringFunc.anlayerOnespot(string.sub(temp_sys_info.record, 2, -2), ",", false)
				content_txt:setText(string.sub(show_list[1], 2, -2))
			else
				content_txt:setText(temp_sys_info.record)
			end
		end
	end

	other_panel:setVisible(true)
end

local function organize_time_info(time_panel, temp_sys_info)
	local show_time_num = 0
	local temp_time_name = nil
	local temp_process_type = temp_sys_info.state
	if temp_process_type == worldProData.worldProProcessType.finish then
		temp_time_name = languagePack['dachengshijian']
		show_time_num = temp_sys_info.finish_time
	elseif temp_process_type == worldProData.worldProProcessType.over_time then
		temp_time_name = languagePack['jieshushijian']
		show_time_num = temp_sys_info.end_time
	end
	if show_time_num ~= 0 then
		local time_sign_txt = tolua.cast(time_panel:getChildByName("sign_label"), "Label")
		local time_num_txt = tolua.cast(time_panel:getChildByName("num_label"), "Label")
		time_sign_txt:setText(temp_time_name)
		time_num_txt:setText(commonFunc.format_date(show_time_num))
		time_panel:setVisible(true)

		return true
	else
		return false
	end
end

local function organize_process_info(process_panel, temp_cfg_info, temp_sys_info)
	local time_panel = tolua.cast(process_panel:getChildByName("time_panel"), "Layout") 
	local is_show_time = organize_time_info(time_panel, temp_sys_info)

	local temp_condition_type = worldProData.get_conditon_type(temp_cfg_info.condition[1])
	if temp_condition_type == worldProData.worldProContentType.other_type then
		local other_panel = tolua.cast(process_panel:getChildByName("other_panel"), "Layout")
		organize_other_show_info(other_panel, temp_cfg_info, temp_sys_info)
		return
	end

	local is_show_percent = false
	local rate_panel = tolua.cast(process_panel:getChildByName("rate_panel"), "Layout")
	if temp_condition_type == worldProData.worldProContentType.rate_type then
		organize_rate_show_info(rate_panel, temp_cfg_info, temp_sys_info)
		is_show_percent = true
		if not worldProData.is_show_rank_in_detail(temp_cfg_info.condition[1]) then
			return
		end
	end

	local rank_panel = tolua.cast(process_panel:getChildByName("rank_panel"), "Layout")
	local is_show_rank = organize_rank_show_info(rank_panel, temp_cfg_info, temp_sys_info)
	if not is_show_rank then
		return
	end

	if is_show_time then
		rank_panel:setPositionY(time_panel:getPositionY() + time_panel:getSize().height + 2)
	end

	if is_show_percent then
		rate_panel:setPositionY(rank_panel:getPositionY() + rank_panel:getSize().height + 2)
		if rate_panel:getPositionY() + rate_panel:getSize().height > process_panel:getSize().height then
			process_panel:setSize(CCSize(process_panel:getSize().width, rate_panel:getPositionY() + rate_panel:getSize().height))
		else
			rate_panel:setPositionY(process_panel:getSize().height - rate_panel:getSize().height)
			rank_panel:setPositionY(rate_panel:getPositionY() - 2 - rank_panel:getSize().height)
		end
	else
		if rank_panel:getPositionY() + rank_panel:getSize().height > process_panel:getSize().height then
			process_panel:setSize(CCSize(process_panel:getSize().width, rank_panel:getPositionY() + rank_panel:getSize().height))
		else
			rank_panel:setPositionY(process_panel:getSize().height - rank_panel:getSize().height)
		end
	end
end

local function organize_reward_info(reward_panel, temp_cfg_info, temp_finish_state)
	local temp_com_reward_list = temp_cfg_info.reward
	local temp_com_reward_rate = 1
	if type(temp_cfg_info.reward_ratio) == "table" then
		temp_com_reward_rate = temp_cfg_info.reward_ratio[1][2]/100
	end

	local temp_spe_reward_list = temp_cfg_info.action
	local all_nums = #temp_com_reward_list + #temp_spe_reward_list
	if all_nums == 0 then
		reward_panel:setVisible(false)
		return false
	end

	local show_lines = nil
	if all_nums%2 == 0 then
		show_lines = all_nums/2
	else
		show_lines = math.floor(all_nums/2) + 1
	end

	local temp_decorate_des = worldProData.get_com_reward_decorate_des(temp_cfg_info)

	local base_panel = tolua.cast(reward_panel:getChildByName("base_panel"), "Layout")
	local temp_index, temp_type, temp_show_content = nil, nil, nil
	local reward_icon, icon_img, des_txt, num_txt = nil, nil, nil, nil
	for i=show_lines,1,-1 do
		for j=1,2 do
			temp_index = (i-1)*2 + j

			if temp_index <= all_nums then
				reward_icon = base_panel:clone()
				reward_icon:setPosition(cc.p(30 + (j-1) * 280, (show_lines - i) * 60))
				icon_img = tolua.cast(reward_icon:getChildByName("type_img"), "ImageView")
				des_txt = tolua.cast(reward_icon:getChildByName("des_label"), "Label")
				if temp_index <= #temp_com_reward_list then
					temp_type = temp_com_reward_list[i][1]
					icon_img:loadTexture(loginRewardHelper.getResIconByRewardType(temp_type),UI_TEX_TYPE_PLIST)
					if temp_type%100 == dropType.RES_ID_HERO then
						temp_show_content = string.format("%s%s", temp_decorate_des, loginRewardHelper.getResNameByRewardType(temp_type))
						des_txt:setText(temp_show_content)
        				--des_txt:setColor(ColorUtil.getHeroColor(Tb_cfg_hero[math.floor(temp_type/100)].quality))
					else
						temp_show_content = string.format("%s%s %d", temp_decorate_des, loginRewardHelper.getResNameByRewardType(temp_type), temp_com_reward_rate*temp_com_reward_list[i][2])
						des_txt:setText(temp_show_content)
					end
				else
					temp_type = temp_spe_reward_list[temp_index - #temp_com_reward_list]
					local temp_icon_name, temp_icon_des = worldProData.get_spe_reward_show_info(temp_type, temp_finish_state)
					icon_img:loadTexture(temp_icon_name,UI_TEX_TYPE_PLIST)
					des_txt:setText(worldProData.get_spe_reward_des(temp_type))
				end
				reward_icon:setVisible(true)
				reward_panel:addChild(reward_icon)
			end
		end
	end

	if all_nums > 2 then
		local title_img = tolua.cast(reward_panel:getChildByName("title_img"), "ImageView")
		title_img:setPositionY((show_lines*60 + title_img:getSize().height/2))
		local line_img = tolua.cast(reward_panel:getChildByName("line_img"), "ImageView")
		line_img:setPositionY(show_lines* 60 + title_img:getSize().height + 2)

		reward_panel:setSize(CCSize(reward_panel:getSize().width, line_img:getPositionY() + 2))
	end

	return true
end

local function update_time_content()
	local op_panel = tolua.cast(m_main_widget:getChildByName("op_panel"), "Layout")
	local leave_txt = tolua.cast(op_panel:getChildByName("num_label"), "Label")
	local leave_time = m_end_time - userData.getServerTime()
	if leave_time >= 0 then
		leave_txt:setText(languagePack['leave_time'] .. commonFunc.format_time(leave_time))
	else
		leave_txt:setVisible(false)
		scheduler.remove(m_update_timer)
		m_update_timer = nil
	end
end

local function organize_op_info(temp_cfg_info, temp_sys_info, temp_got_state)
	local op_panel = tolua.cast(m_main_widget:getChildByName("op_panel"), "Layout")
	local sign_img = tolua.cast(op_panel:getChildByName("sign_img"), "ImageView")
	local tips_txt = tolua.cast(op_panel:getChildByName("tips_label"), "Label")
	local leave_txt = tolua.cast(op_panel:getChildByName("num_label"), "Label")
	local obtain_btn = tolua.cast(op_panel:getChildByName("obtain_btn"), "Button")
	sign_img:setVisible(false)
	tips_txt:setVisible(false)
	leave_txt:setVisible(false)
	obtain_btn:setTouchEnabled(false)
	obtain_btn:setVisible(false)

	local temp_process_type = temp_sys_info.state
	if temp_process_type == worldProData.worldProProcessType.running then
		tips_txt:setText("【" .. temp_cfg_info.name .. "】" .. languagePack['jindujinxing'])
		tips_txt:setPositionY(50)
		sign_img:setPosition(cc.p(tips_txt:getPositionX() - tips_txt:getContentSize().width/2, 50))
		tips_txt:setVisible(true)
		sign_img:setVisible(true)

		local leave_time = temp_sys_info.end_time - userData.getServerTime()
		if leave_time >= 0 then
			m_end_time = temp_sys_info.end_time
			leave_txt:setText(languagePack['leave_time'] .. commonFunc.format_time(leave_time))
			leave_txt:setVisible(true)

			m_update_timer = scheduler.create(update_time_content, 1)
		end
	else
		if worldProData.get_reward_obtain_state(m_state_type, m_cfg_id) then
			if temp_got_state then
				tips_txt:setText(languagePack['yijinglingqu'])
				tips_txt:setPositionY(34)
				sign_img:setPosition(cc.p(tips_txt:getPositionX() - tips_txt:getContentSize().width/2, 34))
				tips_txt:setVisible(true)
				sign_img:setVisible(true)
			else
				obtain_btn:addTouchEventListener(deal_with_obtain_click)
				obtain_btn:setTouchEnabled(true)
				obtain_btn:setVisible(true)
			end
		end
	end
end

local function create(temp_state_type, temp_cfg_id)
	if m_layer then
		return
	end

	ColorUtil = require("game/utils/color_util")
	loginRewardHelper = require("game/daily/login_reward_helper")

	m_state_type = temp_state_type
	m_cfg_id = temp_cfg_id
	local temp_cfg_info = worldProData.get_world_pro_cfg_info(m_cfg_id)
	local temp_sys_info = worldProData.get_sys_pro_info(m_state_type, m_cfg_id)
	local temp_got_state = worldProData.get_pro_reward_state(m_cfg_id)

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/shijiejindu_3.json")
	m_main_widget:setTag(999)
	m_main_widget:setScale(config.getgScale())
	m_main_widget:ignoreAnchorPointForPosition(false)
	m_main_widget:setAnchorPoint(cc.p(0.5,0.5))
	m_main_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	--m_up_img = tolua.cast(m_main_widget:getChildByName("up_img"), "ImageView")
    --m_down_img = tolua.cast(m_main_widget:getChildByName("down_img"), "ImageView")
    --breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)

   	local title_img = tolua.cast(m_main_widget:getChildByName("title_img"), "ImageView")
   	local title_txt = tolua.cast(title_img:getChildByName("content_label"), "Label")
   	title_txt:setText(temp_cfg_info.name)

   	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
   	local temp_sv = tolua.cast(content_img:getChildByName("scroll_view"), "ScrollView")
   	temp_sv:addEventListenerScrollView(deal_with_scroll_event)
   	local condition_panel = tolua.cast(temp_sv:getChildByName("cond_panel"), "Layout")
   	local temp_finish_state = organize_condition_info(condition_panel, temp_cfg_info, temp_sys_info, temp_got_state)

   	local des_panel = tolua.cast(temp_sv:getChildByName("des_panel"), "Layout")
   	organize_process_info(des_panel, temp_cfg_info, temp_sys_info)

   	local reward_panel = tolua.cast(temp_sv:getChildByName("reward_panel"), "Layout")
   	local temp_show_reward = organize_reward_info(reward_panel, temp_cfg_info, temp_finish_state)

   	m_up_img = tolua.cast(content_img:getChildByName("up_img"), "ImageView")
    m_down_img = tolua.cast(content_img:getChildByName("down_img"), "ImageView")
    breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)

    if temp_show_reward then
    	des_panel:setPositionY(reward_panel:getPositionY() + reward_panel:getSize().height)
    else
    	des_panel:setPositionY(reward_panel:getPositionY())
    end
    
    condition_panel:setPositionY(des_panel:getPositionY() + des_panel:getSize().height)
    local real_height = condition_panel:getPositionY() + condition_panel:getSize().height
    if real_height > content_img:getSize().height then
    	temp_sv:setTouchEnabled(true)
		temp_sv:setInnerContainerSize(CCSizeMake(temp_sv:getContentSize().width, real_height))
		temp_sv:jumpToTop()
		m_down_img:setVisible(false)
    else
    	if not temp_show_reward then
    		des_panel:setPositionY(des_panel:getPositionY() + reward_panel:getSize().height)
    		condition_panel:setPositionY(condition_panel:getPositionY() + reward_panel:getSize().height)
    	end
    	temp_sv:setTouchEnabled(false)
    end

   	organize_op_info(temp_cfg_info, temp_sys_info, temp_got_state)

	m_layer = TouchGroup:create()
	m_layer:addWidget(m_main_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.WORLD_PROCESS_DETAIL_UI)
	uiManager.showConfigEffect(uiIndexDefine.WORLD_PROCESS_DETAIL_UI, m_layer)
end

local function deal_with_obtain_response()
	if not m_layer then
		return
	end

	local op_panel = tolua.cast(m_main_widget:getChildByName("op_panel"), "Layout")
	local sign_img = tolua.cast(op_panel:getChildByName("sign_img"), "ImageView")
	local tips_txt = tolua.cast(op_panel:getChildByName("tips_label"), "Label")
	local leave_txt = tolua.cast(op_panel:getChildByName("num_label"), "Label")
	local obtain_btn = tolua.cast(op_panel:getChildByName("obtain_btn"), "Button")
	sign_img:setVisible(false)
	tips_txt:setVisible(false)
	leave_txt:setVisible(false)
	obtain_btn:setTouchEnabled(false)
	obtain_btn:setVisible(false)
	tips_txt:setText(languagePack['yijinglingqu'])
	tips_txt:setPositionY(34)
	sign_img:setPosition(cc.p(tips_txt:getPositionX() - tips_txt:getContentSize().width/2, 34))
	tips_txt:setVisible(true)
	sign_img:setVisible(true)


	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
   	local temp_sv = tolua.cast(content_img:getChildByName("scroll_view"), "ScrollView")
   	local condition_panel = tolua.cast(temp_sv:getChildByName("cond_panel"), "Layout")
	local state_img = tolua.cast(condition_panel:getChildByName("state_img"), "ImageView")
	state_img:loadTexture(ResDefineUtil.world_process_res[31], UI_TEX_TYPE_PLIST)
	state_img:setVisible(true)
end

worldProDetailManager = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						deal_with_obtain_response = deal_with_obtain_response
}