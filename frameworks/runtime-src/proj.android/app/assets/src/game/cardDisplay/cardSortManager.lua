local m_is_army_first = nil 	--针对实际生成的卡牌排序时判断是否在部队中的需要在最前面
local m_sort_type_uid = nil 	--针对实际生成的卡牌排序时的排序方式

local m_sort_type_cid = nil 		--针对卡牌包（配置ID）的排序方式

local function star_fun_uid(a_card, b_card, a_base_card, b_base_card)
	local a_quality = a_base_card.quality
	local b_quality = b_base_card.quality

	if a_quality == b_quality then
		return 0
	else
		if a_quality > b_quality then
			return -1
		else
			return 1
		end
	end
end

local function level_fun_uid(a_card, b_card, a_base_card, b_base_card)
	local a_level = a_card.level
	local b_level = b_card.level

	if a_level == b_level then
		return 0
	else
		if a_level > b_level then
			return -1
		else
			return 1
		end
	end
end

local function cost_fun_uid(a_card, b_card, a_base_card, b_base_card)
	local a_cost = a_base_card.cost
	local b_cost = b_base_card.cost

	if a_cost == b_cost then
		return 0
	else
		if a_cost > b_cost then
			return -1
		else
			return 1
		end
	end
end

local function get_country_sort_index(country_type)
	if country_type == countryType.qun then
		return 1
	elseif country_type == countryType.wei then
		return 2
	elseif country_type == countryType.shu then
		return 3
	elseif country_type == countryType.wu then
		return 4
	elseif country_type == countryType.han then
		return 5
	end

	return 0
end

local function country_fun_uid(a_card, b_card, a_base_card, b_base_card)
	local a_country_index = get_country_sort_index(a_base_card.country)
	local b_country_index = get_country_sort_index(b_base_card.country)

	if a_country_index == b_country_index then
		return 0
	else
		if a_country_index < b_country_index then
			return -1
		else
			return 1
		end
	end
end

local function bingzhong_fun_uid(a_card, b_card, a_base_card, b_base_card)
	local a_type = a_base_card.hero_type
	local b_type = b_base_card.hero_type

	if a_type == b_type then
		return 0
	else
		if a_type < b_type then
			return -1
		else
			return 1
		end
	end
end

local function sort_ruler_for_uid(a_uid, b_uid)
	local a_card = heroData.getHeroInfo(a_uid)
	local b_card = heroData.getHeroInfo(b_uid)

	if m_is_army_first then
		local a_army_id = a_card.armyid
		local b_army_id = b_card.armyid

		if a_army_id ~= 0 and b_army_id == 0 then
			return true
		end

		if a_army_id == 0 and b_army_id ~= 0 then
			return false
		end
	end

	local a_base_card = Tb_cfg_hero[a_card.heroid]
	local b_base_card = Tb_cfg_hero[b_card.heroid]

	local temp_order_fun_list = nil
	if m_sort_type_uid == 1 then
		temp_order_fun_list = {star_fun_uid, level_fun_uid, cost_fun_uid, country_fun_uid, bingzhong_fun_uid}
	elseif m_sort_type_uid == 2 then
		temp_order_fun_list = {country_fun_uid, star_fun_uid, level_fun_uid, cost_fun_uid, bingzhong_fun_uid}
	elseif m_sort_type_uid == 3 then
		temp_order_fun_list = {bingzhong_fun_uid, star_fun_uid, level_fun_uid, cost_fun_uid, country_fun_uid}
	elseif m_sort_type_uid == 4 then
		temp_order_fun_list = {level_fun_uid, star_fun_uid, cost_fun_uid, country_fun_uid, bingzhong_fun_uid}
	elseif m_sort_type_uid == 5 then
		temp_order_fun_list = {cost_fun_uid, star_fun_uid, level_fun_uid, country_fun_uid, bingzhong_fun_uid}
	end

	if temp_order_fun_list then
		for i,v in ipairs(temp_order_fun_list) do
			local temp_result = v(a_card, b_card, a_base_card, b_base_card)
			if temp_result == -1 then
				return true
			elseif temp_result == 1 then
				return false
			end
		end
	end

	return a_uid > b_uid
end

local function sort_fun_for_uid(temp_card_list, temp_sort_type, is_army_first)
	m_is_army_first = is_army_first
	m_sort_type_uid = temp_sort_type

	table.sort(temp_card_list, sort_ruler_for_uid)
	m_is_army_first = nil
	m_sort_type_uid = nil
end

------------------------配置ID排序--------------------------
local function star_fun_cid(a_base_card, b_base_card)
	local a_quality = a_base_card.quality
	local b_quality = b_base_card.quality

	if a_quality == b_quality then
		return 0
	else
		if a_quality > b_quality then
			return -1
		else
			return 1
		end
	end
end

local function level_fun_cid(a_base_card, b_base_card)
	return 0
end

local function cost_fun_cid(a_base_card, b_base_card)
	local a_cost = a_base_card.cost
	local b_cost = b_base_card.cost

	if a_cost == b_cost then
		return 0
	else
		if a_cost > b_cost then
			return -1
		else
			return 1
		end
	end
end

local function country_fun_cid(a_base_card, b_base_card)
	local a_country_index = get_country_sort_index(a_base_card.country)
	local b_country_index = get_country_sort_index(b_base_card.country)

	if a_country_index == b_country_index then
		return 0
	else
		if a_country_index < b_country_index then
			return -1
		else
			return 1
		end
	end
end

local function bingzhong_fun_cid(a_base_card, b_base_card)
	local a_type = a_base_card.hero_type
	local b_type = b_base_card.hero_type

	if a_type == b_type then
		return 0
	else
		if a_type < b_type then
			return -1
		else
			return 1
		end
	end
end

local function sort_rule_for_cid(a_id, b_id)
	local a_base_card = Tb_cfg_hero[a_id]
	local b_base_card = Tb_cfg_hero[b_id]

	local temp_order_fun_list = nil
	if m_sort_type_cid == 1 then
		temp_order_fun_list = {star_fun_cid, level_fun_cid, cost_fun_cid, country_fun_cid, bingzhong_fun_cid}
	elseif m_sort_type_cid == 2 then
		temp_order_fun_list = {country_fun_cid, star_fun_cid, level_fun_cid, cost_fun_cid, bingzhong_fun_cid}
	elseif m_sort_type_cid == 3 then
		temp_order_fun_list = {bingzhong_fun_cid, star_fun_cid, level_fun_cid, cost_fun_cid, country_fun_cid}
	elseif m_sort_type_cid == 4 then
		temp_order_fun_list = {level_fun_cid, star_fun_cid, cost_fun_cid, country_fun_cid, bingzhong_fun_cid}
	elseif m_sort_type_cid == 5 then
		temp_order_fun_list = {cost_fun_cid, star_fun_cid, level_fun_cid, country_fun_cid, bingzhong_fun_cid}
	end

	if temp_order_fun_list then
		for i,v in ipairs(temp_order_fun_list) do
			local temp_result = v(a_base_card, b_base_card)
			if temp_result == -1 then
				return true
			elseif temp_result == 1 then
				return false
			end
		end
	end

	return a_id > b_id
end

local function sort_fun_for_cid(temp_card_list, temp_sort_type)
	m_sort_type_cid = temp_sort_type
	table.sort(temp_card_list, sort_rule_for_cid)
	m_sort_type_cid = nil
end

cardSortManager = {
					sort_fun_for_uid = sort_fun_for_uid,
					sort_fun_for_cid = sort_fun_for_cid
}