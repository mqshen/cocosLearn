--读取需要提前预读的文件
uiUtil = require("game/utils/ui_util")
g_fileTable = {
"game/voice/voice",
"game/voice/voiceMgr",
"game/help/iosComment",
"game/voice/voiceSendUI",
"game/voice/voicePlayAnimation",
"game/notificationLayer/lockLayer",
-- 设置系统相关
"game/utils/ui_util",
"game/option/setting",
"game/option/ui_gift_exchange",
"game/help/bindingPhone",
"game/mapObject/objectManager",
"game/encapsulation/cardFrameInterface",
"game/encapsulation/cardTextureManager",
"game/help/helpUI",
"game/utils/alpha_util",
"game/utils/breathAnimUtil",
"game/pay/payUI",
"game/pay/payData",
"game/task/taskData",
"game/mapObject/mapObjectPool",
"game/pay/bonusUI",
"game/battle/battleLoadingUI",
"game/help/gameSpriteMainUI",
-- "game/config/scene",
"game/utils/ui_res_define",
"game/dbData/commonData",
"game/config/cityComponent",
"game/pushMsg/localPush",
"game/config/terrain",
"game/encapsulation/graySprite",

"game/config/resourceInMap",
"game/map/mapAllData",

"game/config/stateData",

"game/uiCommon/com_op_menu",
"game/uiCommon/com_alert_confirm",
"game/uiCommon/recordLocalManager",

"game/userData/user",
"game/userData/politics",
"game/userData/simpleUpdateManager",
"game/userData/userCommonRequest",

"game/daily/daily_data_model",
"game/option/mainOption",
"game/option/inner_option_right",
"game/option/inner_option_left",
"game/army/armyListManager",

"game/uiManager/uiManager",
"game/uiManager/uiPanelDefine",
"game/uiManager/uiBackPanel",
"game/uiManager/uiListViewSize",
"game/option/smallMiniMap",
"game/option/rolling_notice_manager",
"game/option/mainScreenNotification",

"game/mapObject/objectTouchManager",
"game/mapObject/objectCountDown",
"game/mapObject/flagLandMark",
"game/mapObject/groundEvent",
"game/mapObject/groundEventData",
"game/mapObject/groundEventDescribe",
"game/mapObject/buildCityAnimation",
"game/mapObject/objectNewGuideObject",

"game/option/city_list_army",
"game/cardDisplay/cardOverviewManager",
"game/skill/skill_overview",
"game/option/userOfficial",
"game/cardCall/cardCallManager",
"game/uiCommon/commonPopupManager",
"game/chat/ui_chat_main",
"game/option/blackNameListData",
"game/battle/battleAnimationController",
"game/ranking/rankingManager",
"game/daily/ui_daily_bulletin",
"game/option/newbie_protect_detail",
"game/army/armyCityOverview/armyListInCityManager",
"game/option/remindManager",
"game/option/miniMapManager",

--登录连接
"game/net/login",
--主页面按钮管理
"game/management/mainScene",

--主页面建筑页面
"game/buildScene/mainBuildScene",
--load map
"game/map/mapSpriteManage",
"game/map/map",
-- "game/map/mapData",

-- "game/map/mapLocation",

-- "game/map/readOnlyMapLocation",

"game/map/resourcesInMap",

-- "game/map/mapStateData",

"game/map/mapOpRequest",

"game/option/cityMarking",
"game/option/miniMapManager",
"game/map/mapMessageUI",
"game/map/mapData",
"game/map/mapNodeData",
"game/map/mapController",
"game/map/warFogData",
"game/map/mapLandInfo",
"game/map/mapArmyWarStatus",
"game/mapObject/cityNameDisplay",
"game/map/birdAnimation",
"game/map/cloudAnimation",
"game/buildScene/buildingExpand",
"game/map/mapResidence",
"game/map/mapFarming",
"game/map/mapTraining",
"game/dbData/client_cfg/valley_image_cfg_info",

--建筑界面
"game/buildScene/cityMsg",
"game/buildScene/buildingExpandTitle",
"game/union/unionRebelUI",
--登陆
-- "game/login/loginGui",

"game/notificationLayer/taskTipsLayer",

--部队出征
"game/army/armyData",
"game/army/armyMark",
"game/army/armyMarchLine",
"game/army/armyOpRequest",

--战斗
"game/battle/reportDetail",
"game/battle/report",
"game/battle/reportUI",
"game/battle/reportData",
"game/battle/practiceReportData",
"game/battle/detailReport",
"game/battle/openBattleAnimation",

--邮件
"game/mail/mailManager",
"game/mail/sendMailUI",
"game/mail/newMailData",

--卡牌展示
"game/cardDisplay/addSoldierRequest",
"game/cardDisplay/cardAddSoldier",

--同盟界面
"game/union/unionUIJudge",
"game/union/unionMainUI",
"game/union/unionGovernment",
"game/union/unionOfficialManagement",

-- 聊天界面
"game/chat/ui_chat_main",
--任务界面
"game/task/taskUI",

--抽卡相关
"game/cardCall/cardCallData",

--个人势力界面
"game/roleForces/ui_role_forces_main",
"game/roleForces/ui_role_forces_edit_intro",
--内政界面
"game/buildScene/ui_internal_affairs",
--测试数据
"game/dbData/client_cfg/new_guide_cfg_info",
"game/dbData/landData",
"game/dbData/gmManager",
"game/dbData/userCityData",
"game/dbData/client_cfg/game_log_cfg_info",

--非强制引导
"game/guide/shareGuide/guideShowShare",
"game/dbData/client_cfg/com_guide_cfg_info",
"game/guide/comGuide/comGuideManager",

"game/dbData/heroChangeManager",
"game/dbData/heroData",
"game/dbData/heroDataOthers",
"game/dbData/skillData",
"game/dbData/armySpecialData",
"game/dbData/buildData",
"game/dbData/sysUserConfigData",

"game/dbData/officiaDescription",

"game/cardDisplay/cardSortManager",
"game/cardDisplay/cardOpRequest",
}
