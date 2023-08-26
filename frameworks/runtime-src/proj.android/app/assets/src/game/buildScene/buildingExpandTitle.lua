local titleLayer = nil

require("game/option/optionController")

local m_iNonForcedGuideId = nil
local function remove_self()
    if titleLayer then
    	titleLayer:removeFromParentAndCleanup(true)
    	titleLayer = nil
    	uiManager.remove_self_panel(uiIndexDefine.BUILD_EXPAND_TITLE)
        
        optionController.resetOptions()
        innerOptionLeft.setEnable(true)
        innerOptionRight.setEnable(true)

        cityMsg.setEnabled(true)

        m_iNonForcedGuideId = nil
    end
    
end

local function dealwithTouchEvent(x,y)
    return false
end
local function deal_with_cancel()
    BuildingExpand.remove()
end

local function create()
    
    cityMsg.setEnabled(false)
    innerOptionLeft.setEnable(false)
    innerOptionRight.setEnable(false)
    if titleLayer then return end

    local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/Expand_UI.json")
    temp_widget:setTag(999)
    temp_widget:setScale(config.getgScale())
    temp_widget:ignoreAnchorPointForPosition(false)
    temp_widget:setAnchorPoint(cc.p(0.5,0.5))
    temp_widget:setPosition(cc.p(config.getWinSize().width*29/48, config.getWinSize().height * 21/24))
    

    titleLayer = TouchGroup:create()
    titleLayer:addWidget(temp_widget)

    uiManager.add_panel_to_layer(titleLayer,uiIndexDefine.BUILD_EXPAND_TITLE)

    local cancel_btn = tolua.cast(temp_widget:getChildByName("cancel_btn"),"Button")
    cancel_btn:addTouchEventListener(deal_with_cancel)

    local img_content = uiUtil.getConvertChildByName(temp_widget,"img_content")
    local text_content = uiUtil.getConvertChildByName(img_content,"text_content")
    text_content:setText(politics.getBuildingExpandAbleCount(mainBuildScene.getThisCityid()))
    
    optionController.removeOptions()

    local function finally()
        comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2023)
    end
    if (not CCUserDefault:sharedUserDefault():getBoolForKey("opened_building_expand_title") ) then 
        require("game/guide/shareGuide/picTipsManager")
        picTipsManager.create(11,finally)
        CCUserDefault:sharedUserDefault():setBoolForKey("opened_building_expand_title",true)
    elseif m_iNonForcedGuideId and m_iNonForcedGuideId == com_guide_id_list.CONST_GUIDE_2023 then 
        finally()
    end
end

local function updateView()
    if not titleLayer then return end

    local temp_widget = titleLayer:getWidgetByTag(999)

    local img_content = uiUtil.getConvertChildByName(temp_widget,"img_content")
    local text_content = uiUtil.getConvertChildByName(img_content,"text_content")
    text_content:setText(politics.getBuildingExpandAbleCount(mainBuildScene.getThisCityid()))

    
end

local function getInstance()
    return titleLayer
end

local function get_com_guide_widget(temp_guide_id)
    if not titleLayer then return end
    local temp_widget = titleLayer:getWidgetByTag(999)
    return temp_widget
end


local function activeNonForceGuide(guide_id)
    m_iNonForcedGuideId = guide_id
end

buildingExpandTitle = {
    create = create,
    remove_self = remove_self,
    dealwithTouchEvent = dealwithTouchEvent,
    getInstance = getInstance,
    updateView = updateView,
    get_com_guide_widget = get_com_guide_widget,
    activeNonForceGuide = activeNonForceGuide,
}
