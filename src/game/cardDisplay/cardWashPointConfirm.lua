local main_layer = nil

local washAlertGoldCountDown = nil
local callback = nil
-- local costCoin = 0
local costGold = 0


local hero_uid = nil
local function dealwithTouchEvent(x,y)
	if not main_layer then
		return false
	end

	local temp_widget = main_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		return true
	end
end



local function remove()
	if not main_layer then return end
	main_layer:removeFromParentAndCleanup(true)
	main_layer = nil
	callback = nil
	costGold = 0
	-- costCoin = 0
    hero_uid = nil
	if washAlertGoldCountDown then 
        scheduler.remove(washAlertGoldCountDown)
        washAlertGoldCountDown = nil
    end

	uiManager.remove_self_panel(uiIndexDefine.CARD_WASH_POINT_CONFIRM)
end




local function removeWashAlertGoldCountDown()
    if washAlertGoldCountDown then 
        scheduler.remove(washAlertGoldCountDown)
        washAlertGoldCountDown = nil
    end
end


local function switchVisiblePanel(isCoinAble)
	local temp_widget = main_layer:getWidgetByTag(999)
	-- local panel_coin_unable = tolua.cast(temp_widget:getChildByName("panel_coin_unable"),"Layout")
	-- local panel_coin_unable = tolua.cast(temp_widget:getChildByName("Label_761499"),"Label")
	-- local des = tolua.cast(temp_widget:getChildByName("Label_761498"),"Label")
	local tips = tolua.cast(temp_widget:getChildByName("label_tips"),"Label")

	if isCoinAble then 
		tips:setText(languagePack["errorContentTips_134"])
	else
		tips:setText(languagePack["errorContentTips_133"])
	end

	--如果是在冷却时间，那么显示倒计时
	local label_cost_time = tolua.cast(temp_widget:getChildByName("label_cost_time"),"Label")
	local sureBtn = tolua.cast(temp_widget:getChildByName("confirm_btn"),"Button")
	local label_cost = tolua.cast(sureBtn:getChildByName("label_cost"),"Label")

	local icon = tolua.cast(sureBtn:getChildByName("img_flag"),"ImageView")
	if not isCoinAble then
		local hero_info = heroData.getHeroInfo(hero_uid)
        local free_wash_time = hero_info.clean_point_time
		local cd_time = commonFunc.format_day(free_wash_time + HERO_CLEAN_POINTS_COOL_DOWN_TIME - userData.getServerTime())
		-- local label_cd = tolua.cast(panel_coin_unable:getChildByName("label_cd"),"Label")
		-- label_cd:setText(cd_time)
		label_cost_time:setText(cd_time)
		label_cost:setText(HERO_CLEAN_POINTS_YUANBAO)
		icon:loadTexture(ResDefineUtil.ui_res_icon[dropType.RES_ID_YUAN_BAO], UI_TEX_TYPE_PLIST)
		icon:setVisible(true)
	else
		label_cost:setText(languagePack["mianfei"])
		label_cost_time:setVisible(false)
		icon:loadTexture(ResDefineUtil.ui_comfire_icon,UI_TEX_TYPE_PLIST)
		icon:setVisible(false)
	end

	
end

local function addWashAlertGoldCountDown()
    removeWashAlertGoldCountDown()
    local function update()
        local hero_info = heroData.getHeroInfo(hero_uid)
        local free_wash_time = hero_info.clean_point_time
        if free_wash_time == 0 or (free_wash_time + HERO_CLEAN_POINTS_COOL_DOWN_TIME) < userData.getServerTime() then
            switchVisiblePanel(true)
            removeWashAlertGoldCountDown()
        else
            switchVisiblePanel(false)
        end 
    end
    washAlertGoldCountDown = scheduler.create(update, 1)
end




local function create(hero_uidT,callbackT)
	if main_layer then return end
    hero_uid = hero_uidT
    local hero_info = heroData.getHeroInfo(hero_uid)
    if not hero_info then return end
    local free_wash_time = hero_info.clean_point_time
    if free_wash_time == 0 or (free_wash_time + HERO_CLEAN_POINTS_COOL_DOWN_TIME) < userData.getServerTime() then
        isCoinAble = true
    else
        isCoinAble = false
    end 
     
	callback = callbackT

	-- costCoin = HERO_CLEAN_POINTS_MONEY
	costGold = HERO_CLEAN_POINTS_YUANBAO

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/washPointConfirm.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))


	

	if not isCoinAble then 
		addWashAlertGoldCountDown()
	end

	-- add events
	local closeBtn = tolua.cast(temp_widget:getChildByName("close_btn"),"Button")
	closeBtn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove()
		end
	end)

	local sureBtn = tolua.cast(temp_widget:getChildByName("confirm_btn"),"Button")
	sureBtn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			if callback then 
                if isCoinAble then 
                    -- local is_enough_coin =  gameUtilFunc.is_ennough_res(consumeType.common_money,costCoin) 
                    -- if is_enough_coin then
                        callback()
                    -- else
                        -- remove()
                        -- tipsLayer.create(errorTable[144])
                        -- return
                    -- end
                else
                    local is_enough_gold =  gameUtilFunc.is_ennough_res(consumeType.yuanbao,costGold) 
                    if is_enough_gold then
                        callback()
                    else
                        -- remove()
                        -- tipsLayer.create(errorTable[143])
                        alertLayer.create(errorTable[16])
                        return
                    end
                end
			end
			remove()
		end
	end)





	main_layer = TouchGroup:create()
	main_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(main_layer, uiIndexDefine.CARD_WASH_POINT_CONFIRM)


	switchVisiblePanel(isCoinAble)
end

cardWashPointConfirm = { 
	create = create,
	remove = remove,
	dealwithTouchEvent = dealwithTouchEvent,
}
