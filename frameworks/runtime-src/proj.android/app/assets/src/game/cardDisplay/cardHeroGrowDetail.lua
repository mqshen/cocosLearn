local mainLayer = nil
-- 武将卡成长率详情

local m_iHeroId = nil --卡牌类型ID
local m_iHeroUid = nil -- 卡牌唯一ID

local function do_remove_self()
    if mainLayer then 
        mainLayer:removeFromParentAndCleanup(true)
        mainLayer = nil

        uiManager.remove_self_panel(uiIndexDefine.CARD_HERO_GROW_DETAIL)
    end
    m_iHeroId = nil
    m_iHeroUid = nil
end

local function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.CARD_HERO_GROW_DETAIL,mainLayer,do_remove_self)
end

local function dealwithTouchEvent(x,y)
    if not mainLayer then return false end

    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return false end
    if mainWidget:hitTest(cc.p(x,y)) then 
        return false
    else
        remove_self()
        return true
    end
end

local function reloadData()
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local basic_hero_info = Tb_cfg_hero[m_iHeroId]
    
    -- 武将成长率信息
    local label_rate_attack = uiUtil.getConvertChildByName(mainWidget,"label_rate_attack")
    local label_rate_intel = uiUtil.getConvertChildByName(mainWidget,"label_rate_intel")
    local label_rate_defense = uiUtil.getConvertChildByName(mainWidget,"label_rate_defense")
    local label_rate_speed = uiUtil.getConvertChildByName(mainWidget,"label_rate_speed")
    local label_rate_attack_city = uiUtil.getConvertChildByName(mainWidget,"label_rate_attack_city")
    
    
    label_rate_attack:setText(basic_hero_info.attack_grow/100)
    label_rate_intel:setText(basic_hero_info.intel_grow/100)
    label_rate_defense:setText(basic_hero_info.defence_grow/100)
    label_rate_speed:setText(basic_hero_info.speed_grow/100)
    label_rate_attack_city:setText(basic_hero_info.destroy_grow/100)

    local label_tips_sex = uiUtil.getConvertChildByName(mainWidget,"label_tips_sex")
    -- TODOTK 中文收集
    if basic_hero_info.sex == 0 then 
        label_tips_sex:setText("每10级获得10点属性点")
    else
        label_tips_sex:setText("女性武将，每10级获得15点属性点")
    end

    local consume_res_list = {}
    consume_res_list[resType.wood] = 0
    consume_res_list[resType.stone] = 0
    consume_res_list[resType.iron] = 0
    consume_res_list[resType.food] = 0

    for k,v in pairs(basic_hero_info.recruit_cost) do
        consume_res_list[v[1]] = consume_res_list[v[1]] + v[2]
    end

    
    local panel_soldier_cost = uiUtil.getConvertChildByName(mainWidget,"panel_soldier_cost")
    local label_cost_wood = uiUtil.getConvertChildByName(panel_soldier_cost,"label_cost_wood")
    -- local label_cost_stone = uiUtil.getConvertChildByName(panel_soldier_cost,"label_cost_stone")
    local label_cost_iron = uiUtil.getConvertChildByName(panel_soldier_cost,"label_cost_iron")
    local label_cost_food = uiUtil.getConvertChildByName(panel_soldier_cost,"label_cost_food")
    local label_cost_food_per_h = uiUtil.getConvertChildByName(panel_soldier_cost,"label_cost_food_per_h")

    label_cost_wood:setText(consume_res_list[resType.wood])
    -- label_cost_stone:setText(consume_res_list[resType.stone])
    label_cost_iron:setText(consume_res_list[resType.iron])
    label_cost_food:setText(consume_res_list[resType.food])

    label_cost_food_per_h:setText(basic_hero_info.food_cost .. languagePack["liangshi"] .. "/"  .. languagePack["xiaoshi"])

end

local function create()
    if mainLayer then return end

    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/chengzhang_0.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    mainWidget:setTouchEnabled(true)

    mainLayer = TouchGroup:create()
    mainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(mainLayer, uiIndexDefine.CARD_HERO_GROW_DETAIL)
    uiManager.showConfigEffect(uiIndexDefine.CARD_HERO_GROW_DETAIL,mainLayer)



    local btn_close = uiUtil.getConvertChildByName(mainWidget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self()
        end
    end)
end

-- heroId 武将卡类型ID 
-- heroUid 武将卡唯一ID nil 表示是无主的

local function show(heroId,heroUid)
    if not heroId and not heroUid then return end

    -- 目前只需要heroId 即可
    if not heroId then return end
    -- 武将卡配置信息不存在
    if not Tb_cfg_hero[heroId] then return end

    m_iHeroUid = heroUid
    m_iHeroId = heroId

    create()
    reloadData()
end

--[[
local function get_guide_widget(temp_guide_id)
    if not mainLayer then
        return nil
    end

    return mainLayer:getWidgetByTag(999)
end
--]]

cardHeroGrowDetail = {
    show = show,
    remove_self = remove_self,
    dealwithTouchEvent = dealwithTouchEvent,
    --get_guide_widget = get_guide_widget
}