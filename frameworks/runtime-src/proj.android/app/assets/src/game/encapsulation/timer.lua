-- @author huangchunhao
-- @date   20131017
-- @brief  定时器封装

-- @brief 创建定时器
-- @param dt 循环时间
-- @param callback 循环回调
-- @return funId 定时器id
local function create(callback, dt)
	return cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, dt, false)
	-- return funId
end

-- @brief 删除定时器
-- @param funId 函数id
local function remove( funId)
	if funId then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(funId)
		return
	end
	print(">>>>>>>>------------------timer is nil")
end

scheduler = {
				create = create,
				remove = remove
}