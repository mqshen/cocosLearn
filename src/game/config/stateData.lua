--州数据
local des = {"a","b", "c", "d", "e", "f", "g","h","i","j","k","l","m","n"}
local temp = {}

for i,v in ipairs(des) do
	temp[v] = i-1
end

local npcCityInState = {}
local guangqiaInState = {}
local wharfInState = {}
for i=1, 13 do
	npcCityInState[i] = {}
	guangqiaInState[i] = {}
	wharfInState[i] = {}
end

local wid_x = nil
local wid_y = nil
local temp_state = {}

-- 获取州里面的所有npc城市，不包括关卡
local function getNpcCityInState(id)
	return npcCityInState[id]
end

-- 获取在州边界的关卡
local function getGuangqiaInState(id)
	return guangqiaInState[id]
end

local function getWharfInState( id )
	return wharfInState[id]
end

local function stateInMap(x, y )
	local state = string.sub(mapAllData,(x-1)*1501+y, (x-1)*1501+y)
	if state then
		state = string.byte(state)
		state = state%16
		if state == 15 then
			state = 13
		end
		return state
	else
		return false
	end
end

local function getStateName( wid )
	local id = stateInMap(math.floor(wid/10000),wid%10000)
	if id and Tb_cfg_region[id] then
		return Tb_cfg_region[id].name
	end
	return false
end

local function getStateNameById( id )
	if id and Tb_cfg_region[id] then
		return Tb_cfg_region[id].name
	end
	return false
end

stateData = {
					stateInMap = stateInMap,
					getStateName = getStateName,
					getStateNameById = getStateNameById,
					getNpcCityInState = getNpcCityInState,
					getGuangqiaInState = getGuangqiaInState,
					getWharfInState = getWharfInState,
}

local temp_state_id = nil
for i, v in pairs(Tb_cfg_world_city) do
	if v.city_type == cityTypeDefine.npc_cheng then
		if v.region ~= 0 then
			table.insert(npcCityInState[v.region], v.wid)
		else
			if Tb_cfg_region_connection[v.wid] then
				table.insert(guangqiaInState[Tb_cfg_region_connection[v.wid].region1], v.wid)
				table.insert(guangqiaInState[Tb_cfg_region_connection[v.wid].region2], v.wid)
			end
			-- wid_x = math.floor(v.wid/10000)
			-- wid_y = v.wid%10000
			-- temp_state = {}
			-- for m = wid_x-1,wid_x+1 do
			-- 	for n = wid_y-1, wid_y+1 do
			-- 		temp_state_id = stateInMap(m,n)
			-- 		if temp_state_id~=0 and not temp_state[temp_state_id] then
			-- 			temp_state[temp_state_id] = 1
			-- 			table.insert(guangqiaInState[temp_state_id], v.wid)
			-- 		end
			-- 	end
			-- end
		end
	elseif v.city_type == cityTypeDefine.matou then
		if v.region == 0 then
			-- wid_x = math.floor(v.wid/10000)
			-- wid_y = v.wid%10000
			-- temp_state = {}
			-- for m = wid_x-1,wid_x+1 do
			-- 	for n = wid_y-1, wid_y+1 do
			-- 		temp_state_id = stateInMap(m,n)
			-- 		if temp_state_id~=0 and not temp_state[temp_state_id] then
			-- 			temp_state[temp_state_id] = 1
			-- 			-- table.insert(guangqiaInState[temp_state_id], v.wid)
			-- 			table.insert(wharfInState[temp_state_id], v.wid)
			-- 		end
			-- 	end
			-- end
			table.insert(wharfInState[Tb_cfg_region_connection[v.wid].region1], v.wid)
			table.insert(wharfInState[Tb_cfg_region_connection[v.wid].region2], v.wid)
		else
			table.insert(wharfInState[v.region], v.wid)
		end
	end
end

for i = 1, 13 do
	table.sort(npcCityInState[i], function ( a,b )
		return Tb_cfg_world_city[a].param%100 > Tb_cfg_world_city[b].param%100
	end)

	table.sort(guangqiaInState[i], function ( a,b )
		return Tb_cfg_world_city[a].param%100 > Tb_cfg_world_city[b].param%100
	end)
end


temp_state = nil