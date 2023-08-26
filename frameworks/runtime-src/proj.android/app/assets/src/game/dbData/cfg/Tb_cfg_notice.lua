_Tb_cfg_notice = {
[14] = { 1,1,'开服活动公告','        欢迎各位主公来到《率土之滨》。游戏新服会有各种活动伴主公：\n@活动1  首充送豪礼@\n@活动2  连续登录领名将@\n@活动3  势力基金返利300%@\n@活动4  同盟招募送玉符@\n@活动5  演武送女名将@\n@活动6  冲榜赢玉符@\n@活动7  同盟攻城赢玉符@\n（详情请在活动界面查看）',0,1382400,0,1,0, },
[24] = { 2,1,'','#欢迎来到#@《率土之滨》@#，您将在真实的三国世界里发展势力，请努力成为一方之主，成就自己的基业！#',0,1382400,0,1,1, },
}
local function convertFunc( key, arr )
	return {notice_id=key,notice_type=arr[1],notice_subtype=arr[2],notice_title=arr[3],notice_text=arr[4],begin_time=arr[5],end_time=arr[6],time_type=arr[7],priority=arr[8],interval=arr[9],}
end
Tb_cfg_notice = {_src_tb_=_Tb_cfg_notice,_tb_convert_func_=convertFunc}
setmetatable(Tb_cfg_notice,_tb_cfg_mt_)
