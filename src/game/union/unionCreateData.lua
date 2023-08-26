--同盟创建的数据
module("UnionCreateData", package.seeall)
local m_arrRecommendUnionData = nil --推荐同盟数据
local m_arrInviteUnionData = nil --邀请同盟数据
local m_arrInviteUnionIndex = nil
local m_iTag = nil

local function tranDistance( dis )
	if dis >=0 and dis <=40 then
		return languagePack["julijin"]
	elseif dis >= 41 and dis <= 80 then
		return languagePack["julizhong"]
	else
		return languagePack["juliyuan"]
	end
end

-- 返回值：0同盟id、1同盟名、2等级、3当前人数、4所属州、5距离、6是否申请过（1已申请、0未申请）
local function setRecommendUnionData(package )
	local function setData( v )
		table.insert(m_arrRecommendUnionData, {						 
										union_name = v[2],
										distance = tranDistance( v[6] ),
										union_member_count = v[4],
										union_level = v[3],
										union_state = Tb_cfg_region[v[5]].name,
										applyed = v[7],
										union_id = v[1],
									})

	end

	-- if #package > 1 then
		m_arrRecommendUnionData = {}
	-- end

	for i, v in ipairs(package) do
		setData( v)
	end
end

-- 0同盟名、1等级、2人数、3所属州、4距离、5是否已读（1已读，0未读）
local function setInviteUnionDataDetails(data )
	local b_tips = false
	for i, v in pairs(data) do
		m_arrInviteUnionData[v[7]].union_name = v[1]
		m_arrInviteUnionData[v[7]].union_level = v[2]
		m_arrInviteUnionData[v[7]].union_member_count = v[3]
		m_arrInviteUnionData[v[7]].union_state = Tb_cfg_region[v[4]].name
		m_arrInviteUnionData[v[7]].distance = tranDistance(v[5])
		m_arrInviteUnionData[v[7]].new = v[6]
		if v[6] == 0 then
			b_tips = true
		end
	end

	if #data > 1 then 
		table.sort(m_arrInviteUnionIndex, function (a,b )
			if m_arrInviteUnionData[a].new == m_arrInviteUnionData[b].new then
				return m_arrInviteUnionData[a].invite_time > m_arrInviteUnionData[b].invite_time
			end
			return m_arrInviteUnionData[a].new < m_arrInviteUnionData[b].new		
		end)
	end

	if m_iTag ~= 3 then
		UnionCreateMainUI.unReadInviteData( b_tips )
	end
end

local function setInviteUnionData( )
	m_arrInviteUnionData = {}
	m_arrInviteUnionIndex = {}
	-- local b_tips = false
	for i, v in pairs(allTableData[dbTableDesList.union_invite.name]) do
		if v.invite_time + UNION_INVITE_VALID_TIME > userData.getServerTime() then
			m_arrInviteUnionData[v.invite_id] = {}
			m_arrInviteUnionData[v.invite_id] = v
			table.insert(m_arrInviteUnionIndex, v.invite_id)
		end
		-- if v.new == 1 then
		-- 	b_tips = true
		-- end
	end

	requestUnionInviteDetails(m_arrInviteUnionIndex)

	-- if m_iTag ~= 3 then
	-- 	UnionCreateMainUI.unReadInviteData( b_tips )
	-- end
end

local function inviteDataAdd(package )
	if m_iTag ~= 3 then
		UnionCreateMainUI.unReadInviteData( true )
	end

	table.insert(m_arrInviteUnionIndex,1,package.invite_id)
	m_arrInviteUnionData[package.invite_id] = package
	requestUnionInviteDetails({package.invite_id})
	if m_iTag == 3 then
		UnionInviteNoUnion.reloadData()
	end
end

local function inviteDataRemove(package )
	local b_tips = false
	for i, v in pairs(m_arrInviteUnionData) do
		if v.invite_id == package then
			table.remove(m_arrInviteUnionData,i)
		else
			if v.new and v.new == 0 then
				b_tips = true
			end
		end
	end

	for i, v in ipairs(m_arrInviteUnionIndex) do
		if v == package then
			table.remove(m_arrInviteUnionIndex,i)
		end
	end

	if m_iTag ~= 3 and b_tips then
		UnionCreateMainUI.unReadInviteData( true )
	else
		UnionCreateMainUI.unReadInviteData( false )
	end

	if m_iTag == 3 then
		UnionInviteNoUnion.reloadData()
	end	
end

local function inviteDataChange(package )
	for i, v in pairs(m_arrInviteUnionData) do
		if v.invite_id == package.invite_id then
			for m, n in pairs(package) do
				v[m] = n
			end
		end
		break
	end
end

--请求推荐同盟信息
function requestRecommendUnion( )
	Net.send(UNION_NEARBY_UNION_LIST,{})
end

function receiveRecommendUnion( package)
	setRecommendUnionData(package )
	if m_iTag == 2 then
		UnionJoin.reloadData()
	end
end

function getRecommendUnionCount( )
	return #m_arrRecommendUnionData
end

function getInviteUnion(index )
	return m_arrInviteUnionData[m_arrInviteUnionIndex[index]]
end

function getInviteUnionCount( )
	return #m_arrInviteUnionIndex
end

function getRecommendUnionData( )
	return m_arrRecommendUnionData
end

function setTagIndex( index)
	if index == 3 then
		UnionCreateMainUI.unReadInviteData( false )
		--发送指令告诉服务器全部邀请信息已经读取
		local arrTemp = {}
		for i, v in pairs(m_arrInviteUnionData) do
			if v.new == 0 then
				table.insert(arrTemp, v.invite_id)
			end
		end
		if #arrTemp > 0 then
			Net.send(UNION_UPDATE_INVITATION,{arrTemp})
		end
	end
	m_iTag = index
end

function init( )
	m_arrRecommendUnionData = {}
	m_arrInviteUnionData = {}
	m_arrInviteUnionIndex = {}
	m_iTag = 1
	setInviteUnionData()
	--申请加入同盟的返回信息
	netObserver.addObserver(UNION_APPLY,receiveJoinUnion)
	--取消加入同盟的返回信息
	netObserver.addObserver(UNION_CANCEL_APPLY,receiveDeleteJoinUnion)

	netObserver.addObserver(UNION_CREATE,reciveUnionId)

	netObserver.addObserver(UNION_NEARBY_UNION_LIST,receiveRecommendUnion)
	netObserver.addObserver(UNION_INVITATION_LIST,receiveUnionInviteDetails)
	netObserver.addObserver(UNION_DEAL_INVITATION, receiveAgreeInvite)
	netObserver.addObserver(UNION_APPLY_DIRECTLY, receiveJoinUnionByName)
	
	
	UIUpdateManager.add_prop_update(dbTableDesList.union_invite.name, dataChangeType.add, UnionCreateData.inviteDataAdd)
	UIUpdateManager.add_prop_update(dbTableDesList.union_invite.name, dataChangeType.remove, UnionCreateData.inviteDataRemove)
	UIUpdateManager.add_prop_update(dbTableDesList.union_invite.name, dataChangeType.update, UnionCreateData.inviteDataChange)
end

function remove( )
	m_arrRecommendUnionData = nil
	m_arrInviteUnionData = nil
	m_arrInviteUnionIndex = nil
	netObserver.removeObserver(UNION_APPLY)
	netObserver.removeObserver(UNION_CANCEL_APPLY)
	netObserver.removeObserver(UNION_CREATE)
	netObserver.removeObserver(UNION_NEARBY_UNION_LIST)
	netObserver.removeObserver(UNION_INVITATION_LIST)
	netObserver.removeObserver(UNION_DEAL_INVITATION)
	netObserver.removeObserver(UNION_APPLY_DIRECTLY)

	UIUpdateManager.remove_prop_update(dbTableDesList.union_invite.name, dataChangeType.add, UnionCreateData.inviteDataAdd)
	UIUpdateManager.remove_prop_update(dbTableDesList.union_invite.name, dataChangeType.remove, UnionCreateData.inviteDataRemove)
	UIUpdateManager.remove_prop_update(dbTableDesList.union_invite.name, dataChangeType.update, UnionCreateData.inviteDataChange)
end

--根据名字直接申请加入同盟
function requestJoinUnionByName( name )
	-- ADD BY TK 沦陷后不能申请加入
    if userData.getAffilated_union_id() ~= 0 then 
        tipsLayer.create(errorTable[206])
        return
    end
	if name and string.len(name) >=1 then
		Net.send(UNION_APPLY_DIRECTLY,{name})
	end
end

function receiveJoinUnionByName(union_id )
	tipsLayer.create(languagePack["fasongchenggong"])
	requestRecommendUnion()
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

function receiveJoinUnion(union_id )
	tipsLayer.create(languagePack["fasongchenggong"])
	for i, v  in ipairs(m_arrRecommendUnionData) do
		if v.union_id == union_id then
			v.applyed = 1
			UnionJoin.refreshCell(i)
			return
		end
	end
	-- requestRecommendUnion()
end

--取消加入同盟
function requestDeleteJoinUnion(union_id )
	Net.send(UNION_CANCEL_APPLY,{union_id})
end

function receiveDeleteJoinUnion(union_id )
	tipsLayer.create(languagePack["fasongchenggong"])
	for i, v  in ipairs(m_arrRecommendUnionData) do
		if v.union_id == union_id then
			v.applyed = 0
			UnionJoin.refreshCell(i)
			return
		end
	end
	-- requestRecommendUnion()
end

--请求建立联盟
function requestCreateUnion(union_name )
	Net.send(UNION_CREATE,{union_name})
end

--建立同盟后返回联盟id
function reciveUnionId(package )
	UnionCreateMainUI.remove_self(function (  )
		UnionUIJudge.create(package)
	end)
end

--请求同盟邀请详细信息
function requestUnionInviteDetails(arrInvite )
	if #arrInvite > 0 then
		Net.send(UNION_INVITATION_LIST,{})
	end
end

function receiveUnionInviteDetails( package )
	-- for i, v in ipairs(package) do
		setInviteUnionDataDetails(package )
	-- end
end

--同意邀请请求
function requestAgreeInvite(apply_id )
	-- ADD BY TK  BEGIN 如果被附属 不能创建
    if userData.getAffilated_union_id() ~= 0 then 
        tipsLayer.create(errorTable[207])
        return
    end
	Net.send(UNION_DEAL_INVITATION,{apply_id})
end

function receiveAgreeInvite( )
	UnionCreateMainUI.remove_self()
	UnionUIJudge.create(userData.getUnion_id())
end