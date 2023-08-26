local function get_skill_detail_info(skill_detail_id, skill_level, hero_intel_num, base_num, need_value)
	local detail_info = Tb_cfg_skill_detail[skill_detail_id]
	local skill_effect_info = Tb_cfg_skill_effect[detail_info.effect_id]
	if not need_value then
		return skill_effect_info.tips
	end

	local current_effect_ration = detail_info.init_effect_ratio + (skill_level - 1) * (100 - detail_info.init_effect_ratio) / 9

	local param_nums = detail_info.constant_param + detail_info.intel_param / 200 * hero_intel_num / 100
	local result_num = base_num + math.floor(current_effect_ration * param_nums / 100) --current_effect_ration 要转换成百分比的
	
	local result_des = skill_effect_info.name
	--[[
		0 直接使用计算后的数值
		1 直接使用计算后的数值 后面要加百   分号显示
		2 计算后的数值要特殊处理（50W以上的要百分比显示，一下的除以100然后保留小数点后一位四舍五入）
	--]]
	local temp_value_type = skill_effect_info.value_type
	if temp_value_type == 0 then
		result_des = result_des .. result_num
	elseif temp_value_type == 1 then
		result_des = result_des .. result_num .. "%"
	elseif temp_value_type == 2 then
		if result_num >= 500000 then
			result_des = result_des .. (result_num/1000000) .. "%" --因为是百分比 所以除以100W，还要在乘以100，所以最后只除以10000即可
		else
			result_des = result_des .. math.ceil(result_num/10)/10			--策划要保留小数点后一位
		end
	end 
	
	return result_des
end

--因为服务器的计算时跟卡牌的智力挂钩的，为了统一所以加入智力数值，不存在则填写0； 在某些情况下有个基础值，计算出来的要加上他
local function get_skill_effect(skill_id, skill_level, hero_intel_num, base_num)
	local result = {}
	if not skillDetailList[skill_id] then
		return result
	end

	for i,v in ipairs(skillDetailList[skill_id]) do
		table.insert(result, get_skill_detail_info(v, skill_level, hero_intel_num, base_num, true))
	end

	return result
end

local function get_skill_effect_simple_des(skill_id, skill_level, hero_intel_num, base_num)
	local retStr = ""
	local result = {}
	if not skillDetailList[skill_id] then
		return retStr
	end

	for i,v in ipairs(skillDetailList[skill_id]) do
		table.insert(result, get_skill_detail_info(v, skill_level, hero_intel_num, base_num, false))
	end
	for k,v in ipairs(result) do 
		retStr = retStr .. v .. "  "
	end
	if retStr == ""  then retStr = " " end
	return retStr
end

skillData = {
				get_skill_effect = get_skill_effect,
				get_skill_effect_simple_des = get_skill_effect_simple_des,
}