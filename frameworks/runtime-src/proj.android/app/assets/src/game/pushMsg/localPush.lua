-- localPush.lua
-- 本地推送
module("LocalPush", package.seeall)
local thief_event = nil
local other_event = nil
local local_push_cfg = {}
local handler = nil
local_push_cfg["alert_thief_1"] = { id = "alert_thief_1" }
local_push_cfg["alert_thief_2"] = { id = "alert_thief_2" }
local_push_cfg["alert_thief_3"] = { id = "alert_thief_3" }

local_push_cfg["alert_card_1"] = { id = "alert_card_1" }

function update( )
	local renown = userData.getShowRenownNums()
	local hour, min = nil, nil
	-- 贼兵
	if renown*100 >= FIELD_EVENT_RENOWN[3] and not thief_event then
		for i, v in pairs(CRON_TIME_FIELD_EVENT_REFRESH[2]) do
			hour = math.floor(v/3600)
			min = math.floor(v%3600/60)
			if hour >= 8 and hour <= 23 then
				if local_push_cfg["alert_thief_"..i] then
					thief_event = true
					sdkMgr:sharedSkdMgr():setAlarmTime(hour, min, "alert_thief_"..i, "", languagePack["alert_event"])
				end
			end
		end 
	end

	-- 卡包和经验书
	if (renown*100 >= FIELD_EVENT_RENOWN[1] or renown*100 >= FIELD_EVENT_RENOWN[2]) and not other_event then
		for i, v in pairs(CRON_TIME_FIELD_EVENT_REFRESH[1]) do
			hour = math.floor(v/3600)
			min = math.floor(v%3600/60)
			if hour >= 8 and hour <= 23 then
				if local_push_cfg["alert_card_"..i] then
					other_event = true
					sdkMgr:sharedSkdMgr():setAlarmTime(hour, min, "alert_card_"..i, "", languagePack["alert_event"])
				end
			end
		end 
	end

	if other_event and thief_event then
		scheduler.remove(handler)
		handler = nil
	end
end

function init( )
	-- UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update,
	-- update )
	sdkMgr:sharedSkdMgr():removeAllLocalPush()
	handler = scheduler.create(update,30)
end

function remove( )
	other_event = nil
	thief_event = nil
	scheduler.remove(handler)
	handler = nil
	-- UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update,
	-- update )
end