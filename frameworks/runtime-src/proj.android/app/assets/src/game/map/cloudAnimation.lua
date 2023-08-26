--云的动画
module("CloudAnimation", package.seeall)
local m_pCloudAnimation = nil
local m_pScheduler = nil
local m_pMoveScherduler = nil
local m_iCount = 0
local m_pPoint = nil
local m_fScale = nil
function setCloudAnimationVisible( flag )
	if m_pCloudAnimation then
		m_pCloudAnimation:setVisible(flag)
	end
end

function deleteScheduler( )
	if m_pScheduler then
		scheduler.remove(m_pScheduler)
		m_pScheduler = nil
	end
end

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
	if not m_pPoint then return false end
	local locationXPos, locationYPos = userData.getLocationPos()
	if not locationYPos or not locationXPos then return false end
	local coorX,coorY = map.getLocation( )
	local x, y =config.getMapSpritePos(locationXPos,locationYPos, coorX,coorY, m_pPoint.x,m_pPoint.y)
		
	local point = map.getInstance():convertToWorldSpace(cc.p(x+m_iCount,y))
	local pointX,pointY = config.countWorldSpace(point.x,point.y,map.getAngel())
	return pointX,pointY
end

local function playAgain( )
	if not m_pCloudAnimation then
		remove()
		create()
	end
end

function create( )
	if m_pMoveScherduler then
		return
	end

	if not map.getInstance() then
		return
	end

	deleteScheduler()

	local winSize = config.getWinSize()
	local picture = "gameResources/cloud/cloud1.png"

	-- math.randomseed(os.time())
	local num=math.random(1,3000)
	local num2 = math.random(1,2000)

	if num <=1000 then
		picture = "gameResources/cloud/cloud2.png"
	elseif num <=2000 then
		picture = "gameResources/cloud/cloud3.png"
	end

	local mapArea = mapData.getMapArea()
	local arrIsMountain = nil
	local arrGround = nil
	for i = mapArea.row_up, mapArea.row_down do
		for j = mapArea.col_left, mapArea.col_right do
			if isInScreen( i, j ) then
				if mapData.getCityType( i, j) then
					if not arrIsMountain then
						arrIsMountain = {}
					end
					table.insert(arrIsMountain,i*10000+j)
				else
					if not arrGround then
						arrGround = {}
					end
					table.insert(arrGround,i*10000+j)
				end
			end
		end
	end

	if not arrIsMountain and not arrGround then return end
	
	local randomNum = math.random(1,10000)

	if arrIsMountain and randomNum > 1000 then
		arrIsMountain = arrIsMountain[math.random(1,#arrIsMountain)]
		m_pPoint = {x =math.floor(arrIsMountain/10000), y = arrIsMountain%10000}
	elseif arrGround and randomNum > 5000 then
		arrGround = arrGround[math.random(1,#arrGround)]
		m_pPoint = {x =math.floor(arrGround/10000), y = arrGround%10000}
	end

	local arrTimeDelay = {}
	for i=1,5 do
		table.insert(arrTimeDelay,i)
	end
	local timeDelay = arrTimeDelay[math.random(1,#arrTimeDelay)]

	m_iCount = 0

	local function setCloud( )
		if not m_pCloudAnimation then return end
		m_iCount = m_iCount + 0.4
		local pointX, pointY  = getPos()
		m_pCloudAnimation:setPosition(cc.p(pointX, pointY))
		cloudScale()
		local scale = getCloudScale()
		local leftTop = {pointX- scale*m_pCloudAnimation:getContentSize().width/2, pointY + scale*m_pCloudAnimation:getContentSize().height/2}
		local rightTop = {pointX+ scale*m_pCloudAnimation:getContentSize().width/2, pointY + scale*m_pCloudAnimation:getContentSize().height/2}
		local leftDown = {pointX- scale*m_pCloudAnimation:getContentSize().width/2, pointY - scale*m_pCloudAnimation:getContentSize().height/2}
		local rightDown = {pointX+ scale*m_pCloudAnimation:getContentSize().width/2, pointY - scale*m_pCloudAnimation:getContentSize().height/2}
		local isVisible = false

		for i ,v in ipairs({leftTop,rightTop,leftDown,rightDown }) do
			if v[1] > 0 and v[1] < config.getWinSize().width and v[2] > 0 and v[2] < config.getWinSize().height then
				isVisible = true
				break
			end
		end

		if isVisible and map.getInstance():isVisible() then
			m_pCloudAnimation:setVisible(true)
		else
			m_pCloudAnimation:setVisible(false)
		end
		-- setCloudAnimationVisible( map.getInstance():isVisible())
	end

	local pointX, pointY  = getPos()
	if not pointX then return end
	m_pCloudAnimation = cc.Sprite:create(picture)
	cc.Director:getInstance():getRunningScene():addChild(m_pCloudAnimation,FLY_SCENE)
	m_pCloudAnimation:setPosition(cc.p(pointX,pointY))
	m_pCloudAnimation:setOpacity(0)
	m_pCloudAnimation:setScale( config.getgScale()*config.scaleIn3D(m_pCloudAnimation:getPositionX(), m_pCloudAnimation:getPositionY(), map.getAngel()))
	local action = animation.sequence({cc.DelayTime:create(timeDelay),cc.CallFunc:create(function ( )
		m_pMoveScherduler = scheduler.create(setCloud, 0.01)
	end),CCFadeIn:create(3), cc.DelayTime:create(28), CCFadeOut:create(3),
				 cc.CallFunc:create(function( )
				 	remove()
				 -- 	local textureCache = CCTextureCache:sharedTextureCache()
					-- textureCache:removeTextureForKey(picture)
				 	if map.getInstance() then
					 	m_pScheduler = scheduler.create(function  ()
					 		playAgain()
					 	end,30)
					end
				 end)})
	m_pCloudAnimation:runAction(action)
end

function cloudMove()
	if not m_pMoveScherduler then
		remove()
	end
end

function cloudScale( )
	if m_pCloudAnimation then
		m_fScale = map.getInstance():getScale()*config.scaleIn3D(m_pCloudAnimation:getPositionX(), m_pCloudAnimation:getPositionY(), map.getAngel())
		m_pCloudAnimation:setScale( m_fScale)
		setCloudAnimationVisible( map.getInstance():isVisible())
	end
end

function getCloudScale( )
	return m_fScale
end

function remove( )
	if m_pCloudAnimation then
		m_pCloudAnimation:removeFromParentAndCleanup(true)
		m_pCloudAnimation = nil
		m_iCount = 0
		m_pPoint = nil
		m_fScale = nil
		if m_pMoveScherduler then
			scheduler.remove(m_pMoveScherduler)
			m_pMoveScherduler = nil
		end

		deleteScheduler()
	end
end

function getInstance( )
	return m_pCloudAnimation
end