_Tb_cfg_city_renown = {
[1] = { 600000, },
[2] = { 750000, },
[3] = { 900000, },
[4] = { 1050000, },
[5] = { 1200000, },
[6] = { 1350000, },
[7] = { 1500000, },
[8] = { 1650000, },
[9] = { 1800000, },
}
local function convertFunc( key, arr )
	return {city_count=key,renown=arr[1],}
end
Tb_cfg_city_renown = {_src_tb_=_Tb_cfg_city_renown,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_city_renown,_tb_cfg_mt_)
