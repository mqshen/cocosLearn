Connect = {}

local CONNECT_STATE_NULL = 0 -- 未连接
local CONNECT_STATE_SERVICE = 1 -- 服务连接（获取服务器列表以及登录公告信息等）
local CONNECT_STATE_GAME = 2 --游戏连接（正常的游戏连接）

local connect_state = CONNECT_STATE_NULL

local connect_ip = 0
local connect_port = 0

-- local outter_ip_str = "123.58.167.78"
-- local inner_ip_str = "192.168.11.144"

local isSidValid = true

-- 连接服务
function Connect.connect_service()
	if connect_state == CONNECT_STATE_SERVICE and 
		Net.getConnect() then
		Connect.connected()
	else
		connect_port = configBeforeLoad.getPort()
		connect_ip = configBeforeLoad.getServiceIp()
		connect_state = CONNECT_STATE_SERVICE 
		Net.connect(connect_ip, connect_port)
	end
end



-- 连接游戏
function Connect.connect_game(ip,port)
	if connect_state == CONNECT_STATE_GAME 
		and Net.getConnect() 
		and isSidValid then
		Connect.connected()
	else
		connect_ip = ip
		connect_port = port
		connect_state = CONNECT_STATE_GAME
		Net.connect(connect_ip, connect_port)

		if not isSidValid then 
			-- 处于被顶号 此时socket已经自动连上 
			-- Net.connect(connect_ip, connect_port) 这一句不会触发connected 事件
			Connect.connected()
		end
	end
end


-- 连接游戏 测试用（不走获取服务器列表流程）
function Connect.connect_game_t()
	connect_port = 8001
	-- if configBeforeLoad.getGameServerIp() then
	-- 	connect_ip = configBeforeLoad.getGameServerIp()
	-- 	-- CCUserDefault:sharedUserDefault():setStringForKey("net", LUpdate.m_strNetName)
	-- else
	-- 	local defaultNet = "内网"--CCUserDefault:sharedUserDefault():getStringForKey("net")
	-- 	if defaultNet then
	-- 		if defaultNet == "外网" then
	-- 			connect_ip = configBeforeLoad.getGameServerIp() --outter_ip_str
	-- 		else
	-- 			connect_ip = inner_ip_str
	-- 		end
	-- 	end
	-- end
	Connect.connect_game(configBeforeLoad.getGameServerIp(),connect_port)
end


function Connect.connected()
	if connect_state == CONNECT_STATE_SERVICE then
		isSidValid = true
		if not configBeforeLoad.getIfSdkLogin() and Login.getAccountInfo() ~= "" and UpdateUI.getIsUpdateComplete() then
			SDKLogin.setSimulateSDKData()
		end

		if configBeforeLoad.getIfSdkLogin() then
			local temp_sdk = configBeforeLoad.getSdkData()

			if temp_sdk and temp_sdk.nt_uid and temp_sdk.nt_uid == sdkMgr:sharedSkdMgr():getPropStr("UID") then
				SDKLogin.connectToServer()
			end
		else
			if Login.getAccountInfo() ~= "" then
				SDKLogin.connectToServer()
			else
				loginGUI.showLoginView()
			end
		end
			-- Login.requestServerList()
		-- end
		-- loginGUI.showLoginView()
	elseif connect_state == CONNECT_STATE_GAME then
		isSidValid = true
		--登录
		-- local userName,userCode = Login.getAccountInfo()
		-- Login.requestLogin(userName,userCode)
		-- sdkMgr:sharedSkdMgr():registerScriptHandler(loginEnterGame.registerHandler)
	else
		-- CCMessageBox("error connected state" .. connect_state 
		-- 	.. "\n" .. debug.traceback(), "CONNECTED")
	end 
end

function Connect.disconnected()
	-- connect_state = CONNECT_STATE_NULL
	-- connect_ip = 0
	-- connect_port = 0

	print("#####disconnected#########")
end

function Connect.clearConnectedState()
	connect_state = CONNECT_STATE_NULL
	connect_ip = 0
	connect_port = 0
end

function Connect.invalidSid()
	isSidValid = false
end


function Connect.connect_service_filter()
	if not UpdateUI.getIsUpdateComplete() then
		return
	end
	
	if configBeforeLoad.getIsNeedInfoFromService() then
        -- 获取登录服务器列表等信息
        Connect.connect_service()
    else
        -- Connect.connect_game_t()
        loginGUI.showLoginView()
    end
end
