module("PayUI", package.seeall)
local main_layer = nil
local m_idx = nil
local m_x, m_y = nil, nil

local mTableView = nil

local yuekaLeftTimeHandler = nil

local function removeHandler( )
	if yuekaLeftTimeHandler then
		scheduler.remove(yuekaLeftTimeHandler)
		yuekaLeftTimeHandler = nil
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

local function scrollViewDidScroll(table)
	local temp_widget = main_layer:getWidgetByTag(999)
	if table:getContentOffset().y < 0 then
		tolua.cast(temp_widget:getChildByName("ImageView_372346_0"),"ImageView" ):setVisible(true)
	else
		tolua.cast(temp_widget:getChildByName("ImageView_372346_0"),"ImageView" ):setVisible(false)
	end

	if table:getContentSize().height + table:getContentOffset().y >1+table:getViewSize().height then
		tolua.cast(temp_widget:getChildByName("ImageView_1091966"),"ImageView" ):setVisible(true)
	else
		tolua.cast(temp_widget:getChildByName("ImageView_1091966"),"ImageView" ):setVisible(false)
	end
end

local function refreshCell(table,idx )
	-- if idx and table:cellAtIndex(idx) then
	local realIdx = 0
	if idx%2 == 0 then
		realIdx = idx/2
	else
		realIdx = math.floor(idx/2)+1
	end
	if not table:cellAtIndex(realIdx-1) or not table:cellAtIndex(realIdx-1):getChildByTag(123) then
		return
	end

	local layer = tolua.cast(table:cellAtIndex(realIdx-1):getChildByTag(123),"TouchGroup")
	if layer then
		if layer:getWidgetByTag(1) then
			local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
	     	local first_item = tolua.cast(item_panel:getChildByName("Panel_first"),"Layout")
	        local sec_item = tolua.cast(item_panel:getChildByName("Panel_second"),"Layout")

	        local first_goods = first_item:getChildByTag(321)
	        local sec_goods = sec_item:getChildByTag(321)
	        if first_goods then
	        	tolua.cast(first_goods:getChildByName("select_image"),"ImageView"):setVisible(false)
	        end

	        if sec_goods then
	        	tolua.cast(sec_goods:getChildByName("select_image"),"ImageView"):setVisible(false)
	        end
		end
	end
	-- end
end

local function setSelectStatus( table,cell,flag )
	local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	if layer:getWidgetByTag(1) then
    		local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
	        local first_item = tolua.cast(item_panel:getChildByName("Panel_first"),"Layout")
	        local sec_item = tolua.cast(item_panel:getChildByName("Panel_second"),"Layout")
	        local data_first = PayData.getGoodsDataByIndex(2*(cell:getIdx()+1)-1)
			local data_second = PayData.getGoodsDataByIndex(2*(cell:getIdx()+1))

	        local first_goods = first_item:getChildByTag(321)
	        local sec_goods = sec_item:getChildByTag(321)

			if (not sec_item:hitTest(cc.p(m_x, m_y)) and not first_item:hitTest(cc.p(m_x, m_y))) or (not data_second and sec_item:hitTest(cc.p(m_x, m_y))) then
				return
			end

	        if first_goods and tolua.cast(first_goods,"Layout"):hitTest(cc.p(m_x, m_y)) then
	        	tolua.cast(first_goods:getChildByName("select_image"),"ImageView"):setVisible(flag)
	        end

	        if sec_goods and tolua.cast(sec_goods,"Layout"):hitTest(cc.p(m_x, m_y)) then
	        	tolua.cast(sec_goods:getChildByName("select_image"),"ImageView"):setVisible(flag)
	        end
    	end
    end
end

local function tableCellHighlight( table,cell )
	setSelectStatus( table,cell,true )
end

local function tableCellUnhighlight( table,cell)
	setSelectStatus( table,cell,false )
end

local function tableCellTouched(table,cell  )
	-- m_idx = cell:getIdx()
    -- local widx, widy =math.floor(npcTable[m_idx+1]/10000), npcTable[m_idx+1]%10000
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	if layer:getWidgetByTag(1) then
    		local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
	        local first_item = tolua.cast(item_panel:getChildByName("Panel_first"),"Layout")
	        local sec_item = tolua.cast(item_panel:getChildByName("Panel_second"),"Layout")


	        local first_goods = first_item:getChildByTag(321)
	        local sec_goods = sec_item:getChildByTag(321)
	        local data_first = PayData.getGoodsDataByIndex(2*(cell:getIdx()+1)-1)
			local data_second = PayData.getGoodsDataByIndex(2*(cell:getIdx()+1))

			if (not sec_item:hitTest(cc.p(m_x, m_y)) and not first_item:hitTest(cc.p(m_x, m_y))) or (not data_second and sec_item:hitTest(cc.p(m_x, m_y))) then
				return
			end

			-- refreshCell(table,m_idx )
	        if first_goods and tolua.cast(first_goods,"Layout"):hitTest(cc.p(m_x, m_y)) then
	        	m_idx = 2*(cell:getIdx()+1)-1
	        	-- tolua.cast(first_goods:getChildByName("select_image"),"ImageView"):setVisible(true)
	        	if data_first then
	        		if data_first.good_id == PayData.getYueka() and userData.isHasYueka() then
	        			tipsLayer.create(languagePack['payagain'])
	        		else
	        			PayData.regProduct( data_first.good_id, Tb_cfg_goods[data_first.good_id].name, Tb_cfg_goods[data_first.good_id].rmb)
	        		end
	        	end
	        end

	        if sec_goods and tolua.cast(sec_goods,"Layout"):hitTest(cc.p(m_x, m_y)) then
	        	m_idx = 2*(cell:getIdx()+1)
	        	-- tolua.cast(sec_goods:getChildByName("select_image"),"ImageView"):setVisible(true)
	        	if data_second then
	        		if data_second.good_id == PayData.getYueka() and userData.isHasYueka() then
	        			tipsLayer.create(languagePack['payagain'])
	        		else
	        			PayData.regProduct( data_second.good_id, Tb_cfg_goods[data_second.good_id].name, Tb_cfg_goods[data_second.good_id].rmb)
	        		end
	        	end
	        end
    	end
    end
end

local function cellSizeForTable( )
	return 135,810
end

local function initCell(first_goods,data_first)
	local price = nil
	local gold = nil
	local id = nil
	local dec = nil
	price = tolua.cast(first_goods:getChildByName("Label_price"),"Label")
    price:setText(Tb_cfg_goods[data_first.good_id].rmb/100)
    gold = tolua.cast(first_goods:getChildByName("ImageView_gold"),"ImageView")
    id = tolua.cast(first_goods:getChildByName("Label_id"),"Label")
    dec = tolua.cast(first_goods:getChildByName("Label_dec"),"Label")
    -- 推荐的标示
    local special = tolua.cast(first_goods:getChildByName("ImageView_spe"),"ImageView")
    special:setVisible(false)

    -- 月卡有效期的文字
    local Label_left_time_dec = tolua.cast(first_goods:getChildByName("Label_left_time_dec"),"Label")
    Label_left_time_dec:setVisible(false)

    -- 月卡有效期倒计时
    local Label_time = tolua.cast(first_goods:getChildByName("Label_time"),"Label")
    Label_time:setVisible(false)

    --底图
    local ImageView_img = tolua.cast(first_goods:getChildByName("ImageView_img"),"ImageView")
    ImageView_img:loadTexture(Tb_cfg_goods[data_first.good_id].img, UI_TEX_TYPE_PLIST)
    
    local user_stuff = allTableData[dbTableDesList.user_stuff.name][userData.getUserId()]
    local goods = stringFunc.anlayerMsg(user_stuff.goods_bought)
    local temp_goods = {}
    -- config.dump(goods)
    for i, v in pairs(goods) do
    	temp_goods[v[1]] = v[2]
    end

    -- config.dump(temp_goods)

    if data_first.good_id ~= PayData.getYueka() then
    	id:setText(Tb_cfg_goods[data_first.good_id].rmb/100*10)
    	gold:setVisible(true)
    	gold:setPositionX(id:getPositionX()+id:getSize().width+20)
    	local count = nil
    	-- if Tb_cfg_goods[data_first.good_id].first_bonus == 0 then
    	if not temp_goods[data_first.good_id] or temp_goods[data_first.good_id] == 0 then
    		count = Tb_cfg_goods[data_first.good_id].yuan_bao_count+Tb_cfg_goods[data_first.good_id].first_bonus-Tb_cfg_goods[data_first.good_id].rmb/10
    		if Tb_cfg_goods[data_first.good_id].first_bonus ~= 0 then
    			special:setVisible(true)
    		end
    	else
    		count = Tb_cfg_goods[data_first.good_id].yuan_bao_count-Tb_cfg_goods[data_first.good_id].rmb/10
    	end
    	if count == 0 then
    		dec:setText(" ")
    	else
    		if (not temp_goods[data_first.good_id] or temp_goods[data_first.good_id] == 0) and Tb_cfg_goods[data_first.good_id].first_bonus ~= 0 then
    			dec:setText(languagePack['extra_bonus']..count..languagePack['jin'].."（"..languagePack['xiangou'].."1"..languagePack['cishu'].."）")
    		else
    			dec:setText(languagePack['extra_bonus']..count..languagePack['jin'])
    		end
    	end
    else
    	if userData.isHasYueka() then
    		Label_left_time_dec:setVisible(true)
    		Label_time:setVisible(true)
    		Label_time:setText(commonFunc.format_time(userData.getYuekaLeftTime()))
    	end
    	id:setText(Tb_cfg_goods[data_first.good_id].name)
    	gold:setVisible(false)
    	dec:setText(Tb_cfg_goods[data_first.good_id].description)
    	special:setVisible(true)
    end
end

local function tableCellAtIndex(table, idx)
	local cell = table:dequeueCell()
    if nil == cell then
    	cell = CCTableViewCell:new()
    	local layer = TouchGroup:create()
    	local widget = nil
		widget = GUIReader:shareReader():widgetFromJsonFile("test/pay_big_cell.json")
	    tolua.cast(widget,"Layout")
	    layer:addWidget(widget)
	    widget:setTag(1)
	    cell:addChild(layer)
	    layer:setTag(123)
	    local first = GUIReader:shareReader():widgetFromJsonFile("test/pay_cell.json")
	    first:setTag(321)
	    tolua.cast(widget:getChildByName("Panel_first"),"Layout"):addChild(first)
	    local sec = GUIReader:shareReader():widgetFromJsonFile("test/pay_cell.json")
	    sec:setTag(321)
	    tolua.cast(widget:getChildByName("Panel_second"),"Layout"):addChild(sec)
    end
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	local data_first = nil
    	local data_second = nil
    	local first_item = nil
    	local sec_item = nil
    	local widget = layer:getWidgetByTag(1)
    	local price = nil
		local gold = nil
		local id = nil
		local dec = nil
    	if widget then
    		data_first = PayData.getGoodsDataByIndex(2*(idx+1)-1)
    		first_item = tolua.cast(widget:getChildByName("Panel_first"),"Layout")
    		local first_goods = nil
    		if data_first then
    			first_goods = first_item:getChildByTag(321)
    			if first_goods then
    				tolua.cast(first_goods,"Layout")
    				-- if 2*(idx+1)-1 == m_idx then
    				-- 	tolua.cast(first_goods:getChildByName("select_image"),"ImageView"):setVisible(true)
    				-- else
    				-- 	tolua.cast(first_goods:getChildByName("select_image"),"ImageView"):setVisible(false)
    				-- end
    				initCell(first_goods,data_first)
    			end
    		else
    			first_item:removeAllChildrenWithCleanup(true)
    		end

    		data_second = PayData.getGoodsDataByIndex(2*(idx+1))
    		sec_item = tolua.cast(widget:getChildByName("Panel_second"),"Layout")

    		local sec_goods = nil
    		if data_second then
    			sec_goods = sec_item:getChildByTag(321)
    			if not sec_goods then
    				local sec = GUIReader:shareReader():widgetFromJsonFile("test/pay_cell.json")
	    			sec:setTag(321)
	    			sec_item:addChild(sec)
	    			sec_goods = sec
    			end

    			if sec_goods then
    				tolua.cast(sec_goods,"Layout")
    				-- if 2*(idx+1) == m_idx then
    				-- 	tolua.cast(sec_goods:getChildByName("select_image"),"ImageView"):setVisible(true)
    				-- else
    				-- 	tolua.cast(sec_goods:getChildByName("select_image"),"ImageView"):setVisible(false)
    				-- end
    				initCell(sec_goods,data_second)
    			end
    		else
	    		sec_item:removeAllChildrenWithCleanup(true)
    		end
    	end
    end
    return cell
end

local function numberOfCellsInTableView(  )
	return PayData.getGoodsCount()
end

function create(  )
	m_idx = 1
	PayData.initUIData()
	if main_layer then 
		remove_self()
	end
	main_layer = TouchGroup:create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/chongzhijiemian.json")
    temp_widget:setTag(999)
    -- temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(0.5,0.5))
    temp_widget:setScale(config.getgScale())
    temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UI_PAY_UI)
	uiManager.showConfigEffect(uiIndexDefine.UI_PAY_UI, main_layer)

	--关闭按钮
    local btn_close = tolua.cast(temp_widget:getChildByName("btn_close"),"Button")
    btn_close:addTouchEventListener(function (sender, eventType  )
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
            -- PayData.regProduct( 1, Tb_cfg_goods[1].name, Tb_cfg_goods[1].rmb, 1)
            -- PayData.requestOrder(1, 1 )
        end
    end)

    local panel = tolua.cast(temp_widget:getChildByName("Panel_root"),"Layout")

    local temp_layer = CCLayer:create()
    temp_layer:setTouchEnabled(true)
    temp_layer:registerScriptTouchHandler(function ( eventType, x,y )
		if eventType == "began" then
	    elseif eventType == "ended" or eventType == "canceled" then
	    end
	    m_x, m_y = x,y
	    return true
	end,false,-1)
    panel:addChild(temp_layer)

    local ImageView_up =  tolua.cast(temp_widget:getChildByName("ImageView_372346_0"),"ImageView" )
    ImageView_up:setVisible(false)
	local ImageView_down =  tolua.cast(temp_widget:getChildByName("ImageView_1091966"),"ImageView" )
	ImageView_down:setVisible(false)

	breathAnimUtil.start_anim(ImageView_down, true, 76, 255, 1, 0)
    breathAnimUtil.start_anim(ImageView_up, true, 76, 255, 1, 0)

    mTableView = CCTableView:create(true, CCSizeMake(panel:getSize().width,panel:getSize().height))
    mTableView:setDirection(kCCScrollViewDirectionVertical)
	mTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	mTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    mTableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    mTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    mTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    mTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
    mTableView:registerScriptHandler(tableCellHighlight,CCTableView.kTableCellHighLight)
    mTableView:registerScriptHandler(tableCellUnhighlight,CCTableView.kTableCellUnhighLight)
	panel:addChild(mTableView)
	mTableView:reloadData()
	scrollViewDidScroll(mTableView)

	if userData.isHasYueka() then
		local cell = nil
		local temp_layer = nil
		local _temp_widget = nil
		local first_item = nil
		local first_goods = nil
		local Label_left_time_dec = nil
		local Label_time = nil
		yuekaLeftTimeHandler=scheduler.create(function ( )
			if not userData.isHasYueka() then
				removeHandler()
				reloadData()
			end
			cell = mTableView:cellAtIndex(0)
			if cell then
				temp_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
				if temp_layer then
					_temp_widget = temp_layer:getWidgetByTag(1)
					if _temp_widget then
						first_item = tolua.cast(_temp_widget:getChildByName("Panel_first"),"Layout")
						if first_item then
							first_goods = first_item:getChildByTag(321)
						    -- 月卡有效期的文字
						    Label_left_time_dec = tolua.cast(first_goods:getChildByName("Label_left_time_dec"),"Label")
						    Label_left_time_dec:setVisible(true)

						    -- 月卡有效期倒计时
						    Label_time = tolua.cast(first_goods:getChildByName("Label_time"),"Label")
						    Label_time:setVisible(true)
						    Label_time:setText(commonFunc.format_time(userData.getYuekaLeftTime()))
						end
					end
				end
			end
		end,1)
	end
end

function reloadData( )
	PayData.initData()
	mTableView:reloadData()
end

local function do_remove_self( )
	if main_layer then
		removeHandler()
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        m_idx = nil
        m_x, m_y = nil, nil
        PayData.removeUIData()
        uiManager.remove_self_panel(uiIndexDefine.UI_PAY_UI)
    end
end

function remove_self(  )
	uiManager.hideConfigEffect(uiIndexDefine.UI_PAY_UI,main_layer,do_remove_self)
end