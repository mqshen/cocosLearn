-- 主界面右上角的小地图
module("SmallMiniMap", package.seeall)
local main_layer = nil
local m_sprite = nil
local m_arrOwnCityData = nil
local m_arrOwnLingdiData = nil
local m_arrNpcCityData = nil
local m_scale = nil
local itemBatch = nil

---------------------------------------------------------非强制引导相关
local schedulerHandler = nil
local mainCityNotInScreenLastTimestamp = nil


local i_lastActivedNonforcedGuideId = 0


local m_pCircleAnimation = nil  -- 圆圈指引
local m_pFingerAnimation = nil  -- 手指指引


local function getColor(wid )
    local relation = mapData.getRelation(math.floor(wid/10000), wid%10000)
    if not relation or relation==mapAreaRelation.all_free or relation == mapAreaRelation.attach_free then
        return ccc3(255,255,255)
    elseif relation == mapAreaRelation.free_ally or relation == mapAreaRelation.free_underling then
        return ccc3(255,255,0)
    elseif relation == mapAreaRelation.free_enemy or relation == mapAreaRelation.attach_enemy then
        return ccc3(255,0,0)
    elseif relation == mapAreaRelation.attach_higher_up or relation == mapAreaRelation.attach_same_higher then
        return ccc3(233,144,227)
    else
        return ccc3(255,255,255)
    end
end

local function getSelfColor(wid )
    local relation = mapData.getRelation(math.floor(wid/10000), wid%10000)
    if not relation or relation == mapAreaRelation.all_free then
        return ccc3(255,255,255)
    elseif relation == mapAreaRelation.own_self then
        return ccc3(0,255,0)
    elseif relation == mapAreaRelation.free_ally then
        return ccc3(0,0,255)
    elseif relation == mapAreaRelation.attach_same_higher or relation == mapAreaRelation.attach_higher_up then
        return ccc3(233,144,227)
    elseif relation == mapAreaRelation.free_underling then
        return ccc3(255,255,0)
    else
        return ccc3(255,0,0)
    end
end

local function hideAllGuideAnimation()
    if m_pCircleAnimation then 
        m_pCircleAnimation:setVisible(false)
    end

    if m_pFingerAnimation then 
        m_pFingerAnimation:setVisible(false)
    end
end

local function onFrameEvent(bone,evt,originFrameIndex,currentFrameIndex)
    if evt == "finish" then
        if m_pFingerAnimation then
            m_pFingerAnimation:getAnimation():play("left_anim")
        end
    end
end



local function onFrameEventDingWei(bone,evt,originFrameIndex,currentFrameIndex)
    if evt == "finished" then
        if m_pCircleAnimation then 
            m_pCircleAnimation:getAnimation():playWithIndex(0)
        end
    end
end
local function showGuideAnimation()
    if not main_layer then return end
    if is_nonforcedGuideFinished2012 then return end
    
    if i_lastActivedNonforcedGuideId == com_guide_id_list.CONST_GUIDE_2012 then 
        if not m_pCircleAnimation  then 
            local btn_cityList_switch = tolua.cast(main_layer:getChildByName("btn_cityList_switch"),"Button")

            CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou_dingweiguanquan.ExportJson")
            m_pCircleAnimation = CCArmature:create("xinshou_dingweiguanquan")
            m_pCircleAnimation:getAnimation():playWithIndex(0)
            m_pCircleAnimation:ignoreAnchorPointForPosition(false)
            m_pCircleAnimation:setAnchorPoint(cc.p(0.5, 0.5))
            btn_cityList_switch:addChild(m_pCircleAnimation)
            m_pCircleAnimation:setPosition(cc.p(1,-1.5 ))
            m_pCircleAnimation:setScale(0.9)
            m_pCircleAnimation:getAnimation():setFrameEventCallFunc(onFrameEventDingWei)
            
        end
        m_pCircleAnimation:setVisible(true)
    end

    if i_lastActivedNonforcedGuideId == com_guide_id_list.CONST_GUIDE_2013 then 
        if not m_pFingerAnimation then 
            local container_cityList = tolua.cast(main_layer:getChildByName("container_cityList"),"Layout")
            CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xinshou/xinshou_zhiyinguanquan.ExportJson")
            m_pFingerAnimation = CCArmature:create("xinshou_zhiyinguanquan")
            m_pFingerAnimation:getAnimation():play("left_anim")
            m_pFingerAnimation:getAnimation():setFrameEventCallFunc(onFrameEvent)
            container_cityList:addChild(m_pFingerAnimation)
            m_pFingerAnimation:setPosition(cc.p(75,-25))
        end
        m_pFingerAnimation:setVisible(true)
    end

end

local function disposeSchedulerHandler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
    end
    mainCityNotInScreenLastTimestamp = 0
    i_lastActivedNonforcedGuideId = 0

    if m_pCircleAnimation then 
        CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou/xinshou_dingweiguanquan.ExportJson")
        m_pCircleAnimation = nil
    end

    if m_pFingerAnimation then 
        CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xinshou/xinshou_zhiyinguanquan.ExportJson")
        m_pFingerAnimation = nil
    end
end


local function getNonforcedGuideKey(guide_id)
    return userData.getUserHelpId() .. "_nonforcedguide_" .. guide_id
end

local is_nonforcedGuideFinished2012 = false

function deleteNonforceGuide2012()
    is_nonforcedGuideFinished2012 = true
    hideAllGuideAnimation()
    CCUserDefault:sharedUserDefault():setIntegerForKey(getNonforcedGuideKey(com_guide_id_list.CONST_GUIDE_2012),1)
    disposeSchedulerHandler()
end
function activeNonforcedGuide(guide_id)

    if i_lastActivedNonforcedGuideId == guide_id then return end

    if guide_id == com_guide_id_list.CONST_GUIDE_2012  and 
        i_lastActivedNonforcedGuideId == com_guide_id_list.CONST_GUIDE_2013 then 
        return 
    end
    hideAllGuideAnimation()

    if mainOption.getIsIncity() then return end

    if guide_id == com_guide_id_list.CONST_GUIDE_2012 then 

        if is_nonforcedGuideFinished2012 then return end

        if not mainCityNotInScreenLastTimestamp 
            or mainCityNotInScreenLastTimestamp == 0 
            or userData.getServerTime() - mainCityNotInScreenLastTimestamp < 5 then 
            return 
        end
        

        i_lastActivedNonforcedGuideId = com_guide_id_list.CONST_GUIDE_2012 

        if CityListOwnedAndMarked.getShowState() then 
            guide_id = com_guide_id_list.CONST_GUIDE_2013
        end
    end


    if guide_id == com_guide_id_list.CONST_GUIDE_2013 then 

        if i_lastActivedNonforcedGuideId ~= com_guide_id_list.CONST_GUIDE_2012 then 
            return 
        end
    end

    i_lastActivedNonforcedGuideId = guide_id

    showGuideAnimation()
end

function deactiveNonforcedGuide(guide_id)
    hideAllGuideAnimation()


    if guide_id == i_lastActivedNonforcedGuideId then 
        i_lastActivedNonforcedGuideId = 0
    end

    if guide_id == com_guide_id_list.CONST_GUIDE_2013  then 
        activeNonforcedGuide(com_guide_id_list.CONST_GUIDE_2012)
    end

    
end






local function checkMainCityOutScreenState()
    if mainCityNotInScreenLastTimestamp and mainCityNotInScreenLastTimestamp ~= 0 then 
        if userData.getServerTime() - mainCityNotInScreenLastTimestamp >= 5 then 
            activeNonforcedGuide(com_guide_id_list.CONST_GUIDE_2012)
        end
    end
end

local function updateScheduler()
    
    -- 
    local mainWid = userData.getMainPos()
    local main_coor_x = math.floor(mainWid /10000)
    local main_coor_y = mainWid % 10000


    checkMainCityOutScreenState()
    if mapController.isCoordinateInScreen(main_coor_x,main_coor_y) then 
        mainCityNotInScreenLastTimestamp = 0
        deactiveNonforcedGuide(com_guide_id_list.CONST_GUIDE_2012)
    else
        if mainCityNotInScreenLastTimestamp == 0 then 
            mainCityNotInScreenLastTimestamp = userData.getServerTime()
        end
    end
end

local function activeSchedulerHandler()
    
    
    local state = CCUserDefault:sharedUserDefault():getIntegerForKey(getNonforcedGuideKey(com_guide_id_list.CONST_GUIDE_2012))
    if state and state == 1 then 
        is_nonforcedGuideFinished2012 = true
        return 
    end

    is_nonforcedGuideFinished2012 = false

    disposeSchedulerHandler()
    mainCityNotInScreenLastTimestamp = 0
    schedulerHandler = scheduler.create(updateScheduler,1)
end

----------------------------------------- 非强制引导 end

local function setLightEffect( x1,y1,width1,height1)
    local p_temp = m_sprite
    local x,y,width,height = x1,y1,width1,height1
    
    if x + width > p_temp:getContentSize().width then
        width = p_temp:getContentSize().width - x
    end

    if y + height > p_temp:getContentSize().height then
        height = p_temp:getContentSize().height - y
    end


    local left = x/p_temp:getContentSize().width
    local right = (x + width)/p_temp:getContentSize().width
    local up = 1-(y+ height)/p_temp:getContentSize().height
    local down = 1-y/p_temp:getContentSize().height 
    -- if y + height > p_temp:getContentSize().height then
    --     y = 0
    -- else
    --     y = p_temp:getContentSize().height- y -height
    -- end
    p_temp:setLight(kCCSpritelight, 255*0.5, 15, left, right, up, down)
end

local function getPos(coorX, coorY  )
    if not main_layer then return end
    
    local panel_root = tolua.cast(main_layer:getChildByName("map_panel"),"Layout")
    local temp_panel = tolua.cast(panel_root:getChildByName("Panel_342171"),"Layout")
    
    local map_content_panel = tolua.cast(temp_panel:getChildByName("Panel_322621"),"Layout")
    local width,height = map_content_panel:getSize().width, map_content_panel:getSize().height
    return height*(coorX+coorY)/1501, height/2*((coorY-coorX)/1501+1)
end

function get_top_height()
    if not main_layer then
        return 0
    end

    return main_layer:getSize().height * config.getgScale()
end

function checkTouchState(x,y)
    if not main_layer then return end
    local btn_cityList_switch = tolua.cast(main_layer:getChildByName("btn_cityList_switch"),"Button")
    if not btn_cityList_switch:hitTest(cc.p(x,y)) then 
        if CityListOwnedAndMarked then 
            CityListOwnedAndMarked.checkTouchState(x,y)
        end
    end
end
--自己的领地和要塞，主城，分城
function initOwnCity( )
    if not main_layer then return end
    local main_city_id = userData.getMainPos()
    local panel = tolua.cast(main_layer:getChildByName("map_panel"),"Layout")
    local temp_panel = tolua.cast(panel:getChildByName("Panel_342171"),"Layout")
    local map_content_panel = tolua.cast(temp_panel:getChildByName("Panel_322621"),"Layout")
    local layerPanel = tolua.cast(map_content_panel:getChildByName("Panel_316402"),"Layout")
    local lingdiPanel = tolua.cast(map_content_panel:getChildByName("Panel_548885"),"Layout")

    for i, v in ipairs(m_arrOwnCityData) do
        v:removeFromParentAndCleanup(true)
    end

    for i, v in ipairs(m_arrOwnLingdiData) do
        v:removeFromParentAndCleanup(true)
    end

    m_arrOwnCityData = {}
    m_arrOwnLingdiData = {}

    local layer = nil
    local temp_layer = nil
    local temp_pos_x, temp_pos_y = nil, nil

    local drawNode = function (color, wid, city_type)
        -- layer = tolua.cast(layerPanel:clone(),"Layout")
        -- layer:setBackGroundColor(color)
        temp_pos_x, temp_pos_y = getPos(math.floor(wid/10000), wid%10000)
        -- layer:setAnchorPoint(cc.p(0.5,0.5))
        layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
        layer:setColor(color)
        layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
        return layer
    end

    local drawCityNode = function (color, wid, city_type)

        layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
        layer:setColor(ccc3(0,0,0))
        temp_pos_x, temp_pos_y = getPos(math.floor(wid/10000), wid%10000)
        layer:setPosition(cc.p(temp_pos_x, temp_pos_y))

        temp_layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
        temp_layer:setColor(color)
        temp_layer:setPosition(cc.p(layer:getContentSize().width/2,layer:getContentSize().height/2))
        temp_layer:setScale(0.5)
        layer:addChild(temp_layer)
        -- itemBatch:addChild(layer,1)
        return layer
    end

    local node = nil
    for i, v in pairs(allTableData[dbTableDesList.world_city.name]) do
        if v.city_type == cityTypeDefine.zhucheng then
            node = drawCityNode(ccc3(0,255,0), v.wid, v.city_type )
            itemBatch:addChild(node,1)
            table.insert(m_arrOwnCityData,node)
        elseif v.city_type == cityTypeDefine.fencheng then
            node = drawCityNode(ccc3(0,255,0), v.wid, v.city_type )
            itemBatch:addChild(node,1)
            table.insert(m_arrOwnCityData,node)
        elseif v.city_type == cityTypeDefine.yaosai then
            node = drawCityNode(ccc3(0,255,0), v.wid, v.city_type )
            itemBatch:addChild(node,1)
            table.insert(m_arrOwnCityData,node)
        elseif v.city_type == cityTypeDefine.player_chengqu or v.city_type == cityTypeDefine.lingdi then
            node = drawNode(ccc3(0,255,0), v.wid, v.city_type )
            itemBatch:addChild(node,0)
            table.insert(m_arrOwnLingdiData,node)
        end
    end
end

local function initCity( )
    if not main_layer then return end
    local main_city_id = userData.getMainPos()
    local panel = tolua.cast(main_layer:getChildByName("map_panel"),"Layout")
    local temp_panel = tolua.cast(panel:getChildByName("Panel_342171"),"Layout")
    local map_content_panel = tolua.cast(temp_panel:getChildByName("Panel_322621"),"Layout")
    local layerPanel = tolua.cast(map_content_panel:getChildByName("Panel_316402"),"Layout")
    -- local temp_pos_x, temp_pos_y = getPos(math.floor(main_city_id/10000), main_city_id%10000)
    -- local layer = layerPanel:clone()--cc.LayerColor:create(cc.c4b(106,255,255,255), 3, 3)
    -- layer:setAnchorPoint(cc.p(0.5,0.5))
    -- map_content_panel:addChild(layer,1)
    -- layer:setPosition(cc.p(temp_pos_x, temp_pos_y))

    local capitalParam = {}
    for i, v in ipairs(REGION_CAPITAL_PARAM) do
        if NPC_CAPITAL_PARAM ~= v then
            capitalParam[v] = 1
        end
    end
    m_arrNpcCityData = {}
    local temp_pos_x, temp_pos_y = nil, nil 
    local layer = nil
    for i, v in pairs(Tb_cfg_world_city) do
        
        if v.city_type == cityTypeDefine.npc_cheng and v.param%100 ~= 1 and v.param%100 ~= 2 then
            -- 州首府
            if capitalParam[v.param] then
                temp_pos_x, temp_pos_y = getPos(math.floor(v.wid/10000), v.wid%10000)
                -- layer = tolua.cast(layerPanel:clone(),"Layout")
                -- layer:setBackGroundColor(getColor(v.wid))
                -- layer:setAnchorPoint(cc.p(0.5,0.5))
                -- layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                -- map_content_panel:addChild(layer,1)
                layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
                layer:setColor(getColor(v.wid))
                layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                itemBatch:addChild(layer,1)
                table.insert(m_arrNpcCityData,{layer, v.wid} )
            -- 关卡
            elseif v.param >=NPC_CITY_PARAM_GUAN_QIA[1] and v.param <= NPC_CITY_PARAM_GUAN_QIA[2] then
                temp_pos_x, temp_pos_y = getPos(math.floor(v.wid/10000), v.wid%10000)
                -- layer = tolua.cast(layerPanel:clone(),"Layout")--cc.LayerColor:create(cc.c4b(255,236,106,255), 3, 3)
                -- layer:setBackGroundColor(getColor(v.wid))
                -- layer:setAnchorPoint(cc.p(0.5,0.5))
                -- layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                -- map_content_panel:addChild(layer,1)
                layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
                layer:setColor(getColor(v.wid))
                layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                itemBatch:addChild(layer,1)
                table.insert(m_arrNpcCityData,{layer, v.wid} )
            -- 国都
            elseif v.param == NPC_CAPITAL_PARAM then
                temp_pos_x, temp_pos_y = getPos(math.floor(v.wid/10000), v.wid%10000)
                -- layer = tolua.cast(layerPanel:clone(),"Layout")--cc.LayerColor:create(cc.c4b(255,236,106,255), 3, 3)
                -- layer:setBackGroundColor(getColor(v.wid))
                -- layer:setAnchorPoint(cc.p(0.5,0.5))
                -- layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                -- map_content_panel:addChild(layer,1)
                layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
                layer:setColor(getColor(v.wid))
                layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                itemBatch:addChild(layer,1)
                table.insert(m_arrNpcCityData,{layer, v.wid} )
            -- 其他
            else
                temp_pos_x, temp_pos_y = getPos(math.floor(v.wid/10000), v.wid%10000)
                -- layer = tolua.cast(layerPanel:clone(),"Layout")--cc.LayerColor:create(cc.c4b(255,236,106,255), 3, 3)
                -- layer:setBackGroundColor(getColor(v.wid))
                -- layer:setAnchorPoint(cc.p(0.5,0.5))
                -- layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                -- map_content_panel:addChild(layer,1)
                layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
                layer:setColor(getColor(v.wid))
                layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
                itemBatch:addChild(layer,1)
                table.insert(m_arrNpcCityData,{layer, v.wid} )
            end
        
        elseif v.city_type == cityTypeDefine.matou then
            temp_pos_x, temp_pos_y = getPos(math.floor(v.wid/10000), v.wid%10000)
            -- layer = tolua.cast(layerPanel:clone(),"Layout")--cc.LayerColor:create(cc.c4b(255,236,106,255), 3, 3)
            -- layer:setBackGroundColor(getSelfColor(v.wid ))
            -- layer:setAnchorPoint(cc.p(0.5,0.5))
            -- layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
            -- map_content_panel:addChild(layer,1)
            layer = cc.Sprite:createWithSpriteFrameName("minimap_item_color.png")
            layer:setColor(getSelfColor(v.wid))
            layer:setPosition(cc.p(temp_pos_x, temp_pos_y))
            itemBatch:addChild(layer,1)
            table.insert(m_arrNpcCityData,{layer, v.wid} )
        end
    end
end

function hideEffect(duration)
    if not main_layer then return end
    if not duration then duration = 0.5 end
    uiUtil.hideScaleEffect(main_layer,nil,duration)
    miniMapVisible()
end
function showEffect(duration)
    if not main_layer then return end
    if not duration then duration = 0.5 end
    uiUtil.showScaleEffect(main_layer,nil,duration,nil,nil,0)
    miniMapVisible()
end

function showTipsEffectMarkedLand()
    if not main_layer then return end
    local btn_cityList_switch = tolua.cast(main_layer:getChildByName("btn_cityList_switch"),"Button")
    local img_tips = uiUtil.getConvertChildByName(btn_cityList_switch,"img_tips")
    img_tips:setVisible(true)
    local action = animation.sequence({CCFadeIn:create(0.4),CCFadeOut:create(0.4),
        cc.CallFunc:create(function()
            img_tips:setVisible(false)
        end)})
    img_tips:runAction(action)
end



function create( parent_layer )
    m_arrOwnCityData = {}
    m_arrOwnLingdiData = {}
	local temp_left_widget = GUIReader:shareReader():widgetFromJsonFile("test/Mini_Map_xin.json")
    temp_left_widget:setTag(970)
    temp_left_widget:ignoreAnchorPointForPosition(false)
    temp_left_widget:setAnchorPoint(cc.p(1,1))
    temp_left_widget:setScale(config.getgScale())
    temp_left_widget:setPosition(cc.p(config.getWinSize().width, config.getWinSize().height))
    parent_layer:addWidget(temp_left_widget)
    main_layer = temp_left_widget
    local panel = tolua.cast(temp_left_widget:getChildByName("map_panel"),"Layout")
    m_sprite = cc.Sprite:create("test/res_single/Small_map_new.png")
    m_scale = 2
    m_sprite:setScale(m_scale)
    m_sprite:setAnchorPoint(cc.p(0,0))
    panel:addChild(m_sprite)

    local temp_panel = tolua.cast(panel:getChildByName("Panel_342171"),"Layout")
    local map_content_panel = tolua.cast(temp_panel:getChildByName("Panel_322621"),"Layout")

    itemBatch = CCSpriteBatchNode:create("gameResources/map/smallMiniMap_item.png")
    map_content_panel:addChild(itemBatch)

    initCity( )
    initOwnCity()
    coordToPicture()

    local button = tolua.cast(panel:getChildByName("Button_287741"),"Button")
    button:addTouchEventListener(function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if main_layer:isVisible() then
                button:setTouchEnabled(false)
                miniMapManager.create()
            end
        end
    end)
    local map_button = tolua.cast(main_layer:getChildByName("Button_287741_0"),"Button")
    map_button:setRotation(0)
    tolua.cast(temp_left_widget:getChildByName("Button_287741_0"),"Button"):addTouchEventListener(function ( sender, eventType )
        if eventType == TOUCH_EVENT_ENDED then
            if main_layer:isVisible() then
                miniMapVisible( )
            end
        end
    end)


    local container_cityList = tolua.cast(main_layer:getChildByName("container_cityList"),"Layout")
    container_cityList:setTouchEnabled(true)


    


    local btn_cityList_switch = tolua.cast(main_layer:getChildByName("btn_cityList_switch"),"Button")
    local img_tips = uiUtil.getConvertChildByName(btn_cityList_switch,"img_tips")
    img_tips:setVisible(false)
    btn_cityList_switch:setTouchEnabled(true)
    btn_cityList_switch:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
            CityListOwnedAndMarked.switchShowState()

        end
    end)



    UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.update, SmallMiniMap.initOwnCity)
    UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.remove, SmallMiniMap.initOwnCity)
    UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.add, SmallMiniMap.initOwnCity)



    require("game/option/city_list_owned_and_marked")
    CityListOwnedAndMarked.create(container_cityList)


    activeSchedulerHandler()
end

function miniMapButtonVisible(flag )
    if not main_layer then return end
    local panel = tolua.cast(main_layer:getChildByName("map_panel"),"Layout")
    local button = tolua.cast(panel:getChildByName("Button_287741"),"Button")
    local function setvisi( )
        button:setTouchEnabled(flag)
        button:setVisible(flag)
    end
    if flag then
        button:runAction(animation.sequence({cc.CallFunc:create(function ( )
            button:setVisible(true)
        end),CCFadeIn:create(0.3),cc.CallFunc:create(setvisi)}))
    else
        button:runAction(animation.sequence({CCFadeOut:create(0.3),cc.CallFunc:create(setvisi)}))
    end
end

function miniMapVisible()
    if not main_layer then return end
    local panel = tolua.cast(main_layer:getChildByName("map_panel"),"Layout")
    local button = tolua.cast(panel:getChildByName("Button_287741"),"Button")
    local map_button = tolua.cast(main_layer:getChildByName("Button_287741_0"),"Button")

    -- m_bMiniMapVisibel = flag
    local function setpanelvisi( )
        button:setTouchEnabled(not panel:isVisible())
        panel:setVisible(not panel:isVisible())
    end

    if not panel:isVisible() then
        panel:runAction(animation.sequence({cc.CallFunc:create(setpanelvisi),CCFadeIn:create(0.3)}))
    else
        panel:runAction(animation.sequence({CCFadeOut:create(0.3),cc.CallFunc:create(setpanelvisi)}))
    end
    map_button:runAction(animation.sequence({cc.CallFunc:create(function ( )
            map_button:setTouchEnabled(false)
        end),CCRotateBy:create(0.3, (panel:isVisible() and -180) or 180), cc.CallFunc:create(function ( )
            map_button:setTouchEnabled(true)
        end)}))
end

function setMapVisibel( flag )
    if not main_layer then return end
    main_layer:setVisible(flag)
end




function remove( )
	if CityListOwnedAndMarked then 
        CityListOwnedAndMarked.remove()
    end
    m_arrNpcCityData = nil
    main_layer = nil
    itemBatch = nil
    m_sprite = nil
    m_arrOwnCityData = nil
    m_arrOwnLingdiData = nil
    UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.update, SmallMiniMap.initOwnCity)
    UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.remove, SmallMiniMap.initOwnCity)
    UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.add, SmallMiniMap.initOwnCity)

    disposeSchedulerHandler()

    
end

function coordToPicture()
    if not main_layer then return end
    local coorX, coorY = map.touchInMap(config.getWinSize().width/2, config.getWinSize().height/2)
    if not coorX or not coorY then return end
    local panel_root = tolua.cast(main_layer:getChildByName("map_panel"),"Layout")
    local temp_panel = tolua.cast(panel_root:getChildByName("Panel_342171"),"Layout")
    local map_content_panel = tolua.cast(temp_panel:getChildByName("Panel_322621"),"Layout")
    local x, y = getPos(coorX, coorY  )
    map_content_panel:setPosition(cc.p(temp_panel:getSize().width/2 - x, temp_panel:getSize().height/2-y ))
    local x1 = (x-panel_root:getSize().width/2 > 0 and x-panel_root:getSize().width/2) or 0
    local y1=  (y-panel_root:getSize().height/2 > 0 and y-panel_root:getSize().height/2) or 0
    setLightEffect( x1/m_scale, y1/m_scale, panel_root:getSize().width/m_scale, panel_root:getSize().height/m_scale)
    m_sprite:setPosition(cc.p(panel_root:getSize().width/2 - x, panel_root:getSize().height/2-y ))
    local panel = tolua.cast(panel_root:getChildByName("Panel_311321"),"Layout")
    panel:removeAllChildrenWithCleanup(true)
    local str = coorX..","..coorY --string.len(tostring(coorX)) + string.len(tostring(coorY)) + 1
    local image = nil
    local h = 0
    for i=1, string.len(str) do
        image = ImageView:create()
        panel:addChild(image)
        image:setPositionX(h)
        if string.sub(str, i,i) == "," then
            image:loadTexture("douhao.png", UI_TEX_TYPE_PLIST)
            image:setAnchorPoint(cc.p(0.5,0))
            h = h + image:getSize().width-15
        else
            image:loadTexture(string.sub(str, i,i).."j.png", UI_TEX_TYPE_PLIST)
            image:setAnchorPoint(cc.p(0.5,0))
            h = h + image:getSize().width
        end
    end
end

function setNpcCityColor( )
    if not main_layer then return end
    local coorX, coorY = map.touchInMap(config.getWinSize().width/2, config.getWinSize().height/2)
    if not coorX or not coorY then return end
    local panel_root = tolua.cast(main_layer:getChildByName("map_panel"),"Layout")
    local point = nil

    for i ,v in pairs(m_arrNpcCityData) do
        -- point = v[1]:convertToWorldSpace(cc.p(0,0))
        if Tb_cfg_world_city[v[2]].city_type == cityTypeDefine.matou then
            v[1]:setColor(getSelfColor(v[2]))
        else
            v[1]:setColor(getColor(v[2]))
        end
        -- if not panel_root:hitTest(point) then
        --     v[1]:setVisible(false)
        -- else
        --     v[1]:setVisible(true)
        -- end
    end
end

function setNpcCityColorWhenOpenMiniMap( )
    if m_arrNpcCityData then
        local npcData = MiniMapData.getWorldNpcCityData()
        for i, v in pairs(m_arrNpcCityData) do
            if npcData[v[2]] then
                v[1]:setColor(npcData[v[2]].color)
            end
        end
    end
end