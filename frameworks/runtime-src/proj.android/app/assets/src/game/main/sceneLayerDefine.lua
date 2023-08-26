--加载scene上面的层级定义

MAIN_SCENE = 1 --主场景
OBJECT_SCENE = 3 --在主场景之上的物品
FLY_SCENE = 5 --飞鸟，云之类的动画
CITY_DISTANCE = 6 --显示npc城，主城，分城，要塞位置的标示
CITY_SHADOW = 8 --进入城市后显示的阴影
UI_SCENE = 10 --ui层

GUIDE_SWALLOW_SCENE = 12 	--新手吞噬层
NEW_GUIDE_SCENE = 13 --新手引导层
COM_GUIDE_SCENE = 14 --非强制引导层
SLIDE_SCENE = 15 --滑动表现层
GUIDE_TOOL_SCENE = 89 --引导辅助工具层次

TIPS_SCENE = 90 --提示界面
REWARD_EFFECT_SCENE = 91 --奖励提示界面
UI_ASSIST_EFFECT_SCENE = 92 	--UI辅助效果层次
LOADING_SCENE = 100 --loading加载界面
END_GAME  = 102--退出游戏弹窗

ANNOUNCEMENT = 11 --屏幕滚动公告


--OBJECT_SCENE上面东西的回调的定义以及层次关系
GROUND_EVENT = 2
BUILD_ANIMATION = 4
COUNTDOWN_OBJECT = 6
VIEW_INFO = 8
ARMY_WAR_STATUS = 9
NEW_GUIDE_OBJECT = 10
ARMY_MARK_LINE = 11
ARMY_MARK_FLAG = 12
ARMY_MARK_TIME = 13
LAND_MARK_FLAG = 14 -- 地块标记
CITY_NAME = 15

TOP_LAYER = 99 --最顶层