module("SDKLogin", package.seeall)

local sdkData = nil
local sdkLoginFail = nil
function remove( )
	-- if main_layer then
		-- main_layer:removeFromParentAndCleanup(true)
		-- main_layer = nil
		sdkData = nil
	-- end
end

function getSdkLoginFail( )
	return sdkLoginFail
end

function connectToServer( )
	if not sdkData then
		if configBeforeLoad.getIfSdkLogin() and sdkMgr:sharedSkdMgr():hasLogin() and sdkMgr:sharedSkdMgr():isLogin() then
			Login.requestServerList()
		elseif not configBeforeLoad.getIfSdkLogin() and configBeforeLoad.getLoginServerUserid() ~= 0 then
			Login.requestServerList()
		end
		return 
	end
	-- return new Object[] { 1, mpRet, strToken, tbUser.userid,iUserAgreementVer };
	-- { "code", "subcode", "aid", "username", "SN", "message" };
	local function receiveSdkLoginData(packet )
		netObserver.removeObserver(PLATFORM_LOGIN_CHECK)
		if not sdkData then return end
		if packet[1] == 1 then
			loadingLayer.remove()
			sdkLoginFail = false
			configBeforeLoad.setLoginServerUserid(packet[4])
			sdkData.server_session = packet[3]
			configBeforeLoad.setUserAgreementVers(packet[5])
			-- 这是不通过sdk登陆
			if packet[2] == cjson.null then
				-- sdkData.uid = packet[4]
				configBeforeLoad.setSdkData(packet[4], "", "", "", "", "_stzb_test_", "",
					"",packet[3], "" )
				Login.setAccountInfo(sdkData.uid,"")
			else
				configBeforeLoad.setAid(packet[2].aid)
				sdkData.uid = packet[2].username
				local index = 0
				for i=1, string.len(packet[2].username) do
					if "@"==string.sub(packet[2].username, i,i) then
						index = i
					end
				end

				local uid = string.sub(packet[2].username,1,index-1)
				-- local sn = packet[2].SN

				configBeforeLoad.setSdkData(sdkData.uid, sdkData.guest_uid, sdkData.session, sdkData.deviceId, sdkData.platform, sdkData.channel, sdkData.app_channel,
					sdkData.sdk_version,sdkData.server_session, uid )

				if SdkStuff then
					SdkStuff.sdkParamReSet(packet)
				end

				-- if sdkMgr:sharedSkdMgr():getChannel() == "coolpad_sdk" then
				-- 	local message = cjson.decode(packet[2].message)
				-- 	uid = message.token.openid
				-- 	sn = message.token.access_token
				-- end

				-- sdkMgr:sharedSkdMgr():setPropStr("UID", uid)
				-- sdkMgr:sharedSkdMgr():setPropStr("SESSION", sn)
			end
			require("game/pushMsg/adForIOS")
			AdForIOS.sendAdData()
			Login.requestServerList()
		else
			if configBeforeLoad.getPlatFormInfo() ~= kTargetWindows and configBeforeLoad.getDebugEnvironment() then
       			CCMessageBox("code ="..packet[2].code.."\n".."subcode ="..packet[2].subcode.."\n".."status ="..packet[2].status, "SDK")
    		end
    		sdkLoginFail = true
    		tipsLayer.create(languageBeforeLogin["AuthorizationFailed"])
		end
	end
	netObserver.addObserver(PLATFORM_LOGIN_CHECK,receiveSdkLoginData)
	--发送给登陆服务器的guest——uid不能带后缀
	Net.send(PLATFORM_LOGIN_CHECK, {sdkData.uid,sdkData.session,sdkData.channel, 
		sdkData.platform, sdkData.deviceId,sdkData.app_channel, sdkData.sdk_version,sdkMgr:sharedSkdMgr():getUDID()})
end

local function registerHandler(eventType, data, data2 )
	local timer = nil
	if SdkStuff then
		SdkStuff.sdkCallback(eventType, data, data2)
	end
	--登陆完成回调
	if eventType == kloginNotification then
		local temp_sdk = configBeforeLoad.getSdkData()

		if temp_sdk and temp_sdk.nt_uid and temp_sdk.nt_uid ~= sdkMgr:sharedSkdMgr():getPropStr("UID") then
			-- if sdkMgr:sharedSkdMgr():getAppChannel() == "baidu" then
			if not UpdateUI.playCGEnd() then
        	else
        		scene.remove()
    		end
		end
		-- elseif temp_sdk and temp_sdk.nt_uid and temp_sdk.nt_uid == sdkMgr:sharedSkdMgr():getPropStr("NT_UID") then
		-- 	loadingLayer.remove()
		-- 	return
		-- end

		-- loadingLayer.remove()
		local uid = sdkMgr:sharedSkdMgr():getPropStr("UID")

		local guest_uid = sdkMgr:sharedSkdMgr():getPropStr("ORIGIN_GUEST_UID")
		local session = sdkMgr:sharedSkdMgr():getPropStr("SESSION")
		local deviceId = sdkMgr:sharedSkdMgr():getPropStr("DEVICE_ID")
		local platform = sdkMgr:sharedSkdMgr():getPlatform()
		local channel = sdkMgr:sharedSkdMgr():getChannel()
		local app_channel = sdkMgr:sharedSkdMgr():getAppChannel()
		local version = sdkMgr:sharedSkdMgr():getSDKVersion()
		if app_channel == "" then
			app_channel = channel
		end
		sdkData = {uid = uid, 
		guest_uid = guest_uid, 
		session = session, 
		deviceId = deviceId, 
		platform = platform, 
		channel= channel, 
		app_channel = app_channel,
		sdk_version = version,
		server_session = nil,
		nt_uid = uid,
		}
		configBeforeLoad.setSdkData(sdkData.uid, sdkData.guest_uid, sdkData.session, 
			sdkData.deviceId, sdkData.platform, sdkData.channel, sdkData.app_channel, sdkData.sdk_version, sdkData.server_session, sdkData.nt_uid)
		-- Login.setAccountInfo(sdkData.uid,"")
		Connect.connect_service_filter()

		UpdateUI.setLoginFinish(true)
		sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(true)
	-- 注销通知
	elseif eventType == klogoutNotification then
		scene.remove()
	--网络断开
	elseif eventType == knetWorkError then
		loadingLayer.remove()
		EndGameUI.create(languageBeforeLogin[3], function ( )
				-- cc.Director:getInstance():endToLua()
				configBeforeLoad.exitGame()
			end, function ( )
				EndGameUI.remove_self()
				loadingLayer.create(999)
			end)
	-- 支付页面关闭通知
	elseif eventType == kclosePayViewNotification then
		loadingLayer.remove()
	--网络连接上
	elseif eventType == knetWorkConnect then
		EndGameUI.remove_self()
		loadingLayer.remove()
	-- sdk调用退出游戏界面
	elseif eventType == kopenExitView then
		EndGameUI.create(languageBeforeLogin["tuichuyouxi"], EndGameUI.remove_self, function (  )
            		configBeforeLoad.exitGame()
            	end)
	-- sdk初始化完成
	elseif eventType == kfinishInitNotification then
		-- timer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( )
			StartAnimation.create()
			-- cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer)
			-- timer = nil
		-- end, 0.1, false)
	-- 支付返回需要向服务器验证的订单和receipt，如果是android,receipt是""
	elseif eventType == ksendFinishedOrder then
	-- 用户中心有新消息
	elseif eventType == konReceivedNotification then
	end
end

function setSimulateSDKData( )
	if configBeforeLoad.getLoginServerUserid() ~= 0 then
		return
	end
	sdkData = {uid = Login.getAccountInfo() or "", 
		guest_uid = "", 
		session = "", 
		deviceId = "", 
		platform = "", 
		channel= "_stzb_test_", 
		app_channel = "",
		sdk_version = "",
		server_session = "",
		nt_uid = "",
		}
	configBeforeLoad.setSdkData(sdkData.uid, sdkData.guest_uid, sdkData.session, 
			sdkData.deviceId, sdkData.platform, sdkData.channel, sdkData.app_channel, sdkData.sdk_version, sdkData.server_session, sdkData.nt_uid)
	-- configBeforeLoad.setSdkData("", "", "", 
	-- 				"", "", "_stzb_test_", "", "", "", "")
end

function registerSDK( )
	-- sdkMgr:sharedSkdMgr():registerScriptHandler(registerHandler)
	-- netObserver.addObserver(PAY_DEAL_AFTER_PAY_DONE,function (package )
	-- end )
end

function create( )
	-- local channel = sdkMgr:sharedSkdMgr():getChannel()
	-- if channel == "oppo" or channel == "dangle" then
		-- sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(false)
	-- elseif channel == "uc_platform" then
		-- sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(false)
	-- end

	cc.Director:getInstance():getRunningScene():runAction(animation.sequence({cc.DelayTime:create(0), cc.CallFunc:create(function (  )
		-- sdkMgr:sharedSkdMgr():startLogin()
		loadingLayer.create()
	end)}))
end