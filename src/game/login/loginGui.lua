local login_layer = nil
local touch_point = nil
local state_info = nil --州状态信息
local m_pre_load_finished = nil
local m_isRanger = nil
local m_touchLayer = nil
local m_userCenter = nil
require("game/net/login")
local loginEnterGame = require("game/login/login_enter_game")
local loginLoading = require("game/login/login_loading")
local loginUserCenter = require("game/login/login_user_center")
local loginServerList = require("game/login/login_server_list")
local loginBulletin = require("game/login/login_bulletin")
local loginBulletinList = require("game/login/login_bulletin_list")


local m_pBlackLayer = nil
-- local uiUtil = require("game/utils/ui_util")

local usercenter_parent = nil
local isClickUserCenter = nil --如果点击的是用户管理界面，则不要播放射箭cg
local function getIsClickUserCenter(  )
	return isClickUserCenter
end

local function add_login_observer()
	-- netObserver.addObserver(ON_LOGIN,loginData.onLogin)
	netObserver.addObserver(CREATE_ROLE_NAME, loginData.onNameCheck)
    netObserver.addObserver(CREATE_ROLE, loginData.onCreateRole)
    netObserver.addObserver(GET_REGION_STATE, loginData.receiveStateInfo)
end

local function remove_login_observer()
	-- netObserver.removeObserver(ON_LOGIN)
	netObserver.removeObserver(CREATE_ROLE_NAME)
    netObserver.removeObserver(CREATE_ROLE)
    netObserver.removeObserver(GET_REGION_STATE)
end

local function add_login_content(temp_touch_group)
	if not login_layer then return end
	login_layer:addChild(temp_touch_group)
end

local function get_touch_point()
	return touch_point
end

local function dealWithClick2UserCenter(sender,eventType)
	if not UpdateUI.playCGEnd() then
		return
	end
	
	if eventType == TOUCH_EVENT_BEGAN then
		isClickUserCenter = true
	elseif eventType == TOUCH_EVENT_ENDED then
		isClickUserCenter = false
		if configBeforeLoad.getIfSdkLogin() then
			-- 因为uc这sb没有账户管理界面的接口
			if (sdkMgr:sharedSkdMgr():getAppChannel() == "uc_platform" or sdkMgr:sharedSkdMgr():getAppChannel() == "dangle" 
				or sdkMgr:sharedSkdMgr():getAppChannel() == "oppo") and not sdkMgr:sharedSkdMgr():hasLogin() then
				-- sdkMgr:sharedSkdMgr():startLogin()
				SDKLogin.create()
			else
				if Setting then
					Setting.setNewMsg(false)
				end
				sdkMgr:sharedSkdMgr():openManagerView()
			end
		else
			loginGUI.createUserCenter()
		end
	elseif eventType == TOUCH_EVENT_CANCELED then
		isClickUserCenter = false
	end
end

local function setNewMsgAtUserCenter( )
	if not usercenter_parent then return end
	local temp_widget = usercenter_parent:getWidgetByTag(85)
	if temp_widget then
		local new_msg = tolua.cast(temp_widget:getChildByName("ImageView_msg"),"ImageView")
		if Setting then
		 	if Setting.getNewMsg() then
		 		new_msg:setVisible(true)
		 	else
		 		new_msg:setVisible(false)
		 	end
		end
	end
end

local function createBtn2UserCenter()
	if not usercenter_parent then return end
	local fun = function ( )
		local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_to_user_center.json")
		temp_widget:setScale(configBeforeLoad.getgScale())
		temp_widget:ignoreAnchorPointForPosition(false)
		temp_widget:setAnchorPoint(cc.p(0,1))
		m_userCenter = temp_widget
		local posX = 0
		local posY = configBeforeLoad.getWinSize().height
		temp_widget:setPosition(cc.p(posX, posY))
		temp_widget:setTag(85)
	 	usercenter_parent:addWidget(temp_widget)
	 	temp_widget:setTouchEnabled(true)
	 	local btn_to_user_center = tolua.cast(temp_widget:getChildByName("btn_to_user_center"),"Button")
	 	btn_to_user_center:setTouchEnabled(true)
	 	btn_to_user_center:addTouchEventListener(dealWithClick2UserCenter)

	 	local new_msg = tolua.cast(temp_widget:getChildByName("ImageView_msg"),"ImageView")
	 	new_msg:setVisible(false)
	 	if Setting then
		 	if Setting.getNewMsg() then
		 		new_msg:setVisible(true)
		 	else
		 		new_msg:setVisible(false)
		 	end
		 end
	end

	if configBeforeLoad.getIfSdkLogin() then
		if sdkMgr:sharedSkdMgr():getChannel() == "netease" then
			fun()
		else
			-- sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(true)
		end
	else
		fun()
	end
end

local function setLoginLayer( )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_loading_layer.json")
	temp_widget:setTag(999)
	temp_widget:setScale(configBeforeLoad.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	login_layer:addWidget(temp_widget)
	local image = tolua.cast(temp_widget:getChildByName("name_img_0"),"ImageView") 
	image:setScale(4)
	local easeAction = CCEaseExponentialIn:create(CCScaleTo:create(0.2,1))
	local scaleAction = animation.sequence({easeAction, cc.CallFunc:create(function ( )
		local scene = cc.Director:getInstance():getRunningScene()
		local left1 = CCMoveBy:create(0.05,ccp(5,0))
		local right1 = CCMoveBy:create(0.05,ccp(-5,0))
		local top1 = CCMoveBy:create(0.05,ccp(0,5))
		local rom1 = CCMoveBy:create(0.05,ccp(0,-5))
		local action3 = animation.sequence({left1,right1,top1,rom1,left1:reverse(),right1:reverse(),top1:reverse(),rom1:reverse(), cc.CallFunc:create(function ( )
			if configBeforeLoad.getIfSdkLogin() then
	    		SDKLogin.create()
	    	else
	    		Connect.connect_service_filter()
			end
		end)})
		-- local action = CCRepeat:create(action3,1)
		scene:runAction(action3)
	end)})
    image:runAction(scaleAction)
end


local function on_login_layer_touch(eventType, x, y)
	if eventType == "ended" then
		touch_point.x = x
		touch_point.y = y
	end
	return true
end


local function removeLoadingLayer()
	local temp_widget = login_layer:getWidgetByTag(998)
	if temp_widget then 
		temp_widget:removeFromParentAndCleanup(true)
		temp_widget = nil
	end
end

local function createLoadingLayer()
	if not login_layer then
		return
	end
	local _temp = TouchGroup:create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/login_loading_layer.json")
	temp_widget:setTag(998)
	temp_widget:setScale(configBeforeLoad.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	_temp:addWidget(temp_widget)
	login_layer:addChild(_temp)
end

local function removeLoginLayer()
	if not login_layer then
		return
	end
	local temp_widget = login_layer:getWidgetByTag(999)
	if temp_widget then 
		temp_widget:removeFromParentAndCleanup(true)
		temp_widget = nil
	end

	local temp_widget_login = login_layer:getWidgetByTag(998)
	if temp_widget_login then
		temp_widget_login:removeFromParentAndCleanup(true)
		temp_widget_login = nil
	end
end

local function showLoginView()
	-- if Login.hasCacheAccount() then 
	-- 	loginUserCenter.remove()
	-- 	loginEnterGame.create()
	-- else
		if not configBeforeLoad.getIfSdkLogin() then
			if not Login.hasCacheAccount() then
				loginUserCenter.create()
			else
				loginUserCenter.remove()
				loginEnterGame.create()
			end
		else
			loginUserCenter.remove()
			loginEnterGame.create()
		end
	-- end
end



local function setBlackLayerVisible(isVisible)
	if isVisible then 
		if not m_pBlackLayer then 
			local win_size = config.getWinSize()
			m_pBlackLayer = cc.LayerColor:create(cc.c4b(14, 17, 24, 150), win_size.width, win_size.height)
			loginGUI.add_login_content(m_pBlackLayer)
		end
	else
		if m_pBlackLayer then 
			m_pBlackLayer:removeFromParentAndCleanup(true)
			m_pBlackLayer = nil
		end
	end
end
local function create(pre_load_finished,isRanger)
	require("game/login/loginData")
    if not login_layer then 
        add_login_observer()
	    touch_point = ccp(0, 0)
	    login_layer = TouchGroup:create()
	    if pre_load_finished or UpdateUI.getIsLoginFinish() then

	    else
	    	login_layer:setVisible(false)
	    end

	    usercenter_parent = TouchGroup:create()
	    if pre_load_finished or UpdateUI.getIsLoginFinish() then

	    else
	    	usercenter_parent:setVisible(false)
	    end
	    cc.Director:getInstance():getRunningScene():addChild(usercenter_parent)


	    cc.Director:getInstance():getRunningScene():addChild(login_layer)

	    m_touchLayer = CCLayer:create()
	    m_touchLayer:setTouchEnabled(true) 
	    m_touchLayer:registerScriptTouchHandler(on_login_layer_touch, false, -1, false)
	    cc.Director:getInstance():getRunningScene():addChild(m_touchLayer)    
    end

    m_isRanger = isRanger
    m_pre_load_finished = pre_load_finished
    require("game/login/sdk_login")
	if not m_isRanger then
		createBtn2UserCenter()
		-- if configBeforeLoad.getIfSdkLogin() then
	 --    	SDKLogin.create()
	 --    	return
	 --    end

	    -- if m_pre_load_finished then 
		    loginGUI.showLoginView()
	    -- else
		    -- if Login.hasCacheAccount() then
	            Connect.connect_service_filter()
	        -- else
	            -- loginGUI.showLoginView()
	        -- end
	    -- end
	end
	-- setLoginLayer()
    
end



local function remove( )

	if m_pBlackLayer then 
		m_pBlackLayer:removeFromParentAndCleanup(true)
		m_pBlackLayer = nil
	end

	if login_layer then
		local inputNameLoginInfo = require("game/login/inputNameLoginInfo")
		SDKLogin.remove()
		loginLoading.remove()
		loginEnterGame.remove()
		removeLoadingLayer()
		removeLoginLayer()
		loginServerList.remove()
		loginUserCenter.remove()
		loginBulletin.remove()
		loginBulletinList.remove()

		if selectBornInfo then
			selectBornInfo.remove()
		end
		if inputNameLoginInfo then
			inputNameLoginInfo.remove()
		end
		
		if usercenter_parent then
			usercenter_parent:removeFromParentAndCleanup(true)
			usercenter_parent = nil
		end

		login_layer:unregisterScriptTouchHandler()
		login_layer:removeFromParentAndCleanup(true)
		login_layer = nil

		state_info = nil
		touch_point = nil
		m_pre_load_finished = nil
		m_isRanger = nil
		m_userCenter = nil
		-- m_bFirstTouch = nil
		-- if m_handler then
		-- 	scheduler.remove(m_handler)
		-- 	m_handler = nil
		-- end
		remove_login_observer()
	end

	if m_touchLayer then
		m_touchLayer:removeFromParentAndCleanup(true)
		m_touchLayer = nil
	end
end

local function on_pre_load_finish(num_finished,num_need)
	-- namePasswordInfo.on_pre_load_finish()
	loginLoading.on_pre_load_finish(num_finished,num_need)
end



local function set_state_info(packet)
	state_info = {}
	for k,v in pairs(packet) do
		state_info[v.region_id] = v.state
	end
end

local function get_state_info_by_index(state_id)
	if state_info[state_id] == 0 then
		return true
	else
		return false
	end
end

local function createMaintenanceLayer( )
	if configBeforeLoad.isGmAccount() then
		return false
	end
	
	if loginData.getLastCacheServerId() then
 		local server_info = loginData.getServerInfoById(loginData.getLastCacheServerId())
 		if server_info then
 			-- 如果在维护弹出提示
 			if server_info.flag_maintain and server_info.flag_maintain == 1 then
				if login_layer then
					local Maintenance = require("game/login/serverOnMaintenance")
					login_layer:addChild(Maintenance.create(),5,5)
					return true
				end
			end
		end
	end
	return false
end

local function createEnterGame(serverid)
	loginEnterGame.create(serverid)
end

local function removeEnterGame()
	loginEnterGame.remove()
end

local function createUserCenter()
	loginBulletin.remove()
	loginUserCenter.create()
end

local function removeUserCenter()
	loginUserCenter.remove()
end

local function createServerList()
	if not loginBulletin.getInstance() then
		loginServerList.create()
	end
end

local function removeServerList()
	loginServerList.remove()
	loginEnterGame.changeAbleBtnEnterGame(true)
end

-- 开始进入创建角色流程
local function showCreateRole(loginPakect)
	local selectBornInfo = require("game/login/selectBornInfo")
	loginGUI.set_state_info(loginPakect[4])
	selectBornInfo.create(true)
end

local function setUIVisible( flag, noAnimation )
	if login_layer then
		local action = nil
		if flag then
			login_layer:runAction(animation.sequence({cc.CallFunc:create(function ( )
				login_layer:setVisible(flag)
				usercenter_parent:setVisible(flag)
			end), CCFadeIn:create(0.3)}))
		else
			if noAnimation then
				usercenter_parent:setVisible(flag)
				login_layer:setVisible(flag)
			else
				login_layer:runAction(animation.sequence({CCFadeOut:create(0.3), cc.CallFunc:create(function ( )
					login_layer:setVisible(flag)
					usercenter_parent:setVisible(flag)
				end)}))
			end
		end
	end
end

local function setUserCenterVisible( flag,noAnimation )
	if usercenter_parent then
		local action = nil
		if flag then
			usercenter_parent:runAction(animation.sequence({cc.CallFunc:create(function ( )
				usercenter_parent:setVisible(flag)
			end), CCFadeIn:create(0.3)}))
		else
			if noAnimation then
				usercenter_parent:setVisible(flag)
			else
				usercenter_parent:runAction(animation.sequence({CCFadeOut:create(0.3), cc.CallFunc:create(function ( )
					usercenter_parent:setVisible(flag)
				end)}))
			end
		end
	end
end

-- 进入资源加载
local function beginLoginLoading()
	loginEnterGame.remove()
	loginServerList.remove()
	loginUserCenter.remove()
	loginBulletin.remove()
	loginBulletinList.remove()
	removeLoginLayer()
	local inputNameLoginInfo = require("game/login/inputNameLoginInfo")
	local selectBornInfo = require("game/login/selectBornInfo")
	
	if selectBornInfo then
		selectBornInfo.remove()
	end

	if inputNameLoginInfo then
		inputNameLoginInfo.remove()
	end

	if m_userCenter then
		m_userCenter:removeFromParentAndCleanup(true)
		m_userCenter = nil
	end
    createLoadingLayer()
    loginLoading.create()
end

loginGUI = { 
	create = create,
	remove = remove,
	get_touch_point = get_touch_point,
	add_login_content = add_login_content,
	on_pre_load_finish = on_pre_load_finish,
	set_state_info = set_state_info,
	get_state_info_by_index = get_state_info_by_index,
	createEnterGame = createEnterGame,
	removeEnterGame = removeEnterGame,
	createUserCenter = createUserCenter,
	removeUserCenter = removeUserCenter,
	createServerList = createServerList,
	removeServerList = removeServerList,
	-- onCreateRole = onCreateRole,
	showCreateRole = showCreateRole,
	beginLoginLoading = beginLoginLoading,
	showLoginView = showLoginView,
	resumeVideo = resumeVideo,
	setLoginLayer = setLoginLayer,
	setUIVisible = setUIVisible,
	setUserCenterVisible = setUserCenterVisible,
	getIsClickUserCenter = getIsClickUserCenter,
	setBlackLayerVisible = setBlackLayerVisible,
	createLoadingLayer = createLoadingLayer,
	createMaintenanceLayer = createMaintenanceLayer,
	add_login_observer = add_login_observer,
	remove_login_observer = remove_login_observer,
	setNewMsgAtUserCenter = setNewMsgAtUserCenter,
}
