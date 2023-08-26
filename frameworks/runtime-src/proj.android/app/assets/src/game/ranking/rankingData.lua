local player_list_type = nil
local union_list_type = nil

local function request_player_list()
	Net.send(RANK_LIST,{0, 300, player_list_type})
end

local function request_union_list()
	Net.send(RANK_LIST,{0, 100, union_list_type})
end

local function receive_ranking_list(packet)
	local temp_type = packet[1]
	if temp_type == player_list_type then
		rankingManager.organize_player_list(packet)
		request_union_list()
	else
		rankingManager.organize_union_list(packet)
	end
end

local function remove()
	player_list_type = nil
	union_list_type = nil
	netObserver.removeObserver(RANK_LIST)
end

local function create()
	player_list_type = 0
	union_list_type = 1

	netObserver.addObserver(RANK_LIST, receive_ranking_list)

	request_player_list()
end

rankingData = {
				create = create,
				remove = remove
}