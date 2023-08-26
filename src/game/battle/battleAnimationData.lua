--战报动画数据

--begin 0:回合数之类的 1：单步执行 2：技能一起执行 3:普通攻击或者反击 4:动作结束，5：普通攻击和反击一起执行, 99:可忽略
--finish false 还没有结束 true 已经结束
--Info 内容
local tBattleData = {}
local isIgnore = false
local iBattleId = nil
local tArmyData = {}
local m_arrHeroName = {}
local s_arrPosName = {"军师","大本营","中军","前军","前军","中军","大本营","军师"}
local normalHeroPos = nil
local beatBackHeroPos = nil
local function initHeroArmyInfo( iPos, strName )
	if strName == nil or strName == " " or strName == "null" then
		strName = s_arrPosName[iPos+1]
	end
	local name = tonumber(strName)
	m_arrHeroName[iPos+1] = {name = Tb_cfg_hero[name], level = 0, army = 0, heroid =name, isDead = false, armyAfter = 0 , levelAfter = 0, wounded_soldier = 0}
end

local function setHeroArmyInfo( iPos, lv, armyCount )
	if m_arrHeroName[iPos+1] then
		m_arrHeroName[iPos+1].level = tonumber(lv)
		m_arrHeroName[iPos+1].levelAfter = tonumber(lv)
		m_arrHeroName[iPos+1].army = tonumber(armyCount)
		m_arrHeroName[iPos+1].wounded_soldier = tonumber(armyCount)
		m_arrHeroName[iPos+1].this_wounded_soldier = tonumber(armyCount)
	end
end

--标记为这个动画段的结束
local function markAsOver( )
	if tBattleData[table.getn(tBattleData)] then
		tBattleData[table.getn(tBattleData)].finish = true
	else
		print(">>>>>>>>>>>>>>>>>>>>没有找到 iAction=")
	end
end

--初始化战斗数据，每回合的战斗数据插进表
local function initBattleData(arrTmp )
	if not arrTmp then return end
	local iAction = tonumber(arrTmp[1])
	if not warRoundKeyword[iAction] then return end
	if iAction == actionDefine.initArmy then--初始化
		for i = 2,table.getn(arrTmp),2 do
			initHeroArmyInfo(tonumber(arrTmp[i]),arrTmp[i+1])
			return 
		end
	end

	-- if iAction == actionDefine.effectNow then
	-- 	--0 立即结算
	-- 	if tonumber(arrTmp[4]) == 0 or not effectName[tonumber(arrTmp[3])] then
	-- 		return
	-- 	end
	-- end

	if iAction == actionDefine.noHero then
		isNoReport = true
	end

	if iAction ==actionDefine.cannotFight then
		m_arrHeroName[arrTmp[2]+1].isDead = true
	end

	if iAction == actionDefine.armyAfter then
		if m_arrHeroName[arrTmp[2]+1] then
			m_arrHeroName[arrTmp[2]+1].armyAfter = arrTmp[3]
			m_arrHeroName[arrTmp[2]+1].this_wounded_soldier = arrTmp[4]
		end
	end

	if iAction == actionDefine.wounded_soldier then
		if m_arrHeroName[arrTmp[2]+1] then
			m_arrHeroName[arrTmp[2]+1].wounded_soldier = arrTmp[3]
		end
	end

	if iAction == actionDefine.animationBattle then
		if m_arrHeroName[arrTmp[2]+1] then
			m_arrHeroName[arrTmp[2]+1].normal_kill = arrTmp[3]
			m_arrHeroName[arrTmp[2]+1].skill_kill = arrTmp[4]
			m_arrHeroName[arrTmp[2]+1].skill_count = arrTmp[5]
			m_arrHeroName[arrTmp[2]+1].recover = arrTmp[6]
		end
	end

	if isIgnore and iAction ~=actionDefine.ignoreEnd then
		return
	end
	--攻守方阵容
	if iAction == actionDefine.warInit then
		setHeroArmyInfo(tonumber(arrTmp[2]), arrTmp[3], arrTmp[4])
	--战斗开始
	elseif iAction == actionDefine.warBegin or iAction==actionDefine.win or iAction==actionDefine.lose or iAction==actionDefine.draw
	or iAction == actionDefine.drawNoRest then
		if iAction==actionDefine.win or iAction==actionDefine.lose or iAction == actionDefine.allDead then
			-- if reportData.getReport(iBattleId).attack_userid ~= userData.getUserId() then
			if not reportData.returnAttackOrDefend(reportData.getReport(iBattleId) ) then
				arrTmp[1] = (iAction==actionDefine.win and actionDefine.lose) or actionDefine.win
				table.insert(tBattleData,{begin=0, finish=true, info = {{arrTmp[1],arrTmp}}})
			else
				table.insert(tBattleData,{begin=0, finish=true, info = {{iAction,arrTmp}}})
			end
		else
			table.insert(tBattleData,{begin=0, finish=true, info = {{iAction,arrTmp}}})
		end
	--可忽略的开始
	elseif iAction == actionDefine.ignoreBegin then
		table.insert(tBattleData,{begin=99, finish=false, info = {}})
		isIgnore = true
	--可忽略的结束
	elseif iAction == actionDefine.ignoreEnd then
		markAsOver()
		isIgnore = false
	--技能一并执行的动作的开始标记位
	elseif iAction == actionDefine.parallelBegin then
		table.insert(tBattleData,{begin=2, finish=false, info = {}})
	--技能和普攻一并执行的动作的结束标记位
	elseif iAction == actionDefine.parallelEnd or iAction ==actionDefine.normalParallelEnd then
		markAsOver()
	--普攻一并执行的动作开始标记位
	elseif iAction == actionDefine.normalParallelBegin then
		table.insert(tBattleData,{begin=5, finish=false, info = {}})
	--普通攻击，反击
	-- elseif iAction == actionDefine.normalAttackFlag then
	-- 	table.insert(tBattleData,{begin=1, finish=true, info = {{iAction,arrTmp}}})
	-- elseif iAction == actionDefine.beatBack then
	-- 	table.insert(tBattleData,{begin=1, finish=true, info = {{iAction,arrTmp}}})
	--武将动作结束
	-- elseif iAction == actionDefine.heroEnd then
	-- 	table.insert(tBattleData,{begin=4, finish=true, info = {}})
	--单步执行 
	else
		--当这个解析还没完成
		if tBattleData[table.getn(tBattleData)] and not tBattleData[table.getn(tBattleData)].finish then
			if string.len(warRoundKeyword[iAction][2])>0 then
				if tBattleData[table.getn(tBattleData)].begin == 2 then
					table.insert(tBattleData[table.getn(tBattleData)].info, {iAction,arrTmp})
				elseif tBattleData[table.getn(tBattleData)].begin == 5 and not specialKey[iAction] then
					table.insert(tBattleData[table.getn(tBattleData)].info, {iAction,arrTmp})
				end
			end
		else
			if string.len(warRoundKeyword[iAction][2])>0 and not specialKey[iAction] then
				--如果技能范围内没有目标，那么要把前面已经插入的解析删除
				if iAction == actionDefine.skillRangeLack then
					if tBattleData[table.getn(tBattleData)].info[1] and (tBattleData[table.getn(tBattleData)].info[1][1] == actionDefine.playSkillBefore 
						or tBattleData[table.getn(tBattleData)].info[1][1] == actionDefine.playSkillAfter) then
						table.remove(tBattleData, table.getn(tBattleData))
					end
				end

				if iAction ~= actionDefine.skillRangeLack then
					table.insert(tBattleData,{begin=1, finish=true, info = {{iAction,arrTmp}}})
				end
			end
		end
	end
end

local function setBattleId( id )
	iBattleId = id
end

local function getBattleId( )
	return iBattleId
end

local function getBattleData( )
	return tBattleData
end

local function clearBattleData(  )
	tBattleData = {}
	m_arrHeroName = {}
	iBattleId = nil
	normalHeroPos = nil
	beatBackHeroPos = nil
	isIgnore = false
	isNoReport = false
end

local function getArmyInfo()
	return m_arrHeroName
end

local function setArmyInfo(  )
	for i=1,8 do
		if not m_arrHeroName[i] then
			m_arrHeroName[i] = {name = 0, level = 0, army = 0, heroid =0, isDead = false, armyAfter = 0, levelAfter = 0, wounded_soldier = 0,
				this_wounded_soldier = 0, normal_kill = 0, skill_kill = 0, skill_count = 0, recover = 0 }
		end
	end
end

local function isNoBattleReport( )
	return isNoReport
end

BattlaAnimationData = {
						initBattleData = initBattleData,
						getBattleData = getBattleData,
						clearBattleData = clearBattleData,
						getArmyInfo = getArmyInfo,
						setBattleId = setBattleId,
						getBattleId = getBattleId,
						setArmyInfo = setArmyInfo,
						isNoBattleReport = isNoBattleReport
}