-- practiceReportData.lua
module("PracticeReportData", package.seeall)

local m_practiceReport = nil
local last_report = nil
local first_report_index = nil
local m_last_callFuc = nil

function remove(  )
	m_practiceReport = nil
	last_report = nil
	first_report_index = nil
	m_last_callFuc = nil
	-- netObserver.removeObserver(GET_ALL_BATTLE_REPORT_PROFILE_CMD)
	-- netObserver.removeObserver(GET_THE_BATTLE_REPORT_CMD)
end

local function isReady( )
	if last_report then
		for i, v in pairs(last_report) do
			if not m_practiceReport[v].report then
				return false
			end
		end
	end
	return true
end

function receiveReportProfile(package )
	netObserver.removeObserver(GET_ALL_BATTLE_REPORT_PROFILE_CMD)
	for i ,v in pairs(package) do
		m_practiceReport[v.battle_id] = { 	battle_id = v.battle_id,
										attack_userid = allTableData[dbTableDesList.battle_report_exersice.name][v.battle_id].userid,--package.attack_userid,
										attack_name = v.attack_name,
										attack_unionid = v.attack_unionid,
										attack_union_name = v.attack_union_name,
										defend_userid = 0,--package.defend_userid,
										defend_name = v.defend_name,
										defend_unionid = v.defend_unionid,
										defend_union_name = v.defend_union_name,
										wid = v.wid,
										wid_name = v.wid_name,
										attack_base_heroid = v.attack_base_heroid,
										attack_base_level = v.attack_base_level,
										attack_hp = v.attack_hp,
										defend_base_heroid = v.defend_base_heroid,
										defend_base_level = v.defend_base_level,
										defend_hp = v.defend_hp,
										result = v.result,
										time = v.time,
										attack_read = allTableData[dbTableDesList.battle_report_exersice.name][v.battle_id].read,
										defend_read = 1,
										npc = v.npc,
										-- relax = 0,
										--report = nil,--packet.report
									}

	end

	netObserver.addObserver(GET_THE_BATTLE_REPORT_CMD,PracticeReportData.receiveReportDetails)
	for i , v in ipairs(package) do
		requestReportDetails( v.battle_id )
	end

	-- if isReady( ) then
	-- 	playePracticeReport(m_practiceReport[last_report[first_report_index]].report,m_practiceReport[last_report[first_report_index]].attack_userid, nil, last_report[first_report_index] )
	-- end
end

function requestReportProfile( battle_id )
	netObserver.addObserver(GET_ALL_BATTLE_REPORT_PROFILE_CMD,PracticeReportData.receiveReportProfile)
	Net.send(GET_ALL_BATTLE_REPORT_PROFILE_CMD, {battle_id})
end

function receiveReportDetails(package )
	if not m_practiceReport[package.battle_id] then
		m_practiceReport[package.battle_id] = {}
	end
	local real_str = reportData.anlayeReport(package.report)
	m_practiceReport[package.battle_id].report = real_str
	if isReady( ) then
		netObserver.removeObserver(GET_THE_BATTLE_REPORT_CMD)
		playePracticeReport(m_practiceReport[last_report[first_report_index]].report, m_practiceReport[last_report[first_report_index]].attack_userid, nil, last_report[first_report_index] )
	end
end

function requestReportDetails( battle_id )
	
	Net.send(GET_THE_BATTLE_REPORT_CMD, {battle_id, 3})
end

function getPracticeReport(battle_id )
	return m_practiceReport[battle_id]
end

function init( )
	m_practiceReport = {}
	--返回单个战报详细信息
	-- netObserver.addObserver(GET_THE_BATTLE_REPORT_CMD,receiveReportDetails)
	
end

function playePracticeReport(report,attack_userid ,defend_userid, battle_id )
	--[[local detail,info =]] reportInfo.analyze(report,attack_userid, defend_userid, battle_id)
	BattleAnalyse.setBeforePlay()
	BattleAnalyse.analyseAnimation()
	BattleAnalyse.remove()

	BattleAnimationController.create()
	BattleAnimationController.closeWidgetFunc()
	-- BattleAnalyse.analyseAnimation()
end

function playePracticeReportCallBack(  )
	if first_report_index and last_report and first_report_index ~= #last_report then
		first_report_index = first_report_index + 1
		playePracticeReport(m_practiceReport[last_report[first_report_index]].report, m_practiceReport[last_report[first_report_index]].attack_userid, nil, last_report[first_report_index] )
		return
	end

	if m_last_callFuc then
		m_last_callFuc()
	end
end

-- battle_id_table 需要播放的战报列表
-- last_callFuc 播放完最后战报的回调函数
function requestPracticeReport(battle_id_table, last_callFuc )
	require("game/battle/battleAnimation")
	require("game/battle/battleAnimationController")
	require("game/battle/battleAnalyse")
	require("game/battle/battleAnimationData")
	require("game/battle/actionDefine")
	require("game/dbData/client_cfg/animation_Music_cfg_info")
	m_last_callFuc = last_callFuc
	local temp_battle_id_play = battle_id_table
	local temp_battle_id = {}
	first_report_index = 1
	for i, v in ipairs(temp_battle_id_play) do
		if not m_practiceReport[v] then
			table.insert(temp_battle_id, v)
		end
	end

	last_report = temp_battle_id_play
	if #temp_battle_id > 0 then
		requestReportProfile(temp_battle_id)
		-- for i , v in ipairs(temp_battle_id) do
		-- 	requestReportDetails( v )
		-- end
	else
		playePracticeReport(m_practiceReport[last_report[first_report_index]].report, m_practiceReport[last_report[first_report_index]].attack_userid, nil, last_report[first_report_index])
	end
end