local loginRewardHelper = {}




local function getCurLoginRewardCycle()
    for k,v in pairs(allTableData[dbTableDesList.user_login.name]) do
        return v.cycle_cur
    end
end

local function getCurLoginRewardCycleLoginedDays()
    for k,v in pairs(allTableData[dbTableDesList.user_login.name]) do
        return v.cycle_login_days
    end
end



local function getCurLoginRewardCycleTotalDays()
    local curCycleId = getCurLoginRewardCycle()
    local totalDays = 0
    for k,v in pairs(Tb_cfg_login_reward) do 
        if (curCycleId == math.floor( k/100 ) ) then 
            totalDays = totalDays + 1
        end
    end
    return totalDays
end



-- 获取当前周期的奖励配置
local function getRewardListCurCycle()
    local curCycleId = getCurLoginRewardCycle()
    local days = getCurLoginRewardCycleTotalDays()
    local retList = {}

    local rewardId = nil
    for i = 1,days do 
        rewardId = curCycleId * 100 + i
        if Tb_cfg_login_reward[rewardId] then 
            table.insert(retList,Tb_cfg_login_reward[rewardId])
        end
    end

    return retList
end


-- 获取登录天数对应的登录奖励配置
local function getDailyRewardDetailList(dayth)
    local rewardId = getCurLoginRewardCycle() * 100 + dayth
    return Tb_cfg_login_reward[rewardId]
end


-- 不是所有品质都有资源的
local res_icon_hero = ResDefineUtil.ui_login_res_icon_hero

local function getResIconByRewardType(rewardType)
    if not rewardType then return nil end
    if rewardType == resType.wood then 
        return ResDefineUtil.ui_login_res_icon[1]
    elseif rewardType == resType.stone then 
        return ResDefineUtil.ui_login_res_icon[2]
    elseif rewardType == resType.iron then 
        return ResDefineUtil.ui_login_res_icon[3]
    elseif rewardType == resType.food then 
        return ResDefineUtil.ui_login_res_icon[4]
    elseif rewardType == resType.money then 
        return ResDefineUtil.ui_login_res_icon[5]
    elseif rewardType == resType.gold then 
        return ResDefineUtil.ui_login_res_icon[6]
    elseif rewardType == resType.skills then
        return ResDefineUtil.ui_login_res_icon[8]
    elseif rewardType == resType.renown then
        return ResDefineUtil.ui_login_res_icon[9]
    elseif rewardType == resType.decree then
        return ResDefineUtil.ui_login_res_icon[10]
    else
        -- 武将卡根据品质来
        if rewardType %100 == 8 then 
            rewardType = math.floor(rewardType / 100)
            local basic_hero_info = Tb_cfg_hero[rewardType]
            if basic_hero_info then 
                return res_icon_hero[basic_hero_info.quality]
            else
                -- "unknow type"
                return res_icon_hero[0]
            end
        else
            return res_icon_hero[0]
        end
    end
end





local function getResNameByRewardType(rewardType)
    local ColorUtil = require("game/utils/color_util")
    if not rewardType then return nil end
    if rewardType % 100 == dropType.RES_ID_HERO then
        rewardType = math.floor(rewardType / 100)
        local basic_hero_info = Tb_cfg_hero[rewardType]
        if basic_hero_info then 
            return ColorUtil.getHeroNameWrite(basic_hero_info.heroid )
            -- return basic_hero_info.name .. "(" .. (basic_hero_info.quality + 1) .. languagePack["heroCardLvName"] .. ")"
        else
            return nil
        end
    else
        if rewardName[rewardType] then 
            return rewardName[rewardType]
        else
            return nil
        end
    end
end

-- 设置奖励图标布局
local function setRewardWidgetLayout(rewardWidget,rewardType,rewardNum)
    if not rewardWidget then return end
    if not rewardType then return end
    if not rewardNum then rewardNum = 1 end

    local label_num = uiUtil.getConvertChildByName(rewardWidget,"label_num")
    
    label_num:setVisible(false)

    local label_detail = uiUtil.getConvertChildByName(rewardWidget,"label_detail")
    label_detail:setText(rewardNum)

    local img_icon = uiUtil.getConvertChildByName(rewardWidget,"img_icon")
    img_icon:loadTexture(getResIconByRewardType(rewardType),UI_TEX_TYPE_PLIST)

    local img_selected_bg = uiUtil.getConvertChildByName(rewardWidget,"img_selected_bg")
    img_selected_bg:setVisible(false)

    local img_received = uiUtil.getConvertChildByName(rewardWidget,"img_received")
    img_received:setVisible(false)


    if rewardType % 100 == dropType.RES_ID_HERO then 
        label_detail:setText(loginRewardHelper.getResNameByRewardType(rewardType))
        label_num:setText(loginRewardHelper.getResNameByRewardType(rewardType))
        local ColorUtil = require("game/utils/color_util")
        label_detail:setColor(ColorUtil.getHeroColor(Tb_cfg_hero[math.floor(rewardType / 100)].quality))
    else
        label_detail:setText(rewardNum)
        label_num:setText(rewardNum)
    end


    if label_num:isVisible() then 
        tolua.cast(label_num:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)
    end

    if label_detail:isVisible() then 
        tolua.cast(label_detail:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)
    end

    local bg_num = uiUtil.getConvertChildByName(rewardWidget,"bg_num")
    bg_num:setVisible(false)
    local label_num = uiUtil.getConvertChildByName(bg_num,"label_num")
    label_num:setText(rewardNum)
    if bg_num:isVisible() then 
        tolua.cast(label_num:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)
    end
end


local function cacheAlphaAnimIndx(indx,dayth)
    
end

local function clearAlphAnimIndx(dayth)
    
end

local function clearAllAlphAnim()
    
end
-- 不是大奖 要停掉特效
local function stopBigRewardEffect(rewardWidget,dayth)
    if not rewardWidget then return end
    clearAlphAnimIndx(dayth)
    local img_effectBg = uiUtil.getConvertChildByName(rewardWidget,"img_effectBg")
    img_effectBg:stopAllActions()
end
-- 大奖的特效
-- 顺时针旋转（2秒一圈）
-- 透明度 100-->45-->100 循环
local function showBigRewardEffect(rewardWidget,dayth)
    if not rewardWidget then return end

    local img_effectBg = uiUtil.getConvertChildByName(rewardWidget,"img_effectBg")
    img_effectBg:stopAllActions()

    local actionRotation = CCRepeatForever:create(CCRotateBy:create(2,360))
    img_effectBg:runAction(actionRotation) 

    
    breathAnimUtil.start_scroll_dir_anim(img_effectBg,img_effectBg)
end

local function showReceiveEffect(rewardWidget)
    if not rewardWidget then return end
    local img_received = uiUtil.getConvertChildByName(rewardWidget,"img_received")
    if not img_received then return end
    img_received:setVisible(true)
    img_received:setScale(2)
    img_received:runAction(CCScaleTo:create(0.2,1))
    
end
-- 设置某一天的奖励礼包图标的布局
local function setDailyRewardIconLayout(rewardWidget,dayth)
    if not rewardWidget then return end
    if not dayth then return end
    local rewardId = loginRewardHelper.getCurLoginRewardCycle() * 100 + dayth
    local cfgInfo = Tb_cfg_login_reward[rewardId]

    if not cfgInfo then return end

    local label_detail = uiUtil.getConvertChildByName(rewardWidget,"label_detail")
    label_detail:setVisible(false)
    local label_num = uiUtil.getConvertChildByName(rewardWidget,"label_num")
    
    label_num:setZOrder(10)
    label_num:setText(dayth)
    if label_num:isVisible() then 
        tolua.cast(label_num:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)
    end
    
    clearAlphAnimIndx(dayth)
    
    

    -- 图标 （用第一个奖励的图标）
    local img_icon = uiUtil.getConvertChildByName(rewardWidget,"img_icon")
    local rewards = cfgInfo.rewards
    if rewards and rewards[1] then 
        local resIconUrl = getResIconByRewardType(rewards[1][1])
        if resIconUrl then 
            img_icon:loadTexture(resIconUrl,UI_TEX_TYPE_PLIST)
        end
    end
    img_icon:setZOrder(8)

    local img_selected_bg = uiUtil.getConvertChildByName(rewardWidget,"img_selected_bg")
    img_selected_bg:setVisible(false)


    -- 领取标志
    local img_received = uiUtil.getConvertChildByName(rewardWidget,"img_received")
    local m_iMineLoginCount = getCurLoginRewardCycleLoginedDays()

    if dayth > m_iMineLoginCount then 
        img_received:setVisible(false)        
    else
        img_received:setVisible(true)
    end
    img_received:setZOrder(9)
end


loginRewardHelper = {
    getCurLoginRewardCycle = getCurLoginRewardCycle,
    getCurLoginRewardCycleLoginedDays = getCurLoginRewardCycleLoginedDays,
    getCurLoginRewardCycleTotalDays = getCurLoginRewardCycleTotalDays,
    getRewardListCurCycle = getRewardListCurCycle,
    getDailyRewardDetailList = getDailyRewardDetailList,
    getResIconByRewardType = getResIconByRewardType,
    getResNameByRewardType = getResNameByRewardType,
    setRewardWidgetLayout = setRewardWidgetLayout,
    setDailyRewardIconLayout = setDailyRewardIconLayout,
    showReceiveEffect = showReceiveEffect,
    showBigRewardEffect = showBigRewardEffect,
    clearAllAlphAnim = clearAllAlphAnim,
}

return loginRewardHelper



