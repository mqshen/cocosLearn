local m_exchange_layer = nil
local m_city_id = nil 		--部队所在城市ID

local function do_remove_self()
	exchangeAssistManager.remove_self()
	m_city_id = nil

	m_exchange_layer:removeFromParentAndCleanup(true)
	m_exchange_layer = nil

	uiManager.remove_self_panel(uiIndexDefine.ARMY_EXCHANGE_UI)

	UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyExchangeManager.dealWithHeroUpdate)

	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.add, armyExchangeManager.dealWithArmyAdd)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, armyExchangeManager.dealWithArmyUpdate)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.remove, armyExchangeManager.dealWithArmyRemove)

	UIUpdateManager.remove_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, armyExchangeManager.dealWithEffectUpdate)
end

local function remove_self()
	if m_exchange_layer then
		uiManager.hideConfigEffect(uiIndexDefine.ARMY_EXCHANGE_UI, m_exchange_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x, y)
	if not m_exchange_layer then
		return false
	end

	local temp_widget = m_exchange_layer:getWidgetByTag(999)
	local bg_img = tolua.cast(temp_widget:getChildByName("bg_img"), "ImageView")
	local return_btn = tolua.cast(temp_widget:getChildByName("return_btn"), "Button")
	if bg_img:hitTest(cc.p(x, y)) or return_btn:hitTest(cc.p(x, y)) then
		return false
	else
		return true
	end
end

local function deal_with_return_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function deal_with_hzb_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local army_index = tonumber(string.sub(sender:getParent():getParent():getName(), 6))
		local army_nums = buildData.get_army_param_info(m_city_id)
		if army_index > army_nums then
			tipsLayer.create(errorTable[179])
		else
			require("game/army/armyAdditionManager")
			armyAdditionManager.enter_addition_by_army(m_city_id*10 + army_index)
		end
	end
end

local function init_show_widget(bg_img)
	local army_base_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyExchangeCell.json")
	local hero_base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
	local army_widget, title_panel, index_img, index_txt, hzb_btn = nil, nil, nil, nil, nil
	local unopen_index_txt, unopen_tips_txt = nil, nil
	local hero_panel, hero_img, hero_widget = nil, nil, nil
	local start_pos_x, start_pos_y = 22, 485
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		army_widget = army_base_widget:clone()
		army_widget:setName("army_" .. i)
		
		title_panel = tolua.cast(army_widget:getChildByName("title_panel"), "Layout")
		index_img = tolua.cast(title_panel:getChildByName("index_img"), "ImageView")
		index_txt = tolua.cast(index_img:getChildByName("num_label"), "Label")
		index_txt:setText(i)
		hzb_btn = tolua.cast(title_panel:getChildByName("hzb_btn"), "Button")
		hzb_btn:addTouchEventListener(deal_with_hzb_click)
		hzb_btn:setTouchEnabled(true)

		for j=1,3 do
			hero_panel = tolua.cast(army_widget:getChildByName("hero_" .. j), "Layout")
			hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
			hero_widget = hero_base_widget:clone()
			hero_widget:ignoreAnchorPointForPosition(false)
			hero_widget:setAnchorPoint(cc.p(0.5,0.5))
			hero_widget:setName("hero_widget")
			hero_img:addChild(hero_widget)
		end

		unopen_index_txt = tolua.cast(army_widget:getChildByName("index_label"), "Label")
		unopen_index_txt:setText(languagePack["budui"] .. numOrderList[i])
		unopen_tips_txt = tolua.cast(army_widget:getChildByName("unopen_label"), "Label")
		unopen_tips_txt:setText(Tb_cfg_build[cityBuildDefine.jiaochang].name .. "Lv." .. i .. languagePack["kaifang"])

		army_widget:setPosition(cc.p(start_pos_x, start_pos_y - (i-1) * 114))
		bg_img:addChild(army_widget)
	end
end

local function set_layout(temp_widget, scene_width, scene_height)
	local scale_value = config.getgScale()
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	--title_img:ignoreAnchorPointForPosition(false)
	--title_img:setAnchorPoint(cc.p(0,1))
	title_img:setPosition(cc.p(20, scene_height))
	title_img:setScale(scale_value)

	local return_btn = tolua.cast(temp_widget:getChildByName("return_btn"), "Button")
	return_btn:setPosition(cc.p(scene_width, scene_height))
	return_btn:addTouchEventListener(deal_with_return_click)
	return_btn:setTouchEnabled(true)
	return_btn:setScale(scale_value)

	local bg_img = tolua.cast(temp_widget:getChildByName("bg_img"), "ImageView")
	bg_img:setPosition(cc.p(scene_width/2 - scale_value * bg_img:getSize().width/2, scene_height/2 - scale_value * bg_img:getSize().height/2 - 10))
	init_show_widget(bg_img)
	bg_img:setScale(scale_value)
end

local function create()
	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyExchangeUI.json")
	temp_widget:setTag(999)
	temp_widget:setSize(CCSizeMake(scene_width, scene_height))
	temp_widget:setTouchEnabled(true)
	--temp_widget:setScale(config.getgScale())
	--temp_widget:ignoreAnchorPointForPosition(false)
	--temp_widget:setAnchorPoint(cc.p(0,0))
	--temp_widget:setPosition(cc.p(0, 0))

	set_layout(temp_widget, scene_width, scene_height)
 
	m_exchange_layer = TouchGroup:create()
	m_exchange_layer:addWidget(temp_widget)

    uiManager.add_panel_to_layer(m_exchange_layer, uiIndexDefine.ARMY_EXCHANGE_UI)
    uiManager.showConfigEffect(uiIndexDefine.ARMY_EXCHANGE_UI, m_exchange_layer)
end

local function on_enter(city_id)
	if m_exchange_layer then
		return
	end

	m_city_id = city_id
	create()

	require("game/army/armyExchange/exchangeAssistManager")
	local temp_widget = m_exchange_layer:getWidgetByTag(999)
	exchangeAssistManager.create(temp_widget, m_city_id)

	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyExchangeManager.dealWithHeroUpdate)

	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.add, armyExchangeManager.dealWithArmyAdd)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, armyExchangeManager.dealWithArmyUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.remove, armyExchangeManager.dealWithArmyRemove)

	UIUpdateManager.add_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, armyExchangeManager.dealWithEffectUpdate)
end

local function dealWithHeroUpdate(packet)
	local hero_info = heroData.getHeroInfo(packet.heroid_u)
	if hero_info and math.floor(hero_info.armyid/10) == m_city_id then
		exchangeAssistManager.deal_with_content_update()
	end
end

local function dealWithArmyChange(temp_army_id)
	if math.floor(temp_army_id/10) == m_city_id then
		exchangeAssistManager.deal_with_content_update()
	end
end

local function dealWithArmyAdd(packet)
	dealWithArmyChange(packet.armyid)
end

local function dealWithArmyUpdate(packet)
	dealWithArmyChange(packet.armyid)
end

local function dealWithArmyRemove(packet)
	dealWithArmyChange(packet)
end

local function dealWithEffectUpdate(packet)
	if packet.city_wid == m_city_id then
		if packet.army_pos_front ~= nil or packet.army_max ~= nil then
			exchangeAssistManager.deal_with_content_update()
		end
	end
end

armyExchangeManager = {
						on_enter = on_enter,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						dealWithHeroUpdate = dealWithHeroUpdate,
						dealWithArmyAdd = dealWithArmyAdd,
						dealWithArmyUpdate = dealWithArmyUpdate,
						dealWithArmyRemove = dealWithArmyRemove,
						dealWithEffectUpdate = dealWithEffectUpdate
}