-- @author huangchunhao
-- @date   20131017
-- @brief  组合动作封装

-- @brief 创建按序列执行组合动作
-- @param action 包含所有动作的table
local function sequence( action )
	local actions = CCArray:create()
	for i,v in pairs(action) do
		actions:addObject(v)
	end

	return cc.Sequence:create(actions)
end

-- @brief 创建同时执行组合动作
-- @param action 包含所有动作的table
local function spawn( action )
	local actions = CCArray:create()
	for i,v in pairs(action) do
		actions:addObject(v)
	end
	return CCSpawn:create(actions)
end

-- @brief 获取角度
-- @param start_pos 起始位置
-- @param end_pos 结束位置
local function pointRotate(start_pos, end_pos)
	local M_PI = 3.14159265358979323846
	-- local len_y = end_pos.y - start_pos.y
	-- local len_x = end_pos.x - start_pos.x
	
	-- if len_x == 0 then
	-- 	if len_y > 0 then return 0 end
	-- 	if len_y < 0 then return 180 end
	-- end
	-- local tan_yx  = math.abs(len_y) / math.abs(len_x)	
	
	-- local rotate = 0
	-- if(len_y > 0 and len_x < 0) then
	-- 	rotate = math.atan(tan_yx)*180/M_PI - 90
	-- elseif (len_y > 0 and len_x > 0) then
	-- 	rotate = 90 - math.atan(tan_yx)*180/M_PI
	-- elseif(len_y < 0 and len_x < 0) then
	-- 	rotate = -math.atan(tan_yx)*180/M_PI - 90
	-- elseif(len_y < 0 and len_x > 0) then
	-- 	rotate = math.atan(tan_yx)*180/M_PI + 90
	-- end
	-- return rotate

	 -- //两点的x、y值
	 	local px1,py1 = start_pos.x, start_pos.y
	 	local px2, py2 = end_pos.x, end_pos.y
        local x = px2-px1
        local y = py2-py1
        local hypotenuse = math.sqrt(math.pow(x, 2)+math.pow(y, 2))
        -- //斜边长度
        local cos = x/hypotenuse
        local radian = math.acos(cos)
        -- //求出弧度
        local angle = 180/(M_PI/radian)
        -- //用弧度算出角度        
        if y<0 then
            angle = -angle
        elseif y == 0 and x<0 then
            angle = 180
        end
        return angle
end

animation = {
				sequence = sequence,
				spawn = spawn,
				pointRotate = pointRotate
}