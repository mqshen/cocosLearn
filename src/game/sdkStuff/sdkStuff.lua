-- sdkStuff.lua
module("SdkStuff", package.seeall)
function sdkCallback(eventType, data, data2 )
	local sdkName =sdkMgr:sharedSkdMgr():getChannel()
	-- 注销通知
	if eventType == klogoutNotification or eventType == kopenExitView or eventType == kgameEnterBackground then
		-- if sdkName ~= "netease" then return end
		local uid = sdkMgr:sharedSkdMgr():getPropStr("USERINFO_UID")
		local len = string.len(uid)
		if len>0 then
			sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_CAPABILITY",userData.getUserForcesPower())
			sdkMgr:sharedSkdMgr():ntUpLoadUserInfo()
		end
	elseif eventType == kgameEnterForeground then
	-- 支付返回需要向服务器验证的订单和receipt，如果是android,receipt是""
	elseif eventType == ksendFinishedOrder then
		if sdkMgr:sharedSkdMgr():getPlatform() == "ios" then
			require("game/pay/payData")
			local temp_table = {}
			temp_table["receipt-data"] = data2
			-- 获取支付的币种
			local currency = sdkMgr:sharedSkdMgr():getUserPriceLocaleId(data)
			PayData.setAdditionData({data, temp_table, currency or ""})
		else
			Net.send(PAY_DEAL_AFTER_PAY_DONE, {{data, {}}})
		end
	-- 用户中心有新消息
	elseif eventType == konReceivedNotification then
		if Setting and sdkMgr:sharedSkdMgr():getChannel() == "netease" then
			Setting.setNewMsg(true)
		end
	end
end

function upLoadUserInfo( )
	local serverdata = nil
	local lastLoginServerId = loginData.getLastLoginServerId()
	if lastLoginServerId then
		serverdata = loginData.getServerInfoById(lastLoginServerId)
	end

	-- local build_info = allTableData[dbTableDesList.build.name][userData.getMainPos()*100 + 10]
	-- local level = 1
	-- if build_info then
	-- 	level = build_info.level
	-- end

	if userData.getUserId() then
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_UID",userData.getUserHelpId())
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_NAME",userData.getUserName())
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_GRADE","1")
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_CAPABILITY",userData.getUserForcesPower())
		local sdkName =sdkMgr:sharedSkdMgr():getChannel()
		if sdkName == "pps" then
			local id = lastLoginServerId or ""
			sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTID","ppsmobile_s"..id)
		else
			sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTID",lastLoginServerId or "")
		end
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_BALANCE", userData.getYuanbao())
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_ORG", userData.getUnion_name())
		sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_VIP", "")
		sdkMgr:sharedSkdMgr():setPropStr("GAME_NAME","率土之滨")

		if serverdata then
			sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_HOSTNAME",serverdata.name or "")
			local loginsertList = loginData.getLoginServerList()
			if loginsertList[serverdata.server_id] then
				sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_DATATYPE", "1")
			else
				sdkMgr:sharedSkdMgr():setUserInfo("USERINFO_DATATYPE", "2")
			end
		end

		sdkMgr:sharedSkdMgr():ntGameLoginSuccess()
		sdkMgr:sharedSkdMgr():ntUpLoadUserInfo()
	end
end

function sdkParamReSet(packet )
	local index = 0
	for i=1, string.len(packet[2].username) do
		if "@"==string.sub(packet[2].username, i,i) then
			index = i
		end
	end
	local uid = string.sub(packet[2].username,1,index-1)
	local sn = packet[2].SN
	if sdkMgr:sharedSkdMgr():getChannel() == "coolpad_sdk" then
		local message = cjson.decode(packet[2].message)
		uid = message.token.openid
		sn = message.token.access_token
	end

	sdkMgr:sharedSkdMgr():setPropStr("UID", uid)
	sdkMgr:sharedSkdMgr():setPropStr("SESSION", sn)
end

