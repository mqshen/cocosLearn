local userOfficialGuard = {}

local m_pMainWidget = nil

local schedulerHandler = nil



-- TODOTK 中文收集
local state_desc = {}
state_desc[userGuardState.normal] = "未开始坚守"
state_desc[userGuardState.preparing] = "坚守准备中"
state_desc[userGuardState.guarding] = "坚守中"
state_desc[userGuardState.during_cd] = "冷却中"

local prepare_desc = {}
prepare_desc[userGuardState.normal] = "准备3小时"
prepare_desc[userGuardState.preparing] = "准备中"
prepare_desc[userGuardState.guarding] = "准备完成"
prepare_desc[userGuardState.during_cd] = "undefined"

local guarding_desc = {}
guarding_desc[userGuardState.normal] = "坚守5小时"
guarding_desc[userGuardState.preparing] = "坚守5小时"
guarding_desc[userGuardState.guarding] = "坚守中"
guarding_desc[userGuardState.during_cd] = "undefined"

local function resetOpBtnState(confirmAble,cancelAble,confirmBrightAble,cancelBrightAble)
	if not m_pMainWidget then return end
	local btn_confirm_guard = uiUtil.getConvertChildByName(m_pMainWidget,"btn_confirm_guard")
	local btn_cancel_guard = uiUtil.getConvertChildByName(m_pMainWidget,"btn_cancel_guard")

	btn_confirm_guard:setVisible(confirmAble)
	btn_confirm_guard:setTouchEnabled(confirmAble)

	btn_cancel_guard:setVisible(cancelAble)
	btn_cancel_guard:setTouchEnabled(cancelAble)

	if confirmBrightAble ~= nil then 
		btn_confirm_guard:setBright(confirmBrightAble)
	else
		btn_confirm_guard:setBright(true)
	end

	if cancelBrightAble ~= nil then 
		btn_cancel_guard:setBright(confirmBrightAble)
	else
		btn_cancel_guard:setBright(true)
	end
end

local function loadGuardStateDetail( percentPrepare,percentGuard,descPrepare,descGuard,cd_time)
	if not m_pMainWidget then return end
	local state = userData.getUserGuardState()

	local label_guard_state = uiUtil.getConvertChildByName(m_pMainWidget,"label_guard_state")
	label_guard_state:setText(state_desc[state])

	local label_cd = uiUtil.getConvertChildByName(m_pMainWidget,"label_cd")
	local panel_state_time_detail = uiUtil.getConvertChildByName(m_pMainWidget,"panel_state_time_detail")
	


	local label_detail_guard = uiUtil.getConvertChildByName(panel_state_time_detail,"label_detail_guard")
	local label_detail_prepare = uiUtil.getConvertChildByName(panel_state_time_detail,"label_detail_prepare")
	local progress_bar_guard = uiUtil.getConvertChildByName(panel_state_time_detail,"progress_bar_guard")
	local progress_bar_prepare = uiUtil.getConvertChildByName(panel_state_time_detail,"progress_bar_prepare")
	label_detail_guard:setText(descGuard)
	label_detail_prepare:setText(descPrepare)
	progress_bar_prepare:setPercent(percentPrepare)
	progress_bar_guard:setPercent(percentGuard)


	tolua.cast(label_detail_guard:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)
	tolua.cast(label_detail_prepare:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)


	if cd_time and cd_time > 0 then 
		label_cd:setVisible(true)
		panel_state_time_detail:setVisible(false)
		label_cd:setText(commonFunc.format_time(cd_time))
	else
		label_cd:setVisible(false)
		panel_state_time_detail:setVisible(true)
	end
end
-- 坚守冷却中
local function offsetStateDuringCD()
	if not m_pMainWidget then return end
	resetOpBtnState(true,false,false)
	local cd_time = userData.getUserGuardStateCD()
	loadGuardStateDetail(100,100,"","",cd_time)

end

-- 坚守中
local function offsetStateGuarding()
	if not m_pMainWidget then return end
	local cd_time = userData.getUserGuardStateCD()
	local percent = (1 - (cd_time / GUARD_TIME)) * 100
	local state = userData.getUserGuardState()
	loadGuardStateDetail(100,percent,prepare_desc[state],guarding_desc[state] .. commonFunc.format_time(cd_time))
	resetOpBtnState(false,true)
end


-- GUARD_PREPARE_TIME = 10800
-- GUARD_TIME = 28800
-- GUARD_CD_TIME = 18000
-- MOVE_MAIN_CITY_YUBAO_COST = 500

-- 准备阶段
local function offsetStatePreparing()
	if not m_pMainWidget then return end
	local cd_time = userData.getUserGuardStateCD()
	local percent = (1 - (cd_time / GUARD_PREPARE_TIME)) * 100
	local state = userData.getUserGuardState()
	loadGuardStateDetail(percent,0,prepare_desc[state] .. commonFunc.format_time(cd_time),guarding_desc[state])
	resetOpBtnState(false,true)
end

--正常状态，流程未启动
local function offsetStateNormal()
	if not m_pMainWidget then return end

	local state = userData.getUserGuardState()
	loadGuardStateDetail(100,100,prepare_desc[state],guarding_desc[state])
	resetOpBtnState(true,false)

end



local function doReloadData()
	local state = userData.getUserGuardState()
	if state == userGuardState.normal then 
		offsetStateNormal()
	elseif state == userGuardState.preparing then 
		offsetStatePreparing()
	elseif state == userGuardState.guarding then 
		offsetStateGuarding()
	elseif state == userGuardState.during_cd then 
		offsetStateDuringCD()
	end
end

local function disposeSchedulerHandler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
    end
end


local function updateScheduler()
	doReloadData()
end

local function activeSchedulerHandler()
    disposeSchedulerHandler()
    schedulerHandler = scheduler.create(updateScheduler,1)
end


local function doReloadData()
	local state = userData.getUserGuardState()
	if state == userGuardState.normal then 
		offsetStateNormal()
	elseif state == userGuardState.preparing then 
		offsetStatePreparing()
	elseif state == userGuardState.guarding then 
		offsetStateGuarding()
	elseif state == userGuardState.during_cd then 
		offsetStateDuringCD()
	end
end
local function reloadData()
	if not m_pMainWidget then return end
	disposeSchedulerHandler()
	local state = userData.getUserGuardState()
	if state ~=  userGuardState.normal then 
		activeSchedulerHandler()
	end
	doReloadData()
end



GUARD_PREPARE = 841 -- ; // 准备坚守 
GUARD_CANCEL = 842 --; // 取消坚守


local function onRequestGuardStart()

end


local function onRequestGuardCancel()

end

local function removeNetObserver()
	netObserver.removeObserver(GUARD_PREPARE)
	netObserver.removeObserver(GUARD_CANCEL)
end

local function addNetObserver()
	netObserver.addObserver(GUARD_PREPARE,onRequestGuardStart)
	netObserver.addObserver(GUARD_CANCEL,onRequestGuardCancel)
end


local function removeDbdataObserver()
	UIUpdateManager.remove_prop_update(dbTableDesList.user_guard.name, dataChangeType.update, reloadData)
end

local function addDbdataObserver()
	UIUpdateManager.add_prop_update(dbTableDesList.user_guard.name, dataChangeType.update, reloadData)
end
local function create()

	m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/jianshou_bg.json")


	local bnt_tips = uiUtil.getConvertChildByName(m_pMainWidget,"bnt_tips")
	bnt_tips:setTouchEnabled(true)
	bnt_tips:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			alertLayer.create(errorTable[2021])
        end
	end)


	local btn_confirm_guard = uiUtil.getConvertChildByName(m_pMainWidget,"btn_confirm_guard")
	btn_confirm_guard:setTouchEnabled(true)
	btn_confirm_guard:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			if userData.getUserGuardState() == userGuardState.during_cd then 
				--TODOTK 中文收集
				tipsLayer.create("坚守冷却中")
				return
			end
			Net.send(GUARD_PREPARE,{})
		end
	end)


	local btn_cancel_guard = uiUtil.getConvertChildByName(m_pMainWidget,"btn_cancel_guard")
	btn_cancel_guard:setTouchEnabled(true)
	btn_cancel_guard:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			local function finally()
				Net.send(GUARD_CANCEL,{})
			end
			if userData.getUserGuardState() == userGuardState.preparing then
				alertLayer.create(errorTable[2022],nil,finally)
			elseif userData.getUserGuardState() == userGuardState.guarding then
				alertLayer.create(errorTable[2023],nil,finally)
			end
		end
	end)


	addNetObserver()
	addDbdataObserver()

	reloadData()
end



function userOfficialGuard.remove_self( )
	if m_pMainWidget then
		disposeSchedulerHandler()
		m_pMainWidget:removeFromParentAndCleanup(true)
		m_pMainWidget = nil

		removeNetObserver()
		removeDbdataObserver()


	end
end


function userOfficialGuard.getInstance()
    create()
    return m_pMainWidget
end


function userOfficialGuard.setEnabled(flag,callback)
	if not m_pMainWidget then return end

	m_pMainWidget:setVisible(flag)

	if flag then 
		uiUtil.showScaleEffect(m_pMainWidget,callback,0.5,nil,nil)
	else
        uiUtil.hideScaleEffect(m_pMainWidget,callback,0.5)
    end
end
return userOfficialGuard
