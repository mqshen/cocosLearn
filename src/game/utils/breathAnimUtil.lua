local function start_anim(temp_obj, is_init_max, min_alpha, max_alpha, change_time, repeat_num, temp_tag)
	if min_alpha < 0 or min_alpha > 255 then
        return
    end

    if max_alpha < 0 or max_alpha > 255 then
        return
    end

    if min_alpha >= max_alpha then
        return
    end

    if change_time <= 0 then
        return
    end

    if repeat_num < 0 then
        return
    end

    local temp_seq = nil
    if is_init_max then
    	temp_obj:setOpacity(max_alpha)
    	temp_seq = cc.Sequence:createWithTwoActions(
    		CCFadeTo:create(change_time, min_alpha), 
    		CCFadeTo:create(change_time, max_alpha))
    else
    	temp_obj:setOpacity(min_alpha)
    	temp_seq = cc.Sequence:createWithTwoActions(
    		CCFadeTo:create(change_time, max_alpha), 
    		CCFadeTo:create(change_time, min_alpha))
    end

    local temp_action = nil
    if repeat_num == 0 then
    	temp_action = CCRepeatForever:create(temp_seq)
    else
    	temp_action = CCRepeat:create(temp_seq, repeat_num)
    end

    if temp_tag then
    	temp_action:setTag(temp_tag)
    end
    temp_obj:runAction(temp_action)
end

local function stop_action_by_tag(temp_obj, temp_tag)
	temp_obj:stopActionByTag(temp_tag)
end

local function stop_all_anim(temp_obj)
	temp_obj:stopAllActions()
end


--可滑动界面的方向按钮需要加入呼吸动画，为了统一调整变化节奏，所以这个函数存在
local function start_scroll_dir_anim(up_img, down_img)
    start_anim(up_img, true, 76, 255, 1, 0)
    start_anim(down_img, true, 76, 255, 1, 0)
end

local function stop_scroll_dir_anim(up_img, down_img)
    stop_all_anim(up_img)
    stop_all_anim(down_img)
end

breathAnimUtil = {
					start_anim = start_anim,
					stop_all_anim = stop_all_anim,
					stop_action_by_tag = stop_action_by_tag,
                    start_scroll_dir_anim = start_scroll_dir_anim,
                    stop_scroll_dir_anim = stop_scroll_dir_anim
}