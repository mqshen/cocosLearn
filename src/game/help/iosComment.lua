-- iosComment.lua
-- 引导玩家去评论
module("IOSComment", package.seeall)
local shouldComment = nil
local main_layer = nil
local ui_daily_Login = nil
local ui_handler = nil
local ui_daily_Login_handler = nil

function setFirstOpen( )
	if true then
		return
	end
	if not config.ClientFuncisVisible(CLIENT_FUNC_IOS_COMMENT) then return end
	if not userData.isNewBieTaskFinished() then return end
	if ui_daily_Login then return end

	ui_daily_Login = true
	if userData.getUserCommentDone() then
		return
	end
	local lastTime = CCUserDefault:sharedUserDefault():getStringForKey("player_comment")
	if string.len(lastTime) > 0 then
		lastTime = tonumber(lastTime)
	else
		lastTime = 0
	end

	if (lastTime==0 or (lastTime > 0 and userData.getServerTime() - lastTime > 3600*24*3)) and userData.getServerTime() - userData.getRegTime() > 3600 then
		local allhero =  heroData.getAllHero()
		scheduler.remove(ui_daily_Login_handler)
		ui_daily_Login_handler = scheduler.create(function ( )
			scheduler.remove(ui_daily_Login_handler)
			ui_daily_Login_handler = nil
			if lastTime == 0 then
				for i, v in pairs(allhero) do
					if Tb_cfg_hero[v.heroid].quality>=4 then
						if create5Star( v.heroid) then
							return
						end
					end
				end
			else
				for i, v in pairs(allhero) do
					if Tb_cfg_hero[v.heroid].quality>=3 then
						if create4Star( v.heroid) then
							return
						end
					end
				end
			end
		end,5)
	end
end

function getCommentFlag( )
	return shouldComment
end

function setCommentFlag( flag )
	shouldComment = flag
end

function init( )
	if not config.ClientFuncisVisible(CLIENT_FUNC_IOS_COMMENT) then return end
	ui_handler = nil
	ui_daily_Login_handler = nil
	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.add, heroChange)
end

function remove( )
	ui_daily_Login= nil
	shouldComment = nil
	if ui_handler then
		scheduler.remove(ui_handler)
	end
	ui_handler = nil

	if ui_daily_Login_handler then
		scheduler.remove(ui_daily_Login_handler)
	end
	ui_daily_Login_handler = nil
	UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.add, heroChange)
end

function do_remove_self( )
	if main_layer then
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_IOS_COMMENT)
    end
end

function remove_self( )
	uiManager.hideConfigEffect(uiIndexDefine.UI_IOS_COMMENT,main_layer,do_remove_self)
end

function heroChange( packet)
	if not config.ClientFuncisVisible(CLIENT_FUNC_IOS_COMMENT) then return end
	if userData.getUserCommentDone() or not userData.isNewBieTaskFinished() then
		return
	end



	local lastTime = CCUserDefault:sharedUserDefault():getStringForKey("player_comment")
	if string.len(lastTime) > 0 then
		lastTime = tonumber(lastTime)
	else
		lastTime = 0
	end

	if (lastTime==0 or (lastTime > 0 and userData.getServerTime() - lastTime > 3600*24*3)) and userData.getServerTime() - userData.getRegTime() > 3600 then
		if Tb_cfg_hero[packet.heroid].quality>=4 then
			if create5Star( packet.heroid) then
				return
			end
		elseif Tb_cfg_hero[packet.heroid].quality==3 then
			if create4Star( packet.heroid) then
				return
			end
		end
	end
end

function create5Star( heroId)
	-- 没有5星评论过,这次是5星武将，且在大地图
	if not userData.getUserCommentDone() and Tb_cfg_hero[heroId].quality>=4 and not shouldComment then
		if not uiManager.hasUI() then
			
			create()
			return true
		end
		setCommentFlag( true )
		return true 
	end
	return false
end

function create4Star(heroId )
	local lastTime = CCUserDefault:sharedUserDefault():getStringForKey("player_comment")
	if string.len(lastTime) > 0 then
		lastTime = tonumber(lastTime)
	else
		lastTime = 0
	end

	if lastTime == 0 then
		return false
	end
	-- 没有4星评论过,这次是4星武将，且在大地图
	if not userData.getUserCommentDone() and Tb_cfg_hero[heroId].quality==3 and not shouldComment then 
		if not uiManager.hasUI() then
			
			create()
			return true
		end
		setCommentFlag( true )
		return true
	end
	return false
end

function dealwithTouchEvent(x,y)
	if not main_layer then
		return false
	end

	-- local temp_widget = main_layer:getWidgetByTag(999)

	-- if temp_widget and temp_widget:hitTest(cc.p(x,y)) then
		return false
	-- else
	-- 	remove_self()
	-- 	return true
	-- end
end

function shouldOpenComment( )
	if shouldComment and not userData.getUserCommentDone() and not uiManager.hasUI() then
		scheduler.remove(ui_handler)
		ui_handler = scheduler.create(function ( )
			if shouldComment and not userData.getUserCommentDone() and not uiManager.hasUI() then
				create()
			end
			scheduler.remove(ui_handler)
			ui_handler = nil
		end,1)
	end
end

function create( )
	-- ios_pinglun
	if main_layer then 
		return
	end

	if not uiManager.getBasicLayer() then return end

	if not userData.isNewBieTaskFinished() then return end
	local lastTime = CCUserDefault:sharedUserDefault():getStringForKey("player_comment")
	if string.len(lastTime) > 0 then
		lastTime = tonumber(lastTime)
	else
		lastTime = 0
	end

	if lastTime > 0 then
		Net.send(USER_IOS_COMMENT_DONE,{})
	end

	main_layer = TouchGroup:create()
    local Panel_touch = Layout:create()--tolua.cast(temp_widget:getChildByName("Panel_touch"),"Layout")
    Panel_touch:setAnchorPoint(cc.p(0.5,0.5))
    Panel_touch:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    Panel_touch:setSize(CCSize(config.getWinSize().width, config.getWinSize().height))
    Panel_touch:setTouchEnabled(true)
    main_layer:addWidget(Panel_touch)
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/ios_pinglun.json")
    temp_widget:setTag(999)
    temp_widget:setAnchorPoint(cc.p(0.5,0.5))
    temp_widget:setScale(config.getgScale())
    temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_layer:addWidget(temp_widget)


    local Panel_back = tolua.cast(temp_widget:getChildByName("Panel_back"),"Layout")

    local btn_reject = tolua.cast(Panel_back:getChildByName("btn_reject"),"Button")
    btn_reject:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
        	CCUserDefault:sharedUserDefault():setStringForKey("player_comment", os.time())
            remove()
            remove_self()
        end
    end)

    local btn_comment = tolua.cast(Panel_back:getChildByName("btn_comment"),"Button")
    btn_comment:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
        	-- CCUserDefault:sharedUserDefault():setStringForKey("player_comment", os.time())
        	Net.send(USER_IOS_COMMENT_DONE,{})
            remove()
        	remove_self()
            sdkMgr:sharedSkdMgr():openURL("http://www.163.com")
        end
    end)

	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_IOS_COMMENT)
	uiManager.showConfigEffect(uiIndexDefine.UI_IOS_COMMENT, main_layer)
end