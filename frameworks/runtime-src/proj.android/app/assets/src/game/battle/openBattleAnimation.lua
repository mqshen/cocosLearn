-- 用于直接打开战斗动画
module("OpenBattleAnimation", package.seeall)
local m_isDirect, m_isNoResult, m_callFun = nil,nil,nil
function remove( )
	BattleAnalyse.remove()
	reportInfo.remove()
	BattleAnimation.removeAnimationName()
	reportData.remove()
	config.removeAnimationFile()
	m_isDirect, m_isNoResult, m_callFun = nil,nil,nil
end

function reciveReport( report, attack_userid, defend_userid,id )
	local detail,info = reportInfo.analyze(report,attack_userid, defend_userid, id)
	BattleAnalyse.setBeforePlay()
	BattleAnalyse.analyseAnimation()
	BattleAnalyse.remove()

	BattleAnimationController.create(m_isDirect, m_isNoResult,m_callFun)
	-- if m_callFun then
	-- 	m_callFun()
	-- end
    -- BattleAnalyse.analyseAnimation()
end

function reciveAllReport( )
	local battleReport = reportData.getReportDataByIndex(0)
	if battleReport then
		reportData.requestReportMsgById(battleReport.battle_id, true)
	else
		remove()
	end
end

function create(isDirect, isNoResult, callFun )
	m_isDirect, m_isNoResult, m_callFun = isDirect, isNoResult, callFun
	require("game/battle/battleAnimation")
	require("game/battle/battleAnimationController")
	require("game/battle/battleAnalyse")
	require("game/battle/battleAnimationData")
	require("game/battle/actionDefine")
	require("game/dbData/client_cfg/animation_Music_cfg_info")
	reportData.initData(1)
	reportData.setSortWay(0)
	reportData.requestReportByType(0,0,true)
end