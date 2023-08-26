--城市扩建功能
module("BuildingExpand", package.seeall)
local m_pWid = nil
local canPressBtnArray = {}

local m_tLastCacheExpandedWid = nil
local m_tCurCacheExpandedWid = nil

function getInstance(  )
	return m_pWid
end

function remove( )
	UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.update, BuildingExpand.reload)
	UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, BuildingExpand.reload)
	if mapData.getObject() and mapData.getObject().resLayer then
		MapNodeData.removeAllExpandNode()
		-- mapData.getObject().expand:removeAllChildrenWithCleanup(true)
	end
	m_pWid = nil
	canPressBtnArray = {}
	buildingExpandTitle.remove_self()

	m_tLastCacheExpandedWid = {}
	m_tCurCacheExpandedWid = {}
	if buildingEffectObject then 
		buildingEffectObject.remove_self()
	end
end


function refreshWidExpandedEffect()
	if m_tCurCacheExpandedWid then 
		if not m_tLastCacheExpandedWid then 
			m_tLastCacheExpandedWid = {}
		end

		for k,v in pairs(m_tCurCacheExpandedWid) do 
			if m_tCurCacheExpandedWid[k] and (not m_tLastCacheExpandedWid[k]) then 
				require("game/buildScene/buildingEffectObject")
				buildingEffectObject.playWidExpandedEffect(k)
			end
		end
	end
end
function reload( ... )
	
	if mapData.getObject() then
		-- mapData.getObject().expand:removeAllChildrenWithCleanup(true)
		MapNodeData.removeAllExpandNode()
	end
	
	m_tLastCacheExpandedWid = m_tCurCacheExpandedWid
	if m_pWid then
		create(m_pWid)
	else
		remove()
	end

	
	buildingExpandTitle.updateView()

	refreshWidExpandedEffect()
end

local function returnIndex( x,y )
	local rootX,rootY = config.countNodeSpace(x,y,map.getAngel())
	local point = nil
	local index = 0
	for i, v in pairs(canPressBtnArray) do
		point = v.sprite:convertToNodeSpace(cc.p(rootX,rootY))
		index = mapData.getRealWid(i )
		break
	end
	if not point then 
		return nil,nil
	end
	local coorX = math.floor((point.x-0)/200-(point.y-50)/100)
	local coorY = math.floor((point.x-0)/200+(point.y-50)/100)
	return coorX+math.floor(index/10000)+1, coorY+(math.floor(index/10000)+1)*10000-index
end

function touchBegin( x,y )
	local coorX, coorY = returnIndex(x,y)
	if not coorX then return end
	local tag  = mapData.getTagFunction(coorX, coorY, mapElement.EXPAND)
	if canPressBtnArray[tag] then

		canPressBtnArray[tag].sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expansion_of_tips_2.png"))
	end

	for i, v in pairs(canPressBtnArray) do
		if i ~= tag then
			if v.flag == 0 then
				v.sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expansion_of_tips_1.png"))
			else
				v.sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expansion_of_tips_3.png"))
			end
		end
	end
end

function touchEnd( x,y )
    local coorX, coorY =returnIndex(x,y)
    if not coorX then return end
    local tag  = mapData.getTagFunction(coorX, coorY, mapElement.EXPAND)
    if canPressBtnArray[tag] then
		if canPressBtnArray[tag].flag ==0 then
		    canPressBtnArray[tag].sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expansion_of_tips_1.png"))
			

			-- Net.send(WORLD_EXTEND_CITY, {m_pWid, coorX*10000+coorY})
			require("game/buildScene/buildingExpandConfirm")
			BuildingExpandConfirm.create(m_pWid, coorX*10000+coorY)
			
		else
		    canPressBtnArray[tag].sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("expansion_of_tips_3.png"))
		    if canPressBtnArray[tag].flag == -1 then
				tipsLayer.create(errorTable[61])
		    elseif canPressBtnArray[tag].flag == -2 then
				tipsLayer.create(errorTable[108])
		    else
				tipsLayer.create(errorTable[62],nil,{canPressBtnArray[tag].flag,
				canPressBtnArray[tag].point })
		    end
		end
    end
end

-- 如果是 山，水或者NPC 城市 则返回true
local function unexpandable(expanded,i,j)
	local isMountain = mapData.getCityType(i,j)
	local isWater = terrain.isWaterTerrain(i,j)
	local isNpc = false
	local temp_city_info = Tb_cfg_world_city[i*10000+j]
	if temp_city_info and (temp_city_info.city_type == cityTypeDefine.npc_cheng ) then
		isNpc = true
	end
	if isMountain or isWater or isNpc then return true end
	return false
end

function create(wid)
	m_pWid = wid
	canPressBtnArray = {}
	local mainCityType = mapData.getCityTypeData(math.floor(m_pWid/10000), m_pWid%10000)
	if not mainCityType or (mainCityType ~= cityTypeDefine.zhucheng and mainCityType ~= cityTypeDefine.fencheng) then return end
	local userCityData = userCityData.getUserCityData(m_pWid)
	if not userCityData then return end
	if not map.getInstance() then return end
	local extend_wid = {}

	if string.len(userCityData.extend_wids)>0 then
		extend_wid = stringFunc.anlayerOnespot(userCityData.extend_wids, ",", false)
	end
	if #extend_wid >= BUILD_EXPAND then return end

	local centerX,centerY = math.floor(m_pWid/10000), m_pWid%10000
	
	local up = (centerX-1 < 1 and 1) or centerX-1
	local down = (centerX+1 > 1501 and 1501) or centerX+1
	local left = (centerY-1 < 1 and 1) or centerY-1
	local right = (centerY+1 > 1501 and 1501) or centerY+1
	
	local expanded = {}
	m_tCurCacheExpandedWid = {}
	for i,v in pairs(extend_wid) do
		expanded[tonumber(v)] = 1
		m_tCurCacheExpandedWid[tonumber(v)] = 1
	end


	local mapLayer = mapData.getLoadedMapLayer(centerX,centerY)
	local expandLayer = mapData.getObject().resLayer
	local relation = nil
	local locationX, locationY = nil,nil
	local sprite = nil
	local spriteBtn = nil
	for i=up, down do
		for j=left, right do
			local relation = mapData.getRelation(i,j)
			local cityType = mapData.getCityTypeData(i,j)
			local isMountain = mapData.getCityType(i,j)
			local isWater = terrain.isWaterTerrain(i,j)
			local isBorderLegal = true
			--左上角
			if i== centerX-1 and j== centerY -1 then
				if unexpandable(expanded,i+1,j) or unexpandable(expanded,i,j+1) then
					isBorderLegal =false
				end
			end
			 
			--右上角
			if i== centerX-1 and j== centerY +1 then
				if unexpandable(expanded,i+1,j) or unexpandable(expanded,i,j-1) then
					isBorderLegal =false
				end
			end

			--左下角
			if i== centerX+1 and j== centerY -1 then
				if unexpandable(expanded,i-1,j) or unexpandable(expanded,i,j+1) then
					isBorderLegal =false
				end
			end

			--右下角
			if i== centerX+1 and j== centerY +1 then
				if unexpandable(expanded,i-1,j) or unexpandable(expanded,i,j-1) then
					isBorderLegal =false
				end
			end
			
			if not expanded[i*10000+j] and not isMountain and not isWater and isBorderLegal then
				locationX, locationY =  ((i- centerX)+(j - centerY))*0.5*200,
										 0.5*100*((j-centerY)-(i-centerX))

				
				local cityLevel = nil
				if userCityData.city_type == cityTypeDefine.zhucheng then 
					cityLevel = politics.getBuildLevel(mainBuildScene.getThisCityid(), cityBuildDefine.chengzhufu)
				elseif userCityData.city_type == cityTypeDefine.fencheng then 
					cityLevel = politics.getBuildLevel(mainBuildScene.getThisCityid(), cityBuildDefine.dudufu)
				else
					cityLevel = 0
				end
				--扩建按钮
				if cityType and ((cityType == cityTypeDefine.lingdi or cityType == cityTypeDefine.player_chengqu ) or (i==centerX and j==centerY))
					and relation and relation==mapAreaRelation.own_self 
					then
					sprite = cc.Sprite:createWithSpriteFrameName("expansion_of_tips_1.png")--cc.Sprite:createWithTexture(expandLayer:getTexture(), CCRectMake(406,2, 200,100))
					canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)] = {}
					canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)].sprite = sprite
					canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)].flag = 0
				else
					sprite = cc.Sprite:createWithSpriteFrameName("expansion_of_tips_3.png")--cc.Sprite:createWithTexture(expandLayer:getTexture(), CCRectMake(2,2, 200,100))
					canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)] = {}
					canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)].sprite = sprite
					-- -- 城主府等级需求
					-- if cityLevel < cityLevelNeed then 
					-- 	-- 城主府等级不足
					-- 	canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)].flag = #extend_wid+1
					-- 	canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)].point = cityLevelNeed
					-- else
					-- 	--其他原因不能扩建
					-- 	canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)].flag = -1
					-- end

					--其他原因不能扩建
					canPressBtnArray[mapData.getTagFunction(i,j, mapElement.EXPAND)].flag = -1
				end
				expandLayer:addChild(sprite, mapData.getTagFunction(i,j, mapElement.EXPAND),mapData.getTagFunction(i,j, mapElement.EXPAND))
				MapNodeData.addExpandNode(sprite,mapData.getTagFunction(i,j, mapElement.EXPAND))
				sprite:setPosition(cc.p(mapLayer:getPositionX()+100+locationX, mapLayer:getPositionY()+50+locationY))
			end
		end
	end
	UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.update, BuildingExpand.reload)
	UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, BuildingExpand.reload)
	
	buildingExpandTitle.create()

end

