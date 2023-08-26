--鸟的动画
module("BirdAnimation", package.seeall)
local m_pBirdAnimation = nil
local m_pScheduler = nil
local m_pNodePoint = nil
local m_bStarAnimation = nil

local function isInScreen( coorX, coorY )
	local pSprite = mapData.getLoadedMapLayer(coorX, coorY)
	if not pSprite then return false end
	local winSize = config.getWinSize()
	local point = map.getInstance():convertToWorldSpace(cc.p(pSprite:getPositionX(),pSprite:getPositionY()))
	local pointX,pointY = config.countWorldSpace(point.x,point.y,map.getAngel())
	if pointX < winSize.width and pointX > 0 and pointY < winSize.height and pointY > 0 then
		return true
	end
	return false
end

local function getPos(  )
	if not m_pNodePoint then return false end
	local locationXPos, locationYPos = userData.getLocationPos()
	if not locationYPos or not locationXPos then return false end
	local coorX,coorY = map.getLocation( )
	local x, y =config.getMapSpritePos(locationXPos,locationYPos, coorX,coorY, m_pNodePoint.x,m_pNodePoint.y)
		
	local point = map.getInstance():convertToWorldSpace(cc.p(x,y))
	local pointX,pointY = config.countWorldSpace(point.x,point.y,map.getAngel())
	return pointX,pointY
end

local function playAgain( )
	if not m_pBirdAnimation then
		remove()
		create()
	end
end

function deleteSchedler(  )
	if m_pScheduler then
		scheduler.remove(m_pScheduler)
		m_pScheduler = nil
	end
end

function create( )
	if not map.getInstance() then
		return
	end

	if m_pBirdAnimation then
		return
	end

	deleteSchedler()

	-- math.randomseed(os.time())
	local num2 = math.random(1,3000)
	
	local x,y = nil, nil
	local rotation = 0

	local mapArea = mapData.getMapArea()
	local arrIsMountainOrCity = nil
	local arrGround = nil
	for i = mapArea.row_up, mapArea.row_down do
		for j = mapArea.col_left, mapArea.col_right do
			if isInScreen( i, j ) then
				local cityType = mapData.getCityTypeData(i,j )
				if mapData.getCityType( i, j) or (mapData.getCityTypeData(i,j ) 
					and cityType and cityType ~=cityTypeDefine.lingdi ) then
					if not arrIsMountainOrCity then
						arrIsMountainOrCity = {}
					end
					table.insert(arrIsMountainOrCity,i*10000+j)
				else
					if not arrGround then
						arrGround = {}
					end
					table.insert(arrGround,i*10000+j)
				end
			end
		end
	end

	local randomNum = math.random(1,10000)
	if arrIsMountainOrCity and randomNum > 2500 then
		arrIsMountainOrCity = arrIsMountainOrCity[math.random(1,#arrIsMountainOrCity)]
		m_pNodePoint = {x =math.floor(arrIsMountainOrCity/10000), y = arrIsMountainOrCity%10000}
	elseif arrGround and randomNum > 7000 then
		arrGround = arrGround[math.random(1,#arrGround)]
		m_pNodePoint = {x =math.floor(arrGround/10000), y = arrGround%10000}
	end

	if not arrIsMountainOrCity and not arrGround then return end

	if num2 <=1000 then
		rotation = 15
	elseif num2 <=2000 then
		rotation = -15
	end

	local arrTimeDelay = {}
	for i=1,5 do
		table.insert(arrTimeDelay,i)
	end
	local timeDelay = arrTimeDelay[math.random(1,#arrTimeDelay)]

	local pointX, pointY  = getPos()
	if not pointX then return end
	config.loadBirdAnimationFile()
	m_pBirdAnimation = CCArmature:create("bird")
	cc.Director:getInstance():getRunningScene():addChild(m_pBirdAnimation,FLY_SCENE)
	local action = animation.sequence({cc.DelayTime:create(timeDelay),cc.CallFunc:create(function ( )
					if m_pBirdAnimation then
						m_bStarAnimation = true
						m_pBirdAnimation:getAnimation():playWithIndex(0)
						birdMove()
						m_pBirdAnimation:setRotation(rotation)
						m_pBirdAnimation:getAnimation():setMovementEventCallFunc(function (armature, eventType, name)
							if eventType == 1 then
								remove()
								m_bStarAnimation = false
								if map.getInstance() then
									m_pScheduler = scheduler.create(playAgain, 30)
								end			
							end
						end)
					end
				end)})
	m_pBirdAnimation:runAction(action)
end

function birdMove( )
	if not m_pBirdAnimation then return end
	if not map.getInstance() then return end
	if not m_pNodePoint then return end
	if not m_bStarAnimation then remove() return end
	local pointX, pointY  = getPos()
	m_pBirdAnimation:setPosition(cc.p(pointX, pointY))
	if pointX < 0 or pointX > config.getWinSize().width or pointY < 0 or pointY > config.getWinSize().height then
		m_pBirdAnimation:setVisible(false)
	else
		m_pBirdAnimation:setVisible(true)
	end

	m_pBirdAnimation:setVisible(map.getInstance():isVisible())

	m_pBirdAnimation:setScale( config.getgScale()*config.scaleIn3D(m_pBirdAnimation:getPositionX(), m_pBirdAnimation:getPositionY(), 20))
end

function remove( )
	if m_pBirdAnimation then
		m_pBirdAnimation:removeFromParentAndCleanup(true)
		m_pBirdAnimation = nil
		m_pNodePoint = nil
		m_bStarAnimation = nil
		deleteSchedler(  )
		-- config.removeBirdAnimationFile()
	end
end

function getInstance( )
	return m_pBirdAnimation
end

function setBirdAnimationVisible( flag )
	if m_pBirdAnimation then
		m_pBirdAnimation:setVisible(flag)
	end
end
	
