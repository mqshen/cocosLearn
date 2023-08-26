_Tb_cfg_goods = {
[1] = { '60玉符',600,60,60,'','img_yufu_one.png', },
[2] = { '300玉符',3000,315,285,'','img_yufu_two.png', },
[3] = { '980玉符',9800,1060,0,'','img_yufu_two.png', },
[4] = { '1980玉符',19800,2220,1740,'','img_yufu_two.png', },
[5] = { '3280玉符',32800,3680,2880,'','img_yufu_three.png', },
[6] = { '6480玉符',64800,8100,4860,'','img_yufu_three.png', },
[101] = { '300玉符贡品礼包',3000,0,0,'每天赠送150玉符，有效期30天','img_gongpin.png', },
}
local function convertFunc( key, arr )
	return {good_id=key,name=arr[1],rmb=arr[2],yuan_bao_count=arr[3],first_bonus=arr[4],description=arr[5],img=arr[6],}
end
Tb_cfg_goods = {_src_tb_=_Tb_cfg_goods,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_goods,_tb_cfg_mt_)
