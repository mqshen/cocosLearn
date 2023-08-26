--登陆返回信息
local lastLoginServerId = nil
local loginPacket = nil
local hasRequestServerId = nil
local function setHasRequestServerid( flag )
	hasRequestServerId = flag
end
local isLogin = nil

local function getHasRequestServerid(  )
	return hasRequestServerId
end

local function upLoadUserInfo(  )
	if SdkStuff then
		SdkStuff.upLoadUserInfo()
	end
	-- local serverdata = nil
	-- if lastLoginServerId then
	-- 	serverdata = loginData.getServerInfoById(lastLoginServerId)
	-- end

	-- if userData.getUserId() then
	-- 	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_UID",userData.getUserHelpId())
	-- 	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_NAME",userData.getUserName())
	-- 	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_GRADE","")
	-- 	local sdkName =sdkMgr:sharedSkdMgr():getChannel()
	-- 	if sdkName == "pps" then
	-- 		local id = lastLoginServerId or ""
	-- 		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTID","ppsmobile_s"..id)
	-- 	else
	-- 		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTID",lastLoginServerId or "")
	-- 	end
	-- 	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_BALANCE", userData.getYuanbao())
	-- 	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_ORG", userData.getUnion_name())
	-- 	sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_VIP", "")
	-- 	sdkMgr:sharedSkdMgr():setPropStr("GAME_NAME","率土之滨")
	-- 	sdkMgr:sharedSkdMgr():setPropStr("USERINFO_NAME",userData.getUserName())
	-- 	sdkMgr:sharedSkdMgr():setPropStr("USERINFO_UID",userData.getUserHelpId())

	-- 	if serverdata then
	-- 		sdkMgr:sharedSkdMgr():setPropStr("USERINFO_HOSTNAME",serverdata.name or "")
	-- 		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTNAME",serverdata.name or "")
	-- 	end

	-- 	if sdkMgr:sharedSkdMgr():getPlatform() ~= "ios" then
	-- 		sdkMgr:sharedSkdMgr():ntGameLoginSuccess()
	-- 	end
	-- 	sdkMgr:sharedSkdMgr():ntUpLoadUserInfo()
	-- end
end

local function onLogin(packet)
	netObserver.removeObserver(ON_LOGIN)
	if packet == cjson.null then
		return
	end
	
	
	local check_result = packet[1]
	if check_result == 0 then
		-- token过期。重新登录
		-- tipsLayer.create(languageBeforeLogin["chongxindenglu"])
		print(">>>>>>>>>>>>>>>>> token out of date")
		-- scene.remove()
		if map then
			if map.getisLockMapCoord() then
				-- scene.remove()
				return
			end
		end

		SDKLogin.create()
		return
	elseif check_result == 2 then
		-- Net.reStartGameListener(packet[2])
		Net.setRestartFlag(true)
		--StartAnimation.reStartGame()
	else
		local rolling_notice_manager = function ( )
			require("game/option/rolling_notice_manager")
			require("game/userData/user")
		end
		
		rolling_notice_manager()
		--dbDataChange.init_table_data()		--必须优先初始化，不然数据刷新时会出问题
		local user_base_info = packet[2]
		--cmdIndex, sid, userId
		Net.setPlayerMsg(user_base_info[3], user_base_info[2], user_base_info[1])

		
		userData.setServerTime(user_base_info[4])
		
		-- scene.onLogin(packet,packet[3] ~= 0)
		-- loginPacket = packet

		

		if packet[3] == 0 then 
			loginGUI.showCreateRole(packet)
		else
			isLogin = true
			local user_game_info = packet[4]
			userData.setUserData(user_game_info[1])
			if map then
				scene.beforeEnterGame(map.getisLockMapCoord())
			else
				scene.beforeEnterGame()
			end
			-- config.setClientFuncOpen(user_game_info[4])
			RollingNoticeManager.receiveRollingNoitceFromServer(user_game_info[2])
			userData.setIsDialyFirstLogin(user_game_info[3])
			upLoadUserInfo()
			if configBeforeLoad.getUpdateTime() and configBeforeLoad.getUpdateUseTime() then
				Net.send(CLIENT_UPDATE_INFO, {configBeforeLoad.getUpdateTime(), configBeforeLoad.getUpdateUseTime()})
			end
		end
	end
end

local function onCreateRole(packet)
	local create_result = packet[1]
	if create_result == 0 then
		tipsLayer.create(languageBeforeLogin["chuangjianshibai"])
	else
		local rolling_notice_manager = function ( )
			require("game/option/rolling_notice_manager")
			require("game/userData/user")
		end
		
		rolling_notice_manager()
		local user_game_info = packet[2]
		if user_game_info then
			userData.setUserData(user_game_info[1])
			RollingNoticeManager.receiveRollingNoitceFromServer(user_game_info[2])
			-- config.setClientFuncOpen(user_game_info[4])
			userData.setIsDialyFirstLogin(user_game_info[3])
			
			-- scene.onLogin(loginPacket,true)
			scene.beforeEnterGame()
			upLoadUserInfo()
		end
	end
end

local function onNameCheck(packet)
	if packet == 0 then
		tipsLayer.create(errorTable[102])
	else
		local inputNameLoginInfo = require("game/login/inputNameLoginInfo")
		inputNameLoginInfo.name_check_finish()
	end
end




--登录公告列表相关
-- id
-- title
-- content
-- time
-- announce_type  0:普通,1：特殊
-- popup
--1：自动弹出 只能存在一个 
local bulletin_list = {}

local function saveBulletinList(packet)
	bulletin_list = packet
end

local function getBulletinList()
	return bulletin_list
end


-- 普通类型的 只取一个最新的
-- 特殊类型1的 都加入滚动列表
local function getBulletinRollingList()
	if not bulletin_list then return {} end
	local ret = {}
	
	for i = 1,#bulletin_list do 
		if bulletin_list[i].announce_type == 1 then
		 	table.insert(ret,#ret + 1,bulletin_list[i])
		end
	end

	if #ret >0 then return ret end
	for i = 1 ,#bulletin_list do
		if bulletin_list[i].announce_type == 0 then 
			if not ret[1] then 
				ret[1] = bulletin_list[i]
			else
				if ret[1].time < bulletin_list[i].time then 
					ret[1] = bulletin_list[i]
				end
			end
		end
	end
	return ret
end


-------------服务器列表相关
--[[
public Integer server_id;
public String name;
public String host;
public Integer port;
public Byte flag_new;
public Byte flag_recommand;
public Byte flag_maintain;
public Integer server_port;
public Integer open_time;
run_server_id;

]]

local server_list = {}
local login_server_list = {}
local login_server_time = nil
local login_time_diff = nil

local function setLogin_server_time(serverTime )
	login_server_time = serverTime
	login_time_diff = login_server_time - os.time()
end

local function getLogin_server_time(  )
	return login_server_time
end

local function saveServerList(packet)
	server_list = packet
end

local function getServerList()
	return server_list
end

-- 设置玩家登陆过的服务器
local function setLoginServerList(data )
	login_server_list = data
end

local function getLoginServerList(  )
	return login_server_list
end

-- 获取最新的服务器信息
local function getLastedServer()
	local temp_login_time_diff = login_time_diff or 0
	for k,v in pairs(server_list) do 
		if v.open_time < temp_login_time_diff+os.time() then
			if tonumber(v.flag_new) == 1 and tonumber(v.flag_recommand) == 1 then 
				return v
			end
		end
	end

	for k,v in pairs(server_list) do 
		if v.open_time < temp_login_time_diff+os.time() then
			if tonumber(v.flag_new) == 1 then 
				return v
			end
		end
	end

	for k,v in pairs(server_list) do 
		if tonumber(v.flag_new) == 1 and tonumber(v.flag_recommand) == 1 then 
			return v
		end
	end
	
	for k,v in pairs(server_list) do 
		if tonumber(v.flag_new) == 1 then 
			return v
		end
	end

	local serverid_info = nil
	for k,v in pairs(server_list) do 
		if not serverid or serverid_info.server_id < v.server_id then
			serverid_info = v
		end
	end
	return serverid_info
end
local function getServerInfoById(serverid)
	for k,v in pairs(server_list) do 
		if tostring(v.server_id) == tostring(serverid) then 
			return v
		end
	end

	return getLastedServer()
end

local function setLastLoginServerId(idStr)
	lastLoginServerId = tonumber(idStr)
end

local function getLastLoginServerId( )
	return lastLoginServerId
end

local lastCacheServerId = nil

-- 获取玩家上一次登录的服务器信息
-- 如果没有则返回最新的服务器信息
local function getLastCacheServer()
	if lastLoginServerId then
		return getServerInfoById(lastLoginServerId)
	else
		return getLastedServer()
	end
end

-- 最近登录的服务器相关
local function setLastCacheServer(id)
	lastCacheServerId = tonumber(id)
end

local function getLastCacheServerId()
	return lastCacheServerId
end

local function sendCacheServerId2Server()
	-- if lastCacheServerId ~= lastLoginServerId then
		-- local name,code = Login.getAccountInfo()
		local server_session = ""
		-- print(">>>>>>>>>>>>>>>>>token ="..configBeforeLoad.getSdkData().server_session)
		local userid = configBeforeLoad.getLoginServerUserid()
		if configBeforeLoad.getSdkData() and configBeforeLoad.getSdkData().server_session then
			server_session = configBeforeLoad.getSdkData().server_session
		end
		local temp_serverid = lastCacheServerId
		if not lastCacheServerId then
			temp_serverid = 0
		end
		Net.send(SET_LOGINED_SERVER, {userid,temp_serverid, server_session})
	-- end
	lastLoginServerId = lastCacheServerId
end

--获取州信息
local function requestStateInfo( )
	Net.send(GET_REGION_STATE,{})
end

local function receiveStateInfo(packet )
	loginGUI.set_state_info(packet)
	local selectBornInfo = require("game/login/selectBornInfo")
	selectBornInfo.create(false)
end

local cacheUserInfo = { serverName = "", serverId = "", serverHost = "", serverPort = "", run_server_id = ""}
local function setCacheUserInfo(data )
	-- CCUserDefault:sharedUserDefault():setStringForKey("serverName", data.name)
	-- CCUserDefault:sharedUserDefault():setStringForKey("serverId", data.id)
	-- CCUserDefault:sharedUserDefault():setStringForKey("serverHost", data.host)
	-- CCUserDefault:sharedUserDefault():setStringForKey("serverPort", data.port)
	-- CCUserDefault:sharedUserDefault():setStringForKey("run_server_id", data.run_server_id)
	cacheUserInfo.serverName = data.name
	cacheUserInfo.serverId = data.id
	cacheUserInfo.serverHost = data.host
	cacheUserInfo.serverPort = data.port
	cacheUserInfo.run_server_id = data.run_server_id
end

--获取缓存的用户信息
local function getCacheUserInfo( )
	-- return CCUserDefault:sharedUserDefault():getStringForKey("serverName"),
	-- CCUserDefault:sharedUserDefault():getStringForKey("serverId"),
	-- CCUserDefault:sharedUserDefault():getStringForKey("serverHost"),
	-- CCUserDefault:sharedUserDefault():getStringForKey("serverPort"),
	-- CCUserDefault:sharedUserDefault():getStringForKey("run_server_id")
	return cacheUserInfo.serverName or "", 
	cacheUserInfo.serverId or "", 
	cacheUserInfo.serverHost or "", 
	cacheUserInfo.serverPort or "", 
	cacheUserInfo.run_server_id or ""
end

local function hasLogin(  )
	return isLogin
end

local function setIsLogin(flag )
	isLogin = flag
end

loginData = {
	onLogin = onLogin,
	onNameCheck = onNameCheck,
	onCreateRole = onCreateRole,
	requestStateInfo = requestStateInfo,
	receiveStateInfo = receiveStateInfo,
	-- 服务器列表相关
	saveServerList = saveServerList,
	getServerList = getServerList,
	getLastedServer = getLastedServer,
	getLastCacheServer = getLastCacheServer,
	getServerInfoById = getServerInfoById,
	
	-- 公告列表相关
	saveBulletinList = saveBulletinList,
	getBulletinList = getBulletinList,
	getBulletinRollingList = getBulletinRollingList,
	-- 最新登录的服务器相关
	setLastCacheServer = setLastCacheServer,
	setLastLoginServerId = setLastLoginServerId,
	getLastCacheServerId = getLastCacheServerId,
	sendCacheServerId2Server = sendCacheServerId2Server,
	setCacheUserInfo = setCacheUserInfo,
	getCacheUserInfo = getCacheUserInfo,
	setHasRequestServerid = setHasRequestServerid,
	getHasRequestServerid = getHasRequestServerid,
	getLastLoginServerId = getLastLoginServerId,
	setLoginServerList = setLoginServerList,
	getLoginServerList = getLoginServerList,
	hasLogin = hasLogin,
	setIsLogin = setIsLogin,
	setLogin_server_time = setLogin_server_time,
	getLogin_server_time = getLogin_server_time,
}