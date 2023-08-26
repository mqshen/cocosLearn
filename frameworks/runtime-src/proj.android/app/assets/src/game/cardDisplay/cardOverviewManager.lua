local card_overview_layer = nil
local temp_widget = nil
local m_backPanel = nil
local m_card_tb_view = nil
local touch_response_area = nil

local card_sort_widget = nil	--排序方式选择
local sort_type = nil
local m_hero_id_list = nil
local m_is_card_click = nil --卡牌与排序按钮点击有穿透问题
local num_per_line = nil --每行显示的卡牌数

local cardSortOption = require("game/cardDisplay/card_sort_option")
local uiUtil = require("game/utils/ui_util")

local function do_remove_self()
	if card_overview_layer then
		temp_widget = nil
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end
		m_card_tb_view = nil
		touch_response_area = nil

		card_sort_widget = nil
		sort_type = nil
		m_hero_id_list = nil

		card_overview_layer:removeFromParentAndCleanup(true)
		card_overview_layer = nil
		
		UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, cardOverviewManager.dealWithHeroChange)

		cardTextureManager.remove_cache()
		uiManager.remove_self_panel(uiIndexDefine.CARD_OVERVIEW_UI)
	end
end

local function remove_self(closeEffect)
	if closeEffect then 
		do_remove_self()
		return
	end
    if m_backPanel then
    	uiManager.hideConfigEffect(uiIndexDefine.CARD_OVERVIEW_UI, card_overview_layer, do_remove_self, 999, {m_backPanel:getMainWidget()})
    end
end


local function update_tb_state(new_state)
	if not card_overview_layer then
		return
	end

	if m_card_tb_view then
		m_card_tb_view:setTouchEnabled(new_state)
		--if new_state then
			cardOverviewManager.reload_data(true)
		--end
	end
end

local function update_show_level(is_most_above)
	if m_card_tb_view then
		m_card_tb_view:setTouchEnabled(is_most_above)
		if is_most_above then
			cardOverviewManager.reload_data(true)
		end
	end
	--暂时不调用上面的了，因为这个函数在任何装填都刷新一遍列表，至于为什么，应该是跟排序按钮有关，没时间去查，先这样吧
	--update_tb_state(is_most_above)
end

local function update_sort_panel_state(new_state)
	if new_state then
		m_is_card_click = false
	else
		m_is_card_click = true
	end
	cardSortOption.setVisible(card_sort_widget,new_state,true)

	update_tb_state(not new_state)
end

local function dealwithTouchEvent(x, y)
	if not card_overview_layer then
		return false
	end

	if card_sort_widget and card_sort_widget:isVisible() then
		local temp_sort_btn = tolua.cast(temp_widget:getChildByName("sort_btn"), "Button")
		if not (temp_sort_btn:hitTest(cc.p(x, y)) or card_sort_widget:hitTest(cc.p(x, y))) then
			update_sort_panel_state(false)
			return true
		end
	end

	return false
end

local function is_response_touch_end()
	if m_card_tb_view:isTouchEnabled() and uiManager:getLastMoveState() then
		return false
	end

	local card_list_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")
	local touch_pos = card_list_panel:convertToNodeSpace(uiManager.getLastPoint())

	return touch_response_area:containsPoint(touch_pos)
end

local function deal_with_sort_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		 local select_index = tonumber(string.sub(sender:getName(),5))
		 if select_index ~= sort_type then
		 	sort_type = select_index
		 	--cardOverviewManager.reload_data()
		 end
		 update_sort_panel_state(false)
	end
end

local function show_sort_list_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if card_sort_widget then
			if card_sort_widget:isVisible() then
				update_sort_panel_state(false)
			else
				update_sort_panel_state(true)
			end
		else

			local posx = sender:getPositionX() - sender:getContentSize().width/2
			local posy = sender:getPositionY()
			card_sort_widget = cardSortOption.create(sender:getParent(),posx,posy,0.75,deal_with_sort_click)
			
			update_sort_panel_state(true)
		end
	end
end

local function scrollViewDidScroll(view)
    local up_img = tolua.cast(temp_widget:getChildByName("up_img"), "ImageView")
    local down_img = tolua.cast(temp_widget:getChildByName("down_img"), "ImageView")
    if view:getContentOffset().y < 0 then
    	down_img:setVisible(true)
    else
    	down_img:setVisible(false)
    end

	if view:getContentSize().height + view:getContentOffset().y > view:getViewSize().height then
		up_img:setVisible(true)
	else
		up_img:setVisible(false)
	end
end

local function tableCellTouched(table,cell)
end

local function cellSizeForTable(table,idx)
	return 222, 970
end

local function show_cell_content(cell_widget, idx)
	local start_index = idx * num_per_line + 1
	local end_index = (idx + 1) * num_per_line
	if end_index > #m_hero_id_list then
		end_index = #m_hero_id_list
	end

	local function deal_with_card_click(sender)
		if is_response_touch_end() then
			if card_sort_widget and card_sort_widget:isVisible() then
				return
			end

			local select_index = tonumber(string.sub(sender:getParent():getName(),7))
			local temp_hero_uid = m_hero_id_list[start_index + select_index - 1]
			if temp_hero_uid ~= 0 then
				--update_tb_state(false)
				require("game/cardDisplay/userCardViewer")
				userCardViewer.create(m_hero_id_list,temp_hero_uid)
			end
		end
	end

	for i=1,num_per_line do
		local hero_panel = tolua.cast(cell_widget:getChildByName("panel_" .. i), "Layout")
		hero_panel:setVisible(false)
		local hero_widget = tolua.cast(hero_panel:getChildByName("hero_icon"), "Layout")
		hero_widget:setTouchEnabled(false)
	end

	for j=start_index,end_index do
		local hero_panel = tolua.cast(cell_widget:getChildByName("panel_" .. (j - start_index + 1)), "Layout")
		local hero_widget = tolua.cast(hero_panel:getChildByName("hero_icon"), "Layout")
		local hero_uid = m_hero_id_list[j]
		cardFrameInterface.set_middle_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid))

		local hero_info = heroData.getHeroInfo(hero_uid)
		if hero_info and hero_info.armyid ~= 0 then
			cardFrameInterface.set_hero_state(hero_widget, 2, heroStateDefine.inarmy)
			cardFrameInterface.set_hero_tips_content(hero_widget, 2, landData.get_city_name_lv_by_coordinate(math.floor(hero_info.armyid/10)), true)
		else
			--cardFrameInterface.set_hero_tips_content(hero_widget, 2, " ", false)
		end
		if hero_info then
			cardFrameInterface.set_left_point_info(hero_widget, hero_info.point_left,hero_info.heroid_u)
		end

		if m_is_card_click then
			cardFrameInterface.set_middle_touch_sign_related(hero_widget, true, deal_with_card_click)
			--hero_panel:addTouchEventListener(deal_with_card_click)
			--hero_panel:setTouchEnabled(true)
		end
		hero_panel:setVisible(true)
	end
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local cell_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardOverviewCell.json")
		local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameMiddle.json")
		for i=1, num_per_line do
			local hero_panel = tolua.cast(cell_widget:getChildByName("panel_" .. i), "Layout")
			local hero_widget = base_widget:clone()
			hero_widget:ignoreAnchorPointForPosition(false)
			hero_widget:setAnchorPoint(cc.p(0.5,0.5))
			hero_widget:setPosition(cc.p(70, 98))
			hero_widget:setName("hero_icon")
			hero_panel:addChild(hero_widget)
		end
		
	    cell_widget:setTag(1)
	    local cell_layer = TouchGroup:create()
	    cell_layer:setTag(123)
	    cell_layer:addWidget(cell_widget)
	    cell = CCTableViewCell:new()
	    cell:addChild(cell_layer)
	end
    
    local temp_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if not temp_layer then
    	return cell
    end
     
    local temp_cell_widget = temp_layer:getWidgetByTag(1)
    if not temp_cell_widget then
    	return cell
    end
    show_cell_content(temp_cell_widget, idx)

    return cell
end

local function numberOfCellsInTableView(table)
	local hero_nums = #m_hero_id_list
	if hero_nums%num_per_line == 0 then
		return hero_nums/num_per_line
	else
		return math.floor(hero_nums/num_per_line) + 1
	end
end

local function set_scroll_layout()
	local height = 0
	local winsize = config.getWinSize()

	local bottom_interval_1 = 60
	local bottom_interval_2 = 69

	local bg_img_1 = tolua.cast(temp_widget:getChildByName("scroll_area_img"), "ImageView")
	bg_img_1:setPosition(cc.p(bg_img_1:getPositionX() - bg_img_1:getSize().width/2, bg_img_1:getPositionY() + bg_img_1:getSize().height/2))
	bg_img_1:setAnchorPoint(cc.p(0, 1))
	local point_1 = temp_widget:convertToWorldSpace(cc.p(bg_img_1:getPositionX(),bg_img_1:getPositionY()))
	local panel_height_1 = point_1.y / config.getgScale()
	bg_img_1:setSize(CCSize(bg_img_1:getSize().width, panel_height_1))

	local bg_new_img = tolua.cast(temp_widget:getChildByName("bg_panel"), "Layout")
	bg_new_img:setPosition(cc.p(bg_new_img:getPositionX(), bg_new_img:getPositionY() + bg_new_img:getSize().height))
	bg_new_img:setAnchorPoint(cc.p(0, 1))
	local new_bg_point = temp_widget:convertToWorldSpace(cc.p(bg_new_img:getPositionX(),bg_new_img:getPositionY()))
	local panel_height_new = new_bg_point.y / config.getgScale()
	bg_new_img:setSize(CCSize(bg_new_img:getSize().width, panel_height_new))

	local bg_img_2 = tolua.cast(temp_widget:getChildByName("bg_img"), "ImageView")
	bg_img_2:setPosition(cc.p(bg_img_2:getPositionX() - bg_img_2:getSize().width/2, bg_img_2:getPositionY() + bg_img_2:getSize().height/2))
	bg_img_2:setAnchorPoint(cc.p(0, 1))
	local point_2 = temp_widget:convertToWorldSpace(cc.p(bg_img_2:getPositionX(),bg_img_2:getPositionY()))
	local panel_height_2 = (point_2.y - bottom_interval_1 * config.getgScale()) / config.getgScale()
	bg_img_2:setSize(CCSize(bg_img_2:getSize().width, panel_height_2))

	local card_list_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")
	local panel_height_3 = (point_2.y - bottom_interval_2 * config.getgScale())/config.getgScale()
	card_list_panel:setPositionY(card_list_panel:getPositionY() + card_list_panel:getContentSize().height - panel_height_3)
	card_list_panel:setSize(CCSize(card_list_panel:getContentSize().width, panel_height_3))

	local down_img = tolua.cast(temp_widget:getChildByName("down_img"), "ImageView")
	down_img:setPositionY(card_list_panel:getPositionY() + down_img:getContentSize().height/2)

	local temp_sort_btn = tolua.cast(temp_widget:getChildByName("sort_btn"), "Button")
	temp_sort_btn:setPositionY(bg_img_2:getPositionY() - panel_height_2/2)
	local temp_zs_img = tolua.cast(temp_widget:getChildByName("zs_img"), "ImageView")
	temp_zs_img:setPositionY(bg_img_2:getPositionY() - panel_height_2/2)

	local num_txt = tolua.cast(temp_widget:getChildByName("num_label"), "Label")
	local left_img = tolua.cast(temp_widget:getChildByName("left_line_img"), "ImageView")
	local right_img = tolua.cast(temp_widget:getChildByName("right_line_img"), "ImageView")
	local bottom_pos_y = bg_img_2:getPositionY() - panel_height_2 - bottom_interval_1/2 + 5
	num_txt:setPositionY(bottom_pos_y)
	left_img:setPositionY(bottom_pos_y)
	right_img:setPositionY(bottom_pos_y)
end

local function create()
	temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardOverviewUI.json")
	temp_widget:setTag(999)
	m_backPanel = UIBackPanel.new()
	local all_widget = m_backPanel:create(temp_widget, remove_self, panelPropInfo[uiIndexDefine.CARD_OVERVIEW_UI][2], false, true)
	card_overview_layer = TouchGroup:create()
	card_overview_layer:addWidget(all_widget)

	set_scroll_layout()

	sort_type = 1
	num_per_line = 6
	m_is_card_click = true
	local temp_sort_btn = tolua.cast(temp_widget:getChildByName("sort_btn"), "Button")
	temp_sort_btn:setTouchEnabled(true)
	temp_sort_btn:addTouchEventListener(show_sort_list_click)
	
	local card_list_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")
	local up_img = tolua.cast(temp_widget:getChildByName("up_img"), "ImageView")
	up_img:setVisible(false)

	m_card_tb_view = CCTableView:create(CCSizeMake(math.floor(card_list_panel:getSize().width + num_per_line * 2), math.floor(card_list_panel:getSize().height)))
	card_list_panel:addChild(m_card_tb_view)
	m_card_tb_view:setDirection(kCCScrollViewDirectionVertical)
	m_card_tb_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_card_tb_view:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    m_card_tb_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    m_card_tb_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_card_tb_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_card_tb_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

    touch_response_area = m_card_tb_view:boundingBox()

    uiManager.add_panel_to_layer(card_overview_layer, uiIndexDefine.CARD_OVERVIEW_UI,999)
    uiManager.showConfigEffect(uiIndexDefine.CARD_OVERVIEW_UI, card_overview_layer, nil, 999, {all_widget})

    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, cardOverviewManager.dealWithHeroChange)

	local up_img = tolua.cast(temp_widget:getChildByName("up_img"), "ImageView")
    local down_img = tolua.cast(temp_widget:getChildByName("down_img"), "ImageView")
    breathAnimUtil.start_scroll_dir_anim(up_img, down_img)
end

local function reload_data(is_keep_offset)
	m_hero_id_list = {}
	for k,v in pairs(heroData.getAllHero()) do
		table.insert(m_hero_id_list, k)
	end
	cardSortManager.sort_fun_for_uid(m_hero_id_list, sort_type, true)

	if is_keep_offset then
		local before_offset = m_card_tb_view:getContentOffset()
		m_card_tb_view:reloadData()

		if before_offset.y < m_card_tb_view:getViewSize().height - m_card_tb_view:getContentSize().height then
			before_offset.y = m_card_tb_view:getViewSize().height - m_card_tb_view:getContentSize().height
		end
		m_card_tb_view:setContentOffset(before_offset)
	else
		m_card_tb_view:reloadData()
	end

	local num_txt = tolua.cast(temp_widget:getChildByName("num_label"), "Label")
	num_txt:setText(#m_hero_id_list .. "/" .. sysUserConfigData.get_card_bag_nums())
end

local function dealWithHeroChange(packet)
	if m_card_tb_view and m_card_tb_view:isTouchEnabled() then
		reload_data(true)
	end
end

local function enter_card_overview()
	if card_overview_layer then
		return
	end

	create()
	reload_data(false)
end

--[[
local function get_guide_widget(temp_guide_id)
    if not card_overview_layer then
        return nil
    end

    return temp_widget
end
--]]

cardOverviewManager = {
						enter_card_overview = enter_card_overview,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						update_show_level = update_show_level,
						--get_guide_widget = get_guide_widget,
						--update_tb_state = update_tb_state,
						dealWithHeroChange = dealWithHeroChange,
						reload_data = reload_data
}