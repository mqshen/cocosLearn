_Tb_cfg_repay_advice = {
[1] = { 'aebfljnzrebxpdak@ad.netease.win.163.com',300, },
[2] = { '80936468@ad.xiaomi_app.win.163.com',300, },
[3] = { 'aebfkurciabogko7@ad.netease.win.163.com',300, },
[4] = { '110782912311@ad.dangle.win.163.com',300, },
[5] = { 'b2b72e53bb551a61c56b3b975b1281e7@ad.uc_platform.win.163.com',300, },
[6] = { '32952898@ad.xiaomi_app.win.163.com',300, },
[7] = { '41277277@ad.360_assistant.win.163.com',300, },
[8] = { 'aebfid7kgiaqt2dh@ad.netease.win.163.com',300, },
[9] = { '1735322115204@ad.dangle.win.163.com',300, },
[10] = { '2476434815622@ad.dangle.win.163.com',300, },
[11] = { 'aebfjtsioma6kgdp@ad.netease.win.163.com',300, },
[12] = { '3536010408350@ad.dangle.win.163.com',300, },
[13] = { '80979481@ad.xiaomi_app.win.163.com',300, },
[14] = { '260086000076092490@ad.huawei.win.163.com',300, },
}
local function convertFunc( key, arr )
	return {id=key,passport=arr[1],count=arr[2],}
end
Tb_cfg_repay_advice = {_src_tb_=_Tb_cfg_repay_advice,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_repay_advice,_tb_cfg_mt_)
