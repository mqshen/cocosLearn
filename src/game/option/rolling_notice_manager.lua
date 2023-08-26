--屏幕滚动公告管理器
module("RollingNoticeManager", package.seeall)

local instance = false
local schedulerHandler = nil


local sys_tips_tab = languageBeforeLogin.sys_tips_tab
local user_game_info_tips = languageBeforeLogin.user_game_info_tips
-- 1 系统公告 2 活动公告 3系统提示 4玩家公告
local TYPE_NOTICE_PUBLIC_NOTICE = 1
local TYPE_NOTICE_ACTIVITY_INFO = 2
local TYPE_NOTICE_SYS_TIPS = 3
local TYPE_NOTICE_USER_INFO = 4


-- 记录公告滚动的类型序列 如：
-- 系统公告 --> 系统提示 --> 活动公告 --> 系统提示 --> 系统公告
local tab_rolling_type_order = nil 
local cur_rolling_indx = nil

local notice_from_server = nil
local rolling_noitce_public = nil
local rolling_noitce_activity = nil

local schedulerSecCount = nil


local function updateScheduler()
    schedulerSecCount = schedulerSecCount + 1
    if schedulerSecCount % (math.floor(3600 / LIMIT_ROLLING_NOTICE_PER_H)) == 0 then 
        RollingNoticeManager.playNextNotice()
        schedulerSecCount = 0
    end
    -- 检查是否有新的CD 启动 或者 结束
    for k,notice_info in pairs(notice_from_server) do 
        if notice_info.begin_time == userData.getServerTime() or 
            notice_info.end_time == userData.getServerTime() then 
            RollingNoticeManager.activeScheduler()
        end
    end
end

local function disposeScheduler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
        tab_rolling_type_order = nil
        schedulerSecCount = nil
    end
end


local function isRollingTypeOrderFull()
    local ret = true 
    for i = 1,LIMIT_ROLLING_NOTICE_PER_H do 
        if tab_rolling_type_order[i] == 0 then 
            return false
        end
    end
    return ret
end

local function getRollingTypeOrderEmptyIndx()
    local ret_indx_table = {}
    for i = 1,LIMIT_ROLLING_NOTICE_PER_H do 
        if tab_rolling_type_order[i] == 0 then 
            table.insert(ret_indx_table,i)
        end
    end
    return ret_indx_table
end

local function allocateRollingTypeOrderIndx(emptyIdxTab,noticeType,dataIndx,interval)
    if interval < 0 then return end
    if interval >= #emptyIdxTab then 
        interval = #emptyIdxTab 
        for k,indx in ipairs(emptyIdxTab) do 
            tab_rolling_type_order[indx] = {
                notice_type = noticeType,
                data_indx = dataIndx
            }
        end
        return 
    end

    local cell_split = math.ceil(#emptyIdxTab/interval)
    local allocated_count = 0
    for i = 1,#emptyIdxTab, cell_split do 
        tab_rolling_type_order[emptyIdxTab[i]] ={
            notice_type = noticeType,
            data_indx = dataIndx
        }
        allocated_count = allocated_count + 1
    end

    if allocated_count < interval then 
        allocateRollingTypeOrderIndx(
            getRollingTypeOrderEmptyIndx(),
            noticeType,
            dataIndx,
            interval - allocated_count
        )
    end
end


-- 初始化类型序列
local function initRollingTypeOrder()
    tab_rolling_type_order = {}
    for i = 1,LIMIT_ROLLING_NOTICE_PER_H do 
        tab_rolling_type_order[i] = 0
    end
    cur_rolling_indx = 1

    
    local notice_info = nil
    if rolling_noitce_public and #rolling_noitce_public > 0 then 
        -- 插入系统公告
        for k = 1,#rolling_noitce_public do
            notice_info = rolling_noitce_public[k]
            if notice_info.end_time == 0  or 
             (notice_info.begin_time < userData.getServerTime() and notice_info.end_time>userData.getServerTime() )then 
                allocateRollingTypeOrderIndx(
                    getRollingTypeOrderEmptyIndx(),
                    TYPE_NOTICE_PUBLIC_NOTICE,
                    k,
                    notice_info.interval
                )
            end
        end
    end

   
    
    if isRollingTypeOrderFull() then return end
    -- 插入活动公告
    if rolling_noitce_activity and #rolling_noitce_activity > 0 then 
        for k = 1,#rolling_noitce_activity  do
            notice_info = rolling_noitce_activity[k] 
            if notice_info.end_time == 0 or
            (notice_info.begin_time < userData.getServerTime() and notice_info.end_time>userData.getServerTime())  then  
                allocateRollingTypeOrderIndx(
                    getRollingTypeOrderEmptyIndx(),
                    TYPE_NOTICE_ACTIVITY_INFO,
                    k,
                    notice_info.interval
                )
            end
        end
    end
    
   
    if isRollingTypeOrderFull() then return end
    -- for k,v in ipairs(tab_rolling_type_order) do 
    --     if tab_rolling_type_order[k] == 0 then 
    --         tab_rolling_type_order[k] = {
    --             notice_type = TYPE_NOTICE_SYS_TIPS,
    --             data_indx = 1
    --         }
    --     end
    -- end
    allocateRollingTypeOrderIndx(
        getRollingTypeOrderEmptyIndx(),
        TYPE_NOTICE_SYS_TIPS,
        1,
        LIMIT_ROLLING_NOTICE_SYS_PER_H
    )

end

function activeScheduler()
    disposeScheduler()
    initRollingTypeOrder()
    schedulerSecCount = 0
    schedulerHandler = scheduler.create(updateScheduler,1)
end

local function preHandleRichText(cfgContent)
    return cfgContent
    -- local subCfgContent = nil
    -- while cfgContent:match("{.-}")  do
    --     subCfgContent = cfgContent:match("{.-}") 
    --     subCfgContent = string.gsub(subCfgContent,"{","")
    --     subCfgContent = string.gsub(subCfgContent,"}","")
    --     cfgContent = string.gsub(cfgContent,"{" .. subCfgContent .. "}","#@" .. subCfgContent .. "@#")
    -- end 

    -- cfgContent = "#" .. cfgContent .. "#"
    -- return cfgContent
end
function playNextNotice()
    if not instance then return end
    
    if cur_rolling_indx >= LIMIT_ROLLING_NOTICE_PER_H then 
        cur_rolling_indx = 0
    end

    local notice_info = tab_rolling_type_order[cur_rolling_indx]
    if notice_info == 0 then 
        -- 该位置没有安排公告
    elseif notice_info and notice_info.notice_type == TYPE_NOTICE_PUBLIC_NOTICE then 
        -- 播放系统公告
        MainScreenNotification.create(preHandleRichText( rolling_noitce_public[notice_info.data_indx].notice ) )
    elseif notice_info and notice_info.notice_type == TYPE_NOTICE_ACTIVITY_INFO then 
        -- 播放活动公告
        MainScreenNotification.create(preHandleRichText( rolling_noitce_activity[notice_info.data_indx].notice) )
    elseif notice_info and notice_info.notice_type == TYPE_NOTICE_SYS_TIPS then 
        -- 播放系统提示
        -- math.randomseed(os.time())
        local sys_tips_idx = math.random(#sys_tips_tab)
        MainScreenNotification.create( preHandleRichText( sys_tips_tab[sys_tips_idx]) )
    end
    cur_rolling_indx = cur_rolling_indx + 1

end

-- 目前只有玩家公告会推送
local function receiveNoticeFromServer(packet)

    -- 玩家公告直接播放
    local indx = packet[1] + 1
    local arg = {}
    for i = 2,#packet do 
        table.insert(arg,packet[i])
    end
    MainScreenNotification.create( preHandleRichText(user_game_info_tips[indx]) ,arg)
end

function remove()
    if instance then 
        disposeScheduler()
        netObserver.removeObserver(NOTIFY_SEND_NOTICE)

        instance = nil
    end
end

-- 游戏一启动一直存在
function create()
    if instance then return end
    instance = true
    netObserver.addObserver(NOTIFY_SEND_NOTICE, receiveNoticeFromServer)
    -- 启动公告轮询
    activeScheduler()
    playNextNotice()
end






-- 只从服务器接收 系统公告 和 活动公告
function receiveRollingNoitceFromServer(packet)
    local notice_info = nil
    notice_from_server = {}
    -- notice_subtype 只接收 1,2 其他类型不接收
    rolling_noitce_public = {}
    for k,v in pairs(packet) do 
        if v[5] == TYPE_NOTICE_PUBLIC_NOTICE then
            notice_info = {}
            notice_info.begin_time = v[1]
            notice_info.end_time = v[2]
            notice_info.notice = v[3]
            notice_info.priority = v[4]
            notice_info.subtype = v[5]
            notice_info.interval = v[6]
            if notice_info.interval <= 0 then 
                notice_info.interval = 1
            end
            table.insert(rolling_noitce_public,notice_info)
            table.insert(notice_from_server,notice_info)
        end
    end
    rolling_noitce_activity = {}
    for k,v in pairs(packet) do 
        if v[5] == TYPE_NOTICE_ACTIVITY_INFO then
            notice_info = {}
            notice_info.begin_time = v[1]
            notice_info.end_time = v[2]
            notice_info.notice = v[3]
            notice_info.priority = v[4]
            notice_info.subtype = v[5]
            notice_info.interval = v[6]
            if notice_info.interval <= 0 then 
                notice_info.interval = 1
            end
            table.insert(notice_from_server,notice_info)
            table.insert(rolling_noitce_activity,notice_info)
        end
    end


    -- priority 数字越大 优先级越高
    -- interval 越大越靠前
    -- begin_time 为0 立马显示
    -- end_time 为0 永久存在
    local function sortRuler(na,nb)
        if na.priority > nb.priority then 
            return true
        end

        if na.interval > nb.interval then 
            return true
        end

        return false
    end

    table.sort( rolling_noitce_public, sortRuler )
    table.sort( rolling_noitce_activity, sortRuler )


    
end