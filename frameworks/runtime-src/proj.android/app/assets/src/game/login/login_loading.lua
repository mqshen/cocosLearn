local loginLoading = {}


local main_layer = nil
local preload_lua_file = nil
local preload_pic_file = nil
local m_total_file = nil
local m_loaded_file = nil
-- local uiutil = require("game/utils/ui_util")
local loginEnterGame = require("game/login/login_enter_game")
local loginLoadingBar = require("game/login/login_loading_bar")

function loginLoading.remove()
	
	loginLoadingBar.remove()
	m_total_file = nil
	m_loaded_file = nil
	if main_layer then 
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
	end

end

local function createLoadingBar()
	if not main_layer then return end
	local instance = loginLoadingBar.create()
	instance:setScale(config.getgScale())
	instance:ignoreAnchorPointForPosition(false)
	instance:setAnchorPoint(cc.p(0.5,0))
	instance:setPosition(cc.p(config.getWinSize().width/2, 0))
	main_layer:addChild(instance)
end

function loginLoading.create()
	if main_layer then return end
	main_layer = TouchGroup:create()
 	loginGUI.add_login_content(main_layer)
 	login_packet = login_packet_t
 	createLoadingBar()
 	loginLoadingBar.setPatchName(languageBeforeLogin["loading_res_tips"])
end

function loginLoading.on_pre_load_finish(num_finished)
	if not main_layer then return end
	
	if type(num_finished) ~= "number" then--or type(num_need) ~= "number" then 
		return 
	end
	m_loaded_file = m_loaded_file + 1
	loginLoadingBar.setPercent(100 * m_loaded_file/m_total_file)
	loginLoadingBar.setPatchName(nil,100 * m_loaded_file/m_total_file)
	if m_loaded_file == m_total_file then
		preload_pic_file = true
		loginLoading.enter_scene()
	end
end

function loginLoading.on_pre_load_lua_finish(flag )
	preload_lua_file = flag
	loginLoading.enter_scene()
end

function loginLoading.enter_scene( )
	if preload_pic_file and preload_lua_file then
		local callback = function()
			scene.create()
			loginGUI.remove()
		end
		local actions = CCArray:create()  
    	actions:addObject(cc.DelayTime:create(0.1))
    	actions:addObject(cc.CallFunc:create(callback))
    	local action = cc.Sequence:create(actions)
		main_layer:runAction(action)
	end
end

function loginLoading.setTotalFile( file )
	m_total_file = file
	m_loaded_file = 0
end

return loginLoading