module("tianxiaContentManager", package.seeall)

local m_up_img = nil
local m_down_img = nil
local m_show_tb_view = nil

local m_state_type = nil 		--州编号
local m_content_list = nil

local m_update_list = nil

local loginRewardHelper = nil

function remove_self()
	m_update_list = nil

	m_up_img = nil
	m_down_img = nil
	m_show_tb_view = nil

	m_state_type = nil
	m_content_list = nil

	loginRewardHelper = nil
end

local function tableCellTouched(table,cell)
	local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
	local cell_widget = cell_layer:getWidgetByTag(1)
	local reward_panel = tolua.cast(cell_widget:getChildByName("reward_panel"), "Layout")
	if reward_panel:hitTest(uiManager.getLastPoint()) then
		return
	end

	local state_panel = tolua.cast(cell_widget:getChildByName("state_panel"), "Layout")
	local obtain_btn = tolua.cast(state_panel:getChildByName("obtain_btn"), "Button")
	if obtain_btn:isVisible() and obtain_btn:hitTest(uiManager:getLastPoint()) then
		return
	end

	local temp_cfg_id = m_content_list[cell:getIdx() + 1]
	local temp_sys_info = worldProData.get_sys_pro_info(m_state_type, temp_cfg_id)
	if temp_sys_info then
		require("game/world_process/worldProDetailManager")
		worldProDetailManager.create(m_state_type, temp_cfg_id)
	else
		tipsLayer.create(errorTable[508])
		local temp_need_time = 0.5
	    local unopen_panel = tolua.cast(cell_widget:getChildByName("unopen_panel"), "Layout")
        local light_img = tolua.cast(unopen_panel:getChildByName("light_img"), "ImageView")
       	light_img:setScale(1)
        breathAnimUtil.start_anim(light_img, false, 0, 128, temp_need_time, 1)

        local scale_to = CCScaleTo:create(temp_need_time, 1.05)
        light_img:runAction(scale_to)
        light_img:setVisible(true)
	end
end

local function cellSizeForTable(table,idx)
    return 224, 854
end

local function organize_unopen_show_info(unopen_panel, temp_cfg_id)
	local temp_pre_cfg_id = worldProData.get_pre_process_cfg_id(temp_cfg_id)
	local temp_pre_cfg_info = worldProData.get_world_pro_cfg_info(temp_pre_cfg_id)
	local content_txt = tolua.cast(unopen_panel:getChildByName("content_label"), "Label")
	content_txt:setText(languagePack['wancheng'] .. "[" .. temp_pre_cfg_info.name .. "]" .. languagePack['kaiqi'])
	local light_img = tolua.cast(unopen_panel:getChildByName("light_img"), "ImageView")
	light_img:setSize(CCSizeMake(content_txt:getSize().width, light_img:getSize().height))
	light_img:setVisible(false)
	unopen_panel:setVisible(true)
end

local function organize_rate_show_info(rate_panel, temp_cfg_info, temp_sys_info)
	local temp_all_nums = worldProData.get_rate_max_num(temp_cfg_info, m_state_type)
	local temp_finish_nums = 0
	local temp_process_type = worldProData.worldProProcessType.unopen
	if temp_sys_info then
		temp_finish_nums = temp_sys_info.value
		temp_process_type = temp_sys_info.state
	end

	local temp_percent_state = worldProData.get_percent_condition_type(temp_cfg_info.condition[1])
	if temp_percent_state then
		temp_finish_nums = temp_finish_nums/100
	end

	if temp_finish_nums > temp_all_nums then
		temp_finish_nums = temp_all_nums
	end

	local temp_rate_num = math.floor(temp_finish_nums/temp_all_nums * 100)

	--worldProProcessType = {unopen = 10, running = 0, finish = 1, over_time = 2}

	local num_txt_1 = tolua.cast(rate_panel:getChildByName("num_label"), "Label")
	if temp_percent_state then
		num_txt_1:setText(languagePack['dagnqianjindu'] .. temp_finish_nums .. "%")
	else
		num_txt_1:setText(languagePack['dagnqianjindu'] .. temp_finish_nums .. "/" .. temp_all_nums)
	end
	local num_txt_2 = tolua.cast(rate_panel:getChildByName("percent_label"), "Label")
	num_txt_2:setText(temp_rate_num .. "%")
	tolua.cast(num_txt_2:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)

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

local function organize_rank_show_info(rank_panel, temp_sys_info)
	local temp_rank_list = {}
	if temp_sys_info and temp_sys_info.record ~= "" then
		temp_rank_list = stringFunc.anlayerOnespot(string.sub(temp_sys_info.record, 2, -2), ",", false)
	end

	local sign_txt, name_txt = nil, nil
	for i=1,3 do
		sign_txt = tolua.cast(rank_panel:getChildByName("label_" .. i), "Label")
		name_txt = tolua.cast(rank_panel:getChildByName("content_" .. i), "Label")
		if i > #temp_rank_list then
			sign_txt:setVisible(false)
			name_txt:setVisible(false)
		else
			name_txt:setText(string.sub(temp_rank_list[i], 2, -2))
			sign_txt:setVisible(true)
			name_txt:setVisible(true)
		end
	end

	rank_panel:setVisible(true)
end

local function organize_other_show_info(other_panel, temp_cfg_info, temp_sys_info)
	local is_player_condition = worldProData.get_other_condition_type(temp_cfg_info.condition[1])
	local temp_process_type = worldProData.worldProProcessType.unopen
	if temp_sys_info then
		temp_process_type = temp_sys_info.state
	end

	local title_txt = tolua.cast(other_panel:getChildByName("title_label"), "Label")
	local content_txt = tolua.cast(other_panel:getChildByName("content_label"), "Label")
	if is_player_condition then
		title_txt:setText(languagePack['dachengshili'])
	else
		title_txt:setText(languagePack['dachengtongmeng'])
	end

	if temp_process_type == worldProData.worldProProcessType.unopen or temp_process_type == worldProData.worldProProcessType.running then
		if is_player_condition then
			content_txt:setText(languagePack['zanwushilidacheng'])
		else
			content_txt:setText(languagePack['zanwutongmengdacheng'])
		end
	else
		if is_player_condition then
			local show_list = stringFunc.anlayerOnespot(string.sub(temp_sys_info.record, 2, -2), ",", false)
			content_txt:setText(string.sub(show_list[1], 2, -2))
		else
			content_txt:setText(temp_sys_info.record)
		end
	end

	other_panel:setVisible(true)
end

local function organize_state_show_info(idx, state_panel, temp_cfg_id, temp_sys_info, temp_got_state)
	local temp_process_type = worldProData.worldProProcessType.unopen
	if temp_sys_info then
		temp_process_type = temp_sys_info.state
	end

	local state_img = tolua.cast(state_panel:getChildByName("sign_img"), "ImageView")
	state_img:setVisible(false)
	local content_txt = tolua.cast(state_panel:getChildByName("content_label"), "Label")
	content_txt:setVisible(false)

	local temp_finish_state = false
	if temp_process_type == worldProData.worldProProcessType.unopen then
		state_img:loadTexture(ResDefineUtil.world_process_res[30], UI_TEX_TYPE_PLIST)
		state_img:setVisible(true)
	elseif temp_process_type == worldProData.worldProProcessType.running then
		local leave_time = temp_sys_info.end_time - userData.getServerTime()
		if leave_time >= 0 then
			m_update_list[idx + 1] = temp_sys_info.end_time
			content_txt:setText(languagePack['leave_time'] .. commonFunc.format_time(leave_time))
			content_txt:setVisible(true)
		end
	elseif temp_process_type == worldProData.worldProProcessType.finish then
		state_img:loadTexture(ResDefineUtil.world_process_res[32], UI_TEX_TYPE_PLIST)
		state_img:setVisible(true)
		temp_finish_state = true
	elseif temp_process_type == worldProData.worldProProcessType.over_time then
		state_img:loadTexture(ResDefineUtil.world_process_res[31], UI_TEX_TYPE_PLIST)
		state_img:setVisible(true)
		temp_finish_state = true
	end

	local function deal_with_obtain_click(sender, eventType) 
		if eventType == TOUCH_EVENT_ENDED then
			worldProData.request_obtain_reward(temp_sys_info.id)
		end
	end

	local obtain_btn = tolua.cast(state_panel:getChildByName("obtain_btn"), "Button")
	obtain_btn:setVisible(false)
	obtain_btn:setTouchEnabled(false)
	if temp_finish_state then
		if worldProData.get_reward_obtain_state(m_state_type, temp_cfg_id) then
			if not temp_got_state then
				obtain_btn:addTouchEventListener(deal_with_obtain_click)
				obtain_btn:setTouchEnabled(true)
				obtain_btn:setVisible(true)
			end
		end
	end

	return temp_finish_state
end

local function organize_process_info(cell_widget, temp_cfg_id, temp_cfg_info, temp_sys_info)
	local rank_panel = tolua.cast(cell_widget:getChildByName("rank_panel"), "Layout")
	local rate_panel = tolua.cast(cell_widget:getChildByName("rate_panel"), "Layout")
	local other_panel = tolua.cast(cell_widget:getChildByName("other_panel"), "Layout")
	local unopen_panel = tolua.cast(cell_widget:getChildByName("unopen_panel"), "Layout")
	rank_panel:setVisible(false)
	rate_panel:setVisible(false)
	other_panel:setVisible(false)
	unopen_panel:setVisible(false)

	if not temp_sys_info then
		organize_unopen_show_info(unopen_panel, temp_cfg_id)
		return
	end

	local temp_condition_type = worldProData.get_conditon_type(temp_cfg_info.condition[1])
	if temp_condition_type == worldProData.worldProContentType.rate_type then
		organize_rate_show_info(rate_panel, temp_cfg_info, temp_sys_info)
	elseif temp_condition_type == worldProData.worldProContentType.rank_type then
		organize_rank_show_info(rank_panel, temp_sys_info)
	elseif temp_condition_type == worldProData.worldProContentType.other_type then
		organize_other_show_info(other_panel, temp_cfg_info, temp_sys_info)
	end
end

local function organize_reward_info(idx, reward_panel, temp_cfg_info, temp_got_state, temp_finish_state)	
	local temp_com_reward_list = temp_cfg_info.reward
	local temp_com_reward_rate = 1
	if type(temp_cfg_info.reward_ratio) == "table" then
		temp_com_reward_rate = temp_cfg_info.reward_ratio[1][2]/100
	end

	local temp_spe_reward_list = temp_cfg_info.action

	local temp_decorate_des = worldProData.get_com_reward_decorate_des(temp_cfg_info)

	local function deal_with_com_click(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED and (not uiManager.getLastMoveState()) then
			local select_index = tonumber(string.sub(sender:getName(), 8))
			require("game/world_process/speRewardTipsManager")
			local temp_type = temp_com_reward_list[select_index][1]
			local temp_icon_name = loginRewardHelper.getResIconByRewardType(temp_type)
			local temp_des_content = nil
			if temp_type%100 == dropType.RES_ID_HERO then
				temp_des_content = string.format("%s%s", temp_decorate_des, loginRewardHelper.getResNameByRewardType(temp_type))
			else
				temp_des_content = string.format("%s%s %d", temp_decorate_des, loginRewardHelper.getResNameByRewardType(temp_type), temp_com_reward_rate*temp_com_reward_list[select_index][2])
			end

			speRewardTipsManager.create(temp_icon_name, temp_des_content)
		end
	end

	local function deal_with_spe_click(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED and (not uiManager.getLastMoveState()) then
			local select_index = tonumber(string.sub(sender:getName(), 8))
			require("game/world_process/speRewardTipsManager")
			local temp_type = temp_spe_reward_list[select_index - #temp_com_reward_list]
			local temp_icon_name = worldProData.get_spe_reward_show_info(temp_type, temp_finish_state)
			local temp_des_content = worldProData.get_spe_reward_des(temp_type)
			speRewardTipsManager.create(temp_icon_name, temp_des_content)
		end
	end

	local all_nums = #temp_com_reward_list + #temp_spe_reward_list
	local reward_icon, icon_img, got_img, num_txt = nil, nil, nil, nil
	for i=1,5 do
		reward_icon = tolua.cast(reward_panel:getChildByName("reward_" .. i), "ImageView")
		if i <= all_nums then
			icon_img = tolua.cast(reward_icon:getChildByName("type_img"), "ImageView")
			got_img = tolua.cast(reward_icon:getChildByName("received_img"), "ImageView")
			num_txt = tolua.cast(reward_icon:getChildByName("num_label"), "Label")
			if i <= #temp_com_reward_list then
				icon_img:loadTexture(loginRewardHelper.getResIconByRewardType(temp_com_reward_list[i][1]),UI_TEX_TYPE_PLIST)
				got_img:setVisible(temp_got_state)
				num_txt:setText(temp_com_reward_rate*temp_com_reward_list[i][2])
				reward_icon:addTouchEventListener(deal_with_com_click)
			else
				local temp_icon_name, temp_icon_des = worldProData.get_spe_reward_show_info(temp_spe_reward_list[i - #temp_com_reward_list], temp_finish_state)
				icon_img:loadTexture(temp_icon_name,UI_TEX_TYPE_PLIST)
				got_img:setVisible(false)
				num_txt:setText(temp_icon_des)
				reward_icon:addTouchEventListener(deal_with_spe_click)
			end

			reward_icon:setTouchEnabled(true)
			reward_icon:setVisible(true)
		else
			reward_icon:setTouchEnabled(false)
			reward_icon:setVisible(false)
		end
	end

	if all_nums == 0 then
		reward_panel:setSize(CCSize(10, reward_panel:getSize().height))
	else
		reward_panel:setSize(CCSize((all_nums - 1) * 80 + 62, reward_panel:getSize().height))
	end
end

local function set_cell_content(cell_widget, idx)
	local temp_cfg_id = m_content_list[idx+1]
	local temp_cfg_info = worldProData.get_world_pro_cfg_info(temp_cfg_id)
	local temp_sys_info = worldProData.get_sys_pro_info(m_state_type, temp_cfg_id)
	local temp_got_state = worldProData.get_pro_reward_state(temp_cfg_id)

	local decorate_panel = tolua.cast(cell_widget:getChildByName("decorate_panel"), "Layout")
	local title_txt = tolua.cast(decorate_panel:getChildByName("title_label"), "Label")
	title_txt:setText(temp_cfg_info.name)

	local condition_txt = tolua.cast(decorate_panel:getChildByName("cond_label"), "Label")
	condition_txt:setText(temp_cfg_info.desc)

	local diwen_img = tolua.cast(decorate_panel:getChildByName("diwen_img"), "ImageView")
	diwen_img:loadTexture(ResDefineUtil.world_process_res[temp_cfg_info.bg_res_type], UI_TEX_TYPE_PLIST)

	local state_panel = tolua.cast(cell_widget:getChildByName("state_panel"), "Layout")
	local temp_finish_state = organize_state_show_info(idx, state_panel, temp_cfg_id, temp_sys_info, temp_got_state)

	local reward_panel = tolua.cast(cell_widget:getChildByName("reward_panel"), "Layout")
	organize_reward_info(idx, reward_panel, temp_cfg_info, temp_got_state, temp_finish_state)

	organize_process_info(cell_widget, temp_cfg_id, temp_cfg_info, temp_sys_info)

	local new_sign_img = tolua.cast(decorate_panel:getChildByName("sign_img"), "ImageView")
	if temp_finish_state then
		if worldProData.get_reward_obtain_state(m_state_type, temp_cfg_id) then
			if temp_got_state then
				new_sign_img:setVisible(false)
			else
				new_sign_img:setVisible(true)
			end
		else
			new_sign_img:setVisible(false)
		end
	else
		new_sign_img:setVisible(false)
	end

	local bg_type = tolua.cast(cell_widget:getChildByName("bg_type"), "ImageView")
	local num_txt = tolua.cast(bg_type:getChildByName("num_label"), "Label")
	num_txt:setText((idx + 1))

	local dir_img = tolua.cast(bg_type:getChildByName("dir_img"), "ImageView")
	if idx+1 == #m_content_list then
		dir_img:setVisible(false)
	else
		dir_img:setVisible(true)
	end

	if temp_sys_info then
		GraySprite.create(cell_widget, nil, true)
	else
		GraySprite.create(cell_widget, {"light_img"})
	end
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/shijiejindu_2.json")
	    new_widget:setTag(1)
	    local new_layer = TouchGroup:create()
	    new_layer:setTag(123)
	    new_layer:addWidget(new_widget)
	    cell = CCTableViewCell:new()
	    cell:addChild(new_layer)
	end

	local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local cell_widget = cell_layer:getWidgetByTag(1)
	set_cell_content(cell_widget, idx)
 
    return cell
end

local function numberOfCellsInTableView(table)
	return #m_content_list
end

local function scrollViewDidScroll(table)
	if table:getContentOffset().y < 0 then
		m_down_img:setVisible(true)
	else
		m_down_img:setVisible(false)
	end

	if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
		m_up_img:setVisible(true)
	else
		m_up_img:setVisible(false)
	end
end

function update_time_content()
	if not m_update_list then
		return
	end

	local temp_cell, cell_layer, cell_widget = nil, nil, nil
	local state_panel, content_txt, leave_time = nil, nil, nil
	local is_need_update = false
	for k,v in pairs(m_update_list) do
		temp_cell = m_show_tb_view:cellAtIndex(k-1)
		if temp_cell then
			cell_layer = tolua.cast(temp_cell:getChildByTag(123),"TouchGroup")
	    	cell_widget = cell_layer:getWidgetByTag(1)

			state_panel = tolua.cast(cell_widget:getChildByName("state_panel"), "Layout")
			content_txt = tolua.cast(state_panel:getChildByName("content_label"), "Label")
			leave_time = v - userData.getServerTime()
			if leave_time < 0 then
				is_need_update = true
			else
				content_txt:setText(languagePack['leave_time'] .. commonFunc.format_time(leave_time))
			end
		end
	end

	if is_need_update then
		worldProData.request_process_info(m_state_type)
	end
end

function reload_data(is_locate_new_pos)
	if not m_show_tb_view then
		return
	end

	m_update_list = {}
	m_content_list = worldProData.get_own_server_list()
	local before_offset = nil
	if not is_locate_new_pos then
		before_offset = m_show_tb_view:getContentOffset()
	end
	m_show_tb_view:reloadData()

	if is_locate_new_pos then
		local temp_locate_id = worldProData.get_new_sign_state_for_tianxia()
		if temp_locate_id == 0 then
			temp_locate_id = worldProData.get_running_id_for_tianxia()
		end
		
		if temp_locate_id ~= 0 then
			local init_offset_y = m_show_tb_view:getViewSize().height - m_show_tb_view:getContentSize().height
			local new_offset_y = init_offset_y + (temp_locate_id - 1) * 224
			if new_offset_y < init_offset_y then
				new_offset_y = init_offset_y
			else
				if new_offset_y > 0 then
					new_offset_y = 0
				end
			end
			
			m_show_tb_view:setContentOffsetInDuration(cc.p(0, new_offset_y), 0.5)
		end
	else
		if before_offset.y < m_show_tb_view:getViewSize().height - m_show_tb_view:getContentSize().height then
			before_offset.y = m_show_tb_view:getViewSize().height - m_show_tb_view:getContentSize().height
		end
		m_show_tb_view:setContentOffset(before_offset)
	end
end

function update_scroll_state(scroll_or_not)
	if m_show_tb_view then
		m_show_tb_view:setTouchEnabled(scroll_or_not)
	end
end

function set_tb_visible(show_state)
	if not m_show_tb_view then
		return
	end

	if not show_state then
		m_content_list = {}
		m_show_tb_view:reloadData()
	end

	m_show_tb_view:setTouchEnabled(show_state)
	m_show_tb_view:setVisible(show_state)
end

function create(right_img)
	m_state_type = 0

	loginRewardHelper = require("game/daily/login_reward_helper")

	m_up_img = tolua.cast(right_img:getChildByName("up_img"), "ImageView")
	m_down_img = tolua.cast(right_img:getChildByName("down_img"), "ImageView")

    m_show_tb_view = CCTableView:create(CCSizeMake(right_img:getSize().width, right_img:getSize().height))
    m_show_tb_view:setPosition(cc.p(-1 * right_img:getSize().width/2, -1 * right_img:getSize().height/2))
    m_show_tb_view:setVisible(false)
    m_show_tb_view:setTouchEnabled(false)
	right_img:addChild(m_show_tb_view)
	m_show_tb_view:setDirection(kCCScrollViewDirectionVertical)
	m_show_tb_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_show_tb_view:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    m_show_tb_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    m_show_tb_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_show_tb_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_show_tb_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
end