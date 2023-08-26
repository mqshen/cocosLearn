-- armyMarchLine.lua
-- 部队行军的路线
module("ArmyMarchLine", package.seeall)
local m_marchLineData = nil

function remove( )
	if m_marchLineData then
		m_marchLineData:removeFromParentAndCleanup(true)
		m_marchLineData = nil
	end
end

-- marchLineData
-- marchLineData = {
	-- start_wid = nil
	-- end_wid = nil
-- }
function create( marchLineData)
	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local start_x = math.floor(marchLineData.start_wid/10000)
	local start_y = marchLineData.start_wid%10000
	local end_x = math.floor(marchLineData.end_wid/10000)
	local end_y = marchLineData.end_wid%10000

	local resideLos = {x = nil, y=nil}
	resideLos.x, resideLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, start_x, start_y)
		
	local targetLos = {x= nil, y = nil}

	targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, end_x, end_y)

	local length = math.sqrt(math.pow((resideLos.x - targetLos.x),2) + math.pow((resideLos.y - targetLos.y),2))
	local line_layer = TouchGroup:create()
	local pColor = nil
	local width = 35
	local dt = 0
	local count = math.floor(length/(width+dt))
	local rotation = animation.pointRotate({x= resideLos.x, y=resideLos.y}, {x= targetLos.x, y = targetLos.y })
	for m=1, count do
		pColor = ImageView:create()
		pColor:loadTexture(ResDefineUtil.March_route_Icon_2,UI_TEX_TYPE_PLIST)

		pColor:setRotation(180)
		line_layer:addWidget(pColor)
		pColor:setPosition(cc.p(dt+width/2+m*(width + dt), pColor:getContentSize().height/2))
	end

	if pColor then
		line_layer:setContentSize(CCSize(length, pColor:getContentSize().height))
	end

	line_layer:ignoreAnchorPointForPosition(false)
	line_layer:setAnchorPoint(cc.p(0,0.5))
	line_layer:setRotation(-rotation)
	line_layer:setPosition(cc.p(resideLos.x+100, resideLos.y+50))

	local map_layer = map.getInstance()
	if map_layer then
		map_layer:addChild(line_layer)
		map_layer:reorderChild(line_layer,6)
	end

	line_layer:runAction( CCRepeatForever:create(animation.sequence({CCFadeOut:create(1.6),CCFadeIn:create(1.6) })))
	m_marchLineData = line_layer
end