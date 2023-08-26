--播放cg的画面
module("UpdateUI", package.seeall)
-- require("game/encapsulation/action")
local main_layer = nil
local m_bNotFirstLogin = nil
local m_pVideoPlayer = nil
local m_pArrowVideoPlayer = nil
local m_pSecVideoPlayer = nil
local m_touchLayer = nil
local m_bUpdateComplete = nil
local touchLogo_image = nil
local cg_play_end = nil
local loginEnterGame =  require("game/login/login_enter_game")
require("game/login/loginGui")
require("game/login/sdk_login")
local login_finished = nil

function getIsLoginFinish( )
	return login_finished
end

function getBeginCg( )
	return m_bNotFirstLogin
end

function getIsUpdateComplete( )
	return m_bUpdateComplete
end

local function setLogoVisible()
	if m_bUpdateComplete then
		-- if m_bUpdateComplete and (not login_finished or (configBeforeLoad.getDebugEnvironment() and configBeforeLoad.getIfUpdate()
		-- 	and not configBeforeLoad.getIfSdkLogin() )) then
		if m_bUpdateComplete then
			require("game/config/scene")
			SceneBeforeLogin.initOnceFile()
			-- loginGUI.setUserCenterVisible(true)
			-- if configBeforeLoad.getIfSdkLogin() then
		 --    	SDKLogin.create()
		 --    end
		end
	    if m_bUpdateComplete --[[and login_finished]] and not m_bNotFirstLogin then
		    if main_layer and not touchLogo_image then
				touchLogo_image = GUIReader:shareReader():widgetFromJsonFile("test/login_touch.json")
				-- temp_widget:setTag(999)
				touchLogo_image:setScale(configBeforeLoad.getgScale())
				touchLogo_image:ignoreAnchorPointForPosition(false)
				touchLogo_image:setAnchorPoint(cc.p(0.5,0))
				touchLogo_image:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, 0))
				main_layer:addWidget(touchLogo_image)
				local image = tolua.cast(touchLogo_image:getChildByName("ImageView_524093"),"ImageView")

			    local actions = CCArray:create()
				actions:addObject(CCFadeTo:create(0.8, 255*0.38))
				actions:addObject(CCFadeTo:create(0.8, 255))
			    local action = cc.Sequence:create(actions)
			    image:runAction(CCRepeatForever:create(action))
			end
		end
	end
end

function setLoginFinish(flag )
	login_finished = flag
	-- setLogoVisible()
end

function setUpdateComplete( flag )
	m_bUpdateComplete = flag
	setLogoVisible()
end

function resumeVideo( )
	-- if m_pVideoPlayer then
	-- 	m_pVideoPlayer:resume()
	-- 	if sdkMgr:sharedSkdMgr():getRAMSize()<512 then
	-- 		m_pVideoPlayer:pause()
	-- 	end
	-- end

	-- if m_pSecVideoPlayer then
	-- 	m_pSecVideoPlayer:resume()
	-- 	if sdkMgr:sharedSkdMgr():getRAMSize()<512 then
	-- 		m_pVideoPlayer:pause()
	-- 	end
	-- end
end

function playSecondCg( )
	if m_pVideoPlayer then
		m_pVideoPlayer:removeFromParentAndCleanup(true)
	end
	local layout = Layout:create()
	m_pVideoPlayer = CCVideoLayer:create("cg_2.mp4",nil,nil, 50, 60)
	local oriWidth = m_pVideoPlayer:getOriFrameWidth()
	local realWidth = m_pVideoPlayer:getRealFrameWidth()
	local height = m_pVideoPlayer:getFrameHeight()
	m_pVideoPlayer:setAnchorPoint(cc.p(oriWidth/2/realWidth, 0.5))
	m_pVideoPlayer:setScale(configBeforeLoad.getWinSize().height/height)
	m_pVideoPlayer:setScaleX(2*configBeforeLoad.getWinSize().height/height)
	m_pVideoPlayer:setPosition(cc.p(configBeforeLoad.getWinSize().width/2 ,configBeforeLoad.getWinSize().height/2))
	layout:addChild(m_pVideoPlayer)
	main_layer:addWidget(layout)
	sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(true)
	LSound.playMusic("OP_bgm")
	LSound.playSound(musicSound["op_fire"])
end

function playAnimation( )
	if not m_bNotFirstLogin --[[and login_finished]] then
		if m_pVideoPlayer then
			m_pVideoPlayer:beginArrow()
			-- LSound.playSound(musicSound["op_arrow"])
		end
	end
end

local function on_login_layer_touch(eventType, x, y )
	if eventType == "ended" and m_bUpdateComplete --[[and login_finished]] and not loginGUI.getIsClickUserCenter() then
		
		local actions2 = CCArray:create()
		actions2:addObject(cc.CallFunc:create(function ( )
			if touchLogo_image then
				touchLogo_image:removeFromParentAndCleanup(true)
				touchLogo_image = nil
			end
		end))
		actions2:addObject(cc.DelayTime:create(0.1))
		actions2:addObject(cc.CallFunc:create(function ( )
			playAnimation()
			m_bNotFirstLogin = true
		end))
		main_layer:runAction(cc.Sequence:create(actions2))
	end
	return true
end

local function createCG_1 ()
	loginEnterGame.changeAbleBtnEnterGame(false)
	local layout = Layout:create()
	m_pVideoPlayer = CCVideoLayer:create("cg_1.mp4","cg_2.mp4","cg_arrow.mp4", 50, 60)
	local oriWidth = m_pVideoPlayer:getOriFrameWidth()
	local realWidth = m_pVideoPlayer:getRealFrameWidth()
	local height = m_pVideoPlayer:getFrameHeight()
	m_pVideoPlayer:setAnchorPoint(cc.p(oriWidth/2/realWidth, 0.5))
	m_pVideoPlayer:setScale(configBeforeLoad.getWinSize().height/height)
	m_pVideoPlayer:setScaleX(2*configBeforeLoad.getWinSize().height/height)
	m_pVideoPlayer:setPosition(cc.p(configBeforeLoad.getWinSize().width/2 ,configBeforeLoad.getWinSize().height/2))
	layout:addChild(m_pVideoPlayer)
	main_layer:addWidget(layout)

	m_pVideoPlayer:setFrameCallbackForLua(95, function ( )
		LSound.playSound(musicSound["op_fire"])
		CCTextureCache:sharedTextureCache():removeTextureForKey("test/res_single/logo.png")
		loginGUI.setUserCenterVisible(true)
		-- if configBeforeLoad.getIfSdkLogin() then
	 --    	SDKLogin.create()
		-- end
		loginGUI.setUIVisible(true)
		loginGUI.setLoginLayer()
		loginEnterGame.changeAbleBtnEnterGame(true)
		local loginBulletinList = require("game/login/login_bulletin_list")
		loginBulletinList.activeRollingBulletin()
		cg_play_end = true
		sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(true)
	end)
end

function playCGEnd( )
	return cg_play_end
end

function remove( )
	if main_layer then
		main_layer:removeFromParentAndCleanup(true)
		main_layer = nil
		touchLogo_image = nil
		m_pVideoPlayer = nil
	end

	if m_touchLayer then
		m_touchLayer:removeFromParentAndCleanup(true)
		m_touchLayer = nil
	end
end

function create( )
	if not main_layer then 
	    main_layer = TouchGroup:create()
	    cc.Director:getInstance():getRunningScene():addChild(main_layer,-1)

	    m_touchLayer = CCLayer:create()
	    m_touchLayer:setTouchEnabled(true) 
	    m_touchLayer:registerScriptTouchHandler(on_login_layer_touch, false, 0, false)
	    cc.Director:getInstance():getRunningScene():addChild(m_touchLayer,-1)
    end

    if not m_bNotFirstLogin then--and cc.Application:getInstance():getTargetPlatform() ~= kTargetWindows then
		require("game/main/sound")
		LSound.startMusic()
		createCG_1()
		local actions = CCArray:create()
		actions:addObject(cc.DelayTime:create(0.1))
		actions:addObject(cc.CallFunc:create(function ( )
			if configBeforeLoad.getIfUpdate() then
				LUpdate.create()
			else
				m_bUpdateComplete = true
			end
		end))
		main_layer:runAction(cc.Sequence:create(actions))
	-- elseif cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
	-- 	if not configBeforeLoad.getIsFirstLogin() then
	-- 		return
	-- 	end

	-- 	if configBeforeLoad.getIfUpdate() then
	-- 		LUpdate.create()
	-- 	else
	-- 		LUpdate.runSceneBegin()
	-- 	end
	else
		-- if cc.Application:getInstance():getTargetPlatform() ~= kTargetWindows then
			-- if sdkMgr:sharedSkdMgr():getRAMSize()<512 then
			-- 	createCG_1()
			-- else
				playSecondCg()
			-- end
		-- end
	end
end

