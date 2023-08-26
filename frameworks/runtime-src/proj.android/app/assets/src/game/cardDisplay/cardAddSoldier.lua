local card_add_soldier_layer = nil
local m_main_widget = nil

local m_army_id = nil
--local m_is_in_own_city = nil                --部队是否在自己的城市（也就是部队正常状态还是调动状态）
local m_own_city_id = nil       --部队所属城市
local m_in_city_id = nil        --部队所在城市
local m_resource_param = nil    --资源消耗系数
local m_is_can_use_yb = nil     --是否可以使用预备兵
local m_is_need_money = nil     --是否需要消耗铜钱

local hero_list_info = nil
local zb_num_list = nil

local is_using_yubeibing = nil          -- 是否使用预备兵种
local yubeisuo_soldier_num = nil        --预备所兵力限制
local zb_interval_timer = nil           --正在征兵的倒计时刷新

local update_timer = nil            --滑块拖动时的刷新间隔
local m_is_need_update = nil

local ColorUtil = require("game/utils/color_util")
local UIUtil = require("game/utils/ui_util")

local ARMY_RECRUIT_OUTSIDE_COST_MONEY = 2

local function do_remove_self()
	if card_add_soldier_layer then
        m_main_widget = nil
        m_army_id = nil
        m_own_city_id = nil
        m_in_city_id = nil
        m_resource_param = nil
        m_is_can_use_yb = nil
        m_is_need_money = nil

        hero_list_info = nil
        zb_num_list = nil

        is_using_yubeibing = nil
        yubeisuo_soldier_num = nil
        m_is_need_update = nil

		card_add_soldier_layer:removeFromParentAndCleanup(true)
		card_add_soldier_layer = nil

        uiManager.remove_self_panel(uiIndexDefine.CARD_ADD_SOLDIER)

        UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, cardAddSoldier.dealWithHeroUpdate)
        UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.add, cardAddSoldier.dealWithBuildChange)
        UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, cardAddSoldier.dealWithBuildChange)
	
        if armyHeroManager then
            armyHeroManager.play_ybb_anim()
        end
    end
end

local function remove_self()
    if zb_interval_timer then
        scheduler.remove(zb_interval_timer)
        zb_interval_timer = nil
    end

    if update_timer then
        scheduler.remove(update_timer)
        update_timer = nil
    end

    if card_add_soldier_layer then
       uiManager.hideConfigEffect(uiIndexDefine.CARD_ADD_SOLDIER, card_add_soldier_layer, do_remove_self)
    end 
end

local function dealwithTouchEvent(x,y)
	if not card_add_soldier_layer then
		return false
	end

	if m_main_widget:hitTest(cc.p(x,y)) then
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

local function deal_with_add_soldier_event()
    local add_type = 0
    local temp_zb_index_list = nil
    if is_using_yubeibing then 
        add_type = 1
        temp_zb_index_list = {}
    end

    local temp_zb_list = {}
    for i,v in ipairs(zb_num_list) do
        if v.cur_num ~= 0 then
            local temp_zb_info = {}
            table.insert(temp_zb_info, hero_list_info[i]["hero_uid"])
            table.insert(temp_zb_info, v.cur_num)
            table.insert(temp_zb_list, temp_zb_info)

            if is_using_yubeibing then
                table.insert(temp_zb_index_list, i)
            end
        end
    end

    if is_using_yubeibing then
        armyHeroManager.set_anim_list(temp_zb_index_list)
    end
    
    remove_self()
    addSoldierRequest.requestNewAddRecruit(add_type, temp_zb_list)
    newGuideInfo.enter_next_guide()
end

local function calc_confirm_condition()
    local current_add_nums, max_add_nums = 0, 0
    local show_content = languagePack["shifouqueren"]
    local show_args = {}
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 then
            local temp_current_nums = zb_num_list[i]["cur_num"]
            current_add_nums = current_add_nums + temp_current_nums
            max_add_nums = max_add_nums + zb_num_list[i]["max_num"]

            if temp_current_nums ~= 0 then
                if is_using_yubeibing then
                    show_content = show_content .. "#\n#" .. languagePack["zb_unuse_time"]
                    table.insert(show_args, Tb_cfg_hero[v.hero_cfg_id].name)
                    table.insert(show_args, temp_current_nums)
                else
                    show_content = show_content .. "#\n#" .. languagePack["zb_use_time"]
                    table.insert(show_args, Tb_cfg_hero[v.hero_cfg_id].name)
                    table.insert(show_args, temp_current_nums)
                    table.insert(show_args, commonFunc.format_time(addSoldierRequest.getRecruitTime(math.floor(m_army_id/10), v.hero_cfg_id, temp_current_nums)))
                end
            end
        end
    end
    return current_add_nums, max_add_nums,show_content,show_args
end

local function deal_with_confirm_click(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        local current_add_nums, max_add_nums,show_content,show_args = calc_confirm_condition()
        if current_add_nums == 0 then
            if m_in_city_id == m_own_city_id then
                local temp_leave_nums, all_queue_num = armyData.get_army_city_zb_queue_num(m_army_id)
                if temp_leave_nums == 0 then
                    if all_queue_num == ARMY_QUEUE_INIT then
                        require("game/cardDisplay/zbQueueDesManager")
                        zbQueueDesManager.create()
                    end
                else
                    tipsLayer.create(errorTable[141])
                end
            else
                tipsLayer.create(errorTable[141])
            end

            return
        end

        --[[
        if max_add_nums == 0 then 
            tipsLayer.create(errorTable[140])
            return
        end
        --]]

        newGuideInfo.enter_next_guide()

        alertLayer.create({comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL,languagePack["zb_title"],show_content}, show_args, deal_with_add_soldier_event)
    end
end

local function deal_with_cancel_click(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        local select_index = tonumber(string.sub(sender:getParent():getParent():getName(),5))
        addSoldierRequest.requestCancelRecruit(hero_list_info[select_index]["hero_uid"])
    end
end

local function organize_res_info()
    local consume_res_list = {}
    consume_res_list[resType.wood] = 0
    consume_res_list[resType.stone] = 0
    consume_res_list[resType.iron] = 0
    consume_res_list[resType.food] = 0
    consume_res_list[resType.money] = 0

    local basic_hero_info = nil
    local current_add_nums, consume_food_nums = 0, 0
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 then
            basic_hero_info = Tb_cfg_hero[v.hero_cfg_id]
            for kk,vv in pairs(basic_hero_info.recruit_cost) do
                consume_res_list[vv[1]] = consume_res_list[vv[1]] + m_resource_param*vv[2]*zb_num_list[i]["cur_num"]
            end
            if m_is_need_money then
                consume_res_list[resType.money] = consume_res_list[resType.money] + ARMY_RECRUIT_OUTSIDE_COST_MONEY*zb_num_list[i]["cur_num"]
            end
            current_add_nums = current_add_nums + zb_num_list[i]["cur_num"]
            consume_food_nums = consume_food_nums + math.floor(basic_hero_info.food_cost * zb_num_list[i]["cur_num"] * 0.01)
        end
    end

    local consume_panel = tolua.cast(m_main_widget:getChildByName("consume_panel"), "Layout")
    local com_consume = tolua.cast(consume_panel:getChildByName("com_consume"), "Layout")
    local res_panel, need_txt, own_txt = nil, nil, nil
    for i=1,4 do
        res_panel = tolua.cast(com_consume:getChildByName("res_" .. i), "Layout")
        need_txt = tolua.cast(res_panel:getChildByName("need_label"), "Label")
        own_txt = tolua.cast(res_panel:getChildByName("own_label"), "Label")

        local own_res_num = politics.getResNumsByType(i)
        need_txt:setText(consume_res_list[i])
        own_txt:setText("/" .. own_res_num)
        --[[
        if own_res_num < consume_res_list[i] then 
            need_txt:setColor(ColorUtil.CCC_TEXT_RED)
        else
            need_txt:setColor(ColorUtil.CCC_TEXT_YELLOW)
        end
        --]]
        own_txt:setPositionX(need_txt:getPositionX() + need_txt:getContentSize().width)
    end

    if m_is_can_use_yb then
        local yb_img = tolua.cast(consume_panel:getChildByName("yb_img"), "ImageView")
        local cur_yubei_txt = tolua.cast(yb_img:getChildByName("cur_label"), "Label")
        if is_using_yubeibing then
            cur_yubei_txt:setText(current_add_nums)
        else
            cur_yubei_txt:setText("0")
        end
    end

    local food_panel = tolua.cast(com_consume:getChildByName("food_consume_panel"), "Layout")
    local need_food_txt = tolua.cast(food_panel:getChildByName("num_label"), "Label")
    local sign_txt = tolua.cast(food_panel:getChildByName("sign_label_2"), "Label")
    need_food_txt:setText("-" .. consume_food_nums)
    sign_txt:setPositionX(need_food_txt:getPositionX() + need_food_txt:getContentSize().width)

    if m_is_need_money then
        local money_consume = tolua.cast(consume_panel:getChildByName("money_consume"), "Layout")
        need_txt = tolua.cast(money_consume:getChildByName("need_label"), "Label")
        own_txt = tolua.cast(money_consume:getChildByName("own_label"), "Label")
        local own_money_num = userData.getUserCoin()
        need_txt:setText(consume_res_list[resType.money])
        own_txt:setText("/" .. own_money_num)
        --[[
        if own_money_num < consume_res_list[resType.money] then 
            need_txt:setColor(ColorUtil.CCC_TEXT_RED)
        else
            need_txt:setColor(ColorUtil.CCC_TEXT_YELLOW)
        end
        --]]
        own_txt:setPositionX(need_txt:getPositionX() + need_txt:getContentSize().width)
        local des_txt = tolua.cast(money_consume:getChildByName("content_label"), "Label")
        des_txt:setPositionX(own_txt:getPositionX() + own_txt:getContentSize().width + 10)
    end
    
    local btn_panel = tolua.cast(m_main_widget:getChildByName("btn_panel"), "Layout")
    local confirm_btn = tolua.cast(btn_panel:getChildByName("confirm_btn"), "Button")
    if current_add_nums == 0 then
        --confirm_btn:setTouchEnabled(false)
        confirm_btn:setBright(false)
    else
        --confirm_btn:setTouchEnabled(true)
        confirm_btn:setBright(true)
    end

    local label_resNotEnough = uiUtil.getConvertChildByName(m_main_widget,"label_resNotEnough")
    local current_add_nums, max_add_nums,show_content,show_args = calc_confirm_condition()
    if max_add_nums == 0 then 
        label_resNotEnough:setVisible(true)
    else
        label_resNotEnough:setVisible(false)
    end
end

local function calculation_num_by_index(index)
    local current_res_list = {}
    current_res_list[resType.wood] = politics.getResNumsByType(resType.wood)
    current_res_list[resType.stone] = politics.getResNumsByType(resType.stone)
    current_res_list[resType.iron] = politics.getResNumsByType(resType.iron)
    current_res_list[resType.food] = politics.getResNumsByType(resType.food)
    current_res_list[resType.money] = userData.getUserCoin()

    local basic_hero_info = nil
    local other_add_nums = 0
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 and i ~= index then
            basic_hero_info = Tb_cfg_hero[v.hero_cfg_id]
            for kk,vv in pairs(basic_hero_info.recruit_cost) do
                current_res_list[vv[1]] = current_res_list[vv[1]] - m_resource_param*vv[2]*zb_num_list[i]["cur_num"]
            end
            if m_is_need_money then
                current_res_list[resType.money] = current_res_list[resType.money] - ARMY_RECRUIT_OUTSIDE_COST_MONEY * zb_num_list[i]["cur_num"]
            end

            other_add_nums = other_add_nums + zb_num_list[i]["cur_num"]
        end
    end

    local temp_add_nums, can_add_nums = nil, nil
    basic_hero_info = Tb_cfg_hero[hero_list_info[index]["hero_cfg_id"]]
    for kk,vv in pairs(basic_hero_info.recruit_cost) do
         temp_add_nums = math.floor(current_res_list[vv[1]]/(vv[2]*m_resource_param))
         if can_add_nums then
            if can_add_nums > temp_add_nums then
                can_add_nums = temp_add_nums
            end
         else
            can_add_nums = temp_add_nums
         end
     end
     if m_is_need_money then
        temp_add_nums = math.floor(current_res_list[resType.money]/ARMY_RECRUIT_OUTSIDE_COST_MONEY)
        if can_add_nums > temp_add_nums then
            can_add_nums = temp_add_nums
        end
     end

    --获取武将可以容纳的最大兵力
    local temp_hero_uid = hero_list_info[index]["hero_uid"]
    zb_num_list[index]["need_max_num"] = heroData.getHeroMaxHp(temp_hero_uid) - heroData.getHeroHp(temp_hero_uid)
    can_add_nums = math.min(zb_num_list[index]["need_max_num"], can_add_nums)

    if is_using_yubeibing then
        can_add_nums = math.min(yubeisuo_soldier_num - other_add_nums, can_add_nums)
    end
    zb_num_list[index]["max_num"] = can_add_nums
end

local function calculation_can_add_num()
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 then
            calculation_num_by_index(i)
        end
    end
end

local function update_zb_leave_time(index, value_info)
    local pos_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. index), "Layout")
    local content_panel = tolua.cast(pos_panel:getChildByName("content_panel"), "Layout")
    local num_txt_5 = tolua.cast(content_panel:getChildByName("num_5"), "Label")
    num_txt_5:setText(commonFunc.format_time(value_info.zb_end_time - userData.getServerTime()))
end

local function update_common_content(index, is_update_percent)
    local pos_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. index), "Layout")
    local content_panel = tolua.cast(pos_panel:getChildByName("content_panel"), "Layout")
    local num_txt_1 = tolua.cast(content_panel:getChildByName("num_1"), "Label")
    local num_txt_2 = tolua.cast(content_panel:getChildByName("num_2"), "Label")
    local sign_img = uiUtil.getConvertChildByName(content_panel,"sign_img")
    
    local base_hero_info = Tb_cfg_hero[hero_list_info[index]["hero_cfg_id"]]
    sign_img:loadTexture(ResDefineUtil.img_soldier_type[base_hero_info.hero_type], UI_TEX_TYPE_PLIST)

    local hero_info = heroData.getHeroInfo(hero_list_info[index]["hero_uid"])
    num_txt_1:setText(hero_info.hp)
    num_txt_2:setText("/" .. heroData.getHeroMaxHp(hero_list_info[index]["hero_uid"]))

    local max_txt = tolua.cast(content_panel:getChildByName("max_label"), "Label")
    max_txt:setText("MAX" .. languagePack["maohao"] .. zb_num_list[index]["need_max_num"])
    local num_txt_3 = tolua.cast(content_panel:getChildByName("num_3"), "Label")
    num_txt_3:setText(zb_num_list[index]["cur_num"])

    local temp_loadingbar = tolua.cast(content_panel:getChildByName("loading_bar"), "LoadingBar")
    local temp_slider = tolua.cast(content_panel:getChildByName("slider_content"), "Slider")
    if zb_num_list[index]["need_max_num"] == 0 then
        temp_loadingbar:setPercent(0)
        if is_update_percent then
            temp_slider:setPercent(0)
        end
    else
        temp_loadingbar:setPercent(math.floor(100 * zb_num_list[index]["max_num"]/zb_num_list[index]["need_max_num"]))
        if is_update_percent then
            temp_slider:setPercent(math.floor(100 * zb_num_list[index]["cur_num"]/zb_num_list[index]["need_max_num"]))
        end
    end

    local des_txt_4 = tolua.cast(content_panel:getChildByName("des_4"), "Label")
    local num_txt_5 = tolua.cast(content_panel:getChildByName("num_5"), "Label")
    if is_using_yubeibing then
        des_txt_4:setText(languagePack["yubeibingnotime"])
        num_txt_5:setVisible(false)
    else
        des_txt_4:setText(languagePack["yujishijian"])
        num_txt_5:setText(commonFunc.format_time(addSoldierRequest.getRecruitTime(math.floor(m_army_id/10), hero_info.heroid, zb_num_list[index]["cur_num"])))
        num_txt_5:setVisible(true)
    end
end

local function organize_content_by_index(index, value_info)    
    local pos_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. index), "Layout")
    local zb_img = tolua.cast(pos_panel:getChildByName("zb_img"), "ImageView")
    local hero_img = tolua.cast(pos_panel:getChildByName("hero_img"), "ImageView")
    local hero_widget = tolua.cast(hero_img:getChildByName("hero_icon"), "Layout")
    local content_panel = tolua.cast(pos_panel:getChildByName("content_panel"), "Layout")
    local des_txt_1 = tolua.cast(content_panel:getChildByName("des_1"), "Label")
    local max_txt = tolua.cast(content_panel:getChildByName("max_label"), "Label")
    local des_txt_2 = tolua.cast(content_panel:getChildByName("des_2"), "Label")
    local num_txt_3 = tolua.cast(content_panel:getChildByName("num_3"), "Label")
    local des_txt_4 = tolua.cast(content_panel:getChildByName("des_4"), "Label")
    --local temp_slider = tolua.cast(content_panel:getChildByName("slider_content"), "Slider")
    local zb_txt = tolua.cast(content_panel:getChildByName("zb_sign_label"), "Label")
    local cancel_btn = tolua.cast(content_panel:getChildByName("cancel_btn"), "Button")
    if value_info.zb_state == 1 then
        zb_img:setVisible(true)
        zb_txt:setVisible(true)
        des_txt_1:setText(languagePack["zb_num"])
        max_txt:setVisible(false)
        des_txt_2:setVisible(false)
        num_txt_3:setVisible(false)
        des_txt_4:setText(languagePack["leave_time"])
        cancel_btn:setTouchEnabled(true)
        cancel_btn:setVisible(true)
        --temp_slider:setOpacity(20)
        --temp_slider:setTouchEnabled(false)
        cardFrameInterface.set_hero_state(hero_widget, 3, heroStateDefine.zengbing)

        local num_txt_1 = tolua.cast(content_panel:getChildByName("num_1"), "Label")
        local num_txt_2 = tolua.cast(content_panel:getChildByName("num_2"), "Label")
        local hero_info = heroData.getHeroInfo(value_info.hero_uid)
        num_txt_1:setText(hero_info.hp)
        num_txt_2:setText("+" .. hero_info.hp_adding)
    else
        zb_img:setVisible(false)
        zb_txt:setVisible(false)
        des_txt_1:setText(languagePack["dangqianbingli"])
        max_txt:setVisible(true)
        des_txt_2:setVisible(true)
        num_txt_3:setVisible(true)
        des_txt_4:setText(languagePack["yujishijian"])
        cancel_btn:setTouchEnabled(false)
        cancel_btn:setVisible(false)
        --temp_slider:setOpacity(255)
        --temp_slider:setTouchEnabled(true)
        cardFrameInterface.set_hero_state(hero_widget, 3, 0)
    end
end

local function organize_content_info()
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 then
            organize_content_by_index(i, v)
            if v.zb_state == 1 then
                update_zb_leave_time(i, v)
            else
                update_common_content(i, true)
            end
        end
    end
end

local function zb_update_callback()
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 and v.zb_state == 1 then
            update_zb_leave_time(i, v)
        end
    end
end

local function set_show_info(is_update_percent)
    calculation_can_add_num()
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 then
            if v.zb_state == 0 then
                update_common_content(i, is_update_percent)
            end
        end
    end
    organize_res_info()
end

local function update_percent_change()
    if m_is_need_update then
        set_show_info(false)
        m_is_need_update = false
    end
end

local function deal_with_slider_click(sender, eventType)
    if eventType == SLIDER_PERCENTCHANGED then
        local temp_slider = tolua.cast(sender,"Slider")

        if not armyData.getTeamZbState(m_army_id) then
            local temp_leave_nums, all_queue_num = armyData.get_army_city_zb_queue_num(m_army_id)
            if temp_leave_nums == 0 and (not is_using_yubeibing) then
                temp_slider:setPercent(0)
                tipsLayer.create(errorTable[219])
                return
            end
        end
        
        local new_index = tonumber(string.sub(sender:getParent():getParent():getName(),5))
        if hero_list_info[new_index]["zb_state"] == 0 then
            if zb_num_list[new_index]["need_max_num"] == 0 then
                temp_slider:setPercent(0)
                tipsLayer.create(errorTable[204])
            else
                if zb_num_list[new_index]["max_num"] == 0 then
                    temp_slider:setPercent(0)
                    tipsLayer.create(errorTable[140])
                else
                    local new_percent = temp_slider:getPercent()
                    local temp_max_percent = math.floor(100 * zb_num_list[new_index]["max_num"] / zb_num_list[new_index]["need_max_num"])
                    if new_percent > temp_max_percent then
                        new_percent = temp_max_percent
                        temp_slider:setPercent(new_percent)
                    end

                    local new_num = math.floor(zb_num_list[new_index]["need_max_num"] * new_percent/100)
                    if new_num ~= zb_num_list[new_index]["cur_num"] then
                        zb_num_list[new_index]["cur_num"] = new_num
                        m_is_need_update = true

                        if not update_timer then
                            update_timer = scheduler.create(update_percent_change, 0.3)
                        end
                        --set_show_info(false)
                    end
                end
            end
        else
            temp_slider:setPercent(0)
            tipsLayer.create(errorTable[202])
        end
    end
end

local function play_yb_anim()
    local pos_panel, content_panel, light_img = nil, nil, nil

    if not is_using_yubeibing then
        for i,v in ipairs(hero_list_info) do
            pos_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. i), "Layout")
            content_panel = tolua.cast(pos_panel:getChildByName("content_panel"), "Layout")
            light_img = tolua.cast(content_panel:getChildByName("light_img"), "ImageView")
            light_img:setVisible(false)
        end

        return
    end

    local temp_need_time = 0.5
    local scale_to = CCScaleTo:create(temp_need_time, 1.05)
    for i,v in ipairs(hero_list_info) do
        if v.hero_uid ~= 0 and v.zb_state == 0 then
            pos_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. i), "Layout")
            content_panel = tolua.cast(pos_panel:getChildByName("content_panel"), "Layout")
            light_img = tolua.cast(content_panel:getChildByName("light_img"), "ImageView")
            breathAnimUtil.start_anim(light_img, false, 0, 128, temp_need_time, 1)

            light_img:setScale(1)
            light_img:runAction(tolua.cast(scale_to:copy():autorelease(), "CCActionInterval"))
            light_img:setVisible(true)
        end
    end
end

local function deal_with_yb_click(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        if not m_is_can_use_yb then
            tipsLayer.create(errorTable[309])
            return
        end

        is_using_yubeibing = not is_using_yubeibing
        local yb_cb = tolua.cast(sender:getChildByName("yb_checkbox"), "CheckBox")
        yb_cb:setSelectedState(is_using_yubeibing)

        for i=1,3 do
            zb_num_list[i]["cur_num"] = 0
        end

        set_show_info(true)
        play_yb_anim()
    end 
end

local function init_basic_content_info()
    local pos_panel, zb_img, content_panel, temp_slider, cancel_btn = nil, nil, nil, nil, nil
    local hero_uid = nil
    for i,v in ipairs(hero_list_info) do
        pos_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. i), "Layout")
        zb_img = tolua.cast(pos_panel:getChildByName("zb_img"), "ImageView")
        content_panel = tolua.cast(pos_panel:getChildByName("content_panel"), "Layout")

        if v.hero_uid ~= 0 then
            cancel_btn = tolua.cast(content_panel:getChildByName("cancel_btn"), "Button")
            cancel_btn:addTouchEventListener(deal_with_cancel_click)

            temp_slider = tolua.cast(content_panel:getChildByName("slider_content"), "Slider")
            temp_slider:setTouchEnabled(true)
            temp_slider:addEventListenerSlider(deal_with_slider_click)
        else
            zb_img:setVisible(false)
            content_panel:setVisible(false)
        end
    end

    if not m_is_need_money then
        local consume_panel = tolua.cast(m_main_widget:getChildByName("consume_panel"), "Layout")
        local com_consume = tolua.cast(consume_panel:getChildByName("com_consume"), "Layout")
        local money_consume = tolua.cast(consume_panel:getChildByName("money_consume"), "Layout")
        com_consume:setPositionY(34)
        money_consume:setVisible(false)
    end

    local btn_panel = tolua.cast(m_main_widget:getChildByName("btn_panel"), "Layout")
    local confirm_btn = tolua.cast(btn_panel:getChildByName("confirm_btn"), "Button")
    confirm_btn:setTouchEnabled(true)
    confirm_btn:addTouchEventListener(deal_with_confirm_click)
end


local function set_unhero_content(temp_index)
    local hero_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. temp_index), "Layout")
    local hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
    local unhero_img = tolua.cast(hero_panel:getChildByName("unhero_img"), "ImageView")
    local unopen_type = 0
    local army_index = m_army_id%10
    if temp_index == 3 then
        local army_nums, qianfeng_nums = buildData.get_army_param_info(m_own_city_id)
        if army_index > qianfeng_nums then
            unopen_type = 1
        end
    end

    local first_txt = tolua.cast(unhero_img:getChildByName("unopen_sign"), "Label")
    local second_txt = tolua.cast(unhero_img:getChildByName("unopen_label"), "Label")
    if unopen_type == 0 then
        first_txt:setVisible(false)
        second_txt:setPositionY(0)
        second_txt:setColor(ccc3(166,166,166))
        second_txt:setText(languagePack["weipeizhi"])
    else
        first_txt:setVisible(true)
        second_txt:setPositionY(-14)
        second_txt:setColor(ccc3(207, 72, 75))
        second_txt:setText(Tb_cfg_build[cityBuildDefine.dianjiangtai].name .. "Lv." .. army_index .. languagePack["kaifang"])
    end

    hero_img:setVisible(false)
    unhero_img:setVisible(true)
end

local function set_hero_content(base_widget, temp_index, hero_uid)
    local hero_panel = tolua.cast(m_main_widget:getChildByName("pos_" .. temp_index), "Layout")
    local hero_img = tolua.cast(hero_panel:getChildByName("hero_img"), "ImageView")
    local unhero_img = tolua.cast(hero_panel:getChildByName("unhero_img"), "ImageView")

    local hero_widget = base_widget:clone()
    hero_widget:ignoreAnchorPointForPosition(false)
    hero_widget:setAnchorPoint(cc.p(0.5,0.5))
    hero_widget:setName("hero_icon")
    hero_img:addChild(hero_widget)
    cardFrameInterface.set_small_card_info(hero_widget, hero_uid, heroData.getHeroOriginalId(hero_uid), false)

    hero_img:setVisible(true)
    unhero_img:setVisible(false)
end

local function set_army_icon_by_index(base_widget, temp_index)
    local temp_hero_uid = hero_list_info[temp_index]["hero_uid"]
    if temp_hero_uid == 0 then
        set_unhero_content(temp_index)
    else
        set_hero_content(base_widget, temp_index, temp_hero_uid)
    end
end

local function init_icon_info()
    local base_widget = GUIReader:shareReader():widgetFromJsonFile("test/cardFrameSmall.json")
    for i,v in ipairs(hero_list_info) do
        set_army_icon_by_index(base_widget, i)
    end
end

local function organize_yubeisuo_info()
    local consume_panel = tolua.cast(m_main_widget:getChildByName("consume_panel"), "Layout")
    local yb_img = tolua.cast(consume_panel:getChildByName("yb_img"), "ImageView")
    local current_txt = tolua.cast(yb_img:getChildByName("cur_label"), "Label")
    local sum_txt = tolua.cast(yb_img:getChildByName("sum_label"), "Label")
    local yb_btn = tolua.cast(yb_img:getChildByName("yb_btn"), "Button")
    local content_txt = tolua.cast(yb_btn:getChildByName("content_label"), "Label")

    -- 策划调整需求，预备兵的开放不由预备所控制了，该有募兵所控制；
    -- 募兵所是可以征兵的前提，所以在征兵界面可以打开的情况下募兵所一定有的
    if m_is_can_use_yb then
        yubeisuo_soldier_num = userData.getCityReserveForcesSoldierNum(m_in_city_id)
        current_txt:setText("0")
        sum_txt:setText("/" .. yubeisuo_soldier_num)
        content_txt:setColor(ccc3(83,18,0))
    else
        yubeisuo_soldier_num = 0
        current_txt:setText("---")
        sum_txt:setText("/---")
        yb_btn:setBright(false)
        GraySprite.create(yb_img, {"content_label"})
        content_txt:setColor(ccc3(41,41,41))
    end

    yb_btn:setTouchEnabled(true)
    yb_btn:addTouchEventListener(deal_with_yb_click)
end

local function init_param_info()
    hero_list_info = {}
    zb_num_list = {}
    is_using_yubeibing = false

    local temp_army_info = armyData.getTeamMsg(m_army_id)
    local hero_uid, hero_info = nil, nil
    for i=1,3 do
        hero_list_info[i] = {}
        zb_num_list[i] = {}
        zb_num_list[i]["cur_num"] = 0
        zb_num_list[i]["max_num"] = 0
        zb_num_list[i]["need_max_num"] = 0
        hero_uid = 0
        if i == 1 then
            hero_uid = temp_army_info.base_heroid_u
        elseif i == 2 then
            hero_uid = temp_army_info.middle_heroid_u
        elseif i == 3 then
            hero_uid = temp_army_info.front_heroid_u
        end

        hero_list_info[i]["hero_uid"] = hero_uid
        if hero_uid ~= 0 then
            hero_list_info[i]["hero_cfg_id"] = heroData.getHeroOriginalId(hero_uid)
            hero_info = heroData.getHeroInfo(hero_uid)
            if hero_info.state == cardState.zhengbing then
                hero_list_info[i]["zb_state"] = 1
            else
                hero_list_info[i]["zb_state"] = 0
            end
            hero_list_info[i]["zb_end_time"] = hero_info.hp_end_time
        end
    end

    calculation_can_add_num()
end

local function create()
    m_main_widget = GUIReader:shareReader():widgetFromJsonFile("test/addSoldierUI.json")
    m_main_widget:setTag(999)
    m_main_widget:setScale(config.getgScale())
    m_main_widget:ignoreAnchorPointForPosition(false)
    m_main_widget:setAnchorPoint(cc.p(0.5,0.5))
    m_main_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

    local close_btn = tolua.cast(m_main_widget:getChildByName("close_btn"), "Button")
    close_btn:addTouchEventListener(deal_with_close_click)
    close_btn:setTouchEnabled(true)

    local label_resNotEnough = uiUtil.getConvertChildByName(m_main_widget,"label_resNotEnough")
    label_resNotEnough:setVisible(false)

    init_param_info()
    init_icon_info()
    init_basic_content_info()
    organize_yubeisuo_info()
    organize_content_info()
    organize_res_info()

    card_add_soldier_layer = TouchGroup:create()
    card_add_soldier_layer:addWidget(m_main_widget)
    uiManager.add_panel_to_layer(card_add_soldier_layer, uiIndexDefine.CARD_ADD_SOLDIER)
    uiManager.showConfigEffect(uiIndexDefine.CARD_ADD_SOLDIER, card_add_soldier_layer)

    zb_interval_timer = scheduler.create(zb_update_callback, 1)

    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, cardAddSoldier.dealWithHeroUpdate)

    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, cardAddSoldier.dealWithBuildChange)
    UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, cardAddSoldier.dealWithBuildChange)

    --uiManager.showScaleEffect(card_add_soldier_layer,999,nil,0.3,0.6)
end

--根据ID判断是否可以在城内使用预备兵
local function is_can_use_reserve()
    local temp_city_type = landData.get_city_type_by_id(m_in_city_id)
    if temp_city_type == cityTypeDefine.zhucheng or temp_city_type == cityTypeDefine.fencheng then
        return true
    end

    if temp_city_type == cityTypeDefine.npc_yaosai then
        local temp_city_param = Tb_cfg_world_city[m_in_city_id].param
        if temp_city_param >= NPC_FORT_TYPE_RECRUIT[1] and temp_city_param <= NPC_FORT_TYPE_RECRUIT[2] then
            return true
        end
    end

    return false
end

local function is_need_consume_money()
    local temp_city_type = landData.get_city_type_by_id(m_in_city_id)
    if temp_city_type == cityTypeDefine.zhucheng or temp_city_type == cityTypeDefine.fencheng then
        return false
    end

    return true
end

local function deal_with_enter_guide()
    if armyData.is_need_ybb_guide() then
        if armyData.is_show_ybb_guide_for_army(m_army_id) then
            comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2017)
        end
    end
end

local function on_enter(temp_army_id)
    if card_add_soldier_layer then
        return
    end

    local temp_army_info = armyData.getTeamMsg(temp_army_id)
    if not temp_army_info then
        return
    end

    m_army_id = temp_army_id
    m_own_city_id = math.floor(m_army_id/10)

    if temp_army_info.state == armyState.normal then
        --m_is_in_own_city = true
        m_in_city_id = m_own_city_id
        m_resource_param = 1
    else
        --m_is_in_own_city = false
        m_in_city_id = temp_army_info.target_wid
        local temp_city_lv = landData.get_city_lv_by_id(m_in_city_id)
        if NPC_RECRUIT_REDIF_COST[temp_city_lv] then
            m_resource_param = NPC_RECRUIT_REDIF_COST[temp_city_lv]/100
        else
            m_resource_param = 1
        end
    end

    m_is_can_use_yb = is_can_use_reserve()
    m_is_need_money = is_need_consume_money()

    create()

    deal_with_enter_guide()
end

local function dealWithHeroUpdate(packet)
    if not packet.state then
        return
    end

    for i,v in ipairs(hero_list_info) do
        if v.hero_uid == packet.heroid_u then
            if v.zb_state ~= packet.state then
                v.zb_state = packet.state
                organize_content_by_index(i, v)
                update_common_content(i, true)
                break
            end
        end
    end
end

local function dealWithBuildChange(packet)
    local change_city_id = math.floor(packet.build_id_u/100)
    local change_build_id = packet.build_id_u%100

    if change_city_id == m_own_city_id and change_build_id == cityBuildDefine.dianjiangtai then
        if hero_list_info[3]["hero_uid"] == 0 then
            set_unhero_content(3)
        end
    end
end

local function is_enough_zb_guide(hero_index)
    --return zb_num_list[hero_index]["cur_num"] == zb_num_list[hero_index]["need_max_num"]
    if zb_num_list[hero_index]["cur_num"] > 0 then
        zb_num_list[hero_index]["cur_num"] = zb_num_list[hero_index]["need_max_num"]
        set_show_info(true)
        
        return true
    else
        return false
    end
end

local function get_guide_widget(temp_guide_id)
    if not card_add_soldier_layer then
        return nil
    end

    return card_add_soldier_layer:getWidgetByTag(999)
end

local function get_com_guide_widget(temp_guide_id)
    if not card_add_soldier_layer then
        return nil
    end

    return card_add_soldier_layer:getWidgetByTag(999)
end

cardAddSoldier = {
				on_enter = on_enter,
				remove_self = remove_self,
				showSoldierInfo = showSoldierInfo,
				dealwithTouchEvent = dealwithTouchEvent,
                get_guide_widget = get_guide_widget,
                get_com_guide_widget = get_com_guide_widget,
                is_enough_zb_guide = is_enough_zb_guide,
                dealWithHeroUpdate = dealWithHeroUpdate,
                dealWithBuildChange = dealWithBuildChange
}