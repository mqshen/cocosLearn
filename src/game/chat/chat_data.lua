module("ChatData",package.seeall)

ChatData.CHANNEL_INDX_WORLD = 1         -- 世界频道
ChatData.CHANNEL_INDX_REGION = 2        -- 州频道
ChatData.CHANNEL_INDX_UNION = 3         -- 同盟频道
ChatData.CHANNEL_INDX_SYS = 4           -- 系统事件




-- Object[] arr = new Object[]{iChatType,iChatSubtype, iUserId, tbUser.name, strMsg, iNow, iRegion, strUnionName, iUnionId,param};
-- 正常信息
ChatData.CHAT_SUB_TYPE_NORMAL = 0
-- 语音信息 param = {voice_file_name,md5_key,voice_seconds}
ChatData.CHAT_SUB_TYPE_VOICE = 1
-- 占领城池 （附带占领信息）param = {npc_wid,union_id,union_name,kill_max_name,duribility_max_name,is_first} 
ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_NPCCITY = 2
-- 同盟沦陷 （附带附属信息）param = {attack_union_id,attack_union_name,defend_union_id,defend_union_name,attack_finnaly_user_id,attack_finnaly_user_name}
ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_UNION = 3
-- 同盟相关的正常信息（附带同盟信息）param = {union_id,union_name}
ChatData.CHAT_SUB_TYPE_UNION_INFO = 4
-- 个人被沦陷信息
ChatData.CHAT_SUB_TYPE_OCCUPIED = 5
-- 个人脱离沦陷信息
ChatData.CHAT_SUB_TYPE_DE_OCCUPIED = 6
-- 个人被攻击信息
ChatData.CHAT_SUB_TYPE_ATTACK = 7

ChatData.CHAT_SUB_TYPE_SYS = 8



ChatData.CHANNEL_WORLD_SUBTYPE_NROMAL = ChatData.CHAT_SUB_TYPE_NORMAL 				

ChatData.CHANNEL_WORLD_SUBTYPE_OCCUPY_NPCCITY = ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_NPCCITY 		

ChatData.CHANNEL_WORLD_SUBTYPE_OCCUPY_UNION = ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_UNION	

ChatData.CHANNEL_WORLD_SUBTYPE_UNION_INFO_NORMAL = ChatData.CHAT_SUB_TYPE_UNION_INFO	 
ChatData.CHANNEL_WORLD_SUBTYPE_VOICE = ChatData.CHAT_SUB_TYPE_VOICE


ChatData.CHANNEL_UNION_SUBTYPE_NORMAL = ChatData.CHAT_SUB_TYPE_NORMAL
ChatData.CHANNEL_UNION_SUBTYPE_VOICE = ChatData.CHAT_SUB_TYPE_VOICE

ChatData.CHANNEL_REGION_SUBTYPE_NORMAL = ChatData.CHAT_SUB_TYPE_NORMAL
ChatData.CHANNEL_REGION_SUBTYPE_VOICE = ChatData.CHAT_SUB_TYPE_VOICE


ChatData.CHANNEL_CACHE_MAX = {}
ChatData.CHANNEL_CACHE_MAX[ChatData.CHANNEL_INDX_WORLD] = 100
ChatData.CHANNEL_CACHE_MAX[ChatData.CHANNEL_INDX_REGION] = 100
ChatData.CHANNEL_CACHE_MAX[ChatData.CHANNEL_INDX_UNION] = 100
ChatData.CHANNEL_CACHE_MAX[ChatData.CHANNEL_INDX_SYS] = 100

ChatData.CHANNEL_FREE_CHAT_COUNT_WORLD = CHAT_WORLD_CHANNEL_COUNT_DAILY


local chat_unread_num = nil
local chat_data = nil

local chat_last_timestamp = nil
local chat_free_count_left = nil
local chat_cost_gold = nil


local function convertSubTypeParam(channel_id,subType,param)
	if not param then return {} end
	
	local ret = {}
	if subType == ChatData.CHAT_SUB_TYPE_NORMAL then
        ret = {}
    elseif subType == ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_NPCCITY then
        ret.npc_wid = param[1]
        ret.union_id = param[2]
        ret.union_name = param[3]
        ret.kill_max_name = param[4]
        ret.duribility_max_name = param[5]
        ret.is_first = param[6]
    elseif subType == ChatData.CHAT_SUB_TYPE_UNION_OCCUPY_UNION then
        ret.attack_union_id = param[1]
        ret.attack_union_name = param[2]
        ret.defend_union_id = param[3]
        ret.defend_union_name = param[4]
        ret.attack_finnaly_user_id = param[5]
        ret.attack_finnaly_user_name = param[6]
    elseif subType == ChatData.CHAT_SUB_TYPE_UNION_INFO then
        ret.union_id = param[1]
        ret.union_name = param[2]
    elseif subType == ChatData.CHAT_SUB_TYPE_VOICE then
        ret.voice_file_name = param[1]
        ret.md5_key = param[2]
        ret.voice_seconds = param[3]
    end
	
	return ret
end


local function refreshBattleStuffInfo(package)
    if package and package.affiliate_info then
        if package.affiliate_info ~= "" then
            CCUserDefault:sharedUserDefault():setBoolForKey("occupied_tips_showed",true)
            require("game/option/scene_tips_occupied")
            SceneTipsOccupied.create()
        end
    end
end

function updateChanelLastChatTimestamp(package)
    refreshBattleStuffInfo(package)

    local last_chat_time_world = 0
    local last_chat_time_region = 0

    for k,v in pairs(allTableData[dbTableDesList.user_stuff.name]) do
        if v.last_world_chat_time then 
            last_chat_time_world = v.last_world_chat_time
        end
        if v.last_region_chat_time then 
            last_chat_time_region = v.last_region_chat_time
        end
    end



    chat_last_timestamp[ChatData.CHANNEL_INDX_WORLD] = last_chat_time_world
    chat_last_timestamp[ChatData.CHANNEL_INDX_REGION] = last_chat_time_region
end

-- 判断是否是同一天
local function isSameDay(timeStampA,timeStampB)
    local dateA =  os.date("*t",timeStampA)
    local dateB = os.date("*t",timeStampB)

    return dateA.year == dateB.year and dateA.month == dateB.month and dateA.day == dateB.day
end

function updateChanelChatFreeCount()
    local  free_chat_count_used_world = 0
    for k,v in pairs(allTableData[dbTableDesList.user.name]) do
        if v.free_world_chat then 
            free_chat_count_used_world = v.free_world_chat
        end
    end
    local last_chat_time_world = 0
    for k,v in pairs(allTableData[dbTableDesList.user_stuff.name]) do
        if v.last_world_chat_time then 
            last_chat_time_world = v.last_world_chat_time
        end
    end

    if not isSameDay(last_chat_time_world,userData.getServerTime()) then
        free_chat_count_used_world = 0
    end

    chat_free_count_left[ChatData.CHANNEL_INDX_WORLD] = CHAT_WORLD_CHANNEL_COUNT_DAILY - free_chat_count_used_world
end

function initUnreadCache()
    -- 每个频道未读的信息数目
    chat_unread_num={}
    chat_unread_num[ChatData.CHANNEL_INDX_WORLD] = 0
    chat_unread_num[ChatData.CHANNEL_INDX_REGION] = 0
    chat_unread_num[ChatData.CHANNEL_INDX_UNION] = 0
    chat_unread_num[ChatData.CHANNEL_INDX_SYS] = 0
end
function initData()
    

    -- 每个频道的信息
    chat_data = {}
    chat_data[ChatData.CHANNEL_INDX_WORLD] = {}
    chat_data[ChatData.CHANNEL_INDX_REGION] = {}
    chat_data[ChatData.CHANNEL_INDX_UNION] = {}
    chat_data[ChatData.CHANNEL_INDX_SYS] = {}

    
    -- 每个频道上次聊天的时间戳
    chat_last_timestamp = {}
    chat_last_timestamp[ChatData.CHANNEL_INDX_WORLD] = 0
    chat_last_timestamp[ChatData.CHANNEL_INDX_REGION] = 0
    chat_last_timestamp[ChatData.CHANNEL_INDX_UNION] = 0
    chat_last_timestamp[ChatData.CHANNEL_INDX_SYS] = 0


    

    -- 每个频道的免费聊天剩余次数  -1 的话 无次数限制
    chat_free_count_left = {}
    chat_free_count_left[ChatData.CHANNEL_INDX_WORLD] = 0
    chat_free_count_left[ChatData.CHANNEL_INDX_REGION] = -1
    chat_free_count_left[ChatData.CHANNEL_INDX_UNION] = -1
    chat_free_count_left[ChatData.CHANNEL_INDX_SYS] = -1


   

    -- 每个频道聊天的玉符花费
    chat_cost_gold = {}
    chat_cost_gold[ChatData.CHANNEL_INDX_WORLD] = CHAT_WORLD_CHANNEL_COST_YUANBAO
    chat_cost_gold[ChatData.CHANNEL_INDX_REGION] = 0
    chat_cost_gold[ChatData.CHANNEL_INDX_UNION] = 0
    chat_cost_gold[ChatData.CHANNEL_INDX_SYS] = 0

    updateChanelLastChatTimestamp()
    updateChanelChatFreeCount()
end


-- 频道功能是否已经开放
function getChatChannelOpenState(channelId)
    if channelId == ChatData.CHANNEL_INDX_UNION or 
        channelId == ChatData.CHANNEL_INDX_SYS then 
        -- 无限制
        return true,0
    end

    if channelId == ChatData.CHANNEL_INDX_WORLD then 
        return userData.getRenownNums() >= CHAT_RENOWN_WORLD_CHANNEL,CHAT_RENOWN_WORLD_CHANNEL
    elseif channelId == ChatData.CHANNEL_INDX_REGION then 
        return userData.getRenownNums() >= CHAT_RENOWN_REGION_CHANNEL,CHAT_RENOWN_REGION_CHANNEL
    else
        return true,0
    end
end


local function getChatIntervalByChannelId(channelId)
    if channelId == ChatData.CHANNEL_INDX_UNION or 
        channelId == ChatData.CHANNEL_INDX_SYS then 
        -- 无限制
        return 0
    end

    local userRenown = userData.getRenownNums()
    if channelId == ChatData.CHANNEL_INDX_WORLD then 
        return CHAT_WORLD_CHANNEL_CD
    elseif channelId == ChatData.CHANNEL_INDX_REGION then 
        if userRenown >= CHAT_REGION_CHANNEL_CD[1] then 
            return CHAT_REGION_CHANNEL_CD[2]
        elseif userRenown >= CHAT_REGION_CHANNEL_CD[3] then 
            return CHAT_REGION_CHANNEL_CD[4]
        else
            return 0
        end
    else
        return 0
    end
end
--- 下一次可聊天的时间戳 
---- return timestamp 0 为无限制
function getNextChatTimestamp(channelId)
    local interval = getChatIntervalByChannelId(channelId)
    if interval > 0 then 
        if chat_last_timestamp[channelId] > 0 then 
            return chat_last_timestamp[channelId] + interval 
        end
    end
    return 0
end

function getChatCost(channelId)
    return chat_cost_gold[channelId]
end
function getChatFreeCountLeft(channelId)
    return chat_free_count_left[channelId]
end
local function convertChatDataVo(channel_id,package)
    local vo = {}
    vo.channel_id = channel_id
	
	vo.subType = package[2]

    vo.user_id = package[3]
    
    vo.user_name = package[4]
    vo.content = package[5]
    
    vo.timestamp = package[6]

    vo.region_id = package[7]
    vo.region_name = ""
    
    vo.union_name = package[8]
    vo.union_id = package[9]
	
	
	
	-- 额外的信息参数，各个类型有各自的定义
	vo.param = convertSubTypeParam(vo.channel_id,vo.subType,package[10])
	

    if not vo.union_id then vo.union_id = 0 end

    if vo.user_id == userData.getUserId() then 
        vo.is_self = true
    else
        vo.is_self = false
    end

    if not vo.region_id then 
        vo.region_id = 0
        vo.region_name = ""
    else
        local region_info = Tb_cfg_region[vo.region_id] 
        if region_info then 
            if region_info.show_name then 
                vo.region_name = region_info.show_name
            else
                vo.region_name = region_info.name 
            end
        else
            vo.region_name = ""
        end        
    end

    if not vo.union_name or vo.union_name == "" then 
        vo.union_name = languagePack['zaiye']
    end

	--if math.random(1,10) % 2 == 0 then
		--vo.subType = ChatData.CHANNEL_WORLD_SUBTYPE_OCCUPY_UNION 
	--end
    
    return vo
end

local function sort_ruler(MA,MB)
    if MA.timestamp < MB.timestamp then return true end
    return false
end

function get_world_channel_data()
    table.sort( chat_data[ChatData.CHANNEL_INDX_WORLD], sort_ruler )
    return chat_data[ChatData.CHANNEL_INDX_WORLD]
end

function get_union_channel_data()
    table.sort( chat_data[ChatData.CHANNEL_INDX_WORLD], sort_ruler )
    return chat_data[ChatData.CHANNEL_INDX_UNION]
end


function getTotalUnreadMsgNum()
    local totalUnread = 0
    for k,v in pairs(chat_unread_num) do 
        totalUnread = totalUnread + v
    end
    return totalUnread
end

function add_channel_cache_info(channelId,chatInfo,ignoreUnreadCache)
    if #chat_data[channelId] >= ChatData.CHANNEL_CACHE_MAX[channelId] then 
        table.remove(chat_data[channelId],1)
    end
    table.insert(chat_data[channelId],chatInfo)
    if not ignoreUnreadCache then
        chat_unread_num[channelId] = chat_unread_num[channelId] + 1
        if not UIChatMain.getInstance() then 
            mainOption.refreshChatNotify(chat_unread_num[ChatData.CHANNEL_INDX_UNION])
        end
        UIChatMain.refreshMsgCount(channelId,chat_unread_num[channelId])   
    end
end

function get_channel_cache_info_list(channelId)
    if channelId == ChatData.CHANNEL_INDX_SYS then 
        local data = allTableData[dbTableDesList.game_log.name]
        local m_arrLog = {}
   
        for i, v in pairs(data) do
            table.insert( m_arrLog, v )
        end

        table.sort( m_arrLog, function ( a,b )
            return a.log_time < b.log_time
        end )

        local list = {}
        if #m_arrLog > ChatData.CHANNEL_CACHE_MAX[ChatData.CHANNEL_INDX_SYS] then
            for i= #m_arrLog-ChatData.CHANNEL_CACHE_MAX[ChatData.CHANNEL_INDX_SYS]+1, #m_arrLog do
                table.insert(list, m_arrLog[i])
            end
        else
            list = m_arrLog
        end
        return list
    else
        table.sort(chat_data[channelId],sort_ruler)
        return chat_data[channelId]
    end
end



function clearUnReadMsg(channelId)
    
    chat_unread_num[channelId] = 0
    
    if channelId == ChatData.CHANNEL_INDX_UNION then 
        mainOption.refreshChatNotify(0)
    end
end

function getChannelUnreadNum(channelId)
    return chat_unread_num[channelId]
end

-----------------------协议相关----------------
-- channelId 0:世界频道，1：同盟频道，2：私聊 3州聊天
-- subType
-- msg 文本信息
-- paramTab ---> 语音聊天{voice_file_name,md5_key,voice_seconds}

local function setLastChatChannelInfo(channelId)
    if chat_free_count_left[channelId] > 0 then 
        chat_free_count_left[channelId] = chat_free_count_left[channelId] - 1
    end
    chat_last_timestamp[channelId] = userData.getServerTime()
end

function requestChat(channelId,subType,msg,param)
    Net.send(CHAT,{channelId,subType,msg,param})
end

function requestChatWorld(msg,subType,param)
	if not subType then 
		subType = ChatData.CHANNEL_WORLD_SUBTYPE_NROMAL
	end
    requestChat(0,subType,msg,param)
    setLastChatChannelInfo(ChatData.CHANNEL_INDX_WORLD)
end
function requestChatUnion(msg,param)
	if param then
		requestChat(1,ChatData.CHANNEL_UNION_SUBTYPE_VOICE ,msg,param)	
	else
		requestChat(1,ChatData.CHANNEL_UNION_SUBTYPE_NORMAL ,msg,param)	
	end
end
function requestChatRegion(msg,param)
	if param then
		requestChat(3,ChatData.CHANNEL_REGION_SUBTYPE_VOICE,msg,param)
	else
		requestChat(3,ChatData.CHANNEL_REGION_SUBTYPE_NORMAL,msg,param)
	end
    setLastChatChannelInfo(ChatData.CHANNEL_INDX_REGION)
end



local function responeNotifyChatMsg(package)
    local blist = userData.getUserBlackList()
    for k,v in ipairs(blist) do 
        if tonumber( package[2] ) == tonumber(v) then 
            return 
        end
    end
    local chatInfo = nil

    if package[1] == 0 then
       chatInfo = convertChatDataVo(ChatData.CHANNEL_INDX_WORLD,package)
       add_channel_cache_info(ChatData.CHANNEL_INDX_WORLD,chatInfo)
       UIChatMain.refreshChatInfo(ChatData.CHANNEL_INDX_WORLD)
       if UIChatMain.getCurSelectedIndx() == ChatData.CHANNEL_INDX_WORLD then 
           ChatData.clearUnReadMsg(ChatData.CHANNEL_INDX_WORLD )
       end
    elseif package[1] == 1 then 
       chatInfo = convertChatDataVo(ChatData.CHANNEL_INDX_UNION,package)
       add_channel_cache_info(ChatData.CHANNEL_INDX_UNION,chatInfo)
       UIChatMain.refreshChatInfo(ChatData.CHANNEL_INDX_UNION)
       if UIChatMain.getCurSelectedIndx() == ChatData.CHANNEL_INDX_UNION then 
           ChatData.clearUnReadMsg(ChatData.CHANNEL_INDX_UNION )
       end
    elseif package[1] == 3 then 
        chatInfo = convertChatDataVo(ChatData.CHANNEL_INDX_REGION,package)
        add_channel_cache_info(ChatData.CHANNEL_INDX_REGION,chatInfo)
        UIChatMain.refreshChatInfo(ChatData.CHANNEL_INDX_REGION)
        if UIChatMain.getCurSelectedIndx() == ChatData.CHANNEL_INDX_REGION then 
           ChatData.clearUnReadMsg(ChatData.CHANNEL_INDX_REGION )
       end
    else
       print(">>>>>>>>>>>>>> unknow what to do",package[1])
    end
end

local function responeChat(package)
    
end


--------- 过滤掉黑名单的聊天信息
local function filterBlackListData()

    local chatVo = nil
    local blist = userData.getUserBlackList()
    for k,v in pairs(blist) do 
        v = tonumber(v)
        for i,chatVoList in pairs(chat_data) do 
            for j = #chatVoList, 1,-1 do 
                chatVo = chatVoList[j]
                if tonumber( chatVo.user_id ) == v then 
                    table.remove(chat_data[i],j)
                end
            end
        end
    end
end


function requestChatHistory()
    initData()
    Net.send(CHAT_HISTORY,{})
end

local function responeChatHistory(package)
    -- chat_data["world"] = package[1]
    -- chat_data["union"] = package[2]
    -- filterBlackListData()
    -- UIChatMain.create()
    if not package[1] then 
        package[1] = {}
    end

    if not package[2] then 
        package[2] = {}
    end

    if not package[3] then 
        package[3] = {}
    end

    chat_data = {}
    chat_data[ChatData.CHANNEL_INDX_WORLD] = {}
    chat_data[ChatData.CHANNEL_INDX_REGION] = {}
    chat_data[ChatData.CHANNEL_INDX_UNION] = {}
    chat_data[ChatData.CHANNEL_INDX_SYS] = {}
    
    for k,v in pairs(package[1]) do 
        local chatInfo = convertChatDataVo(ChatData.CHANNEL_INDX_WORLD,v)
        add_channel_cache_info(ChatData.CHANNEL_INDX_WORLD,chatInfo,true)
    end

    for k,v in pairs(package[2]) do 
        local chatInfo = convertChatDataVo(ChatData.CHANNEL_INDX_UNION,v)
        add_channel_cache_info(ChatData.CHANNEL_INDX_UNION,chatInfo,true)
    end

    for k,v in pairs(package[3]) do 
        local chatInfo = convertChatDataVo(ChatData.CHANNEL_INDX_REGION,v)
        add_channel_cache_info(ChatData.CHANNEL_INDX_REGION,chatInfo,true)
    end

    

    
    filterBlackListData()
    UIChatMain.create()

    -- ChatData.clearUnReadMsg(ChatData.CHANNEL_INDX_WORLD)
    -- ChatData.clearUnReadMsg(ChatData.CHANNEL_INDX_UNION)
    -- ChatData.clearUnReadMsg(ChatData.CHANNEL_INDX_REGION)

end









local function refreshBlackRelated(package)

    if not package then return end
    if not package.black_list then return end
    
    updateChanelChatFreeCount()

    if not UIChatMain.getInstance() then return end
    filterBlackListData()
    UIChatMain.refreshChatInfo(1)
    UIChatMain.refreshChatInfo(2)



end


local function sysMsgUnreadUpdate()
    local count = 0
    for i, v in pairs(allTableData[dbTableDesList.game_log.name]) do
        if v.log_id then
            count = 1
            break
        end
    end


    chat_unread_num[ChatData.CHANNEL_INDX_SYS] = 1
        
    UIChatMain.refreshMsgCount(ChatData.CHANNEL_INDX_SYS,count)
end


local function responeUnionOccupyCity(package)
    -- print(">>>>>>>>>>>>> responeUnionOccupyCity")
    -- config.dump(package)
    require("game/option/scene_tips_occupy_city")
    SceneTipsOccupyCity.create(package)
end


----------------------data init --------------------------
function create()
    initData()
    initUnreadCache()
    netObserver.addObserver(NOTIFY_CHAT_MSG,responeNotifyChatMsg)
    netObserver.addObserver(CHAT,responeChat)
    netObserver.addObserver(CHAT_HISTORY,responeChatHistory)

    -- TODOTK暂时没地方放
    netObserver.addObserver(NOTIFY_UNION_OCCUPY_CITY,responeUnionOccupyCity)
    UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, refreshBlackRelated)
    UIUpdateManager.add_prop_update(dbTableDesList.game_log.name, dataChangeType.update, sysMsgUnreadUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.game_log.name, dataChangeType.add, sysMsgUnreadUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.game_log.name, dataChangeType.update, sysMsgUnreadUpdate)

    UIUpdateManager.add_prop_update(dbTableDesList.user_stuff.name,dataChangeType.update,updateChanelLastChatTimestamp)
end

function remove()
    chat_data = nil
    chat_unread_num = nil

    netObserver.removeObserver(NOTIFY_CHAT_MSG)
    netObserver.removeObserver(CHAT)
    netObserver.removeObserver(CHAT_HISTORY)
    netObserver.removeObserver(NOTIFY_UNION_OCCUPY_CITY)
    UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, refreshBlackRelated)

    UIUpdateManager.remove_prop_update(dbTableDesList.game_log.name, dataChangeType.update, sysMsgUnreadUpdate)
    UIUpdateManager.remove_prop_update(dbTableDesList.game_log.name, dataChangeType.add, sysMsgUnreadUpdate)
    UIUpdateManager.remove_prop_update(dbTableDesList.game_log.name, dataChangeType.update, sysMsgUnreadUpdate)

    UIUpdateManager.remove_prop_update(dbTableDesList.user_stuff.name, dataChangeType.update, updateChanelLastChatTimestamp)
end






