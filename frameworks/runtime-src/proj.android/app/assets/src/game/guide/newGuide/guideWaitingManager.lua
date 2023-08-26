local bg_color_layer = nil
local waiting_layer = nil
local waiting_id = nil

local m_keep_timer = nil 		--时间到达后自动消失
local m_touch_timer = nil 		--出现多久后可以点击消失

local function remove_self()
	if m_keep_timer then
		scheduler.remove(m_keep_timer)
		m_keep_timer = nil
	end

	if m_touch_timer then
		scheduler.remove(m_touch_timer)
		m_touch_timer = nil
	end

	if bg_color_layer then
		bg_color_layer:removeFromParentAndCleanup(true)
		bg_color_layer = nil
	end

	if waiting_layer then
		waiting_id = nil

		local temp_widget = waiting_layer:getWidgetByTag(999)
		local continue_img = tolua.cast(temp_widget:getChildByName("continue_img"), "ImageView")
		continue_img:stopAllActions()

		waiting_layer:removeFromParentAndCleanup(true)
		waiting_layer = nil
	end
end

local function remove_texture_cache(temp_show_id)
	local res_name = nil
	if temp_show_id == guide_waiting_list.ZHENGBING then
		res_name = ResDefineUtil.guide_res[2]
	elseif temp_show_id == guide_waiting_list.KILL_ZB then
		res_name = ResDefineUtil.guide_res[3]
	elseif temp_show_id == guide_waiting_list.GAME_TARGET then
		res_name = ResDefineUtil.guide_res[4]
	end

	local temp_texture = CCTextureCache:sharedTextureCache():textureForKey(res_name)
	if temp_texture and temp_texture:retainCount() == 1 then
		CCTextureCache:sharedTextureCache():removeTextureForKey(res_name)
	end
end

local function deal_with_disappear()
	local current_id = waiting_id
	remove_self()
	remove_texture_cache(current_id)

	if current_id == guide_waiting_list.ZHENGBING then
		if armyHeroManager then
			armyHeroManager.play_zb_guide_anim()
		end
	else
		newGuideInfo.enter_next_guide()
	end
end

local function deal_with_touch_timer()
	scheduler.remove(m_touch_timer)
	m_touch_timer = nil

	local temp_widget = waiting_layer:getWidgetByTag(999)
	local continue_img = tolua.cast(temp_widget:getChildByName("continue_img"), "ImageView")

	local move_by_1 = CCMoveBy:create(0.5, ccp(0, -10))
	local move_by_2 = CCMoveBy:create(0.5, ccp(0, 10))
	local temp_seq = cc.Sequence:createWithTwoActions(move_by_1, move_by_2)
	local temp_repeat = CCRepeatForever:create(temp_seq)
	continue_img:runAction(temp_repeat)
	continue_img:setVisible(true)
end

local function play_anim(temp_widget)
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	local fade_in = CCFadeIn:create(0.5)
	des_img:runAction(fade_in)
	des_img:setVisible(true)
end

local function set_content(temp_widget)
	local bg_img = tolua.cast(temp_widget:getChildByName("bg_img"), "ImageView")
	local des_img = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	local content_img = tolua.cast(des_img:getChildByName("content_img"), "ImageView")

	if waiting_id == guide_waiting_list.ZHENGBING then
		bg_img:loadTexture(ResDefineUtil.guide_res[2], UI_TEX_TYPE_LOCAL)
		content_img:loadTexture(ResDefineUtil.guide_res[40], UI_TEX_TYPE_PLIST)
	elseif waiting_id == guide_waiting_list.KILL_ZB then
		bg_img:loadTexture(ResDefineUtil.guide_res[3], UI_TEX_TYPE_LOCAL)
		content_img:loadTexture(ResDefineUtil.guide_res[41], UI_TEX_TYPE_PLIST)
	elseif waiting_id == guide_waiting_list.GAME_TARGET then
		bg_img:loadTexture(ResDefineUtil.guide_res[4], UI_TEX_TYPE_LOCAL)
		content_img:loadTexture(ResDefineUtil.guide_res[42], UI_TEX_TYPE_PLIST)
	end

	m_touch_timer = scheduler.create(deal_with_touch_timer, 2)
	m_keep_timer = scheduler.create(deal_with_disappear, 5)
end

local function deal_with_layer_touch(eventType, x, y)
	if eventType == "began" then
		if m_keep_timer and (not m_touch_timer) then
			deal_with_disappear()
		end
		return true
	else
		return true
	end
end

local function create(new_id)
	if waiting_layer then
		return
	end

	waiting_id = new_id
	local win_size = config.getWinSize()
	bg_color_layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255), win_size.width, win_size.height)
	bg_color_layer:registerScriptTouchHandler(deal_with_layer_touch, false, layerPriorityList.guide_swallow_priority, true)
	bg_color_layer:setTouchEnabled(true)

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/waitingUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(win_size.width/2, win_size.height/2))

	set_content(temp_widget)

    waiting_layer = TouchGroup:create()
    waiting_layer:addWidget(temp_widget)
	newGuideManager.add_waiting_panel(bg_color_layer, waiting_layer)

	play_anim(temp_widget)
end

guideWaitingManager = {
						create = create
}