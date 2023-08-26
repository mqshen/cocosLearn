--更新完前的网络协议号

CREATE_ROLE = 2 --创建角色
CREATE_ROLE_NAME = 3 --角色名称确认是否可用
GET_REGION_STATE = 4 --获取州信息
PLATFORM_LOGIN_CHECK = 20005 --sdk登陆
LOGIN_GET_SERVER_LIST_NEW = 20002	--获取服务器列表 公告信息
ON_LOGIN = 1  --登陆连接
SET_LOGINED_SERVER = 20003	 -- 设置最新登录的服务器ID
PAY_GEN_ORDER_INFO = 321--; // 产生订单
PAY_DEAL_AFTER_PAY_DONE = 322--; // 玩家充值完毕通知服务端
NOTIFY_CLIENT_VERSION = 2111--;//通知客户端所需要的最低版本
SYS_LOGIN_IN_ANOTHER_DEVICE_90010 = 90010--;// 通知客户端被顶号
CLIENT_UPDATE_INFO = 791 --更新patch的时候记录一下更新时间和耗时
AD_ACTIVATE = 20006