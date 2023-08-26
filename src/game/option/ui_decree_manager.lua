module("UIDecreeManager",package.seeall)
-- 政令管理  购买政令等
-- 类名 UIDecreeManager
-- json名 maizhengling.json
-- 配置ID UI_DECREE_MANAGER


--[[
// 消费
 /** 每天可购买政令的次数 */
 public static final int CONSUME_DECREE_DAILY_COUNT = 2;
 /** 每次可购买政令的个数 */
 public static final int CONSUME_DECREE_NUM = 5;
 /** 每个政令的价格 */
 public static final int CONSUME_DECREE_COST_YUANBAO = 10;

CONSUME_BUY_DECREE = 860; // 购买政令
]]
local m_pMainLayer = nil

local schedulerHandler = nil

local flag_decree_is_max = nil  -- 政令数是否达到上限
local flag_has_buy_count_left = nil -- 是否还有剩余的购买次数

local function disposeSchedulerHandler()
	if schedulerHandler then 
		scheduler.remove(schedulerHandler)
		schedulerHandler = nil
	end
end


local function do_remove_self()
	if m_pMainLayer then 
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UI_DECREE_MANAGER)
		
		disposeSchedulerHandler()
		UIUpdateManager.remove_prop_update(dbTableDesList.user_farm.name, dataChangeType.update, UIDecreeManager.reloadData)
	end
end


function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.UI_DECREE_MANAGER, m_pMainLayer, do_remove_self, 999)	
end


function dealwithTouchEvent(x,y)
	if not m_pMainLayer then return false end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return false end
	if widget:hitTest(cc.p(x,y)) then 
		return false
	else
		remove_self()
		return true
	end
end



-- 判断是否是同一天
local function isSameDay(timeStampA,timeStampB)
    local dateA =  os.date("*t",timeStampA)
    local dateB = os.date("*t",timeStampB)

    return dateA.year == dateB.year and dateA.month == dateB.month and dateA.day == dateB.day
end


local function getBuyCountDailyLimit()
	return CONSUME_DECREE_DAILY_COUNT
end

local function getBuyCountUsed()
	local used = 0
	local next_decree_refresh_time = 0
	for k,v in pairs(allTableData[dbTableDesList.user_consume.name]) do 
		used = v.decree_buy_count
		next_decree_refresh_time = v.next_decree_refresh_time
	end
	
	
	if userData.getServerTime() > next_decree_refresh_time then 
		-- 服务端数据还没刷新（要么就是服务端数据错乱了）
		used = 0
	end
	
	return used
end

local function getDecreeRecoverCD()
	return userData.getUserDecreeCD()
end

local function getDecreeNum()
	return userData.getUserDecreeNum()
end

local function autoLayout()
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end

	local btn_add = uiUtil.getConvertChildByName(widget,"btn_add")
	local panel_cd = uiUtil.getConvertChildByName(widget,"panel_cd")
	local panel_max_tips = uiUtil.getConvertChildByName(widget,"panel_max_tips")
	local panel_add_limit_tips = uiUtil.getConvertChildByName(widget,"panel_add_limit_tips")
	local panel_add_count_left = uiUtil.getConvertChildByName(widget,"panel_add_count_left")
	
	local layout_h = 140
	local layout_h_real = 0

	local layout_y = 150

	if panel_cd:isVisible() then
		layout_h_real = layout_h_real + panel_cd:getContentSize().height
	end
	
	if panel_max_tips:isVisible() then
		layout_h_real = layout_h_real + panel_max_tips:getContentSize().height
	end

	if panel_add_limit_tips:isVisible() then
		layout_h_real = layout_h_real + panel_add_limit_tips:getContentSize().height
	end


	if panel_add_count_left:isVisible() then
		layout_h_real = layout_h_real + panel_add_count_left:getContentSize().height
	end

	if btn_add:isVisible() then
		layout_h_real = layout_h_real + (btn_add:getContentSize().height - 20)
	end

	-------------
	
	layout_y = layout_y - ( layout_h - layout_h_real)/2
	
	print(">>>>>>>>>>>>>>>>>>>。。 ",layout_h_real,layout_y)
	if panel_cd:isVisible() then
		layout_y = layout_y - panel_cd:getContentSize().height
		panel_cd:setPositionY(layout_y)
	end
	if panel_max_tips:isVisible() then
		layout_y = layout_y - panel_max_tips:getContentSize().height
		panel_max_tips:setPositionY(layout_y)
	end
	if panel_add_limit_tips:isVisible() then
		layout_y = layout_y - panel_add_limit_tips:getContentSize().height
		panel_add_limit_tips:setPositionY(layout_y)
	end
	if panel_add_count_left:isVisible() then
		layout_y = layout_y - panel_add_count_left:getContentSize().height
		panel_add_count_left:setPositionY(layout_y)
	end

	if btn_add:isVisible() then
		layout_y = layout_y - (btn_add:getContentSize().height - 20) 
		btn_add:setPositionY(layout_y + (btn_add:getContentSize().height - 20)/2 )
	end
end
local function reloadData()
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end

	local btn_add = uiUtil.getConvertChildByName(widget,"btn_add")
	btn_add:setVisible(false)
	btn_add:setTouchEnabled(false)
	local panel_cd = uiUtil.getConvertChildByName(widget,"panel_cd")
	panel_cd:setVisible(false)
	local panel_max_tips = uiUtil.getConvertChildByName(widget,"panel_max_tips")
	panel_max_tips:setVisible(false)
	local panel_add_limit_tips = uiUtil.getConvertChildByName(widget,"panel_add_limit_tips")
	panel_add_limit_tips:setVisible(false)
	
	local panel_add_count_left = uiUtil.getConvertChildByName(widget,"panel_add_count_left")
	panel_add_count_left:setVisible(false)
	
	
	local curNum,maxNum = getDecreeNum()
	local cd = getDecreeRecoverCD()
	if cd >= 0 and (curNum <= maxNum) then
		flag_decree_is_max = false
	else
		flag_decree_is_max = true
	end

	if getBuyCountUsed() >= getBuyCountDailyLimit() then
		-- 购买数已用完
		flag_has_buy_count_left = false	
	else
		flag_has_buy_count_left = true
	end

	if flag_decree_is_max then 
		panel_max_tips:setVisible(true)
	else
		if cd > 0 then
			panel_cd:setVisible(true)
			local label_cd = uiUtil.getConvertChildByName(panel_cd,"label_cd")
			label_cd:setText(commonFunc.format_time(cd))
		end
	end
	
	if flag_has_buy_count_left then 
		btn_add:setVisible(true)
		btn_add:setTouchEnabled(true)
		local icon_gold = uiUtil.getConvertChildByName(btn_add,"icon_gold")
		local label_text = uiUtil.getConvertChildByName(btn_add,"label_text")
		local label_cost = uiUtil.getConvertChildByName(btn_add,"label_cost")

		label_cost:setText(CONSUME_DECREE_COST_YUANBAO * CONSUME_DECREE_NUM)
		if flag_decree_is_max then 
			btn_add:setBright(false)
			-- btn_add:setTitleColor(ccc3(45,45,45))

			label_text:setColor(ccc3(45,45,45))
			label_cost:setColor(ccc3(45,45,45))
			GraySprite.create(icon_gold)
		--elseif userData.getYuanbao() < CONSUME_DECREE_COST_YUANBAO then
		--	btn_add:setBright(false)
		--	btn_add:setTitleColor(ccc3(45,45,45))
		else
			btn_add:setBright(true)
			-- btn_add:setTitleColor(ccc3(83,18,0))

			if userData.getYuanbao() < CONSUME_DECREE_COST_YUANBAO * CONSUME_DECREE_NUM then
				label_text:setColor(ccc3(181,48,31))
				label_cost:setColor(ccc3(181,48,31))
			else
				label_text:setColor(ccc3(83,18,0))
				label_cost:setColor(ccc3(83,18,0))
			end
			GraySprite.create(icon_gold,nil,true)
		end

		panel_add_count_left:setVisible(true)
		local label_count = uiUtil.getConvertChildByName(panel_add_count_left,"label_count")
		label_count:setText((CONSUME_DECREE_DAILY_COUNT - getBuyCountUsed()))
	else
		panel_add_limit_tips:setVisible(true)
	end

	autoLayout()
end


local function updateScheduler()
	reloadData()
end

local function activeSchedulerHandler()
	disposeSchedulerHandler()
	schedulerHandler = scheduler.create(updateScheduler,1)
end



local function initView()
	if not m_pMainLayer then return end
	
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end
	
	local btn_close = uiUtil.getConvertChildByName(widget,"btn_close")
	btn_close:setVisible(true)
	btn_close:setTouchEnabled(true)
	btn_close:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			remove_self()
		end
	end)
	

	local btn_add = uiUtil.getConvertChildByName(widget,"btn_add")
	btn_add:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			if flag_decree_is_max then 
				alertLayer.create(errorTable[2031])
				return
			end
			if userData.getYuanbao() < CONSUME_DECREE_COST_YUANBAO * CONSUME_DECREE_NUM then
				-- 元宝不足
				alertLayer.create(errorTable[2033],nil,function()
						require("game/pay/payUI")
            			PayUI.create()
					end
					,{ {CONSUME_DECREE_NUM , CONSUME_DECREE_NUM * CONSUME_DECREE_COST_YUANBAO },{CONSUME_DECREE_DAILY_COUNT }  })

				comAlertConfirm.setBtnTitleText(languagePack['goto_pay'],languagePack['cancel'])
				return
			end

			-- alertLayer.create(errorTable[2034],{CONSUME_DECREE_COST_YUANBAO * CONSUME_DECREE_NUM,CONSUME_DECREE_NUM},function()
			-- 		Net.send(CONSUME_BUY_DECREE)	
			-- 	end,
			-- 	{{ (CONSUME_DECREE_DAILY_COUNT - getBuyCountUsed()) .. '/' .. CONSUME_DECREE_DAILY_COUNT }})
			
			Net.send(CONSUME_BUY_DECREE)
		end
	end)	

end


local function responeBuyDecree()
	alertLayer.create(errorTable[2032],{CONSUME_DECREE_NUM})
end


local function init()
	if not m_pMainLayer then return end
	initView()
	activeSchedulerHandler()
	reloadData()

	netObserver.addObserver(CONSUME_BUY_DECREE,responeBuyDecree)

end


function create()
	if m_pMainLayer then return end
	
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/maizhengling.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_DECREE_MANAGER)
	
	init()
	reloadData()

	uiManager.showConfigEffect(uiIndexDefine.UI_DECREE_MANAGER,m_pMainLayer)

	UIUpdateManager.add_prop_update(dbTableDesList.user_farm.name, dataChangeType.update, UIDecreeManager.reloadData)

end
