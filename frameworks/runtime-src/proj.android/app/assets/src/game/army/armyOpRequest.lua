
-- public Integer armyid;//city_wid*10 + 部队编号 ，小于10000代表是npc部队
-- 	public Integer userid;//如果是0，代表是npc部队
-- 	public Integer city_wid;
-- 	public Integer reside_wid;
-- 	public Integer front_heroid_u;
-- 	public Integer middle_heroid_u;
-- 	public Integer base_heroid_u;
-- 	public Integer counsellor_heroid_u;
-- 	public Byte state;// 部队状态，0：正常，1:出征中 2：驻扎路上 3：援军路上 4:返回中  5：驻扎 6：援军
-- 	public Integer target_wid;
-- 	public Integer begin_time;
-- 	public Integer end_time;
local function setTeamMsg(v)
	--dbDataChange.updateData(dbTableDesList.army.name, v)
end

--请求单个武将信息
local function requestHero(heroid_u )
	--Net.send(ARMY_GET_HERO_INFO,{heroid_u})
end

-- public Integer heroid_u; // （武将卡唯一ID）由系统生成，标示每张卡片，小于10000代表npc英雄
-- 	public Integer heroid; // （武将ID）
-- 	@MyColumn(key = true)
-- 	public Integer userid; // （拥有该卡片的玩家ID）
-- 	public Integer armyid; // （武将卡所在的部队ID）不在部队中为0
-- 	public Integer del_time; // （玩家删除卡片的时间）未删除为0
-- 	public Integer hurt_end_time; // 重伤结束时间
-- 	public Byte state; // 武将状态，0：正常，1：征兵中 3：锁定 4：删除掉了
-- 	public Integer level; // （武将等级）初始为1
-- 	public Integer energy; // （武将体力）万分之一体力
-- 	public Integer energy_add; // 体力每秒回复
-- 	public Integer energy_time; // 体力时间
-- 	public Integer exp; // （武将经验）初始为0
-- 	public Integer hp; // （武将兵力）初始为100
-- 	public Integer hp_adding; // 正在征兵数量
-- 	public Integer hp_end_time; // 征兵结束时间
-- 	public Integer point_left; // （点数剩余）
-- 	public Integer attack_add; // （武将攻击力）攻击力加点
-- 	public Integer defence_add;
-- 	public Integer intel_add;
-- 	public Integer speed_add;
-- 	public Integer skill_count;// （武将技能数上限）
-- 	public String skill; // （武将技能信息）技能，等级，经验标示，如100001,2,234;100002,3,342
local function setHeroInfo(v)
	--dbDataChange.updateData(dbTableDesList.hero.name, v)
end

--返回单个武将信息
local function receiveHero( packet )
end

--请求部队信息
local function requestAllTeamInfo( )
	--Net.send(GET_ARMY_INFO_CMD, {})
end

local function reciveAllTeamInfo(packet)
	--[[
	for i, v in pairs(packet[1]) do
		setTeamMsg(v)
	end

	for i, v in pairs(packet[2]) do
		setHeroInfo(v)
	end
	--]]
end


--请求部队状态
local function requestTeamState( teamId)
	--Net.send(GET_ARMY_STATE_CMD, {teamId})
end

--返回部队状态
local function reciveTeamState(packet)
end

--请求城市，要塞，分成等信息
local function requestCityInfo( )
	--Net.send(GET_USER_CITY_CMD, {})
end

--返回城市，要塞， 分城等信息 
-- public Integer wid;
-- 	public Byte city_type;// 0:系统保留，请不要使用 1:玩家主城, 2：领地, 3：玩家分城, 4:要塞
-- 							// ,6:码头,7:村庄,8:npc城
-- 	public Byte param;// 建筑等级之类信息
-- 	public Byte facade;// 建筑外观
-- 	@MyColumn(length = 32)
-- 	public String name;
-- 	public Integer userid;//
-- 	public Integer durability_cur;// 耐久度
-- 	public Integer durability_max;// 耐久度
-- 	public Integer durability_time;// 上一次耐久度更新时间
-- 	public Integer protect_end_time;// 保护结束时间
-- del_end_time //删除结束时间
local function setCityInfo(v)
	--dbDataChange.updateData(dbTableDesList.world_city.name, v)
end

-- public static final String city_wid = "city_wid";
-- 		public static final String userid = "userid";
-- 		public static final String city_type = "city_type";
-- 		public static final String build_point_cur = "build_point_cur";
-- 		public static final String build_point_adding = "build_point_adding";
-- 		public static final String build_point_max = "build_point_max";
-- 		public static final String build_queue_cur = "build_queue_cur";
-- 		public static final String build_queue_max = "build_queue_max";
-- 		public static final String prosperity_cur = "prosperity_cur";
-- 		public static final String forces_cur = "forces_cur";
-- 		public static final String forces_adding = "forces_adding";
-- 		public static final String end_time = "end_time";
-- public static final String state = "state"; 0：正常，1：正在建，2：正在拆
local function setCityPol(v)
	--dbDataChange.updateData(dbTableDesList.user_city.name, v)
end
--所有城市信息
local function reciveCityInfo(packet )
	--[[
	for i, v in pairs(packet[1]) do
		setCityInfo(v)
	end

	for i, v in pairs(packet[2]) do
		setCityPol(v)
	end
	--]]
end

--返回出征信息
local function reciveBattle( packet )
	LSound.playMusic("main_bgm3")
	print("收到出征回复")
end


-- 返回练兵消息
local function receiveArmyTraining(packet)
	print(">>>>>>>>>>>>>>>>> receiveArmyTraining")
	config.dump(packet)
end
--返回屯田消息
local function reciveBattleDecree( packet )
	LSound.playMusic("main_bgm3")
	print("收到屯田回复")
end

--返回援军消息		处理方式同出征
local function receiveYuanjun( packet )
	print("收到援军回复")
end

--返回驻扎消息
local function receiveZhuzha( packet )
	print("收到驻扎回复")
end

local function receiveCancel( packet )
	print("收到取消回复")
end

local function receiveBack( packet )
	print("收到召回回复")
end

-- 请求练兵
local function requestArmyTraining(coorX,coorY,teamId)
	Net.send(TRINING_GOING,{coorX * 10000 + coorY,teamId})
end

-- 请求屯田
local function requestBattleDecree(coorX,coorY,teamId)
	Net.send(FARM_GOING,{coorX * 10000 + coorY,teamId})
end

--请求出征
local function requestBattle(coorX, coorY, teamId)
	print(">>>>>>>>>>请求出征")
	Net.send(CONQUER_FIELD_CMD, {coorX*10000+coorY, teamId})
end

--请求援军
local function requestYuanjun(coorX, coorY, teamId)
	print(">>>>>>>>>>请求援军")
	Net.send(REINFORCE_FIELD_CMD, {coorX*10000+coorY, teamId})
end

--请求驻扎
local function requestZhuzha(coorX, coorY, teamId)
	print(">>>>>>>>>>请求驻扎")
	Net.send(RESIDE_FIELD_CMD, {coorX*10000+coorY, teamId})
end

--请求取消操作（出征，援军，驻扎等的路上）
local function requestCancel(teamId)
	print(">>>>>>>>>>请求取消")
	Net.send(ARMY_MOVE_CANCEL, {teamId})
end

--立即返回
local function requestBackAtOnce(teamId)
	Net.send(ARMY_BACK_IMMEDIATELY, {teamId})
end

--请求返回（援军，驻扎等）
local function requestBack(teamId)
	print(">>>>>>>>>>请求召回")
	Net.send(ARMY_CALL_BACK, {teamId})
end

local function requestSwitchHero( cityWid,ArmyId1,Pos1,ArmyId2,Pos2 )
	Net.send(ARMY_SWITCH_HERO, {cityWid,ArmyId1,Pos1,ArmyId2,Pos2})
	--loadingLayer.create()
end

local function requestRemoveHero( cityWid, armyid, pos )
	Net.send(ARMY_REMOVE_HERO_FROM_ARMY,{cityWid, armyid, pos})
	--loadingLayer.create()
end

local function requestAddHero( CityWid,HeroIdU,TargetArmyId,TargetPos)
	Net.send(ARMY_ADD_HERO_TO_ARMY,{CityWid,HeroIdU,TargetArmyId,TargetPos})
	--loadingLayer.create()
end

local function remove( )
	netObserver.removeObserver(CONQUER_FIELD_CMD)
	netObserver.removeObserver(FARM_GOING)
	netObserver.removeObserver(TRINING_GOING)
	netObserver.removeObserver(REINFORCE_FIELD_CMD)
	netObserver.removeObserver(RESIDE_FIELD_CMD)
	netObserver.removeObserver(ARMY_MOVE_CANCEL)
	netObserver.removeObserver(ARMY_CALL_BACK)
	--netObserver.removeObserver(GET_ARMY_INFO_CMD)
	--netObserver.removeObserver(GET_USER_CITY_CMD)
	--netObserver.removeObserver(GET_ARMY_STATE_CMD)
	--netObserver.removeObserver(ARMY_GET_HERO_INFO)
end

local function create( )
	if isInit then return end
	--注册出征网络消息
	netObserver.addObserver(CONQUER_FIELD_CMD,reciveBattle)
	--注册屯田网络消息
	netObserver.addObserver(FARM_GOING,reciveBattleDecree)	
	--注册练兵网络消息
	netObserver.addObserver(TRINING_GOING ,receiveArmyTraining)
	--注册援军网络消息
	netObserver.addObserver(REINFORCE_FIELD_CMD,receiveYuanjun)
	--注册驻扎网络消息
	netObserver.addObserver(RESIDE_FIELD_CMD,receiveZhuzha)
	--注册取消网络消息（部队操作）
	netObserver.addObserver(ARMY_MOVE_CANCEL,receiveCancel)
	--注册召回网络消息（部队操作）
	netObserver.addObserver(ARMY_CALL_BACK,receiveBack)
	--返回部队信息
	--netObserver.addObserver(GET_ARMY_INFO_CMD,reciveAllTeamInfo)
	--所有城市信息
	--netObserver.addObserver(GET_USER_CITY_CMD,reciveCityInfo)
	--获取部队状态
	--netObserver.addObserver(GET_ARMY_STATE_CMD,reciveTeamState)

	--获取单个武将状态
	--netObserver.addObserver(ARMY_GET_HERO_INFO,receiveHero)


	
	--requestCityInfo()
	--requestAllTeamInfo()
end


armyOpRequest = {
					create = create,
					remove = remove,
					requestSwitchHero = requestSwitchHero,
					requestRemoveHero = requestRemoveHero,
					requestAddHero = requestAddHero,
					requestBattle = requestBattle,
					requestBattleDecree = requestBattleDecree,
					requestArmyTraining = requestArmyTraining,
					requestYuanjun = requestYuanjun,
					requestZhuzha = requestZhuzha,
					requestCancel = requestCancel,
					requestBack = requestBack,
					requestBackAtOnce = requestBackAtOnce
}