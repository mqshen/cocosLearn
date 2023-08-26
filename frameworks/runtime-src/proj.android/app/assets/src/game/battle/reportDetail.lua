---------------------------------动画播放方式代号-----------------------------------------------
--0:只放特效，查表
--1：卡牌动作，向上
--2：卡牌动作，向下
--3:根据卡牌播放动画,查表
--4:普通攻击和反击距离不足，然后向上抖两下，再向下
--5:施法距离不足，抖两下，再向下
--6:直接显示预设文字和数字。
--7:按代号播放特效
--8:显示图片，譬如溃败，无效等图片
--9:根据效果ID显示特效
---------------------------------数字前缀的含义------------------------------------------------
--H：英雄ID
--h：攻击/防御方标示
--S：技能ID
--E：效果ID
--D：数字显示
--p：魔法特效ID
--t：攻击武将兵种ID
--c：效果结算位置
---------------------------------数字后缀的含义------------------------------------------------
-- +：有益效果
-- -：有害效果
-- ！：伤害效果
-- #：治疗效果



-----------------------------------忽略的战报条目----------------------------------------------
ignoreReport = {}
ignoreReport[1] = 1
ignoreReport[2] = 1
ignoreReport[3] = 1
ignoreReport[5] = 1
ignoreReport[6] = 1
ignoreReport[7] = 1
ignoreReport[8] = 1
-- ignoreReport[9] = 1
ignoreReport[10] = 1
ignoreReport[11] = 1
ignoreReport[12] = 1
-- ignoreReport[13] = 1
ignoreReport[14] = 1
ignoreReport[18] = 1
ignoreReport[19] = 1
-- ignoreReport[20] = 1
-- ignoreReport[208] = 1
ignoreReport[115] = 1
ignoreReport[117] = 1
ignoreReport[213] = 1
ignoreReport[222] = 1
ignoreReport[214] = 1
ignoreReport[223] = 1
ignoreReport[215] = 1
ignoreReport[216] = 1
ignoreReport[217] = 1
ignoreReport[219] = 1
ignoreReport[220] = 1
ignoreReport[241] = 1

----------------------------------效果结算的缩短显示的战报-------------------------------------
continuousSkill = {}
continuousSkill[31] = {"H的攻击提高了@D@(D)",3,4,5}
continuousSkill[32] = {"H的防御提高了@D@(D)",3,4,5}
continuousSkill[33] = {"H的谋略提高了@D@(D)",3,4,5}
continuousSkill[34] = {"H的速度提高了@D@(D)",3,4,5}
continuousSkill[35] = {"H的攻城力提高了@D@(D)",3,4,5}
continuousSkill[36] = {"H的攻击距离提高了@D@(D)",3,4,5}
continuousSkill[37] = {"H的兵力上限提高了@D@(D)",3,4,5}
continuousSkill[38] = {"H的攻击降低了@D@(D)",3,4,5}
continuousSkill[39] = {"H的防御降低了@D@(D)",3,4,5}
continuousSkill[40] = {"H的谋略降低了@D@(D)",3,4,5}
continuousSkill[41] = {"H的速度降低了@D@(D)",3,4,5}
continuousSkill[42] = {"H的攻城力降低了@D@(D)",3,4,5}
continuousSkill[43] = {"H的攻击距离降低了@D@(D)",3,4,5}
continuousSkill[44] = {"H的兵力上限降低了@D@(D)",3,4,5}
continuousSkill[45] = {"H的攻击提高了@D@%(D)(D)",3,4,5,6}
continuousSkill[46] = {"H的防御提高了@D@%(D)(D)",3,4,5,6}
continuousSkill[47] = {"H的谋略提高了@D@%(D)(D)",3,4,5,6}
continuousSkill[48] = {"H的速度提高了@D@%(D)(D)",3,4,5,6}
continuousSkill[49] = {"H的攻城力提高了@D@%(D)(D)",3,4,5,6}
continuousSkill[50] = {"H的攻击距离提高了@D@%(D)(D)",3,4,5,6}
continuousSkill[51] = {"H的兵力上限提高了@D@%(D)(D)",3,4,5,6}
continuousSkill[52] = {"H的攻击降低了@D@%(D)(D)",3,4,5,6}
continuousSkill[53] = {"H的防御降低了@D@%(D)(D)",3,4,5,6}
continuousSkill[54] = {"H的谋略降低了@D@%(D)(D)",3,4,5,6}
continuousSkill[55] = {"H的速度降低了@D@%(D)(D)",3,4,5,6}
continuousSkill[56] = {"H的攻城力降低了@D@%(D)(D)",3,4,5,6}
continuousSkill[57] = {"H的攻击距离降低了@D@%(D)(D)",3,4,5,6}
continuousSkill[58] = {"H不可回复兵力",3}
continuousSkill[59] = {"H损失了@D@兵力(D)t",3,4,5,6}
continuousSkill[60] = {"H损失了@D@兵力(D)p",3,4,5,6}
continuousSkill[61] = {"H动摇损失了@D@兵力(D)",1,4,5}
continuousSkill[62] = {"H恐慌损失了@D@兵力(D)",1,4,5}
continuousSkill[242] = {"H燃烧损失了@D@兵力(D)",1,4,5}
continuousSkill[243] = {"H妖术损失了@D@兵力(D)",1,4,5}
continuousSkill[63] = {"H回复了@D@兵力(D)",3,4,5}
continuousSkill[64] = {"休整效果为H回复了@D@兵力(D)",3,4,5}
continuousSkill[65] = {"H陷入混乱中",3}
continuousSkill[66] = {"H陷入犹豫中",3}
continuousSkill[67] = {"H陷入暴走中",3}
continuousSkill[68] = {"H被H援护中",3,1}
continuousSkill[69] = {"H被H嘲讽中",3,1}
continuousSkill[70] = {"H进入洞察状态中",3}
continuousSkill[71] = {"消除了H的E效果",3,4}
continuousSkill[227] = {"H受到了看破",1}

continuousSkill[72] = {"消除了H的E效果",3,4}
continuousSkill[229] = {"H受到了镇静",1}

continuousSkill[73] = {"H进入规避状态",3}
continuousSkill[74] = {"H无视规避状态中",3}
continuousSkill[75] = {"H受到的攻击伤害提高@D@%",3,4}
continuousSkill[76] = {"H受到的攻击伤害降低@D@%",3,4}
continuousSkill[77] = {"H受到的策略攻击伤害提高@D@%",3,4}
continuousSkill[203] = {"H受到的策略攻击伤害降低@D@%",3,4}
continuousSkill[78] = {"H造成的攻击伤害提高@D@%",3,4}
continuousSkill[79] = {"H造成的攻击伤害降低@D@%",3,4}
continuousSkill[80] = {"H造成的策略攻击伤害提高@D@%",3,4}
continuousSkill[204] = {"H造成的策略攻击伤害降低@D@%",3,4}
continuousSkill[81] = {"H反射伤害@D@%",3,4}
continuousSkill[82] = {"H准备凭借攻击进行攻心（@D@%）",3,4}
continuousSkill[83] = {"H获得先攻能力",3}
continuousSkill[84] = {"H获得连击能力",3}
continuousSkill[85] = {"H进入分兵状态",3}
continuousSkill[86] = {"H获得反击能力",3}
continuousSkill[87] = {"H失去普通攻击能力",3}
continuousSkill[88] = {"H获得先手",3}
continuousSkill[238] = {"H无视兵种相克中",3}
continuousSkill[89] = {"H本次战斗木材收益提升@D@%",3,4}
continuousSkill[90] = {"H本次战斗石头收益提升@D@%",3,4}
continuousSkill[91] = {"H本次战斗铁块收益提升@D@%",3,4}
continuousSkill[92] = {"H本次战斗粮食收益提升@D@%",3,4}
continuousSkill[93] = {"H本次战斗钱收益提升@D@%",3,4}
continuousSkill[94] = {"H本次战斗经验值收益提升@D@%",3,4}
continuousSkill[95] = {"H对弓兵伤害提高@D@%",3,4}
continuousSkill[96] = {"H对枪兵伤害提高@D@%",3,4}
continuousSkill[97] = {"H对骑兵伤害提高@D@%",3,4}
continuousSkill[98] = {"H受弓兵伤害降低@D@%",3,4}
continuousSkill[99] = {"H受枪兵伤害降低@D@%",3,4}
continuousSkill[100] = {"H受骑兵伤害降低@D@%",3,4}
continuousSkill[101] = {"H对NPC伤害提高@D@%",3,4}
continuousSkill[244] = {"H的E效果继续生效中",4,3}
continuousSkill[201] = {"H的E没有生效",4,3}
continuousSkill[102] = {"H的E效果消失了",1,4}
continuousSkill[103] = {"H的E效果预备中",1,4}





---------------------------------只在技能释放时播放的效果----------------------------------------
specialKey = {}
specialKey[75] = 1
specialKey[76] = 1
specialKey[77] = 1
specialKey[203] = 1
specialKey[78] = 1
specialKey[79] = 1
specialKey[80] = 1
specialKey[204] = 1
---------------------------------按代号播放特效的特效配置--------------------------------
skillSelect = {}
skillSelect[59] = {"gongbingshouji_1","bubingmingzhong_1","qibingmingzhong_1"} --  - 受物伤
skillSelect[60] = {"bubing_attack_1","12_beiluoshijinenggongji_1","huoyan1_1;huoyan2_3","leidian1_1;leidian2_3","11_beishuixijinenggongji_1","14_jianxuexiaoguo_1"} --  - 受谋伤

----------------------------------根据效果ID显示特效配置---------------------------------
effectName= {}
effectName[101]= "18_qusan_1;"
effectName[102]= "18_qusan_1;"
effectName[103]= "18_qusan_1;"
effectName[104]= "18_qusan_1;"
effectName[105]= "18_qusan_1;"
effectName[106]= "18_qusan_1;"
effectName[107]= "18_qusan_1;"
effectName[201]= "06_qibing_1;"
effectName[202]= "14_jianxuexiaoguo_1;"
effectName[203]= "06_qibing_1;"
effectName[204]= "06_qibing_1;"
effectName[205]= "06_qibing_1;"
effectName[206]= "06_qibing_1;"
effectName[207]= "06_qibing_1;"
effectName[301]= "06_beiqibinggongji_1;"
effectName[302]= "10_beihuoranshao_1;"
effectName[303]= "14_jianxuexiaoguo_1;"
effectName[304]= "10_beihuoranshao_1;"
effectName[242]= "10_beihuoranshao_1;"
effectName[243]= "10_beihuoranshao_1;"
effectName[401]= "15_zhiliao_1;"
effectName[402]= "15_zhiliao_1;"
effectName[501]= "17_tiaoxin_1;"
effectName[502]= "12_beiluoshijinenggongji_1;"
effectName[503]= "12_beiluoshijinenggongji_1;"
effectName[504]= "16_tishen_1;"
effectName[505]= "17_tiaoxin_1;"
effectName[511]= "18_qusan_1;"
effectName[512]= "18_qusan_1;"
effectName[513]= "18_qusan_1;"
effectName[514]= "19_shanghaiguibi_1;"

effectName[521]= "14_jianxuexiaoguo_1;"
effectName[522]= "16_tishen_1;"
effectName[523]= "14_jianxuexiaoguo_1;"
effectName[524]= "16_tishen_1;"
effectName[531]= "18_qusan_1;"
effectName[532]= "06_qibing_1;"
effectName[533]= "18_qusan_1;"
effectName[534]= "06_qibing_1;"
effectName[541]= "18_qusan_1;"
effectName[542]= "21_xixuexiaoguo_1;"
effectName[543]= "18_qusan_1;"
effectName[544]= "18_qusan_1;"
effectName[545]= "18_qusan_1;"
effectName[551]= "18_qusan_1;"

effectName[561]= "18_qusan_1;"


----------------------------------数字播放效果前缀文字--------------------------
effectNumber = {}
effectNumber[31] = "攻击+"
effectNumber[32] = "防御+"
effectNumber[33] = "谋略+"
effectNumber[34] = "速度+"
effectNumber[35] = "攻城+"
effectNumber[36] = "攻击距离+"
effectNumber[37] = "兵力上限+"
effectNumber[38] = "攻击-"
effectNumber[39] = "防御-"
effectNumber[40] = "谋略-"
effectNumber[41] = "速度-"
effectNumber[42] = "攻城-"
effectNumber[43] = "攻击距离-"
effectNumber[44] = "兵力上限-"
effectNumber[45] = "攻击+%"
effectNumber[46] = "防御+%"
effectNumber[47] = "谋略+%"
effectNumber[48] = "速度+%"
effectNumber[49] = "攻城+%"
effectNumber[50] = "攻击距离+%"
effectNumber[51] = "兵力上限+%"
effectNumber[52] = "攻击-%"
effectNumber[53] = "防御-%"
effectNumber[54] = "谋略-%"
effectNumber[55] = "速度-%"
effectNumber[56] = "攻城-%"
effectNumber[57] = "攻击距离-%"
effectNumber[58] = "不可回复兵力"
effectNumber[59] = "兵力-"
effectNumber[60] = "兵力-"
effectNumber[61] = "兵力-"
effectNumber[62] = "兵力-"
effectNumber[242] = "兵力-"
effectNumber[243] = "兵力-"
effectNumber[63] = "兵力+"
effectNumber[64] = "兵力+"
effectNumber[75] = "受到攻击伤害+%"
effectNumber[76] = "受到攻击伤害-%"
effectNumber[77] = "受到策略攻击伤害+%"
effectNumber[203] = "受到策略攻击伤害-%"
effectNumber[78] = "攻击伤害+%"
effectNumber[79] = "攻击伤害-%"
effectNumber[80] = "策略攻击伤害+%"
effectNumber[204] = "策略攻击伤害-%"
effectNumber[81] = "反射伤害"
effectNumber[82] = "吸血"
effectNumber[83] = "先攻预备中"
effectNumber[84] = "连击预备中"
effectNumber[85] = "分兵"
effectNumber[86] = "获得反击能力"
effectNumber[87] = "失去攻击能力"
effectNumber[88] = "获得先手"
effectNumber[95] = "对弓兵伤害+%"
effectNumber[96] = "对枪兵伤害+%"
effectNumber[97] = "对骑兵伤害+%"
effectNumber[98] = "受弓兵伤害-%"
effectNumber[99] = "受枪兵伤害-%"
effectNumber[100] = "受骑兵伤害-%"
effectNumber[101] = "对NPC伤害+%"
effectNumber[104] = "混乱中"
effectNumber[105] = "犹豫中"
effectNumber[118] = "反射伤害"
effectNumber[202] = "吸血"
effectNumber[121] = "兵力-"
effectNumber[122] = "兵力-"


-------------------------------------------------------------------------------------
--------------------------------效果播放参数----------------------------------
-------------------------------------------------------------------------------------
warRoundKeyword = {}
warRoundKeyword[1] = {"战斗开始","",""}
warRoundKeyword[2] = {"战前准备开始","",""}
warRoundKeyword[3] = {"战前准备结束","",""}
warRoundKeyword[4] = {"战前准备回合","",""}
warRoundKeyword[5] = {"H战前行动开始","",""}
warRoundKeyword[6] = {"H战前行动结束","",""}
warRoundKeyword[7] = {"战前回合结束","",""}
warRoundKeyword[8] = {"正式阶段开始","0;","kaishi_1"}
warRoundKeyword[9] = {"第D回合","",""}
warRoundKeyword[10] = {"H行动开始","",""}
warRoundKeyword[11] = {"H行动结束","",""}
warRoundKeyword[12] = {"第@D@回合结束","",""}
warRoundKeyword[13] = {"战斗结束","",""}
warRoundKeyword[14] = {"@D@,H","",""}
warRoundKeyword[205] = {"H @D@级 兵力：D","",""}
warRoundKeyword[15] = {"@【攻方阵容】@","",""}
warRoundKeyword[16] = {"@【守方阵容】@","",""}
warRoundKeyword[17] = {"军师属性加成","",""}
warRoundKeyword[18] = {"H 攻 @D@↑防 D↑谋 D↑速 D↑","",""}
warRoundKeyword[19] = {"H 攻 @D@↑防 D↑谋 D↑速 D↑","",""}
warRoundKeyword[20] = {"hS使部队获得强化","",""}
warRoundKeyword[208] = {"h部队获得S","",""}
warRoundKeyword[21] = {"H的战法【S】生效！","1;H1;S2",""}
warRoundKeyword[22] = {"H发动【S】！","1;H1;S2","normal_attack_1_1;normal_attack_2_3"}
warRoundKeyword[23] = {"H发动【S】！","1;H1;S2","normal_attack_1_1;normal_attack_2_3"}
warRoundKeyword[24] = {"H的攻击发动【S】！","1;H1;S2","normal_attack_1_1;normal_attack_2_3"}
warRoundKeyword[25] = {"H的战法【S】开始准备！","3;H1;S2","02_jinengzhunbei_2"}
warRoundKeyword[26] = {"H的战法【S】准备中！","3;H1;S2","02_jinengzhunbei_2"}
warRoundKeyword[27] = {"H的战法【S】准备被打断了！","",""}
warRoundKeyword[28] = {"H的E效果已施加","",""}
warRoundKeyword[29] = {"H已存在E效果","",""}
warRoundKeyword[210] = {"H已存在同等或更强E效果","",""}
warRoundKeyword[30] = {"H的E效果被刷新了","",""}
warRoundKeyword[31] = {"H【S】的效果使H的攻击提高了@D@(D)","6;H3;D4+","tongyong_2"}
warRoundKeyword[32] = {"H【S】的效果使H的防御提高了@D@(D)","6;H3;D4+","tongyong_2"}
warRoundKeyword[33] = {"H【S】的效果使H的谋略提高了@D@(D)","6;H3;D4+","tongyong_2"}
warRoundKeyword[34] = {"H【S】的效果使H的速度提高了@D@(D)","6;H3;D4+","tongyong_2"}
warRoundKeyword[35] = {"H【S】的效果使H的攻城力提高了@D@(D)","6;H3;D4+","tongyong_2"}
warRoundKeyword[36] = {"H【S】的效果使H的攻击距离提高了@D@(D)","6;H3;D4+","tongyong_2"}
warRoundKeyword[37] = {"H【S】的效果使H的兵力上限提高了@D@(D)","6;H3;D4+","tongyong_2"}
warRoundKeyword[38] = {"H【S】的效果使H的攻击降低了@D@(D)","6;H3;D4-",""}
warRoundKeyword[39] = {"H【S】的效果使H的防御降低了@D@(D)","6;H3;D4-",""}
warRoundKeyword[40] = {"H【S】的效果使H的谋略降低了@D@(D)","6;H3;D4-",""}
warRoundKeyword[41] = {"H【S】的效果使H的速度降低了@D@(D)","6;H3;D4-",""}
warRoundKeyword[42] = {"H【S】的效果使H的攻城力力降低了@D@(D)","6;H3;D4-",""}
warRoundKeyword[43] = {"H【S】的效果使H的攻击距离降低了@D@(D)","6;H3;D4-",""}
warRoundKeyword[44] = {"H【S】的效果使H的兵力上限降低了@D@(D)","6;H3;D4-",""}
warRoundKeyword[45] = {"H【S】的效果使H的攻击提高了@D%@(D)(D)","6;H3;D5+","tongyong_2"}
warRoundKeyword[46] = {"H【S】的效果使H的防御提高了@D%@(D)(D)","6;H3;D5+","tongyong_2"}
warRoundKeyword[47] = {"H【S】的效果使H的谋略提高了@D%@(D)(D)","6;H3;D5+","tongyong_2"}
warRoundKeyword[48] = {"H【S】的效果使H的速度提高了@D%@(D)(D)","6;H3;D5+","tongyong_2"}
warRoundKeyword[49] = {"H【S】的效果使H的攻城力提高了@D%@(D)(D)","6;H3;D5+","tongyong_2"}
warRoundKeyword[50] = {"H【S】的效果使H的攻击距离提高了@D%@(D)(D)","6;H3;D5+","tongyong_2"}
warRoundKeyword[51] = {"H【S】的效果使H的兵力上限提高了@D%@(D)(D)","6;H3;D5+","tongyong_2"}
warRoundKeyword[52] = {"H【S】的效果使H的攻击降低了@D%@(D)(D)","6;H3;D5-",""}
warRoundKeyword[53] = {"H【S】的效果使H的防御降低了@D%@(D)(D)","6;H3;D5-",""}
warRoundKeyword[54] = {"H【S】的效果使H的谋略降低了@D%@(D)(D)","6;H3;D5-",""}
warRoundKeyword[55] = {"H【S】的效果使H的速度降低了@D%@(D)(D)","6;H3;D5-",""}
warRoundKeyword[56] = {"H【S】的效果使H的攻城力降低了@D%@(D)(D)","6;H3;D5-",""}
warRoundKeyword[57] = {"H【S】的效果使H的攻击距离降低了@D%@(D)(D)","6;H3;D5-",""}
warRoundKeyword[58] = {"H【S】的效果使H不可回复兵力","6;H3;D5-",""}
warRoundKeyword[59] = {"H【S】的效果使H损失了@D@兵力(D)t","7;H3;D4!;P6",""}
warRoundKeyword[60] = {"H【S】的效果使H损失了@D@兵力(D)p","7;H3;D4!;P6",""}
warRoundKeyword[61] = {"H由于H【S】施加的动摇效果损失了@D@兵力(D)","3;H1;D4!","dongyao1_1;dongyao2_3"}
warRoundKeyword[62] = {"H由于H【S】施加的恐慌效果损失了@D@兵力(D)","3;H1;D4!","dot1_1;dot2_3"}
warRoundKeyword[242] = {"H由于H【S】施加的燃烧效果损失了@D@兵力(D)","3;H1;D4!","dianran1_1;dianran2_3"}
warRoundKeyword[243] = {"H由于H【S】施加的妖术效果损失了@D@兵力(D)","3;H1;D4!","yaoshu1_1;yaoshu2_3;"}
warRoundKeyword[63] = {"H【S】的急救效果使H回复了@D@兵力(D)","3;H3;D4#","zhiliao_1"}
warRoundKeyword[64] = {"H【S】的休整效果为H回复了@D@兵力(D)","3;H3;D4#","zhiliao_1"}
warRoundKeyword[65] = {"H【S】令H陷入混乱中","3;H3","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[66] = {"H【S】令H陷入犹豫中","3;H3","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[67] = {"H【S】令H陷入暴走中","3;H3","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[68] = {"H【S】援护H中","3;H3","beitishen_2"}
warRoundKeyword[69] = {"H【S】嘲讽H中","3;H3","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[70] = {"H【S】使H进入洞察状态","3;H3","beitishen_2"}
warRoundKeyword[71] = {"H【S】消除了H的E效果","",""}
warRoundKeyword[227] = {"H受到了H【S】的看破","3;H1","qusan_3"}
warRoundKeyword[228] = {"H没有效果可以被消除","",""}
warRoundKeyword[72] = {"H【S】消除了H的E效果","",""}
warRoundKeyword[229] = {"H受到了H【S】的镇静","3;H1","qusan_3"}
warRoundKeyword[230] = {"H没有效果可以被消除","",""}
warRoundKeyword[73] = {"H【S】令H进入规避状态","3;H3","shanghaiguibi_2"}
warRoundKeyword[74] = {"H【S】令H无视规避状态","3;H3","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[75] = {"H【S】使H受到的攻击伤害提高@D%@","6;H3;D4-",""}
warRoundKeyword[76] = {"H【S】使H受到的攻击伤害降低@D%@","6;H3;D4+",""}
warRoundKeyword[77] = {"H【S】使H受到的策略攻击伤害提高@D%@","6;H3;D4-",""}
warRoundKeyword[203] = {"H【S】使H受到的策略攻击伤害降低@D%@","6;H3;D4+",""}
warRoundKeyword[78] = {"H【S】使H造成的攻击伤害提高@D%@","6;H3;D4+",""}
warRoundKeyword[79] = {"H【S】使H造成的攻击伤害降低@D%@","6;H3;D4-",""}
warRoundKeyword[80] = {"H【S】使H造成的策略攻击伤害提高@D%@","6;H3;D4+",""}
warRoundKeyword[204] = {"H【S】使H造成的策略攻击伤害降低@D%@","6;H3;D4-",""}
warRoundKeyword[81] = {"H【S】使H反射伤害@D%@","3;H3;D4+","beitishen_2"}
warRoundKeyword[82] = {"H【S】使H准备凭借攻击进行攻心(@D%@)","3;H3;D4+","21_xixuexiaoguo_2"}
warRoundKeyword[83] = {"H【S】使H获得先攻能力","6;H3",""}
warRoundKeyword[84] = {"H【S】使H获得连击能力","6;H3",""}
warRoundKeyword[85] = {"H【S】使H进入分兵状态","6;H3",""}
warRoundKeyword[86] = {"H【S】使H获得反击能力","6;H3",""}
warRoundKeyword[87] = {"H【S】使H失去普通攻击能力","6;H3",""}
warRoundKeyword[88] = {"H【S】使H获得先手","6;H3",""}
warRoundKeyword[238] = {"H【S】使H无视兵种相克中","6;H3",""}
warRoundKeyword[89] = {"H【S】使h本次战斗木材收益提升@D%@","",""}
warRoundKeyword[90] = {"H【S】使h本次战斗石头收益提升@D%@","",""}
warRoundKeyword[91] = {"H【S】使h本次战斗铁块收益提升@D%@","",""}
warRoundKeyword[92] = {"H【S】使h本次战斗粮食收益提升@D%@","",""}
warRoundKeyword[93] = {"H【S】使h本次战斗钱收益提升@D%@","",""}
warRoundKeyword[94] = {"H【S】使h本次战斗经验值收益提升@D%@","",""}
warRoundKeyword[95] = {"H【S】使H对弓兵伤害提高@D%@","6;H3;D4+",""}
warRoundKeyword[96] = {"H【S】使H对枪兵伤害提高@D%@","6;H3;D4+",""}
warRoundKeyword[97] = {"H【S】使H对骑兵伤害提高@D%@","6;H3;D4+",""}
warRoundKeyword[98] = {"H【S】使H受弓兵伤害降低@D%@","6;H3;D4+",""}
warRoundKeyword[99] = {"H【S】使H受枪兵伤害降低@D%@","6;H3;D4+",""}
warRoundKeyword[100] = {"H【S】使H受骑兵伤害降低@D%@","6;H3;D4+",""}
warRoundKeyword[101] = {"H【S】使H对NPC伤害提高@D%@","6;H3;D4+",""}
warRoundKeyword[244] = {"H【S】的E效果对H继续生效中","",""}
warRoundKeyword[201] = {"H【S】的E对H没有生效","",""}
warRoundKeyword[102] = {"H的来自H【S】的E效果消失了","",""}
warRoundKeyword[103] = {"H的来自H【S】的E效果预备中","",""}
warRoundKeyword[104] = {"H陷入混乱状态无法行动","6;H1","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[105] = {"H陷入犹豫状态无法发动主动战法技","6;H1","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[106] = {"H陷入暴走状态","3;H1","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[107] = {"H由于被援护，转移攻击","3;H1","beitishen_2"}
warRoundKeyword[108] = {"H由于被挑衅，强制攻击挑衅目标","3;H1","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[109] = {"H由于处于洞察状态，不受E的影响","3;H1","beitishen_2"}
warRoundKeyword[110] = {"H由于处于规避状态，伤害无效","3;H1","shanghaiguibi_2"}
warRoundKeyword[111] = {"H无视规避状态进行攻击","3;H1","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[211] = {"H由于处于规避状态，攻击无效","3;H1","shanghaiguibi_2"}
warRoundKeyword[212] = {"H无视规避状态进行攻击","3;H1","tiaoxin1_1;tiaoxin2_3"}
warRoundKeyword[112] = {"H执行先攻","",""}
warRoundKeyword[113] = {"H执行两次攻击","",""}
warRoundKeyword[114] = {"H执行分兵","",""}
warRoundKeyword[115] = {"H准备反击","",""}
warRoundKeyword[116] = {"H无法普通攻击","",""}
warRoundKeyword[117] = {"无","",""}
warRoundKeyword[118] = {"H由于反射损失了@D@兵力(D)","3;H1;D2!","beitishen_2"}
warRoundKeyword[202] = {"H由于攻心回复了@D@兵力(D)","3;H1;D2#","21_xixuexiaoguo_2"}
warRoundKeyword[119] = {"H对H发动普通攻击","",""}
warRoundKeyword[120] = {"H进行反击","1;H1",""}
warRoundKeyword[121] = {"H损失@D@兵力(D)","6;H1;D2!",""}
warRoundKeyword[122] = {"H损失@D@兵力(D)","6;H1;D2!",""}
warRoundKeyword[123] = {"H无法再战","8;H1",""}
warRoundKeyword[124] = {"H无法再战","8;H1",""}
warRoundKeyword[125] = {"H由于射程不足，无法进行攻击","",""}
warRoundKeyword[221] = {"H由于射程不足，无法进行反击","",""}
warRoundKeyword[126] = {"H【S】的有效范围内没有目标","5;H1",""}
warRoundKeyword[127] = {"@【我方胜利】@","0","huosheng_1"}
warRoundKeyword[206] = {"@【未分胜负，继续战斗】@（剩余战斗次数@D@）","0","pingju_1"}
warRoundKeyword[232] = {"@【未分胜负，敌军继续战斗】@","0","pingju_1"}
warRoundKeyword[233] = {"@【久攻不下，罢兵回城】@ （剩余战斗次数@0@）","0","pingju_1"}
warRoundKeyword[234] = {"@【未分胜负，敌军罢兵回城】@","0","pingju_1"}
warRoundKeyword[207] = {"@【我方战败】@","0","zhanbai_1"}
warRoundKeyword[218] = {"@【两败俱伤，罢兵回城】@","0","pingju_1"}
warRoundKeyword[130] = {"@【对方没有武将出战】@","",""}
warRoundKeyword[240] = {"@【我方没有武将出战】@","",""}
warRoundKeyword[236] = {"@【目标土地不属于敌对方，无法进攻】@","",""}
warRoundKeyword[239] = {"@【目标地块周围没有土地相连，无法进攻】@","",""}
warRoundKeyword[131] = {"@【玩家处于保护期中，没有发生战斗】@","",""}
warRoundKeyword[132] = {"@【土地处于保护期中，没有发生战斗】@","",""}
warRoundKeyword[133] = {"@【玩家坚守中，没有发生战斗】@","",""}
warRoundKeyword[134] = {"@【遇到新的敌军】@","",""}
warRoundKeyword[224] = {"H战斗后兵力为@D@，产生伤兵@D@","",""}
warRoundKeyword[241] = {"H战斗后总伤兵为@D@","",""}
warRoundKeyword[225] = {"H等级提升至@D@","",""}
warRoundKeyword[231] = {"(等级提升至@D@)","",""}
warRoundKeyword[136] = {"H获得@D@经验","",""}
warRoundKeyword[237] = {"同盟获得@D@经验","",""}
warRoundKeyword[137] = {"对城防造成@D@点伤害","",""}
warRoundKeyword[235] = {"由于名望不足，不能占领目标","",""}
warRoundKeyword[138] = {"成功占据目标","",""}
warRoundKeyword[139] = {"同盟成功占领目标","",""}
warRoundKeyword[140] = {"成功拆除目标","",""}
warRoundKeyword[141] = {"成功使玩家沦陷","",""}
warRoundKeyword[226] = {"同时使全盟所有玩家沦陷","",""}
warRoundKeyword[209] = {"成功解救玩家","",""}
warRoundKeyword[142] = {"获得木材*200，粮食*100，钱*200，礼券1*22。","",""}
warRoundKeyword[213] = {"攻击连续播放开始","",""}
warRoundKeyword[222] = {"战法连续播放开始","",""}
warRoundKeyword[214] = {"攻击连续播放结束","",""}
warRoundKeyword[223] = {"战法连续播放结束","",""}
warRoundKeyword[215] = {"忽略播放开始","",""}
warRoundKeyword[216] = {"忽略播放结束","",""}
warRoundKeyword[217] = {"武将动作结束","",""}
warRoundKeyword[219] = {"H被普通攻击t","",""}
warRoundKeyword[220] = {"H下去","4;H1",""}
warRoundKeyword[245] = {"H,D,D,D,D","",""}


