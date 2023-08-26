-- 练兵的图标表现
module("MapTraining", package.seeall)


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
			nodeName = nil
			if city_type and aroundUserId then
				if city_type == cityTypeDefine.lingdi and centerUserId == aroundUserId then
					if m==i and n== j then
						nodeName = "training_big.png"
					end
				end

				if nodeName then
					tag = mapData.getTagFunction(m, n, mapElement.TRAINING)
					childNode = MapNodeData.getTrainingNode()[tag] --mapData.getObject().zhuzhaNode:getChildByTag(mapData.getTagFunction(m, n))
					if childNode then 
						-- childNode:removeFromParentAndCleanup(true)
						MapNodeData.removeTrainingNode(tag)
					end
					node = MapSpriteManage.popSprite(mapElement.TRAINING, nodeName, mapData.getObject().zhuzha)
					node:setAnchorPoint(cc.p(0.5, 0.5))
					MapNodeData.addTrainingNode(node,tag, nodeName)
					x,y = config.getMapSpritePos(posx,posy, coorX,coorY, m,n  )
					node:setPosition(cc.p(x+100, y+50))
					node:setVisible(true)
					node:setTag(tag)
					mapData.getObject().zhuzha:reorderChild(node,tag)
					node:setScale(mapController.getBuildingScaleTime())
					MapLandInfo.setCannotWarMarkVisible(m*10000+n, false)
					MapResidence.setIconVisible( m*10000+n, false )
					MapFarming.setFarmingIcon(m*10000+n,false)
				end
			end
		end
	end
end

function createAll( )
	local x, y = nil, nil
	local tagwid = nil
	local trainingNode = {}
	for i, v in pairs(MapNodeData.getTrainingNode()) do
		tagwid = mapData.getRealWid(i )
		tagX = math.floor(tagwid/10000)+1
		tagY = tagX*10000-tagwid
		table.insert(trainingNode, tagX*10000+tagY)
	end

	MapNodeData.removeAllTrainingNode()

	for i ,v in ipairs(trainingNode) do
		MapLandInfo.setCannotWarMarkVisible(v, true)
		MapResidence.setIconVisible( v, true )
		MapFarming.setFarmingIcon(v, true)
	end

	local data = armyData.getAllTeamMsg()
	for i, v in pairs(data) do
		if v.state == armyState.training then
			create(v.target_wid)
		end
	end

	data = mapData.getFieldArmyMsg()
	for i, v in pairs(data) do
		if v.state == armyState.training then
			create(v.wid_to)
		end
	end
end

function removeAll( )
	MapNodeData.removeAllTrainingNode()
end


function init( )
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update,createAll )
	createAll() 
end

function removeData( )
	UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update,createAll )
end