--指引相关请求
local function sendNewGuideRequest(guide_id)
	Net.send(USER_GUIDE_RECORD, {guide_id})
end

local function receive_dail_res(first_show_money)
	-- if first_show_money ~= 0 then
		-- tipsLayer.create(errorTable[106], {first_show_money})
	-- end
end

local function remove()
	-- netObserver.removeObserver(REWARD_FIRST_LOGIN)
end

local function create()
	-- netObserver.addObserver(REWARD_FIRST_LOGIN, receive_dail_res)
end

userCommonRequest = {
						create = create,
						remove = remove,
						sendNewGuideRequest = sendNewGuideRequest
}