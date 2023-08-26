local union_log_layer = nil
local is_open_state = nil
local log_content_list = nil

local current_height = nil

local panel_height = nil
local text_space = nil
local title_space_down = nil
local title_space_up = nil
local title_height_div_2 = nil
local default_txt_height = nil

local m_up_img = nil
local m_down_img = nil

local function do_remove_self()
	if union_log_layer then
		is_open_state = nil
		log_content_list = nil

		current_height = nil
		panel_height = nil
		text_space = nil
		title_space_down = nil
		title_space_up = nil
		title_height_div_2 = nil
		default_txt_height = nil

		m_up_img = nil
		m_down_img = nil
		union_log_layer:removeFromParentAndCleanup(true)
		union_log_layer = nil
		
		uiManager.remove_self_panel(uiIndexDefine.UNION_LOG_UI)
	end
end

local function remove_self()
	if union_log_layer then
		uiManager.hideConfigEffect(uiIndexDefine.UNION_LOG_UI, union_log_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not union_log_layer then
		return false
	end

	local temp_widget = union_log_layer:getWidgetByTag(999)
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

local function init_param_info()
	panel_height = 480
	text_space = 10
	title_space_down = 16
	title_space_up = 24
	title_height_div_2 = 17
	default_txt_height = 100
end

local function deal_with_scroll_event(sender, eventType)
    if eventType == SCROLLVIEW_EVENT_SCROLLING then
    	m_up_img:setVisible(true)
	    m_down_img:setVisible(true)
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_TOP then
		m_up_img:setVisible(false)
    elseif eventType == SCROLLVIEW_EVENT_BOUNCE_BOTTOM then
    	m_down_img:setVisible(false)
    end
end

local function is_today_date(temp_year, temp_month, temp_day)
	local today_info = os.date("*t", os.time())
	if temp_year == today_info.year and temp_month == today_info.month and temp_day == today_info.day then
		return true
	else
		return false
	end
end

local function organize_item_content(content_table, time_content)
	local before_change_content = "#" .. time_content .. "  #" .. unionLogTable[content_table.show_type][1]
	local param_list = content_table.need_param
	local index = 1
    local temp = nil
    local after_change_content = string.gsub(before_change_content, "&", function (n)
        temp = param_list[index]
        index = index + 1
        return temp or "&"
    end)

	local rich_text = RichText:create()
	rich_text:ignoreContentAdaptWithSize(false)
    rich_text:setSize(CCSizeMake(580, default_txt_height))
    rich_text:setAnchorPoint(cc.p(0, 0))

    local parse_list = config.richText_split(after_change_content)
    local rich_element = nil
    for k,v in pairs(parse_list) do
        if v[1] == 1 then
        	rich_element = RichElementText:create(1, ccc3(255,255,255), 255, v[2], config.getFontName(), 22)
        else
            rich_element = RichElementText:create(1, ccc3(255,217,90), 255, v[2], config.getFontName(), 22)
        end
        rich_text:pushBackElement(rich_element)
    end

	rich_text:formatText()
	local real_height = rich_text:getRealHeight()
	--rich_text:setSize(CCSizeMake(580, real_height))
	rich_text:setPosition(cc.p(20,current_height- (default_txt_height - real_height)))
	current_height = current_height + real_height

	return rich_text
end

local function organize_show_content(temp_widget)
	local temp_sv = tolua.cast(temp_widget:getChildByName("content_sv"), "ScrollView")
	temp_sv:addEventListenerScrollView(deal_with_scroll_event)

	local base_time_img = tolua.cast(temp_widget:getChildByName("time_img"), "ImageView")
	base_time_img:setVisible(false)
	if #log_content_list == 0 then
		return
	end

	local pos_x = base_time_img:getContentSize().width/2 - 20

	local temp_year, temp_month, temp_day = 0, 0, 0
	local show_time_img, time_txt, rich_text = nil
	current_height = 0
	for k,v in pairs(log_content_list) do
		local date_table = os.date("*t", v.show_time)
		if temp_year == date_table.year and temp_month == date_table.month and temp_day == date_table.day then
			current_height = current_height + text_space
		else
			temp_year = date_table.year
			temp_month = date_table.month
			temp_day = date_table.day

			if show_time_img then
				current_height = current_height + title_space_down + title_height_div_2
				show_time_img:setPosition(cc.p(pos_x, current_height))
				show_time_img:setVisible(true)
				temp_sv:addChild(show_time_img)
				current_height = current_height + title_height_div_2 + title_space_up
			end

			show_time_img = base_time_img:clone()
			show_time_img:ignoreAnchorPointForPosition(false)
			show_time_img:setAnchorPoint(cc.p(0.5,0.5))
			time_txt = tolua.cast(show_time_img:getChildByName("time_label"), "Label")
			if is_today_date(temp_year, temp_month, temp_day) then
				time_txt:setText(languagePack["today"])
			else
				time_txt:setText(date_table.month .. languagePack["yue"] .. date_table.day .. languagePack["ri"])
			end
		end

		local time_content = nil
		if date_table.min < 10 then
			time_content = date_table.hour .. ":0" .. date_table.min
		else
			time_content = date_table.hour .. ":" .. date_table.min
		end
		rich_text = organize_item_content(v, time_content)
		temp_sv:addChild(rich_text)
	end

	current_height = current_height + title_space_down + title_height_div_2
	show_time_img:setPosition(cc.p(pos_x, current_height))
	show_time_img:setVisible(true)
	temp_sv:addChild(show_time_img)
	current_height = current_height + title_height_div_2

	if current_height > panel_height then
		temp_sv:setTouchEnabled(true)
		temp_sv:setInnerContainerSize(CCSizeMake(temp_sv:getContentSize().width, current_height))
		temp_sv:jumpToTop()
		m_down_img:setVisible(true)
	else
		temp_sv:setPositionY(temp_sv:getPositionY() + panel_height - current_height)
	end
end

local function create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/unionLogUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	m_up_img = tolua.cast(temp_widget:getChildByName("up_img"), "ImageView")
    m_down_img = tolua.cast(temp_widget:getChildByName("down_img"), "ImageView")
    breathAnimUtil.start_scroll_dir_anim(m_up_img, m_down_img)

	init_param_info()
	organize_show_content(temp_widget)

	local close_btn = tolua.cast(temp_widget:getChildByName("close_btn"), "Button")
	close_btn:addTouchEventListener(deal_with_close_click)
	close_btn:setTouchEnabled(true)

	union_log_layer = TouchGroup:create()
	union_log_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(union_log_layer, uiIndexDefine.UNION_LOG_UI)
	uiManager.showConfigEffect(uiIndexDefine.UNION_LOG_UI, union_log_layer)
end

local function sort_ruler(a_item, b_item)
	return a_item.show_id < b_item.show_id
end

local function organize_log_list(packet)
	log_content_list = {}
	for k,v in pairs(packet) do
		log_content_list[k] = {}
		log_content_list[k]["show_id"] = v.log_id
		log_content_list[k]["show_type"] = v.log_type
		log_content_list[k]["need_param"] = cjson.decode(v.param)
		log_content_list[k]["show_time"] = v.log_time
	end

	table.sort(log_content_list, sort_ruler)

	create()
end

local function on_enter()
	if is_open_state then
		return
	end

	require("game/dbData/client_cfg/union_log_cfg_info")
	UnionData.requestUnionLog()
	is_open_state = true
end

unionLogManager = {
						on_enter = on_enter,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						organize_log_list = organize_log_list
}