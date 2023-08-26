--地图物体的管理，譬如倒计时，出征条，路径之类
-- objectManager.lua
module("ObjectManager", package.seeall)
local m_pObjectLayer = nil
local m_tObjectCallFun = nil
local m_parentGroup = nil
local m_bDisplayDetail = nil
if CCUserDefault:sharedUserDefault():getStringForKey("army_move_state") == "1" then
	m_bDisplayDetail = true
end


function getInstance(  )
	return m_pObjectLayer
end

function setObjectVisible( flag )
	if m_pObjectLayer then
		m_pObjectLayer:setVisible(flag)
	end
end

function setObjectLayerVisible( flag)
	if m_pObjectLayer then
		if not flag and not mainBuildScene.getRootLayer() then
			m_pObjectLayer:setVisible(true)
		else
			m_pObjectLayer:setVisible(false)
		end
		ObjectManager.objectMove()
	end
end

function create( )
	remove()
	m_tObjectCallFun = {}
	m_parentGroup = TouchGroup:create()
	m_pObjectLayer = Layout:create()--TouchGroup:create()
	m_parentGroup:addWidget(m_pObjectLayer)
	cc.Director:getInstance():getRunningScene():addChild(m_parentGroup,OBJECT_SCENE)
	m_pObjectLayer:setVisible(false)
	ObjectCountDown.init()
	GroundEvent.create()
	flagLandMark.create()
end

function remove( )
	if m_pObjectLayer then
		BuildCityAnimation.removeAll()
		ObjectNewGuideObject.removeAllObject()
		ObjectCountDown.remove()
		flagLandMark.remove()
		MapLandInfo.removeAll()
		MapArmyWarStatus.removeAll()
		CityName.removeAll()
		GroundEvent.remove()
		MapObjectPool.remove()
		m_parentGroup:removeFromParentAndCleanup(true)
		m_parentGroup = nil
		m_pObjectLayer = nil
		m_tObjectCallFun = nil
		m_pObjectLayer = nil
		m_bDisplayDeatail = nil
	end
end

function objectMove()
	if map.getInstance() then
		postMoveCallBack()
		
	end
end

function setObjectPos(object,x,y, isFlip )
	if not map.getInstance() then return end
	if not object then return end
	local point = map.getInstance():convertToWorldSpace(cc.p(x,y))
	local px, py = config.countWorldSpace(point.x, point.y, map.getAngel())
	local nodePoint = m_pObjectLayer:convertToNodeSpace(cc.p(px, py))
	object:setPosition(nodePoint)
	local winsize = config.getWinSize()
	if px+object:getContentSize().width >= 0 and px-object:getContentSize().width <= winsize.width and py+object:getContentSize().height >= 0 and py-object:getContentSize().height <= winsize.height then
		object:setVisible(true)
		object:setScale(map.getInstance():getScale()*config.scaleIn3D(px, py, map.getAngel()))
		-- if isFlip then
		-- 	object:setScaleX(-1*map.getInstance():getScale()*config.scaleIn3D(px, py, 20))
		-- end
	else
		object:setVisible(false)
	end
end

-- function addPoolObject( index,object, isWidget, x, y, isFlip, isAdd)
-- 	if not map.getInstance() then return end
-- 	setObjectPos(object,x,y,isFlip )
-- 	if isAdd then
-- 		m_pObjectLayer:addChild(object,index)
-- 	end
-- end

--把object加入管理层
function addObject( index,object, isWidget, x, y, isFlip, isnotAdd)
	if not map.getInstance() then return end
	setObjectPos(object,x,y,isFlip )
	-- if isWidget then
	-- 	m_pObjectLayer:addWidget(object)
	-- 	object:setZOrder(index)
	-- else
	-- 	m_pObjectLayer:addChild(object,index)
	-- end
	if not isnotAdd then
		m_pObjectLayer:addChild(object,index)
	end
end

function addObjectCallBack(index, moveCallback, jumpCallback)
	-- table.insert(m_tObjectCallFun, callback)
	if not m_pObjectLayer then return end
	m_tObjectCallFun[index] = {moveCallback,jumpCallback}
end

function postMoveCallBack()
	if not m_pObjectLayer then return end
	for i, v in pairs(m_tObjectCallFun) do
		if v[1] then
			v[1]()
		end
	end
end

function postJumpCallBack(coorX, coorY)
	if not m_pObjectLayer then return end
	
	for i, v in pairs(m_tObjectCallFun) do
		if v[2] then
			v[2](coorX, coorY)
		end
	end
end

function getIsDisplay( )
	return false--m_bDisplayDetail
end

function setDisplayDetail( flag )
	-- m_bDisplayDetail = flag
	-- MapLandInfo.reloadAll()
	-- ObjectCountDown.create()	
	-- CityName.reloadAll()
	-- armyMark.organizeMarkInfo()
end