-- battleResultSum.lua
-- 战后结算界面
module("BattleResultSum", package.seeall)
local temp_widget = nil

local fontSize = 20

local firstPage = nil
local secondPage = nil

function getInstance( )
	return temp_widget
end

function remove_self( )
	if temp_widget then
		temp_widget:removeFromParentAndCleanup(true)
		temp_widget = nil
		firstPage = nil
		secondPage = nil
	end
end

local function getStr(v, _richText)
	local re = nil
	local sprite = nil
	local height = nil
    for m,n in ipairs(v[1]) do
    	if m == #v[1] then
            n[2] = n[2].."\n"
        end
        --平常的字
        if n[1] == 1 then
            re = RichElementText:create(1, ccc3(255,255,255), 255, n[2],config.getFontName(), fontSize)
        --数字
        elseif n[1] == 2 then
            re = RichElementText:create(1, ccc3(219,173,100), 255, n[2],config.getFontName(), fontSize)
        --我方武将 ^
        elseif n[1] == 3 then
            re = RichElementText:create(1, ccc3(125,187,139), 255, n[2],config.getFontName(), fontSize)
        --敌方武将 ~
        elseif n[1] == 4 then
            re = RichElementText:create(1, ccc3(229,60,67), 255, n[2],config.getFontName(), fontSize)
        elseif n[1] == 5 then
            --攻
            if n[2] == "-1" then
                re = RichElementImage:create(1, ccc3(0,0,0), 255, "Attacking_t.png")
            --守
            elseif n[2] == "-2" then
                re = RichElementImage:create(1, ccc3(0,0,0), 255, "Defense_t.png")
            elseif n[2] == "-3" then
                re = RichElementImage:create(1, ccc3(0,0,0), 255, "Attacking_ash.png")
            elseif n[2] == "-4" then
                re = RichElementImage:create(1, ccc3(0,0,0), 255, "Defense_ash.png")
            else
                re = RichElementImage:create(1, ccc3(0,0,0), 255, itemTextureName[tonumber(n[2])])
                sprite = cc.Sprite:createWithSpriteFrameName(itemTextureName[tonumber(n[2])])
                height = sprite:getContentSize().height
            end
        end
        _richText:pushBackElement(re)
    end
    return height
end

-- 战果的页面
function addResultPage( )
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_zhanguo.json")
	local panel_pos = tolua.cast(widget:getChildByName("Panel_pos"),"Layout")

	local temp_y = panel_pos:getPositionY()
	local temp_x = panel_pos:getPositionX()
	-- local temp_height = temp_line:getSize().height
	local topdata = reportInfo.getSumResultTop()
	local reportStrData = {}
	local function readReport(string,iaction)
        str = config.richText_split(string, {"#","@","^","~","$"})
        table.insert(reportStrData,{str,iaction})
    end

    for i, v in ipairs(topdata) do
        readReport(v[1],v[2])
    end

    local group = nil
    local layer_str = nil
    local _richText = nil
    for i, v in ipairs(reportStrData) do
    	group = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_top.json")
    	group:setVisible(true)
    	group:setPosition(cc.p(temp_x, temp_y))
    	layer_str = tolua.cast(group:getChildByName("Panel_3"),"Layout")
    	_richText = RichText:create()
	    _richText:setAnchorPoint(cc.p(0,1))
	    _richText:ignoreContentAdaptWithSize(false)
	    _richText:setSize(CCSizeMake(500, layer_str:getSize().height))
	    _richText:setPosition(cc.p(0, layer_str:getSize().height))
	    layer_str:addChild(_richText)
	    widget:addChild(group)
	    getStr(v,_richText)
	    if i~= #reportStrData then
	    	temp_y = temp_y - group:getSize().height
	    end
    end

    local line = tolua.cast(widget:getChildByName("line"),"ImageView")
    line:setAnchorPoint(cc.p(0.5,1))
    line:setPositionY(temp_y)
    temp_y = temp_y - line:getSize().height

    local resdata = reportInfo.getSumResource()
	local zhanli = tolua.cast(widget:getChildByName("zhanliping_line"),"ImageView")
    if #resdata > 0 then     
	    local res_pos = tolua.cast(widget:getChildByName("Panel_mid"),"Layout")
	    temp_y = temp_y - zhanli:getSize().height*0.7
	    zhanli:setPositionY(temp_y)
	    temp_y = temp_y - zhanli:getSize().height*0.5-res_pos:getSize().height

	    local reportStrData = {}
		local function readReport(string,iaction)
	        str = config.richText_split(string, {"#","@","^","~","$"})
	        table.insert(reportStrData,{str,iaction})
	    end

	    for i, v in ipairs(resdata) do
	        readReport(v[1],v[2])
	    end

	    temp_x = res_pos:getPositionX()
	    local _temp_height = nil
	    
	    for i, v in ipairs(reportStrData) do
	    	if i%2 == 1 then
		    	group = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_mid.json")
		    	group:setVisible(true)
		    	group:setPosition(cc.p(temp_x, temp_y))
		    	widget:addChild(group)
		    end

	    	if i%2 == 1 then
	    		layer_str = tolua.cast(group:getChildByName("Panel_1"),"Layout")
	    	else
	    		layer_str = tolua.cast(group:getChildByName("Panel_2"),"Layout")
	    	end
	    	_richText = RichText:create()
		    _richText:setAnchorPoint(cc.p(0,0))
		    _richText:ignoreContentAdaptWithSize(false)
		    _richText:setSize(CCSizeMake(500, layer_str:getSize().height))
		    _richText:setPosition(cc.p(0, 0))
		    layer_str:addChild(_richText)
		    _temp_height = getStr(v,_richText)
		    if _temp_height then
		    	_richText:setSize(CCSizeMake(500, _temp_height))
		    end
		    if i~= #reportStrData and i%2 == 0 then
		    	temp_y = temp_y - group:getSize().height
		    end
	    end
	else
		zhanli:setVisible(false)
	end

    local downdata = reportInfo.getSumResultDown()      
    local reportStrData = {}
	local function readReport(string,iaction)
        str = config.richText_split(string, {"#","@","^","~","$"})
        table.insert(reportStrData,{str,iaction})
    end

    for i, v in ipairs(downdata) do
        readReport(v[1],v[2])
    end

    local panelDown = tolua.cast(widget:getChildByName("Panel_down"),"Layout")
    panelDown:setAnchorPoint(cc.p(0,1))
    temp_y = temp_y - 10
    panelDown:setPositionY(temp_y)

    -- 显示的是否升级之类的
    _richText = RichText:create()
	_richText:setAnchorPoint(cc.p(0,1))
	_richText:ignoreContentAdaptWithSize(false)
	_richText:setVerticalSpace(3)
	_richText:setSize(CCSizeMake(panelDown:getSize().width, panelDown:getSize().height))
	_richText:setPosition(cc.p(0, panelDown:getSize().height))
	panelDown:addChild(_richText)
    for i, v in ipairs(reportStrData) do
    	getStr(v,_richText)
    end
	return widget
end

-- 统计的页面
local function addSumPage( )
	local armyBattleData = BattlaAnimationData.getArmyInfo()
	local battle_id = BattlaAnimationData.getBattleId()
	local battleReport = reportData.getReport(battle_id)
	local armyTable = {}
	if not reportData.returnAttackOrDefend(battleReport ) then
		for i, v in ipairs({7,6,5}) do
			if armyBattleData[v] then
				table.insert(armyTable, v)
			end
		end
	else
		for i, v in ipairs({2,3,4}) do
			if armyBattleData[v] then
				table.insert(armyTable, v)
			end
		end
	end

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_tongji.json")
	local cell_ = tolua.cast(widget:getChildByName("Panel_item"),"Layout")
	local _height = cell_:getPositionY()
	local fun = function (item,v )
		-- 普通杀伤
		tolua.cast(item:getChildByName("normal_kill"),"Label"):setText(armyBattleData[v].normal_kill)
		-- 技能杀伤
		tolua.cast(item:getChildByName("skill_kill"),"Label"):setText(armyBattleData[v].skill_kill)
		-- 技能释放
		tolua.cast(item:getChildByName("skill_count"),"Label"):setText(armyBattleData[v].skill_count)
		-- 救援
		tolua.cast(item:getChildByName("army_recover"),"Label"):setText(armyBattleData[v].recover)
		-- 损失
		tolua.cast(item:getChildByName("army_loss"),"Label"):setText((armyBattleData[v].army - armyBattleData[v].armyAfter))
		-- 本场伤兵
		tolua.cast(item:getChildByName("army_hurt"),"Label"):setText(armyBattleData[v].this_wounded_soldier)
		-- 总伤兵
		tolua.cast(item:getChildByName("army_total_hurt"),"Label"):setText(armyBattleData[v].wounded_soldier)
	end
	local cell = nil
	local card = nil
	for i, v in ipairs(armyTable) do
		cell = GUIReader:shareReader():widgetFromJsonFile("test/zhanbao_tongji_item.json")
		cell:setPosition(cc.p(cell_:getPositionX() ,_height))
		widget:addChild(cell)

		if armyBattleData[v].level > 0 then
			fun(cell,v)
			card = cardFrameInterface.create_small_card(nil,armyBattleData[v].heroid , false)
			tolua.cast(cell:getChildByName("Panel_icon"),"Layout"):addChild(card)
			cardFrameInterface.set_lv_images(armyBattleData[v].level,card)
		end

		_height = _height - cell_:getSize().height
	end

	return widget
end

-- index 1 战果页面 2 统计页面
function changePage(index )
	if not temp_widget then return end
	local panel = tolua.cast(temp_widget:getChildByName("Panel_main"), "Layout")
	-- panel:removeAllChildrenWithCleanup(true)
	local widget = nil
	if not firstPage and index == 1 then
		firstPage = addResultPage()
		panel:addChild(firstPage)
	elseif not secondPage and index == 2 then
		secondPage = addSumPage()
		panel:addChild(secondPage)
	end

	if index == 1 then
		if firstPage then
			firstPage:setVisible(true)
		end

		if secondPage then
			secondPage:setVisible(false)
		end
	end

	if index == 2 then
		if firstPage then
			firstPage:setVisible(false)
		end

		if secondPage then
			secondPage:setVisible(true)
		end
	end
end

function create( parent)
	if not parent then return end
	if temp_widget then return end
	BattleAnimationController.setCloseBtnVisible(false)
	BattleAnimationController.stopAi()
	BattleAnalyse.remove()

	temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/zhanbaojiesuan_01.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	parent:addWidget(temp_widget)

	local color_layer = cc.LayerColor:create(cc.c4b(14, 17, 24, 150), config.getWinSize().width, config.getWinSize().height)
	color_layer:ignoreAnchorPointForPosition(false)
	color_layer:setAnchorPoint(cc.p(0.5,0.5))
	color_layer:setScale(1/config.getgScale())
	temp_widget:addChild(color_layer,-1)
	color_layer:setPosition(cc.p(temp_widget:getSize().width*0.5, temp_widget:getSize().height*0.5))

	--关闭按钮
	local confirm_close_btn = tolua.cast(temp_widget:getChildByName("return_btn"), "Button")
	confirm_close_btn:setTouchEnabled(true)
	confirm_close_btn:setAnchorPoint(cc.p(1,1))
	local point = temp_widget:convertToNodeSpace(cc.p(config.getWinSize().width, config.getWinSize().height))
	confirm_close_btn:setPosition(point)
	confirm_close_btn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			-- temp_widget:removeFromParentAndCleanup(true)
			BattleAnimationController.remove_self()

			newGuideInfo.enter_next_guide()
		end
	end)

	--回放按钮
	local replay_btn = tolua.cast(temp_widget:getChildByName("replay_btn"), "Button")
	replay_btn:setTouchEnabled(true)
	replay_btn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			BattleAnimationController.resumeBattle()
		end
	end)

	local battle_id = BattlaAnimationData.getBattleId()
	local draw = tolua.cast(temp_widget:getChildByName("result"), "ImageView")
	local battleReport = reportData.getReport(battle_id)
	if reportData.returnAttackOrDefend( battleReport) then
		if battleReport.result == REPORT_RESULT.FALSE then
			draw:loadTexture(ResDefineUtil.animation_battle_result[2], UI_TEX_TYPE_PLIST)
	    --平局 --同归于尽
	    elseif battleReport.result == REPORT_RESULT.PINGJU or battleReport.result == REPORT_RESULT.DRAWfAIL
	    		or battleReport.result == REPORT_RESULT.ALLDIE then
	    	draw:loadTexture(ResDefineUtil.animation_battle_result[1], UI_TEX_TYPE_PLIST)
	    --胜利
	    else
	    	draw:loadTexture(ResDefineUtil.animation_battle_result[3], UI_TEX_TYPE_PLIST)
	    end
	else
		--失败
        if battleReport.result == REPORT_RESULT.FALSE then
        	draw:loadTexture(ResDefineUtil.animation_battle_result[3], UI_TEX_TYPE_PLIST)
    	--平局
    	elseif battleReport.result == REPORT_RESULT.PINGJU or battleReport.result == REPORT_RESULT.DRAWfAIL
	    		or battleReport.result == REPORT_RESULT.ALLDIE then
	    	draw:loadTexture(ResDefineUtil.animation_battle_result[1], UI_TEX_TYPE_PLIST)
    	--胜利
    	else
    		draw:loadTexture(ResDefineUtil.animation_battle_result[2], UI_TEX_TYPE_PLIST)
    	end
	end

	local checkBoxArray = {}
	local checkBox_zhanguo = tolua.cast(temp_widget:getChildByName("CheckBox_831526"),"CheckBox")
	table.insert(checkBoxArray, checkBox_zhanguo)
	local checkBox_sum = tolua.cast(temp_widget:getChildByName("CheckBox_831528"),"CheckBox")
	table.insert(checkBoxArray, checkBox_sum)

	checkBoxArray[1]:setSelectedState(true)
	checkBoxArray[1]:setTouchEnabled(false)
	changePage(1 )

	for i, v in ipairs(checkBoxArray) do
		v:addEventListenerCheckBox(function ( sender, eventType )
			if eventType == CHECKBOX_STATE_EVENT_SELECTED then
				v:setTouchEnabled(false)
				v:setSelectedState(true)
				changePage(i)
				for m,n in ipairs(checkBoxArray) do
					if m ~= i then
						n:setSelectedState(false)
						n:setTouchEnabled(true)
					end
				end
			end
		end)
	end

	newGuideInfo.enter_next_guide()
end