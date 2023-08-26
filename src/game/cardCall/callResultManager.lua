local m_result_panel = nil
local m_is_in_result_page = nil

local m_call_uid = nil 		--当前显示招募方式的ID
local m_card_list = nil 	--招募出来的卡牌列表
local m_clear_anim_type = nil 	--关闭结果面板的类型  1 点击右上角关闭；2 点击招募按钮
local m_call_index = nil 	--点击招募的索引

local function remove()
	callResultAnimManager.remove()
	m_call_uid = nil
	m_card_list = nil

	m_clear_anim_type = nil
	m_call_index = nil
	m_is_in_result_page = nil

	m_result_panel = nil
end

local function is_in_result_page()
	return m_is_in_result_page
end

local function deal_with_hide_state()
	m_call_uid = nil
	m_card_list = nil

	callResultAnimManager.reset_star_anim()
	callResultAnimManager.reset_widget_show()

	local btn_1 = tolua.cast(m_result_panel:getChildByName("btn_1"), "Button")
	local btn_2 = tolua.cast(m_result_panel:getChildByName("btn_2"), "Button")
	btn_1:setTouchEnabled(false)
	btn_2:setTouchEnabled(false)

	m_result_panel:setTouchEnabled(false)
	m_result_panel:setVisible(false)

	m_is_in_result_page = false
end

local function close_result_page()
	m_clear_anim_type = 1

	callResultAnimManager.play_enter_bag_anim()
end

local function clear_anim_callback()
	if m_clear_anim_type == 1 then
		deal_with_hide_state()
		cardCallListManager.return_to_call_state()
	elseif m_clear_anim_type == 2 then
		local temp_extract_data = cardCallData.get_extract_card_info(m_call_uid)
		cardOpRequest.request_call_card(temp_extract_data.refresh_way_id, m_call_uid, m_call_index-1)
	end
end

local function get_card_cfg_id_by_idx(idx)
	return m_card_list[idx][2]
end

local function is_good_card_by_index(idx)
	local hero_cfg_id = get_card_cfg_id_by_idx(idx)
	if Tb_cfg_hero[hero_cfg_id].quality >= cardQuality.four_star then
		return true
	else
		return false
	end
end

local function get_good_card_list()
	local temp_result_list = {}
	for k,v in pairs(m_card_list) do
		local hero_cfg_id = v[2]
		if Tb_cfg_hero[hero_cfg_id].quality >= cardQuality.four_star then			
			table.insert(temp_result_list, {hero_cfg_id, Tb_cfg_hero[hero_cfg_id].quality})
		end
	end

	return temp_result_list
end

local function own_good_card_state()
	local is_have_good_card = false
	for k,v in pairs(m_card_list) do
		if is_good_card_by_index(k) then
			is_have_good_card = true
			break
		end
	end

	return is_have_good_card
end

local function get_package_level()
	if m_call_uid == 0 then
		return 1
	else
		local temp_extract_data = cardCallData.get_extract_card_info(m_call_uid)
		return cardCallData.get_extract_card_level(temp_extract_data.refresh_way_id)
	end
end

local function deal_with_call_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED and callResultAnimManager.is_can_call_click() then
		--callResultAnimManager.reset_anim_after_call_click()
		m_clear_anim_type = 2
		m_call_index = tonumber(string.sub(sender:getName(), 5))

		local temp_extract_data = cardCallData.get_extract_card_info(m_call_uid)
		if cardOpRequest.judge_call_card_condition(temp_extract_data.refresh_way_id, m_call_uid, m_call_index-1) then
			callResultAnimManager.play_enter_bag_anim()
		end
	end
end

local function deal_with_card_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED and callResultAnimManager.is_touch_enabled() then
		local select_index = tonumber(string.sub(sender:getParent():getName(), 6))
		if m_card_list[select_index][1] == 0 then
			require("game/cardDisplay/basicCardViewer")
			local temp_hero_level = get_package_level()
			if temp_hero_level == 1 then
				basicCardViewer.create(nil,get_card_cfg_id_by_idx(select_index))
			else
				basicCardViewer.create(nil, get_card_cfg_id_by_idx(select_index), nil, temp_hero_level)
			end
		else
			require("game/cardDisplay/userCardViewer")
			userCardViewer.create(nil,m_card_list[select_index][1])
		end
	end
end

local function change_technic_response()
	local add_value = 0
	local change_index_list = {}
	for k,v in pairs(m_card_list) do
		if v[1] == 0 then
			table.insert(change_index_list, k)
			add_value = add_value + v[3]
		end
	end

	if add_value == 0 then
		return
	end

	callResultAnimManager.start_technic_anim(change_index_list, add_value)
end

local function order_rule(a_table, b_table)
	return Tb_cfg_hero[a_table[2]].quality > Tb_cfg_hero[b_table[2]].quality
end

local function refresh_card_content(temp_call_uid, temp_card_list)
	callResultAnimManager.reset_anim_after_call_click()

	m_call_uid = temp_call_uid
	m_card_list = temp_card_list
	for k,v in pairs(m_card_list) do
		if v[2] == 0 then
			m_card_list[k][2] = heroData.getHeroOriginalId(v[1])
		end
	end

	table.sort(m_card_list, order_rule)

	callResultAnimManager.set_show_card_nums(#m_card_list, deal_with_card_click)
	
	local icon_con, hero_widget = nil, nil
	local temp_hero_level = get_package_level()
	for k,v in pairs(m_card_list) do
		icon_con = callResultAnimManager.get_widget_by_index(k)
		hero_widget = tolua.cast(icon_con:getChildByName("hero_icon"), "Layout")
		cardFrameInterface.set_middle_card_info(hero_widget, v[1], v[2])
		if v[1] == 0 then
			if temp_hero_level ~= 1 then
				cardFrameInterface.set_lv_images(temp_hero_level, hero_widget)
			end
		end

		hero_widget:setTouchEnabled(true)
	end

	local btn_1 = tolua.cast(m_result_panel:getChildByName("btn_1"), "Button")
	local btn_2 = tolua.cast(m_result_panel:getChildByName("btn_2"), "Button")
	btn_1:setTouchEnabled(false)
	btn_2:setTouchEnabled(false)

	local baodi_panel = tolua.cast(m_result_panel:getChildByName("baodi_panel"), "Layout")
	if m_call_uid == 0 then
		callResultAnimManager.set_btn_show_state(false, false, false)
		baodi_panel:setVisible(false)
	else
		local temp_extract_data = cardCallData.get_extract_card_info(m_call_uid)
		local temp_refresh_info = Tb_cfg_card_extract[temp_extract_data.refresh_way_id]
		if temp_refresh_info.daily_count ~= 0 and temp_extract_data.used_count_daily >= temp_refresh_info.daily_count then
			callResultAnimManager.set_btn_show_state(false, false, false)
			baodi_panel:setVisible(false)
		else
			callWayManager.set_way_show_content(m_call_uid, cardCallType.actived, btn_1, btn_2, 2)
			callWayManager.set_baodi_show_content(m_call_uid, cardCallType.actived, baodi_panel)
			callResultAnimManager.set_btn_show_state(true, btn_2:isVisible(), baodi_panel:isVisible())
		end
	end

	btn_1:setVisible(false)
	btn_2:setVisible(false)

	m_result_panel:setTouchEnabled(true)
	m_result_panel:setVisible(true)

	callResultAnimManager.play_refresh_card_anim()

	m_is_in_result_page = true
end

local function create(temp_panel)
	require("game/cardCall/callResultAnimManager")

	m_result_panel = temp_panel
	callResultAnimManager.create(m_result_panel)

	local icon_base = tolua.cast(m_result_panel:getChildByName("icon_base"), "Layout")
	icon_base:setVisible(false)

	local btn_1 = tolua.cast(m_result_panel:getChildByName("btn_1"), "Button")
	local btn_2 = tolua.cast(m_result_panel:getChildByName("btn_2"), "Button")
	btn_1:addTouchEventListener(deal_with_call_click)
	btn_2:addTouchEventListener(deal_with_call_click)

	deal_with_hide_state()
end

callResultManager = {
						create = create,
						remove = remove,
						is_in_result_page = is_in_result_page,
						close_result_page = close_result_page,
						clear_anim_callback = clear_anim_callback,
						refresh_card_content = refresh_card_content,
						change_technic_response = change_technic_response,
						own_good_card_state = own_good_card_state,
						get_good_card_list = get_good_card_list,
						get_package_level = get_package_level,
						get_card_cfg_id_by_idx = get_card_cfg_id_by_idx,
						is_good_card_by_index = is_good_card_by_index
}