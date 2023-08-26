local size = 1501
local offset = {x=0,y=0}
local actionTable = {} --所有在闪烁的地表
local blinkGround = nil --让某个地表闪烁

local isJumpToCity = nil
local isLocateToCity = nil
local m_bIsLocatingCity = nil
local openMapmessageWhileLocating = true
local disposeMapmessageWhileLocating = true
local outScreenJumpCall = nil

local mainCityFade = nil --主城外观，新手引导期间当服务器推送过来外观改动不主动刷新，要由新手调用接口才刷新
local mainCityWallFade = nil
local refreshMainCityFade = true --是否刷新主城外观

local MOVE_UP = 1
local MOVE_DOWN = 2
local MOVE_LEFT = 3
local MOVE_RIGHT = 4

local m_bSimulatingMove = nil
local isResVisible = true

local cityShadow = nil
local levelOneWid = nil


local m_iLocateOffsetScreenX = nil
local m_iLocateOffsetScreenY = nil

local level5animationHandler = nil
--显示出来的草地 1
--丘陵 2
--水和沙地 3
--水和沙地边缘 4
--网格 5
--资源 6
--建筑batchnode 7
--山脉 8
--活动的时候的山城 9
--战争迷雾 10
--战争迷雾过渡 11

--销毁数据
local function remove( )
	levelOneWid = nil
	offset = {x=0,y=0}
	actionTable = {} --所有在闪烁的地表
	isJumpToCity = nil
	isLocateToCity = nil
	openMapmessageWhileLocating = true
	disposeMapmessageWhileLocating = true
	mainCityFade = nil
	mainCityWallFade = nil
	refreshMainCityFade = true
	isResVisible = true
	cityShadow = nil
	if level5animationHandler then
		scheduler.remove(level5animationHandler)
	end
	level5animationHandler = nil

	m_iLocateOffsetScreenX = nil
	m_iLocateOffsetScreenY = nil
end

local function setLocateScreenOffset(offsetScreenX,offsetScreenY)
	if not offsetScreenX then 
		offsetScreenX = 0
	end

	if not offsetScreenY then 
		offsetScreenY = 0
	end

	m_iLocateOffsetScreenX = offsetScreenX
	m_iLocateOffsetScreenY = offsetScreenY
end

local function setJumpToCity( wid )
	isJumpToCity = wid
end

local function setLocateToCity(wid)
	isLocateToCity = wid
end
local function getScaleTime( )
	return 0.5
end

local function getBuildingScaleTime( )
	return 0.5
end

--增加迷雾边缘
local function addFog( coorX, coorY, posX, posY,index  )
	local object = mapData.getObject()
	-- if object.fogLayer:getChildByTag(mapData.getTagFunction(coorX, coorY)) then
	if MapNodeData.getFogNode()[mapData.getTagFunction(coorX, coorY, mapElement.FOGEAGE)] then
		return
	end
	local jumpCoorX, jumpCoorY = map.getLocation( )
	local jumpPosX, jumpPosY = userData.getLocationPos()
	if not jumpCoorX or not jumpPosX then return end
	-- local layer = mapData.getLoadedMapLayer( math.ceil(coorX/2), math.ceil(coorY/2))
	-- if not layer then return end

	local arrFogData = WarFogData.getAllFogData()
	local function isSmallFog(  x, y )
		return arrFogData[math.ceil(x/2)*10000+math.ceil(y/2)]
	end

	local count = 0
	for i=coorX-1, coorX+1 do
		for j = coorY-1, coorY + 1 do
			if not isSmallFog(i,j) then
				count = count + 1
			end
		end
	end

	local function addFogEdge(x, y, imageName)
		local posx, posy = nil, nil
		local tag = mapData.getTagFunction(x, y,mapElement.FOGEAGE)
		if MapNodeData.getFogNode()[tag] then return end
		local localX,localY = config.getMapSpritePos(jumpPosX,jumpPosY, jumpCoorX,jumpCoorY, math.ceil(coorX/2), math.ceil(coorY/2), 200, 100  )--layer:getPositionX()
		--上下夹角
		if imageName == 421 then
			posx, posy = localX+100, localY
		--左右夹角
		elseif imageName == 431 then
			posx, posy = localX, localY + 50
		else
			posx, posy =config.getMapSpritePos(localX+posX,localY+posY, coorX,coorY, x,y, 100, 50  )
		end

		-- local fogLayer= cc.Sprite:createWithSpriteFrameName(imageName)
		local fogLayer= MapSpriteManage.popSprite(mapElement.FOGEAGE, imageName, object.zhuzha)
		-- object.zhuzha:addChild(fogLayer,tag,tag)
		MapNodeData.addFogNode(fogLayer,tag,imageName)
		fogLayer:setTag(tag)
		-- fogLayer:setZOrder(tag)
		object.zhuzha:reorderChild(fogLayer,tag)
		fogLayer:setAnchorPoint(cc.p(0.5, 0.5))
		fogLayer:setPosition(cc.p(posx,posy))
		fogLayer:setVisible(true)
	end

	local quejiao = {
						{{coorX, coorY, "fog_21.png"},{coorX-1, coorY, "fog_31.png"},{coorX, coorY+1, "fog_33.png"}},
						{{coorX, coorY, "fog_22.png"},{coorX, coorY-1, "fog_34.png"},{coorX+1, coorY, "fog_32.png"}},
						{{coorX, coorY, "fog_23.png"},{coorX-1, coorY, "fog_32.png"},{coorX, coorY-1, "fog_33.png"}},
						{{coorX, coorY, "fog_24.png"},{coorX, coorY+1, "fog_34.png"},{coorX+1, coorY, "fog_31.png"}},
						}

	local zhuanjiao = {
						"fog_11.png",
						"fog_12.png",
						"fog_13.png",
						"fog_14.png",
	}

	--直边
	if count == 3 then
		--上直边
		if not isSmallFog(coorX-1,coorY) then
			addFogEdge(coorX,coorY, "fog_33.png" )
		--右直边
		elseif not isSmallFog(coorX,coorY+1) then
			addFogEdge(coorX,coorY, "fog_31.png")
		--下直边
		elseif not isSmallFog(coorX+1,coorY) then
			addFogEdge(coorX,coorY, "fog_34.png")
		--左直边
		elseif not isSmallFog(coorX,coorY-1) then
			addFogEdge(coorX,coorY, "fog_32.png")
		end
	--缺角
	elseif count == 1 then
		for i = 1 ,3 do
			addFogEdge(quejiao[index][i][1], quejiao[index][i][2], quejiao[index][i][3] )
		end
	--转角
	elseif count == 5 then
		addFogEdge(coorX, coorY,zhuanjiao[index])
	--上下夹角
	elseif count == 4 and index == 2 then
		addFogEdge(coorX,coorY, "fog_12.png")
		addFogEdge(coorX+1,coorY-1, "fog_11.png")
	--左右夹角
	elseif count == 4 and index == 3 then
		addFogEdge(coorX,coorY, "fog_13.png")
		addFogEdge(coorX-1,coorY-1, "fog_14.png")
	end
end

local function removeFog( )
	MapNodeData.removeAllFogNode()
	local arrFogData = WarFogData.getAllFogData()
	local netArea = mapData.getArea()
	if not mapData.getObject() then return end
	local object = MapNodeData.getSurfaceNode()--mapData.getObject().batchNode
	local pSprite = nil
	local mapArea = mapData.getMapArea()
	local row_up = math.min(netArea.row_up, mapArea.row_up)
	local row_down = math.max(netArea.row_down, mapArea.row_down)
	local col_left = math.min(netArea.col_left, mapArea.col_left)
	local col_right = math.max(netArea.col_right, mapArea.col_right)
	for i = row_up, row_down do
		for j = col_left, col_right do
			pSprite = object[mapData.getTagFunction(i,j,mapElement.FOG)]
			if arrFogData[i*10000+j] then
				if pSprite then
					pSprite[1]:setVisible(false)
				end
				addFog(2*i-1, 2*j-1, 50, 50, 3)
				addFog(2*i-1, 2*j, 100, 75,1)
				addFog(2*i, 2*j-1, 100, 25,2)
				addFog(2*i, 2*j, 150, 50,4)
			else
				if pSprite then
					pSprite[1]:setVisible(true)
				end
			end
		end
	end
end

local function runFlagAction(sprite,rect, index)
	local count = index
	-- local rect_real = rect..".png"--string.sub(rect, 1, string.len(rect)-5)
	return animation.sequence({cc.DelayTime:create(0.2), cc.CallFunc:create(function ( )
		sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(rect..count..".png"))		
		count = count + 1
		if count > 5 then
			count =1
		end
	end)})
end

local function playLandLevel5Animation(sprite, name, totalCount, index,time )
	local count = index
	return animation.sequence({cc.DelayTime:create(time), cc.CallFunc:create(function ( )
		sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name..count..".png"))		
		count = count + 1
		if count > totalCount then
			count =1
		end
	end)})
end

local function setDefendFireAnimation(coorX, coorY,nodePosx, nodePosy  )
	local totalCount = CityComponentType.getDefendSmokeCount()
	local total_index = math.random(1,totalCount)
	local fire = cc.Sprite:createWithSpriteFrameName("xinshou_smoke_"..total_index..".png")
	fire:setAnchorPoint(cc.p(0.3,0))
	fire:setScale(getScaleTime())
	mapData.getObject().newGuideNode:addChild(fire)
	fire:setPosition(cc.p(nodePosx, nodePosy))
	fire:runAction(CCRepeatForever:create(playLandLevel5Animation(fire, "xinshou_smoke_", totalCount, total_index,0.1 )))
	mapData.insertDefendFireData(fire, coorX*10000+coorY)
end

local function addDefendFire( coorX, coorY )
	local cityData= mapData.getCityComponentData(coorX, coorY)
	mapData.removeDefendFireData( coorX,coorY )
	if cityData then
		local building = nil
		local defendPos = nil
		local guard_end_time = mapData.getGuard_end_timeData(coorX, coorY)
		if guard_end_time and guard_end_time > userData.getServerTime() then
			for i, v in pairs(cityData) do
				if v.view == "zuozhuanjiao" or v.view == "youzhuanjiao" or v.view == "shangzhuanjiao"
				or v.view == "xiazhuanjiao" then
					building = MapNodeData.getBuildingNode()[v.parentTag] --mapData.getObject().building:getChildByTag(v.parentTag)
					if building then
						defendPos = CityComponentType.getDefendPos(v.view)
						-- 坚守期间的烟火
						worldPos = building[1]:convertToWorldSpace(cc.p(defendPos[1], building[1]:getContentSize().height-defendPos[2]+20))
						nodePos = mapData.getObject().newGuideNode:convertToNodeSpace(worldPos)
						setDefendFireAnimation(coorX, coorY,nodePos.x, nodePos.y  )
					end
				end
			end
		end
	end
end

local function changeFlagColor( coorX, coorY)
	local relation = mapData.getRelation(coorX, coorY)
	local rect = CityComponentType.getFlagColorRect(relation)
	local cityData= mapData.getCityComponentData(coorX, coorY)
	if cityData then
		local flag = nil
		local building = nil
		local flag_index = nil
		local defendPos = nil
		local defend = nil
		local totalCount = nil
		local total_index = nil
		local fire = nil
		local worldPos = nil
		local nodePos = nil
		mapData.removeDefendFireData( coorX,coorY )
		local guard_end_time = mapData.getGuard_end_timeData(coorX, coorY)
		for i, v in pairs(cityData) do
			if v.view == "zuozhuanjiao" or v.view == "youzhuanjiao" or v.view == "shangzhuanjiao"
			or v.view == "xiazhuanjiao" then
				building = MapNodeData.getBuildingNode()[v.parentTag] --mapData.getObject().building:getChildByTag(v.parentTag)
				if building then
					building[1]:removeAllChildrenWithCleanup(true)
				end
				if rect then
					local message = mapData.getBuildingData()
					if relation == mapAreaRelation.free_ally and message and message[coorX] and message[coorX][coorY]
					and message[coorX][coorY].cityType
					 and message[coorX][coorY].cityType == cityTypeDefine.npc_cheng then
						rect= CityComponentType.getFlagColorRect(mapAreaRelation.free_underling)
					end
					flag_index = math.random(1,5)
					flag = cc.Sprite:createWithSpriteFrameName(rect..flag_index..".png" )
					flag:setAnchorPoint(cc.p(0.5,0))
					local tempPos = CityComponentType.getFlagPos(v.view)
					flag:setPosition(cc.p(tempPos[1], building[1]:getContentSize().height-tempPos[2]))
					building[1]:addChild(flag,1,1)
					flag:runAction(CCRepeatForever:create(runFlagAction(flag,rect, flag_index)))

					if guard_end_time and guard_end_time > userData.getServerTime() then
						-- 如果是坚守期间
						defendPos = CityComponentType.getDefendPos(v.view)
						defend = cc.Sprite:createWithSpriteFrameName("home_defend.png")
						defend:setAnchorPoint(cc.p(0.5,0.2))
						building[1]:addChild(defend,2,2)
						defend:setPosition(cc.p(defendPos[1], building[1]:getContentSize().height-defendPos[2]))

						-- 坚守期间的烟火
						worldPos = defend:getParent():convertToWorldSpace(cc.p(defend:getPositionX(), defend:getPositionY()+20))
						nodePos = mapData.getObject().newGuideNode:convertToNodeSpace(worldPos)
						setDefendFireAnimation(coorX, coorY,nodePos.x, nodePos.y  )
					end
				end
				-- mapData.setFlagData(tempX, tempY, mapData.getTagFunction(coorX, coorY),component_type  )
			end
		end
	end
	-- addDefendFire( coorX, coorY )
end

--增加城墙
local function addComponent(targetIndex,mainCityWid,sprite,x,y,component_type,coorX, coorY )
	local component_typeStr = component_type
	local wallstr = nil
	local widX,widY = math.floor(mainCityWid/10000),mainCityWid%10000
	if CityComponentType.getWallLevelData(widX,widY) or mapData.getBuildingWall(widX,widY) then
		if (mapData.getBuildingWall(widX,widY) == "2")
			and component_typeStr~= "shang"
			and component_typeStr~= "xia"
			and component_typeStr~= "zuo"
			and component_typeStr~= "you" 
			and component_typeStr~= "xiaquejiao" 
			and component_typeStr~= "zuoquejiao" 
			and component_typeStr~= "shangquejiao" 
			and component_typeStr~= "youquejiao" then
			component_typeStr = component_typeStr.."2"
		end

		if CityComponentType.getWallLevelData(widX,widY) == "3" then
			component_typeStr = "npc_"..component_typeStr
		end
	end

	local hang_index = math.ceil(targetIndex/9)
	local lie_index = targetIndex-(hang_index-1)*9
	local tempX, tempY = CityComponentType.centerCoorToCoor( widX,widY,hang_index, lie_index)
	mapData.setCityComponentData(widX,widY,mapData.getTagFunction(coorX, coorY,mapElement.BUILDING ), tempX*10000+tempY,component_type )

	-- local building = cc.Sprite:createWithSpriteFrameName(component_typeStr..".png")
	local building = MapSpriteManage.popSprite(mapElement.BUILDING, component_typeStr..".png", mapData.getObject().building)
	building:setAnchorPoint(cc.p(0.5,building:getContentSize().width/4/building:getContentSize().height))
	local tag = mapData.getTagFunction(coorX, coorY,mapElement.BUILDING)
	-- mapData.getObject().building:addChild(building, tag,tag)

	MapNodeData.addBuildingNode(building, tag, component_typeStr..".png")
	building:setVisible(true)
	building:setTag(tag)
	mapData.getObject().building:reorderChild(building, tag)
	building:setPosition(cc.p(sprite:getPositionX()+x*getBuildingScaleTime(), sprite:getPositionY()+y*getBuildingScaleTime()))
	building:setScale(getBuildingScaleTime())

end


--建筑拼接 sprite:主城精灵
local function addSmallBuilding(targetIndex,sprite,coorX, coorY, view,mainCityWid)
	local hang = math.ceil(targetIndex/9)
	local lie = (targetIndex%9 == 0 and 9 ) or targetIndex%9

	-- local png_index= string.byte(view,(hang-1)*5+lie)
	-- if png_index == 66 or png_index == 67 then
	-- 	return
	-- end

	if not CityComponentType.isBuilding(view, hang, lie) then
		return
	end

	--上转角加两个直边
	if CityComponentType.isBuilding(view, hang-1, lie) == 0
		and CityComponentType.isBuilding(view,hang, lie+1) == 0
		and CityComponentType.isBuilding(view,hang-1, lie+1) == 1 then
		addComponent(targetIndex,mainCityWid,sprite,-100,50,"zuoquejiao",coorX-1, coorY)
		addComponent(targetIndex,mainCityWid,sprite,100,50,"youquejiao",coorX, coorY+1)
	end

	--上转角 上右北都无建筑
	if CityComponentType.isBuilding(view,hang-1,lie) == 0 
		and CityComponentType.isBuilding(view,hang,lie+1) == 0
		and CityComponentType.isBuilding(view,hang-1,lie+1) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,0,100,"shangzhuanjiao",coorX-1, coorY+1)
	end

	--下转角 左下南都无建筑
	if CityComponentType.isBuilding(view,hang,lie-1) == 0 
		and CityComponentType.isBuilding(view,hang+1,lie) == 0
		and CityComponentType.isBuilding(view,hang+1,lie-1) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,0,-100,"xiazhuanjiao",coorX+1, coorY-1)
	end

	--左转角加两个直边
	if CityComponentType.isBuilding(view,hang-1,lie) == 0
		and CityComponentType.isBuilding(view,hang,lie-1) == 0
		and CityComponentType.isBuilding(view,hang-1,lie-1) == 1 then
		addComponent(targetIndex,mainCityWid,sprite,-100,50,"shangquejiao",coorX-1, coorY)
		addComponent(targetIndex,mainCityWid,sprite,-100,-50,"xiaquejiao",coorX, coorY-1)
	end

	--左转角 西上左都无建筑
	if CityComponentType.isBuilding(view,hang-1,lie) == 0 
		and CityComponentType.isBuilding(view,hang,lie-1) == 0
		and CityComponentType.isBuilding(view,hang-1,lie-1) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,-200,0,"zuozhuanjiao",coorX-1, coorY-1)
	end

	--右转角 东右下都无建筑
	if CityComponentType.isBuilding(view,hang,lie+1) == 0
		and CityComponentType.isBuilding(view,hang+1,lie) == 0
		and CityComponentType.isBuilding(view,hang+1,lie+1) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,200,0,"youzhuanjiao",coorX+1, coorY+1)
	end

	--上缺角 
	if CityComponentType.isBuilding(view,hang-1,lie) == 1 and CityComponentType.isBuilding(view,hang,lie+1) == 1
		and CityComponentType.isBuilding(view,hang-1,lie+1) == 0
		and CityComponentType.isBuilding(view,hang-2,lie+1) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,0,100,"shangquejiao",coorX-1, coorY+1)
	end

	--下缺角
	if CityComponentType.isBuilding(view,hang+1,lie) == 1 and CityComponentType.isBuilding(view,hang,lie-1) == 1
		and CityComponentType.isBuilding(view,hang+1,lie-1) == 0
		and CityComponentType.isBuilding(view,hang+2,lie-1) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,0,-100,"xiaquejiao",coorX+1, coorY-1)
	end 

	--左缺角
	if CityComponentType.isBuilding(view,hang-1,lie) == 1 and CityComponentType.isBuilding(view,hang,lie-1) == 1
		and CityComponentType.isBuilding(view,hang-1,lie-1) == 0
		and CityComponentType.isBuilding(view,hang-1,lie-2) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,-200,0,"zuoquejiao",coorX-1, coorY-1)
	end

	--右缺角
	if CityComponentType.isBuilding(view,hang+1,lie) == 1 and CityComponentType.isBuilding(view,hang,lie+1) == 1
		and CityComponentType.isBuilding(view,hang+1,lie+1) == 0 
		and CityComponentType.isBuilding(view,hang+2,lie+1) == 0 then
		addComponent(targetIndex,mainCityWid,sprite,200,0,"youquejiao",coorX+1, coorY+1)
	end

	--上直边 上无建筑
	if CityComponentType.isBuilding(view,hang-1,lie) == 0
		and (CityComponentType.isBuilding(view,hang-1,lie-1) == 0 or not CityComponentType.isBuilding(view,hang-1,lie-1))
		and (CityComponentType.isBuilding(view,hang-1,lie+1) == 0 or not CityComponentType.isBuilding(view,hang-1,lie+1)) then
		if lie == 5 then
			addComponent(targetIndex,mainCityWid,sprite,-100,50,"shangmen",coorX-1, coorY)
		else
			addComponent(targetIndex,mainCityWid,sprite,-100,50,"shang",coorX-1, coorY)
		end
	end

	--下直边 左右有建筑，下无建筑
	if CityComponentType.isBuilding(view,hang+1,lie) == 0
		and (CityComponentType.isBuilding(view,hang+1,lie-1) == 0 or not CityComponentType.isBuilding(view,hang+1,lie-1))
		and (CityComponentType.isBuilding(view,hang+1,lie+1) == 0 or not CityComponentType.isBuilding(view,hang+1,lie+1)) then
		if lie == 5 then
			addComponent(targetIndex,mainCityWid,sprite,100,-50,"xiamen",coorX+1, coorY)
		else
			addComponent(targetIndex,mainCityWid,sprite,100,-50,"xia",coorX+1, coorY)
		end
	end

	--左直边 左无建筑
	if CityComponentType.isBuilding(view,hang,lie-1) == 0
		and (CityComponentType.isBuilding(view,hang-1,lie-1) == 0 or not CityComponentType.isBuilding(view,hang-1,lie-1))
		and (CityComponentType.isBuilding(view,hang+1,lie-1) == 0 or not CityComponentType.isBuilding(view,hang+1,lie-1)) then
		if hang == 5 then
			addComponent(targetIndex,mainCityWid,sprite,-100,-50,"zuomen",coorX, coorY-1)
		else
			addComponent(targetIndex,mainCityWid,sprite,-100,-50,"zuo",coorX, coorY-1)
		end
	end

	--右直边 右无建筑
	if CityComponentType.isBuilding(view,hang,lie+1) == 0
		and (CityComponentType.isBuilding(view,hang-1,lie+1) == 0 or not CityComponentType.isBuilding(view,hang-1,lie+1))
		and (CityComponentType.isBuilding(view,hang+1,lie+1) == 0 or not CityComponentType.isBuilding(view,hang+1,lie+1)) then
		if hang == 5 then
			addComponent(targetIndex,mainCityWid,sprite,100,50,"youmen",coorX, coorY+1)
		else
			addComponent(targetIndex,mainCityWid,sprite,100,50,"you",coorX, coorY+1)
		end
	end
end

local function addRootLayer(tempX,tempY,layer,x,y )
	if not layer then return end
	local locationX, locationY = config.getMapSpritePos(layer:getPositionX(),layer:getPositionY(), x,y, tempX,tempY)
	local tag = mapData.getTagFunction(tempX,tempY, mapElement.RES)
	-- local tempBuilding = cc.Sprite:createWithTexture(mapData.getObject().resLayer:getTexture(), mapData.getEmptyRect())
	local tempBuilding = MapSpriteManage.popSprite(mapElement.RES, "nil", mapData.getObject().resLayer)
	-- mapData.getObject().resLayer:addChild(tempBuilding,tag,tag)
	MapNodeData.addResourceNode(tempBuilding,tag, "nil")
	tempBuilding:setAnchorPoint(cc.p(0.5,0))
	tempBuilding:setPosition(cc.p(locationX+100, locationY))
	tempBuilding:setTag(tag)
	-- tempBuilding:setZOrder(tag)
	mapData.getObject().resLayer:reorderChild(tempBuilding, tag)
	tempBuilding:setVisible(true)
	tempBuilding:setScale(getScaleTime())
	return tempBuilding
end

local function addColorlayer( root,color,coorX,coorY)
	for i=1,2 do
		-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/map/res.plist")
		local relationRes = cc.Sprite:createWithSpriteFrameName(color[i])
		relationRes:setAnchorPoint(cc.p(0.5,0))
		if i==1 then
			root:addChild(relationRes)--,mapData.getColorLayerZorder(),mapData.getColorLayerZorder())
		else
			root:addChild(relationRes,-1)
		end
		relationRes:setPosition(cc.p(root:getContentSize().width/2,0))
		relationRes:setScale(1/getScaleTime())
	end
end

local function removeAdditionWallNode(x,y )
	local tag = mapData.getTagFunction(x,y,mapElement.ADDITION)
	local node = MapNodeData.getAdditionWallNode()[tag]
	if node then
		-- node:removeFromParentAndCleanup(true)
		MapNodeData.removeAdditionWallNode(tag)
	end
end

--增加被山挡住的城墙或者搞活动的时候增加在山上的城
local function addAdditionWall(x,y,strRect, coorX, coorY)
	-- local coorX,coorY = userData.getLocation()
	local layer = mapData.getLoadedMapLayer(coorX,coorY)
	if not layer then return end
	local locationX, locationY = config.getMapSpritePos(layer:getPositionX(),layer:getPositionY(), coorX,coorY, x,y)
	local tag = mapData.getTagFunction(x,y,mapElement.ADDITION)
	removeAdditionWallNode(x,y )
	local wall = nil
	wall = MapSpriteManage.popSprite(mapElement.ADDITION, strRect, mapData.getObject().zhuzha)
	MapNodeData.addAdditionWallNode(wall,tag,strRect)
	wall:setAnchorPoint(cc.p(0.5,wall:getContentSize().width/4/wall:getContentSize().height))
	wall:setPosition(cc.p(locationX+100,locationY+50))
	-- wall:setScale(getScaleTime())
	wall:setVisible(true)
	wall:setTag(tag)
	mapData.getObject().zhuzha:reorderChild(wall, tag)
end

--增加归属颜色显示
local function addRelationLand( x,y )
	local layer = mapData.getLoadedMapLayer(x, y)
	if layer and not mapData.getCityType(x,y) then

		local data = mapData.getBuildingData()

		if data[x] and data[x][y] and data[x][y].cityType then
			local rect, rect1
			-- local color = " "
			if data[x][y].relation then
				if mapRelationColor[data[x][y].relation] then
					rect= mapRelationColor[data[x][y].relation][1]
					rect1 = mapRelationColor[data[x][y].relation][2]
					--盟友的同盟建筑不显示蓝色，显示成黄色
					if data[x][y].relation == mapAreaRelation.free_ally and data[x][y].cityType and data[x][y].cityType == cityTypeDefine.npc_cheng then
						rect= mapRelationColor[mapAreaRelation.free_underling][1]
						rect1 = mapRelationColor[mapAreaRelation.free_underling][2]
					end
				end

				-- if data[x][y].relation == mapAreaRelation.own_self then
				-- 	rect = "green_1.png"
				-- 	rect1 = "green_2.png"
				-- 	-- color = "green"
				-- elseif data[x][y].relation == mapAreaRelation.free_ally then
				-- 	rect = "blue_1.png"
				-- 	rect1 = "blue_2.png"
				-- 	-- color = "green"
				-- elseif data[x][y].relation == mapAreaRelation.attach_same_higher then
				-- 	rect = "purple_1.png"
				-- 	rect1 = "purple_2.png"
				-- 	-- color = "purple"
				-- elseif data[x][y].relation == mapAreaRelation.attach_higher_up then
				-- 	rect = "purple_1.png"
				-- 	rect1 = "purple_2.png"
				-- 	-- color = "purple"
				-- elseif data[x][y].relation == mapAreaRelation.free_underling then
				-- 	rect = "yellow_1.png"
				-- 	rect1 = "yellow_2.png"
				-- 	-- color = "yellow"
				-- elseif data[x][y].relation == mapAreaRelation.free_enemy or data[x][y].relation == mapAreaRelation.attach_enemy then
				-- 	rect = "red_1.png"
				-- 	rect1 = "red_2.png"
				-- 	-- color = "red"
				-- end
			end
			
			if data[x][y].relation then--== mapAreaRelation.attach_free then
			-- elseif data[x][y].relation then
				
				local tWid = {}
				tWid[1] = {x=x,y=y}
				--多坐标关联
				if Tb_cfg_world_join[x*10000+y] then
					for i,v in pairs(Tb_cfg_world_join) do
						if v.target_wid == x*10000+y and i~= x*10000+y then
							table.insert(tWid, {x=math.floor(v.wid/10000),y=v.wid%10000})
						end
					end
				end
				for i,v in pairs(tWid) do
					--是否上面有资源
					local tag = mapData.getTagFunction(v.x,v.y, mapElement.RES)
					local reslayer = MapNodeData.getResourceNode()[tag] --mapData.getObject().resLayer:getChildByTag(mapData.getTagFunction(v.x,v.y))
					if reslayer then
						reslayer[1]:removeAllChildrenWithCleanup(true)
						-- MapNodeData.removeResourceNode(tag)
					end
					-- addFlag(x,y)
					if data[x][y].relation ~= mapAreaRelation.all_free and data[x][y].relation ~= mapAreaRelation.attach_free then
						local parent = MapNodeData.getResourceNode()[tag] --mapData.getObject().resLayer:getChildByTag(tag)

						-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/map/res.plist")
						local ground = cc.Sprite:createWithSpriteFrameName(rect)
						local ground1= cc.Sprite:createWithSpriteFrameName(rect1)
						if parent then
							parent[1]:addChild(ground)
							ground:setAnchorPoint(cc.p(0.5,0))
							ground:setPosition(cc.p(parent[1]:getContentSize().width/2,0))
							ground:setScale(1/getScaleTime())
							ground:setVisible(isResVisible)

							parent[1]:addChild(ground1,-1)
							ground1:setAnchorPoint(cc.p(0.5,0))
							ground1:setPosition(cc.p(parent[1]:getContentSize().width/2,0))
							ground1:setScale(1/getScaleTime())
							ground1:setVisible(isResVisible)

						else
							local tempLayer = mapData.getLoadedMapLayer(v.x, v.y)
							if tempLayer then
								local sprite = addRootLayer(v.x, v.y,mapData.getLoadedMapLayer(v.x, v.y),v.x, v.y )

								sprite:addChild(ground)--, mapData.getColorLayerZorder(), mapData.getColorLayerZorder())
								ground:setAnchorPoint(cc.p(0.5,0))
								ground:setPosition(cc.p(sprite:getContentSize().width/2,0))
								ground:setScale(1/getScaleTime())
								ground:setVisible(isResVisible)

								sprite:addChild(ground1,-1)
								ground1:setAnchorPoint(cc.p(0.5,0))
								ground1:setPosition(cc.p(sprite:getContentSize().width/2,0))
								ground1:setScale(1/getScaleTime())
								ground1:setVisible(isResVisible)
							end
						end
					end
				end
			end
		end
	end
end

-- 强制刷新主城外观
local function setMainCityFade( )
	local x, y =math.floor(userData.getMainPos()/10000), userData.getMainPos()%10000
	mapData.removeAllBuilding(x,y  )
	mapController.addBuilding( x, y,mainCityFade,mainCityWallFade,true)
end

-- 设置是否刷新主城外观
local function setIsRefreshMainCity(flag )
	refreshMainCityFade = flag
end

local function changeResourcesFrame(x,y,parentNode )
	-- local layer = mapData.getLoadedMapLayer(x, y)
	-- if layer then

		local data = mapData.getBuildingData()

		if data[x] and data[x][y] and data[x][y].cityType then
			local rect, rect1
			if data[x][y].relation then
				if mapRelationColor[data[x][y].relation] then
					rect= mapRelationColor[data[x][y].relation][1]
					rect1 = mapRelationColor[data[x][y].relation][2]
					--盟友的同盟建筑不显示蓝色，显示成黄色
					if data[x][y].relation == mapAreaRelation.free_ally and data[x][y].cityType and data[x][y].cityType == cityTypeDefine.npc_cheng then
						rect= mapRelationColor[mapAreaRelation.free_underling][1]
						rect1 = mapRelationColor[mapAreaRelation.free_underling][2]
					end
				end
			end
			
			if data[x][y].relation then
				local tWid = {}
				tWid[1] = {x=x,y=y}
				--多坐标关联
				if Tb_cfg_world_join[x*10000+y] then
					for i,v in pairs(Tb_cfg_world_join) do
						if v.target_wid == x*10000+y and i~= x*10000+y then
							table.insert(tWid, {x=math.floor(v.wid/10000),y=v.wid%10000})
						end
					end
				end
				for i,v in pairs(tWid) do
					if data[x][y].relation ~= mapAreaRelation.all_free and data[x][y].relation ~= mapAreaRelation.attach_free then
						local ground = cc.Sprite:createWithSpriteFrameName(rect)
						local ground1= cc.Sprite:createWithSpriteFrameName(rect1)
						if parentNode then
							parentNode:addChild(ground)
							ground:setAnchorPoint(cc.p(0.5,0))
							ground:setPosition(cc.p(parentNode:getContentSize().width/2,0))
							ground:setScale(1/getScaleTime())
							ground:setVisible(isResVisible)

							parentNode:addChild(ground1,-1)
							ground1:setAnchorPoint(cc.p(0.5,0))
							ground1:setPosition(cc.p(parentNode:getContentSize().width/2,0))
							ground1:setScale(1/getScaleTime())
							ground1:setVisible(isResVisible)
						end
					end
				end
			end
		end
	-- end
end

--生成市中心建筑
local function addBuilding( x, y,view,wall,forceRefresh)
	local strView = view
	local strWall = wall
	local layer = mapData.getLoadedMapLayer(x, y)
	if layer and not mapData.getCityType(x,y) then
		-- local data = mapData.getBuildingData()
		if not mainCityFade and userData.getMainPos() == x*10000+y then
			mainCityFade = view
			mainCityWallFade = wall
		end

		local isGoon = true

		if not forceRefresh then
			if not refreshMainCityFade and userData.getMainPos() == x*10000+y and mainCityFade ~= view then
				strView = mainCityFade
				strWall = mainCityWallFade
			end
		end

		if userData.getMainPos() == x*10000+y then
			mainCityWallFade = wall
			mainCityFade = view
		end

		--额外的关卡城墙
		local worldCity = Tb_cfg_world_city[x*10000+y]

		if worldCity and (worldCity.param >=NPC_CITY_PARAM_GUAN_QIA[1] and worldCity.param <= NPC_CITY_PARAM_GUAN_QIA[2]) then
			if mapData.getCityType(x-1,y) then
				addAdditionWall(x-1,y,"component_77.png",x,y)
			end

			if mapData.getCityType(x+1,y) then
				addAdditionWall(x+1,y,"component_76.png",x,y)
			end

			if mapData.getCityType(x,y+1) then
				addAdditionWall(x,y+1,"component_75.png", x,y)
			end

			-- if mapData.getCityType(x,y-1) then
			-- 	addAdditionWall(x,y-1,"component_74.png",x,y)
			-- end
		end
		
		local posx,posy
		-- local indexTable = {13,1,2,3,4,5,6,7,8,9,10,11,12,14,15,16,17,18,19,20,21,22,23,24,25}

		local indexTable = {41}
		for i=1, 81 do
			if i~= 41 then
				table.insert(indexTable, i)
			end
		end
		-- local isDelete = {}
		-- local relationData = mapData.getRelationData()
		-- for i=x-1,x+1 do
		-- 	for j=y-1,y+1 do
		-- 		isDelete[i*10000+j] = 0
		-- 	end
		-- end

		local tempMapLayer = nil
		local buildingData = mapData.getBuildingData()
		local spriteFrame = nil
		local sprite = nil
		local tag = nil
		local sprite_temp = nil
		local rootNode = nil
		local loaderLayer = nil
		local function removeResWhenAddBuilding(i,j,isPlayerChengqu, isCity )
			-- tempMapLayer = MapNodeData.getResourceNode()[mapData.getTagFunction(i,j,mapElement.RES)] --mapData.getObject().resLayer:getChildByTag(mapData.getTagFunction(i,j))
			-- if tempMapLayer then
				if isPlayerChengqu then
					if buildingData[i] and buildingData[i][j] and buildingData[i][j].belong_city then--and rootNode then
						local m,n = math.floor(buildingData[i][j].belong_city/10000), buildingData[i][j].belong_city%10000
						tag = mapData.getTagFunction(i,j, mapElement.RES)
						MapNodeData.removeResourceNode( tag )
						sprite = MapSpriteManage.popSprite(mapElement.RES, "land_ground_"..((i-m+1)*3+(j-n+2))..".png", mapData.getObject().resLayer)
						sprite:setAnchorPoint(cc.p(0.5,0))
						rootNode = mapData.getLoadedMapLayer(x, y)
						local locationX, locationY = config.getMapSpritePos(rootNode:getPositionX(),rootNode:getPositionY(), x,y, i,j)
						sprite:setPosition(cc.p(locationX+100, locationY))
						sprite:setVisible(true)
						sprite:setTag(tag)
						mapData.getObject().resLayer:reorderChild(sprite, tag)
						sprite:setScale(getScaleTime())
						changeResourcesFrame(i,j,sprite )
						MapNodeData.addResourceNode(sprite, tag, "land_ground_"..((i-m+1)*3+(j-n+2))..".png")
					end
				elseif isCity then
					for k = i-1, i+1 do
						for v = j-1, j+1 do
							loaderLayer = mapData.getLoadedMapLayer(i, j)
							if loaderLayer then
								sprite_temp = MapNodeData.getResourceNode()[mapData.getTagFunction(k,v,mapElement.RES)]
								tag = mapData.getTagFunction(k,v, mapElement.RES)
								if sprite_temp then
									MapNodeData.removeResourceNode( tag )
								end
								sprite = MapSpriteManage.popSprite(mapElement.RES, "land_ground_"..((k-i+1)*3+(v-j+2))..".png", mapData.getObject().resLayer)
								sprite:setAnchorPoint(cc.p(0.5,0))
								local locationX, locationY = config.getMapSpritePos(loaderLayer:getPositionX(),loaderLayer:getPositionY(), i,j, k,v)
								sprite:setPosition(cc.p(locationX+100, locationY))
								sprite:setVisible(true)
								sprite:setTag(tag)
								mapData.getObject().resLayer:reorderChild(sprite, tag)
								MapNodeData.addResourceNode(sprite, tag, "land_ground_"..((k-i+1)*3+(v-j+2))..".png")
								sprite:setScale(getScaleTime())
								changeResourcesFrame(k,v,sprite )
							end
						end
					end
				else
					tag = mapData.getTagFunction(i,j, mapElement.RES)
					MapNodeData.removeResourceNode( tag )
					sprite = addRootLayer(i,j,mapData.getLoadedMapLayer(i, j),i,j)
					if sprite then
						changeResourcesFrame(i,j,sprite )
					end
				end
			-- end
		end

		-- local flag = false
		-- for i,v in pairs({7,8,9,12,14,17,18,19}) do
		-- 	if string.byte(view,v) ~=126 then
		-- 		flag = true
		-- 		break
		-- 	end
		-- end

		--当扩建过一次，把9格地的资源都删除
		-- if string.byte(view,13) ~= 126 and flag then
		local city_type = nil
		for i=x-1, x+1 do
			for j=y-1,y+1 do
				if landData.isNpcChengqu(i*10000+j) then
					removeResWhenAddBuilding(i,j, false,false)
				end

				if landData.isPlayerChengqu(i*10000+j) then
					removeResWhenAddBuilding(i,j, true,false)
				end

				city_type = landData.get_land_type(i*10000+j)
				if city_type then
					if city_type == cityTypeDefine.zhucheng or city_type == cityTypeDefine.fencheng then
						removeResWhenAddBuilding(i,j, false,true)
					elseif city_type == cityTypeDefine.npc_cheng or city_type == cityTypeDefine.npc_yaosai then
						removeResWhenAddBuilding(i,j, false,false)
					end
				end
			end
		end

		-- --当没有扩建过，只删除中间一格，并且把周围8格的资源画回去
		-- elseif string.byte(view,13) ~= 126 and not flag then
		-- 	removeResWhenAddBuilding(x,y)
		-- 	for i=x-1, x+1 do
		-- 		for j=y-1,y+1 do
		-- 			if i~= x or j~= y then
		-- 				changeResRect(i,j)
		-- 			end
		-- 		end
		-- 	end
		-- --当没有扩建，把9格的资源都画回去
		-- elseif string.byte(view,13) == 126 then
		-- 	for i=x-1, x+1 do
		-- 		for j=y-1,y+1 do
		-- 			changeResRect(i,j)
		-- 		end
		-- 	end
		-- end

		local hang,lie
		local viewStr
		local area = 9
		local centerX, centerY = area*x-4, area*y-4
		for v,i in ipairs(indexTable) do
			viewStr = string.byte(strView,i)
			if viewStr ~=126 then
				if i%area ~=0 then
					hang = math.floor(i/area)+1 - 5+centerX
					lie = i%area - 5 +centerY
				else
					hang = math.floor(i/area) - 5+centerX
					lie = centerY+4
				end

				posx,posy = 100+ getBuildingScaleTime()*100*((hang- centerX)+(lie - centerY)),
							50+ getBuildingScaleTime()*50*((lie - centerY)-(hang- centerX))
				-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/map/cityComponent.plist")

				-- local building = cc.Sprite:createWithSpriteFrameName("component_"..viewStr..".png")
				-- if building:getContentSize().width == 400 then
				-- 	building:setAnchorPoint(cc.p(0.5,100/building:getContentSize().height))
				-- elseif building:getContentSize().width == 600 then
				-- 	building:setAnchorPoint(cc.p(0.5,150/building:getContentSize().height))
				-- else
				-- 	building:setAnchorPoint(cc.p(0.5,50/building:getContentSize().height))
				-- end

				local building = nil
				local hang_index = math.ceil(i/9)
				local lie_index = i-(hang_index-1)*9
				local tempCoorX, tempCoorY = CityComponentType.centerCoorToCoor(x,y,hang_index,lie_index)
				local tag = nil
				-- 废墟，分城建造中，要塞建造中，新手引导的战乱图都把他放到另外一个层
				if viewStr == 96 or viewStr == 95 or viewStr == 94 --[[or viewStr == 104 or viewStr == 105 or viewStr == 106]] then
					tag = mapData.getTagFunction(hang,lie, mapElement.BETWEENNODE)
					-- mapData.getObject().zhuzha:addChild(building,tag,tag)
					building = MapSpriteManage.popSprite(mapElement.BETWEENNODE, "component_"..viewStr..".png", mapData.getObject().zhuzha)
					MapNodeData.addBetweenMountainNode(building,tag,"component_"..viewStr..".png")
					mapData.getObject().zhuzha:reorderChild(building, tag)
					mapController.setLevel5animationVisible(x*10000+ y,false)
				else
					mapController.setLevel5animationVisible(x*10000+ y,false)
					tag = mapData.getTagFunction(hang,lie, mapElement.BUILDING)
					building = MapSpriteManage.popSprite(mapElement.BUILDING, "component_"..viewStr..".png", mapData.getObject().building)
					-- mapData.getObject().building:addChild(building,tag,tag)
					MapNodeData.addBuildingNode(building,tag,"component_"..viewStr..".png")
					mapData.getObject().building:reorderChild(building, tag)
				end
				-- 建城的外观， 1,2级要塞的外观特殊处理
				if viewStr == 96 or viewStr == 119 or viewStr == 120 or viewStr == 121 then
					building:setAnchorPoint(cc.p(0.5,0.5))
				else
					building:setAnchorPoint(cc.p(0.5,building:getContentSize().width/4/building:getContentSize().height))
				end

				mapData.setCityComponentData(x,y,tag,tempCoorX*10000+tempCoorY,viewStr )
				building:setPosition(cc.p(layer:getPositionX()+posx,layer:getPositionY()+posy))
				building:setScale(getBuildingScaleTime())
				building:setVisible(true)
				building:setTag(tag)

				if viewStr == 99 or viewStr == 100 or viewStr == 101 or viewStr == 59 or viewStr == 60 or viewStr == 61 then
					mapData.setSmokeData(x*10000+y,tag,viewStr)
				end

				if strWall ~="~" then
					addSmallBuilding(i,building,hang, lie, strView, x*10000+y )
				end
			end
		end

		
		mapController.changeFlagColor( x,y)
		if mainBuildScene.isInCity() and mainBuildScene.getThisCityid() == x*10000+y then
			mapController.addSmokeAnimation()
		end
	end
end

local function selectGroundDisplay( coorX, coorY )
	local loadSprite = mapData.getLoadedMapLayer(coorX, coorY)
	local touchLayer = mapData.getTouchLayer()
	if not loadSprite or not touchLayer then return end
	local connect_state = mapData.getIsCanConnect(coorX, coorY)
	if not connect_state then
		touchLayer:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(ResDefineUtil.touchcolor))
	else
		touchLayer:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fixground.png"))
	end
	touchLayer:setPosition(cc.p(loadSprite:getPositionX(), loadSprite:getPositionY()))
	touchLayer:setVisible(true)
	local action = animation.sequence({CCFadeOut:create(1),CCFadeIn:create(1)})
	touchLayer:runAction(CCRepeatForever:create(action))
end

local function addTouchGround(coorX, coorY )
	local posx, posy = nil, nil
	local loadSprite = mapData.getLoadedMapLayer(coorX, coorY)
	local tempSprite = cc.Sprite:createWithSpriteFrameName("fixground.png")
	tempSprite:setAnchorPoint(cc.p(0,0))
	map.getInstance():addChild(tempSprite)
	posx, posy = config.getMapSpritePos(loadSprite:getPositionX(),loadSprite:getPositionY(), coorX, coorY, coorX, coorY  )
	tempSprite:setPosition(cc.p(posx, posy))
	local animationAction = animation.sequence({CCFadeOut:create(1),CCFadeIn:create(1)})
	tempSprite:runAction(CCRepeatForever:create(animationAction))
	blinkGround = tempSprite
end

local function removeTouchGround( )
	if blinkGround then
		blinkGround:removeFromParentAndCleanup(true)
		blinkGround = nil
	end
end


--读出地图的信息
local function touchGroundCallback(coorX, coorY, posX, posY ,ignoreLocate)
	local touchLayer = mapData.getTouchLayer()
	local connect_state = mapData.getIsCanConnect(coorX, coorY)
	if not connect_state then
		touchLayer:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(ResDefineUtil.touchcolor))
	else
		touchLayer:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("fixground.png"))
	end

	local loadSprite = mapData.getLoadedMapLayer(coorX, coorY)
	if loadSprite then
		for i, v in pairs(actionTable) do
			v.sprite:removeFromParentAndCleanup(true)
		end
		actionTable = {}
		if Tb_cfg_world_join[coorX*10000+coorY] then
			local posx, posy = nil, nil
			local tempSprite = nil
			for i, v in pairs(worldJoinList[Tb_cfg_world_join[coorX*10000+coorY].target_wid]) do
				if not connect_state then
					tempSprite = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.touchcolor)
				else
					tempSprite = cc.Sprite:createWithSpriteFrameName("fixground.png")
				end
				tempSprite:setAnchorPoint(cc.p(0,0))
				map.getInstance():addChild(tempSprite)
				posx, posy = config.getMapSpritePos(loadSprite:getPositionX(),loadSprite:getPositionY(), coorX, coorY, math.floor(v/10000), v%10000  )
				tempSprite:setPosition(cc.p(posx, posy))
				local animationAction = animation.sequence({CCFadeOut:create(1),CCFadeIn:create(1)})
				tempSprite:runAction(CCRepeatForever:create(animationAction))
				table.insert(actionTable, {sprite = tempSprite, wid = v })
			end
		end

		if mapData.isInArea(coorX, coorY) then
			touchLayer:stopAllActions()
			touchLayer:setVisible(false)
			miniMapManager.closeMiniMap()
			

			local function finally_end()
				if #actionTable > 0 then
					mapMessageUI.create(posX, posY, coorX, coorY, true)
				else
					touchLayer:setPosition(cc.p(loadSprite:getPositionX(), loadSprite:getPositionY()))
					touchLayer:setVisible(true)
					local action = animation.sequence({CCFadeOut:create(1),CCFadeIn:create(1)})
					touchLayer:runAction(CCRepeatForever:create(action))
					mapMessageUI.create(posX, posY, coorX, coorY)
				end
				if SmallMiniMap then 
			        SmallMiniMap.checkTouchState(posX,posY)
			    end
			end
			local function finally()
				local ownUserId = mapData.getLandOwnerInfo(coorX,coorY)
				local flag_clicked = CCUserDefault:sharedUserDefault():getBoolForKey("map_clicked_enemy_zhuchenng") 
				if (not userData.isInNewBieProtection()) and 
					(not flag_clicked) then
					local relation = mapData.getRelation(coorX,coorY)
					if relation and ( relation == mapAreaRelation.free_enemy or relation == mapAreaRelation.attach_enemy ) 
						and mapData.getCityTypeData(coorX,coorY) == cityTypeDefine.zhucheng then
						require("game/guide/shareGuide/picTipsManager")
	                	picTipsManager.create(15, finally_end)
	                	CCUserDefault:sharedUserDefault():setBoolForKey("map_clicked_enemy_zhuchenng",true)
	                else
	                	finally_end()
	                end
				else
					finally_end()
				end
			end
			if ignoreLocate or m_bIsLocatingCity then 
				finally()
			else
				if armyListDetail.detect_is_need_show_army(coorX,coorY) then
					mapController.locateCoordinate(coorX,coorY,function()
						armyListDetail.set_land_pos(coorX, coorY,false)
					end,100 * config.getgScale(),0)
				else
					finally()
				end
			end
		end
	end
end



--从城市列表点出城市信息
local function cityToTouchInfo()
	if not m_bIsLocatingCity then return end
	local function doCityToTouchInfo()
		if isJumpToCity then
			local coorX, coorY = math.floor(isJumpToCity/10000), isJumpToCity%10000
			if coorX >=1 and coorX <=1501 and coorY >= 1 and coorY <=1501 then
				local sprite = mapData.getLoadedMapLayer(coorX, coorY)
				if sprite then
					local _3dPoint = sprite:convertToWorldSpace(cc.p(100,50))
					local worldPointX, worldPointY = config.countWorldSpace(_3dPoint.x, _3dPoint.y, map.getAngel())
					touchGroundCallback(coorX, coorY, worldPointX, worldPointY,true )
				end
			end
			setJumpToCity(nil)
		end

		m_bIsLocatingCity = false
	end

	if isLocateToCity then 
		local coorX, coorY = math.floor(isLocateToCity/10000), isLocateToCity%10000
		mapController.locateCoordinate(coorX,coorY,function ( )
			if outScreenJumpCall then
				outScreenJumpCall()
				outScreenJumpCall = nil
			end
			doCityToTouchInfo()
		end,m_iLocateOffsetScreenX,m_iLocateOffsetScreenY)

		setLocateToCity(nil)
	else
		doCityToTouchInfo()
	end
end

--删除所有地图，用于坐标跳转
local function removeAllMap( )
	-- local buildingData = mapData.getBuildingData()
	BuildCityAnimation.removeAll()
	for i, v in pairs(actionTable) do
		v.sprite:removeFromParentAndCleanup(true)
	end
	actionTable = {}

	MapNodeData.removeAllSurfaceNode()
	MapNodeData.removeAllWaterEdgeNode()
	MapNodeData.removeAllSandEdgeNode()
	mapData.removeAllDefendFireData()
	MapNodeData.removeAllBuildingNode()
	MapNodeData.removeAllBetweenMountainNode()
	MapNodeData.removeAllMountainNode()
	MapNodeData.removeAllResourceNode()
	MapNodeData.removeAllYuanjunNode()
	MapNodeData.removeAllFarmingNode()
	MapNodeData.removeAllWaterNode()
	MapNodeData.removeAllGrassNode()
	MapNodeData.removeAllFogNode()
	MapNodeData.removeAllAdditionWallNode()

	mapData.deleteAllSmokeData()

	
	-- mapData.deleteAllBuildingData()
	mapData.deleteCityComponentData()
end

--删除所有建筑
local function removeAllBuilding()
	-- mapData.getObject().building:removeAllChildrenWithCleanup(true)
	-- mapData.getObject().additionWall:removeAllChildrenWithCleanup(true)
	MapNodeData.removeAllAdditionWallNode()
end

local function removeAllWaterEdge( )
	-- mapData.getObject().waterEdge:removeAllChildrenWithCleanup(true)
	MapNodeData.removeAllWaterEdgeNode()
	MapNodeData.removeAllSandEdgeNode()
end

local function removeQiulin(coorX, coorY )
	local tag = mapData.getTagFunction(coorX, coorY, mapElement.QIULING)
	local qiulin = MapNodeData.getQiuLingNode()[tag]--mapData.getObject().mountainLayer:getChildByTag(mapData.getTagFunction(coorX, coorY))
	if qiulin then
		-- mapData.getObject().grass:removeChild(qiulin, true)
		MapNodeData.removeQiuLingNode(tag)
		-- mapData.getObject().mountainLayer:removeChild(qiulin, true)
	end
end

--删除定点建筑
-- local function removeBuilding(coorX, coorY )
-- 	local buildingData = mapData.getBuildingData()
-- 	local tag = mapData.getTagFunction(2*coorX-1,2*coorY-1)
-- 	local building = MapNodeData.getBuildingNode()[tag] --mapData.getObject().building:getChildByTag(mapData.getTagFunction(2*coorX-1,2*coorY-1))
-- 	if building then
-- 		mapData.getObject().building:removeChild(building, true)
-- 		MapNodeData.removeBuildingNode(tag)
-- 		--todo 删除数据
-- 		if buildingData[coorX] and buildingData[coorX][coorY] then
-- 			mapData.deleteBuildingData(coorX, coorY)
-- 		end
-- 	end
-- end

--删除城市拼接部件
-- local function removeCityComponent( coorX, coorY)
-- 	local buildingData = mapData.getBuildingData()
-- 	local tag = mapData.getTagFunction(coorX,coorY)
-- 	local building = MapNodeData.getBuildingNode()[tag]--mapData.getObject().building:getChildByTag(mapData.getTagFunction(coorX,coorY))
-- 	if building then
-- 		mapData.getObject().building:removeChild(building, true)
-- 		MapNodeData.removeBuildingNode(tag)
-- 	end
-- end

--删除水的边缘
local function removeWaterEdge(coorX, coorY )
	-- local location = {{2*coorX-1, 2*coorY-1}, {2*coorX-1, 2*coorY}, {2*coorX, 2*coorY-1},
	-- 					{2*coorX, 2*coorY}}
	-- local waterBatch = nil
	-- for i,v in pairs(location) do
	-- 	waterBatch = mapData.getObject().waterEdge:getChildByTag(mapData.getTagFunction(v[1],v[2]))
	-- 	if waterBatch then
	-- 		mapData.getObject().waterEdge:removeChild(waterBatch, true)
	-- 	end
	-- end

	-- local count = mapData.getObject().waterEdge:getChildrenCount()
	local area = mapData.getMapArea()
	local row_up = 2*area.row_up - 1-1
	local row_down = 2*area.row_down +1
	local col_left = 2*area.col_left-1-1
	local col_right = 2*area.col_right+1

	local tag_row = nil
	local tag_col = nil
	local tag = nil
	local tagSprite = nil
	local temp_sprite = {}
	local tag_table = {}
	-- if count > 0 then
		-- local temp = mapData.getObject().waterEdge:getChildren()
	 --    for i=0 , count-1 do
	 --    	tagSprite = tolua.cast(temp:objectAtIndex(i),"CCSprite")
	 --        tag = tagSprite:getTag()
	 --        tag_row = math.floor(tag/10000)+1
	 --        tag_col = tag_row*10000-tag
	 --        if tag_row < row_up or tag_row > row_down or tag_col < col_left or tag_col > col_right then
	 --        	table.insert(temp_sprite,tagSprite)
	 --        	table.insert(tag_table, tag)
	 --        end
	 --    end
	-- end
	for i ,v in pairs(MapNodeData.getWaterEdgeNode()) do
		-- tag = i
		tag = mapData.getRealWid(i )
		tag_row = math.floor(tag/10000)+1
		tag_col = tag_row*10000-tag
		if tag_row < row_up or tag_row > row_down or tag_col < col_left or tag_col > col_right then
	       	-- table.insert(temp_sprite,v)
	       	table.insert(tag_table, i)
	    end
	end

	for i, v in ipairs(tag_table) do
		-- temp_sprite[i]:removeFromParentAndCleanup(true)
		MapNodeData.removeWaterEdgeNode(v)
	end

	temp_sprite = {}
	tag_table = {}

	for i ,v in pairs(MapNodeData.getSandEdgeNode()) do
		-- tag = i
		tag = mapData.getRealWid(i )
		tag_row = math.floor(tag/10000)+1
		tag_col = tag_row*10000-tag
		if tag_row < row_up or tag_row > row_down or tag_col < col_left or tag_col > col_right then
	       	-- table.insert(temp_sprite,v)
	       	table.insert(tag_table, i)
	    end
	end

	for i, v in ipairs(tag_table) do
		-- temp_sprite[i]:removeFromParentAndCleanup(true)
		MapNodeData.removeSandEdgeNode(v)
	end
end

--删除资源
local function removeRes(coorX, coorY )
	local tag = mapData.getTagFunction(coorX, coorY, mapElement.RES)
	local res = MapNodeData.getResourceNode()[tag] --mapData.getObject().resLayer:getChildByTag(mapData.getTagFunction(coorX, coorY))
	if res and res[1]:getChildrenCount() == 0 then
		-- mapData.getObject().resLayer:removeChild(res, true)
		MapNodeData.removeResourceNode(tag)
	end

	-- local level1Res = mapData.getObject().level1ResNode:getChildByTag(mapData.getTagFunction(coorX, coorY))
	-- if level1Res then
	-- 	mapData.getObject().level1ResNode:removeChild(level1Res, true)
	-- end
end

--删除山地的过渡
-- local function removeGrassTran( coorX, coorY )
-- 	local grass = mapData.getObject().grassTran:getChildByTag(mapData.getTagFunction(coorX, coorY))
-- 	if grass then
-- 		mapData.getObject().grassTran:removeChild(grass, true)
-- 	end
-- end

--删除网格
-- local function removeGrid( coorX, coorY )
-- 	local grass = mapData.getObject().gridNode:getChildByTag(mapData.getTagFunction(coorX, coorY))
-- 	if grass then
-- 		mapData.getObject().gridNode:removeChild(grass, true)
-- 	end
-- end

--删除多余的地图
local function removeAdditionMap(coorX, coorY)
	local loadSprite, spr_type = mapData.getLoadedMapLayer(coorX, coorY)
	if loadSprite then
		local flag  = false
		for i, v in pairs (actionTable) do
			if coorX*10000+coorY == v.wid then
				flag = true
				break
			end
		end
		if flag then
			for i, v in pairs(actionTable) do
				v.sprite:removeFromParentAndCleanup(true)
			end
			actionTable = {}
		end

		local tag = mapData.getTagFunction(coorX,coorY, mapElement.WATER)
		local water = MapNodeData.getWaterNode()[tag]--mapData.getObject().batchNode:getChildByTag(mapData.getTagFunction(coorX,coorY))
		if water then
			-- water:removeFromParentAndCleanup(true)
			MapNodeData.removeWaterNode(tag)
		end


		--这个应该是基本的格子，现在是战争迷雾的显示格子
		tag = mapData.getTagFunction(coorX,coorY, mapElement.FOG)
		local surface = MapNodeData.getSurfaceNode()[tag]--mapData.getObject().batchNode:getChildByTag(mapData.getTagFunction(coorX,coorY))
		if surface then
			-- MapSpriteManage.pushSprite(mapElement.FOG, surface[2], surface[1] )
			-- surface[1]:removeFromParentAndCleanup(true)
			MapNodeData.removeSurfaceNode(tag)
		end
		-- mapData.deleteLoadedMapData(coorX, coorY)
		--删除山脉
		tag = mapData.getTagFunction(coorX,coorY, mapElement.MOUNTAIN)
		local city = MapNodeData.getMountainNode()[tag] --mapData.getObject().city:getChildByTag(mapData.getTagFunction(coorX,coorY))
		if city then
			-- mapData.getObject().zhuzha:removeChild(city,true)
			MapNodeData.removeMountainNode(tag)
		end
		--npc城
		-- local capital = mapData.getObject().capital:getChildByTag(mapData.getTagFunction(coorX,coorY))
		-- if capital then
		-- 	mapData.getObject().capital:removeChild(capital,true)
		-- end
		-- removeCoverLayer(coorX, coorY)
		-- removeWaterEdge(coorX, coorY)
		removeRes(coorX, coorY)
		removeQiulin(coorX, coorY)
		-- removeGrassTran(coorX, coorY)
		-- removeGrid(coorX,coorY)
	end
end

--增加水的边缘
--index 1,2,3,4 分别表示上下左右四个小格子
--水的边缘 pngtype 1 沙地边缘 pngtype 2
local function addWaterEdge(pngtype,coorX, coorY, posX, posY,localX, localY,index)
	local object = mapData.getObject()
	local count = 0
	local isFix = nil
	if pngtype == 1 then
		isFix = terrain.isSmallWater
	else
		isFix = terrain.isSmallSand
	end

	for i=coorX-1, coorX+1 do
		for j = coorY-1, coorY + 1 do
			if not isFix(i, j) then
				count = count + 1
			end
		end
	end

	local function addEdge(x, y, imageIndex)
		local posx, posy = nil, nil
		local tag = nil
		if pngtype == 1 then
			tag = mapData.getTagFunction(x, y, mapElement.WATEREAGE)
			if MapNodeData.getWaterEdgeNode()[tag] then return end
		else
			tag = mapData.getTagFunction(x, y, mapElement.SANDEAGE)
			if MapNodeData.getSandEdgeNode()[tag] then return end
		end
		--上下夹角
		if imageIndex == 421 then
			posx, posy = localX+100, localY
		--左右夹角
		elseif imageIndex == 431 then
			posx, posy = localX, localY + 50
		else
			posx, posy =config.getMapSpritePos(localX+posX,localY+posY, coorX,coorY, x,y, 100, 50  )
		end
		-- if object.waterEdge:getChildByTag(mapData.getTagFunction(x, y)) then return end
		
		local image = nil
		if pngtype == 1 then
			image =terrain.returnCCRectAndPos(imageIndex)
		else
			image =terrain.returnSandCCRectAndPos(imageIndex)
		end
		if not image then return end
		local waterEdge = nil
		-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/map/smallwater.plist")
		-- local waterEdge= cc.Sprite:createWithSpriteFrameName(image)
		-- object.grass:addChild(waterEdge,tag, tag)
		if pngtype == 1 then
			waterEdge = MapSpriteManage.popSprite(mapElement.WATEREAGE, image, object.grass)
			MapNodeData.addWaterEdgeNode(waterEdge,tag,image)
		else
			waterEdge = MapSpriteManage.popSprite(mapElement.SANDEAGE, image, object.grass)
			MapNodeData.addSandEdgeNode(waterEdge,tag,image)
		end
		waterEdge:setAnchorPoint(cc.p(0.5, 0.5))
		waterEdge:setPosition(cc.p(posx,posy))
		waterEdge:setTag(tag)
		-- waterEdge:setZOrder(tag)
		object.grass:reorderChild(waterEdge,tag)
		waterEdge:setVisible(true)
	end

	local quejiao = {
					{{coorX-1, coorY},{coorX, coorY},{coorX, coorY+1}},
					{{coorX, coorY-1},{coorX, coorY},{coorX+1, coorY}},
					{{coorX-1, coorY},{coorX, coorY},{coorX, coorY-1}},
					{{coorX, coorY+1},{coorX, coorY},{coorX+1, coorY}},
				}


	local function zhibianIndex( _index, k )
		return (k==1 and 3*100+_index*10+1) or 3*100+_index*10+2
	end

	--直边
	if count == 3 then
		--左直边
		if not isFix(coorX-1, coorY) then
			addEdge(coorX,coorY, zhibianIndex( 3,(coorX+coorY)%2+1))
		--上直边
		elseif not isFix(coorX, coorY+1) then
			addEdge(coorX,coorY, zhibianIndex( 1,(coorX+coorY)%2+1))
		--右直边
		elseif not isFix(coorX+1, coorY) then
			addEdge(coorX,coorY, zhibianIndex( 4,(coorX+coorY)%2+1))
		--下直边
		elseif not isFix(coorX, coorY-1) then
			addEdge(coorX,coorY, zhibianIndex( 2,(coorX+coorY)%2+1))
		end
	--缺角
	elseif count == 1 then
		for i = 1 ,3 do
			addEdge(quejiao[index][i][1], quejiao[index][i][2], count*100+index*10+i)
		end
	--转角
	elseif count == 5 then
		addEdge(coorX,coorY, count*100+index*10+2)
	--上下夹角
	elseif count == 4 and index == 2 then
		addEdge(coorX,coorY, count*100+index*10+1)
	--左右夹角
	elseif count == 4 and index == 3 then
		addEdge(coorX,coorY, count*100+index*10+1)
	end
end

--增加山脉
local function addMountain( posX, posY, coorX, coorY, i, j)
	local w = 200
	local h = 100
	local rect
	local object = mapData.getObject()
	local v = mapData.getCityType(i,j)
	local cityChild
	local hillSprite

	if v and (v =="1" or v =="2" or v =="3") then
		if v =="2" then
			if i%2 == 0 then
				rect = "hill5.png"
			else
				rect = "hill2.png"
			end
		elseif v== "3" then
			if i%2 == 0 then
				rect = "hill3.png"
			else
				rect = "hill4.png"
			end
		else
			rect = "hill1.png"
		end

		-- 是否是过渡的1x1山,下边
		local oneSquareDown = false
		-- 是否是过渡的1x1山,右边
		local oneSquareRight = false

		if v == "1" then
			local down = mapData.getCityType(i+1, j)
			local right = mapData.getCityType(i, j+1)
			if down and down ~= "1" then
				oneSquareDown = true
			end

			if right and right ~= "1" then
				oneSquareRight = true
			end
		end

		if v == "2" or v== "3" or (not oneSquareDown and not oneSquareRight) then--"b4" or v== "B5" or v== "9" or v=="b4#" or v=="B5#" then
			local zorder = nil

			local tag = mapData.getTagFunction(i,j,mapElement.MOUNTAIN)
			if MapNodeData.getMountainNode()[tag] then return end
			zorder = mapData.getTagFunction(i,j,mapElement.MOUNTAIN)
			hillSprite = MapSpriteManage.popSprite(mapElement.MOUNTAIN, rect, object.zhuzha)
			local sprite = mapData.getLoadedMapLayer(i,j)
			if sprite then
				MapNodeData.addMountainNode(hillSprite, tag, rect)
				hillSprite:setAnchorPoint(cc.p(0.5, hillSprite:getContentSize().width/4/hillSprite:getContentSize().height))
					
				if v== "2" then
					hillSprite:setPosition(cc.p(sprite:getPositionX()+200, sprite:getPositionY()+50))
				elseif v== "3" then
					hillSprite:setPosition(cc.p(sprite:getPositionX()+300, sprite:getPositionY()+50))
				elseif v == "1" then
					hillSprite:setAnchorPoint(cc.p(0, 0))
					hillSprite:setPosition(cc.p(sprite:getPositionX(), sprite:getPositionY()))
				end
				hillSprite:setTag(tag)
				object.zhuzha:reorderChild(hillSprite, zorder)
				hillSprite:setVisible(true)
			end
		end

		local otherSprite = nil
		local temp_x, temp_y = nil, nil
		if oneSquareDown then
			local tag = mapData.getTagFunction(i,j,mapElement.MOUNTAIN)
			otherSprite = MapNodeData.getMountainNode()[tag]--object.city:getChildByTag(tag)

			temp_x, temp_y = config.getMapSpritePos(posX+ 50,-25+posY, coorX,coorY, i,j)
			if not otherSprite then
				hillSprite = MapSpriteManage.popSprite(mapElement.MOUNTAIN, "hill1.png", object.zhuzha)
				MapNodeData.addMountainNode(hillSprite, tag, "hill1.png")

				hillSprite:setAnchorPoint(cc.p(0, 0))
				hillSprite:setPosition(cc.p(temp_x, temp_y))
				hillSprite:setVisible(true)
				object.zhuzha:reorderChild(hillSprite, tag)
				hillSprite:setTag(tag)
			else
				-- hillSprite = cc.Sprite:createWithSpriteFrameName("hill1.png")
				-- otherSprite[1]:addChild(hillSprite, tag, tag)
				-- hillSprite:setAnchorPoint(cc.p(0,0))
				-- hillSprite:setPosition(cc.p(0, -100))
			end
		end

		if oneSquareRight then
			local tag = mapData.getTagFunction(i,j,mapElement.MOUNTAIN)
			otherSprite = MapNodeData.getMountainNode()[tag] --object.city:getChildByTag(mapData.getTagFunction(i,j))
			if not otherSprite then
				hillSprite = MapSpriteManage.popSprite(mapElement.MOUNTAIN, "hill1.png", object.zhuzha)
				MapNodeData.addMountainNode(hillSprite, tag, "hill1.png")

				temp_x, temp_y = config.getMapSpritePos(posX+ 50,25+posY, coorX,coorY, i,j)
				hillSprite:setPosition(cc.p(temp_x, temp_y))
				hillSprite:setAnchorPoint(cc.p(0, 0))
				hillSprite:setVisible(true)
				object.zhuzha:reorderChild(hillSprite, tag)
				hillSprite:setTag(tag)
			else
				-- hillSprite = cc.Sprite:createWithSpriteFrameName("hill1.png")
				-- otherSprite[1]:addChild(hillSprite, tag, tag)
				-- hillSprite:setAnchorPoint(cc.p(0,0))
				-- hillSprite:setPosition(cc.p(0,100))
			end
		end
	end
end

local function setCityShadow( flag)
	local winSize = config.getWinSize()
	if flag then
		if not cityShadow then
			cityShadow = cc.Sprite:createWithSpriteFrameName("chengneibeijzhezhao_01.png")
			-- cityShadow = cc.Sprite:create("gameResources/blackshadow.png")
			cc.Director:getInstance():getRunningScene():addChild(cityShadow,CITY_SHADOW)
			cityShadow:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
			cityShadow:setScaleX(winSize.width/cityShadow:getContentSize().width --[[+ winSize.width*0.01/cityShadow:getContentSize().width]])
			cityShadow:setScaleY(winSize.height/cityShadow:getContentSize().height--[[+ winSize.height*0.01/cityShadow:getContentSize().height]])
			-- cityShadow:getTexture():setAliasTexParameters()
		end
		cityShadow:runAction(CCFadeIn:create(0.5))
	else
		if cityShadow then
			cityShadow:runAction(animation.sequence({CCFadeOut:create(0.5),cc.CallFunc:create(function ( )
				cityShadow:removeFromParentAndCleanup(true)
				cityShadow = nil
			end)}))
		end
	end
	
end

local function setResVisible( flag )
	if not userData.isNewBieTaskFinished() then
		return
	end

	local visibletrue = function ( node )
		isResVisible = flag
		node:setVisible(true)
		node:runAction(CCFadeIn:create(0.5))
	end

	local visiblefalse = function (node  )
		node:runAction(animation.sequence({CCFadeOut:create(0.5),cc.CallFunc:create(function ( )
					node:setVisible(false)
				end)}))
	end

	local temp = nil
	local temp_sprite = nil
	for i, v in pairs(MapNodeData.getResourceNode()) do
		local temp = v[1]:getChildren()
        for k=0 , v[1]:getChildrenCount()-1 do
            temp_sprite = tolua.cast(temp:objectAtIndex(k),"CCSprite")--setVisible(flag)
			if flag then
				visibletrue(temp_sprite)
			else
				isResVisible = flag
				visiblefalse(temp_sprite)
				-- temp_sprite:runAction(animation.sequence({CCFadeOut:create(0.5),cc.CallFunc:create(function ( )
				-- 	temp_sprite:setVisible(false)
				-- end)}))
			end
        end
	end
end

local function setLevel5animationVisible(wid, visible )
	local isanimationVisible = function (wid )
		if MapNodeData.getFarmingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.FARMING)] 
			or MapNodeData.getTrainingNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.TRAINING)]
			or MapNodeData.getYuanjunNode()[mapData.getTagFunction(math.floor(wid/10000), wid%10000, mapElement.YUANJUN)] then
			return false
		end
		return true
	end

	local data = MapNodeData.getLevel5AnimationNode(wid)
	if data then
		for i, v in pairs(data) do
			-- if not v:isVisible() then
				if visible then
					if WarFogData.getFogDataByWid(wid) and isanimationVisible(wid) then
						v[1]:setVisible(visible)
						-- v:runAction(CCFadeIn:create(0.3))
					end
				else
					v[1]:setVisible(visible)
				end
			-- end
		end
	else
		if visible and WarFogData.getFogDataByWid(wid) and isanimationVisible(wid) and not landData.isNpcChengqu(wid)
		and not landData.isPlayerChengqu(wid) then
			mapController.setLevel5Animation(math.floor(wid/10000), wid%10000 )
		end
	end
end

local function playLevel5AnimationByHandler()
	local tLevel5AnimationNode = MapNodeData.getAllLevel5AnimationNode()
	for i, v in pairs(tLevel5AnimationNode) do
		for m, n in pairs(v) do
			-- n[1]:removeFromParentAndCleanup(true)
			n[1]:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(n[4]..n[3]..".png"))
			n[3] = n[3] + 1
			if n[3] > n[2] then
				n[3] = 1
			end
		end
	end

	-- local count = index
	-- return animation.sequence({cc.DelayTime:create(time), cc.CallFunc:create(function ( )
	-- 	sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(name..count..".png"))		
	-- 	count = count + 1
	-- 	if count > totalCount then
	-- 		count =1
	-- 	end
	-- end)})
end

local function addlevel5animation(totalCount, total_index, name, anchorPoint, pos, time,wid  )
	-- local totalCount = CityComponentType.getLandSmokeCount()
	-- local total_index = math.random(1,totalCount)
	local item = cc.Sprite:createWithSpriteFrameName(name..total_index..".png")
	item:setAnchorPoint(anchorPoint)
	item:setScale(getScaleTime())
	mapData.getObject().animationNode:addChild(item)
	item:setPosition(pos)
	-- item:runAction(CCRepeatForever:create(playLandLevel5Animation(item, name, totalCount, total_index,time )))
	MapNodeData.addLevel5AnimationNode(wid,item, totalCount,total_index,name )
	-- 先把动画隐藏，等确定是视野可见才显示
	item:setVisible(false)
	mapController.setLevel5animationVisible(wid, true )
	if not level5animationHandler then
		level5animationHandler = scheduler.create(playLevel5AnimationByHandler, 0.15)
	end
end

local function setLevel5Animation(coorX, coorY )
	local totalCount = nil
	local total_index = nil
	local wid = coorX*10000+coorY
	local res = resourceData.resourceLevel(coorX, coorY)
	if not res then
		return
	end

	local sprite = mapData.getLoadedMapLayer(coorX,coorY)
	if not sprite then
		return
	end

	local posX,posY = sprite:getPositionX(), sprite:getPositionY()
	if res == 53 then
		totalCount = CityComponentType.getLandSmokeCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "land_smoke_", ccp(0.3,0), ccp(posX+110, posY+75), 0.1,wid )
				
		totalCount = CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "land_fire_", ccp(0.5,0), ccp(posX+100, posY), 0.1,wid  )

		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "little_flag_", ccp(0,0), ccp(posX+110, posY+65), 0.2,wid  )
	end

	if res == 54 then
		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "little_flag_", ccp(0,0), ccp(posX+105, posY+75), 0.2,wid )

		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "little_flag_", ccp(0,0), ccp(posX+145, posY+47), 0.2,wid  )

		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "waterwheel_", ccp(0.5,0), ccp(posX+100, posY), 0.15,wid  )
	end

	if res == 51 then
		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "little_flag_", ccp(0,0), ccp(posX+82, posY+63), 0.2,wid )

		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "small_flag_", ccp(0,0), ccp(posX+55, posY+33), 0.2,wid )

		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "small_flag_", ccp(0,0), ccp(posX+105, posY+50), 0.2,wid  )
	end

	if res == 52 then
		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "little_flag_", ccp(0,0), ccp(posX+93, posY+65), 0.2,wid  )

		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "small_flag_", ccp(0,0), ccp(posX+77, posY+80), 0.2,wid )

		totalCount = 5--CityComponentType.getLandFireCount()
		total_index = math.random(1,totalCount)
		addlevel5animation(totalCount, total_index, "small_flag_", ccp(0,0), ccp(posX+117, posY+70), 0.2,wid )
	end
end

--增加资源
local function addRes( posX, posY, i, j )
	local object = mapData.getObject()
	-- local relation = mapData.getRelation(i,j)
	local w = 200
	local h = 100
	local rect
	local res = resourceData.resourceLevel(i,j)
	if not res then return end

	-- if object.resLayer:getChildByTag(mapData.getTagFunction(i,j)) then return end
	if MapNodeData.getResourceNode()[mapData.getTagFunction(i,j, mapElement.RES)] then return end
	if not res or (not terrain.returnTerrain(i,j)) or terrain.isWaterTerrain(i,j)
		or mapData.getCityType(i,j) or Tb_cfg_world_city[i*10000+j] then return end

	if res == 12 or res == 36 then
		
		return 
	end

	local sprite
	if res ==11 then
		
	else
		

		-- local qiulin = terrain.returnTerrain(i,j)
		rect = "land_"..res

		
		-- local str = nil
		-- if qiulin then
		-- 	str = string.sub(qiulin,1,1)
		-- end

		-- if (str == "a" or str == "A" or str == "2") and resArray["land_"..res.."_h"] then
		-- 	rect = rect.."_h"
		-- end
		-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/map/res.plist")
		local tag = mapData.getTagFunction(i,j,mapElement.RES)
		-- sprite = cc.Sprite:createWithSpriteFrameName(rect..".png")
		sprite = MapSpriteManage.popSprite(mapElement.RES, rect..".png", object.resLayer)
		-- object.resLayer:addChild(sprite,tag, tag )
		MapNodeData.addResourceNode(sprite,tag, rect..".png")
		sprite:setAnchorPoint(cc.p(0.5,0))
		sprite:setPosition(cc.p(posX+100, posY))
		sprite:setVisible(true)
		sprite:setTag(tag)
		-- sprite:setZOrder(tag)
		object.resLayer:reorderChild(sprite, tag)
		sprite:setScale(getScaleTime())

		if res >= 50 and res < 60 then
			setLevel5Animation(i,j )
		end

		if res <61 or res >84 then return end
		-- addClippingRes(i,j)
	end
end

local function addQiuLin(x,y,i,j )
	-- CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("gameResources/map/mountain.plist")
	local object = mapData.getObject()
	local rect
	-- if object.grass:getChildByTag(mapData.getTagFunction(i,j)) then return end
	local tag= mapData.getTagFunction(i,j, mapElement.QIULING)
	if MapNodeData.getQiuLingNode()[tag] then return end
	local qiulin = terrain.returnTerrain(i,j)
	-- if (qiulin =="a4" or qiulin =="a41") and i*10000+j ==
	if qiulin =="2" then
		if i%2 == 0 then
			rect = "qiuling2.png"
		else
			rect = "qiuling5.png"
		end
		-- local sprite = cc.Sprite:createWithSpriteFrameName(rect)
		-- object.grass:addChild(sprite,tag, tag )
		local sprite = MapSpriteManage.popSprite(mapElement.QIULING, rect, object.grass)
		sprite:setAnchorPoint(cc.p(0.5,0.5))
			
		sprite:setPosition(cc.p(x, y+50))
		sprite:setVisible(true)
		sprite:setTag(tag)
		-- sprite:setZOrder(tag)
		object.grass:reorderChild(sprite, tag)
		MapNodeData.addQiuLingNode(sprite,tag, rect)
		-- sprite:setScale(getScaleTime())
	elseif qiulin =="3" then
		if i%3 == 0 then
			rect = "qiuling5.png"
		elseif i%3 == 1 then
			rect = "qiuling2.png"
		else
			rect = "qiuling1.png"
		end
		-- local sprite = cc.Sprite:createWithSpriteFrameName(rect)
		-- object.grass:addChild(sprite,tag, tag )
		local sprite = MapSpriteManage.popSprite(mapElement.QIULING, rect, object.grass)
		sprite:setAnchorPoint(cc.p(0.5,0.5))
			
		sprite:setPosition(cc.p(x+100, y+50))
		sprite:setVisible(true)
		sprite:setTag(tag)
		-- sprite:setZOrder(tag)
		object.grass:reorderChild(sprite, tag)
		MapNodeData.addQiuLingNode(sprite,tag, rect)
		-- sprite:setScale(getScaleTime())
	elseif qiulin =="2" then
		-- rect = mountainRect2x2_2
		-- local sprite = cc.Sprite:createWithSpriteFrameName("qiuling1.png")
		local sprite = MapSpriteManage.popSprite(mapElement.QIULING, "qiuling1.png", object.grass)
		-- object.grass:addChild(sprite,tag, tag )
		sprite:setAnchorPoint(cc.p(0.5,0.5))
			
		sprite:setPosition(cc.p(x+100, y+50))
		sprite:setVisible(true)
		sprite:setTag(tag)
		-- sprite:setZOrder(tag)
		object.grass:reorderChild(sprite, tag)
		MapNodeData.addQiuLingNode(sprite,tag,"qiuling1.png")
	end
end



local function addTopObject ( posX, posY, coorX, coorY, i, j)
	if MapNodeData.getSurfaceNode()[mapData.getTagFunction(i,j, mapElement.FOG)] then return end
	if not terrain.isInMap(i,j) then return end
	local arrFogData = WarFogData.getAllFogData()
	local rect = "grass.png"

	local object = mapData.getObject()
	local locationX, locationY = config.getMapSpritePos(posX,posY, coorX,coorY, i,j)
	local sprite = MapSpriteManage.popSprite( mapElement.FOG, "grass.png", object.zhuzha)
	-- local sprite = cc.Sprite:createWithSpriteFrameName(rect)
	-- object.zhuzha:addChild(sprite,mapData.getTagFunction(i,j, mapElement.FOG), mapData.getTagFunction(i,j, mapElement.FOG) )
	sprite:setTag(mapData.getTagFunction(i,j, mapElement.FOG))
	-- sprite:setZOrder(mapData.getTagFunction(i,j, mapElement.FOG))
	object.zhuzha:reorderChild(sprite, mapData.getTagFunction(i,j, mapElement.FOG))
	MapNodeData.addSurfaceNode(sprite,mapData.getTagFunction(i,j, mapElement.FOG), "grass.png")
	if arrFogData[i*10000+j] then
		sprite:setVisible(false)
	else
		sprite:setVisible(true)
	end
	sprite:setAnchorPoint(cc.p(0,0))
	sprite:setPosition(cc.p(locationX, locationY))
	addMountain(posX, posY, coorX, coorY, i, j)
end


--加载额外额地图 coorX,coorY 中心点坐标，i,j 需要加载的坐标
local function additionMap(posX, posY, coorX, coorY, i, j )
	if i < 1 or i > size or j < 1 or j > size then return end
	local w = 200
	local h = 100
	local rect
	local object = mapData.getObject()
	if not terrain.isInMap(i,j) then return end
	-- local arrFogData = WarFogData.getAllFogData()
	local locationX, locationY = config.getMapSpritePos(posX,posY, coorX,coorY, i,j) --posX+ ((i- coorX)+(j - coorY))*getBuildingScaleTime()*w,
	-- if terrain.returnTerrain(i,j) =="1" or terrain.returnTerrain(i,j) =="a41" or 
	-- 	 terrain.returnTerrain(i,j) =="a11" or terrain.returnTerrain(i,j) =="a21" or 
	-- 	 terrain.returnTerrain(i,j) =="a31" then
	if terrain.returnTerrain(i,j) =="1" then
		rect = "water.png"
		-- if not object.water:getChildByTag(mapData.getTagFunction(i,j)) then
		local tag = mapData.getTagFunction(i,j, mapElement.WATER)
		if not MapNodeData.getWaterNode()[tag] then
			-- local pWaterSprite = cc.Sprite:createWithSpriteFrameName(rect)
			-- object.grass:addChild(pWaterSprite,tag, tag )
			local pWaterSprite = MapSpriteManage.popSprite(mapElement.WATER, rect, object.grass)
			MapNodeData.addWaterNode(pWaterSprite,tag,rect)
			pWaterSprite:setAnchorPoint(cc.p(0,0))
			pWaterSprite:setPosition(cc.p(locationX, locationY))
			pWaterSprite:setVisible(true)
			pWaterSprite:setTag(tag)
			-- pWaterSprite:setZOrder(tag)
			object.grass:reorderChild(pWaterSprite,tag)
		end
	end


	--沙地现在和水的边缘放在同一层
	if resourceData.resourceLevel(i,j) == 11 then
		-- if not object.water:getChildByTag(mapData.getTagFunction(i,j)) then
		local tag = mapData.getTagFunction(i,j,mapElement.WATER)
		if not MapNodeData.getWaterNode()[tag] then
			-- local pWaterSprite = cc.Sprite:createWithSpriteFrameName("sand.png")
			-- object.grass:addChild(pWaterSprite,tag, tag )
			local pWaterSprite = MapSpriteManage.popSprite(mapElement.WATER, "sand.png", object.grass)
			MapNodeData.addWaterNode(pWaterSprite,tag,"sand.png")
			pWaterSprite:setAnchorPoint(cc.p(0,0))
			pWaterSprite:setPosition(cc.p(locationX, locationY))
			pWaterSprite:setVisible(true)
			pWaterSprite:setTag(tag)
			-- pWaterSprite:setZOrder(tag)
			object.grass:reorderChild(pWaterSprite,tag)
		end
		addWaterEdge(2,2*i-1, 2*j-1, 50, 50,locationX, locationY, 3)
		addWaterEdge(2,2*i-1, 2*j, 100, 75,locationX, locationY,1)
		addWaterEdge(2,2*i, 2*j-1, 100, 25,locationX, locationY,2)
		addWaterEdge(2,2*i, 2*j, 150, 50,locationX, locationY,4)
	end

	if terrain.isWaterTerrain(i,j) then
		addWaterEdge(1,2*i-1, 2*j-1, 50, 50,locationX, locationY, 3)
		addWaterEdge(1,2*i-1, 2*j, 100, 75,locationX, locationY,1)
		addWaterEdge(1,2*i, 2*j-1, 100, 25,locationX, locationY,2)
		addWaterEdge(1,2*i, 2*j, 150, 50,locationX, locationY,4)
	end

	-- addRes(locationX, locationY, i, j)
	addQiuLin(locationX, locationY,i,j)
	-- addMountain(posX, posY, coorX, coorY, i, j)


	-- local npcCity = Tb_cfg_world_city[i*10000+j]
	-- --移动的时候增加npc城
	-- if npcCity and (not mapData.getCityComponentData(i,j)) then
	-- 	addBuilding(i,j,CityComponentType.getMainCityView(i,j),CityComponentType.getWallLevelData(i,j))
	-- end
	-- addGrid(locationX, locationY, i, j)
end

local function removeSmoke( )
	if map.getSmokeLayer() then
		map.getSmokeLayer():removeAllChildrenWithCleanup(true)
		config.removeSmokeAnimationFile()
	end
end

local function removeSmokeByTime( )
	if map.getSmokeLayer() then
		-- local count = map.getSmokeLayer():getChildrenCount()
		-- map.getSmokeLayer():runAction(animation.sequence({cc.CallFunc:create(function ( )
		-- 	if count > 0 then
		-- 		for i=0, count-1 do
		-- 		    local tempLayout = map.getSmokeLayer():getChildren():objectAtIndex(i)
		-- 		    if tempLayout then
		-- 		    	tempLayout:runAction(CCFadeOut:create(1))
		-- 		    end
		-- 		end
		-- 	end
		-- end),cc.DelayTime:create(1),cc.CallFunc:create(function (  )
		-- 	map.getSmokeLayer():removeAllChildrenWithCleanup(true)
		-- 	config.removeSmokeAnimationFile()
		-- end)}))
		map.getSmokeLayer():removeAllChildrenWithCleanup(true)
		config.removeSmokeAnimationFile()
	end
end

local function addSmokeAnimation()
	local smokeData = mapData.getSmokeData()
	if not smokeData then return end
	removeSmoke()
	local building = mapData.getObject().building
	local child,point,armature,point1 = nil, nil, nil, nil
	local animationTable = {}

	if mainBuildScene.isInCity() and smokeData[mainBuildScene.getThisCityid()] then
	-- for m,n in pairs(smokeData) do
		-- if mainBuildScene.getThisCityid() == m and table.getn(n) > 0 then
			for i,v in pairs (smokeData[mainBuildScene.getThisCityid()]) do
				child = MapNodeData.getBuildingNode()[v.parentTag] --building:getChildByTag(v.parentTag)
				if child and (v.view == 59 or v.view == 60 or v.view == 61) then
					if v.view == 59 then
						animationTable = {}
						point1 = child[1]:convertToWorldSpace(cc.p(57,150-79))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_big"})
					end

					if v.view == 60 then
						animationTable = {}
						point1 = child[1]:convertToWorldSpace(cc.p(126,150-19))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_big"})

						point1 = child[1]:convertToWorldSpace(cc.p(155,150-35))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_big"})

						point1 = child[1]:convertToWorldSpace(cc.p(26,150-65))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_small"})

						point1 = child[1]:convertToWorldSpace(cc.p(13,150-71))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_small"})
					end

					if v.view == 61 then
						animationTable = {}
						point1 = child[1]:convertToWorldSpace(cc.p(165,150-67))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_big"})

						point1 = child[1]:convertToWorldSpace(cc.p(136,150-80))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_big"})

						point1 = child[1]:convertToWorldSpace(cc.p(37,150-57))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_small"})

						point1 = child[1]:convertToWorldSpace(cc.p(59,150-32))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_small"})

						point1 = child[1]:convertToWorldSpace(cc.p(90,150-38))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
						table.insert(animationTable,{point, "flag_small"})
					end

					for i, v in pairs(animationTable) do
						if config.getWinSize().width > v[1].x and v[1].x > 0
							and v[1].y > 0 and config.getWinSize().height > v[1].y then
							CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/"..v[2]..".ExportJson")
							armature = CCArmature:create(v[2])
							armature:getAnimation():playWithIndex(0)
							armature:setPosition(cc.p(v[1].x,v[1].y))
							map.getSmokeLayer():addChild(armature)
							armature:setScale(getScaleTime())
							armature:runAction(animation.sequence({CCFadeIn:create(1)}))
						end
					end
				end

				if child and (v.view == 99 or v.view == 100 or v.view == 101) then
					if v.view == 99 then
						point1 = child[1]:convertToWorldSpace(cc.p(60,150-83))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
					elseif v.view == 100 then
						point1 = child[1]:convertToWorldSpace(cc.p(150,150-36))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
					elseif v.view == 101 then
						point1 = child[1]:convertToWorldSpace(cc.p(160,150-17))
						point = map.getSmokeLayer():convertToNodeSpace(cc.p(point1.x,point1.y))
					end
					if config.getWinSize().width > point1.x and point1.x > 0
						and point1.y > 0 and config.getWinSize().height > point1.y then
						config.loadSmokeAnimationFile()
						armature = CCArmature:create("smoke")
						armature:getAnimation():playWithIndex(0)
						armature:setPosition(cc.p(point.x,point.y))
						map.getSmokeLayer():addChild(armature)
						armature:runAction(animation.sequence({CCFadeIn:create(1)}))
					end
				end
			end
		-- end
	end
end

local function removeGrass(coorX,coorY,isMove)
	-- local posX,posY = math.floor((coorX+2)/3), math.floor((coorY+2)/3)
	local yuX  = coorX%3
	local yuY  = coorY%3
	local realX, realY = nil, nil
	realX = coorX
	realY = coorY

	if yuX == 1 then
		realX = coorX+1
	elseif yuX == 0 then
		realX = coorX-1
	end

	if yuY == 1 then
		realY = coorY+1
	elseif yuY == 0 then
		realY = coorY-1
	end
	
	if (isMove == MOVE_UP and coorX%3 == 0) 
		or (isMove == MOVE_DOWN and coorX%3==1 )
		or (isMove == MOVE_LEFT and coorY%3 == 0) 
		or (isMove == MOVE_RIGHT and coorY%3 == 1) then
		local tag = mapData.getTagFunction(realX,realY,mapElement.GRASS)
		local temp = MapNodeData.getGrassNode()[tag] --mapData.getObject().grass:getChildByTag(mapData.getTagFunction(realX,realY))
		if temp then
			-- mapData.getObject().grass:removeChild(temp,true)
			MapNodeData.removeGrassNode(tag)
		end
	end
end

local function addGrass(isMove,posX, posY,coorX, coorY, i, j )
	local object = mapData.getObject()
	-- local posX,posY = math.floor((i+2)/3), math.floor((j+2)/3)
	local yuX  = i%3
	local yuY  = j%3
	local realX, realY = nil, nil
	realX = i
	realY = j

	if yuX == 1 then
		realX = i+1
	elseif yuX == 0 then
		realX = i-1
	end

	if yuY == 1 then
		realY = j+1
	elseif yuY == 0 then
		realY = j-1
	end

	local tag = mapData.getTagFunction(realX,realY,mapElement.GRASS)
	if MapNodeData.getGrassNode()[tag] then return end
	local locationX, locationY = config.getMapSpritePos(posX,posY, coorX,coorY, realX,realY)	
	-- local sprite = cc.Sprite:createWithSpriteFrameName("dibiao.png")
	-- object.grass:addChild(sprite,tag,tag)
	local sprite = MapSpriteManage.popSprite(mapElement.GRASS, "dibiao.png", object.grass)
	sprite:setPosition(cc.p(locationX+100,locationY+50))
	MapNodeData.addGrassNode(sprite, tag, "dibiao.png")
	sprite:setVisible(true)
	sprite:setTag(tag)
	-- sprite:setZOrder(tag)
	object.grass:reorderChild(sprite, tag)
end

function addObjecBySort(confirm, x, y,coorX, coorY,posX, posY, dis, fangxiang)
	local locationX, locationY = nil,nil
	local npcCity = nil
	local view_str = nil
	local wall_str = nil
	local coorx, coory = nil, nil
	local area = 9
	local centerX, centerY = nil--area*x-4, area*y-4
	for i=x , y do
		if fangxiang then
			if not mapData.getLoadedMapLayer(i, confirm) then
				additionMap(posX, posY, coorX, coorY, i, confirm)
				addGrass(dis,posX, posY, coorX, coorY,i,confirm)
			end
			addTopObject(posX, posY, coorX, coorY, i, confirm)
			locationX, locationY = config.getMapSpritePos(posX,posY, coorX,coorY, i, confirm)
			addRes(locationX, locationY, i, confirm)
			coorx, coory = i, confirm
		else
			if not mapData.getLoadedMapLayer(confirm, i) then
				additionMap(posX, posY, coorX, coorY, confirm, i)
				addGrass(dis,posX, posY, coorX, coorY,confirm,i)
			end
			addTopObject(posX, posY, coorX, coorY, confirm, i)
			locationX, locationY = config.getMapSpritePos(posX,posY, coorX,coorY, confirm, i)
			addRes(locationX, locationY, confirm, i)
			coorx, coory = confirm, i
		end
		npcCity = Tb_cfg_world_city[coorx*10000+coory]
		centerX, centerY = area*coorx-4, area*coory-4
		if npcCity then
			if not MapNodeData.getBuildingNode()[mapData.getTagFunction(centerX, centerY, mapElement.BUILDING)] then--(not mapData.getCityComponentData(i, confirm)) then
				addBuilding(coorx, coory,CityComponentType.getMainCityView(coorx, coory),CityComponentType.getWallLevelData(coorx, coory))
			end
		else
			view_str = mapData.getBuildingView(coorx, coory )
			wall_str = mapData.getBuildingWall(coorx, coory )
			if view_str and wall_str then
				if view_str == CityComponentType.getFengchengView() or view_str == CityComponentType.getYaosaiView() or view_str == CityComponentType.getTotalRuinsView() then
					if not MapNodeData.getBetweenMountainNode()[mapData.getTagFunction(centerX, centerY, mapElement.BETWEENNODE)] then
						addBuilding(coorx, coory,view_str, wall_str)
					end
				else
					if not MapNodeData.getBuildingNode()[mapData.getTagFunction(centerX, centerY, mapElement.BUILDING)] then
						addBuilding(coorx, coory,view_str, wall_str)
					end
				end
			end
		end
	end
end

--加载新的地图 
local function addMap(posX, posY, coorX, coorY )
	-- local mapArray= mapData.getLoadedMapData()
	local addMapTimesX, addMapTimesY = config.getAddMapTimes()
	local row_up = (coorX - addMapTimesX > 0 and coorX - addMapTimesX) or 1
	local row_down = (coorX + addMapTimesX <size and coorX + addMapTimesX) or size
	local col_left = (coorY - addMapTimesY  >0 and coorY - addMapTimesY) or 1
	local col_right = (coorY + addMapTimesY  < size and coorY + addMapTimesY) or size
	for i=row_up, row_down do
		addObjecBySort(i, col_left, col_right,coorX, coorY,posX, posY )
		-- for j=col_left, col_right do

			-- if not mapData.getLoadedMapLayer(i, j) then
				-- addGrass(false,posX, posY, coorX, coorY,i,j)
				-- additionMap(posX, posY, coorX, coorY, i, j)
			-- end
		-- end
	end

	mapData.setMapArea(row_up, row_down, col_left, col_right)
end

--每次移动判断应该向哪个方向增加地图 todo
local function addMapWhenMove(offsetX, offsetY, posX, posY, coorX, coorY )
	local mapArea
	local rang = 1
	local addX, addY = config.getAddMapTimes( )
	-- local loSprite = mapData.getObject().grass:getChildByTag(mapData.getTagFunction(coorX, coorY))
	offset.x = offset.x + offsetX
	offset.y = offset.y + offsetY
	while offset.x <=-rang do
		mapArea = mapData.getMapArea()
		local up, down = mapArea.row_up, mapArea.row_down
		if mapArea.row_up - 1 >= 1 then 
			-- for j= mapArea.col_left, mapArea.col_right do
				-- addGrass(MOVE_UP, posX, posY, coorX, coorY, 
				-- 	mapArea.row_up-1, j)
				-- additionMap(posX, posY,coorX, coorY, mapArea.row_up-1, j)
			-- end
			addObjecBySort(mapArea.row_up-1, mapArea.col_left, mapArea.col_right,coorX, coorY,posX, posY,MOVE_UP  )
			up = mapArea.row_up-1

			if coorX + addX <= size then
				for j= mapArea.col_left, mapArea.col_right do
					removeGrass( mapArea.row_down, j, MOVE_DOWN)
					removeAdditionMap(mapArea.row_down, j)
					down = mapArea.row_down-1
				end
			end

			-- if (mapArea.row_down-1) - (mapArea.row_up-1) >= 2*addX then
				
			-- end
			mapData.setMapArea(up, down, mapArea.col_left, mapArea.col_right)
		end
		offset.x = offset.x + rang
	end

	while offset.x >= rang do
		mapArea = mapData.getMapArea()
		local up, down = mapArea.row_up, mapArea.row_down
		if mapArea.row_down + 1 <= size then
			-- for j= mapArea.col_left, mapArea.col_right do
			-- 	addGrass(MOVE_DOWN, posX, posY, coorX, coorY, 
			-- 		mapArea.row_down+1, j)
			-- 	additionMap(posX, posY,coorX, coorY, mapArea.row_down+1, j)
			-- end
			addObjecBySort(mapArea.row_down+1, mapArea.col_left, mapArea.col_right,coorX, coorY,posX, posY,MOVE_DOWN  )
			down = mapArea.row_down+1

			-- if (mapArea.row_down+1) - (mapArea.row_up+1) >= 2*addX then
			if coorX - addX >= 1 then
				for j= mapArea.col_left, mapArea.col_right do
					removeGrass( mapArea.row_up, j,MOVE_UP)
					removeAdditionMap(mapArea.row_up, j)
					up = mapArea.row_up+1
				end
			end
			mapData.setMapArea(up, down, mapArea.col_left, mapArea.col_right)
		end
		offset.x = offset.x - rang
	end

	while offset.y <=-rang do
		mapArea = mapData.getMapArea()
		local left, right = mapArea.col_left, mapArea.col_right
		if mapArea.col_left - 1 >= 1 then
			-- for i= mapArea.row_up, mapArea.row_down do
			-- 	addGrass(MOVE_LEFT, posX, posY, coorX, coorY, 
			-- 		i, mapArea.col_left-1)
			-- 	additionMap(posX, posY,coorX, coorY, i, mapArea.col_left-1)
			-- end
			addObjecBySort(mapArea.col_left-1, mapArea.row_up, mapArea.row_down,coorX, coorY,posX, posY,MOVE_LEFT,true  )
			left = mapArea.col_left-1

			-- if (mapArea.col_right - 1) - ( mapArea.col_left - 1) >= 2*addY then
			if coorY + addY <= size then
				for i= mapArea.row_up, mapArea.row_down do
					removeGrass( i, mapArea.col_right,MOVE_RIGHT)
					removeAdditionMap(i, mapArea.col_right)
				end
				right = mapArea.col_right-1
			end
			mapData.setMapArea(mapArea.row_up, mapArea.row_down, left, right)
		end
		offset.y = offset.y +rang
	end

	while offset.y >=rang do
		mapArea = mapData.getMapArea()
		local left, right = mapArea.col_left, mapArea.col_right
		if mapArea.col_right + 1 <= size then
			-- for i= mapArea.row_up, mapArea.row_down do
			-- 	addGrass(MOVE_RIGHT, posX, posY,coorX,coorY, 
			-- 		i, mapArea.col_right+1)
			-- 	additionMap(posX, posY,coorX, coorY, i, mapArea.col_right+1)
			-- end
			addObjecBySort(mapArea.col_right+1, mapArea.row_up, mapArea.row_down,coorX, coorY,posX, posY,MOVE_RIGHT,true  )
			right = mapArea.col_right+1

			-- if (mapArea.col_right + 1) - ( mapArea.col_left + 1) >= 2*addY then
			if coorY - addY >= 1 then
				for i= mapArea.row_up, mapArea.row_down do
					removeGrass( i, mapArea.col_left, MOVE_LEFT)
					removeAdditionMap(i, mapArea.col_left)
				end
				left = mapArea.col_left+1
			end
			mapData.setMapArea(mapArea.row_up, mapArea.row_down, left, right)
		end
		offset.y = offset.y - rang
	end
end

local function removeFogWhenJump( )
	-- mapData.getObject().fogLayer:removeAllChildrenWithCleanup(true)
	MapNodeData.removeAllFogNode()
	-- local arrFogData = WarFogData.getAllFogData()
	-- local netArea = mapData.getArea()
	if not mapData.getObject() or not mapData.getObject().zhuzha then return end
	local object = MapNodeData.getSurfaceNode() --mapData.getObject().batchNode
	local pSprite = nil
	local mapArea = mapData.getMapArea()
	local row_up = mapArea.row_up
	local row_down = mapArea.row_down
	local col_left = mapArea.col_left
	local col_right = mapArea.col_right
	for i = row_up, row_down do
		for j = col_left, col_right do
			pSprite = object[mapData.getTagFunction(i,j, mapElement.FOG)][1]--object:getChildByTag(mapData.getTagFunction(i,j))
			if pSprite then
				pSprite:setVisible(true)
			end
		end
	end
end

local function addWarAvailablePos( )
	if not userData.isInNewBieProtection() then return end
	local addTable = {}
	local addTableWid = {}
	local conditionTable = {}
	-- local buildingData = mapData.getBuildingData()
	local area = mapData.getMapArea()
	local relation = nil
	local x, y = nil, nil
	local layer = nil
	local point = nil
	local sprite = nil

	for i, v in pairs(allTableData[dbTableDesList.world_city.name]) do
		table.insert(conditionTable, {math.floor(v.wid/10000),v.wid%10000})
	end

	for i, v in pairs(mapData.getBuildingData()) do
		for m,n in pairs(v) do
			relation = mapData.getRelation(i,m)
			if relation and (relation == mapAreaRelation.free_ally or relation == mapAreaRelation.free_underling) then
				table.insert(conditionTable, {i,m})
			end
		end
	end
	for i, v in ipairs(conditionTable) do
		-- x = math.floor(v.wid/10000)
		-- y = v.wid%10000
		x = v[1]
		y = v[2]
		for m = x - 1, x+1 do
			for n = y- 1, y+1 do
				if m <= 1501 and m >=1 and n<=1501 and n >=1 and m >=area.row_up and m <= area.row_down and n >= area.col_left and n <= area.col_right then 
					relation = mapData.getRelation(m,n)
					if not addTableWid[m*10000+n] and not mapData.getCityType( m, n) and not terrain.isWaterTerrain(m,n) and (not relation or mapAreaRelation.all_free == relation or mapAreaRelation.free_enemy == relation 
						or mapAreaRelation.attach_higher_up == relation or mapAreaRelation.attach_enemy == relation
						or mapAreaRelation.attach_free == relation) then
						layer = mapData.getLoadedMapLayer( m, n )
						if layer then
							point = layer:convertToWorldSpace(cc.p(0,0))
							point = map.getSmokeLayer():convertToNodeSpace(cc.p(point.x,point.y))
							sprite = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.ground_connect)
							map.getSmokeLayer():addChild(sprite)
							sprite:setAnchorPoint(cc.p(0,0))
							sprite:setPosition(point)
							table.insert(addTable, sprite)
							addTableWid[m*10000+n] = 1
						end
					end
				end
			end
		end
	end

	local action = nil
	local action1 = nil
	for i, v in pairs(addTable) do
		-- v:setOpacity(0)
		action = animation.sequence({CCFadeIn:create(0.4), CCFadeOut:create(0.4)})
		action1 = animation.sequence({CCRepeat:create(action, 2), cc.CallFunc:create(function ( )
			for m , n in pairs(addTable) do
				v:removeFromParentAndCleanup(true)
			end
		end)})
		v:runAction(action1)
	end
end


--跳转 coorX x坐标     coorY y坐标
local function jump(coorX, coorY, isCity,isInCity)
	local winSize = config.getWinSize()
	removeAllMap()
	if mapData.getTouchLayer() then
		mapData.getTouchLayer():setVisible(false)
	end
	mapMessageUI.remove_self()
	local mlayer = mapData.getObject().layer

	map.getCompareLayer():setScale(map.getNorScale())
	mlayer:setScale(map.getNorScale())
	mlayer:setAnchorPoint(cc.p(0,0))
	-- mlayer:setPosition(cc.p(winSize.width/2-100*map.getNorScale(), winSize.height/2-50*map.getNorScale()))
	local x_, y_ = config.countNodeSpace(config.getWinSize().width/2,config.getWinSize().height/2, map.getAngel())
	local point = mlayer:getParent():convertToNodeSpace(cc.p(x_,y_))
	mlayer:setPosition(cc.p(point.x - 100*map.getNorScale(), point.y - 50*map.getNorScale()))

	-- WarFog.setScaleRightNow(map.getNorScale())
	local locationX
	local locationY
	if not coorX or coorX < 0 then
		locationX, locationY = userData.getLocation()--1244,1156
	else
		locationX, locationY = coorX, coorY
	end
	offset = {x=0,y=0}
	userData.setLocation(locationX,locationY)
	map.setLocation(locationX,locationY)
	map.setLockMapCoord(locationX,locationY)
	addMap(0, 0,locationX,locationY)
	removeFogWhenJump()
	CityName.removeAll()
	mapData.requestMapData(locationX, locationY, isCity)
	armyMark.resetLinePosition(locationX,locationY)
	miniMapManager.setMarkPos(locationX,locationY)
	ObjectManager.postJumpCallBack(locationX,locationY)
	BirdAnimation.birdMove()
	CityMarking.move()
	SmallMiniMap.coordToPicture()
end



local function getCoordinateScreenPos(coorX,coorY,angleOffset)
	if not angleOffset then angleOffset = 0 end
	local locationXPos, locationYPos = map.getLocation( )
	-- local loadSprite = mapData.getLoadedMapLayer(locationXPos, locationYPos)
	local px, py = userData.getLocationPos()
	-- if not loadSprite then return end
	local posx,posy = config.getMapSpritePos(px,py, locationXPos, locationYPos ,coorX, coorY)
	-- local point = map.getInstance():convertToWorldSpace(cc.p(posx + 100,posy + 50))
	local point = map.getInstance():convertToWorldSpace(cc.p(posx + 100,posy + 50))
	local screenX,screenY = config.countWorldSpace(point.x,point.y,map.getAngel() + angleOffset)
	return screenX,screenY
end

-- 模拟触屏 将当前 screenX screenY 移动到屏幕中间
local function simulateScaleMove2Screen(moveBeinPosX,moveBeinPosY)
	local winSize = config.getWinSize()
	local moveEndPosX,moveEndPosY = winSize.width/2,winSize.height/2

	local distance_x = moveEndPosX - moveBeinPosX
	local distance_y = moveEndPosY - moveBeinPosY

	
	local stepCount = 10
	local moveStepScreen_X = (distance_x)/stepCount
	local moveStepScreen_Y = (distance_y)/stepCount
	
	local stepSimulateMove = function()
		moveEndPosX = moveEndPosX + moveStepScreen_X
		moveEndPosY = moveEndPosY + moveStepScreen_Y
		map.onTouchSimulation("moved",moveEndPosX,moveEndPosY)
	end


	moveEndPosX = moveBeinPosX
	moveEndPosY = moveBeinPosY
	map.onTouchSimulation("began",moveBeinPosX,moveBeinPosY)
	for i = 1,stepCount do 
		stepSimulateMove()
	end
	map.onTouchSimulation("ended",moveEndPosX,moveEndPosY)
end

-- 模拟触屏 将coorX coorY 移动到屏幕中心点
local function simulateScaleMove2Coordinate(coorX,coorY)
	local moveBeinPosX ,moveBeinPosY = getCoordinateScreenPos(coorX,coorY)
	-- print(">>>>>>>>>>>>>>>>>>>>rrrrr ="..moveBeinPosX.."       y="..moveBeinPosY)
	simulateScaleMove2Screen(moveBeinPosX,moveBeinPosY)
	return moveEndPosX,moveEndPosY
end

local function isSimulatingMove()
	return m_bSimulatingMove
end





-- 定位屏幕内可见的坐标到屏幕中心点
local function simulateLocateCoordinateInScreen(coorX,coorY,callback,duration)
	local moveEndPosX,moveEndPosY = simulateScaleMove2Coordinate(coorX,coorY)
	map.simulateMove(callback,duration,moveEndPosX,moveEndPosY)
end

local function simulateLocateScreen(screenX,screenY,callback,duration,speedType)
	simulateScaleMove2Screen(screenX,screenY)
	map.simulateMove(callback,duration,screenX,screenY,speedType)
end



local DEFAUKT_ANGLE_OFFSET = 10
-- 只在屏幕内的城市才会用到此接口
local function enterCity(coorX,coorY,callback)
	if m_bSimulatingMove then 
		if callback then callback() end
		return 
	end

	m_bSimulatingMove = true

	map.setAnchorPoint(0.5,0.5)
	local locateDuration = 0.6
	local etnerDuration = 0.8


	lockLayer.create(nil,false)

	local function finallycallback()
		m_bSimulatingMove = false
		if callback then callback() end
		lockLayer.remove()

		-- optionController.resetOptions()
	end
	local function finally()
		local moveEndPosX,moveEndPosY = simulateScaleMove2Coordinate(coorX,coorY,-DEFAUKT_ANGLE_OFFSET)
		if not moveEndPosX then 
			moveEndPosX = config.getWinSize().width/2

		end
		if not moveEndPosY then 
			-- moveEndPosY = config.getWinSize().height * (55/100) 
			moveEndPosY = config.getWinSize().height/2
		end

		map.simulateAgnleScaleMoveSpwan(finallycallback,etnerDuration,map.getInstance():getScale(),map.getNorScale()*1.7,moveEndPosX,moveEndPosY,-DEFAUKT_ANGLE_OFFSET)
	end
	
	simulateLocateCoordinateInScreen(coorX,coorY,nil,locateDuration)
	mapData.getObject().layer:runAction( animation.sequence{
			cc.DelayTime:create(locateDuration * 0.8),
			cc.CallFunc:create(function ()
				-- map.simulateMoveClear(nil,  0.1 )
				-- finally()
				-- optionController.removeOptions()
				mapData.getObject().layer:stopAllActions()
				finally()
			end)

		} ) 

	-- mainOption.changeInCityState(true)
	-- mainOption.setSecondPanelVisible(false,false)
	mainOption.switchCityEffect(true,coorX * 10000 + coorY)
end

-- 退出城市
local function quitCity(coorX,coorY,callback)
	if m_bSimulatingMove then 
		if callback then callback() end
		return 
	end

	lockLayer.create(nil,false)

	m_bSimulatingMove = true
	local finallycallback = function()
		m_bSimulatingMove = false
		if callback then callback() end
		lockLayer.remove()

		-- if not openMapmessageWhileLocating then 
		-- 	selectGroundDisplay(coorX,coorY)
		-- end
		selectGroundDisplay(coorX,coorY)

	end

	local quitDuration = 0.8
	map.setAnchorPoint(0.5,0.5)
	local moveEndPosX,moveEndPosY = simulateScaleMove2Coordinate(coorX,coorY,DEFAUKT_ANGLE_OFFSET)
	map.simulateAgnleScaleMoveSpwan(finallycallback,quitDuration,map.getNorScale()*1.7,map.getNorScale(),moveEndPosX,moveEndPosY,DEFAUKT_ANGLE_OFFSET)

	mainOption.switchCityEffect(false,coorX * 10000 + coorY)
end

local function locateAndEnterCity(coorX,coorY,callback)

	


	if mainBuildScene.isInCity() then 
		if callback then callback() end
	else
		mapController.setOpenMessage(false)
		mapController.setResVisible(false)
		


    	mainOption.setSecondPanelVisible(false,false)
	    mainScene.setBtnsVisible(false)
	    ObjectManager.setObjectLayerVisible(2)
	    armyMark.setLineVisible(false)

	    local function finally()
	        mapController.addSmokeAnimation()
	        mainBuildScene.create(coorX, coorY)
	        if callback then callback() end
	    end
    
	    mapController.setResVisible(false)
	    mapController.setCityShadow(true)


		mapController.locateCoordinate(coorX,coorY,function()
			mapController.setOpenMessage(true)
			mapController.enterCity(coorX,coorY,function()
				finally()
			end)
		end)
	end
end

local DEFAULT_SCREEN_SIDE_LEFT = 1
local DEFAULT_SCREEN_SIDE_RIGHT = 2
local DEFAULT_SCREEN_SIDE_UP = 3
local DEFAULT_SCREEN_SIDE_DOWN = 4

-- 计算与屏幕中心点连线的直线 与 屏幕四边的焦点
-- return screenX,screenY,screenSide

local function calcIntersectionWithScreenByPoint(screenXOri,screenYOri,angleAtanValue)
	
	local winSize = config.getWinSize()
	local screenX_center = winSize.width/2
	local screenY_center = winSize.height/2

	local screenX = nil
	local screenY = nil


	--屏幕下方检测
	screenY = 0
	screenX = (screenY - screenY_center )*angleAtanValue + screenX_center 

	if screenX >= 0 and screenX <= winSize.width and screenY >= 0 and screenY <= winSize.height then 

		if (screenXOri - screenX) * (screenX - screenX_center) >= 0 and 
			(screenYOri - screenY) * (screenY - screenY_center)>=0 then
			return screenX,screenY,DEFAULT_SCREEN_SIDE_DOWN
		end
		
	end
	--屏幕上方检测
	screenY = winSize.height
	screenX = (screenY - screenY_center )*angleAtanValue + screenX_center 
	if screenX >= 0 and screenX <= winSize.width and screenY >= 0 and screenY <= winSize.height then 
		if (screenXOri - screenX) * (screenX - screenX_center) >= 0 and 
			(screenYOri - screenY) * (screenY - screenY_center)>=0 then
			return screenX,screenY,DEFAULT_SCREEN_SIDE_UP
		end
		
	end

	-- 屏幕左方检测
	
	screenX = 0
	screenY =   ( screenX - screenX_center )/angleAtanValue  + screenY_center 
	if screenX >= 0 and screenX <= winSize.width and screenY >= 0 and screenY <= winSize.height then 
		if (screenXOri - screenX) * (screenX - screenX_center) >= 0 and 
			(screenYOri - screenY) * (screenY - screenY_center)>=0 then
			return screenX,screenY,DEFAULT_SCREEN_SIDE_LEFT
		end
		
	end
	-- 屏幕右方检测
	screenX = winSize.width
	screenY = ( screenX - screenX_center )/angleAtanValue  + screenY_center 
	if screenX >= 0 and screenX <= winSize.width and screenY >= 0 and screenY <= winSize.height then 
		if (screenXOri - screenX) * (screenX - screenX_center) >= 0 and 
			(screenYOri - screenY) * (screenY - screenY_center)>=0 then
			return screenX,screenY,DEFAULT_SCREEN_SIDE_RIGHT
		end
	end
	return nil,nil
end

-- 地图任一网格映射的屏幕坐标


local function getMapCoordinateScreenPos(coorX,coorY,angle)
	-- map.setAnchorPoint(0.5,0.5)
	if not angle then angle = map.getAngel() end
	local winSize = config.getWinSize()

	-- 屏幕中心点坐标
	local screenX_center = winSize.width/2
	local screenY_center = winSize.height/2
	
	-- 当前屏幕中心的 coordinate
	local center_coorX, center_coorY = map.touchInMap(winSize.width/2, winSize.height/2)
	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	
	local targetLos = {x= nil, y = nil}
	targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, coorX, coorY)

	-- local targetPoint = map.getInstance():convertToWorldSpace(cc.p(targetLos.x + 100 * map.getNorScale()   ,targetLos.y + 50* map.getNorScale()  ))
	local targetPoint = map.getInstance():convertToWorldSpace(cc.p(targetLos.x + 100 ,targetLos.y + 50))

	local screenXTarget,screenYTarget = config.countWorldSpace(targetPoint.x,targetPoint.y,angle)
	-- map.setAnchorPoint(0,0)
	return screenXTarget,screenYTarget
end

local function isCoordinateInScreen(coorX,coorY)
	local winSize = config.getWinSize()
	local screenX,screenY = getMapCoordinateScreenPos(coorX,coorY)

	if screenX and screenY and screenX >= 0 and screenX <= winSize.width and screenY >=0 and screenY <= winSize.height then 
		return true
	else
		return false
	end
end


local function locateCoordinateOutScreen(coorX,coorY, callback)
	
	local winSize = config.getWinSize()
	local screenX_center = winSize.width/2
	local screenY_center = winSize.height/2
	local center_coorX, center_coorY = map.touchInMap(winSize.width/2, winSize.height/2)

	local screenX,screenY,screenQuitSide = nil,nil,nil
	screenX,screenY = getMapCoordinateScreenPos(coorX,coorY,0)


	local winSize = config.getWinSize()
	local screenXCenter,screenYCenter = winSize.width/2,winSize.height/2
	
	local angleAtanValue = (screenX - screenXCenter)/(screenY - screenYCenter)
	



	screenX,screenY,screenQuitSide = calcIntersectionWithScreenByPoint(screenX,screenY,angleAtanValue)
	
	local screenEnterSide = nil
	if screenQuitSide == DEFAULT_SCREEN_SIDE_LEFT then 
		screenEnterSide = DEFAULT_SCREEN_SIDE_RIGHT 
	elseif screenQuitSide == DEFAULT_SCREEN_SIDE_RIGHT then 
		screenEnterSide = DEFAULT_SCREEN_SIDE_LEFT
	elseif screenQuitSide == DEFAULT_SCREEN_SIDE_UP then 
		screenEnterSide = DEFAULT_SCREEN_SIDE_DOWN
	elseif  screenQuitSide == DEFAULT_SCREEN_SIDE_DOWN then 
		screenEnterSide = DEFAULT_SCREEN_SIDE_UP
	end


	local docallback = function ()
		if callback then callback() end


	end

	map.setAnchorPoint(0.5,0.5)
	local finally = function()
		map.setAnchorPoint(0,0)
		-- ObjectManager.setObjectVisible(true)
		-- armyMark.setLineVisible(true)
		-- SmallMiniMap.setMapVisibel(true)

		screenX,screenY = getMapCoordinateScreenPos(coorX,coorY)
		if screenX >= 0 and screenX<= winSize.width and screenY >= 0 and screenY <= winSize.height then 
			mapController.locateCoordinateInScreen(screenX,screenY,coorX,coorY,docallback)
		else
			outScreenJumpCall = docallback
			local jump_screen_x = nil
			local jump_screen_y = nil

			if screenEnterSide == DEFAULT_SCREEN_SIDE_LEFT then 
				jump_screen_x = 0
				jump_screen_y = (jump_screen_x - screenX_center)/angleAtanValue + screenY_center 
			elseif screenEnterSide == DEFAULT_SCREEN_SIDE_RIGHT then
				jump_screen_x = winSize.width
				jump_screen_y = (jump_screen_x - screenX_center)/angleAtanValue + screenY_center 
			elseif screenEnterSide == DEFAULT_SCREEN_SIDE_UP then 
				jump_screen_y = winSize.height
				jump_screen_x = (jump_screen_y - screenY_center) * angleAtanValue + screenX_center
			elseif screenEnterSide == DEFAULT_SCREEN_SIDE_DOWN then 
				jump_screen_y = 0
				jump_screen_x = (jump_screen_y - screenY_center) * angleAtanValue + screenX_center
			end
			screenX,screenY = getMapCoordinateScreenPos(coorX,coorY,0)

			
			jump_screen_x = screenX - (screenX_center - jump_screen_x) * 2/4
			jump_screen_y = screenY - (screenY_center - jump_screen_y) * 2/4

			local jump_coor_x,jump_coor_y = nil,nil
			jump_coor_x,jump_coor_y = map.touchInMap(jump_screen_x,jump_screen_y ,0)
			

			m_bIsLocatingCity = true
			


			mapController.setLocateToCity(coorX*10000+coorY)
			mapController.jump(jump_coor_x,jump_coor_y)
			mapController.cityToTouchInfo()
			mapController.setLocateToCity(nil)
			if openMapmessageWhileLocating then 
				-- mapController.setJumpToCity(coorX*10000+coorY)
			end
		end
	end
	
	local quit_screen_x = nil
	local quit_screen_y = nil

	if screenQuitSide == DEFAULT_SCREEN_SIDE_LEFT then 
		quit_screen_x = 0
		quit_screen_y = (quit_screen_x - screenX_center)/angleAtanValue + screenY_center 
	elseif screenQuitSide == DEFAULT_SCREEN_SIDE_RIGHT then
		quit_screen_x = winSize.width
		quit_screen_y = (quit_screen_x - screenX_center)/angleAtanValue + screenY_center 
	elseif screenQuitSide == DEFAULT_SCREEN_SIDE_UP then 
		quit_screen_y = winSize.height
		quit_screen_x = (quit_screen_y - screenY_center) * angleAtanValue + screenX_center
	elseif screenQuitSide == DEFAULT_SCREEN_SIDE_DOWN then 
		quit_screen_y = 0
		quit_screen_x = (quit_screen_y - screenY_center) * angleAtanValue + screenX_center
	end

	screenX = screenX_center - (screenX_center - quit_screen_x) * 2/4
	screenY = screenY_center - (screenY_center - quit_screen_y) * 2/4
	-- 根据角度退出当前屏幕
	


	-- ObjectManager.setObjectVisible(false)
	-- armyMark.setLineVisible(false)
	-- SmallMiniMap.setMapVisibel(false)

	simulateLocateScreen(screenX,screenY,finally,0.5,1)

end

local function locateCoordinateInScreen(screenX,screenY,coorX,coorY,callback)
	if openMapmessageWhileLocating then
		-- mapController.setJumpToCity(coorX*10000+coorY)
	end

	map.setAnchorPoint(0.5,0.5)

	m_bIsLocatingCity = true

	local winSize = config.getWinSize()

	local locateDuration = 0.7
	local finally = function()
		cityToTouchInfo()
		map.setAnchorPoint(0,0)
		
		if callback then callback() end
	end
	
	if math.abs(screenX - winSize.width/2) <= 10 and math.abs(screenY - winSize.height/2) <=10 then 
		finally()
	else
		simulateLocateScreen(screenX,screenY,finally,locateDuration)
	end

end

-- 定位坐标
local function locateCoordinate(coorX,coorY,callback,scrOffsetX,scrOffsetY)
	if not coorX or not coorY then 
		if callback then callback() end
		return 
	end

	if not scrOffsetX then scrOffsetX = 0 end
	if not scrOffsetY then scrOffsetY = 0 end

	if disposeMapmessageWhileLocating then 
		mapMessageUI.remove_self()
	end

	ObjectManager.setObjectVisible(false)
	armyMark.setLineVisible(false)
	SmallMiniMap.setMapVisibel(false)

	local function finally ()
		if not openMapmessageWhileLocating then 
			selectGroundDisplay(coorX,coorY)
		end
		--这个加上这个来修正模拟地图带来的地图物件上的误差 add by huangchunhao
        BirdAnimation.birdMove()
		CloudAnimation.cloudMove()
		ObjectManager.objectMove()
		

		ObjectManager.setObjectVisible(true)
		armyMark.setLineVisible(true)
		SmallMiniMap.setMapVisibel(true)
		
		
		
		lockLayer.remove()

		if openMapmessageWhileLocating then
			if coorX >=1 and coorX <=1501 and coorY >= 1 and coorY <=1501 then
				local sprite = mapData.getLoadedMapLayer(coorX, coorY)
				if sprite then
					local _3dPoint = sprite:convertToWorldSpace(cc.p(100,50))
					local worldPointX, worldPointY = config.countWorldSpace(_3dPoint.x, _3dPoint.y, map.getAngel())
					touchGroundCallback(coorX, coorY, worldPointX, worldPointY,true )
				end
			end
		end

		if callback then 
			callback()
		end

	end
	local winSize = config.getWinSize()
	local screenX,screenY = getMapCoordinateScreenPos(coorX,coorY)
	screenX = screenX + scrOffsetX
	screenY = screenY + scrOffsetY
	lockLayer.create(nil,false)

	if screenX >= 0 and screenX<= winSize.width and screenY >= 0 and screenY <= winSize.height then 
		--目标在当前屏幕内 
		
		locateCoordinateInScreen(screenX,screenY,coorX,coorY,finally)
	else
		-- 目标在屏幕外 
		locateCoordinateOutScreen(coorX,coorY,finally)
	end

end

local function setOpenMessage( flag )
	openMapmessageWhileLocating = flag
end

local function setMapMessageDisposeState( flag )
	disposeMapmessageWhileLocating = flag
end

local function setLevelOne( x,y )
	levelOneWid = x*10000+y
end

local function getLevelOne(  )
	return levelOneWid
end

local function findLevelOne( )
    local main_city_pos = userData.getMainPos()
    local pos_x = math.floor(main_city_pos/10000)
    local pos_y = main_city_pos%10000

    local isRightPos = function ( x,y )
    	for i, v in pairs(armyData.getAllTeamMsg()) do
    		if v.state == armyState.chuzhenging and v.target_wid == x*10000+y then
    			return false
    		end
    	end

    	return true
    end

    local conditionTable = {}
    local relation = nil
	for i, v in pairs(allTableData[dbTableDesList.world_city.name]) do
		table.insert(conditionTable, {math.floor(v.wid/10000),v.wid%10000})
	end
	
    for i, v in pairs(mapData.getBuildingData()) do
		for m,n in pairs(v) do
			relation = mapData.getRelation(i,m)
			if relation and (relation == mapAreaRelation.free_ally or relation == mapAreaRelation.free_underling) then
				table.insert(conditionTable, {i,m})
			end
		end
	end

    
    -- local area = mapData.getMapArea()
    for i, v in pairs(conditionTable) do
        x = v[1]--math.floor(v.wid/10000)
        y = v[2]--v.wid%10000
        for m = x - 1, x+1 do
            for n = y- 1, y+1 do
                if m <= 1501 and m >=1 and n<=1501 and n >=1 then 
                    relation = mapData.getRelation(m,n)
                    if not mapData.getCityType( m, n) and not terrain.isWaterTerrain(m,n) and resourceData.resourceLevel(m,n) < 20
                    	and isRightPos(m,n)
                        and (not relation or mapAreaRelation.all_free == relation ) then
                        layer = mapData.getLoadedMapLayer( m, n )
                        if layer then
                        	setLevelOne(m,n)
                            return m,n
                        end
                    end
                end
            end
        end
    end
    return false
end



mapController = {	
	addMap = addMap,
	addBuilding = addBuilding,
	additionMap = additionMap,
	addRes = addRes,
	moveAddMap = moveAddMap,
	removeAllMap = removeAllMap,
	touchGroundCallback= touchGroundCallback,
	removeAllBuilding = removeAllBuilding,
	-- removeBuilding = removeBuilding,
	remove = remove,
	addMapWhenMove = addMapWhenMove,
	jump = jump,
	locateCoordinate = locateCoordinate,
	locateCoordinateInScreen = locateCoordinateInScreen,
	locateCoordinateOutScreen = locateCoordinateOutScreen,
	isSimulatingMove = isSimulatingMove,
	remove = remove,
	-- removeCityComponent =removeCityComponent,
	addFog = addFog,
	removeFog = removeFog,
	addRelationLand = addRelationLand,
	addSmokeAnimation = addSmokeAnimation,
	removeSmoke = removeSmoke,
	cityToTouchInfo = cityToTouchInfo,
	addClippingRes = addClippingRes,
	removeClippingRes = removeClippingRes,
	changeFlagColor = changeFlagColor,
	setJumpToCity = setJumpToCity,
	setLocateToCity = setLocateToCity,
	selectGroundDisplay = selectGroundDisplay,
	removeWaterEdge = removeWaterEdge,
	getBuildingScaleTime = getBuildingScaleTime,
	enterCity = enterCity,
	quitCity = quitCity,
	simulateLocateScreen = simulateLocateScreen,
	getMapCoordinateScreenPos = getMapCoordinateScreenPos,
	isCoordinateInScreen = isCoordinateInScreen,
	setOpenMessage = setOpenMessage,
	setMapMessageDisposeState = setMapMessageDisposeState,
	removeAdditionWallNode = removeAdditionWallNode,
	addAdditionWall = addAdditionWall,
	setMainCityFade = setMainCityFade,
	setIsRefreshMainCity = setIsRefreshMainCity,
	removeSmokeByTime = removeSmokeByTime,
	addWarAvailablePos = addWarAvailablePos,
	addTouchGround = addTouchGround,
	removeTouchGround = removeTouchGround,
	setResVisible = setResVisible,
	setCityShadow = setCityShadow,
	findLevelOne = findLevelOne,
	setLevelOne = setLevelOne,
	getLevelOne = getLevelOne,
	locateAndEnterCity = locateAndEnterCity,
	addDefendFire = addDefendFire,
	playLandLevel5Animation = playLandLevel5Animation,
	setLevel5animationVisible = setLevel5animationVisible,
	setLevel5Animation = setLevel5Animation,
	setLocateScreenOffset = setLocateScreenOffset,
}
