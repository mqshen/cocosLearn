--地表事件详细说明 包括结果
module("GroundEventDescribe", package.seeall)
local m_layer = nil
-- local m_arrLog = nil

local function do_remove_self()
	if m_layer then
		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		m_arrLog = nil
		uiManager.remove_self_panel(uiIndexDefine.GROUND_LOG)
		
		-- Net.send(DEL_ALL_FIELD_EVENT_REPORTS,{})
	end
end

function remove_self()
	-- uiManager.hideScaleEffect(m_layer,999,do_remove_self,nil,0.85)
	uiManager.hideConfigEffect(uiIndexDefine.GROUND_LOG,m_layer,do_remove_self)
end

function create( )
	if m_layer then return end
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/ground_event_log.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local confirm_close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	confirm_close_btn:setTouchEnabled(true)
	confirm_close_btn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)
	m_layer = TouchGroup:create()
    m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.GROUND_LOG)
	uiManager.showConfigEffect(uiIndexDefine.GROUND_LOG,m_layer)
	-- uiManager.showScaleEffect(m_layer,999,nil,uiUtil.uiShowEffectDuration)

	local data = GroundEventData.getWorldEventLog( )
	if not data then return end
	local m_arrLog = {}
	local timeDate = nil
	local day = nil

	for i, v in pairs(data) do
		table.insert( m_arrLog, v )
	end

	table.sort( m_arrLog, function ( a,b )
		return a.time > b.time
	end )

	local scrollView = CCScrollView:create()
	local panel = tolua.cast(temp_widget:getChildByName("Panel_575029"),"Layout")
	local temp_layer = TouchGroup:create()
	temp_layer:setContentSize(CCSizeMake(panel:getSize().width,panel:getSize().height))

	local _richText = RichText:create()
	_richText:setVerticalSpace(4)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(panel:getSize().width, panel:getSize().height))
    temp_layer:addWidget(_richText)
    _richText:setPosition(cc.p(0,panel:getSize().height))

    local re = nil

	local now_day = commonFunc.get_time_by_timestamp(userData.getServerTime())
	local last_day = nil

	local temp_image_panel = nil
	local temp_cell_panel = nil
	local function imageNode(title )
		temp_image_panel = GUIReader:shareReader():widgetFromJsonFile("test/event_cell.json")--image_panel:clone()
		-- temp_image_panel:setVisible(true)
		tolua.cast(temp_image_panel:getChildByName("Label_575030"),"Label"):setText(title)
		return temp_image_panel
	end

	local function desNode( timedata, temp_data)
		temp_cell_panel = GUIReader:shareReader():widgetFromJsonFile("test/event_panel.json")
		temp_cell_panel:setAnchorPoint(cc.p(0,1))
		local temp_panel = tolua.cast(temp_cell_panel:getChildByName("Panel_575033"),"Layout")
		local labelText = tolua.cast(temp_cell_panel:getChildByName("Label_575032"),"Label")

		temp_panel:ignoreAnchorPointForPosition(false)
		temp_panel:setAnchorPoint(cc.p(0,1))
		labelText:setAnchorPoint(cc.p(0,1))

		local hour = timedata.hour
		local min = timedata.min
		if hour < 10 then
			hour = "0"..hour
		end

		if min < 10 then
			min = "0"..min
		end

		labelText:setText(hour..":"..min)
		local _richText_temp = RichText:create()
	    _richText_temp:setAnchorPoint(cc.p(0,1))
	    _richText_temp:ignoreContentAdaptWithSize(false)
	    _richText_temp:setSize(CCSizeMake(temp_panel:getSize().width, temp_panel:getSize().height))
	    temp_panel:addChild(_richText_temp)
	    _richText_temp:setPosition(cc.p(0,temp_panel:getSize().height))

	    local index = 1
	    local arg = {}
	    local reward = stringFunc.anlayerMsg(temp_data.reward)
	    local str = nil
	    if temp_data.event_type == GROUND.FIELD_EVENT_CARD then
	    	arg = {Tb_cfg_hero[temp_data.base_hero_id].name, math.floor(temp_data.wid/10000), temp_data.wid%10000, clientConfigData.getDorpName(reward[1][1])}
	    	str = languagePack["ground_event_card_log"]
	    elseif temp_data.event_type == GROUND.FIELD_EVENT_EXP then
	    	arg = {Tb_cfg_hero[temp_data.base_hero_id].name, math.floor(temp_data.wid/10000), temp_data.wid%10000, clientConfigData.getDorpCount(reward[1][1], reward[1][2] ),clientConfigData.getDorpName(reward[1][1])}
	    	str = languagePack["ground_event_exp_log"]
	    elseif temp_data.event_type == GROUND.FIELD_EVENT_THIEF then
	    	if temp_data.win == 1 then
	    		arg = {Tb_cfg_hero[temp_data.base_hero_id].name, math.floor(temp_data.wid/10000), temp_data.wid%10000, clientConfigData.getDorpCount(reward[1][1], reward[1][2] ),clientConfigData.getDorpName(reward[1][1])}
	    		str = languagePack["ground_event_thief_log_win"]
	    	else
	    		arg = {Tb_cfg_hero[temp_data.base_hero_id].name, math.floor(temp_data.wid/10000), temp_data.wid%10000}
	    		str = languagePack["ground_event_thief_log_lose"]
	    	end
	    end

	    local tempStr = string.gsub(str, "&", function (n)
	    	temp = arg[index]
	    	index = index + 1
	    	return temp or "&"
	    end)
	    local tStr = config.richText_split(tempStr)
	    local re1 = nil
	    for i,v in ipairs(tStr) do
	    	if v[1] == 1 then
		    	re1 = RichElementText:create(i, ccc3(255,255,255), 255, v[2],config.getFontName(), 20)
			else
				re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
			end
			_richText_temp:pushBackElement(re1)
		end
	    -- local re1 = RichElementText:create(1, ccc3(255,255,255), 255, "",config.getFontName(), 20)
	    -- _richText_temp:pushBackElement(re1)
	    _richText_temp:formatText()
	    
	    temp_cell_panel:setSize(CCSizeMake(temp_cell_panel:getSize().width, _richText_temp:getRealHeight()))

		labelText:setPosition(cc.p(labelText:getPositionX(),_richText_temp:getRealHeight()))
		temp_panel:setPosition(cc.p(temp_panel:getPositionX(),_richText_temp:getRealHeight()))
		return temp_cell_panel
	end

	for i, v in ipairs(m_arrLog) do
		timeDate = commonFunc.get_time_by_timestamp(v.time)
		if not last_day or last_day ~= timeDate.month*100 + timeDate.day then
			last_day = timeDate.month*100 + timeDate.day
			if now_day.month*100 + now_day.day == timeDate.month*100 + timeDate.day then
    			re = RichElementCustomNode:create(1, ccc3(255,255,255), 255, imageNode(languagePack["jintian"] ))
			elseif now_day.month*100 + now_day.day - (timeDate.month*100 + timeDate.day) == 1 then
				re = RichElementCustomNode:create(1, ccc3(255,255,255), 255, imageNode(languagePack["zuotian"] ))
			else
				re = RichElementCustomNode:create(1, ccc3(255,255,255), 255, imageNode(timeDate.month..languagePack["yue"]..timeDate.day..languagePack["ri"] ))
			end
			_richText:pushBackElement(re)
		end
		re = RichElementCustomNode:create(1, ccc3(255,255,255), 255, desNode(timeDate,v))
		_richText:pushBackElement(re)
	end
	_richText:formatText()
    temp_layer:setContentSize(CCSizeMake(temp_layer:getContentSize().width,_richText:getRealHeight()))
    _richText:setPositionY(_richText:getRealHeight())

    local function scrollViewDidScroll( )
        
    end
    tolua.cast(temp_widget:getChildByName("ImageView_372344_0"),"ImageView" ):setVisible(false)
    tolua.cast(temp_widget:getChildByName("ImageView_579271"),"ImageView" ):setVisible(false)

	if nil ~= scrollView then
        scrollView:registerScriptHandler(function ( )
        	if scrollView:getContentOffset().y < 0 then
            	tolua.cast(temp_widget:getChildByName("ImageView_579271"),"ImageView" ):setVisible(true)
	        else
	            tolua.cast(temp_widget:getChildByName("ImageView_579271"),"ImageView" ):setVisible(false)
	        end

	        if scrollView:getContentSize().height + scrollView:getContentOffset().y > 1+scrollView:getViewSize().height then
	            tolua.cast(temp_widget:getChildByName("ImageView_372344_0"),"ImageView" ):setVisible(true)
	        else
	            tolua.cast(temp_widget:getChildByName("ImageView_372344_0"),"ImageView" ):setVisible(false)
	        end
        end,CCScrollView.kScrollViewScroll)
        scrollView:setViewSize(CCSizeMake(panel:getSize().width,panel:getSize().height))
        scrollView:setContainer(temp_layer)
        scrollView:updateInset()
        scrollView:setDirection(kCCScrollViewDirectionVertical)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(false)
        scrollView:setContentOffset(cc.p(0,temp_layer:getContentSize().height))
        panel:addChild(scrollView)
    end
end

function dealwithTouchEvent(x,y)
	if not m_layer then
		return false
	end

	local temp_widget = m_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end