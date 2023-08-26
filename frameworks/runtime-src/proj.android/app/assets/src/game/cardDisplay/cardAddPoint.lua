local hero_uid = nil

local change_timer = nil        --长按+-时处理持续加减点
local change_state_sign = nil     --当前是加点还是减点(0 普通状态；1 减点状态； 2 加点状态)
local last_selected_index = nil --当前正在处理的属性索引 0 普通状态
local is_keep_change = nil       --指引过程中不允许按下持续触发加点操作

local all_leave_point = nil     --剩余可以加的点数
local old_prop_list = nil       --需要显示的属性当前值
local added_point_list = nil    --已经加的点数
local temp_add_point = nil      --临时增加点数（也就是本次操作加减造成的部分）
local grow_up_list = nil        --各个属性测的成长值

local POINT_COLOR_DEFAULT = ccc3(255,255,255)
local POINT_COLOR_TEMP = ccc3(147,255,147)
local POINT_COLOR_ADDED = ccc3(244,202,101)



local INSTANCE_TAG = 400
local instance = nil

local function do_remove_self()
	if instance then
        if change_timer then
            scheduler.remove(change_timer)
            change_timer = nil
        end
        

        change_state_sign = nil
        last_selected_index = nil
        is_keep_change = nil

		instance:removeFromParentAndCleanup(true)
		instance = nil
		hero_uid = nil

		all_leave_point = nil
        old_prop_list = nil
        added_point_list = nil
		temp_add_point = nil
        grow_up_list = nil

        UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, cardAddPoint.dealWithCardUpdate)

	end
end
local function remove_self(isNeedEffect)
    if not instance then return end
    if isNeedEffect then 
        local actionMove = CCMoveTo:create(0.2,ccp(instance:getContentSize().width * 2,instance:getPositionY()))
        local finally = cc.CallFunc:create(function ( )
            do_remove_self()
        end)
        instance:runAction(animation.sequence({actionMove,finally}))
    else
        do_remove_self()
    end
end



local function updatePointShowColor(index,state)
    if not index then return end
    if index < 1 then return end
    if index > 4 then return end
    if not instance then return end

    local prop_change_panel = uiUtil.getConvertChildByName(instance,"prop_panel_" .. index)

    local new_prop_txt = uiUtil.getConvertChildByName(prop_change_panel,"value_label_2")
    local temp_adding_txt = uiUtil.getConvertChildByName(prop_change_panel,"add_label")

    if state == 0 then 
        --默认
        new_prop_txt:setColor(POINT_COLOR_DEFAULT)
        temp_adding_txt:setColor(POINT_COLOR_DEFAULT)
    elseif state == 1 then 
        --临时
        new_prop_txt:setColor(POINT_COLOR_TEMP)
        temp_adding_txt:setColor(POINT_COLOR_TEMP)
    elseif state == 2 then 
        --已加过了
        new_prop_txt:setColor(POINT_COLOR_ADDED)
        temp_adding_txt:setColor(POINT_COLOR_ADDED)
    end
end
local function resetPointColorDefault(isWash)
    for indx = 1, 4 do 
        if isWash then 
            updatePointShowColor(indx,0)
        else
            if (added_point_list[indx] + temp_add_point[indx]) > 0 then 
                updatePointShowColor(indx,2)
            else
                updatePointShowColor(indx,0)
            end
        end
    end
end

local function updatePlusAndAddBtnsBrightState(index,isAddBright,isPlusBright)
    if not index then return end
    if index < 1 then return end
    if index > 4 then return end
    if not instance then return end

    local btn_flag = nil

    local prop_change_panel = uiUtil.getConvertChildByName(instance,"prop_panel_" .. index)

    local temp_dec_btn = uiUtil.getConvertChildByName(prop_change_panel,"dec_btn")
    local temp_add_btn = uiUtil.getConvertChildByName(prop_change_panel,"add_btn")

    btn_flag = uiUtil.getConvertChildByName(temp_dec_btn,"btn_flag")
    btn_flag:setBright(isPlusBright)
    temp_dec_btn:setBright(isPlusBright)

    btn_flag = uiUtil.getConvertChildByName(temp_add_btn,"btn_flag")
    btn_flag:setBright(isAddBright)
    temp_add_btn:setBright(isAddBright)

    
end
local function updateClearAndConfirmBtnsBrightState(isOperated)
    -- 如果没开始操作 清除和确认按钮 都灰态显示
    if not instance then return end

    
    local confirm_btn = uiUtil.getConvertChildByName(instance,"confirm_btn")
    confirm_btn:setBright(isOperated)
    
end

local function set_keep_state(new_state)
    if instance then
        is_keep_change = new_state
    end
end

local function set_op_state(is_operate)
    if not instance then
        return
    end

    local confirm_btn = tolua.cast(instance:getChildByName("confirm_btn"), "Button")
    confirm_btn:setTouchEnabled(is_operate)
end

local function deal_with_return_click(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then
		--remove_self()
	end
end

local function deal_with_close_click(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        remove_self()
    end
end

local function deal_with_clear_click(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        if temp_add_point[1] ~= 0 or temp_add_point[2] ~= 0 or temp_add_point[3] ~= 0 or temp_add_point[4] ~= 0 then
            cardAddPoint.reload_data()
            resetPointColorDefault()
        else
            tipsLayer.create(errorTable[170])
        end
    end
end

local function deal_with_wash_event()

    local hero_info = heroData.getHeroInfo(hero_uid)
    local free_wash_time = hero_info.clean_point_time
    if free_wash_time == 0 or (free_wash_time + HERO_CLEAN_POINTS_COOL_DOWN_TIME) < userData.getServerTime() then
        cardOpRequest.request_wash_point(hero_uid, consumeType.common_money)
    else
        cardOpRequest.request_wash_point(hero_uid, consumeType.yuanbao)
    end

    resetPointColorDefault(true)
end




local function deal_with_wash_click(sender, eventType)
    if eventType == TOUCH_EVENT_ENDED then
        local hero_info = heroData.getHeroInfo(hero_uid)
        if hero_info.level < 15 then
            tipsLayer.create(errorTable[175])
            return
        end
        if added_point_list[1] == 0 and added_point_list[2] == 0 and added_point_list[3] == 0 and added_point_list[4] == 0 then
            tipsLayer.create(errorTable[163])
            return
        end

        require("game/cardDisplay/cardWashPointConfirm")
        cardWashPointConfirm.create(hero_uid,deal_with_wash_event) 
    end
end

local function send_add_point_plan(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if temp_add_point[1] ~= 0 or temp_add_point[2] ~= 0 or temp_add_point[3] ~= 0 or temp_add_point[4] ~= 0 then
           
            resetPointColorDefault()
            cardOpRequest.request_add_point(hero_uid, temp_add_point[1], temp_add_point[2], temp_add_point[3], temp_add_point[4])
            set_op_state(false)

        else
            tipsLayer.create(errorTable[171])
        end
	end
end

local function init_param_info()
    local hero_info = heroData.getHeroInfo(hero_uid)
    local basic_hero_info = Tb_cfg_hero[hero_info.heroid]

    all_leave_point = hero_info.point_left
    temp_add_point = {0,0,0,0}
    old_prop_list = {}
    added_point_list = {}
    grow_up_list = {}

    local growup_num, had_add_num, show_value = 0
    for i=1,4 do
        if i == heroPorpDefine.attack then
            growup_num = basic_hero_info.attack_grow
            had_add_num = hero_info.attack_add - (hero_info.level - 1) * growup_num
            show_value = basic_hero_info.attack_base + hero_info.attack_add
        elseif i == heroPorpDefine.defence then
            growup_num = basic_hero_info.defence_grow
            had_add_num = hero_info.defence_add - (hero_info.level - 1) * growup_num
            show_value = basic_hero_info.defence_base + hero_info.defence_add
        elseif i == heroPorpDefine.intel then
            growup_num = basic_hero_info.intel_grow
            had_add_num = hero_info.intel_add - (hero_info.level - 1) * growup_num
            show_value = basic_hero_info.intel_base + hero_info.intel_add
        elseif i == heroPorpDefine.speed then
            growup_num = basic_hero_info.speed_grow
            had_add_num = hero_info.speed_add - (hero_info.level - 1) * growup_num
            show_value = basic_hero_info.speed_base + hero_info.speed_add
        end

        growup_num = growup_num/100
        show_value = show_value/100

        had_add_num = had_add_num / 100
        
        table.insert(old_prop_list, show_value)
        table.insert(added_point_list, had_add_num)
        table.insert(grow_up_list, growup_num)
    end
end


local function create(parent,callback)
	
    if instance then return end

    instance = GUIReader:shareReader():widgetFromJsonFile("test/addPointUI.json")
    instance:ignoreAnchorPointForPosition(false)
    instance:setAnchorPoint(cc.p(0,0))
    instance:setPosition(cc.p(0,0))
    parent:addChild(instance)
    instance:setTag(INSTANCE_TAG)
    
    



    last_selected_index = 0
    change_state_sign = 0
    is_keep_change = true

	local hero_info = heroData.getHeroInfo(hero_uid)
    local basic_hero_info = Tb_cfg_hero[hero_info.heroid]

	

    init_param_info()
    --具体数据信息面板
    local leave_point_txt = tolua.cast(instance:getChildByName("sum_point_label"), "Label")
    for i=1,4 do
    	local prop_change_panel = tolua.cast(instance:getChildByName("prop_panel_" .. i), "Layout")
        local new_prop_txt = tolua.cast(prop_change_panel:getChildByName("value_label_2"), "Label")
    	local temp_adding_txt = tolua.cast(prop_change_panel:getChildByName("add_label"), "Label")

        local temp_dec_btn = tolua.cast(prop_change_panel:getChildByName("dec_btn"), "Button")
        local temp_add_btn = tolua.cast(prop_change_panel:getChildByName("add_btn"), "Button")

        local function deal_with_dec_click(sender, eventType)
            if change_state_sign == 2 then
                return
            end

            local function dec_callback()
                if temp_add_point[i] < 1 then 
                    tipsLayer.create(errorTable[176])
                    return
                end
                if temp_add_point[i] > 0 and sender:isFocused() then
                    temp_add_point[i] = temp_add_point[i] - 1
                    all_leave_point = all_leave_point + 1
                    
                    leave_point_txt:setText(tostring(all_leave_point))
                    -- new_prop_txt:setText(tostring(old_prop_list[i] + grow_up_list[i] * temp_add_point[i]))
                    temp_adding_txt:setText("+" .. (added_point_list[i] + temp_add_point[i]))
                    new_prop_txt:setText(tostring(old_prop_list[i] + temp_add_point[i]))
                    -- temp_adding_txt:setText("+" .. temp_add_point[i])
                end
                updateClearAndConfirmBtnsBrightState(true)
                for indx = 1 ,4 do 
                    updatePlusAndAddBtnsBrightState(indx,all_leave_point > 0,temp_add_point[indx] > 0)    
                end

                if temp_add_point[i] > 0 then 
                    updatePointShowColor(i,1)
                else
                    if added_point_list[i] > 0 then 
                        updatePointShowColor(i,2)
                    else
                        updatePointShowColor(i,0)
                    end
                end
            end

            if eventType == TOUCH_EVENT_BEGAN then
                if not change_timer then
                    change_timer = scheduler.create(dec_callback, 0.1)
                    change_state_sign = 1
                    last_selected_index = i
                    dec_callback()
                end
            elseif eventType == TOUCH_EVENT_CANCELED or eventType == TOUCH_EVENT_ENDED then
                if last_selected_index == i and change_timer then
                    scheduler.remove(change_timer)
                    change_timer = nil
                    change_state_sign = 0
                    last_selected_index = 0
                end
            end
        end
    	
        local function deal_with_add_click(sender,eventType)
            if change_state_sign == 1 then
                return
            end

            local function add_callback()
                if all_leave_point < 1 then 
					if basic_hero_info.sex == 0 then 
                    	tipsLayer.create(errorTable[177])
					else
						tipsLayer.create(errorTable[2035])
					end
                    return 
                end
                if all_leave_point > 0 and sender:isFocused() then
                    if not is_keep_change then
                        if temp_add_point[i] > 0 then
                            return 
                        end
                    end
                    temp_add_point[i] = temp_add_point[i] + 1
                    all_leave_point = all_leave_point - 1
                    
                    leave_point_txt:setText(tostring(all_leave_point))
                    temp_adding_txt:setText("+" .. (added_point_list[i] + temp_add_point[i]))
                    new_prop_txt:setText(tostring(old_prop_list[i] + temp_add_point[i]))
                end
                updateClearAndConfirmBtnsBrightState(true)
                for indx = 1 ,4 do 
                    updatePlusAndAddBtnsBrightState(indx,all_leave_point > 0,temp_add_point[indx] > 0)    
                end
                if temp_add_point[i] > 0 then 
                    updatePointShowColor(i,1)
                else
                    if added_point_list[i] > 0 then 
                        updatePointShowColor(i,2)
                    else
                        updatePointShowColor(i,0)
                    end
                end
            end

            if eventType == TOUCH_EVENT_BEGAN then
                if not change_timer then
                    change_timer = scheduler.create(add_callback, 0.1)
                    change_state_sign = 2
                    last_selected_index = i
                    add_callback()
                end
            elseif eventType == TOUCH_EVENT_CANCELED or eventType == TOUCH_EVENT_ENDED then
                if last_selected_index == i and change_timer then
                    scheduler.remove(change_timer)
                    change_timer = nil
                    change_state_sign = 0
                    last_selected_index = 0
                end
            end
        end

    	
    	
    	temp_dec_btn:addTouchEventListener(deal_with_dec_click)
    	temp_add_btn:addTouchEventListener(deal_with_add_click)
        temp_dec_btn:setTouchEnabled(true)
        temp_add_btn:setTouchEnabled(true)
        
    end

   
    local btn_return = uiUtil.getConvertChildByName(instance,"btn_return")
    btn_return:setTouchEnabled(true)
    btn_return:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self(true)
            if callback then 
                callback()
            end
        end
    end)

    local wash_btn = tolua.cast(instance:getChildByName("wash_btn"), "Button")
    wash_btn:addTouchEventListener(deal_with_wash_click)
    -- or hero_info.level < 15
    if not hero_info  then 
        wash_btn:setTouchEnabled(false)
        wash_btn:setVisible(false)
    else
        wash_btn:setTouchEnabled(true)
        wash_btn:setVisible(true)
    end
    local confirm_btn = tolua.cast(instance:getChildByName("confirm_btn"), "Button")
   -- confirm_btn:setTouchEnabled(true)
    confirm_btn:addTouchEventListener(send_add_point_plan)


	local btn_tips = uiUtil.getConvertChildByName(instance,"btn_tips")
	btn_tips:setTouchEnabled(true)
	btn_tips:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			alertLayer.create(errorTable[2040])
		end
	end)
end

local function reload_data()
    if not instance then
        return
    end

    local hero_info = heroData.getHeroInfo(hero_uid)
    local basic_hero_info = Tb_cfg_hero[hero_info.heroid]

    init_param_info()


    --具体数据信息面板

    local leave_point_txt = tolua.cast(instance:getChildByName("sum_point_label"), "Label")
    leave_point_txt:setText(tostring(all_leave_point))

    local prop_change_panel, temp_growup_txt, prop_txt_1, prop_txt_2, temp_adding_txt = nil, nil, nil, nil, nil
    for i=1,4 do
        prop_change_panel = tolua.cast(instance:getChildByName("prop_panel_" .. i), "Layout")
        -- temp_growup_txt = tolua.cast(prop_change_panel:getChildByName("growup_txt"), "Label")
        prop_txt_1 = tolua.cast(prop_change_panel:getChildByName("value_label_1"), "Label")
        prop_txt_2 = tolua.cast(prop_change_panel:getChildByName("value_label_2"), "Label")
        temp_adding_txt = tolua.cast(prop_change_panel:getChildByName("add_label"), "Label")
        
        -- temp_growup_txt:setText(grow_up_list[i])
        prop_txt_1:setText(tostring(old_prop_list[i]))
        -- prop_txt_2:setText(tostring(old_prop_list[i] + grow_up_list[i] * temp_add_point[i]))
        temp_adding_txt:setText("+" .. (added_point_list[i] + temp_add_point[i]))
        prop_txt_2:setText(tostring(old_prop_list[i] + temp_add_point[i]))
        -- temp_adding_txt:setText("+" .. temp_add_point[i])
    end

    set_op_state(true)

    updateClearAndConfirmBtnsBrightState(false)
    if hero_info.point_left > 0 then 
        updatePlusAndAddBtnsBrightState(1,true,false)
        updatePlusAndAddBtnsBrightState(2,true,false)
        updatePlusAndAddBtnsBrightState(3,true,false)
        updatePlusAndAddBtnsBrightState(4,true,false)
    else
        updatePlusAndAddBtnsBrightState(1,false,false)
        updatePlusAndAddBtnsBrightState(2,false,false)
        updatePlusAndAddBtnsBrightState(3,false,false)
        updatePlusAndAddBtnsBrightState(4,false,false)
    end

    
end

local function showPointInfo(new_uid,parent,callback)
    local hero_info = heroData.getHeroInfo(new_uid)
    if not hero_info then
        return
    end

    if instance then
        remove_self()
    end

    hero_uid = new_uid
    create(parent,callback)
    reload_data()
    resetPointColorDefault()

    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, cardAddPoint.dealWithCardUpdate)

    instance:setPositionX(instance:getContentSize().width)
    local actionMove = CCMoveTo:create(0.2,ccp(0,instance:getPositionY()))
    local finally = cc.CallFunc:create(function ( )
        instance:setVisible(true)
    end)
    instance:runAction(animation.sequence({actionMove,finally}))

end

local function dealWithCardUpdate(packet)
    if packet.heroid_u == hero_uid then
        reload_data()
    end
end

local function checkNonforceGuide()
    if not instance then return end
    if all_leave_point <= 0 then return end
    if (not CCUserDefault:sharedUserDefault():getBoolForKey("first_open_wash_point") ) then 
        CCUserDefault:sharedUserDefault():setBoolForKey("first_open_wash_point",true)
        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2037)
    end
end
cardAddPoint = {
	create = create,
	remove_self = remove_self,
    reload_data = reload_data,
	showPointInfo = showPointInfo,
	dealwithTouchEvent = dealwithTouchEvent,
    set_keep_state = set_keep_state,
    checkNonforceGuide = checkNonforceGuide,
}
