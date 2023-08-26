--任务数据
module("TaskData", package.seeall)
local m_tTaskData = nil
local m_iChooseTask = nil
  -- `task_id`'任务配置ID',
  -- `name`'任务名称',
  -- `task_type`'任务类型：1＝主线、2＝每日、3＝活动',
  -- `follow_tasks`'后续任务，完成此任务后出现的各个任务的配置ID，格式：ID1;ID2;ID3;',
  -- `pre_condition_time`'其它前置条件：时间（任务每日出现的时间）',
  -- `pre_condition_renown`'其它前置条件：名望（玩家达到特定名望才能看到任务）',
  -- `description`'任务说明',
  -- `sequence`'条件序号，以1-34表示，用来判断接下来使用的判断逻辑',
  -- `category`'种类：地块类型、操作、城市类型、资源种类、位置代号、称号队、卡包、卡牌、稀有度等的ID',
  -- `categories`'种类：建筑ID，格式：0/1,101,102,103 或 1,101  首位0表示后面任意一个，1表示后面全部',
  -- `level`'等级：地块、建筑、城市、武将、技能、技能数、同盟等的等级',
  -- `amount`'数量，条件要求达到的各种量',
  -- `rewards`'任务奖励，格式：资源ID1,数量1;资源ID2,数量2;资源ID3,数量3;资源ID4,数量4;',
local function setTaskData( )
	m_iChooseTask = nil
	local function setChooseTask(arrTable, count )
		if arrTable[count].is_completed == 1 and not m_iChooseTask then
			arrTable[count].isChoose = true
			m_iChooseTask = arrTable[count].task_id_u
		elseif not m_iChooseTask or arrTable[count].task_id_u ~= m_iChooseTask then
			arrTable[count].isChoose = false
		end
	end

	m_tTaskData = {}
	local arrTempNormal = {}
	local arrTempSpe = {}

	-- local iCount_normal = 0
	-- local iCount_spe = 0
	for i, v in pairs (allTableData[dbTableDesList.task.name]) do
		if v.got_award == 0 and Tb_cfg_task[v.task_id] then
			if Tb_cfg_task[v.task_id].priority == 1 then
				table.insert(arrTempSpe, v)
				-- iCount_spe = iCount_spe + 1
				-- setChooseTask(arrTempSpe, iCount_spe )
			else
				table.insert(arrTempNormal, v)
				-- iCount_normal = iCount_normal + 1
				-- setChooseTask(arrTempNormal, iCount_normal )
			end
		end
	end

	local function sortTable( arrTempTable)
		table.sort( arrTempTable, function (a,b )
			if a.is_completed == b.is_completed then
				if Tb_cfg_task[a.task_id].priority == Tb_cfg_task[b.task_id].priority then
					return a.task_id < b.task_id
				else
					return Tb_cfg_task[a.task_id].priority < Tb_cfg_task[b.task_id].priority
				end
			else
				return a.is_completed > b.is_completed
			end
		end )
	end

	

	if #arrTempNormal > 0 then
		sortTable( arrTempNormal)
		table.insert(m_tTaskData, {special = 0})
		for i, v in ipairs(arrTempNormal) do
			setChooseTask(arrTempNormal, i )
			table.insert(m_tTaskData, v)
		end
	end
	-- 战略任务
	if #arrTempSpe > 0 then
		sortTable( arrTempSpe)
		table.insert(m_tTaskData, {special = 1})
		for i, v in ipairs(arrTempSpe) do
			setChooseTask(arrTempSpe, i )
			table.insert(m_tTaskData, v)
		end
	end

	if not m_iChooseTask and #m_tTaskData > 0 then
		local index_ = 0
		for i, v in ipairs(m_tTaskData) do
			if m_tTaskData[i-1] and m_tTaskData[i-1].special and m_tTaskData[i-1].special == 0 then
				m_tTaskData[i].isChoose = true
				m_iChooseTask = m_tTaskData[i].task_id_u
				index_ = i
				break
			end
		end

		if index_ == 0 then
			m_tTaskData[2].isChoose = true
			m_iChooseTask = m_tTaskData[2].task_id_u
		end
	end

	if #m_tTaskData == 0 then
		m_iChooseTask = 0
	end

	
	

	-- if #m_tTaskData > 0 then
	-- 	m_tTaskData[1].isChoose = true
	-- end
end




function taskUpdate( )
	setTaskData()
	TaskUI.taskChange()
end

function initData(  )
	setTaskData()
	-- if #m_tTaskData > 0 then
	-- 	m_tTaskData[1].isChoose = true
	-- 	m_iChooseTask = m_tTaskData[1].task_id_u
	-- end

	
	netObserver.addObserver(TASK_AWARD,receiveCompleteTask)
	-- UIUpdateManager.add_prop_update(dbTableDesList.task.name, dataChangeType.add, taskUpdate)
	-- UIUpdateManager.add_prop_update(dbTableDesList.task.name, dataChangeType.remove, taskUpdate)
	-- UIUpdateManager.add_prop_update(dbTableDesList.task.name, dataChangeType.update, taskUpdate)
end

function remove( )
	m_tTaskData = nil
	m_iChooseTask = nil

	netObserver.removeObserver(TASK_AWARD)
	-- UIUpdateManager.remove_prop_update(dbTableDesList.task.name, dataChangeType.add, taskUpdate)
	-- UIUpdateManager.remove_prop_update(dbTableDesList.task.name, dataChangeType.remove, taskUpdate)
	-- UIUpdateManager.remove_prop_update(dbTableDesList.task.name, dataChangeType.update, taskUpdate)
end

function getTaskInfo( )
	return allTableData[dbTableDesList.task.name]
end

function getTaskNum( )
	return #m_tTaskData
end

function getTaskInfoByIndex(index )
	return m_tTaskData[index]
end

function getChooseTask(  )
	return m_iChooseTask
end

function getChooseTaskIndex( )
	for i,v in pairs(m_tTaskData) do
		if v.isChoose then
			return i
		end
	end
	return 0
end

--设置正在看的任务
function setTaskChoose(index )
	for i,v in pairs(m_tTaskData) do
		if i== index then
			v.isChoose = true
			m_iChooseTask = v.task_id_u
		else
			v.isChoose = false
		end
	end
end

function requestCompleteTask(idu,id )
	Net.send(TASK_AWARD,{idu})
	-- LSound.playSound(musicSound["sys_quest"])
end


function receiveCompleteTask( package )
	require("game/uiCommon/commonPopupManager")
	local arrTemp = {}
	-- local handler = nil
	if not Tb_cfg_task[package] then return end
	local name = nil
	local count = nil

	LSound.playSound(musicSound["sys_quest"])
	-- 同时获得多个任务特殊奖励时播放顺序为：卡牌→建筑队列→玉符。即关闭完一个后再打开下一个
	local tempRewards = Tb_cfg_task[package].rewards
	local tempSortList = {}
	tempSortList[16] = 1
	tempSortList[dropType.RES_ID_HERO] = 2
	tempSortList[dropType.RES_ID_QUEUE] = 3
	tempSortList[dropType.RES_ID_YUAN_BAO] = 4


	table.sort(tempRewards,function(va,vb)
		-- 对武将卡做特殊处理
		if va[1] % 100 == 8 then return true end
		if va[2] % 100 == 8 then return false end
		if tempSortList[va[1]] and tempSortList[vb[1]] then 
			
			if tempSortList[va[1]] < tempSortList[vb[1]] then 
				return true
			else
				return false
			end
		else
			return false
		end
	end)
	
	for i,v in ipairs(tempRewards) do
		
        if v[1] == 16 then 
        	-- 同名卡
            local hero_id = userData.getLastSameNameHero()
            v[1] = hero_id * 100 + 8
            commonPopupManager.gainAwardItem(taskAwardType.TYPE_CARD_HERO,hero_id)
        end
		name = clientConfigData.getDorpName(v[1]) 
		count = clientConfigData.getDorpCount(v[1], v[2] )


		if name and count then
			table.insert(arrTemp,languagePack["huode"]..name.." "..count)
			-- TODOTK 客户端应该要定义这些奖励类型的常量的
			if v[1] == dropType.RES_ID_YUAN_BAO then 
	        	-- 金
	        	commonPopupManager.gainAwardItem(taskAwardType.TYPE_GOLD,count)
	        elseif v[1] == dropType.RES_ID_QUEUE then
	        	--建筑队列
	        	commonPopupManager.gainAwardItem(taskAwardType.TYPE_BUILD_QUEUE,count,function ( )
	        		require("game/guide/shareGuide/picTipsManager")
                	picTipsManager.create(3)
	        	end)
	        else
	        	local iResId = v[1]%100
				if iResId == dropType.RES_ID_HERO then
					commonPopupManager.gainAwardItem(taskAwardType.TYPE_CARD_HERO,math.floor(v[1]/100))
				elseif iResId == dropType.RES_ID_CARD_EXTRACT then
					commonPopupManager.gainAwardItem(taskAwardType.TYPE_CARD_HERO,math.floor(v[1]/100))
				elseif iResId == dropType.RES_ID_SKILL then
					commonPopupManager.gainAwardItem(taskAwardType.TYPE_NEW_SKILL,math.floor(v[1]/1000))
				else
					-- "unknow"
				end
			end
		end
	end

	if #arrTemp > 0 then
		taskTipsLayer.create(arrTemp)
	end
end