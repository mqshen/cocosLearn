Login = {}
require("game/login/loginData")

-- 账号信息相关 
-- （开发版本是由账号输入界面获取）
-- （发布版本是从平台那边获取）


-- 是否拥有账号信息
function Login.hasCacheAccount()
	-- 如果是win平台 直接显示账号输入界面
	-- if config.getPlatFormInfo() == kTargetWindows then
	-- 	return false
	-- end

	local userName = Login.getAccountInfo()--CCUserDefault:sharedUserDefault():getStringForKey("name")
	if userName and (userName ~= "") then 
		return true 
	end
	return false
end

function Login.getAccountInfo()
	local userName = CCUserDefault:sharedUserDefault():getStringForKey("name", true)
	local userPsw = CCUserDefault:sharedUserDefault():getStringForKey("code", true)
	return userName,userPsw
end

function Login.setAccountInfo(name,code)
	CCUserDefault:sharedUserDefault():setStringForKey("name", name, true)
	CCUserDefault:sharedUserDefault():setStringForKey("code", code, true)	
end

-- lstRet.add(lstServer);
-- lstRet.add(lstAnnounce);
-- lstRet.add(tbUser.servers_logined);
-- lstRet.add(1);//是否可以忽略维护标志进入服务器
-- 服务器时间
function Login.onRequestServerList(packet)
	netObserver.removeObserver(LOGIN_GET_SERVER_LIST_NEW)
	if packet == cjson.null then

	else
		loginData.setHasRequestServerid(true)
		loginData.saveServerList(packet[1])
		loginData.saveBulletinList(packet[2])
		local loginBulletinList = require("game/login/login_bulletin_list")
	    loginBulletinList.reloadData()
	    local uid = sdkMgr:sharedSkdMgr():getPropStr("UID")
	    uid = string.gsub(uid,"@","")
	    local version = CCUserDefault:sharedUserDefault():getStringForKey("userAgreement_"..uid, true)
	    if string.len(configBeforeLoad.getUserAgreementVers())>0 and version ~= configBeforeLoad.getUserAgreementVers() then
	    	local userAgreement = require("game/login/userAgreement")
			userAgreement.create()
	    end

	    configBeforeLoad.setGmAccount(packet[4]==1)
	    loginData.setLogin_server_time(packet[5])
		local loginserverList = configBeforeLoad.split_to_table(packet[3],",") --stringFunc.split_to_table(packet[3],",")[1]
		local lastedServerId = loginserverList[1]
		local tempdata = {}
		for i, v in pairs(loginserverList) do
			if string.len(v) > 0 then
				tempdata[tonumber(v)] = 1
			end
		end

		loginData.setLoginServerList(tempdata)
		loginData.setLastLoginServerId(lastedServerId)
		loginData.setLastCacheServer(lastedServerId)
	end
	SDKLogin.remove()

	loginGUI.showLoginView()
end


function Login.requestServerList()
	if loginData.getHasRequestServerid() then return end
	netObserver.addObserver(LOGIN_GET_SERVER_LIST_NEW,Login.onRequestServerList)
	-- local name,code = Login.getAccountInfo()
	local server_session = ""
	local userid = configBeforeLoad.getLoginServerUserid()
	if configBeforeLoad.getSdkData() and configBeforeLoad.getSdkData().server_session then
		server_session = configBeforeLoad.getSdkData().server_session
	end
	Net.send(LOGIN_GET_SERVER_LIST_NEW, {userid,server_session,sdkMgr:sharedSkdMgr():getBaseVersion()})
	loginGUI.showLoginView()
end


--TODOTK 把登录创建角色的东东从 loginGui 移植过来

function Login.requestLogin()
	local device = sdkMgr:sharedSkdMgr():getDeviceInfo()
	local cpu = sdkMgr:sharedSkdMgr():getCPUInfo()
	local gpu = sdkMgr:sharedSkdMgr():getGPUInfo()
	local log = {device.."#"..cpu.."#"..gpu}
	local width = sdkMgr:sharedSkdMgr():getDeviceWidth()
	local height = sdkMgr:sharedSkdMgr():getDeviceHeight()
	if width == "" then
		width = 0
	else
		width = tonumber(width)
	end

	if height == "" then
		height = 0
	else
		height = tonumber(height)
	end

	table.insert( log, width )
	table.insert( log, height )
	table.insert( log, sdkMgr:sharedSkdMgr():getOSName() )
	table.insert( log, sdkMgr:sharedSkdMgr():getOSVer() )
	table.insert( log, sdkMgr:sharedSkdMgr():getMacAddr() )
	table.insert( log, sdkMgr:sharedSkdMgr():getUDID() )
	table.insert( log, sdkMgr:sharedSkdMgr():getIMSI() )
	table.insert( log, sdkMgr:sharedSkdMgr():getConnectType() )
	table.insert( log, sdkMgr:sharedSkdMgr():getAppChannel() )
	table.insert( log, CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion",true))
	
	local temp_serverid = loginData.getLastCacheServerId()
	if not temp_serverid then
		temp_serverid = 0
	end

	if not configBeforeLoad.getIfSdkLogin() then
		Net.send(ON_LOGIN, {0, Login.getAccountInfo(), configBeforeLoad.getSdkData().server_session or "", log, temp_serverid, CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion",true), sdkMgr:sharedSkdMgr():getDevId()})
	else
		if not configBeforeLoad.getSdkData().server_session then
			SDKLogin.create()
			return
		else
			Net.send(ON_LOGIN, {1, configBeforeLoad.getSdkData().uid, configBeforeLoad.getSdkData().server_session or "", log, temp_serverid, CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion",true), sdkMgr:sharedSkdMgr():getDevId()})
		end
	end
	netObserver.addObserver(ON_LOGIN,loginData.onLogin)
	loginData.setIsLogin(false)
end
