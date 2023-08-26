--服务器主动推送信息

local function onError(packet)
	tipsLayer.create(packet[2])
	if not Net.getLastIcmd() or packet[1] == Net.getLastIcmd() then
		loadingLayer.remove()
	end
	print("icmd:"..packet[1].." \n error:"..packet[2])
end

local function LoginError( packet )
	tipsLayer.create(packet)
	print("error:"..packet)
end

local function battleReport(packet )
	--reportData.reciveReport(packet)
end

local function armyInfoChange(packet )
	print("+++++++++++++++++++++++")
end



globalNotice = {
					onError = onError,
					battleReport = battleReport,
					armyInfoChange = armyInfoChange,
					LoginError = LoginError
}