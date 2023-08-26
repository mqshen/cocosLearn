local m_layer = nil

local m_hero_id = nil 		--要移动的武将ID
local m_callfun = nil 		--点击确定的回调函数

local function do_remove_self()
	if m_layer then
		m_hero_id = nil
		m_callfun = nil

		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.SOLDIER_DISSOLVE_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.SOLDIER_DISSOLVE_UI, m_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
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

local function deal_with_cancel_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function deal_with_confirm_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		sender:setTouchEnabled(false)

		if m_callfun then
			m_callfun()
		end

		remove_self()
	end
end

local function init_res_content(temp_widget)
	local res_panel = tolua.cast(temp_widget:getChildByName("res_panel"), "Layout")
	local hero_info = heroData.getHeroInfo(m_hero_id)
	local dissolve_num = hero_info.hp - HERO_HP_INIT_IN_ARMY

	local basic_hero_info = Tb_cfg_hero[hero_info.heroid]
	local res_con, num_txt = nil, nil
	for k,v in pairs(basic_hero_info.recruit_cost) do
		res_con = tolua.cast(res_panel:getChildByName("res_" .. v[1]), "Layout") 
		num_txt = tolua.cast(res_con:getChildByName("num_label"), "Label")
		local show_num = math.floor(v[2] * dissolve_num * HERO_HP_RETURN_RES_RATIO/100)
		num_txt:setText(show_num)
    end
end

local function init_event(temp_widget)
	local cancel_btn = tolua.cast(temp_widget:getChildByName("cancel_btn"), "Button")
	cancel_btn:setTouchEnabled(true)
	cancel_btn:addTouchEventListener(deal_with_cancel_click)

	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"), "Button")
	confirm_btn:setTouchEnabled(true)
	confirm_btn:addTouchEventListener(deal_with_confirm_click)
end

local function create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/soldierDissolveUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_res_content(temp_widget)
	init_event(temp_widget)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.SOLDIER_DISSOLVE_UI)
	uiManager.showConfigEffect(uiIndexDefine.SOLDIER_DISSOLVE_UI, m_layer)
end

local function on_enter(temp_hero_id, temp_callfun)
	m_hero_id = temp_hero_id
	m_callfun = temp_callfun

	create()
end

soldierDissolveManager = {
						on_enter = on_enter,
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent

}