local function requestLandInfo(coor_x, coor_y)
	Net.send(GET_FIELD_INFO_CMD, {coor_x, coor_y})
end

local function receiveLandInfo(packet)
	if mapMessageUI then
		mapMessageUI.set_belong_content(packet[2], packet[3], packet[4],packet[5],packet[6],packet[7],packet[8],packet[9])        
	end
end

local function remove()
	netObserver.removeObserver(GET_FIELD_INFO_CMD)
end

local function create()
	netObserver.addObserver(GET_FIELD_INFO_CMD, receiveLandInfo)
end

mapOpRequest = {
				create = create,
				remove = remove,
				requestLandInfo = requestLandInfo
}