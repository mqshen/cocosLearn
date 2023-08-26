module("UIInternalAffairs", package.seeall)

-- 内政UI by TK




local m_pMainLayer = nil

local m_pWidgetTrade = nil  -- 交易面板
local m_pWidgetStronghold = nil -- 坚守面板

local m_iCurViewIndx = nil




local function do_remove_self()
    if m_pMainLayer then 

        UIResourceTrade.remove_self()


        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_INTERNAL_AFFAIRS)
        m_pWidgetTrade = nil
        m_pWidgetStronghold = nil

    end

    m_iCurViewIndx = nil
end

function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.UI_INTERNAL_AFFAIRS,m_pMainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
    if not m_pMainLayer then return false end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if mainWidget:hitTest(cc.p(x,y)) then 
        return false
    else
        remove_self()
        return true
    end
end



local function setTradeEnable(isAble)

    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local panel_unopen_1 = uiUtil.getConvertChildByName(mainWidget,"panel_unopen_1")
    
    local panel_content = uiUtil.getConvertChildByName(mainWidget,"panel_content")
    local img_contentBg = uiUtil.getConvertChildByName(panel_content,"img_contentBg")
    img_contentBg:setVisible(true)
    require("game/roleForces/ui_resource_trade")
    if isAble then 
        if politics.getUserMarketNum() < 1 then 
            if m_pWidgetTrade then 
                UIResourceTrade.remove_self()
                m_pWidgetTrade = nil
            end
            panel_unopen_1:setVisible(true)
        else
            if not m_pWidgetTrade then 
                m_pWidgetTrade = UIResourceTrade.getInstance()
                
                panel_content:addChild(m_pWidgetTrade)
                img_contentBg:setVisible(false)
            end
        end
    else
        panel_unopen_1:setVisible(false)
        if m_pWidgetTrade then 
            UIResourceTrade.remove_self()
            m_pWidgetTrade = nil
        end
    end
end

local function setStrongHoldEnable(isAble)
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local panel_unopen_2 = uiUtil.getConvertChildByName(mainWidget,"panel_unopen_2")
    panel_unopen_2:setVisible(isAble)
end

local function setViewByIndx(indx)
    if not m_pMainLayer then return end
    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    if not indx then return end

    if m_iCurViewIndx == indx then return end

    if indx > 2 or indx < 1 then return end

    m_iCurViewIndx = indx

    local tempBtn = nil

    for i = 1,2 do 
        tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_" .. i)
        tempBtn:setTouchEnabled(true)
        uiUtil.setBtnLabel(tempBtn,false)
        tempBtn:setBright(true)
    end

    tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_" .. m_iCurViewIndx)
    tempBtn:setTouchEnabled(false)
    uiUtil.setBtnLabel(tempBtn,true)
    tempBtn:setBright(false)

    if m_iCurViewIndx == 1 then 
        setTradeEnable(true)
        setStrongHoldEnable(false)
    elseif m_iCurViewIndx == 2 then 
        setTradeEnable(false)
        setStrongHoldEnable(true)
    end
end
local function init()
    if not m_pMainLayer then return end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)

    if not mainWidget then return end

    local btn_close = uiUtil.getConvertChildByName(mainWidget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self()
        end
    end)


    local panel_unopen_1 = uiUtil.getConvertChildByName(mainWidget,"panel_unopen_1")
    local panel_unopen_2 = uiUtil.getConvertChildByName(mainWidget,"panel_unopen_2")

    panel_unopen_1:setVisible(false)
    panel_unopen_2:setVisible(false)
    

    local tempBtn = nil

    for i = 1,2 do 
        tempBtn = uiUtil.getConvertChildByName(mainWidget,"btn_" .. i)
        tempBtn:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                setViewByIndx(i)
            end
        end)
    end

    setViewByIndx(1)

end


function create()
    if m_pMainLayer then return end


    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/neizhen_2.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))


    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_INTERNAL_AFFAIRS)

    init()

    uiManager.showConfigEffect(uiIndexDefine.UI_INTERNAL_AFFAIRS,m_pMainLayer)
end
