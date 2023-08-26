--同盟功能数据
module("UnionData", package.seeall)

--记录同盟成员主界面打开的是哪个分页面
--1 成员， 2官员， 3申请人
local pageIndex = nil
--如果是反叛界面，反叛界面信息
local m_tRebel = {}
--同盟信息
local m_tUnionInfo = {}
--同盟成员
local m_tUnionMember = {}
--同盟成员按数组排序
local m_tUnionMemberSort = {}
--同盟官员
local m_tUnionOfficer = {}
--同盟申请者信息
local m_tUnionApply = {}
--当前查看的同盟id
local m_iUnionId = nil

-- 0是否申请（1已申请、0未申请）、1盟主名、2领地数、3下级成员数、4同盟信息对象
-- `union_id`  '同盟ID，六位，9开头',
--   `name`  '同盟的名字',
--   `leader_id`  '盟主ID，即玩家ID',
--   `vice_leader_id`  '副盟主ID，即玩家ID',
--   `create_time`  '建立时间',
--   `level`  '当前等级，在野为0级',
--   `exp`  '当前经验值',
--   `total_member`  '当前成员总数',
--   `tip`  '同盟介绍信息',
--   `notice` '同盟公告内容',
--   `apply_state` '同盟是否接受申请：0不接受、1接受',
local function setUnionInfo ( package)
	m_tUnionInfo = {}
	if package == cjson.null then return end
	local function npc_add( data)
		local addData = {}
		-- local add_des = {
		-- 				"wood_npc_add",
		-- 				"iron_npc_add",
		-- 				"stone_npc_add",
		-- 				"food_npc_add",
		-- 				"money_npc_add",
		-- 				"gong_attack_npc_add",
		-- 				"gong_defend_npc_add",
		-- 				"gong_intel_npc_add",
		-- 				"qiang_attack_npc_add",
		-- 				"qiang_defend_npc_add",
		-- 				"qiang_intel_npc_add",
		-- 				"qi_attack_npc_add",
		-- 				"qi_defend_npc_add",
		-- 				"qi_intel_npc_add",}
		-- if data.wood_npc_add ~= 0 then
			table.insert(addData, data.wood_npc_add)
		-- end

		-- if data.iron_npc_add ~= 0 then
			table.insert(addData, data.iron_npc_add)
		-- end

		-- if data.stone_npc_add ~= 0 then
			table.insert(addData, data.stone_npc_add)
		-- end

		-- if data.food_npc_add ~= 0 then
			table.insert(addData, data.food_npc_add)
		-- end

		-- if data.login_money_npc_add ~= 0 then
			table.insert(addData, data.login_money_npc_add)
		-- end

		-- if data.gong_attack_npc_add ~= 0 then
			table.insert(addData, data.gong_attack_npc_add)
		-- end

		-- if data.gong_defend_npc_add ~= 0 then
			table.insert(addData, data.gong_defend_npc_add)
		-- end

		-- if data.gong_intel_npc_add ~= 0 then
			table.insert(addData, data.gong_intel_npc_add)
		-- end

		-- if data.qiang_attack_npc_add ~= 0 then
			table.insert(addData, data.qiang_attack_npc_add)
		-- end

		-- if data.qiang_defend_npc_add ~= 0 then
			table.insert(addData, data.qiang_defend_npc_add)
		-- end

		-- if data.qiang_intel_npc_add ~= 0 then
			table.insert(addData, data.qiang_intel_npc_add)
		-- end

		-- if data.qi_attack_npc_add ~= 0 then
			table.insert(addData, data.qi_attack_npc_add)
		-- end

		-- if data.qi_defend_npc_add ~= 0 then
			table.insert(addData, data.qi_defend_npc_add)
		-- end

		-- if data.qi_intel_npc_add ~= 0 then
			table.insert(addData, data.qi_intel_npc_add)
		-- end
		return addData
	end
	m_tUnionInfo = { 
						--是否已申请加入这个联盟
						applyed = package[1],
						--盟主名字
						union_leader_name = package[2],
						--领地数
						area_number = package[3],
						--下级数
						under_number = package[4],
						union_id = package[5].union_id,
						name = package[5].name,
						leader_id = package[5].leader_id,
						vice_leader_id = package[5].vice_leader_id,
						create_time = package[5].create_time,
						level = package[5].level,
						exp = package[5].exp,
						total_member = package[5].total_member,
						tip = package[5].tip,
						notice = package[5].notice,
						apply_state = package[5].apply_state,
						power = package[5].power,
						region_spread = stringFunc.anlayerOnespot(package[5].region_spread, ",", true),
						region = package[5].region,
						union_add =  npc_add( package[5])
					}
end

-- 0玩家id、
-- 1用户名、
-- 2贡献值、
-- 3官位、

-- 4是否被禅让（1有，0没有）、
-- 5是否被附属（1是，0不是）,
-- 6主城坐标
local function setUnionMember(package )
	-- if m_iFirst then
		m_tUnionMember = {}
		m_tUnionMemberSort = {}
		m_tUnionOfficer = {}
	-- end
	for i,v in pairs(package) do
		if not m_tUnionMember[v[1]] then
			m_tUnionMember[v[1]] = {
									userid = v[1],
									userName = v[2],
									donate = v[3],
									position = v[4],
									-- online = v[5],
									isDemise = v[5],
									isAffiliated = v[6],
									wid = v[7],
									donateWeekly = v[8],
									roleForce = v[9]
								}
			table.insert(m_tUnionMemberSort, m_tUnionMember[v[1]])

			if v[4] >=1 and v[4] <=11 then
				if not m_tUnionOfficer[v[4]] then
					m_tUnionOfficer[v[4]] = {}
				end
				table.insert(m_tUnionOfficer[v[4]],v[1])
			end
		end
	end
end

--申请人信息
-- 0申请人、1申请时间、2,是否在线 3 申请id(不是用户id)  
function setUnionApply(package )
	m_tUnionApply = {}
	for i,v in ipairs(package) do
		table.insert(m_tUnionApply, {userName = v[1],applyTime = v[2], online = v[2], userid = v[3], isAgree = false})
	end
end

function setUnionApplyByIndex(index, flag )
	if m_tUnionApply[index] then
		m_tUnionApply[index].isAgree = flag
	end
end

function getUnionInfo( )
	return m_tUnionInfo
end

function getUnionMember( )
	return m_tUnionMemberSort
end

function getUnionOfficer( )
	return m_tUnionOfficer
end

function getUnionApply( )
	return m_tUnionApply
end

function setUnionId( id )
	m_iUnionId = id
end

function getUnionId( )
	return m_iUnionId
end

--请求联盟信息
function requestUnionInfo()
	-- setUnionId(union_id)
	Net.send(UNION_OVERVIEW,{m_iUnionId})
end

--接收联盟信息
function reciveUnionInfo(package )
	setUnionInfo(package)
	UnionMainUI.initUI()
	UnionDonateUI.init_all_content_show()
end

--请求捐赠或者反叛
function requestDonateOrRebel(wood, stone,iron, rice )
	local donateOrRebel = 1
	if 0 ~= userData.getAffilated_union_id() then
		donateOrRebel = 0
	end
	Net.send(UNION_DONATE,{donateOrRebel,wood, stone,iron, rice})
end

function reciveDonateOrRebel(packet)
	if 0 == userData.getAffilated_union_id() then
		requestUnionInfo()
	-- else
	-- 	m_tRebel.hasDonate = m_tRebel.hasDonate + UnionDonateUI.getDonateCount() or 0
	-- 	UnionDonateUI.initUI()
	end

	UnionDonateUI.receive_donate_or_rebel_result(packet)
end

--申请加入同盟
function requestJoinUnion(union_id )
	-- ADD BY TK 沦陷后不能申请加入
    if userData.getAffilated_union_id() ~= 0 then 
        tipsLayer.create(errorTable[206])
        return
    end
	Net.send(UNION_APPLY,{union_id})
end

function receiveJoinUnion( )
	if m_tUnionInfo and m_tUnionInfo.applyed then
		m_tUnionInfo.applyed = 1
	end
	UnionMainUI.initUI()
end

--取消加入同盟
function requestDeleteJoinUnion(union_id )
	Net.send(UNION_CANCEL_APPLY,{union_id})
end

function receiveDeleteJoinUnion( )
	if m_tUnionInfo and m_tUnionInfo.applyed then
		m_tUnionInfo.applyed = 0
	end
	UnionMainUI.initUI()
end

--请求解散联盟
function requestDeleteUnion( )
	Net.send(UNION_DISSOLVE,{})
end

--返回解散联盟是否成功
function reciveDeleteUnion( )
	-- UnionMemberMainUI.remove_self()
	requestUnionInfo()
end

function setPageIndex( index )
	pageIndex = index
end

function getPageIndex(  )
	return pageIndex
end

--请求成员列表
function requestUnionMember( )
	-- pageIndex = 1
	Net.send(UNION_MEMBER_LIST)
end

--在官员列表请求成员列表
function requestUnionMemberByOfficer( )
	-- pageIndex = 2
	Net.send(UNION_MEMBER_LIST)
end

--接收成员列表
function reciveUnionMember( package )
	setUnionMember(package)
	UnionMemberUI.reloadData()
	-- UnionMemberMainUI.initUI()
	-- UnionMemberMainUI.addUI(pageIndex)
end

--编辑公告板
function requestEditAnnouncement( str )
	if str then
		Net.send(UNION_EDIT_NOTICE,{str})
	end
end

function receiveEditAnnouncement( )
	UnionAnnouncement.remove_self()
	requestUnionInfo()
end

--请求申请人信息
function requestUnionApply( )
	-- pageIndex = 3
	Net.send(UNION_APPLICANT_LIST,{})
end

--接收申请人信息
function reciveUnionApply( package )
	setUnionApply(package )
	-- UnionMemberMainUI.addUI(pageIndex)
end

--请求同意或拒绝申请人处理
function requestAgreeApply( index)
	local temp = {}
	local name = {}
	for i, v in ipairs(m_tUnionApply) do
		-- if v.isAgree then
			table.insert(temp, v.userid)
			table.insert(name, v.userName)
		-- end
	end
	if #temp > 0 then
		--同意所选
		if index == 1 then
			--人数超过上限
			if getUnionInfo().total_member + #temp > Tb_cfg_union_level[getUnionInfo().level].people_max then
				tipsLayer.create(errorTable[84])
				return
			end

			Net.send(UNION_DEAL_APPLICATION,{temp,index})
		else
			Net.send(UNION_DEAL_APPLICATION,{temp,index})
		end
	end
end

--接收同意申请人结果
function reciveAgreeApply( )
	-- UnionMemberMainUI.addUI(3)
	requestUnionApply()
	requestUnionInfo()
	requestUnionMember()
end

--退出同盟
function requestQuitUnion( )
	Net.send(UNION_QUIT,{})
end

--请求反叛资源
function requestRebelInfo( )
	-- Net.send(UNION_GET_REBEL_VALUE,{})
end

--返回反叛资源
function reciveRebelInfo( package)
	-- m_tRebel = {hasDonate = package[1], total = package[2]}
	-- UnionDonateUI.initUI()
end

--返回反叛成功
function receiveRebel( )
	UnionRebelUI.remove_self()
	netObserver.removeObserver(UNION_ESCAPE_AFFILIATE)
	-- requestUnionInfo()
end

--请求反叛的操作
function requestRebel()
	--反叛
	netObserver.addObserver(UNION_ESCAPE_AFFILIATE,receiveRebel)
	Net.send(UNION_ESCAPE_AFFILIATE,{})
end

--请求移除成员
function requestDeleteMember(userid )
	Net.send(UNION_REMOVE_MEMBER,{userid})
end

--请求禅让
function requestDemise(userid )
	Net.send(UNION_DEMISS_LEADER,{userid})
end

--请求卸任
function requestOutgoing(userid )
	Net.send(UNION_GIVE_UP_OFFICIAL,{userid})
end

--接收移除成员或者禅让或者卸任或者取消禅让
function reciveMemberOption( )
	requestUnionInfo()
	requestUnionMember()
	-- UnionMemberMainUI.initUI()
end

--取消禅让
function requestCancelDemise( )
	Net.send(UNION_CANCEL_DEMISS,{})
end

function getRebelData( )
	local temp =allTableData[dbTableDesList.user.name][userData.getUserId()]
	m_tRebel.hasDonate = temp.rebel_cur
	m_tRebel.total = temp.rebel_total
	return m_tRebel
end


--治所 - 据点列表
function receiveGovernmentStrongholdList(package)
    UnionGovernment.updateData(package)
end
--治所 - 下属成员列表
function receiveGovernmentSubordinateList(package)
    UnionGovernment.updateData(package)
end

function requestGovernmentStrongholdList(unionId)
    Net.send(UNION_NPC_CITY_LIST,{})
end

function requestGovernmentSubordinateList(unionId)
    Net.send(UNION_AFFILIATED_MEMBER_LIST,{})
end

--日志信息
function requestUnionLog()
	Net.send(UNION_LOG_GET, {})
end

function receiveUnionLog(packet)
	unionLogManager.organize_log_list(packet)
end

function remove( )
	m_tUnionInfo = nil
	m_tUnionMember = nil
	m_tUnionMemberSort = nil
	m_tUnionOfficer = nil
	pageIndex = nil
	m_tUnionApply = nil
	m_iUnionId = nil
	m_tRebel = nil
	-- m_iFirst = false
	netObserver.removeObserver(UNION_OVERVIEW)
	netObserver.removeObserver(UNION_MEMBER_LIST)
	netObserver.removeObserver(UNION_APPLICANT_LIST)
	netObserver.removeObserver(UNION_DEAL_APPLICATION)
	-- netObserver.removeObserver(UNION_CREATE)
	netObserver.removeObserver(UNION_APPLY)
	netObserver.removeObserver(UNION_CANCEL_APPLY)
	netObserver.removeObserver(UNION_DONATE)
	netObserver.removeObserver(UNION_DISSOLVE)
	netObserver.removeObserver(UNION_REMOVE_MEMBER)
	netObserver.removeObserver(UNION_DEMISS_LEADER)
	netObserver.removeObserver(UNION_GIVE_UP_OFFICIAL)
	netObserver.removeObserver(UNION_LOG_GET)
	-- netObserver.removeObserver(UNION_ESCAPE_AFFILIATE)
	netObserver.removeObserver(UNION_CANCEL_DEMISS)
	netObserver.removeObserver(UNION_QUIT)
	-- netObserver.removeObserver(UNION_ESCAPE_AFFILIATE)
    netObserver.removeObserver(UNION_NPC_CITY_LIST)
    netObserver.removeObserver(UNION_AFFILIATED_MEMBER_LIST)
    netObserver.removeObserver(UNION_EDIT_NOTICE)
    UnionOfficialData.remove()
end

function initData(  )
    UnionOfficialData.initData()
	pageIndex = nil
	--如果是反叛界面，反叛界面信息
	m_tRebel = {}
	--同盟信息
	m_tUnionInfo = {}
	--同盟成员
 	m_tUnionMember = {}
	--同盟成员按数组排序
	m_tUnionMemberSort = {}
	--同盟官员
	m_tUnionOfficer = {}
	--同盟申请者信息
	m_tUnionApply = {}
	--当前查看的同盟id
	m_iUnionId = nil
	--接收联盟信息
	netObserver.addObserver(UNION_OVERVIEW,reciveUnionInfo)
	--接收成员列表
	netObserver.addObserver(UNION_MEMBER_LIST,reciveUnionMember)
	--接收申请人信息
	netObserver.addObserver(UNION_APPLICANT_LIST,reciveUnionApply)
	--接收申请人处理结果
	netObserver.addObserver(UNION_DEAL_APPLICATION,reciveAgreeApply)

	netObserver.addObserver(UNION_EDIT_NOTICE,receiveEditAnnouncement)
	
	--接收捐赠或反叛信息
	netObserver.addObserver(UNION_DONATE,reciveDonateOrRebel)
	--接收解散同盟信息
	netObserver.addObserver(UNION_DISSOLVE,reciveDeleteUnion)
	--移除成员
	netObserver.addObserver(UNION_REMOVE_MEMBER,reciveMemberOption)
	--禅让
	netObserver.addObserver(UNION_DEMISS_LEADER,reciveMemberOption)
	--副盟主放弃官位
	netObserver.addObserver(UNION_GIVE_UP_OFFICIAL,reciveMemberOption)
	--取消禅让
	netObserver.addObserver(UNION_CANCEL_DEMISS,reciveMemberOption)
	
	--同盟日志
	netObserver.addObserver(UNION_LOG_GET, receiveUnionLog)

    --治所 - 据点列表
	netObserver.addObserver(UNION_NPC_CITY_LIST,receiveGovernmentStrongholdList)
    --治所 - 下属成员列表
	netObserver.addObserver(UNION_AFFILIATED_MEMBER_LIST,receiveGovernmentSubordinateList)

	--退出同盟
	netObserver.addObserver(UNION_QUIT,reciveDeleteUnion)

	--申请加入同盟的返回信息
	netObserver.addObserver(UNION_APPLY,receiveJoinUnion)
	--取消加入同盟的返回信息
	netObserver.addObserver(UNION_CANCEL_APPLY,receiveDeleteJoinUnion)
	
end
