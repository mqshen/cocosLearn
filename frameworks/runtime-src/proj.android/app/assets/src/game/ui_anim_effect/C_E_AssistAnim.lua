local m_anim_layer = nil
local m_hero_widget = nil

local m_hero_list = nil 	--需要出现动画的卡牌列表
local m_hero_level = nil 	--卡牌等级
local m_current_index = nil 
local m_blue_sprite = nil
local m_purple_sprite = nil
local m_blue_armature = nil
local m_purple_armature = nil

local m_init_or_not = nil
local m_is_show = nil
local m_response_touch_state = nil

local m_is_get_anim = nil
local m_get_fun_call = nil

local function remove()
	if m_init_or_not then
		if m_get_fun_call then
			m_get_fun_call()
			m_get_fun_call = nil
		end

		m_hero_widget:removeFromParentAndCleanup(true)
		m_hero_widget = nil

		m_hero_list = nil
		m_hero_level = nil
		m_current_index = nil
		if m_blue_sprite then
			m_blue_sprite:removeFromParentAndCleanup(true)
			m_blue_sprite = nil
		end
		
		if m_purple_sprite then
			m_purple_sprite:removeFromParentAndCleanup(true)
			m_purple_sprite = nil
		end
		
		if m_blue_armature then
			m_blue_armature:removeFromParentAndCleanup(true)
			m_blue_armature = nil
		end

		if m_purple_armature then
			m_purple_armature:removeFromParentAndCleanup(true)
			m_purple_armature = nil
		end

		m_init_or_not = nil
		m_is_show = nil
		m_response_touch_state = nil
		m_is_get_anim = nil

		m_anim_layer:removeFromParentAndCleanup(true)
		m_anim_layer = nil

		CCTextureCache:sharedTextureCache():removeTextureForKey("Export/extractCardAnim_temp.png")
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("Export/extractCardAnim_temp.plist")

		--CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/blue_anim.ExportJson")
		--CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/purple_anim.ExportJson")
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

local function play_purple_anim()
	local sprite_frame_cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    local temp_array = CCArray:createWithCapacity(3)
    temp_array:addObject(sprite_frame_cache:spriteFrameByName(ResDefineUtil.card_extract_res[7]))
    temp_array:addObject(sprite_frame_cache:spriteFrameByName(ResDefineUtil.card_extract_res[8]))
    temp_array:addObject(sprite_frame_cache:spriteFrameByName(ResDefineUtil.card_extract_res[9]))
    local temp_animation = CCAnimation:createWithSpriteFrames(temp_array, 0.07)
    local temp_animate = CCAnimate:create(temp_animation)
    m_purple_armature:runAction(temp_animate) 
end

local function play_finish_anim()
	if m_hero_list[m_current_index][2] == cardQuality.four_star then
		m_blue_armature:setScale(1.15 * config.getgScale())
		breathAnimUtil.start_anim(m_blue_armature, true, 128, 255, 0.5, 0)
	else
		m_purple_armature:setScale(1.15 * config.getgScale())
		breathAnimUtil.start_anim(m_purple_armature, true, 128, 255, 0.5, 0)
	end

	m_response_touch_state = true
end

local function play_second_anim()
	m_anim_layer:setColor(ccc3(0, 0, 0))

	m_hero_widget:setOpacity(0)
	m_hero_widget:setScale(0.6*config.getgScale())
	m_hero_widget:setVisible(true)
	local fun_call = cc.CallFunc:create(play_finish_anim)
	local fade_in = CCFadeIn:create(0.15)
	local scale_to = CCScaleTo:create(0.15, config.getgScale())
	local temp_spawn = CCSpawn:createWithTwoActions(fade_in, scale_to)
	local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
	m_hero_widget:runAction(temp_seq)
end

local function play_bg_second_anim()
	if m_hero_list[m_current_index][2] == cardQuality.four_star then
		play_blue_anim()
		m_blue_armature:setVisible(true)
		m_blue_sprite:setVisible(false)
	else
		play_purple_anim()
		m_purple_armature:setVisible(true)
		m_purple_sprite:setVisible(false)
	end
end

local function sort_ruler(a_table, b_table)
	if a_table[2] < b_table[2] then
		return true
	else
		return false
	end
end

local function play_first_anim()
	m_hero_widget:setVisible(false)
	m_blue_armature:setVisible(false)
	m_purple_armature:setVisible(false)
	m_response_touch_state = false

	local first_time_num = 0.1
	local rotate_to = CCRotateTo:create(first_time_num, 0)
	local scale_to = CCScaleTo:create(first_time_num, 1)
	local temp_array = CCArray:create()
	temp_array:addObject(rotate_to)
	temp_array:addObject(scale_to)
	--[[
	if m_current_index == 1 then
		local move_to = CCMoveTo:create(first_time_num, ccp(config.getWinSize().width/2, config.getWinSize().height/2))
		temp_array:addObject(move_to)
	end
	--]]
	local temp_spawn = CCSpawn:create(temp_array)
	local bg_fun_call = cc.CallFunc:create(play_bg_second_anim)
	local bg_seq = cc.Sequence:createWithTwoActions(temp_spawn, bg_fun_call)

	cardFrameInterface.set_big_card_info(m_hero_widget, 0, m_hero_list[m_current_index][1], false)
	if m_hero_level and m_hero_level ~= 1 then
		cardFrameInterface.set_lv_images(m_hero_level, m_hero_widget)
	end

	if m_hero_list[m_current_index][2] == cardQuality.four_star then
		--if m_current_index ~= 1 then
			m_blue_sprite:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
		--end

		m_blue_sprite:setRotation(-180)
		m_blue_sprite:setScale(0.1)
		m_blue_sprite:setVisible(true)
		m_blue_sprite:runAction(bg_seq)
	else
		--if m_current_index ~= 1 then
			m_purple_sprite:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
		--end
		m_purple_sprite:setRotation(-180)
		m_purple_sprite:setScale(0.1)
		m_purple_sprite:setVisible(true)
		m_purple_sprite:runAction(bg_seq)
	end

	m_anim_layer:setColor(ccc3(255, 255, 255))
	local second_time_num = 0.1
	local fun_call = cc.CallFunc:create(play_second_anim)
	local fade_in = CCFadeIn:create(second_time_num)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	m_anim_layer:runAction(temp_seq)
end

local function init_anim_componment_info(init_pos)
	if not m_blue_sprite then
		m_blue_sprite = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.card_extract_res[2])
		m_blue_sprite:setPosition(init_pos)
		m_blue_sprite:setScale(config.getgScale())
		m_anim_layer:addChild(m_blue_sprite, 1)
		m_blue_sprite:setVisible(false)
	end
	if not m_blue_armature then
		m_blue_armature = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.card_extract_res[4])
		m_blue_armature:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
		m_blue_armature:setScale(config.getgScale())
		m_anim_layer:addChild(m_blue_armature, 2)
		m_blue_armature:setVisible(false)
	end

	if not m_purple_sprite then
		m_purple_sprite = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.card_extract_res[3])
		m_purple_sprite:setPosition(init_pos)
		m_purple_sprite:setScale(config.getgScale())
		m_anim_layer:addChild(m_purple_sprite, 1)
		m_purple_sprite:setVisible(false)
	end
	if not m_purple_armature then
		m_purple_armature = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.card_extract_res[7])
		m_purple_armature:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
		m_purple_armature:setScale(config.getgScale())
		m_anim_layer:addChild(m_purple_armature, 2)
		m_purple_armature:setVisible(false)
	end
end

local function play_anim()
	m_hero_list = callResultManager.get_good_card_list()
	m_hero_level = callResultManager.get_package_level()
	m_current_index = 1
	m_is_show = true
	
	table.sort(m_hero_list, sort_ruler)
	
	init_anim_componment_info(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	play_first_anim()
end

local function dealwithTouchEvent(x,y)
	if m_is_show then
		if m_response_touch_state then
			breathAnimUtil.stop_all_anim(m_blue_armature)
			breathAnimUtil.stop_all_anim(m_purple_armature)
			m_blue_armature:setScale(config.getgScale())
			m_purple_armature:setScale(config.getgScale())
			if m_current_index < #m_hero_list then
				m_current_index = m_current_index + 1
				play_first_anim()
			else
				local fade_out = CCFadeOut:create(0.2)

				if m_hero_list[m_current_index][2] == cardQuality.four_star then
					m_blue_armature:setVisible(false)
				else
					m_purple_armature:setVisible(false)
				end
				m_hero_widget:runAction(tolua.cast(fade_out:copy():autorelease(), "CCActionInterval"))

				if m_is_get_anim then
					local fun_call = cc.CallFunc:create(remove)
					local temp_seq = cc.Sequence:createWithTwoActions(fade_out, fun_call)
					m_anim_layer:runAction(temp_seq)
				else
					m_anim_layer:runAction(fade_out)
					callResultAnimManager.play_refresh_good_second_anim()
				end
				m_is_show = false
			end
		end

		return true
	else
		return false
	end
end

local function onLayerTouch(eventType, x, y)
	if eventType == "began" then
    	return dealwithTouchEvent(x, y)
	else
		return false
	end
end

local function play_begin_bg_anim(bg_anim_finish)
	local temp_action_time = 0.1
	m_anim_layer:setColor(ccc3(255, 255, 255))
	m_anim_layer:setVisible(true)
	local fade_out = CCFadeOut:create(temp_action_time)
	local fun_call = cc.CallFunc:create(bg_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_out, fun_call)
	m_anim_layer:runAction(temp_seq)
end

local function create()
	if m_init_or_not then
		return
	end

	m_init_or_not = true
	m_is_show = false
	m_is_get_anim = false

	local win_width = config.getWinSize().width
	local win_height = config.getWinSize().height

	m_hero_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameBig.json")
	m_hero_widget:setScale(config.getgScale())
	m_hero_widget:ignoreAnchorPointForPosition(false)
	m_hero_widget:setAnchorPoint(cc.p(0.5,0.5))
	m_hero_widget:setPosition(cc.p(win_width/2 + 6, win_height/2 + 4))
	m_hero_widget:setVisible(false)
	local refresh_anim_layer = TouchGroup:create()
	refresh_anim_layer:addWidget(m_hero_widget)

	m_anim_layer = cc.LayerColor:create(cc.c4b(255, 255, 255, 0), win_width, win_height)
	m_anim_layer:addChild(refresh_anim_layer, 3)
	m_anim_layer:registerScriptTouchHandler(onLayerTouch, false, layerPriorityList.ui_assist_priority, true)
	m_anim_layer:setTouchEnabled(true)
	cc.Director:getInstance():getRunningScene():addChild(m_anim_layer, UI_ASSIST_EFFECT_SCENE)

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("Export/extractCardAnim_temp.plist")

	--CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/blue_anim.ExportJson")
	--CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/purple_anim.ExportJson")
end

local function play_get_card_anim(hero_cfg_id_list, fun_call)
	--[[
		因为对于招募来说第一张的卡牌是有一个从招募界面过来位移显示的，我们这块绕开就是先对于第一个元素赋予0占位，
		然后从第二个开始播放
	--]]
	if not m_init_or_not then
		m_hero_list = {}
		m_hero_level = 1
		table.insert(m_hero_list, {0, 0})
	end

	--只有4星一级以及以上的卡牌才显示动画效果
	local is_enough_condition = false
	for k,v in pairs(hero_cfg_id_list) do
		local temp_quality = Tb_cfg_hero[v].quality
		if temp_quality >= cardQuality.four_star then
			local show_list = {}
			table.insert(show_list, v)
			table.insert(show_list, temp_quality)
			table.insert(m_hero_list, show_list)
			is_enough_condition = true
		end
	end

	if not is_enough_condition then
		if not m_init_or_not then
			m_hero_list = nil
			m_hero_level = nil
		end

		return
	end

	if not m_init_or_not then
		create()
		m_is_get_anim = true

		m_current_index = 2
		m_is_show = true
		m_hero_level = 1
		init_anim_componment_info(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
		play_first_anim()
	end

	m_get_fun_call = fun_call
end

C_E_AssistAnim = {
						create = create,
						remove = remove,
						dealwithTouchEvent = dealwithTouchEvent,
						play_anim = play_anim,
						play_begin_bg_anim = play_begin_bg_anim,
						play_get_card_anim = play_get_card_anim
}