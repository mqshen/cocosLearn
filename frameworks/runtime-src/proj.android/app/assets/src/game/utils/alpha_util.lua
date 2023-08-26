local m_index = nil
local m_interval = nil
local m_init_or_not = nil

local m_anim_list = nil
local m_timer = nil

local function remove()
    if m_timer then
        scheduler.remove(m_timer)
        m_timer = nil
    end

    m_index = nil
    m_interval = nil
    m_anim_list = nil
    m_init_or_not = nil
end

local function init_param_info()
    m_index = 0
    m_interval = 0.1
end

local function remove_alpha_anim(temp_index)
    if not m_anim_list then
        return
    end

    if m_anim_list[temp_index] then
        m_anim_list[temp_index] = nil
    end
end

local function update_action()
    local temp_finish_list = {}
    for k,v in pairs(m_anim_list) do
        if v.current_phase == 1 then
            v.current_alpha = v.current_alpha - v.change_range
            if v.current_alpha <= v.min_alpha then
                v.current_alpha = v.min_alpha
                v.current_phase = 0
                v.current_num = v.current_num + 1
            end
        else
            v.current_alpha = v.current_alpha + v.change_range
            if v.current_alpha >= v.max_alpha then
                v.current_alpha = v.max_alpha
                v.current_phase = 1
                v.current_num = v.current_num + 1
            end
        end
        v["change_obj"]:setOpacity(v.current_alpha)

        if v.repeat_nums ~= 0 and v.current_num >= v.repeat_nums then
            table.insert(temp_finish_list, k)
        end
    end

    for kk,vv in pairs(temp_finish_list) do
        remove_alpha_anim(vv)
    end
end

local function add_alpha_anim(temp_obj, is_init_max, min_alpha, max_alpha, change_time, repeat_num)
    if min_alpha >= max_alpha then
        return
    end

    if not m_init_or_not then
        init_param_info()
        m_init_or_not = true
    end

    if not m_anim_list then
        m_anim_list = {}
    end

    local temp_list = {}
    temp_list["change_obj"] = temp_obj
    temp_list["min_alpha"] = min_alpha
    temp_list["max_alpha"] = max_alpha
    temp_list["repeat_nums"] = repeat_num
    temp_list["current_num"] = 0
    local temp_range = math.floor((max_alpha - min_alpha)/(change_time/m_interval))
    if temp_range == 0 then
        temp_range = 1
    end
    temp_list["change_range"] = temp_range
    if is_init_max then
        temp_list["current_alpha"] = max_alpha
        temp_list["current_phase"] = 1
        temp_obj:setOpacity(max_alpha)
    else
        temp_list["current_alpha"] = min_alpha
        temp_list["current_phase"] = 0
        temp_obj:setOpacity(min_alpha)
    end

    m_index = m_index + 1
    m_anim_list[m_index] = temp_list

    if not m_timer then
        m_timer = scheduler.create(update_action, m_interval)
    end

    return m_index
end

alphaUtil = {
                remove = remove,
                add_alpha_anim = add_alpha_anim,
                remove_alpha_anim = remove_alpha_anim
}