local userOfficialMoveCity = {}

local m_pMainWidget = nil

local schedulerHandler = nil

local m_iSelectedCityWid = nil


--[[
1 玉符不足  
2 未选择目标城市 
3 冷却CD中
4 该不满足 城部队均返回城内  
5 主城还有建筑队列在进行
6 还有征兵队列在进行中
7 迁城的目标城市处于放弃中
8 玩家处于沦陷状态
]]
local MOVE_BTN_UNABLE_TYPE_GOLD_NOT_ENOUGH = 1
local MOVE_BTN_UNABLE_TYPE_NO_TARGET_CID = 2
local MOVE_BTN_UNABLE_TYPE_CD = 3
local MOVE_BTN_UNABLE_TYPE_HAS_ARMY_OUTSIDE = 4
local MOVE_BTN_UNABLE_TYPE_HAS_UNFINISHED_BUILDING = 5
local MOVE_BTN_UNABLE_TYPE_HAS_ARMY_RECRUIT = 6
local MOVE_BTN_UNABLE_TYPE_TARGET_CITY_IS_REMOVING = 7
local MOVE_BTN_UNABLE_TYPE_USERCITY_IS_OCCUPIED = 8


local moveBtnUnableTipsTab = {}
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_GOLD_NOT_ENOUGH] = languagePack["MOVE_BTN_UNABLE_TYPE_GOLD_NOT_ENOUGH"]
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_NO_TARGET_CID] = languagePack["MOVE_BTN_UNABLE_TYPE_NO_TARGET_CID"]
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_CD] = languagePack["MOVE_BTN_UNABLE_TYPE_CD"]
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_HAS_ARMY_OUTSIDE] = languagePack["MOVE_BTN_UNABLE_TYPE_HAS_ARMY_OUTSIDE"]
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_HAS_UNFINISHED_BUILDING] = languagePack["MOVE_BTN_UNABLE_TYPE_HAS_UNFINISHED_BUILDING"]
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_HAS_ARMY_RECRUIT] = languagePack["MOVE_BTN_UNABLE_TYPE_HAS_ARMY_RECRUIT"]
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_TARGET_CITY_IS_REMOVING] = languagePack["MOVE_BTN_UNABLE_TYPE_TARGET_CITY_IS_REMOVING"]
moveBtnUnableTipsTab[MOVE_BTN_UNABLE_TYPE_USERCITY_IS_OCCUPIED] = languagePack["MOVE_BTN_UNABLE_TYPE_USERCITY_IS_OCCUPIED"]




local move_btn_unable_type = nil  

local function getCountDownCD()
	return userData.getUserMoveMainCityCD()
end





local function updateCountDownTime()
	if not m_pMainWidget then return end

	local panel_count_down = uiUtil.getConvertChildByName(m_pMainWidget,"panel_count_down")
	local label_cd = uiUtil.getConvertChildByName(panel_count_down,"label_cd")

	label_cd:setText(commonFunc.format_time(getCountDownCD()))
end


local function checkCostState()
	if not m_pMainWidget then return end

	local label_cost_gold = uiUtil.getConvertChildByName(m_pMainWidget,"label_cost_gold")
	if userData.getYuanbao() >= MOVE_MAIN_CITY_YUBAO_COST then 
		label_cost_gold:setColor(ccc3(255,219,133))
	else 
		label_cost_gold:setColor(ccc3(215,44,43))
	end
	label_cost_gold:setText(MOVE_MAIN_CITY_YUBAO_COST)
end


-- TODOTK

local function checkBtnStates()
	if not m_pMainWidget then return end

	local btn_startmove = uiUtil.getConvertChildByName(m_pMainWidget,"btn_startmove")
	btn_startmove:setTouchEnabled(true)
	move_btn_unable_type = nil
	-- if getCountDownCD() > 0 then 
	-- 	btn_startmove:setBright(false)
	-- 	move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_CD
	-- else
	-- 	if not m_iSelectedCityWid then 
	-- 		btn_startmove:setBright(false)
	-- 		move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_NO_TARGET_CID
	-- 	else
	-- 		if userData.getYuanbao() < MOVE_MAIN_CITY_YUBAO_COST  then 
	-- 			btn_startmove:setBright(false)
	-- 			move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_GOLD_NOT_ENOUGH
	-- 		else
	-- 			btn_startmove:setBright(true)

	-- 		end
	-- 	end
	-- end
	btn_startmove:setBright(true)

	--未选择城市
	if not m_iSelectedCityWid then 
		btn_startmove:setBright(false)
		move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_NO_TARGET_CID
		return
	end


	-- 迁城CD中
	if getCountDownCD() > 0 then 
		move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_CD
		btn_startmove:setBright(false)
		return 
	end

	-- 目标城市正在放弃
	local cityInfo = userCityData.getUserCityData(wid)
    if cityInfo and  cityInfo.state == cityState.removing then 
    	move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_TARGET_CITY_IS_REMOVING
		btn_startmove:setBright(false)
		return
	end

	-- 玩家已被附属
	if userData.getAffilated_union_id() ~= 0 then 
		move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_USERCITY_IS_OCCUPIED
		btn_startmove:setBright(false)
		return
	end
	-- 还有未完成的建造队列
	local tab_freeQueue = politics.getBuildingBuildListInCity(userData.getMainPos(),1)
    local tab_tempQueue = politics.getBuildingBuildListInCity(userData.getMainPos(),2)

	if #tab_freeQueue > 0 or  #tab_tempQueue > 0 then 
		move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_HAS_UNFINISHED_BUILDING
		btn_startmove:setBright(false)
		return
	end

	-- 还有未返城的部队
	
	local temp_army_info = nil
	for k,v in pairs(armyData.getAllArmyInCity( userData.getMainPos() )) do 
        temp_army_info = armyData.getTeamMsg(v)
        if temp_army_info then 
            if temp_army_info.state ~= armyState.normal then
            	move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_HAS_ARMY_OUTSIDE
				btn_startmove:setBright(false)
            end
        end
    end

    local leave_nums = userCityData.get_leave_zb_queue_in_city(userData.getMainPos())
	local all_queue_num = userCityData.get_all_zb_queue_num(userData.getMainPos())

	-- 还有未完成的征兵队列
	if leave_nums ~= all_queue_num then
		move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_HAS_ARMY_RECRUIT
		btn_startmove:setBright(false)
		return
	end
	-- 元宝不足
	if userData.getYuanbao() < MOVE_MAIN_CITY_YUBAO_COST  then 
		move_btn_unable_type = MOVE_BTN_UNABLE_TYPE_GOLD_NOT_ENOUGH
		btn_startmove:setBright(false)
		return
	end
end

local function offsetLayoutView()
	if not m_pMainWidget then return end

	local panel_city_selected = uiUtil.getConvertChildByName(m_pMainWidget,"panel_city_selected")
	local panel_count_down = uiUtil.getConvertChildByName(m_pMainWidget,"panel_count_down")

	if getCountDownCD() > 0 then 
		panel_city_selected:setVisible(false)
		panel_city_selected:setTouchEnabled(false)
		panel_count_down:setVisible(true)
		updateCountDownTime()
	else
		panel_city_selected:setVisible(true)
		panel_city_selected:setTouchEnabled(true)
		panel_count_down:setVisible(false)
	end
	checkBtnStates()
	checkCostState()


	local label_tips = uiUtil.getConvertChildByName(panel_city_selected,"label_tips")
	local label_city_coordinate = uiUtil.getConvertChildByName(panel_city_selected,"label_city_coordinate")
	local label_city_name = uiUtil.getConvertChildByName(panel_city_selected,"label_city_name")
	label_tips:setVisible(false)
	label_city_coordinate:setVisible(false)
	label_city_name:setVisible(false)
	if not m_iSelectedCityWid then 
		label_tips:setVisible(true)
	else
		label_city_coordinate:setVisible(true)
		label_city_name:setVisible(true)

		
	    local coor_x = math.floor(m_iSelectedCityWid / 10000)
	    local coor_y = m_iSelectedCityWid % 10000
	    label_city_coordinate:setText("(" .. coor_x .. "," .. coor_y .. ")")

	    local target_wid_info = landData.get_world_city_info(m_iSelectedCityWid)
        local target_name = target_wid_info.name

    	label_city_name:setText(target_name)
	end
end


local function doReloadData()
	offsetLayoutView()
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

local function reloadData()
	disposeSchedulerHandler()

	if getCountDownCD() > 0 then 
		activeSchedulerHandler()
	end

	doReloadData()

end



function userOfficialMoveCity.onSelectedTargetCityWid(cityWid)
	if not m_pMainWidget then return end
	if cityWid == m_iSelectedCityWid then return end
	m_iSelectedCityWid = cityWid
	reloadData()
end


local function handleOpenCitySelectList()
	require("game/option/userOfficialMoveCitySelectCity")
	UserOfficialMoveCitySelectCity.create()
end


local function handleRequestMoveCity()
	if not m_iSelectedCityWid then return end

 	userData.setMainPos(m_iSelectedCityWid)
	Net.send(MOVE_MAIN_CITY,{m_iSelectedCityWid})
	m_iSelectedCityWid = nil


	-- 地表上相关的信息
	MapLandInfo.removeAll()
	MapArmyWarStatus.removeAll()
	-- 屯田
	MapFarming.removeAll()
	-- 练兵
	MapTraining.removeAll()
end
local function initOperateEvents()
	if not m_pMainWidget then return end

	local panel_city_selected = uiUtil.getConvertChildByName(m_pMainWidget,"panel_city_selected")
	panel_city_selected:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			handleOpenCitySelectList()
        end
	end)


	local btn_city_selected = uiUtil.getConvertChildByName(panel_city_selected,"btn_city_selected")
	btn_city_selected:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			handleOpenCitySelectList()
        end
	end)

	local btn_startmove = uiUtil.getConvertChildByName(m_pMainWidget,"btn_startmove")
	btn_startmove:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			if not move_btn_unable_type then 
				handleRequestMoveCity()
			else
				if move_btn_unable_type == MOVE_BTN_UNABLE_TYPE_GOLD_NOT_ENOUGH then 
					-- TODOTK 中文收集
					alertLayer.create(errorTable[2024],nil,function()
                        PayUI.create()
                    end)
                    comAlertConfirm.setBtnTitleText("前往充值","取消")
                else
                	tipsLayer.create(moveBtnUnableTipsTab[move_btn_unable_type])
                end
			end
		end
	end)
end

local function onRequestMoveMainCity()
	--TODOTK 中文收集
	tipsLayer.create('迁城成功')
	m_iSelectedCityWi = nil
	reloadData()

	-- 地表上相关的信息
	MapLandInfo.reloadAll()
	MapArmyWarStatus.reloadAll()
	-- 屯田
	MapFarming.createAll()
	-- 练兵
	MapTraining.createAll()
	

	mapController.jump(math.floor(userData.getMainPos()/10000),math.floor(userData.getMainPos()%10000))
end

local function removeNetObserver()
	netObserver.removeObserver(MOVE_MAIN_CITY)
	UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, checkCostState)
end

local function addNetObserver()
	netObserver.addObserver(MOVE_MAIN_CITY,onRequestMoveMainCity)

	UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, checkCostState)
end



local function create()

	m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/qianchenglengque.json")
	initOperateEvents()
	addNetObserver()
	reloadData()
end



function userOfficialMoveCity.remove_self( )
	if m_pMainWidget then
		removeNetObserver()
		disposeSchedulerHandler()

		m_pMainWidget:removeFromParentAndCleanup(true)
		m_pMainWidget = nil

		m_iSelectedCityWid = nil
	end
end


function userOfficialMoveCity.getInstance()
    create()
    return m_pMainWidget
end


function userOfficialMoveCity.setEnabled(flag,callback)
	if not m_pMainWidget then return end

	m_pMainWidget:setVisible(flag)

	if flag then 
		uiUtil.showScaleEffect(m_pMainWidget,callback,0.5,nil,nil)
	else
        uiUtil.hideScaleEffect(m_pMainWidget,callback,0.5)
    end
end
return userOfficialMoveCity