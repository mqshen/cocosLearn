local flagPos = {}
flagPos["zuozhuanjiao"] = {174,82}
flagPos["youzhuanjiao"] = {30,79}
flagPos["shangzhuanjiao"] = {101,114}
flagPos["xiazhuanjiao"] = {97,45}

local defendPos = {}
defendPos["zuozhuanjiao"] = {174,80}
defendPos["youzhuanjiao"] = {30,80}
defendPos["shangzhuanjiao"] = {101,120}
defendPos["xiazhuanjiao"] = {97,44}

local firstTime = false
local changeTable = {}
local center = 5
local m_row = 9
-- local changeTable = {}
changeTable[1] = 41
local count = 3
for m = 1, 4 do
	for i = center-m, center+m do
		changeTable[count] = (center-m-1)*m_row+i
		count = count + 1
	end

	for i = center-m+1, center+m do
		changeTable[count] = (i-1)*m_row+ center+m
		count = count + 1
	end

	for i = center+m-1, center-m, -1 do
		changeTable[count] = (center+m-1)*m_row+i
		count = count + 1
	end

	for i = center+m-1, center-m+1, -1 do
		changeTable[count] = (i-1)*m_row+center-m
		count = count + 1
	end
end

local function getFlagColorRect(relation )
	if relation == mapAreaRelation.own_self then
		return "flag_green_"
	elseif relation == mapAreaRelation.free_ally then
		return "flag_blue_"
	elseif relation == mapAreaRelation.attach_same_higher then
		return "flag_purple_"
	elseif relation == mapAreaRelation.attach_higher_up then
		return "flag_purple_"
	elseif relation == mapAreaRelation.free_underling then
		return "flag_yellow_"
	elseif relation == mapAreaRelation.free_enemy then
		return "flag_red_"
	elseif relation == mapAreaRelation.attach_enemy then
		return "flag_red_"
	else
		return nil
	end
end

local function getFlagPos(str )
	return flagPos[str]
end

local function getDefendPos( str )
	return defendPos[str]
end

local mainCityData = {}
local cityComponentData = {}
local wallData = {}
local mainCityView = {}
local wallLevelData = {}

--该点是否有建筑
local function isBuilding(index)
	if not cityComponentData[index] then
		return false
	else
		return true
	end
end

local function insertWallData(mainPos,x,y,str,coorX,coorY )
	if not wallData[mainPos] then
		wallData[mainPos] = {}
	end
	table.insert(wallData[mainPos], {coorX = coorX, coorY=coorY, x=x,y=y, str= str})
end

--和服务器的外观系数转换
local function changeIndexWithServer(str )
	local temp = {}
	local tempStr = ""
	local wall = "~"
	for i=1,m_row*m_row do
		temp[i] = "~"
	end

	if string.len(str) > 0 then
		for i=1, string.len(str) do
			if i~=2 then
				local str = string.sub(str,i,i)
				if str == "}" then
					str = "~"
				end
				temp[changeTable[i]] = str
			else
				wall = string.sub(str,i,i)
			end
		end
	end

	for i,v in ipairs(temp) do
		tempStr = tempStr..v
	end
	return tempStr,wall
end

--获取废墟外观
local function getRuinsView( )
	return "^"
end

-- local function setNpcCityData()
-- 	if firstTime then return end
-- 	firstTime = true
-- 	local tempView = nil
-- 	local wall = nil
-- 	for m,n in pairs(Tb_cfg_world_city) do
-- 		local coorX, coorY = math.floor(n.wid/10000), n.wid%10000
-- 		local index = (2*coorX-1)*10000+2*coorY-1
-- 		tempView,wall = changeIndexWithServer(n.facade)
-- 		wallLevelData[n.wid] = wall
-- 		mainCityView[index] = tempView
-- 	end
-- end

local function centerCoorToCoor( x,y,hang,lie )
	local tempX,tempY
	if hang <=4 then
		tempX = (x-3) + math.ceil(hang/2)
	elseif hang == 5 then
		tempX = x
	else
		tempX = (x-2) + math.floor(hang/2)
	end

	if lie <=4 then
		tempY = (y-3) + math.ceil(lie/2)
	elseif lie == 5 then
		tempY = y
	else
		tempY = (y-2) + math.floor(lie/2)
	end

	return tempX,tempY
end

local function getNpcWallData(x,y )
	return wallData[x*10000+y]
end

local function getNpcMainCityData(i,j )
	return mainCityData[(2*i-1)*10000+2*j-1]
end

local function setNpcCityData(wid )
	if not Tb_cfg_world_city[wid] then
		return
	end
	local coorX, coorY = math.floor(wid/10000), wid%10000
	-- local wid = coorX*10000+coorY
	local index = (2*coorX-1)*10000+2*coorY-1
	local tempView,wall = changeIndexWithServer(Tb_cfg_world_city[wid].facade)
	wallLevelData[wid] = wall
	mainCityView[index] = tempView
end

local function getMainCityView( x,y )
	if not mainCityView[(2*x-1)*10000+2*y-1] then
		setNpcCityData(x*10000+y )
	end
	return mainCityView[(2*x-1)*10000+2*y-1]
end

local function getWallLevelData(x,y )
	if not wallLevelData[x*10000+y] then
		setNpcCityData(x*10000+y )
	end
	return wallLevelData[x*10000+y]
end

local clippingPos = {}
clippingPos[61] = {207,82}
clippingPos[62] = {247,97}
clippingPos[63] = {248,80}
clippingPos[64] = {163,67}

clippingPos[71] = {178,76}
clippingPos[72] = {176,76}
clippingPos[73] = {255,79}
clippingPos[74] = {186,78}

clippingPos[81] = {213,92}
clippingPos[82] = {241,105}
clippingPos[83] = {195,88}
clippingPos[84] = {201,79}
local function getClippingResPos(level )
	return clippingPos[level]
end

--该点是否有建筑
--1 有建筑 0 没建筑 false 该点不可用
function isBuilding(view,hang,lie)
	if hang>m_row or hang<1 or lie >m_row or lie< 1 then
		return 0
	end

	local png_index= string.byte(view,(hang-1)*m_row+lie)
	if png_index == 66 or png_index == 67 or png_index == 64 or png_index == 65 then
		return false
	elseif png_index == 126 then
		return 0
	else
		return 1
	end
end

--设置分城或要塞正在建设的外观,废墟的外观
local function setBuildingDeleteOrBuildFacade(city_type )
	local str = ""
	for i=1,m_row*m_row do
		if i== 41 then
			if city_type == cityTypeDefine.yaosai then
				str = str.."_"
			elseif city_type == cityTypeDefine.fencheng then
				str = str.."`"
			else
				str = str.."^"
			end
		else
			str = str.."~"
		end
	end
	return str
end

local fengchengView = setBuildingDeleteOrBuildFacade(cityTypeDefine.fencheng )
local yaosaiView = setBuildingDeleteOrBuildFacade(cityTypeDefine.yaosai )
local ruinsView = setBuildingDeleteOrBuildFacade(cityTypeDefine.own_free )

--获取分城外观
local function getFengchengView( )
	return fengchengView
end

--获取要塞外观
local function getYaosaiView( )
	return yaosaiView
end

-- 获取废墟完整外观
local function getTotalRuinsView(  )
	return ruinsView
end

local function getLandSmokeCount( )
	return 10
end

local function getDefendSmokeCount( )
	return 15
end

local function getLandFireCount( )
	return 5
end

CityComponentType = {getComponentRect  = getComponentRect,
					-- setNpcCityData = setNpcCityData,
					getNpcWallData = getNpcWallData,
					getNpcMainCityData = getNpcMainCityData,
					getMainCityView = getMainCityView,
					getAdditionComponentRect = getAdditionComponentRect,
					changeIndexWithServer = changeIndexWithServer,
					getWallLevelData = getWallLevelData,
					centerCoorToCoor = centerCoorToCoor,
					getFlagColorRect = getFlagColorRect,
					getFlagPos = getFlagPos,
					getClippingResPos = getClippingResPos,
					isBuilding = isBuilding,
					setBuildingDeleteOrBuildFacade = setBuildingDeleteOrBuildFacade,
					getRuinsView = getRuinsView,
					getFengchengView = getFengchengView,
					getYaosaiView = getYaosaiView,
					getTotalRuinsView = getTotalRuinsView,
					getDefendPos = getDefendPos,
					getLandSmokeCount = getLandSmokeCount,
					getDefendSmokeCount = getDefendSmokeCount,
					getLandFireCount = getLandFireCount,
					}