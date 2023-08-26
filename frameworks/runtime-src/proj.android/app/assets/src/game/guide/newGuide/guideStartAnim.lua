local m_anim_layer = nil
local m_bg_layer = nil
local m_main_widget = nil
local m_show_index = nil 			--当前显示文字的索引
local m_first_armature = nil
local m_second_armature = nil

local m_start_timer = nil 			--出现加一个延迟，处理第一行动画看不到
local m_timer = nil					--文字出现完成后的等待时间

local function remove()
	if m_anim_layer then
		if m_timer then
			scheduler.remove(m_timer)
			m_timer = nil
		end

		if m_start_timer then
			scheduler.remove(m_start_timer)
			m_start_timer = nil
		end

		m_first_armature = nil
		m_second_armature = nil
		m_show_index = nil

		m_main_widget = nil

		m_bg_layer:removeFromParentAndCleanup(true)
		m_bg_layer = nil

		m_anim_layer:removeFromParentAndCleanup(true)
		m_anim_layer = nil

		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou_yanhuo.ExportJson")
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou_zhuhuo.ExportJson")
		
		CCTextureCache:sharedTextureCache():removeTextureForKey(ResDefineUtil.guide_res[20])
		CCTextureCache:sharedTextureCache():removeTextureForKey(ResDefineUtil.guide_res[21])

		newGuideManager.deal_with_leave_start_anim()
	end
end

local function deal_with_jump_finish()
	remove()
end

local function jump_to_map()
	m_bg_layer:setVisible(false)
	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
	content_img:setVisible(false)

	m_second_armature:getAnimation():stop()
	m_second_armature:setVisible(false)

	local second_bg_img = tolua.cast(m_main_widget:getChildByName("second_bg_img"), "ImageView")
	local scale_to = CCScaleTo:create(1, 1.5 * second_bg_img:getScale())
	local fade_out = CCFadeOut:create(1)
	local temp_spawn = CCSpawn:createWithTwoActions(scale_to, fade_out)
	local fun_call = cc.CallFunc:create(deal_with_jump_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)

	
	second_bg_img:runAction(temp_seq)
end

local function change_bg_finish()
	m_second_armature:setVisible(true)
	m_second_armature:getAnimation():play("Animation1")

	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
	content_img:setVisible(true)

	guideStartAnim.organize_show_content()
end

local function change_bg_img()
	m_first_armature:getAnimation():stop()

	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
	content_img:setVisible(false)

	local first_bg_img = tolua.cast(m_main_widget:getChildByName("first_bg_img"), "ImageView")
	local fade_out = CCFadeOut:create(1)
	first_bg_img:runAction(fade_out)

	local second_bg_img = tolua.cast(m_main_widget:getChildByName("second_bg_img"), "ImageView")
	second_bg_img:setOpacity(0)
	local fade_in = CCFadeIn:create(1)
	local fun_call = cc.CallFunc:create(change_bg_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	second_bg_img:setVisible(true)
	second_bg_img:runAction(temp_seq)

	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou_zhuhuo.ExportJson")
	m_second_armature = CCArmature:create("xinshou_zhuhuo")
	m_second_armature:setScale(2 * config.getWinSize().height/second_bg_img:getContentSize().height)
	m_second_armature:setPosition(second_bg_img:convertToWorldSpace(cc.p(232, 210)))
	m_second_armature:setVisible(false)
	m_main_widget:addChild(m_second_armature, 1)
end

local function show_content_finish()
	scheduler.remove(m_timer)
	m_timer = nil

	if m_show_index == 1 then
		change_bg_img()
		m_show_index = m_show_index + 1
	else
		jump_to_map()
	end
end

local function second_content_finish()
	if m_timer then
		scheduler.remove(m_timer)
		m_timer = nil
	end
	
	m_timer = scheduler.create(show_content_finish, 2)
end

local function first_content_finish()
	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
	local second_img = tolua.cast(content_img:getChildByName("second_img"), "ImageView")

	local fade_in = CCFadeIn:create(1)
	local fun_call = cc.CallFunc:create(second_content_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	second_img:setVisible(true)
	second_img:runAction(temp_seq)
end

local function organize_show_content()
	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
	local first_img = tolua.cast(content_img:getChildByName("first_img"), "ImageView")
	first_img:setVisible(false)

	local second_img = tolua.cast(content_img:getChildByName("second_img"), "ImageView")
	second_img:setVisible(false)
	
	local first_img_name, second_img_name = nil, nil
	if m_show_index == 1 then
		first_img_name = ResDefineUtil.guide_res[22]
		second_img_name = ResDefineUtil.guide_res[23]
	elseif m_show_index == 2 then
		first_img_name = ResDefineUtil.guide_res[24]
		second_img_name = ResDefineUtil.guide_res[25]
	end

	first_img:loadTexture(first_img_name, UI_TEX_TYPE_PLIST)
	second_img:loadTexture(second_img_name, UI_TEX_TYPE_PLIST)

	first_img:setOpacity(0)
	local fade_in = CCFadeIn:create(1)
	local fun_call = cc.CallFunc:create(first_content_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
	first_img:setVisible(true)
	first_img:runAction(temp_seq)
end

local function play_anim()
	scheduler.remove(m_start_timer)
	m_start_timer = nil

	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	m_first_armature = CCArmature:create("xinshou_yanhuo")
	m_first_armature:setScale(5 * config.getgScale())
	m_first_armature:setPosition(cc.p(scene_width/2, scene_height/2))
	m_main_widget:addChild(m_first_armature, 1)
	m_first_armature:getAnimation():play("Animation1")

	m_show_index = 1
	organize_show_content()

	--local first_bg_img = tolua.cast(m_main_widget:getChildByName("first_bg_img"), "ImageView")
	--first_bg_img:setVisible(true)
	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
	content_img:setVisible(true)
end

local function init_widget_content(scene_width, scene_height)
	local first_bg_img = tolua.cast(m_main_widget:getChildByName("first_bg_img"), "ImageView")
	first_bg_img:loadTexture(ResDefineUtil.guide_res[20], UI_TEX_TYPE_LOCAL)
	first_bg_img:setScale(scene_height/first_bg_img:getContentSize().height)
	first_bg_img:setPosition(cc.p(scene_width/2, scene_height/2))
	--first_bg_img:setVisible(false)

	local second_bg_img = tolua.cast(m_main_widget:getChildByName("second_bg_img"), "ImageView")
	second_bg_img:loadTexture(ResDefineUtil.guide_res[21], UI_TEX_TYPE_LOCAL)
	second_bg_img:setScale(scene_height/second_bg_img:getContentSize().height)
	second_bg_img:setPosition(cc.p(scene_width/2, scene_height/2))
	second_bg_img:setVisible(false)

	local content_img = tolua.cast(m_main_widget:getChildByName("content_img"), "ImageView")
	content_img:setScale(config.getgScale())
	content_img:setPosition(cc.p(scene_width * 9/10, scene_height/2))
	content_img:setVisible(false)
end

local function create()
	if m_anim_layer then
		return
	end

	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou_yanhuo.ExportJson")

	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height
	m_bg_layer = cc.LayerColor:create(cc.c4b(14, 17, 24, 150), scene_width, scene_height)

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/guideStartUI.json")
	m_main_widget:setTag(999)
	m_main_widget:setSize(CCSizeMake(scene_width, scene_height))

	--m_main_widget:setScale(config.getgScale())
	--m_main_widget:ignoreAnchorPointForPosition(false)
	--m_main_widget:setAnchorPoint(cc.p(0.5,0.5))
	--m_main_widget:setPosition(cc.p(win_size.width/2, win_size.height/2))
	init_widget_content(scene_width, scene_height)

	m_anim_layer = TouchGroup:create()
	m_anim_layer:addWidget(m_main_widget)
	newGuideManager.add_waiting_panel(m_bg_layer, m_anim_layer)

	m_start_timer = scheduler.create(play_anim, 1.5)
end

guideStartAnim = {
					create = create,
					organize_show_content = organize_show_content
}