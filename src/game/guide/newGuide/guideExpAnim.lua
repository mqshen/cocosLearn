local m_anim_layer = nil
local m_bg_layer = nil
local m_armature_1 = nil
local m_armature_2 = nil

local function remove()
	if m_anim_layer then
		m_armature_1 = nil
		m_armature_2 = nil

		m_bg_layer:removeFromParentAndCleanup(true)
		m_bg_layer = nil

		m_anim_layer:removeFromParentAndCleanup(true)
		m_anim_layer = nil

		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou_jingyanshu.ExportJson")
		
		local temp_army_id = userData.getMainPos() * 10 + 2
		local temp_army_info = armyData.getTeamMsg(temp_army_id)
		if temp_army_info.state == armyState.normal then
			newGuideInfo.enter_next_guide()
		end
	end
end

local function init_icon_content(temp_widget)
	local temp_army_id = userData.getMainPos() * 10 + 2

	local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	local hero_uid, hero_widget, icon_panel, lv_img = nil, nil, nil, nil
	for i=1,2 do
		hero_uid = armyData.getHeroIdInTeamAndPos(temp_army_id, i)
		hero_widget = base_widget:clone()
		cardFrameInterface.set_middle_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid))
		icon_panel = tolua.cast(temp_widget:getChildByName("icon_panel_" .. i), "Layout")
		icon_panel:addChild(hero_widget)
		icon_panel:setVisible(false)
		local lv_img = tolua.cast(temp_widget:getChildByName("lv_img_" .. i), "ImageView")
		lv_img:setVisible(false)
	end

	local exp_img = tolua.cast(temp_widget:getChildByName("exp_img"), "ImageView")
	exp_img:setVisible(false)
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	des_img:setVisible(false)
end

local function init_anim_content(temp_widget)
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou_jingyanshu.ExportJson")

	m_armature_1 = CCArmature:create("xinshou_jingyanshu")
	m_armature_1:setPosition(cc.p(170, 225))
	m_armature_1:setScaleX(-1)
	temp_widget:addChild(m_armature_1, 1)
    m_armature_1:setVisible(false)

    m_armature_2 = CCArmature:create("xinshou_jingyanshu")
	m_armature_2:setPosition(cc.p(454, 225))
	temp_widget:addChild(m_armature_2, 1)
    m_armature_2:setVisible(false)
end

local function play_lv_anim()
	local move_by = CCMoveBy:create(0.6, ccp(0, 100))
	local fade_out = CCFadeOut:create(0.6)
	local temp_spawn = CCSpawn:createWithTwoActions(move_by, fade_out)

	local temp_widget = m_anim_layer:getWidgetByTag(999)
	local lv_img = nil
	for i=1,2 do
		lv_img = tolua.cast(temp_widget:getChildByName("lv_img_" .. i), "ImageView")
		lv_img:setVisible(true)
		if i == 1 then
			lv_img:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCActionInterval"))
		else
			lv_img:runAction(temp_spawn)
		end
	end
end

local function play_exp_anim()
	local temp_widget = m_anim_layer:getWidgetByTag(999)

	local fade_out = CCFadeOut:create(0.2)
	local exp_img = tolua.cast(temp_widget:getChildByName("exp_img"), "ImageView")
	exp_img:runAction(fade_out)
end

local function second_anim_finish()
	local function onFrameEvent( bone,evt,originFrameIndex,currentFrameIndex)
        if evt == "frame_8" then
        	play_lv_anim()
        elseif evt == "frame_10" then
        	play_exp_anim()
        elseif evt == "finish" then
        	--m_is_playing_anim = false
        	remove()
        end
    end

	m_armature_1:getAnimation():setFrameEventCallFunc(onFrameEvent)
	m_armature_1:getAnimation():play("Animation1")
	m_armature_2:getAnimation():play("Animation1")
end

local function first_anim_finish()
	local temp_widget = m_anim_layer:getWidgetByTag(999)
	local fade_in = CCFadeIn:create(0.3)

	local icon_panel = nil
	for i=1,2 do
		icon_panel = tolua.cast(temp_widget:getChildByName("icon_panel_" .. i), "Layout")
		icon_panel:setVisible(true)
		icon_panel:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))
	end
	
	m_armature_1:setVisible(true)
	m_armature_1:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))
	m_armature_2:setVisible(true)
	m_armature_2:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))

	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	des_img:setVisible(true)
	local fun_call = cc.CallFunc:create(second_anim_finish)
   	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
   	des_img:runAction(temp_seq)
end

local function play_anim(temp_widget)
	local exp_img = tolua.cast(temp_widget:getChildByName("exp_img"), "ImageView")
	local init_pos = mapMessageUI.get_map_guide_pos_info(6)
	exp_img:setPosition(temp_widget:convertToNodeSpace(init_pos))
	exp_img:setVisible(true)

	local move_to = CCMoveTo:create(0.4, ccp(312, 224))
	local fun_call = cc.CallFunc:create(first_anim_finish)
   	local temp_seq = cc.Sequence:createWithTwoActions(move_to, fun_call)
	exp_img:runAction(temp_seq)
end

--[[
local function dealwithTouchEvent(x,y)
	if not m_anim_layer then
		return false
	end

	if not m_is_playing_anim then
		remove()
	end

	return true
end

local function deal_with_layer_touch(eventType, x, y)
	if eventType == "began" then
		return dealwithTouchEvent(x, y)
	else
		return true
	end
end
--]]

local function is_playing()
	if m_anim_layer then
		return true
	else
		return false
	end
end

local function create()
	if m_anim_layer then
		return
	end

	--m_is_playing_anim = true

	local win_size = config.getWinSize()
	m_bg_layer = cc.LayerColor:create(cc.c4b(14, 17, 24, 150), win_size.width, win_size.height)
	--m_bg_layer:registerScriptTouchHandler(deal_with_layer_touch, false, layerPriorityList.guide_swallow_priority, true)
	--m_bg_layer:setTouchEnabled(true)

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/guideExpUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_icon_content(temp_widget)
	init_anim_content(temp_widget)

	m_anim_layer = TouchGroup:create()
	m_anim_layer:addWidget(temp_widget)
	newGuideManager.add_waiting_panel(m_bg_layer, m_anim_layer)

	play_anim(temp_widget)
end

guideExpAnim = {
					create = create,
					remove = remove,
					is_playing = is_playing
}