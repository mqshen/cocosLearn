--[[
数字显示规则，主要针对资源等显示
超过10000显示XX万，其余正常显示数字
--]]
local function common_num_show_content(show_num)
	local show_info = ""
	if show_num >= 100000 then
        show_info = math.floor(show_num/10000) .. languagePack["wan"]
        if show_num % 10000 ~= 0 then 
        	show_info = show_info .. math.floor(show_num % 10000)
        end
    else
    	show_info = tostring(show_num)
    end
    return show_info
end


-- 铜钱 玉符显示规则
local function common_money_show_content(show_num)
	return common_num_show_content(show_num)
end

-- 铜钱显示规则
local function common_coin_show_content(show_num)
	local show_info = ""
	if show_num >= 100000 then
        show_info = (math.floor(show_num/1000) / 10) .. languagePack["wan"]
        
    else
    	show_info = tostring(show_num)
    end
    return show_info
end

-- 元宝显示规则
local function common_gold_show_content(show_num)
	return common_num_show_content(show_num)
end
--[[
计算一个数字在列表中的区间范围
例如 {2, 6, 10, 20}  1返回1； 3 返回2 等
--]]
local function get_sequene_range_in_list(new_value, new_table)
	local table_nums = #new_table
	if new_value <= new_table[1] then
		return 1
	end

	if new_value > new_table[table_nums] then
		return table_nums + 1
	end

	local range_result = 1
	for i=1,table_nums do
		if new_value > new_table[i] and new_value <= new_table[i+1] then
			range_result = i + 1
			break
		end
	end

	return range_result
end


local function for_time_h_m_s(new_time)
	local hour = math.floor(new_time/3600)
	new_time = new_time%3600
	local min = math.floor(new_time/60)
	local sec = new_time%60
	return hour,min,sec
end
--[[
时间的显示规则，将具体时间数字转化为指定格式，传递的参数是以秒为单位的
如果超过99小时则只显示天数，小于显示 hh:mm:ss
--]]
local function format_time(new_time,flag)
	local hour = math.floor(new_time/3600)
	if hour > 99 and not flag then
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


-- 将文本字符转换为时间值 yy-mm-dd h:m:s
local function get_time_by_data(data_s)
	local a = stringFunc.anlayerOnespot(data_s, " ", false)
	local b = stringFunc.anlayerOnespot(a[1], "-", true)
	local c = stringFunc.anlayerOnespot(a[2], ":", true)
	local t = os.time({year=b[1], month=b[2], day=b[3], hour=c[1], min=c[2], sec=c[3]})

	return t
end

--返回时间戳的年月日时分秒
local function get_time_by_timestamp( timestamp )
	return os.date("*t", timestamp)
-- 例如：{year = 1998, month = 9, day = 16, yday = 259, wday = 4,
--  hour = 23, min = 48, sec = 10, isdst = false}
end

-- 大于一天就按天显示 小于一天就按时间显示
local function format_day(time_t)
	local day = math.floor(time_t/(3600 * 24))
	if day > 0 then 
		return  math.ceil(time_t/(3600 * 24)) .. languagePack["date_day"]
	else
		return format_time(time_t)
	end
end

local function is_in_today(time_num)
	local time_info = get_time_by_timestamp(time_num)
	local today_info = get_time_by_timestamp(userData.getServerTime())

	if time_info.year == today_info.year and time_info.month == today_info.month and time_info.day == today_info.day then
		return true
	else
		return false
	end
end

local function format_date(new_time)
	return os.date("%Y/%m/%d %H:%M:%S", new_time)
end

commonFunc = {
				common_num_show_content = common_num_show_content,
				common_money_show_content = common_money_show_content,
				common_coin_show_content = common_coin_show_content,
				common_gold_show_content = common_gold_show_content,
				for_time_h_m_s = for_time_h_m_s,
				format_time = format_time,
				format_date = format_date,
				format_day = format_day,
				is_in_today = is_in_today,
				get_time_by_data = get_time_by_data,
				get_sequene_range_in_list = get_sequene_range_in_list,
				get_time_by_timestamp = get_time_by_timestamp
} 

--[[
字符串相关处理函数
--]]


--  字符串简单分割  如 "a,b,c" 分割成 {a,b,c}
local function split_to_table(szFullString, szSeparator)
	if not szSeparator or szSeparator == "" then return {szFullString} end
	
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
   		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
   		if not nFindLastIndex then  
   			local ret = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
   			if ret and ret ~= "" then 
    			nSplitArray[nSplitIndex] = ret 
    		end
    		break  
   		end  
   		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
   		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
   		nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end

-- @value 实数 {1234.5678}
-- @return integerTab{1,2,3,4} 整数部分各位,decimalTab {5,6,7,8}小数部分各位数
local function split_number_to_table(value)
	if type(value) ~= "number" then return {},{} end
	value = math.abs(value)
	local decimalCount = 0  -- 小数个数
	local totalTab = {}

	local integerTab =  {}
	local decimalTab = {}
	local isIngerger = false 
	if value % 1 == 0 then
		isIngerger = true
	end
	if not isIngerger then
		while value % 1 ~= 0 do
			decimalCount = decimalCount + 1
			value = value * 10
		end
	end

	while value ~= 0 do
		table.insert(totalTab,1,math.floor(value%10))
		value = math.floor(value / 10)
	end

	for i = 1,#totalTab - decimalCount do
		table.insert(integerTab,totalTab[i])
	end

	for i = #totalTab - decimalCount + 1,#totalTab do 
		table.insert(decimalTab,totalTab[i])
	end

	if value == 0 and #integerTab == 0 then 
		table.insert(integerTab,0)
	end
    return integerTab,decimalTab
end

--字符串分割
local function lua_string_split(str, split1, split2)
    local sub_str_tab = {}
    local count = string.len(str)
    if count == 0 then return sub_str_tab end
    local pos = 1
    local rePos = 1
    while (true) do
    	local tempStr = string.sub(str, pos, pos) 
    	if  tempStr == split1 or tempStr == split2 then
    		table.insert(sub_str_tab, string.sub(str,rePos, pos-1))
    		rePos = pos + 1
    	end
    	pos = pos + 1
    	if pos > count then
    		if string.sub(str, pos-1, pos-1) ~= split1 and string.sub(str, pos-1, pos-1) ~= split2 then
    			table.insert(sub_str_tab, string.sub(str,rePos, pos-1))
    		end
    		break
    	end
    end
    return sub_str_tab
end

local function stringSplit(text, keyWord, beginPos, endPos)
	local textTable = {}
	if string.len(text) < 1 then
		return textTable
	end
	
	local index =beginPos
	local endPosition = endPos or string.len(text)
	while true do
		local endIndex = string.find(text, keyWord, index)
		if endIndex then
			endIndex = endIndex -1
		else
			endIndex = endPosition
		end
		table.insert(textTable,string.sub(text, index, endIndex))
	
		index = endIndex+2
		if index > endPosition then
			return textTable
		end
	end
end

local function anlayerMsg(text)
	local douhao = {}
	local fenhao = {}
	local shuzi = {}
	douhao = {}
	douhao=stringSplit(text, ";", 1, string.len(text))

	fenhao = {}
	if douhao then
		for m,n in pairs(douhao) do
			table.insert(fenhao,stringSplit(n,",", 1, string.len(n)))
		end
	end

	shuzi = {}
	if fenhao then
		for k,p in pairs(fenhao) do
			local temp_table = {}
			for x,y in pairs(p) do
				table.insert(temp_table,tonumber(y))
			end
			table.insert(shuzi, temp_table)
		end
	end
	return shuzi
end

local function anlayerOnespot(text, delimiter, is_number)
	local temp = stringSplit(text, delimiter, 1, string.len(text))
	local outPut = {}
	if not temp then
		return outPut
	end
	
	for i, v in ipairs(temp) do
		if is_number then
			table.insert(outPut, tonumber(v))
		else
			table.insert(outPut, v)
		end
	end
	return outPut
end

--替代字
local function gsub( text, dot ,arg )
	local index = 0
	return string.gsub(text, dot, function (n )
		index = index + 1
		return arg[index]
	end)
end

--一个英文和一个中文都对应一个字符的长度
local function get_str_length(str)
  return #(string.gsub(str, '[\128-\255][\128-\255][\128-\255]', ' '))
end

--截取字符串指定长度的文本 一个中文3个字符
local function get_str_by_length_1(s, n)
	local dropping = string.byte(s, n+1)
	if not dropping then
		return s
	end

	if dropping >= 128 and dropping < 192 then
		return get_str_by_length_1(s, n-1)
	end

	return string.sub(s, 1, n)
end

local function get_str_by_length_2(s, n)
	local temp_s = (string.gsub(s, ' ', 'a'))
	temp_s = (string.gsub(temp_s, '[\128-\255][\128-\255][\128-\255]', ' '))
	local temp_cut_len = 0
	for i=1,string.len(temp_s) do
		if string.sub(temp_s, i, i) == ' ' then
			temp_cut_len = temp_cut_len + 3
		else
			temp_cut_len = temp_cut_len + 1
		end

		if i >= n then
			break
		end
	end

	return string.sub(s, 1, temp_cut_len)
end

local function thirty_sixToDecimal (str )
	local len = string.len(str)
	local asii = nil
	local _oneStr = 0
	for i=1, len do
		asii = string.byte(string.sub(str,i,i))
		-- 0----9
		if asii >=48 and asii <=57 then
			_oneStr = _oneStr + (asii-48)*math.pow(36,len-i)
		else
			_oneStr = _oneStr + (asii-87)*math.pow(36,len-i)
		end
	end
	return _oneStr
end

stringFunc = {
	stringSplit = stringSplit,
	anlayerMsg = anlayerMsg,
	anlayerOnespot = anlayerOnespot,
	lua_string_split = lua_string_split,
	gsub = gsub,
	split_to_table = split_to_table,
	get_str_length = get_str_length,
	get_str_by_length_1 = get_str_by_length_1,
	get_str_by_length_2 = get_str_by_length_2,
	split_number_to_table = split_number_to_table,
	thirty_sixToDecimal = thirty_sixToDecimal,
}


local function is_ennough_res(resType,resNum)
	if resType == consumeType.common_money then
		return (politics.getSelfRes().money_cur - resNum) >= 0
	elseif resType == consumeType.yuanbao then
		return (userData.getYuanbao()- resNum) >= 0
	else
		return false 
	end
end

gameUtilFunc = {
	is_ennough_res = is_ennough_res,
}