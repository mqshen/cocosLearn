
local curyear = os.date("*t")["year"] --当前年份
local curmonth = os.date("*t")["month"]--当前月份
local curday = os.date("*t")["day"] --当前日期
local curweek = os.date("*t")["wday"]--当前星期
local MAX_YEAR = 10000--最大年份
local MIN_YEAR = 1--最小年份
local MAX_MONTH = 12--最大月份
local MIN_MONTH = 1--最小月份

local help_msg ={
    [9] = "The year and the month should be an enterger!",
    [10] = "The month should be an enterger!",
    [12] = "The year should between [1, 10000], and the month should be an enterger!",
    [17] = "The year should be an enterger!",
    [20] = "The year should between [1, 10000]!",
    [33] = "The year should be an enterger and the month should between [1, 12]!",
    [34] = "The month should between [1, 12]",
    [36] = "The year should between [1, 10000] and the month should between [1, 12]!"
}


local function initDate()
    curyear = os.date("*t")["year"]
    curmonth = os.date("*t")["month"]
    curday = os.date("*t")["day"] 
    curweek = os.date("*t")["wday"]
end
--检查年份和月份是否合法
local function checkDate(year, month) 
    initDate()     
    local flag = 0
    if year == nil then
        flag = flag + 1
    elseif year <= MAX_YEAR and year >= MIN_YEAR then
        flag = flag + 2
    else
        flag = flag + 4
    end
    if month == nil then
        flag = flag + 8
    elseif month <= MAX_MONTH and month >= MIN_MONTH then
        flag = flag + 16
    else
        flag = flag + 32
    end
    if flag == 18 then 
        return true
    else
        print(help_msg[flag])
        return false
    end
end
--获取指定年月的天数和第一天的星期
local function getDays(year,month)
    if not checkDate(year,month) then return 0 end

    local bigmonth = "(1)(3)(5)(7)(8)(10)(12)"
    local strmonth = "(" .. month .. ")"
    local week = os.date("*t", os.time{year = year, month = month, day = 1})["wday"]
    if month == 2 then
        if year % 4 == 0 or (year % 400 == 0 and year % 400 ~= 0) then
            return 29, week
        else
            return 28, week
        end
    elseif string.find(bigmonth, strmonth) ~= nil then
        return 31, week
    else
        return 30, week
    end
end

local function getCurDays()
    initDate()
    return getDays(curyear,curmonth)
end


-- 判断是否是同一天
local function isSameDay(timeStampA,timeStampB)
    local dateA =  os.date("*t",timeStampA)
    local dateB = os.date("*t",timeStampB)

    return dateA.year == dateB.year and dateA.month == dateB.month and dateA.day == dateB.day
end


-- 获取时间戳对应的当天的零点时间
local function calcDawnTSByTS(ts)
    local date =  os.date("*t",ts) 
    local ret = os.time({year=date.year, month=date.month, day=date.day, hour=0})
    if not ret then ret = 0 end
    return ret
end
calendarUtil = {
    getDays = getDays,
    getCurDays = getCurDays,
    isSameDay = isSameDay,
    calcDawnTSByTS = calcDawnTSByTS,
}