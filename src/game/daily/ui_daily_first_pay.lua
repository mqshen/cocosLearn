local uiDailyFirstPay = {}

local m_pMainWidget = nil


local loginRewardHelper = require("game/daily/login_reward_helper")


function uiDailyFirstPay.remove()
	if not m_pMainWidget then return end

	m_pMainWidget:removeFromParentAndCleanup(true)
	m_pMainWidget = nil

end


function uiDailyFirstPay.reloadData()
	if not m_pMainWidget then return end

end

local function init()
	if not m_pMainWidget then return end

	local panel_rewards = uiUtil.getConvertChildByName(m_pMainWidget,"panel_rewards")
	panel_rewards:setBackGroundColorType(LAYOUT_COLOR_NONE)

	local btn_charge = uiUtil.getConvertChildByName(m_pMainWidget,"btn_charge")
	btn_charge:setTouchEnabled(true)
	btn_charge:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
        	require("game/pay/payUI")
			PayUI.create()
		end
	end)


	local rewardList = Tb_cfg_activity[1].rewards[1]
	
	local rewardType = nil 
	local rewardNum = nil
	local rewardWidget = nil
	local pos_x = 0
	for k,v in pairs(rewardList) do 
		if rewardWidget then
			pos_x = pos_x + rewardWidget:getContentSize().width + 15
		end
		local rewardType = v[1]
        local rewardNum = v[2]

		rewardWidget = GUIReader:shareReader():widgetFromJsonFile("test/login_reward_cell.json")
		loginRewardHelper.setRewardWidgetLayout(rewardWidget,rewardType,rewardNum)

		local label_num = uiUtil.getConvertChildByName(rewardWidget,"label_num")
		local label_detail = uiUtil.getConvertChildByName(rewardWidget,"label_detail")
		label_num:setVisible(false)
		label_detail:setVisible(true)
		panel_rewards:addChild(rewardWidget)
		rewardWidget:setPositionX(pos_x)
		rewardWidget:setPositionY(10)
		rewardWidget:setTouchEnabled(true)
        rewardWidget:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                require("game/daily/ui_reward_detail")
                UIRewardDetail.create(rewardType,rewardNum)
            end
        end)

	end
end

local function create()
	if m_pMainWidget then return end

	m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/huodong_1.json")

	
	init()

	return m_pMainWidget
end


function uiDailyFirstPay.getInstance()
	create()
	return m_pMainWidget
end


return uiDailyFirstPay
