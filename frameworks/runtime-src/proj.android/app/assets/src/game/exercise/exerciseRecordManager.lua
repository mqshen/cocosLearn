local m_layer = nil
local m_army_list = nil
local m_up_img = nil
local m_down_img = nil
local m_show_tb_view = nil

local function do_remove_self()
	if m_layer then
		m_layer:removeFromParentAndCleanup(true)
		m_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.EXERCISE_RECORD_UI)
	end
end

local function remove_self()
	if m_layer then
		uiManager.hideConfigEffect(uiIndexDefine.EXERCISE_RECORD_UI, m_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not m_layer then
		return false
	end

	local temp_widget = m_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_close_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function set_cell_content(cell, idx)
	local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local cell_widget = cell_layer:getWidgetByTag(1)

    local temp_army_info = exerciseData.get_exercise_record_army_info(m_army_list[idx + 1])
    local hero_panel, hero_img, hero_widget = nil, nil, nil
   	local hero_cfg_id = nil
	for i=1,3 do
		hero_panel = tolua.cast(cell_widget:getChildByName("hero_" .. i), "Layout")
		hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
		hero_widget = tolua.cast(hero_img:getChildByName("hero_widget"), "Layout")
		if i == 1 then
			hero_cfg_id = temp_army_info.base_hero_id
		elseif i == 2 then
			hero_cfg_id = temp_army_info.middle_hero_id
		else
			hero_cfg_id = temp_army_info.front_hero_id
		end

		if hero_cfg_id == 0 then
			cardFrameInterface.reset_small_card_info(hero_widget)
		else
			cardFrameInterface.set_small_card_info(hero_widget, 0, hero_cfg_id, false)
			cardFrameInterface.set_lv_images(temp_army_info.base_hero_level, hero_widget)
		end
	end
end

local function tableCellTouched(table,cell)
	require("game/exercise/exerciseRecordEnemyManager")
	local temp_army_info = exerciseData.get_exercise_record_army_info(m_army_list[cell:getIdx() + 1])
	exerciseRecordEnemyManager.set_army_id(temp_army_info.army_id)
end

local function cellSizeForTable(table,idx)
    return 94, 664
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_12.json")
		local hero_base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
		local hero_panel, hero_img, hero_widget = nil, nil, nil
		for i=1,3 do
			hero_panel = tolua.cast(new_widget:getChildByName("hero_" .. i), "Layout")
			hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
			hero_widget = hero_base_widget:clone()
			hero_widget:ignoreAnchorPointForPosition(false)
			hero_widget:setAnchorPoint(cc.p(0.5,0.5))
			hero_widget:setName("hero_widget")
			hero_img:addChild(hero_widget)
		end

	    new_widget:setTag(1)
	    local new_layer = TouchGroup:create()
	    new_layer:setTag(123)
	    new_layer:addWidget(new_widget)
	    cell = CCTableViewCell:new()
	    cell:addChild(new_layer)
	end

	set_cell_content(cell, idx)

    return cell
end

local function numberOfCellsInTableView(table)
	return #m_army_list
end

local function scrollViewDidScroll(table)
	if table:getContentOffset().y < 0 then
		m_down_img:setVisible(true)
	else
		m_down_img:setVisible(false)
	end

	if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
		m_up_img:setVisible(true)
	else
		m_up_img:setVisible(false)
	end
end

local function init_right_info(right_img)
	m_army_list = exerciseData.get_exercise_record_army_list()
	if #m_army_list == 0 then
		local none_sign_txt = tolua.cast(right_img:getChildByName("none_sign_label"), "Label")
		none_sign_txt:setVisible(true)
	else
		local content_panel = tolua.cast(right_img:getChildByName("content_panel"), "Layout")
		m_up_img = tolua.cast(content_panel:getChildByName("up_img"), "ImageView")
		m_down_img = tolua.cast(content_panel:getChildByName("down_img"), "ImageView")
	    breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)

		m_show_tb_view = CCTableView:create(CCSizeMake(content_panel:getSize().width, content_panel:getSize().height))
		content_panel:addChild(m_show_tb_view)
		m_show_tb_view:setDirection(kCCScrollViewDirectionVertical)
		m_show_tb_view:setVerticalFillOrder(kCCTableViewFillTopDown)
		m_show_tb_view:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	    m_show_tb_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	    m_show_tb_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	    m_show_tb_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	    m_show_tb_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	    m_show_tb_view:reloadData()

		content_panel:setVisible(true)
	end
end

local function init_left_info(left_img)
	local temp_all_nums, temp_win_nums, temp_diff_list = exerciseData.get_exercise_record_sum_info()
	local all_img = tolua.cast(left_img:getChildByName("img_1"), "ImageView")
	local num_txt = tolua.cast(all_img:getChildByName("num_label"), "Label")
	num_txt:setText(temp_all_nums)

	local win_panel = tolua.cast(left_img:getChildByName("win_panel"), "Layout")
	num_txt = tolua.cast(win_panel:getChildByName("num_label"), "Label")
	num_txt:setText(temp_win_nums)

	local temp_diff_panel = nil
	for k,v in pairs(temp_diff_list) do
		temp_diff_panel = tolua.cast(left_img:getChildByName("diff_" .. v[1]), "Layout")
		num_txt = tolua.cast(temp_diff_panel:getChildByName("num_label"), "Label")
		num_txt:setText(v[2])
	end
end

local function create()
	if m_layer then
		return
	end

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/shapanyanwu_9.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)

	local left_img = tolua.cast(temp_widget:getChildByName("left_img"), "ImageView")
	init_left_info(left_img)

	local right_img = tolua.cast(temp_widget:getChildByName("right_img"), "ImageView")
	init_right_info(right_img)

	m_layer = TouchGroup:create()
	m_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_layer, uiIndexDefine.EXERCISE_RECORD_UI)
	uiManager.showConfigEffect(uiIndexDefine.EXERCISE_RECORD_UI, m_layer)
end

exerciseRecordManager = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent
}