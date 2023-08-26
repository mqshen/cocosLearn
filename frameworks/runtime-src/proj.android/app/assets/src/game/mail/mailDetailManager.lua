module("mailDetailManager", package.seeall)

local m_content_panel = nil
local m_scroll_height = nil
local m_attach_order_list = nil

local m_is_rich_state = nil
local m_rich_element = nil

local ColorUtil = nil

function remove_self()
	ColorUtil = nil

	m_rich_element = nil
	m_is_rich_state = nil

	m_attach_order_list = nil
	m_scroll_height = nil
	m_content_panel = nil
end

local function deal_with_name_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_tab_num = mailListManager.get_selected_tab()
		if temp_tab_num ~= 1 then
			return
		end

		local temp_cell_idx = mailListManager.get_selected_cell_idx()
		local temp_simple_info = newMailData.get_mail_content_in_list(temp_tab_num, temp_cell_idx + 1)
		if not temp_simple_info then
			return
		end

		local function callback_detail()
	        UIRoleForcesMain.create(temp_simple_info.sender_id)
	    end

	    local function callback_sendMail()
	        SendMailUI.create("", "", temp_simple_info.sender_id, temp_simple_info.sender_name)
	    end

	    local function callback_defriend()
	        alertLayer.create(errorTable[2018], {temp_simple_info.sender_name}, function()
	            BlackNameListData.addUserByIdList({temp_simple_info.sender_id})
	        end)
	    end

		comOPMenu.create({
            {label = languagePack["gerenxinxi"],callback = callback_detail},
            {label = languagePack["fasongyoujian"],callback = callback_sendMail},
            {label = languagePack["jiaruheimingdan"] ,callback = callback_defriend},
        })
	end
end

local function deal_with_op_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local temp_tab_num = mailListManager.get_selected_tab()
		local temp_cell_idx = mailListManager.get_selected_cell_idx()

		local temp_simple_info = newMailData.get_mail_content_in_list(temp_tab_num, temp_cell_idx + 1)
		if not temp_simple_info then
			return
		end

		local temp_detail_info = newMailData.get_mail_detail_info(temp_simple_info.id)
		if not temp_detail_info then
			return
		end

		local function request_get_attach()
			newMailData.requestGetAttachment(temp_simple_info.id)
		end

		if temp_tab_num == 1 then
			SendMailUI.create(nil, nil, temp_simple_info.sender_id, temp_simple_info.sender_name)
		else
			if temp_detail_info.confirm_content == "" then
				request_get_attach()
			else
				alertLayer.create({20, languagePack['queren'], '#' .. temp_detail_info.confirm_content .. '#'}, {}, request_get_attach)
			end
		end
	end
end

local function set_content_layout(is_show_attach)
	local title_img = tolua.cast(m_content_panel:getChildByName("title_img"), "ImageView")
	local title_panel = tolua.cast(m_content_panel:getChildByName("content_panel"), "Layout")
	title_panel:setPositionY(title_img:getPositionY() - title_img:getSize().height/2 - title_panel:getSize().height - 10)

	local attach_panel = tolua.cast(m_content_panel:getChildByName("fujian_panel"), "Layout")
	local content_sv = tolua.cast(m_content_panel:getChildByName("content_sv"), "ScrollView")

	if is_show_attach then
		m_scroll_height = title_panel:getPositionY() - 10 - (attach_panel:getSize().height +10)
		--content_sv:setPositionY(attach_panel:getContentSize().height + 10)
	else
		if temp_tab_num == 1 then
			local op_btn = tolua.cast(m_content_panel:getChildByName("op_btn"), "Button")
			m_scroll_height = title_panel:getPositionY() - 10 - (op_btn:getPositionY() + op_btn:getContentSize().height)
			--content_sv:setPositionY(op_btn:getContentSize().height + 10)
		else
			--local op_btn = tolua.cast(m_content_panel:getChildByName("op_btn"), "Button")
			m_scroll_height = title_panel:getPositionY() - 10 - 10
			--content_sv:setPositionY(op_btn:getContentSize().height + 10)
		end
		
	end
	
	content_sv:setSize(CCSize(content_sv:getContentSize().width, m_scroll_height))
	local txt_height = nil
	if m_is_rich_state then
		local rich_text = tolua.cast(content_sv:getChildByName("rich_label"), "RichText")
		txt_height = rich_text:getRealHeight()
	else
		local content_txt = tolua.cast(content_sv:getChildByName("content_label"), "Label")
		txt_height = content_txt:getContentSize().height
	end
	
	if m_scroll_height < txt_height then
		content_sv:setTouchEnabled(true)
		content_sv:setSize(CCSize(content_sv:getContentSize().width, m_scroll_height))
		content_sv:setInnerContainerSize(CCSizeMake(content_sv:getContentSize().width, txt_height))
		content_sv:setPositionY(title_panel:getPositionY() - m_scroll_height - 10)
	else
		content_sv:setTouchEnabled(false)
		content_sv:setSize(CCSize(content_sv:getContentSize().width, txt_height))
		content_sv:setInnerContainerSize(CCSizeMake(content_sv:getContentSize().width, txt_height))
		content_sv:setPositionY(title_panel:getPositionY() - txt_height - 10)
	end
	content_sv:jumpToTop()

	--content_sv:setPositionY(attach_panel:getSize().height + 10)

	attach_panel:setVisible(is_show_attach)
end

local function set_scroll_content(temp_tab_num, name_sign, name_content, time_nums, detail_content)
	local title_panel = tolua.cast(m_content_panel:getChildByName("content_panel"), "Layout")
	local name_sign_txt = tolua.cast(title_panel:getChildByName("name_sign_label"), "Label")
	local name_btn = tolua.cast(title_panel:getChildByName("name_btn"), "Button")
	local time_txt = tolua.cast(title_panel:getChildByName("time_label"), "Label")

	name_sign_txt:setText(name_sign)
	name_btn:setTitleText(name_content)
	if temp_tab_num == 2 then
		name_btn:setTitleColor(ccc3(186, 63, 71))
	else
		name_btn:setTitleColor(ccc3(194,245,187))
	end

	local _time =  os.date("*t", time_nums)
	time_txt:setText(_time.year .. languagePack["nian"] .. _time.month .. languagePack["yue"] .. _time.day 
		.. languagePack["ri"] .. " " .. _time.hour .. ":" .. _time.min)

	local content_sv = tolua.cast(m_content_panel:getChildByName("content_sv"), "ScrollView")
	if m_is_rich_state then
		local rich_text = tolua.cast(content_sv:getChildByName("rich_label"), "RichText")
		for k,v in pairs(m_rich_element) do
			rich_text:removeElement(v)
		end
		m_rich_element = {}

		local des_list = config.richText_split(detail_content)
	    local rich_element = nil
	    for k,v in ipairs(des_list) do
	    	if v[1] == 1 then
		    	rich_element = RichElementText:create(1, ColorUtil.CCC_TEXT_MAIN_CONTENT, 255, v[2],config.getFontName(), 18)
			else
				rich_element = RichElementText:create(1, ColorUtil.CCC_TEXT_SUB_TITLE, 255, v[2],config.getFontName(), 18)
			end
			rich_text:pushBackElement(rich_element)
			table.insert(m_rich_element, rich_element)
		end

		rich_text:formatText()
		rich_text:setPositionY(rich_text:getRealHeight())
		--rich_text:setSize(CCSizeMake(700, rich_text:getRealHeight()))
	else
		local content_txt = tolua.cast(content_sv:getChildByName("content_label"), "Label")
		content_txt:setText(detail_content)
	end
end

local function get_type_index(type_id)
	for k,v in pairs(m_attach_order_list) do
		if v == type_id then
			return k
		end
	end

	return 0
end

local function order_ruler(attach_a, attach_b)
	local a_type_id = attach_a[1]%100
	local b_type_id = attach_b[1]%100

	return get_type_index(a_type_id) < get_type_index(b_type_id)
end

local function set_attachment(attach_detail)
	if not attach_detail then
		return
	end

	if attach_detail == "" then
		return
	end

	local attach_list = stringFunc.anlayerMsg(attach_detail)
	table.sort(attach_list, order_ruler)

	local fj_panel = tolua.cast(m_content_panel:getChildByName("fujian_panel"), "Layout")
	local temp_attach_panel = nil
	for i=1,7 do
		temp_attach_panel = tolua.cast(fj_panel:getChildByName("fj_" .. i), "Layout")
		temp_attach_panel:setVisible(false)
	end

	local icon_img, name_txt, num_txt = nil, nil, nil
	for k,v in pairs(attach_list) do
		temp_attach_panel = tolua.cast(fj_panel:getChildByName("fj_" .. k), "Layout")
		icon_img = tolua.cast(temp_attach_panel:getChildByName("sign_img"), "ImageView")
		icon_img:loadTexture(ResDefineUtil.ui_res_icon[v[1]%100], UI_TEX_TYPE_PLIST)
		name_txt = tolua.cast(temp_attach_panel:getChildByName("name_label"), "Label")
		name_txt:setText(clientConfigData.getDorpName(v[1]))
		if v[1]%100 == dropType.RES_ID_HERO then
			name_txt:setColor(ColorUtil.getHeroColor(Tb_cfg_hero[math.floor(v[1]/100)].quality))
		else
			name_txt:setColor(ccc3(255, 213, 110))
		end

		num_txt = tolua.cast(temp_attach_panel:getChildByName("num_label"), "Label")
		num_txt:setText(" " .. clientConfigData.getDorpCount(v[1], v[2]))
		num_txt:setPositionX(name_txt:getPositionX() + name_txt:getContentSize().width + 18)

		temp_attach_panel:setVisible(true)
	end
end

local function set_op_btn_state(temp_tab_num, is_show_attach, is_got_attach)
	local op_btn = tolua.cast(m_content_panel:getChildByName("op_btn"), "Button")
	local got_img = tolua.cast(m_content_panel:getChildByName("got_img"), "ImageView")
	got_img:setVisible(false)

	if temp_tab_num == 1 then
		op_btn:setTitleText(languagePack["reply"])
		op_btn:setBright(true)
		op_btn:setTouchEnabled(true)
		op_btn:setVisible(true)
	elseif temp_tab_num == 2 then
		if is_show_attach then
			if is_got_attach then
				op_btn:setBright(false)
				op_btn:setTitleText(languagePack["yilingqu"])
				op_btn:setTouchEnabled(false)
				op_btn:setVisible(false)
				got_img:setVisible(true)
			else
				op_btn:setBright(true)
				op_btn:setTitleText(languagePack["lingqufujian"])
				op_btn:setTouchEnabled(true)
				op_btn:setVisible(true)
			end
		else
			op_btn:setTouchEnabled(false)
			op_btn:setVisible(false)
		end
	elseif temp_tab_num == 3 then
		op_btn:setTouchEnabled(false)
		op_btn:setVisible(false)
	end
end

function set_mail_detail_info()
	local temp_tab_num = mailListManager.get_selected_tab()
	local temp_cell_idx = mailListManager.get_selected_cell_idx()

	local temp_simple_info = newMailData.get_mail_content_in_list(temp_tab_num, temp_cell_idx + 1)
	if not temp_simple_info then
		return
	end

	local temp_detail_info = newMailData.get_mail_detail_info(temp_simple_info.id)
	if not temp_detail_info then
		return
	end

	local is_show_attach, is_got_attach = false, false
	if temp_tab_num == 1 or temp_tab_num == 2 then
		if temp_simple_info.has_attach == 1 then
			is_show_attach = true

			if temp_simple_info.got_attach == 1 then
				is_got_attach = true
			end
		end
	end

	local title_img = tolua.cast(m_content_panel:getChildByName("title_img"), "ImageView")
	local title_txt = tolua.cast(title_img:getChildByName("title_label"), "Label")
	title_txt:setText(temp_simple_info.title)

	local name_sign, name_content = nil, nil
	if temp_tab_num == 3 then
		name_sign = languagePack["shoujianren"]
		name_content = temp_simple_info.receiver_name
	else
		name_sign = languagePack["fajianren"]
		name_content = temp_simple_info.sender_name
	end

	set_scroll_content(temp_tab_num, name_sign, name_content, temp_simple_info.send_time, temp_detail_info.text)
	set_content_layout(is_show_attach)

	if is_show_attach then
		set_attachment(temp_detail_info.attachment)
	end

	set_op_btn_state(temp_tab_num, is_show_attach, is_got_attach)
	set_panel_visible(true)
end

local function init_content_color()
	local title_img = tolua.cast(m_content_panel:getChildByName("title_img"), "ImageView")
	local title_txt = tolua.cast(title_img:getChildByName("title_label"), "Label")
	title_txt:setColor(ColorUtil.CCC_TEXT_MAIN_TITLE)

	local title_panel = tolua.cast(m_content_panel:getChildByName("content_panel"), "Layout")
	local name_sign_txt = tolua.cast(title_panel:getChildByName("name_sign_label"), "Label")
	local time_sign_txt = tolua.cast(title_panel:getChildByName("time_sign_label"), "Label")
	local time_txt = tolua.cast(title_panel:getChildByName("time_label"), "Label")
	name_sign_txt:setColor(ColorUtil.CCC_TEXT_SUB_TITLE)
	time_sign_txt:setColor(ColorUtil.CCC_TEXT_SUB_TITLE)
	time_txt:setColor(ColorUtil.CCC_TEXT_MAIN_CONTENT)

	local content_sv = tolua.cast(m_content_panel:getChildByName("content_sv"), "ScrollView")
	local content_txt = tolua.cast(content_sv:getChildByName("content_label"), "Label")
	content_txt:setColor(ColorUtil.CCC_TEXT_MAIN_CONTENT)
end

function set_panel_visible(new_state)
	m_content_panel:setVisible(new_state)
end

function create(right_panel)
	ColorUtil = require("game/utils/color_util")

	m_is_rich_state = true
	m_content_panel = right_panel
	m_attach_order_list = {dropType.RES_ID_HERO, dropType.RES_ID_YUAN_BAO, dropType.RES_ID_MONEY, dropType.RES_ID_WOOD,
							dropType.RES_ID_IRON, dropType.RES_ID_STONE, dropType.RES_ID_FOOD}

	init_content_color()

	local new_height = m_content_panel:getSize().height
	local title_img = tolua.cast(m_content_panel:getChildByName("title_img"), "ImageView")
	title_img:setPositionY(new_height - title_img:getSize().height/2)

	local content_sv = tolua.cast(m_content_panel:getChildByName("content_sv"), "ScrollView")
	local content_txt = tolua.cast(content_sv:getChildByName("content_label"), "Label")
	if m_is_rich_state then
		local rich_text = RichText:create()
		rich_text:setName("rich_label")
		rich_text:ignoreContentAdaptWithSize(false)
	    rich_text:setSize(CCSizeMake(700, 200))
	    rich_text:setAnchorPoint(cc.p(0, 1))
	    rich_text:setPosition(cc.p(0, 0))
	    local content_sv = tolua.cast(m_content_panel:getChildByName("content_sv"), "ScrollView")
	    content_sv:addChild(rich_text)
	    m_rich_element = {}

	    content_txt:setVisible(false)
	else
		content_txt:ignoreContentAdaptWithSize(true)
		content_txt:setTextAreaSize(CCSize(content_txt:getContentSize().width, 0))
	end

	local title_panel = tolua.cast(m_content_panel:getChildByName("content_panel"), "Layout")
	local name_btn = tolua.cast(title_panel:getChildByName("name_btn"), "Button")
	name_btn:addTouchEventListener(deal_with_name_click)
	name_btn:setTouchEnabled(true)

	--暂时屏蔽下一封的功能，优先还原原来的功能
	local next_btn = tolua.cast(m_content_panel:getChildByName("next_btn"), "Button")
	next_btn:setVisible(false)

	local op_btn = tolua.cast(m_content_panel:getChildByName("op_btn"), "Button")
	op_btn:addTouchEventListener(deal_with_op_click)

	set_panel_visible(false)
end

function obtain_attach_success(mail_id)
	local temp_detail_info = newMailData.get_mail_detail_info(mail_id)
	local attach_list = stringFunc.anlayerMsg(temp_detail_info.attachment)
	table.sort(attach_list, order_ruler)

	local show_list = {}
	for k,v in pairs(attach_list) do
		local show_name = clientConfigData.getDorpName(v[1])
		local show_num = clientConfigData.getDorpCount(v[1], v[2])
		local show_content = languagePack["huode"] .. show_name .. " " .. show_num

		table.insert(show_list, show_content)
	end

	if #show_list > 0 then
		taskTipsLayer.create(show_list)
	end
end