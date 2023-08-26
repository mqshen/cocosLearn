--同盟势力界面
module("UnionPowerUI", package.seeall)
local m_pMainLayer = nil

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

function remove_self( )
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UNION_POWER_UI)
	end
end

function create(text )
	if m_pMainLayer then return end
	local strText = text
	local unionInfo = UnionData.getUnionInfo()
	m_pMainLayer = TouchGroup:create()
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UNION_POWER_UI)
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Allied_forces_s.json")
	m_pMainLayer:addWidget(widget)
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local closeBtn = tolua.cast(widget:getChildByName("btn_close"),"Button")
	closeBtn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)

	--同盟名字
	tolua.cast(widget:getChildByName("label_left_title_0"),"Label"):setText(unionInfo.name)

	--同盟势力值
	tolua.cast(widget:getChildByName("Label_212337_0_1_3_0_0"),"Label"):setText(unionInfo.power)

	--势力范围
	if unionInfo.region_spread then
		local powerRegion = ""
		for i, v in ipairs(unionInfo.region_spread) do
			if i==1 then
				powerRegion = stateData.getStateNameById(v)
			elseif i==7 or i== 12 then
				powerRegion = powerRegion..stateData.getStateNameById(v)
			else
				powerRegion = powerRegion.."     "..stateData.getStateNameById(v)
			end

			if i==6 or i== 12 then
				powerRegion = powerRegion.."\n"
			end
		end
		tolua.cast(widget:getChildByName("Label_228953"),"Label"):setText(powerRegion)
	end
end