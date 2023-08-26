local m_show_img = nil
local m_tips_layer = nil
local m_offset_index = nil

local function remove()
	if m_tips_layer then
		m_show_img = nil

		m_tips_layer:removeFromParentAndCleanup(true)
		m_tips_layer = nil

		if m_offset_index == 7 then
			-- nothing
		elseif m_offset_index == 8 then
			require("game/guide/newGuide/guideWaitingManager")
			guideWaitingManager.create(guide_waiting_list.KILL_ZB)

			if guideSmokeAnim then
				guideSmokeAnim.remove()
			end
		else
			newGuideInfo.enter_next_guide()
		end

		m_offset_index = nil
	end
end

local function deal_with_anim_finish()
	remove()
end

local function play_anim()
	local move_by = CCMoveBy:create(0.5, ccp(0, 60))
	local fun_call = cc.CallFunc:create(deal_with_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(move_by, fun_call)
	m_show_img:runAction(temp_seq)
end

local function create(offset_index)
	if m_tips_layer then
		return
	end
	m_offset_index = offset_index

	m_show_img = ImageView:create()
	m_show_img:loadTexture(ResDefineUtil.guide_res[10], UI_TEX_TYPE_PLIST)
	m_show_img:setScale(config.getgScale())
	
	local temp_point = mapMessageUI.get_map_guide_pos_info(m_offset_index)
	m_show_img:setPosition(temp_point)

	m_tips_layer = TouchGroup:create()
	m_tips_layer:addWidget(m_show_img)
	newGuideManager.add_waiting_panel(m_tips_layer)

	play_anim()
end

guideTipsManager = {
					create = create
}