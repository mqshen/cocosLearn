local cfgFuncIntro = {}
--[[
cfg_func_intro["test"] = {
	-- 标题
	title = "test",	
	-- 功能正文介绍
	intro = "#function#@ intro @#test#", 
	-- 功能提示 一个一行
	tips = {
			"#tips111111111111111#",
			"#tips222222222222222#"
		}, 
	-- 是否有确认按钮  1 是有  0 是没有
	state_btn_ok = 0,
}
]]

cfgFuncIntro["test"] = {
	title = "test",
	intro = "#function#@ intro @@&@#test#",
	tips = {
			"#tips111111111111111#@&@#222222222222222222222222222222222222222222222222222222222222#",
			"#tips222222222222222#@&@#33333333333333333333333333333333333333333333333333333333333333333333333#"
		},
	state_btn_ok = 1,
}

cfgFuncIntro["test1"] = {
	title = "test1",
	intro = "#function#@ intro @#test#",
	tips = {
			"#tips111111111111111#@&@",
			"#tips222222222222222#@&@"
		},
	state_btn_ok = 0,
}




return cfgFuncIntro