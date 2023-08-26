module("UIGiftExchange", package.seeall)
-- 类名 礼包兑换  UIGiftExchange
-- json文件  shezhi_2
--ID  UI_GIFT_EXCHANGE
local StringUtil = require("game/utils/string_util")

local m_pMainLayer = nil
local textEditbox = nil


local function onRequestExchange(package)
   
--     如果是1，代表成功；
-- 如果是0，代表非法礼包码；
-- 如果是2，代表此礼包码已经使用过了；
-- 如果是3，代表已经用过相同组的礼包码；
-- 如果是4，该礼包领取数已达上限
    if package[1] == 1 then 
        alertLayer.create(errorTable[2010],{package[2]})
    elseif package[1] == 0 then 
        alertLayer.create(errorTable[2011])
    elseif package[1] == 2 then 
        alertLayer.create(errorTable[2012])
    elseif package[1] == 3 then
        alertLayer.create(errorTable[2013])
    elseif package[1] == 4 then
        alertLayer.create(errorTable[2038])
    elseif package[1] == 5 then
        alertLayer.create(errorTable[2039])
    else

    end
end

local function do_remove_self()
    if m_pMainLayer then 
        if textEditbox then 
            textEditbox:removeFromParentAndCleanup(true)
            textEditbox = nil
        end

        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_GIFT_EXCHANGE)
    end
    netObserver.removeObserver(USE_GIFT_CODE)
end
function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.UI_GIFT_EXCHANGE,m_pMainLayer,do_remove_self) 
end

function dealwithTouchEvent(x,y)
    if not m_pMainLayer then return false end

    local mainWidget = m_pMainLayer:getWidgetByTag(999)
    if not mainWidget then return false end

    if mainWidget:hitTest(cc.p(x,y)) then 
        return false 
    else
        remove_self()
        return true 
    end
end

function create()
    if m_pMainLayer then return end
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/shezhi_2.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setTouchEnabled(true)
    mainWidget:setAnchorPoint(cc.p(0.5,0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))


    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    
    uiManager.add_panel_to_layer(m_pMainLayer,uiIndexDefine.UI_GIFT_EXCHANGE)

    
    


    local edit_panel = uiUtil.getConvertChildByName(mainWidget,"edit_panel")
    edit_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)

    local label_default = uiUtil.getConvertChildByName(edit_panel,"label_default")
    local size_width = edit_panel:getSize().width
    local size_height = edit_panel:getSize().height
    --输入正文
    
    local editBoxSize = CCSizeMake(edit_panel:getContentSize().width*config.getgScale(),edit_panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)

    textEditbox = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    textEditbox:setAlignment(1)
    textEditbox:setFontName(config.getFontName())
    textEditbox:setFontSize(20*config.getgScale())
    textEditbox:setFontColor(ccc3(91,92,96))
    mainWidget:addChild(textEditbox)
    textEditbox:setScale(1/config.getgScale())
    textEditbox:setPosition(cc.p(edit_panel:getPositionX(), edit_panel:getPositionY()))
    textEditbox:setAnchorPoint(cc.p(0,0))
    
    label_default:setVisible(true)

    textEditbox:registerScriptEditBoxHandler(function (strEventName,pSender)
        
        if strEventName == "began" then
            label_default:setVisible(false)
        elseif strEventName == "ended" then
            -- ignore
        elseif strEventName == "return" then
            if StringUtil.isEmptyStr(textEditbox:getText()) then
                label_default:setVisible(true)
            else
                label_default:setVisible(false)
            end
        elseif strEventName == "changed" then
            -- ignore
        end
        
    end)



    local btn_exchange = uiUtil.getConvertChildByName(mainWidget,"btn_exchange")
    btn_exchange:setTouchEnabled(true)
    btn_exchange:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then     
            local exchangId = StringUtil.DelS( textEditbox:getText() ) 

            Net.send(USE_GIFT_CODE,{ exchangId  } ) 
        end
    end)
    netObserver.addObserver(USE_GIFT_CODE,onRequestExchange)

    uiManager.showConfigEffect(uiIndexDefine.UI_GIFT_EXCHANGE,m_pMainLayer)
end


 