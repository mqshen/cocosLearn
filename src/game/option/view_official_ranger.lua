local viewOfficialRanger = {}


local m_pMainWidget = nil

local schedulerHandler = nil


local ranger_cd = nil




local function disposeSchedulerHandler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
    end
end


local function count_down_cd()
	if not m_pMainWidget then return end

	local panel_count_down = uiUtil.getConvertChildByName(m_pMainWidget,"panel_count_down")
	local label_count_down = uiUtil.getConvertChildByName(panel_count_down,"label_count_down")
	label_count_down:setText(commonFunc.format_day(ranger_cd))
	ranger_cd = ranger_cd - 1
	if ranger_cd <= 0 then 
		disposeSchedulerHandler()
		viewOfficialRanger.resetViewState()
	end
end

local function updateScheduler()
	count_down_cd()
end

local function activeSchedulerHandler()
    disposeSchedulerHandler()
    schedulerHandler = scheduler.create(updateScheduler,1)
end


function viewOfficialRanger.remove_self( )
	if m_pMainWidget then
		m_pMainWidget:removeFromParentAndCleanup(true)
		m_pMainWidget = nil
		disposeSchedulerHandler()
		ranger_cd = nil
	end
end

function viewOfficialRanger.resetViewState()
	if not m_pMainWidget then return end
	if not ranger_cd then 
		ranger_cd = USER_TRAMP_COOL_DOWN_TIME - (userData.getServerTime() - userData.getUserTrampTime())
	end
	local panel_count_down = uiUtil.getConvertChildByName(m_pMainWidget,"panel_count_down")
	local btn_ok = uiUtil.getConvertChildByName(m_pMainWidget,"btn_ok")
	
	if ranger_cd > 0 then 
		panel_count_down:setVisible(true)
		btn_ok:setVisible(false)
		btn_ok:setTouchEnabled(false)
		count_down_cd()
		activeSchedulerHandler()
	else
		panel_count_down:setVisible(false)
		btn_ok:setVisible(true)
		btn_ok:setTouchEnabled(true)
	end

end

function viewOfficialRanger.create()
	if m_pMainWidget then return end
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/liulang.json")
	m_pMainWidget = widget

	local btn_ok = uiUtil.getConvertChildByName(widget,"btn_ok")
	btn_ok:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			-- 副盟主 或者盟主 不能进行流浪操作
			if userData.isUnionLeader() or userData.isUnionDeputyLeader() then 
				tipsLayer.create(errorTable[152])
				return
			end
			require("game/roleForces/ui_role_forces_ranger_confirm")
			UIRoleForcesRangerConfirm.create()
		end
	end)

	viewOfficialRanger.resetViewState()
end

function viewOfficialRanger.getInstance()
    viewOfficialRanger.create()
    return m_pMainWidget
end


function viewOfficialRanger.setEnabled(flag,callback)
	if not m_pMainWidget then return end

	m_pMainWidget:setVisible(flag)

	if flag then 
		uiUtil.showScaleEffect(m_pMainWidget,callback,0.5,nil,nil)
	else
        uiUtil.hideScaleEffect(m_pMainWidget,callback,0.5)
    end
end

return viewOfficialRanger