--地表事件的数据
module("GroundEventData", package.seeall)

function getWorldEvent( )
	local arrTemp = {}
	local data = allTableData[dbTableDesList.user_world_event.name][userData.getUserId()]
	if data then
		for i, v in pairs (stringFunc.anlayerMsg(data.event)) do
			if v[4] + FIELD_EVENT_EXPIRATION_INTERVAL > userData.getServerTime( ) then
				table.insert(arrTemp, v)
			end
		end
		if #arrTemp > 0 then
			return arrTemp
		end
	end
	return false
end

function getWorldEventByWid(wid )
	local data = allTableData[dbTableDesList.user_world_event.name][userData.getUserId()]
	if data then
		local eventData = stringFunc.anlayerMsg(data.event)
		for i, v in ipairs(eventData) do
			if v[2] == wid and v[4]+ FIELD_EVENT_EXPIRATION_INTERVAL > userData.getServerTime( ) then
				return v
			end
		end
	end
	return false
end

function getWorldEventLog( )
	return allTableData[dbTableDesList.user_field_event_report.name]
end