local m_main_widget = nil
local m_widget_list = nil 			--部队各个位置组件的列表
local m_soldier_list_in_scene = nil --场景中的部队列表
local m_pos_list = nil 				--部队中卡牌显示位置坐标信息
local m_soldier_offset_y = nil 		--部队出现位置相对于卡牌的偏移值

local function remove()
	for k,v in pairs(m_soldier_list_in_scene) do
		if v ~= 0 then
			v:removeFromParentAndCleanup(true)
		end
	end
	m_soldier_list_in_scene = nil

	m_pos_list = nil
	m_soldier_offset_y = nil
	m_widget_list = nil

	m_main_widget = nil
end

local function init_card_panel_pos()
	local scene_width = config.getWinSize().width
	local scene_height = config.getWinSize().height

	m_pos_list = {}
	m_pos_list[1] = {scene_width * 0.22, scene_height * 0.3}
	m_pos_list[2] = {scene_width * 0.45, scene_height * 0.41}
	m_pos_list[3] = {scene_width * 0.67, scene_height * 0.52}
end

local function organize_pos_base_content(index, icon_img, is_unopen)
	local add_sign_1 = tolua.cast(icon_img:getChildByName("add_sign_1"), "ImageView")
	local add_sign_2 = tolua.cast(icon_img:getChildByName("add_sign_2"), "ImageView")
	local unopen_sign_1 = tolua.cast(icon_img:getChildByName("unopen_sign"), "ImageView")
	local unopen_sign_2 = tolua.cast(icon_img:getChildByName("lock_sign_img"), "ImageView")

	if is_unopen then
		add_sign_1:setVisible(false)
		add_sign_2:setVisible(false)
		unopen_sign_1:setVisible(true)
		unopen_sign_2:setVisible(true)
	else
		local is_need_anim = false
		if index == 3 then
			local show_sign = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[9])
			if show_sign == 0 then
				if exerciseData.get_hero_by_index(index) == 0 then
					is_need_anim = true
				else
					CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[9], 1)
				end
			end
		end

		if is_need_anim then
			add_sign_1:setVisible(false)
			add_sign_2:setVisible(false)
			unopen_sign_1:setVisible(true)
			unopen_sign_2:setVisible(true)

			local function deal_with_second_anim_finish()
				local temp_need_time = 0.3
			    local light_img = nil
			    for i=1,2 do
		            light_img = tolua.cast(icon_img:getChildByName("light_" .. i), "ImageView")
		            breathAnimUtil.start_anim(light_img, false, 0, 128, temp_need_time, 1)

		            light_img:setScale(1)
		            if i == 1 then
		            	light_img:runAction(CCScaleTo:create(temp_need_time, 1.4))
		            else
		            	light_img:runAction(CCScaleTo:create(temp_need_time, 1.05))
		            end
		            light_img:setVisible(true)
		        end
			end

			local function deal_with_first_anim_finish()
				add_sign_1:runAction(CCFadeIn:create(0.4))
				local fun_call_2 = cc.CallFunc:create(deal_with_second_anim_finish)
				local temp_seq_2 = cc.Sequence:createWithTwoActions(CCFadeIn:create(0.4), fun_call_2)
				add_sign_2:runAction(temp_seq_2)
				add_sign_1:setVisible(true)
				add_sign_2:setVisible(true)
			end

			local temp_spawn = CCSpawn:createWithTwoActions(CCScaleTo:create(0.4, 1.8), CCFadeOut:create(0.4))
			unopen_sign_1:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCActionInterval"))
			local fun_call_1 = cc.CallFunc:create(deal_with_first_anim_finish)
			local temp_seq_1 = cc.Sequence:createWithTwoActions(temp_spawn, fun_call_1)
			unopen_sign_2:runAction(temp_seq_1)

			CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[9], 1)
		else
			add_sign_1:setVisible(true)
			add_sign_2:setVisible(true)
			unopen_sign_1:setVisible(false)
			unopen_sign_2:setVisible(false)
		end
	end
end

local function organize_hero_content(hero_widget, show_soldier_nums, index)
	local hero_uid = exerciseData.get_hero_by_index(index)

	if m_soldier_list_in_scene[index] ~= 0 then
		m_soldier_list_in_scene[index]:removeFromParentAndCleanup(true)
	end

	if hero_uid == 0 then
		cardFrameInterface.reset_middle_card_info(hero_widget)
		hero_widget:setVisible(false)
		m_soldier_list_in_scene[index] = 0
	else		
		local hero_info = heroData.getHeroInfo(hero_uid)
		cardFrameInterface.set_middle_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid))
		local hp_txt = cardFrameInterface.get_hp_txt(hero_widget, 2)
		hp_txt:setText(show_soldier_nums)
		hero_widget:setVisible(true)

		local param_table = {}
		param_table.position = index
		param_table.heroid = heroData.getHeroOriginalId(hero_uid)
		param_table.army = show_soldier_nums
		local show_batchnode = BattleArmyPos.returnOneArmyPos(param_table)
		show_batchnode:setPosition(cc.p(m_pos_list[index][1], m_pos_list[3][2] - m_soldier_offset_y))
		m_main_widget:addChild(show_batchnode, -1)
		m_soldier_list_in_scene[index] = show_batchnode
	end
end

local function organize_show_content()
	local temp_land_index = exerciseMapManager.get_select_land_index()
	local temp_hero_nums, temp_soldier_nums = exerciseData.get_exercise_army_condition(temp_land_index)
	local hero_panel, icon_img, hero_widget = nil, nil, nil
	local hero_uid = 0
	for i=1,3 do
		hero_panel = m_widget_list[i]

		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		if i > temp_hero_nums then
			organize_pos_base_content(i, icon_img, true)
		else
			organize_pos_base_content(i, icon_img, false)
		end

		hero_widget = tolua.cast(icon_img:getChildByName("hero_icon"), "Layout")
		organize_hero_content(hero_widget, temp_soldier_nums, i)
	end
end

local function create(temp_widget)
	require("game/battle/battleArmyPos")
	m_main_widget = temp_widget
	init_card_panel_pos()
	m_soldier_list_in_scene = {0, 0, 0}
	m_soldier_offset_y = 50

	m_widget_list = {}
	local hero_base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	local hero_panel, icon_img, hero_widget = nil, nil, nil
	for i=1,3 do
		hero_panel = tolua.cast(m_main_widget:getChildByName("hero_" .. i), "Layout")
		hero_panel:setPosition(cc.p(m_pos_list[i][1], m_pos_list[3][2]))

		icon_img = tolua.cast(hero_panel:getChildByName("icon_img"), "ImageView")
		--icon_img:addTouchEventListener(deal_with_icon_click)
		--icon_img:setTouchEnabled(true)

		hero_widget = hero_base_widget:clone()
		hero_widget:ignoreAnchorPointForPosition(false) 
		hero_widget:setAnchorPoint(cc.p(0.5,0.5)) 
		hero_widget:setName("hero_icon")
		icon_img:addChild(hero_widget)

		table.insert(m_widget_list, hero_panel)
	end

	organize_show_content()
end

exerciseArmyHeroManager = {
					create = create,
					remove = remove,
					organize_show_content = organize_show_content
}