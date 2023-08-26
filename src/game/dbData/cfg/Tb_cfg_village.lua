_Tb_cfg_village = {
[1] = { 3,86399, },
[2] = { 3,86399, },
[3] = { 3,86399, },
[4] = { 3,86399, },
[5] = { 3,86399, },
}
local function convertFunc( key, arr )
	return {level_id=key,count=arr[1],valid_time=arr[2],}
end
Tb_cfg_village = {_src_tb_=_Tb_cfg_village,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_village,_tb_cfg_mt_)
