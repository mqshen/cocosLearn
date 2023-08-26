-- gameSpriteQuestion.lua
module("GameSpriteQuestion", package.seeall)

local isInit = false
local mTableView = nil
local default_fontSize = 20

function remove( )
	isInit = nil
	mTableView = nil

end

local function tableCellTouched( )
	-- body
end

local function numberOfCellsInTableView( )
	return #GameSpriteMgr.getAllQuestionData()
end

local function cellSizeForTable(table,idx)
	-- print(">>>>>>>>>>>>>>>>>>width="..GameSpriteMgr.getQuestionData(idx+1)[3])
	if GameSpriteMgr.getQuestionData(idx+1) then
		return GameSpriteMgr.getQuestionData(idx+1)[3]+15, 911
	else
		return 93,911
	end
end

local function tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
    if nil == cell then
    	cell = CCTableViewCell:new()
    end
    	cell:removeAllChildrenWithCleanup(true)
    	local layer = TouchGroup:create()
		local m_pWidget = nil
		local question = GameSpriteMgr.getQuestionData(idx+1)
		if question[1] == 1 then
			m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/sprite_ask_item.json")
		elseif question[1] == -1 or question[1] == 99 or question[1] == -99  then
			m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/sol_item.json")
		else
			m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/sprite_question_item.json")
		end

		-- 表示是自己的提问或者回答
		if question[1] == 1 or question[1] == 0 then
			m_pWidget:setSize(CCSizeMake(m_pWidget:getSize().width, 10+GameSpriteMgr.getQuestionData(idx+1)[3]))
			local ImageView_panel = tolua.cast(m_pWidget:getChildByName("ImageView_panel"),"ImageView")
			ImageView_panel:setSize(CCSizeMake(ImageView_panel:getSize().width, 10+GameSpriteMgr.getQuestionData(idx+1)[3]))

			ImageView_panel:setPositionY(m_pWidget:getSize().height)

			if question[1] == 0 then
				local icon = tolua.cast(m_pWidget:getChildByName("ImageView_232545_wenda_3"),"ImageView")
				icon:setPositionY(m_pWidget:getSize().height-icon:getSize().height/2)
			end


			local _richText = RichText:create()
			_richText:setVerticalSpace(2)
			_richText:setAnchorPoint(cc.p(0,1))
			_richText:ignoreContentAdaptWithSize(false)
			_richText:setSize(CCSizeMake(ImageView_panel:getSize().width-10, 2))
			ImageView_panel:addChild(_richText)
			_richText:setPosition(cc.p(10, -5))
			local re1 = nil
			for i, v in ipairs(question[2]) do
				if v[1] ~= "mbutton" then
				    if v[1] == "r" then
				        re1 = RichElementText:create(i, ccc3(216,201,162), 255, "\n",config.getFontName(), default_fontSize)
				        _richText:pushBackElement(re1)
				        re1 = RichElementText:create(i, ccc3(216,201,162), 255, v[2],config.getFontName(), default_fontSize)
				    elseif v[1] == "R" then
				    	re1 = RichElementText:create(i, ccc3(255,0,0), 255, v[2],config.getFontName(), default_fontSize)
				    elseif v[1] == "B" then
				    	re1 = RichElementText:create(i, ccc3(0,0,255), 255, v[2],config.getFontName(), default_fontSize)
				    -- 普通需要变色的字
				    elseif v[1] ~= "" and v[1] ~= "n" then
				    	re1 = RichElementText:create(i, ccc3(188,216,168), 255, v[2],config.getFontName(), default_fontSize)
				    else
				        re1 = RichElementText:create(i, ccc3(216,201,162), 255, v[2],config.getFontName(), default_fontSize)
				    end
				    _richText:pushBackElement(re1)
				else
					first = true
				end
			end

			_richText:formatText()


			-- 提问还要设置底板宽度
			if question[1] == 1 then
				local temp = Label:create()
				temp:setText(question[2][1][2])
				temp:setFontSize(default_fontSize)
				ImageView_panel:setSize(CCSizeMake(temp:getSize().width+20, ImageView_panel:getSize().height)) 
				ImageView_panel:setPositionX(m_pWidget:getSize().width- ImageView_panel:getSize().width)
			end

			local labelStr = ""
			local temp_width = GameSpriteMgr.getWidthSpace()
			local temp_height = -_richText:getRealHeight()-GameSpriteMgr.getHeightSpace()
			local _width = GameSpriteMgr.getWidthSpace()
			local askLabel = nil
			local askLine = nil
			local first = false
			for i, v in ipairs(question[2]) do
				if v[1] == "mbutton" then
					if not first then
						first = true
						re1 = ImageView:create()
						re1:loadTexture(ResDefineUtil.under_line,UI_TEX_TYPE_PLIST)
						re1:setSize(CCSizeMake(ImageView_panel:getSize().width-40,5))
						re1:setAnchorPoint(cc.p(0,0.5))
						ImageView_panel:addChild(re1)
						re1:setScale9Enabled(true)
						re1:setCapInsets(CCRect(0,0,0,0))
						temp_height = temp_height - GameSpriteMgr.getHeightSpace()
						re1:setPosition(cc.p(temp_width, temp_height))
						temp_height = temp_height - GameSpriteMgr.getHeightSpace() - re1:getSize().height
					end
					askLabel = Label:create()
					askLabel:setFontSize(20)
					askLabel:setColor(ccc3(188,216,168))
					local pos =string.find(v[2],"%$")
					if pos then
						labelStr = string.sub(v[2], 1, pos-1)
					else
						labelStr = v[2]
					end
					
					askLabel:setText(labelStr)
					askLabel:setTouchEnabled(true)
					askLabel:addTouchEventListener(function ( sender, eventType )
						if eventType == TOUCH_EVENT_ENDED then
							GameSpriteMgr.sendQuestion(sender:getStringValue())
	    					GameSpriteMgr.writeQuestion(sender:getStringValue())
		        		end
					end)

					askLine = CCDrawNode:create()
					askLine:drawSegment(cc.p(0,0), ccp(askLabel:getSize().width,0), 0.5, ccc4f(188/255,216/255,168/255,0.5))
					askLabel:addChild(askLine)
					askLine:setPositionY(-askLabel:getSize().height)

					ImageView_panel:addChild(askLabel)
					askLabel:setAnchorPoint(cc.p(0,1))
					temp_width = temp_width + askLabel:getSize().width + GameSpriteMgr.getWidthSpace()
					if temp_width > _richText:getSize().width then
						temp_width = GameSpriteMgr.getWidthSpace()
						_width = temp_width
						temp_height = temp_height - askLabel:getSize().height-GameSpriteMgr.getHeightSpace()
					end

					askLabel:setPosition(cc.p(_width, temp_height))
					if temp_width == GameSpriteMgr.getWidthSpace() then
						temp_width = temp_width + askLabel:getSize().width + GameSpriteMgr.getWidthSpace()
					end

					if pos then
						temp_width = GameSpriteMgr.getWidthSpace()
						temp_height = temp_height - askLabel:getSize().height-GameSpriteMgr.getHeightSpace()
					end
					_width = temp_width
				end
			end
		else
			local Panel_btn = tolua.cast(m_pWidget:getChildByName("Panel_btn"),"Layout")
			local Label_sol = tolua.cast(m_pWidget:getChildByName("Label_sol"),"Layout")
			Label_sol:setVisible(false)
			local Label_unsol = tolua.cast(m_pWidget:getChildByName("Label_unsol"),"Layout")
			Label_unsol:setVisible(false)

			local sol_btn = tolua.cast(Panel_btn:getChildByName("sol_btn"),"Button")
			sol_btn:setTouchEnabled(false)
			sol_btn:setVisible(false)

			local unsol_btn = tolua.cast(Panel_btn:getChildByName("unsol_btn"),"Button")
			unsol_btn:setTouchEnabled(false)
			unsol_btn:setVisible(false)

			if question[1] == -1 then
				sol_btn:setTouchEnabled(true)
				sol_btn:setVisible(true)

				unsol_btn:setTouchEnabled(true)
				unsol_btn:setVisible(true)
				sol_btn:addTouchEventListener(function ( sender, eventType)
					if eventType == TOUCH_EVENT_ENDED then
						GameSpriteMgr.sendJudge(1,idx+1 )
						Panel_btn:setEnabled(false)
						Label_sol:setVisible(true)
		        	end
				end)

				unsol_btn:addTouchEventListener(function ( sender, eventType)
					if eventType == TOUCH_EVENT_ENDED then
						GameSpriteMgr.sendJudge(0,idx+1 )
						Panel_btn:setEnabled(false)
						Label_unsol:setVisible(true)
		        	end
				end)
			elseif question[1] == 99 then
				Panel_btn:setVisible(false)
				Label_sol:setVisible(true)
			else
				Panel_btn:setVisible(false)
				Label_unsol:setVisible(true)
			end


		end
		layer:addWidget(m_pWidget)
		cell:addChild(layer)

    return cell
end

function create(widget )
	if not isInit then
		isInit = true
		local panel = tolua.cast(widget:getChildByName("Panel_back"),"Layout")
		mTableView = CCTableView:create(true, CCSizeMake(panel:getSize().width,panel:getSize().height))
	    mTableView:setDirection(kCCScrollViewDirectionVertical)
		mTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
		-- mTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	    mTableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	    mTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	    mTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	    mTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

	    panel:addChild(mTableView)
	    mTableView:reloadData()
	end
end

function reloadData( )
	if mTableView then
		mTableView:reloadData()
		if mTableView:getContentOffset().y > 0 then
		else
			mTableView:setContentOffset(cc.p(0,0))
		end
	end
end