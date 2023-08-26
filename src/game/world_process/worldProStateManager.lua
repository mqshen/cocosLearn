module("worldProStateManager", package.seeall)

local m_up_img = nil
local m_down_img = nil
local m_scroll_view = nil

local m_selected_cell_index = nil

function remove_self()
	m_up_img = nil
	m_down_img = nil
	m_scroll_view = nil

	m_selected_cell_index = nil
end

function get_selected_cell_idx()
	return m_selected_cell_index
end

local function set_state_select_state(index, new_state)
	local state_img = tolua.cast(m_scroll_view:getChildByName("state_" .. index), "ImageView")
	local select_img = tolua.cast(state_img:getChildByName("select_img"), "ImageView")
	select_img:setVisible(new_state)
end

local function set_select_index(new_index)
	if new_index == m_selected_cell_index then
		return
	end

	if m_selected_cell_index then
		set_state_select_state(m_selected_cell_index, false)
	end
		
	m_selected_cell_index = new_index
	set_state_select_state(m_selected_cell_index, true)

	worldProContentManager.set_process_content(m_selected_cell_index)
end

local function deal_with_state_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getName(),7))

		set_select_index(select_index)
	end
end

local function organize_state_list(state_base_img)
	local state_img, name_txt = nil, nil
	local state_nums = 13
	local state_width = m_scroll_view:getSize().width
	local state_height = state_base_img:getSize().height + 4
	for i=state_nums,1,-1 do
		state_img = state_base_img:clone()
		state_img:setName("state_" .. i)
		state_img:setPosition(cc.p(state_width/2, state_height/2 + (state_nums-i)*state_height))
		name_txt = tolua.cast(state_img:getChildByName("name_label"), "Label")
		name_txt:setText(Tb_cfg_region[i].name)
		state_img:setVisible(true)
		state_img:setTouchEnabled(true)
		state_img:addTouchEventListener(deal_with_state_click)
		m_scroll_view:addChild(state_img)
	end

	state_img = tolua.cast(m_scroll_view:getChildByName("state_0"), "ImageView")
	state_img:setTouchEnabled(true)
	state_img:addTouchEventListener(deal_with_state_click)
	local ds_pos_y = state_nums*state_height + state_img:getSize().height/2
	state_img:setPositionY(ds_pos_y)
	m_scroll_view:setInnerContainerSize(CCSizeMake(m_scroll_view:getContentSize().width, ds_pos_y + state_img:getSize().height/2))
	m_scroll_view:jumpToTop()
	m_up_img:setVisible(false)
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

function update_scroll_state(scroll_or_not)
	if m_scroll_view then
		m_scroll_view:setTouchEnabled(scroll_or_not)
	end
end

function set_tianxia_new_sign_state()
	local state_img = tolua.cast(m_scroll_view:getChildByName("state_0"), "ImageView")
	local sign_img = tolua.cast(state_img:getChildByName("sign_img"), "ImageView")
	if worldProData.get_new_sign_state_for_tianxia() == 0 then
		sign_img:setVisible(false)
	else
		sign_img:setVisible(true)
	end

	local temp_running_id = worldProData.get_running_id_for_tianxia()
	if temp_running_id ~= 0 then
		local des_txt = tolua.cast(state_img:getChildByName("label_2"), "Label")
		des_txt:setText("-" .. Tb_cfg_progress[temp_running_id].name .. "-")
		des_txt:setVisible(true)
	end
end

function revert_last_close_state()
	set_select_index(0)
end

function create(left_img)
	m_up_img = tolua.cast(left_img:getChildByName("up_img"), "ImageView")
	m_down_img = tolua.cast(left_img:getChildByName("down_img"), "ImageView")

	local new_height = left_img:getSize().height

	m_up_img:setPositionY(new_height/2 - m_up_img:getSize().height/2)
	m_down_img:setPositionY(-1 * new_height/2 + m_down_img:getSize().height/2)
    breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)

    m_scroll_view = tolua.cast(left_img:getChildByName("state_sv"), "ScrollView")
	m_scroll_view:addEventListenerScrollView(deal_with_scroll_event)
	m_scroll_view:setSize(CCSize(m_scroll_view:getContentSize().width, new_height - 6))
	m_scroll_view:setPositionY(-1 * new_height/2 + 3)

	local state_base_img = tolua.cast(left_img:getChildByName("con_img"), "ImageView")
	organize_state_list(state_base_img)
end