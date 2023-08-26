--地图ui表现
local mlayer = nil -- 触摸层
local touchBeginPoint = nil --单指触摸
local touchBeginesPoint = nil -- 多指触摸
local locationX = nil  --起始坐标X  
local locationY = nil  --起始坐标Y
local scaleTime = 0.1
local canScale = true
local touchOrigPoint = {x=nil,y=nil}
local begin_move_x, begin_move_y = nil, nil
local m_rootLayer = nil
local m_pCompareLayer = nil
local m_pSmokeLayer = nil
local m_pBuildEffectLayer = nil -- 建筑特效层
local m_pBlueEffect = nil
local m_iAngle = 0
local m_bHasRunAction = nil
local m_armyTouch = nil
local m_touchPointsCount = nil --记录当前有多少只手指在屏幕
-- local m_touchEndTime = nil --记录touchend事件的时间，然后在一段时间内不响应点击事件，主要是因为多点触控的问题

local touch = false  --长时间没有点击
local mTouchHandler = nil --长时间点击的handler
local multiTouchMove = nil
local multiTouchHandler = nil

local midPonit = {x= nil, y=nil}  --双指缩放的中点，以这个点为焦点缩放
local isMove = false  --是否移动
local mScaleNormal, mScaleSmall = config.getDisplayeScale()
if not mScaleNormal then
	mScaleNormal = 1
	mScaleSmall = 0.75
end

local newGuideTouch = nil --新手引导，大地图只能点不能拖
local m_TouchAnimationHandler = nil --云和鸟的动画计时器
local m_touchAnimation = nil

local isSimulatingTouch = nil

local simulatingMove_beginX = nil
local simulatingMove_beginY = nil

local simulatingMove_endX = nil
local simulatingMove_endY = nil

local multiTouch = nil

local isLockCoord = nil  --是否锁定坐标，用于被服务器踢下线重新回到之前的坐标
local lockCoorx, lockCoory = nil, nil

local distanceScale = nil

--是否点击在不透明的像素上，返回true则点击在有效像素
-- local function isInAlpha(coorX, coorY, x, y )
-- 	local layer = mapData.getLoadedMapLayer(coorX, coorY)
-- 	if layer then
-- 		local pointAtMap = layer:convertToNodeSpace(cc.p(x,y))
-- 		local rect =layer:boundingBox()
-- 		rect.origin = ccp(0,0)
-- 		if rect:containsPoint(pointAtMap) and gDetect:getAlpha(gImage, layer, pointAtMap.x, pointAtMap.y).a~=0 then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

--具体在哪个点 
local function touchInMap(x, y,angle )
	--a+(x-x1)/w-(y-y1)/h
	--b+(x-x1)/w+(y-y1)/h
	if not angle then angle = m_iAngle end
	local rootX,rootY = config.countNodeSpace(x,y,angle)
	local point= mlayer:convertToNodeSpace(cc.p(rootX,rootY))
	local coorX = math.floor(locationX+(point.x-0)/200-(point.y-50)/100)
	local coorY = math.floor(locationY+(point.x-0)/200+(point.y-50)/100)
	if coorX > 1501 or coorX <1 or coorY >1501 or coorY <1 then
		return nil,nil
	else
		return coorX, coorY
	end
end

local function touchPoint( x,y  )
	local rootX,rootY = config.countNodeSpace(x,y,m_iAngle)
	local point= mlayer:convertToNodeSpace(cc.p(rootX,rootY))
	local coorX = math.floor(locationX+(point.x-0)/200-(point.y-50)/100)
	local coorY = math.floor(locationY+(point.x-0)/200+(point.y-50)/100)
	return coorX, coorY
end

local function initData( )
	touchBeginPoint = {x= 0, y= 0}
	touchBeginesPoint = {}

	for i=1 ,2 do
		touchBeginesPoint[i] = {x = nil, y=nil}
	end
end

local function animationTouchHandler( )
	if m_TouchAnimationHandler then
	    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_TouchAnimationHandler)
	    m_TouchAnimationHandler =nil
	end
	m_TouchAnimationHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(map.endTouchMove, 1, false)
end

local function endTouchMove( )
	if m_TouchAnimationHandler then
	    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_TouchAnimationHandler)
	    m_TouchAnimationHandler =nil
	end
	CloudAnimation.create()
	BirdAnimation.create()
	m_touchAnimation = false
end


--在固定时间内是否点击屏幕，如果没有，则根据情况决定是否加载地图
local function touchScreen( )
	if mTouchHandler then
	    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(mTouchHandler)
	    mTouchHandler =nil
	end
	touch = false
	local winSize = config.getWinSize()
	local coorX, coorY = touchInMap(winSize.width/2, winSize.height/2)
	if coorX and coorY then
		if mapData.isNeedMapData(coorX, coorY) then
			mapData.requestMapData(coorX, coorY)
		end
	end
end

local function setHandler( )
	if mTouchHandler then
	    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(mTouchHandler)
	    mTouchHandler =nil
	end
	mTouchHandler = cc.Director:getInstance():getScheduler():scheduleScriptFunc(touchScreen, 1, false)
end

--放大缩小公式：
local function layerScale(posX, posY )
	-- if userData.getUserName == "tk500" then 
	-- 	tipsLayer.create(" layerScale ")
	-- end
	
	if not canScale then return end

	local function setChange( from,to,x,y )
        return mlayer:getPositionX()+ (1- to/from)*(x- mlayer:convertToWorldSpace(cc.p(0,0)).x),
                mlayer:getPositionY()+ (1- to/from)*(y- mlayer:convertToWorldSpace(cc.p(0,0)).y)
                -- WarFog.getClip():getPositionX() + (1- to/from)*(x- WarFog.getClip():convertToWorldSpace(cc.p(0,0)).x),
                -- WarFog.getClip():getPositionY() + (1- to/from)*(y- WarFog.getClip():convertToWorldSpace(cc.p(0,0)).y)
    end
    local x1,x2
    local fogPosX,fogPosY
    local scale
    if mlayer:getScale() <= mScaleNormal then
	    x1,x2,fogPosX,fogPosY= setChange(mScaleNormal, mScaleSmall,posX, posY)
	    scale = mScaleSmall
	else
		x1,x2,fogPosX,fogPosY= setChange(mScaleSmall, mScaleNormal,posX, posY)
		scale = mScaleNormal
	end

	local function callback( )
		canScale = true
		-- CloudAnimation.cloudScale()
		-- ObjectManager.objectMove()
	end

	canScale = false
	-- local tempPoint = mlayer:getParent():convertToWorldSpace(cc.p(x1, x2))
	local action = animation.spawn({CCScaleTo:create(scaleTime, scale), CCMoveTo:create(scaleTime,ccp(x1,x2))})
	-- local action1 = animation.spawn({CCScaleTo:create(scaleTime, scale), CCMoveTo:create(scaleTime,ccp(fogPosX,fogPosY))})
	
	mlayer:runAction(animation.sequence({action, cc.CallFunc:create(callback)}))
	m_pCompareLayer:runAction(CCScaleTo:create(scaleTime, scale))

	local action_arr = animation.sequence({cc.DelayTime:create(0.02), cc.CallFunc:create(function ( )
		BirdAnimation.birdMove()
		CloudAnimation.cloudMove()
		ObjectManager.objectMove()
	end)})
	m_rootLayer:runAction(CCRepeat:create(action_arr,5))

	-- WarFog.getClip():runAction(action1)
end

--计算与菱形边平行方向偏移量
local function offset(starPos, endPos )
	local x = (starPos.x - endPos.x)--/mlayer:getScale()
	local y = (starPos.y- endPos.y)--/mlayer:getScale()
	--(x-2*y)/(4*0.5h)
	return (x - 2*y)/200, (x+2*y)/200
end

--根据偏移量做图片的增加和删除
local function moveAccordingOffset(posX,posY )
	local winSize = config.getWinSize()
	local coorX, coorY = touchInMap(winSize.width/2, winSize.height/2)
	if coorX and coorY then
		local loadSprite = mapData.getLoadedMapLayer(coorX, coorY)
		if loadSprite then
			local offsetX, offsetY = offset(touchBeginPoint,{x=posX, y=posY})
			miniMapManager.setMarkPos(coorX, coorY )
			mapController.addMapWhenMove(offsetX, offsetY,
					loadSprite:getPositionX(), loadSprite:getPositionY(),coorX, coorY)
		end
	end
end

local function onTouchBegan(touches )
	if #touches == 3 then
		local rootX,rootY = config.countNodeSpace(touches[1], touches[2],m_iAngle)
		touchOrigPoint = {x= rootX, y= rootY}
		local pointInLayer = m_pCompareLayer:convertToNodeSpace(cc.p(rootX,rootY))
		touchBeginPoint = { x = pointInLayer.x, y = pointInLayer.y}
		begin_move_x = mlayer:getPositionX()
		begin_move_y = mlayer:getPositionY()
		-- object_begin_move_x = ObjectManager.getInstance():getPositionX()
		-- object_begin_move_y = ObjectManager.getInstance():getPositionY()
	end
	return true
end

local function onTouchMoved(touches, isfinger)
	if #touches == 3 then
		-- if m_touchPointsCount and m_touchPointsCount > 1 and isfinger then
		-- 	return false
		-- end
		if multiTouchMove then
			return false
		end

		if not touchOrigPoint.x or (not touchBeginPoint.x) then return end
		local winSize = config.getWinSize()
		local coorX, coorY = touchPoint(winSize.width/2, winSize.height/2)
		local cx, cy = mlayer:getPosition()
		local rootX,rootY = config.countNodeSpace(touches[1], touches[2],m_iAngle)
		local pointInLayer = m_pCompareLayer:convertToNodeSpace(cc.p(rootX,rootY))
		
		local offsetX, offsetY = offset(touchBeginPoint,{x=pointInLayer.x, y=pointInLayer.y})
		if (coorX <=1 and offsetX < 0) or (coorX >=1501 and offsetX > 0) or (coorY <=1 and offsetY < 0) or (coorY >=1501 and offsetY > 0) then
			return false
		end
		
		local orginPoint = m_pCompareLayer:convertToNodeSpace(cc.p(touchOrigPoint.x, touchOrigPoint.y))
		if math.abs(pointInLayer.x-touchBeginPoint.x) > 100 or math.abs(pointInLayer.y-touchBeginPoint.y) >100 then 
			return false
		end
		
		if math.abs(pointInLayer.x-orginPoint.x) > 10 or math.abs(pointInLayer.y-orginPoint.y) > 10 then
			if newGuideTouch then
				return false
			end
			isMove  = true
		end

		local rootX,rootY = config.countNodeSpace(touches[1], touches[2],m_iAngle)
		local parentPoint = mlayer:getParent():convertToNodeSpace(cc.p(rootX, rootY))
		local parentbeginPoint = mlayer:getParent():convertToNodeSpace(cc.p(touchOrigPoint.x, touchOrigPoint.y))
		
		local m_pos_x = begin_move_x + (parentPoint.x - parentbeginPoint.x)
		local m_pos_y = begin_move_y + (parentPoint.y - parentbeginPoint.y)
		mlayer:setPosition(cc.p(m_pos_x ,m_pos_y))
		BirdAnimation.birdMove()
		CloudAnimation.cloudMove()
		ObjectManager.objectMove()
		-- SmallMiniMap.coordToPicture()

		-- WarFog.setStencilPos(begin_move_x + (parentPoint.x - parentbeginPoint.x)-cx,
		-- 				begin_move_y + (parentPoint.y - parentbeginPoint.y)-cy)
		moveAccordingOffset(pointInLayer.x, pointInLayer.y)
		touchBeginPoint= {x= pointInLayer.x, y=pointInLayer.y}

		--是否一段时间没点击屏幕
		if touch then
			touch = false
			setHandler()
		else
			setHandler()
	        touch = true
		end

		if m_touchAnimation then
			m_touchAnimation = false
			animationTouchHandler( )
		else
			animationTouchHandler( )
			m_touchAnimation = true
		end

	elseif #touches == 6 then
		if not touchBeginesPoint[1].x then
			-- local midPonit = {x = nil, y=nil}
			touchBeginesPoint[1].x = touches[1]
			touchBeginesPoint[1].y = touches[2]

			touchBeginesPoint[2].x = touches[4]
			touchBeginesPoint[2].y = touches[5]
			midPonit.x = (touchBeginesPoint[1].x + touchBeginesPoint[2].x)*0.5
			midPonit.y = (touchBeginesPoint[1].y + touchBeginesPoint[2].y)*0.5
		else
			local firstDistance = nil
			local endDistance = nil

			firstDistance = math.sqrt(math.pow((touchBeginesPoint[1].x - touchBeginesPoint[2].x),2)
									+math.pow((touchBeginesPoint[1].y - touchBeginesPoint[2].y), 2))


			endDistance = math.sqrt(math.pow((touches[1] - touches[4]),2)
									+math.pow((touches[2] - touches[5]), 2))

			

			if math.abs(firstDistance - endDistance) > 10 then
				touchBeginesPoint[1].x = touches[1]
				touchBeginesPoint[1].y = touches[2]

				touchBeginesPoint[2].x = touches[4]
				touchBeginesPoint[2].y = touches[5]
				if firstDistance - endDistance > 0 and mlayer:getScale()>= mScaleSmall then
				
					layerScale(midPonit.x, midPonit.y)
				elseif firstDistance - endDistance < 0 and mlayer:getScale()<= mScaleNormal then
					
					layerScale(midPonit.x, midPonit.y)
				end
			end		
		end
		-- local j = 0
		-- local firstDistance = nil
		-- local endDistance = nil
		-- local touchesEndPoint = {{x= nil, y= nil},{x= nil, y=nil}}
		-- for i=1, #touches, 3 do
		-- 	j= j+1
		-- 	local rootX,rootY = config.countNodeSpace(touches[i], touches[i+1],m_iAngle)
		-- 	if touchBeginesPoint[1].x and touchBeginesPoint[2].x and touchesEndPoint[j] then
		-- 		touchesEndPoint[j] = { x= rootX, y =rootY}
		-- 	else
		-- 		touchBeginesPoint[j] = {x= rootX, y =rootY}
		-- 	end
		-- end

		-- if touchBeginesPoint[1].x and touchBeginesPoint[2].x and touchesEndPoint[1].x then
		-- 	firstDistance = math.sqrt(math.pow((touchBeginesPoint[1].x - touchBeginesPoint[2].x),2)
		-- 							+math.pow((touchBeginesPoint[1].y - touchBeginesPoint[2].y), 2))

		-- 	endDistance = math.sqrt(math.pow((touchesEndPoint[1].x - touchesEndPoint[2].x),2)
		-- 							+math.pow((touchesEndPoint[1].y - touchesEndPoint[2].y),2))

		-- 	--防止双指放在屏幕但只有单指移动的时候被识别为缩放
		-- 	if firstDistance < 20 or endDistance < 20 then return end

		-- 	if not midPonit.x then
		-- 		midPonit.x = (touchBeginesPoint[1].x + touchBeginesPoint[2].x)*0.5
		-- 		midPonit.y = (touchBeginesPoint[1].y + touchBeginesPoint[2].y)*0.5
		-- 	end

		-- 	if math.abs(firstDistance - endDistance) > 20 then
		-- 		if firstDistance - endDistance > 0 and mlayer:getScale()>= mScaleSmall then
		-- 			layerScale(midPonit.x, midPonit.y)
		-- 		elseif firstDistance - endDistance < 0 and mlayer:getScale()< mScaleNormal then
		-- 			layerScale(midPonit.x, midPonit.y)
		-- 		end
		-- 	end
		-- end
	end
    return true
end

local function onTouchEnded( touches )
	-- for i=1, 2 do
	-- 	touchBeginesPoint[i] = {x= nil, y=nil}	
	-- end
	
	touchOrigPoint = {x= nil, y= nil}
	touchBeginPoint = {x = nil, y =nil}
	if #touches == 3 then
		if multiTouchHandler then
			return
		end

		local winSize = config.getWinSize()
		local coorX, coorY = touchInMap(winSize.width/2, winSize.height/2)
		if coorX and coorY then
			lockCoorx, lockCoory = coorX, coorY
		end

		local x, y = touchInMap(touches[1], touches[2])
		if not isSimulatingTouch and not isMove and not m_armyTouch and x and y and not newGuideManager.get_guide_state() then
		-- and m_touchPointsCount and m_touchPointsCount <=1 then
			mapController.touchGroundCallback(x, y, touches[1], touches[2])
		end
		isMove = false
		CityMarking.move()
		mapController.removeWaterEdge()
		SmallMiniMap.coordToPicture()
		-- if m_touchEndTime then
		-- 	scheduler.remove(m_touchEndTime)
		-- 	m_touchEndTime = nil
		-- end
		-- m_touchEndTime = scheduler.create(function ( )
		-- 	isMove = false
		-- 	scheduler.remove(m_touchEndTime)
		-- end,0.1)

	end
	return true
end


-- local function onTouch( eventType, touches)
local function onTouch( eventType, x, y)
	if isSimulatingTouch then return false end
	if eventType == "began" then
		multiTouch = true
		ObjectCountDown.setReleaseLockArmy()
		armyMark.removeLockScreenWhenTouch()   
        -- return onTouchBegan(touches)
        return onTouchBegan({x,y,eventType})
    elseif eventType == "moved" then
		-- return onTouchMoved(touches,true)
        return onTouchMoved({x,y,eventType},true)
    elseif eventType == "ended" then
    	-- multiTouch = false
        return onTouchEnded({x,y,eventType})
        -- return onTouchEnded(touches)
    else
    	-- multiTouch = false
    	return true
    end
end

local function onTouchSimulation(eventType, x, y)
	if eventType == "began" then   
		isSimulatingTouch = true
		simulatingMove_beginX = mlayer:getPositionX()
		simulatingMove_beginY = mlayer:getPositionY()
        return onTouchBegan({x,y,eventType})
    elseif eventType == "moved" then
    	isSimulatingTouch = true
        return onTouchMoved({x,y,eventType})
    elseif eventType == "ended" then
    	local ret = onTouchEnded({x,y,eventType})
    	isSimulatingTouch = false
        return ret
    else
    	isSimulatingTouch = false
    	return false
    end
end

local function create(message)
	-- if mlayer then return end
	--弹出框
	
	-- config.loadSmokeAnimationFile()
	m_touchPointsCount = nil
	config.loadRestWarAnimation()
	-- config.loadBirdAnimationFile()
	
	-- local filePath = "gameResources/map/res.png"
	-- local buildingPath = "gameResources/map/cityComponent.png"
	-- local cityPath = "gameResources/map/res.png"
	-- local waterEdgePath = "gameResources/map/mountain.png"
	-- local resPath = "gameResources/map/res.png"
	-- local mountainPath = "gameResources/map/mountain.png"
	-- local waterPath = "gameResources/map/res.png"
	-- local gridPath = "gameResources/map/res.png"
	-- local fogPath = "gameResources/map/res.png"
	-- local additionWallPath = "gameResources/map/mountain.png"
	-- local dibiaoPath = "gameResources/map/mountain.png"
	-- local expandPath = "gameResources/map/res.png"
	-- local zhuzhaPath = "gameResources/map/mountain.png"
	-- if not lockCoorx or (not lockCoory) then
		lockCoorx, lockCoory = math.floor(userData.getMainPos()/10000), userData.getMainPos()%10000
	-- end
	locationX ,locationY = lockCoorx, lockCoory


	initData()
	mapData.initData()

	local winSize = config.getWinSize()
	local rootLayer = CCLayer:create()
	-- rootLayer:setContentSize(CCSize(2048,1536))
	-- rootLayer:setContentSize(CCSize(1,1))
	cc.Director:getInstance():getRunningScene():addChild(rootLayer,MAIN_SCENE)
	rootLayer:setAnchorPoint(cc.p(0,0))
	m_rootLayer = rootLayer

	-- local layer = cc.LayerColor:create(cc.c4b(255,255,255,200),200, 100)
	local layer = CCLayer:create()
	layer:setContentSize(CCSize(200,100))
	mlayer = layer
	-- map.run3DAction(20)
	
	layer:setTouchEnabled(false)
	layer:registerScriptTouchHandler(onTouch,false,layerPriorityList.map_priority)
	rootLayer:addChild(layer)
	layer:setAnchorPoint(cc.p(0,0))
	-- layer:setPosition(cc.p(winSize.width/2-100*mScaleNormal, winSize.height/2-50*mScaleNormal))
	layer:setScale(mScaleNormal)

	local x, y = config.countNodeSpace(config.getWinSize().width/2,config.getWinSize().height/2, 20)
	local point = mlayer:getParent():convertToNodeSpace(cc.p(x,y))
	mlayer:setPosition(cc.p(point.x - 100*mScaleNormal, point.y - 50*mScaleNormal))

	sdkMgr:sharedSkdMgr():registerMultiTouchHandler(function (x1, y1, x2, y2 )
		if isSimulatingTouch or newGuideTouch then return false end
		if x1==0 and y1 == 0 and x2 == 0 and y2 == 0 then
			midPonit = {x= nil, y = nil}
			for i=1, 2 do
				touchBeginesPoint[i] = {x= nil, y=nil}	
			end
		elseif x1==-1 and y1 == -1 and x2 == -1 and y2 == -1 then
			multiTouch = false
			multiTouchMove = false
			scheduler.remove(multiTouchHandler)
			multiTouchHandler = scheduler.create(function ( )
				scheduler.remove(multiTouchHandler)
				multiTouchHandler = nil
			end, 0.2)
		else
			-- if mainBuildScene.isInCity() then
			-- 	local tempDistance = math.sqrt(math.pow((x1 - x2),2)
			-- 						+math.pow((y1 - y2), 2))
			-- 	if not distanceScale then
			-- 		distanceScale = tempDistance
			-- 	else
			-- 		if distanceScale - tempDistance < 20 then

			-- 		end
			-- 	end
			-- 	return
			-- end

			if multiTouch and mlayer then
				multiTouchMove = true
				onTouchMoved({x1, config.getWinSize().height-y1,"moved", x2, config.getWinSize().height-y2, "moved" },true)
			end
		end
	end)

	-- local touchCountLayer = CCLayer:create()
	-- touchCountLayer:setTouchEnabled(true)
	-- touchCountLayer:registerScriptTouchHandler(function ( eventType, touches )
	-- 	if eventType == "began" then
	-- 		-- m_touchPointsCount = m_touchPointsCount + math.floor(#touches/3)
	--     elseif eventType == "ended" or eventType == "canceled" then
	--   --   	m_touchPointsCount = m_touchPointsCount - math.floor(#touches/3)
	-- 		-- if m_touchPointsCount < 0 then
	-- 		-- 	m_touchPointsCount = 0
	-- 		-- end
	-- 		print(">>>>>>>>>>>>>woqwunimabi")
	-- 		for i=1, 2 do
	-- 			touchBeginesPoint[i] = {x= nil, y=nil}	
	-- 		end
	--     end
	--     return true
	-- end,true,layerPriorityList.global_priority)
	-- rootLayer:addChild(touchCountLayer)

	m_pCompareLayer = cc.LayerColor:create(cc.c4b(255,255,255,0),200, 100)
	m_pCompareLayer:setScale(mScaleNormal)
	rootLayer:addChild(m_pCompareLayer)

	-- node:setVisible(false)

	--显示出来的草地
	local grass = CCSpriteBatchNode:create("gameResources/map/additionCity.png")
	layer:addChild(grass)
	-- grass:setVisible(false)

	--丘陵
	-- local mountain = CCSpriteBatchNode:create(mountainPath)
	-- layer:addChild(mountain)
	-- mountain:setVisible(false)
	--水
	-- local water = CCSpriteBatchNode:create(waterPath)
	-- layer:addChild(water)
	-- water:setVisible(false)


	--装饰（水，边缘）
	-- local waterEdge = CCSpriteBatchNode:create(waterEdgePath)
	-- layer:addChild(waterEdge)
	--网格
	-- local gridNode = CCSpriteBatchNode:create(gridPath)
	-- layer:addChild(gridNode)

	--资源
	local resBatchNode = CCSpriteBatchNode:create("gameResources/map/res.png")
	layer:addChild(resBatchNode)
	-- resBatchNode:setVisible(false)

	local animationNode = CCSpriteBatchNode:create("gameResources/map/armyMark.png") 
	layer:addChild(animationNode)
	--扩建的地块
	-- local expandBatch = CCSpriteBatchNode:create(expandPath,9)
	-- layer:addChild(expandBatch)

	--建筑batchnode
	local buildingBatchNode = CCSpriteBatchNode:create("gameResources/map/cityComponent.png")
	layer:addChild(buildingBatchNode)
	
	local zhuzhaNode = CCSpriteBatchNode:create("gameResources/map/additionCity.png")
	layer:addChild(zhuzhaNode)

	local xinshouNode = CCSpriteBatchNode:create("gameResources/map/xinshou_smoke.png")
	layer:addChild(xinshouNode)

	local armyMarkNode = CCSpriteBatchNode:create("gameResources/map/armyMark.png")
	layer:addChild(armyMarkNode)

	--山脉
	-- local cityBatchNode = CCSpriteBatchNode:create(cityPath, 50)
	-- layer:addChild(cityBatchNode)

	--活动的时候的山城
	-- local additionwallBatchNode = CCSpriteBatchNode:create(additionWallPath)
	-- layer:addChild(additionwallBatchNode)

	--点击地块测试
	local touchLayer = cc.Sprite:createWithSpriteFrameName("fixground.png")
	layer:addChild(touchLayer)
	-- touchLayer:setFlipY(true)

	--草
	-- local node = CCSpriteBatchNode:create(filePath)
	-- layer:addChild(node)

	--迷雾
	-- local fogLayer = CCSpriteBatchNode:create(fogPath)
	-- layer:addChild(fogLayer)

	-- local function addImage( path )
	-- 	framcache:addSpriteFramesWithFile(path..".plist", ccahe:textureForKey(path..".png"))
	-- end

	-- for i, v in pairs(scene.getSceneImageList()) do
	-- 	-- addImage( v )
	-- end

	-- m_pSightLayer = TouchGroup:create()--cc.LayerColor:create(cc.c4b(255,255,255,0),200, 100)
	-- layer:addChild(m_pSightLayer)

	m_pSmokeLayer = CCLayer:create()
	m_pSmokeLayer:setContentSize(CCSize(1024,768))
	layer:addChild(m_pSmokeLayer)

	m_pBuildEffectLayer = CCLayer:create()
	m_pBuildEffectLayer:setContentSize(CCSize(1024,768))
	layer:addChild(m_pBuildEffectLayer)

	touchLayer:setVisible(false)
	touchLayer:setAnchorPoint(cc.p(0,0))

	mapData.setTouchLayer(touchLayer)

	-- mapData.setObject(node, buildingBatchNode, layer, cityBatchNode, --[[capital,]] --[[cover,]]waterEdge,resBatchNode,
						-- mountain, --[[grassTran,]]water,gridNode,--[[level1ResNode,]] fogLayer,additionwallBatchNode,grass,expandBatch,zhuzhaNode)--,cityComponent)
	
	mapData.setObject(mlayer, grass, resBatchNode, buildingBatchNode, zhuzhaNode,animationNode,xinshouNode,armyMarkNode)
	mapData.setRootLayer(rootLayer)

	mapController.addMap(0, 0,locationX,locationY)
	userData.setLocation(locationX,locationY)

	LSound.stopMusic()
    LSound.fromOPToEnterGame(5)
	-- rootLayer:addChild(WarFog.create())
	-- WarFog.setScaleRightNow(layer:getScale())

	mapData.requestMapData(locationX, locationY)

	if isLockCoord then
		map.run3DActionWithoutTime(20,0 )
	else
		mlayer:runAction(animation.sequence({cc.DelayTime:create(2),cc.CallFunc:create(function ( )
			map.run3DAction(20 )
		end)}))
	end
	isLockCoord = nil
	CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(mlayer,function ( )
		local cloud = CloudAnimation.getInstance()
		if cloud then
			cloud:runAction(animation.sequence({CCFadeOut:create(1),cc.CallFunc:create(function ( )
				CloudAnimation.remove()
			end)}))
		end

		local bird = BirdAnimation.getInstance()
		if bird then
			bird:runAction(animation.sequence({CCFadeOut:create(1),cc.CallFunc:create(function ( )
				BirdAnimation.remove()
			end)}))
		end
	end,"GAME_ENTER_FORWARD")
end

local function run3DActionWithoutTime(angle )
	if not m_bHasRunAction then
		sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(true)
		m_iAngle = angle
		local orbit = OrbitCamera:create(1,1, 0, 0,-angle, 90, 0)
		m_rootLayer:runAction(animation.sequence({orbit,cc.CallFunc:create(function ( )
			ObjectManager.setObjectLayerVisible()
			BirdAnimation.create()
			CloudAnimation.create()
			userData.on_enter_game_finish()
			mlayer:setTouchEnabled(true)
		end)}))
		m_bHasRunAction = true
		
		-- 删除掉登录相关的资源
		local cache = CCSpriteFrameCache:sharedSpriteFrameCache()	
		local textureCache = CCTextureCache:sharedTextureCache()
		textureCache:removeTextureForKey("test/res/Login.png")
		cache:removeSpriteFramesFromFile("test/res/Login.plist")

		

		TaskData.taskUpdate()
	    mainOption.taskTips()


	    Setting.initState()
	end
end

local function run3DAction(angle)
	if not m_bHasRunAction then
		sdkMgr:sharedSkdMgr():ntSetFloatBtnVisible(true)
		m_iAngle = angle
		local orbit = CCOrbitCamera:create(1,1, 0, 0,-angle, 90, 0)
		m_rootLayer:runAction(animation.sequence({orbit,cc.CallFunc:create(function ( )
			ObjectManager.setObjectLayerVisible()
			BirdAnimation.create()
			CloudAnimation.create()
			userData.on_enter_game_finish()
			mlayer:setTouchEnabled(true)
		end)}))
		m_bHasRunAction = true
		
		-- 删除掉登录相关的资源
		local cache = CCSpriteFrameCache:sharedSpriteFrameCache()	
		local textureCache = CCTextureCache:sharedTextureCache()
		textureCache:removeTextureForKey("test/res/Login.png")
		cache:removeSpriteFramesFromFile("test/res/Login.plist")

		

		TaskData.taskUpdate()
	    mainOption.taskTips()


	    Setting.initState()
	end
end

local function setLocation(x,y )
	locationX,locationY = x,y
end

local function getLocation( )
	return locationX,locationY
end

local function remove( )
	multiTouch = nil
	if multiTouchHandler then
		scheduler.remove(multiTouchHandler)
	end

	sdkMgr:sharedSkdMgr():unregisterMultiTouchHandler()
	multiTouchHandler = nil
	distanceScale = nil
	multiTouchMove = nil
	isSimulatingTouch = nil
	m_touchPointsCount = nil
	touchBeginPoint = nil
	touchBeginesPoint = nil
	newGuideTouch = nil
	locationX = nil
	locationY = nil
	if not isLockCoord then
		lockCoorx = nil
		lockCoory = nil
	end
	clicked = false
	distanceX= nil
	distanceY =nil
	midPonit = {x= nil, y=nil}
	canScale = true
	m_pBlueEffect = nil
	begin_move_x, begin_move_y = nil, nil
	touch = nil  --长时间没有点击
	-- object_begin_move_x, object_begin_move_y = nil, nil
	m_bHasRunAction = nil
	m_iAngle = 0
	m_armyTouch = nil

	if mTouchHandler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(mTouchHandler)
		mTouchHandler = nil
	end

	if m_TouchAnimationHandler then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(m_TouchAnimationHandler)
		m_TouchAnimationHandler = nil
	end

	-- if m_touchEndTime then
	-- 	scheduler.remove(m_touchEndTime)
	-- 	m_touchEndTime = nil
	-- end

	CloudAnimation.remove()
	BirdAnimation.remove()
	if mlayer then
		CCNotificationCenter:sharedNotificationCenter():unregisterScriptObserver(mlayer,"GAME_ENTER_FORWARD")
		MapSpriteManage.remove()
		armyMark.remove()
		ArmyMarchLine.remove()
		ObjectManager.remove()
		-- WarFog.remove()
		WarFogData.deleteStencilByArea()
		mapData.remove()
		mapController.remove()
		-- MapLandInfo.removeAll()
		mlayer:getParent():removeFromParentAndCleanup(true)
		m_rootLayer = nil
		mlayer = nil
		m_pCompareLayer = nil
		-- m_pSightLayer = nil
		m_pSmokeLayer = nil
		m_pBuildEffectLayer = nil
	end
end

local function getInstance( )
	return mlayer
end

-- local function getSightLand( )
-- 	return m_pSightLayer
-- end

local function getNorScale( )
	return mScaleNormal
end

local function getSmokeLayer(  )
	return m_pSmokeLayer
end

local function getBuildEffectLayer( )
	return m_pBuildEffectLayer
end

local function setBlueEffectLayerVisible(flag )
	if m_pBlueEffect then
		m_pBlueEffect:setVisible(flag)
	end
end

local function getIsDoubleClick( )
	return clicked
end

local function setMlayerScale( scale ,callback,duration)
	if not mlayer then return end 
	if not duration then duration = 0.5 end
	if duration == 0 then 
		m_pCompareLayer:setScale(scale)
		mlayer:setScale(scale)
		if callback then callback() end
		return 
	end

	local scaleAction = CCScaleTo:create(duration,scale)
	local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
        m_pCompareLayer:setScale(scale)
    end)
    mlayer:runAction(animation.sequence({scaleAction,finally}))

   	-- if not m_pCompareLayer then return end
   	-- scaleAction = CCScaleTo:create(duration,scale)
   	-- m_pCompareLayer:runAction(animation.sequence({scaleAction}))
end


local function getMapPosScaleOffset( from,to,x,y )
    return mlayer:getPositionX()+ (1- to/from)*(x- mlayer:convertToWorldSpaceAR(cc.p(0,0)).x),
            mlayer:getPositionY()+ (1- to/from)*(y- mlayer:convertToWorldSpaceAR(cc.p(0,0)).y)
end


local function actionTransitEaseSineSpeed(action,speedType)
	if not speedType then return action end
	if speedType == 1 then 
		action = CCEaseSineIn:create( action )
	elseif speedType == 2 then 
		action = CCEaseSineOut:create( action )
	elseif speedType == 3 then 
		action = CCEaseSineInOut:create( action )
	end
	return action
end
-- 3D 视觉调整
-- speedType 1  加速
-- speedType 2  减速
-- speedType 3  加速再减速
local function run3DAngleOffset(angleDiff,callback,duration,speedType)
	if not duration then duration = 0.5 end
	local orbit = CCOrbitCamera:create(duration,1, 0, -m_iAngle, -angleDiff, 90, 0)
	orbit = actionTransitEaseSineSpeed(orbit,speedType)

	local totalAction = animation.sequence({
		orbit,
		cc.CallFunc:create(function ( )				
			if callback then callback() end
			
		end)}
	)
	totalAction = actionTransitEaseSineSpeed(totalAction,speedType)

	m_iAngle = m_iAngle + angleDiff
	m_rootLayer:runAction(totalAction)	
end



-- -- 模拟移动并缩放
-- -- speedType 1  加速
-- -- speedType 2  减速
-- -- speedType 3  加速再减速
-- local function simulatingScaleMove(callback,duration,scaleFrom,scaleTo,toScreenX,toScreenY,speedType,angleOffset)

	
-- 	-- if not isSimulatingTouch then return end
-- 	if not duration then duration = 0.5 end
-- 	local finally = cc.CallFunc:create(function ( )
--         m_pCompareLayer:setScale(scaleTo)
--         mlayer:setScale(scaleTo)
--         if callback then callback() end
--     end)

-- 	local from_x = simulatingMove_beginX
-- 	local from_y = simulatingMove_beginY

-- 	if not toScreenX then 
-- 		toScreenX = config.getWinSize().width/2
-- 	end
-- 	if not toScreenY then 
-- 		toScreenY = config.getWinSize().height/2
-- 	end
-- 	local rootX,rootY = config.countNodeSpace(toScreenX, toScreenY,m_iAngle)
-- 	local to_x,to_y = setChange(scaleFrom,scaleTo,rootX,rootY)


-- 	mlayer:setPosition(cc.p(from_x,from_y))
	


-- 	local moveAction = CCMoveTo:create(duration,ccp(to_x,to_y))
-- 	moveAction = actionTransitEaseSineSpeed(moveAction,3)

-- 	local scaleDelay = cc.DelayTime:create(duration * 0.5)
-- 	local actionAngle = cc.CallFunc:create(function () 
-- 			run3DAngleOffset(angleOffset,nil,duration * 0.5,2)
-- 		end)
-- 	local scaleAction = CCScaleTo:create(duration,scaleTo)
-- 	scaleAction = actionTransitEaseSineSpeed(scaleAction,2)
-- 	scaleAction = animation.sequence({scaleDelay,actionAngle,scaleAction})

-- 	local actionArray = CCArray:create()
--     actionArray:addObject(moveAction)
--     actionArray:addObject(scaleAction)
-- 	local action = CCSpawn:create(actionArray)

-- 	local totalAction = animation.sequence({action,finally})
-- 	totalAction = actionTransitEaseSineSpeed(totalAction,2)
-- 	mlayer:runAction(totalAction)
-- end

local function getAngel(  )
	return m_iAngle
end


local function setCannotMoveTouch( flag )
	newGuideTouch = flag
end

local function setAnchorPoint(ax,ay)
	if not mapData.getObject().layer then return end
	local ori_screen_x = mapData.getObject().layer:convertToWorldSpace(cc.p(0,0)).x
	local ori_screen_y = mapData.getObject().layer:convertToWorldSpace(cc.p(0,0)).y
	local ori_pos_x = mapData.getObject().layer:getPositionX()
	local ori_pos_y = mapData.getObject().layer:getPositionY()
	mapData.getObject().layer:setAnchorPoint(cc.p(ax,ay))
	local cur_screen_x = mapData.getObject().layer:convertToWorldSpace(cc.p(0,0)).x
	local cur_screen_y = mapData.getObject().layer:convertToWorldSpace(cc.p(0,0)).y
	local diff_pos_x = ori_screen_x - cur_screen_x 
	local diff_pos_y = ori_screen_y - cur_screen_y 
	mapData.getObject().layer:setPosition(cc.p(ori_pos_x + diff_pos_x,ori_pos_y + diff_pos_y))
end





-- 清理模拟移动（用于大地图同屏定位）
local function simulateMoveClear(callback,duration)

	local speedType = nil
	local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
    end)


	local moveAction = CCMoveTo:create(duration,ccp(simulatingMove_endX,simulatingMove_endY))
	mlayer:stopAllActions()
	moveAction = actionTransitEaseSineSpeed(moveAction,speedType)
	mlayer:runAction(animation.sequence({moveAction,finally}))
end

-- 模拟移动（用于大地图同屏定位）
local function simulateMove(callback,duration,toScreenX,toScreenY,speedType)
	if not speedType then speedType = 2 end
	local finally = cc.CallFunc:create(function ( )
        if callback then callback() end
        
    end)

	local from_x = simulatingMove_beginX
	local from_y = simulatingMove_beginY

	if not toScreenX then 
		toScreenX = config.getWinSize().width/2
	end
	if not toScreenY then 
		toScreenY = config.getWinSize().height/2
	end
	local rootX,rootY = config.countNodeSpace(toScreenX, toScreenY,m_iAngle)
	local to_x,to_y = getMapPosScaleOffset(mlayer:getScale(),mlayer:getScale(),rootX,rootY)
	simulatingMove_endX = to_x
	simulatingMove_endY = to_y
	mlayer:setPosition(cc.p(from_x,from_y))
	local moveAction = CCMoveTo:create(duration,ccp(to_x,to_y))
	moveAction = actionTransitEaseSineSpeed(moveAction,speedType)
	
	
	totalAction = animation.sequence({moveAction,finally})
	totalAction = actionTransitEaseSineSpeed(totalAction,speedType)
	mlayer:runAction(totalAction)
end


-- 模拟视角切换缩放（用于进出城）
local function simulateAgnleScaleMoveSpwan(callback,duration,scaleFrom,scaleTo,toScreenX,toScreenY,angleOffset)
	local speedType  = 2
	local finally = cc.CallFunc:create(function ( )
        m_pCompareLayer:setScale(scaleTo)
        mlayer:setScale(scaleTo)
        if callback then callback() end
    end)

	local from_x = simulatingMove_beginX
	local from_y = simulatingMove_beginY

	if not toScreenX then 
		toScreenX = config.getWinSize().width/2
	end
	if not toScreenY then 
		toScreenY = config.getWinSize().height/2 
	end
	local rootX,rootY = config.countNodeSpace(toScreenX, toScreenY,m_iAngle + angleOffset)
	local to_x,to_y = getMapPosScaleOffset(scaleFrom,scaleTo,rootX,rootY)

	mlayer:setPosition(cc.p(from_x,from_y))
	


	local moveAction = CCMoveTo:create(duration,ccp(to_x,to_y))
	moveAction = actionTransitEaseSineSpeed(moveAction,speedType)


	local scaleAction = CCScaleTo:create(duration,scaleTo)
	scaleAction = actionTransitEaseSineSpeed(scaleAction,speedType)

	local actionArray = CCArray:create()
    actionArray:addObject(moveAction)
    actionArray:addObject(scaleAction)
	local action = CCSpawn:create(actionArray)
	action = actionTransitEaseSineSpeed(action,speedType)

	local totalAction = animation.sequence({action,finally})
	totalAction = actionTransitEaseSineSpeed(totalAction,speedType)
	mlayer:runAction(totalAction)
	run3DAngleOffset(angleOffset,nil,duration ,speedType)
end

local function setMapVisible(flag )
	if mlayer then
		mlayer:setVisible(flag)
		BirdAnimation.setBirdAnimationVisible(flag)
		CloudAnimation.setCloudAnimationVisible(flag)
	end
end

local function setArmyTouch( flag )
	m_armyTouch = flag
end

local function setSimulatingTouch(flag )
	isSimulatingTouch = flag
end

local function getCompareLayer( )
	return m_pCompareLayer
end

local function isLockMapCoord( flag )
	-- isLockCoord = flag
end

local function getisLockMapCoord(  )
	return false
end

local function setLockMapCoord( x,y )
	-- lockCoorx, lockCoory = x, y
end

local function setDistanceScaleNil( )
	distanceScale = nil
end

map = { create = create,
		remove = remove,
		touchInMap = touchInMap,
		getInstance = getInstance,
		getNorScale = getNorScale,
		setLocation = setLocation,
		getIsDoubleClick = getIsDoubleClick,
		setMlayerScale = setMlayerScale,
		-- getSightLand = getSightLand,
		getLocation = getLocation,
		getSmokeLayer = getSmokeLayer,
		getBuildEffectLayer = getBuildEffectLayer,
		setBlueEffectLayerVisible = setBlueEffectLayerVisible,
		run3DAction = run3DAction,
		getAngel = getAngel,
		touchScreen = touchScreen,
		touchPoint = touchPoint,
		setCannotMoveTouch = setCannotMoveTouch,
		endTouchMove = endTouchMove,
		setAnchorPoint = setAnchorPoint,
		run3DAngleOffset = run3DAngleOffset,
		setMapVisible = setMapVisible,
		onTouchBegan = onTouchBegan,
		onTouchMoved = onTouchMoved,
		onTouchEnded = onTouchEnded,
		onTouchSimulation = onTouchSimulation,
		simulateMove = simulateMove, -- 模拟移动（用于大地图同屏定位）
		simulateMoveClear = simulateMoveClear,
		simulateAgnleScaleMoveSpwan = simulateAgnleScaleMoveSpwan, -- 模拟视角切换缩放移动 （用于进出城）
		setArmyTouch = setArmyTouch,
		setSimulatingTouch = setSimulatingTouch,
		getCompareLayer = getCompareLayer,
		isLockMapCoord = isLockMapCoord,
		setLockMapCoord = setLockMapCoord,
		getisLockMapCoord = getisLockMapCoord,
		run3DActionWithoutTime = run3DActionWithoutTime,
		setDistanceScaleNil = setDistanceScaleNil,
}