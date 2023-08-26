module("zhouContentManager", package.seeall)

local m_up_img = nil
local m_down_img = nil
local m_show_tb_view = nil

local m_state_type = nil 		--州编号
local m_content_list = nil

local m_update_list = nil

function remove_self()
	m_update_list = nil

	m_up_img = nil
	m_down_img = nil
	m_show_tb_view = nil

	m_state_type = nil
	m_content_list = nil
end

local function tableCellTouched(table,cell)
	local temp_cfg_id = m_content_list[cell:getIdx() + 1]
	require("game/world_process/worldProDetailManager")
	worldProDetailManager.create(m_state_type, temp_cfg_id)
end

local function cellSizeForTable(table,idx)
    return 140, 854
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

local function organize_state_show_info(idx, state_panel, temp_cfg_id, temp_sys_info)
	local temp_process_type = worldProData.worldProProcessType.unopen
	if temp_sys_info then
		temp_process_type = temp_sys_info.state
	end

	local state_img = tolua.cast(state_panel:getChildByName("sign_img"), "ImageView")
	state_img:setVisible(false)
	local content_txt = tolua.cast(state_panel:getChildByName("content_label"), "Label")
	content_txt:setVisible(false)

	local temp_finish_state = false
	if temp_process_type == worldProData.worldProProcessType.running then
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

	return temp_finish_state
end

local function organize_process_info(cell_widget, temp_cfg_id, temp_cfg_info, temp_sys_info, temp_finish_state)
	local rate_panel = tolua.cast(cell_widget:getChildByName("rate_panel"), "Layout")
	local other_panel = tolua.cast(cell_widget:getChildByName("other_panel"), "Layout")
	rate_panel:setVisible(false)
	other_panel:setVisible(false)

	if temp_finish_state then
		rate_panel:setPositionY(42)
		other_panel:setPositionY(33)
	else
		rate_panel:setPositionY(23)
		other_panel:setPositionY(20)
	end

	local temp_condition_type = worldProData.get_conditon_type(temp_cfg_info.condition[1])
	if temp_condition_type == worldProData.worldProContentType.rate_type then
		organize_rate_show_info(rate_panel, temp_cfg_info, temp_sys_info)
	elseif temp_condition_type == worldProData.worldProContentType.other_type then
		organize_other_show_info(other_panel, temp_cfg_info, temp_sys_info)
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

	local area_panel = tolua.cast(decorate_panel:getChildByName("area_panel"), "Layout")
	local diwen_img = tolua.cast(area_panel:getChildByName("diwen_img"), "ImageView")
	diwen_img:loadTexture(ResDefineUtil.world_process_res[temp_cfg_info.bg_res_type], UI_TEX_TYPE_PLIST)

	local state_panel = tolua.cast(cell_widget:getChildByName("state_panel"), "Layout")
	local temp_finish_state = organize_state_show_info(idx, state_panel, temp_cfg_id, temp_sys_info)

	organize_process_info(cell_widget, temp_cfg_id, temp_cfg_info, temp_sys_info, temp_finish_state)

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
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/shijiejindu_6.json")
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

function reload_data()
	if not m_show_tb_view then
		return
	end

	m_update_list = {}
	m_content_list = worldProData.get_own_state_list()
	m_show_tb_view:reloadData()
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

function set_process_content(state_index)
	m_state_type = state_index
end

function create(right_img)
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

    --reload_data()
end