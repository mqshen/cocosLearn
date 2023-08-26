--招募次数按钮显示内容
local function set_btn_1_content(btn_1, free_count, all_free_num, half_price_state, cost_type, need_num)
	local cost_sign_img = tolua.cast(btn_1:getChildByName("sign_img"), "ImageView")
	local cost_txt = tolua.cast(btn_1:getChildByName("res_label"), "Label")
	local half_img = tolua.cast(btn_1:getChildByName("cheap_img"), "ImageView")

	if free_count == 0 then
		cost_sign_img:loadTexture(cardCallData.get_call_res_icon(cost_type), UI_TEX_TYPE_PLIST)
		cost_sign_img:setVisible(true)

		half_img:setVisible(half_price_state)
		if half_price_state then
			need_num = need_num/2
		end

		local own_num = cardCallData.get_call_res_nums(cost_type)
		if own_num >= need_num then
			cost_txt:setColor(ccc3(105, 58, 40))
		else
			cost_txt:setColor(ccc3(255, 0, 0))
		end
		cost_txt:setPositionX(-23)
		cost_txt:setText(cardCallData.get_call_res_name(cost_type) .. need_num)
	else
		cost_sign_img:setVisible(false)
		cost_txt:setPositionX(-46)
		cost_txt:setColor(ccc3(105, 58, 40))
		cost_txt:setText(languagePack["mianfeicishu"] .. free_count .. "/" .. all_free_num)

		half_img:setVisible(false)
	end

	btn_1:setTouchEnabled(true)
end

local function set_btn_2_content(btn_2, call_nums, cost_type, need_num)
	local num_txt = tolua.cast(btn_2:getChildByName("num_label"), "Label")
	num_txt:setText(call_nums)

	local cost_sign_img = tolua.cast(btn_2:getChildByName("sign_img"), "ImageView")
	cost_sign_img:loadTexture(cardCallData.get_call_res_icon(cost_type), UI_TEX_TYPE_PLIST)

	local cost_txt = tolua.cast(btn_2:getChildByName("res_label"), "Label")
	local own_num = cardCallData.get_call_res_nums(cost_type)
	if own_num >= need_num then
		cost_txt:setColor(ccc3(105, 58, 40))
	else
		cost_txt:setColor(ccc3(255, 0, 0))
	end
	cost_txt:setText(cardCallData.get_call_res_name(cost_type) .. need_num)
end

local function set_way_show_content(call_id, call_type, btn_1, btn_2, page_type)
	local temp_refresh_info = nil
	local leave_free_num, all_free_num = nil, nil
	local temp_half_price = false
	if call_type == cardCallType.share then
		local temp_extract_cfg_id = call_id
		temp_refresh_info = Tb_cfg_card_extract[temp_extract_cfg_id]

		leave_free_num, all_free_num = cardCallData.get_free_nums_for_cfg_id(temp_extract_cfg_id)
	elseif call_type == cardCallType.actived then
		local temp_extract_uid = call_id
		local temp_extract_data = cardCallData.get_extract_card_info(temp_extract_uid)
		temp_refresh_info = Tb_cfg_card_extract[temp_extract_data.refresh_way_id]

		leave_free_num, all_free_num = cardCallData.get_free_nums_for_uid(temp_extract_uid, userData.getServerTime())
		if temp_extract_data.half_price == 1 then
			temp_half_price = true
		end
	end
	set_btn_1_content(btn_1, leave_free_num, all_free_num, temp_half_price, temp_refresh_info.refresh_cost[1][1], temp_refresh_info.refresh_cost[1][2])
	
	if temp_refresh_info.refresh_n == 0 then
		btn_2:setVisible(false)

		if page_type == 1 then
			btn_1:setPositionY(0)
		else
			btn_1:setPositionX(520)
		end
	else
		set_btn_2_content(btn_2, temp_refresh_info.refresh_n, temp_refresh_info.refresh_cost_n[1][1], temp_refresh_info.refresh_cost_n[1][2])
		btn_2:setVisible(true)
		btn_2:setTouchEnabled(true)

		if page_type == 1 then
			btn_1:setPositionY(63)
		else
			btn_1:setPositionX(400)
		end
	end
end

local function set_baodi_show_content(call_id, call_type, baodi_panel)
	local temp_refresh_info = nil
	local called_nums = nil
	if call_type == cardCallType.share then
		local temp_extract_cfg_id = call_id
		temp_refresh_info = Tb_cfg_card_extract[temp_extract_cfg_id]
		called_nums = 0
	elseif call_type == cardCallType.actived then
		local temp_extract_uid = call_id
		local temp_extract_data = cardCallData.get_extract_card_info(temp_extract_uid)
		temp_refresh_info = Tb_cfg_card_extract[temp_extract_data.refresh_way_id]
		called_nums = temp_extract_data.quality_appear_count
	end

	if type(temp_refresh_info.quality_appear) == "table" then
		local num_txt = tolua.cast(baodi_panel:getChildByName("num_label"), "Label")
		num_txt:setText(temp_refresh_info.quality_appear[1][1] - called_nums)

		local content_txt = tolua.cast(baodi_panel:getChildByName("content_label"), "Label")
		local card_lv_limit = math.floor(temp_refresh_info.quality_appear[1][2]/10) + 1
		if card_lv_limit < 5 then
			content_txt:setText(card_lv_limit .. languagePack["heroCardLvName"] .. languagePack["above"] .. languagePack["wujiang"])
		else
			content_txt:setText(card_lv_limit .. languagePack["heroCardLvName"] .. languagePack["wujiang"])
		end

		baodi_panel:setVisible(true)
	else
		baodi_panel:setVisible(false)
	end
end

callWayManager = {
					set_baodi_show_content = set_baodi_show_content,
					set_way_show_content = set_way_show_content
}