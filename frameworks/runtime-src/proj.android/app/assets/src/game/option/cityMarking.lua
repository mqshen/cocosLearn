--玩家主城，分城，要塞，npc城标示
module("CityMarking", package.seeall)
local m_mainLayer = nil
local arrMarking = nil
--屏幕中点坐标（coorX, coorY）
--目标点坐标(wid)
local function isInDisplayArea(coorX, coorY, wid )
	local winSize = config.getWinSize()
	local x = math.floor(wid/10000)
	local y = wid%10000
	if math.abs(x - coorX) < 50 and math.abs(y - coorY) < 50 then
		-- local loadSprite = mapData.getLoadedMapLayer(x, y)
		-- if not loadSprite then
		-- 	return true
		-- end
		local locationX, locationY = userData.getLocation()
		local locationXPos, locationYPos = userData.getLocationPos()
		local targetLos = {x = locationXPos + ((x- locationX) + (y - locationY))*0.5*200,
							y = locationYPos + ((y - locationY) - (x - locationX))*0.5*100}
		local temp_point = map.getInstance():convertToWorldSpace(cc.p(targetLos.x+100, targetLos.y+50))
		local real_point_x, real_point_y = config.countWorldSpace(temp_point.x,temp_point.y,map.getAngel())
		if real_point_x > winSize.width*0.2 and real_point_x < winSize.width
			and real_point_y > winSize.height*0.2 and real_point_y < winSize.height*0.8 then
			return false
		end
		return true
	else
		return false
	end
end

function remove(  )
	if m_mainLayer then
		m_mainLayer:removeFromParentAndCleanup(true)
		m_mainLayer = nil
		arrMarking = nil
	end
end

function create( )
	arrMarking = {}
	m_mainLayer = TouchGroup:create()
	cc.Director:getInstance():getRunningScene():addChild(m_mainLayer,CITY_DISTANCE)
	m_mainLayer:setVisible(false)
	-- move()
	m_mainLayer:runAction(animation.sequence({cc.DelayTime:create(3), cc.CallFunc:create(function ( )
		move()
	end)}))
end

function setVisi( flag )
	if m_mainLayer then
		m_mainLayer:setVisible(flag)
	end
end

local function initWidget(widget )
	-- body
end

function move( )
	if not m_mainLayer then return end
	local winSize = config.getWinSize()
	local coorX, coorY  = map.touchInMap(winSize.width/2, winSize.height/2)
	if not coorX or not coorY then return end
	local arrMarkPos = {}
	for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
		if v.state == cityState.normal then
			if (v.city_type == cityTypeDefine.zhucheng or v.city_type ==cityTypeDefine.fencheng
			or v.city_type == cityTypeDefine.yaosai ) and isInDisplayArea(coorX, coorY, v.city_wid ) then
				table.insert(arrMarkPos, {v.city_wid, v.city_type})
			end
		end
	end

	local arrDisplayPos = {}
	for i,v in pairs(Tb_cfg_world_city) do
		if v.city_type == cityTypeDefine.npc_cheng then
		-- if v.wid == 7510751 then
			if isInDisplayArea(coorX, coorY, v.wid ) then
				table.insert(arrDisplayPos,{v.wid, v.city_type})
			end
		end
	end

	-- for i,v in pairs(arrMarkPos) do
	-- 	if isInDisplayArea(coorX, coorY, v[1] ) then
	-- 		table.insert(arrDisplayPos,{v[1], v[2]})
	-- 	end
	-- end

	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	if not locationX or not locationY or not locationXPos or not locationYPos then return end
	if not map.getInstance() then return end
	local x, y = nil, nil
	local posX, posY = nil, nil
	-- local midX, midY = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, coorX, coorY  )
	local temp_point = nil--map.getInstance():convertToWorldSpace(cc.p(midX, midY))
	local real_point_x, real_point_y = nil, nil--config.countWorldSpace(temp_point.x,temp_point.y,map.getAngel())
	local rotation = nil
	local midPoint = {x = winSize.width/2, y =winSize.height/2 }

	local point_0_1 = {x =winSize.width*0.2, y = winSize.height*0.8}
	local point_1_1 = {x =winSize.width*0.8, y = winSize.height*0.8}
	local point_0_0 = {x =winSize.width*0.2, y = winSize.height*0.2}
	local point_1_0 = {x =winSize.width*0.8, y = winSize.height*0.2}
	local arrPoint = {}

	for i= 1,4 do
		if i == 1 then 
			table.insert(arrPoint,{point_0_1, point_1_1})
		elseif i == 2 then
			table.insert(arrPoint,{point_0_0, point_1_0})
		elseif i ==3 then
			table.insert(arrPoint,{point_0_1, point_0_0})
		else
			table.insert(arrPoint,{point_1_1, point_1_0})
		end
		
	end

	local count = #arrMarking
	local num = 0
	local widget = nil
	local temp_x, temp_y = nil, nil
	for i, v in ipairs(arrDisplayPos) do
		x, y = math.floor(v[1]/10000), v[1]%10000
		posX, posY = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, x, y  )
		temp_point = map.getInstance():convertToWorldSpace(cc.p(posX+100, posY+50))
		real_point_x, real_point_y = config.countWorldSpace(temp_point.x,temp_point.y,map.getAngel())
		rotation = animation.pointRotate({x= midPoint.x, y=midPoint.y}, {x= real_point_x, y = real_point_x })
		for m, n in ipairs(arrPoint) do
			if config.intersect(midPoint, {x=real_point_x, y = real_point_y},n[1],n[2]) then
				num = num + 1
				temp_x, temp_y = config.cross(midPoint, {x=real_point_x, y = real_point_y},n[1],n[2] )
				-- if x == 651 and y == 817 then
				-- 	print(">>>>>>>>>>>>>1111111 ="..temp_x.."   afdaf= "..temp_y)
				-- end

				-- if x == 646 and y == 815 then
				-- 	print(">>>>>>>>>>>>>rotation="..rotation.."      x="..temp_x.."  y="..temp_y)
				-- end
				if num > count then
					if not widget then
						widget = ImageView:create()
						widget:loadTexture(ResDefineUtil.enemy_station_flag,UI_TEX_TYPE_PLIST)
						widget:setAnchorPoint(cc.p(28/widget:getContentSize().width,22/widget:getContentSize().height))
					else
						widget = widget:clone()
					end
					table.insert(arrMarking,widget)
					m_mainLayer:addWidget(widget)
				end
				initWidget(arrMarking[num])
				arrMarking[num]:setPosition(cc.p(temp_x, temp_y))
				arrMarking[num]:setRotation(-rotation+90)
				arrMarking[num]:setScale(config.getgScale())
				break
			end
		end
	end

	if num < count then
		for i=num + 1, count do
			arrMarking[i]:removeFromParentAndCleanup(true)
			arrMarking[i] = nil
			-- table.remove(arrMarking, i )
		end
	end
end