--税收界面
module("TaxUI", package.seeall)
local m_pMainWidget = nil
local m_sched_timer = nil
local m_bNotFirst_open = nil

local m_iCountLeftTax = nil -- 剩余多少次税收
local m_iCountLeftTaxForce = nil -- 剩余多少次强制
local m_iCurTaxNum = nil -- 当前税收收益
local m_iCurTaxNumForce = nil -- 当前强征收益

local m_iNonForcedGuideId = nil

local function deleteTime( )
	if m_sched_timer then
		scheduler.remove(m_sched_timer)
		m_sched_timer = nil
	end
end


local function onRequestRevenue(param)
	if param == 1 then 
		tipsLayer.create(languagePack["taxForceRevenue_rewardTips"],nil,{m_iCurTaxNumForce})
	end
end



function remove_self( )
	if m_pMainWidget then
		deleteTime( )
		m_pMainWidget:removeFromParentAndCleanup(true)
		m_pMainWidget = nil
		m_bNotFirst_open = nil

		m_iCountLeftTax = nil
		m_iCountLeftTaxForce = nil
		m_iCurTaxNum = nil
		m_iCurTaxNumForce = nil

		netObserver.removeObserver(REVENUE,onRequestRevenue)
		netObserver.removeObserver(REVENUE_CLEAR_CD,TaxUI.onRequestClearCD)
		netObserver.removeObserver(NOTIFY_MIDNIGHT,TaxUI.taxChange)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.update, TaxUI.taxChange)
    	UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.add, TaxUI.taxChange)
    	UIUpdateManager.remove_prop_update(dbTableDesList.user_revenue.name, dataChangeType.remove, TaxUI.taxChange)
    	UIUpdateManager.remove_prop_update(dbTableDesList.user.name, dataChangeType.update, TaxUI.userGoldChanged)
    	
	end
end

-- 判断是否是同一天
local function isSameDay(timeStampA,timeStampB)
    local dateA =  os.date("*t",timeStampA)
    local dateB = os.date("*t",timeStampB)

    return dateA.year == dateB.year and dateA.month == dateB.month and dateA.day == dateB.day
end


function taxChange( )
	if not m_pMainWidget then return end
	local temp_widget = m_pMainWidget
	local leftTime = tolua.cast(temp_widget:getChildByName("Panel_376142"),"Layout")
	leftTime:setVisible(false)
	local btn_clear = tolua.cast(leftTime:getChildByName("btn_clear"),"Button")
	
	btn_clear:setEnabled(false)

	local taxbtn = tolua.cast(temp_widget:getChildByName("btn_ok_0"),"Button")
	taxbtn:setEnabled(false)

	local btn_force_tax = tolua.cast(temp_widget:getChildByName("btn_force_tax"),"Button")
	btn_force_tax:setEnabled(false)
	local panel_force_tax = tolua.cast(temp_widget:getChildByName("panel_force_tax"),"Layout")
	panel_force_tax:setVisible(false)
	local label_force_tax_count = tolua.cast(panel_force_tax:getChildByName("label_count"),"Label")
	
	deleteTime( )
	
	m_iCountLeftTaxForce = 0

	for i, v in pairs(allTableData[dbTableDesList.user_revenue.name]) do
		if v.userid == userData.getUserId() then
			m_iCountLeftTaxForce = v.force_count
		end
	end

	m_iCountLeftTaxForce = REVENUE_FORCE_COUNT_A_DAY - m_iCountLeftTaxForce

	local temp = {}
	for i, v in pairs(allTableData[dbTableDesList.user_revenue.name]) do
        if v.userid == userData.getUserId() then
        	temp = stringFunc.anlayerMsg(v.revenue_info)
        	if not isSameDay(v.revenue_time,userData.getServerTime()) then 
        		temp = {}
        	end

        	if  (userData.getServerTime() - v.revenue_time <= REVENUE_CD and #temp > 0 and #temp<REVENUE_COUNT_A_DAY ) then
        		m_sched_timer = scheduler.create(function ( )
        			--过了12点
        			if userData.getServerTime() - v.revenue_time <= REVENUE_CD then
		        		leftTime:setVisible(true)
		        		btn_clear:setEnabled(true)
		        		if #temp>=REVENUE_COUNT_A_DAY or os.date("%d", v.revenue_time+REVENUE_CD) ~= os.date("%d", userData.getServerTime()) then
		        			local time = 24*3600 - tonumber(os.date("%H",userData.getServerTime()))*3600 - tonumber(os.date("%M",userData.getServerTime()))*60-tonumber(os.date("%S",userData.getServerTime()))
		        			tolua.cast(leftTime:getChildByName("Label_373107_0"),"Label"):setText(commonFunc.format_day(time))
		        		else
		        			tolua.cast(leftTime:getChildByName("Label_373107_0"),"Label"):setText(commonFunc.format_day(v.revenue_time+REVENUE_CD-userData.getServerTime()))
		        		end
		        	else
		        		deleteTime()
		        		taxChange( )
		        	end
        		end,0.2)

        	else

        		if #temp >= REVENUE_COUNT_A_DAY then 
        			leftTime:setVisible(false)
		        	btn_clear:setEnabled(false)
		        	panel_force_tax:setVisible(true)
		        	

		        	label_force_tax_count:setText(m_iCountLeftTaxForce)

		        	if m_iCountLeftTaxForce > 0 then 
		        		btn_force_tax:setEnabled(true)
		        		panel_force_tax:setPositionY(75)
		        	else
		        		panel_force_tax:setPositionY(50)
		        	end
        		else
        			taxbtn:setEnabled(true)
        		end
        	end
        end
    end
    if #temp == 0 then
    	taxbtn:setEnabled(true)
    end

    local widget = tolua.cast(temp_widget:getChildByName("Panel_376129"),"Layout")
    widget:setVisible(false)
    local cloneWidget = nil
    local flag = true
    for i=1, 3 do
    	local btn = tolua.cast(temp_widget:getChildByName("Button_"..i),"Button")
    	local finish = tolua.cast(btn:getChildByName("finish_"..i),"ImageView")
    	local unfinish = tolua.cast(btn:getChildByName("unfinish_"..i),"ImageView")
    	local panel = tolua.cast(btn:getChildByName("Panel_"..i),"Layout")
    	panel:removeAllChildrenWithCleanup(true)
    	if temp[i] then
    		finish:setVisible(true)
    		unfinish:setVisible(false)
    		cloneWidget = widget:clone()
    		cloneWidget:setVisible(true)
    		panel:addChild(cloneWidget)
    		cloneWidget:setPosition(cc.p(0,0))
    		tolua.cast(cloneWidget:getChildByName("Label_235663_0_1"),"Label"):setText(os.date("%X",temp[i][1]))
    		tolua.cast(cloneWidget:getChildByName("Label_235663_0"),"Label"):setText(temp[i][2])
    	else
    		finish:setVisible(false)
    		unfinish:setVisible(true)
    		if not flag or not taxbtn:isEnabled() then
    			GraySprite.create(unfinish)
    		end
    		flag = false
    	end


    	if #temp == i and m_bNotFirst_open and tonumber(temp[i][2]) > 0 then
    		finish:setScale(2)
    		finish:runAction(CCEaseExponentialIn:create(CCScaleTo:create(0.2,1)))
    		tipsLayer.create(errorTable[106], nil, {temp[i][2]})
    	end
    end

 --    if m_bNotFirst_open and m_iCountLeftTax <= 0  then
	-- 	tipsLayer.create(errorTable[106], nil, {m_iCurTaxNumForce})
	-- end

    m_iCountLeftTax = REVENUE_COUNT_A_DAY - #temp

    m_bNotFirst_open = nil
end

function onRequestClearCD()
	taxChange()
end

local function checkUserGold()
	if not m_pMainWidget then return end
	local leftTime = tolua.cast(m_pMainWidget:getChildByName("Panel_376142"),"Layout")
	local btn_clear = tolua.cast(leftTime:getChildByName("btn_clear"),"Button")
	local btn_force_tax = tolua.cast(m_pMainWidget:getChildByName("btn_force_tax"),"Button")

	local label_title = nil
	local label_cost = nil

	label_title = uiUtil.getConvertChildByName(btn_clear,"label_title")
	label_cost = uiUtil.getConvertChildByName(btn_clear,"label_cost")
	label_cost:setText(REVENUE_CLEAR_CD_MONEY)
	if userData.getYuanbao() < REVENUE_CLEAR_CD_MONEY then 
		label_title:setColor(ccc3(181,48,31))
		label_cost:setColor(ccc3(181,48,31))
	else
		label_title:setColor(ccc3(83,18,0))
		label_cost:setColor(ccc3(83,18,0))
	end

	label_title = uiUtil.getConvertChildByName(btn_force_tax,"label_title")
	label_cost = uiUtil.getConvertChildByName(btn_force_tax,"label_cost")
	label_cost:setText(REVENUE_FORCE_MONEY)
	if userData.getYuanbao() < REVENUE_FORCE_MONEY then 
		label_title:setColor(ccc3(181,48,31))
		label_cost:setColor(ccc3(181,48,31))
	else
		label_title:setColor(ccc3(83,18,0))
		label_cost:setColor(ccc3(83,18,0))
	end
end
function userGoldChanged(package)
	if package and package.yuan_bao_cur then
		checkUserGold()
	end
end

function activeNonForceGuide(guide_id)
	m_iNonForcedGuideId = guide_id
end

function create( )
	if m_pMainWidget then return end
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Tax_2.json")
	m_pMainWidget = widget


	local taxbtn = tolua.cast(widget:getChildByName("btn_ok_0"),"Button")
	taxbtn:setVisible(true)
	taxbtn:setEnabled(false)
	taxbtn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			Net.send(REVENUE,{0})
			m_bNotFirst_open = true
			if m_iNonForcedGuideId == com_guide_id_list.CONST_GUIDE_2008 then 
				-- CCUserDefault:sharedUserDefault():setStringForKey(userData.getUserId().."ID2008", "1")
				CCUserDefault:sharedUserDefault():setStringForKey("ID2006", "1")
				m_iNonForcedGuideId = nil
			end
		end
	end)

	local btn_tips = uiUtil.getConvertChildByName(widget,"btn_tips")
	btn_tips:setTouchEnabled(true)
	btn_tips:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			require("game/option/ui_tax_statistical_info")
			UITaxStatisticalInfo.create()
		end
	end)
	local selfCommonRes = politics.getSelfRes()
    m_iCurTaxNum = selfCommonRes.login_money
    m_iCurTaxNumForce = selfCommonRes.login_money


	local leftTime = tolua.cast(widget:getChildByName("Panel_376142"),"Layout")
	local btn_clear = tolua.cast(leftTime:getChildByName("btn_clear"),"Button")
	btn_clear:setVisible(true)
	btn_clear:setEnabled(false)
	btn_clear:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			
			local callback = function()
				if userData.getYuanbao() < REVENUE_CLEAR_CD_MONEY then 
					-- 元宝不足
					alertLayer.create(errorTable[2042],nil,function()
						require("game/pay/payUI")
            			PayUI.create()
					end,{{REVENUE_CLEAR_CD_MONEY}})

					comAlertConfirm.setBtnTitleText(languagePack['goto_pay'],languagePack['cancel'])
					return 
				end

				


				Net.send(REVENUE_CLEAR_CD)
			end
			-- local content = "是否确认花费" .. REVENUE_CLEAR_CD_MONEY .."玉符，立即完成税收"
			-- local tip = "立即税收可获得" .. m_iCurTaxNum .. "铜钱，税收还剩余" .. m_iCountLeftTax .."次"
			-- comAlertConfirm.setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL)
			-- comAlertConfirm.show(languagePack["queren"],content,nil,{tip},nil,callback)
			callback()
		end
	end)

	local btn_force_tax = tolua.cast(widget:getChildByName("btn_force_tax"),"Button")
	btn_force_tax:setVisible(true)
	btn_force_tax:setEnabled(false)
	btn_force_tax:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			
			local callback = function()
				if userData.getYuanbao() < REVENUE_FORCE_MONEY then 
					-- 元宝不足
					alertLayer.create(errorTable[2043],nil,function()
						require("game/pay/payUI")
            			PayUI.create()
					end,{{REVENUE_FORCE_MONEY}})

					comAlertConfirm.setBtnTitleText(languagePack['goto_pay'],languagePack['cancel'])
					return 
				end
				Net.send(REVENUE,{1})
			end
			-- local content = "是否确认花费" .. REVENUE_FORCE_MONEY .."玉符，强征税收"
			-- local tip = "强征税收可获得" .. m_iCurTaxNumForce .."铜钱，还可强征" .. m_iCountLeftTaxForce .."次"
			-- comAlertConfirm.setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL)
			-- comAlertConfirm.show(languagePack["queren"],content,nil,{tip},nil,callback)

			callback()
		end
	end)
	
	netObserver.addObserver(REVENUE,onRequestRevenue)
	netObserver.addObserver(REVENUE_CLEAR_CD,TaxUI.onRequestClearCD)
	netObserver.addObserver(NOTIFY_MIDNIGHT,TaxUI.taxChange)

	taxChange()
	
	UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.update, TaxUI.taxChange)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.add, TaxUI.taxChange)
    UIUpdateManager.add_prop_update(dbTableDesList.user_revenue.name, dataChangeType.remove, TaxUI.taxChange)

    UIUpdateManager.add_prop_update(dbTableDesList.user.name, dataChangeType.update, TaxUI.userGoldChanged)

    if taxbtn:isEnabled() and m_iNonForcedGuideId == com_guide_id_list.CONST_GUIDE_2008  then 
 		comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2008)
 	end

    checkUserGold()
end

function getInstance()
    create()
    return m_pMainWidget
end


function setEnabled(flag,callback)
	if not m_pMainWidget then return end

	m_pMainWidget:setVisible(flag)

	if flag then 
		uiUtil.showScaleEffect(m_pMainWidget,callback,0.5,nil,nil)
	else
        uiUtil.hideScaleEffect(m_pMainWidget,callback,0.5)
    end
end
