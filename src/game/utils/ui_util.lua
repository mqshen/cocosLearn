local uiUtil = {}

uiUtil.uiShowEffectDuration = 0.2 
uiUtil.uiHideEffectDuration = 0.2

uiUtil.uiShowScaleFrom = 0.85
uiUtil.uiShowOpacityFrom = 0

uiUtil.DURATION_FULL_SCREEN_SHOW = 0.15 
uiUtil.DURATION_FULL_SCREEN_HIDE = 0.15




function uiUtil.getConvertChildByName(parent,childName)
	assert(childName, "why get a nil child")
    local child = parent:getChildByName(childName)
    if child then 
       tolua.cast(child, child:getDescription())
    else
        -- print("node named["..childName.."]not found")
        -- print(debug.traceback())
    end
    return child
end



function uiUtil.playArmatureOnce(file,parent)
    if not parent then return end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/" .. file ..".ExportJson")
    local armature = CCArmature:create(file)
    
    
    armature:getAnimation():playWithIndex(0)
    parent:addChild(armature,2,2)
    armature:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    local function animationCallFunc(armatureNode, eventType, name)
        if eventType == 1 then
            armatureNode:removeFromParentAndCleanup(true)
            armature = nil
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
end

function uiUtil.hideScaleEffect(widget,callback,duration,scaleTo)
    if not widget then return end
    if not duration then duration = uiUtil.uiShowEffectDuration end
    
    if uiManager.isClearAll() then 
        if callback then callback() end
        return 
    end

    local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
    end)
    local actionHide = CCFadeOut:create(duration)
    if scaleTo then 
        local actionScale = CCScaleTo:create(duration,scaleTo * config.getgScale())
        local scaleAndHide = CCSpawn:createWithTwoActions(actionScale,actionHide)
        widget:runAction(animation.sequence({scaleAndHide,finally}))
    else
        widget:runAction(animation.sequence({actionHide,finally}))
    end
end

function uiUtil.showScaleEffect(widget,callback,duration,scaleFrom,scaleTo,opacityFrom)
    if not widget then return end
    if not duration then
        duration = uiUtil.uiShowEffectDuration
    end
    if uiManager.isClearAll() then 
        if callback then callback() end
        return 
    end
    local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
    end)
    if not opacityFrom then opacityFrom = uiUtil.uiShowOpacityFrom end
    if widget.setOpacity then 
        widget:setOpacity(opacityFrom)
    end
    local actionShow = CCFadeIn:create(duration)
    if scaleFrom then 
        if not scaleTo then scaleTo = 1 * config.getgScale() end
        local actionScale = CCScaleTo:create(duration,scaleTo)
        local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)
        widget:setScale(scaleFrom * config.getgScale())
        widget:runAction(animation.sequence({scaleAndShow,finally}))
    else
        widget:runAction(animation.sequence({actionShow,finally}))
    end
end

function uiUtil.setBtnLabel(btn,isSelected)
    if not btn then return end
    
    local btnLabel = uiUtil.getConvertChildByName(btn,"btnLabel")
    if not btnLabel then 
        btnLabel = Label:create()
        btnLabel:setName("btnLabel")
        btnLabel:setText(btn:getTitleText())
        btn:addChild(btnLabel)
        btnLabel:setFontSize(btn:getTitleFontSize())

        -- local labelRender = btnLabel:getVirtualRenderer()
        -- labelRender:setTextVerticalAlignment(kCCVerticalTextAlignmentCenter)
        -- labelRender:setTextHorizontalAlignment(kCCTextAlignmentCenter)
        btnLabel:setPosition(cc.p(btnLabel:getPositionX(),btnLabel:getPositionY() - 5))
    end
    btn:setTitleText(" ")   


    if isSelected then 
        btnLabel:setColor(ccc3(199,219,219))
    else
        btnLabel:setColor(ccc3(139,139,139))
    end
end
return uiUtil
