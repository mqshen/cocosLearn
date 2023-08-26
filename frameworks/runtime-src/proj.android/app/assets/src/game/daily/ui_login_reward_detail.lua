module("UIDailyLoginRewardDetail",package.seeall)
local loginRewardHelper = require("game/daily/login_reward_helper")

-- 每日登陆奖励 当日奖励详情
local m_pMainLayer = nil


local m_iDayth = nil
local m_bIsToday = nil

local m_tbCfgReward = nil
local m_funCallback = nil


local function do_remove_self()
    if m_pMainLayer then 
        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_DAILY_LOGIN_REWARD_DETAIL)

        m_iDayth = nil
        m_bIsToday = nil
        m_tbCfgReward = nil

        if m_funCallback and type(m_funCallback) == "function" then 
            m_funCallback()
            m_funCallback = nil
        end
    end
end
function remove_self()
   uiManager.hideConfigEffect(uiIndexDefine.UI_DAILY_LOGIN_REWARD_DETAIL,m_pMainLayer,do_remove_self) 
end

function dealwithTouchEvent(x,y)
    if not m_pMainLayer then return false end
  
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    local img_mainBg = uiUtil.getConvertChildByName(mainWidget,"img_mainBg")
    if img_mainBg:hitTest(cc.p(x,y)) then
        return false
    else
        remove_self()
        return true
    end
end

local function createWidget()
    local mainWidget = nil
    mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/login_reward_daily.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    return mainWidget
end

local function autoSizeWidth(viewWidth)
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    if not viewWidth then viewWidth = 618 end

    local label_title = uiUtil.getConvertChildByName(mainWidget,"label_title")


    local img_head = uiUtil.getConvertChildByName(mainWidget,"img_head")
    img_head:setSize(CCSize(viewWidth - 46, img_head:getSize().height))


    local img_head_1 = uiUtil.getConvertChildByName(mainWidget,"img_head_1")


    local img_mainBg = uiUtil.getConvertChildByName(mainWidget,"img_mainBg")
    img_mainBg:setSize(CCSize(viewWidth,img_mainBg:getSize().height))


    local btn_ok = uiUtil.getConvertChildByName(mainWidget,"btn_ok")

    local img_container_bg = uiUtil.getConvertChildByName(mainWidget,"img_container_bg")
    img_container_bg:setSize(CCSize(viewWidth - 46, img_container_bg:getSize().height))


    local panel_bg = uiUtil.getConvertChildByName(mainWidget,"panel_bg")
    panel_bg:setSize(CCSize(viewWidth , panel_bg:getSize().height))    
end

local function reloadData()
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    -- 设置title
    local label_title = uiUtil.getConvertChildByName(mainWidget,"label_title")
    if m_bIsToday then 
        label_title:setText(languagePack["ui_login_detail_title_today"])
    else
        local titleText = string.gsub(languagePack["ui_login_detail_title_dayth"], 
            "#", 
            function(...)
                return m_iDayth
            end)
        label_title:setText(titleText)
    end

    local item_view_w = 80
    local item_view_h = 80
    local total_view_w = 0
    for k,v in pairs(m_tbCfgReward.rewards) do
        total_view_w = total_view_w + item_view_w
    end
    total_view_w = total_view_w + 46
    if total_view_w < 572 then total_view_w = 572 end
    autoSizeWidth(total_view_w)

    -- 设置奖励列表 要居中
    local img_container_bg = uiUtil.getConvertChildByName(mainWidget,"img_container_bg")
    img_container_bg:removeAllChildrenWithCleanup(true)
    local rewardType = nil
    local rewardNum = nil
    local rewardWidget = nil
    local posX = nil
    local posY = nil
    local columnSplit = 18
    
    for k,v in pairs(m_tbCfgReward.rewards) do
        rewardType = v[1]
        rewardNum = v[2]
        rewardWidget = GUIReader:shareReader():widgetFromJsonFile("test/login_reward_cell.json")
        rewardWidget:ignoreAnchorPointForPosition(false)
        rewardWidget:setAnchorPoint(cc.p(0.5,0.5))
        loginRewardHelper.setRewardWidgetLayout(rewardWidget,rewardType,rewardNum)
        img_container_bg:addChild(rewardWidget)

        if not posY then 
            posY = 0
        end

        if not posX then 
            posX =  (img_container_bg:getSize().width - (#m_tbCfgReward.rewards - 1) * item_view_w)/2
            posX = img_container_bg:getSize().width/2 - posX
            posX = -posX
        else
            posX = posX + item_view_w
        end

        rewardWidget:setPosition(cc.p(posX,posY))
        rewardWidget:setTouchEnabled(true)
        rewardWidget:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                require("game/daily/ui_reward_detail")
                UIRewardDetail.create(v[1],v[2])
            end
        end)
    end


   
end


local function init()
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    -- 关闭按钮 
    local btn_close = uiUtil.getConvertChildByName(mainWidget,"btn_close")
    btn_close:setVisible(false)
    btn_close:setTouchEnabled(false)
    -- btn_close:setTouchEnabled(true)
    -- btn_close:addTouchEventListener(function(sender,eventType)
    --     if eventType == TOUCH_EVENT_ENDED then 
    --         remove_self()
    --     end
    -- end)
    -- 确认按钮
    local btn_ok = uiUtil.getConvertChildByName(mainWidget,"btn_ok")
    btn_ok:setTouchEnabled(true)
    btn_ok:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self()
        end
    end)
end
function create(dayth,callback)
    if m_pMainLayer then return end
    if not dayth then 
        dayth = loginRewardHelper.getCurLoginRewardCycleLoginedDays()
    end
    m_iDayth = dayth
    m_funCallback = callback
    m_bIsToday = (loginRewardHelper.getCurLoginRewardCycleLoginedDays() == dayth)

    m_tbCfgReward = loginRewardHelper.getDailyRewardDetailList(dayth)
    local mainWidget = createWidget()
    mainWidget:setTouchEnabled(false)
    local img_mainBg = uiUtil.getConvertChildByName(mainWidget,"img_mainBg")
    img_mainBg:setTouchEnabled(true)
    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_DAILY_LOGIN_REWARD_DETAIL)

    init()

    reloadData()

    uiManager.showConfigEffect(uiIndexDefine.UI_DAILY_LOGIN_REWARD_DETAIL,m_pMainLayer)

end


function getInstance()
    return m_pMainLayer
end