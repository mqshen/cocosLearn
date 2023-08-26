-- 用于物品获取的统一动画
-- （卡牌抽卡方式，建筑队列，金币，武将卡）

module("comItemReceiveEffect", package.seeall)


local ITEM_TYPE = {}
ITEM_TYPE[taskAwardType.TYPE_CARD_EXTRACT_MODE] = true
ITEM_TYPE[taskAwardType.TYPE_BUILD_QUEUE] = true
ITEM_TYPE[taskAwardType.TYPE_GOLD] = true
ITEM_TYPE[taskAwardType.TYPE_CARD_HERO] = true
ITEM_TYPE[taskAwardType.TYPE_NEW_SKILL] = true



local m_pMainWidget = nil
local m_iItemType = nil

local m_strTipsText = nil
local m_strContentImgeUrl = nil
local m_strContentText = nil
local m_strTypeImageUrl = nil



local m_lstShowList = nil
local m_iCurShowIndx = nil

function checkType(itemType)
    if not ITEM_TYPE[itemType] then return false end
    m_iItemType = itemType
    return true
end


function remove()
    if m_pMainWidget then 

        

        m_pMainWidget:removeFromParentAndCleanup(true)
        m_pMainWidget = nil

        m_iItemType = nil

        m_strTipsText = nil
        m_strContentImgeUrl = nil
        m_strContentText = nil
        m_strTypeImageUrl = nil

    end
end


local function deal_with_animation_finished()
    local light_img = uiUtil.getConvertChildByName(m_pMainWidget,"light_img")
    breathAnimUtil.start_anim(light_img,true, 50, 255, 0.2, 0)
    local itemInfo = m_lstShowList[m_iCurShowIndx]
    if itemInfo and itemInfo.callback then 
        itemInfo.callback()
    end
end
local function startEffect(callback)
    if not m_pMainWidget then return end

    local common_img = uiUtil.getConvertChildByName(m_pMainWidget,"common_img")
    local special_img = uiUtil.getConvertChildByName(m_pMainWidget,"special_img")
    local special_img_2 = uiUtil.getConvertChildByName(m_pMainWidget,"special_img_2")
    common_img:setScale(0.1)
    special_img:setScale(0.1)
    special_img_2:setScale(0.1)

    local temp_time_num = 0.2
    local fade_in = CCFadeIn:create(temp_time_num)
    local first_scale_to = CCScaleTo:create(temp_time_num, 1)
    local temp_spawn = CCSpawn:createWithTwoActions(fade_in,first_scale_to)
    common_img:runAction(temp_spawn)
    special_img:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCSpawn"))
    special_img_2:runAction(tolua.cast(temp_spawn:copy():autorelease(), "CCSpawn"))
    


    local function finally()
        deal_with_animation_finished()
        if callback then callback() end
    end
    --背景发光特效
    local light_img = uiUtil.getConvertChildByName(m_pMainWidget,"light_img")
    light_img:setScale(0.2)
    local second_scale_to = CCScaleTo:create(temp_time_num, 2)
    local light_spawn = CCSpawn:createWithTwoActions(tolua.cast(fade_in:copy():autorelease(), "CCFadeIn"), second_scale_to)
    local fun_call = cc.CallFunc:create(finally)
    local temp_sequence = cc.Sequence:createWithTwoActions(light_spawn,fun_call)
    light_img:runAction(temp_sequence)
end


local function autoCenterLayout()
    if not m_pMainWidget then return end

    local special_img = uiUtil.getConvertChildByName(m_pMainWidget,"special_img")
    local special_img_2 = uiUtil.getConvertChildByName(m_pMainWidget,"special_img_2")
    if special_img:isVisible() or special_img_2:isVisible() then 
        --tips部分可见 已在UI编辑器里布好局
        --TODOTK  不要依赖于编辑器
        -- return 
    else
        local new_pos_y = m_pMainWidget:getContentSize().height/2
        
        local common_img = uiUtil.getConvertChildByName(m_pMainWidget,"common_img")
        common_img:setPositionY(new_pos_y)
        local light_img = uiUtil.getConvertChildByName(m_pMainWidget,"light_img")
        light_img:setPositionY(new_pos_y)
    end

    

end

-- 下半部分的tips 部分
local function setContentTipsLayOut()
    if not m_pMainWidget then return end
    local special_img = uiUtil.getConvertChildByName(m_pMainWidget,"special_img")

    local special_img_2 = uiUtil.getConvertChildByName(m_pMainWidget,"special_img_2")
    special_img_2:setVisible(false)
    local content_label = uiUtil.getConvertChildByName(special_img,"content_label")
    if m_strTipsText then 
        special_img:setVisible(true)
        content_label:setText(m_strTipsText)
    else
        special_img:setVisible(false)
    end

    if m_iItemType == taskAwardType.TYPE_NEW_SKILL then 
        special_img_2:setVisible(true)
        special_img:setVisible(false)
    end
end


local function setTypeImageLayout()
    if not m_pMainWidget then return end
    local common_img = uiUtil.getConvertChildByName(m_pMainWidget,"common_img")

    local type_img = uiUtil.getConvertChildByName(common_img,"type_img")

    type_img:loadTexture(m_strTypeImageUrl, UI_TEX_TYPE_PLIST)

end


local function setContentLayout()
    if not m_pMainWidget then return end
    local common_img = uiUtil.getConvertChildByName(m_pMainWidget,"common_img")
    local label_img = uiUtil.getConvertChildByName(common_img,"label_img")


    -- 正文 文本类型
    local content_txt = uiUtil.getConvertChildByName(label_img,"content_label")
    if m_strContentText then 
        content_txt:setVisible(true)
        content_txt:setText(m_strContentText)
    else
        content_txt:setVisible(false)
    end

    -- 正文 图片类型
    local name_img = uiUtil.getConvertChildByName(label_img,"name_img")
    if m_strContentImgeUrl then 
        name_img:setVisible(true)
        name_img:loadTexture(m_strContentImgeUrl,UI_TEX_TYPE_PLIST)
    else
        name_img:setVisible(false)
    end

end


local function initState()
    if not m_pMainWidget then return end
    if not m_iCurShowIndx or not m_lstShowList then return end
    if not m_lstShowList[m_iCurShowIndx] then return end

    local itemInfo = m_lstShowList[m_iCurShowIndx]
    m_strTipsText = itemInfo.strTipsText
    m_strContentImgeUrl = itemInfo.strContentImgeUrl
    m_strContentText = itemInfo.strContentText
    m_strTypeImageUrl = itemInfo.strTypeImageUrl
    m_iItemType = itemInfo.itemType
end


local function doPlayEffect(callback)
    if not m_iItemType then 
        if callback then callback() end
        return 
    end
    initState()

    setTypeImageLayout()
    setContentLayout()
    setContentTipsLayOut()

    autoCenterLayout()

    startEffect(callback)
end

local function doPlayReceiveList()
    if not m_pMainWidget then return end
    if not m_iCurShowIndx or not m_lstShowList then return end

    m_iCurShowIndx = m_iCurShowIndx + 1
    
    local itemInfo = m_lstShowList[m_iCurShowIndx]
    if itemInfo  and checkType(itemInfo.itemType) then 
        doPlayEffect()
    end
end

function dealwithTouchEvent(x,y)
    if not m_pMainWidget then
        return false
    end


    
    if m_iCurShowIndx >= #m_lstShowList then
        -- comItemReceiveEffect.remove()
        return false
    else
        doPlayReceiveList()
        return true
    end
end


-- 开始播放 获得特效
function beginReceiveList(itemTypeList)
    if not m_pMainWidget then return end

    if not itemTypeList then return nil end
    if #itemTypeList == 0 then return nil end

    m_iCurShowIndx = 0
    m_lstShowList = itemTypeList


    doPlayReceiveList()
end

function create()

    m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/texiaobeijing.json")
    m_pMainWidget:setTag(999)
    m_pMainWidget:setScale(config.getgScale())
    m_pMainWidget:ignoreAnchorPointForPosition(false)
    m_pMainWidget:setAnchorPoint(cc.p(0.5,0.5))
    m_pMainWidget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

    return m_pMainWidget
end


