local skillDetailHelper = {}
local skillUtil =  require("game/utils/skillUtil")


-- textLayoutType  nil 或者 0 默认左对齐  1 居中

function skillDetailHelper.loadResearchConditionRichText(panel,paramTab,isSplitLine,splitHeight,textLayoutType)
	if not panel then return end
	panel:removeAllChildrenWithCleanup(true)

	if not splitHeight then splitHeight = 10 end
	local labelAddDesc = nil
	local pos_x = 10
	local pos_y = 0


	local text_tab_first_line = {}
	local text_tab_second_line = {}
	local real_w_fisrt_line = 0
	local real_w_second_line = 0

	local panel_w = panel:getContentSize().width
	local panel_h = panel:getContentSize().height


	if isSplitLine then 
		pos_y = panel:getSize().height - 15
	else
		pos_y = panel:getSize().height/2
	end

	local tmp_labelCondition = nil
	for k,v in ipairs(paramTab[1]) do 
		local labelCondition = Label:create()
		labelCondition:setFontSize(18)
		panel:addChild(labelCondition)
		labelCondition:setText(v[1])
		labelCondition:setPosition(cc.p(pos_x,pos_y))
		labelCondition:ignoreAnchorPointForPosition(false)
		labelCondition:setAnchorPoint(cc.p(0, 0.5))
		-- labelCondition:setColor(ccc3(255,213,110))
		labelCondition:setColor(v[2])
		pos_x = pos_x + labelCondition:getSize().width + 20



		table.insert(text_tab_first_line,labelCondition)
		real_w_fisrt_line = real_w_fisrt_line + labelCondition:getContentSize().width + 20

		tmp_labelCondition = labelCondition
	end

	if isSplitLine then 
		if tmp_labelCondition then
			pos_y = pos_y - tmp_labelCondition:getSize().height - splitHeight
		end
		pos_x = 10
	else
		if tmp_labelCondition then
			pos_x = pos_x + 20
		end
	end

	local count = 0
	for k,v in ipairs(paramTab[2]) do 
		local labelCondition = Label:create()
		labelCondition:setFontSize(18)
		panel:addChild(labelCondition)
		labelCondition:setText(v[1])
		labelCondition:setPosition(cc.p(pos_x,pos_y))
		labelCondition:ignoreAnchorPointForPosition(false)
		labelCondition:setAnchorPoint(cc.p(0, 0.5))
		-- labelCondition:setColor(ccc3(255,213,110))
		labelCondition:setColor(v[2])
		pos_x = pos_x + labelCondition:getSize().width 
		count = count + 1
		-- if splitHeight then
		-- 	if count % 2 == 0 and #paramTab[2] > 3 then 
		-- 		pos_y = pos_y - labelCondition:getSize().height - splitHeight
		-- 		pos_x = 10
		-- 	end
		-- end


		table.insert(text_tab_second_line,labelCondition)

		real_w_second_line = real_w_second_line + labelCondition:getContentSize().width 
	end


	if textLayoutType and textLayoutType == 1 then 
		if isSplitLine then 
			-- 第一行
			local pos_x = ( panel_w - real_w_fisrt_line + 20  )/2 
			for i = 1,#text_tab_first_line do 
				text_tab_first_line[i]:setPositionX(pos_x)
				pos_x = pos_x + text_tab_first_line[i]:getContentSize().width + 20
			end

			-- 第二行
			pos_x = (panel_w - real_w_second_line )/2 

			for i = 1,#text_tab_second_line do 
				text_tab_second_line[i]:setPositionX(pos_x)
				pos_x = pos_x + text_tab_second_line[i]:getContentSize().width 
			end
		else
			-- 第一行
			local pos_x = ( panel_w - real_w_fisrt_line - real_w_second_line  )/2 
			for i = 1,#text_tab_first_line do 
				text_tab_first_line[i]:setPositionX(pos_x)
				pos_x = pos_x + text_tab_first_line[i]:getContentSize().width + 20
			end

			-- 第二行
			if tmp_labelCondition then
				pos_x = pos_x + 20
			else
				pos_x = ( panel_w - real_w_fisrt_line - real_w_second_line  )/2 
			end
			for i = 1,#text_tab_second_line do 
				text_tab_second_line[i]:setPositionX(pos_x)
				pos_x = pos_x + text_tab_second_line[i]:getContentSize().width 
			end
		end
	end

	text_tab_first_line = nil
	text_tab_second_line = nil

end


function skillDetailHelper.getSkillDetailWidget(pwidget)
	if not pwidget then return end
	
	local widget = uiUtil.getConvertChildByName(pwidget,"skillDetailWidget")
	if not widget then 
		widget = GUIReader:shareReader():widgetFromJsonFile("test/jinengxiangqing_5.json")
		
		pwidget:addChild(widget)
		widget:setName("skillDetailWidget")

		local size_w = pwidget:getContentSize().width
		local size_h = pwidget:getContentSize().height

		widget:setContentSize(CCSizeMake(size_w ,size_h))
		widget:setSize(CCSizeMake(size_w ,size_h))
		local main_bg = uiUtil.getConvertChildByName(widget,"main_bg")
		main_bg:setSize(CCSizeMake(size_w ,size_h))
		main_bg:ignoreAnchorPointForPosition(false)
		main_bg:setAnchorPoint(cc.p(0, 0))
		main_bg:setPosition(cc.p(0,0))


		size_w = size_w - 10
		size_h = size_h - 10

		local scroll_panel = uiUtil.getConvertChildByName(widget,"scroll_panel")
		local main_panel = uiUtil.getConvertChildByName(scroll_panel,"main_panel")
		-- scroll_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)
		-- scroll_panel:setBackGroundColorType(LAYOUT_COLOR_SOLID)

		scroll_panel:setContentSize(CCSizeMake(size_w ,size_h))
		scroll_panel:setSize(CCSizeMake(size_w ,size_h))
		scroll_panel:setInnerContainerSize(CCSizeMake(size_w,size_h))
		scroll_panel:setPosition(cc.p(5,5))

		widget:setPosition(cc.p(0,0))
		local img_drag_flag_down = uiUtil.getConvertChildByName(widget,"down_img")
    	local img_drag_flag_up = uiUtil.getConvertChildByName(widget,"up_img")
    	img_drag_flag_down:setVisible(true)
    	img_drag_flag_up:setVisible(false)
    	
    	breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
		local function ScrollViewEvent(sender, eventType) 
	    	if eventType == SCROLLVIEW_EVENT_SCROLL_TO_TOP then 
	    		img_drag_flag_up:setVisible(false)
	    		img_drag_flag_down:setVisible(true)
	    	elseif eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
	    		img_drag_flag_up:setVisible(true)
	    		img_drag_flag_down:setVisible(false)
	    	elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
	    		if scroll_panel:getInnerContainer():getPositionY() > (-main_panel:getPositionY()) and 
					scroll_panel:getInnerContainer():getPositionY() < 0  then 
	    			img_drag_flag_down:setVisible(true)
	    			img_drag_flag_up:setVisible(true)
	    		end
	    	end
	        
		end 
	    scroll_panel:addEventListenerScrollView(ScrollViewEvent)

	end
	return widget
end

-- tipsType 1技能详情界面的tips  2技能研究的tips
function skillDetailHelper.updateInfo(pwidget,skillId,skillLv,tipsType)

	if not pwidget then return end
	if not skillId or skillId == 0 then return end
	
	local widget = uiUtil.getConvertChildByName(pwidget,"skillDetailWidget")
	if not widget then return end

	local scroll_panel = uiUtil.getConvertChildByName(widget,"scroll_panel")
	local main_panel = uiUtil.getConvertChildByName(scroll_panel,"main_panel")
	-- scroll_panel:setBackGroundColorType(LAYOUT_COLOR_SOLID)

	local condition_study = uiUtil.getConvertChildByName(main_panel,"condition_study")
	condition_study:setVisible(false)
	condition_study:setBackGroundColorType(LAYOUT_COLOR_NONE)
	
	local main_h = 0
	local pos_y = 0
	local panel_title_1 = uiUtil.getConvertChildByName(main_panel,"panel_title_1")
	local panel_title_2 = uiUtil.getConvertChildByName(main_panel,"panel_title_2")
	
	local panel_detail = uiUtil.getConvertChildByName(main_panel,"panel_detail")
	local des_panel = uiUtil.getConvertChildByName(main_panel,"des_panel")
	des_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)


	--------------------------------------- 一些提示类型的适配 ------------------------------------
	panel_title_1:setVisible(false)
	panel_title_2:setVisible(false)
	if tipsType == 1 then
		panel_title_1:setVisible(true)
	end

	if tipsType == 2 then 
		panel_title_2:setVisible(true)
	end

	-- 填充技能研究素材
    if tipsType == 3 then 
    	condition_study:setVisible(true)
    end


	
	--------------------------------------自适应----------------------------------------------------
	if condition_study:isVisible() then
		-- condition_study:ignoreAnchorPointForPosition(false)
		-- condition_study:setAnchorPoint(cc.p(0,1))

		local condition_study_size_h = condition_study:getSize().height

		local label_condition = nil
    	local label_add = nil
    	local paramTab = SkillDataModel.getSkillResearchConditionDetailTxt(skillId)
    	for i = 1,2 do 
    		label_condition = uiUtil.getConvertChildByName(condition_study,"label_condition_" ..i)
    		label_add = uiUtil.getConvertChildByName(condition_study,"label_add_" .. i)
    		-- if paramTab[i] then 
    		-- 	label_condition:setText(paramTab[i][1])
    		-- 	label_add:setText(paramTab[i][2])
    		-- else
    		-- 	label_condition:setVisible(false)
    		-- 	label_add:setVisible(false)
    		-- end
    		label_condition:setVisible(false)
    		label_add:setVisible(false)
    	end
    	local panel_condition = uiUtil.getConvertChildByName(condition_study,"panel_condition")
    	if not panel_condition then 
    		panel_condition = Layout:create()
    		panel_condition:setContentSize(CCSizeMake(condition_study:getContentSize().width,condition_study:getContentSize().height))
    		panel_condition:setSize(CCSizeMake(condition_study:getContentSize().width,condition_study:getContentSize().height))
    		condition_study:addChild(panel_condition)
    		panel_condition:setName("panel_condition")
    		panel_condition:ignoreAnchorPointForPosition(false)
    		panel_condition:setAnchorPoint(cc.p(0,1))
    		panel_condition:setPositionY(condition_study:getContentSize().height/2 + 8)
    	end
    	skillDetailHelper.loadResearchConditionRichText(panel_condition,paramTab,true,5)

    	condition_study:setPositionY(pos_y)
    	main_h = main_h + condition_study:getSize().height
		pos_y = pos_y + condition_study:getSize().height
	end

	local desc_h,desc_richText = skillUtil.loadSkillDescRichText(des_panel,skillId,skillLv,true,20)
	des_panel:setSize(CCSizeMake(pwidget:getSize().width - 20,desc_h))
	des_panel:setPositionY(pos_y)
	des_panel:setPositionX(10)

	desc_richText:setPosition(cc.p(des_panel:getSize().width/2,des_panel:getSize().height))
	main_h = main_h + desc_h + 10
	pos_y = pos_y + desc_h + 10

	panel_detail:setPositionY(pos_y)
	main_h = main_h + panel_detail:getSize().height
	pos_y = pos_y + panel_detail:getSize().height

	if panel_title_1:isVisible() then
		panel_title_1:setPositionY(pos_y)
		main_h = main_h + panel_title_1:getSize().height
		pos_y = pos_y + panel_title_1:getSize().height
	end

	if panel_title_2:isVisible() then
		panel_title_2:setPositionY(pos_y)
		main_h = main_h + panel_title_2:getSize().height
		pos_y = pos_y + panel_title_2:getSize().height
	end
	


	
	main_panel:setPositionY(0)

	local view_h = pwidget:getContentSize().height - 10
	local twidth = scroll_panel:getContentSize().width
    
	if main_h > view_h then 
        scroll_panel:setTouchEnabled(true)
        main_panel:setSize(CCSizeMake(main_panel:getSize().width,main_h))
        scroll_panel:setInnerContainerSize(CCSizeMake(twidth,main_h))
        main_panel:setPositionY(0)
    else
    	main_panel:setSize(CCSizeMake(main_panel:getSize().width,view_h))
    	scroll_panel:setInnerContainerSize(CCSizeMake(twidth,view_h))
    	main_panel:setPositionY(view_h - main_h )
        scroll_panel:setTouchEnabled(false)
    end    



    ---------------------------------------------- 填充数据-----------------------------

    local cfgSkillInfo = Tb_cfg_skill[skillId]
	local current_skill_type = cfgSkillInfo.skill_type

	

    -- 技能类型
    local label_skill_type = uiUtil.getConvertChildByName(panel_detail,"label_skill_type")
    label_skill_type:setText( heroSkillTypeName[current_skill_type] )

    -- 攻击距离
    local label_range = uiUtil.getConvertChildByName(panel_detail,"label_range")
    if current_skill_type == 4 then
		label_range:setText("--")
	else
		label_range:setText(tostring(cfgSkillInfo.hit_range))
	end


    -- 攻击目标类型
    local label_target = uiUtil.getConvertChildByName(panel_detail,"label_target")
    local detail_info = Tb_cfg_skill_detail[cfgSkillInfo.main_detail]
    local temp_s1, temp_s2 = get_skill_attack_des(detail_info.attack_type, detail_info.select_type, detail_info.attack_max)
	label_target:setText(temp_s1 .. temp_s2)

    -- 发动几率
    local label_rate = uiUtil.getConvertChildByName(panel_detail,"label_rate")
    if current_skill_type == 1 or current_skill_type == 2 then 
        label_rate:setText("--")
    else
        local rate_val = math.floor(skillUtil.getSkillPerformRate(skillId,skillLv) * 10) / 10
        label_rate:setText( rate_val .. "%")
    end 

    
    -- 兵种类型限制
    -- print(skillLimitForCounsellor[cfgSkillInfo.counselor + 1])
    local img_soldier_type = nil
    for i = 1,3 do 
    	img_soldier_type =  uiUtil.getConvertChildByName(panel_detail,"img_soldier_type_" .. i)
    	img_soldier_type:setVisible(false)
    end
    
    local cfgSkillResearchInfo = Tb_cfg_skill_research[skillId] 
    if cfgSkillResearchInfo then 
    	if #cfgSkillResearchInfo.allow_type == 0 then 
    		for i = 1,3 do 
		    	img_soldier_type =  uiUtil.getConvertChildByName(panel_detail,"img_soldier_type_" .. i)
		    	img_soldier_type:setVisible(true)
		    end
    	else
	    	for k,v in ipairs(cfgSkillResearchInfo.allow_type) do
	    		img_soldier_type =  uiUtil.getConvertChildByName(panel_detail,"img_soldier_type_" .. v)
    			if img_soldier_type then 
    				img_soldier_type:setVisible(true)
    			end
	    	end
	    end
    end

    local pos_x = 395
    for i = 1,3 do 
    	img_soldier_type =  uiUtil.getConvertChildByName(panel_detail,"img_soldier_type_" .. i)
    	if img_soldier_type:isVisible() then 
    		img_soldier_type:setPositionX(pos_x)
    		pos_x = pos_x + img_soldier_type:getSize().width
    	end
    end
end


return skillDetailHelper