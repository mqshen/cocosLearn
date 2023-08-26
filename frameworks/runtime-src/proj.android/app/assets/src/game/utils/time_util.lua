local timeUtil = {}

-- 聊天的时间转换
function timeUtil.formatChatTime(timeStamp,timeStampNow)
    if not timeStamp then 
        return "nil timestamp"
    end

    if type(timeStamp) ~= "number" then 
        return "illegal timestamp"
    end
    -- 默认timeStamp 时间戳 比服务器时间要小
    -- 否则是错误的
    if timeStamp > timeStampNow then 
        return languagePack["date_a_moument"]
    end

    local dateNow =  os.date("*t",timeStampNow)
    local dateTime = os.date("*t",timeStamp)

    

    
    -- 不同天 跨零点了
    if dateNow.year ~= dateTime.year
        or dateNow.month ~= dateTime.month 
        or dateNow.day ~= dateTime.day then 
        if (timeStampNow  - timeStamp - (timeStampNow % 86400)) < 86400 then
            return languagePack["date_yesterday"]
        else
            return dateTime.month .. "-" .. dateTime.day
        end
    end   
    local timestampDiff = timeStampNow - timeStamp
    -- 同一天
    if timestampDiff < 0 then 
        return languagePack["date_a_moument"]
    elseif timestampDiff <= 60 then 
        return languagePack["date_a_moument"]
    elseif timestampDiff <= 3600 then  
        return math.floor(timestampDiff / 60) .. languagePack["date_min_ago"]
    elseif timestampDiff <= 86400 then 
        return math.floor(timestampDiff / 3600) .. languagePack["date_hour_ago"]
    else 
        return dateTime.month .. "-" .. dateTime.day
    end
    

    -- -- 不同一年的不处理 （服务器也存不了一年的数据吧）
    -- if dateNow.year ~= dateTime.year then 
    --     return "years ago"
    -- end

    -- -- 不同月 至少是上个月的事了
    -- if dateNow.month ~= dateTime.month then 
    --     return dateTime.month .. "-" .. dateTime.day
    -- end

      
    
    -- -- 不同时段
    -- if dateNow.hour ~= dateTime.hour then 
    --     return (dateNow.hour - dateTime.hour) .. languagePack["date_hour_ago"]
    -- else
    --     if dateNow.min ~= dateTime.min then 
    --         return (dateNow.min - dateTime.min) .. languagePack["date_min_ago"]
    --     else
    --         return languagePack["date_a_moument"]
    --     end
    -- end

    return "unknow"
end


--[[
时间的显示规则，将具体时间数字转化为指定格式，传递的参数是以秒为单位的
如果超过一天则只显示天数，小于一天显示 hh:mm:ss
--]]
function timeUtil.formatTime(new_time,flag)
    local hour = math.floor(new_time/3600)
    if hour > 24 and not flag then
        local day = math.floor(hour/24)
        return day .. languagePack["date_day"]
    end

    new_time = new_time%3600
    local min = math.floor(new_time/60)
    local sec = new_time%60
    if hour < 10 then
        hour = "0" .. hour
    end

    if min < 10 then
        min = "0" .. min
    end

    if sec < 10 then
        sec = "0" .. sec
    end

    return hour .. ":" .. min .. ":" .. sec
end

return timeUtil