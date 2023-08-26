--该函数用来获取城市（主城，分城）中开放的部队数量以及前锋开放的数量
local function get_army_param_info(city_id)
	local city_build_effect_info = userCityData.getCityBuildEffectData(city_id)
	return city_build_effect_info.army_max, city_build_effect_info.army_pos_front

	--[[
	-- 40 校场 配置部队数量 41 兵法阁 配置部队军师；42 点将台 配置部队中军；44 封禅台 城市部队COST值上限
	local jc_level = politics.getBuildLevel(city_id, cityBuildDefine.jiaochang)
	local army_nums = 0
	if jc_level ~= 0 then
		army_nums = Tb_cfg_build_cost[cityBuildDefine.jiaochang*100 + jc_level].effect[1][2]
	end

	local djt_level = politics.getBuildLevel(city_id, cityBuildDefine.dianjiangtai)
	local qianfeng_nums = 0
	if djt_level ~= 0 then
		qianfeng_nums = Tb_cfg_build_cost[cityBuildDefine.dianjiangtai*100 + djt_level].effect[1][2]
	end

	return army_nums, qianfeng_nums
	--]]
end

buildData = {
				get_army_param_info = get_army_param_info
}