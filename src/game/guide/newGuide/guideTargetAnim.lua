local bg_color_layer = nil
local m_target_layer = nil
local m_main_widget = nil

local m_keep_timer = nil

local m_clear_res_timer = nil

local function deal_with_res_clear()
	scheduler.remove(m_clear_res_timer)
	m_clear_res_timer = nil

	local remove_file_list = {ResDefineUtil.guide_res[4], ResDefineUtil.guide_res[5], ResDefineUtil.guide_res[6]}
	for k,v in pairs(remove_file_list) do
		local temp_texture = CCTextureCache:sharedTextureCache():textureForKey(v)
		if temp_texture and temp_texture:retainCount() == 1 then
			CCTextureCache:sharedTextureCache():removeTextureForKey(v)
		end
	end
end

local function remove_self()
	if m_keep_timer then
		scheduler.remove(m_keep_timer)
		m_keep_timer = nil
	end
	
	if bg_color_layer then
		bg_color_layer:removeFromParentAndCleanup(true)
		bg_color_layer = nil
	end

	if m_target_layer then
		m_main_widget = nil
		m_target_layer:removeFromParentAndCleanup(true)
		m_target_layer = nil
	end

	m_clear_res_timer = scheduler.create(deal_with_res_clear, 0.5)
end

local function deal_with_disappear()
	remove_self()
	newGuideInfo.enter_next_guide()
end

local function play_touch_anim()
	local continue_img = tolua.cast(m_main_widget:getChildByName("continue_img"), "ImageView")

	local move_by_1 = CCMoveBy:create(0.5, ccp(0, -10))
	local move_by_2 = CCMoveBy:create(0.5, ccp(0, 10))
	local temp_seq = cc.Sequence:createWithTwoActions(move_by_1, move_by_2)
	local temp_repeat = CCRepeatForever:create(temp_seq)
	continue_img:runAction(temp_repeat)
	continue_img:setVisible(true)
end

local function third_anim_finish()
	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	local left_anim = CCMoveBy:create(0.03, ccp(10,0))
	local right_anim = CCMoveBy:create(0.03, ccp(-10,0))
	local top_anim = CCMoveBy:create(0.03, ccp(0,10))
	local bottom_anim = CCMoveBy:create(0.03, ccp(0,-10))
	local temp_array = CCArray:create()
	temp_array:addObject(left_anim)
	temp_array:addObject(right_anim)
	temp_array:addObject(top_anim)
	temp_array:addObject(bottom_anim)
	--local temp_array = {left_anim,right_anim,top_anim,bottom_anim,left_anim:reverse(),right_anim:reverse(),top_anim:reverse(),bottom_anim:reverse()}
	local temp_seq = cc.Sequence:create(temp_array)
	bg_img:runAction(temp_seq)

	play_touch_anim()

	m_keep_timer = scheduler.create(deal_with_disappear, 2)
end

local function second_anim_finish()
	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	local state_img = tolua.cast(bg_img:getChildByName("state_img"), "ImageView")
	state_img:setScale(5)
	local scale_to = CCScaleTo:create(0.08, 1)
	local fun_call = cc.CallFunc:create(third_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(scale_to, fun_call)
	state_img:runAction(temp_seq)
	state_img:setVisible(true)
end

local function first_anim_finish()
	local des_img = tolua.cast(m_main_widget:getChildByName("des_img"), "ImageView")
	local fade_in = CCFadeIn:create(0.5)
	local fun_call = cc.CallFunc:create(second_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	des_img:runAction(temp_seq)
	des_img:setVisible(true)
end

local function play_anim()
	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	local fade_in = CCFadeIn:create(0.5)
	local fun_call = cc.CallFunc:create(first_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	bg_img:runAction(temp_seq)
	bg_img:setVisible(true)
end

local function set_content(scene_width, scene_height)
	local bg_img = tolua.cast(m_main_widget:getChildByName("bg_img"), "ImageView")
	local map_img = tolua.cast(bg_img:getChildByName("map_img"), "ImageView")
	local state_img = tolua.cast(bg_img:getChildByName("state_img"), "ImageView")
	bg_img:loadTexture(ResDefineUtil.guide_res[4], UI_TEX_TYPE_LOCAL)
	map_img:loadTexture(ResDefineUtil.guide_res[5], UI_TEX_TYPE_LOCAL)
	state_img:loadTexture(ResDefineUtil.guide_res[6], UI_TEX_TYPE_LOCAL)

	bg_img:setScale(scene_height/bg_img:getContentSize().height)
	bg_img:setPosition(cc.p(scene_width/2, scene_height/2))

	local des_img = tolua.cast(m_main_widget:getChildByName("des_img"), "ImageView")
	des_img:setPositionX(scene_width/2)
	des_img:setScale(config.getgScale())
end

local function deal_with_layer_touch(eventType, x, y)
	if eventType == "began" then
		if m_keep_timer then
			deal_with_disappear()
		end
		return true
	else
		return true
	end
end

local function create()
	if m_target_layer then
		return
	end

	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height
	bg_color_layer = cc.LayerColor:create(cc.c4b(255, 255, 255, 0), scene_width, scene_height)
	bg_color_layer:registerScriptTouchHandler(deal_with_layer_touch, false, layerPriorityList.guide_swallow_priority, true)
	bg_color_layer:setTouchEnabled(true)

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/guideTargetUI.json")
	m_main_widget:setTag(999)
	m_main_widget:setSize(CCSizeMake(scene_width, scene_height))
	set_content(scene_width, scene_height)

    m_target_layer = TouchGroup:create()
    m_target_layer:addWidget(m_main_widget)
	newGuideManager.add_waiting_panel(bg_color_layer, m_target_layer)

	play_anim()
end

guideTargetAnim = {
						create = create
}