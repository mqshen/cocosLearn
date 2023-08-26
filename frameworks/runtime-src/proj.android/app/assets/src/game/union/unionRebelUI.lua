--同盟的反叛界面
module("UnionRebelUI", package.seeall)
local m_pMainLayer = nil
local m_bDonate = nil
--local m_iDonateCount = nil

local m_donate_need_nums = nil 		--捐赠到最大等级还差多少
local m_rebel_need_nums = nil 		--反叛所需的剩余资源
local m_slider_max_list = nil 		--各种资源可以拖动的最大值
local m_slider_current_list = nil   --各种资源当前拖动的数值
function do_remove_self( )
	if m_pMainLayer then
		m_bDonate = nil
		--m_iDonateCount = nil
		m_donate_need_nums = nil
		m_rebel_need_nums = nil
		m_slider_current_list = nil
		m_slider_max_list = nil

		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		netObserver.removeObserver(UNION_GET_NAMES)
		UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, UnionRebelUI.init_all_content_show)
		uiManager.remove_self_panel(uiIndexDefine.UI_REBEL_MAIN)
	end
end

function remove_self( )
	if m_pMainLayer then
		uiManager.hideConfigEffect(uiIndexDefine.UI_REBEL_MAIN,m_pMainLayer,do_remove_self)
	end
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_close_clik(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function get_res_all_num(remove_id)
	local sum_num = 0
	for i,v in ipairs(m_slider_current_list) do
		if i ~= remove_id then
			sum_num = sum_num + v
		end
	end

	return sum_num
end

local function deal_with_confirm_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if (not m_bDonate) and m_rebel_need_nums == 0 then
			UnionData.requestRebel()
			return
		end

		local res_sum_num = get_res_all_num(0)
		if res_sum_num ~= 0 then
			UnionData.requestDonateOrRebel(m_slider_current_list[1],m_slider_current_list[2],
											m_slider_current_list[3],m_slider_current_list[4])
		end
	end
end

local function set_res_show_content(is_show_res)
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local res_img = tolua.cast(temp_widget:getChildByName("res_img"), "ImageView")

	local res_panel = tolua.cast(res_img:getChildByName("res_panel"), "Layout")
	local fp_panel = tolua.cast(res_img:getChildByName("fp_panel"), "Layout")
	if is_show_res then
		res_panel:setVisible(true)
		fp_panel:setVisible(false)
	else
		res_panel:setVisible(false)
		fp_panel:setVisible(true)
	end

	for i=1,4 do
		local res_content = tolua.cast(res_panel:getChildByName("content_" .. i), "Layout")
		local num_slider = tolua.cast(res_content:getChildByName("num_slider"), "Slider")
		num_slider:setTouchEnabled(is_show_res)
	end
end

local function set_btn_show_content(new_content)
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"), "Button")
	local btn_content_txt = tolua.cast(confirm_btn:getChildByName("name_label"), "Label")
	btn_content_txt:setText(new_content)
end

local function init_rebel_ui(temp_widget)
	local content_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")

	local name_txt_1 = tolua.cast(content_panel:getChildByName("sign_1"), "Label")
	-- name_txt_1:setText(languagePack["fanpanjindu"])
	local name_txt_2 = tolua.cast(content_panel:getChildByName("sign_3"), "Label")
	-- name_txt_2:setText(languagePack["shangjiaoziyuan"])

	-- local lv_txt = tolua.cast(content_panel:getChildByName("lv_label"), "Label")
	-- lv_txt:setVisible(false)

	local loading_bg_img = tolua.cast(content_panel:getChildByName("process_bg_img"), "ImageView")
	-- loading_bg_img:setPositionX(313)
	local loading_bar = tolua.cast(content_panel:getChildByName("loading_bar"), "LoadingBar")
	-- loading_bar:setPositionX(313)
end

local function init_rebel_content()
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local content_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")

	-- local before_txt = tolua.cast(content_panel:getChildByName("before_label"), "Label")
	-- local sign_img = tolua.cast(content_panel:getChildByName("sign_2"), "ImageView")
	local after_txt = tolua.cast(content_panel:getChildByName("after_label"), "LabelAtlas")

	-- if UnionData.getRebelData().hasDonate < UnionData.getRebelData().total then
	if userData.getHasRebel() < userData.getRebelTotal() then
		-- before_txt:setVisible(true)
		-- sign_img:setPositionX(250)
		-- sign_img:setVisible(true)
		-- after_txt:setPositionX(265)
		set_res_show_content(true)
	else
		-- before_txt:setVisible(false)
		-- sign_img:setVisible(false)
		-- after_txt:setPositionX(110)
		set_res_show_content(false)
		set_btn_show_content(languagePack["fanpan"])
	end
end

local function init_param_info()
	if not m_slider_max_list then
		m_slider_max_list = {}
	end

	if not m_slider_current_list then
		m_slider_current_list = {}
	end

	for i=1,4 do
		local own_res_num = politics.getResNumsByType(i)
		--[[
		if m_bDonate then
			if own_res_num > 100000 then
				own_res_num = 100000
			end
		end
		--]]

		m_slider_max_list[i] = own_res_num
		m_slider_current_list[i] = 0
	end

	if m_bDonate then
		-- local unionInfo = UnionData.getUnionInfo()
		-- m_donate_need_nums = 0
		-- for i=unionInfo.level+1,#_Tb_cfg_union_level do
		-- 	m_donate_need_nums = m_donate_need_nums + Tb_cfg_union_level[i].exp
		-- end
		-- m_donate_need_nums = m_donate_need_nums - unionInfo.exp
	else
		m_rebel_need_nums = userData.getRebelTotal() - userData.getHasRebel() --UnionData.getRebelData().total - UnionData.getRebelData().hasDonate
	end
end

local function compute_exp_info(old_level, old_exp, add_exp)
	local new_level, new_exp, new_all_exp = nil, nil, nil

	local all_exp = old_exp + add_exp
	local max_level = #_Tb_cfg_union_level
	for i=old_level+1,max_level do
		if Tb_cfg_union_level[i].exp >= all_exp then
			new_level = i - 1
			new_exp = all_exp
			new_all_exp = Tb_cfg_union_level[i].exp
			break
		else
			all_exp = all_exp - Tb_cfg_union_level[i].exp
		end
	end

	if not new_level then
		new_level = max_level
		new_exp = Tb_cfg_union_level[max_level].exp
		new_all_exp = new_exp
	end

	return new_level, new_exp, new_all_exp, new_percent
end	

--现实上面数字信息等
local function organize_first_content()
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local content_panel = tolua.cast(temp_widget:getChildByName("content_panel"), "Layout")

	local current_txt = tolua.cast(content_panel:getChildByName("current_label"), "Label")
	local sum_num = get_res_all_num(0)
	current_txt:setText(sum_num)

	-- local before_txt = tolua.cast(content_panel:getChildByName("before_label"), "Label")
	local after_txt = tolua.cast(content_panel:getChildByName("after_label"), "LabelAtlas")
	local loading_bar = tolua.cast(content_panel:getChildByName("loading_bar"), "LoadingBar")

	local current_rebel_num = userData.getHasRebel()--UnionData.getRebelData().hasDonate
	local total_rebel_num = userData.getRebelTotal()
	if current_rebel_num < total_rebel_num then
		-- before_txt:setText(current_rebel_num)
		local after_op_num = current_rebel_num + sum_num
		after_txt:setStringValue(after_op_num .. "/" .. total_rebel_num)
		loading_bar:setPercent(math.floor(100 * after_op_num / total_rebel_num))
	else
		after_txt:setStringValue(total_rebel_num .. "/" .. total_rebel_num)
		loading_bar:setPercent(100)
	end
end

local function organize_second_content()
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local res_img = tolua.cast(temp_widget:getChildByName("res_img"), "ImageView")
	local res_panel = tolua.cast(res_img:getChildByName("res_panel"), "Layout")

	for i=1,4 do
		local res_content = tolua.cast(res_panel:getChildByName("content_" .. i), "Layout")
		local current_txt = tolua.cast(res_content:getChildByName("current_label"), "Label")
		local num_slider = tolua.cast(res_content:getChildByName("num_slider"), "Slider")
		local max_txt = tolua.cast(res_content:getChildByName("max_label"), "Label")
		current_txt:setText(m_slider_current_list[i])
		num_slider:setPercent(math.floor(100 * m_slider_current_list[i] / m_slider_max_list[i]))
		max_txt:setText("MAX " .. politics.getResNumsByType(i))
	end
end

function init_all_content_show()
	if not m_pMainLayer then
		return
	end

	init_param_info()

	if not m_bDonate then
		init_rebel_content()
	end

	organize_first_content()
	organize_second_content()
end

local function deal_with_percent_change(sender, eventType)
    if eventType == SLIDER_PERCENTCHANGED then
        --local temp_slider = tolua.cast(sender,"Slider")
        local select_index = tonumber(string.sub(sender:getParent():getName(), 9))
        local new_percent = sender:getPercent()
        local other_res_sum = get_res_all_num(select_index)
        local new_res_num = math.floor(m_slider_max_list[select_index] * new_percent / 100)
        if m_bDonate then
        	if new_res_num > 100000 then
        		new_res_num = 100000
        	end

        	if other_res_sum + new_res_num < m_donate_need_nums then
        		m_slider_current_list[select_index] = new_res_num
        	else
        		m_slider_current_list[select_index] = m_donate_need_nums - other_res_sum
        	end
        else
        	if other_res_sum + new_res_num < m_rebel_need_nums then
        		m_slider_current_list[select_index] = new_res_num
        	else
        		m_slider_current_list[select_index] = m_rebel_need_nums - other_res_sum
        	end
        end

        organize_first_content()
		organize_second_content()
    end
end

local function init_ui()
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local title_txt = tolua.cast(temp_widget:getChildByName("title_label"), "Label")
		-- title_txt:setText(languagePack["tongmengfanpan"])
		init_rebel_ui(temp_widget)

	local res_img = tolua.cast(temp_widget:getChildByName("res_img"), "ImageView")
	local res_panel = tolua.cast(res_img:getChildByName("res_panel"), "Layout")
	for i=1,4 do
		local res_content = tolua.cast(res_panel:getChildByName("content_" .. i), "Layout")
		local num_slider = tolua.cast(res_content:getChildByName("num_slider"), "Slider")
		num_slider:addEventListenerSlider(deal_with_percent_change)
	end

	

	local btn = tolua.cast(temp_widget:getChildByName("Button_217509_0"), "Button")
	btn:addTouchEventListener(function ( sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
			UnionMainUI.create(userData.getAffilated_union_id())
		end
	end)

	init_all_content_show()
end 

local function setAffilated_union_name(package )
	--上级同盟名字
	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	local unionName = tolua.cast(temp_widget:getChildByName("Label_212674_2_1_0_0_0"), "Label")
	unionName:setText(package[2])
end

function create(isDonate)
	if m_pMainLayer then
		return
	end

	
	netObserver.addObserver(UNION_GET_NAMES,setAffilated_union_name)
	Net.send(UNION_GET_NAMES)
	m_bDonate = isDonate

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/The_alliance_with.json")
	widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	
	local close_btn = tolua.cast(widget:getChildByName("close_btn"), "Button")
	close_btn:addTouchEventListener(deal_with_close_clik)
	close_btn:setTouchEnabled(true)

	local confirm_btn = tolua.cast(widget:getChildByName("confirm_btn"), "Button")
	confirm_btn:addTouchEventListener(deal_with_confirm_click)
	confirm_btn:setTouchEnabled(true)
	
	m_pMainLayer = TouchGroup:create()
	m_pMainLayer:addWidget(widget)

	init_ui()
	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, UnionRebelUI.init_all_content_show)
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_REBEL_MAIN)
	uiManager.showConfigEffect(uiIndexDefine.UI_REBEL_MAIN,m_pMainLayer)
end

function receive_donate_or_rebel_result(all_res)
	if m_bDonate then
		tipsLayer.create(errorTable[182], nil, {all_res})
	else
		tipsLayer.create(errorTable[183], nil, {all_res})
	end
end
