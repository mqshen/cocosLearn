local lastHeroAddPointUid = nil

local function request_add_point(card_id, add_point_1, add_point_2, add_point_3, add_point_4)
	Net.send(HERO_CONFIG_POINTS, {card_id, add_point_1, add_point_2, add_point_3, add_point_4})
	lastHeroAddPointUid = card_id
end

local function request_wash_point(card_id, wash_type)
	-- Net.send(HERO_CLEAN_POINTS, {card_id, wash_type})
	Net.send(HERO_CLEAN_POINTS, {card_id})
end

local function enter_skill_change()
	cardCallManager.remove_self(true)

	require("game/skill/skill_operate")
	SkillOperate.create(SkillOperate.OP_TYPE_TRANSFER)
end

local function judge_call_card_condition(call_cfg_id, call_uid, call_type)
	local temp_refresh_info = Tb_cfg_card_extract[call_cfg_id]

	local need_space_nums = 0
	if call_type == 0 then
		need_space_nums = 1
	else
		need_space_nums = temp_refresh_info.refresh_n
	end

	if heroData.getHeroNums() + need_space_nums > sysUserConfigData.get_card_bag_nums() then
		alertLayer.create(errorTable[221], nil, enter_skill_change)
		comAlertConfirm.setBtnTitleText(languagePack['goto_transferSkillValue'],languagePack['cancel'])
		return false
	end

	local is_res_enough = true
	local cost_type, need_num, own_num = nil, nil, nil
	if call_type == 0 then
		local leave_num = nil
		local half_state = false
		if call_uid == 0 then
			leave_num = cardCallData.get_free_nums_for_cfg_id(call_cfg_id)
		else
			leave_num = cardCallData.get_free_nums_for_uid(call_uid, userData.getServerTime())
			half_state = cardCallData.get_half_state(call_uid)
		end

		if leave_num == 0 then
			cost_type = temp_refresh_info.refresh_cost[1][1]
			need_num = temp_refresh_info.refresh_cost[1][2]
			own_num = cardCallData.get_call_res_nums(cost_type)
			if half_state then
				need_num = need_num/2
			end
			if need_num > own_num then
				is_res_enough = false
			end
		end
	else
		cost_type = temp_refresh_info.refresh_cost_n[1][1]
		need_num = temp_refresh_info.refresh_cost_n[1][2]
		own_num = cardCallData.get_call_res_nums(cost_type)
		if need_num > own_num then
			is_res_enough = false
		end
	end

	if not is_res_enough then
		if cost_type == consumeType.common_money then
			tipsLayer.create(errorTable[212])
		else
			tipsLayer.create(errorTable[220])
		end
		return false
	end

	return true
end

local function request_call_card(call_cfg_id, call_uid, call_type)
	local change_quality, change_consume = callTechnicChangeManager.get_change_param()
	Net.send(CARD_RECRUIT, {call_cfg_id, call_uid, call_type, change_quality, change_consume})
end

local function receive_call_card(packet)
	callResultManager.refresh_card_content(packet[1], packet[2])
	if callResultManager.own_good_card_state() then
		LSound.playSound(musicSound["card_getbetter"])
	else
		LSound.playSound(musicSound["card_getnormal"])
	end
end

local function request_clear_new_sign()
	Net.send(CARD_SET_ALL_NOT_NEW, {})
end

local function receive_add_point( packet )
	--print("收到加点回复")
end

-- 检查是否需要播放加点成功特效
local function checkHeroAddPointSucceedEffect(hero_uid)
	if lastHeroAddPointUid and lastHeroAddPointUid == hero_uid then 
		lastHeroAddPointUid = nil
		return true
	end

	return false
end

-- 武将卡保护状态切换
local function request_switch_card_protected_state(hero_uid,state)
	Net.send(HERO_SWITCH_LOCK_STATE,{hero_uid,state})
	if skillShowManager then 
		skillShowManager.deal_switch_card_protected_state(hero_uid,state)
	end
end



-- 清理一些 标志操作是否需要特效的 缓存数据
local function clearOperateEffectCheckData()
	lastHeroAddPointUid = nil
end

local function remove()
	clearOperateEffectCheckData()

	netObserver.removeObserver(HERO_CONFIG_POINTS)

	netObserver.removeObserver(CARD_RECRUIT)
end

local function create()
	netObserver.addObserver(HERO_CONFIG_POINTS,receive_add_point)

	netObserver.addObserver(CARD_RECRUIT, receive_call_card)
end

cardOpRequest = {
	create = create,
	remove = remove,
	request_add_point = request_add_point,
	request_wash_point = request_wash_point,
	request_call_card = request_call_card,
	judge_call_card_condition = judge_call_card_condition,
	request_clear_new_sign = request_clear_new_sign,
	request_switch_card_protected_state = request_switch_card_protected_state,
	checkHeroAddPointSucceedEffect = checkHeroAddPointSucceedEffect,
	clearOperateEffectCheckData = clearOperateEffectCheckData,
}