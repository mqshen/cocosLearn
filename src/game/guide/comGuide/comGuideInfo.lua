local m_share_guide_obj = nil

local m_touch_group = nil
local m_bg_layer = nil
local m_guide_id = nil
local m_is_loading_ui = nil

local function remove()
	if m_touch_group then
		m_share_guide_obj:remove()
		m_share_guide_obj = nil

		m_guide_id = nil
		m_is_loading_ui = nil
		m_bg_layer = nil
		m_touch_group = nil
	end
end

local function create()
	if m_touch_group then
		return
	end

	m_guide_id = 0
	m_is_loading_ui = false

	local win_size = config.getWinSize()
	m_bg_layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 128), win_size.width, win_size.height)
	comGuideManager.add_content_panel(m_bg_layer)
	
	m_share_guide_obj = guideShowShare.new()
	local temp_widget = m_share_guide_obj:create(2)

    m_touch_group = TouchGroup:create()
    m_touch_group:addWidget(temp_widget)
	comGuideManager.add_content_panel(m_touch_group)

	m_share_guide_obj:reset_componment()
end

local function load_guide_info()
	m_share_guide_obj:reset_componment()
	m_share_guide_obj:reset_param()
	local temp_guide_info = com_guide_cfg_info[m_guide_id]

	if temp_guide_info.bg_state == 0 then
		m_bg_layer:setVisible(false)
	else
		m_bg_layer:setVisible(true)
	end

	if temp_guide_info.dialog_id ~= 0 then
		m_share_guide_obj:set_dialog_info(temp_guide_info.dialog_id, true)
	end

	m_share_guide_obj:set_guide_id(m_guide_id)

	comGuideManager.set_stencil(m_share_guide_obj:get_stencil())
	comGuideManager.set_visible(true)

	m_is_loading_ui = false
end

local function set_guide_id(temp_id)
	print("=====================" .. temp_id)
	local temp_guide_info = com_guide_cfg_info[temp_id]
	if not temp_guide_info then
		print(">>>>>>>" .. debug.traceback())
		return
	end

	m_guide_id = temp_id
	m_is_loading_ui = true

	if temp_guide_info.wait_ui_load == 0 then
		load_guide_info()
	end
end

local function get_guide_id()
	if m_guide_id then
		return m_guide_id
	else
		return 0
	end
end

local function deal_with_ui_loaded(ui_index)
	if not m_guide_id then
		return
	end

	if m_guide_id == 0 then
		return
	end

	local temp_guide_info = com_guide_cfg_info[m_guide_id]
	if temp_guide_info.wait_ui_load == 1 and uiIndexDefine[temp_guide_info.ui_id_name] == ui_index then
		load_guide_info()
	end
end

local function deal_with_touch_began(x, y)
	if not m_guide_id then
		return false
	end
	
	if m_guide_id == 0 then
		return false
	end

	if m_share_guide_obj:is_playing_anim() then
		return false
	end
	
	if m_is_loading_ui then
		return false
	end

	return true
end

local function deal_with_guide_stop()
	if not m_guide_id then
		return
	end

	if m_guide_id == 0 then
		return
	end

	m_share_guide_obj:stop_alpha_anim()
	m_share_guide_obj:stop_finger_anim()
	m_share_guide_obj:reset_componment()
	m_share_guide_obj:reset_param()

	local temp_guide_info = com_guide_cfg_info[m_guide_id]
	if temp_guide_info.next_guide_id == 0 then
		m_guide_id = 0
	else
		m_guide_id = 0
		set_guide_id(temp_guide_info.next_guide_id)
	end
end

local function deal_with_touch_ended(x, y)
	if m_guide_id == 0 then
		return
	end

	if m_share_guide_obj:is_playing_anim() then
		return
	end

	if m_is_loading_ui then
		return
	end

	local temp_guide_info = com_guide_cfg_info[m_guide_id]
	if temp_guide_info.hit_state == 1 then
		deal_with_guide_stop()
	end
end

comGuideInfo = {
					create = create,
					remove = remove,
					set_guide_id = set_guide_id,
					get_guide_id = get_guide_id,
					deal_with_touch_began = deal_with_touch_began,
					deal_with_touch_ended = deal_with_touch_ended,
					deal_with_guide_stop = deal_with_guide_stop,
					deal_with_ui_loaded = deal_with_ui_loaded
}