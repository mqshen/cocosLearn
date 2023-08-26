module("setConfigUI", package.seeall)

local this = nil
local labelVersion = nil
local selectSdk = nil

local function remove( )
	labelVersion = nil
	-- selectSdk = nil
	if this then
		this:removeFromParentAndCleanup(true)
		this = nil
	end
end

function create( )
	local layer = TouchGroup:create()
	this = layer
	cc.Director:getInstance():getRunningScene():addChild(layer, 1)

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Test_select_version.json")
	widget:setScale(configBeforeLoad.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	
	layer:addWidget(widget)
	local btnOk = UIHelper:seekWidgetByName(widget,"Button_ok")
	local btnOk0 = UIHelper:seekWidgetByName(widget,"Button_ok_0")
	-- labelVersion = tolua.cast(UIHelper:seekWidgetByName(widget,"Label_version"),"Label")

	-- --游戏服输入框
	-- local input = tolua.cast(UIHelper:seekWidgetByName(widget,"TextField_465055"),"TextField")
	-- input:addEventListenerTextField(function ( sender, eventType )
	-- 	if eventType == 1 then
	-- 		configBeforeLoad.setGameServerIp(input:getStringValue())
	-- 		-- m_strIp = input:getStringValue()
	-- 		-- CCUserDefault:sharedUserDefault():setStringForKey("ip", input:getStringValue())
	-- 	end
	-- end)

	-- --登陆服输入框
	-- local inputLogin = tolua.cast(UIHelper:seekWidgetByName(widget,"TextField_465056"),"TextField")
	-- inputLogin:addEventListenerTextField(function ( sender, eventType )
	-- 	if eventType == 1 then
	-- 		-- service_ip_str = inputLogin:getStringValue()
	-- 		configBeforeLoad.setServiceIp(inputLogin:getStringValue())
	-- 		-- CCUserDefault:sharedUserDefault():setStringForKey("ip_game", inputLogin:getStringValue())
	-- 	end
	-- end)
	-- inputLogin:setText(service_ip_str)

	--复选框
	local sdk = tolua.cast(UIHelper:seekWidgetByName(widget,"CheckBox_470670"),"CheckBox")
	sdk:addEventListenerCheckBox(function ( sender, eventType )
			
			if eventType == CHECKBOX_STATE_EVENT_SELECTED then
				selectSdk = true
				configBeforeLoad.setSdkLogin(true)
			elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
				selectSdk = false
				configBeforeLoad.setSdkLogin(false)
			end
		end)

	local function setIpInfo( strName, strIp,strUpdateListUrl, strUpdateDir)
		-- body
		-- m_strNetName = strName

		-- labelVersion:setText(strName)
		-- input:setText(strIp)
		-- if strName ~= "本机" then
			-- inputLogin:setText("192.168.11.144")
			-- service_ip_str = "192.168.11.144"
			-- configBeforeLoad.setServiceIp("192.168.11.144")
		-- else
			-- inputLogin:setText(strIp)
			-- service_ip_str = CCUserDefault:sharedUserDefault():getStringForKey("ip_game")
			-- configBeforeLoad.setServiceIp(strIp)
		-- end
		-- m_strIp = input:getStringValue()

		-- configBeforeLoad.setGameServerIp(strIp)
		configBeforeLoad.setUpdateAddress(strUpdateListUrl)
		configBeforeLoad.setUpdateDir(strUpdateDir)

		btnOk:setEnabled(true)
		btnOk0:setEnabled(true)

		if strName == "外网" and cc.Application:getInstance():getTargetPlatform() ~= kTargetWindows then
			btnOk0:setEnabled(false)
			btnOk0:setEnabled(false)
		end
	end
	--外网
	-- local outsize = UIHelper:seekWidgetByName(widget,"Button_exterior")
	-- outsize:setVisible(false)
	

	-- --内网
	-- local insize = UIHelper:seekWidgetByName(widget,"Button_intra")
	-- insize:setVisible(false)

	-- --本机
	-- local localhost = UIHelper:seekWidgetByName(widget,"Button_local")
	-- localhost:setVisible(false)
	-- localhost:addTouchEventListener(function ( sender,eventType )
		-- if eventType == 2 then
		-- 	-- isNeedInfoFromService = false
		-- 	-- configBeforeLoad.setServerType(0)
		-- 	setIpInfo("本机", "127.0.0.1","","")
  --       end
	-- end)

	setIpInfo("内网", SERVER_IP,UPDATE_ADDR_INTRA,"update_exterior")


	require("game/encapsulation/action")
	


	btnOk:addTouchEventListener(function ( sender,eventType )
		if eventType == 2 then
			configBeforeLoad.setIfUpdate(true)
			if not selectSdk then
				configBeforeLoad.setSdkLogin(false)
			end
			LUpdate.runSceneBegin()
			this:runAction(animation.sequence({cc.DelayTime:create(0.2), cc.CallFunc:create(function ( )
				loginGUI.setUIVisible( false, true )
				remove()
				UpdateUI.create()
				if not selectSdk then
					UpdateUI.setLoginFinish(true)
				end
			end)}))
        end
	end)

	local func = function ( sender,eventType )
		if eventType == 2 then
			configBeforeLoad.setIfUpdate(false)
			if not selectSdk then
				configBeforeLoad.setSdkLogin(false)
			end
			UpdateUI.setUpdateComplete(true)
			LUpdate.runSceneBegin()
			this:runAction(animation.sequence({cc.DelayTime:create(0.2), cc.CallFunc:create(function ( )
				loginGUI.setUIVisible( false, true )
				remove()
				UpdateUI.create()
				if not selectSdk then
					UpdateUI.setLoginFinish(true)
				end
			end)}))
        end
	end

	btnOk0:addTouchEventListener(func)

	if WIN_DEV_MODE then
		func(nil, 2)
	end

end


