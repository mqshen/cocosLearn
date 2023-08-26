--定义部队可以进行的行动 1：出征；2 援军；3驻扎；11 练兵；12 屯田；13扫荡
armyOp = {chuzheng = 1,yuanjun = 2,zhuzha = 3, training = 11,farm = 12,rake = 13}


--资源索引定义 1 木材，2 石头，3 铁块，4 粮食，5 钱
resType = {
	wood = 1,
	stone = 2, 
	iron = 3, 
	food = 4, 
	money = 5,
	gold = 99,
	sameNameHero = 16,		--同名武将卡
	buildingQueue = 13,		--建筑队列
	renown = 11,			--名望
	decree = 17, 			--政令
	skills = 18 			--技巧值
}

--城市城防对应的等级
cityConvertToLevel = {2,4,6,8,10}
--要塞城防对应的等级
yaosaiConvertToLevel = {2,3,3,5,7}
-- 城防建筑（警戒所兵力配置）
cfgbuildingDefenceTroops = {500,700,900,1200,1500}


--0:无主的废墟， 1:玩家主城, 2：玩家领地, 3：玩家分城, 4:要塞,5:玩家城区, 6:码头,7:npc城区,8:npc城,9:npc要塞
cityTypeDefine = {
					own_free = 0,
					zhucheng = 1,
					lingdi = 2,
					fencheng = 3,
					yaosai = 4,
					player_chengqu = 5,
					matou = 6,
					npc_chengqu = 7,
					npc_cheng = 8,
					npc_yaosai = 9,
					-- shanzhai = 10,

}
cityTypeSortTable = {}
cityTypeSortTable[cityTypeDefine.zhucheng] = 1
cityTypeSortTable[cityTypeDefine.fencheng] = 2
cityTypeSortTable[cityTypeDefine.yaosai] = 3
cityTypeSortTable[cityTypeDefine.npc_yaosai] = 4
cityTypeSortTable[cityTypeDefine.lingdi] = 5
cityTypeSortTable[cityTypeDefine.player_chengqu] = 6
cityTypeSortTable[cityTypeDefine.matou] = 7
cityTypeSortTable[cityTypeDefine.npc_chengqu] = 8
cityTypeSortTable[cityTypeDefine.npc_cheng] = 9
-- cityTypeSortTable[cityTypeDefine.shanmai] = 9
cityTypeSortTable[cityTypeDefine.own_free] = 10


cityTypeName = {}
cityTypeName[cityTypeDefine.own_free] = languagePack["cityTypeName_own_free"]
cityTypeName[cityTypeDefine.zhucheng] = languagePack["cityTypeName_zhucheng"]
cityTypeName[cityTypeDefine.lingdi] = languagePack["cityTypeName_lingdi"]
cityTypeName[cityTypeDefine.fencheng] = languagePack["cityTypeName_fencheng"]
cityTypeName[cityTypeDefine.yaosai] = languagePack["cityTypeName_yaosai"]
cityTypeName[cityTypeDefine.matou] = languagePack["cityTypeName_matou"]
cityTypeName[cityTypeDefine.npc_chengqu] = languagePack["cityTypeName_cunzhuang"]
cityTypeName[cityTypeDefine.npc_cheng] = languagePack["cityTypeName_npc_cheng"]
cityTypeName[cityTypeDefine.player_chengqu] = languagePack["cityTypeName_player_chengqu"]

--地图地块同自己的关系	
--0 无主 1 自己 2 自由状态-盟友 3 自由状态-下属 4 自由状态-敌对 5 附属状态-上级 6 附属状态-同上级 7 附属状态-敌对 8 附属状态-无主
mapAreaRelation = {	all_free = 0,
					own_self = 1,
					free_ally = 2,
					free_underling = 3,
					free_enemy = 4,
					attach_higher_up = 5,
					attach_same_higher = 6,
					attach_enemy = 7,
					attach_free = 8
				}
mapAreaRelationName = {}
mapAreaRelationName[mapAreaRelation.all_free] = languagePack["mapAreaRelationName_all_free"]
mapAreaRelationName[mapAreaRelation.own_self] = languagePack["mapAreaRelationName_own_self"]
mapAreaRelationName[mapAreaRelation.free_ally] = languagePack["mapAreaRelationName_free_ally"]
mapAreaRelationName[mapAreaRelation.free_underling] = languagePack["mapAreaRelationName_free_underling"]
mapAreaRelationName[mapAreaRelation.free_enemy] = languagePack["mapAreaRelationName_free_enemy"]
mapAreaRelationName[mapAreaRelation.attach_higher_up] = languagePack["mapAreaRelationName_attach_higher_up"]
mapAreaRelationName[mapAreaRelation.attach_same_higher] = languagePack["mapAreaRelationName_attach_same_higher"]
mapAreaRelationName[mapAreaRelation.attach_enemy] = languagePack["mapAreaRelationName_attach_enemy"]
mapAreaRelationName[mapAreaRelation.attach_free] = languagePack["mapAreaRelationName_attach_free"]

mapRelationColor = {}
mapRelationColor[mapAreaRelation.own_self] = {
	"green_1.png",
	"green_2.png"
}
mapRelationColor[mapAreaRelation.free_ally] = {
	"blue_1.png",
	"blue_2.png"
}
mapRelationColor[mapAreaRelation.attach_same_higher] = {
	"purple_1.png",
	"purple_2.png"
}
mapRelationColor[mapAreaRelation.attach_higher_up] = {
	"purple_1.png",
	"purple_2.png"
}
mapRelationColor[mapAreaRelation.free_underling] = {
	"yellow_1.png",
	"yellow_2.png"
}
mapRelationColor[mapAreaRelation.free_enemy] = {
	"red_1.png", 
	"red_2.png"
}
mapRelationColor[mapAreaRelation.attach_enemy] = {
	"red_1.png", 
	"red_2.png"
}

--地图建筑（归属权归同盟）
function isOwnLeague(cityType)
	return cityType == cityTypeDefine.npc_cheng
end

--领地/个人建筑（归属权归个人）
function isOwnPerson(cityType)
	return (not isOwnLeague(cityType))
end

numOrderList = {languagePack["one"], languagePack["two"], languagePack["three"], languagePack["four"], languagePack["five"]}

--城市状态 0：正常，1：正在建，2：正在拆
cityState = {normal = 0, building = 1, removing = 2}

--部队状态 0：正常，1:出征中 2：驻扎路上 3：援军路上 4:返回中  5：驻扎 6：援军 7：战间休息 8:屯田 9:练兵
armyState = {normal = 0, chuzhenging = 1, zhuzhaing = 2, yuanjuning = 3, returning = 4, zhuzhaed = 5, yuanjuned = 6, sleeped = 7,decreed = 8,training = 9}

--武将状态，0：正常，1：征兵中 3：锁定 
cardState = {normal = 0, zhengbing = 1, lock = 3}

--武将品质
cardQuality = {one_star = 0, two_star = 1, three_star = 2, four_star = 3, five_star = 4}

--武将招募类型 共享，激活，每日次数用完，未开放
cardCallType = {share = 1, actived = 2, no_daily = 3, unopen = 4}

--建筑状态 0：正常， 1：升级， 2：拆除
buildState = {normal = 0, upgrade = 1, demolition = 2}

--武将类型 1 弓兵；2 枪兵；3 骑兵
heroType = {archer = 1, spearman = 2, sowar = 3}
heroTypeName = {
	languagePack["heroTypeName_1"], 
	languagePack["heroTypeName_2"], 
	languagePack["heroTypeName_3"]
	}

taskAwardType = {
	TYPE_CARD_EXTRACT_MODE = 1,-- 获取武将卡新的招募方式 
	TYPE_BUILD_QUEUE = 2,-- 获取新的建筑队列
	TYPE_GOLD = 3,-- 获取金
	TYPE_CARD_HERO = 4,--获取新的武将,
	TYPE_NEW_SKILL = 5, -- 获取新战法
}

--国家类型
countryType = {han = 1, wei = 2, shu = 3, wu = 4, qun = 5}
countryNameDefine = {
	languagePack["countryName_1"],
	languagePack["countryName_2"],
	languagePack["countryName_3"],
	languagePack["countryName_4"],
	languagePack["countryName_5"],
}
--（技能类型）1：被动技，2：战前技，3：攻前技，4：攻后技，5：军师加成，
--61：建筑加成一，62：建筑加成二，7：国家加成，8：兵种加成，9：称号加成，10：兵种相克
heroSkillTypeName = {}
heroSkillTypeName[1] = languagePack["heroSkillTypeName_1"]
heroSkillTypeName[2] = languagePack["heroSkillTypeName_2"]
heroSkillTypeName[3] = languagePack["heroSkillTypeName_3"]
heroSkillTypeName[4] = languagePack["heroSkillTypeName_4"]
heroSkillTypeName[5] = languagePack["heroSkillTypeName_5"]
heroSkillTypeName[61] = languagePack["heroSkillTypeName_61"]
heroSkillTypeName[62] = languagePack["heroSkillTypeName_62"]
heroSkillTypeName[7] = languagePack["heroSkillTypeName_7"]
heroSkillTypeName[8] = languagePack["heroSkillTypeName_8"]
heroSkillTypeName[9] = languagePack["heroSkillTypeName_9"]
heroSkillTypeName[10] = languagePack["heroSkillTypeName_10"]

skillLimitForCounsellor = {
	languagePack["skillLimitForCounsellor_1"],
	languagePack["skillLimitForCounsellor_2"],
	languagePack["skillLimitForCounsellor_3"],
}

skillUseRateInfo = {
	languagePack["skillUserRate_1"],
	languagePack["skillUserRate_2"],
	languagePack["skillUserRate_3"],
	languagePack["skillUserRate_4"],
}


function get_skill_attack_des(attack_type, select_type, attack_max)
	local dst_content = " "
	local dis_content = " "
	if attack_type == 0 then
		dst_content = languagePack["skillAttackDes_1"]
	elseif attack_type == 11 then
		dst_content = languagePack["skillAttackDes_2"]
	elseif attack_type == 21 then
		dst_content = languagePack["skillAttackDes_3"]
	elseif attack_type == 41 then
		dst_content = languagePack["skillAttackDes_4"]
	elseif attack_type == 23 then
		if select_type == 0 then
			--当配置表中的目标类型为 随机 时，目标后的括号内说明文字新增加一类：有效距离内n个目标
			dst_content = languagePack["skillAttackDes_5"]
			dis_content = languagePack["skillAttackDes_15"] .. attack_max .. languagePack["skillAttackDes_14"]
		elseif select_type == 34 then
			dst_content = languagePack["skillAttackDes_6"]
			dis_content = languagePack["skillAttackDes_12"]
		else
			dst_content = languagePack["skillAttackDes_6"]
			dis_content = languagePack["skillAttackDes_13"] .. attack_max .. languagePack["skillAttackDes_14"]
		end
	elseif attack_type == 13 then
		if select_type == 0 then
			--当配置表中的目标类型为 随机 时，目标后的括号内说明文字新增加一类：有效距离内n个目标
			dst_content = languagePack["skillAttackDes_7"]
			dis_content = languagePack["skillAttackDes_15"] .. attack_max .. languagePack["skillAttackDes_14"]
		elseif select_type == 34 then
			dst_content = languagePack["skillAttackDes_8"]
			dis_content = languagePack["skillAttackDes_12"]
		else
			dst_content = languagePack["skillAttackDes_8"]
			dis_content = languagePack["skillAttackDes_13"] .. attack_max .. languagePack["skillAttackDes_14"]
		end
	elseif attack_type == 43 then
		if select_type == 0 then
			--当配置表中的目标类型为 随机 时，目标后的括号内说明文字新增加一类：有效距离内n个目标
			dst_content = languagePack["skillAttackDes_9"]
			dis_content = languagePack["skillAttackDes_15"] .. attack_max .. languagePack["skillAttackDes_14"]
		elseif select_type == 34 then
			dst_content = languagePack["skillAttackDes_10"]
			dis_content = languagePack["skillAttackDes_12"]
		else
			dst_content = languagePack["skillAttackDes_10"]
			dis_content = languagePack["skillAttackDes_13"] .. attack_max .. languagePack["skillAttackDes_14"]
		end
	elseif attack_type == 99 then
		dst_content = languagePack["skillAttackDes_11"]
	end

	return dst_content, dis_content
end

cityBuildDefine = {
					chengzhufu = 10,
					baolei = 11,
					dudufu = 12,
					minju = 13,
					cangku = 20,
					famuchang = 21,
					caishichang = 22,
					liantiechang = 23,
					mofang = 24,
					jishi = 25,
					bingying = 30,
					handian = 31,
					weidian = 32,
					shudian = 33,
					wudian = 34,
					qunxiongdian = 35,
					yubeisuo = 36,
					mubingsuo = 37,
					jiaochang = 40,
					dianjiangtai = 42,
					shejitan = 43,
					fengshantai = 44,
					shangwuying = 51,
					tiebiying = 52,
					junjiying = 53,
					jifengying = 54,
					chengqiang_1 = 61,
					fenghuotai = 63,
					wushenjuxiang_1 = 64,
					shapanzhentu_1 = 65,
					jingjiesuo = 66,
					qianzhuang = 81,
					jigongsuo = 82,
					talou = 83,
					jiuguan = 84
}

--卡牌需要显示的状态
heroStateDefine = {
	not_deploy = 1, 			-- 不能配置
	other_place = 2, 			-- 其他地方
	chuzheng = 3, 				-- 出征
	returning = 4,  			-- 返回
	yuanjun = 5, 				-- 援军
	zhuzha = 6,  				-- 驻扎
	zengbing = 7, 				-- 征兵中
	zjsleep = 8, 				-- 战间休息
	inarmy = 9,					-- 部队中
	hurted = 10, 				-- 重伤中
	selected_nomal = 11, 		-- 正常选中状态
	selected_attention = 12,	-- 被选中但需要玩家注意
	no_energy = 13, 			-- 体力不足
	prepare = 14, 				-- 队伍中有武将处于征兵、重伤、体力不足的状态 
	unnormal = 15, 				-- 部队不在正常状态下
}
--卡牌属性索引定义
heroPorpDefine = {attack = 1, defence = 2, intel= 3, speed = 4, destroy = 5, hit = 6}
--颜色RGB以及显示文字
fightPowerEstimate = {
						{125, 187, 139, languagePack["fightPowerEstimate_1"]},
						{255, 243, 195, languagePack["fightPowerEstimate_2"]},
						{219, 173, 100, languagePack["fightPowerEstimate_3"]},
						{168, 76, 76, languagePack["fightPowerEstimate_4"]},
						--地表事件卡包和经验卡
						{125,187,139,languagePack["fightPowerEstimate_5"]},
						--领地数上限
						{168,73,75,languagePack["fightPowerEstimate_6"]},
						{168,73,75,languagePack["fightPowerEstimate_7"]},
						--对NPC城市、*敌方*玩家的领地（包括城市、要塞、领地）
						--和野外建筑出征时的战力评价统一写成“敌情难测，请斟酌行事”
						--（字体颜色：fdd75c）；
						{253,215,92,languagePack["fightPowerEstimate_8"]},
						{168,73,75,languagePack["fightPowerEstimate_9"]},
						{168,73,75,languagePack["fightPowerEstimate_10"]},
						{168,73,75,languagePack["fightPowerEstimate_11"]},
						--地表事件贼兵
						{168,73,75,languagePack["fightPowerEstimate_12"]},
					}

--地表事件的定义
GROUND = {FIELD_EVENT_CARD  = 1,
			FIELD_EVENT_EXP = 2,
		FIELD_EVENT_THIEF = 3}


--消费类型 5 铜钱 99 元宝
consumeType = {common_money = 5, yuanbao = 99}
--玩家物品类型 1虎符·汉、2虎符·魏、3虎符·蜀、4虎符·吴、6虎符·群、7将军印
itemType = {hufu_han = 1, hufu_wei = 2, hufu_shu = 3, hufu_wu = 4, hufu_qun = 6, jiangjunyin = 7}

-- /** 盟主 */
-- 	public static final int UNION_OFFICIAL_ID_LEADER = 1
-- 	/** 副盟主 */
-- 	public static final int UNION_OFFICIAL_ID_VICE_LEADER = 2
-- 	/** 林掾史 */
-- 	public static final int UNION_OFFICIAL_ID_LINYUANSHI = 3
-- 	/** 石坊令 */
-- 	public static final int UNION_OFFICIAL_ID_SHIFANGLING = 4
-- 	/** 武库史 */
-- 	public static final int UNION_OFFICIAL_ID_WUKUSHI = 5
-- 	/** 籍田令 */
-- 	public static final int UNION_OFFICIAL_ID_JITIANLING = 6
-- 	/** 监市吏 */
-- 	public static final int UNION_OFFICIAL_ID_JIANSHILI = 7
-- 	/** 黄门中丞 */
-- 	public static final int UNION_OFFICIAL_ID_HUANGMENZHONGCHENG = 8
-- 	/** 西园廷卫 */
-- 	public static final int UNION_OFFICIAL_ID_XIYUANTINGWEI = 9
-- 	/** 兵曹 */
-- 	public static final int UNION_OFFICIAL_ID_BINGCAO = 10
-- 	/** 祭酒 */
-- 	public static final int UNION_OFFICIAL_ID_JIJIU = 11
positionType = {
				languagePack["mengzhu"], 
				languagePack["fumengzhu"], 
				languagePack['guanyuan'],
				languagePack["linyuanshi"],
				languagePack["shifangling"],
				languagePack["wukushi"],
				languagePack["jitianling"],
				languagePack["jianshili"],
				languagePack["huangmenzhongchen"],
				languagePack["xiyuantiwei"],
				languagePack["bingcao"],
				languagePack["jijiu"],
}


resNameDefine = {}
resNameDefine[1] = languagePack["mucai"]
resNameDefine[2] = languagePack["shikuai"]
resNameDefine[3] = languagePack["tiekuai"]
resNameDefine[4] = languagePack["liangshi"]
--战斗和邮件附件掉落
-- // 资源、奖励（类别奖励的配置方式：具体物品id * 100 + 类别id）
-- 	/** 木 */
-- 	public static final int RES_ID_WOOD = 1;
-- 	/** 石 */
-- 	public static final int RES_ID_STONE = 2;
-- 	/** 铁 */
-- 	public static final int RES_ID_IRON = 3;
-- 	/** 粮 */
-- 	public static final int RES_ID_FOOD = 4;
-- 	/** 钱 */
-- 	public static final int RES_ID_MONEY = 5;
-- 	/** 资源类 */
-- 	public static final int RES_ID_RES_TYPE = 6;
-- 	/** 经验 */
-- 	public static final int RES_ID_EXP = 7;
-- 	/** 卡牌类 */
-- 	public static final int RES_ID_HERO = 8;
-- 	/** 道具类 */
-- 	public static final int RES_ID_ITEM = 9;
-- 	/** 预备兵 */
-- 	public static final int RES_ID_REDIF = 10;
-- 	/** 名望 */
-- 	public static final int RES_ID_RENOWN = 11;
-- 	/** 增加所有部队的cost上限 */
-- 	public static final int RES_ID_ARMY_COST = 12;
-- 	/** 建筑队列 */
-- 	public static final int RES_ID_BUILD_QUEUE = 13;
-- 	/** 卡包类（抽卡方式） */
-- 	public static final int RES_ID_CARD_EXTRACT = 14;
-- 	/** 开放内政 */
-- 	public static final int RES_ID_INTERNAL_AFFAIRS = 15;
-- 	/** 同名武将卡 */
-- 	public static final int RES_ID_SAME_NAME_HERO = 16;
-- /** 战法类 */
-- 	public static final int RES_ID_SKILL = 19;
-- 	/** 元宝  */
-- 	public static final int RES_ID_YUAN_BAO = 99;
dropType = {
				RES_ID_WOOD = 1,
				RES_ID_STONE = 2,
				RES_ID_IRON = 3,
				RES_ID_FOOD = 4,
				RES_ID_MONEY = 5,--// 1表示木材，2石头，3铁块，4粮食，5钱
				RES_ID_RES_TYPE = 6,--// 资源类
				RES_ID_EXP = 7,--// 经验
				RES_ID_HERO = 8,--// 英雄
				RES_ID_ITEM = 9,--// 道具
				RES_ID_REDIF = 10,--// 预备兵
				RES_ID_RENOWN = 11,--// 名望
				RES_ID_COUPON = 12,--// 礼券
				RES_ID_QUEUE = 13,
				RES_ID_CARD_EXTRACT = 14,
				RES_ID_INTERNAL_AFFAIRS = 15,
				RES_ID_DECREE = 17,--政令
				-- RES_ID_SAME_NAME_HERO = 16,
				RES_ID_SKILL = 19, --战法
				RES_ID_YUAN_BAO = 99,--// 元宝
}

rewardName = {
				[1] = languagePack["mucai"],
				[2] = languagePack["shikuai"],
				[3] = languagePack["tiekuai"],
				[4] = languagePack["liangshi"],
				[5] = languagePack["tongqian"],
				[7] = languagePack["jingyan"],
				[10] = languagePack["tongzhidian"],
				[11] = languagePack["mingwang"],
				[12] = languagePack["liquan"],
				[13] = languagePack["jianzhuduilie"],
				[14] = languagePack["xinchouka"],
				[17] = languagePack["zhengling"],
				[18] = languagePack["jiqiao"],
				[99] = languagePack["jin"],
				
}

--所有掉落的小图标名字
itemTextureName = ResDefineUtil.ui_res_icon

--战斗结果定义
REPORT_RESULT = {FALSE = 0, WIN_NO_RESULT = 1, SUC_OCCP = 2, UNION_OCCP = 3, FUSHU = 4, JIEJIU = 5,
				 PINGJU = 6, ALLDIE = 7, DRAWfAIL = 8, NOWAR = 9}
--攻方
REPORT_STR = {  
				[2] = languagePack["REPORT_STR_2"],
				[3] = languagePack["REPORT_STR_3"],
				[4] = languagePack["REPORT_STR_4"],
				[5] = languagePack["REPORT_STR_5"]
			}
--守方
REPORT_DEF_STR = {
				[2] = languagePack["REPORT_DEF_STR_2"],
				[3] = languagePack["REPORT_DEF_STR_3"],
				[4] = languagePack["REPORT_DEF_STR_4"],
				[5] = languagePack["REPORT_DEF_STR_5"]
}

--攻方文字战报结果说明
REPORT_ACT_ = {
				[1] = languagePack["REPORT_ACT_1"],
				[2] = languagePack["REPORT_ACT_2"],
				[3] = languagePack["REPORT_ACT_3"],
				[4] = languagePack["REPORT_ACT_4"],
				[5] = languagePack["REPORT_ACT_5"]
}

--守方文字战报结果说明
REPORT_DEF_ = {
				[1] = languagePack["REPORT_DEF_1"],
				[2] = languagePack["REPORT_DEF_2"],
				[3] = languagePack["REPORT_DEF_3"],
				[4] = languagePack["REPORT_DEF_4"],
				[5] = languagePack["REPORT_DEF_5"]
}


-- `task_type`'任务类型：1＝主线、2＝每日、3＝活动',
taskType = {
	languagePack["taskType_1"],
	languagePack["taskType_2"],
	languagePack["taskType_3"]
}

--建筑提示对应的名字
buildingInclude = { 
	[1] = {name={languagePack["buildingName_10"],languagePack["buildingName_11"],languagePack["buildingName_12"]},id = {10,11,12}},
	[2] = {name={languagePack["buildingName_2"]},id = {20,21,23,22,24,82,25,81}},
	[3] = {name={languagePack["buildingName_3"]},id = {40,37,54,52,53,51,36,30}},
	[4] = {name={languagePack["buildingName_4"]},id = {42,31,32,33,34,35,84}},
	[5] = {name={languagePack["buildingName_5"]},id = {61,66,63,64,65,83}},
	[6] = {name={languagePack["buildingName_6"]},id = {43}},
	[7] = {name={languagePack["buildingName_7"]},id = {44}},
}

--建筑对应的区域
buildingInArea = {
	[10] = 1,
	[11] = 1,
	[12] = 1,
	[13] = 2,
	[20] = 2,
	[21] = 2,
	[23] = 2,
	[22] = 2,
	[24] = 2,
	[82] = 2,
	[25] = 2,
	[81] = 2,
	[40] = 3,
	[37] = 3,
	[54] = 3,
	[52] = 3,
	[53] = 3,
	[51] = 3,
	[36] = 3,
	[30] = 3,
	[42] = 4,
	[31] = 4,
	[32] = 4,
	[33] = 4,
	[34] = 4,
	[35] = 4,
	[84] = 4,
	[61] = 5,
	[66] = 5,
	[63] = 5,
	[64] = 5,
	[65] = 5,
	[83] = 5,
	[43] = 6,
	[44] = 7,
}

BUILDING_TYPE = {
	[1] = {[33] =1, [34] =1, [35] =1, [36] =1, [37] = 1, [119] =1, [120] = 1},
	[2] = {[89] =1, [90] =1, [91] = 1},
	[3] = {[59] =1, [60] =1, [61] = 1},
	[4] = {[69] =1, [70] =1, [71] = 1},
	[5] = {["zuomen"] =1, ["zuomen2"] = 1},
	[6] = {[109] =1, [110] =1, [111] = 1},
	[7] = {[79] =1, [80] =1, [81] = 1},
}

-- --州首府的唯一id，对应是cfg_world_city的param字段
-- capitalParam = {}
-- capitalParam[10110] = 1
-- capitalParam[12109] = 1
-- capitalParam[14209] = 1
-- capitalParam[17109] = 1
-- capitalParam[19608] = 1
-- capitalParam[22208] = 1
-- capitalParam[24408] = 1
-- capitalParam[26608] = 1
-- capitalParam[29408] = 1
-- capitalParam[31708] = 1
-- capitalParam[33908] = 1
-- capitalParam[36608] = 1
-- capitalParam[39108] = 1

--部队出征或返回的操作名字
armyEnterState = {}
armyEnterState[armyState.chuzhenging] = languagePack["armyEnterState_1"]
armyEnterState[armyState.zhuzhaing] = languagePack["armyEnterState_2"]
armyEnterState[armyState.yuanjuning] = languagePack["armyEnterState_3"]
armyEnterState[armyState.returning] = languagePack["armyEnterState_4"]
armyEnterState[99] = languagePack["armyEnterState_5"]


union_add_defined = {}
union_add_defined["exp_add"] = languagePack["union_add_defined_1"]
union_add_defined["wood_npc_add"] = languagePack["union_add_defined_2"]
union_add_defined["stone_npc_add"] = languagePack["union_add_defined_3"]
union_add_defined["iron_npc_add"] = languagePack["union_add_defined_4"]
union_add_defined["food_npc_add"] = languagePack["union_add_defined_5"]
union_add_defined["money_npc_add"] = languagePack["union_add_defined_15"]
union_add_defined["gong_attack_add"] = languagePack["union_add_defined_6"]
union_add_defined["gong_defend_add"] = languagePack["union_add_defined_7"]
union_add_defined["gong_intel_add"] = languagePack["union_add_defined_8"]
union_add_defined["qiang_attack_add"] = languagePack["union_add_defined_9"]
union_add_defined["qiang_defend_add"] = languagePack["union_add_defined_10"]
union_add_defined["qiang_intel_add"] = languagePack["union_add_defined_11"]
union_add_defined["qi_attack_add"] = languagePack["union_add_defined_12"]
union_add_defined["qi_defend_add"] = languagePack["union_add_defined_13"]
union_add_defined["qi_intel_add"] = languagePack["union_add_defined_14"]


-- 玩家坚守状态
userGuardState = { 
	normal = 0,    -- 正常状态 
	preparing = 1, -- 准备状态
	guarding = 2,  -- 坚守中
	during_cd = 3, -- 冷却CD 中
}


