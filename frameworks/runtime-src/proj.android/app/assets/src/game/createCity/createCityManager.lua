local m_main_layer = nil

local create_type = nil --1 分城；2 要塞
local touch_map_x, touch_map_y = nil, nil
local ColorUtil = require("game/utils/color_util")

local function do_remove_self()
	if m_main_layer then
		touch_map_x = nil
		touch_map_y = nil
		create_type = nil

		m_main_layer:removeFromParentAndCleanup(true)
		m_main_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.CREATE_CITY_UI)
	end
end

local function remove_self()
	if m_main_layer then
		uiManager.hideConfigEffect(uiIndexDefine.CREATE_CITY_UI, m_main_layer, do_remove_self)
	end
end

local function dealwithTouchEvent(x,y)
	if not m_main_layer then
		return false
	end

	local temp_widget = m_main_layer:getWidgetByTag(999)
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

local function deal_with_build_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		require("game/createCity/inputCityNameInfo")
		inputCityNameInfo.create(create_type, touch_map_x, touch_map_y)
	end
end

local function init_res_content(temp_widget)
	local condition_img = tolua.cast(temp_widget:getChildByName("condition_img"), "ImageView")
	local is_res_enough = true
	local need_nums, own_nums = nil, nil
	local name_txt, need_txt, own_txt = nil, nil, nil
	for i=1,4 do
		name_txt = tolua.cast(condition_img:getChildByName("name_" .. i), "Label")
		need_txt = tolua.cast(condition_img:getChildByName("need_num_" .. i), "Label")
        own_txt = tolua.cast(condition_img:getChildByName("own_num_" .. i), "Label")
        own_nums = politics.getResNumsByType(i)
        if create_type == 1 then
			need_nums = BRANCH_CITY_BUILD_RES_COST[i * 2]
		else
			need_nums = FORT_BUILD_RES_COST[i * 2]
		end
		
		name_txt:setText(resNameDefine[i])
		need_txt:setText(need_nums)
		own_txt:setText("/" .. own_nums)
		
        if own_nums < need_nums then 
            own_txt:setColor(ColorUtil.CCC_TEXT_RED)
            is_res_enough = false
        else
            own_txt:setColor(ColorUtil.CCC_TEXT_YELLOW)
        end
        own_txt:setPositionX(need_txt:getPositionX() + need_txt:getContentSize().width)
	end

	local build_panel = tolua.cast(temp_widget:getChildByName("build_panel"), "Layout")
	local build_btn = tolua.cast(build_panel:getChildByName("build_btn"), "Button")
	local time_txt = tolua.cast(build_panel:getChildByName("time_label"), "Label")
	if is_res_enough then
		local notice_txt = tolua.cast(build_panel:getChildByName("notice_label"), "Label")
		notice_txt:setVisible(false)
		
		if create_type == 1 then
			time_txt:setText(commonFunc.format_time(BRANCH_CITY_BUILD_TIME))
		else
			time_txt:setText(commonFunc.format_time(FORT_BUILD_TIME))
		end

		build_btn:setTouchEnabled(true)
		build_btn:addTouchEventListener(deal_with_build_click)
	else
		local sign_txt = tolua.cast(build_panel:getChildByName("need_label"), "Label")
		sign_txt:setVisible(false)
		time_txt:setVisible(false)

		build_btn:setBright(false)
		local sign_img = tolua.cast(build_btn:getChildByName("sign_img"), "ImageView")
		GraySprite.create(sign_img)
	end
end

local function set_icon_content(build_img)
	local content_img = tolua.cast(build_img:getChildByName("content_img"), "ImageView")
	content_img:loadTexture(ResDefineUtil.create_city_res[create_type], UI_TEX_TYPE_PLIST)

	local name_txt = tolua.cast(build_img:getChildByName("name_label"), "Label")
	if create_type == 1 then
		name_txt:setText(languagePack["cityTypeName_fencheng"])
	else
		name_txt:setText(languagePack["cityTypeName_yaosai"])
	end
end

local function set_attention_show_content(des_img)
	local attention_txt = nil
	for i=1,2 do
		attention_txt = tolua.cast(des_img:getChildByName("zy_label_" .. i), "Label")
		attention_txt:setVisible(false)
	end

	if create_type == 1 then
		for i,v in ipairs(client_cfg_city_attention) do
			attention_txt = tolua.cast(des_img:getChildByName("zy_label_" .. i), "Label")
			attention_txt:setText(v)
			attention_txt:setVisible(true)
		end
	else
		for ii,vv in ipairs(client_cfg_fort_attention) do
			attention_txt = tolua.cast(des_img:getChildByName("zy_label_" .. ii), "Label")
			attention_txt:setText(vv)
			attention_txt:setVisible(true)
		end
	end
end

local function init_title_content(temp_widget)
	local title_img = tolua.cast(temp_widget:getChildByName("title_img"), "ImageView")
	local title_txt = tolua.cast(title_img:getChildByName("title_label"), "Label")
	if create_type == 1 then
		title_txt:setText(languagePack["create_city_title"])
	else
		title_txt:setText(languagePack["create_fort_title"])
	end

	local close_btn = tolua.cast(title_img:getChildByName("close_btn"), "Button")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)
end

local function init_des_content(temp_widget)
	local detail_img = tolua.cast(temp_widget:getChildByName("detail_img"), "ImageView")
	local des_img = tolua.cast(detail_img:getChildByName("des_img"), "ImageView")

	local des_title_img = tolua.cast(des_img:getChildByName("des_title_img"), "ImageView")
	local des_title_txt = tolua.cast(des_title_img:getChildByName("des_title_label"), "Label")
	if create_type == 1 then
		des_title_txt:setText(languagePack["city_des_title"])
	else
		des_title_txt:setText(languagePack["fort_des_title"])
	end

	local des_txt = tolua.cast(des_img:getChildByName("des_label"), "Label")
	des_txt:setText(client_cfg_city_des[create_type])
	set_attention_show_content(des_img)

	local build_img = tolua.cast(detail_img:getChildByName("build_img"), "ImageView")
	set_icon_content(build_img)
end

local function create(new_type, pos_x, pos_y)
	if m_main_layer then
		return
	end

	require("game/dbData/client_cfg/create_city_cfg_info")

	create_type = new_type
	touch_map_x = pos_x
	touch_map_y = pos_y

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/createCityUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	init_title_content(temp_widget)
	init_des_content(temp_widget)
	init_res_content(temp_widget)

	m_main_layer = TouchGroup:create()
	m_main_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(m_main_layer, uiIndexDefine.CREATE_CITY_UI)
	uiManager.showConfigEffect(uiIndexDefine.CREATE_CITY_UI, m_main_layer)
end

createCityManager = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent
}