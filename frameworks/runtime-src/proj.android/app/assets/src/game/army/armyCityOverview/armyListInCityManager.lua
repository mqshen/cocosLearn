--进入城市下方显示的部队列表管理
local m_main_widget = nil
local m_city_id = nil

local uiUtil = nil

local function remove()
	m_city_id = nil
	uiUtil = nil

	m_main_widget:removeFromParentAndCleanup(true)
	m_main_widget = nil

	UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyListInCityManager.dealWithHeroUpdate)
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, armyListInCityManager.dealWithArmyUpdate)
	UIUpdateManager.remove_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, armyListInCityManager.dealWithEffectUpdate)
end

local function dealwithTouchEvent(x, y)
	if not m_main_widget then
		return false
	end

	if not m_main_widget:isVisible() then
		return false
	end

	return m_main_widget:hitTest(cc.p(x, y))
end

local function enter_army_by_index(new_index)
	local temp_city_id = mainBuildScene.getThisCityid()
	armyListCityShare.deal_with_city_army_click(temp_city_id, new_index)
end

local function deal_with_army_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local select_index = tonumber(string.sub(sender:getName(),6))
		enter_army_by_index(select_index)
	end
end

local function set_army_touch_state(new_state)
	armyListCityShare.set_army_touch_state(m_main_widget, mainBuildScene.getThisCityid(), new_state)
end

local function hideEffect(duration)
	if not m_main_widget then
		return
	end

	if not duration then
		duration = 0.5
	end
    
    m_main_widget:setVisible(true)
    uiUtil.hideScaleEffect(m_main_widget,function()
        m_main_widget:setVisible(false)
    end,duration)

    set_army_touch_state(false)
end

local function showEffect(duration)
    if not m_main_widget then
    	return
    end

    if not duration then
    	duration = 0.5
    end

    m_main_widget:setVisible(true)
    uiUtil.showScaleEffect(m_main_widget,nil,duration,nil,nil,0)

    set_army_touch_state(true)
end

local function update_army_info()
	armyListCityShare.set_city_id(m_main_widget, mainBuildScene.getThisCityid(), true)
end

local function effectLoadingNewCityArmyInfo(cid,oldCid,callback)
	local cloneItem = m_main_widget:clone()
	armyListCityShare.set_city_id(cloneItem, oldCid, true)
	m_main_widget:getParent():addChild(cloneItem)
	armyListCityShare.set_city_id(m_main_widget, cid, true)


	set_army_touch_state(false)

	local duration = 0.5
	cloneItem:setPosition(cc.p(m_main_widget:getPositionX(),m_main_widget:getPositionY()))
	local hideMoveAction = CCMoveTo:create(duration,ccp(cloneItem:getPositionX() - cloneItem:getContentSize().width,cloneItem:getPositionY()))
	local hideAction = CCFadeOut:create(duration)
	local hideActionFinally = cc.CallFunc:create(function ( )
		cloneItem:removeFromParentAndCleanup(true)
		cloneItem = nil
	end)
	
    cloneItem:runAction(animation.sequence({CCSpawn:createWithTwoActions(hideMoveAction,hideAction),hideActionFinally}))

    -- ATTK  oriPosx oriPosy 有问题 ，因为外部调用机制 可以避免 所以暂时不处理
    local oriPosx = m_main_widget:getPositionX()
    local oriPosy = m_main_widget:getPositionY()
    m_main_widget:setPositionX(oriPosx + m_main_widget:getContentSize().width)
	local showMoveAction = CCMoveTo:create(duration,ccp(oriPosx,oriPosy))
	local showAction = CCFadeIn:create(duration)
	local showActionFinally = cc.CallFunc:create(function ( )
		if callback then callback() end
		set_army_touch_state(true)
	end)
	m_main_widget:runAction(animation.sequence({CCSpawn:createWithTwoActions(showMoveAction,showAction),showActionFinally}))	


end

local function changeInCityState(b_isInCity,closeEffect)
	if not m_main_widget then
		return
	end

    if closeEffect and (not b_isInCity) then
    	set_army_touch_state(false)
        m_main_widget:setVisible(false)
        return 
    end

    if b_isInCity then
    	update_army_info()
        showEffect()
    else
        hideEffect()
    end
end

local function create(parent_con, bottom_y, tag_id)
	if m_main_widget then
		return
	end

	require("game/army/armyCityOverview/armyListCityShare")
	uiUtil = require("game/utils/ui_util")

	--m_city_id = city_id
	m_main_widget = armyListCityShare.create(deal_with_army_click)
	m_main_widget:setTag(tag_id)
	m_main_widget:ignoreAnchorPointForPosition(false)
    m_main_widget:setAnchorPoint(cc.p(0,0))
    m_main_widget:setScale(config.getgScale())
    m_main_widget:setPosition(cc.p(0, bottom_y * config.getgScale()))
	m_main_widget:setTouchEnabled(true)
	m_main_widget:setVisible(false)

	parent_con:addWidget(m_main_widget)

	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, armyListInCityManager.dealWithHeroUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, armyListInCityManager.dealWithArmyUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.build_effect_city.name, dataChangeType.update, armyListInCityManager.dealWithEffectUpdate)
end

local function deal_with_related_update()
	if not m_main_widget then
		return
	end

	if not m_main_widget:isVisible() then
		return
	end

	update_army_info()
end

local function dealWithHeroUpdate(packet)
	deal_with_related_update()
end

local function dealWithArmyUpdate(packet)
	deal_with_related_update()
end

local function dealWithEffectUpdate(packet)
	if packet.city_wid == mainBuildScene.getThisCityid() then
		deal_with_related_update()
		set_army_touch_state(true)
	end
end

local function getInstance()
	return m_main_widget
end
armyListInCityManager = {
							create = create,
							remove = remove,
							dealwithTouchEvent = dealwithTouchEvent,
							showEffect = showEffect,
							hideEffect = hideEffect,
							enter_army_by_index = enter_army_by_index,
							changeInCityState = changeInCityState,
							update_army_info = update_army_info,
							dealWithHeroUpdate = dealWithHeroUpdate,
							dealWithArmyUpdate = dealWithArmyUpdate,
							dealWithEffectUpdate = dealWithEffectUpdate,
							effectLoadingNewCityArmyInfo = effectLoadingNewCityArmyInfo,
							getInstance = getInstance,
}