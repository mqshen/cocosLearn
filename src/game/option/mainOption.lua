-- TODOTK 
-- mainoption mainoptioninner 两个分别管理城内外主UI入口 
-- optioncontroller 用于做两个管理器的中间人
-- 目前的入口管理太分散了，UI特效也混乱不堪

--主操作界面按钮和显示
local main_serface_layer = nil

local TAG_ID_MAIN_TOOL = 999
local TAG_ID_MAIN_TOP = 998
local TAG_ID_MAIN_LEFT = 997
local TAG_ID_REMINDER = 996
local TAG_ID_MAIN_RIGHT = 994
local TAG_ID_INNER_ARMY = 985
local TAG_ID_SMALL_MAP = 970
local m_bIsInCity = false
local m_bIsInSwitchingEnable = false
local uiUtil = require("game/utils/ui_util")
local topBarSwitchState = 1  -- 顶层资源栏的切换状态 1显示基本信息 2显示资源信息
local flag_is_second_tool_bar_visible = false

local innerMainTools = require("game/option/inner_main_tools")

local m_iOpenBtnBreathEffectTag = nil

local m_next_com_guide_id = nil

local function getIsIncity()
    return m_bIsInCity
end

local function getIsInSwitchingEnable()
    return m_bIsInSwitchingEnable
end

local function remove_self()
    if main_serface_layer then
        m_iOpenBtnBreathEffectTag = nil
        m_next_com_guide_id = nil

        innerMainTools.remove()
        armyListInCityManager.remove()
        
        simpleUpdateManager.remove_update_content(updateType.RENOWN_TYPE)
        simpleUpdateManager.remove_update_content(updateType.RES_TYPE)

        remindManager.remove()
        SmallMiniMap.remove()
        main_serface_layer:removeFromParentAndCleanup(true)
        main_serface_layer = nil
        m_bIsInCity = false
        m_bIsInSwitchingEnable = false
        UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, mainOption.dealWithUserUpdate)
        UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, mainOption.dealWithResUpdate)

        UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, mainOption.yuekaTips)
        UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.add, mainOption.yuekaTips)
        
        UIUpdateManager.remove_prop_update(dbTableDesList.task.name, dataChangeType.add, mainOption.taskTips)
        UIUpdateManager.remove_prop_update(dbTableDesList.task.name, dataChangeType.update, mainOption.taskTips)
        UIUpdateManager.remove_prop_update(dbTableDesList.task.name, dataChangeType.remove, mainOption.taskTips)

        UIUpdateManager.remove_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.add, mainOption.refreshCardTips)
        UIUpdateManager.remove_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.update, mainOption.refreshCardTips)
        UIUpdateManager.remove_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.remove, mainOption.refreshCardTips)

        uiManager.remove_self_panel(uiIndexDefine.MAIN_INTERFACE_UI)

        ChatData.remove()
        BlackNameListData.remove()

    end
end


local function get_top_height()
    if not main_serface_layer then
        return 0
    end

    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    return temp_top_widget:getContentSize().height * config.getgScale()
end

local function get_bottom_height(is_bg_part)
    if not main_serface_layer then
        return 0
    end

    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if is_bg_part then
        local temp_bg_img = tolua.cast(temp_top_widget:getChildByName("bg_img"), "ImageView")
        return temp_bg_img:getContentSize().height * config.getgScale()
    else
        return temp_top_widget:getContentSize().height * config.getgScale()
    end
end

local function get_tool_btn_world_pos(btn_index)
    local temp_tool_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    local first_btn_content = tolua.cast(temp_tool_widget:getChildByName("tool_panel"), "Layout")
    local temp_btn = tolua.cast(first_btn_content:getChildByName("btn_" .. btn_index), "Button")
    return temp_btn:convertToWorldSpace(cc.p(0, 0))
end

local function get_top_res_pos()
    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local city_img = tolua.cast(temp_widget:getChildByName("city_img"), "ImageView")
    return city_img:convertToWorldSpace(cc.p(0, 0))
end

local function isHitInPanelBtTag(tagId,x,y)
    local temp_widget = main_serface_layer:getWidgetByTag(tagId)
    if not temp_widget then return false end
    return temp_widget:hitTest(cc.p(x,y))
end

--是否点击在本层的空白区域
local function isHitInVoidArea(x,y)
    local tagList = {TAG_ID_MAIN_TOOL,TAG_ID_MAIN_TOP,TAG_ID_MAIN_LEFT}
    local ret = true
    for k,v in ipairs(tagList,x,y) do
	ret = ret and (isHitInPanelBtTag(v,x,y) == false)
    end

    --城内部队列表相关区域检测，暂时特殊处理一下，后面再统一调整结构吧
    if ret then
        if armyListInCityManager then
            if armyListInCityManager.dealwithTouchEvent(x, y) then
                ret = false
            else
                ret = true
            end
        end
    end

    return ret
end


local function setResources()
    if not main_serface_layer then
        return
    end

    local yuanbao_nums = userData.getYuanbao()
    local money_nums = 0
    local selfCommonRes = politics.getSelfRes()
    if selfCommonRes then
        money_nums = selfCommonRes.money_cur
    end

    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    local yuanbao_txt = tolua.cast(temp_widget:getChildByName("yuanbao_txt"), "Label")
    yuanbao_txt:setText(commonFunc.common_gold_show_content(yuanbao_nums))
    local money_txt = tolua.cast(temp_widget:getChildByName("money_txt"), "Label")
    money_txt:setText(commonFunc.common_coin_show_content(money_nums))

    innerMainTools.reloadData()
end

local function show_res_in_top_panel(show_or_not)
    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local city_img = tolua.cast(temp_widget:getChildByName("city_img"), "ImageView")
    local common_img = tolua.cast(temp_widget:getChildByName("common_img"), "ImageView")
    common_img:setVisible(not show_or_not)
    city_img:setVisible(show_or_not)
end

--TODOTK 中文收集
local guard_state_desc = {}
guard_state_desc[userGuardState.normal] = " "
guard_state_desc[userGuardState.preparing] = "准备中"
guard_state_desc[userGuardState.guarding] = "坚守中"
guard_state_desc[userGuardState.during_cd] = "冷却中"

local function updateUserGuardInfo()
    if not main_serface_layer then return end
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local panel_jianshou_time = uiUtil.getConvertChildByName(temp_top_widget,"panel_jianshou_time")

    local cd_time = userData.getUserGuardStateCD()
    local state = userData.getUserGuardState()

    if state == userGuardState.normal or 
        state == userGuardState.during_cd then 
        cd_time = 0
    end
    
    if cd_time > 0 then 
        panel_jianshou_time:setVisible(true)
        local label_cd = uiUtil.getConvertChildByName(panel_jianshou_time,"label_cd")
        label_cd:setText(commonFunc.format_time(cd_time))
        local label_state = uiUtil.getConvertChildByName(panel_jianshou_time,"label_state")
        label_state:setText(guard_state_desc[state])
        panel_jianshou_time:setTouchEnabled(true)
        panel_jianshou_time:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                require("game/option/userOfficial")
                UserOfficial.create(5)
            end
        end)
    else
        panel_jianshou_time:setVisible(false)
        panel_jianshou_time:setTouchEnabled(false)
    end


end



local function updateDailyActivityState()
	if not main_serface_layer then return end
	local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
	if not temp_top_widget then return end
	local panel_activity = uiUtil.getConvertChildByName(temp_top_widget,"panel_activity")
	local btn_activity = uiUtil.getConvertChildByName(panel_activity,"btn_activity")
	local armature = btn_activity:getNodeByTag(10)
	
	if not armature then
		armature = CCArmature:create("btn_effect_shuishou")
        armature:getAnimation():playWithIndex(0)
		armature:setScale(0.8)
        btn_activity:addChild(armature,2,2)
		armature:setTag(10)
		armature:setPositionX(-1)
		armature:setPositionY(1)
	end

	if userData.isNewBieTaskFinished() and DailyDataModel.hasActivityNotification() then

		armature:setVisible(true)
	else
		armature:setVisible(false)
	end
end

-- 客户端需要模拟政令恢复
local function updateDecreeInfo()
    if not main_serface_layer then return end
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local panel_decree = uiUtil.getConvertChildByName(temp_top_widget,"panel_decree")
    
    local label_num_cur = uiUtil.getConvertChildByName(panel_decree,"label_num_cur")
    local label_num_max = uiUtil.getConvertChildByName(panel_decree,"label_num_max")
    local label_cd = uiUtil.getConvertChildByName(panel_decree,"label_cd")

    local curNum,maxNum = userData.getUserDecreeNum()
    label_num_cur:setText(curNum )
    label_num_max:setText( "/" .. maxNum)
	if curNum > maxNum then
        label_num_cur:setColor(ccc3(241,105,91))
	else
		label_num_cur:setColor(ccc3(255,243,195))
	end

    local img_bg = uiUtil.getConvertChildByName(panel_decree,"img_bg")
    local btn_add = uiUtil.getConvertChildByName(panel_decree,"btn_add")
    local cd = userData.getUserDecreeCD()
    if cd >= 0 and (curNum < maxNum)  then 
        label_cd:setVisible(true)
        label_cd:setText(commonFunc.format_time(cd))
        img_bg:setScaleX(1)
        panel_decree:setSize(CCSize(260,panel_decree:getContentSize().height))
        btn_add:setPositionX(img_bg:getPositionX() + img_bg:getSize().width * 0.8 + 5  )
    else
        label_cd:setVisible(false)
        img_bg:setScaleX(0.5)
        panel_decree:setSize(CCSize(140,panel_decree:getContentSize().height))
        btn_add:setPositionX(img_bg:getPositionX() + img_bg:getSize().width * 0.4 + 5 )
    end

end

-- 自适应位置
local function offsetTopPanel()
    if not main_serface_layer then return end

    --活动图标 月卡 新手保护 反叛 和 政令  坚守
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
	local panel_activity = uiUtil.getConvertChildByName(temp_top_widget,"panel_activity")
    local yuekaBtn = tolua.cast(temp_top_widget:getChildByName("gongpinBtn"), "Button")
	local panel_fanpan = uiUtil.getConvertChildByName(temp_top_widget,"panel_fanpan")
    local panel_decree = tolua.cast(temp_top_widget:getChildByName("panel_decree"), "Layout")
    local btn_newbie_protect_detail = uiUtil.getConvertChildByName(temp_top_widget,"btn_newbie_protect_detail")
    local panel_jianshou_time = uiUtil.getConvertChildByName(temp_top_widget,"panel_jianshou_time")
    local tmpTab = {panel_activity, yuekaBtn, btn_newbie_protect_detail,panel_fanpan,panel_decree,panel_jianshou_time}
    local pos_x = 143
    for i = 1,#tmpTab do 
        if tmpTab[i]:isVisible() then 
            tmpTab[i]:setPositionX(pos_x)
            pos_x = pos_x + tmpTab[i]:getContentSize().width
        end
    end
end

local function newbieProtectionTips()
    if not main_serface_layer then return end
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local btn_newbie_protect_detail = uiUtil.getConvertChildByName(temp_top_widget,"btn_newbie_protect_detail")

    local protectTimeLeft = userData.getNewBieProtectionTimeLeft()
    if protectTimeLeft > 0 then 
        btn_newbie_protect_detail:setVisible(true)
        btn_newbie_protect_detail:setTouchEnabled(true)
    else
        btn_newbie_protect_detail:setVisible(false)
        btn_newbie_protect_detail:setTouchEnabled(false)
    end
    offsetTopPanel()
end

local function update_main_tool_tips()
    if not main_serface_layer then return end

    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL) 
    if not temp_widget then return end

    -- 内政tips
    local first_btn_content = tolua.cast(temp_widget:getChildByName("tool_panel"), "Layout")
    local temp_btn = uiUtil.getConvertChildByName(first_btn_content,"btn_4")
    local img_new_flag = uiUtil.getConvertChildByName(temp_btn,"img_new_flag")
    
    if userData.getUserFreeTaxCount() > 0 and userData.getUserFreeTaxCountDown() <= 0 then 
        img_new_flag:setVisible(true)
    else
        img_new_flag:setVisible(false)
    end


    local flag_openBtn_need_breath_effect = false

    -- 同盟tips
    -- hasNewUnionApply
    local second_tool_panel = uiUtil.getConvertChildByName(temp_widget,"second_tool_panel")
    local temp_btn = uiUtil.getConvertChildByName(second_tool_panel,"btn_4")
    local img_new_flag = uiUtil.getConvertChildByName(temp_btn,"img_new_flag")
    if userData.hasNewUnionApply() or userData.hasNewUnionInvite() then 
        img_new_flag:setVisible(true)
        flag_openBtn_need_breath_effect = true
    else
        img_new_flag:setVisible(false)
    end

    local temp_btn = uiUtil.getConvertChildByName(second_tool_panel,"btn_7")
    local img_new_flag = uiUtil.getConvertChildByName(temp_btn,"img_new_flag")
    if Setting.getNewMsg() then 
        img_new_flag:setVisible(true)
        flag_openBtn_need_breath_effect = true
    else
        img_new_flag:setVisible(false)
    end
    
	

    local open_btn = uiUtil.getConvertChildByName(temp_widget,"open_btn")
    if flag_openBtn_need_breath_effect then 
        if not m_iOpenBtnBreathEffectTag then
            m_iOpenBtnBreathEffectTag = 110
            open_btn:setBright(false)
            breathAnimUtil.start_anim(open_btn, true, 120, 255, 1, 0, m_iOpenBtnBreathEffectTag)
        end
    else
        if m_iOpenBtnBreathEffectTag then
            breathAnimUtil.stop_action_by_tag(open_btn,m_iOpenBtnBreathEffectTag)
            m_iOpenBtnBreathEffectTag = nil
        end
        open_btn:setBright(true)
        open_btn:setOpacity(255)
    end
    
end

local function setLocalTime(serverTime)
    if not main_serface_layer then
        return
    end
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local temp_common_imageview = tolua.cast(temp_top_widget:getChildByName("common_img"), "ImageView")
    local shijian_2 = uiUtil.getConvertChildByName(temp_common_imageview,"shijian_2")
    shijian_2:setText(os.date("%X", serverTime))
    -- local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    -- local temp_common_imageview = tolua.cast(temp_top_widget:getChildByName("common_img"), "ImageView")
    -- local temp_time_label = tolua.cast(temp_common_imageview:getChildByName("time_txt"), "Label")
    -- temp_time_label:setText(os.date("%X", serverTime))
    updateUserGuardInfo()
    updateDecreeInfo()
    newbieProtectionTips()
    update_main_tool_tips()
	updateDailyActivityState()
end

local function updateTZL()
    if not main_serface_layer then
        return
    end

    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local temp_common_imageview = tolua.cast(temp_top_widget:getChildByName("common_img"), "ImageView")

    local temp_tzl_label = tolua.cast(temp_common_imageview:getChildByName("tzl_value_txt"), "Label")
    temp_tzl_label:setText(userData.getTzlInfo())
    local temp_mw_label = tolua.cast(temp_common_imageview:getChildByName("mw_value_txt"), "Label")
    temp_mw_label:setText(userData.getShowRenownNums().. "/" .. userData.getShowRenownNumsMax())
end


--显示上方资源数据信息
local function setResContent(current_num,max_num,add_speed,res_label,res_add_label,res_label_max)
    local show_content_1 = ""
    local show_content_1_max = "/"
    local value_divide_base = 100000
    local value_divide_factor = value_divide_base / 10000
    if current_num >= value_divide_base then
        show_content_1 = math.floor(current_num * value_divide_factor/value_divide_base).. languagePack["wan"] 
    else
        show_content_1 = show_content_1 .. current_num 
    end
    if max_num >= value_divide_base then
        show_content_1_max = show_content_1_max .. math.floor(max_num * value_divide_factor/value_divide_base) .. languagePack["wan"]
    else
        show_content_1_max = show_content_1_max .. max_num
    end
    res_label:setText(show_content_1)
    if current_num > max_num then 
        res_label:setColor(ccc3(241,105,91))
    else
        res_label:setColor(ccc3(255,255,255))
    end
    res_label_max:setText(show_content_1_max)
    res_label_max:setColor(ccc3(255,255,255))
    local show_content_2 = "+"
    --部分资源的产量可能为负数，需要特殊处理
    if add_speed < 0 then
        show_content_2 = "-"
        add_speed = -1 * add_speed
    end
    if add_speed >= value_divide_base then
        show_content_2 = show_content_2 .. math.floor(add_speed * value_divide_factor/value_divide_base) .. languagePack["wan"]
    else
        show_content_2 = show_content_2 .. add_speed
    end
    res_add_label:setText(show_content_2)
end

local function showResNum()
    if not main_serface_layer then
        return
    end

    local self_res = politics.getSelfRes()
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local temp_city_imageview = tolua.cast(temp_top_widget:getChildByName("city_img"), "ImageView")
    for i=1,4 do
        local res_con = tolua.cast(temp_city_imageview:getChildByName("res_panel_" .. i), "Layout")
        local res_label = tolua.cast(res_con:getChildByName("res_label"),"Label")
        local res_add_label = tolua.cast(res_con:getChildByName("res_add_label"),"Label")
        local res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(i)
        local res_label_max = uiUtil.getConvertChildByName(res_con,"res_label_max")
        setResContent(res_cur_nums,res_max_nums,res_add_speed,res_label,res_add_label,res_label_max)

        res_label_max:setPositionX(res_label:getPositionX() + res_label:getContentSize().width)
    end
end

local function setCityName()
    if not main_serface_layer then return end
end

local function setCityTitleInfo()
    if not main_serface_layer then return end
    local cityMessage = userCityData.getUserCityData(mainBuildScene.getThisCityid())

    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local temp_city_imageview = tolua.cast(temp_top_widget:getChildByName("city_img"), "ImageView")
    local temp_content_panel = tolua.cast(temp_city_imageview:getChildByName("content_panel_1"), "Layout")

    local city_jsd_txt = tolua.cast(temp_content_panel:getChildByName("jsd_txt"), "Label")
    city_jsd_txt:setText(cityMessage.build_area_cur .. "/" .. cityMessage.build_area_max)

    local city_frd_txt = tolua.cast(temp_content_panel:getChildByName("frd_txt"), "Label")
    city_frd_txt:setText(tostring(cityMessage.prosperity_cur))

    
end

local function updateToolChangeCityState(is_in_city)
    if not main_serface_layer then return end
    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if not temp_widget then return end
    temp_widget:setVisible(not is_in_city)
    

    local first_btn_content = tolua.cast(temp_widget:getChildByName("tool_panel"), "Layout")
    local temp_btn = nil
    for i=1,5 do
        temp_btn = tolua.cast(first_btn_content:getChildByName("btn_" .. i), "Button")
        temp_btn:setTouchEnabled(not is_in_city)
    end

    

    -- innerMainTools.changeInCityState(is_in_city,true)
end






local function fanpanTips( )
    if not main_serface_layer then return end
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
	local panel_fanpan = uiUtil.getConvertChildByName(temp_top_widget,"panel_fanpan")
    local fanpanBtn =  tolua.cast(panel_fanpan:getChildByName("Button_393869"), "Button")

    if userData.getAffilated_union_id() ~= 0 and (not m_bIsInCity) then
        fanpanBtn:setTouchEnabled(true)
        panel_fanpan:setVisible(true)
    else
        fanpanBtn:setTouchEnabled(false)
        panel_fanpan:setVisible(false)
    end
    offsetTopPanel()
end

local function updateTopChangeCityState(is_in_city)
    if not main_serface_layer then return end
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)

    local temp_common_imageview = tolua.cast(temp_top_widget:getChildByName("common_img"), "ImageView")
    temp_common_imageview:setVisible(false)
    local temp_city_imageview = tolua.cast(temp_top_widget:getChildByName("city_img"), "ImageView")
    temp_city_imageview:setVisible(false)
    
    local switch_btn = tolua.cast(temp_top_widget:getChildByName("switch_btn"),"Button")
    switch_btn:setVisible(false)
    switch_btn:setTouchEnabled(false)
    

	local panel_activity = uiUtil.getConvertChildByName(temp_top_widget,"panel_activity")
	panel_activity:setVisible(not is_in_city)
	panel_activity:setTouchEnabled(not is_in_city)
	local btn_activity = uiUtil.getConvertChildByName(panel_activity,"btn_activity")
	btn_activity:setVisible(not is_in_city)
	btn_activity:setTouchEnabled(not is_in_city)

    local panel_decree = uiUtil.getConvertChildByName(temp_top_widget,"panel_decree")
    panel_decree:setVisible(not is_in_city)
    panel_decree:setTouchEnabled(not is_in_city)

	local btn_add = uiUtil.getConvertChildByName(panel_decree,"btn_add")
	btn_add:setVisible(not is_in_city)
	btn_add:setTouchEnabled(not is_in_city)

    updateDecreeInfo()
    updateUserGuardInfo()
    if is_in_city then
        setCityTitleInfo()
        UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.update, mainOption.dealWithUserCityUpdate)
        temp_city_imageview:setVisible(true)
    else
        UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.update, mainOption.dealWithUserCityUpdate)
        temp_common_imageview:setVisible(true)
        switch_btn:setVisible(true)
        switch_btn:setTouchEnabled(true)
    end

    if (not is_in_city) then
        if topBarSwitchState == 1 then
            temp_common_imageview:setVisible(true)
            temp_city_imageview:setVisible(false)
        elseif topBarSwitchState == 2 then 
            temp_common_imageview:setVisible(false)
            temp_city_imageview:setVisible(true)
        end
    end
        
    fanpanTips()
    newbieProtectionTips()

end

local function updateLeftChangeCityState(is_in_city)
    if not main_serface_layer then return end
    
end




--参数is_in_city只是确认在城内以及城外大地图的区别，并不是真正游戏中主城，分城的概念
local function updateRightChangeCityState(is_in_city)
    if not is_in_city then 
        innerOptionRight.remove_self()
        innerOptionLeft.remove_self()
    else
        innerOptionRight.create()
        innerOptionLeft.create(main_serface_layer)
    end

    require("game/option/city_list_owned_and_marked")
    CityListOwnedAndMarked.changeInCityState(is_in_city)
end

local function changeInCityState(is_in_city)
    if not main_serface_layer then return end
    m_bIsInCity = is_in_city
    updateToolChangeCityState(is_in_city)
    updateTopChangeCityState(is_in_city)
    updateLeftChangeCityState(is_in_city)
    updateRightChangeCityState(is_in_city)
    remindManager.updateChangeCityState(is_in_city)
    miniMapManager.updateChangeCityState(is_in_city)
    MainScreenNotification.chageShowState(is_in_city,true )
end



local function deal_with_open_menu(sender, eventType)
    if eventType == TOUCH_EVENT_BEGAN then
        if comGuideManager then
            local temp_guide_id = comGuideManager.get_guide_id()
            if temp_guide_id == com_guide_id_list.CONST_GUIDE_2038 then
                m_next_com_guide_id = com_guide_id_list.CONST_GUIDE_2039
            else
                m_next_com_guide_id = 0
            end
        else
            m_next_com_guide_id = 0
        end
    elseif eventType == TOUCH_EVENT_ENDED then
        mainOption.setSecondPanelVisible(not flag_is_second_tool_bar_visible, true)
    end
end


local function deal_with_tool_btn_click(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        if m_bIsInCity then return end
        mainOption.setSecondPanelVisible(false, false)
        local select_index = tonumber(string.sub(sender:getName(),5))
        if select_index == 1 then
            -- 城市
            require("game/option/city_list_army")
            UICityListArmy.create()
            --CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
        elseif select_index == 2 then
            -- 武将
            require("game/cardDisplay/cardOverviewManager")
            cardOverviewManager.enter_card_overview()
        elseif select_index == 3 then
            -- 技能
            require("game/skill/skill_overview")
            SkillOverview.create()  
        elseif select_index == 4 then
            -- 内政
            require("game/option/userOfficial")
            UserOfficial.create()
        elseif select_index == 5 then
            -- 招募
            newGuideInfo.enter_next_guide()
            require("game/cardCall/cardCallManager")
            cardCallManager.create()

            local temp_tool_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
            local first_btn_content = tolua.cast(temp_tool_widget:getChildByName("tool_panel"), "Layout")
            local show_armature = tolua.cast(first_btn_content:getNodeByTag(100), "CCArmature")
            if show_armature and show_armature:isVisible() then
                show_armature:getAnimation():stop()
                show_armature:setVisible(false)

                require("game/uiCommon/commonPopupManager")
                commonPopupManager.gainExtractCardMode()
            end
        end
    end
end



local function deal_with_left_click_in_common(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        require("game/chat/ui_chat_main") 
        UIChatMain.show()
    end
end

local function refreshCardTips(packet)
    if not main_serface_layer then
        return 
    end

    local temp_tool_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    local first_btn_content = tolua.cast(temp_tool_widget:getChildByName("tool_panel"), "Layout")
    local new_sign_img = tolua.cast(first_btn_content:getChildByName("new_sign_img"), "ImageView")

    if not userData.isNewBieTaskFinished() then
        new_sign_img:setVisible(false)
        return
    end  

    local temp_new_state, temp_share_new_state, temp_active_new_nums, temp_share_new_nums = cardCallData.get_new_extract_nums()
    local total_nums = temp_active_new_nums + temp_share_new_nums
    if total_nums == 0 then
        new_sign_img:setVisible(false)
    else
        local num_txt = tolua.cast(new_sign_img:getChildByName("num_label"), "Label")
        num_txt:setText(total_nums)
        new_sign_img:setVisible(true)
    end

    local show_armature = tolua.cast(first_btn_content:getNodeByTag(100), "CCArmature")
    if temp_new_state or temp_share_new_state then
        if not show_armature then
            show_armature = CCArmature:create("35_renwu")
            show_armature:setTag(100)
            local call_btn = tolua.cast(first_btn_content:getChildByName("btn_5"), "Button")
            show_armature:setPosition(cc.p(call_btn:getPositionX() + 6, call_btn:getPositionY() - 4) )
            first_btn_content:addChild(show_armature)
        end
        show_armature:getAnimation():playWithIndex(0)
        show_armature:setVisible(true)
    else
        if show_armature and show_armature:isVisible() then
            show_armature:getAnimation():stop()
            show_armature:setVisible(false)
        end
    end
end

local function onClickSecondToolBtns(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then 
        local select_index = tonumber(string.sub(sender:getName(),5))
        mainOption.setSecondPanelVisible(false, true)
        if select_index == 1 then
            --战报
            require("game/battle/battleAnimationController")
            reportUI.create()
        elseif select_index == 2 then
            --排行榜
            require("game/ranking/rankingManager")
            rankingManager.on_enter()
        elseif select_index == 3 then
            -- 势力
            UIRoleForcesMain.create()
        elseif select_index == 4 then
            -- 同盟
            UnionUIJudge.create(userData.getUnion_id())
        elseif select_index == 5 then
            --活动
			require("game/daily/ui_daily_manager")
			UIDailyManager.create()
            -- require("game/option/scene_tips_occupy_city")
            -- SceneTipsOccupyCity.create()
        elseif select_index == 6 then
            --邮件
            mailManager.on_enter()
        elseif select_index == 7 then
            --设置
            Setting.create()
        elseif select_index == 8 then
            --充值 预设的 
            -- TODOTK 中文收集
            -- tipsLayer.create("敬请期待")
            require("game/pay/payUI")
            PayUI.create()
        elseif select_index == 9 then
            --公告
            require("game/daily/ui_daily_bulletin")
            UIDailyBulletin.show(false)
        elseif select_index == 10 then
            --帮助
            -- require("game/help/helpUI")
            -- gmManager.create()
            HelpUI.create()
        elseif select_index == 11 then 
            --演武的入口
            require("game/exercise/exerciseWholeManager")
            exerciseWholeManager.on_enter()
        elseif select_index == 12 then 
            --tipsLayer.create("敬请期待")
			--miniMapManager.create()
            --天下
            require("game/world_process/worldProcessManager")
            worldProcessManager.create()
        end
    end
end


local function init_main_tool_info()
    local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/mainToolbar.json")
    temp_widget:setTag(TAG_ID_MAIN_TOOL)
    temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(1,0))
    temp_widget:setScale(config.getgScale())
    temp_widget:setPosition(cc.p(config.getWinSize().width, 0))
    main_serface_layer:addWidget(temp_widget)

    local first_btn_content = tolua.cast(temp_widget:getChildByName("tool_panel"), "Layout")
    local temp_btn = nil
    for i=1,5 do
        temp_btn = tolua.cast(first_btn_content:getChildByName("btn_" .. i), "Button")
        temp_btn:setTouchEnabled(true)
        temp_btn:addTouchEventListener(deal_with_tool_btn_click)
    end

    update_main_tool_tips()

    mainOption.setSecondPanelVisible(false, false)
    local second_tool_panel = uiUtil.getConvertChildByName(temp_widget,"second_tool_panel")

    local tmp_btn = nil

    for i = 1,12 do 
        tmp_btn = uiUtil.getConvertChildByName(second_tool_panel,"btn_" .. i)
        tmp_btn:setTouchEnabled(false)
        tmp_btn:addTouchEventListener(onClickSecondToolBtns)
    end
    local open_btn = tolua.cast(temp_widget:getChildByName("open_btn"), "Button")
    open_btn:setTouchEnabled(true)
    open_btn:addTouchEventListener(deal_with_open_menu)

    local payBtn = tolua.cast(temp_widget:getChildByName("rmb_btn"), "Button")
    payBtn:setTouchEnabled(true)
    payBtn:addTouchEventListener(function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            PayUI.create()
        end
    end)

    local yuanbao = tolua.cast(temp_widget:getChildByName("yuanbao_img"),"ImageView")
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/yufu_texiao.ExportJson")

    local effect = CCArmature:create("yufu_texiao")--ImageView:create()
    effect:getAnimation():playWithIndex(0)
    yuanbao:addChild(effect)


    setResources()
    refreshCardTips()


    -- 聊天相关
    local btnChat = uiUtil.getConvertChildByName(temp_widget,"btn_chat")
    btnChat:setTouchEnabled(true)
    btnChat:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            require("game/chat/ui_chat_main") 
            UIChatMain.show()
        end
    end)
    -- btnChat:setPositionX(btnChat:getPositionX() + 100)
    -- btnChat:setPositionY(btnChat:getPositionY() + 100)
    local inner_tool_height = innerMainTools.create(main_serface_layer)
    require("game/army/armyCityOverview/armyListInCityManager")
    armyListInCityManager.create(main_serface_layer, inner_tool_height, TAG_ID_INNER_ARMY)
end

local function yuekaTips( )
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    if not temp_top_widget then return end
    local m_last_time = userData.getYuekaLastTime()
    local yuekaBtn = tolua.cast(temp_top_widget:getChildByName("gongpinBtn"), "Button")
    if userData.isHasYueka() and userData.getYuekaLeftTime() > 0 then
        yuekaBtn:setTouchEnabled(true)
        yuekaBtn:setVisible(true)
        if not commonFunc.is_in_today(m_last_time) then
            yuekaBtn:removeAllChildrenWithCleanup(true)
            local armature = CCArmature:create("btn_effect_shuishou")
            armature:getAnimation():playWithIndex(0)
            yuekaBtn:addChild(armature,2,2)
            armature:setPositionX(yuekaBtn:getSize().width*0.5)
        else
            yuekaBtn:removeAllChildrenWithCleanup(true)
        end
    else
        yuekaBtn:removeAllChildrenWithCleanup(true)
        yuekaBtn:setTouchEnabled(false)
        yuekaBtn:setVisible(false)
    end
    offsetTopPanel()
end

local function taskTips( )
    if not main_serface_layer then return end
    local count = 0
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    if not temp_top_widget then return end
    local taskBtn =  tolua.cast(temp_top_widget:getChildByName("task_btn"), "Button")
    local pane_task = tolua.cast(taskBtn:getChildByName("Panel_1232364"), "Layout")
    local sign_image = tolua.cast(temp_top_widget:getChildByName("task_sign_img"), "ImageView")

    pane_task:removeAllChildrenWithCleanup(true)

    local isFinished = true
    for i, v in pairs (allTableData[dbTableDesList.task.name]) do
        if v.is_completed == 1 and v.got_award == 0 then
            count = count + 1
        end

        if v.is_completed == 0 and v.task_id == 10102 then
            isFinished = false
        end
    end
    
    if count > 0 or (not isFinished and userData.isNewBieTaskFinished()) then
        local armature = CCArmature:create("35_renwu")
        armature:getAnimation():playWithIndex(0)
        pane_task:addChild(armature,2,2)
        armature:setPosition(cc.p(pane_task:getSize().width*0.5, pane_task:getSize().height*0.5))
        if count > 0 then
            local num_txt = tolua.cast(sign_image:getChildByName("num_label"), "Label")
            num_txt:setText(count)
            sign_image:setVisible(true)
        end
    else
        sign_image:setVisible(false)
    end
end

local function setTaskTipsVisible(flag )
    if not main_serface_layer then return end
    local count = 0
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    if not temp_top_widget then return end
    local taskBtn =  tolua.cast(temp_top_widget:getChildByName("task_btn"), "Button")
    local pane_task = tolua.cast(taskBtn:getChildByName("Panel_1232364"), "Layout")
    pane_task:removeAllChildrenWithCleanup(true)

    local isFinished = true
    for i, v in pairs (allTableData[dbTableDesList.task.name]) do
        if v.is_completed == 0 and v.task_id == 10102 then
            isFinished = false
        end
    end

    if flag or not isFinished then
        local armature = CCArmature:create("35_renwu")
        armature:getAnimation():playWithIndex(0)
        pane_task:addChild(armature,2,2)
        armature:setPosition(cc.p(pane_task:getSize().width*0.5, pane_task:getSize().height*0.5))
    end
end



local function init_main_top_info()
    local temp_top_widget = GUIReader:shareReader():widgetFromJsonFile("test/mainTopbar.json")
    temp_top_widget:setTag(TAG_ID_MAIN_TOP)
    temp_top_widget:ignoreAnchorPointForPosition(false)
    temp_top_widget:setAnchorPoint(cc.p(0,1))
    temp_top_widget:setScale(config.getgScale())
    temp_top_widget:setPosition(cc.p(0, config.getWinSize().height))
    main_serface_layer:addWidget(temp_top_widget)

    --初始化一般显示数据
    local temp_common_imageview = tolua.cast(temp_top_widget:getChildByName("common_img"), "ImageView")
    local temp_city_imageview = tolua.cast(temp_top_widget:getChildByName("city_img"), "ImageView")
    local temp_name_label = tolua.cast(temp_common_imageview:getChildByName("name_txt"), "Label")
    temp_name_label:setText(userData.getUserName())


    temp_city_imageview:setTouchEnabled(true)
    temp_city_imageview:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            UIRoleForcesMain.create(userData.getUserId(),nil,3)
        end
    end)
    local sign_image = tolua.cast(temp_top_widget:getChildByName("task_sign_img"), "ImageView")
    sign_image:setVisible(false)

    local taskBtn =  tolua.cast(temp_top_widget:getChildByName("task_btn"), "Button")
    taskBtn:addTouchEventListener(function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if userData.isInNewBieProtection() then
                local count = 0
                for i, v in pairs (allTableData[dbTableDesList.task.name]) do
                    if v.is_completed == 1 and v.got_award == 0 then
                        count = count + 1
                    end
                end
                if count <= 0 then
                    setTaskTipsVisible(false)
                end
            end
            TaskUI.create()
        end
    end)

    
    --反叛按钮
	local panel_fanpan = uiUtil.getConvertChildByName(temp_top_widget,"panel_fanpan")
    local fanpanBtn = tolua.cast(panel_fanpan:getChildByName("Button_393869"), "Button")
    fanpanBtn:addTouchEventListener(function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            UnionRebelUI.create(false)
        end
    end)

    --月卡按钮
    local yuekaBtn = tolua.cast(temp_top_widget:getChildByName("gongpinBtn"), "Button")
    yuekaBtn:addTouchEventListener(function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            BonusUI.create()
        end
    end)

    local btn_newbie_protect_detail = uiUtil.getConvertChildByName(temp_top_widget,"btn_newbie_protect_detail")
    btn_newbie_protect_detail:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            require("game/option/newbie_protect_detail")
            NewbieProtectDetail.create(1)
        end
    end)

    local panel_decree = uiUtil.getConvertChildByName(temp_top_widget,"panel_decree")
    panel_decree:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
			require("game/option/ui_decree_manager")
			UIDecreeManager.create()
        end
    end)

	local panel_activity = uiUtil.getConvertChildByName(temp_top_widget,"panel_activity")
	panel_activity:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("game/daily/ui_daily_manager")
			UIDailyManager.create()
		end
	end)
	local btn_activity = uiUtil.getConvertChildByName(panel_activity,"btn_activity")
	btn_activity:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("game/daily/ui_daily_manager")
			UIDailyManager.create()
		end
	end)

    local btn_add = uiUtil.getConvertChildByName(panel_decree,"btn_add")
    btn_add:setTouchEnabled(true)
    btn_add:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
			require("game/option/ui_decree_manager")
			UIDecreeManager.create()
        end
    end)
	

    local switch_btn = tolua.cast(temp_top_widget:getChildByName("switch_btn"),"Button")

    local updateSwitchView = function(needEffect)
        if needEffect then 
            switch_btn:runAction(animation.sequence({
            cc.CallFunc:create(function ( )
                switch_btn:setTouchEnabled(false)
            end),

            CCRotateTo:create(0.2, (topBarSwitchState == 1) and -90  or 90), 
            cc.CallFunc:create(function ( )
                switch_btn:setTouchEnabled(true)
            end)}))
        end

        if topBarSwitchState == 1 then 
            temp_common_imageview:setVisible(true)
            temp_city_imageview:setVisible(false)
        else
            temp_common_imageview:setVisible(false)
            temp_city_imageview:setVisible(true)
        end
    end
    
    switch_btn:setVisible(true)
    switch_btn:setTouchEnabled(true)
    switch_btn:addTouchEventListener(function (sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                if topBarSwitchState == 1 then
                    topBarSwitchState = 2
                elseif topBarSwitchState == 2 then
                    topBarSwitchState = 1
                end
                updateSwitchView(true)
            end
        end
        )
    updateSwitchView()

    taskTips()
    yuekaTips()
    fanpanTips()
    newbieProtectionTips()
    updateTZL()

    --初始化城市中显示数据
    showResNum()
end


local function init_main_left_info()
    -- pass
end




local function refreshChatNotify(notifyNum)
    if not notifyNum then notifyNum = 0 end
    if not main_serface_layer then return end
    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if not temp_widget then return end

    local temp_chat_btn = uiUtil.getConvertChildByName(temp_widget, "btn_chat")
    local img_notify = uiUtil.getConvertChildByName(temp_chat_btn,"img_notify")
    local label_notify = uiUtil.getConvertChildByName(temp_chat_btn,"label_notify")
    if notifyNum > 0 then 
        img_notify:setVisible(true)
        img_notify:setTouchEnabled(true)
        label_notify:setVisible(true)
    else
        img_notify:setVisible(false)
        img_notify:setTouchEnabled(false)
        label_notify:setVisible(false)
    end
    
    label_notify:setText(notifyNum)

    if img_notify:isVisible() then 
        img_notify:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                require("game/chat/ui_chat_main") 
                UIChatMain.create()
            end
        end)
    end
end



local function create()
    if main_serface_layer then
        return
    end

    require("game/option/remindManager")
    require("game/option/miniMapManager")

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/35_renwu.ExportJson")
	CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/btn_effect_shuishou.ExportJson")

    main_serface_layer = TouchGroup:create()
    init_main_tool_info()
    init_main_top_info()
    init_main_left_info()

    remindManager.create(main_serface_layer)
    SmallMiniMap.create(main_serface_layer)
    -- miniMapManager.create(main_serface_layer)

    changeInCityState(false)

    refreshChatNotify()

    uiManager.add_panel_to_layer(main_serface_layer, uiIndexDefine.MAIN_INTERFACE_UI)

    simpleUpdateManager.add_update_content(updateType.RENOWN_TYPE, updateTZL, 5*60)
    simpleUpdateManager.add_update_content(updateType.RES_TYPE, showResNum, 60)

    UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, mainOption.dealWithUserUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, mainOption.dealWithResUpdate)

    UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, mainOption.yuekaTips)
    UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.add, mainOption.yuekaTips)
    
    UIUpdateManager.add_prop_update(dbTableDesList.task.name, dataChangeType.add, mainOption.taskTips)
    UIUpdateManager.add_prop_update(dbTableDesList.task.name, dataChangeType.update, mainOption.taskTips)
    UIUpdateManager.add_prop_update(dbTableDesList.task.name, dataChangeType.remove, mainOption.taskTips)

    UIUpdateManager.add_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.add, mainOption.refreshCardTips)
    UIUpdateManager.add_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.update, mainOption.refreshCardTips)
    UIUpdateManager.add_prop_update(dbTableDesList.user_card_extract.name, dataChangeType.remove, mainOption.refreshCardTips)

    BlackNameListData.create()
    ChatData.create()

end

local function dealWithResUpdate(packet)
    setResources()
    showResNum()
end

local function dealWithUserUpdate(packet)
    setResources()
    updateTZL()
    fanpanTips()
end

local function dealWithUserCityUpdate(packet)
    if packet.city_wid == mainBuildScene.getThisCityid() then
        setCityTitleInfo()
    end
end

local function getMainLeftbarPos( )
    if not main_serface_layer then return nil end
    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_LEFT)
    if temp_widget then
        return temp_widget:getContentSize().width*config.getgScale()+temp_widget:getPositionX()
    else
        return nil
    end
end



local function getMianTopBarPos( )
    if not main_serface_layer then return nil end
    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    if temp_widget then
        local temp = temp_widget:getChildByName("switch_btn")
        if temp then
            local height = temp:convertToWorldSpace(cc.p(0, -temp:getSize().height/2))
            return height.y
        end
    else
        return nil
    end
end

local function setSecondPanelEnable(flag)
    if not main_serface_layer then return end
    local temp_widget =  main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if not temp_widget then return end

    local second_tool_panel = uiUtil.getConvertChildByName(temp_widget,"second_tool_panel")
    second_tool_panel:setTouchEnabled(flag)
    local tmp_btn = nil

    for i = 1,12 do 
        tmp_btn = uiUtil.getConvertChildByName(second_tool_panel,"btn_" .. i)
        tmp_btn:setTouchEnabled(flag)
    end


    -- 活动tips
    local temp_btn = uiUtil.getConvertChildByName(second_tool_panel,"btn_5")
    local img_new_flag = uiUtil.getConvertChildByName(temp_btn,"img_new_flag")
    if DailyDataModel.hasActivityNotification() then
        img_new_flag:setVisible(true)
    else
        img_new_flag:setVisible(false)
    end
end

local function setSecondPanelVisible(visible,needEffect)    
    flag_is_second_tool_bar_visible = visible
    if not main_serface_layer then return end
    local temp_widget =  main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if not temp_widget then return end
    local open_btn = uiUtil.getConvertChildByName(temp_widget,"open_btn")
    open_btn:ignoreAnchorPointForPosition(false)
    open_btn:setAnchorPoint(cc.p(0.5,0.5))
    open_btn:runAction(animation.sequence({
        cc.CallFunc:create(function ( )
            open_btn:setTouchEnabled(false)
        end),
        CCRotateTo:create(0.2, (visible and 90) or -90), 
        cc.CallFunc:create(function ( )
            open_btn:setTouchEnabled(true)
        end)}))
    
    local second_tool_panel = uiUtil.getConvertChildByName(temp_widget,"second_tool_panel")
    if not needEffect then 
        second_tool_panel:setVisible(visible)
        setSecondPanelEnable(visible)
        return 
    end

    second_tool_panel:setVisible(true)
    local action = nil
    if visible == true then 
        action = CCFadeIn:create(0.2)
    else
        action = CCFadeOut:create(0.2)
    end

    local action2 = cc.CallFunc:create(function ( )
        second_tool_panel:setVisible(visible)
        setSecondPanelEnable(visible)
        if visible then
            if m_next_com_guide_id and m_next_com_guide_id ~= 0 then
                comGuideManager.set_show_guide(m_next_com_guide_id)
            end
        end
    end)

    second_tool_panel:runAction(animation.sequence({action,action2}))

end


local function dealwithTouchEvent(x, y)
    if not main_serface_layer then return false end


    if SmallMiniMap then 
        SmallMiniMap.checkTouchState(x,y)
    end

    if flag_is_second_tool_bar_visible then 
        local  temp_widget = main_serface_layer:getWidgetByTag(999)
        if not temp_widget:hitTest(cc.p(x,y)) then 
            local second_tool_panel = uiUtil.getConvertChildByName(temp_widget,"second_tool_panel")
            if not second_tool_panel:hitTest(cc.p(x,y)) then 
                mainOption.setSecondPanelVisible(false, true)
            end
        end
    end

   
    local widgetTagTab = {TAG_ID_MAIN_TOOL,TAG_ID_MAIN_TOP,TAG_ID_MAIN_LEFT,TAG_ID_REMINDER,TAG_ID_MAIN_RIGHT}
    for k,v in pairs(widgetTagTab) do 
        local temp_widget = main_serface_layer:getWidgetByTag(v)
        if temp_widget and temp_widget:hitTest(cc.p(x,y)) then 
            mapMessageUI.disableTouchAndRemove()
        end
    end

    local temp_tool_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    local tool_panel = tolua.cast(temp_tool_widget:getChildByName("tool_panel"), "Layout")
    for i = 1,5 do 
        local btn_temp = uiUtil.getConvertChildByName(tool_panel,"btn_" .. i)
        if btn_temp and btn_temp:hitTest(cc.p(x,y)) then 
            mapMessageUI.disableTouchAndRemove()
        end
    end
    local btn_chat = uiUtil.getConvertChildByName(temp_tool_widget,"btn_chat")
    if btn_chat:hitTest(cc.p(x,y)) then 
        mapMessageUI.disableTouchAndRemove()
    end

    if remindManager and remindManager.dealwithTouchEvent then 
        remindManager.dealwithTouchEvent(x,y)
    end
    return false
end


local function hideEffect(callback)
    if not main_serface_layer then return end
    local actionHide = nil
    local temp_widget = nil
    m_bIsInSwitchingEnable = true
    local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
        m_bIsInSwitchingEnable = false
    end)

    local duration = 0.5
    actionHide = CCFadeOut:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if temp_widget then 
        temp_widget:runAction(actionHide)
    end

    actionHide = CCFadeOut:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    if temp_widget then 
        temp_widget:runAction(animation.sequence({actionHide,finally}))
    end

    actionHide = CCFadeOut:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_LEFT)
    if temp_widget then 
        temp_widget:runAction(actionHide)
    end

    actionHide = CCFadeOut:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_REMINDER)
    if temp_widget then 
        temp_widget:runAction(actionHide)
    end

    actionHide = CCFadeOut:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_RIGHT)
    if temp_widget then 
        temp_widget:runAction(actionHide)
    end

    if m_bIsInCity then 
        innerMainTools.hideEffect()
        armyListInCityManager.hideEffect()
    end
    armyListManager.hide_effect(duration)
end
local function showEffect(callback)
    if not main_serface_layer then return end
    local actionShow = nil
    local temp_widget = nil
    main_serface_layer:setVisible(true)

    m_bIsInSwitchingEnable = true
    local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
        m_bIsInSwitchingEnable = false
    end)

    local duration = 0.5
    actionShow = CCFadeIn:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if temp_widget then 
        temp_widget:runAction(actionShow)
    end

    actionShow = CCFadeIn:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    if temp_widget then 
        temp_widget:runAction(animation.sequence({actionShow,finally}))
    end

    actionShow = CCFadeIn:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_LEFT)
    if temp_widget then 
        temp_widget:runAction(actionShow)
    end

    actionShow = CCFadeIn:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_REMINDER)
    if temp_widget then 
        temp_widget:runAction(actionShow)
    end

    actionShow = CCFadeIn:create(duration)
    temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_RIGHT)
    if temp_widget then 
        temp_widget:runAction(actionShow)
    end
    
    armyListManager.show_effect(0.2)

    if m_bIsInCity then
        innerMainTools.showEffect()
        armyListInCityManager.showEffect()
    end
end


local function doSetEnable(flag)
    if main_serface_layer then
        local temp = main_serface_layer:getChildren()
        for i=0 , main_serface_layer:getChildrenCount()-1 do
            tolua.cast(temp:objectAtIndex(i),"Widget"):setEnabled(flag)
        end
    end
    remindManager.updateChangeCityState(m_bIsInCity and flag)
end
local function setEnable( flag, noAnimation )
    if uiManager.isClearAll() then 
        doSetEnable(flag)
        return 
    end
    
    local function finally()
        doSetEnable(flag)
    end

    if noAnimation then
        doSetEnable(flag)
    else
        if flag then 
            doSetEnable(true)
            showEffect(finally)
        else
            hideEffect(finally)
        end
    end
end


-- cid 用于强制切换数据
local function switchCityEffect(isIncity,cid)
    if not main_serface_layer then return end
    
    if isIncity and cid then 
        mainBuildScene.setThisCityid(cid)
    end

    m_bIsInCity = isIncity

    local duration = 0.5
    -- 顶层  这个特殊处理 没办法 等代码重构后调整
    local temp_top_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    local cp_temp_top_widget = temp_top_widget:clone()
    temp_top_widget:getParent():addChild(cp_temp_top_widget)
    cp_temp_top_widget:setTag(100)

    uiUtil.hideScaleEffect(cp_temp_top_widget,function()
        cp_temp_top_widget:removeFromParentAndCleanup(true)
        cp_temp_top_widget = nil
    end,duration)
    updateTopChangeCityState(isIncity)
    uiUtil.showScaleEffect(temp_top_widget,nil,duration)
    
    -- 下层
    local tool_widget = main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    if isIncity then 
        uiUtil.hideScaleEffect(tool_widget,function()
            updateToolChangeCityState(isIncity)
        end,0.5,nil)
    else
        tool_widget:setVisible(true)
        uiUtil.showScaleEffect(tool_widget,function()
            tool_widget:setVisible(false)
            updateToolChangeCityState(isIncity)
        end,0.5,nil)
    end
    innerMainTools.changeInCityState(isIncity)
    armyListInCityManager.changeInCityState(isIncity)
    
    --城外特有
    if isIncity then 
        armyListManager.hide_effect(duration)
    else
        armyListManager.show_effect(duration)
    end
    local temp_widget = main_serface_layer:getWidgetByTag(TAG_ID_REMINDER)
    if isIncity then 
        SmallMiniMap.hideEffect()
    else
        SmallMiniMap.showEffect()
    end

    remindManager.updateChangeCityState(isIncity)
    if isIncity then 
        remindManager.hideEffect()
    else
        remindManager.showEffect()
    end
    

    miniMapManager.updateChangeCityState(isIncity)
    MainScreenNotification.chageShowState(isIncity,true )
    --城内特有
    updateRightChangeCityState(isIncity)
end

local function get_guide_widget(temp_guide_id)
    if not main_serface_layer then
        return nil
    end

    --[[
    if temp_guide_id == guide_id_list.CONST_GUIDE_22 or temp_guide_id == guide_id_list.CONST_GUIDE_42 
        or temp_guide_id == guide_id_list.CONST_GUIDE_47 or temp_guide_id == guide_id_list.CONST_GUIDE_216 
        or temp_guide_id == guide_id_list.CONST_GUIDE_225 or temp_guide_id == guide_id_list.CONST_GUIDE_235 then
        return main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_66 then
        return main_serface_layer:getWidgetByTag(TAG_ID_REMINDER)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_202 then
        return main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    end
    --]]

    if temp_guide_id == guide_id_list.CONST_GUIDE_1006 or temp_guide_id == guide_id_list.CONST_GUIDE_1033 
        or temp_guide_id == guide_id_list.CONST_GUIDE_1056 or temp_guide_id == guide_id_list.CONST_GUIDE_1088 then
        return main_serface_layer:getWidgetByTag(TAG_ID_INNER_ARMY)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1013 or temp_guide_id == guide_id_list.CONST_GUIDE_1040 
        or temp_guide_id == guide_id_list.CONST_GUIDE_1065 or temp_guide_id == guide_id_list.CONST_GUIDE_1083 
        or temp_guide_id == guide_id_list.CONST_GUIDE_1095 then
        return innerMainTools.get_guide_widget(temp_guide_id)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1020 then
        return remindManager.get_guide_widget()
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1076 then
        return main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    elseif temp_guide_id == guide_id_list.CONST_GUIDE_1112 or temp_guide_id == guide_id_list.CONST_GUIDE_1113 then
        return main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOP)
    end

    return nil
end

local function get_com_guide_widget(temp_guide_id)
    if not main_serface_layer then
        return nil
    end
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2012 then 
        return  main_serface_layer:getWidgetByTag(TAG_ID_SMALL_MAP)
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2013 then
        require("game/option/city_list_owned_and_marked")
        return CityListOwnedAndMarked.getInstance()
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2007 or temp_guide_id == com_guide_id_list.CONST_GUIDE_2038 
        or temp_guide_id == com_guide_id_list.CONST_GUIDE_2039 then 
        return main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2024 then 
        return main_serface_layer:getWidgetByTag(TAG_ID_MAIN_TOOL)
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2022 then
        return innerMainTools.get_com_guide_widget(temp_guide_id)
    end 
    return nil
end

mainOption = { 
				create = create,
                remove_self = remove_self,
                dealwithTouchEvent = dealwithTouchEvent,
                get_guide_widget = get_guide_widget,
                get_top_height = get_top_height,
                get_tool_btn_world_pos = get_tool_btn_world_pos,
                get_top_res_pos = get_top_res_pos,
                show_res_in_top_panel = show_res_in_top_panel,
                setLocalTime = setLocalTime,
                changeInCityState = changeInCityState,
                dealWithResUpdate = dealWithResUpdate,
                dealWithUserUpdate = dealWithUserUpdate,
                dealWithUserCityUpdate = dealWithUserCityUpdate,
                getMainLeftbarPos = getMainLeftbarPos,
                taskTips = taskTips,
                refreshCardTips = refreshCardTips,
                refreshChatNotify = refreshChatNotify,
                setEnable = setEnable,
                getMianTopBarPos = getMianTopBarPos,
                setSecondPanelVisible = setSecondPanelVisible,
                getInnerListCityListPos = getInnerListCityListPos,
                isHitInVoidArea = isHitInVoidArea,
                switchCityEffect = switchCityEffect,
                getIsIncity = getIsIncity,
                setTaskTipsVisible = setTaskTipsVisible,
                getIsInSwitchingEnable = getIsInSwitchingEnable,
                yuekaTips = yuekaTips,
                get_com_guide_widget =get_com_guide_widget,
			}
