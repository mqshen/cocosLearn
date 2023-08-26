module("worldProContentManager", package.seeall)

local m_state_type = nil 		--州编号
local m_update_timer = nil

function remove_self()
	if m_update_timer then
		scheduler.remove(m_update_timer)
		m_update_timer = nil
	end

	tianxiaContentManager.remove_self()
	zhouContentManager.remove_self()

	m_state_type = nil
end

local function update_time_content()
	if m_state_type == 0 then
		tianxiaContentManager.update_time_content()
	else
		zhouContentManager.update_time_content()
	end
end

function reload_data(is_locate_new_pos)
	if m_state_type == 0 then
		tianxiaContentManager.reload_data(is_locate_new_pos)
	else
		zhouContentManager.reload_data()
	end

	if not m_update_timer then
		m_update_timer = scheduler.create(update_time_content, 1)
	end
end

function update_scroll_state(scroll_or_not)
	if m_state_type == 0 then
		tianxiaContentManager.update_scroll_state(scroll_or_not)
	else
		zhouContentManager.update_scroll_state(scroll_or_not)
	end
end

function set_process_content(state_index)
	if m_state_type == state_index then
		return
	end

	m_state_type = state_index
	if m_state_type == 0 then
		tianxiaContentManager.set_tb_visible(true)
		zhouContentManager.set_tb_visible(false)
	else
		tianxiaContentManager.set_tb_visible(false)
		zhouContentManager.set_tb_visible(true)
		zhouContentManager.set_process_content(m_state_type)
	end

	worldProData.request_process_info(m_state_type)
end

function create(right_img)
	local new_height = right_img:getSize().height

	local temp_up_img = tolua.cast(right_img:getChildByName("up_img"), "ImageView")
	local temp_down_img = tolua.cast(right_img:getChildByName("down_img"), "ImageView")
	temp_up_img:setPositionY(new_height/2 - temp_up_img:getSize().height/2)
	temp_down_img:setPositionY(-1 * new_height/2 + temp_down_img:getSize().height/2)
    breathAnimUtil.start_scroll_dir_anim(temp_up_img, temp_down_img)

    require("game/world_process/tianxiaContentManager")
    tianxiaContentManager.create(right_img)
    require("game/world_process/zhouContentManager")
    zhouContentManager.create(right_img)
end