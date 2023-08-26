local m_technic_panel = nil

local m_change_state = nil 		--是否自动转化
local m_filter_index = nil 		--技巧值转化选择的索引（1星，2星等）

--local SkillOpreateObserver = nil

local function remove()
	--SkillOpreateObserver.remove()
	--SkillOpreateObserver = nil
	m_change_state = nil
	m_filter_index = nil

	m_technic_panel = nil
end

--[[
local function deal_with_change_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED and callResultAnimManager.is_touch_enabled() then
		if SkillDataModel.getUserSkillValue() >= SKILL_VALUE_MAX then
			tipsLayer.create(errorTable[232])
			return
		end

		local temp_limit_star = nil
		if m_filter_index == 1 then
			temp_limit_star = cardQuality.one_star
		elseif m_filter_index == 2 then
			temp_limit_star = cardQuality.two_star
		elseif m_filter_index == 3 then
			temp_limit_star = cardQuality.three_star
		end

		local temp_result_list = {}
		for k,v in pairs(m_card_list) do
			if m_change_list[k] == 0 then
				local hero_cfg_id = m_card_cfg_list[k]
				if hero_cfg_id ~= 0 and Tb_cfg_hero[hero_cfg_id].quality <= temp_limit_star then			
					table.insert(temp_result_list, v)
				end
			end
		end

		--转化所需铜钱判断
		local cost_coin = #temp_result_list * SKILL_VALUE_TRANSFORM_MONEY
		local money_nums = userData.getUserCoin()
		if money_nums < cost_coin then 
            tipsLayer.create(languagePack["res_not_enough_coin"])
            return 
        end

		if #temp_result_list > 0 then
			SkillOpreateObserver.requestTranserlateSkillValue(temp_result_list, consumeType.common_money)
		else
			tipsLayer.create(errorTable[231])
		end
	end
end
--]]

local function set_filter_option_state(new_state)
	local filter_panel = tolua.cast(m_technic_panel:getChildByName("filter_panel"), "Layout")
	for i=1,6 do
		local filter_option = tolua.cast(filter_panel:getChildByName("filter_btn_" .. i), "Button")
		if new_state then
			if i == m_filter_index then
				filter_option:setBright(false)
			else
				filter_option:setBright(true)
			end
		end
		filter_option:setTouchEnabled(new_state)
	end

	filter_panel:setVisible(new_state)
end

local function organize_filter_btn_content()
	local filter_btn = tolua.cast(m_technic_panel:getChildByName("filter_btn"), "Button")
	local filter_star_txt = tolua.cast(filter_btn:getChildByName("star_label"), "Label")
	local filter_range_txt = tolua.cast(filter_btn:getChildByName("range_label"), "Label")
	local gold_img = tolua.cast(filter_btn:getChildByName("gold_img"), "ImageView")
	local money_img = tolua.cast(filter_btn:getChildByName("money_img"), "ImageView")

	local filter_panel = tolua.cast(m_technic_panel:getChildByName("filter_panel"), "Layout")
	local filter_option = tolua.cast(filter_panel:getChildByName("filter_btn_" .. m_filter_index), "Button")
	local option_star_txt = tolua.cast(filter_option:getChildByName("star_label"), "Label")
	local option_range_txt = tolua.cast(filter_option:getChildByName("range_label"), "Label")

	filter_star_txt:setText(option_star_txt:getStringValue())
	filter_range_txt:setText(option_range_txt:getStringValue())
	if m_filter_index >=1 and m_filter_index <= 3 then
		gold_img:setVisible(false)
		money_img:setVisible(true)
	else
		gold_img:setVisible(true)
		money_img:setVisible(false)
	end
end

local function deal_with_option_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		m_filter_index = tonumber(string.sub(sender:getName(),12))
		set_filter_option_state(false)
		organize_filter_btn_content()

		CCUserDefault:sharedUserDefault():setIntegerForKey(recordLocalInfo[7], m_filter_index)
	end
end

local function deal_with_filter_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local filter_panel = tolua.cast(m_technic_panel:getChildByName("filter_panel"), "Layout")
		if filter_panel:isVisible() then
			set_filter_option_state(false)
		else
			set_filter_option_state(true)
		end
	end
end

local function deal_with_change_cb_click(sender, eventType)
	if eventType == CHECKBOX_STATE_EVENT_SELECTED then
		m_change_state = true
	else
		m_change_state = false
	end

	CCUserDefault:sharedUserDefault():setBoolForKey(recordLocalInfo[6], m_change_state)
end

local function init_change_event()
	local select_cb = tolua.cast(m_technic_panel:getChildByName("select_cb"), "CheckBox")
	select_cb:setSelectedState(m_change_state)
	select_cb:setTouchEnabled(true)
	select_cb:addEventListenerCheckBox(deal_with_change_cb_click)

	--local change_btn = tolua.cast(tech_panel:getChildByName("change_btn"), "Button")
	--change_btn:addTouchEventListener(deal_with_change_click)

	local filter_panel = tolua.cast(m_technic_panel:getChildByName("filter_panel"), "Layout")
	local filter_option, price_txt = nil, nil
	for i=1,6 do
		filter_option = tolua.cast(filter_panel:getChildByName("filter_btn_" .. i), "Button")
		filter_option:addTouchEventListener(deal_with_option_click)

		price_txt = tolua.cast(filter_option:getChildByName("price_label"), "Label")
		if i >= 1 and i <= 3 then
			price_txt:setText(SKILL_VALUE_TRANSFORM_MONEY .. languagePack['meizhang'])
		else
			price_txt:setText(SKILL_VALUE_TRANSFORM_YUANBAO .. languagePack['meizhang'])
		end
	end

	local filter_btn = tolua.cast(m_technic_panel:getChildByName("filter_btn"), "Button")
	filter_btn:setTouchEnabled(true)
	filter_btn:addTouchEventListener(deal_with_filter_click)
end

local function create(temp_panel)
	m_technic_panel = temp_panel
	m_change_state = CCUserDefault:sharedUserDefault():getBoolForKey(recordLocalInfo[6])
	m_filter_index = CCUserDefault:sharedUserDefault():getIntegerForKey(recordLocalInfo[7])
	if m_filter_index == 0 then
		m_filter_index = 1
	end

	init_change_event()
	set_filter_option_state(false)
	organize_filter_btn_content()

	--SkillOpreateObserver = require("game/skill/skill_operate_observer")
	--SkillOpreateObserver.create()
end

local function get_change_param()
	if m_change_state then
		if m_filter_index >= 1 and m_filter_index <= 3 then
			return m_filter_index - 1, consumeType.common_money
		else
			return m_filter_index - 4, consumeType.yuanbao
		end
	else
		return 0, 0
	end	
end

callTechnicChangeManager = {
							create = create,
							remove = remove,
							get_change_param = get_change_param
}