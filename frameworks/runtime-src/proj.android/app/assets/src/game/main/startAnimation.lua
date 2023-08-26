-- startAnimation
--品牌动画
module("StartAnimation", package.seeall)
local m_logo = nil
local m_layer = nil
local function on_login_layer_touch(eventType, x, y )
	-- if eventType == "ended" then
	-- 	playAnimation()
	-- 	m_bNotFirstLogin = true
	-- end

	return false
end

function create( )
	-- require("game/main/startAnimation")
 --    require("game/update/LUpdate")
 --    require("game/update/setConfigUI")
 --    require("game/update/updateUI")
 --    require("game/update/languageBeforeLogin")
    -- require("game/encapsulation/action")
    if configBeforeLoad.getDebugEnvironment() then
        cc.Director:getInstance():setDisplayStats(true)
    end

    local gSceneGame = cc.Director:getInstance():getRunningScene()
    if not gSceneGame then
    	gSceneGame = cc.Scene:create()
    	cc.Director:getInstance():runWithScene(gSceneGame)
    end

    -- gSceneGame:addChild(StartAnimation.create(), 200)
    -- StartAnimation.play( )

	m_layer = cc.LayerColor:create(cc.c4b(255,255,255,255), configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height)
	m_layer:setTouchEnabled(true)
	m_layer:registerScriptTouchHandler(on_login_layer_touch, false, -10, true)
	gSceneGame:addChild(m_layer,200)
	m_logo = cc.Sprite:create("test/res_single/logo.png")
	m_logo:setScale(configBeforeLoad.getgScale())
	m_logo:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	m_layer:addChild(m_logo)
	play()
	-- return m_layer
end

function remove( )
	if m_layer then
		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		m_logo = nil
	end
end

local function beforeGame( )
	SceneBeforeLogin.loadFileBeforeLogin()
	-- EndGameUI.init()
	-- local actions2 = CCArray:create()
	-- actions2:addObject(cc.CallFunc:create(function ( )
	-- 	if configBeforeLoad.getDebugEnvironment( ) then
	-- 		setConfigUI.create()
	-- 	else
	-- 		UpdateUI.create()
	-- 	end
	-- end))
	-- actions2:addObject(CCFadeOut:create(1))
	-- actions2:addObject(cc.CallFunc:create(function ( )
	-- 	m_layer:runAction(CCFadeOut:create(1))
	-- end))
	-- actions2:addObject(cc.DelayTime:create(1))
	-- actions2:addObject(cc.CallFunc:create(function ( )
	-- 	remove()
	-- end))
	m_logo:runAction(
		cc.Sequence:create(
			cc.CallFunc:create(function ( ) 
				if configBeforeLoad.getDebugEnvironment( ) then 
					setConfigUI.create() 
				else 
					UpdateUI.create() 
				end 
			end), 
			CCFadeOut:create(1), 
			cc.CallFunc:create(function ( ) 
				m_layer:runAction(CCFadeOut:create(1)) 
			end), 
			cc.DelayTime:create(1),	
			cc.CallFunc:create(function ( ) 	
				remove(	) 
			end)
		)	
    )

end

function play( )
	if not m_logo then return end

	
	m_logo:runAction(cc.Sequence:create(cc.DelayTime:create(0), 
		cc.CallFunc:create(function ()
			print("ttttt0")
    		-- CSound:sharedSound():preloadEventGroup("ui", "gameSound/G10_output_03", true)
    		local cache = cc.SpriteFrameCache:getInstance()
    		cache:addSpriteFrames("test/res/Login.plist")
    		-- cache:addSpriteFramesWithFile("test/res/Login_1.plist")
    		cache:addSpriteFrames("test/res/Login_common.plist")
    		-- if not configBeforeLoad.getDebugEnvironment() then
			print("ttttt")
    		LUpdate.runSceneBegin()
			print("ttttt1")
    		loginGUI.setUIVisible( false, true )
			print("ttttt2")
    		-- else
    		-- end
   		end),
		cc.DelayTime:create(0.1),
		cc.CallFunc:create(function ( )
			beforeGame( ) 
		end)
	))
end

function reStartGame( )
	require("game/config/scene")
	scene.removeAllGameData()
	if Net then
        Net.remove()
    end

    if LSound then
        LSound.remove()
    end
    local textureCache = CCTextureCache:sharedTextureCache()
    textureCache:delAllNoRemoveFlag()
	-- cc.Director:getInstance():getScheduler():unscheduleAll()
	cc.Director:getInstance():getRunningScene():removeAllChildrenWithCleanup(true)
	cc.Director:getInstance():getRunningScene():stopAllActions()
	cc.Director:getInstance():purgeCachedData()

	for i, v in pairs(package.loaded) do
		package.loaded[i] = nil  
	end
	
	sdkMgr:sharedSkdMgr():reStartGame()
	-- _G = nil
	-- require("game/main/main")
end