local uiDailyForcesFunds = {}
local loginRewardHelper = require("game/daily/login_reward_helper")

local m_pMainWidget = nil


local tv_list = nil
local list_data = nil
local list_rewards = nil
local list_finish_info = nil
local list_rewards_info = nil
local cell_default_height = nil
local cell_default_width = nil

local flag_is_pay_match_condition = nil

local lst_received_rewards_indx = nil


local flag_has_rewards_can_received = nil

function uiDailyForcesFunds.remove()
	if not m_pMainWidget then return end
	m_pMainWidget:removeFromParentAndCleanup(true)
	m_pMainWidget = nil
	tv_list = nil
	flag_is_pay_match_condition = nil
	list_data = nil
	list_rewards = nil
	list_finish_info = nil
	list_rewards_info = nil
	lst_received_rewards_indx = nil
	flag_has_rewards_can_received = nil

	netObserver.removeObserver(ACTIVITY_GET_REWARD)
end




local function resetData()
	list_data = DailyDataModel.getActivityConditions(DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS)
	list_rewards = DailyDataModel.getActivityRewards(DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS)
	list_finish_info = DailyDataModel.getActivityConditionsFinishInfo(DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS)
	list_rewards_info = DailyDataModel.getActivityRewardsReceivedInfo(DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS)

	flag_has_rewards_can_received = false
	for k,v in pairs(list_finish_info) do 
		if v == 1 and list_rewards_info[k] == 0  then 
			flag_has_rewards_can_received = true
		end
	end
end

function uiDailyForcesFunds.hasRewardsCanReceived()
	if flag_has_rewards_can_received == nil then
		resetData()
	end
	return flag_has_rewards_can_received
end







function uiDailyForcesFunds.reloadData(activityInfo,needReloadList)
	if not m_pMainWidget then return end

	resetData()

	if tv_list then
		if needReloadList == true then
			tv_list:reloadData()
		else
			uiDailyForcesFunds.refreshAllCell()
		end
	end


	local paid_num = 0
	local flag_is_pay_match_condition,paid_num = DailyDataModel.isActivityConditionsActived(DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS)
	



	local btn_goto_pay = uiUtil.getConvertChildByName(m_pMainWidget,"btn_goto_pay")
	btn_goto_pay:setTouchEnabled(false)
	btn_goto_pay:setVisible(false)


	local img_paid_match_condition = uiUtil.getConvertChildByName(m_pMainWidget,"img_paid_match_condition")
	img_paid_match_condition:setVisible(false)

	if flag_is_pay_match_condition then 
		img_paid_match_condition:setVisible(true)
	else
		btn_goto_pay:setVisible(true)
		btn_goto_pay:setTouchEnabled(true)
		btn_goto_pay:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then
				require("game/pay/payUI")
				PayUI.create()
			end	
		end)

		local label_paid = uiUtil.getConvertChildByName(btn_goto_pay,"label_paid")
		local label_time = uiUtil.getConvertChildByName(btn_goto_pay,"label_time")
		local activityInfo = nil
		for k,v in pairs(DailyDataModel.getDailyActivityList()) do 
			if v.activity_type == DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS then
				activityInfo = v
			end
		end
		label_time:setFontName(config.getFontName())
		if activityInfo then
			label_time:setText(DailyDataModel.getActivityTimeDesc(activityInfo))
		else
			label_time:setText(" ")
		end

		
		label_paid:setText(string.format('已充值%d元',paid_num))
	end

end

local function tableCellHightlight(table,cell)
    -- local idx = cell:getIdx()
    -- local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    -- local cellWidget = nil
    -- cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
end
    
 

local function tableCellUnhightlight(table,cell)
    -- local idx = cell:getIdx()
    -- local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    -- local cellWidget = nil
    -- cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
end

local function tableviewScroll(view)
	if not m_pMainWidget then return end
	local instance = m_pMainWidget
    local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
    local img_drag_flag_up = uiUtil.getConvertChildByName(instance,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(instance,"down_img")

    if tv_list:getContentOffset().y < 0 then 
        img_drag_flag_down:setVisible(true)
    else
        img_drag_flag_down:setVisible(false)
    end

    if tv_list:getContentOffset().y > -(#list_data * cell_default_height - panel_list:getSize().height) then 
        img_drag_flag_up:setVisible(true)
    else
        img_drag_flag_up:setVisible(false)
    end
end

local function numberOfCellsInTableView()
    return #list_data
end


local function cellSizeForTable(table,idx)
    return cell_default_height,cell_default_width
end


local function tableCellTouched(table,cell)
    --local idx = cell:getIdx()
    --local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    --local cellWidget = nil
    --local btn_cell = nil
    --cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
end



local function requestReceiveRewards(rewards_indx)
	lst_received_rewards_indx = rewards_indx
	Net.send(ACTIVITY_GET_REWARD,{DailyDataModel.getActivityIdu(DailyDataModel.ACTIVITY_TYPE_FORCES_FUNDS) ,rewards_indx})
end

local function setCellWidget(indx,cellWidget)
    local vo = list_data[indx + 1]
	local reward_vo = list_rewards[indx+1]

	local forces_val = 0
	for k,v in pairs(vo) do 
		if v[1] == 53 then 
			forces_val = v[2]
		end
	end
	local label_desc = uiUtil.getConvertChildByName(cellWidget,"label_desc")
	label_desc:setText(string.format('个人势力值达到%d',forces_val))

	
	local rewards_count = 0
	local pos_x = 0
	local rewardWidget = nil

	for k,v in pairs(reward_vo) do
		rewards_count = rewards_count + 1
		
		rewardWidget = uiUtil.getConvertChildByName(cellWidget,"reward_item_" .. rewards_count)

		local rewardType = v[1]
        local rewardNum = v[2]

		if not rewardWidget then
			rewardWidget = GUIReader:shareReader():widgetFromJsonFile("test/login_reward_cell.json")
			cellWidget:addChild(rewardWidget)
			
		end
		
		pos_x =  (rewards_count - 1) * rewardWidget:getContentSize().width + 15
		rewardWidget:setPositionX(pos_x)
		rewardWidget:setPositionY(10)

		loginRewardHelper.setRewardWidgetLayout(rewardWidget,rewardType,rewardNum)

		local label_num = uiUtil.getConvertChildByName(rewardWidget,"label_num")
		local label_detail = uiUtil.getConvertChildByName(rewardWidget,"label_detail")
		local bg_num = uiUtil.getConvertChildByName(rewardWidget,"bg_num")
		bg_num:setVisible(true)
		label_num:setVisible(false)
		label_detail:setVisible(false)
		
		rewardWidget:setTouchEnabled(true)
        rewardWidget:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                require("game/daily/ui_reward_detail")
                UIRewardDetail.create(rewardType,rewardNum)
            end
        end)
	end

	label_desc:setPositionX(pos_x + rewardWidget:getContentSize().width + 10)

	local label_received = uiUtil.getConvertChildByName(cellWidget,"label_received")
	label_received:setVisible(false)

	local btn_receive_reward = uiUtil.getConvertChildByName(cellWidget,"btn_receive_reward")
	btn_receive_reward:setVisible(false)
	btn_receive_reward:setTouchEnabled(false)

	local flag_is_received = list_rewards_info[indx+1] == 1
	local flag_can_receive = list_finish_info[indx+1] == 1

	if flag_can_receive then
		label_desc:setColor(ccc3(227,182,64))
	else
		label_desc:setColor(ccc3(141,138,132))
	end


	if flag_is_received then 
		label_received:setVisible(true)
	else
		btn_receive_reward:setVisible(true)
		btn_receive_reward:setTouchEnabled(true)

		if flag_can_receive then
			btn_receive_reward:setBright(true)
			btn_receive_reward:setTitleColor(ccc3(83,18,0))
		else
			btn_receive_reward:setBright(false)
			btn_receive_reward:setTitleColor(ccc3(36,29,27))
		end

		btn_receive_reward:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then
				if flag_can_receive then 
					requestReceiveRewards(indx + 1)
				else
					tipsLayer.create("未达到领取条件")
				end
			end
		end)
	end

	
end


local function refreshCell(indx)

    if not tv_list then return end
    
    local cell = tv_list:cellAtIndex(indx)
    if not cell then return end
    
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(indx,cellWidget)
    end  
end

function uiDailyForcesFunds.refreshAllCell()
	if not m_pMainWidget then return end
	
    if not list_data then return end
    for i = 1 ,#list_data do 
        refreshCell(i - 1)
    end
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    
    if cell == nil then
        cell = CCTableViewCell:new()
        local cellLayer = TouchGroup:create()
        cellLayer:setTag(1)
        cell:addChild(cellLayer)

        local instance = m_pMainWidget
        local panel_list = uiUtil.getConvertChildByName(instance,"panel_list")
        local panel_item = uiUtil.getConvertChildByName(panel_list,"panel_item")
        cellWidget = panel_item:clone()
        cellWidget:setVisible(true)
        cellLayer:addWidget(cellWidget)
        cellWidget:setPosition(cc.p(0,0))
        cellWidget:setTag(10)
	end
    local cellWidget = nil
    local cellLayer = tolua.cast(cell:getChildByTag(1),"TouchGroup")
    if cellLayer then
        cellWidget = tolua.cast(cellLayer:getWidgetByTag(10),"Layout")
        setCellWidget(idx,cellWidget)
    end
    
    return cell
end

local function init()
	if not m_pMainWidget then return end
	local mainWidget = m_pMainWidget

	local panel_list = uiUtil.getConvertChildByName(mainWidget,"panel_list")
   	panel_list:setBackGroundColorType(LAYOUT_COLOR_NONE)
   	local panel_item = uiUtil.getConvertChildByName(panel_list,"panel_item")
   	panel_item:setBackGroundColorType(LAYOUT_COLOR_NONE)
   	panel_item:setVisible(false)
    local img_drag_flag_up = uiUtil.getConvertChildByName(mainWidget,"up_img")
    local img_drag_flag_down = uiUtil.getConvertChildByName(mainWidget,"down_img")
	img_drag_flag_up:setVisible(false)
	img_drag_flag_down:setVisible(false)
    breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
	
	cell_default_height = panel_item:getContentSize().height
	cell_default_width = panel_item:getContentSize().width

    tv_list = CCTableView:create(CCSizeMake(panel_list:getContentSize().width,panel_list:getContentSize().height))
 	panel_list:addChild(tv_list)
 	tv_list:setDirection(kCCScrollViewDirectionVertical)
 	tv_list:setVerticalFillOrder(kCCTableViewFillTopDown)
	tv_list:ignoreAnchorPointForPosition(false)
	tv_list:setAnchorPoint(cc.p(0.5,0.5))
	tv_list:setPosition(cc.p(panel_list:getContentSize().width/2,panel_list:getContentSize().height/2))
	tv_list:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tv_list:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tv_list:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tv_list:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    tv_list:registerScriptHandler(tableCellHightlight,CCTableView.kTableCellHighLight)
    tv_list:registerScriptHandler(tableCellUnhightlight,CCTableView.kTableCellUnhighLight)
    tv_list:registerScriptHandler(tableviewScroll,CCTableView.kTableViewScroll)
end


local function responeReceiveRewards(package)
	if not m_pMainWidget then return end
	if package == 1 then
		vo = list_rewards[lst_received_rewards_indx]
		
		local arrTemp = {}
		local name = nil
		local count = nil
		for i,v in ipairs(vo) do
			name = clientConfigData.getDorpName(v[1]) 
			count = clientConfigData.getDorpCount(v[1], v[2] )
			table.insert(arrTemp,languagePack["huode"]..name.." "..count)
		end
		if #arrTemp > 0 then
			taskTipsLayer.create(arrTemp)
		end
	end
end
local function create()
	if m_pMainWidget then return end

	m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/huodong_4.json")

	
	init()

	uiDailyForcesFunds.reloadData(nil,true)

	netObserver.addObserver(ACTIVITY_GET_REWARD,responeReceiveRewards)
	return m_pMainWidget
end


function uiDailyForcesFunds.getInstance()
	create()
	return m_pMainWidget
end


return uiDailyForcesFunds
