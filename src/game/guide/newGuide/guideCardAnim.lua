local m_bg_layer = nil 		--最底层layer
local m_touch_group = nil 	--加载widget的容器
local m_hero_widget = nil
local m_des_bg_img = nil
local m_des_img = nil

local m_hero_cfg_id = nil

local m_blue_sprite = nil
local m_blue_armature = nil
local m_response_touch_state = nil

local function remove()
	if m_bg_layer then
		m_des_img = nil
		m_des_bg_img = nil

		m_hero_widget:removeFromParentAndCleanup(true)
		m_hero_widget = nil

		m_blue_sprite:removeFromParentAndCleanup(true)
		m_blue_sprite = nil

		m_blue_armature:removeFromParentAndCleanup(true)
		m_blue_armature = nil

		m_hero_cfg_id = nil
		m_response_touch_state = nil

		m_touch_group:removeFromParentAndCleanup(true)
		m_touch_group = nil

		m_bg_layer:removeFromParentAndCleanup(true)
		m_bg_layer = nil

		CCTextureCache:sharedTextureCache():removeTextureForKey("Export/extractCardAnim_temp.png")
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("Export/extractCardAnim_temp.plist")
		
		cardTextureManager.remove_cache()

		newGuideInfo.enter_next_guide()
	end
end

local function play_blue_anim()
	local sprite_frame_cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    local temp_array = CCArray:createWithCapacity(3)
    temp_array:addObject(sprite_frame_cache:spriteFrameByName(ResDefineUtil.card_extract_res[4]))
    temp_array:addObject(sprite_frame_cache:spriteFrameByName(ResDefineUtil.card_extract_res[5]))
    temp_array:addObject(sprite_frame_cache:spriteFrameByName(ResDefineUtil.card_extract_res[6]))
    local temp_animation = CCAnimation:createWithSpriteFrames(temp_array, 0.07)
    local temp_animate = CCAnimate:create(temp_animation)
    m_blue_armature:runAction(temp_animate) 
end

local function play_finish_anim()
	m_blue_armature:setScale(1.15 * config.getgScale())
	breathAnimUtil.start_anim(m_blue_armature, true, 128, 255, 0.5, 0)
	m_response_touch_state = true
end

local function play_second_anim()
	--if true then
		--return
	--end

	m_bg_layer:setColor(ccc3(0, 0, 0))

	m_hero_widget:setOpacity(0)
	m_hero_widget:setScale(0.6*config.getgScale())
	m_hero_widget:setVisible(true)
	
	local fade_in = CCFadeIn:create(0.15)
	local scale_to = CCScaleTo:create(0.15, config.getgScale())
	local temp_spawn = CCSpawn:createWithTwoActions(fade_in, scale_to)
	local fun_call = cc.CallFunc:create(play_finish_anim)
	local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
	m_hero_widget:runAction(temp_seq)
end

local function play_bg_second_anim()
	play_blue_anim()
	m_blue_armature:setVisible(true)
	m_blue_sprite:setVisible(false)
end

local function play_first_anim()
	--cc.Director:getInstance():setProjection(kCCDirectorProjection2D)
	m_hero_widget:setVisible(false)
	m_blue_armature:setVisible(false)
	m_response_touch_state = false

	local first_time_num = 0.1
	local rotate_to = CCRotateTo:create(first_time_num, 0)
	local scale_to = CCScaleTo:create(first_time_num, 1)
	local temp_spawn = CCSpawn:createWithTwoActions(rotate_to, scale_to)
	local bg_fun_call = cc.CallFunc:create(play_bg_second_anim)
	local bg_seq = cc.Sequence:createWithTwoActions(temp_spawn, bg_fun_call)

	cardFrameInterface.set_big_card_info(m_hero_widget, 0, m_hero_cfg_id, false)
	m_blue_sprite:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	m_blue_sprite:setRotation(-180)
	m_blue_sprite:setScale(0.1)
	m_blue_sprite:setVisible(true)


	--local orbit1 = CCOrbitCamera:create(5,1, 0, 0, 180, 0, 0)
	--local action1 = cc.Sequence:createWithTwoActions(orbit1, orbit1:reverse())
	--local orbitShow = CCOrbitCamera:create(1,1, 0, 90,-90, 0, 0)
	--m_blue_sprite:runAction(CCRepeatForever:create(action1))

	m_blue_sprite:runAction(bg_seq)

	m_bg_layer:setColor(ccc3(255, 255, 255))
	local second_time_num = 0.1
	local fade_in = CCFadeIn:create(second_time_num)
	local fun_call = cc.CallFunc:create(play_second_anim)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	m_bg_layer:runAction(temp_seq)
end

local function init_anim_componment_info(init_pos)
	if not m_blue_sprite then
		m_blue_sprite = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.card_extract_res[2])
		m_blue_sprite:setPosition(init_pos)
		m_blue_sprite:setScale(config.getgScale())
		m_bg_layer:addChild(m_blue_sprite, 1)
		m_blue_sprite:setVisible(false)
	end
	if not m_blue_armature then
		m_blue_armature = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.card_extract_res[4])
		m_blue_armature:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
		m_blue_armature:setScale(config.getgScale())
		m_bg_layer:addChild(m_blue_armature, 2)
		m_blue_armature:setVisible(false)
	end
end

local function deal_with_anim_finish()
	remove()
end

local function play_anim()
	m_response_touch_state = false

	breathAnimUtil.stop_all_anim(m_blue_armature)
	m_blue_armature:setVisible(false)
	m_bg_layer:setVisible(false)

	if m_des_img then
		m_des_img:setVisible(false)
	end

	if m_des_bg_img then
		m_des_bg_img:setVisible(false)
	end

	local scale_to = CCScaleTo:create(0.3, 0.2)
	local move_to = CCMoveTo:create(0.5, mainOption.get_tool_btn_world_pos(2))
	local fun_call = cc.CallFunc:create(deal_with_anim_finish)

	local temp_array = CCArray:create()
	temp_array:addObject(scale_to)
	temp_array:addObject(move_to)
	temp_array:addObject(fun_call)
	local temp_seq = cc.Sequence:create(temp_array)
	m_hero_widget:runAction(temp_seq)
end

local function dealwithTouchEvent(x,y)
	if not m_bg_layer then
		return false
	end

	if m_response_touch_state then
		play_anim()
	end

	return true
end

local function onLayerTouch(eventType, x, y)
	if eventType == "began" then
    	return dealwithTouchEvent(x, y)
	else
		return false
	end
end

local function create()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("Export/extractCardAnim_temp.plist")

	local win_width = config.getWinSize().width
	local win_height = config.getWinSize().height

	m_hero_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameBig.json")
	m_hero_widget:setScale(config.getgScale())
	m_hero_widget:ignoreAnchorPointForPosition(false)
	m_hero_widget:setAnchorPoint(cc.p(0.5,0.5))
	m_hero_widget:setPosition(cc.p(win_width/2 + 6, win_height/2 + 4))
	m_hero_widget:setVisible(false)
	m_touch_group = TouchGroup:create()
	m_touch_group:addWidget(m_hero_widget)

	if m_hero_cfg_id == INIT_HERO then
		m_des_bg_img = ImageView:create()
		m_des_bg_img:loadTexture(ResDefineUtil.guide_res[12], UI_TEX_TYPE_PLIST)
		m_des_bg_img:setSize(CCSize(800, 26))
		m_des_bg_img:setPosition(cc.p(175, -27))
		m_hero_widget:addChild(m_des_bg_img)

		m_des_img = ImageView:create()
		m_des_img:loadTexture(ResDefineUtil.guide_res[11], UI_TEX_TYPE_PLIST)
		m_des_img:setPosition(cc.p(175, -27))
		m_hero_widget:addChild(m_des_img)
	end

	m_bg_layer = cc.LayerColor:create(cc.c4b(255, 255, 255, 0), win_width, win_height)
	m_bg_layer:registerScriptTouchHandler(onLayerTouch, false, layerPriorityList.guide_swallow_priority, true)
	m_bg_layer:setTouchEnabled(true)

	newGuideManager.add_waiting_panel(m_bg_layer, m_touch_group)
	init_anim_componment_info(cc.p(win_width/2, win_height/2))
end

local function play_get_card_anim(hero_cfg_id)
	if m_bg_layer then
		return
	end

	m_hero_cfg_id = hero_cfg_id
	m_response_touch_state = false
	
	create()
	play_first_anim()
end

guideCardAnim = {
					play_get_card_anim = play_get_card_anim
}