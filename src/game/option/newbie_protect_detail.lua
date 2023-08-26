module("NewbieProtectDetail", package.seeall)

-- 新手保护详情
-- 类名 ：  NewbieProtectDetail
-- json名： newbie_protect_detail.json
-- 配置ID:	UI_NEWBIE_PROTECT_DETAIL

local m_pMainLayer = nil
local schedulerHandler = nil

local timeLeftPostfix = ""

local FUNC_OPEN_COLOR_TITLE = ccc3(234,232,156)
local FUNC_OPEN_COLOR_DESC = ccc3(255,255,255)
local FUNC_OPEN_COLOR_STATE = ccc3(255,213,210)

local FUNC_CLOSE_COLOR_TITLE = ccc3(128,128,128)
local FUNC_CLOSE_COLOR_DESC = ccc3(128,128,128)
local FUNC_CLOSE_COLOR_STATE = ccc3(181,95,90)


local function updateTimeLeft()
    if not m_pMainLayer then return end

    local widget = m_pMainLayer:getWidgetByTag(999)
    local label_time = uiUtil.getConvertChildByName(widget,"label_time")
    local timeLeft = userData.getNewBieProtectionTimeLeft()
    -- TODOTK 中文收集
    label_time:setText(commonFunc.format_time(timeLeft) .. timeLeftPostfix)

    if timeLeft <= 0 then 
        NewbieProtectDetail.remove_self()
    end
end


local function disposeSchedulerHandler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
    end
end

local function updateScheduler()
    updateTimeLeft()
end

local function activeSchedulerHandler()
    disposeSchedulerHandler()
    schedulerHandler = scheduler.create(updateScheduler,1)
end

local function do_remove_self()
    if m_pMainLayer then

        disposeSchedulerHandler()

        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_NEWBIE_PROTECT_DETAIL)
    end
end

function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.UI_NEWBIE_PROTECT_DETAIL,m_pMainLayer,do_remove_self)
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

function create()

	if m_pMainLayer then return end

	local widget = nil
    widget = GUIReader:shareReader():widgetFromJsonFile("test/newbie_protect_detail.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_NEWBIE_PROTECT_DETAIL)
    uiManager.showConfigEffect(uiIndexDefine.UI_NEWBIE_PROTECT_DETAIL,m_pMainLayer)

    local label_time = uiUtil.getConvertChildByName(widget,"label_time")
    timeLeftPostfix = label_time:getStringValue()
    local btn_close = uiUtil.getConvertChildByName(widget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self()
        end
    end)

    updateTimeLeft()
    activeSchedulerHandler()

    local btn_tips = uiUtil.getConvertChildByName(widget,"btn_tips")
    btn_tips:setTouchEnabled(true)
    btn_tips:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            alertLayer.create(errorTable[2009])
        end
    end)


    local label_func_title = nil
    local label_func_desc = nil
    local label_func_state_open = nil
    local label_func_state_close = nil

    local funcOpenRenownNeedTab = {}
    funcOpenRenownNeedTab[1] = FUNC_OPEN_RENWON_NEED_FARM
    funcOpenRenownNeedTab[2] = FUNC_OPEN_RENWON_NEED_TRAINING
    funcOpenRenownNeedTab[3] = FUNC_OPEN_RENWON_NEED_RESIDE

    local func_close_renwon_tips = ""
    for i = 1,3 do 
        label_func_title = uiUtil.getConvertChildByName(widget,"label_func_title_" .. i)
        label_func_desc = uiUtil.getConvertChildByName(widget,"label_func_desc_" .. i)
        label_func_state_open = uiUtil.getConvertChildByName(widget,"label_func_state_open_" .. i)
        label_func_state_close = uiUtil.getConvertChildByName(widget,"label_func_state_close_" .. i)
        
        func_close_renwon_tips = string.gsub(languagePack["func_close_renwon_tips"], "&",  math.floor( funcOpenRenownNeedTab[i] / 100) )
        label_func_state_open:setVisible(false)
        label_func_state_close:setVisible(false)
        if funcOpenRenownNeedTab[i] > userData.getRenownNums() then 
            label_func_state_close:setVisible(true)
            label_func_title:setColor(FUNC_CLOSE_COLOR_TITLE)
            label_func_desc:setColor(FUNC_CLOSE_COLOR_DESC)

            label_func_state_close:setText(func_close_renwon_tips)
        else
            label_func_state_open:setVisible(true)
            label_func_title:setColor(FUNC_OPEN_COLOR_TITLE)
            label_func_desc:setColor(FUNC_OPEN_COLOR_DESC)
        end
    end
end

