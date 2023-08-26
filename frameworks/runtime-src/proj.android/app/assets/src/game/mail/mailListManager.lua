module("mailListManager", package.seeall)
local timeUtil = require("game/utils/time_util")
local ColorUtil = require("game/utils/color_util")

local m_up_img = nil
local m_down_img = nil
local m_show_tb_view = nil

local m_select_tab_num = nil
local m_selected_cell_index = nil

function remove_self()
	timeUtil = nil
	ColorUtil = nil
	
	m_selected_cell_index = nil
	m_select_tab_num = nil

	m_show_tb_view = nil
	m_down_img = nil
	m_up_img = nil
end

local function set_select_show(cell_widget, selected_state)
	local common_img = tolua.cast(cell_widget:getChildByName("common_img"), "ImageView")
	local select_img = tolua.cast(cell_widget:getChildByName("select_img"), "ImageView")
	if selected_state then
		select_img:setVisible(true)
		common_img:setVisible(false)
	else
		common_img:setVisible(true)
		select_img:setVisible(false)
	end
end

local function set_read_and_attach_content(cell_widget, read_or_not, is_own_attach, is_got_attach)
	local attach_img = tolua.cast(cell_widget:getChildByName("attach_img"), "ImageView")
	attach_img:setVisible(is_own_attach)

	local opened_img = tolua.cast(cell_widget:getChildByName("read_img"), "ImageView")
	local gray_or_not = false

	if m_select_tab_num == 3 then
		opened_img:loadTexture(ResDefineUtil.ui_mail[5], UI_TEX_TYPE_PLIST)
	else
		if read_or_not then
			opened_img:loadTexture(ResDefineUtil.ui_mail[4], UI_TEX_TYPE_PLIST)
			if is_own_attach then
				if is_got_attach then
					gray_or_not = true
				end
			else
				gray_or_not = true
			end
		else
			opened_img:loadTexture(ResDefineUtil.ui_mail[3], UI_TEX_TYPE_PLIST)
		end
	end

	if gray_or_not then
		--local select_img = tolua.cast(cell_widget:getChildByName("select_img"), "ImageView")
		--GraySprite.create(cell_widget, {"select_img"})
		GraySprite.create(opened_img)
		GraySprite.create(attach_img)
	end

	return gray_or_not
end

local function set_title_and_time_content(cell_widget, gray_or_not, system_or_not, title_content, name_content, time_nums)
	local title_txt = tolua.cast(cell_widget:getChildByName("title_label"), "Label")
	local date_txt = tolua.cast(cell_widget:getChildByName("date_label"), "Label")
	local name_txt = tolua.cast(cell_widget:getChildByName("name_label"), "Label")

	if stringFunc.get_str_length(title_content) > 10 then
		local temp_content = stringFunc.get_str_by_length_2(title_content, 10)
		title_txt:setText(temp_content .. "...")
	else
		title_txt:setText(title_content)
	end
	
	date_txt:setText(timeUtil.formatChatTime(time_nums, userData.getServerTime()))
	name_txt:setText(name_content)

	if system_or_not then
		name_txt:setColor(ccc3(186, 63, 71))
	else
		name_txt:setColor(ccc3(219, 179, 103))
	end

	---[[
	if gray_or_not then
		title_txt:setOpacity(150)
		date_txt:setOpacity(150)
		name_txt:setOpacity(150)
	else
		title_txt:setOpacity(255)
		date_txt:setOpacity(255)
		name_txt:setOpacity(255)
	end
	--]]
end

local function show_common_inbox_cell(cell_widget, idx)
	local temp_mail_info = newMailData.get_mail_content_in_list(1, idx + 1)

	set_select_show(cell_widget, idx == m_selected_cell_index)

	local gray_or_not = nil
	if temp_mail_info.readed == 0 then
		gray_or_not = set_read_and_attach_content(cell_widget, false, false, false)
	else
		gray_or_not = set_read_and_attach_content(cell_widget, true, false, false)
	end

	set_title_and_time_content(cell_widget, gray_or_not, false, temp_mail_info.title, temp_mail_info.sender_name, temp_mail_info.send_time)

	local sign_txt = tolua.cast(cell_widget:getChildByName("sign_label"), "Label")
	sign_txt:setText(languagePack["fajianren"] .. languagePack["maohao"])
	---[[
	if gray_or_not then
		sign_txt:setOpacity(150)
	else
		sign_txt:setOpacity(255)
	end
	--]]
end

local function show_system_inbox_cell(cell_widget, idx)
	local temp_mail_info = newMailData.get_mail_content_in_list(2, idx + 1)

	set_select_show(cell_widget, idx == m_selected_cell_index)

	local read_or_not, is_own_attach, is_got_attach = nil, nil, nil
	if temp_mail_info.readed == 0 then
		read_or_not = false
	else
		read_or_not = true
	end

	if temp_mail_info.has_attach == 0 then
		is_own_attach = false
	else
		is_own_attach = true
	end

	if temp_mail_info.got_attach == 0 then
		is_got_attach = false
	else
		is_got_attach = true
	end
	
	local gray_or_not = set_read_and_attach_content(cell_widget, read_or_not, is_own_attach, is_got_attach)
	set_title_and_time_content(cell_widget, gray_or_not, true, temp_mail_info.title, temp_mail_info.sender_name, temp_mail_info.send_time)

	local sign_txt = tolua.cast(cell_widget:getChildByName("sign_label"), "Label")
	sign_txt:setText(languagePack["fajianren"] .. languagePack["maohao"])
	---[[
	if gray_or_not then
		sign_txt:setOpacity(150)
	else
		sign_txt:setOpacity(255)
	end
	--]]
end

local function show_outbox_cell(cell_widget, idx)
	local temp_mail_info = newMailData.get_mail_content_in_list(3, idx + 1)

	set_select_show(cell_widget, idx == m_selected_cell_index)

	local gray_or_not = set_read_and_attach_content(cell_widget, false, false, false)
	set_title_and_time_content(cell_widget, gray_or_not, false, temp_mail_info.title, temp_mail_info.receiver_name, temp_mail_info.send_time)

	local sign_txt = tolua.cast(cell_widget:getChildByName("sign_label"), "Label")
	sign_txt:setText(languagePack["shoujianren"] .. languagePack["maohao"])
	---[[
	if gray_or_not then
		sign_txt:setOpacity(150)
	else
		sign_txt:setOpacity(255)
	end
	--]]
end

local function set_cell_content(cell, idx)
	local cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local cell_widget = cell_layer:getWidgetByTag(1)
    if m_select_tab_num == 1 then
    	show_common_inbox_cell(cell_widget, idx)
	elseif m_select_tab_num == 2 then
		show_system_inbox_cell(cell_widget, idx)
	elseif m_select_tab_num == 3 then
		show_outbox_cell(cell_widget, idx)
	end
end

local function deal_with_cell_touched(cell_idx)
	if m_selected_cell_index == cell_idx then
		return
	end

	if m_selected_cell_index ~= -1 then
		local last_cell = m_show_tb_view:cellAtIndex(m_selected_cell_index)
		if last_cell then
			local last_cell_layer = tolua.cast(last_cell:getChildByTag(123),"TouchGroup")
    		local last_cell_widget = last_cell_layer:getWidgetByTag(1)
			set_select_show(last_cell_widget, false)
		end
	end

	m_selected_cell_index = cell_idx
	local cell = m_show_tb_view:cellAtIndex(m_selected_cell_index)

	local is_update_selected_state = false
	local own_state, is_update_show_state = newMailData.is_owned_mail_detail(m_select_tab_num, cell_idx + 1)
	if own_state then
		is_update_selected_state = true
		mailDetailManager.set_mail_detail_info()
	else
		mailDetailManager.set_panel_visible(false)
		if is_update_show_state then
			set_cell_content(cell, cell_idx)
			mailManager.update_new_state_show()
		else
			is_update_selected_state = true
		end
	end

	if is_update_selected_state then
		local new_cell_layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    	local new_cell_widget = new_cell_layer:getWidgetByTag(1)
		set_select_show(new_cell_widget, true)
	end

end

local function tableCellTouched(table,cell)
	deal_with_cell_touched(cell:getIdx())
end

local function cellSizeForTable(table,idx)
    return 84, 350
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
		local new_widget = GUIReader:shareReader():widgetFromJsonFile("test/mailCellUI.json")
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
	return newMailData.get_cell_nums(m_select_tab_num)
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

function update_selected_cell()
	if m_selected_cell_index ~= -1 then
		local cell = m_show_tb_view:cellAtIndex(m_selected_cell_index)
		set_cell_content(cell, m_selected_cell_index)
		mailDetailManager.set_mail_detail_info()
	end
end

local function update_tips_state()
	local mail_nums = newMailData.get_cell_nums(m_select_tab_num)
	if mail_nums == 0 then
		mailManager.update_no_mail_state(true)
	else
		mailManager.update_no_mail_state(false)
	end

	return mail_nums
end

function set_selected_tab(new_num)
	m_select_tab_num = new_num
	m_selected_cell_index = -1
	m_show_tb_view:reloadData()

	local mail_nums = update_tips_state()

	if mail_nums ~= 0 then
		local temp_cell_index = 0

		local com_new_index, sys_new_index = newMailData.get_mail_list_new_state()
		if m_select_tab_num == 1 then
			if com_new_index ~= 0 then
				temp_cell_index = com_new_index - 1
			end
		elseif m_select_tab_num == 2 then
			if sys_new_index ~= 0 then
				temp_cell_index = sys_new_index - 1
			end
		end

		if temp_cell_index ~= 0 then
			local init_offset_y = m_show_tb_view:getViewSize().height - m_show_tb_view:getContentSize().height
			if init_offset_y < 0 then
				local new_offset_y = init_offset_y + temp_cell_index * 84
				if new_offset_y < init_offset_y then
					new_offset_y = init_offset_y
				else
					if new_offset_y > 0 then
						new_offset_y = 0
					end
				end
				
				m_show_tb_view:setContentOffsetInDuration(cc.p(0, new_offset_y), 0.5)
			end
		end

		deal_with_cell_touched(temp_cell_index)
	end
end

function get_selected_tab()
	return m_select_tab_num
end

function get_selected_cell_idx()
	return m_selected_cell_index
end

function deal_with_add_mail(update_tab_num)
	if m_select_tab_num == update_tab_num then
		if m_selected_cell_index ~= -1 then
			m_selected_cell_index = m_selected_cell_index + 1
		end

		local before_offset = m_show_tb_view:getContentOffset()
		m_show_tb_view:reloadData()

		if before_offset.y < m_show_tb_view:getViewSize().height - m_show_tb_view:getContentSize().height then
			before_offset.y = m_show_tb_view:getViewSize().height - m_show_tb_view:getContentSize().height
		end
		m_show_tb_view:setContentOffset(before_offset)

		update_tips_state()
	end
end

function create(left_panel)
	timeUtil = require("game/utils/time_util")
	ColorUtil = require("game/utils/color_util")

	m_select_tab_num = 0
	m_selected_cell_index = -1

	local bg_img = tolua.cast(left_panel:getChildByName("bg_img"), "ImageView")
	m_up_img = tolua.cast(left_panel:getChildByName("up_img"), "ImageView")
	m_down_img = tolua.cast(left_panel:getChildByName("down_img"), "ImageView")

	local new_height = left_panel:getSize().height
	bg_img:setSize(CCSize(bg_img:getSize().width, new_height))
	bg_img:setPositionY(new_height/2)

	m_up_img:setPositionY(new_height - m_up_img:getSize().height/2)
	m_down_img:setPositionY(m_down_img:getSize().height/2)
	
	m_show_tb_view = CCTableView:create(CCSizeMake(left_panel:getSize().width, left_panel:getSize().height))
	left_panel:addChild(m_show_tb_view)
	m_show_tb_view:setDirection(kCCScrollViewDirectionVertical)
	m_show_tb_view:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_show_tb_view:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	--show_tb_view:registerScriptHandler(tableCellHighlight, CCTableView.kTableCellHighLight)
	--show_tb_view:registerScriptHandler(tableCellUnhighlight, CCTableView.kTableCellUnhighLight)
    m_show_tb_view:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    m_show_tb_view:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_show_tb_view:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_show_tb_view:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)

    breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)
end