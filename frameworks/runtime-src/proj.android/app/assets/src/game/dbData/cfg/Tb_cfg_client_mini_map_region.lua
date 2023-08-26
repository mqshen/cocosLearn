_Tb_cfg_client_mini_map_region = {
[1] = { '193,91','27,-181',129,126, },
[2] = { '180,83','26,-175',125,125, },
[3] = { '195,43','22,-283',135,142, },
[4] = { '159,78','18,-199',138,141, },
[5] = { '256,32','24,-310',70,73, },
[6] = { '225,37','17,-254',79,78, },
[7] = { '215,53','25,-204',59,65, },
[8] = { '196,-3','36,-343',60,66, },
[9] = { '203,6','76,-233',66,69, },
[10] = { '14,-144','229,-268',68,66, },
[11] = { '192,33','79,-305',58,59, },
[12] = { '153,78','65,-232',66,66, },
[13] = { '282,12','20,-338',58,63, },
}
local function convertFunc( key, arr )
	return {region_id=key,pos=arr[1],left_up_pos=arr[2],scale_x=arr[3],scale_y=arr[4],}
end
Tb_cfg_client_mini_map_region = {_src_tb_=_Tb_cfg_client_mini_map_region,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_client_mini_map_region,_tb_cfg_mt_)
