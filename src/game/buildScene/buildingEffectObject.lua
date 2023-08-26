module("buildingEffectObject", package.seeall)


-- local m_pMainLayer = nil

-- local m_tFlagExtendedWid = nil

-- local function do_remove_self()
--     if m_pMainLayer then
--         m_pMainLayer:removeFromParentAndCleanup(true)
--         m_pMainLayer = nil
--         uiManager.remove_self_panel(uiIndexDefine.INNER_CITY_BUILDING_EFFECT)
--         m_tFlagExtendedWid = nil
--     end    
-- end

-- function dealwithTouchEvent(x,y)
--     return false
-- end

-- function remove_self()
--     do_remove_self()
-- end


-- -- 城市区域外观
-- local function getComponentByIndx(index)
--     local cityComponentData = mapData.getCityComponentData( math.floor(mainBuildScene.getThisCityid()/10000),mainBuildScene.getThisCityid()%10000 )
--     if cityComponentData then 
--         for i, v in pairs(cityComponentData) do
--             if BUILDING_TYPE[index][v.view] then
--                 local component = mapData.getObject().building:getChildByTag(v.parentTag)
--                 if component then
--                     local temp_point = component:convertToWorldSpace(cc.p(component:getContentSize().width/2,component:getContentSize().height/2))
--                     local posX,posY = config.countWorldSpace(temp_point.x,temp_point.y,map.getAngel())
--                     -- return posX + component:getContentSize().width/2,posY + component:getContentSize().height/2
--                     return posX,posY,component
--                 end
--             end
--         end
--     end

--     return nil,nil,nil
-- end



-- local function playEffectByIndex(index)
--     local posX,posY = getComponentByIndx(index)
--     if not posX or not posY then return end

--     CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jianzhushengji.ExportJson")

--     local armature = CCArmature:create("jianzhushengji")
--     armature:getAnimation():playWithIndex(0)
--     armature:ignoreAnchorPointForPosition(false)
--     armature:setAnchorPoint(cc.p(0.5, 0.5))
--     armature:setScale(config.getgScale())
--     armature:setPosition(cc.p(posX ,posY ))

--     m_pMainLayer:addChild(armature)

--     local function animationCallFunc(armatureNode, eventType, name)
--         if eventType == 1 then
--             -- armatureNode:removeFromParentAndCleanup(true)
--             -- armature = nil
--         elseif eventType == 2 then 
--             -- armatureNode:removeFromParentAndCleanup(true)
--             -- armature = nil
--         end
--     end
--     armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
-- end


-- function reloadData()
--     if not m_pMainLayer then return end

--     for i =1,7 do 
--         local lastFlag = m_tFlagComponentExistByIndx[i]
--         local x,y,item = getComponentByIndx(i)
--         local curFlag = false
--         if item then 
--             curFlag = true
--         end


--         if lastFlag ~= curFlag then 
--             m_tFlagComponentExistByIndx[i] = curFlag
--             if curFlag == true then 
--                 playEffectByIndex(i)
--             end
--         end
--         playEffectByIndex(i)
--     end
-- end


-- --
-- function create()
--     if not mainBuildScene.getThisCityid() then return end

--     if m_pMainLayer then return end

--     m_pMainLayer = TouchGroup:create()


--     uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.INNER_CITY_BUILDING_EFFECT)

--     m_tFlagComponentExistByIndx = {}
--     for i = 1,7 do 
--         local x,y,item = getComponentByIndx(i)
--         if item then 
--             m_tFlagComponentExistByIndx[i] = true
--         end
--     end

--     reloadData()

-- end



local m_pMainLayer = nil


local function do_remove_self()
    if m_pMainLayer then
        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.INNER_CITY_BUILDING_EFFECT)
    end    
end

function dealwithTouchEvent(x,y)
    return false
end

function remove_self()
    do_remove_self()
end



--
function create()
    if not mainBuildScene.getThisCityid() then return end

    if m_pMainLayer then return end

    m_pMainLayer = TouchGroup:create()


    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.INNER_CITY_BUILDING_EFFECT)

end

function playWidExpandedEffect(wid)
    if not wid then return end

    local coorX = math.floor(wid/10000)
    local coorY = math.floor(wid%10000)
    local sprite = mapData.getLoadedMapLayer(coorX, coorY)
    if not sprite then return end

    if not mainBuildScene.getThisCityid() then return end
    if not m_pMainLayer then create() end

    tipsLayer.create(languagePack["building_expand_succeed_tips"])

    -- TODOTK 找地方把资源清掉
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jianzhushengji.ExportJson")

    local armature = CCArmature:create("jianzhushengji")
    armature:getAnimation():playWithIndex(0)
    armature:ignoreAnchorPointForPosition(false)
    armature:setAnchorPoint(cc.p(0.5, 0.5))
    armature:setScale(config.getgScale() * 1.5)


    m_pMainLayer:addChild(armature)

    local tempPoint = sprite:convertToWorldSpace(cc.p(100,50))
    local pointX, pointY = config.countWorldSpace(tempPoint.x, tempPoint.y, map.getAngel())
    armature:setPosition(cc.p(pointX, pointY))

    local function animationCallFunc(armatureNode, eventType, name)
        if eventType == 1 then
            armatureNode:removeFromParentAndCleanup(true)
            armature = nil
        elseif eventType == 2 then 
            armatureNode:removeFromParentAndCleanup(true)
            armature = nil
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)

end