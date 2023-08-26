module('DailyDataModel',package.seeall)

require("game/daily/ui_daily_manager")
require("game/utils/util_calendar")

local uiDailyForcesFunds = require("game/daily/ui_daily_forces_funds")

DailyDataModel.ACTIVITY_TYPE_FIRST_PAY = 1 -- 首充
DailyDataModel.ACTIVITY_TYPE_DAILY_LOGIN = 2 -- 连续登陆
DailyDataModel.ACTIVITY_TYPE_UNION_RECRUIT = 3 -- 同盟招募
DailyDataModel.ACTIVITY_TYPE_DAILY_ARMY_EXERCISE = 4 -- 日常演武
DailyDataModel.ACTIVITY_TYPE_RANK_PROFIT = 5 -- 排行榜冲榜
DailyDataModel.ACTIVITY_TYPE_UNION_OCCUIPY_NPCCITY = 6 -- 同盟攻城
DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS = 7 --势力基金


DailyDataModel.TYPE_RES_URL = {}
DailyDataModel.TYPE_RES_URL[DailyDataModel.ACTIVITY_TYPE_FIRST_PAY] = ResDefineUtil.ui_daily_manager_type_title_imgs[1]
DailyDataModel.TYPE_RES_URL[DailyDataModel.ACTIVITY_TYPE_DAILY_LOGIN] = ResDefineUtil.ui_daily_manager_type_title_imgs[2]
DailyDataModel.TYPE_RES_URL[DailyDataModel.ACTIVITY_TYPE_UNION_RECRUIT] = ResDefineUtil.ui_daily_manager_type_title_imgs[3]
DailyDataModel.TYPE_RES_URL[DailyDataModel.ACTIVITY_TYPE_DAILY_ARMY_EXERCISE] = ResDefineUtil.ui_daily_manager_type_title_imgs[4]
DailyDataModel.TYPE_RES_URL[DailyDataModel.ACTIVITY_TYPE_RANK_PROFIT] = ResDefineUtil.ui_daily_manager_type_title_imgs[5]
DailyDataModel.TYPE_RES_URL[DailyDataModel.ACTIVITY_TYPE_UNION_OCCUIPY_NPCCITY] = ResDefineUtil.ui_daily_manager_type_title_imgs[6]
DailyDataModel.TYPE_RES_URL[DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS] = ResDefineUtil.ui_daily_manager_type_title_imgs[7]


local m_tbActivityList = nil

local m_tbActivityReadTimestamp = nil

local m_bHasNotification = nil

local m_bIsDataDurty = nil

local function removeDBChangeObserver()
	UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, DailyDataModel.onDbdataChanngedUser)
	UIUpdateManager.remove_prop_update(dbTableDesList.activity.name,dataChangeType.update,DailyDataModel.onDbdataChanngedActivity)
end

local function addDBChangeObserver()
	UIUpdateManager.add_prop_update(dbTableDesList.user.name,dataChangeType.update,DailyDataModel.onDbdataChanngedUser )
	UIUpdateManager.add_prop_update(dbTableDesList.activity.name,dataChangeType.update,DailyDataModel.onDbdataChanngedActivity)
end


function remove()
	m_tbActivityList = nil
	m_bHasNotification = nil
	m_bIsDataDurty = nil
	m_tbActivityReadTimestamp = nil
	removeDBChangeObserver()
end


local function sortConfigActivityListRuler(infoA,infoB)
	if infoA.priority < infoB.priority then
		return true
	end
	return false
end

local function isUserPaid()
	for k,v in pairs(allTableData[dbTableDesList.user.name]) do
		return v.rmb_paid > 0 
	end
	return false
end


local function getServerOpenTimestamp()
	local ret = nil
	for k,v in pairs(allTableData[dbTableDesList.sys_param.name]) do
		if v.param_id == 1 then 
 			ret = tonumber(v.value)
 			break
		end
	end
	if not ret then ret = userData.getServerTime() end
	return ret
end

local function convertActivityTimestamp(cfgActivityInfo)
	local show_begin_time = cfgActivityInfo.show_begin_time
	local show_end_time = cfgActivityInfo.show_end_time
	local begin_time = cfgActivityInfo.begin_time
	local end_time = cfgActivityInfo.end_time
	
	if cfgActivityInfo.time_type == 0 then
		---- 相对服务器开服时间
		local serverOpenTime = getServerOpenTimestamp()
		show_begin_time = serverOpenTime + show_begin_time
		begin_time = serverOpenTime + begin_time
		end_time = serverOpenTime + end_time
		show_end_time = serverOpenTime + show_end_time
	end

	if cfgActivityInfo.time_type == 3 then
		---- 相对服务器开服当天的0点
		local serverOpenTime = getServerOpenTimestamp()
		serverOpenTime = calendarUtil.calcDawnTSByTS(serverOpenTime)
		show_begin_time = serverOpenTime + show_begin_time
		begin_time = serverOpenTime + begin_time
		end_time = serverOpenTime + end_time
		show_end_time = serverOpenTime + show_end_time
	end
	return show_begin_time,show_end_time,begin_time,end_time
end

function getActivityTimeDesc(cfgActivityInfo)
	if cfgActivityInfo.time_type == 2 then return "" end

	local show_begin_time,show_end_time,begin_time,end_time = convertActivityTimestamp(cfgActivityInfo)
	
	local ret_str = ""
	ret_str = ret_str .. os.date("%Y/%m/%d %H:%M", begin_time)
	ret_str = ret_str .. "~"
	ret_str = ret_str .. os.date("%Y/%m/%d %H:%M", end_time)

	return ret_str
end

local function parseActivityRewardsState( str_rewards_state)

end

local function parseActivityFinishState( str_finish_state)

end

local function parseActivityCompleteAmounts(str_com_amounts)

end



function getActivityConditionsType(activity_id)
	local ret = 0
	for k,v in pairs(Tb_cfg_activity) do 
		if v.activity_id == activity_id then
			for kk,vv in ipairs(v.conditions) do 
				if kk == 1 then 
					ret = v
				end
			end
		end
	end
	return ret
end

function getActivityConditions(activity_id)
	local ret = {}
	for k,v in pairs(Tb_cfg_activity) do 
		if v.activity_id == activity_id then
			for kk,vv in ipairs(v.conditions) do 
				if kk ~= 1 then 
					table.insert(ret,vv)
				end
			end
		end
	end
	return ret
end

function getActivityRewards(activity_id)
	local ret = {}
	for k,v in pairs(Tb_cfg_activity) do 
		if v.activity_id == activity_id then
			for kk,vv in ipairs(v.rewards) do 
				table.insert(ret,vv)
			end
		end
	end
	return ret
end


function getActivityCompleteAmountsInfo(activity_id)
	local ret = {}
	local tmp_ret = nil
	local complete_amounts = nil
	for k,v in pairs(allTableData[dbTableDesList.activity.name]) do 
		for k,v in pairs(allTableData[dbTableDesList.activity.name]) do
			if v.userid == userData.getUserId() and v.activity_id == activity_id then
				complete_amounts = v.complete_amounts
			end
		end
	end
	if complete_amounts then 
		tmp_ret = stringFunc.anlayerOnespot(complete_amounts,";",false)

		for k,v in ipairs(tmp_ret) do 
			table.insert(ret,stringFunc.anlayerOnespot(v,",",true))
		end
	end
	return ret
end

-- 活动先决条件是否满足
function isActivityConditionsActived(activity_id)
	if activity_id == DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS then
		local complete_amounts = getActivityCompleteAmountsInfo(activity_id)
		local conditions = getActivityConditions(activity_id)
		local ret = false
		local paid_num = 0
		for k,v in pairs(complete_amounts) do 
			if v[1] == 64 then
				paid_num = v[2]
			end
		end
		for k,v in pairs(conditions) do
			for kk,vv in ipairs(v) do 
				if vv[1] == 64 then
					if paid_num >= vv[2] then
						ret = true
						break
					end
				end
			end
		end
		return ret,paid_num
	else
		return true
	end
end



function orgnizeActivityList()
	m_tbActivityList = {}
	
	--[[ 测试数据 ]]

	for k,v  in pairs(Tb_cfg_activity) do 
		local show_begin_time,show_end_time,begin_time,end_time = convertActivityTimestamp(v)

		if v.activity_type == DailyDataModel.ACTIVITY_TYPE_FIRST_PAY then
			if not isUserPaid() then
				table.insert(m_tbActivityList,v)
			end
		elseif v.activity_type == DailyDataModel.ACTIVITY_TYPE_DAILY_LOGIN then
			table.insert(m_tbActivityList,v)
		else
			if v.time_type == 2 then 
				--无时间限制  不完成就一直存在
				local flag_is_finished = false
				for kkk,vvv in pairs(allTableData[dbTableDesList.activity.name]) do
					if vvv.userid == userData.getUserId() and vvv.activity_id == v.activity_id then
						if vvv.is_completed == 1 then
							flag_is_finished = true
						end
					end
				end

				if not flag_is_finished then
					table.insert(m_tbActivityList,v)
				end	
			else
				if show_begin_time <= userData.getServerTime() and show_end_time >= userData.getServerTime()  then
					table.insert(m_tbActivityList,v)
				end
			end
		end
		local ret = tonumber(CCUserDefault:sharedUserDefault():getStringForKey("daily_activity_read_" .. v.activity_id))
		if not ret then ret = 0 end
		v.lst_read_timestamp = ret
	end
	
	
	

	table.sort(m_tbActivityList,sortConfigActivityListRuler)
	
	m_bIsDataDurty = true
	
end






local function init()
	-- parseConfigData()
	addDBChangeObserver()
	orgnizeActivityList()	
	DailyDataModel.updateNotificationState()
end

local function refreshActivityData()
	orgnizeActivityList()
	if UIDailyManager then
		UIDailyManager.onDbdataPayInfoChannged()
	end
end

function onDbdataChanngedActivity(package)
	refreshActivityData()
end



function onDbdataChanngedUser(package)
	if package.rmb_paid then
		orgnizeActivityList()
		if UIDailyManager then
			UIDailyManager.onDbdataPayInfoChannged()
		end
	end
end

function create()
	init()
end


-- 当有活动消失 或者新增活动时
function isDataDurty()
	return m_bIsDataDurty
end

function getDailyActivityList()
	return m_tbActivityList
end


-- 判断是否是同一天
local function isSameDay(timeStampA,timeStampB)
    local dateA =  os.date("*t",timeStampA)
    local dateB = os.date("*t",timeStampB)

    return dateA.year == dateB.year and dateA.month == dateB.month and dateA.day == dateB.day
end


-- 获取玩家上一次阅读对应活动的时间
function getActivityLastReadTimestamp(activityId)
	for k,v in pairs(m_tbActivityList) do
		if activityId == v.activity_id then
			return v.lst_read_timestamp
		end
	end
	return 0
end

-- 设置玩家上一次阅读对应活动的时间
function setActivityLastReadTimestamp(activityId,timestamp)
	CCUserDefault:sharedUserDefault():setStringForKey("daily_activity_read_" .. activityId,tostring(timestamp))
	for k,v in pairs(m_tbActivityList) do
		if activityId == v.activity_id then
			v.lst_read_timestamp = timestamp
		end
	end
	m_bIsDataDurty = true
end

-- 阅读活动信息
function readActivityInfo(activityId)
	setActivityLastReadTimestamp(activityId,userData.getServerTime())
end


local function doCheckReadNotification(activityDetail)
	local lastReadTimeStamp = getActivityLastReadTimestamp(activityDetail.activity_id)
	if lastReadTimeStamp == 0 then
		return true
	end
	if activityDetail.red_dot == 1 then
		if not isSameDay(userData.getServerTime(),lastReadTimeStamp ) then
			return true
		end
	end
	if activityDetail.activity_type == DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS then
		return uiDailyForcesFunds.hasRewardsCanReceived()
	end
	return false
end

function updateNotificationState()
	local lastReadTimeStamp = nil
	m_bHasNotification = false
	for k,v in pairs(m_tbActivityList) do
		if doCheckReadNotification(v) then
			m_bHasNotification = true
			break
		end
	end
	m_bIsDataDurty = false
end
-- 是否有未读的信息（需要红点提示）
-- red_dot 0查看后不再显示，1每天都显示
function hasActivityNotification()
	if isDataDurty() then
		updateNotificationState()
	end

	-- local tmp_ret = uiDailyForcesFunds.hasRewardsCanReceived()
	return m_bHasNotification 
end

-- 检查活动的阅读情况
function checkActivityNotificationById(activityId)
	local lastReadTimeStamp = nil
	for k,v in pairs(m_tbActivityList) do
		if activityId == v.activity_id then
			return doCheckReadNotification(v)
		end
	end
	return false
end





--------- 活动条件的完成信息
function getActivityConditionsFinishInfo(activity_id)
	local ret = {}
	for k,v in pairs(allTableData[dbTableDesList.activity.name]) do
		if v.userid == userData.getUserId() and v.activity_id == activity_id then 
			ret = stringFunc.anlayerOnespot(v.finish_info,",",true)
		end
	end
	return ret
end

-------- 活动条件的奖励信息
function getActivityRewardsReceivedInfo(activity_id)
	local ret = {}
	for k,v in pairs(allTableData[dbTableDesList.activity.name]) do
		if v.userid == userData.getUserId() and v.activity_id == activity_id then 
			ret = stringFunc.anlayerOnespot(v.award_info,",",true)
		end
	end
	return ret
end




function getActivityIdu(activity_id)
	local ret = 0
	for k,v in pairs(allTableData[dbTableDesList.activity.name]) do
		if v.userid == userData.getUserId() and v.activity_id == activity_id then 
			ret = v.activity_id_u
		end
	end
	return ret
end





