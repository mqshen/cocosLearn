--该部分是针对部队编成管理界面中卡牌滚动显示部分管理的代码，只针对该部分服务，所以其他的地方不要用这个类中的方法
local scroll_frame_widget = nil
local m_left_img = nil
local m_right_img = nil
local current_city_id = nil

local selected_widget = nil
local hero_id_list = nil

local current_index = nil 	--指定开始显示的索引（我们以从做开始第一个正常显示的卡片）
local start_show_index = nil 	--第几个位置上显示指定的索引
local move_one_card_dis = nil 	--移动多少像素算是滚动了一个卡牌

local scroll_widget_list = nil	--滚动区域内创建英雄显示列表
local widget_pos_list = nil
local widget_scale_list = nil		--小卡牌相对正常尺寸的缩放比例
local widget_order_list = nil

local start_touch_x, start_touch_y = nil, nil 		--开始选中的坐标（相对于WIDGET中的位置,采用这个是在移动时计算位移值获取一层组件就好了）

local card_sort_widget = nil	--排序方式选择
local sort_type = nil
local m_frame_height = nil 		--滚动窗口的高度，用于处理出现，显示移动动画

local m_is_playing_anim = nil

local cardSortOption = require("game/cardDisplay/card_sort_option")

local function init_const_param_info()
	move_one_card_dis = 140

	widget_pos_list = {33, 63, 93, 123, 263, 403, 543, 683, 713, 743, 773}
	widget_scale_list = {0.9, 0.9, 0.9, 0.9, 1, 1, 1, 0.9, 0.9, 0.9, 0.9}
	widget_order_list = {1, 2, 3, 4, 9, 10, 11, 8, 7, 6, 5}
end

local function set_current_index(temp_index)
	current_index = temp_index

	if not hero_id_list then
		return
	end

	if m_left_img then
		if current_index <= 4 then
			m_left_img:setVisible(false)
		else
			m_left_img:setVisible(true)
		end
	end

	if m_right_img then
		local hero_nums = #hero_id_list
		if current_index + 6 <= hero_nums then
			m_right_img:setVisible(true)
		else
			m_right_img:setVisible(false)
		end
	end
end

local function init_param_info()
	set_current_index(1)
	start_show_index = 5
	m_is_playing_anim = false

	start_touch_x = 0
	start_touch_y = 0

	--引导期间按照获得时间排序
	if newGuideManager.get_guide_state() then
		sort_type = 10
	else
		sort_type = 1
	end
end

local function remove()
	hero_id_list = nil
	current_city_id = nil

	current_index = nil
	start_show_index = nil
	move_one_card_dis = nil

	scroll_widget_list = nil
	widget_pos_list = nil
	widget_scale_list = nil
	widget_order_list = nil

	start_touch_x = nil
	start_touch_y = nil

	card_sort_widget = nil
	sort_type = nil
	m_is_playing_anim = nil

	m_left_img = nil
	m_right_img = nil
	selected_widget = nil
	scroll_frame_widget = nil
	m_frame_height = nil
end

local function set_widget_info_by_index(new_index, temp_widget)
	local show_index = new_index - start_show_index + current_index
	if show_index > 0 and show_index <= #hero_id_list then
		local hero_uid = hero_id_list[show_index]
		cardFrameInterface.set_middle_card_info(temp_widget, hero_uid, heroData.getHeroOriginalId(hero_uid))
		local show_tips_type = heroData.get_hero_state_in_office(hero_uid, current_city_id)
		cardFrameInterface.set_hero_state(temp_widget, 2, show_tips_type)
		cardFrameInterface.set_middle_touch_sign_related(temp_widget, true, nil)

		if show_tips_type == heroStateDefine.inarmy then
			local temp_army_id = heroData.getHeroArmyId(hero_uid)
			if math.floor(temp_army_id/10) ~= current_city_id then
				cardFrameInterface.set_hero_tips_content(temp_widget, 2, landData.get_city_name_lv_by_coordinate(math.floor(temp_army_id/10)), true)
			end
		end
		temp_widget:setVisible(true)
	else
		cardFrameInterface.reset_middle_card_info(temp_widget)
		temp_widget:setVisible(false)
	end
end

local function organize_hero_list()
	hero_id_list = {}
	for k,v in pairs(heroData.getAllHero()) do
		table.insert(hero_id_list, k)
	end
	--暂时升序排列
	cardSortManager.sort_fun_for_uid(hero_id_list, sort_type, true)

	local num_txt = tolua.cast(scroll_frame_widget:getChildByName("num_label"), "Label")
	num_txt:setText(#hero_id_list .. "/" .. sysUserConfigData.get_card_bag_nums())

	local bg_img = tolua.cast(scroll_frame_widget:getChildByName("bg_img"), "ImageView")
	local nohero_txt = tolua.cast(bg_img:getChildByName("nohero_label"), "Label")
	if #hero_id_list == 0 then
		nohero_txt:setVisible(true)
	else
		nohero_txt:setVisible(false)
	end
end

--初始化显示卡片信息
local function init_widget_info()
	for k,v in pairs(scroll_widget_list) do
		set_widget_info_by_index(k,v)
	end
end

--重新设置显示卡片的信息
local function reset_widget_info()
	organize_hero_list()
	local hero_nums = #hero_id_list
	if hero_nums <= 3 then
		set_current_index(1)
	else
		if current_index > hero_nums - 2 then
			set_current_index(hero_nums - 2)
		else
			set_current_index(current_index)
		end
	end
	init_widget_info()
end

local function update_sort_panel_state(new_state)
	cardSortOption.setVisible(card_sort_widget,new_state,true)
end

local function deal_with_sort_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		 local select_index = tonumber(string.sub(sender:getName(),5))
		 if select_index ~= sort_type then
		 	sort_type = select_index
		 	set_current_index(1)
		 	reset_widget_info()
		 end
		 update_sort_panel_state(false)
	end
end

local function show_sort_list_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED and armyWholeManager.get_current_stage() == 2 then
		if card_sort_widget then
			if card_sort_widget:isVisible() then
				update_sort_panel_state(false)
			else
				update_sort_panel_state(true)
			end
		else
			
			local posx = sender:getPositionX() - sender:getContentSize().width/2
			local posy = sender:getPositionY()
			card_sort_widget = cardSortOption.create(sender:getParent(),posx,posy,0.6,deal_with_sort_click)
			
			update_sort_panel_state(true)
		end
	end
end

local function init_scroll_widget_info()
	local temp_sort_btn = tolua.cast(scroll_frame_widget:getChildByName("sort_btn"), "Button")
	temp_sort_btn:setTouchEnabled(true)
	temp_sort_btn:addTouchEventListener(show_sort_list_click)

	local temp_container = tolua.cast(scroll_frame_widget:getChildByName("card_scrollview"), "ScrollView")

	local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
	scroll_widget_list = {}
	local hero_widget = nil
	for i=1,11 do
		hero_widget = base_widget:clone()
		hero_widget:ignoreAnchorPointForPosition(false)
		hero_widget:setAnchorPoint(cc.p(0.5,0.5))
		hero_widget:setScale(widget_scale_list[i])
		hero_widget:setPosition(cc.p(widget_pos_list[i], 98))
		temp_container:addChild(hero_widget, widget_order_list[i])
		table.insert(scroll_widget_list, hero_widget)
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
			set_current_index(current_index + 1)
			hero_widget = table.remove(scroll_widget_list,1)
			set_widget_info_by_index(11, hero_widget)
			table.insert(scroll_widget_list, hero_widget)
			reset_widget_show()
			start_touch_x =  -1 * move_one_card_dis + start_touch_x
			return
		end
	else
		if scroll_x_distance >= move_one_card_dis then
			set_current_index(current_index - 1)
			hero_widget = table.remove(scroll_widget_list, 11)
			set_widget_info_by_index(1, hero_widget)
			table.insert(scroll_widget_list, 1, hero_widget)
			reset_widget_show()
			start_touch_x = start_touch_x + move_one_card_dis
			return
		end
	end

	--三个参数含义：重叠部分间距；缩放交界处间距；正规显示部分间距
	local one_distance, two_distance, three_distance = 30, 140, 140
	
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
end

local function deal_with_stop_scroll(x, y)
	local scroll_x_distance = x - start_touch_x
	--内部增加针对current_index的判断是为了防止那种拖过边界的问题
	if scroll_x_distance < 0 then
		if math.abs(scroll_x_distance) >= move_one_card_dis/2 then
			if current_index < #hero_id_list - 2 then
				set_current_index(current_index + 1)
				hero_widget = table.remove(scroll_widget_list,1)
				set_widget_info_by_index(11, hero_widget)
				table.insert(scroll_widget_list, hero_widget)
			end
		end
	else
		if scroll_x_distance >= move_one_card_dis/2 then
			if current_index > 1 then
				set_current_index(current_index - 1)
				hero_widget = table.remove(scroll_widget_list, 11)
				set_widget_info_by_index(1, hero_widget)
				table.insert(scroll_widget_list, 1, hero_widget)
			end
		end
	end

	reset_widget_show()
end

local function judge_tb_for_scroll_area(x, y)
	local is_touch_scroll_area = false
	local selected_hero_id = 0
	local start_x_in_card, start_y_in_card = 0, 0

	local is_in_sort_content = false
	if card_sort_widget and card_sort_widget:isVisible() then
		is_in_sort_content = true

		local temp_sort_btn = tolua.cast(scroll_frame_widget:getChildByName("sort_btn"), "Button")
		if not (temp_sort_btn:hitTest(cc.p(x, y)) or card_sort_widget:hitTest(cc.p(x, y))) then
			update_sort_panel_state(false)
		end
	end

	if not is_in_sort_content then
		local temp_container = tolua.cast(scroll_frame_widget:getChildByName("card_scrollview"), "ScrollView")
		if temp_container:hitTest(cc.p(x, y)) then
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
	end

	return is_touch_scroll_area, selected_hero_id, start_x_in_card, start_y_in_card
end

--[[
local function set_show_state(new_state)
	if not scroll_frame_widget then
		return
	end

	if new_state then
		scroll_frame_widget:setAnchorPoint(cc.p(0.5, 0))
		scroll_frame_widget:setPosition(cc.p(config.getWinSize().width/2, 0))
	else
		scroll_frame_widget:setAnchorPoint(cc.p(0.5, 1))
		scroll_frame_widget:setPosition(cc.p(config.getWinSize().width/2, 0))
	end

	scroll_frame_widget:setVisible(new_state)
end
--]]

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

local function set_start_touch_pos(pos_x, pos_y)
	start_touch_x = pos_x
	start_touch_y = pos_y
end

local function is_play_anim()
	return m_is_playing_anim
end

local function deal_with_anim_finish()
	m_is_playing_anim = false
end

local function deal_with_leave_set()
	m_is_playing_anim = true
	local move_to = CCMoveTo:create(0.2, ccp(scroll_frame_widget:getPositionX(), 0))
	local fun_call = cc.CallFunc:create(deal_with_anim_finish)
	local temp_seq = cc.Sequence:createWithTwoActions(move_to, fun_call)
	scroll_frame_widget:runAction(temp_seq)

	local return_sign = tolua.cast(scroll_frame_widget:getChildByName("return_btn"), "Button")
	return_sign:setVisible(false)
end

local function set_city_id(new_city_id)
	current_city_id = new_city_id

	init_param_info()
	reset_widget_info()

	if armyWholeManager.get_current_stage() == 1 then
		m_is_playing_anim = true
		local move_to = CCMoveTo:create(0.2, ccp(scroll_frame_widget:getPositionX(), m_frame_height))
		local fun_call = cc.CallFunc:create(deal_with_anim_finish)
		local temp_seq = cc.Sequence:createWithTwoActions(move_to, fun_call)
		scroll_frame_widget:runAction(temp_seq)

		local return_sign = tolua.cast(scroll_frame_widget:getChildByName("return_btn"), "Button")
		return_sign:setVisible(true)
	end
end

local function is_touch_widget(x, y)
	if scroll_frame_widget then
		if card_sort_widget and card_sort_widget:isVisible() then
			return true
		end

		if scroll_frame_widget:hitTest(cc.p(x, y)) then
			local return_sign = tolua.cast(scroll_frame_widget:getChildByName("return_btn"), "Button")
			if return_sign:hitTest(cc.p(x, y)) then
				return false
			else
				return true
			end
		else
			return false
		end
	else
		return false
	end
end

local function create(parent_con)
	scroll_frame_widget = GUIReader:shareReader():widgetFromJsonFile("test/armyOfficeUI.json")
	m_frame_height = scroll_frame_widget:getContentSize().height * config.getgScale()
	--print("======================" .. scroll_frame_widget:getSize().height .. "/" .. m_frame_height)
	scroll_frame_widget:setName("scroll_view")
	scroll_frame_widget:ignoreAnchorPointForPosition(false)
	scroll_frame_widget:setAnchorPoint(cc.p(0.5, 1))
	scroll_frame_widget:setScale(config.getgScale())
	scroll_frame_widget:setPosition(cc.p(config.getWinSize().width/2, 0))
	parent_con:addChild(scroll_frame_widget)

	init_const_param_info()
	init_scroll_widget_info()

	local bg_img = tolua.cast(scroll_frame_widget:getChildByName("bg_img"), "ImageView")
	m_left_img = tolua.cast(bg_img:getChildByName("left_img"), "ImageView")
	m_right_img = tolua.cast(bg_img:getChildByName("right_img"), "ImageView")
	breathAnimUtil.start_scroll_dir_anim(m_left_img, m_right_img)
end

armyScrollManager = {
							create = create,
							remove = remove,
							set_city_id = set_city_id,
							is_touch_widget = is_touch_widget,
							is_play_anim = is_play_anim,
							deal_with_leave_set = deal_with_leave_set,
							reset_widget_info = reset_widget_info,
							set_selected_state = set_selected_state,
							judge_tb_for_scroll_area = judge_tb_for_scroll_area,
							set_start_touch_pos = set_start_touch_pos,
							deal_with_scroll = deal_with_scroll,
							deal_with_stop_scroll = deal_with_stop_scroll
}