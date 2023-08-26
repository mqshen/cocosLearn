-- gameSpriteMainUI.lua
-- 游戏精灵的主ui
module("GameSpriteMainUI", package.seeall)
local main_layer = nil
local checkBoxArray = nil
function do_remove_self(  )
	GameSpriteMgr.remove()
	GameSpriteHotPoint.remove()
	GameSpriteQuestion.remove()
	if main_layer then
		checkBoxArray = nil
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_GAME_SPRITE)
    end
end

function dealwithTouchEvent(x,y)
	if not main_layer then
		return false
	end

	local temp_widget = main_layer:getWidgetByTag(999)

	if temp_widget and temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

function remove_self( )
	uiManager.hideConfigEffect(uiIndexDefine.UI_GAME_SPRITE,main_layer,do_remove_self)
end

function create(pageIndex )
	require("game/help/gameSpriteMgr")
    require("game/help/gameSpriteHotPoint")
    require("game/help/gameSpriteQuestion")
	if main_layer then 
		remove_self()
	end
	GameSpriteMgr.init()
	main_layer = TouchGroup:create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/youxijingling.json")
    temp_widget:setTag(999)
    temp_widget:setAnchorPoint(cc.p(0.5,0.5))
    temp_widget:setScale(config.getgScale())
    temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_layer:addWidget(temp_widget)

	-- GameSpriteMgr.sendQuestion("【system】热点问题")
	checkBoxArray = {}
	local CheckBox_hot = tolua.cast(temp_widget:getChildByName("CheckBox_hot"),"CheckBox")
	table.insert(checkBoxArray, CheckBox_hot)
	local CheckBox_recommend = tolua.cast(temp_widget:getChildByName("CheckBox_recommend"),"CheckBox")
	table.insert(checkBoxArray, CheckBox_recommend)
	CheckBox_recommend:setTouchEnabled(false)
	CheckBox_recommend:setVisible(false)
	local CheckBox_question = tolua.cast(temp_widget:getChildByName("CheckBox_question"),"CheckBox")
	table.insert(checkBoxArray, CheckBox_question)

	local page = pageIndex or 1
	checkBoxArray[page]:setSelectedState(true)
	checkBoxArray[page]:setTouchEnabled(false)
	changeTag(page )
	for i, v in ipairs(checkBoxArray) do
		v:addEventListenerCheckBox(function ( sender, eventType )
			if eventType == CHECKBOX_STATE_EVENT_SELECTED then
				changeTagButton(i)
			elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
			end
		end)
	end

	--关闭按钮
    local btn_close = tolua.cast(temp_widget:getChildByName("close_btn"),"Button")
    btn_close:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)

    -- 输入框
    local inputPanel = tolua.cast(temp_widget:getChildByName("Panel_shurukuang"),"Layout")
    local panel = tolua.cast(inputPanel:getChildByName("coor_txt"),"Layout")
    local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    inputBoxX = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    inputBoxX:setFontName(config.getFontName())
    inputBoxX:setFontSize(20*config.getgScale())
    inputBoxX:setFontColor(ccc3(255,255,255))

    inputBoxX:setPlaceHolder("请输入你要提问的问题")
    inputBoxX:setPlaceholderFontColor(ccc3(128,128,127))
    inputBoxX:setPlaceholderFontSize(20*config.getgScale())

    inputPanel:addChild(inputBoxX)
    inputBoxX:setScale(1/config.getgScale())
    inputBoxX:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    inputBoxX:setAnchorPoint(cc.p(0,0))

    -- 发送按钮
    local btn_send = tolua.cast(inputPanel:getChildByName("btn_send"),"Button")
    btn_send:addTouchEventListener(function ( sender, eventType )
    	if eventType == TOUCH_EVENT_ENDED then
    		if stringFunc.get_str_length(inputBoxX:getText()) > 15 then
    			tipsLayer.create(languagePack['gameSprite_max_num'])
    			return
    		end

    		if string.len(inputBoxX:getText()) > 0 then
    			if not GameSpriteMgr.getLastQuesTime() or os.time() - GameSpriteMgr.getLastQuesTime() > 3 then
	    			if GameSpriteMgr.getGameSpriteTag() ~= 3 then
						GameSpriteMainUI.changeTagButton(3)
					end
	    			GameSpriteMgr.sendQuestion(inputBoxX:getText())
	    			GameSpriteMgr.writeQuestion(inputBoxX:getText())
	    			inputBoxX:setText("")
	    		else
	    			tipsLayer.create(languagePack['chat_interval_limit'])
	    		end
    		end
    	end
    end)

	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_GAME_SPRITE)
	uiManager.showConfigEffect(uiIndexDefine.UI_GAME_SPRITE, main_layer)
end

function changeTagButton( pageIndex )
	local v = checkBoxArray[pageIndex]
	v:setTouchEnabled(false)
	v:setSelectedState(true)
	changeTag(pageIndex)
	-- tolua.cast(v:getChildByTag(1),"Label"):setColor(pressColor)
	for m,n in ipairs(checkBoxArray) do
		if m ~= pageIndex then
			n:setSelectedState(false)
			n:setTouchEnabled(true)
			-- tolua.cast(n:getChildByTag(1),"Label"):setColor(releaseColor)
		end
	end
end

function changeTag(pageIndex )
	if not main_layer then
		return
	end

	local temp_widget = main_layer:getWidgetByTag(999)
	if not temp_widget then 
		return
	end

	-- 热点面板
	local hotPointPanel = tolua.cast(temp_widget:getChildByName("Panel_rediancitiao"),"Layout")
	hotPointPanel:setEnabled(false)
	hotPointPanel:setVisible(false)

	-- 换一换按钮
	local hotPointChangeBtn = tolua.cast(temp_widget:getChildByName("Panel_huanyihuan"),"Layout")
	hotPointChangeBtn:setEnabled(false)
	hotPointChangeBtn:setVisible(false)

	-- 问答面板
	local questionPanel = tolua.cast(temp_widget:getChildByName("Panel_wenda"),"Layout")
	questionPanel:setEnabled(false)
	questionPanel:setVisible(false)

	GameSpriteMgr.setGameSpriteTag(pageIndex)
	if pageIndex == 1 then
		hotPointPanel:setEnabled(true)
		hotPointPanel:setVisible(true)

		hotPointChangeBtn:setEnabled(true)
		hotPointChangeBtn:setVisible(true)
		GameSpriteHotPoint.create(hotPointPanel,hotPointChangeBtn)
	end

	if pageIndex == 3 then
		questionPanel:setEnabled(true)
		questionPanel:setVisible(true)
		GameSpriteQuestion.create(questionPanel)
	end
end