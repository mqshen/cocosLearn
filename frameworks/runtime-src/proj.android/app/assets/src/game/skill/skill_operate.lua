module("SkillOperate", package.seeall)


-- 技能操作UI 学习 强化 转化技能值 研究  武将卡进阶 武将卡觉醒
-- 类名 ：  SkillOperate
-- json名：  jinengxiangqing_2.json
-- 配置ID:	UI_SKILL_OPERATE
local skillOperateHelper = require("game/skill/skill_operate_helper")
local opHeroStarFilter = require("game/uiCommon/op_hero_star_filter")

SkillOperate.OP_TYPE_TRANSFER = 1 -- 技巧值转换
SkillOperate.OP_TYPE_STUDY_SKILL = 2 -- 研究技能
SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS = 3 -- 技能研究进度
SkillOperate.OP_TYPE_HERO_ADVANCE = 4 -- 武将卡进阶
SkillOperate.OP_TYPE_HERO_AWAKEN = 5 -- 武将卡觉醒

local m_widgetFilterStar = nil

local m_pMainLayer = nil
local m_backPanel = nil
local op_type = nil 				
local hero_id_list = nil

local m_star_filter_type = nil -- 0 代表不过滤 

local selected_widget = nil

---------------  滑动区域
local is_touch_scroll_area, is_touch_skill_area = false, false
local type_touch_skill_area = nil  -- 1 主卡区域  2副卡区域 3素材卡区域

local is_moving, is_scrolling = false, false
local MOVE_SENSITIVE_DIS = 5
local start_x_in_card, start_y_in_card = 0, 0 	--开始选中卡片时选中的卡片中的坐标点
local start_touch_x, start_touch_y = 0, 0 		--开始选中的坐标（相对于WIDGET中的位置,采用这个是在移动时计算位移值获取一层组件就好了）
local drag_widget = nil
local current_index = 5 	--指定开始显示的索引（我们以从做开始第一个正常显示的卡片）
local start_show_index = 5 	--第几个位置上显示指定的索引
local one_distance = 30			--重叠部分间距
local two_distance = 140 		--缩放交界处间距
local three_distance = 140 		--正规显示部分间距
local move_one_card_dis = 140 	--移动多少像素算是滚动了一个卡牌
local scroll_widget_list = nil	--滚动区域内创建英雄显示列表
local sort_type = 1
local selected_id_list = nil
local widget_pos_list = {33, 63, 93, 123, 263, 403, 543, 683, 713, 743, 773}
local widget_scale_list = {0.9, 0.9, 0.9, 0.9, 1, 1, 1, 0.9, 0.9, 0.9, 0.9}		--小卡牌相对正常尺寸的缩放比例
local widget_order_list = {1, 2, 3, 4, 9, 10, 11, 8, 7, 6, 5}

local m_iQuitAddQuality = nil   -- 1 一星卡 2 二星卡以下 3 三星卡以下  以此类推
local curr_hero_uid = nil

local target_card_id = nil

-- 主卡区域
local main_card_id = nil 		-- 主卡的ID
local second_card_id = nil		-- 副卡的ID
local main_card_widget = nil	-- 主卡widget
local second_card_widget = nil	-- 副卡widget

local main_skill_id = nil

local m_closeCallBack = nil


local m_pSkillItemProgressBg = nil
local m_pSkillItemProgressBgExpecting = nil

local m_iSkillStudyProgressLeft = nil -- 技能研究度剩余多少百分比就达到技能研究度上限

local SkillOpreateObserver = require("game/skill/skill_operate_observer")
local skillItemHelper = require("game/skill/skill_item_helper")

local skillDetailHelper = require("game/skill/skill_detail_helper")

local m_iNonForcedGuideId = nil


local m_bFlagCloseDirectly = nil

local function do_remove_self()
	if m_pMainLayer then 

		if m_widgetFilterStar then
			m_widgetFilterStar:removeFromParentAndCleanup(true)
			m_widgetFilterStar = nil
		end

		if drag_widget then 
			drag_widget:removeFromParentAndCleanup(true)
			drag_widget = nil
		end

		if main_card_widget then 
			main_card_widget:removeFromParentAndCleanup(true)
			main_card_widget = nil
		end

		if second_card_widget then 
			second_card_widget:removeFromParentAndCleanup(true)
			second_card_widget = nil
		end


		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end

		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil

        op_type = nil
        scroll_widget_list = nil
        selected_id_list = nil
        selected_widget = nil
        target_card_id = nil
        main_card_id = nil
        second_card_id = nil
        m_iQuitAddQuality = nil

        main_skill_id = nil

        uiManager.remove_self_panel(uiIndexDefine.UI_SKILL_OPERATE)

        if m_closeCallBack then 
        	m_closeCallBack()
        end

        UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.add, SkillOperate.dealReloadData)
		UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.remove, SkillOperate.dealReloadData)
		UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, SkillOperate.dealWithCardUpdate)

		UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.add, SkillOperate.updateRes)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.remove, SkillOperate.updateRes)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, SkillOperate.updateRes)

		m_iNonForcedGuideId = nil

		if SkillOverview and SkillOverview.updateTouchEnable then 
			SkillOverview.updateTouchEnable(true)
		end

		--[[
		if cardOverviewManager then
			if uiManager.is_most_above_layer(uiIndexDefine.CARD_OVERVIEW_UI) then
				cardOverviewManager.update_tb_state(true)
			end
		end

		if cardPacketManager then
			if uiManager.is_most_above_layer(uiIndexDefine.CARD_PACKET_UI) then
				cardPacketManager.update_tb_state(true)
			end
		end
		--]]
	end
end


-- 处理 往招募界面的跳转，关闭掉所有可能已经打开的界面 避免环形交互
local function handle_jump_2_card_recruit()

	m_closeCallBack = nil

	remove_self(true)
	
	if SkillDetail then
		SkillDetail.remove_self(true)
	end

	if SkillOverview then
		SkillOverview.remove_self(true)
	end

	if userCardViewer then
		userCardViewer.remove_self(true)
	end

	if basicCardViewer then 
		basicCardViewer.remove_self(true)
	end
	require("game/cardCall/cardCallManager")
    cardCallManager.create()
end
function remove_self( closeEffect )
	if m_pSkillItemProgressBg then 
		m_pSkillItemProgressBg:stopAllActions()
		m_pSkillItemProgressBg:removeFromParentAndCleanup(true)
		m_pSkillItemProgressBg = nil
	end

	if m_backPanel then
		if closeEffect then 
			do_remove_self() 
		elseif m_bFlagCloseDirectly then
			do_remove_self()
		else
    		uiManager.hideConfigEffect(uiIndexDefine.UI_SKILL_OPERATE, m_pMainLayer, do_remove_self, 999, {m_backPanel:getMainWidget()})
    	end
    end
end
function activeNonForceGuide(guide_id)
    m_iNonForcedGuideId = guide_id
end

function dealwithTouchEvent(x,y)
	return false
end

local function resLayout()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local label_num = nil
	local yuanbao_nums = userData.getYuanbao()
    local money_nums = 0
    local selfCommonRes = politics.getSelfRes()
    if selfCommonRes then
        money_nums = selfCommonRes.money_cur
    end


	local panel_res_skillValue = uiUtil.getConvertChildByName(mainWidget,"panel_res_skillValue")
	label_num = uiUtil.getConvertChildByName(panel_res_skillValue,"label_num")
	label_num:setText(SkillDataModel.getUserSkillValue())
	local panel_res_gold = uiUtil.getConvertChildByName(mainWidget,"panel_res_gold")
	label_num = uiUtil.getConvertChildByName(panel_res_gold,"label_num")
	label_num:setText(commonFunc.common_gold_show_content(yuanbao_nums))
	local panel_res_coin = uiUtil.getConvertChildByName(mainWidget,"panel_res_coin")
	label_num = uiUtil.getConvertChildByName(panel_res_coin,"label_num")
	label_num:setText(commonFunc.common_coin_show_content(money_nums))


	local btn_add = uiUtil.getConvertChildByName(panel_res_gold,"btn_add")
	btn_add:setVisible(false)
	btn_add:setTouchEnabled(false)


	local btn_add = uiUtil.getConvertChildByName(panel_res_skillValue,"btn_add")
	btn_add:setVisible(false)
	btn_add:setTouchEnabled(false)



	panel_res_skillValue:setVisible(false)
	panel_res_gold:setVisible(false)
	panel_res_coin:setVisible(false)


	local panel_jump2Recruit = uiUtil.getConvertChildByName(mainWidget,"panel_jump2Recruit")
	panel_jump2Recruit:setVisible(false)
	panel_jump2Recruit:setTouchEnabled(false)

	if op_type == SkillOperate.OP_TYPE_TRANSFER then 
		panel_res_gold:setVisible(true)
		panel_res_coin:setVisible(true)

		panel_jump2Recruit:setVisible(true)
		panel_jump2Recruit:setTouchEnabled(true)
		panel_jump2Recruit:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				handle_jump_2_card_recruit()
			end
		end)
	elseif op_type == SkillOperate.OP_TYPE_STUDY_SKILL then
		panel_res_skillValue:setVisible(true)

		local btn_add = uiUtil.getConvertChildByName(panel_res_skillValue,"btn_add")
		btn_add:setVisible(true)
		btn_add:setTouchEnabled(true)
		btn_add:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				-- 拆解战法增加 到 转换技巧值的跳转， 关闭转换技巧值后 再回来拆解战法
				do_remove_self()
				m_bFlagCloseDirectly = true
				SkillOperate.create(SkillOperate.OP_TYPE_TRANSFER,function()
					m_bFlagCloseDirectly = false
					SkillOperate.create(SkillOperate.OP_TYPE_STUDY_SKILL)
				end)
			end
		end)
	elseif op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
		-- 不消耗资源 消耗的是卡牌
		-- panel_res_gold:setVisible(true)
		-- panel_res_coin:setVisible(true)
	elseif op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
		-- 不消耗资源 消耗的是卡牌
	elseif op_type == SkillOperate.OP_TYPE_HERO_AWAKEN then
		-- 不消耗资源 消耗的是卡牌
	end
	
	local pos_x = 20
	if panel_res_skillValue:isVisible() then 
		panel_res_skillValue:setPositionX(pos_x)
		pos_x = pos_x + panel_res_skillValue:getSize().width
	end

	if panel_res_coin:isVisible() then 
		panel_res_coin:setPositionX(pos_x)
		pos_x = pos_x + panel_res_coin:getSize().width
	end

	if panel_res_gold:isVisible() then 
		panel_res_gold:setPositionX(pos_x)
		pos_x = pos_x + panel_res_gold:getSize().width
	end

	if panel_res_gold:isVisible() then 
		local btn_add = uiUtil.getConvertChildByName(panel_res_gold,"btn_add")
		btn_add:setVisible(true)
		btn_add:setTouchEnabled(true)
		btn_add:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				require("game/pay/payUI")
            	PayUI.create()
			end
		end)
	end

end

local function updateView()
	if not m_pMainLayer then return end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end

	resLayout()

	if op_type == SkillOperate.OP_TYPE_TRANSFER then 
		-- 技巧值转化
    	skillOperateHelper.updateTransferSkillValue(mainWidget,selected_id_list)
    elseif op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 
    	-- 研究获得新技能
    	skillOperateHelper.updateSutdySkillView(mainWidget,main_card_id)
    elseif op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
    	-- 提高技能研究度
    	local panel_main_3 = uiUtil.getConvertChildByName(mainWidget,"panel_main_3")
    	local panel_container = uiUtil.getConvertChildByName(panel_main_3,"panel_container")
		panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)
		local skillItemWidget  = uiUtil.getConvertChildByName(panel_container,"skillItemWidget" )
		if not skillItemWidget then 
	        skillItemWidget,m_pSkillItemProgressBg,m_pSkillItemProgressBgExpecting = skillItemHelper.createWidgetItem(true,true)
	        skillItemWidget:setName("skillItemWidget")
	        panel_container:addChild(skillItemWidget)
	        skillItemWidget:ignoreAnchorPointForPosition(false)
			skillItemWidget:setAnchorPoint(cc.p(0.5,0.5))
			skillItemWidget:setPosition(cc.p(panel_container:getSize().width/2,panel_container:getSize().height/2))
	    end
	    skillItemWidget:setScale(1.4)
	    skillItemHelper.loadSkillInfo(skillItemWidget,m_pSkillItemProgressBg, main_skill_id,skillItemHelper.LAYOUT_TYPE_SKILL_PROGRESS_STUDY,nil,nil,#selected_id_list > 0)
	    

	    skillOperateHelper.updateStudySkillProgressView(mainWidget,selected_id_list,main_skill_id)
    elseif op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
    	-- 武将卡进阶
    	skillOperateHelper.updateAdvanceHeroView(mainWidget,target_card_id,main_card_id)
	elseif op_type == SkillOperate.OP_TYPE_HERO_AWAKEN then
		-- 武将卡觉醒
		skillOperateHelper.updateAwakeSkillView(mainWidget,target_card_id,main_card_id,second_card_id)
	end


	-- 如果没有任何可以进行研究的素材卡，则提示玩家需要从招募武将处获得对应的素材卡，并直接写出这个技能所需要的素材卡（位于原武将卡排列区）
	local panel_studySkill_hasNoMaterial = uiUtil.getConvertChildByName(mainWidget,"panel_studySkill_hasNoMaterial")
    panel_studySkill_hasNoMaterial:setVisible(false)

    local btn_jump2Recruit = uiUtil.getConvertChildByName(panel_studySkill_hasNoMaterial,"btn_jump2Recruit")
    btn_jump2Recruit:setVisible(false)
    btn_jump2Recruit:setTouchEnabled(false)


    if (op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS) and ((not hero_id_list) or (#hero_id_list == 0)) then 
    	panel_studySkill_hasNoMaterial:setVisible(true)
    	btn_jump2Recruit:setVisible(true)
    	btn_jump2Recruit:setTouchEnabled(true)

    	btn_jump2Recruit:addTouchEventListener(function(sender,eventType)
    		if eventType == TOUCH_EVENT_ENDED then 
				handle_jump_2_card_recruit()
    		end
    	end)
    	local panel_detail = uiUtil.getConvertChildByName(panel_studySkill_hasNoMaterial,"panel_detail")
    	local paramTab = SkillDataModel.getSkillResearchConditionDetailTxt(main_skill_id)
		skillDetailHelper.loadResearchConditionRichText(panel_detail,paramTab,true,nil,1)

		local label_scroll_null_tips = uiUtil.getConvertChildByName(mainWidget,"label_scroll_null_tips")
		label_scroll_null_tips:setVisible(false)

    end

end


-- 没有建设对应的国家殿 不能配置
-- 如果武将在其他据点	其他据点
-- 武将在自己编辑所在城市 	出征等状态
--重伤单独显示
local function get_hero_state_info(temp_widget, hero_uid)
	local hero_info = heroData.getHeroInfo(hero_uid)
	local hero_in_army_id = hero_info.armyid

	if hero_in_army_id == 0 then
		cardFrameInterface.set_hero_state(temp_widget, 2, 0)
	else
		cardFrameInterface.set_hero_state(temp_widget, 2, heroStateDefine.inarmy)
	end
end




local function getHeroStateInfo(hero_uid,ingoreLevelUp)
	-- local cardState = heroStateDefine.selected_nomal
	local cardState = 0
	local hero_info = heroData.getHeroInfo(hero_uid)
	local base_hero_info = Tb_cfg_hero[hero_info.heroid]
	local hero_quality = base_hero_info.quality


	local is_protected = false -- 是否保护
	local is_unlock = false  -- 是否觉醒
	local is_advanced = false -- 是否进阶
	local is_learned_skill = false -- 是否学习技能
	local is_strengthed_skill = false -- 是否强化过技能
	local is_hight_quality = false -- 是否是稀有武将
	local is_upgrade = false -- 是否已经升级
	
	local is_allocated_point = false -- 是否已经配点

	local is_selected = false -- 是否选中
	

	-- 是否升级

	if not ingoreLevelUp and hero_info and hero_info.level > 1 then 
		is_upgrade = true 
		cardState = heroStateDefine.selected_attention
	end

	if hero_quality >= 3 then
		-- 星级过高的
		is_hight_quality = true
		cardState = heroStateDefine.selected_attention
	end
	
	local hero_skill_list = heroData.getHeroSkillList(hero_uid)
	local skill_id = 0
	if #hero_skill_list > 1 then
		--学习过技能
		for i = 2,#hero_skill_list do
			skill_id = hero_skill_list[i][1]
			if skill_id ~= 0 then
				is_learned_skill = true
				cardState = heroStateDefine.selected_attention
			end
		end
	else
		-- 强化过技能的
		local skill_level = 0
		local skill_exp = 0
		for i = 1,#hero_skill_list do 
			skill_id = hero_skill_list[i][1]
			if skill_id ~= 0 then 
				skill_level = hero_skill_list[i][2]
				if skill_level > 1 then 
					is_strengthed_skill = true
					cardState = heroStateDefine.selected_attention
				end
			end
		end
		
	end

	-- 已觉醒
	if hero_info.awake_state == 1 then
		is_unlock = true
		cardState = heroStateDefine.selected_attention
	end

	-- 进阶
	if hero_info.advance_num > 0 then 
		is_advanced = true
		cardState = heroStateDefine.selected_attention
	end

	-- 配点
	if heroData.isHeroAllocatedPoint(hero_info.heroid_u) then
		is_allocated_point = true
		cardState = heroStateDefine.selected_attention
	end

	-- 保护
	if hero_info.lock_state ~= 0 then
		is_protected = true
		cardState = heroStateDefine.selected_attention
	end

	
	--显示优先级：已保护＞已觉醒＞已进阶＞已配点> 已强化/学习技能＞稀有＞已升级
	if is_selected then
		attention_text = languagePack["skillTipsSelected"]
	end

	if is_upgrade then 
		attention_text = languagePack["skillTipsUpgraded"]
	end

	if is_hight_quality then
		attention_text = languagePack["skillTipsHightQuality"]
	end

	if is_learned_skill then
		attention_text = languagePack["skillTipsLearnedSkill"]
	end

	if is_strengthed_skill then
		attention_text = languagePack["skillTipsStrengthedSkill"]
	end

	if is_advanced then 
		attention_text = languagePack["skillTipsAdvanced"]
	end

	if is_allocated_point then 
		attention_text = languagePack["skillTipsAllocatedPoint"]
	end
	if is_unlock then 
		attention_text = languagePack["skillTipsUnlocked"]
	end


	if is_protected then 
		attention_text = languagePack["skillTipsProtected"]
	end

	return cardState,attention_text
end

local function is_in_selected_id(hero_uid)
	for k,v in ipairs(selected_id_list) do
		if v == hero_uid then 
			return true
		end
	end
	return false
end

local function add_selected_id(hero_uid)
	if not selected_id_list then return end
	if is_in_selected_id(hero_uid) then return end
	if #selected_id_list >= SKILL_VALUE_TRANSFORM_CARD_MAX then return end
	table.insert(selected_id_list,hero_uid)
end

local function remove_selected_id(hero_uid)
	if not selected_id_list then return end
	for k,v in ipairs(selected_id_list) do
		if v == hero_uid then
			table.remove(selected_id_list,k)
		end
	end
end

local function sort_ruler(a_uid, b_uid)
	local a_card = heroData.getHeroInfo(a_uid)
	local b_card = heroData.getHeroInfo(b_uid)
	local a_base_card = Tb_cfg_hero[a_card.heroid]
	local b_base_card = Tb_cfg_hero[b_card.heroid]

	local cmp_result, is_equal = false, false

	if sort_type == 1 then
		if a_base_card.quality == b_base_card.quality then
			is_equal = true
		else
			
			if op_type == SkillOperate.OP_TYPE_STUDY_SKILL then
				
				cmp_result = a_base_card.quality > b_base_card.quality
			else	
				-- 升序
				cmp_result = a_base_card.quality < b_base_card.quality
			end
		end
	elseif sort_type == 2 then
		if a_base_card.country == b_base_card.country then
			is_equal = true
		else
			cmp_result = a_base_card.country < b_base_card.country
		end
	elseif sort_type == 3 then
		if a_base_card.hero_type == b_base_card.hero_type then
			is_equal = true
		else
			cmp_result = a_base_card.hero_type < b_base_card.hero_type
		end
	elseif sort_type == 4 then
		if a_card.level == b_card.level then
			is_equal = true
		else
			cmp_result = a_card.level > b_card.level
		end
	elseif sort_type == 5 then
		if a_base_card.cost == b_base_card.cost then
			is_equal = true
		else
			cmp_result = a_base_card.cost > b_base_card.cost
		end
	end

	if is_equal then
		if a_card.heroid == b_card.heroid then
			if a_card.level == b_card.level then
				cmp_result = a_uid < b_uid
			else
				cmp_result = a_card.level > b_card.level
			end
		else
			cmp_result = a_card.heroid < b_card.heroid
		end
	end

	-- local cardStateA,__textA = getHeroStateInfo(a_uid)
	-- local cardStateB,__textB = getHeroStateInfo(b_uid)
	-- local isCardNeedAttenttionA = cardStateA ~= 0
	-- local isCardNeedAttenttionB = cardStateB ~= 0
	

	-- if isCardNeedAttenttionA and isCardNeedAttenttionB then 
	-- 	cmp_result = cmp_result 
	-- elseif isCardNeedAttenttionA or isCardNeedAttenttionB then 
	-- 	if isCardNeedAttenttionA then 
	-- 		cmp_result = false
	-- 	else
	-- 		cmp_result = true
	-- 	end
	-- end

	-- 锁住的卡牌的优先排序
	local is_a_card_protected = (a_card.lock_state ~= 0)
	local is_b_card_protected = (b_card.lock_state ~= 0)
	if is_a_card_protected and  is_b_card_protected then
		-- 两个都锁住了 无差啦
		cmp_result = cmp_result
	elseif is_a_card_protected or is_b_card_protected then
		-- 其中一个锁住了 哪就个锁住哪个拍后边
		if is_a_card_protected then 
			cmp_result = false
		else
			cmp_result = true
		end
	end

	return cmp_result
end

-- return false  不显示
-- return true 显示
local function filter_hero(hero_info)
	if not hero_info then return false end
	if m_star_filter_type ~= 0 then 
		local cfgHeroInfo = Tb_cfg_hero[hero_info.heroid]
		if cfgHeroInfo.quality + 1 ~= m_star_filter_type then 
			return false
		end
	end

	if hero_info.armyid ~= 0 then return false end

	if hero_info.state == cardState.lock then return false end
	-- 同一张卡 不再显示
	if target_card_id then 
		if hero_info.heroid_u == target_card_id then return false end
	else
		if hero_info.heroid_u == main_card_id then return false end
	end
	
	-- -- 处于保护状态
	-- if hero_info.lock_state ~= 0 then return false end
	-- 处于征战状态
	if hero_info.state ~= 0 then return false end

	--  技巧值转化 进阶 觉醒  （已学习技能的素材不显示）
	if op_type == SkillOperate.OP_TYPE_TRANSFER or 
		op_type == SkillOperate.OP_TYPE_HERO_ADVANCE or 
		op_type == SkillOperate.OP_TYPE_HERO_AWAKEN or
		op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 

		if SkillDataModel.isHeroLearnedSkill(hero_info) then 
			return false
		end
	end

	if op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 
		-- 低星级的不能用
		local cfgHeroInfo = Tb_cfg_hero[hero_info.heroid]
		if cfgHeroInfo.quality < SKILL_RESEARCH_QUALITY_MIN then 
			return false
		end
	end
	
	-- 觉醒界面的列表过滤
	if op_type == SkillOperate.OP_TYPE_HERO_AWAKEN then
		local targetCardInfo = heroData.getHeroInfo(target_card_id)
		local cfgTargetInfo = Tb_cfg_hero[targetCardInfo.heroid]

		local cfgHeroInfo = Tb_cfg_hero[hero_info.heroid]
		local flag_sub = false
		-- 品质限制
		for k,v in ipairs(cfgTargetInfo.awake_cost[1]) do 
			if cfgHeroInfo.quality == v then 
				flag_sub = true
			end
		end
		if not flag_sub then return false end

		-- 国家限制
		for k,v in ipairs(cfgTargetInfo.awake_cost[2]) do 
			if cfgHeroInfo.country == v then 
				flag_sub = true
			end
		end
		if not flag_sub then return false end

		-- 兵种限制
		for k,v in ipairs(cfgTargetInfo.awake_cost[3]) do 
			if cfgHeroInfo.hero_type == v then 
				flag_sub = true
			end
		end
		if not flag_sub then return false end
	end

	-- 技能提高研究度过滤
	if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 	
		local addValue = SkillDataModel.getStudyProgressValueByCard(main_skill_id,hero_info.heroid,hero_info.advance_num)
		if addValue and addValue > 0 then 
			return true 
		else
			return false
		end
	end

	-- 武将卡进阶
	if op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
		local targetCardInfo = heroData.getHeroInfo(target_card_id)
		if hero_info.heroid == targetCardInfo.heroid then 
			return true
		else
			return false
		end
	end

	return true
end


-- 办公室位置 tips 适配
local function autoLayoutScrollView()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local btn_quitAdd = uiUtil.getConvertChildByName(mainWidget,"btn_quitAdd")

	local label_scroll_null_tips = uiUtil.getConvertChildByName(mainWidget,"label_scroll_null_tips")
	if hero_id_list and #hero_id_list > 0 then 
		label_scroll_null_tips:setVisible(false)
	else
		label_scroll_null_tips:setVisible(true)
		-- 不同类型的tips
		-- TODOTK tips配置
		if op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 
			label_scroll_null_tips:setText("没有研究所需的武将")
		elseif op_type == SkillOperate.OP_TYPE_TRANSFER then 
			label_scroll_null_tips:setText("没有转化所需的武将")
		elseif op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
			label_scroll_null_tips:setText("没有研究所需的武将")
		elseif op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
			label_scroll_null_tips:setText("没有进阶所需的武将")
		elseif op_type == SkillOperate.OP_TYPE_HERO_AWAKEN then 
			label_scroll_null_tips:setText("没有觉醒所需的武将")
		end
	end

	-- 调整位置
	local img_scroll_flag_left = uiUtil.getConvertChildByName(mainWidget,"img_scroll_flag_left")
	local img_scroll_flag_right = uiUtil.getConvertChildByName(mainWidget,"img_scroll_flag_right")
	local card_scrollview = uiUtil.getConvertChildByName(mainWidget,"card_scrollview")
	if hero_id_list and #hero_id_list > 0  and btn_quitAdd:isVisible() then 
		img_scroll_flag_left:setPositionX(74)
		img_scroll_flag_right:setPositionX(924)
		label_scroll_null_tips:setPositionX(520)
		card_scrollview:setPositionX(96)
	else
		local posx_offset = 50
		img_scroll_flag_left:setPositionX(74 + posx_offset)
		img_scroll_flag_right:setPositionX(924 + posx_offset)
		label_scroll_null_tips:setPositionX(520 + posx_offset)
		card_scrollview:setPositionX(96 + posx_offset)
	end

	local btn_quitAdd = uiUtil.getConvertChildByName(mainWidget,"btn_quitAdd")

	local btn_quitSelect = uiUtil.getConvertChildByName(mainWidget,"btn_quitSelect")

	if hero_id_list and #hero_id_list > 0 then 
		if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
			btn_quitSelect:setVisible(false)
			btn_quitSelect:setTouchEnabled(false)
		end
	else
		btn_quitSelect:setVisible(false)
		btn_quitSelect:setTouchEnabled(false)
		btn_quitAdd:setVisible(false)
		btn_quitAdd:setTouchEnabled(false)
	end
end


local function update_scroll_percent_view(percent)
	if not m_pMainLayer then return end
	if not percent then percent = 0 end
	if percent < 0 then percent = 0 end
	if percent > 100 then percent = 100 end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local img_progress = uiUtil.getConvertChildByName(mainWidget,"img_progress")
	local img_flag = uiUtil.getConvertChildByName(img_progress,"img_flag")

	local pos_start_x = - img_progress:getSize().width/2 + img_flag:getSize().width/2 + 5
	local total_w = img_progress:getSize().width - img_flag:getSize().width - 10
	img_flag:setPositionX( pos_start_x + total_w * percent / 100)

	local img_scroll_flag_left = uiUtil.getConvertChildByName(mainWidget,"img_scroll_flag_left")
	local img_scroll_flag_right = uiUtil.getConvertChildByName(mainWidget,"img_scroll_flag_right")
	img_scroll_flag_left:setVisible(false)
	img_scroll_flag_right:setVisible(false)
	breathAnimUtil.start_scroll_dir_anim(img_scroll_flag_left, img_scroll_flag_right)
	


	local hero_nums = 0
	if hero_id_list then 
		hero_nums = #hero_id_list
	end
	
	if hero_nums <= 3 then 
		img_scroll_flag_left:setVisible(false)
		img_scroll_flag_right:setVisible(false)
	else
		if current_index <= 3 then 
			img_scroll_flag_left:setVisible(false)
			img_scroll_flag_right:setVisible(true)
		elseif  current_index == hero_nums - 3 then
			img_scroll_flag_left:setVisible(true)
			img_scroll_flag_right:setVisible(false)
		else
			img_scroll_flag_left:setVisible(true)
			img_scroll_flag_right:setVisible(true)
		end
	end
		
	
end


local function organize_hero_list(seledIdList)
	hero_id_list = {}
	if seledIdList then 
		selected_id_list = seledIdList
	else
		selected_id_list = {}
	end
	
	
	local hero_info = nil
	for k,v in pairs(heroData.getAllHero()) do
		hero_info = heroData.getHeroInfo(k)
		if filter_hero(hero_info) then
			table.insert(hero_id_list, k)
		end
	end
	--暂时升序排列
	table.sort(hero_id_list, sort_ruler)
	local temp_widget = m_pMainLayer:getWidgetByTag(999)

	autoLayoutScrollView()

	update_scroll_percent_view(0)
end


local function init_scroll_widget()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end


	local card_scrollview = uiUtil.getConvertChildByName(mainWidget,"card_scrollview")
	local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")

	scroll_widget_list = {}
	local hero_widget = nil
	for i=1,11 do
		hero_widget = base_widget:clone()
		hero_widget:ignoreAnchorPointForPosition(false)
		hero_widget:setAnchorPoint(cc.p(0.5,0.5))
		hero_widget:setScale(widget_scale_list[i])
		hero_widget:setPosition(cc.p(widget_pos_list[i], 98))
		card_scrollview:addChild(hero_widget, widget_order_list[i])
		table.insert(scroll_widget_list, hero_widget)
	end


	local panel_material = uiUtil.getConvertChildByName(mainWidget,"panel_material")

	local panel_container = uiUtil.getConvertChildByName(panel_material,"panel_container")
	panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local material_widget = nil
	--TODOTK 这里不应该全都初始化
    for i=1,SKILL_VALUE_TRANSFORM_CARD_MAX do
        material_widget = base_widget:clone()
        material_widget:setTag(i)
        material_widget:ignoreAnchorPointForPosition(false)
        material_widget:setAnchorPoint(cc.p(0, 0))
        material_widget:setPosition(cc.p( 5 + 38 * (i-1), 2))
        material_widget:setVisible(false)
        material_widget:setScale(0.9)
        panel_container:addChild(material_widget)
    end

end


local function setQuitSelectType(star,starTxt, range)
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	m_iQuitAddQuality = star

	local btn_quitSelect = uiUtil.getConvertChildByName(mainWidget,"btn_quitSelect")
	local label_star = uiUtil.getConvertChildByName(btn_quitSelect,"label_star")
	local label_range = uiUtil.getConvertChildByName(btn_quitSelect,"label_range")
	label_star:setText(starTxt)
	label_range:setText(range)

end

local function setQuitSelectListVisible(isVisible,selectIndx,needEvent)
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)

	local panel_quitSelectList = uiUtil.getConvertChildByName(mainWidget,"panel_quitSelectList")
	panel_quitSelectList:setVisible(isVisible)

	local btn_quitSelect = nil

	for i = 1,3  do
		btn_quitSelect = uiUtil.getConvertChildByName(panel_quitSelectList,"btn_quitSelect_" .. i)
		btn_quitSelect:setTouchEnabled(isVisible)
		if selectIndx == i then 
			local label_star = uiUtil.getConvertChildByName(btn_quitSelect,"label_star")
			local label_range = uiUtil.getConvertChildByName(btn_quitSelect,"label_range")
			btn_quitSelect:setBright(false)
			setQuitSelectType(i,label_star:getStringValue(),label_range:getStringValue())
		else
			btn_quitSelect:setBright(true)
		end
		if needEvent then 
			btn_quitSelect:addTouchEventListener(function(sender,eventType)
				if eventType == TOUCH_EVENT_ENDED then
					setQuitSelectListVisible(false,i)
				end
			end)
		end
	end
end




local function resetQuitSelectMaterial()
	if not m_pMainLayer then return end
	if not m_iQuitAddQuality then return end

	if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
		m_iQuitAddQuality = 99

		if m_iSkillStudyProgressLeft <= 0 then 
			tipsLayer.create("此战法研究度已达上限")	-- TODOTK 中文收集
			return 
		end
	end

	local num_can_add = SKILL_VALUE_TRANSFORM_CARD_MAX - #selected_id_list

	if num_can_add <= 0 then 
		tipsLayer.create(errorTable[132])
		return 
	end

	
	local tm_hero_id_list = {}
	for k,v in ipairs(hero_id_list) do 
		table.insert(tm_hero_id_list,v)
	end

	local tmp_valid_hero_id_lst = {}

	local lst_HeroId = {}
	local hero_info = nil
	local base_hero_info = nil
	local cardState,cardStateTxt = nil

	local tmp_left_prgress = m_iSkillStudyProgressLeft
	local tmp_add_prgress = 0
	for k,v in ipairs(hero_id_list) do
		-- hero_id_list　已经按照　quality 排好序了　所以这里肯定是quality低的先插入 
		if (not is_in_selected_id(v)) then
			hero_info = heroData.getHeroInfo(v)

			base_hero_info = Tb_cfg_hero[hero_info.heroid]

			if base_hero_info.quality < m_iQuitAddQuality   then 	
				if op_type == SkillOperate.OP_TYPE_TRANSFER then
					cardState,cardStateTxt = getHeroStateInfo(v,true)
					if cardState == 0 then
						table.insert(tmp_valid_hero_id_lst,v)
					end
				else
					cardState,cardStateTxt = getHeroStateInfo(v,false)
					if cardState == 0 then
						table.insert(tmp_valid_hero_id_lst,v)
					end
				end
			end
		end
	end
	

	if op_type == SkillOperate.OP_TYPE_TRANSFER then
		-- 技巧值转换
		
		-- 默认已经按照quality 排好序了
		-- 先装入未升级的
		for k,v in ipairs(tmp_valid_hero_id_lst) do 
			if num_can_add > 0 then 
				local hero_info = heroData.getHeroInfo(v)
				if hero_info and hero_info.level == 1 then
					table.insert(lst_HeroId,v)
					table.insert(selected_id_list,v)
					num_can_add = num_can_add - 1
				end
			end
		end

		-- 放入其他的
		for k,v in ipairs(tmp_valid_hero_id_lst) do 
			if (num_can_add > 0) and (not is_in_selected_id(v)) then 
				table.insert(lst_HeroId,v)
				table.insert(selected_id_list,v)
				num_can_add = num_can_add - 1
			end
		end
	elseif op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
		-- 检查是否达到研究数上限 没有才能加进去
		for k,v in ipairs(tmp_valid_hero_id_lst) do 
			if num_can_add > 0 then 
				if tmp_left_prgress > 0 then 
					table.insert(lst_HeroId,v)
					table.insert(selected_id_list,v)
					num_can_add = num_can_add - 1

					local add_value = SkillDataModel.getStudyProgressValueByCard(main_skill_id,hero_info.heroid,hero_info.advance_num)
					tmp_left_prgress = tmp_left_prgress - add_value
					tmp_add_prgress = tmp_add_prgress + add_value
				end
			end
		end
	else
		for k,v in ipairs(tmp_valid_hero_id_lst) do 
			if num_can_add > 0 then 
				table.insert(lst_HeroId,v)
				table.insert(selected_id_list,v)
				num_can_add = num_can_add - 1
			end
		end
	end

	
	if not lst_HeroId or #lst_HeroId == 0 then 
		if #selected_id_list == 0 then
			-- 没有符合条件的素材
			tipsLayer.create("#" .. languagePack["skillStrength_notFoundMaterial"] .. "#")
		end
		
		return 
	end
	-- 技巧值转化的飘字效果
	if op_type == SkillOperate.OP_TYPE_TRANSFER  then 
		local mainWidget = m_pMainLayer:getWidgetByTag(999)
		local add_value = 0
		for k,v in ipairs(lst_HeroId) do 
			add_value = add_value + SkillDataModel.getSkillValueTurnedFromHeroCard(v)
		end
		
		
		skillOperateHelper.floatEffectAddingSkillValue(mainWidget,{{add_value,false}})
	end

	
	SkillOperate.resetData(selected_id_list)
	if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
		m_iSkillStudyProgressLeft = tmp_left_prgress
		local mainWidget = m_pMainLayer:getWidgetByTag(999)
		skillOperateHelper.effectPreAddingSkillStudyProgress(mainWidget,tmp_add_prgress,m_pSkillItemProgressBg,main_skill_id,m_iSkillStudyProgressLeft)
	end


end
local function initQuitAddEvent()
	if not m_pMainLayer then return end
	
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local btn_quitAdd = uiUtil.getConvertChildByName(mainWidget,"btn_quitAdd")

	local btn_quitSelect = uiUtil.getConvertChildByName(mainWidget,"btn_quitSelect")
	local panel_quitSelectList = uiUtil.getConvertChildByName(mainWidget,"panel_quitSelectList")
	-- 其实这里用 setEnable isEnable 更好
	if not btn_quitAdd:isVisible() then 
		btn_quitAdd:setTouchEnabled(false)
		btn_quitSelect:setVisible(false)
		btn_quitSelect:setTouchEnabled(false)
		return 
	end

	btn_quitAdd:setTouchEnabled(true)
	btn_quitAdd:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			resetQuitSelectMaterial()
		end
	end)

	
	btn_quitSelect:setVisible(true)
	btn_quitSelect:setTouchEnabled(true)
	btn_quitSelect:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			setQuitSelectListVisible(not panel_quitSelectList:isVisible() ,m_iQuitAddQuality)
		end
	end)
	setQuitSelectListVisible(false,1,true)


	
end



local function resetHeroListByFilterStar(starType)
	if starType == m_star_filter_type then return end
	m_star_filter_type = starType
	main_card_id = 0 
	second_card_id = 0
	selected_id_list = {}
	SkillOperate.resetData()
end

local function initStarFilter()
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local panel_star_filter = uiUtil.getConvertChildByName(temp_widget,"panel_star_filter")
	panel_star_filter:setBackGroundColorType(LAYOUT_COLOR_NONE)

	if op_type ~= SkillOperate.OP_TYPE_STUDY_SKILL then return end

	local starList = {}
	for i = SKILL_RESEARCH_QUALITY_MIN + 1,5 do 
		table.insert(starList,i)
	end
	m_widgetFilterStar = opHeroStarFilter.create(panel_star_filter,starList,resetHeroListByFilterStar)
end
local function init_drag_widget_info()
	local temp_widget = m_pMainLayer:getWidgetByTag(999)


	drag_widget = Layout:create()
	drag_widget:setTouchEnabled(false)
	drag_widget:setVisible(false)
	local content_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	content_widget:setName("hero_icon")
	drag_widget:addChild(content_widget)
	local light_img = ImageView:create()
	light_img:loadTexture(ResDefineUtil.Card_light_n, UI_TEX_TYPE_PLIST)
	light_img:setAnchorPoint(cc.p(0,0))
	drag_widget:addChild(light_img)

	local icon_pos_x = math.floor((light_img:getContentSize().width - content_widget:getContentSize().width)/2)
	local icon_pos_y = math.floor((light_img:getContentSize().height - content_widget:getContentSize().height)/2)
	content_widget:setPosition(cc.p(icon_pos_x, icon_pos_y))
	temp_widget:addChild(drag_widget, 9999)

end


local function set_widget_info_by_index(new_index, temp_widget)
	local show_index = new_index - start_show_index + current_index
	if show_index > 0 and show_index <= #hero_id_list then
		local hero_uid = hero_id_list[show_index]
		cardFrameInterface.set_middle_card_info(temp_widget, hero_uid, heroData.getHeroOriginalId(hero_uid))
		cardFrameInterface.set_middle_touch_sign_related(temp_widget, true, nil)
		
		get_hero_state_info(temp_widget, hero_uid)
		if is_in_selected_id(hero_uid) then
			cardFrameInterface.set_hero_state(temp_widget,2,heroStateDefine.selected_nomal)
			cardFrameInterface.set_attention_content(temp_widget,true ,languagePack["skillTipsSelected"])
		else
			-- 没有选中的卡牌对保护状态的卡牌要做处理
			local cardState,attention_text = getHeroStateInfo(hero_uid)
			local hero_info = heroData.getHeroInfo(hero_uid)
			if cardState ~= 0 and (hero_info.lock_state ~= 0) then
				cardFrameInterface.set_hero_state(temp_widget,2,cardState)
				cardFrameInterface.set_attention_content(temp_widget,cardState ~= 0 ,attention_text)
			else
				-- cardFrameInterface.set_hero_state(temp_widget,2,0)
				-- cardFrameInterface.set_attention_content(temp_widget,false ,attention_text)
				cardFrameInterface.set_hero_state(temp_widget,2,cardState)
				cardFrameInterface.set_attention_content(temp_widget,cardState ~= 0 ,attention_text)
			end

		end
		temp_widget:setVisible(true)
	else
		cardFrameInterface.reset_middle_card_info(temp_widget)
		temp_widget:setVisible(false)
	end
end

local function load_widget_info()
	if not scroll_widget_list then return end
	for k,v in pairs(scroll_widget_list) do
		set_widget_info_by_index(k,v)
	end
end


-- 设置主卡区域

local function update_main_card(new_id)
	if not new_id then new_id = 0 end

	local hero_info = heroData.getHeroInfo(new_id)
	if not hero_info then new_id = 0 end
	if hero_info and hero_info.lock_state ~= 0 then new_id = 0 end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local function load_widget( panel_container )
		local widget = panel_container:getChildByTag(888)
		if not widget then 
			widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
			widget:setTag(888)
			widget:ignoreAnchorPointForPosition(false)
			widget:setAnchorPoint(cc.p(0,0))
			panel_container:addChild(widget)
			widget:setVisible(false)
		end
		if new_id ~= 0 then 
			widget:setVisible(true)
			main_card_widget = widget
			main_card_id = new_id

			cardFrameInterface.set_middle_card_info(main_card_widget, main_card_id, heroData.getHeroOriginalId(main_card_id))
			cardFrameInterface.set_middle_touch_sign_related(main_card_widget, true, nil)
		else
			widget:setVisible(false)
			main_card_widget = nil
			main_card_id = 0
		end
	end


	if op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 
		local panel_main_2 = uiUtil.getConvertChildByName(mainWidget,"panel_main_2")
		local panel_container = uiUtil.getConvertChildByName(panel_main_2,"panel_container")
		load_widget(panel_container)
	elseif op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
		local panel_main_4 = uiUtil.getConvertChildByName(mainWidget,"panel_main_4")
		local panel_container = uiUtil.getConvertChildByName(panel_main_4,"panel_container")
		load_widget(panel_container)
	elseif op_type == SkillOperate.OP_TYPE_HERO_AWAKEN then 
		local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
		local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_1")
		load_widget(panel_container)
	end

	updateView()
end

-- 设置副卡区域
local function update_second_card(new_id)
	-- 只有 武将卡觉醒才有
	if op_type ~= SkillOperate.OP_TYPE_HERO_AWAKEN then return end

	local hero_info = heroData.getHeroInfo(new_id)
	if not hero_info then new_id = 0 end
	if hero_info and hero_info.lock_state ~= 0 then new_id = 0 end
	
	if not new_id then new_id = 0 end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local function load_widget( panel_container )
		local widget = panel_container:getChildByTag(888)
		if not widget then 
			widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
			widget:setTag(888)
			widget:ignoreAnchorPointForPosition(false)
			widget:setAnchorPoint(cc.p(0,0))
			panel_container:addChild(widget)
			widget:setVisible(false)
		end
		if new_id ~= 0 then 
			widget:setVisible(true)
			second_card_widget = widget
			second_card_id = new_id

			cardFrameInterface.set_middle_card_info(second_card_widget, second_card_id, heroData.getHeroOriginalId(second_card_id))
			cardFrameInterface.set_middle_touch_sign_related(second_card_widget, true, nil)
		else
			widget:setVisible(false)
			second_card_widget = nil
			second_card_id = 0
		end
	end

	local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
	local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_2")
	load_widget(panel_container)


	updateView()
end
local function initLayout()
	if not m_pMainLayer then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end

	local img_scroll_flag_left = uiUtil.getConvertChildByName(mainWidget,"img_scroll_flag_left")
    local img_scroll_flag_right = uiUtil.getConvertChildByName(mainWidget,"img_scroll_flag_right")
    local label_scroll_null_tips = uiUtil.getConvertChildByName(mainWidget,"label_scroll_null_tips")

    local btn_quitAdd = uiUtil.getConvertChildByName(mainWidget,"btn_quitAdd")
    local btn_quitSelect = uiUtil.getConvertChildByName(mainWidget,"btn_quitSelect")
    local panel_quitSelectList = uiUtil.getConvertChildByName(mainWidget,"panel_quitSelectList")
	btn_quitAdd:setVisible(false)
	btn_quitSelect:setVisible(false)
	panel_quitSelectList:setVisible(false)
	btn_quitAdd:setTouchEnabled(false)
	btn_quitSelect:setTouchEnabled(false)

	local sub_btnQuitSelect = nil
	for i =1,3 do 
		sub_btnQuitSelect = uiUtil.getConvertChildByName(panel_quitSelectList,"btn_quitSelect_" .. i)
		sub_btnQuitSelect:setTouchEnabled(false)
	end


	-- 技巧值转换 
	local panel_main_1 = uiUtil.getConvertChildByName(mainWidget,"panel_main_1")
	local panel_op_1 = uiUtil.getConvertChildByName(mainWidget,"panel_op_1")
    local panel_material = uiUtil.getConvertChildByName(mainWidget,"panel_material")
    panel_main_1:setVisible(false)
	panel_op_1:setVisible(false)
	panel_material:setVisible(false)
	-- 研究技能 
	local panel_main_2 = uiUtil.getConvertChildByName(mainWidget,"panel_main_2")
	local panel_op_2 = uiUtil.getConvertChildByName(mainWidget,"panel_op_2")
	local panel_intro_1 = uiUtil.getConvertChildByName(mainWidget,"panel_intro_1")
    local panel_skill_detail = uiUtil.getConvertChildByName(mainWidget,"panel_skill_detail")
    panel_main_2:setVisible(false)
	panel_op_2:setVisible(false)
	panel_skill_detail:setVisible(false)
	panel_intro_1:setVisible(false)
	
	-- 技能研究进度
	local panel_main_3 = uiUtil.getConvertChildByName(mainWidget,"panel_main_3")
    local panel_op_3 = uiUtil.getConvertChildByName(mainWidget,"panel_op_3")
    local panel_material = uiUtil.getConvertChildByName(mainWidget,"panel_material")
    panel_main_3:setVisible(false)
	panel_op_3:setVisible(false)
	panel_material:setVisible(false)

	-- 武将卡进阶
	local panel_main_4 = uiUtil.getConvertChildByName(mainWidget,"panel_main_4")
	local panel_container = uiUtil.getConvertChildByName(panel_main_4,"panel_container")
    panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)

    local panel_op_4 = uiUtil.getConvertChildByName(mainWidget,"panel_op_4")
    local panel_intro_2 = uiUtil.getConvertChildByName(mainWidget,"panel_intro_2")
    panel_main_4:setVisible(false)
    panel_op_4:setVisible(false)
    panel_intro_2:setVisible(false)


    -- 武将卡觉醒
    local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
    local panel_op_5 = uiUtil.getConvertChildByName(mainWidget,"panel_op_5")
    local panel_intro_3 = uiUtil.getConvertChildByName(mainWidget,"panel_intro_3")
    panel_main_5:setVisible(false)
    panel_op_5:setVisible(false)
    panel_intro_3:setVisible(false)
    local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_1")
    panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)
    local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_2")
    panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)




    --- 其他后续调整的
    --- 研究新技能时 没有素材卡的提示
    local panel_studySkill_hasNoMaterial = uiUtil.getConvertChildByName(mainWidget,"panel_studySkill_hasNoMaterial")
    panel_studySkill_hasNoMaterial:setBackGroundColorType(LAYOUT_COLOR_NONE)
    panel_studySkill_hasNoMaterial:setVisible(false)

    local panel_detail = uiUtil.getConvertChildByName(panel_studySkill_hasNoMaterial,"panel_detail")
    panel_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)

    --- 研究新技能时 没有素材卡 前往招募的入口按钮
    local btn_jump2Recruit = uiUtil.getConvertChildByName(panel_studySkill_hasNoMaterial,"btn_jump2Recruit")
    btn_jump2Recruit:setVisible(false)
    btn_jump2Recruit:setTouchEnabled(false)
    --- 转换技巧值面板 前往招募的入口
    local panel_jump2Recruit = uiUtil.getConvertChildByName(mainWidget,"panel_jump2Recruit")
    panel_jump2Recruit:setVisible(false)

    --- 拆解新技能 面板 添加 到技巧值的入口
    local panel_res_skillValue = uiUtil.getConvertChildByName(mainWidget,"panel_res_skillValue")
    local btn_add = uiUtil.getConvertChildByName(panel_res_skillValue,"btn_add")
    btn_add:setVisible(false)
    btn_add:setTouchEnabled(false)

    --- 玉符信息 添加一个充值跳转 
    local panel_res_gold = uiUtil.getConvertChildByName(mainWidget,"panel_res_gold")
    local btn_add = uiUtil.getConvertChildByName(panel_res_gold,"btn_add")
    btn_add:setVisible(false)
    btn_add:setTouchEnabled(false)


    if op_type == SkillOperate.OP_TYPE_TRANSFER then 
    	panel_main_1:setVisible(true)
		panel_op_1:setVisible(true)
		panel_material:setVisible(true)
    	btn_quitAdd:setVisible(true)
    	btn_quitSelect:setVisible(true)
    elseif op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 
    	panel_main_2:setVisible(true)
		panel_op_2:setVisible(true)
		panel_intro_1:setVisible(true)
    elseif op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
    	panel_main_3:setVisible(true)
    	panel_op_3:setVisible(true)
    	panel_material:setVisible(true)
    	btn_quitAdd:setVisible(false)
    	btn_quitSelect:setVisible(false)
    	local btn_tips = uiUtil.getConvertChildByName(panel_op_3,"btn_tips")
    	btn_tips:setTouchEnabled(true)
    	btn_tips:addTouchEventListener(function(sender,eventType)
    		if eventType == TOUCH_EVENT_ENDED then 
       			alertLayer.create(errorTable[2019])
       			local parentBG = comAlertConfirm.fetchContentBG()
				local paramTab = SkillDataModel.getSkillResearchConditionDetailTxt(main_skill_id)
				local contentPanel = Layout:create()
				parentBG:addChild(contentPanel)
				-- contentPanel:setBackGroundColorType(LAYOUT_COLOR_SOLID)
				contentPanel:setSize(CCSizeMake(parentBG:getSize().width,parentBG:getSize().height - 40))
				contentPanel:setPosition(cc.p(-contentPanel:getSize().width/2,-contentPanel:getSize().height/2))
				skillDetailHelper.loadResearchConditionRichText(contentPanel,paramTab,true,5)
    		end
    	end)
    elseif op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
    	panel_main_4:setVisible(true)
	    panel_op_4:setVisible(true)
	    panel_intro_2:setVisible(true)
	elseif op_type == SkillOperate.OP_TYPE_HERO_AWAKEN then
		panel_main_5:setVisible(true)
	    panel_op_5:setVisible(true)
	    panel_intro_3:setVisible(true)
	    local btn_op = uiUtil.getConvertChildByName(panel_op_5,"btn_op")
	    btn_op:setTouchEnabled(true)
	    btn_op:addTouchEventListener(function(sender,eventType)
	    	if eventType == TOUCH_EVENT_ENDED then
	            -- 觉醒协议
	            if not main_card_id or  main_card_id == 0 then
	            	-- TODOTK 中文收集
	            	tipsLayer.create("请先放入2张同星素材卡")
	            	return 
	            end
	            if not second_card_id or second_card_id == 0 then 
	            	-- TODOTK 中文收集
	            	tipsLayer.create("请先放入2张同星素材卡")
	            	return 
	            end
	            
	            SkillOpreateObserver.requestAwakeHero(target_card_id,{main_card_id,second_card_id})
	            SkillOperate.remove_self()
	    	end
	    end)
	end
end




--初始化显示卡片信息
local function init_widget_info()
	if not scroll_widget_list then return end
	for k,v in pairs(scroll_widget_list) do
		set_widget_info_by_index(k,v)
	end
end


local function set_widget_selected_state(hero_uid,isSelected,ismulti)
	if isSelected then 
		if not ismulti then
			-- 如果是单选的 先删了其他的再说
			for i = 1,#hero_id_list do 
				remove_selected_id(hero_id_list[i])
			end
		end
		add_selected_id(hero_uid)
		curr_hero_uid = nil
	else
		remove_selected_id(hero_uid)
	end
	init_widget_info()
end




local function show_material_content()
    local all_nums = #selected_id_list
    local material_widget = nil
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    local panel_material = uiUtil.getConvertChildByName(mainWidget,"panel_material")
	local panel_container = uiUtil.getConvertChildByName(panel_material,"panel_container")
	
    for i=1,SKILL_VALUE_TRANSFORM_CARD_MAX do
        material_widget = panel_container:getChildByTag(i)
        if i <= all_nums then
            cardFrameInterface.set_middle_card_info(material_widget, selected_id_list[i], heroData.getHeroOriginalId(selected_id_list[i]))
            cardFrameInterface.set_middle_touch_sign_related(material_widget, true, nil)
            material_widget:setVisible(true)
        else
            cardFrameInterface.reset_middle_card_info(material_widget)
            material_widget:setVisible(false)
        end
    end
    local label_num = uiUtil.getConvertChildByName(panel_material,"label_num")
    label_num:setText( all_nums .. "/" .. SKILL_VALUE_TRANSFORM_CARD_MAX)

    -- setCostContent()
    -- switch_visible_item()
end


local function deal_with_swap_main_and_second()
	local main_card_id_t = main_card_id
	local second_card_id_t = second_card_id
	update_main_card(second_card_id_t)
	update_second_card(main_card_id_t)
end


local function deal_with_material_card_addORdelete(new_id,isAdd)
	if not m_pMainLayer then return end

	if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
		local hero_info = heroData.getHeroInfo(new_id)
		local add_value = SkillDataModel.getStudyProgressValueByCard(main_skill_id,hero_info.heroid,hero_info.advance_num)
		local mainWidget = m_pMainLayer:getWidgetByTag(999)
		local panel_main_3 = uiUtil.getConvertChildByName(mainWidget,"panel_main_3")
		local panel_container = uiUtil.getConvertChildByName(panel_main_3,"panel_container")
		panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)
		local skillItemWidget  = uiUtil.getConvertChildByName(panel_container,"skillItemWidget" )
		
		

		local curProgress = 0
		if isAdd then 
			curProgress = 100 - m_iSkillStudyProgressLeft - add_value
		else
			curProgress = 100 - m_iSkillStudyProgressLeft + add_value
		end
		if not isAdd then add_value = -1 * add_value end

		local curProgressIndeed,_maxProgress = SkillDataModel.getSkillStudyProgressInfo(main_skill_id)
		skillItemHelper.expectedProgressing(skillItemWidget,m_pSkillItemProgressBg,m_pSkillItemProgressBgExpecting,curProgress, add_value,curProgressIndeed)
	end
end


-- 移除主卡 或者移除 素材卡
local function deal_with_delete_card(new_id)
	if not is_in_selected_id(new_id) then return end
	for k,v in pairs(selected_id_list) do 
        if v == new_id then 
            table.remove(selected_id_list,k)
        end
    end
    if type_touch_skill_area == 1 then 
    	update_main_card()
    elseif  type_touch_skill_area == 2 then 
    	update_second_card()
    end
	show_material_content()
	set_widget_selected_state(new_id,false,true)


	-- 技巧值转化的飘字效果
	if op_type == SkillOperate.OP_TYPE_TRANSFER then 
		local mainWidget = m_pMainLayer:getWidgetByTag(999)
		local add_value = SkillDataModel.getSkillValueTurnedFromHeroCard(new_id)
		skillOperateHelper.floatEffectAddingSkillValue(mainWidget,{{-add_value,false}})
	end


	updateView()


	if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
		local mainWidget = m_pMainLayer:getWidgetByTag(999)
		local hero_info = heroData.getHeroInfo(new_id)
		local add_value = SkillDataModel.getStudyProgressValueByCard(main_skill_id,hero_info.heroid,hero_info.advance_num)
		m_iSkillStudyProgressLeft = m_iSkillStudyProgressLeft + add_value
		skillOperateHelper.effectPreAddingSkillStudyProgress(mainWidget,-add_value,m_pSkillItemProgressBg,main_skill_id,m_iSkillStudyProgressLeft)
		deal_with_material_card_addORdelete(new_id,false)
	end
	
end


-- 设置主卡
local function deal_with_set_main_card(new_id)
	if new_id == main_card_id then return end
	local hero_info = heroData.getHeroInfo(new_id)
    if (hero_info.lock_state ~= 0) then 
        tipsLayer.create(errorTable[137])
        return
    end


    

    if new_id == second_card_id then 
		deal_with_swap_main_and_second()
		set_widget_selected_state(new_id,true,true)
	else
		for k,v in pairs(selected_id_list) do 
	        if v == main_card_id then 
	            table.remove(selected_id_list,k)
	        end
	    end
		table.insert(selected_id_list,new_id)
		update_main_card(new_id)
		set_widget_selected_state(new_id,true,true)
	end
	

	if op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 
    	if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_skill_operate_study_skill_draged_first") ) then 
    		comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2033)

    		CCUserDefault:sharedUserDefault():setBoolForKey("opened_skill_operate_study_skill_draged_first",true)
    	end
    end

end

-- 设置副卡
local function deal_with_set_second_card(new_id)
	if new_id == second_card_id then return end
	
	local hero_info = heroData.getHeroInfo(new_id)
    if (hero_info.lock_state ~= 0) then 
        tipsLayer.create(errorTable[137])
        return 
    end

    if new_id == main_card_id then 
    	deal_with_swap_main_and_second()
    	set_widget_selected_state(new_id,true,true)
    else
    	for k,v in pairs(selected_id_list) do 
	        if v == second_card_id then 
	            table.remove(selected_id_list,k)
	        end
	    end
	    table.insert(selected_id_list,new_id)
	    update_second_card(new_id)
		set_widget_selected_state(new_id,true,true)
    end
end




-- 添加素材卡
local function deal_with_add_material_card(new_id)
	local hero_info = heroData.getHeroInfo(new_id)
    if (hero_info.lock_state ~= 0) then 
        tipsLayer.create(errorTable[137])
        return false
    end

    if is_in_selected_id(new_id) then return end


    if #selected_id_list >= SKILL_VALUE_TRANSFORM_CARD_MAX then 
        tipsLayer.create(errorTable[132])
        return false
    end



   

    
    if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then 
    	local add_value = SkillDataModel.getStudyProgressValueByCard(main_skill_id,hero_info.heroid,hero_info.advance_num)
    	if m_iSkillStudyProgressLeft <=0 then 
    		tipsLayer.create("此战法研究度已达上限")	-- TODOTK 中文收集
    		return 
    	end
    	m_iSkillStudyProgressLeft = m_iSkillStudyProgressLeft - add_value
    	local mainWidget = m_pMainLayer:getWidgetByTag(999)
    	skillOperateHelper.effectPreAddingSkillStudyProgress(mainWidget,add_value,m_pSkillItemProgressBg,main_skill_id,m_iSkillStudyProgressLeft)

    	deal_with_material_card_addORdelete(new_id,true)
	end


	table.insert(selected_id_list,new_id)
	show_material_content()
	set_widget_selected_state(heroid,true,true)

	-- 技巧值转化的飘字效果
	if op_type == SkillOperate.OP_TYPE_TRANSFER then 
		local mainWidget = m_pMainLayer:getWidgetByTag(999)
		local add_value = SkillDataModel.getSkillValueTurnedFromHeroCard(new_id)
		skillOperateHelper.floatEffectAddingSkillValue(mainWidget,{{add_value,false}})
	end

	if op_type == SkillOperate.OP_TYPE_TRANSFER then 
    	if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_skill_operate_transfer_skillvalue_draged_first") ) then 
    		comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2027)

    		CCUserDefault:sharedUserDefault():setBoolForKey("opened_skill_operate_transfer_skillvalue_draged_first",true)
    	end
    end

	updateView()

	

	
end


----------------------------- 拖动事件  begin--------------------------------


local function judge_tb_for_skill_area(x, y)
	local is_touch_skill_area = false
	local selected_hero_id = 0
	local start_x_in_card, start_y_in_card = 0, 0
	type_touch_skill_area = nil
	-- 上半部分 素材卡区域
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local panel_material = uiUtil.getConvertChildByName(mainWidget,"panel_material")
	local panel_container = uiUtil.getConvertChildByName(panel_material,"panel_container")
	if panel_material:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		local material_widget = nil
        local temp_point = nil
		for i = #selected_id_list,1,-1 do 
			material_widget = panel_container:getChildByTag(i)
            if material_widget and material_widget:hitTest(cc.p(x, y)) then
                selected_widget = material_widget
                selected_hero_id = selected_id_list[i]
                temp_point = material_widget:convertToNodeSpace(cc.p(x, y))
                start_x_in_card = temp_point.x
                start_y_in_card = temp_point.y
                break
            end
        end
        type_touch_skill_area = 3
		is_touch_skill_area = true
	end

	-- -- 上半部分 主卡区域
	local panel_main_2 = uiUtil.getConvertChildByName(mainWidget,"panel_main_2")
	local panel_container = uiUtil.getConvertChildByName(panel_main_2,"panel_container")
	if panel_main_2:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		if main_card_id ~= 0 then
			selected_widget = main_card_widget
			selected_hero_id = main_card_id
			local temp_point = main_card_widget:convertToNodeSpace(cc.p(x, y))
			start_x_in_card = temp_point.x
			start_y_in_card = temp_point.y
		end
		is_touch_skill_area = true
		type_touch_skill_area = 1
	end

	local panel_main_4 = uiUtil.getConvertChildByName(mainWidget,"panel_main_4")
	local panel_container = uiUtil.getConvertChildByName(panel_main_4,"panel_container")
	if panel_main_4:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		if main_card_id ~= 0 then
			selected_widget = main_card_widget
			selected_hero_id = main_card_id
			local temp_point = main_card_widget:convertToNodeSpace(cc.p(x, y))
			start_x_in_card = temp_point.x
			start_y_in_card = temp_point.y
		end
		is_touch_skill_area = true
		type_touch_skill_area = 1
	end

	local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
	local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_1")
	panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)
	if panel_main_5:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		if main_card_id ~= 0 then
			selected_widget = main_card_widget
			selected_hero_id = main_card_id
			local temp_point = main_card_widget:convertToNodeSpace(cc.p(x, y))
			start_x_in_card = temp_point.x
			start_y_in_card = temp_point.y
		end
		is_touch_skill_area = true
		type_touch_skill_area = 1
	end

	-- 上半区域 添加副卡
	local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
	local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_2")

	if panel_main_5:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		if second_card_id ~= 0 then
			selected_widget = second_card_widget
			selected_hero_id = second_card_id
			local temp_point = second_card_widget:convertToNodeSpace(cc.p(x, y))
			start_x_in_card = temp_point.x
			start_y_in_card = temp_point.y
		end
		is_touch_skill_area = true
		type_touch_skill_area = 2
	end

	return is_touch_skill_area, selected_hero_id, start_x_in_card, start_y_in_card
end


local function judge_tb_for_scroll_area(x, y)
	local is_touch_scroll_area = false
	local selected_hero_id = 0
	local start_x_in_card, start_y_in_card = 0, 0

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local is_in_sort_content = false

	local card_scrollview = uiUtil.getConvertChildByName(mainWidget,"card_scrollview")
	if card_scrollview:hitTest(cc.p(x, y)) then
		local judge_widget_order = {4,3,2,5,6,7,8,9,10}
		local hero_widget = nil
		for i,v in ipairs(judge_widget_order) do
			hero_widget = scroll_widget_list[v]
			if hero_widget:hitTest(cc.p(x,y)) then
				local show_index = v - start_show_index + current_index
				if show_index > 0 and show_index <= #hero_id_list then
					selected_widget = hero_widget
					selected_hero_id = hero_id_list[show_index]
					local temp_point = hero_widget:convertToNodeSpace(cc.p(x,y))
					start_x_in_card = temp_point.x
					start_y_in_card = temp_point.y
				end
				break
			end
		end
		is_touch_scroll_area = true
	end


	if m_widgetFilterStar then 
		if opHeroStarFilter.hitTest(m_widgetFilterStar,x,y) then 
			is_touch_scroll_area = false
		end
	end
	return is_touch_scroll_area, selected_hero_id, start_x_in_card, start_y_in_card
end


local function set_selected_state(new_state)
    if selected_widget then
        if new_state then
            selected_widget:setOpacity(100)
        else
            selected_widget:setOpacity(255)
            selected_widget = nil
        end
    end
end


local function set_start_touch_pos(pos_x,pos_y)
	start_touch_x = pos_x
	start_touch_y = pos_y
end




local function on_touch_began(x,y)
	if is_moving or is_scrolling then
		return false
	end
	
	is_touch_scroll_area = false
	is_touch_skill_area = false
	is_moving = false
	is_scrolling = false

	is_touch_skill_area, selected_hero_id, start_x_in_card, start_y_in_card = judge_tb_for_skill_area(x,y)
	if not is_touch_skill_area then
		is_touch_scroll_area, selected_hero_id, start_x_in_card, start_y_in_card = judge_tb_for_scroll_area(x, y)
	end



	if is_touch_scroll_area or is_touch_skill_area then
		local temp_widget = m_pMainLayer:getWidgetByTag(999)
		local point = temp_widget:convertToNodeSpace(cc.p(x,y))
		start_touch_x = point.x
		start_touch_y = point.y
		set_start_touch_pos(start_touch_x, start_touch_y)
		return true
	else
		return false
	end
end


local function deal_with_move(current_x, current_y)
	if selected_hero_id == 0 then
		return
	end

	drag_widget:setPosition(cc.p(current_x - start_x_in_card, current_y - start_y_in_card))
	if not drag_widget:isVisible() then
		local hero_widget = tolua.cast(drag_widget:getChildByName("hero_icon"), "Layout")
		cardFrameInterface.set_middle_card_info(hero_widget, selected_hero_id, heroData.getHeroOriginalId(selected_hero_id))
		drag_widget:setVisible(true)

		if is_touch_skill_area then 
			set_selected_state(true)
		else
			if is_touch_scroll_area then 
				set_selected_state(true)
			end
		end
	end

end


local function reset_widget_show()
	for k,v in pairs(scroll_widget_list) do
		v:setScale(widget_scale_list[k])
		v:setPositionX(widget_pos_list[k])
		v:getParent():reorderChild(v, widget_order_list[k])
	end
end



local function deal_with_scroll(current_x)
	local hero_nums = #hero_id_list
	if hero_nums <= 3 then
		start_touch_x = current_x
		return
	end

	local scroll_x_distance = current_x - start_touch_x

	local is_left = false
	if scroll_x_distance < 0 then
		is_left = true
	end

	--滚动到边界时不允许继续滚动
	if is_left then
		if current_index == #hero_id_list - 2 then
			start_touch_x = current_x
			return
		end
	else
		if current_index == 1 then
			start_touch_x = current_x
			return
		end
	end

	

	local hero_widget = nil
	if is_left then
		if scroll_x_distance <= -1 * move_one_card_dis then
			current_index = current_index + 1
			hero_widget = table.remove(scroll_widget_list,1)
			set_widget_info_by_index(11, hero_widget)
			table.insert(scroll_widget_list, hero_widget)
			reset_widget_show()
			start_touch_x =  -1 * move_one_card_dis + start_touch_x
			return
		end
	else
		if scroll_x_distance >= move_one_card_dis then
			current_index = current_index - 1
			hero_widget = table.remove(scroll_widget_list, 11)
			set_widget_info_by_index(1, hero_widget)
			table.insert(scroll_widget_list, 1, hero_widget)
			reset_widget_show()
			start_touch_x = start_touch_x + move_one_card_dis
			return
		end
	end
	
	
	
	
	if is_left then
		for i=2,11 do
			hero_widget = scroll_widget_list[i]
			if i == 2 or i == 3 or i == 4 then
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * one_distance / move_one_card_dis))
			end

			if i == 5 then
				hero_widget:setScale(1 + 0.01 * math.floor(0.1 * 100 * scroll_x_distance / move_one_card_dis))
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * two_distance / move_one_card_dis))
			end

			if i == 6 or i == 7 then
				hero_widget:setPositionX(widget_pos_list[i] + scroll_x_distance * three_distance / move_one_card_dis)
			end

			if i == 8 then
				hero_widget:setScale(0.9 - 0.01 * math.floor(0.1 * 100 * scroll_x_distance/move_one_card_dis))
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * two_distance /move_one_card_dis))
			end

			if i == 9 or i == 10 or i == 11 then
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * one_distance / move_one_card_dis))
			end
		end
	else
		for i=1,10 do
			hero_widget = scroll_widget_list[i]
			if i == 1 or i == 2 or i == 3 then
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * one_distance / move_one_card_dis))
			end

			if i == 4 then
				hero_widget:setScale(0.9 + 0.01 * math.floor(0.1 * 100 * scroll_x_distance/move_one_card_dis))
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * two_distance / move_one_card_dis))
			end

			if i == 5 or i == 6 then
				hero_widget:setPositionX(widget_pos_list[i] + scroll_x_distance * three_distance / move_one_card_dis)
			end

			if i == 7 then
				hero_widget:setScale(1 - 0.01 * math.floor(0.1 * 100 * scroll_x_distance / move_one_card_dis))
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * two_distance /move_one_card_dis))
			end

			if i == 8 or i == 9 or i == 10 then
				hero_widget:setPositionX(math.floor(widget_pos_list[i] + scroll_x_distance * one_distance / move_one_card_dis))
			end
		end
	end

	local percent = 0

	if is_left then
		if current_index > 3 then
			percent = math.floor( current_index * 100 / (#hero_id_list -3 ))
		else
			percent = math.floor( current_index * 100 / #hero_id_list )
		end	
	else
		if current_index > 3 then
			percent = math.floor( current_index * 100 / #hero_id_list )
		else
			percent = math.floor( (current_index - 3) * 100 / #hero_id_list )
		end
	end
	update_scroll_percent_view(percent)
end

local function on_touch_move(x,y)
	
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local point = temp_widget:convertToNodeSpace(cc.p(x,y))

	if is_moving == false and is_scrolling == false then
		local move_x_distance = point.x - start_touch_x
		local move_y_distance = point.y - start_touch_y
		local move_distance = math.sqrt((math.pow(move_x_distance,2) + math.pow(move_y_distance,2)))
		--判定滑动的敏感范围 判定移动卡片的敏感范围
		if move_distance >= MOVE_SENSITIVE_DIS/config.getgScale() then
			if is_touch_scroll_area then
				local angle = math.deg(math.asin(move_y_distance/move_distance))
				if angle >= -30 and angle <= 30 then
					is_scrolling = true
				else
					is_moving = true
				end
			end

			if is_touch_skill_area then
				is_moving = true
			end
		end
	end

	if is_moving then
		deal_with_move(point.x, point.y)
	else
		if is_scrolling then
			deal_with_scroll(point.x)
		end
	end
end



-- 0 移除卡（移除主卡 移除副卡 移除素材卡） 1 添加主卡 2 添加副卡 3 添加素材卡 
local function deal_with_stop_drag(x,y)

	-- 上半部分 素材卡区域
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local panel_material = uiUtil.getConvertChildByName(mainWidget,"panel_material")
	local panel_container = uiUtil.getConvertChildByName(panel_material,"panel_container")
	if panel_material:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		return 3
	end



	-- 上半部分 主卡区域
	local panel_main_2 = uiUtil.getConvertChildByName(mainWidget,"panel_main_2")
	local panel_container = uiUtil.getConvertChildByName(panel_main_2,"panel_container")
	if panel_main_2:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		return 1
	end

	local panel_main_4 = uiUtil.getConvertChildByName(mainWidget,"panel_main_4")
	local panel_container = uiUtil.getConvertChildByName(panel_main_4,"panel_container")
	if panel_main_4:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		return 1
	end

	local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
	local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_1")
	if panel_main_5:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		return 1
	end

	-- 上半区域 添加副卡
	local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
	local panel_container = uiUtil.getConvertChildByName(panel_main_5,"panel_container_2")
	if panel_main_5:isVisible() and panel_container:hitTest(cc.p(x,y)) then
		return 2
	end

	return 0
end







--------------- 停止滑动 --------------------
local function deal_with_stop_scroll(x, y)
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local point = temp_widget:convertToNodeSpace(cc.p(x,y))
	local scroll_x_distance = point.x - start_touch_x
	--内部增加针对current_index的判断是为了防止那种拖过边界的问题
	if scroll_x_distance < 0 then
		if math.abs(scroll_x_distance) >= move_one_card_dis/2 then
			if current_index < #hero_id_list - 2 then
				current_index = current_index + 1
				hero_widget = table.remove(scroll_widget_list,1)
				set_widget_info_by_index(11, hero_widget)
				table.insert(scroll_widget_list, hero_widget)
			end
		end
	else
		if scroll_x_distance >= move_one_card_dis/2 then
			if current_index > 1 then
				current_index = current_index - 1
				hero_widget = table.remove(scroll_widget_list, 11)
				set_widget_info_by_index(1, hero_widget)
				table.insert(scroll_widget_list, 1, hero_widget)
			end
		end
	end
	
	reset_widget_show()
end

local function on_touch_end(x,y)
	

	if is_touch_skill_area then 
		set_selected_state(false)
	else
		if is_touch_scroll_area then 
			set_selected_state(false)
		end
	end
	if is_scrolling then
		deal_with_stop_scroll(x, y)
		is_scrolling = false
	else
		if is_moving then
			if selected_hero_id ~= 0 then
				local target_type = deal_with_stop_drag(x, y)
				if target_type == 0 then
					if is_touch_skill_area then
						deal_with_delete_card(selected_hero_id)
					end
				elseif target_type == 1 then
					if is_touch_skill_area and type_touch_skill_area == 2 then 
						deal_with_swap_main_and_second()
					elseif is_touch_scroll_area then
						deal_with_set_main_card(selected_hero_id)
					end
				elseif target_type == 2 then
					if is_touch_skill_area and type_touch_skill_area == 1 then 
						deal_with_swap_main_and_second()
					elseif is_touch_scroll_area then
						deal_with_set_second_card(selected_hero_id)
					end
				elseif target_type == 3 then
					if is_touch_scroll_area then
						deal_with_add_material_card(selected_hero_id)
					end
				end
				drag_widget:setVisible(false)
			end
			is_moving = false
		else
			if selected_hero_id ~= 0 then
				require("game/cardDisplay/userCardViewerLock")
				userCardViewerLock.create(hero_id_list,selected_hero_id)
			end
		end
	end
end

local function on_touch_cancel(x,y)
	if is_touch_scroll_area then
		set_selected_state(false)
	else
		if is_touch_skill_area then
			set_selected_state(false)
		end
	end

	if is_scrolling then
		is_scrolling = false
	else
		if is_moving then
			is_moving = false
			drag_widget:setVisible(false)
		end
	end
end
-- 界面的拖动事件
local function onTouch(eventType, x, y)
	if eventType == "began" then
		 return on_touch_began(x,y)
	elseif eventType == "moved" then
		on_touch_move(x,y)
	elseif eventType == "ended" then
		on_touch_end(x,y)
	elseif eventType == "cancelled" then
		on_touch_cancel(x,y)
	end
	return true
end


-- 初始化拖动层
local function initScrollEvent()
	if not m_pMainLayer then return end
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local drag_layer = cc.LayerColor:create(cc.c4b(0,0,0,0),temp_widget:getContentSize().width, temp_widget:getContentSize().height)
	drag_layer:setTouchEnabled(true)
	drag_layer:registerScriptTouchHandler(onTouch,false, 0, false)
	temp_widget:addChild(drag_layer)
end
----------------------------- 拖动事件 end --------------------------------

local function resetHeroWidgetListPos()
	if not scroll_widget_list then return end
	current_index = 1
	for i=1,11 do
		local hero_widget = scroll_widget_list[i] 
		if hero_widget then 
			hero_widget:setScale(widget_scale_list[i])
			hero_widget:setPosition(cc.p(widget_pos_list[i], 98))
		end
	end
	
end

-- 要分开两个 是因为 reloadData 注册了数据更新 会带上数据库刷过来的参数
function reloadData(selectIdList)
	if not m_pMainLayer then return end
	resetHeroWidgetListPos()

	organize_hero_list(selectIdList)
    load_widget_info()
    show_material_content()

    update_main_card(main_card_id)
    update_second_card(second_card_id)

    updateView()


	

    ----------------------------------------------
    m_iSkillStudyProgressLeft = 0
    
    local curProgress,maxProgress = SkillDataModel.getSkillStudyProgressInfo(main_skill_id)
    m_iSkillStudyProgressLeft = maxProgress - curProgress
end

function resetData(selectIdList)
	if not m_pMainLayer then return end
	resetHeroWidgetListPos()

	organize_hero_list(selectIdList)
    load_widget_info()
    show_material_content()

    update_main_card(main_card_id)
    update_second_card(second_card_id)

    updateView()
end



function updateRes()
	if not m_pMainLayer then return end

	updateView()
end

function dealReloadData()
	reloadData()
end
function dealWithCardUpdate(packet)
	if not m_pMainLayer then return end
	local heroUid = packet.heroid_u
	
	local flag_need_update = false
	for k,v in pairs(hero_id_list) do 
		if heroUid == v then 
			flag_need_update = true
		end
	end

	if flag_need_update then 
		local hero_info = heroData.getHeroInfo(heroUid)
		if hero_info.lock_state ~= 0 then 
			if heroUid == main_card_id then
				main_card_id = 0
			end

			if heroUid == second_card_id then 
				second_card_id = 0 
			end

			for k,v in pairs(selected_id_list) do
				if v == heroUid then 
					table.remove(selected_id_list,k)
				end
			end
		end
		reloadData(selected_id_list)
	end
end


function get_com_guide_widget(temp_guide_id)
    if not m_pMainLayer then return nil end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return nil end
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2032 then 
        return mainWidget
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2033 then 
        return mainWidget
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2036 then 
    	return mainWidget
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2026 then 
    	return mainWidget
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2027 then 
    	return mainWidget
    else
        return nil
    end
end

function create(optype,callback,mainCardId,mainSkillId,afterShowCB)

	--[[
	if cardOverviewManager then
		cardOverviewManager.update_tb_state(false)
	end

	if cardPacketManager then
		cardPacketManager.update_tb_state(false)
	end
	--]]



	require("game/skill/skill_data_model")
	SkillDataModel.create()


    if optype == SkillOperate.OP_TYPE_STUDY_SKILL then 
    	if #SkillDataModel.getSkillList() >= SKILL_NUM_MAX  then 
	    	alertLayer.create(errorTable[306])
	    	if callback then callback() end
	    	return 
	    end
    end


	if m_pMainLayer then return end
	

	if SkillOverview and SkillOverview.updateTouchEnable then 
		SkillOverview.updateTouchEnable(false)
	end

	m_star_filter_type = 0  
	-- TODOTK 中文收集
	local op_title_txt = {}
	op_title_txt[SkillOperate.OP_TYPE_TRANSFER] = "战法经验转化"
	op_title_txt[SkillOperate.OP_TYPE_STUDY_SKILL] = "拆解战法"
	op_title_txt[SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS] = "研究"
	op_title_txt[SkillOperate.OP_TYPE_HERO_ADVANCE] = "进阶"
	op_title_txt[SkillOperate.OP_TYPE_HERO_AWAKEN] = "觉醒"

	local title_txt = op_title_txt[optype]

	SkillOpreateObserver.create()

	op_type = optype
	m_closeCallBack = callback
	if op_type == SkillOperate.OP_TYPE_HERO_AWAKEN then 
		target_card_id = mainCardId
	elseif op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
		target_card_id = mainCardId
	else
		main_card_id = mainCardId
	end
    main_skill_id = mainSkillId

    current_index = 1
	sort_type = 1
	m_iQuitAddQuality = 1

	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/jinengxiangqing_2.json")
	mainWidget:setTag(999)
	mainWidget:setTouchEnabled(true)
	m_backPanel = UIBackPanel.new()
	local all_widget = m_backPanel:create(mainWidget, remove_self, title_txt , true)
	m_pMainLayer = TouchGroup:create()
	m_pMainLayer:addWidget(all_widget)
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_SKILL_OPERATE,999)
    uiManager.showConfigEffect(uiIndexDefine.UI_SKILL_OPERATE, m_pMainLayer, function()
    	if afterShowCB then 
    		afterShowCB()
    	end
    end, 999, {all_widget})


    initScrollEvent()

    initLayout()
    init_scroll_widget()
    init_drag_widget_info()
    
    

    initQuitAddEvent()
    initStarFilter()

    reloadData()

    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.add, SkillOperate.dealReloadData)
	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.remove, SkillOperate.dealReloadData)
	UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, SkillOperate.dealWithCardUpdate)


	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.add, SkillOperate.updateRes)
	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.remove, SkillOperate.updateRes)
	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, SkillOperate.updateRes)


	-- attention  以下各个分支 必须是互斥的

	if op_type == SkillOperate.OP_TYPE_TRANSFER then 

		local function finally()
			comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2026)
		end
		if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_skill_operate_transfer") ) then 
	        require("game/guide/shareGuide/picTipsManager")
	        picTipsManager.create(8,finally)
	        CCUserDefault:sharedUserDefault():setBoolForKey("opened_skill_operate_transfer",true)
	    else
	    	if m_iNonForcedGuideId == com_guide_id_list.CONST_GUIDE_2026 then 
	    		finally()
	    	end
	    end
	end


	if op_type == SkillOperate.OP_TYPE_HERO_ADVANCE then 
		if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_skill_operate_advance") ) then 
	        require("game/guide/shareGuide/picTipsManager")
	        picTipsManager.create(12)
	        CCUserDefault:sharedUserDefault():setBoolForKey("opened_skill_operate_advance",true)
	    end
	end

	if op_type == SkillOperate.OP_TYPE_STUDY_SKILL then 
		if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_skill_operate_study_skill") ) then 
	        require("game/guide/shareGuide/picTipsManager")
	        picTipsManager.create(5,function()
	        	comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2032)
	        end)
	        CCUserDefault:sharedUserDefault():setBoolForKey("opened_skill_operate_study_skill",true)
	    end
	end

	if op_type == SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then
		if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_skill_operate_study_skill_progress") ) then 
	        require("game/guide/shareGuide/picTipsManager")
	        picTipsManager.create(20)
	        CCUserDefault:sharedUserDefault():setBoolForKey("opened_skill_operate_study_skill_progress",true)
	    end
	end
	
end


------------------------------------- 一下操作协议回来后的回调---------


local function playArmatureOnce(file,parent,posX,posY,needFloating)
    if not parent then return end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/" .. file ..".ExportJson")
    local armature = CCArmature:create(file)
    
    
    armature:getAnimation():playWithIndex(0)
    parent:addChild(armature,2,2)
    if not posX or not posY then 
    	posX = parent:getContentSize().width/2
    	posY = parent:getContentSize().height/2
    end
    armature:setPosition(cc.p( posX, posY ))

    local function animationCallFunc(armatureNode, eventType, name)
        if eventType == 1 then
        	if armature then 
            	armatureNode:removeFromParentAndCleanup(true)
            	armature = nil
            	-- CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/" .. file .. ".ExportJson")
            end
        end
    end
    -- local function animationFrameFunc(...)
    -- 	print(">>>>>>>>>>>> animationFrameFunc")
    -- end
    -- armature:getAnimation():setFrameEventCallFunc(animationFrameFunc)
    if needFloating then 
		local action1 = cc.DelayTime:create(0.1)
		local action2 = CCMoveBy:create(1,ccp(0, 50*1*config.getgScale()))
		local action3 = cc.CallFunc:create(function ( )
		    if armature then
		        armature:removeFromParentAndCleanup(true)
		        armature = nil
		    end
		end)
		armature:runAction(animation.sequence({action1,action2, action3}))
	end
    
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
    
end

-------- 技巧值转换 成功后的处理
--[[
每张素材卡的情况（0：heroidu，1：heroid，2：贡献的经验，3：是否爆击（0普通，1爆击））
]]
function responseRequestTransferSkillValue(isSucceed,param)
	if not m_pMainLayer then return end
	if op_type ~= SkillOperate.OP_TYPE_TRANSFER then return end
	
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	local add_value = 0
	
	LSound.playSound(musicSound["skill_exp"])
	local crit_count = 0
	for k,v in pairs(param) do 
		if v[4] > 0 then 
			crit_count = crit_count + 1
		end
		add_value = add_value + v[3]
	end
	skillOperateHelper.floatEffectAddingSkillValue(mainWidget,{{add_value,false}})

	local panel_main_1 = uiUtil.getConvertChildByName(mainWidget,"panel_main_1")

	local function effectCrit()
        playArmatureOnce("29_baoji",panel_main_1,panel_main_1:getSize().width/2,-panel_main_1:getSize().height/2,true)
        LSound.playSound(musicSound["skill_expreward"])
    end
    for i = 1 ,crit_count do 
        local action1 = cc.DelayTime:create(0.2 * (i-1))
        local action3 = cc.CallFunc:create(function ( )
            effectCrit()
        end)
        panel_main_1:runAction(animation.sequence({action1, action3}))
    end

end


-- 技能提升研究度成功
function responeSkillImproveStudyValueSucceed(newSkillGained)
	if not m_pMainLayer then return end
	if op_type ~= SkillOperate.OP_TYPE_SKILL_STUDY_PROGRESS then return end
	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if not mainWidget then return end

	local panel_main_3 = uiUtil.getConvertChildByName(mainWidget,"panel_main_3")
	local panel_container = uiUtil.getConvertChildByName(panel_main_3,"panel_container")
	panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local skillItemWidget  = uiUtil.getConvertChildByName(panel_container,"skillItemWidget" )

	if newSkillGained then 
		skillItemHelper.playArmatureEffect(skillItemWidget,"yanjiu")
	else
		skillItemHelper.playArmatureEffect(skillItemWidget,"yanjiu")
	end

	if m_pSkillItemProgressBgExpecting then 
		m_pSkillItemProgressBgExpecting:setVisible(false)
	end
end
