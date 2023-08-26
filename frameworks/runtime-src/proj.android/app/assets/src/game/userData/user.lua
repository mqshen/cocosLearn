local serverTime = nil
local locationXPos = nil
local locationYPos = nil

local locationFix_x = nil --坐标的参考点
local locationFix_y = nil 

local mainPosition = nil

local time_diff = nil 	--客户端服务器时间差

local function remove()
	locationXPos = nil
	locationYPos = nil
	locationFix_x = nil
	locationFix_y = nil

	mainPosition = nil
	
	simpleUpdateManager.remove_update_content(updateType.ADD_TIME)
	simpleUpdateManager.remove_update_content(updateType.HEART_PACKET)
	simpleUpdateManager.remove()
	time_diff = nil
end

--发送心跳包
local function sendHeartBeat( )
	-- Net.send(SYS_HEART_BEAT,{})
	-- collectgarbage("collect")
end

-- public Integer userid; 
-- public String passport;
-- public String password;
-- public Byte state;
-- public Integer reg_time; 注册时间
-- public Integer login_time;登陆时间
-- public Integer off_time; 
-- public Integer union_id; 同盟id
-- public Integer affilated_union_id; 附属id
-- public Integer city_wid; 城市id
local function setUserData(packet)
	--UIUpdateManager.add_event_update(eventListenerType.initTeamComplete, armyData.dealWithEnterGameFinish)
	--[[
	for first_k,first_v in pairs(packet) do
		for second_k,second_v in pairs(first_v[2]) do
			dbDataChange.updateData(first_v[1], second_v)
		end
	end
	--]]
	local pre_loginTime = nil
	if allTableData then
		pre_loginTime = userData.getLoginTime()
	end
	dbDataChange.set_user_data(packet)

	--初始化需要保存上次信息的表内容
	dbDataChange.organize_record_data()
	--此函数的调用不能删除，第一次调用保留自己主城的位置信息
	userData.getMainPos()

	local this_loginTime = userData.getLoginTime()
	if pre_loginTime and this_loginTime then
		if not calendarUtil.isSameDay(pre_loginTime, this_loginTime) then
			userData.setIsDialyFirstLogin(true)
			userData.on_enter_game_finish()
		end
	end
end

local function getUserId()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return k
	end
end

local function getUserHelpId()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.help_id
	end
end
local function getUserName()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.name
	end
end

local function getRoleName()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.name
	end
end

local function getRegTime()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.reg_time
	end
end

local function getUnion_id()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.union_id
	end
end

-- local function getQuitUnionTime( )
-- 	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
-- 		return v.quit_union_time
-- 	end
-- end

local function getNextJoinUnionTime( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.next_join_time
	end
end

local function getUnion_name()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.union_name
	end
end

local function getAffilated_union_name()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.affiliated_union_name
	end
end

local function getHasRebel()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.rebel_cur
	end
end

local function getRebelTotal()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.rebel_total
	end
end

local function getAffilated_union_id( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.affiliated_union_id
	end
end

local function getUserBuildingQueueCur()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.build_queue_cur
	end
end



local function getBuildingQueneNum()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.build_queue_max
	end
end

-- TODOTK 临时给 迁城用的 不应该这么搞
local function setMainPos(wid)
	mainPosition = wid
end
local function getMainPos()
	if not mainPosition then
		for k,v in pairs(allTableData[dbTableDesList.user.name]) do
			mainPosition = v.city_wid
			return mainPosition
		end
	end

	return mainPosition
end

local function getNewBie_Guide( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.newbie_guide
	end
end

-- 新手任务是否完成
local function isNewBieTaskFinished()
	if getNewBie_Guide() < NEWBIE_GUIDE_COUNT then 
		return false
	end
	return true
end

-- 新手保护期剩余时间
local function getNewBieProtectionTimeLeft()
	local ret_timeStamp = serverTime
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		ret_timeStamp = v.reg_time
	end
	return ret_timeStamp - serverTime + PROTECT_TIME_BORN
end

local function getRegTime( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.reg_time
	end
end

-- 是否处于新手保护期
local function isInNewBieProtection()
	return getNewBieProtectionTimeLeft() > 0
end

local function getHeroEneryMoveNeed()
	if isInNewBieProtection() then 
		return ENERGY_COST_MOVE * 0.5
	else
		return ENERGY_COST_MOVE
	end
end

local function getLocation( )
	-- for k,v in pairs(allTableData[dbTableDesList.user.name]) do
	-- 	return math.floor(v.city_wid/10000),v.city_wid%10000
	-- end
	return locationFix_x, locationFix_y
end

local function setLocation( x, y )
	-- for k,v in pairs(allTableData[dbTableDesList.user.name]) do
	-- 	v.city_wid = x * 10000 + y
	-- 	break
	-- end
	
	locationFix_x = x
	locationFix_y = y
	local sprite = mapData.getLoadedMapLayer(x,y)
	if sprite then
		locationXPos = sprite:getPositionX()
		locationYPos = sprite:getPositionY()
	end
end

local function getLocationPos( )
	return locationXPos,locationYPos
end

local function getYuanbao( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.yuan_bao_cur
	end
end
-- 铜钱数
local function getUserCoin()
    local money_nums = 0
    local selfCommonRes = politics.getSelfRes()
    if selfCommonRes then
        money_nums = selfCommonRes.money_cur
    end
    return money_nums
end


local function getBornRegion()
	local temp_city_wid = getMainPos()
	return allTableData[dbTableDesList.world_city.name][temp_city_wid].region
end

-- 废弃字段
local function getFreeWashTime()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.point_end_time
	end
end

--获取最大声望的数据库值
local function getRenownNumsMax()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.renown_max
	end
end
--获取显示的最大声望值
local function getShowRenownNumsMax()
	local max_renown = getRenownNumsMax()
	return math.floor(max_renown/100)
end

--获取当前声望的数据库值
local function getRenownNums()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		local current_renown = math.floor(v.renown_cur + userData.getIntervalData(v.renown_time, 3600, v.renown_add))
		local max_renown = getRenownNumsMax()
		if current_renown > max_renown then
			current_renown = max_renown
		end

		return current_renown
	end
end
--获取当前声望的显示值
local function getShowRenownNums()
	local current_renown = getRenownNums()
	return math.floor(current_renown/100)
end

local function isRunOutofTzl()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		local current_renown = getRenownNums()
		local current_tzl = math.floor(current_renown/10000)
		local used_tzl = v.land_count
		return used_tzl >= current_tzl
	end
end

local function getTzlInfo()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		local current_renown = getRenownNums()
		local current_tzl = math.floor(current_renown/10000)
		local used_tzl = v.land_count
		return used_tzl .. "/" .. current_tzl
	end
end

local function addTime()
	
	-- require("game/option/mainOption")
	serverTime = time_diff + os.time()
	if mainOption then 
		mainOption.setLocalTime(serverTime)
	end
	
	-- if serverTime%10 == 0 then
	-- 	CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
	-- end
end

local function setServerTime(t)
	time_diff = t - os.time()
	serverTime = t

	require("game/userData/simpleUpdateManager")
	simpleUpdateManager.create()
	simpleUpdateManager.add_update_content(updateType.ADD_TIME, addTime, 1)
	-- simpleUpdateManager.add_update_content(updateType.HEART_PACKET, sendHeartBeat, 180)
end

local function getServerTime( )
	return serverTime
end

local function getIntervalData(ended_time, interval, interval_add )
	return (getServerTime() - ended_time)/interval*interval_add
end

--个人介绍
local function getUserIntroduction()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.introduction
	end
end

-- 上一次流浪时间戳
local function getUserTrampTime()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.tramp_time
	end
end

-- 获取玩家的黑名单列表
local function getUserBlackList()
	local strlist = nil
	local retlist = {}
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		strlist = v.black_list
	end
	

	if strlist then 
		retlist = stringFunc.split_to_table(strlist,",")
	end

	for k,v in pairs(retlist) do 
		if tonumber(v) == 0 or v == "" then 
			table.remove(retlist,k)
		end
	end
	return retlist
end

local function checkIsInUserBlackList(uid)
	local black_list = getUserBlackList()
	for k,v in pairs(black_list) do 
		if uid == tonumber(v) then 
			return true
		end
	end
	return false
end


local isDailyFirstLogin = nil
local function setIsDialyFirstLogin(value)
	isDailyFirstLogin = value
end

local function getIsDailyFirstLogin()
	return isDailyFirstLogin
end


-- 检查新手保护期是否过期
local function checkIsDuringNewbieProtection()

	-- 理论上 新手期不会沦陷 
	-- 所以这里做一个互斥的检查
	
	if userData.getAffilated_union_id() ~= 0 then
		if (not CCUserDefault:sharedUserDefault():getBoolForKey("occupied_tips_showed" ) ) then 
        	CCUserDefault:sharedUserDefault():setBoolForKey("occupied_tips_showed",true)
        	require("game/option/scene_tips_occupied")
			SceneTipsOccupied.create()
			return
		end
	else
		CCUserDefault:sharedUserDefault():setBoolForKey("occupied_tips_showed",false)
	end
	
	if userData.isInNewBieProtection() then 
		-- 如果是注册账号的第二天自动弹出新手保护提示
		if getIsDailyFirstLogin() then 

			local reg_time = 0
			for k,v in pairs(allTableData[dbTableDesList.user.name]) do
				reg_time = v.reg_time
			end
			if os.date("%d", reg_time) ~= os.date("%d", userData.getServerTime()) then
		        require("game/option/newbie_protect_detail")
	        	NewbieProtectDetail.create()
		    end
		end
		return 
	end
	if allTableData[dbTableDesList.user_stuff.name][userData.getUserId()].protected_popup ~= 1 then 
		local NewbieProtectOverdue = require("game/option/newbie_protect_overdue")
		NewbieProtectOverdue.create()
	end
end


local function showDailyBulletin()
	-- 每日公告
	require("game/daily/ui_daily_bulletin")
    UIDailyBulletin.show(true,checkIsDuringNewbieProtection)
end

local function showDailyLoginReward()
	-- 登录奖励
	require("game/daily/ui_daily_manager")
	UIDailyManager.create(DailyDataModel.ACTIVITY_TYPE_DAILY_LOGIN,showDailyBulletin,true)
end



local function dailyFirstLogin(isCompulsive)
	if isCompulsive then 
		setIsDialyFirstLogin(true)
	end
	if getIsDailyFirstLogin() then 
		-- 当日第一次上线  登录奖励
		showDailyLoginReward()
	else
		checkIsDuringNewbieProtection()
	end
end

local function on_enter_new_guide()
	if not isNewBieTaskFinished() then
		newGuideManager.start_guide()
	end
end

local function on_enter_game_finish()
	if isNewBieTaskFinished() then
		dailyFirstLogin()
	end

	armyListManager.create()
end

-- 获取玩家预备兵数量
local function getCityReserveForcesSoldierNum(cityId)
	local userCityData = userCityData.getUserCityData(cityId)
    local serverTime = userData.getServerTime()
    local ret = 0
    ret = userCityData.redif_cur + math.floor((userData.getServerTime() - userCityData.redif_time) / userCityData.redif_add)
    ret = math.min(userCityData.redif_max,ret)
    return ret
end

--获取立即完成需要的金
local function getBuildFinishImmediatelyCostYuanbao(leftTime )
	if not leftTime or leftTime <= 0 then
		return 0
	end

	for i , v in ipairs(BUILD_FINISH_DIRECTLY_YUANBAO) do
		if v[1] >= leftTime then
			return v[2]
		end
	end
end

-- 是否是盟主
local function isUnionLeader()
	local position = 0
    if allTableData[dbTableDesList.user_union_attr.name] and 
        allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()]
        then

        position = allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()].official_id
    end
    if position == 1 then 
    	return true
    else
    	return false
    end
end
-- 是否是副盟主
local function isUnionDeputyLeader()
	local position = 0
    if allTableData[dbTableDesList.user_union_attr.name] and 
        allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()]
        then

        position = allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()].official_id
    end
    if position == 2 then 
    	return true
    else
    	return false
    end
end

-- 是否是官员
local function isUnionOfficer()
	local position = 0
    if allTableData[dbTableDesList.user_union_attr.name] and 
        allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()]
        then

        position = allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()].official_id
    end
    if position == 3 then 
    	return true
    else
    	return false
    end
end

-- 是否可以 发送同盟邮件
local function isAbleSendUnionMail()
	if isUnionLeader() then return true end
	if isUnionDeputyLeader() then return true end
	if isUnionOfficer() then return true end
	return false
end

-- 是否有新的同盟申请
local function hasNewUnionApply()
	local unionApplyState = allTableData[dbTableDesList.union_apply_notice.name][userData.getUserId()]
	if unionApplyState and unionApplyState.has_new_apply == 1 then 
		return true
	else
		return false
	end
end

-- 是否有新的同盟邀请
local function hasNewUnionInvite()
	for k,v in pairs(allTableData[dbTableDesList.union_invite.name]) do 
		if v.user_id == userData.getUserId() and (v.invite_time + UNION_INVITE_VALID_TIME > userData.getServerTime() ) then 
			if v.read == 0 then 
				return true
			end
		end
	end
	return false
end

-- 获取任务的第一张同名卡
local function getLastSameNameHero()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.got_first_card
	end
end

local function getUserForcesPower()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.power
	end
end


-- 客户端需要模拟政令恢复
local function getUserDecreeNum()
	local ret_cur = 0
	local ret_max = 0
	local decree_time = 0
	local decree_last = 0
	local cd = 0
	for k,v in pairs(allTableData[dbTableDesList.user_farm.name]) do 
		ret_cur,ret_max = v.decree_cur,v.decree_max
	end

	for k,v in pairs(allTableData[dbTableDesList.user_farm.name]) do 
		decree_time,decree_last = v.decree_time,v.decree_last
		cd = (FARM_DECREE_ADD_INTERVAL - (serverTime - v.decree_time + v.decree_last))
	end

	if ret_cur >= ret_max then 
		return ret_cur,ret_max
	end

	if cd >= 0 then 
		-- 正处于正常恢复中
		return ret_cur,ret_max
	else
		if ret_cur < ret_max then
			ret_cur = ret_cur + math.floor( math.abs(cd) / FARM_DECREE_ADD_INTERVAL ) + 1
		else
			ret_cur = ret_cur + math.floor( math.abs(cd) / FARM_DECREE_ADD_INTERVAL ) 
		end			
		if ret_cur > ret_max then ret_cur = ret_max end
		return ret_cur ,ret_max
	end	
	
end

local function getUserDecreeCD()
	local cd = 0
	local ret_cur = 0
	local ret_max = 0
	for k,v in pairs(allTableData[dbTableDesList.user_farm.name]) do 
		cd = FARM_DECREE_ADD_INTERVAL - (serverTime - v.decree_time + v.decree_last)

		ret_cur,ret_max = v.decree_cur,v.decree_max

		if ret_cur >= ret_max then return 0 end
		if cd > 0 then 
			-- 处于正常恢复中
			return cd
		else
			if cd == 0 and ret_cur < ret_max then 
				return FARM_DECREE_ADD_INTERVAL
			end
			if ret_cur >= ret_max then 
				-- 不需要再恢复了
				return 0
			else
				return math.floor( (FARM_DECREE_ADD_INTERVAL - math.abs(cd)) % FARM_DECREE_ADD_INTERVAL )
			end
		end
	end	
end

local function checkTaxOpenState()
	local ret = false
	for i, v in pairs(allTableData[dbTableDesList.build.name]) do
        --民居
        if v.build_id_u%100 == 13 and v.level >=1 then
            ret = true
        end
    end
    return ret
end


-- 免费征税的次数
local function getUserFreeTaxCount()
	if not checkTaxOpenState() then return 0 end
	local temp = {}
	for i, v in pairs(allTableData[dbTableDesList.user_revenue.name]) do
        if v.userid == userData.getUserId() then
        	temp = stringFunc.anlayerMsg(v.revenue_info)
        	if os.date("%d", v.revenue_time) ~= os.date("%d", userData.getServerTime()) then
        		temp = {}
        	end
        end
    end
    return REVENUE_COUNT_A_DAY - #temp
end

-- 免费征税的CD
local function getUserFreeTaxCountDown()
	if not checkTaxOpenState() then return 0 end
	local temp = nil
	for i, v in pairs(allTableData[dbTableDesList.user_revenue.name]) do
       

        temp = stringFunc.anlayerMsg(v.revenue_info)
    	if os.date("%d", v.revenue_time) ~= os.date("%d", userData.getServerTime()) then
    		temp = {}
    	end

    	if  (userData.getServerTime() - v.revenue_time <= REVENUE_CD and #temp > 0 and #temp<REVENUE_COUNT_A_DAY ) then
    		if userData.getServerTime() - v.revenue_time <= REVENUE_CD then

        		if #temp>=REVENUE_COUNT_A_DAY or os.date("%d", v.revenue_time+REVENUE_CD) ~= os.date("%d", userData.getServerTime()) then
        			local time = 24*3600 - tonumber(os.date("%H",userData.getServerTime()))*3600 - tonumber(os.date("%M",userData.getServerTime()))*60-tonumber(os.date("%S",userData.getServerTime()))
        			return time
        		else
        			return v.revenue_time+REVENUE_CD-userData.getServerTime()
        		end
        	end
    	end
    end

    return 0
end


local function isLandMarked(wid)
	for k,v in pairs(allTableData[dbTableDesList.world_mark.name]) do
        if v.wid == wid and v.userid == userData.getUserId() then
            return true
        end
    end
    return false
end

local function getUserMarkedLandCount()
	local ret_count = 0
	for k,v in pairs(allTableData[dbTableDesList.world_mark.name]) do
        if v.userid == userData.getUserId() then
            ret_count = ret_count + 1
        end
    end
    return ret_count
end

local function getUserMarkedLandList()
	local ret = {}
	for k,v in pairs(allTableData[dbTableDesList.world_mark.name]) do
        if v.userid == userData.getUserId() then
            table.insert(ret,v)
        end
    end
    return ret
end

local function isHasYueka( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.yue_ka_endtime - getServerTime() > 0
	end
end

local function getYuekaLeftTime( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.yue_ka_endtime - getServerTime()
	end
end

local function getYuekaLastTime( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.yue_ka_time
	end
end




-- 获取玩家坚守状态所对应的结束CD
local function getUserGuardStateCD()
	local state = nil
	local end_time = 0
	for k,v in pairs(allTableData[dbTableDesList.user_guard.name]) do
		state = v.state
		if state == 0 then 
			end_time = v.next_time
		else
			end_time = v.end_time
		end
	end
	local cd = end_time - userData.getServerTime()
	if cd < 0 then cd = 0 end

	return cd
end


local function getUserMoveMainCityCD()
	local move_city_time = nil
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		move_city_time = v.move_city_time
	end
	if not move_city_time then return 0 end
	
	return move_city_time + MOVE_MAIN_CITY_CD - userData.getServerTime()
end

local function getMoveCityTime(  )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.move_city_time
	end
	
end

-- 获取玩家坚守状态
local function getUserGuardState()
	local state = nil
	local end_time = nil
	for k,v in pairs(allTableData[dbTableDesList.user_guard.name]) do
		state = v.state
		end_time = v.end_time
	end
	if state == 1 then 
		return userGuardState.preparing
	elseif state == 2 then 
		return userGuardState.guarding 
	else
		if getUserGuardStateCD() > 0 then 
			return userGuardState.during_cd
		else
			return userGuardState.normal
		end
	end
end

-- 获取玩家是否已评论过游戏
local function getUserCommentDone( )
	for k,v in pairs(allTableData[dbTableDesList.user_stuff.name]) do
		if v.comment_done == 0 then
			return false
		else
			return true
		end
	end
end

-- 获取登录时间
local function getLoginTime( )
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.login_time
	end
end

-- 获取累计充值转换成的vip等级
local function getVipLevelByPay( )
	local money = nil
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		money = v.login_time
	end
	if not money or money <6 then
		return 0
	end

	if money >=6 and money < 1000 then
		return 1
	elseif money >=1000 and money < 2000 then
		return 2
	elseif money >=2000 and money <5000 then
		return 3
	elseif money >= 5000 and money < 10000 then
		return 4
	else
		return 5
	end
end


userData = {
				remove = remove,
				setUserData = setUserData,
				getUserId = getUserId,
				getUserHelpId = getUserHelpId,
				getUserName = getUserName,
                getRoleName = getRoleName,
				getUnion_id = getUnion_id,
				getUnion_name = getUnion_name,
				getAffilated_union_name = getAffilated_union_name,
				getAffilated_union_id = getAffilated_union_id,
				getRegTime = getRegTime,
				getUserBuildingQueueCur = getUserBuildingQueueCur,
				getBuildingQueneNum = getBuildingQueneNum,
				getMainPos = getMainPos,
				setMainPos = setMainPos,
				getLocation = getLocation,
				setLocation = setLocation,
				getAllTeamMsg = getAllTeamMsg,
				setServerTime = setServerTime,
				getServerTime = getServerTime,
				getYuanbao = getYuanbao,
				getUserCoin = getUserCoin,
				getShowRenownNums = getShowRenownNums,
				getShowRenownNumsMax = getShowRenownNumsMax,
				getRenownNums = getRenownNums,
				getRenownNumsMax = getRenownNumsMax,
				isRunOutofTzl = isRunOutofTzl,
				getTzlInfo = getTzlInfo,
				getBornRegion = getBornRegion,
				getFreeWashTime = getFreeWashTime,
				getLocationPos = getLocationPos,
				on_enter_new_guide = on_enter_new_guide,
				on_enter_game_finish = on_enter_game_finish,
				getIntervalData = getIntervalData,
				getUserIntroduction = getUserIntroduction,
				getUserTrampTime = getUserTrampTime,
				getUserBlackList = getUserBlackList,
				checkIsInUserBlackList = checkIsInUserBlackList,
				getCityReserveForcesSoldierNum = getCityReserveForcesSoldierNum,
				getBuildFinishImmediatelyCostYuanbao = getBuildFinishImmediatelyCostYuanbao,
				isUnionDeputyLeader = isUnionDeputyLeader,
				isUnionOfficer = isUnionOfficer,
				isUnionLeader = isUnionLeader,
				isAbleSendUnionMail = isAbleSendUnionMail,
				hasNewUnionApply = hasNewUnionApply,
				hasNewUnionInvite = hasNewUnionInvite,
				getHasRebel = getHasRebel,
				getRebelTotal = getRebelTotal,
				getLastSameNameHero = getLastSameNameHero,
				getIsDailyFirstLogin = getIsDailyFirstLogin,
				setIsDialyFirstLogin = setIsDialyFirstLogin,
				getUserForcesPower = getUserForcesPower,
				getUserDecreeNum = getUserDecreeNum,
				getUserDecreeCD	 = getUserDecreeCD,
				getNewBie_Guide = getNewBie_Guide,
				getHeroEneryMoveNeed = getHeroEneryMoveNeed,
				isInNewBieProtection = isInNewBieProtection,
				isNewBieTaskFinished = isNewBieTaskFinished,
				getNewBieProtectionTimeLeft = getNewBieProtectionTimeLeft,
				checkTaxOpenState = checkTaxOpenState,
				-- getQuitUnionTime = getQuitUnionTime,
				getUserFreeTaxCount = getUserFreeTaxCount,
				getUserFreeTaxCountDown = getUserFreeTaxCountDown,
				dailyFirstLogin = dailyFirstLogin,
				getUserMarkedLandCount = getUserMarkedLandCount,
				isLandMarked = isLandMarked,
				getUserMarkedLandList = getUserMarkedLandList,
				isHasYueka = isHasYueka,
				getYuekaLeftTime = getYuekaLeftTime,
				getYuekaLastTime = getYuekaLastTime,
				getUserGuardState = getUserGuardState,
				getUserGuardStateCD = getUserGuardStateCD,
				getUserMoveMainCityCD = getUserMoveMainCityCD,
				getNextJoinUnionTime = getNextJoinUnionTime,
				getRegTime = getRegTime,
				getUserCommentDone = getUserCommentDone,
				getMoveCityTime = getMoveCityTime,
				getLoginTime = getLoginTime,
				getVipLevelByPay = getVipLevelByPay,
			}
