--战争迷雾数据层
local allFogData = {}

local function getAllFogData(  )
	return allFogData
end

local function insertFogEgdeData(coorX,coorY )

	allFogData[coorX*10000+coorY] = 1
end

local function getFogDataByWid( wid )
	return allFogData[wid]
end

--超出范围的迷雾删除
local function deleteStencilByArea() 
	allFogData = {}
end

WarFogData = { 
				-- setStencilGrid = setStencilGrid,
				insertFogEgdeData = insertFogEgdeData,
				-- getWhichConner = getWhichConner,
				getAllFogData = getAllFogData,
				-- returnRect = returnRect,
				deleteStencilByArea = deleteStencilByArea,
				getFogDataByWid = getFogDataByWid,
				}