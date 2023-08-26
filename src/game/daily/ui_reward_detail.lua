module("UIRewardDetail",package.seeall)

local loginRewardHelper = require("game/daily/login_reward_helper")


--奖励的图文提示
-- json文件   jiangli_tips.json
-- 类名		  UIRewardDetail
-- ID 名      UI_REWARD_DETAIL

local m_pMainLayer = nil

local function do_remove_self()
	if m_pMainLayer then 
        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil

        uiManager.remove_self_panel(uiIndexDefine.UI_REWARD_DETAIL)
    end
end


function remove_self()
   uiManager.hideConfigEffect(uiIndexDefine.UI_REWARD_DETAIL,m_pMainLayer,do_remove_self) 
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



function create(rewardType,rewardNum)
    if rewardType % 100 == dropType.RES_ID_HERO then 
        require("game/cardDisplay/basicCardViewer")
        basicCardViewer.create(nil,math.floor(rewardType / 100))
        return 
    end
	if m_pMainLayer then return end
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/jiangli_tips.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    
    -- rewardType = 100024

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_REWARD_DETAIL)

    local label_type = uiUtil.getConvertChildByName(mainWidget,"label_type")
    local label_num = uiUtil.getConvertChildByName(mainWidget,"label_num")
    local img_rewardIcon = uiUtil.getConvertChildByName(mainWidget,"img_rewardIcon")
    img_rewardIcon:loadTexture(loginRewardHelper.getResIconByRewardType(rewardType),UI_TEX_TYPE_PLIST)

    if rewardType % 100 == dropType.RES_ID_HERO then 
        local ColorUtil = require("game/utils/color_util")
        label_num:setText(loginRewardHelper.getResNameByRewardType(rewardType))

        label_num:setColor(ColorUtil.getHeroColor(Tb_cfg_hero[math.floor(rewardType / 100)].quality))
    else
        label_type:setText(loginRewardHelper.getResNameByRewardType(rewardType))
        label_num:setText(rewardNum)
    end

end