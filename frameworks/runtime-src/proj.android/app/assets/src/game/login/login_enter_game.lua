local loginEnterGame = {}

local main_layer = nil
-- local uiUtil = require("game/utils/ui_util")
local loginBulletinList = require("game/login/login_bulletin_list")

local target_ip = nil
local target_port = nil
local target_server_id = nil
local target_name = nil
local target_running_server_id = nil
local handler = nil

local function removeHandler( )
	if handler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handler)
	end
	handler = nil
end

local function sendLogin( )
	-- loginEnterGame.changeAbleBtnEnterGame(false)
	-- 开始连接服务器
	if configBeforeLoad.getIsNeedInfoFromService() then
		if not target_server_id or not target_ip or not target_port then
			return
		end
		loginData.setLastCacheServer(target_server_id)
		Connect.connect_service()
		loginData.sendCacheServerId2Server()
		-- local serverList = loginData.getServerList()
		-- local isSave = true
		-- if serverList then
		-- 	for i, v in pairs(serverList) do
		-- 		if v.server_id == tonumber(target_server_id) and v.flag_test == 1 then
		-- 			isSave = false
		-- 			break
		-- 		end
		-- 	end
		-- end
		-- if isSave then
			loginData.setCacheUserInfo({name= target_name, id =target_server_id, host = target_ip, port = target_port, run_server_id = target_running_server_id})
		-- end
		Connect.connect_game(target_ip,target_port)
	else
		Connect.connect_game_t()
	end
	-- local userName,userCode = Login.getAccountInfo()
	Login.requestLogin()

	-- main_layer:runAction(animation.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function ( )
	-- 	loginEnterGame.changeAbleBtnEnterGame(true)
	-- end)}))
end

function loginEnterGame.sendLoginWithoutGui( )
	local name , serverid,serverHost, serverPort, run_server_id= loginData.getCacheUserInfo()
	Connect.connect_service()
	if serverHost ~= "" and serverPort ~= "" then
		netObserver.addObserver(ON_LOGIN,loginData.onLogin)
		Connect.connect_game(serverHost,tonumber(serverPort))
		Login.requestLogin()
		local waitHandler = nil
		waitHandler = scheduler.create(function ( )
			scheduler.remove(waitHandler)
			if loginData.hasLogin() then
				return
			else
				netObserver.removeObserver(ON_LOGIN)
				scene.remove()
			end
		end,3)
	else
		scene.remove()
	end
end

local function changeAbleBtnEnterGame(isAble)
	if not main_layer then return end
	local temp_widget = main_layer:getWidgetByTag(999)
	if not temp_widget then return end
	local btn_enter_game = tolua.cast(temp_widget:getChildByName("btn_enter_game"),"Button")--uiUtil.getConvertChildByName(temp_widget,"btn_enter_game")
	local btn_server = tolua.cast(temp_widget:getChildByName("btn_server"),"Button")--uiUtil.getConvertChildByName(temp_widget,"btn_server")
	btn_enter_game:setTouchEnabled(isAble)
	btn_server:setTouchEnabled(isAble)
end

local function dealWithClickChangeServer(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED and UpdateUI.playCGEnd() then
		-- Connect.connect_service()
		loginGUI.createServerList()
	end
end

local function dealWithClickEnterGame(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED and UpdateUI.playCGEnd() then
		loginEnterGame.changeAbleBtnEnterGame(false)
		main_layer:runAction(animation.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function ( )
			loginEnterGame.changeAbleBtnEnterGame(true)
		end)}))
		if configBeforeLoad.getIfSdkLogin() and ( SDKLogin.getSdkLoginFail() or not sdkMgr:sharedSkdMgr():hasLogin() or not sdkMgr:sharedSkdMgr():isLogin()) then
			-- if configBeforeLoad.getIfSdkLogin() then
				SDKLogin.create()
			
			return
		elseif not configBeforeLoad.getIfSdkLogin() then
			local userName, userCode=Login.getAccountInfo()
			if userName == "" then
				tipsLayer.create(languageBeforeLogin["zhanghao"])
				return
			end
		end
		loginType = nil

		-- local mabi = require("game/login/userAgreement")
		-- mabi.create()
		if not loginGUI.createMaintenanceLayer() then
			sendLogin()
		end
	end
end

local function createBtnEnterGame()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_enter_game.json")
	temp_widget:setTag(999)
	temp_widget:setScale(configBeforeLoad.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))

	temp_widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
 	main_layer:addWidget(temp_widget)
 	temp_widget:setVisible(false)
 	local action1 = CCFadeIn:create(0.3)
	local action2 = cc.CallFunc:create(function ( )
			temp_widget:setVisible(true)
		end)
	local spawn = animation.spawn({action1, action2})
 	local action = animation.sequence({spawn, cc.CallFunc:create(function ( )
 		-- loginGUI.setLoginLayer()
 	end)})
 	temp_widget:runAction(action)

 	local btn_enter_game = tolua.cast(temp_widget:getChildByName("btn_enter_game"),"Button")--uiUtil.getConvertChildByName(temp_widget,"btn_enter_game")
 	btn_enter_game:addTouchEventListener(dealWithClickEnterGame)

 	local btn_server = tolua.cast(temp_widget:getChildByName("btn_server"),"Button")--uiUtil.getConvertChildByName(temp_widget,"btn_server")
 	btn_server:addTouchEventListener(dealWithClickChangeServer)

 	local image_server_maintenance = tolua.cast(btn_server:getChildByName("image_server_maintenance"),"ImageView")
	image_server_maintenance:setVisible(false)
 	--sdk测试
 	-- sdkMgr:sharedSkdMgr():registerScriptHandler(loginEnterGame.registerHandler)
	----------------------------------------------------------end-----------------------


 	if not configBeforeLoad.getIsNeedInfoFromService() then
        --外网服务还没搭好
        btn_server:setVisible(false)
        btn_server:setTouchEnabled(false)
    end

 	changeAbleBtnEnterGame(true)
end

local function createBulletinList()
	
	-- loginBulletinList.show()
end

local function connect_server()

end

function loginEnterGame.setServerInfo(serverid)
    if not configBeforeLoad.getIsNeedInfoFromService()then 
    	return 
    end

	local temp_widget = main_layer:getWidgetByTag(999)
	if not temp_widget then
		return
	end
	local btn_server = tolua.cast(temp_widget:getChildByName("btn_server"),"Button")--uiUtil.getConvertChildByName(temp_widget,"btn_server")
	local label_server_num = tolua.cast(btn_server:getChildByName("label_server_num"),"Label")--uiUtil.getConvertChildByName(btn_server,"label_server_num")
	local label_server_name = tolua.cast(btn_server:getChildByName("label_server_name"),"Label")--uiUtil.getConvertChildByName(btn_server,"label_server_name")
	local image_server_maintenance = tolua.cast(btn_server:getChildByName("image_server_maintenance"),"ImageView")
	image_server_maintenance:setVisible(false)
	local server_info = nil
	if serverid then 
		server_info = loginData.getServerInfoById(serverid)
		loginData.setLastCacheServer(serverid)
	else
		server_info = loginData.getLastCacheServer()
	end

	if not server_info then
		return
		-- server_info = {}
		-- server_info.name, server_info.server_id, server_info.host, server_info.port, server_info.run_server_id = loginData.getCacheUserInfo()
		-- if server_info.name == "" or server_info.server_id == "" or server_info.host == "" or server_info.port == "" 
		-- 	or server_info.run_server_id == "" then
		-- end
	end
	
	local server_name = server_info.name
	local server_id = server_info.server_id
	label_server_num:setText(server_id%1000 .. languageBeforeLogin["server_title"])
	label_server_name:setText(server_name)
	label_server_name:setColor(ccc3(214,208,141))
	label_server_num:setColor(ccc3(214,208,141))
	if server_info.flag_maintain and server_info.flag_maintain == 1 then
		label_server_num:setColor(ccc3(110,110,110))
		label_server_name:setColor(ccc3(110,110,110))
		image_server_maintenance:setPositionX(label_server_name:getPositionX()+label_server_name:getSize().width +22)
		image_server_maintenance:setVisible(true)
	end

	target_ip = server_info.host
	target_port = server_info.port
	target_server_id = server_id
	target_name = server_name
	target_running_server_id = server_info.run_server_id
end

function loginEnterGame.changeAbleBtnEnterGame(isAble)
	if not main_layer then return end
	changeAbleBtnEnterGame(isAble)
end

function loginEnterGame.remove()
	if main_layer then 
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		target_port = nil
		target_ip = nil
		target_server_id = nil
		target_name = nil
		target_running_server_id = nil
	end
	-- loginBulletinList.remove()
	removeHandler()
	sdkData = nil
	loginType = nil
end

function loginEnterGame.create(serverid)
	if main_layer then
		if UpdateUI.getBeginCg() then
			changeAbleBtnEnterGame(true)
		else
			changeAbleBtnEnterGame(false)
		end

		if serverid then 
			loginEnterGame.setServerInfo(serverid)
		else
			loginEnterGame.setServerInfo()
		end

		-- loginGUI.createMaintenanceLayer()
		return 
	end
	main_layer = TouchGroup:create()


 	createBulletinList()
 	-- createBtn2UserCenter()
 	createBtnEnterGame()
 	loginGUI.add_login_content(main_layer)

 	loginData.getLastCacheServer()
 	loginEnterGame.setServerInfo()

 	-- loginGUI.createMaintenanceLayer()
end

return loginEnterGame