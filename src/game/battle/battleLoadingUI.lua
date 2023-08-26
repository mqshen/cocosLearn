-- battleLoadingUI.lua
--战斗动画的loading界面
module("BattleLoadingUI", package.seeall)
local main_layer = nil
local loginLoadingBar = nil
function remove_self( )
	if main_layer then
		if loginLoadingBar then
        	loginLoadingBar.remove()
        end
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        loginLoadingBar = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_BATTLE_LOADING)
    end
end

function dealwithTouchEvent(x,y)
	return true
end

function create(playeCallFunc )
	if main_layer then 
		remove_self()
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("test/res/Login.plist")
	
	loginLoadingBar = require("game/login/login_loading_bar")
	
	main_layer = TouchGroup:create()
	local layer = Layout:create()
	layer:setContentSize(CCSize(config.getWinSize().width,config.getWinSize().height))
	layer:setTouchEnabled(true)


	local colorLayer = cc.LayerColor:create(cc.c4b(0,0,0,255), configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height)
	layer:addChild(colorLayer)

	local sprite = cc.Sprite:create(ResDefineUtil.guide_res[3])
	colorLayer:addChild(sprite)
	sprite:setPosition(cc.p(configBeforeLoad.getWinSize().width*0.5, configBeforeLoad.getWinSize().height*0.5))
	sprite:setScale(config.getgScale())

	local colorLayer_temp = cc.LayerColor:create(cc.c4b(0,0,0,255*0.75), configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height)
	colorLayer:addChild(colorLayer_temp)


	main_layer:addWidget(layer)

 	local loadingUI = loginLoadingBar.create()
    main_layer:addWidget(loadingUI)
    loadingUI:setScale(config.getgScale())
	loadingUI:ignoreAnchorPointForPosition(false)
	loadingUI:setAnchorPoint(cc.p(0.5,0))
	loadingUI:setPosition(cc.p(configBeforeLoad.getWinSize().width*0.5, 0))

	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_BATTLE_LOADING)
	loginLoadingBar.setPatchName(languagePack['waiting_4'])
	-- local logo = cc.Sprite:createWithSpriteFrameName("LOGO.png")
	-- colorLayer:addChild(logo)
	-- logo:setAnchorPoint(cc.p(0.5,0))
	-- logo:setPosition(cc.p(configBeforeLoad.getWinSize().width*0.5, configBeforeLoad.getWinSize().height*0.5))
	-- logo:setScale(config.getgScale())
	local textureCache = CCTextureCache:sharedTextureCache()
	textureCache:removeUnusedTextures()

	local index = 0
	local temp = {}
	for i,v in pairs(BattleAnimation.getAnimationName()) do
		if i~= "tongyong" then
			table.insert( temp, i )
		end
	end

	local setPercent = nil
	setPercent = function ( )
		index = index + 1
		if #temp >= index then
			loginLoadingBar.setPercent(100*index/#temp)
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfoAsync("Export/battle/"..temp[index]..".ExportJson", setPercent)
		else
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/battle/battle_dir_1_2.plist")
			main_layer:runAction(animation.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function ( )
				remove_self()
				BattleAnimationController.battleAsyncCreate()
				if playeCallFunc then
					playeCallFunc()
				else
	                BattleAnalyse.analyseAnimation()
	            end
			end)}))
		end
	end
	setPercent()
end