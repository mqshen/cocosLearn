--定义网络协议号

-- ON_LOGIN = 1  --登陆连接
CREATE_ROLE = 2 --创建角色
CREATE_ROLE_NAME = 3 --角色名称确认是否可用
GET_REGION_STATE = 4 --获取州信息
GET_WORLD_INFO_CMD = 5  --地图信息
CONQUER_FIELD_CMD = 6 --出征
FARM_GOING = 800      --; // 屯田
TRINING_GOING = 831	--; // 练兵
GET_ARMY_INFO_CMD = 7 --部队和武将信息
ENTER_CITY_CMD = 8 --进入城市请求
GET_USER_CITY_CMD = 9 --所有主城，分城，要塞等信息
GET_ALL_BATTLE_REPORT_PROFILE_CMD = 10 --所有战报
GET_THE_BATTLE_REPORT_CMD = 11 --单个战报细节
GET_ALL_CFG_INFO = 12  --配置文件
BUILDING_BUILD = 13 --建筑建造
BUILDING_UPGRADE = 14 --建筑升级
BUILDING_DEGRADE = 15 --建筑拆毁
BUILDING_CANCEL = 16 --建筑取消升级，建造或者拆毁
BUILDING_INFO_OF_CITY = 17 -- 城市建筑信息
BUILDING_FINISH_IMMEDIATELY = 18 --建筑升级立即完成
BUILDING_FINISH_IMMEDIATELY_ONE = 19 --单个建筑升级或拆立即完成
GET_FIELD_INFO_CMD = 21    --获取某个地块的信息（名称，归属等）
GET_NPC_RECRUIT_INFO_CMD = 22--; // 获取NPC军营信息
ARMY_ADD_HERO_TO_ARMY = 30
ARMY_REMOVE_HERO_FROM_ARMY = 31
ARMY_SWITCH_HERO = 32
ARMY_RECRUIT = 33 --增兵
ARMY_GET_HERO_INFO = 34  --获取单个武将状态
ARMY_RECRUIT_CANCEL = 35 --取消增兵
ARMY_RECRUIT_BATCH = 37 --批量增兵、批量征预备兵
RESOURCE_GET_INFO = 40   --获取资源
WORLD_BUILD_BRANCH_CITY = 50  --建分城
WORLD_DELETE_BRANCH_CITY = 51 --拆分城
WORLD_BUILD_FORT = 52  --建要塞
WORLD_DELETE_FORT = 53 --拆要塞
WORLD_CANCEL_BUILD_CITY_FORT = 54 --取消建立分城和要塞
WORLD_CANCEL_DEL_CITY_FORT = 55 --取消拆除分城和要塞
WORLD_DESERT_FIELD = 56       --放弃领地
WORLD_CANCEL_DESERT_FIELD = 57 --取消放弃领地
WORLD_EXTEND_CITY = 58    --城市扩建

REINFORCE_FIELD_CMD = 60	--援军
RESIDE_FIELD_CMD = 61		--驻扎
ARMY_MOVE_CANCEL = 62		--取消
ARMY_CALL_BACK = 63			--返回
ARMY_BACK_IMMEDIATELY = 64	--立即返回

SKILL_REINFORCE = 70 --技能强化
SKILL_LEARN = 71   -- 技能学习
SKILL_FORGET  = 72	--技能遗忘（武将卡的）
SKILL_AWAKE = 73  -- 技能觉醒
SKILL_TRANSFORM = 74 -- 转换技巧值
SKILL_RESEARCH = 75 -- 研究获得新技能
SKILL_IMPROVE  = 76 -- 提升技能研究度
SKILL_REMOVE = 77 --移除技能

HERO_CONFIG_POINTS = 80		--武将配点
HERO_CLEAN_POINTS = 81		--武将洗点
HERO_SWITCH_LOCK_STATE = 82 -- 武将卡保护状态切换
HERO_ADVANCE = 83 -- 武将卡进阶

SET_BATTLE_REPORT_ALL_READ = 91 --全部战报设置为已读
GET_UNION_BATTLE_REPORT = 92 --同盟战报

UNION_OVERVIEW = 100 --同盟信息
UNION_DONATE = 101 --捐赠或反叛
UNION_CREATE = 102 -- 建立同盟
UNION_MEMBER_LIST = 103--; // 成员列表
UNION_APPLICANT_LIST = 104--; // 申请人列表
UNION_DEAL_APPLICATION = 105--; // （副）盟主处理入盟申请
UNION_APPLY = 106--; // 玩家申请入盟
UNION_CANCEL_APPLY = 107--; // 玩家取消入盟申请
UNION_DISSOLVE = 108-- // 解散同盟
UNION_QUIT = 109--; // 退出同盟
UNION_REMOVE_MEMBER = 117--; // （副）盟主移除成员
UNION_DEMISS_LEADER = 118--; // 盟主禅让
UNION_CANCEL_DEMISS = 119--取消禅让
UNION_GIVE_UP_OFFICIAL = 124--; // 副盟主放弃官位
UNION_GET_REBEL_VALUE = 126--; // 获取反叛值
UNION_ESCAPE_AFFILIATE = 127--; // 脱离附属（反叛、主城被打）
UNION_NPC_CITY_LIST = 135--; // 治所 - 据点列表
UNION_AFFILIATED_MEMBER_LIST = 136--; // 治所 - 下属成员列表
UNION_NEARBY_UNION_LIST = 111--; // 附近的同盟列表
UNION_APPLY_DIRECTLY = 120--; // 直接申请入盟

UNION_NEARBY_PLAYER_LIST = 112--; // 附近玩家列表
N_INVITE = 115--; // 邀请入盟
UNION_INVITE_DIRECTLY = 113--; // 直接邀请入盟（通过玩家名）

UNION_INVITATION_LIST = 125--; // 邀请列表
UNION_UPDATE_INVITATION = 126--; // 更新邀请的已读状态
UNION_DEAL_INVITATION = 116--; // 玩家处理入盟邀请
UNION_EDIT_NOTICE = 128--; // 盟主编辑公告
UNION_GET_NAMES = 138--获取同盟和附属同盟名字

UNION_OFFICIAL_LIST = 110--; // 官员列表
UNION_DEMISE_LEADER = 118--; // 盟主禅让
UNION_CANCEL_DEMISS = 119--; // 盟主取消禅让
UNION_SIMPLE_MEMBER_LIST = 121--; // 简单成员列表
UNION_APPOINT_OFFICIAL = 122--; // 盟主任命官员
UNION_DEPOSE_OFFICIAL = 123--; // 盟主罢免官员
UNION_GIVE_UP_OFFICIAL = 124--; // 副盟主放弃官位
UNION_APPLICANT_LIST = 104--; // 申请人列表
UNION_DEAL_APPLICATION = 105--; // （副）盟主处理入盟申请
UNION_SWITCH_APPLY_STATE = 114--; // （副）盟主切换本盟的申请状态
UNION_LOG_GET = 180 	--获取同盟日志
USER_GET_CUSTOMER_SERVICE_TOKEN = 190 --获取客服中心token
PAY_GET_YUE_KA_BONUS = 325--; // 领取月卡每日奖励

MAIL_SEND_UNION_MAIL = 210--; // 发送同盟邮件
MAIL_SEND_PLAYER_MAIL = 200--; // 发送玩家邮件
MAIL_INBOX = 202--; // 收件箱
MAIL_OUTBOX = 203--; // 发件箱
MAIL_INFO = 204--; // 邮件信息
MAIL_DELETE = 205--; // 玩家删除邮件，有附件的不能删
MAIL_SIMPLE_UNION_MEMBER_LIST = 206--; // 邮件简单同盟成员列表
MAIL_REWARD = 208--; // 领取附件
MAIL_BRIEF_INFO_BY_MAILID = 209   --获取一条邮件信息

MINI_MAP_WORLD_INFO = 261--; // mini map 大地图所有州首府、关卡信息
MINI_MAP_REGION_INFO = 262--; // mini map 州信息
TASK_AWARD = 400--; // 领奖
PHONE_BIND_SEND_VERIFY_CODE = 331--手机绑定发送验证码
PHONE_BIND_CHECK_VERIFY_CODE = 332--; // 手机绑定


CARD_RECRUIT = 301 --招募多张卡牌
CARD_SET_ALL_NOT_NEW = 302  --设置全部卡包为非新
USER_IOS_COMMENT_DONE = 506--; // 玩家已经点击ios评价按钮
REVENUE = 750--; // 进行税收
REVENUE_CLEAR_CD = 751 -- 清理税收CD
VILLAGE_GET_INFO = 810--; //山寨信息

-- BATTLE_REPORT_CMD = 2001 --战报
NOTIFY_WORLD_INFO_CMD = 2005 --服务器主动推送地图信息改变
NOTIFY_ARMY_STATE_CMD = 2006 --服务器推送部队信息改变
NOTIFY_WORLD_VIEW_CHANGE_CMD = 2007 --服务器主动推送地图归属变化
NOTIFY_WORLD_VIEW_CMD = 2008 --服务器主动推送地图信息改变

NOTIFY_PAY_ORDER_NOT_EXIST = 2021--;//通知客户端订单不存在，可能是别的玩家的凭条，不用删除，也不要继续轮询

SYS_NOTIFY_INFO = 90001 --通知玩家信息
SYS_NOTIFY_EXCEPTION = 90002 --玩家信息异常
SYS_HEART_BEAT = 90003    --心跳包
SYS_NOTIFY_DB_UPDATE_90005 = 90005

SYS_SID_INVALID_90007 = 90007--;// sid无效

-- PLATFORM_LOGIN_CHECK = 20005 --sdk登陆
TEST_CMD = 1001

TEST_GET_DB_UPDATE_INFO = 1003		--测试数据库数据修改

-- LOGIN_GET_SERVER_LIST = 20001	--获取服务器列表（废弃）
-- LOGIN_GET_SERVER_LIST_NEW = 20002	--获取服务器列表 公告信息
-- SET_LOGINED_SERVER = 20003	 -- 设置最新登录的服务器ID

REWARD_FIRST_LOGIN = 730  	--每天首次登陆奖励铜钱

USER_GUIDE_RECORD = 504 	--新手引导记录

CHAT = 710--; // 聊天
NOTIFY_CHAT_MSG = 2100--;//聊天信息
CHAT_HISTORY = 711 -- ; // 获取聊天历史记录
ADD_BLACK_LIST = 712--; // 加入黑名单
DEL_BLACK_LIST = 713 --// 移除黑名单
GET_BLACK_LIST = 714 --; // 获取黑名单

DEL_ALL_FIELD_EVENT_REPORTS = 790--; // 删除地表事件报告
USER_SET_INTRODUCATION = 501 -- 设置玩家个人介绍
GET_USER_PROFILE = 502 -- 获取玩家个人势力信息


USER_TRAMP = 503	-- 流浪

RESOURCE_EXCHANGE = 600 --资源交换

RANK_LIST = 700    		-- 排行榜

NOTICE_LIST = 780 -- 获取公告列表

--沙盘演武
EXERCISE_ADD_HERO = 821 		--配置武将
EXERCISE_REMOVE_HERO = 822 		--移除武将
EXERCISE_SWITCH_HERO = 823 		--交换武将
EXERCISE_NEXT = 824 			--选择下一轮演武
EXERCISE_NEXT_ARMY = 825		--选择下一个部队
EXERCISE_GET_ARMY_INFO = 826	--获取NPC部队信息
EXERCISE_FIGHT = 827			--进行演武战斗
EXERCISE_REWARD = 828			--领取演武通关奖励

--世界进度
PROGRESS_GET_INFO = 871			--获取世界进程信息
PROGRESS_GET_REWARD = 872 		--获取世界进程奖励

UNION_UPDATE_APPLICATION = 137 -- 更新入盟申请的已读状态

NOTIFY_SEND_NOTICE = 2200 -- // 推送公告 （玩家信息公告）
NOTIFY_PAY_ORDER_SUCCESS = 2020 --//通知客户端订单支付成功，可以删掉本地凭条

BUILDING_UPDATE_EFFECT_STATE = 20 -- 更新建筑的特效状态

NOTIFY_MIDNIGHT = 2300 --; // 凌晨零点，通知客户端


WORLD_MARK_CREATE = 250 -- ; // 标记地图
WORLD_MARK_DELETE = 251 -- ; // 取消地图标记

 USER_PROTECTED_POPUP = 505 --; // 新手保护结束提示

 USE_GIFT_CODE = 335 -- ; // 使用礼包码


GUARD_PREPARE = 841 -- ; // 准备坚守 
GUARD_CANCEL = 842 --; // 取消坚守



MOVE_MAIN_CITY = 851 -- ; // 迁城


CONSUME_BUY_DECREE = 860 --; // 购买政令

NOTIFY_UNION_OCCUPY_CITY = 2101 --; // 占领城池推送

HERO_SHOW_SECOND_SKILL_EFFECT = 84 --;// 播放第二技能格解锁特效

ACTIVITY_GET_REWARD = 880 --; // 获取活动奖励
