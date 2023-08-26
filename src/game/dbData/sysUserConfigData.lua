module("sysUserConfigData", package.seeall)
sysUserConfigType = {user_card_max = 1}

--获取卡牌背包的上限
function get_card_bag_nums()
	for k,v in pairs(allTableData[dbTableDesList.sys_user_config.name]) do
		if k == sysUserConfigType.user_card_max then
			return v.num_val
		end
	end

	return CARD_STORAGE_CAPACITY
end