local new_guide_layer = nil 			--内容显示层
local clipping_node = nil

local guide_swallow_layer = nil 		--TOUCH事件吞噬层
local m_swallow_state = nil
local m_is_in_start_anim = nil 			--是否正在播放开场动画

local function on_guide_touch(eventType, x, y)
	if eventType == "began" then
		if m_is_in_start_anim then
			m_swallow_state = true
		else
			if newGuideInfo then
				m_swallow_state = newGuideInfo.deal_with_touch_began(x, y)
			else
				m_swallow_state = false
			end
		end
	elseif eventType == "ended" then
		if (not m_is_in_start_anim) and newGuideInfo then
			newGuideInfo.deal_with_touch_ended(x, y)
		end
	end

	return true
end

local function on_guide_swallow_touch(eventType, x, y)
	if eventType == "began" then
		return m_swallow_state
	else
		return true
	end
end

local function remove()
	if guide_swallow_layer then
		m_swallow_state = nil

		guide_swallow_layer:removeFromParentAndCleanup(true)
		guide_swallow_layer = nil
	end

	if new_guide_layer then
		newGuideInfo.remove()

		clipping_node = nil
		new_guide_layer:removeFromParentAndCleanup(true)
		new_guide_layer = nil
	end

	m_is_in_start_anim = nil
end

local function add_content_panel(content_touch_group)
	if clipping_node then
		clipping_node:addChild(content_touch_group, 1)
	end
end

local function set_stencil(new_stencil)
	if clipping_node then
		clipping_node:setStencil(new_stencil)
	end
end

local function add_waiting_panel(bg_color_layer, content_touch_group)
	if guide_swallow_layer then
		if bg_color_layer then
			guide_swallow_layer:addChild(bg_color_layer)
		end

		if content_touch_group then
			guide_swallow_layer:addChild(content_touch_group)
		end
	end
end

local function init()
	clipping_node = CCClippingNode:create()
	--clipping_node:setAlphaThreshold(0)
	clipping_node:setInverted(true)

	local temp_stencil = CCNode:create()
	local temp_node = CCDrawNode:create()
	temp_node:ignoreAnchorPointForPosition(false)
	temp_node:setAnchorPoint(cc.p(0.5, 0.5))
    temp_node:drawDot(cc.p(1, 1), 1, ccc4f(1, 0, 0, 1))
    temp_node:setPosition(cc.p(1, 1))
    --temp_node:setDrawVert(cc.p(-100, 50), ccp(100, 50), ccp(100, -50), ccp(-100, -50))
    --temp_node:setPosition(cc.p(200, 200))
    temp_stencil:addChild(temp_node)
    set_stencil(temp_stencil)

	new_guide_layer:addChild(clipping_node)

	require("game/guide/newGuide/newGuideInfo")
	newGuideInfo.create()
end

local function create()
	if new_guide_layer then
		return
	end

	m_is_in_start_anim = false

	guide_swallow_layer = CCLayer:create()
	guide_swallow_layer:registerScriptTouchHandler(on_guide_swallow_touch, false, layerPriorityList.guide_swallow_priority, true)
	guide_swallow_layer:setTouchEnabled(true)
	cc.Director:getInstance():getRunningScene():addChild(guide_swallow_layer, GUIDE_SWALLOW_SCENE)

	new_guide_layer = CCLayer:create()
	new_guide_layer:registerScriptTouchHandler(on_guide_touch, false, layerPriorityList.guide_priority, false)
	new_guide_layer:setTouchEnabled(true)
	new_guide_layer:setVisible(false)
	cc.Director:getInstance():getRunningScene():addChild(new_guide_layer, NEW_GUIDE_SCENE)

	init()
end

local function deal_with_leave_start_anim()
	m_is_in_start_anim = false
	newGuideInfo.set_guide_id(1001)
	require("game/guide/newGuide/guideSmokeAnim")
	guideSmokeAnim.create()
end

local function set_visible(new_state)
	if new_guide_layer then
		new_guide_layer:setVisible(new_state)
	end
end

local function start_guide()
	mapController.setIsRefreshMainCity(false)
	local temp_guide_phase = userData.getNewBie_Guide()
	if temp_guide_phase == 0 then
		m_is_in_start_anim = true
		require("game/guide/newGuide/guideStartAnim")
		guideStartAnim.create()
	else
		newGuideInfo.enter_for_interrupt(temp_guide_phase)
	end
end

local function set_show_guide(temp_id)
	newGuideInfo.set_guide_id(temp_id)
end

local function get_guide_state()
	return newGuideInfo.is_in_guide_state()
end

newGuideManager = {
					create = create,
					remove = remove,
					add_waiting_panel = add_waiting_panel,
					add_content_panel = add_content_panel,
					set_stencil = set_stencil,
					set_visible = set_visible,
					start_guide = start_guide,
					set_show_guide = set_show_guide,
					deal_with_leave_start_anim = deal_with_leave_start_anim,
					get_guide_state = get_guide_state
}