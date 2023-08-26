-- adForIOS.lua
-- ios的广告
module("AdForIOS", package.seeall)

function sendAdData( )
	if sdkMgr:sharedSkdMgr():getPlatform() == "ios" then
		local idfa_keychain = sdkMgr:sharedSkdMgr():getObjectFromKeychainForKey("com.netease.stzb.IDFA")
		local idfv_keychain = sdkMgr:sharedSkdMgr():getObjectFromKeychainForKey("com.netease.stzb.IDFV")
		local idfa = sdkMgr:sharedSkdMgr():getIDFA()
		local idfv = sdkMgr:sharedSkdMgr():getIDFV()
		local mac_add = sdkMgr:sharedSkdMgr():getMacAddr()
		-- 只有这个账号首次注册才算有效
		if string.len(idfa_keychain) <=0 and sdkMgr:sharedSkdMgr():getPlatform() == "ios" then
			Net.send(AD_ACTIVATE,{mac_add,idfa})
			sdkMgr:sharedSkdMgr():saveToKeychainForKey(idfa,"com.netease.stzb.IDFA")
			sdkMgr:sharedSkdMgr():saveToKeychainForKey(idfv,"com.netease.stzb.IDFV")
		else
			-- 如果idfa和idfv不是空字符串，证明已经写入过keychain
			-- Net.send(AD_ACTIVATE,{mac_add,idfa_keychain})
		end
	end
end