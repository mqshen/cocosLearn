-- mapFarming.lua
-- 屯田的图标表现
module("MapFarming", package.seeall)

-- 这个wid是不是屯田的中心位置
local function isFarmingBigImage(wid )
	local data = armyData.getAllTeamMsg()
	for i, v in pairs(data) do
		if v.state == armyState.decreed and wid == v.target_wid then
			return true
		end
	end
	return false
end

-- 地图整体刷新调用这个来创建
local function create(wid )
	local coorX, coorY = userData.getLocation()
	local posx,posy = userData.getLocationPos()
	local i = math.floor(wid/10000)
	local j = wid%10000
	local x, y = nil,nil
	local city_type = nil
	local node = nil
	local childNode = nil
	local relation = nil
	local tag = nil
	local nodeName = nil
	local centerUserId = mapData.getUserIdByWid(i,j)
	local aroundUserId = nil
	for m=i-1,i+1 do
		for n = j-1,j+1 do
			city_type = mapData.getCityTypeData(m,n)
			-- relation = mapData.getRelation(m,n)
			aroundUserId = mapData.getUserIdByWid(m,n)
			node = nil
			if city_type and aroundUserId then
				if city_type == cityTypeDefine.lingdi and centerUserId == aroundUserId  then
					if m==i and n== j then
						-- node = cc.Sprite:createWithSpriteFrameName("farming_big.png")
						nodeName = "farming_big.png"
					else
						if not isFarmingBigImage(m*10000+n ) then
							-- node = cc.Sprite:createWithSpriteFrameName("farming_small.png")
							nodeName = "farming_small.png"
						else
							nodeName = nil
						end
					end
				else
					nodeName = nil
				end

				if nodeName then
					tag = mapData.getTagFunction(m, n, mapElement.FARMING)
					childNode = MapNodeData.getFarmingNode()[tag] --mapData.getObject().zhuzhaNode:getChildByTag(mapData.getTagFunction(m, n))
					if childNode then 
						-- childNode:removeFromParentAndCleanup(true)
						MapNodeData.removeFarmingNode(tag)
					end
					-- mapController.setLevel5animationVisible(m*10000+n, false)
					node = MapSpriteManage.popSprite(mapElement.FARMING, nodeName, mapData.getObject().zhuzha)
					node:setAnchorPoint(cc.p(0.5, 0.5))
					-- mapData.getObject().zhuzha:addChild(node, tag, tag)
					MapNodeData.addFarmingNode(node,tag, nodeName)
					x,y = config.getMapSpritePos(posx,posy, coorX,coorY, m,n  )
					node:setPosition(cc.p(x+100, y+50))
					node:setVisible(true)
					node:setTag(tag)
					mapData.getObject().zhuzha:reorderChild(node,tag)
					node:setScale(mapController.getBuildingScaleTime())
					MapLandInfo.setCannotWarMarkVisible(m*10000+n, false)
					MapResidence.setIconVisible( m*10000+n, false )
				end
			end
		end
	end
end

function createAll( )
	local x, y = nil, nil
	local tagwid = nil
	local farmingNode = {}
	for i, v in pairs(MapNodeData.getFarmingNode()) do
		tagwid = mapData.getRealWid(i )
		tagX = math.floor(tagwid/10000)+1
		tagY = tagX*10000-tagwid
		table.insert(farmingNode, tagX*10000+tagY)
	end

	MapNodeData.removeAllFarmingNode()

	for i ,v in ipairs(farmingNode) do
		-- mapController.setLevel5animationVisible(v, true)
		MapLandInfo.setCannotWarMarkVisible(v, true)
		MapResidence.setIconVisible( v, true )
	end

	local data = armyData.getAllTeamMsg()
	for i, v in pairs(data) do
		if v.state == armyState.decreed then
			create(v.target_wid)
		end
	end

	data = mapData.getFieldArmyMsg()
	for i, v in pairs(data) do
		if v.state == armyState.decreed then
			create(v.wid_to)
		end
	end
end

function removeAll( )
	MapNodeData.removeAllFarmingNode()
end

function farmingHappended() 
	local data = armyData.getAllTeamMsg()
	for i, v in pairs(data) do
		if v.state == armyState.decreed then
			createAll( )
			break
		end
	end
end

function setFarmingIcon( wid, flag )
	if not mapData.getObject() then return end
	if not mapData.getObject().zhuzha then return end
	local node = MapNodeData.getFarmingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.FARMING)] --mapData.getObject().zhuzhaNode:getChildByTag(mapData.getTagFunction(math.floor(wid/10000), wid%10000))
	if node then
		if flag then
			if GroundEventData.getWorldEventByWid(wid ) or MapNodeData.getTrainingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.TRAINING)] then
			else
				node[1]:setVisible(flag)
			end
		else
			node[1]:setVisible(flag)
		end
	end
end

function init( )
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update,
	createAll )
	createAll() 
end

function removeData( )
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update,
	createAll )
end