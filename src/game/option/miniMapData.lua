-- miniMapData.lua
-- 小地图的数据部分
-- 和同盟有关的建筑服务器传unionid回来，只和个人有关的服务器直接传relation
module("MiniMapData", package.seeall)
local m_arrUnionMember = nil
local m_arrNpcCity = nil
-- local 
function init( )
	m_arrUnionMember = {}
    m_arrNpcCity = {}
    netObserver.addObserver(MINI_MAP_WORLD_INFO,receiveDataInBigMap)
    netObserver.addObserver(MINI_MAP_REGION_INFO,receiveDataInState)
end

function remove(  )
    m_arrNpcCity = nil
	m_arrUnionMember = nil
    netObserver.removeObserver(MINI_MAP_WORLD_INFO)
    netObserver.removeObserver(MINI_MAP_REGION_INFO)
end

local function setRelationColor( relation)
	-- local relation = mapData.getRelation(math.floor(wid/10000), wid%10000)
    if not relation or relation==mapAreaRelation.all_free or relation == mapAreaRelation.attach_free then
        return ccc3(255,255,255)
    elseif relation == mapAreaRelation.free_ally or relation == mapAreaRelation.free_underling then
        return ccc3(255,255,0)
    elseif relation == mapAreaRelation.free_enemy or relation == mapAreaRelation.attach_enemy then
        return ccc3(255,0,0)
    elseif relation == mapAreaRelation.attach_higher_up or relation == mapAreaRelation.attach_same_higher then
        return ccc3(233,144,227)
    else
        return ccc3(255,255,255)
    end
end

local function getSelfRelationColor( relation )
    if not relation or relation == mapAreaRelation.all_free then
        return ccc3(255,255,255)
    elseif relation == mapAreaRelation.own_self then
        return ccc3(0,255,0)
    elseif relation == mapAreaRelation.free_ally then
        return ccc3(0,0,255)
    elseif relation == mapAreaRelation.attach_same_higher or relation == mapAreaRelation.attach_higher_up then
        return ccc3(233,144,227)
    elseif relation == mapAreaRelation.free_underling then
        return ccc3(255,255,0)
    else
        return ccc3(255,0,0)
    end
end

function requestUnionMemberData( stateId )
	-- if m_arrUnionMember[stateId] then
		return m_arrUnionMember[stateId]
	-- end
end

-- 请求小地图的所有npc城和码头的数据
function requestDataInBigMap( )
    Net.send(MINI_MAP_WORLD_INFO,{})
end

-- 
function receiveDataInBigMap( package )
    -- m_arrNpcCity = {}
    for i, v in pairs(package) do
        m_arrNpcCity[i] = {wid = i, color = setRelationColor(mapData.getUnionRelationShip(v))}
    end
    miniMapManager.updateNpcCityColor()
end

-- 请求州界面的npc城，同盟成员数据
function requestDataInState(stateId )
    Net.send(MINI_MAP_REGION_INFO,{stateId})
end

function receiveDataInState( package )
    -- npc城的数据
    for i, v in pairs(package[1]) do
        m_arrNpcCity[i] = {wid = i, color = setRelationColor(mapData.getUnionRelationShip(v))}
    end

    -- 码头的数据
    for i, v in pairs(package[2]) do
        m_arrNpcCity[i] = {wid = i, color = getSelfRelationColor(v)}
    end

    -- 同盟成员的数据
    for i, v in pairs(package[3]) do
        if userData.getMainPos() ~= i then
            m_arrUnionMember[i] = {wid = i, color = getSelfRelationColor(v)}
        end
    end
    MiniMapState.updateNpcCityColor()
    MiniMapState.drawUnionMemberNode()
end

function getWorldNpcCityData( )
	return m_arrNpcCity
end

function getUnionMemberData(stateId )
	return m_arrUnionMember
end