_Tb_cfg_field_event_exp = {
[1] = { 1000, },
[2] = { 3000, },
[3] = { 10000, },
[4] = { 30000, },
[5] = { 60000, },
[100] = { 100, },
}
local function convertFunc( key, arr )
	return {id=key,exp=arr[1],}
end
Tb_cfg_field_event_exp = {_src_tb_=_Tb_cfg_field_event_exp,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_field_event_exp,_tb_cfg_mt_)
