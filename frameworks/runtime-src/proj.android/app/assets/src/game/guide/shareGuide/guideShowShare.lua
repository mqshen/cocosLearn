guideShowShare=class()

function guideShowShare:ctor()
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou/xinshou_zhiyinguanquan.ExportJson")

	self.m_npc_rich_element_list = {}
    self.m_com_rich_element_list = {}

    --self.m_current_mask_nums = 0
	--self.m_stencil = nil
	--self.m_tips_pos = nil

	--self.m_is_playing_dialog_anim = false
	--self.m_is_playing_frame_anim = false
	self.m_last_npc_name = ""
	--self.m_dialog_id = 0
	--self.m_guide_type = 0 			--1 强制引导；2 非强制引导
	--self.m_guide_id = 0 			--引导ID

	self.MAX_MASK_NUMS = 3
end

function guideShowShare:remove()
	self.m_npc_rich_element_list = nil
	self.m_com_rich_element_list = nil

	self.m_current_mask_nums = nil
	self.m_stencil = nil
	self.m_tips_pos = nil

	self.m_is_playing_dialog_anim = nil
	self.m_is_playing_frame_anim = nil
	self.m_last_npc_name = nil
	self.m_dialog_id = nil
	self.m_guide_type = nil
	self.m_guide_id = nil
	self.MAX_MASK_NUMS = nil

	self.m_npc_continue_x = nil
	self.m_npc_continue_y = nil
	self.m_com_continue_x = nil
	self.m_com_continue_y = nil

	self.m_finger_anim = nil
	self.main_widget = nil

	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou/xinshou_zhiyinguanquan.ExportJson")
end

function guideShowShare:init_rich_text()
	local npc_rich_text = RichText:create()
	npc_rich_text:setName("rich_label")
	npc_rich_text:ignoreContentAdaptWithSize(false)
    npc_rich_text:setSize(CCSizeMake(700, 100))
    npc_rich_text:setAnchorPoint(cc.p(0, 1))
    npc_rich_text:setPosition(cc.p(-420, 0))
    local npc_img = tolua.cast(self.main_widget:getChildByName("npc_dialog_img"), "ImageView")
    npc_img:addChild(npc_rich_text)

    local common_rich_text = RichText:create()
    common_rich_text:setName("rich_label")
	common_rich_text:ignoreContentAdaptWithSize(false)
    common_rich_text:setSize(CCSizeMake(800, 70))
    common_rich_text:setAnchorPoint(cc.p(0, 1))
    common_rich_text:setPosition(cc.p(-420, 0))
    local common_img = tolua.cast(self.main_widget:getChildByName("com_dialog_img"), "ImageView")
    common_img:addChild(common_rich_text)
end

function guideShowShare:play_finger_anim(anim_name)
	self.m_finger_anim:getAnimation():play(anim_name)
end

function guideShowShare:stop_finger_anim()
	self.m_finger_anim:getAnimation():stop()
	self.m_finger_anim:setVisible(false)
end

function guideShowShare:init_finger_anim()
	local function onFrameEvent(bone,evt,originFrameIndex,currentFrameIndex)
	    if evt == "finish" then
	    	local temp_guide_info = self:get_guide_info()
	    	if temp_guide_info.ui_finger_type == 1 then
	    		self:play_finger_anim("right_anim")
			else
				self:play_finger_anim("left_anim")
			end
	    end
	end

	self.m_finger_anim = CCArmature:create("xinshou_zhiyinguanquan")
	self.m_finger_anim:setVisible(false)
	self.m_finger_anim:getAnimation():setFrameEventCallFunc(onFrameEvent)
	self.main_widget:addChild(self.m_finger_anim)
end

function guideShowShare:init_component_param()
	local com_dialog_img = tolua.cast(self.main_widget:getChildByName("com_dialog_img"), "ImageView")
	local com_continue_img = tolua.cast(com_dialog_img:getChildByName("continue_img"), "ImageView")
	self.m_com_continue_x = com_continue_img:getPositionX()
	self.m_com_continue_y = com_continue_img:getPositionY()

	local npc_dialog_img = tolua.cast(self.main_widget:getChildByName("npc_dialog_img"), "ImageView")
	local npc_continue_img = tolua.cast(npc_dialog_img:getChildByName("continue_img"), "ImageView")
	self.m_npc_continue_x = npc_continue_img:getPositionX()
	self.m_npc_continue_y = npc_continue_img:getPositionY()
end

function guideShowShare:reset_componment()
	local temp_component_list = {{"hit_img", "ImageView"}, {"finger_img", "ImageView"}, {"tips_img", "ImageView"},
								{"mask_img_1", "ImageView"}, {"mask_img_2", "ImageView"}, {"mask_img_3", "ImageView"},
								{"com_dialog_img", "ImageView"}, {"npc_dialog_img", "ImageView"}}

	local temp_component = nil
	for k,v in pairs(temp_component_list) do
		temp_component = tolua.cast(self.main_widget:getChildByName(v[1]), v[2])
		temp_component:setVisible(false)
	end

	local com_dialog_img = tolua.cast(self.main_widget:getChildByName("com_dialog_img"), "ImageView")
	local com_continue_img = tolua.cast(com_dialog_img:getChildByName("continue_img"), "ImageView")
	com_continue_img:stopAllActions()
	com_continue_img:setPosition(cc.p(self.m_com_continue_x, self.m_com_continue_y))

	local npc_dialog_img = tolua.cast(self.main_widget:getChildByName("npc_dialog_img"), "ImageView")
	local npc_continue_img = tolua.cast(npc_dialog_img:getChildByName("continue_img"), "ImageView")
	npc_continue_img:stopAllActions()
	npc_continue_img:setPosition(cc.p(self.m_npc_continue_x, self.m_npc_continue_y))

	self:stop_finger_anim()

	if mapController then
		mapController.removeTouchGround()
	end
end

function guideShowShare:stop_alpha_anim()
	--QC发现一个不知道什么情况下会出现这个值为空的情况造成DUMP，先暂时防御下
	if not self.m_current_mask_nums then
		return
	end

	for i=1, self.m_current_mask_nums do
		local temp_mask_img = tolua.cast(self.main_widget:getChildByName("mask_img_" .. i), "ImageView")
		breathAnimUtil.stop_all_anim(temp_mask_img)
	end
end

function guideShowShare:reset_param()
	self.m_current_mask_nums = 0
	self.m_stencil = CCNode:create()
	self.m_tips_pos = nil

	self.m_is_playing_dialog_anim = false
	self.m_is_playing_frame_anim = false
end

-----------------------------文本设置相关-----------------------------

function guideShowShare:play_continue_anim()
	local temp_dialog_info = dialog_cfg_info[self.m_dialog_id]

	local content_img = nil
	local start_x, start_y = nil, nil
	if temp_dialog_info.npc_state == 0 then
		content_img = tolua.cast(self.main_widget:getChildByName("com_dialog_img"), "ImageView")
		start_x = self.m_com_continue_x
		start_y = self.m_com_continue_y
	else
		content_img = tolua.cast(self.main_widget:getChildByName("npc_dialog_img"), "ImageView")
		start_x = self.m_npc_continue_x
		start_y = self.m_npc_continue_y
	end

	local continue_img = tolua.cast(content_img:getChildByName("continue_img"), "ImageView")
	continue_img:stopAllActions()
	local end_x = start_x
	local end_y = start_y - 10

	local move_to_1 = CCMoveTo:create(0.5, ccp(end_x, end_y))
	local move_to_2 = CCMoveTo:create(0.5, ccp(start_x, start_y))
	local temp_seq = cc.Sequence:createWithTwoActions(move_to_1, move_to_2)
	local temp_repeat = CCRepeatForever:create(temp_seq)
	continue_img:runAction(temp_repeat)
end

function guideShowShare:play_dialog_anim(content_img, temp_npc_state)
	local function deal_with_dialog_anim_first()
		local function deal_with_dialog_anim_finish()
			self:play_continue_anim()
			self.m_is_playing_dialog_anim = false
		end

		local temp_dialog_info = dialog_cfg_info[self.m_dialog_id]

		local content_img = nil
		if temp_dialog_info.npc_state == 0 then
			content_img = tolua.cast(self.main_widget:getChildByName("com_dialog_img"), "ImageView")
		else
			content_img = tolua.cast(self.main_widget:getChildByName("npc_dialog_img"), "ImageView")
		end
		
		local rich_text = tolua.cast(content_img:getChildByName("rich_label"), "RichText")
		local continue_img = tolua.cast(content_img:getChildByName("continue_img"), "ImageView")
		rich_text:setVisible(true)
		continue_img:setVisible(true)

		local fade_in = CCFadeIn:create(0.1)
		rich_text:runAction(tolua.cast(fade_in:copy():autorelease(), "CCActionInterval"))
		local fun_call = cc.CallFunc:create(deal_with_dialog_anim_finish)
		local temp_seq = cc.Sequence:createWithTwoActions(fade_in, fun_call)
		continue_img:runAction(temp_seq)
	end

	local continue_img = tolua.cast(content_img:getChildByName("continue_img"), "ImageView")
	continue_img:setVisible(false)

	local move_by = CCMoveBy:create(0.2, ccp(0, content_img:getSize().height/2))
	local fade_in = CCFadeIn:create(0.2)
	local temp_spawn = CCSpawn:createWithTwoActions(move_by, fade_in)
	local fun_call = cc.CallFunc:create(deal_with_dialog_anim_first)
	local temp_seq = cc.Sequence:createWithTwoActions(temp_spawn, fun_call)
	content_img:runAction(temp_seq)
	content_img:setVisible(true)
end

function guideShowShare:set_dialog_info(temp_dialog_id, temp_need_anim)
	self.m_is_playing_dialog_anim = temp_need_anim
	self.m_dialog_id = temp_dialog_id

	local temp_dialog_info = dialog_cfg_info[temp_dialog_id]
	local content_img = nil
	if temp_dialog_info.npc_state == 0 then
		content_img = tolua.cast(self.main_widget:getChildByName("com_dialog_img"), "ImageView")
	else
		content_img = tolua.cast(self.main_widget:getChildByName("npc_dialog_img"), "ImageView")

		if temp_dialog_info.icon_name ~= m_last_npc_name then
			m_last_npc_name = temp_dialog_info.icon_name
			local icon_img = tolua.cast(content_img:getChildByName("npc_img"), "ImageView")
			icon_img:loadTexture("test/res_single/" .. m_last_npc_name .. ".png", UI_TEX_TYPE_LOCAL)
		end
	end

	local rich_text = tolua.cast(content_img:getChildByName("rich_label"), "RichText")
	if temp_dialog_info.npc_state == 0 then
		for i,v in ipairs(self.m_com_rich_element_list) do
			rich_text:removeElement(v)
		end
		self.m_com_rich_element_list = {}
	else
		for ii,vv in ipairs(self.m_npc_rich_element_list) do
			rich_text:removeElement(vv)
		end
		self.m_npc_rich_element_list = {}
	end
	
	local region_name = stateData.getStateNameById(userData.getBornRegion())
	local show_content = string.gsub(temp_dialog_info.dialog_content, "city_name", region_name)
	local des_list = stringFunc.anlayerOnespot(show_content, "#", false)
    local rich_element = nil
    for i,v in ipairs(des_list) do
    	if i%2 == 0 then
	    	rich_element = RichElementText:create(1, ccc3(255,217,90), 255, v,config.getFontName(), 24)
		else
			rich_element = RichElementText:create(1, ccc3(255,255,255), 255, v,config.getFontName(), 24)
		end
		rich_text:pushBackElement(rich_element)

		if temp_dialog_info.npc_state == 0 then
			table.insert(self.m_com_rich_element_list, rich_element)
		else
			table.insert(self.m_npc_rich_element_list, rich_element)
		end
	end

	rich_text:formatText()
	local realHeight = rich_text:getRealHeight()
	rich_text:setPositionY(realHeight/2)

	if temp_need_anim then
		rich_text:setVisible(false)
		content_img:setPositionY(0)
		self:play_dialog_anim(content_img, temp_dialog_info.npc_state)
	else
		content_img:setPositionY(content_img:getSize().height/2)
		content_img:setVisible(true)
		self:play_continue_anim()
	end
end

-----------------------------显示设置相关-----------------------------

function guideShowShare:create_stencil(stencil_pos, stencil_size)
	if true then
		return
	end

	--[[
	local show_width = math.floor(stencil_size.width/2)
	local show_height = math.floor(stencil_size.height/2)

	local temp_node = CCDrawNode:create()
	temp_node:setDrawVert(cc.p(-show_width, show_height), ccp(show_width, show_height),
							ccp(show_width, -show_height), ccp(-show_width, -show_height))
    temp_node:setPosition(stencil_pos)
    temp_node:setScale(config.getgScale())
    m_stencil:addChild(temp_node)
    --]]
end

function guideShowShare:set_hit_img_info(hit_pos, hit_size)
	local hit_img = tolua.cast(self.main_widget:getChildByName("hit_img"), "ImageView")
	if hit_img:isVisible() then
		return
	end

	hit_img:setPosition(self.main_widget:convertToNodeSpace(hit_pos))
	hit_img:setSize(hit_size)
	hit_img:setVisible(true)
end

function guideShowShare:set_mask_area(temp_pos, show_size, hit_size)
	self.m_current_mask_nums = self.m_current_mask_nums + 1
	if self.m_current_mask_nums > self.MAX_MASK_NUMS then
		return
	end

	local mask_img = tolua.cast(self.main_widget:getChildByName("mask_img_" .. self.m_current_mask_nums), "ImageView")
	mask_img:setPosition(self.main_widget:convertToNodeSpace(temp_pos))
	mask_img:setSize(CCSize(show_size.width + 36*2, show_size.height + 38*2))

	self:create_stencil(temp_pos, show_size)
	self:set_hit_img_info(temp_pos, hit_size)

	if not self.m_tips_pos then
		local show_pos = self.main_widget:convertToNodeSpace(temp_pos)
		self.m_tips_pos = {show_pos.x, show_pos.y, hit_size.width, hit_size.height}
	end
end

function guideShowShare:organize_ui_mask(temp_main_class, ui_mask_refer_info, ui_mask_pos_info)
	local ui_widget = self:get_ui_widget(temp_main_class)
	if not ui_widget then
		return
	end

	local ui_refer_list = stringFunc.anlayerOnespot(ui_mask_refer_info, ";", false)
	local ui_pos_list = stringFunc.anlayerMsg(ui_mask_pos_info)
	for i,v in ipairs(ui_refer_list) do
		local mask_widget = ui_widget
		if v ~= "self" then
			local ui_path_list = stringFunc.anlayerOnespot(v, "/", false)
			for ii,vv in ipairs(ui_path_list) do
				mask_widget = mask_widget:getChildByName(vv)
			end
		end
		
		local mask_pos = nil
		if ui_pos_list[i][5] == 0 then
			mask_pos = mask_widget:convertToWorldSpace(cc.p(ui_pos_list[i][1], ui_pos_list[i][2]))
		else
			mask_pos = mask_widget:convertToWorldSpaceAR(cc.p(ui_pos_list[i][1], ui_pos_list[i][2]))
		end

		local mask_size = CCSizeMake(ui_pos_list[i][3], ui_pos_list[i][4])
		self:set_mask_area(mask_pos, mask_size, mask_size)
	end
end

function guideShowShare:get_finger_pos_info(temp_main_class, ui_mask_refer_info, ui_mask_pos_info)
	local ui_widget = self:get_ui_widget(temp_main_class)
	if ui_mask_refer_info ~= "self" then
		local ui_path_list = stringFunc.anlayerOnespot(ui_mask_refer_info, "/", false)
		for k,v in pairs(ui_path_list) do
			ui_widget = ui_widget:getChildByName(v)
		end
	end
	
	local ui_pos_list = stringFunc.anlayerOnespot(ui_mask_pos_info, ",", true)
	local mask_pos = nil
	if ui_pos_list[5] == 0 then
		mask_pos = ui_widget:convertToWorldSpace(cc.p(ui_pos_list[1], ui_pos_list[2]))
	else
		mask_pos = ui_widget:convertToWorldSpaceAR(cc.p(ui_pos_list[1], ui_pos_list[2]))
	end

	local mask_size = CCSizeMake(ui_pos_list[3], ui_pos_list[4])

	return mask_pos, mask_size
end

function guideShowShare:organize_finger_mask(temp_guide_info, temp_main_class, temp_finger_type)
	local mask_pos, mask_size, hit_size = nil, nil, nil
	if temp_guide_info.map_mask_area == 0 then
		if temp_guide_info.ui_mask_reference == "" then
			mask_pos = ccp(config.getWinSize().width/2, config.getWinSize().height/2)
			hit_size = CCSize(200, 100)
		else
			mask_pos, hit_size = self:get_finger_pos_info(temp_main_class, temp_guide_info.ui_mask_reference, temp_guide_info.ui_mask_pos)
		end
	else
		mask_pos, mask_size, hit_size = self:get_map_area(temp_main_class)
	end

	self:create_stencil(mask_pos, hit_size)
	self:set_hit_img_info(mask_pos, hit_size)

	local show_pos = self.main_widget:convertToNodeSpace(mask_pos)
	self.m_finger_anim:setPosition(show_pos)
	if temp_finger_type == 1 then
		self.m_finger_anim:getAnimation():play("right_anim")
		self.m_tips_pos = {show_pos.x + 45, show_pos.y - 45, 90, 90}
	else
		self.m_finger_anim:getAnimation():play("left_anim")
		self.m_tips_pos = {show_pos.x - 45, show_pos.y - 45, 90, 90}
	end
	self.m_finger_anim:setVisible(true)
end

function guideShowShare:set_mask_show_info()
	local temp_guide_info = self:get_guide_info()
	local temp_ui_name = temp_guide_info.ui_id_name
	if temp_ui_name == "" then
		return false
	end

	local temp_main_class = uiPanelInfo.get_main_class_by_index(uiIndexDefine[temp_ui_name])
	if not temp_main_class then
		return false
	end

	if temp_guide_info.ui_finger_type == 0 then
		if temp_guide_info.ui_mask_reference == "" then
			return false
		else
			self:organize_ui_mask(temp_main_class, temp_guide_info.ui_mask_reference, temp_guide_info.ui_mask_pos)
		end
	else
		self:organize_finger_mask(temp_guide_info, temp_main_class, temp_guide_info.ui_finger_type)
	end

	return true
end

function guideShowShare:set_dir_show_info()
	local temp_guide_info = self:get_guide_info()
	if temp_guide_info.tips_dir == 0 then
		return
	end

	local temp_dir_sign = temp_guide_info.tips_dir

	local temp_tips_img = tolua.cast(self.main_widget:getChildByName("tips_img"), "Button")
	local content_txt = tolua.cast(temp_tips_img:getChildByName("content_label"), "Label")
	content_txt:setText(temp_guide_info.tips_content)
	temp_tips_img:setSize(CCSize(content_txt:getSize().width + 60, temp_tips_img:getSize().height))

	local img_pos_x, img_pos_y = nil, nil
	-- 箭头指向： 上下左右
	local pos_offset, dir_offset = 20, 50
	local move_x_dis, move_y_dis = 0, 0
	if temp_dir_sign == 1 then
		img_pos_y = self.m_tips_pos[2] + self.m_tips_pos[4]/2 + temp_tips_img:getSize().height/2 + pos_offset + dir_offset
		temp_tips_img:setPosition(cc.p(self.m_tips_pos[1], img_pos_y))
		move_y_dis = -1 * dir_offset
	elseif temp_dir_sign == 2 then
		img_pos_y = self.m_tips_pos[2] - self.m_tips_pos[4]/2 - temp_tips_img:getSize().height/2 - pos_offset - dir_offset
		temp_tips_img:setPosition(cc.p(self.m_tips_pos[1], img_pos_y))
		move_y_dis = dir_offset
	elseif temp_dir_sign == 3 then
		img_pos_x = self.m_tips_pos[1] - self.m_tips_pos[3]/2 - temp_tips_img:getSize().width/2 - pos_offset - dir_offset
		temp_tips_img:setPosition(cc.p(img_pos_x, self.m_tips_pos[2]))
		move_x_dis = dir_offset
	elseif temp_dir_sign == 4 then
		img_pos_x = self.m_tips_pos[1] + self.m_tips_pos[3]/2 + temp_tips_img:getSize().width/2 + pos_offset + dir_offset
		temp_tips_img:setPosition(cc.p(img_pos_x, self.m_tips_pos[2]))
		move_x_dis = -1 * dir_offset
	end

	local move_by = CCMoveBy:create(0.3, ccp(move_x_dis, move_y_dis))
	local fade_in = CCFadeIn:create(0.3)
	local temp_spawn = CCSpawn:createWithTwoActions(move_by, fade_in)
	temp_tips_img:runAction(temp_spawn)

	temp_tips_img:setVisible(true)
end

function guideShowShare:play_frame_light_anim()
	if self.m_current_mask_nums == 0 then
		self.m_is_playing_frame_anim = false
		return
	end

	local function play_frame_anim_finish()
		self.m_is_playing_frame_anim = false

		for i=1, self.m_current_mask_nums do
			local temp_mask_img = tolua.cast(self.main_widget:getChildByName("mask_img_" .. i), "ImageView")
			breathAnimUtil.start_anim(temp_mask_img, true, 0, 255, 0.4, 0)
		end
	end

	local scale_to = CCScaleTo:create(0.3, 1)
	for i=1,self.m_current_mask_nums do
		local temp_mask_img = tolua.cast(self.main_widget:getChildByName("mask_img_" .. i), "ImageView")
		temp_mask_img:setScale(1.5)
		if i == self.m_current_mask_nums then
			local fun_call = cc.CallFunc:create(play_frame_anim_finish)
			local temp_seq = cc.Sequence:createWithTwoActions(scale_to, fun_call)
			temp_mask_img:runAction(temp_seq)
		else
			temp_mask_img:runAction(tolua.cast(scale_to:copy():autorelease(), "CCActionInterval"))
		end
		temp_mask_img:setVisible(true)
	end
end

function guideShowShare:get_map_area(temp_main_class)
	local temp_guide_info = self:get_guide_info()
	local mask_pos, mask_size, hit_size = nil, nil, nil

	if temp_guide_info.map_mask_area == 2 then
		if self.m_guide_type == 1 then
			mask_pos, mask_size, hit_size = temp_main_class.get_map_mask_area(self.m_guide_id, true)
		else
			mask_pos, mask_size, hit_size = temp_main_class.get_com_map_mask_area(self.m_guide_id, true)
		end
	else
		if self.m_guide_type == 1 then
			mask_pos, mask_size, hit_size = temp_main_class.get_map_mask_area(self.m_guide_id, false)
		else
			mask_pos, mask_size, hit_size = temp_main_class.get_com_map_mask_area(self.m_guide_id, false)
		end
	end

	return mask_pos, mask_size, hit_size
end

function guideShowShare:get_ui_widget(temp_main_class)
	if self.m_guide_type == 1 then
		return temp_main_class.get_guide_widget(self.m_guide_id)
	else
		return temp_main_class.get_com_guide_widget(self.m_guide_id)
	end
end

function guideShowShare:get_guide_info()
	if self.m_guide_id ~= 0 then
		if self.m_guide_type == 1 then
			return guide_cfg_info[self.m_guide_id]
		else
			return com_guide_cfg_info[self.m_guide_id]
		end
	end

	return nil
end

function guideShowShare:set_guide_id(new_id)
	self.m_guide_id = new_id

	if self:set_mask_show_info() then
		self.m_is_playing_frame_anim = true
		self:set_dir_show_info()
		self:play_frame_light_anim()
	else
		--local temp_node = CCDrawNode:create()
    	--temp_node:drawDot(cc.p(1, 1), 1, ccc4f(1, 0, 0, 1))
    	--temp_node:setPosition(cc.p(1, 1))
    	--m_stencil:addChild(temp_node)
	end

	local temp_node = CCDrawNode:create()
	temp_node:drawDot(cc.p(1, 1), 1, ccc4f(1, 0, 0, 1))
	temp_node:setPosition(cc.p(1, 1))
	self.m_stencil:addChild(temp_node)
end

function guideShowShare:create(temp_guide_type)
	self.m_guide_type = temp_guide_type

	self.main_widget = GUIReader:shareReader():widgetFromJsonFile("test/newGuideUI.json")
	self.main_widget:setTag(999)
	self.main_widget:setScale(config.getgScale())
	self.main_widget:ignoreAnchorPointForPosition(false)
	self.main_widget:setAnchorPoint(cc.p(0, 0))
	self.main_widget:setPosition(cc.p(0, 0))

	self:init_rich_text()
	self:init_finger_anim()
	self:init_component_param()

	return self.main_widget


	--self.x = temp_value
	--self:init_rich_text()
end

function guideShowShare:is_playing_anim()
	return self.m_is_playing_frame_anim or self.m_is_playing_dialog_anim
end

function guideShowShare:get_stencil()
	return self.m_stencil
end

function guideShowShare:get_main_widget()
	return self.main_widget
end