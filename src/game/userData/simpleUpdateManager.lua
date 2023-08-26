--[[
主要处理那种不需要每帧刷新的值
该文件主要用来处理那些游戏期间需要刷新的数值，例如声望，资源等
每种值指定刷新频率，尽量错开刷新，防止某一时刻刷新很多东西的状况
--]]
updateType = {ADD_TIME = 1, HEART_PACKET = 2, RENOWN_TYPE = 3, RES_TYPE = 4, DAILY_RES = 5}

local update_timer = nil
local update_content_list = nil

local function deal_with_add_time()
	if not update_content_list then
		return
	end

	for k,v in pairs(update_content_list) do
		v.currentCount = v.currentCount + 1
		if v.currentCount == v.repeatCount then
			v.callFun()
			v.currentCount = 0
		end
	end
end

local function add_update_content(type, call_fun, time_interval)
	if not update_content_list then
		update_content_list = {}
	end

	local temp_content = {}
	temp_content["callFun"] = call_fun
	temp_content["repeatCount"] = time_interval
	temp_content["currentCount"] = 0

	update_content_list[type] = temp_content
end

local function remove_update_content(type)
	if not update_content_list then
		return
	end

	if update_content_list[type] then
		update_content_list[type] = nil
	end
end

local function create()
	if not update_timer then
		update_timer = scheduler.create(deal_with_add_time, 1)
	end
end

local function remove()
	if update_timer then
		scheduler.remove(update_timer)
		update_timer = nil
	end

	update_content_list = nil
end

simpleUpdateManager = {
						create = create,
						remove = remove,
						add_update_content = add_update_content,
						remove_update_content = remove_update_content
}