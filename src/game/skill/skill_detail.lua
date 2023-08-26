module("SkillDetail", package.seeall)
-- 技能详情(学习 强化 研究详情)
-- 类名 SkillDetail
-- json名：  jinengxiangqing.json
-- 配置ID:	UI_SKILL_DETAIL


SkillDetail.VIEW_TYPE_STUDY = 1		-- 技能研究
SkillDetail.VIEW_TYPE_LEARN = 2		-- 学习 
SkillDetail.VIEW_TYPE_STRENGTH = 3  -- 强化

local SkillOpreateObserver = require("game/skill/skill_operate_observer")
local skillDetailHelper = require("game/skill/skill_detail_helper")

local skillItemHelper = require("game/skill/skill_item_helper")

local m_pSkillItemProgressBg = nil
local m_pMainLayer = nil
local m_closeCallBack = nil
local m_iOptype = nil
local m_bIsEnemy = nil

local m_bIsNormalMax = nil	-- 正常操作达到上限边界（强化时 等级已满）
local m_bIsStudyMax = nil	--研究达到上限边界（研究数）
local m_bIsLockOperate = nil  -- 锁定操作

local m_iSkillItemLayoutType = nil



local m_switchBtnLeft = nil
local m_switchBtnRight = nil
local m_skillIdListToShow = nil
local m_skillIdSwitchIndx = nil
local m_skillIdSwitchIndxNext = nil
local m_bIsSwitching = nil

-- 从玩家技能库获取
local m_iSkillId = nil
local m_iSkillLv = nil

-- 从hero表获取
local m_iMainCardId = nil 
local m_iSkillIndx = nil

-- 技能强化的数据 m_iMainCardId m_iSkillIndx  
-- 技能学习的数据 m_iMainCardId m_iSkillIndx m_iSkillId
-- 技能研究的数据 m_iSkillId 

local function do_remove_self()
	if m_pMainLayer then
		
		if m_switchBtnLeft then 
			m_switchBtnLeft:removeFromParentAndCleanup(true)
			m_switchBtnLeft = nil
		end

		if m_switchBtnRight then 
			m_switchBtnRight:removeFromParentAndCleanup(true)
			m_switchBtnRight = nil
		end


		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil

		uiManager.remove_self_panel(uiIndexDefine.UI_SKILL_DETAIL)

		if m_closeCallBack then 
        	m_closeCallBack()
        end
        m_bIsEnemy = nil
        m_iOptype = nil
        m_iSkillId = nil
        m_iSkillLv = nil
        m_bIsNormalMax = nil
        m_bIsStudyMax = nil
        m_iSkillItemLayoutType = nil
        m_bIsLockOperate = nil
        m_iMainCardId = nil
        m_iSkillIndx  = nil
        UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, SkillDetail.reloadData)
        UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, SkillDetail.reloadData)
        UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, SkillDetail.reloadData)
	    -- UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, SkillDetail.reloadData)
	    -- UIUpdateManager.remove_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, SkillOverview.reload_data)


	    if SkillOverview and SkillOverview.updateTouchEnable then 
			SkillOverview.updateTouchEnable(true)
		end

	end
end

function remove_self(closeEffect)
    if not m_pMainLayer then return end
    if m_pSkillItemProgressBg then 
		m_pSkillItemProgressBg:stopAllActions()
		m_pSkillItemProgressBg:removeFromParentAndCleanup(true)
		m_pSkillItemProgressBg = nil
	end
	if closeEffect then 
		do_remove_self()
		return
	end
    uiManager.hideConfigEffect(uiIndexDefine.UI_SKILL_DETAIL,m_pMainLayer,do_remove_self) 
end


function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")
	if main_bg:hitTest(cc.p(x,y)) or m_switchBtnLeft:hitTest(cc.p(x,y)) or m_switchBtnRight:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end

	
end


local function updateLayout()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end

	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")
	local skill_item_bg = uiUtil.getConvertChildByName(main_bg,"skill_item_bg")

	local skill_item = uiUtil.getConvertChildByName(main_bg,"skill_item")
	-- skill_item:setBackGroundColorType(LAYOUT_COLOR_SOLID)
	skill_item:ignoreAnchorPointForPosition(false)
	skill_item:setAnchorPoint(cc.p(0.5,0.5))
	local skillItemWidget = uiUtil.getConvertChildByName(skill_item,"skillItemWidget" )

	local btn_op_delete = uiUtil.getConvertChildByName(main_bg,"btn_op_delete")
	
	local skillInfo = SkillDataModel.getUserSkillInfoById(m_iSkillId)

	if m_iOptype == SkillDetail.VIEW_TYPE_STUDY then 

		skillItemWidget:setScale(1.2)
		local posx = skill_item_bg:getPositionX() 
		local posy = skill_item_bg:getPositionY() + (skill_item_bg:getSize().height - skill_item:getSize().height)/2 - 10
		skill_item:setPosition(cc.p(posx,posy))	
		local img_hero_null = uiUtil.getConvertChildByName(main_bg,"img_hero_null")
		local img_hero_list = uiUtil.getConvertChildByName(main_bg,"img_hero_list")
		img_hero_null:setVisible(false)
		img_hero_list:setVisible(false)

		if skillInfo and skillInfo.study_progress == 100 then 
			m_bIsStudyMax = true
		end

		local ColorUtil = require("game/utils/color_util")
		if skillInfo and skillInfo.hero_list_learned and #skillInfo.hero_list_learned >0 then 
			img_hero_list:setVisible(true)
			local label_hero_name = nil
			for i = 1 ,5 do 
				label_hero_name = uiUtil.getConvertChildByName(img_hero_list,"label_hero_name_" .. i)
				label_hero_name:setVisible(false)
			end
			local cfgHeroInfo = nil
			local heroInfo = nil
			for i,v in ipairs(skillInfo.hero_list_learned) do 
				heroInfo = heroData.getHeroInfo(v)
				if heroInfo then 
					cfgHeroInfo = Tb_cfg_hero[heroInfo.heroid]
				end
				if cfgHeroInfo then 
					label_hero_name = uiUtil.getConvertChildByName(img_hero_list,"label_hero_name_" .. i)
					label_hero_name:setVisible(true)
					label_hero_name:setText(ColorUtil.getHeroNameWrite(cfgHeroInfo.heroid ))
					label_hero_name:setColor(ColorUtil.getHeroColor(cfgHeroInfo.quality))   
				end
			end
		else
			img_hero_null:setVisible(true)
		end


		if m_bIsStudyMax  then 
			local condition_max = uiUtil.getConvertChildByName(main_bg,"condition_max")
			condition_max:setVisible(true)
			--TODOTK 收集中文
			local label_tips = uiUtil.getConvertChildByName(condition_max,"label_tips")
			label_tips:setText("该战法已研究成功，可配置" .. skillInfo.learn_count_max .. "个武将")
		else
			local condition_study = uiUtil.getConvertChildByName(main_bg,"condition_study")
			condition_study:setVisible(true)
			

			local panel_text = uiUtil.getConvertChildByName(condition_study,"panel_text")
			

			local paramTab = SkillDataModel.getSkillResearchConditionDetailTxt(m_iSkillId)
			skillDetailHelper.loadResearchConditionRichText(panel_text,paramTab)

			if not m_bIsLockOperate then 
				local btn_op_study = uiUtil.getConvertChildByName(main_bg,"btn_op_study")
				btn_op_study:setVisible(true)
				btn_op_study:setTouchEnabled(true)

			end
		end
	elseif m_iOptype == SkillDetail.VIEW_TYPE_LEARN then 
		skillItemWidget:setScale(1.5)
		skill_item:setPosition(cc.p(skill_item_bg:getPositionX(),skill_item_bg:getPositionY() - 20))

		local condition_learn = uiUtil.getConvertChildByName(main_bg,"condition_learn")
		condition_learn:setVisible(true)
		if not m_bIsLockOperate then 
			local btn_op_learn = uiUtil.getConvertChildByName(main_bg,"btn_op_learn")
			btn_op_learn:setVisible(true)
			btn_op_learn:setTouchEnabled(true)
			if SkillDataModel.isSkillLearnedByHeroId(m_iMainCardId,m_iSkillId) then 
				btn_op_learn:setBright(false)
			else
				btn_op_learn:setBright(true)
			end
		end

	elseif m_iOptype == SkillDetail.VIEW_TYPE_STRENGTH then 

		skillItemWidget:setScale(1.5)
		skill_item:setPosition(cc.p(skill_item_bg:getPositionX(),skill_item_bg:getPositionY() - 20))

		if m_iSkillLv >= SKILL_LEVEL_MAX then 
			m_bIsNormalMax = true
		end
		if m_bIsEnemy then 
			local condition_enemy = uiUtil.getConvertChildByName(main_bg,"condition_enemy")
			condition_enemy:setVisible(true)
		elseif m_bIsNormalMax then 
			local condition_max = uiUtil.getConvertChildByName(main_bg,"condition_max")
			condition_max:setVisible(true)
			--TODOTK 收集中文
			local label_tips = uiUtil.getConvertChildByName(condition_max,"label_tips")
			label_tips:setText("该战法等级已经达到上限")
		else
			local condition_strength = uiUtil.getConvertChildByName(main_bg,"condition_strength")
			condition_strength:setVisible(true)
			local btn_op_strength = uiUtil.getConvertChildByName(main_bg,"btn_op_strength")
			local panel_cost_2 = uiUtil.getConvertChildByName(main_bg,"panel_cost_2")
			local label_num = uiUtil.getConvertChildByName(panel_cost_2,"label_num")
			if not m_bIsLockOperate then 
				btn_op_strength:setVisible(true)
				btn_op_strength:setTouchEnabled(true)

				
				panel_cost_2:setVisible(true)

				
				label_num:setText(SkillDataModel.getUserSkillValue())
			end

			local label_lv_cur = uiUtil.getConvertChildByName(condition_strength,"label_lv_cur")
			label_lv_cur:setText(languagePack["lv"] .. m_iSkillLv)

			local label_lv_next = uiUtil.getConvertChildByName(condition_strength,"label_lv_next")
			label_lv_next:setText(languagePack["lv"] .. (m_iSkillLv + 1))


			local cfgSkillInfo = Tb_cfg_skill[m_iSkillId]
			local cfgSkillLvInfo = Tb_cfg_skill_level[cfgSkillInfo.skill_quality*100 + m_iSkillLv + 1]
			local cost = 0 
			if cfgSkillLvInfo then 
				cost = cfgSkillLvInfo.exp
			end

			local label_cost = uiUtil.getConvertChildByName(condition_strength,"label_cost")
			label_cost:setText(cost)
			if SkillDataModel.getUserSkillValue() < cost then 
				btn_op_strength:setBright(false)
				label_num:setColor(ccc3(255,0,0))
				btn_op_strength:setTitleColor(ccc3(40,40,40))
			else
				btn_op_strength:setBright(true)
				label_num:setColor(ccc3(255,255,255))
				btn_op_strength:setTitleColor(ccc3(83,18,40))
			end
		end
	end

	if not m_iSkillId  or m_iSkillId == 0 then 
		btn_op_delete:setVisible(false)
		btn_op_delete:setTouchEnabled(false)
	else
		btn_op_delete:setVisible(true)
		btn_op_delete:setTouchEnabled(true)
	end

	if m_iOptype == SkillDetail.VIEW_TYPE_LEARN then 
		btn_op_delete:setVisible(false)
		btn_op_delete:setTouchEnabled(false)
	end

	if m_bIsLockOperate then 
		btn_op_delete:setVisible(false)
		btn_op_delete:setTouchEnabled(false)
	end

	if m_bIsEnemy then 
		btn_op_delete:setVisible(false)
		btn_op_delete:setTouchEnabled(false)
	end
	if m_iSkillIndx and m_iSkillIndx == 1 then 
		btn_op_delete:setVisible(false)
		btn_op_delete:setTouchEnabled(false)
	end


end

local function autoSizeLayout()
	
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end
	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")


	local size_w = 850 
	local size_h_1 = 518
	local size_h_2 = 420
	
	local size_view_h = nil
	if m_bIsStudyMax or m_bIsNormalMax or m_bIsLockOperate or m_bIsEnemy then 
		size_view_h = size_h_2
	else
		size_view_h = size_h_1
	end
	
	
	local panel_bg = uiUtil.getConvertChildByName(main_bg,"Panel_691781_0")
	-- panel_bg:setBackGroundColorType(LAYOUT_COLOR_SOLID)
	panel_bg:ignoreAnchorPointForPosition(false)
	panel_bg:setAnchorPoint(cc.p(0,1))
	panel_bg:setPositionY(0)


	main_bg:setSize(CCSizeMake(size_w,size_view_h))
	panel_bg:setSize(CCSizeMake(size_w - 40,size_view_h - 30))
	panel_bg:setPosition(cc.p( 20 , - 15))
	main_bg:setPositionY(mainWidget:getSize().height/2  + main_bg:getSize().height/2)
end


local function disableAllLayout()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end

	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")

	-- 技能研究
	local btn_op_study = uiUtil.getConvertChildByName(main_bg,"btn_op_study")
	local img_hero_null = uiUtil.getConvertChildByName(main_bg,"img_hero_null")
	local img_hero_list = uiUtil.getConvertChildByName(main_bg,"img_hero_list")
	local condition_study = uiUtil.getConvertChildByName(main_bg,"condition_study")
	btn_op_study:setVisible(false)
	btn_op_study:setTouchEnabled(false)
	img_hero_null:setVisible(false)
	img_hero_list:setVisible(false)
	condition_study:setVisible(false)

	-- 技能学习
	local btn_op_learn = uiUtil.getConvertChildByName(main_bg,"btn_op_learn")
	local condition_learn = uiUtil.getConvertChildByName(main_bg,"condition_learn")
	btn_op_learn:setVisible(false)
	btn_op_learn:setTouchEnabled(false)
	condition_learn:setVisible(false)

	-- 技能强化
	local btn_op_strength = uiUtil.getConvertChildByName(main_bg,"btn_op_strength")
	local btn_op_delete = uiUtil.getConvertChildByName(main_bg,"btn_op_delete")
	local condition_strength = uiUtil.getConvertChildByName(main_bg,"condition_strength")
	local condition_max = uiUtil.getConvertChildByName(main_bg,"condition_max")
	local panel_cost_2 = uiUtil.getConvertChildByName(main_bg,"panel_cost_2")
	btn_op_strength:setVisible(false)
	btn_op_strength:setTouchEnabled(false)
	btn_op_delete:setVisible(false)
	btn_op_delete:setTouchEnabled(false)
	condition_strength:setVisible(false)
	condition_max:setVisible(false)
	panel_cost_2:setVisible(false)

	local condition_enemy = uiUtil.getConvertChildByName(main_bg,"condition_enemy")
	condition_enemy:setVisible(false)
end

function reloadData()
	if not m_pMainLayer then return end
	if not m_pSkillItemProgressBg then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end
	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")
	local skill_item = uiUtil.getConvertChildByName(main_bg,"skill_item")
	local skillItemWidget = uiUtil.getConvertChildByName(skill_item,"skillItemWidget" )
	skillItemHelper.loadSkillInfo(skillItemWidget,m_pSkillItemProgressBg, m_iSkillId,m_iSkillItemLayoutType,m_iSkillLv)
	
	local cfgSkillInfo = Tb_cfg_skill[m_iSkillId]
	local label_sk_name = uiUtil.getConvertChildByName(main_bg,"label_sk_name")
	label_sk_name:setText(cfgSkillInfo.name)

	
	local panel_skill_detail = uiUtil.getConvertChildByName(main_bg,"panel_skill_detail")
	local skillDetailWidget = skillDetailHelper.getSkillDetailWidget(panel_skill_detail)
    skillDetailHelper.updateInfo(panel_skill_detail,m_iSkillId,m_iSkillLv,1)


    m_bIsNormalMax = nil
    m_bIsStudyMax = nil


   
    if m_iOptype == SkillDetail.VIEW_TYPE_STRENGTH and not m_bIsLockOperate  then 
    	local skillList = heroData.getHeroSkillList(m_iMainCardId)
		m_iSkillId = skillList[m_iSkillIndx][1]
		m_iSkillLv = skillList[m_iSkillIndx][2]
	end

    disableAllLayout()
	updateLayout()
	autoSizeLayout()
end


local function initLayout()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end
	mainWidget:setTouchEnabled(false)
	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")
	main_bg:setTouchEnabled(true)

	local condition_enemy = uiUtil.getConvertChildByName(main_bg,"condition_enemy")
	condition_enemy:setVisible(false)
	-- 技能研究
	local btn_op_study = uiUtil.getConvertChildByName(main_bg,"btn_op_study")
	local img_hero_null = uiUtil.getConvertChildByName(main_bg,"img_hero_null")
	local img_hero_list = uiUtil.getConvertChildByName(main_bg,"img_hero_list")
	local condition_study = uiUtil.getConvertChildByName(main_bg,"condition_study")
	local panel_text = uiUtil.getConvertChildByName(condition_study,"panel_text")
	panel_text:setBackGroundColorType(LAYOUT_COLOR_NONE)
	btn_op_study:setVisible(false)
	btn_op_study:setTouchEnabled(false)
	img_hero_null:setVisible(false)
	img_hero_list:setVisible(false)
	condition_study:setVisible(false)

	-- 技能学习
	local btn_op_learn = uiUtil.getConvertChildByName(main_bg,"btn_op_learn")
	local condition_learn = uiUtil.getConvertChildByName(main_bg,"condition_learn")
	btn_op_learn:setVisible(false)
	btn_op_learn:setTouchEnabled(false)
	condition_learn:setVisible(false)

	-- 技能强化
	local btn_op_strength = uiUtil.getConvertChildByName(main_bg,"btn_op_strength")
	local btn_op_delete = uiUtil.getConvertChildByName(main_bg,"btn_op_delete")
	local condition_strength = uiUtil.getConvertChildByName(main_bg,"condition_strength")
	local condition_max = uiUtil.getConvertChildByName(main_bg,"condition_max")
	local panel_cost_2 = uiUtil.getConvertChildByName(main_bg,"panel_cost_2")
	btn_op_strength:setVisible(false)
	btn_op_strength:setTouchEnabled(false)
	btn_op_delete:setVisible(false)
	btn_op_delete:setTouchEnabled(false)
	condition_strength:setVisible(false)
	condition_max:setVisible(false)
	panel_cost_2:setVisible(false)

	local btn_close = uiUtil.getConvertChildByName(main_bg,"btn_close")
	local skill_item = uiUtil.getConvertChildByName(main_bg,"skill_item")
	local panel_skill_detail = uiUtil.getConvertChildByName(main_bg,"panel_skill_detail")
	skill_item:setBackGroundColorType(LAYOUT_COLOR_NONE)
	panel_skill_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)
	btn_close:setVisible(true)
	btn_close:setTouchEnabled(true)
	btn_close:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then
            remove_self()
    	end
    end)

	local skillItemWidget  = uiUtil.getConvertChildByName(skill_item,"skillItemWidget" )

	if not skillItemWidget then 
        skillItemWidget,m_pSkillItemProgressBg = skillItemHelper.createWidgetItem(true)
        skillItemWidget:setName("skillItemWidget")
        skill_item:addChild(skillItemWidget)
        skillItemWidget:ignoreAnchorPointForPosition(false)
		skillItemWidget:setAnchorPoint(cc.p(0.5,0.5))
		skillItemWidget:setPosition(cc.p(skill_item:getSize().width/2,skill_item:getSize().height/2))
    end
    
    --强化技能
    btn_op_strength:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		
    		local cfgSkillInfo = Tb_cfg_skill[m_iSkillId]
			local cfgSkillLvInfo = Tb_cfg_skill_level[cfgSkillInfo.skill_quality*100 + m_iSkillLv + 1]
			local cost = 0 
			if cfgSkillLvInfo then 
				cost = cfgSkillLvInfo.exp
			end
			if cost > SkillDataModel.getUserSkillValue() then
				local skillOperateHelper = require("game/skill/skill_operate_helper")
				local skillId = m_iSkillId
				local heroUid = m_iMainCardId
				local skilIndx = m_iSkillIndx

				skillOperateHelper.notEnoughResSkillValue(2016,
					function()
						if userCardViewer then 
							userCardViewer.remove_self(true)
						end
						SkillDetail.remove_self(true)
					end,
					function()
						-- SkillDetail.create(SkillDetail.VIEW_TYPE_STRENGTH,nil,skillId,false,heroUid,skilIndx)
					end)
				return 
			end
    		SkillOpreateObserver.requestStrengthSkill(m_iMainCardId, m_iSkillId)
    	end
    end)

    -- 技能学习
    btn_op_learn:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		
    		if SkillDataModel.isSkillLearnedByHeroId(m_iMainCardId,m_iSkillId) then 
    			-- TODOTK 提示配置
    			tipsLayer.create("已学习该战法")
    			return 
    		end

    		SkillOverview.remove_self(true)
    		SkillOpreateObserver.requestHeroLearnSkill(m_iMainCardId, m_iSkillId,m_iSkillIndx)
    		SkillDetail.remove_self()

    	end
    end)

    -- 提升技能研究度入口
    btn_op_study:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		require("game/skill/skill_operate")
            SkillOperate.create(SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS,nil,nil,m_iSkillId)
    	end
    end)

    -- 技能遗忘 或者技能删除
    btn_op_delete:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		local skillOperateHelper = require("game/skill/skill_operate_helper")
    		if m_iMainCardId and m_iMainCardId ~=0 then 
    			-- 技能遗忘
    			skillOperateHelper.heroDeleteSkill(m_iMainCardId,m_iSkillId,m_iSkillLv, function()
    				remove_self()
    			end)
    		else
    			-- 技能移除
    			skillOperateHelper.deleteSkill(m_iSkillId,function()
    				remove_self()
    			end)
    		end
    	end
    end)

end


local function switchSkillView()
	
	if not m_pMainLayer then return end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local tmp_widget = mainWidget:clone()
	mainWidget:getParent():addChild(tmp_widget)

	uiUtil.hideScaleEffect(tmp_widget,function()
        tmp_widget:removeFromParentAndCleanup(true)
        tmp_widget = nil
    end,0.4)


	m_iSkillId = m_skillIdListToShow[m_skillIdSwitchIndx]
	SkillDetail.reloadData()

	uiUtil.showScaleEffect(mainWidget,function()
		m_bIsSwitching = false
	end	,0.2,nil,nil,80)
	

	
end

local function checkSwitchBtns()
	if not m_switchBtnLeft  then return end
	if not m_switchBtnRight then return end
	if not m_skillIdSwitchIndx then return end
	if not m_skillIdSwitchIndxNext then return end
	
	m_switchBtnLeft:setOpacity(255)
	m_switchBtnRight:setOpacity(255)
	breathAnimUtil.start_scroll_dir_anim(m_switchBtnLeft, m_switchBtnRight)
	if m_skillIdSwitchIndx == 1 and m_skillIdSwitchIndxNext > m_skillIdSwitchIndx then 
		m_switchBtnLeft:setTouchEnabled(false)
		m_switchBtnLeft:setVisible(false)
		m_switchBtnRight:setTouchEnabled(true)
		m_switchBtnRight:setVisible(true)
	elseif m_skillIdSwitchIndx > 1 and m_skillIdSwitchIndxNext > m_skillIdSwitchIndx then 
		m_switchBtnLeft:setTouchEnabled(true)
		m_switchBtnLeft:setVisible(true)
		m_switchBtnRight:setTouchEnabled(true)
		m_switchBtnRight:setVisible(true)
	elseif m_skillIdSwitchIndx == #m_skillIdListToShow and m_skillIdSwitchIndxNext == 1 then 
		m_switchBtnLeft:setTouchEnabled(true)
		m_switchBtnLeft:setVisible(true)
		m_switchBtnRight:setTouchEnabled(false)
		m_switchBtnRight:setVisible(false)
	else
		m_switchBtnLeft:setTouchEnabled(false)
		m_switchBtnLeft:setVisible(false)
		m_switchBtnRight:setTouchEnabled(false)
		m_switchBtnRight:setVisible(false)
	end
end


local function switchIdIndx2Next()
	m_skillIdSwitchIndx = m_skillIdSwitchIndxNext
	m_skillIdSwitchIndxNext = m_skillIdSwitchIndx + 1

	if m_skillIdSwitchIndxNext > #m_skillIdListToShow then 
		m_skillIdSwitchIndxNext = 1
	end
end


local function switchIdIndx2Pre()
	m_skillIdSwitchIndx = m_skillIdSwitchIndx - 1
	if m_skillIdSwitchIndx < 1 then 
		m_skillIdSwitchIndx = 1
	end
	m_skillIdSwitchIndxNext = m_skillIdSwitchIndx + 1

	if m_skillIdSwitchIndxNext > #m_skillIdListToShow then 
		m_skillIdSwitchIndxNext = 1
	end
end


local function initSwitchBtns()
	if not m_switchBtnLeft then return end
	if not m_switchBtnRight then return end
	if not m_skillIdListToShow then return end
	if #m_skillIdListToShow <= 1 then return end

	m_bIsSwitching = false

	for i = 1,#m_skillIdListToShow do 
		if m_skillIdListToShow[i] == m_iSkillId then 
			m_skillIdSwitchIndx = i
		end
	end

	if m_skillIdSwitchIndx then 
		m_skillIdSwitchIndxNext = m_skillIdSwitchIndx + 1
	else
		m_skillIdSwitchIndx = 1
		m_skillIdSwitchIndxNext = m_skillIdSwitchIndx + 1
	end

	if m_skillIdSwitchIndxNext > #m_skillIdListToShow then 
		m_skillIdSwitchIndxNext = 1
	end

	checkSwitchBtns()
	

	m_switchBtnLeft:addTouchEventListener(function(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then 	
			if m_bIsSwitching then return end
			m_bIsSwitching = true
			switchIdIndx2Pre()
			checkSwitchBtns()
			switchSkillView()
		end
	end)

	m_switchBtnRight:addTouchEventListener(function(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				if m_bIsSwitching then return end
				m_bIsSwitching = true
				switchIdIndx2Next()
				checkSwitchBtns()
				switchSkillView()
			end
		end)

end

function create(opType ,callback,skillId,isLock,mainCardId,skillIndx,isEnemy,idList)
	if m_pMainLayer then return end
	SkillOpreateObserver.create()
	require("game/skill/skill_data_model")
	SkillDataModel.create()


	if SkillOverview and SkillOverview.updateTouchEnable then 
		SkillOverview.updateTouchEnable(false)
	end

	m_iOptype = opType
	m_closeCallBack = callback
	m_bIsEnemy = isEnemy
	m_bIsLockOperate = isLock
	m_iMainCardId = mainCardId
	

	if m_iOptype == SkillDetail.VIEW_TYPE_LEARN then 
		m_iSkillId = skillId
		m_iSkillIndx = skillIndx
		m_iSkillLv = 1
	elseif m_iOptype == SkillDetail.VIEW_TYPE_STRENGTH then 
		if isLock then 
			m_iSkillId = skillId
			m_iSkillLv = 1
		else
			local skillList = heroData.getHeroSkillList(m_iMainCardId)
			m_iSkillIndx = skillIndx
			m_iSkillId = skillList[m_iSkillIndx][1]
			m_iSkillLv = skillList[m_iSkillIndx][2]
		end
	else
		m_iSkillId = skillId
		m_iSkillLv = 1
	end

	local itemLayoutType = {
		skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STUDY,
		skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_LEARN,
		skillItemHelper.LAYOUT_TYPE_SKILL_DETAIL_STRENGTH,
	}
	m_iSkillItemLayoutType = itemLayoutType[opType]
	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/jinengxiangqing.json")
	mainWidget:setTag(999)
	mainWidget:setScale(config.getgScale())
	mainWidget:ignoreAnchorPointForPosition(false)
	mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
	mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

	m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_SKILL_DETAIL)

    uiManager.showConfigEffect(uiIndexDefine.UI_SKILL_DETAIL,m_pMainLayer,function()
    	if m_iOptype == SkillDetail.VIEW_TYPE_STUDY then 
			if (not CCUserDefault:sharedUserDefault():getBoolForKey("nonforce_guide_2036") ) then 
		        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2036)
		        CCUserDefault:sharedUserDefault():setBoolForKey("nonforce_guide_2036",true)
		    end
		end
    end)

    initLayout()
    reloadData()


    UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.update, SkillDetail.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, SkillDetail.reloadData)
    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, SkillDetail.reloadData)
    -- UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.add, SkillDetail.reloadData)
    -- UIUpdateManager.add_prop_update(dbTableDesList.user_skill.name, dataChangeType.remove, SkillOverview.reload_data)

    if m_iOptype == SkillDetail.VIEW_TYPE_STRENGTH then 
		if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_skill_detail_strength") ) then 
	        require("game/guide/shareGuide/picTipsManager")
	        picTipsManager.create(7)
	        CCUserDefault:sharedUserDefault():setBoolForKey("opened_skill_detail_strength",true)
	    end
	end



	m_switchBtnLeft = uiUtil.getConvertChildByName(mainWidget,"btn_left")
	m_switchBtnLeft:removeFromParentAndCleanup(false)
	m_pMainLayer:addWidget(m_switchBtnLeft)
	m_switchBtnLeft:ignoreAnchorPointForPosition(false)
	m_switchBtnLeft:setScale(config.getgScale())
	m_switchBtnLeft:setAnchorPoint(cc.p(0,0.5))
	m_switchBtnLeft:setPosition(cc.p(10 , config.getWinSize().height/2))
	m_switchBtnLeft:setVisible(false)
	m_switchBtnLeft:setTouchEnabled(false)

	m_switchBtnRight = uiUtil.getConvertChildByName(mainWidget,"btn_right")
	m_switchBtnRight:removeFromParentAndCleanup(false)
	m_pMainLayer:addWidget(m_switchBtnRight)
	m_switchBtnRight:ignoreAnchorPointForPosition(false)
	m_switchBtnRight:setScale(config.getgScale())
	m_switchBtnRight:setAnchorPoint(cc.p(1,0.5))
	m_switchBtnRight:setPosition(cc.p(config.getWinSize().width - 10 , config.getWinSize().height/2))
	m_switchBtnRight:setVisible(false)
	m_switchBtnRight:setTouchEnabled(false)
	
	m_skillIdListToShow = idList
	if not m_skillIdListToShow then m_skillIdListToShow = {} end
	if #m_skillIdListToShow > 1 then 
		initSwitchBtns()
	end

end


-- 强化成功
function onResponeSkillStrengthSucceed()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end
	local main_bg = uiUtil.getConvertChildByName(mainWidget,"main_bg")
	local skill_item = uiUtil.getConvertChildByName(main_bg,"skill_item")
	local skillItemWidget = uiUtil.getConvertChildByName(skill_item,"skillItemWidget" )
	skillItemHelper.playArmatureEffect(skillItemWidget,"zhanfa_shengji")
end
function get_com_guide_widget(temp_guide_id)
    if not m_pMainLayer then return nil end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return nil end
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2036 then 
    	return mainWidget
    else
        return nil
    end
end