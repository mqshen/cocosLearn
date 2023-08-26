local battleReport = nil
local battleReportIdList = nil
-- local sortWay = {all = 1, attack = 2, defend = 3}
local isMoreReport = nil

local m_bMoreSeriesReport = nil --更多连续战报
local curSort = 0--0全部战报， 1攻击战报， 2防守战报 3未读战报
--同盟战报还是自己的战报 1 自己战报 2 同盟战报 4 演武战报
local m_iReportType = nil
local report_profile_data = {}
local report_profile_data_list = {}
local report_lianxu_data = {} --只有连续战报中间的内容

local isLianxuzhanbao = nil

local isOpenAnimation = nil --直接打开动画战报

--请求的battle_id
local m_iBattle_id = 0

local function getReportType( )
	return m_iReportType
end

local function removeReportData( )
	report_profile_data = {}
	report_profile_data_list = {}
	report_lianxu_data = {}
	UIUpdateManager.remove_prop_update(dbTableDesList.report_attack.name, dataChangeType.update,
	reportData.reportUpdate )

	-- UIUpdateManager.remove_prop_update(dbTableDesList.report_attack.name, dataChangeType.add,
	-- reportAttackAdd )

	UIUpdateManager.remove_prop_update(dbTableDesList.report_defend.name, dataChangeType.update,
	reportData.reportUpdate )

	-- UIUpdateManager.remove_prop_update(dbTableDesList.report_defend.name, dataChangeType.add,
	-- reportDefendAdd )
end

local function getIfUnreadReport( )
	if m_iReportType and m_iReportType == 4 then
		for k,v in pairs(allTableData[dbTableDesList.battle_report_exersice.name]) do
	 		if v.read == 0 then
	 			return true
	 		end
		end
		return false
	end

	for i, v in pairs(allTableData[dbTableDesList.report_attack.name]) do
        if v.read == 0 then
            return true
        end
    end

    for i, v in pairs(allTableData[dbTableDesList.report_defend.name]) do
        if v.read == 0 then
            return true
        end
    end

    return false
end

local function reportDataInit(k,v, isAttack)
	report_profile_data[k] = v
	if v.armyid ~= 0 and v.join_id ~= 0 then
		report_profile_data[k].relax = v.armyid..v.join_id
	else
		report_profile_data[k].relax = nil
	end
	report_profile_data[k].attack = isAttack
	report_profile_data[k].attack_userid = nil
	report_profile_data[k].attack_name = nil
	report_profile_data[k].attack_unionid = nil
	report_profile_data[k].attack_union_name = nil
	report_profile_data[k].defend_userid = nil
	report_profile_data[k].defend_name = nil
	report_profile_data[k].defend_unionid = nil
	report_profile_data[k].defend_union_name = nil
	report_profile_data[k].wid = nil
	report_profile_data[k].wid_name = nil
	report_profile_data[k].attack_base_heroid = nil
	report_profile_data[k].attack_base_level = nil
	report_profile_data[k].attack_hp = nil
	report_profile_data[k].defend_base_heroid = nil
	report_profile_data[k].defend_base_level = nil
	report_profile_data[k].defend_hp = nil
	report_profile_data[k].result = nil
	report_profile_data[k].time = nil
	report_profile_data[k].attack_read = nil
	report_profile_data[k].defend_read = nil
	report_profile_data[k].npc = nil
	report_profile_data[k].defend_advance = nil
	report_profile_data[k].attack_advance = nil
end

local function reportUpdate(packet)
	for k, v in pairs (packet) do
		report_profile_data[packet.battle_id][k] = v
	end
	reportUI.refreshReadReportBtn()
end

local function reportAttackAdd(packet )
	reportDataInit(packet.battle_id,packet,1)
	local relax = report_profile_data[packet.battle_id].relax 
	if relax then
		if report_lianxu_data[relax] then
			for i, v in pairs(report_profile_data_list) do
				if report_profile_data[v].relax and report_profile_data[v].relax == relax then
					table.insert(report_lianxu_data[relax],1, v)
					report_profile_data_list[i] = packet.battle_id
					break
				end
			end
		else
			report_lianxu_data[relax] = {}
		end
	else
		table.insert(report_profile_data_list, 1,packet.battle_id)
	end
end

local function reportDefendAdd( packet )
	reportDataInit(packet.battle_id,packet,0)
	-- table.insert(report_profile_data_list, 1,packet.battle_id)
	local relax = report_profile_data[packet.battle_id].relax 
	if relax then
		if report_lianxu_data[relax] then
			for i, v in pairs(report_profile_data_list) do
				if report_profile_data[v].relax and report_profile_data[v].relax == relax then
					table.insert(report_lianxu_data[relax],1, v)
					report_profile_data_list[i] = packet.battle_id
					break
				end
			end
		else
			report_lianxu_data[relax] = {}
		end
	else
		table.insert(report_profile_data_list, 1,packet.battle_id)
	end
end

local function sortReport(sortData )
	table.sort(sortData, function ( a,b)
		return a> b
	end)

	local relax = nil
	for i, v in ipairs(sortData) do
		relax = report_profile_data[v].relax
	 	if relax and not report_lianxu_data[relax] then
	 		report_lianxu_data[relax] = {}
			table.insert(report_profile_data_list, v)
	 	elseif relax and report_lianxu_data[relax] then
	 		table.insert(report_lianxu_data[relax], v)
	 	elseif not relax then
	 		table.insert(report_profile_data_list, v)
	 	end
	end
end

local function reportPracticeInit()
	local relax = nil
	local temp_table = {}
	for k,v in pairs(allTableData[dbTableDesList.battle_report_exersice.name]) do
	 	reportDataInit(k,v, 1)
	 	table.insert(temp_table, v.battle_id)
	end
	
	sortReport(temp_table )

	table.sort(report_profile_data_list, function (a,b )
		return a > b
	end)
end

local function reportInit( )
	local relax = nil
	local temp_table = {}
	for k,v in pairs(allTableData[dbTableDesList.report_attack.name]) do
	 	reportDataInit(k,v, 1)
	 	table.insert(temp_table, v.battle_id)
	end
	
	sortReport(temp_table )

	local temp_table = {}
	for k,v in pairs(allTableData[dbTableDesList.report_defend.name]) do
	 	reportDataInit(k,v, 0)
	 	table.insert(temp_table, v.battle_id)
	end
	sortReport(temp_table )

	table.sort(report_profile_data_list, function (a,b )
		return a > b
	end)
	
	-- UIUpdateManager.add_prop_update(dbTableDesList.report_attack.name, dataChangeType.update,
	-- reportData.reportUpdate )

	-- UIUpdateManager.add_prop_update(dbTableDesList.report_defend.name, dataChangeType.update,
	-- reportData.reportUpdate )
end

local function setDataToReportLianxu( )
	local temp_data = {}
	local count = 0
	local beginIndex = 1
	local previous = nil
	if isLianxuzhanbao then
		for i, v in ipairs(battleReportIdList) do
			if v.battle_id == isLianxuzhanbao then
				if i + 1 > #battleReportIdList then
					beginIndex = i+1
					reportData.reciveReport(temp_data)
					return
				else
					beginIndex = i+1
				end
				break
			end
		end
	end

	local function callFun( data, relax )
		if relax and report_lianxu_data[relax] then
			for i, v in ipairs(report_lianxu_data[relax]) do
				table.insert(data, report_profile_data[v])
			end
		end
	end

	for i=beginIndex, #battleReportIdList do
		--全部
		if curSort == 0 then
			table.insert(temp_data, report_profile_data[battleReportIdList[i].battle_id])
			count = count + 1 
			callFun( temp_data,report_profile_data[battleReportIdList[i].battle_id].relax )
		--攻击
		elseif curSort == 1 and report_profile_data[battleReportIdList[i].battle_id].attack== 1 then
			table.insert(temp_data, report_profile_data[battleReportIdList[i].battle_id])
			count = count + 1 
			callFun( temp_data,report_profile_data[battleReportIdList[i].battle_id].relax )
		elseif curSort == 2 and report_profile_data[battleReportIdList[i].battle_id].attack== 0 then
			table.insert(temp_data, report_profile_data[battleReportIdList[i].battle_id])
			count = count + 1 
			callFun( temp_data,report_profile_data[battleReportIdList[i].battle_id].relax )
		elseif curSort == 3 and report_profile_data[battleReportIdList[i].battle_id].read == 0 then
			table.insert(temp_data, report_profile_data[battleReportIdList[i].battle_id])
			count = count + 1 
			callFun( temp_data,report_profile_data[battleReportIdList[i].battle_id].relax )
		end
		if count >= 15 then
			break
		end
	end

	reportData.reciveReport(temp_data)
end

local function setDataToReport( )
	local temp_data = {}
	local count = 0
	local beginIndex = 1
	local previous = nil
	if m_iBattle_id ~= 0 then
		for i, v in ipairs(report_profile_data_list) do
			if v == m_iBattle_id then
				if i + 1 > #report_profile_data_list then
					beginIndex = i+1
					reportData.reciveReport(temp_data)
					return
				else
					beginIndex = i+1
				end
				break
			end
		end
	end

	local function callFun( data, relax )
		if relax and report_lianxu_data[relax] then
			for i, v in ipairs(report_lianxu_data[relax]) do
				table.insert(data, report_profile_data[v])
			end
		end
	end

	for i=beginIndex, #report_profile_data_list do
		--全部
		if curSort == 0 then
			table.insert(temp_data, report_profile_data[report_profile_data_list[i]])
			count = count + 1 
			callFun( temp_data,report_profile_data[report_profile_data_list[i]].relax )
		--攻击
		elseif curSort == 1 and report_profile_data[report_profile_data_list[i]].attack== 1 then
			table.insert(temp_data, report_profile_data[report_profile_data_list[i]])
			count = count + 1 
			callFun( temp_data,report_profile_data[report_profile_data_list[i]].relax )
		elseif curSort == 2 and report_profile_data[report_profile_data_list[i]].attack== 0 then
			table.insert(temp_data, report_profile_data[report_profile_data_list[i]])
			count = count + 1 
			callFun( temp_data,report_profile_data[report_profile_data_list[i]].relax )
		elseif curSort == 3 and report_profile_data[report_profile_data_list[i]].read == 0 then
			table.insert(temp_data, report_profile_data[report_profile_data_list[i]])
			count = count + 1 
			callFun( temp_data,report_profile_data[report_profile_data_list[i]].relax )
		end
		if count >= 15 then
			break
		end
	end

	reportData.reciveReport(temp_data)
	if isOpenAnimation then
		OpenBattleAnimation.reciveAllReport()
	end
end

local function reciveProfileReport( packet )
	if m_iReportType == 1 or m_iReportType == 4 then
		for i, v in ipairs(packet) do
			for m,n in pairs(v) do
				report_profile_data[v.battle_id][m] = n
			end
		end

		if isLianxuzhanbao then
			setDataToReportLianxu()
		else
			setDataToReport( )
		end
	else
		reportData.reciveReport( packet )
	end
end

local function ifNeedPorfileReport(report_type,battle_id )
	curSort = report_type
	local need_request = {} 
	m_iBattle_id = battle_id
	local temp_relax = nil
	if battle_id == 0 then
		local lastIndex = #report_profile_data_list
		if lastIndex > 15 then
			lastIndex = 15
		end

		for i=1, lastIndex do
			if not report_profile_data[report_profile_data_list[i]].result then
				table.insert(need_request, report_profile_data_list[i])
			end
		end
	else
		local firstIndex = 0
		for i, v in ipairs(report_profile_data_list) do
			if battle_id == v then
				firstIndex = i
				break
			end
		end

		--如果是连续战报中的小战报，那么久要再遍历一次，因为report_profile_data_list没有连续战报的id
		if firstIndex == 0 and battleReportIdList then
			for i, v in ipairs(battleReportIdList) do
				--不能是最后一个
				if v.battle_id == m_iBattle_id and v.index then
					m_iBattle_id = battleReportIdList[math.floor(v.index/10000)].battle_id
					ifNeedPorfileReport(report_type,m_iBattle_id )
					return
				end
			end
		end

		if firstIndex ~= 0 then
			local lastIndex = firstIndex + 15
			if lastIndex > #report_profile_data_list then
				lastIndex = #report_profile_data_list
			end

			for i=firstIndex, lastIndex do
				if not report_profile_data[report_profile_data_list[i]].result then
					table.insert(need_request, report_profile_data_list[i])
				end
			end
		end
	end
	if #need_request > 0 then
		reportData.requestAllReport(need_request )
	else
		setDataToReport()
	end
end

-- `battle_id` 
--   `attack_userid` 
--   `attack_name` 
--   `attack_unionid` 
--   `attack_union_name`
--   `defend_userid`
--   `defend_name` 
--   `defend_unionid` 
--   `defend_union_name` 
--   `wid` 
--   `wid_name` 
--   `result` 战斗结果, 0:失败 1:胜利没有结果, 2：成功占领, 3:同盟占领, 4:成功附属 , 5:成功解救, 6平局, 7同归于尽' 8平局但是失败了,
--   `time` 
--   `attack_read`  '0:未读，1：已读',
--   `defend_read`  '0:未读，1：已读',
--   `npc`  '防守部队是否是npc',
local function reciveReport( packet )
	if not isMoreReport then
		battleReport = {}
		battleReportIdList = {}
	end

	-- local kk = 1
	-- for i,v in ipairs(packet) do
	-- 	if i%3 >=1 then
	-- 		if not v.relax then
	-- 			v.relax= kk
	-- 			if i%3 == 2 then
	-- 				kk = kk + 1
	-- 			end
	-- 		end
	-- 	end
	-- end

	local defend_advance = nil
	local attack_advance = nil
	for i, v in ipairs(packet) do
		if not m_bMoreSeriesReport then
			if not battleReport then battleReport = {} end
			if not battleReport[v.battle_id] then
				battleReport[v.battle_id] = {}
				if v.relax then
					if #battleReportIdList > 0 and battleReportIdList[#battleReportIdList].relax == v.relax then
						-- if #battleReportIdList[#battleReportIdList].count == 0 then
						-- 	table.insert(battleReportIdList, {battle_id = 0, relax = v.relax, isopen = false, count = {v.battle_id}})
						-- else
							table.insert(battleReportIdList[#battleReportIdList].count, v.battle_id)
						-- end
					else
						table.insert(battleReportIdList, {battle_id = v.battle_id, relax = v.relax, isopen = false, count = {}})
					end
				else
					table.insert(battleReportIdList, {battle_id = v.battle_id, relax = 0, isopen = false, count = {}})
				end
			end
		end

		if v.defend_advance == cjson.null or not v.defend_advance or v.defend_advance == "" then
			defend_advance = nil
		else
			defend_advance = stringFunc.anlayerMsg(v.defend_advance)
		end

		if v.attack_advance == cjson.null or not v.attack_advance or v.attack_advance == "" then
			attack_advance = nil
		else
			attack_advance = stringFunc.anlayerMsg(v.attack_advance)
		end

		battleReport[v.battle_id] = { 	battle_id = v.battle_id,
										attack_userid = v.attack_userid,
										attack_name = v.attack_name,
										attack_unionid = v.attack_unionid,
										attack_union_name = v.attack_union_name,
										defend_userid = v.defend_userid,
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
										attack_read = nil,
										defend_read = nil,
										npc = v.npc,
										relax = 0,
										report = nil,-- packet.report
										defend_advance = defend_advance,
										attack_advance = attack_advance, 
									}
		if m_iReportType ~= 1 and m_iReportType ~= 4 then
			battleReport[v.battle_id].attack_read = 1
			battleReport[v.battle_id].defend_read = 1
		else
			battleReport[v.battle_id].attack_read = report_profile_data[v.battle_id].read
			battleReport[v.battle_id].defend_read = report_profile_data[v.battle_id].read
		end
	end

	if not m_bMoreSeriesReport or isLianxuzhanbao then
		if reportUI.getInstance() then
			reportUI.dealWithReportChange()
		end
	end
	isLianxuzhanbao = false
	isMoreReport = false
	m_bMoreSeriesReport = false
	loadingLayer.remove()
end

--点开或者关闭下拉框
local function openOrCloseCell( index)
	-- if battleReportIdList[index].relax == 0 or #battleReportIdList[index].count == 0 then
	-- 	return
	-- end

	--如果已经打开，则关闭
	if battleReportIdList[index].open == true then
		local temp_index = 1
		local temp_delete_id = {}
		for i, v in ipairs (battleReportIdList[index].count) do
			temp_delete_id[v] = 1
		end

		while temp_index <= #battleReportIdList do
			if temp_delete_id[battleReportIdList[temp_index].battle_id] then
				table.remove(battleReportIdList, temp_index)
			else
				temp_index = temp_index + 1
			end
		end
		battleReportIdList[index].open = false
		reportUI.dealWithReportChange()
	--如果关闭，则打开
	else
		local num = index
		local temp = {}
		local flag = true
		for i,v in ipairs(battleReportIdList[index].count) do
			table.insert(battleReportIdList,index+i, {battle_id = v, relax = 0, index = num*10000+i, isopen = false, count = nil})
		end
		battleReportIdList[index].open = true
		if not battleReport[battleReportIdList[index+1].battle_id].result then
			flag = false
			for i = index+1, (index+14 <= #battleReportIdList and index+14 ) or #battleReportIdList do
				if not battleReport[battleReportIdList[i].battle_id].result then
					table.insert(temp, battleReportIdList[i].battle_id)
				end
			end
		end
		if #temp > 0 then
			m_bMoreSeriesReport = true
			isMoreReport = true
			isLianxuzhanbao = battleReportIdList[index].battle_id
			reportData.requestAllReport(temp )
		end

		if flag then
			reportUI.dealWithReportChange()
		end
	end
	
end

local function getPanelLenght( index )
	local len = 0
	for i, v in ipairs(battleReportIdList) do
		if not v.count then
			len = len + 174
		else
			len = len + 174
		end

		if i == index then
			return len
		end
	end
	return len
end

local function getReportListDataByidx(index )
	local temp = {}
	local flag = true
	if not battleReport[battleReportIdList[index].battle_id].result then
		flag = false
		for i = index, (index+14 <= #battleReportIdList and index+14 ) or #battleReportIdList do
			if not battleReport[battleReportIdList[i].battle_id].result then
				table.insert(temp, battleReportIdList[i].battle_id)
			end
		end
	end
	if #temp > 0 then
		m_bMoreSeriesReport = true
		isMoreReport = true
		reportData.requestAllReport(temp )
		-- loadingLayer.create()
	end

	if flag then
		return battleReportIdList[index]
	else
		return false
	end
end

--返回一个战报的具体信息
local function reciveOneReport( packet )
	if battleReport[packet.battle_id] then
		local real_str = reportData.anlayeReport(packet.report)
		battleReport[packet.battle_id].report = real_str
		if m_iReportType == 1  or m_iReportType == 4 then
			report_profile_data[packet.battle_id].report = real_str
		end
		if not isOpenAnimation then
			reportUI.createReportInfoUI(real_str,battleReport[packet.battle_id].attack_userid, battleReport[packet.battle_id].defend_userid, packet.battle_id)
		else
			isOpenAnimation = false
			OpenBattleAnimation.reciveReport(real_str,battleReport[packet.battle_id].attack_userid, battleReport[packet.battle_id].defend_userid, packet.battle_id)
		end
	end
	loadingLayer.remove()
end

--请求所有战报信息
local function requestAllReport(battle_id )
	loadingLayer.create(999)
	Net.send(GET_ALL_BATTLE_REPORT_PROFILE_CMD, {battle_id})
end

--请求更多战报
local function requestMoreReport( battle_id )
	loadingLayer.create()
	isMoreReport = true
	Net.send(GET_ALL_BATTLE_REPORT_PROFILE_CMD,  {battle_id})
end

--全部战报设置为已读
local function requestAllReportRead( )
	if m_iReportType == 1 or m_iReportType == 4 then
		if m_iReportType == 4 then
			Net.send(SET_BATTLE_REPORT_ALL_READ,0)
		else
			Net.send(SET_BATTLE_REPORT_ALL_READ,1)
		end

		for i, v in pairs( battleReport) do
			if reportData.returnAttackOrDefend(v ) then
				v.attack_read = 1
			else
				v.defend_read = 1
			end
		end
		if curSort == 3 then
			battleReport = {}
			battleReportIdList = {}
		end
		reportUI.refreshAllCell()
	end
end

--根据战报id请求一个战报
local function requestReportMsgById( id, openAnimation)
	loadingLayer.create()
	local att_or_def = 0
	if m_iReportType == 1 or m_iReportType == 4 then
		if reportData.returnAttackOrDefend(battleReport[id] ) then
			battleReport[id].attack_read = 1
			att_or_def = 1
		else
			battleReport[id].defend_read = 1
			att_or_def = 2
		end

		if m_iReportType == 4 then
			att_or_def = 4
		end
	end

	isOpenAnimation = openAnimation
	Net.send(GET_THE_BATTLE_REPORT_CMD, {id, att_or_def})
	
end

--请求所有同盟战报信息
local function requestUnionReport(sortWay, battle_id )
	if sortWay <= 2 then
		loadingLayer.create()
		Net.send(GET_UNION_BATTLE_REPORT, {sortWay, battle_id})
	end
end

--请求更多同盟战报
local function requestMoreUnionReport( sortWay, battle_id )
	if sortWay <= 2 then
		loadingLayer.create()
		isMoreReport = true
		Net.send(GET_UNION_BATTLE_REPORT, {sortWay, battle_id})
	end
end

--根据类型请求战报，1 自己的战报 2 同盟战报 4 演武战报
local function requestReportByType( sortWay, battle_id, openAnimation)
	if m_iReportType == 1 or m_iReportType == 4 then
		-- requestAllReport(sortWay, battle_id )
		isOpenAnimation = openAnimation
		ifNeedPorfileReport(sortWay,battle_id)
	else
		requestUnionReport(sortWay, battle_id )
	end
end

--根据类型请求更多战报
local function requestMoreReportByType( sortWay, battle_id)
	if not battle_id then return end
	if m_iReportType == 1 or m_iReportType == 4 then
		isMoreReport = true
		ifNeedPorfileReport(sortWay, battle_id)
		-- requestMoreReport(sortWay, battle_id )
	else
		requestMoreUnionReport(sortWay, battle_id )
	end
end

local function setSortWay(way )
	curSort = way
end

local function getSortWay( )
	return curSort
end

local function getReport(reportId)
	if m_iReportType ~= 4 then
		local practice = PracticeReportData.getPracticeReport(reportId)
		if practice then
			return practice
		end
	end
	if not battleReport then return nil end
	return battleReport[reportId] --allTableData[dbTableDesList.battle_report.name][reportId]
end

--获取显示战报的总个数（根据条件过滤后的结果）
local function getReportShowNums()
	return table.getn(battleReportIdList or {})--show_nums
end

local function getCellSize(index )
	if not battleReportIdList[index].count then
		return 174,1089
	else
		return 174,1089
	end
end

local function getReportDataByIndex(new_index)
	if new_index and battleReportIdList[new_index+1] and battleReportIdList[new_index+1].battle_id then
		return battleReport[battleReportIdList[new_index+1].battle_id]
	else
		return false
	end
end

local function sortRule(a,b)
	return a > b
end

local function initBattleReportList()
end

local function initData(report_type)

	m_iReportType = report_type 
	
	--返回所有战报大概信息
	netObserver.addObserver(GET_ALL_BATTLE_REPORT_PROFILE_CMD,reciveProfileReport)
	--返回单个战报详细信息
	netObserver.addObserver(GET_THE_BATTLE_REPORT_CMD,reciveOneReport)

	if m_iReportType and m_iReportType == 2 then 
		--返回同盟战报
		netObserver.addObserver(GET_UNION_BATTLE_REPORT,reciveProfileReport )
	end

	if m_iReportType and m_iReportType == 1 then
		reportInit()
	elseif m_iReportType and m_iReportType == 4 then
		reportPracticeInit()
	else

	end
	-- UIUpdateManager.add_prop_update(dbTableDesList.battle_report.name, dataChangeType.add, reportData.dealWithBattleReportChange)
end

local function remove( )
	battleReport = nil
	isOpenAnimation = nil
	battleReportIdList = nil
	isMoreReport = nil
	m_iReportType = nil
	m_iBattle_id = nil
	m_bMoreSeriesReport = nil
	isLianxuzhanbao = nil
	report_profile_data = {}
	report_profile_data_list = {}
	report_lianxu_data = {}
	UIUpdateManager.remove_prop_update(dbTableDesList.report_attack.name, dataChangeType.update,
	reportData.reportUpdate )
	UIUpdateManager.remove_prop_update(dbTableDesList.report_defend.name, dataChangeType.update,
	reportData.reportUpdate )
	--返回所有战报大概信息
	netObserver.removeObserver(GET_ALL_BATTLE_REPORT_PROFILE_CMD)
	--返回单个战报详细信息
	netObserver.removeObserver(GET_THE_BATTLE_REPORT_CMD)

	netObserver.removeObserver(GET_UNION_BATTLE_REPORT)
end

local function dealWithBattleReportChange(packet)
end

--返回这是防守还是攻击方看战报  true 攻方  false 守方
local function returnAttackOrDefend(report )
	-- local report = battleReport[id]
	-- 这个是教学演武的战报
	if not m_iReportType then
		return true
	end

	-- 这个是自由演武的战报
	if m_iReportType and m_iReportType == 4 then
		return true
	end

	if m_iReportType == 1 then
		-- if report.attack_userid == userData.getUserId() then
		if report_profile_data[report.battle_id].attack == 1 then
			return true
		else
			return false
		end
	else
		if report.attack_unionid == userData.getUnion_id() then
			return true
		else
			return false
		end
	end
end

local function anlayeReport(_report_str )
	local first_iaction = stringFunc.thirty_sixToDecimal(string.sub(_report_str, 1,2))
	local str = first_iaction..","..string.sub(_report_str, 3,string.len(_report_str))
	local len = string.len(str)
	local temp_str = nil
	local real_str = ""
	local i = 0
	while true do
		i = i+1
		temp_str = string.sub(str,i,i)

		if temp_str == "#" then
			if i ~= len then
				real_str = real_str.."#"..stringFunc.thirty_sixToDecimal(string.sub(str,i+1,i+2))..","
				i = i+2
			end
		else
			real_str = real_str..temp_str
		end
		if i >= len then
			break
		end
	end
	return real_str
end

reportData = {
				remove = remove,
				getReport = getReport,
				initData = initData,
				requestReportMsgById = requestReportMsgById,
				setSortWay = setSortWay,
				getSortWay = getSortWay,
				initBattleReportList = initBattleReportList,
				getReportShowNums = getReportShowNums,
				getReportDataByIndex = getReportDataByIndex,
				requestReportByType = requestReportByType,
				requestMoreReportByType = requestMoreReportByType,
				requestAllReportRead = requestAllReportRead,
				returnAttackOrDefend = returnAttackOrDefend,
				getPanelLenght = getPanelLenght,
				openOrCloseCell = openOrCloseCell,
				getCellSize = getCellSize,
				getReportListDataByidx = getReportListDataByidx,
				reciveReport = reciveReport,
				reportInit = reportInit,
				requestAllReport = requestAllReport,
				removeReportData = removeReportData,
				getReportType = getReportType,
				getIfUnreadReport = getIfUnreadReport,
				reportUpdate = reportUpdate,
				anlayeReport = anlayeReport,
}