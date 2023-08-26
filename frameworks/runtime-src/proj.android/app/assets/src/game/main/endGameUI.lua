--退出游戏弹出框或者网络不给力的弹框
module("EndGameUI", package.seeall)
-- local m_groud = nil
local m_touchgroud = nil
function remove_self( )
    if m_touchgroud then
    	m_touchgroud:removeFromParentAndCleanup(true)
    	m_touchgroud = nil
    end
end

function remove(  )
	-- if m_groud then
 --    	m_groud:removeFromParentAndCleanup(true)
 --    	m_touchgroud = nil
 --    	m_groud = nil
 --    end
end

function init( )
	-- if m_groud then return end
	require("game/main/sceneLayerDefine")
	-- m_groud = CCLayer:create()
	-- m_groud:setKeypadEnabled(true)
	-- m_groud:registerScriptKeypadHandler( function(eventType)
 --            if eventType == "backClicked"  then
 --            	-- create(languageBeforeLogin["tuichuyouxi"], remove_self, function (  )
 --            	-- 	-- cc.Director:getInstance():endToLua()
 --            	-- 	configBeforeLoad.exitGame()
 --            	-- end)
	-- 			sdkMgr:sharedSkdMgr():tryExit()
 --        	end
 --        end)   
	-- cc.Director:getInstance():getRunningScene():addChild(m_groud,102)
end

function create(str,cancel_callback, sure_callback, cancel_str, ok_str )
	require("game/main/sceneLayerDefine")
	--双击返回键退出这个界面
	if m_touchgroud then 
		remove_self()
		return
	end
	m_touchgroud = TouchGroup:create()
	cc.Director:getInstance():getRunningScene():addChild(m_touchgroud,END_GAME)
	-- if m_groud then
	-- 	m_groud:addChild(m_touchgroud)
	-- end

	local layout = Layout:create()
	layout:setSize(CCSize(configBeforeLoad.getWinSize().width, configBeforeLoad.getWinSize().height))
	layout:setTouchEnabled(true)
	m_touchgroud:addWidget(layout)
	
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/end_game_panel.json")
	widget:setTag(999)
	m_touchgroud:addWidget(widget)
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(configBeforeLoad.getWinSize().width/2, configBeforeLoad.getWinSize().height/2))
	m_touchgroud:setScale(configBeforeLoad.getgScale())
	
	local _str = ""
	local single = nil
	for i = 1, string.len(str) do
		single = string.sub(str,i,i)
		if single == "#" then
		else
			_str = _str..single
		end
	end

	local text = tolua.cast(widget:getChildByName("Label_589931"),"Label")
	text:setText(_str)

	local title = tolua.cast(widget:getChildByName("label_title"),"Label")
	title:setText(languageBeforeLogin["queding"])

	local panel_cancel  = tolua.cast(widget:getChildByName("Panel_cancel"),"Layout")
	local panel_ok  = tolua.cast(widget:getChildByName("Panel_ok"),"Layout")

	

	local button_ok = CCMenuItemImage:create()
	button_ok:setNormalSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Skills_of_special_button_1.png"))
	button_ok:setSelectedSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Skills_of_special_button_4.png"))
	button_ok:registerScriptTapHandler(function ( )
		if sure_callback then
			sure_callback()
		end
	end)

	local button_cancel = CCMenuItemImage:create()
	button_cancel:setNormalSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Skills_of_special_button_1.png"))
	button_cancel:setSelectedSpriteFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("Skills_of_special_button_4.png"))
	button_cancel:registerScriptTapHandler(function ( )
		if cancel_callback then
			cancel_callback()
		end
	end)

	local menu = CCMenu:create()
	menu:setTouchPriority(-555)
	menu:addChild(button_ok)
	menu:addChild(button_cancel)

	panel_cancel:addChild(menu)

	local point_ok = panel_ok:convertToWorldSpace(cc.p(0,0))
	local point_cancel = panel_cancel:convertToWorldSpace(cc.p(0,0))

	local ok = menu:convertToNodeSpace(point_ok)
	local cancel = menu:convertToNodeSpace(point_cancel)
	button_ok:setPosition(cc.p(ok.x + button_ok:getContentSize().width/2, ok.y+button_ok:getContentSize().height/2))
	button_cancel:setPosition(cc.p(cancel.x + button_cancel:getContentSize().width/2, cancel.y + button_cancel:getContentSize().height/2))

	if cancel_str then
		local cancel_Label = tolua.cast(panel_cancel:getChildByName("label_cost_0_2_0"),"Label")
		cancel_Label:setText(cancel_str)
	end

	if ok_str then
		local ok_Label = tolua.cast(panel_ok:getChildByName("label_cost_0_1_0_0"),"Label")
		ok_Label:setText(ok_str)
	end

	-- local sureBtn = tolua.cast(widget:getChildByName("btn_ok"),"Button")
	-- sureBtn:addTouchEventListener(function ( sender, eventType )
	-- 	if eventType == TOUCH_EVENT_ENDED then
	-- 		if sure_callback then
	-- 			sure_callback()
	-- 		end
			
	-- 	end
	-- end)

	-- local closeBtn = tolua.cast(widget:getChildByName("btn_cancel"),"Button")
	-- closeBtn:addTouchEventListener(function (sender, eventType )
	-- 	if eventType == TOUCH_EVENT_ENDED then
	-- 		if cancel_callback then
	-- 			cancel_callback()
	-- 		end
	-- 	end
	-- end)
end