local markShowList = {}
local timeShowList = {}
local timer = nil
local m_sched_timer = nil
local m_tLineSpriteList = {}
local m_begin_flag_data = {}
local m_loacScreenArmyId = nil
local first_move = nil
local m_global_x = nil
local m_global_y = nil
-- local m_armyNeedDisplay = {}

local function setLockScreenArmyWhenScale(armyid,object,timeLabel )
	if (not m_loacScreenArmyId or m_loacScreenArmyId ~= armyid ) and 0.1 < map.getInstance():getScale() - map.getNorScale() then
		if object:isVisible() then
			if not object:getActionByTag(12) then
				object:stopAllActions()
				local action = animation.sequence({CCFadeOut:create(0.3), cc.CallFunc:create(function ( )
					object:setVisible(false)
				end)})
				action:setTag(12)
				object:runAction(action)

				timeLabel:stopAllActions()
				action = animation.sequence({CCFadeOut:create(0.3), cc.CallFunc:create(function ( )
					timeLabel:setVisible(false)
				end)})
				timeLabel:runAction(action)
			end
		else
			timeLabel:setVisible(false)
			object:setVisible(false)
		end
	else
		if not object:isVisible() then
			if not object:getActionByTag(13) then
				object:setOpacity(0)
				local action = CCFadeIn:create(0.3)
				action:setTag(13)
				object:runAction(action)

				timeLabel:setOpacity(0)
				action = CCFadeIn:create(0.3)
				timeLabel:runAction(action)
			end
		end
		timeLabel:setVisible(true)
		object:setVisible(true)
	end
end

local function getTimeShowList( )
	return timeShowList
end

local function resetMarkInfo()
	if timer then
		scheduler.remove(timer)
		timer = nil
	end

	if m_sched_timer then
		-- for i, v in pairs(m_sched_timer) do
			scheduler.remove(m_sched_timer)
			m_sched_timer = nil
		-- end
	end

	if markShowList then
		for k,v in pairs(markShowList) do
			if v[4] then
				v[4]:removeFromParentAndCleanup(true)
			end
		end
	end

	if timeShowList then
		for i,v in pairs(timeShowList) do
			if v.object then
				v.object:removeFromParentAndCleanup(true)
			end
		end
	end

	if m_begin_flag_data then
		for i, v in pairs(m_begin_flag_data) do
			if v.sprite then
				v.sprite:removeFromParentAndCleanup(true)
			end
		end
	end

	m_loacScreenArmyId = nil
	markShowList = {}
	timeShowList = {}
	m_sched_timer = nil
	first_move = nil
	m_tLineSpriteList = {}
	m_begin_flag_data = {}
	m_global_x = nil
	m_global_y = nil
	-- m_armyNeedDisplay = {}

	-- for i=1, 5 do
	-- 	CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/xingjunbudui_"..i..".ExportJson")
	-- end
end

local function setLineVisible( flag )
	if markShowList then
		for k,v in pairs(markShowList) do
			if v[4] then
				v[4]:setVisible(flag)
			end
		end
	end
end

local function resetLinePosition(coorX, coorY)
	local sprite = mapData.getLoadedMapLayer(coorX, coorY)
	local posx,posy = userData.getLocationPos()

	local line_pos_x, line_pos_y = nil, nil
	local line_start_x, line_start_y = nil, nil
	for k,v in pairs(markShowList) do
		line_start_x = math.floor(v[1]/10000)
		line_start_y = v[1]%10000
		line_pos_x,line_pos_y = config.getMapSpritePos(posx,posy, coorX,coorY, line_start_x,line_start_y  )
		-- line_pos_x = posx + ((line_start_x - coorX) + (line_start_y - coorY)) * 0.5 * 200
		-- line_pos_y = posy + ((line_start_y - coorY) - (line_start_x - coorX)) * 0.5 * 100
		if v[4] then
			v[4]:setPosition(cc.p(line_pos_x + 100, line_pos_y + 50))
		end
	end
end

local function setFlagPosWhenMove(  )
	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local targetLos = nil
	local end_x = nil
	local end_y = nil
	for i, v in pairs(m_begin_flag_data) do
		if v.sprite then
			end_x, end_y = math.floor(v.target_wid/10000), v.target_wid%10000
			-- targetLos = {x = locationXPos + ((end_x- locationX) + (end_y - locationY))*0.5*200,
			-- 				y = locationYPos + ((end_y - locationY) - (end_x - locationX))*0.5*100}
			targetLos = {x = nil, y = nil}
			targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX,locationY, end_x,end_y  )
			ObjectManager.setObjectPos(v.sprite,targetLos.x + 100, targetLos.y + 50 )
		end
	end
end

local function resetFlagPosition( coorX, coorY )
	-- local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local targetLos = nil
	local end_x = nil
	local end_y = nil
	for i, v in pairs(m_begin_flag_data) do
		if v.sprite then
			end_x, end_y = math.floor(v.target_wid/10000), v.target_wid%10000
			-- targetLos = {x = locationXPos + ((end_x- coorX) + (end_y - coorY))*0.5*200,
			-- 				y = locationYPos + ((end_y - coorY) - (end_x - coorX))*0.5*100}
			targetLos = {x = nil, y = nil}
			targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, coorX,coorY, end_x,end_y  )
			ObjectManager.setObjectPos(v.sprite,targetLos.x + 100, targetLos.y + 50 )
		end
	end
end

local function resetTimePosition( coorX, coorY)
	local locationXPos, locationYPos = userData.getLocationPos()
	local start_x  = nil
	local start_y = nil
	local end_x = nil
	local end_y = nil
	local resideLos = {x=nil, y= nil}
	local targetLos = {x=nil, y= nil}
	local posx,posy = nil, nil
	local frame = nil--math.floor(1/cc.Director:getInstance():getAnimationInterval())
	if platform == kTargetIpad or platform == kTargetIphone then
		frame = 30
	else
		frame = math.floor(1/cc.Director:getInstance():getAnimationInterval())
	end
	for i, v in pairs(timeShowList) do
		start_x = math.floor(v.wid/10000)
		start_y = v.wid%10000
		end_x = math.floor(v.end_wid/10000)
		end_y = v.end_wid%10000

		-- resideLos = {x = locationXPos + ((start_x - coorX) + (start_y - coorY))*0.5*200,
		-- 					y = locationYPos + ((start_y - coorY) - (start_x - coorX))*0.5*100}
		resideLos.x, resideLos.y = config.getMapSpritePos(locationXPos,locationYPos, coorX, coorY, start_x, start_y)
		-- targetLos = {x = locationXPos + ((end_x- coorX) + (end_y - coorY))*0.5*200,
		-- 				y = locationYPos + ((end_y - coorY) - (end_x - coorX))*0.5*100}
		targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, coorX, coorY, end_x, end_y)
		local temp_per = (v.end_time*frame - v.nowTime)/(v.alltime*frame)
		temp_per = temp_per + v.framePercent*((frame -v.frameTime)/frame)
		if temp_per > 1 then
			temp_per = 1 
		end

		if temp_per < 0 then
			temp_per = 0
		end

		percent = 1-temp_per
		-- percent = math.abs(1-(v.end_time - userData.getServerTime())/v.alltime)
		posx = (targetLos.x - resideLos.x-v.offsetX )*percent
		posy = (targetLos.y - resideLos.y-v.offsetY )*percent
		ObjectManager.setObjectPos(v.object,v.offsetX+resideLos.x + posx + 100, v.offsetY+resideLos.y + posy+50, v.isFlip)
		-- local point = map.getInstance():convertToWorldSpace(cc.p(resideLos.x + posx + 100,resideLos.y + posy+50))
		-- local px, py = config.countWorldSpace(point.x, point.y, 20)
		setLockScreenArmyWhenScale(i,v.armature,v.timeLabel )

		if v.isFlip then
			v.armature:setScaleX(-1)
		end
	end
end

local function armyMoveAnimation( )
	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local start_x  = nil
	local start_y = nil
	local end_x = nil
	local end_y = nil
	local resideLos = {x=nil, y= nil}
	local targetLos = {x=nil, y= nil}
	local posx,posy = nil, nil
	local platform = cc.Application:getInstance():getTargetPlatform()
	local frame = nil--math.floor(1/cc.Director:getInstance():getAnimationInterval())
	if platform == kTargetIpad or platform == kTargetIphone then
		frame = 30
	else
		frame = math.floor(1/cc.Director:getInstance():getAnimationInterval())
	end

	for i, v in pairs(timeShowList) do
		if v.end_time - userData.getServerTime() >= 0 then
			start_x = math.floor(v.wid/10000)
			start_y = v.wid%10000
			end_x = math.floor(v.end_wid/10000)
			end_y = v.end_wid%10000

			resideLos.x, resideLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, start_x, start_y)
			targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, end_x, end_y)
			local temp_per = (v.end_time*frame - v.nowTime)/(v.alltime*frame)
			temp_per = temp_per + v.framePercent*((frame -v.frameTime)/frame)
			if temp_per > 1 then
				temp_per = 1 
			end

			if temp_per < 0 then
				temp_per = 0
			end

			percent = 1-temp_per
			posx = (targetLos.x - resideLos.x-v.offsetX )*percent
			posy = (targetLos.y - resideLos.y-v.offsetY )*percent

			ObjectManager.setObjectPos(v.object,v.offsetX+resideLos.x + posx + 100, v.offsetY+resideLos.y + posy+50, v.isFlip)
			-- tolua.cast(v.timeLabel:getChildByName("Label_78708"),"LabelAtlas"):setStringValue(commonFunc.format_time(v.end_time - userData.getServerTime(),true))
			-- tolua.cast(v.timeLabel:getChildByName("loading_bar_0"),"LoadingBar"):setPercent(100*(1-(v.end_time - userData.getServerTime())/v.alltime))
			setLockScreenArmyWhenScale(i,v.armature,v.timeLabel )
			if v.isFlip then
				v.armature:setScaleX(-1)
			end
		end
	end
end

local function setTimePosWhenMove( )
	local locationX, locationY = userData.getLocation()
	local locationXPos, locationYPos = userData.getLocationPos()
	local start_x  = nil
	local start_y = nil
	local end_x = nil
	local end_y = nil
	local resideLos = {x=nil, y= nil}
	local targetLos = {x=nil, y= nil}
	local posx,posy = nil, nil
	local platform = cc.Application:getInstance():getTargetPlatform()
	local frame = nil--math.floor(1/cc.Director:getInstance():getAnimationInterval())
	if platform == kTargetIpad or platform== kTargetIphone then
		frame = 30
	else
		frame = math.floor(1/cc.Director:getInstance():getAnimationInterval())
	end

	for i, v in pairs(timeShowList) do
		if v.end_time - userData.getServerTime() >= 0 then
			start_x = math.floor(v.wid/10000)
			start_y = v.wid%10000
			end_x = math.floor(v.end_wid/10000)
			end_y = v.end_wid%10000
			if userData.getServerTime() ~= v.nowTime then
				v.nowTime = userData.getServerTime()
				v.frameTime = 0
			end
			v.frameTime = v.frameTime + 1

			resideLos.x, resideLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, start_x, start_y)
			targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, end_x, end_y)
			local temp_per = (v.end_time - userData.getServerTime())/(v.alltime)
			temp_per = temp_per + v.framePercent*((frame -v.frameTime)/frame)

			if temp_per > 1 then
				temp_per = 1 
			end

			if temp_per < 0 then
				temp_per = 0
			end

			percent = 1-temp_per
			posx = (targetLos.x - resideLos.x-v.offsetX )*percent
			posy = (targetLos.y - resideLos.y-v.offsetY )*percent

			ObjectManager.setObjectPos(v.object,v.offsetX+resideLos.x + posx + 100, v.offsetY+resideLos.y + posy+50, v.isFlip)

			tolua.cast(v.timeLabel:getChildByName("Label_78708"),"LabelAtlas"):setStringValue(commonFunc.format_time(v.end_time - userData.getServerTime(),true))
			tolua.cast(v.timeLabel:getChildByName("loading_bar_0"),"LoadingBar"):setPercent(100*(1-(v.end_time - userData.getServerTime())/v.alltime))
			
			if v.isFlip then
				v.armature:setScaleX(-1)
			end

			setLockScreenArmyWhenScale(i,v.armature,v.timeLabel )

			if m_loacScreenArmyId and m_loacScreenArmyId == i then
				local point = map.getInstance():convertToWorldSpace(cc.p(resideLos.x + posx + 100,resideLos.y + posy+50))
				local px, py = config.countWorldSpace(point.x, point.y, map.getAngel())
				local flag = false
				if not m_global_x then
					flag = true
				end
				m_global_x = px
				m_global_y = py
				
				if flag then
					armyMark.setAnimationMove()
					if m_global_x >= 0 and m_global_x<= config.getWinSize().width and m_global_y >= 0 and m_global_y <= config.getWinSize().height then 
						armyListManager.dealWithSelectArmy(m_loacScreenArmyId)
					end
				end
			end
		else
			-- if v.object then
			-- 	v.object:removeFromParentAndCleanup(true)
			-- 	v.object = nil
			-- end
			armyMark.armyRemove(i)
			-- table.remove(timeShowList, i)
		end
	end
end

local function setPassColor(v, index )
	if v.cell[index] and not v.cell[index].isPass then
		if v.cell[index].color == "red" then
			-- v.cell[index].sprite:loadTexture(ResDefineUtil.Pass_by_route_Icon_red,UI_TEX_TYPE_PLIST)
			v.cell[index].sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(ResDefineUtil.Pass_by_route_Icon_red))
		elseif v.cell[index].color == "green" then
			-- v.cell[index].sprite:loadTexture(ResDefineUtil.Pass_by_route_Icon_green,UI_TEX_TYPE_PLIST)
			v.cell[index].sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(ResDefineUtil.Pass_by_route_Icon_green))
		else
			-- v.cell[index].sprite:loadTexture(ResDefineUtil.Pass_by_route_Icon_blue,UI_TEX_TYPE_PLIST)
			v.cell[index].sprite:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(ResDefineUtil.Pass_by_route_Icon_blue))
		end
		v.cell[index].isPass = true
		setPassColor(v, index-1 )
	end
end

local function scaleSprite( v )
	v.count = v.count + 0.1
	--一秒发射一次
	if v.count >= 3 then
		v.count = 0
		table.insert(v.top,1)
	end

	for m, n in ipairs (v.top) do
		if v.cell[n-1] then
			if n-1 ~= 1 then
				v.cell[n-1].sprite:setScale(0.8)
			end
		end

		if v.cell[n] then
			if n ~= 1 then
				v.cell[n].sprite:setScale(1)
			end
		end
		v.top[m] = v.top[m] +1
	end

	local num = math.floor(#v.cell*(1-(v.end_time-userData.getServerTime())/v.alltime))
	if num > 0 and #v.cell >= num then
		setPassColor(v, num )
	end

	for m, n in ipairs (v.top) do
		if n > #v.cell + 1 then
			table.remove(v.top, m)
		end
	end
end

local function createLineMark(changeList)
	for k,v in pairs(changeList) do
		local locationX, locationY = userData.getLocation()
		local locationXPos, locationYPos = userData.getLocationPos()
		local start_x = math.floor(v[1]/10000)
		local start_y = v[1]%10000
		local end_x = math.floor(v[2]/10000)
		local end_y = v[2]%10000

		local resideLos = {x = nil, y=nil}
		resideLos.x, resideLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, start_x, start_y)
		
		local targetLos = {x= nil, y = nil}

		targetLos.x, targetLos.y = config.getMapSpritePos(locationXPos,locationYPos, locationX, locationY, end_x, end_y)
		local spriteTable = {}
		spriteTable.cell = {}
		spriteTable.top = {} --当前缩放的点的index
		spriteTable.count = 0
		spriteTable.alltime = v[3]
		spriteTable.end_time = v.end_time

		local length = math.sqrt(math.pow((resideLos.x - targetLos.x),2) + math.pow((resideLos.y - targetLos.y),2))
		local line_layer = nil--TouchGroup:create()--CCClippingNode:create()
		local pColor = nil
		local width = 35
		local dt = 0
		local count = math.ceil(length/(width*0.8))
		local rotation = animation.pointRotate({x= resideLos.x, y=resideLos.y}, {x= targetLos.x, y = targetLos.y })
		for m=1, count do
			table.insert(spriteTable.cell, {sprite = pColor, top = nil, isPass = nil,color = "green"})
			if v.isAttack then
				pColor = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.March_route_Icon_1)
				spriteTable.cell[m].color = "red"
				spriteTable.cell[m].sprite = pColor
			elseif v.relation then
				if clientConfigData.getRelationColor(v.relation) == "green" then
					pColor = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.March_route_Icon_2)
					spriteTable.cell[m].sprite = pColor
				elseif clientConfigData.getRelationColor(v.relation) == "red" then
					pColor = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.March_route_Icon_1)
					spriteTable.cell[m].color = "red"
					spriteTable.cell[m].sprite = pColor
				else
					pColor = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.March_route_Icon_3)
					spriteTable.cell[m].color = "blue"
					spriteTable.cell[m].sprite = pColor
				end
			else
				pColor = cc.Sprite:createWithSpriteFrameName(ResDefineUtil.March_route_Icon_2)
				spriteTable.cell[m].sprite = pColor
			end

			if m == 1 then
				pColor:setScale(0.8)
				pColor:setRotation(180-rotation)
				line_layer = pColor
				spriteTable.top = {1}
				mapData.getObject().armyPassNode:addChild(pColor)
				pColor:setPositionX(resideLos.x+100)
				pColor:setPositionY(resideLos.y+50)
			else
				line_layer:addChild(pColor)
				pColor:setPosition(cc.p(-(#spriteTable.cell-1)*width+17, pColor:getContentSize().height/2))
			end
		end

		if not m_tLineSpriteList[k] then
			m_tLineSpriteList[k] = {}
		end
		m_tLineSpriteList[k] = spriteTable

		table.insert(changeList[k], line_layer)

		if mainBuildScene.getRootLayer() then
			if line_layer then
				line_layer:setVisible(false)
			end
		end
		local file = nil
		local ro = 45
		local isFlip = false

		--右
		if rotation >= -ro/2 and rotation<= ro/2 then
			file = "xingjunbudui_3"
			isFlip = true
		--下
		elseif rotation <= -(90-0.5*ro) and rotation>= -(90+0.5*ro) then
			file = "xingjunbudui_5"
		--上
		elseif rotation <= 0.5*ro+90 and rotation>= 90-0.5*ro then
			file = "xingjunbudui_1"
		--左
		elseif (rotation >= 180-ro/2 and rotation <=180) or (rotation >= -180 and rotation <=-(180-ro/2)) then
			file = "xingjunbudui_3"
		--右上
		elseif rotation > ro/2 and rotation < 90-ro/2 then
			file = "xingjunbudui_2"
			isFlip = true
		--右下
		elseif rotation > -(90-ro/2) and rotation < -ro/2 then
			file = "xingjunbudui_4"
			isFlip = true
		--左下
		elseif rotation > -(180-ro/2) and rotation < -(90+ro/2) then
			file = "xingjunbudui_4"
		--左上
		else
			file = "xingjunbudui_2"
		end

		if file == "" then
			file = "xingjunbudui_1"
		end

		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/"..file..".ExportJson")
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/xiaoqi5.ExportJson")

		if line_layer then
			local begin_flag = CCArmature:create("xiaoqi5")--ImageView:create()
			begin_flag:getAnimation():playWithIndex(0)
			begin_flag:setAnchorPoint(cc.p(0.5,0))
			
			if not m_begin_flag_data[k] then
				m_begin_flag_data[k] = {}
			end
			m_begin_flag_data[k] = {sprite = begin_flag, target_wid = v[2]}

			ObjectManager.addObject(ARMY_MARK_FLAG, begin_flag, false, targetLos.x+100,
				targetLos.y+50, false )
		end

		local panel = TouchGroup:create()
		panel:setContentSize(CCSize(1,1))
		panel:ignoreAnchorPointForPosition(false)
		panel:setAnchorPoint(cc.p(0.5,0.5))
		local armature = CCArmature:create(file)
		local time_label = nil
		if ObjectManager.getIsDisplay() then
			time_label = GUIReader:shareReader():widgetFromJsonFile("test/Army_march_time_detail.json")
			if v.isAttack then
				tolua.cast(time_label:getChildByName("Label_name"),"Label"):setText("???")
				tolua.cast(time_label:getChildByName("label_state"),"Label"):setText(armyEnterState[99])
			elseif v.relation then
				if clientConfigData.getRelationColor(v.relation) == "green" then

				elseif clientConfigData.getRelationColor(v.relation) == "red" then
					tolua.cast(time_label:getChildByName("Label_name"),"Label"):setText("???")
					tolua.cast(time_label:getChildByName("label_state"),"Label"):setText("?")
				else
					tolua.cast(time_label:getChildByName("Label_name"),"Label"):setText("")
					tolua.cast(time_label:getChildByName("label_state"),"Label"):setText("")
				end
			else
				tolua.cast(time_label:getChildByName("Label_name"),"Label"):setText(Tb_cfg_hero[allTableData[dbTableDesList.hero.name][v.base_heroid_u].heroid].name)
				if armyEnterState[v.state] then
					tolua.cast(time_label:getChildByName("label_state"),"Label"):setText(armyEnterState[v.state])
				end
			end
		else
			time_label = GUIReader:shareReader():widgetFromJsonFile("test/Army_march_time.json")
		end

		time_label:setAnchorPoint(cc.p(0.5,0))

		local touch_circle = ImageView:create()
		touch_circle:setVisible(false)

		if v.isAttack then
			touch_circle:loadTexture("hongse_renwuxuanding.png",UI_TEX_TYPE_PLIST)
			tolua.cast(time_label:getChildByName("ImageView_1"),"ImageView"):loadTexture("baoqian_6.png", UI_TEX_TYPE_PLIST)
			tolua.cast(time_label:getChildByName("ImageView_2"),"ImageView"):loadTexture("ditu_2.png", UI_TEX_TYPE_PLIST)
		elseif v.relation then
			if clientConfigData.getRelationColor(v.relation) == "green" then
				tolua.cast(time_label:getChildByName("ImageView_2"),"ImageView"):loadTexture("ditu_1.png", UI_TEX_TYPE_PLIST)
				tolua.cast(time_label:getChildByName("ImageView_1"),"ImageView"):loadTexture("baoqian_5.png", UI_TEX_TYPE_PLIST)
				touch_circle:loadTexture("lvse_renwuxuanding.png",UI_TEX_TYPE_PLIST)
			elseif clientConfigData.getRelationColor(v.relation) == "red" then
				tolua.cast(time_label:getChildByName("ImageView_1"),"ImageView"):loadTexture("baoqian_6.png", UI_TEX_TYPE_PLIST)
				tolua.cast(time_label:getChildByName("ImageView_2"),"ImageView"):loadTexture("ditu_2.png", UI_TEX_TYPE_PLIST)
				touch_circle:loadTexture("hongse_renwuxuanding.png",UI_TEX_TYPE_PLIST)
			else
				tolua.cast(time_label:getChildByName("ImageView_1"),"ImageView"):loadTexture("baoqian_4.png", UI_TEX_TYPE_PLIST)
				tolua.cast(time_label:getChildByName("ImageView_2"),"ImageView"):loadTexture("ditu_3.png", UI_TEX_TYPE_PLIST)
				touch_circle:loadTexture("lanse_renwuxuanding.png",UI_TEX_TYPE_PLIST)
			end
		else
			tolua.cast(time_label:getChildByName("ImageView_2"),"ImageView"):loadTexture("ditu_1.png", UI_TEX_TYPE_PLIST)
			tolua.cast(time_label:getChildByName("ImageView_1"),"ImageView"):loadTexture("baoqian_5.png", UI_TEX_TYPE_PLIST)
			touch_circle:loadTexture("lvse_renwuxuanding.png",UI_TEX_TYPE_PLIST)
		end

		tolua.cast(time_label:getChildByName("Label_78708"),"LabelAtlas"):setStringValue(commonFunc.format_time(v.end_time - userData.getServerTime(),true))
		tolua.cast(time_label:getChildByName("loading_bar_0"),"LoadingBar"):setPercent(100*(1-(v.end_time - userData.getServerTime())/v[3]))
		
		local offsetX, offsetY = 0, 0

		if file == "xingjunbudui_1" then
			-- offsetY = 80
			time_label:setPosition(cc.p(0, 45))
			touch_circle:setPosition(cc.p(armature:getPositionX()-10,armature:getPositionY()-30))
		elseif file == "xingjunbudui_5" then
			-- offsetY = -80
			time_label:setPosition(cc.p(0, 130))
			touch_circle:setPosition(cc.p(armature:getPositionX()+10,armature:getPositionY()+60))
		elseif file == "xingjunbudui_3" then
			if isFlip then
				-- offsetX = 130
				time_label:setPosition(cc.p(-80, 50))
				touch_circle:setPosition(cc.p(armature:getPositionX()-60,armature:getPositionY()))
			else
				-- offsetX = -130
				time_label:setPosition(cc.p(70, 50))
				touch_circle:setPosition(cc.p(armature:getPositionX()+60,armature:getPositionY()))
			end
		elseif file == "xingjunbudui_4" then
			if isFlip then
				-- offsetX = 100
				-- offsetY = -70
				time_label:setPosition(cc.p(-70, 100))
				touch_circle:setPosition(cc.p(armature:getPositionX()-60,armature:getPositionY()+30))
			else
				-- offsetX = -100
				-- offsetY = -70
				time_label:setPosition(cc.p(70, 100))
				touch_circle:setPosition(cc.p(armature:getPositionX()+60,armature:getPositionY()+30))
			end
		elseif file == "xingjunbudui_2" then
			if isFlip then
				-- offsetX = 90
				-- offsetY = 60
				time_label:setPosition(cc.p(-90, 50))
				touch_circle:setPosition(cc.p(armature:getPositionX()-50,armature:getPositionY()-40))
			else
				-- offsetX = -90
				-- offsetY = 60
				time_label:setPosition(cc.p(80, 50))
				touch_circle:setPosition(cc.p(armature:getPositionX()+50,armature:getPositionY()-40))
			end
		end

		offsetY = 80*math.sin(rotation*math.pi/180)
		offsetX = 80*math.cos(rotation*math.pi/180)
		panel:addChild(armature)
		panel:addWidget(time_label)
		panel:addWidget(touch_circle)

		if not timeShowList[k] then
			timeShowList[k] = {}
		end

		timeShowList[k] = {armature = armature, timeLabel =time_label ,wid = v[1], end_wid = v[2], object = panel, alltime = v[3], end_time = v.end_time, isFlip = isFlip,
									touch_circle = touch_circle, nowTime = userData.getServerTime(), frameTime = 0, framePercent = 1/v[3],
									offsetX = offsetX, offsetY = offsetY}

		ObjectManager.addObject(ARMY_MARK_TIME, panel, false, offsetX+resideLos.x+100, offsetY+resideLos.y+50, isFlip )
		armature:getAnimation():playWithIndex(0)
		armature:setVisible(false)
		time_label:setVisible(false)
		local temp_per = (v.end_time - userData.getServerTime())/(v[3])
		if temp_per > 1 then
			temp_per = 1 
		end

		if temp_per < 0 then
			temp_per = 0
		end

		local percent = 1-temp_per
		local posx = (targetLos.x - resideLos.x-offsetX )*percent
		local posy = (targetLos.y - resideLos.y-offsetY )*percent

		ObjectManager.setObjectPos(panel,offsetX+resideLos.x + posx + 100, offsetY+resideLos.y + posy+50, isFlip)

		if not markShowList[k] then
			markShowList[k] = {}
		end
		markShowList[k] = changeList[k]
	end
	

	if timer then
		scheduler.remove(timer)
		timer = nil
	end

	local timelistCount = 0
	for i,v in pairs(timeShowList) do
		if v.armature then
			timelistCount = timelistCount + 1
		end
	end

	if timelistCount > 0 then
		timer = scheduler.create(function ( )
			setTimePosWhenMove()
		end, 0)
	end

	if m_sched_timer then
		scheduler.remove(m_sched_timer)
		m_sched_timer = nil
	end

	if timelistCount > 0 then
		m_sched_timer = scheduler.create(function ( )
			for i, v in pairs(m_tLineSpriteList) do
				if v.cell and #v.cell > 0 then
					scaleSprite(v)
				end
			end
		end,0.1)
	end
	

	ObjectManager.addObjectCallBack(ARMY_MARK_TIME, armyMoveAnimation, resetTimePosition)
	ObjectManager.addObjectCallBack(ARMY_MARK_FLAG, setFlagPosWhenMove, resetFlagPosition)
end

local function removeArmyData(id )
	if markShowList[id] then
		if m_begin_flag_data[id] and m_begin_flag_data[id].sprite then
			m_begin_flag_data[id].sprite:removeFromParentAndCleanup(true)
		end
		m_begin_flag_data[id] = nil

		if markShowList[id][4] then
			markShowList[id][4]:removeFromParentAndCleanup(true)
			m_tLineSpriteList[id] = nil
			if timeShowList[id].object then
				timeShowList[id].object:removeFromParentAndCleanup(true)
				timeShowList[id] = nil
			end
		end
		markShowList[id] = nil
	end
	armyMark.removeLockScreen( id)
end

local function insertChangeArmy(armyidList )
	local armydata = nil
	local army_state = nil
	local changeList = {}
	for i, v  in ipairs(armyidList) do
		armydata = armyData.getAllTeamMsg()[v]
		if armydata then
			army_state = armydata.state
			if army_state == armyState.chuzhenging or army_state == armyState.zhuzhaing or army_state == armyState.yuanjuning or army_state == armyState.returning 
				 then
				--local team_info = armyData.getTeamMsg(v)
				-- local move_dis, move_time = armyData.getMoveShowInfo(v.reside_wid, v.target_wid, team_info.speed)
				-- 1 起始点；2 目标点;
				if armydata.end_time - userData.getServerTime() > 0 then
					if not changeList[v] then
						changeList[v] = {}
					end
					if army_state == armyState.returning then
						table.insert(changeList[v], armydata.target_wid)
						table.insert(changeList[v], armydata.reside_wid)
						table.insert(changeList[v], armydata.end_time - armydata.begin_time)
					else
						local mark_target = armydata.target_wid
						table.insert(changeList[v], armydata.reside_wid)
						table.insert(changeList[v], mark_target)
						table.insert(changeList[v], armydata.end_time - armydata.begin_time)
					end
					changeList[v].end_time = armydata.end_time
					changeList[v].state = armydata.state
					changeList[v].base_heroid_u = armydata.base_heroid_u
				end
			else
				removeArmyData(v )
			end
		end
	end

	local count = 0
	for i, v in pairs(changeList) do
		count = count + 1
		removeArmyData(i )
	end


	return changeList,count
end

local function insertChangeArmy_alert(armyidList )
	local armydata = nil
	local army_state = nil
	local changeList = {}
	for i, v  in ipairs(armyidList) do
		armydata = armyData.getAssaultTeamMsg(v)
		if armydata then
			army_state = armydata.state
			if army_state == armyState.chuzhenging then
				-- 1 起始点；2 目标点；
				if armydata.end_time - userData.getServerTime() > 0 then
					if not changeList[v] then
						changeList[v] = {}
					end
					local mark_target = armydata.to_wid
					table.insert(changeList[v], armydata.from_wid)
					table.insert(changeList[v], mark_target)
					table.insert(changeList[v], armydata.end_time - armydata.begin_time)
					changeList[v].isAttack = true
					changeList[v].state = armydata.state
					changeList[v].end_time = armydata.end_time
				end
			end
		end
	end

	local count = 0
	for i, v in pairs(changeList) do
		count = count + 1
		removeArmyData(i )
	end
	return changeList,count
end

--同盟共享视野部队
local function insertChangeArmy_union( armyidList )
	local armydata = nil
	local army_state = nil
	local changeList = {}
	for i, v  in ipairs(armyidList) do
		armydata = mapData.getFieldArmyMsgByArmyId(v)
		if armydata then

			-- army_state = armydata.state
			-- if army_state == armyState.chuzhenging then
				-- 1 起始点；2 目标点；如果是敌袭，应该是自己管理，不在同盟视野上面增加
				if not armyData.getAssaultTeamMsg(v) and armydata.end_time - userData.getServerTime() > 0 and armydata.wid_from >0 then
					if not changeList[v] then
						changeList[v] = {}
					end
					table.insert(changeList[v], armydata.wid_from)
					table.insert(changeList[v], armydata.wid_to)
					table.insert(changeList[v], armydata.end_time - armydata.begin_time)
					-- changeList[v].isAttack = true
					-- changeList[v].state = armydata.state
					changeList[v].relation = armydata.relation
					changeList[v].end_time = armydata.end_time

				end
			-- end
		end
	end

	local count = 0
	for i, v in pairs(changeList) do
		count = count + 1
		removeArmyData(i )
	end
	return changeList,count
end

--部队删除
local function armyRemove(packet )
	removeArmyData(packet )
end

--部队刷新
local function armyUpdate(packet )
	local armyidList = {}
	
	for i, v in pairs(packet) do
		if i == "armyid" then
			table.insert(armyidList, v)
		end
	end

	local changeList, count = insertChangeArmy(armyidList)

	if count > 0 then
		createLineMark(changeList)
	end
end

--敌袭刷新
local function armyAlertUpdate( packet )
	local armyidList = {}
	
	for i, v in pairs(packet) do
		if i == "armyid" then
			table.insert(armyidList, v)
		end
	end

	local changeList, count = insertChangeArmy_alert(armyidList)

	if count > 0 then
		createLineMark(changeList)
	end
end

--同盟视野部队刷新
local function armyUnionUpdate(armydata )
	local armyidList = {}
	
	for i, v in pairs(armydata) do
		if v.state == armyState.chuzhenging or 
			v.state == armyState.zhuzhaing or
			v.state == armyState.yuanjuning or
			v.state == armyState.returning then
			table.insert(armyidList, v.armyid)
		end
	end

	local changeList, count = insertChangeArmy_union(armyidList)

	if count > 0 then
		createLineMark(changeList)
	end
end


local function organizeMarkInfo()
	resetMarkInfo()
	local armyidList = {}
	local armyidList_alert = {}
	local armyidList_field = {}

	for i, v in pairs(armyData.getAllTeamMsg()) do
		table.insert(armyidList, v.armyid)
	end

	local changeList, count = insertChangeArmy(armyidList)
	if count > 0 then
		createLineMark(changeList)
	end

	for i, v in pairs(armyData.getAllAssaultMsg()) do
		table.insert(armyidList_alert, v.armyid)
	end

	local changeList_alert, count_alert =insertChangeArmy_alert(armyidList_alert )
	if count_alert > 0 then
		createLineMark(changeList_alert)
	end

	for i, v in pairs(mapData.getFieldArmyMsg()) do
		if v.state == armyState.chuzhenging or 
			v.state == armyState.zhuzhaing or
			v.state == armyState.yuanjuning or
			v.state == armyState.returning then
			table.insert(armyidList_field, v.armyid)
		end
	end

	local changeList_union, count_union =insertChangeArmy_union(armyidList_field )
	if count_union > 0 then
		createLineMark(changeList_union)
	end
end

local function init( )
	UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.add, armyMark.armyAlertUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.remove, armyMark.armyRemove)
    UIUpdateManager.add_prop_update(dbTableDesList.army_alert.name, dataChangeType.update, armyMark.armyAlertUpdate)

    UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, armyMark.armyUpdate)
    -- UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.add, armyMark.armyUpdate)
    UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.remove, armyMark.armyRemove)
    organizeMarkInfo()
end

local function remove( )
	resetMarkInfo()
	UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.add, armyMark.armyAlertUpdate)
    UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.remove, armyMark.armyRemove)
    UIUpdateManager.remove_prop_update(dbTableDesList.army_alert.name, dataChangeType.update, armyMark.armyAlertUpdate)

    UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, armyMark.armyUpdate)
    -- UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.add, armyMark.armyUpdate)
    UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.remove, armyMark.armyRemove)
end

local function moveOutofScreen(coorX, coorY )
	local width = config.getWinSize().width/2
	local height = config.getWinSize().height/2
	local realX_ = coorX - 2
	local realY_ = coorY - 2

	local realXPlus = coorX+2
	local realYPlus = coorY+2

	if realX_ < 1 then
		realX_ = 1
	end

	if realY_ < 1 then
		realY_ = 1
	end

	if realXPlus > 1501 then
		realXPlus = 1501
	end

	if realYPlus > 1501 then
		realYPlus = 1501
	end

	-- 上
	if m_global_y > height then

		mapController.jump(realXPlus, coorY)
	--下
	elseif m_global_y < height then
		mapController.jump(realX_, coorY)
	--左
	elseif m_global_x < width then
		mapController.jump(coorX, realYPlus)
	else
		mapController.jump(coorX, realY_)
	end
end

local function setTouchArmy(armyid )
	if m_loacScreenArmyId and m_loacScreenArmyId == armyid then
		return
	end

	for i, v in pairs(timeShowList) do
		if v.touch_circle then
			if i == armyid then
				v.object:getParent():reorderChild(v.object,TOP_LAYER)
			else
				v.object:getParent():reorderChild(v.object,ARMY_MARK_TIME)
			end
			v.touch_circle:setVisible(i==armyid)
		end
	end

	local function jumpTo(wid,id  )
		local coorx = math.floor(wid/10000)
		local coory = wid%10000
		mapController.setOpenMessage(false)
		mapController.locateCoordinate(coorx, coory, function ( )
			mapController.setOpenMessage(true)
			armyListManager.dealWithSelectArmy(id)
			armyMark.setAnimationMove( )
		end)
	end

	if not timeShowList[armyid] then
		-- armyListManager.dealWithSelectArmy(armyid)
		if mapData.getFieldArmyMsgByArmyId( armyid ) then
			jumpTo(mapData.getFieldArmyMsgByArmyId( armyid ).wid_from, armyid)
		elseif armyData.getTeamMsg(armyid) then
			jumpTo(armyData.getTeamMsg(armyid).target_wid, armyid)
		elseif armyData.getAssaultTeamMsg(armyid) then
			jumpTo(armyData.getAssaultTeamMsg(armyid).to_wid, armyid)
		end
		return 
	end

	m_loacScreenArmyId = armyid
	map.setArmyTouch(true)
end

local function move( callbackFun )
		if not m_global_x or not m_global_y then return end
		local winSize = config.getWinSize()
		local moveEndPosX,moveEndPosY = winSize.width/2,winSize.height/2
		local distance_x = moveEndPosX - m_global_x
		local distance_y = moveEndPosY - m_global_y
		local stepCount = 10
		local speed = 10000
		local moveStepScreen_X = (distance_x)/stepCount
		local moveStepScreen_Y = (distance_y)/stepCount

		local distance = ccpDistance(cc.p(moveEndPosX,moveEndPosY), ccp(m_global_x, m_global_y))
		local time_ = distance/speed/10
		local count = 0
		local stepSimulateMove = function()
			count= count + 1
			moveEndPosX = moveEndPosX + moveStepScreen_X
			moveEndPosY = moveEndPosY + moveStepScreen_Y
			map.onTouchSimulation("moved",moveEndPosX,moveEndPosY)
		end
		moveEndPosX = m_global_x
		moveEndPosY = m_global_y
		map.onTouchSimulation("began",m_global_x,m_global_y)

		local function action( )
			local animationAction = animation.sequence({cc.CallFunc:create(function ( )
				stepSimulateMove()
			end), cc.DelayTime:create(time_), cc.CallFunc:create(function ( )
				if count < 10 then
					action()
				else
					map.onTouchSimulation("ended",moveEndPosX,moveEndPosY)
					if callbackFun then
						callbackFun()
					end
				end
			end)})
			timeShowList[m_loacScreenArmyId].object:runAction(animationAction)
		end
		action( )
end

local function setAnimationMove( )
	if m_loacScreenArmyId and timeShowList[m_loacScreenArmyId] then
		local animationAction = animation.sequence({cc.CallFunc:create(function ( )
			if m_loacScreenArmyId then
				if m_global_x and m_global_y then
					local coorx, coory = map.touchPoint(m_global_x,m_global_y )
					if m_global_x >= 0 and m_global_x<= config.getWinSize().width and m_global_y >= 0 and m_global_y <= config.getWinSize().height then 
						move(function (  )
							if m_loacScreenArmyId and timeShowList[m_loacScreenArmyId] then
								local action = animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
									armyMark.setAnimationMove( )
								end)})
								timeShowList[m_loacScreenArmyId].object:runAction(action)
							end
						end)
					else
						mapController.setOpenMessage(false)
						mapController.locateCoordinate(coorx, coory, function ( )
							mapController.setOpenMessage(true)
							armyListManager.dealWithSelectArmy(m_loacScreenArmyId)
							armyMark.setAnimationMove( )
						end)
					end
				end
			end
		end)})
		timeShowList[m_loacScreenArmyId].object:runAction(animationAction)
	end
end

local function removeLockScreenWhenTouch( )
	if m_loacScreenArmyId then
		armyMark.removeLockScreen( m_loacScreenArmyId)
	end
end

local function removeLockScreen( id)
	if m_loacScreenArmyId and m_loacScreenArmyId == id then
		m_loacScreenArmyId = nil
		first_move = nil
		map.setArmyTouch(false)
		m_global_x = nil
		m_global_y = nil
		if timeShowList[id] and timeShowList[id].object then
			timeShowList[id].object:stopAllActions()
			timeShowList[id].object:getParent():reorderChild(timeShowList[id].object,ARMY_MARK_TIME)
			timeShowList[id].touch_circle:setVisible(false)
		end
		map.setSimulatingTouch(false)
	end
end

armyMark = {
				organizeMarkInfo = organizeMarkInfo,
				resetLinePosition = resetLinePosition,
				resetMarkInfo = resetMarkInfo,
				setLineVisible = setLineVisible,
				init = init,
				setAnimationMove = setAnimationMove,
				remove = remove,
				armyUpdate = armyUpdate,
				armyAlertUpdate = armyAlertUpdate,
				armyRemove = armyRemove,
				armyUnionUpdate = armyUnionUpdate,
				setTouchArmy = setTouchArmy,
				removeLockScreen = removeLockScreen,
				removeLockScreenWhenTouch = removeLockScreenWhenTouch,
				getTimeShowList = getTimeShowList,
}