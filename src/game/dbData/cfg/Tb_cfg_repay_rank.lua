_Tb_cfg_repay_rank = {
[1] = { '80959060@ad.xiaomi_app.win.163.com',5000,1, },
[2] = { 'aebfjtsioma6kgdp@ad.netease.win.163.com',3000,2, },
[3] = { 'aebfljogdebxplbl@ad.netease.win.163.com',3000,3, },
[4] = { '260086000076092490@ad.huawei.win.163.com',3000,4, },
[5] = { '1735322115204@ad.dangle.win.163.com',1000,5, },
[6] = { '80979481@ad.xiaomi_app.win.163.com',1000,6, },
[7] = { '9496147@ad.xiaomi_app.win.163.com',1000,7, },
[8] = { '2476434815622@ad.dangle.win.163.com',1000,8, },
[9] = { '3536010408350@ad.dangle.win.163.com',1000,9, },
[10] = { 'aebfljjnrybxoebb@ad.netease.win.163.com',1000,10, },
[11] = { 'aebfidziziaqtrti@ad.netease.win.163.com',500,11, },
[12] = { '53665188@ad.xiaomi_app.win.163.com',500,12, },
[13] = { 'aebflji3hybxny36@ad.netease.win.163.com',500,13, },
[14] = { '5ab7116660fc0ecb4dc2573b69a5c946@ad.uc_platform.win.163.com',500,14, },
[15] = { 'e3dc1902871cc2b4b98ffe1dc0dba023@ad.uc_platform.win.163.com',500,15, },
[16] = { 'aebflkifzybx7hlx@ad.netease.win.163.com',500,16, },
[17] = { 'aebflifv3abwuwtd@ad.netease.win.163.com',500,17, },
[18] = { 'aebfgdokmiaaayg5@ad.netease.win.163.com',500,18, },
[19] = { 'aebfgcx7yqaaaqie@ad.netease.win.163.com',500,19, },
[20] = { '260086000076516503@ad.huawei.win.163.com',500,20, },
}
local function convertFunc( key, arr )
	return {id=key,passport=arr[1],count=arr[2],rank=arr[3],}
end
Tb_cfg_repay_rank = {_src_tb_=_Tb_cfg_repay_rank,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_repay_rank,_tb_cfg_mt_)
