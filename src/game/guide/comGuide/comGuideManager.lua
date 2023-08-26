--[[
非强制引导接口:
单纯图片提示的 
	ResDefineUtil.tips_res

	require("game/guide/shareGuide/picTipsManager")
	picTipsManager.create(1)
常规引导样式：
	comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2001)
--]]

local m_guide_layer = nil 			--内容显示层
local m_clipping_node = nil

local m_init_or_not = nil 				--是否初始化相关显示组件

local function on_guide_touch(eventType, x, y)
	if eventType == "began" then
		if comGuideInfo then
			return comGuideInfo.deal_with_touch_began(x, y)
		else
			return false
		end
	elseif eventType == "ended" then
		if comGuideInfo then
			comGuideInfo.deal_with_touch_ended(x, y)
		end

		return true
	else
		return true
	end
end

local function remove()
	if m_guide_layer then
		comGuideInfo.remove()

		m_clipping_node = nil
		m_guide_layer:removeFromParentAndCleanup(true)
		m_guide_layer = nil
	end

	m_init_or_not = nil
end

local function add_content_panel(content_touch_group)
	if m_clipping_node then
		m_clipping_node:addChild(content_touch_group, 1)
	end
end

local function set_stencil(new_stencil)
	if m_clipping_node then
		m_clipping_node:setStencil(new_stencil)
	end
end

local function set_visible(new_state)
	if m_guide_layer then
		m_guide_layer:setVisible(new_state)
	end
end

local function init()
	m_clipping_node = CCClippingNode:create()
	--m_clipping_node:setAlphaThreshold(0)
	m_clipping_node:setInverted(true)

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

	m_guide_layer:addChild(m_clipping_node)

	require("game/guide/comGuide/comGuideInfo")
	comGuideInfo.create()
end

local function set_show_guide(temp_guide_id)
	if not m_init_or_not then
		m_guide_layer = CCLayer:create()
		m_guide_layer:registerScriptTouchHandler(on_guide_touch, false, layerPriorityList.com_guide_priority, false)
		m_guide_layer:setTouchEnabled(true)
		m_guide_layer:setVisible(false)
		cc.Director:getInstance():getRunningScene():addChild(m_guide_layer, COM_GUIDE_SCENE)

		init()
		m_init_or_not = true
	end

	comGuideInfo.set_guide_id(temp_guide_id)
end

local function get_guide_id()
	if comGuideInfo then
		return comGuideInfo.get_guide_id()
	else
		return 0
	end
end

comGuideManager = {
					remove = remove,
					set_show_guide = set_show_guide,
					get_guide_id = get_guide_id,
					add_content_panel = add_content_panel,
					set_stencil = set_stencil,
					set_visible = set_visible
}