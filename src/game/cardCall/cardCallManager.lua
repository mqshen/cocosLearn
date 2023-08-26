local card_call_layer = nil
local m_main_widget = nil
local m_backPanel = nil

local function do_remove_self()
	if card_call_layer then
		cardCallAnimManager.remove()
		cardCallListManager.remove()
		callResultManager.remove()
		callTechnicChangeManager.remove()

		m_main_widget = nil

		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end

		card_call_layer:removeFromParentAndCleanup(true)
		card_call_layer = nil

    	cardTextureManager.remove_cache()
    	
    	local is_own_new_way = cardCallData.get_new_extract_nums()
    	if is_own_new_way then
    		cardOpRequest.request_clear_new_sign()
    	end

    	uiManager.remove_self_panel(uiIndexDefine.CARD_EXTRACT_INFO)

    	UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, cardCallManager.dealWithResUpdate)
   		UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, cardCallManager.dealWithResUpdate)
		
		UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.add, cardCallManager.dealWithCardUpdate)
    	UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.remove, cardCallManager.dealWithCardUpdate)
	end
end

local function remove_self(close_no_effect)
	cardCallListManager.stop_update_timer()
	if close_no_effect then
		do_remove_self()
	else
		if m_backPanel then
	    	uiManager.hideConfigEffect(uiIndexDefine.CARD_EXTRACT_INFO, card_call_layer, do_remove_self, 999, {m_backPanel:getMainWidget()})
	    end
	end
end

local function deal_with_close_click()
	if cardCallAnimManager.get_anim_state() then
		return
	end

	if not callResultAnimManager.is_touch_enabled() then
		return
	end

	if callResultManager.is_in_result_page() then
		callResultManager.close_result_page()
	else
		remove_self()
	end

	newGuideInfo.enter_next_guide()
end

local function dealwithTouchEvent(x,y)
	return false
end

local function deal_with_btn_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if cardCallAnimManager.get_anim_state() then
			return
		end

		if not callResultAnimManager.is_touch_enabled() then
			return
		end
		
		remove_self()
		
		require("game/cardDisplay/cardOverviewManager")
		cardOverviewManager.enter_card_overview()
	end
end

local function organize_resource_content(is_first_init)
	local refresh_content_img = tolua.cast(m_main_widget:getChildByName("res_img"), "ImageView")

    local yuanbao_nums = userData.getYuanbao()
    local money_nums = 0
    local selfCommonRes = politics.getSelfRes()
    if selfCommonRes then
        money_nums = selfCommonRes.money_cur
    end

    local yuanbao_txt = tolua.cast(refresh_content_img:getChildByName("yuanbao_label"), "Label")
    yuanbao_txt:setText(commonFunc.common_gold_show_content(yuanbao_nums))
    local money_txt = tolua.cast(refresh_content_img:getChildByName("money_label"), "Label")
    money_txt:setText(commonFunc.common_coin_show_content(money_nums))
    local tech_txt = tolua.cast(refresh_content_img:getChildByName("technic_label"), "Label")
    tech_txt:setText(SkillDataModel.getUserSkillValue())


    if is_first_init then
    	local tech_add_txt = tolua.cast(refresh_content_img:getChildByName("tech_add_label"), "Label")
    	tech_add_txt:setVisible(false)
	    -- 充值按钮
	    local payBtn = tolua.cast(refresh_content_img:getChildByName("rmb_btn"), "Button")
	    payBtn:setTouchEnabled(true)
	    payBtn:addTouchEventListener(function ( sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				PayUI.create()
			end
	    end)

	    local yuanbao = tolua.cast(refresh_content_img:getChildByName("yuanbao_img"),"ImageView")
	    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/yufu_texiao.ExportJson")

		local effect = CCArmature:create("yufu_texiao")--ImageView:create()
		effect:getAnimation():playWithIndex(0)
		yuanbao:addChild(effect)

    	if callResultAnimManager then
    		callResultAnimManager.set_technic_component(tech_txt, tech_add_txt)
    	end
    end
end

local function organize_card_num_content(is_add_event)
	local card_btn = tolua.cast(m_main_widget:getChildByName("card_btn"), "Button")
	local own_nums = heroData.getHeroNums()
	if own_nums < sysUserConfigData.get_card_bag_nums() then
		card_btn:setTitleColor(ccc3(213,168,81))
	else
		card_btn:setTitleColor(ccc3(255,0,0))
	end
	card_btn:setTitleText(languagePack["general_card"] .. "(" .. own_nums .. "/" .. sysUserConfigData.get_card_bag_nums() .. ")》")

	if is_add_event then
		card_btn:addTouchEventListener(deal_with_btn_click)
		card_btn:setTouchEnabled(true)

		if callResultAnimManager then
			callResultAnimManager.set_bag_component(card_btn)
		end
	end
end

local function create()
	if card_call_layer then
		return
	end

	require("game/cardCall/cardCallListManager")
	require("game/cardCall/callResultManager")
	require("game/cardCall/cardCallAnimManager")
	require("game/cardCall/callWayManager")
	require("game/cardCall/callTechnicChangeManager")
	cardCallAnimManager.init_param_info()

	m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/callCardUI.json")
	m_main_widget:setTag(999)
	m_backPanel = UIBackPanel.new()
	local temp_widget = m_backPanel:create(m_main_widget, deal_with_close_click, panelPropInfo[uiIndexDefine.CARD_EXTRACT_INFO][2])

	local call_list_img = tolua.cast(m_main_widget:getChildByName("main_call_img"), "ImageView")
	--call_list_img:setVisible(true)
	cardCallListManager.create(call_list_img)

	local called_panel = tolua.cast(m_main_widget:getChildByName("called_panel"), "Layout")
	callResultManager.create(called_panel)

	local technic_panel = tolua.cast(m_main_widget:getChildByName("technic_panel"), "Layout")
	callTechnicChangeManager.create(technic_panel)

	organize_resource_content(true)
	organize_card_num_content(true)

	card_call_layer = TouchGroup:create()
	card_call_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(card_call_layer, uiIndexDefine.CARD_EXTRACT_INFO)
	--uiManager.showConfigEffect(uiIndexDefine.CARD_EXTRACT_INFO, card_call_layer, nil, 999, {temp_widget})

	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, cardCallManager.dealWithResUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, cardCallManager.dealWithResUpdate)

    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.add, cardCallManager.dealWithCardUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.remove, cardCallManager.dealWithCardUpdate)
end

local function dealWithResUpdate(packet)
	organize_resource_content(false)
	if cardCallListManager then
		cardCallListManager.reload_new_data()
	end
end

local function dealWithCardUpdate(packet)
	organize_card_num_content(false)
end

local function get_guide_widget(temp_guide_id)
	if temp_guide_id == guide_id_list.CONST_GUIDE_1079 or temp_guide_id == guide_id_list.CONST_GUIDE_1080 then
		return m_backPanel:getMainWidget()
	else
		return m_main_widget
	end
end

cardCallManager = {
					create = create,
					remove_self = remove_self,
					dealwithTouchEvent = dealwithTouchEvent,
					get_guide_widget = get_guide_widget,
					dealWithResUpdate = dealWithResUpdate,
					dealWithCardUpdate = dealWithCardUpdate
}