--增兵控制和网络逻辑
local function requestAddRecruit( heroid_u, count ,add_type)
	-- add_type 0为普通 1为预备兵
	if not add_type then add_type = 0 end
	Net.send(ARMY_RECRUIT,{heroid_u, count,add_type})
end

local function requestNewAddRecruit(add_type, zb_list)
	Net.send(ARMY_RECRUIT_BATCH, {add_type, zb_list})
end

--取消增兵
local function requestCancelRecruit(hero_uid)
	local function deal_with_cancel_soldier_event()
		Net.send(ARMY_RECRUIT_CANCEL,{hero_uid})
	end

	local hero_info = heroData.getHeroInfo(hero_uid)
	alertLayer.create(errorTable[35], {Tb_cfg_hero[hero_info.heroid].name, hero_info.hp_adding}, deal_with_cancel_soldier_event)
end

local function getRecruitTime(citywid, heroid, count )
	local base_hero_info = Tb_cfg_hero[heroid]
	local all_time = base_hero_info.recruit_time * count

	local city_build_effect_info = allTableData[dbTableDesList.build_effect_city.name][citywid]
	local hero_country = base_hero_info.country
	local country_rate = 0
	if hero_country == countryType.han then
		country_rate = city_build_effect_info.country_recruit_time_han
	elseif hero_country == countryType.wei then
		country_rate = city_build_effect_info.country_recruit_time_wei
	elseif hero_country == countryType.shu then
		country_rate = city_build_effect_info.country_recruit_time_shu
	elseif hero_country == countryType.wu then
		country_rate = city_build_effect_info.country_recruit_time_wu
	elseif hero_country == countryType.qun then
		country_rate = city_build_effect_info.country_recruit_time_qun
	end
	
	all_time = math.floor(all_time * (1 - city_build_effect_info.recruit_time/100) * (1 - country_rate/100))

	return all_time
end

addSoldierRequest = {	
						requestAddRecruit = requestAddRecruit,
						requestNewAddRecruit = requestNewAddRecruit,
						requestCancelRecruit = requestCancelRecruit,
						getRecruitTime = getRecruitTime
					}