-- mapResidence.lua
-- 援军的图片显示
module("MapResidence", package.seeall)
local m_residenceData = nil
function isYuanjun(_viewInfo )
	if not _viewInfo then return false end
	for i,v in pairs(_viewInfo) do
		if v.state == armyState.yuanjuned then
			return true
		end
	end
	return false
end

function isCanYuanjun( userid , x, y)
	local first_message = mapData.getUserInfoInMap(userid)
	local second_message = nil
	local temp_user = mapData.getLandOwnerInfo(x,y)
	if temp_user then
		second_message = mapData.getUserInfoInMap(temp_user)
	end

	if not second_message then
		return false
	end

	if not first_message then
		return false
	end
	-- userid
-- union_id
-- affilated_union_id
	local relation = mapData.getRelationshipBetweenPlayer(first_message.userid, first_message.union_id, first_message.affilated_union_id  ,second_message.userid, second_message.union_id, second_message.affilated_union_id)
	if relation then
		if relation == mapAreaRelation.own_self or relation == mapAreaRelation.free_ally or relation == mapAreaRelation.free_underling then
			return true
		else
			return false
		end
	else
		return false
	end
end

-- 地图整体刷新调用这个来创建
function create(cx, cy )
	local coorX, coorY = userData.getLocation()
	local posx,posy = userData.getLocationPos()
	local i = cx--math.floor(wid/10000)
	local j = cy--wid%10000
	local x, y = nil,nil
	-- mapData.getObject().zhuzhaNode:removeChildByTag(mapData.getTagFunction(i, j),true)
	local userid = mapData.getLandOwnerInfo(i,j)
	local city_type = nil
	local node = nil
	local childNode = nil
	local viewInfo = nil
	local relation = nil
	local color = nil
	local tag = nil
	local nodeName = nil
	for m=i-1,i+1 do
		for n = j-1,j+1 do
			city_type = mapData.getCityTypeData(m,n)
			if city_type then
				if city_type == cityTypeDefine.lingdi or 
					city_type == cityTypeDefine.zhucheng or 
					city_type == cityTypeDefine.fencheng or
					city_type == cityTypeDefine.player_chengqu or
					city_type == cityTypeDefine.matou or
					city_type == cityTypeDefine.npc_yaosai or
					city_type == cityTypeDefine.npc_chengqu or
					city_type == cityTypeDefine.npc_cheng then
					if m==i and n== j then
						if city_type == cityTypeDefine.lingdi then
							-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_big.png")
							nodeName = "zhuzha_big.png"
						else
							relation = mapData.getRelation(m,n)
							if relation then
								color = clientConfigData.getRelationColor( relation)
								-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_"..color..".png")
								nodeName = "zhuzha_"..color..".png"
							else
								-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_blue.png")
								nodeName = "zhuzha_blue.png"
							end
							-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_small.png")
						end
					elseif isCanYuanjun( userid , m, n) then
						if city_type == cityTypeDefine.lingdi then
							-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_small.png")
							nodeName = "zhuzha_small.png"
						else
							relation = mapData.getRelation(m,n)
							if relation then
								color = clientConfigData.getRelationColor( relation)
								-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_"..color..".png")
								nodeName = "zhuzha_"..color..".png"
							else
								-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_blue.png")
								nodeName = "zhuzha_blue.png"
							end
						end
						-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_small.png")
					end
				elseif city_type == cityTypeDefine.yaosai and isCanYuanjun( userid , m, n) then
					-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_mid.png")
					nodeName = "zhuzha_mid.png"
				elseif isCanYuanjun( userid , m, n) then
					relation = mapData.getRelation(m,n)
					if relation then
						color = clientConfigData.getRelationColor( relation)
						-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_"..color..".png")
						nodeName = "zhuzha_"..color..".png"
					else
						-- node = cc.Sprite:createWithSpriteFrameName("zhuzha_blue.png")
						nodeName = "zhuzha_blue.png"
					end
				end
				viewInfo = mapData.getViewInfoData( m,n )
				if (m==i and n== j) or (isCanYuanjun( userid , m, n) and not isYuanjun(viewInfo)) then
					tag = mapData.getTagFunction(m, n, mapElement.YUANJUN)
					childNode = MapNodeData.getYuanjunNode()[tag] --mapData.getObject().zhuzhaNode:getChildByTag(mapData.getTagFunction(m, n))
					if childNode then 
						-- childNode:removeFromParentAndCleanup(true)
						MapNodeData.removeYuanjunNode(tag)
					end
					
					node = MapSpriteManage.popSprite(mapElement.YUANJUN, nodeName, mapData.getObject().zhuzha)
					node:setAnchorPoint(cc.p(0.5, node:getContentSize().width/4/node:getContentSize().height))
					-- mapData.getObject().zhuzha:addChild(node, tag, tag)
					MapNodeData.addYuanjunNode(node,tag,nodeName)
					x,y = config.getMapSpritePos(posx,posy, coorX,coorY, m,n  )
					node:setPosition(cc.p(x+100, y+50))
					node:setScale(mapController.getBuildingScaleTime())
					MapLandInfo.setCannotWarMarkVisible(m*10000+n, false)
					node:setVisible(true)
					node:setTag(tag)
					mapData.getObject().zhuzha:reorderChild(node, tag)
					if GroundEventData.getWorldEventByWid(m*10000+n ) then
						node:setVisible(false)
					end
				end
			end
		end
	end
end

function removeAll( )
	local x, y = nil, nil
	local tagwid = nil
	local YuanjunNode = {}
	for i, v in pairs(MapNodeData.getYuanjunNode()) do
		tagwid = mapData.getRealWid(i )
		tagX = math.floor(tagwid/10000)+1
		tagY = tagX*10000-tagwid
		table.insert(YuanjunNode, tagX*10000+tagY)
	end
	MapNodeData.removeAllYuanjunNode()

	for i, v in ipairs(YuanjunNode) do
		MapLandInfo.setCannotWarMarkVisible(v, true)
	end
end

function createAll( )
	removeAll()
	local data = mapData.getBuildingData()
	local area = mapData.getArea()
	for i = area.row_up, area.row_down do
		for m = area.col_left, area.col_right do
			if data[i] and data[i][m] then
				if isYuanjun(data[i][m].view_info) then
					create(i,m)
				end
			end
		end
	end
	-- for i, v in pairs(data) do
	-- 	for m,n in pairs(v) do
	-- 		if isYuanjun(n.view_info) then
	-- 			create(i*10000+m)
	-- 		end
	-- 	end
	-- end
end

function setIconVisible( wid, flag )
	if not mapData.getObject() then return end
	if not mapData.getObject().zhuzha then return end
	local node = MapNodeData.getYuanjunNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.YUANJUN)] --mapData.getObject().zhuzhaNode:getChildByTag(mapData.getTagFunction(math.floor(wid/10000), wid%10000))
	if node then
		if flag then
			if GroundEventData.getWorldEventByWid(wid ) or MapNodeData.getFarmingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.FARMING)] 
				or MapNodeData.getTrainingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.TRAINING)] then
			else
				node[1]:setVisible(flag)
			end
		else
			node[1]:setVisible(flag)
		end
	end
end

function remove(wid )
	-- mapData.getObject().zhuzhaNode:removeChildByTag(mapData.getTagFunction(math.floor(wid/10000), wid%10000),true)
	local tag =mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.YUANJUN)
	local node = MapNodeData.getYuanjunNode()[tag]
	if node then
		-- node:removeFromParentAndCleanup(true)
		MapNodeData.removeYuanjunNode(tag)
	end
end