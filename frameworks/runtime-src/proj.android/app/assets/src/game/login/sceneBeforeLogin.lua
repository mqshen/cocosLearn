--游戏的开始
module("SceneBeforeLogin", package.seeall)
local preloaded = nil

function loadTextureOfLogin()
    --重新加载登录流程所需的资源
    local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    cache:addSpriteFramesWithFile("test/res/Login.plist")
    -- cache:addSpriteFramesWithFile("test/res/Login_1.plist")

    -- CCTextureCache:sharedTextureCache():addImage("test/res/Login.png")
    -- CCTextureCache:sharedTextureCache():addImage("test/res/Login_1.png")
end

function loadFileBeforeLogin( )
    require("game/main/netCmdBeforeGame")
    require("game/net/netObserver")
    require("game/net/net")
    require("game/net/connect")
    -- require("game/config/globalNotification")
    -- require("game/dbData/dbDataChange")
    -- require("game/config/Language")
    -- require("game/encapsulation/commonFunc")
    -- require("game/dbData/clientConfigData")
    -- require("game/config/config")
    -- require("game/config/sound")
    require("game/encapsulation/timer")
    require("game/notificationLayer/alertLayer")
    require("game/notificationLayer/loadingLayer")
    require("game/encapsulation/action")
    require("game/notificationLayer/tipsLayer")
    -- require("game/dbData/errorTips")
end

function sid_invalid_init( packet )
    netObserver.removeObserver(ON_LOGIN)
    Net.setReLogin(false)
    if packet == cjson.null then
        return
    end
            
    local check_result = packet[1]
    if check_result == 0 then
        -- token过期。重新登录
        print(">>>>>>>>>>>>>>>>> token out of date")
        scene.remove()
        return
    elseif check_result == 2 then
        Net.setRestartFlag(true)
    else
        local rolling_notice_manager = function ( )
            require("game/option/rolling_notice_manager")
            require("game/userData/user")
        end
                
        rolling_notice_manager()
        local user_base_info = packet[2]
        Net.setPlayerMsg(user_base_info[3], user_base_info[2], user_base_info[1])
        userData.setServerTime(user_base_info[4])
        
        if packet[3] == 0 then 
            -- loginGUI.showCreateRole(packet)
        else
            local user_game_info = packet[4]
            userData.setUserData(user_game_info[1])
            RollingNoticeManager.receiveRollingNoitceFromServer(user_game_info[2])

            local area = mapData.getMapArea()
            if area.row_up then
                Net.send(GET_WORLD_INFO_CMD, {area.row_up, area.row_down, area.col_left, area.col_right})
            end
        end
    end
end

function SID_INVALID_callback( )
    -- 如果只是在还没射完火箭的cg界面，那么就不用remove了
    if not UpdateUI.playCGEnd() then
        Net.setReLogin(false)
        return
    end
    netObserver.addObserver(ON_LOGIN,sid_invalid_init)
    local device = sdkMgr:sharedSkdMgr():getDeviceInfo()
    local cpu = sdkMgr:sharedSkdMgr():getCPUInfo()
    local gpu = sdkMgr:sharedSkdMgr():getGPUInfo()
    local log = {device.."#"..cpu.."#"..gpu}
    local width = sdkMgr:sharedSkdMgr():getDeviceWidth()
    local height = sdkMgr:sharedSkdMgr():getDeviceHeight()
    if width == "" then
        width = 0
    else
        width = tonumber(width)
    end

    if height == "" then
        height = 0
    else
        height = tonumber(height)
    end

    table.insert( log, width )
    table.insert( log, height )
    table.insert( log, sdkMgr:sharedSkdMgr():getOSName() )
    table.insert( log, sdkMgr:sharedSkdMgr():getOSVer() )
    table.insert( log, sdkMgr:sharedSkdMgr():getMacAddr() )
    table.insert( log, sdkMgr:sharedSkdMgr():getUDID() )
    table.insert( log, sdkMgr:sharedSkdMgr():getIMSI() )
    table.insert( log, sdkMgr:sharedSkdMgr():getConnectType() )
    table.insert( log, sdkMgr:sharedSkdMgr():getAppChannel() )
    table.insert( log, CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion",true))
        
    local temp_serverid = loginData.getLastCacheServerId()
    if not temp_serverid then
        temp_serverid = 0
    end



    if not configBeforeLoad.getIfSdkLogin() then
        Net.send(ON_LOGIN, {0, Login.getAccountInfo(), configBeforeLoad.getSdkData().server_session or "", log, temp_serverid, CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion",true), sdkMgr:sharedSkdMgr():getDevId()})
    else
        if not configBeforeLoad.getSdkData().server_session then
            scene.remove()
            return
        else
            Net.send(ON_LOGIN, {1, configBeforeLoad.getSdkData().uid, configBeforeLoad.getSdkData().server_session or "", log, temp_serverid, CCUserDefault:sharedUserDefault():getStringForKey("update_exteriorversion",true), sdkMgr:sharedSkdMgr():getDevId()})
        end
    end
end

function initOnceFile( )
    require("game/main/sceneLayerDefine")
    require("game/config/globalNotification")
    require("game/dbData/dbDataChange")
    require("game/config/playerName")
    require("game/config/Language")
    require("game/encapsulation/commonFunc")
    require("game/dbData/clientConfigData")
    require("game/config/config")
    require("game/main/sound")
    require("game/dbData/errorTips")
    require("game/config/netCmd")
    require("game/sdkStuff/sdkStuff")
    
    netObserver.addObserver(SYS_LOGIN_IN_ANOTHER_DEVICE_90010, scene.remove)
    netObserver.addObserver(SYS_NOTIFY_INFO, globalNotice.LoginError)
    netObserver.addObserver(SYS_NOTIFY_EXCEPTION,globalNotice.onError)
    netObserver.addObserver(SYS_NOTIFY_DB_UPDATE_90005, dbDataChange.changeData)
    -- netObserver.addObserver(SYS_SID_INVALID_90007, function ( )
    --     -- local loginEnterGame = require("game/login/login_enter_game")
    --     -- map.isLockMapCoord(true)
    --     -- scene.removeWithoutLoginGui()
    --     -- loginEnterGame.sendLoginWithoutGui()
        
    -- end)
    netObserver.addObserver(SYS_SID_INVALID_90007,function ( )
        Net.setReLogin(true)
    end)

    
    clientConfigData.process_config_data()
    clientConfigData.process_tb_cfg()
    config.setDrawCardData()
end

function restart()
    loadTextureOfLogin()
    if not configBeforeLoad.getIsFirstLogin() then
        UpdateUI.create()
    end
    configBeforeLoad.setIsFirstLogin(false)
    require("game/login/loginGui")
    loginGUI.create(preloaded)
    loginGUI.createLoadingLayer()
    -- LSound.startMusic()
end

function onLoad()
    -- require("game/main/require")
    -- tipsLayer.create("start enter game")
    loadFileBeforeLogin()
    restart()
end

function setPreload( flag )
    preloaded = flag
end
