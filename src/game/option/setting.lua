module("Setting", package.seeall)
-- 类名 设置  Setting
-- json文件  shezhi_1
--ID  UI_SETTING

-- 设置是绑定设备的 所以状态存在 本地数据库文件就行
local m_pMainLayer = nil

local m_bMusicClosed = nil
local m_bSoundClosed = nil
local m_dataInited = false
local m_newMsg = nil
local function getSettingKeyMusic()
    return "b_localMusicClosed"
end

local function getSettingKeySound()
    return "b_localSoundClosed"
end

function isMusicClosed()
    if not m_bMusicClosed then 
        m_bMusicClosed = CCUserDefault:sharedUserDefault():getBoolForKey(getSettingKeyMusic(), true)
    end
    return m_bMusicClosed
end

function setMusicClosedState(isClosed)
    CCUserDefault:sharedUserDefault():setBoolForKey(getSettingKeyMusic(),isClosed,true)
    m_bMusicClosed = isClosed
    
    LSound.openMusic(not isClosed)

    if isClosed then 
        LSound.stopMusic()
    else
        -- startMusic是指开头的音乐，所以这里不要调用
        -- LSound.startMusic()
    end
end

function isSoundClosed()
    if not m_bSoundClosed then 
        m_bSoundClosed = CCUserDefault:sharedUserDefault():getBoolForKey(getSettingKeySound(),true)
    end
    return m_bSoundClosed
end

function setSoundClosedState(isClosed)
    CCUserDefault:sharedUserDefault():setBoolForKey(getSettingKeySound(),isClosed,true)
    m_bSoundClosed = isClosed
    LSound.openSound(not isClosed)
end


local function do_remove_self()
    if m_pMainLayer then 
        m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_SETTING)
    end
end
function remove_self()
    uiManager.hideConfigEffect(uiIndexDefine.UI_SETTING,m_pMainLayer,do_remove_self)
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

function setNewMsg( flag )
    m_newMsg = flag
    if m_pMainLayer then
        local mainWidget = m_pMainLayer:getWidgetByTag(999)
        if mainWidget then
            local btn_accountLogout = uiUtil.getConvertChildByName(mainWidget,"btn_accountLogout")
            local ImageView_remind = uiUtil.getConvertChildByName(btn_accountLogout,"ImageView_remind")
            ImageView_remind:setVisible(true)
        end
    end

    loginGUI.setNewMsgAtUserCenter()
end


function create()
    if not m_dataInited then 
        Setting.initState()
    end
    if m_pMainLayer then return end
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/shezhi_1.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setTouchEnabled(true)
    mainWidget:setAnchorPoint(cc.p(0.5,0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))


    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(mainWidget)
    
    uiManager.add_panel_to_layer(m_pMainLayer,uiIndexDefine.UI_SETTING)



    -- 关闭
    local btn_close = uiUtil.getConvertChildByName(mainWidget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            remove_self()
        end
    end)

    -- 音乐状态切换
	
    local checkbox_music = uiUtil.getConvertChildByName(mainWidget,"checkbox_music")
	local panel_music = uiUtil.getConvertChildByName(mainWidget,"panel_music")
	panel_music:setBackGroundColorType(LAYOUT_COLOR_NONE)
	panel_music:setTouchEnabled(true)
	panel_music:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local new_state = checkbox_music:getSelectedState()
			setMusicClosedState(new_state)
			checkbox_music:setSelectedState(not new_state)
		end
	end)
    checkbox_music:setTouchEnabled(true)
    checkbox_music:setSelectedState(not m_bMusicClosed)
    checkbox_music:addEventListenerCheckBox(function(sender, eventType)
        if eventType == CHECKBOX_STATE_EVENT_SELECTED then
            setMusicClosedState(false)
        else
            setMusicClosedState(true)
        end
    end)
    -- 音效切换
    local checkbox_sound = uiUtil.getConvertChildByName(mainWidget,"checkbox_sound")
	local panel_sound = uiUtil.getConvertChildByName(mainWidget,"panel_sound")
	panel_sound:setBackGroundColorType(LAYOUT_COLOR_NONE)
	panel_sound:setTouchEnabled(true)
	panel_sound:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			local new_state = checkbox_sound:getSelectedState()
			setSoundClosedState(new_state)
			checkbox_sound:setSelectedState(not new_state)
		end
	end)
    checkbox_sound:setTouchEnabled(true)
    checkbox_sound:setSelectedState(not m_bSoundClosed)
    checkbox_sound:addEventListenerCheckBox(function(sender, eventType)
        if eventType == CHECKBOX_STATE_EVENT_SELECTED then
            setSoundClosedState(false)
        else
            setSoundClosedState(true)
        end
    end)
    -- 礼包兑换
    local btn_giftExchange = uiUtil.getConvertChildByName(mainWidget,"btn_giftExchange")
    btn_giftExchange:setTouchEnabled(true)
    btn_giftExchange:addTouchEventListener(function (sender,eventType) 
        if eventType == TOUCH_EVENT_ENDED then 
            UIGiftExchange.create()
        end
    end)


    if configBeforeLoad.getPlatFormInfo() == kTargetMacOS 
        or configBeforeLoad.getPlatFormInfo() == kTargetIphone  
        or configBeforeLoad.getPlatFormInfo() == kTargetIpad then
        btn_giftExchange:setVisible(false)
        btn_giftExchange:setTouchEnabled(false)
    end

    -- 注销账号
    local btn_accountLogout = uiUtil.getConvertChildByName(mainWidget,"btn_accountLogout")
    local ImageView_remind = uiUtil.getConvertChildByName(btn_accountLogout,"ImageView_remind")
    ImageView_remind:setVisible(false)
    if sdkMgr:sharedSkdMgr():getChannel() == "netease" then
        if sdkMgr:sharedSkdMgr():hasFeature("MODE_HAS_MANAGER") then
            btn_accountLogout:setTouchEnabled(true)
            btn_accountLogout:setVisible(true)
            if m_newMsg then
                ImageView_remind:setVisible(true)
            else
                ImageView_remind:setVisible(false)
            end
            btn_accountLogout:addTouchEventListener(function(sender,eventType)
                if eventType == TOUCH_EVENT_ENDED then 
                    ImageView_remind:setVisible(false)
                    m_newMsg = false
                    sdkMgr:sharedSkdMgr():openManagerView()
                end
            end)
        else
            btn_accountLogout:setTouchEnabled(false)
            btn_accountLogout:setVisible(false)
        end
    else
        btn_accountLogout:setTitleText(languagePack['relogin'])
        btn_accountLogout:setTouchEnabled(true)
        btn_accountLogout:setVisible(true)
        btn_accountLogout:addTouchEventListener(function(sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                do_remove_self()
                if sdkMgr:sharedSkdMgr():getChannel() == "youku" then
                    if sdkMgr:sharedSkdMgr().ntLogout then
                        sdkMgr:sharedSkdMgr():ntLogout()
                    end
                else
                    scene.remove()
                end
            end
        end)
    end
    
    

    -- 黑名单管理
    local btn_blackList = uiUtil.getConvertChildByName(mainWidget,"btn_blackList")
    btn_blackList:setTouchEnabled(true)
    btn_blackList:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            require("game/option/blackNameListManager")
            BlackNameListManager.create()
        end
    end)
    uiManager.showConfigEffect(uiIndexDefine.UI_SETTING,m_pMainLayer)
end

-- 初始化 状态
function initState()
    isMusicClosed()
    isSoundClosed()
    m_dataInited = true
end

function getNewMsg( )
    return m_newMsg
end


function getInstance()
    return m_pMainLayer
end
