--因为服务器只是推送了武将重伤结束的时间，在结束时没有单独推送更新了，所以客户端需要自己来处理这个状态的转变
--处理过程就是首先将已经结束重伤的结束时间自己改为0，然后选出最早结束的时间差做定时器，到时更新状态，然后模拟服务器推动的消息来处理刷新处理
local m_interval_timer = nil
local m_hero_id = nil 			--最近需要刷新重伤状态的武将ID

local function remove()
	if m_interval_timer then
		scheduler.remove(m_interval_timer)
		m_interval_timer = nil
	end

	m_hero_id = nil
end

local function client_update_injure_state()
	m_hero_id = 0

	local is_end_state = false
	local first_end_time = 0
	local temp_packet = nil
	for k,v in pairs(heroData.getAllHero()) do
		if v.hurt_end_time ~= 0 then
			local leave_time = v.hurt_end_time - userData.getServerTime()
			if leave_time > 0 then
				if first_end_time == 0 then
					first_end_time = leave_time
					m_hero_id = k
				else
					if first_end_time > leave_time then
						first_end_time = leave_time
						m_hero_id = k
					end
				end
			else
				if not temp_packet then
					temp_packet = {}
				end

				local item_table = {}
				item_table[1] = 2
				item_table[2] = dbTableDesList.hero.name
				item_table[3] = {}
				item_table[3][dbTableDesList.hero.key_index] = v[dbTableDesList.hero.key_index]
				item_table[3]["hurt_end_time"] = 0
				table.insert(temp_packet, item_table)
				is_end_state = true
			end
		end
	end

	if is_end_state then
		m_hero_id = 0
		dbDataChange.changeData(temp_packet)
	end
end

local function on_update()
	if m_hero_id == 0 then
		return
	end

	local hero_info = heroData.getHeroInfo(m_hero_id)
	if not hero_info then
		client_update_injure_state()
	end

	if hero_info.hurt_end_time <= userData.getServerTime() then
		client_update_injure_state()
	end
end

local function create()
	m_hero_id = 0
	m_interval_timer = scheduler.create(on_update, 1)
end

local function deal_with_hero_add(packet)
	client_update_injure_state()
end

local function deal_with_hero_update(packet)
	client_update_injure_state()
end

local function deal_with_hero_remove(packet)
	client_update_injure_state()
end

heroChangeManager = {
						create = create,
						remove = remove,
						client_update_injure_state = client_update_injure_state,
						deal_with_hero_add = deal_with_hero_add,
						deal_with_hero_update = deal_with_hero_update,
						deal_with_hero_remove = deal_with_hero_remove
					}