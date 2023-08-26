local m_cell_list = nil 		--单元格子列表
local m_cell_width = nil 		--单元格子的宽度
local m_cell_height = nil 		--单元格子的高度
local m_cell_spacing = nil 		--单元格子的间距
local m_called_spacing = nil 	--点击抽卡方式时出现的具体招募格子宽度

local m_sv_width = nil 			--滚动显示区域宽度
local m_sv_height = nil 		--滚动显示区域高度

local m_show_cell_nums = nil 		--当前显示的抽卡方式数量
local m_last_selected_index = nil 	--上一个选中的单元
local m_current_select_index = nil 	--选中的单元

local m_way_action_time_1 = nil 	--点击抽卡方式出现可以招募按钮的动画时间
local m_way_action_time_2 = nil 	--滑动列表时选中状态消失的动画时间
local m_is_playing_anim = nil 		--是否正在播放动画

local m_is_new_get_anim = nil 		--是否正在播放初始获取新抽卡方式的动画

local function remove()
	m_cell_list = nil
	m_cell_width = nil
	m_cell_height = nil
	m_cell_spacing = nil
	m_called_spacing = nil

	m_sv_width = nil
	m_sv_height = nil

	m_show_cell_nums = nil
	m_last_selected_index = nil
	m_current_select_index = nil

	m_way_action_time_1 = nil
	m_way_action_time_2 = nil
	m_is_playing_anim = nil

	m_is_new_get_anim = nil
end

local function set_cell_list_related_info(new_index, all_nums)
	m_show_cell_nums = all_nums

	m_last_selected_index = 0
	m_current_select_index = new_index
end

local function get_cell_by_index(idx)
	return m_cell_list[idx]
end

local function set_sv_inner_info(temp_sv)
	local temp_real_width = 0
	if m_show_cell_nums ~= 0 then
		temp_real_width = (m_show_cell_nums - 1) * (m_cell_width + m_cell_spacing) + m_cell_width
		if m_current_select_index ~= 0 then
			temp_real_width = temp_real_width + m_called_spacing
		end
	end

	local temp_container = temp_sv:getInnerContainer()
	if temp_real_width > m_sv_width then
		temp_sv:setInnerContainerSize(CCSizeMake(temp_real_width, m_sv_height))
		if temp_container:getPositionX() > temp_real_width - m_sv_width then
			temp_container:setPositionX(temp_real_width - m_sv_width)
		end
	else
		temp_sv:setInnerContainerSize(CCSizeMake(m_sv_width, m_sv_height))
		temp_container:setPositionX(0)
	end
end

local function reset_cell_content(cell_index, cell_widget)
	local name_list = {"new_sign_img", "spe_sign_panel", "list_spe_img", "leave_label", "sign_img", "res_label", "star_img", "time_label", "select_img", "unused_panel", "new_light_img"}
	local type_list = {"ImageView", "Layout", "ImageView", "Label", "ImageView", "Label", "Label", "ImageView", "Label", "ImageView", "Layout", "ImageView"}

	local cell_content = tolua.cast(cell_widget:getChildByName("content_img"), "ImageView")
	for k,v in pairs(name_list) do
		local temp_componment = tolua.cast(cell_content:getChildByName(v), type_list[k])
		if v == "select_img" then
			if cell_index == m_current_select_index then
				temp_componment:setVisible(true)
			else
				temp_componment:setVisible(false)
			end
		else
			temp_componment:setVisible(false)
		end
	end

	local high_star_area_panel = tolua.cast(cell_content:getChildByName("high_star_area_panel"), "Layout")
	local high_star_content_img = tolua.cast(high_star_area_panel:getChildByName("content_img"), "ImageView")
	high_star_content_img:stopAllActions()
	high_star_area_panel:setVisible(false)

	local temp_call_img = tolua.cast(cell_widget:getChildByName("call_img"), "ImageView")
	local btn_1 = tolua.cast(temp_call_img:getChildByName("btn_1"), "Button")
	local btn_2 = tolua.cast(temp_call_img:getChildByName("btn_2"), "Button")
	local ex_btn = tolua.cast(temp_call_img:getChildByName("ex_btn"), "Button")
	if cell_index == m_current_select_index then
		temp_call_img:setVisible(true)
		temp_call_img:setPositionX(m_cell_width/2 + m_called_spacing)
	else
		temp_call_img:setVisible(false)
		temp_call_img:setPositionX(m_cell_width/2)
	end
	btn_1:setTouchEnabled(false)
	btn_2:setTouchEnabled(false)
	ex_btn:setTouchEnabled(false)

	cell_widget:setTouchEnabled(false)
end

local function reset_list_layout_info(temp_sv, cell_click_event, call_btn_click, ex_btn_click)
	local own_cell_nums = #m_cell_list
	if m_show_cell_nums > own_cell_nums then
		local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/callCardCell.json")
		for i=own_cell_nums+1,m_show_cell_nums do
			local cell_widget = base_widget:clone()
			cell_widget:setName("cell_" .. i)
			cell_widget:addTouchEventListener(cell_click_event)

			local call_img = tolua.cast(cell_widget:getChildByName("call_img"), "ImageView")
			local btn_1 = tolua.cast(call_img:getChildByName("btn_1"), "Button")
			local btn_2 = tolua.cast(call_img:getChildByName("btn_2"), "Button")
			local ex_btn = tolua.cast(call_img:getChildByName("ex_btn"), "Button")
			btn_1:addTouchEventListener(call_btn_click)
			btn_2:addTouchEventListener(call_btn_click)
			ex_btn:addTouchEventListener(ex_btn_click)

			temp_sv:addChild(cell_widget)

			table.insert(m_cell_list, cell_widget)
		end
	end

	for k,v in pairs(m_cell_list) do
		reset_cell_content(k, v)
		if k > m_show_cell_nums then
			v:setVisible(false)
			v:setPositionX(0)
		else
			v:setVisible(true)
			if m_current_select_index ~= 0 then
				if k > m_current_select_index then
					v:setPositionX((k-1) * (m_cell_width + m_cell_spacing) + m_called_spacing)
				else
					v:setPositionX((k-1) * (m_cell_width + m_cell_spacing))
				end
			else
				v:setPositionX((k-1) * (m_cell_width + m_cell_spacing))
			end
		end
	end

	set_sv_inner_info(temp_sv)
end

local function deal_with_list_anim_finish()
	if m_last_selected_index ~= 0 then
		local last_selected_widght = m_cell_list[m_last_selected_index]
		local last_call_img = tolua.cast(last_selected_widght:getChildByName("call_img"), "ImageView")
		last_call_img:setVisible(false)
	end
	m_is_playing_anim = false

	newGuideInfo.enter_next_guide()
end

local function play_last_disappear_anim()
	if m_last_selected_index == 0 then
		return
	end

	local last_selected_widght = m_cell_list[m_last_selected_index]
	local last_content_img = tolua.cast(last_selected_widght:getChildByName("content_img"), "ImageView")
	local last_selected_sign_img = tolua.cast(last_content_img:getChildByName("select_img"), "ImageView")
	last_selected_sign_img:setVisible(false)

	local last_call_img = tolua.cast(last_selected_widght:getChildByName("call_img"), "ImageView")
	local btn_1 = tolua.cast(last_call_img:getChildByName("btn_1"), "Button")
	local btn_2 = tolua.cast(last_call_img:getChildByName("btn_2"), "Button")
	local ex_btn = tolua.cast(last_call_img:getChildByName("ex_btn"), "Button")
	btn_1:setTouchEnabled(false)
	btn_2:setTouchEnabled(false)
	ex_btn:setTouchEnabled(false)

	local fade_out = CCFadeOut:create(m_way_action_time_1)
	local move_by = CCMoveBy:create(m_way_action_time_1, ccp(-1 * m_called_spacing, 0))
	move_by = CCEaseSineInOut:create(move_by)
	local fade_out_seq = CCSpawn:createWithTwoActions(fade_out, move_by)
	last_call_img:runAction(fade_out_seq)
end

local function play_current_appear_anim()
	local current_selected_widget = m_cell_list[m_current_select_index]
	local current_content_img = tolua.cast(current_selected_widget:getChildByName("content_img"), "ImageView")
	local current_selected_sign_img = tolua.cast(current_content_img:getChildByName("select_img"), "ImageView")
	current_selected_sign_img:setVisible(true)

	local current_call_img = tolua.cast(current_selected_widget:getChildByName("call_img"), "ImageView")
	current_call_img:setVisible(true)

	local fade_in = CCFadeIn:create(m_way_action_time_1)
	local move_by = CCMoveBy:create(m_way_action_time_1, ccp(m_called_spacing, 0))
	move_by = CCEaseSineInOut:create(move_by)
	local fade_in_spawn = CCSpawn:createWithTwoActions(fade_in, move_by)
	local fun_call = cc.CallFunc:create(deal_with_list_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in_spawn, fun_call)
	current_call_img:runAction(temp_seq)
end

local function play_list_change_anim()
	local first_move_by = CCMoveBy:create(m_way_action_time_1, ccp(m_called_spacing, 0))
	first_move_by = CCEaseSineInOut:create(first_move_by)

	local start_index, end_index = nil, nil
	if m_last_selected_index == 0 then
		start_index = m_current_select_index + 1
		end_index = m_show_cell_nums
		for i=start_index,end_index do
			m_cell_list[i]:runAction(tolua.cast(first_move_by:copy():autorelease(), "CCActionInterval"))
		end
	else
		if m_last_selected_index < m_current_select_index then
			local second_move_by = CCMoveBy:create(m_way_action_time_1, ccp(-1 * m_called_spacing, 0))
			second_move_by = CCEaseSineInOut:create(second_move_by)

			start_index = m_last_selected_index + 1
			end_index = m_current_select_index
			for i=start_index,end_index do
				m_cell_list[i]:runAction(tolua.cast(second_move_by:copy():autorelease(), "CCActionInterval"))
			end
		else
			start_index = m_current_select_index + 1
			end_index = m_last_selected_index
			for i=start_index,end_index do
				m_cell_list[i]:runAction(tolua.cast(first_move_by:copy():autorelease(), "CCActionInterval"))
			end
		end
	end
end

local function play_list_offset_anim(temp_sv)
	local temp_container = temp_sv:getInnerContainer()
	local current_show_x = temp_container:getPositionX() + (m_current_select_index-1) * (m_cell_width + m_cell_spacing)
	if current_show_x < 0 then
		local first_move_by = CCMoveBy:create(m_way_action_time_1, ccp(-1 * current_show_x, 0))
		first_move_by = CCEaseSineInOut:create(first_move_by)
		temp_container:runAction(first_move_by)
	else
		 local right_interval = current_show_x + m_cell_width + m_called_spacing - m_sv_width
		 if right_interval > 0 then
		 	local second_move_by = CCMoveBy:create(m_way_action_time_1, ccp(-1 * right_interval, 0))
		 	second_move_by = CCEaseSineInOut:create(second_move_by)
			temp_container:runAction(second_move_by)
		 end
	end
end

local function play_extrace_way_anim(temp_sv, select_index)
	if m_current_select_index == select_index then
		return
	end

	m_is_playing_anim = true
	m_last_selected_index = m_current_select_index
	m_current_select_index = select_index

	set_sv_inner_info(temp_sv)

	play_list_change_anim()
	play_list_offset_anim(temp_sv)
	play_last_disappear_anim()
	play_current_appear_anim()
end

local function clear_selected_state(temp_sv)
	if m_current_select_index == 0 then
		return
	end

	m_is_playing_anim = true

	local move_by = CCMoveBy:create(m_way_action_time_2, ccp(-1 * m_called_spacing, 0))
	local start_index = m_current_select_index + 1
	local end_index = m_show_cell_nums
	for i=start_index,end_index do
		m_cell_list[i]:runAction(tolua.cast(move_by:copy():autorelease(), "CCActionInterval"))
	end

	local last_selected_widght = m_cell_list[m_current_select_index]
	local last_content_img = tolua.cast(last_selected_widght:getChildByName("content_img"), "ImageView")
	local last_selected_sign_img = tolua.cast(last_content_img:getChildByName("select_img"), "ImageView")
	last_selected_sign_img:setVisible(false)

	local last_call_img = tolua.cast(last_selected_widght:getChildByName("call_img"), "ImageView")
	local btn_1 = tolua.cast(last_call_img:getChildByName("btn_1"), "Button")
	local btn_2 = tolua.cast(last_call_img:getChildByName("btn_2"), "Button")
	local ex_btn = tolua.cast(last_call_img:getChildByName("ex_btn"), "Button")
	btn_1:setTouchEnabled(false)
	btn_2:setTouchEnabled(false)
	ex_btn:setTouchEnabled(false)

	local fade_out = CCFadeOut:create(m_way_action_time_2)
	local fade_out_spawn = CCSpawn:createWithTwoActions(fade_out, move_by)
	local fun_call = cc.CallFunc:create(deal_with_list_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_out_spawn, fun_call)
	last_call_img:runAction(temp_seq)

	m_last_selected_index = m_current_select_index
	m_current_select_index = 0
	set_sv_inner_info(temp_sv)
end

---------------------------------
--获取新招募方式动画
---------------------------------
local function set_new_anim_state(new_state)
	m_is_new_get_anim = new_state
end

local function get_anim_state()
	return m_is_playing_anim or m_is_new_get_anim
end

local function init_param_info()
	m_cell_list = {}

	m_cell_width = 196
	m_cell_height = 456
	m_cell_spacing = 8
	m_called_spacing = 190
	m_sv_width = 1016
	m_sv_height = 470

	m_current_select_index = 0
	m_last_selected_index = 0

	m_way_action_time_1 = 0.3
	m_way_action_time_2 = 0.1
	m_is_playing_anim = false

	m_is_new_get_anim = false
end

cardCallAnimManager = {
						init_param_info = init_param_info,
						remove = remove,
						set_cell_list_related_info = set_cell_list_related_info,
						reset_list_layout_info = reset_list_layout_info,
						get_cell_by_index = get_cell_by_index,
						play_extrace_way_anim = play_extrace_way_anim,
						clear_selected_state = clear_selected_state,
						set_new_anim_state = set_new_anim_state,
						get_anim_state = get_anim_state
}