UIResourceTrade = {}

local uiUtil = require("game/utils/ui_util")

local mainWidget = nil


local TRADE_RATE_BASE = math.floor( 100 / 10 )
local TRADE_RATE_PERCENT = {}
TRADE_RATE_PERCENT[1] = math.floor((EXCHANGE_DISCOUNT_INIT + 10)/10)
TRADE_RATE_PERCENT[2] = math.floor((EXCHANGE_DISCOUNT_INIT + 20)/10)
TRADE_RATE_PERCENT[3] = math.floor((EXCHANGE_DISCOUNT_INIT + 30)/10)


local left_indx = nil
local right_indx = nil
local trade_rate_percent = nil
local cur_slider_percent = nil

local left_value = nil
local right_value = nil

local CONVERT_RES_INDX_TYPE = {}
CONVERT_RES_INDX_TYPE[1] = 1
CONVERT_RES_INDX_TYPE[2] = 3
CONVERT_RES_INDX_TYPE[3] = 2
CONVERT_RES_INDX_TYPE[4] = 4


local is_able_left = nil
local is_able_right = nil
local function do_remove_self()
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    left_indx = nil
    right_indx = nil
    trade_rate_percent = nil
    cur_slider_percent = nil
    left_value = nil
    right_value = nil

    is_able_left = nil
    is_able_right = nil
    UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, UIResourceTrade.reloadData)
end

function UIResourceTrade.remove_self()
    do_remove_self()
end




-- 初始化集市数量 和 交易比
local function setMarketInfo()
    if not mainWidget then return end
    local widget = mainWidget
    local label_market_num = uiUtil.getConvertChildByName(widget,"label_market_num")
    local marketNum = politics.getUserMarketNum()
    label_market_num:setText(marketNum .. "/" .. BUILD_JI_SHI_NUM_OF_MAX_DISCOUNT)
    
    local label_trade_rate = uiUtil.getConvertChildByName(widget,"label_trade_rate")
    trade_rate_percent = TRADE_RATE_PERCENT[marketNum]
    if not trade_rate_percent then 
        trade_rate_percent = TRADE_RATE_PERCENT[3]
    end
    label_trade_rate:setText(TRADE_RATE_BASE .. ":" .. trade_rate_percent)
end






local function check_btn_ok_touch()
    if not mainWidget then return end

    local widget = mainWidget
    local btn_ok = uiUtil.getConvertChildByName(widget,"btn_ok")
    
    local slider_content = uiUtil.getConvertChildByName(widget,"slider_content")
    if (left_indx and right_indx) and (left_indx ~= right_indx) then 
        slider_content:setTouchEnabled(true)
    else
        slider_content:setTouchEnabled(false)
    end

    -- if not is_able_left or not is_able_right then
    --     slider_content:setTouchEnabled(false) 
    --     -- btn_ok:setTouchEnabled(false)
    -- else
    --     -- btn_ok:setTouchEnabled(true)
    --     slider_content:setTouchEnabled(true)
    -- end
end

local function setRightSelectedItem(indx)
    
    if not mainWidget then return end
    local widget = mainWidget
    local item_panel = nil
    local img_flag = nil
    for i = 1, 4 do 
        item_panel = uiUtil.getConvertChildByName(widget,"right_panel_" .. i)
        img_flag = uiUtil.getConvertChildByName(item_panel,"img_flag")
        if i == indx then 
            item_panel:setTouchEnabled(false)
            img_flag:setVisible(true)
        else
            item_panel:setTouchEnabled(true)
            img_flag:setVisible(false)
        end
    end
    right_indx = indx

    check_btn_ok_touch()

    local label_right_title = uiUtil.getConvertChildByName(widget,"label_right_title")
    label_right_title:setVisible(true)
    label_right_title:setText(
                        languagePack["trade_title_target_res"] 
                        .. "  " 
                        .. rewardName[CONVERT_RES_INDX_TYPE[right_indx]])
    local label_right_res_type = uiUtil.getConvertChildByName(widget,"label_right_res_type")
    label_right_res_type:setVisible(true)
    label_right_res_type:setText(rewardName[CONVERT_RES_INDX_TYPE[right_indx]])      
    local img_right_res_type = uiUtil.getConvertChildByName(widget,"img_right_res_type")
    img_right_res_type:setVisible(true)
    img_right_res_type:loadTexture(itemTextureName[CONVERT_RES_INDX_TYPE[right_indx]],UI_TEX_TYPE_PLIST)

    local label_trade_right = uiUtil.getConvertChildByName(widget,"label_trade_right")
    label_trade_right:setVisible(true)

    local slider_content = uiUtil.getConvertChildByName(widget,"slider_content")
    slider_content:setPercent(0)
    UIResourceTrade.setTradeResult(0)
end

local function getCurResInfo()
    local temp_value = {}
    local res_cur_nums, res_max_nums, res_add_speed = 0,0,0
    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.wood)
    temp_value[1] = res_cur_nums

    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.iron)
    temp_value[2] = res_cur_nums

    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.stone)
    temp_value[3] = res_cur_nums

    

    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.food)
    temp_value[4] = res_cur_nums

    return temp_value
end

local function getMaxResInfo()
    local res_cur_nums, res_max_nums, res_add_speed = 0,0,0
    local max_temp_value = {}

    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.wood)
    max_temp_value[1] = res_max_nums

    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.iron)
    max_temp_value[2] = res_max_nums

    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.stone)
    max_temp_value[3] = res_max_nums

    res_cur_nums, res_max_nums, res_add_speed = politics.getResNumsByType(resType.food)
    max_temp_value[4] = res_max_nums

    
    return max_temp_value
end




local function dealwithTouchRightItem(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        local indx = tonumber(string.sub(sender:getName(),13))
        is_able_right = true
        is_able_left = true
        if indx == left_indx then 
            tipsLayer.create(errorTable[172])
            is_able_right = false
            -- return 
        end
        local temp_value = {}
        local max_temp_value = getMaxResInfo()
        local cur_temp_value = getCurResInfo()
        temp_value[1] = max_temp_value[1] - cur_temp_value[1]
        temp_value[2] = max_temp_value[2] - cur_temp_value[2]
        temp_value[3] = max_temp_value[3] - cur_temp_value[3]
        temp_value[4] = max_temp_value[4] - cur_temp_value[4]
        
        --爆仓
        if temp_value[indx] <= 0  then 
            tipsLayer.create(errorTable[169])
            return 
        end
        
        setRightSelectedItem(indx)
    end
end


local function setLeftSelectedItem(indx)
    if not mainWidget then return end
    local widget = mainWidget
    local item_panel = nil
    local img_flag = nil

    for i = 1, 4 do
        item_panel = uiUtil.getConvertChildByName(widget,"left_panel_" .. i)
        img_flag = uiUtil.getConvertChildByName(item_panel,"img_flag")
        if i == indx then 
            item_panel:setTouchEnabled(false)
            img_flag:setVisible(true)      
        else
            item_panel:setTouchEnabled(true)
            img_flag:setVisible(false)     
        end
    end
    left_indx = indx
    
    local temp_value = getCurResInfo()

    check_btn_ok_touch()
    
    local label_left_title = uiUtil.getConvertChildByName(widget,"label_left_title")
    label_left_title:setVisible(true)
    label_left_title:setText(
            languagePack["trade_title_res"]
            .. "  " 
            .. rewardName[CONVERT_RES_INDX_TYPE[left_indx]])
     
    local label_left_res_type = uiUtil.getConvertChildByName(widget,"label_left_res_type")
    label_left_res_type:setVisible(true)
    label_left_res_type:setText(rewardName[CONVERT_RES_INDX_TYPE[left_indx]])
    
    local img_left_res_type = uiUtil.getConvertChildByName(widget,"img_left_res_type")
    img_left_res_type:setVisible(true)
    img_left_res_type:loadTexture(itemTextureName[CONVERT_RES_INDX_TYPE[left_indx]],UI_TEX_TYPE_PLIST)

    local label_trade_left = uiUtil.getConvertChildByName(widget,"label_trade_left")
    label_trade_left:setVisible(true)
    
    local slider_content = uiUtil.getConvertChildByName(widget,"slider_content")
    slider_content:setPercent(0)
    UIResourceTrade.setTradeResult(0)
end

local function dealwithTouchLeftItem(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        local indx = tonumber(string.sub(sender:getName(),12))
        is_able_left = true
        is_able_right = true
        if indx == right_indx then 
            tipsLayer.create(errorTable[172])
            is_able_left = false
            -- return 
        end
        
        setLeftSelectedItem(indx)
    end
end

local function dealwithClickBtnClose(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then
        UIResourceTrade.remove_self()
    end
end


local function dealwithConfirmBtn(sender,eventType)
    if eventType == TOUCH_EVENT_ENDED then 
        if not is_able_left or not is_able_right then 
            tipsLayer.create(errorTable[172])
            return 
        end
        if not left_indx then 
            tipsLayer.create(errorTable[165])
            return 
        end
        if not right_indx then 
            tipsLayer.create(errorTable[166])
            return 
        end
        if left_indx == right_indx then 
            --TODO
            tipsLayer.create(languagePack["illegal_operate"])
            return 
        end
        if (not left_value ) or (left_value <= 0) then 
            tipsLayer.create(errorTable[167])
            return
        end
        
        

        local function confirmCallback()
            Net.send(RESOURCE_EXCHANGE, {CONVERT_RES_INDX_TYPE[left_indx],left_value,CONVERT_RES_INDX_TYPE[right_indx]})
            -- UIResourceTrade.remove_self()
        end
        alertLayer.create(errorTable[168],
            {rewardName[CONVERT_RES_INDX_TYPE[left_indx]],
             left_value,
             rewardName[CONVERT_RES_INDX_TYPE[right_indx]],
             right_value
            },confirmCallback)

        
    end
end

-- 设置交易结果
function UIResourceTrade.setTradeResult(rate)
    
    if not mainWidget then return end
    local widget = mainWidget
    local label_trade_left = uiUtil.getConvertChildByName(widget,"label_trade_left")
    label_trade_left:setText(0)
    local label_trade_right = uiUtil.getConvertChildByName(widget,"label_trade_right")
    label_trade_right:setText(0)

    
    if not left_indx then return end
    if not right_indx then return end
    if left_indx == right_indx then return end
    
    local temp_value = getCurResInfo()
    
    local max_temp_value = getMaxResInfo()
    
    if rate then 
        cur_slider_percent = rate
    end

    if not cur_slider_percent then 
        cur_slider_percent = 0
    end

    
    local target_res_num_can_add = max_temp_value[right_indx] - temp_value[right_indx]
    local target_res_num_can_trade = temp_value[left_indx] * trade_rate_percent / TRADE_RATE_BASE
    if target_res_num_can_add >= target_res_num_can_trade then
        left_value = math.floor(temp_value[left_indx] * cur_slider_percent / 100)
        right_value = math.floor( left_value * trade_rate_percent / TRADE_RATE_BASE )
    else
        right_value = math.floor(target_res_num_can_add * cur_slider_percent / 100)
        left_value = math.floor( right_value * TRADE_RATE_BASE / trade_rate_percent )
    end
    label_trade_left:setText(left_value)
    label_trade_right:setText(right_value)
end

function UIResourceTrade.reloadData()
    if not mainWidget then return end
    local widget = mainWidget
    local label_value = nil

    local temp_value = getCurResInfo()
    for i = 1, 4 do
        item_panel = uiUtil.getConvertChildByName(widget,"left_panel_" .. i)
        label_value = uiUtil.getConvertChildByName(item_panel,"label_value")
        label_value:setText(temp_value[i])
    end
    
    local slider_content = uiUtil.getConvertChildByName(widget,"slider_content")
    slider_content:setPercent(0)
    UIResourceTrade.setTradeResult(0)

end

local function percentChangedEvent(sender, eventType)
    if eventType == SLIDER_PERCENTCHANGED then
        local temp_slider = tolua.cast(sender,"Slider")
        local new_percent = temp_slider:getPercent()
        if new_percent ~= cur_slider_percent then
            UIResourceTrade.setTradeResult(new_percent)
        end
    end
end 

function UIResourceTrade.setSliderVisible(isVisible)
    if not mainWidget then return end
    local slider_content = uiUtil.getConvertChildByName(mainWidget,"slider_content")
    slider_content:setVisible(isVisible)

end


function UIResourceTrade.create()
    if mainWidget then return end

    -- if politics.getUserMarketNum() < 1 then 
    --     tipsLayer.create(errorTable[180])
    --     return 
    -- end
    is_able_right = true
    is_able_left = true
    local widget = GUIReader:shareReader():widgetFromJsonFile("test/transaction.json")
	-- widget:setTag(999)
	-- widget:setScale(config.getgScale())
	-- widget:ignoreAnchorPointForPosition(false)
	-- widget:setAnchorPoint(cc.p(0.5, 0.5))
	-- widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

    mainWidget = widget
    

    
    local btn_ok = uiUtil.getConvertChildByName(widget,"btn_ok")
    btn_ok:setTouchEnabled(true)
    btn_ok:addTouchEventListener(dealwithConfirmBtn)
    
    setMarketInfo()

   
    --初始化持有资源
    local item_panel = nil
    local img_flag = nil
    local label_value = nil
    for i = 1, 4 do
        item_panel = uiUtil.getConvertChildByName(widget,"left_panel_" .. i)
        item_panel:setTouchEnabled(true)
        img_flag = uiUtil.getConvertChildByName(item_panel,"img_flag")
        img_flag:setTouchEnabled(false)
        img_flag:setVisible(false)
        label_value = uiUtil.getConvertChildByName(item_panel,"label_value")
        label_value:setText(0)
        item_panel:addTouchEventListener(dealwithTouchLeftItem)
    end
   
    --初始化目标资源
    for i = 1, 4 do 
        item_panel = uiUtil.getConvertChildByName(widget,"right_panel_" .. i)
        item_panel:setTouchEnabled(true)
        img_flag = uiUtil.getConvertChildByName(item_panel,"img_flag")
        img_flag:setTouchEnabled(false)
        img_flag:setVisible(false)
        item_panel:addTouchEventListener(dealwithTouchRightItem)
    end


    local slider_content = uiUtil.getConvertChildByName(widget,"slider_content")
    slider_content:setTouchEnabled(false)
    slider_content:addEventListenerSlider(percentChangedEvent)

    
    local label_trade_right = uiUtil.getConvertChildByName(widget,"label_trade_right")
    label_trade_right:setVisible(false)
    local label_right_res_type = uiUtil.getConvertChildByName(widget,"label_right_res_type")
    label_right_res_type:setVisible(false)
    local img_right_res_type = uiUtil.getConvertChildByName(widget,"img_right_res_type")
    img_right_res_type:setVisible(false)
    local label_trade_left = uiUtil.getConvertChildByName(widget,"label_trade_left")
    label_trade_left:setVisible(false)
    local label_left_res_type = uiUtil.getConvertChildByName(widget,"label_left_res_type")
    label_left_res_type:setVisible(false) 
    local img_left_res_type = uiUtil.getConvertChildByName(widget,"img_left_res_type")
    img_left_res_type:setVisible(false)

  
    UIResourceTrade.reloadData()
	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, UIResourceTrade.reloadData)
end



function UIResourceTrade.getInstance()
    UIResourceTrade.create()
    return mainWidget
end

function UIResourceTrade.setEnabled(flag,callback)
    if not mainWidget then return end
    mainWidget:setVisible(flag)
    UIResourceTrade.setSliderVisible(false)
    local function finally()
        UIResourceTrade.setSliderVisible(true)
        if callback then callback() end
    end
    if flag then 
        uiUtil.showScaleEffect(mainWidget,finally,0.5)
    else
        uiUtil.hideScaleEffect(mainWidget,finally,0.5)
    end
end
