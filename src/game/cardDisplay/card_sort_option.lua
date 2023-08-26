local cardSortOption = {}
local uiUtil = require("game/utils/ui_util")


local function setBtnOptionAble(mainWidget,isAble)
    local temp_btn = nil
    for i=1,5 do
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_" .. i)
        temp_btn:setTouchEnabled(isAble)
    end
end
function cardSortOption.show(mainWidget)
    mainWidget:setVisible(true)
    setBtnOptionAble(mainWidget,true)
end

function cardSortOption.hide(mainWidget)
    mainWidget:setVisible(false)
    setBtnOptionAble(mainWidget,false)
end


function cardSortOption.showEffect(mainWidget)
    local finally = cc.CallFunc:create(function ( )
        cardSortOption.show(mainWidget)
    end)
    cardSortOption.show(mainWidget)
    local actionShow = CCFadeIn:create(0.5)
    mainWidget:runAction(animation.sequence({actionShow,finally}))
end

function cardSortOption.hideEffect(mainWidget)
    local finally = cc.CallFunc:create(function ( )
        cardSortOption.hide(mainWidget)
    end)
    cardSortOption.show(mainWidget)
    local actionHide = CCFadeOut:create(0.4)
    mainWidget:runAction(animation.sequence({actionHide,finally}))
end

function cardSortOption.setVisible(mainWidget,isVisible,needEffect)
    if needEffect then 
        if isVisible then 
            cardSortOption.showEffect(mainWidget)
        else
            cardSortOption.hideEffect(mainWidget)
        end
    else
        if isVisible then 
            cardSortOption.show(mainWidget)
        else
            cardSortOption.hide(mainWidget)
        end
    end
end

function cardSortOption.create(parent,posx,posy,scale_value,btnCallback)
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/cardSortUI.json")
    mainWidget:setScale(scale_value)
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(1, 0.5))
    mainWidget:setPosition(cc.p(posx, posy))
    parent:addChild(mainWidget)
    mainWidget:setPosition(cc.p(posx,posy))
    local temp_btn = nil
    for i=1,5 do
        temp_btn = uiUtil.getConvertChildByName(mainWidget,"btn_" .. i)
        temp_btn:setTouchEnabled(true)
        temp_btn:addTouchEventListener(btnCallback)
    end

    return mainWidget
end

return cardSortOption