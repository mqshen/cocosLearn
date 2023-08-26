
local async_layer = nil
local preloaded = false
local preloadedLuaFile = nil
local b_isLeavingScene = nil
local m_count = 0
local loginLoading = require("game/login/login_loading")

local file_list = {
        "test/res/Main_UI_1",
        "test/res/Main_UI_2", 
        "test/res/Main_UI_3",
        "test/res/Main_UI_4", 
        "test/res/Main_UI_5",

        "test/res/Main_UI_11",
        "test/res/Main_UI_12",
        "test/res/Main_UI_13",
        "test/res/Main_UI_14",
        "test/res/Main_UI_15",
        "test/res/Main_UI_16",
        "test/res/Main_UI_17",
        "test/res/Main_UI_18",

        "gameResources/map/additionCity",
        "gameResources/map/res",
        -- "gameResources/map/mountain",
        "gameResources/map/cityComponent",
        -- "gameResources/map/land_level_5_animation",
        "gameResources/map/xinshou_smoke",
        "gameResources/map/armyMark",
        "gameResources/map/smallMiniMap_item",
        "gameResources/battle/battle_dir_1_2",
                        }

local function deal_with_texture_load_finished(num_finished,num_needed)
    -- loginGUI.on_pre_load_finish(num_finished,num_needed)
    if num_finished == num_needed then
        -- tipsLayer.create("load texture finished")
        async_layer:removeAllChildrenWithCleanup(true)
        async_layer = nil
        preloaded = true
        SceneBeforeLogin.setPreload( preloaded )
    else
        local action = animation.sequence({cc.DelayTime:create(0), cc.CallFunc:create(function (  )
            if async_layer then
                async_layer:load_async_texture(file_list[num_finished+1])
            end
        end)})
        cc.Director:getInstance():getRunningScene():runAction(action)
    end
    loginLoading.on_pre_load_finish(num_finished,num_needed)
end


local function loadTextrueFileAsync()
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    if #file_list > 0 then
        for i=1 , #file_list do
            local textureCache = CCTextureCache:sharedTextureCache()
            textureCache:addNoRemoveFlag(file_list[i]..".png")
        end


        async_layer = CCAsyncLayer:create()
        cc.Director:getInstance():getRunningScene():addChild(async_layer)
        async_layer:registerScriptHandler(deal_with_texture_load_finished)
        async_layer:set_basic_info(#file_list)
        async_layer:load_async_texture(file_list[1])
    end
end

local function loadTextureOfLogin()
    --重新加载登录流程所需的资源
    -- local cache = CCSpriteFrameCache:sharedSpriteFrameCache()
    -- cache:addSpriteFramesWithFile("test/res/Login.plist")
    -- cache:addSpriteFramesWithFile("test/res/Login_1.plist")

    -- CCTextureCache:sharedTextureCache():addImage("test/res/Login.png")
    -- CCTextureCache:sharedTextureCache():addImage("test/res/Login_1.png")
end

-- local function restart()
--     loadTextureOfLogin()
--     if not configBeforeLoad.getIsFirstLogin() then
--         UpdateUI.create()
--     end
--     configBeforeLoad.setIsFirstLogin(false)
--     require("game/login/loginGui")
--     loginGUI.create(preloaded)
--     -- LSound.startMusic()
-- end


-- 一切准备就绪 开始进入场景
local function enterGame()
    if not preloaded then return end
    scene.create()
    loginGUI.remove()
end

local function loadLuaFile( )
    sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(false)
    local index = 1
    local count = #g_fileTable
    local action = CCRepeatForever:create(animation.sequence({cc.CallFunc:create(function ( )
        for i=1 , 2 do
            if g_fileTable[index] then
                require(g_fileTable[index])
                loginLoading.on_pre_load_finish(index)
                index = index + 1
            else
                cc.Director:getInstance():getRunningScene():stopActionByTag(12)
                preloadedLuaFile = true
                loginLoading.on_pre_load_lua_finish(true )
                loadTextrueFileAsync()
                break
            end
        end
    end), cc.DelayTime:create(0)}))
    action:setTag(12)
    cc.Director:getInstance():getRunningScene():runAction(action)
end

local function removeLoginImage( )
    local textureCache = CCTextureCache:sharedTextureCache()
    textureCache:removeTextureForKey("test/res_single/beijituditu.png")
    textureCache:removeTextureForKey("test/res_single/dadituchusheng.png")
    textureCache:removeTextureForKey("test/res_single/zhouming_001.png")
    for i, v in ipairs({
        "dadituchusheng_12.png", 
        "dadituchusheng_10.png", 
        "dadituchusheng_13.png", 
        "dadituchusheng_11.png", 
        "dadituchusheng_6.png", 
        "dadituchusheng_5.png", 
        "dadituchusheng_4.png", 
        "dadituchusheng_3.png",
        "dadituchusheng_8.png", 
        "dadituchusheng_9.png", 
        "dadituchusheng_1.png", 
        "dadituchusheng_7.png", 
        "dadituchusheng_2.png"}) do
        textureCache:removeTextureForKey("test/res_single/"..v)
    end
    textureCache:removeUnusedTextures()
end

--进入游戏前开始load 资源
local function beforeEnterGame(isWithoutGui)
    if not isWithoutGui then
        loginGUI.beginLoginLoading()
        removeLoginImage()
    end
    if not preloaded then 
        require("game/config/require")
        loginLoading.setTotalFile(#g_fileTable+#file_list)
        -- loadTextrueFileAsync()
        loadLuaFile()
    else
        enterGame()
    end
end

-- function loadFileBeforeLogin( )
--     require("game/net/netObserver")
--     require("game/net/net")
--     require("game/net/connect")
--     require("game/config/netCmd")
--     -- require("game/config/globalNotification")
--     -- require("game/dbData/dbDataChange")
--     -- require("game/config/Language")
--     -- require("game/encapsulation/commonFunc")
--     -- require("game/dbData/clientConfigData")
--     -- require("game/config/config")
--     -- require("game/config/sound")
--     require("game/encapsulation/timer")
--     require("game/notificationLayer/alertLayer")
--     require("game/notificationLayer/loadingLayer")
--     require("game/encapsulation/action")
--     require("game/notificationLayer/tipsLayer")
--     -- require("game/dbData/errorTips")
-- end

-- local function initOnceFile( )
--     require("game/config/sceneLayerDefine")
--     require("game/config/globalNotification")
--     require("game/dbData/dbDataChange")
--     require("game/config/Language")
--     require("game/encapsulation/commonFunc")
--     require("game/dbData/clientConfigData")
--     require("game/config/config")
--     require("game/config/sound")
--     require("game/dbData/errorTips")
--     netObserver.addObserver(SYS_NOTIFY_INFO, globalNotice.LoginError)
--     netObserver.addObserver(SYS_NOTIFY_EXCEPTION,globalNotice.onError)
--     netObserver.addObserver(SYS_NOTIFY_DB_UPDATE_90005, dbDataChange.changeData)
--     netObserver.addObserver(SYS_SID_INVALID_90007, scene.remove)
    
--     clientConfigData.process_config_data()
--     clientConfigData.process_tb_cfg()
--     config.setDrawCardData()
-- end

-- local function onLoad()
--     -- require("game/main/require")
--     -- tipsLayer.create("start enter game")
--     loadFileBeforeLogin()
--     restart()
-- end

local function remove_request()
    if armyOpRequest then
        armyOpRequest.remove()
    end

    if mapOpRequest then
        mapOpRequest.remove()
    end


    if cardOpRequest then
        cardOpRequest.remove()
    end

    if userCommonRequest then
        userCommonRequest.remove()
    end
end

local function remove_db_change()
    if UIUpdateManager then
        if heroChangeManager then
            UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.add, heroChangeManager.deal_with_hero_add)
            UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.update, heroChangeManager.deal_with_hero_update)
            UIUpdateManager.remove_prop_update(dbTableDesList.hero.name, dataChangeType.remove, heroChangeManager.deal_with_hero_remove)
        end
    end

    if heroChangeManager then
        heroChangeManager.remove()
    end
end

local function newScene( )
    -- cc.Director:getInstance():getRunningScene():removeAllChildrenWithCleanup(true)
    -- SceneBeforeLogin.restart()
    local gSceneGame = cc.Scene:create()
    cc.Director:getInstance():replaceScene(gSceneGame)
    local actions = CCArray:create()  
    actions:addObject(cc.DelayTime:create(0))
    actions:addObject(cc.CallFunc:create(SceneBeforeLogin.restart))
    local action = cc.Sequence:create(actions)
    gSceneGame:runAction(action)
end

local function removeAllGameData( )
    if EndGameUI then
        EndGameUI.remove_self()
    end
    remove_db_change()
    remove_request()
    loginData.setHasRequestServerid(false)
    if cardTextureManager then
        cardTextureManager.remove()
    end

    if VoiceMgr then
        VoiceMgr.remove()
    end

    if PayData then
        PayData.remove()
    end

    if tipsLayer then
        tipsLayer.remove()
    end

    if taskTipsLayer then
        taskTipsLayer.remove()
    end

    if MainScreenNotification then
        MainScreenNotification.remove()
    end

    if loginGUI then
        loginGUI.remove()
    end

    if UpdateUI then
        UpdateUI.remove()
    end

    if mainBuildScene then
        mainBuildScene.remove()
    end

    if PracticeReportData then
        PracticeReportData.remove()
    end

    if heroDataOthers then 
        heroDataOthers.remove()
    end
    if ObjectTouchManager then
        ObjectTouchManager.remove()
    end

    if IOSComment then
        IOSComment.remove()
    end

    if map then
        map.remove()
    end

    if loadingLayer then
        loadingLayer.remove()
    end

    if uiManager then
        uiManager.remove()
    end

    if comGuideManager then
        comGuideManager.remove()
    end

    if userData then
        userData.remove()
    end

    if LSound then
        LSound.setFullScreenZero()
    end

    if alphaUtil then
        alphaUtil.remove()
    end

    if SkillDataModel then 
        SkillDataModel.remove()
    end

    if LocalPush then
        LocalPush.remove()
    end

    if RollingNoticeManager then 
        RollingNoticeManager.remove()
    end

    if BlackNameListManager then 
        BlackNameListManager.removeData()
    end

    if DailyDataModel then
        DailyDataModel.remove()
    end

    if Net then
        Net.removeVersionListen()
    end

    -- if LSound then
    --     LSound.remove()
    -- end
    collectgarbage("collect")
end



--流浪逻辑，删除所有数据但是不走登陆流程
local function remove_scene_not_login( )
    SceneBeforeLogin.loadTextureOfLogin()
    removeAllGameData()
    local gSceneGame = cc.Scene:create()
    cc.Director:getInstance():replaceScene(gSceneGame)
    local actions = CCArray:create()  
    actions:addObject(cc.DelayTime:create(0))
    actions:addObject(cc.CallFunc:create(function ( )
        loginGUI.create(true,true)
        loginData.requestStateInfo()
    end))
    local action = cc.Sequence:create(actions)
    gSceneGame:runAction(action)
    -- cc.Director:getInstance():getRunningScene():removeAllChildrenWithCleanup(true)
    -- loginGUI.create(true,true)
    -- loginData.requestStateInfo()
end

-- 注销账户
local function role_logout()
    SceneBeforeLogin.loadTextureOfLogin()
    removeAllGameData()
    local gSceneGame = cc.Scene:create()
    cc.Director:getInstance():replaceScene(gSceneGame)
    local actions = CCArray:create()  
    actions:addObject(cc.DelayTime:create(0))
    actions:addObject(cc.CallFunc:create(function ( )
        loginGUI.create(true,false)
    end))
    local action = cc.Sequence:create(actions)
    gSceneGame:runAction(action)
    -- cc.Director:getInstance():getRunningScene():removeAllChildrenWithCleanup(true)
    -- loginGUI.create(true,false)
end
--释放add在scene上的layer的lua对象
local function remove()
    -- 如果只是在还没射完火箭的cg界面，那么就不用remove了
    if not UpdateUI.playCGEnd() then
        return
    end
    b_isLeavingScene = true
    Connect.invalidSid()
    removeAllGameData()
    newScene( )
    b_isLeavingScene = false
end

local function removeWithoutLoginGui( )
    if not UpdateUI.playCGEnd() then
        return
    end
    b_isLeavingScene = true
    Connect.invalidSid()
    removeAllGameData()
    cc.Director:getInstance():getRunningScene():removeAllChildrenWithCleanup(true)
    b_isLeavingScene = false
end

local function create_request()
    armyOpRequest.create()
    mapOpRequest.create()
    cardOpRequest.create()
    userCommonRequest.create()
end

local function create_db_change()
    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.add, heroChangeManager.deal_with_hero_add)
    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.update, heroChangeManager.deal_with_hero_update)
    UIUpdateManager.add_prop_update(dbTableDesList.hero.name, dataChangeType.remove, heroChangeManager.deal_with_hero_remove)
end

--玩家初次完整进入游戏调用
local function deal_with_enter_game_finish()
    armyData.dealWithEnterGameFinish()

    heroChangeManager.create()
    heroChangeManager.client_update_injure_state()

    userData.on_enter_new_guide()
end

local function create( )
    -- LSound.stopMusic()
    -- LSound.fromOPToEnterGame(5)
    -- LSound.playMusic("main_bgm1")
    LSound.stopSound(musicSound["op_fire"])
    VoiceMgr.init()
    PayData.init()
    UpdateUI.remove()
    -- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/map/cityComponent.plist")
    loginData.setHasRequestServerid(false)
    require("game/config/cityComponent")
    -- CityComponentType.setNpcCityData()
    EndGameUI.init()
    create_db_change()
    politics.initData()
    LocalPush.init()
    Net.registerVersion()
    -- reportData.reportInit()
    taskTipsLayer.initTaskTipsLayer()
    tipsLayer.initTipsLayer()
    uiManager.create()
    ObjectTouchManager.create()
    map.create()
    IOSComment.init()
    ObjectManager.create()
    armyMark.init()
    PracticeReportData.init()
    DailyDataModel.create()
    mainOption.create()
    heroDataOthers.create()
    -- CityMarking.create()
    create_request()
    MainScreenNotification.init()
    deal_with_enter_game_finish()

    RollingNoticeManager.create()
    IOSComment.setFirstOpen()
	--UIUpdateManager.call_event_update(eventListenerType.initTeamComplete)
end

local function getSceneImageList( )
    return scene_list
end

local function isLeavingScene()
    return b_isLeavingScene
end
scene = {
	create = create,
	remove = remove,
	-- onLoad = onLoad,
    getSceneImageList = getSceneImageList,
    remove_scene_not_login = remove_scene_not_login,
    beforeEnterGame = beforeEnterGame,
    enterGame = enterGame,
    isLeavingScene = isLeavingScene,
    role_logout = role_logout,
    removeAllGameData = removeAllGameData,
    removeWithoutLoginGui = removeWithoutLoginGui,
    -- loadFileBeforeLogin = loadFileBeforeLogin,
    -- initOnceFile = initOnceFile
}
