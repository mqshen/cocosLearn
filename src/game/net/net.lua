cjson = require "cjson"
local m_connect = nil
local g_pCmdMgr = nil
local m_iIP = nil
local m_iPort = nil
local m_netHandler = nil

local m_bInited = false
local m_iLastCmd = false

local g_restartFlag = false

local m_bNeedReLogin = false
local function onCallback(data, iCmd )
	if not data then
		CCLuaLog(">>>>>>>>>>>error!!!!!!  icmd ="..iCmd)
		return
	end

	if m_iLastCmd and iCmd == m_iLastCmd then
		loadingLayer.remove()
	end
	--local jsonData = NetBuff:readStringRemain()
	-- if --[[iCmd == NOTIFY_WORLD_VIEW_CMD or ]]iCmd ==4 then
	-- 	or iCmd == MAIL_INBOX or iCmd == MAIL_INFO or iCmd == MAIL_OUTBOX or iCmd == UNION_CREATE then
		-- CCLuaLog(">> data="..data)
	-- 
    -- if iCmd == PLATFORM_LOGIN_CHECK then
	 	-- CCLuaLog("\n\n\nonCallback>>>>>>>>>>>>>>=".. iCmd .. "\n" .. data)
	-- end

	if configBeforeLoad.getPlatFormInfo() ~= kTargetWindows and configBeforeLoad.getDebugEnvironment() and dbTableDesList and allTableData then
		local userid = 0
		if dbTableDesList.user and dbTableDesList.user.name and allTableData[dbTableDesList.user.name] then
			for k,v in pairs(allTableData[dbTableDesList.user.name]) do
				userid =  k
				break
			end
		end	

		-- CCLuaLog("icmd=".. iCmd .. " data:" .. data.. "\n")
		local path = CCFileUtils:sharedFileUtils():getWritablePath()
	    local file = assert(io.open(path.."/netlog_"..os.date("%Y-%m-%d", os.time())..".txt","a+"))
	    file:write("---------------"..os.date("%Y-%m-%d %H-%M-%S", os.time()).." ---------------------\n")
	    file:write("userId ="..userid.." icmd ="..iCmd.." data: " .. tostring(data) .. "\n")
	    file:write("------------------------------------\n")
	    file:close()
	end
	netObserver.post(iCmd, cjson.decode(data))
end

local function onNetworkState(iState)
	if iState == 1 then --内网
		loadingLayer.remove()
		CCLuaLog("connect network Success!!!!")
		-- tipsLayer.create("服务器连接成功")
		m_connect = true
		Connect.connected()
		if m_bNeedReLogin then
			SceneBeforeLogin.SID_INVALID_callback()
		end
	else 
		if iState == 2 then
			loadingLayer.remove()
			-- tipsLayer.create("不能连接服务器，请检查网络")
			EndGameUI.create(languageBeforeLogin[3], function ( )
				-- cc.Director:getInstance():endToLua()
				configBeforeLoad.exitGame()
			end, EndGameUI.remove_self)
		else 
		-- tipsLayer.create("正在连接服务器")
			-- loadingLayer.create(999)
		end
		m_connect = false
		Connect.disconnected()
	end
end


local function runEveryFrame( )
	g_pCmdMgr:onFrame()
	if g_restartFlag then
		g_restartFlag = false
		StartAnimation.reStartGame()
	end
end

	-- public static final int ID_SERVER_OPEN_TIME = 1;
	-- public static final int ID_SERVER_ID_ACCEPTABLE = 3;
	-- public static final int ID_CLIENT_FUNC_OPEN = 4;
	-- public static final int ID_CLIENT_VERSION_MIN = 5;
local function reStartGameListener( )
	-- if packet then
		local miniVersion = nil
		for k,v in pairs(allTableData[dbTableDesList.sys_param.name]) do
			if v.param_id == 5 then 
				miniVersion = v.value
			end
		end
		if not miniVersion then
			return
		end

		if string.len(miniVersion) <= 0 then
			return
		end
		
		local versionToNumber = function (vv)
			local a={}
			local i=1
			for d in string.gmatch(vv,"%d+") do
				a[i]=tonumber(d)
				i=i+1
			end
			return a[1]*1000+a[2],a[3]
		end

		local version = CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion",true)
		local serverVersion = miniVersion
		local playerMainVersion, playerVersion = versionToNumber(version)
		local serverMainVersion, serverVersion = versionToNumber(serverVersion)
		if playerMainVersion < serverMainVersion then
			-- StartAnimation.reStartGame()
			g_restartFlag = true
			return
		elseif playerMainVersion > serverMainVersion then
			return
		end

		if playerVersion < serverVersion then
			-- StartAnimation.reStartGame()
			g_restartFlag = true
			return
		end
	-- end
end

local function remove()
	-- ~CmdMgr()
	if m_netHandler then
		scheduler.remove(m_netHandler)
		m_netHandler = nil
	end
	if g_pCmdMgr then
		g_pCmdMgr:deleteCmgMgr()
	end
	m_connect = nil
	g_pCmdMgr = nil
	-- m_iIP = nil
	-- m_iPort = nil
	m_netHandler = nil
	m_bNeedReLogin = false
	m_bInited = false
	m_iLastCmd = false
	-- netObserver.removeObserver(NOTIFY_CLIENT_VERSION)
	
end

local function init( )
	if not m_bInited then
		g_pCmdMgr = CmdMgr()
		g_pCmdMgr:registerScriptHandler(1,onCallback)
		g_pCmdMgr:registerScriptHandler(2,onNetworkState)
		m_netHandler =scheduler.create(runEveryFrame, 0.1)
		m_bInited = true

		-- netObserver.addObserver(NOTIFY_CLIENT_VERSION,reStartGameListener)
	end
end

local function connect(strIp, iPort)
	init()
	m_iIP = strIp
	m_iPort = iPort
	--loadingLayer.create(5)
	-- CCUserDefault:sharedUserDefault():getStringForKey("serverHost"),
	-- "10.250.201.150",
	-- CCUserDefault:sharedUserDefault():getStringForKey("serverPort")
	-- CCUserDefault:sharedUserDefault():setStringForKey("run_server_id")
	local name , serverid,serverHost, serverPort, run_server_id= loginData.getCacheUserInfo()
	local id = 0
	if run_server_id and string.len(run_server_id) > 0 then
		id = tonumber(run_server_id)
	end
	g_pCmdMgr:setServerConfig(m_iIP,iPort,id)
	
	
end

local function send(iCmd,data)
	local strJsonData = cjson.encode(data)
	local pNetBuf = g_pCmdMgr:getNetBuff(iCmd, string.len(strJsonData))
	pNetBuf:writeStringWithoutLen(strJsonData)
	if iCmd ~= PAY_DEAL_AFTER_PAY_DONE then
		print(">>>>>>>>>>>>>>>>>>>>>send iCmd="..iCmd.."      data="..cjson.encode(data))
	end
	g_pCmdMgr:send(pNetBuf)
	m_iLastCmd = iCmd

	loadingLayer.create(nil,nil,nil, GET_WORLD_INFO_CMD == iCmd)

	if configBeforeLoad.getPlatFormInfo() ~= kTargetWindows and configBeforeLoad.getDebugEnvironment() and dbTableDesList and allTableData then
		local userid = 0
		if dbTableDesList.user and dbTableDesList.user.name and allTableData[dbTableDesList.user.name] then
			for k,v in pairs(allTableData[dbTableDesList.user.name]) do
				userid =  k
				break
			end
		end	
		local path = CCFileUtils:sharedFileUtils():getWritablePath()
	    local file = assert(io.open(path.."/sendlog_"..os.date("%Y-%m-%d", os.time())..".txt","a+"))
	    file:write("---------------"..os.date("%Y-%m-%d %H-%M-%S", os.time()).." ---------------------\n")
	    file:write("userId ="..userid.." icmd ="..iCmd.." data: " .. tostring(cjson.encode(data)) .. "\n")
	    file:write("------------------------------------\n")
	    file:close()
	end
end

local function getIP( )
	return m_iIP
end

local function getPort( )
	return m_iPort
end

local function setPlayerMsg( cmdIndex, sid, userId)
	if g_pCmdMgr then
		g_pCmdMgr:setPlayerMsg(cmdIndex, sid, userId)
	end
end

local function getConnect( )
	return m_connect
end

local function setEnable(bEnable)
	if g_pCmdMgr then
	g_pCmdMgr:setSocketEnable(bEnable)
	end
end

local function getLastIcmd( )
	return m_iLastCmd
end

local function setRestartFlag( flag )
	g_restartFlag = flag
end

local function registerVersion( )
	if UIUpdateManager then
		UIUpdateManager.add_prop_update(dbTableDesList.sys_param.name, dataChangeType.add, reStartGameListener)
		UIUpdateManager.add_prop_update(dbTableDesList.sys_param.name, dataChangeType.update, reStartGameListener)
	end
end

local function removeVersionListen(  )
	if UIUpdateManager then
		UIUpdateManager.remove_prop_update(dbTableDesList.sys_param.name, dataChangeType.add, reStartGameListener)
		UIUpdateManager.remove_prop_update(dbTableDesList.sys_param.name, dataChangeType.update, reStartGameListener)
	end
end

local function setReLogin( flag)
	if not flag then
		m_bNeedReLogin = false
		return
	end
	-- m_iIP = strIp
	-- m_iPort = iPort
	local name , serverid,serverHost, serverPort, run_server_id= loginData.getCacheUserInfo()
	local id = 0
	if run_server_id and string.len(run_server_id) > 0 then
		id = tonumber(run_server_id)
	end
	if g_pCmdMgr then
		
		g_pCmdMgr:setServerConfig(m_iIP or "" ,m_iPort or 0, id)
		--必须先set false
		g_pCmdMgr:setSocketEnable(false)
		g_pCmdMgr:setSocketEnable(true)
	end
	m_bNeedReLogin = true
end

Net = {
		connect = connect,
		send = send,
		getIP = getIP,
		setPlayerMsg = setPlayerMsg,
		getConnect = getConnect,
		setEnable = setEnable,
		getLastIcmd = getLastIcmd,
		remove = remove,
		setRestartFlag = setRestartFlag,
		registerVersion = registerVersion,
		removeVersionListen = removeVersionListen,
		getPort = getPort,
		setReLogin = setReLogin,
		-- reStartGameListener = reStartGameListener,
}
