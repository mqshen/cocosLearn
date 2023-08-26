--城市建设信息
module("cityMsg", package.seeall)
local city_msg_layer = nil
local m_FontSize = 18
local m_FontOffset = 0
local nagetiIndex = nil
local smallIndex = nil

local times_big = 0.8
local times_small = 0.2


-- [1] = {name={"城主府","都督府","堡垒"},id = {10,11,12}},
-- [2] = {name={"经济"},id = {13,20,21,23,22,24,82,25,81}},
-- [3] = {name={"部队"},id = {40,37,54,52,53,51,36,30}},
-- [4] = {name={"点将"},id = {42,31,32,33,34,35,84}},
-- [5] = {name={"城防"},id = {61,66,63,64,65,83}},
-- [6] = {name={"社稷坛"},id = {43}},
-- [7] = {name={"封禅台"},id = {44}},

local buildingPosDefined = { 		
	-- positi = {[1] = {0.9,0.5},[5] = {0.1,0.5},},
	-- nageti = {{0.1,0.5},{0.9,0.5},{0.1,0.5},},
	-- small = {{0.1,0.5},{0.9,0.5},{0.9,0.5},{0.1,0.5},}

	positi = {[1] = {0.634,0.762},[5] = {0.147,0.299},},
	nageti = {{0.879,0.736},{0.879,0.344},{0.142,0.636},},
	small = {{0.391,0.792},{0.42,0.701},{0.625,0.211},{0.391,0.21},}
}

local LINE_UP = 1
local LINE_DOWN = 2
local LINE_LEFT = 3
local LINE_RIGHT = 4

local list_cache_line = nil
local m_component_line = nil

local list_cache_name_widgets = nil
local list_cache_widgets = nil

function removeLineData( )
	m_component_line = {}
	list_cache_line = {}
end



local function widgetHideEffect(widget, callback)
	local finally = cc.CallFunc:create(function ( )
        widget:setVisible(false)
        if callback then callback() end
	end)
	-- widget:setVisible(true)
	local actionHide = CCFadeOut:create(0.3)
	widget:runAction(animation.sequence({actionHide,finally}))
end

local function widgetShowEffect(widget,needScale)
	local finally = cc.CallFunc:create(function ( )
        -- pass
    end)
    if needScale then 
		widget:setScale(0.8 * config.getgScale())
	end
    local actionScale = CCScaleTo:create(0.3,1* config.getgScale())
    local actionShow = CCFadeIn:create(0.3)
    local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)
    if needScale then 
    	widget:runAction(animation.sequence({scaleAndShow,finally}))
    else
    	widget:runAction(animation.sequence({actionShow,finally}))
    end
end

local function hideLines(needEffect)
	if list_cache_line then 
		for k,v in pairs(list_cache_line) do 
			for kk,vv in pairs(v) do 
				if needEffect then 
					widgetHideEffect(vv)
				else
					vv:setVisible(false)
				end
			end
		end
	end
end

local function hideDetails(needEffect)
	if list_cache_widgets then 
		for k,v in pairs(list_cache_widgets) do 
			if needEffect then 
				widgetHideEffect(v)
			else
				v:setVisible(false)
			end
		end
	end
end



local function hideNames(needEffect)
	if list_cache_name_widgets then 
		for k,v in pairs(list_cache_name_widgets) do 
			if needEffect then 
				widgetHideEffect(v)
			else
				v:setVisible(false)
			end
		end
	end
end



function setEnabled(isAble)
	if not city_msg_layer then return end

	if list_cache_name_widgets then 
		for k,v in pairs(list_cache_name_widgets) do 
			v:setVisible(isAble)
			v:setTouchEnabled(isAble)
		end
	end

	if list_cache_widgets then 
		for k,v in pairs(list_cache_widgets) do 
			v:setVisible(false)
			v:setTouchEnabled(isAble)
		end
	end

	if list_cache_line then 
		for k,v in pairs(list_cache_line) do 
			for kk,vv in pairs(v) do 
				vv:setVisible(false)
			end
		end
	end


end

function dealwithTouchEvent(x,y)

	

	if not city_msg_layer then
		return false
	end

	-- local flag_hit_detail_widget = false
	local tag = {999,998,997,996,995,994,993}
	local temp_widget = nil
	for i, v in pairs(tag) do
		temp_widget = city_msg_layer:getWidgetByTag(v)
		if temp_widget then
			local temp_ = temp_widget:getChildByTag(110)
			if temp_ then
				if temp_:hitTest(cc.p(x,y)) then
					return false
				end
			end
		end
	end

	-- local flag_hit_name = false
	-- for k,v in pairs(list_cache_name_widgets) do 
	-- 	if v:hitTest(cc.p(x,y)) then 
	-- 		flag_hit_name = true
	-- 	end
	-- end

	-- if not flag_hit_name and not flag_hit_detail_widget then 
	-- 	hideLines(true)
	-- 	hideDetails(true)
	-- end
	remove_self()
	return true
	

	-- if not flag_hit_detail_widget and not flag_hit_name then 
	-- 	hideAllDetailAndLine()
	-- end

	-- remove_self()
	-- 
	-- return false
end

local function getDistance(p1,p2,p3,p4 )
	return math.sqrt(math.pow(p1-p2, 2) + math.pow(p3-p4, 2))
end

--获取应该和哪个边进行连线
local function getlines(building, posX, posY, height  )
	local point = {x= building:getPositionX(), y= building:getPositionY()}
	local dis1 = nil
	local dis2 = nil
	local touchPoint = nil
	local pointcir = building:convertToNodeSpace(cc.p(posX, posY))
	--左上
	if point.x <= posX and point.y >= posY then
		dis1 = getDistance(point.x + building:getContentSize().width/2, posX, point.y, posY)
		dis2 = getDistance(point.x + building:getContentSize().width, posX, point.y+height/2, posY)
		touchPoint = pointcir.y + pointcir.x
		if touchPoint > building:getContentSize().width then
			return LINE_RIGHT
		end

		touchPoint = pointcir.y + pointcir.x- building:getContentSize().width
		if touchPoint < building:getPositionY() then
			return LINE_DOWN
		end
		return (dis1 < dis2 and LINE_DOWN) or LINE_RIGHT
	--右上
	elseif point.x > posX and point.y > posY then
		dis1 = getDistance(point.x + building:getContentSize().width/2, posX, point.y, posY)
		dis2 = getDistance(point.x, posX, point.y+height, posY)
		touchPoint = pointcir.y - pointcir.x
		if touchPoint < 0 then
			return LINE_DOWN
		end

		touchPoint = -pointcir.y + pointcir.x
		if touchPoint < 0 then
			return LINE_LEFT
		end
		return (dis1 < dis2 and LINE_DOWN) or LINE_LEFT
	--左下
	elseif point.x <= posX and point.y <= posY then
		dis1 = getDistance(point.x + building:getContentSize().width/2, posX, point.y+height, posY)
		dis2 = getDistance(point.x + building:getContentSize().width, posX, point.y+height/2, posY)
		touchPoint = pointcir.y - pointcir.x + building:getContentSize().width
		if touchPoint > height then
			return LINE_UP 
		end

		touchPoint = height - pointcir.y + pointcir.x
		if touchPoint > building:getContentSize().width then
			return LINE_RIGHT
		end

		return (dis1 < dis2 and LINE_UP) or LINE_RIGHT
	--右下
	elseif point.x > posX and point.y < posY then
		dis1 = getDistance(point.x + building:getContentSize().width/2, posX, point.y+height, posY)
		dis2 = getDistance(point.x, posX, point.y+height/2, posY)
		touchPoint = pointcir.y + pointcir.x - height
		if touchPoint < 0 then
			return LINE_LEFT 
		end

		touchPoint = pointcir.y + pointcir.x
		if touchPoint > height then
			return LINE_UP
		end
		return (dis1 < dis2 and LINE_UP) or LINE_LEFT
	end
end

function connectLine( buildingView, building, conHeight,component,name_widget,index)

	local current_city_id = mainBuildScene.getThisCityid()
	if not current_city_id then return end
	local cityComponentData = mapData.getCityComponentData( math.floor(current_city_id/10000),current_city_id%10000 )
	if not cityComponentData then return end
	local temp_point = component:convertToWorldSpace(cc.p(component:getContentSize().width/2,component:getContentSize().width*0.375))
	local posX,posY = config.countWorldSpace(temp_point.x,temp_point.y,map.getAngel())
	local len = nil
	local xieLen = nil
	local rotation1 = nil
	local rotation2 = nil
	local x= nil
	local y = nil
	local point = building:convertToNodeSpace(cc.p(posX, posY))
	if point.x >= 0 and point.x <= building:getContentSize().width
		and point.y >= 0 and point.y <= conHeight then
		return
	end

	local line_type = getlines(building, posX, posY, conHeight  )
	local touchPoint = nil
	if line_type == LINE_UP then
		if building:getPositionX()+config.getgScale()*building:getContentSize().width/2 < posX then
			touchPoint = conHeight - point.y + point.x
			if touchPoint < 0 then
				if point.x > building:getContentSize().width then
					len = times_big*building:getContentSize().width + math.abs(touchPoint)
				else
					len = -touchPoint + point.x/2
				end
			else
				if point.x > building:getContentSize().width then
					len = (building:getContentSize().width- touchPoint)/2
				else
					len = (point.x - touchPoint)/2
				end
			end
			xieLen = getDistance(point.x, touchPoint, point.y, conHeight) - 1.414*len
			rotation1 = 135
			rotation2 = -90
			x = len + touchPoint
			y = conHeight
		else
			touchPoint = point.y + point.x - conHeight
			if touchPoint > building:getContentSize().width then
				if point.x < 0 then
					len = touchPoint - building:getContentSize().width*times_small
				else
					len = touchPoint - building:getContentSize().width + (building:getContentSize().width - point.x)/2
				end
			else
				if point.x < 0 then
					len = math.abs(touchPoint)/2
				else
					len = (touchPoint - point.x)/2
				end
			end
			xieLen = getDistance(point.x, touchPoint, point.y, conHeight) - 1.414*len
			rotation1 = 45
			rotation2 = -90
			x = touchPoint - len
			y = conHeight
		end
	elseif line_type == LINE_DOWN then
		if building:getPositionX()+config.getgScale()*building:getContentSize().width/2 < posX then
			touchPoint = point.y + point.x
			if touchPoint < 0 then
				if point.x > building:getContentSize().width then
					len = building:getContentSize().width*times_big - touchPoint
				else
					len = point.x /2 - touchPoint
				end
			else
				if point.x > building:getContentSize().width then
					len = (building:getContentSize().width - math.abs(touchPoint))/2
				else
					len = (point.x - touchPoint)/2
				end
			end
			xieLen = getDistance(point.x, touchPoint, point.y, 0) - 1.414*len
			rotation1 = -135
			rotation2 = 90
			x = touchPoint+len
			y = 0
		else
			touchPoint = -point.y + point.x
			if touchPoint > building:getContentSize().width then
				if point.x < 0 then
					len = -building:getContentSize().width*times_small + touchPoint
				else
					len = touchPoint - building:getContentSize().width + (building:getContentSize().width- point.x)/2
				end
			else
				if point.x < 0 then
					len = math.abs(touchPoint/2)
				else
					len = (touchPoint - point.x)/2
				end
			end
			xieLen = getDistance(point.x, touchPoint, point.y, 0) - 1.414*len
			rotation1 = -45
			rotation2 = 90
			x = touchPoint-len
			y = 0
		end
	elseif line_type == LINE_LEFT then
		if building:getPositionY()+config.getgScale()*conHeight/2 > posY then
			touchPoint = point.y - point.x
			if touchPoint > conHeight then
				if point.y < 0 then
					len = touchPoint - conHeight*times_small
				else
					len = (touchPoint - conHeight ) + (conHeight - point.y)/2
				end
			else
				if point.y < 0 then
					len = touchPoint/2
				else
					len = (touchPoint - point.y)/2
				end
			end
			xieLen = getDistance(point.x, 0, point.y, touchPoint) - 1.414*len
			rotation1 = -45
			rotation2 = 180
			x = 0
			y = touchPoint - len
		else
			touchPoint = point.y + point.x
			if touchPoint < 0 then
				if point.y > conHeight then
					len = math.abs(touchPoint) + conHeight*times_big
				else
					len = -touchPoint + point.y/2
				end
			else
				if point.y > conHeight then
					len = (conHeight- touchPoint)/2
				else
					len = (point.y- touchPoint)/2
				end
			end
			xieLen = getDistance(point.x, 0, point.y, touchPoint) - 1.414*len
			rotation1 = 45
			rotation2 = 180
			x = 0
			y = touchPoint + len
		end
	else
		if building:getPositionY()+config.getgScale()*conHeight/2 > posY then
			touchPoint = point.y + point.x- building:getContentSize().width
			if touchPoint > conHeight then
				if point.y < 0 then
					len = touchPoint - conHeight*times_small
				else
					len =  touchPoint - conHeight + (conHeight - point.y)/2
				end
			else
				if point.y < 0 then
					len = touchPoint/2
				else
					len = (touchPoint - point.y)/2
				end
			end
			xieLen = getDistance(point.x, building:getContentSize().width, point.y, touchPoint) - 1.414*len
			rotation1 = -135
			rotation2 = 0
			x = building:getContentSize().width
			y = touchPoint - len				
		else
			touchPoint = point.y - point.x + building:getContentSize().width
			if touchPoint < 0 then
				if point.y > conHeight then
					len = math.abs(touchPoint) + conHeight*0.8
				else
					len = -touchPoint + point.y/2
				end
			else
				if point.y > conHeight then
					len = (conHeight - touchPoint)/2
				else
					len = (point.y -touchPoint)/2
				end
			end
			xieLen = getDistance(point.x, building:getContentSize().width, point.y, touchPoint) - 1.414*len
			rotation1 = 135
			rotation2 = 0
			x = building:getContentSize().width
			y = touchPoint + len
		end
	end

	local new_point = buildingView:convertToNodeSpace(cc.p(posX,posY))
	local circle = ImageView:create()--cc.LayerColor:create(cc.c4b(0,0,0,255), 1.414*len, 4)
	circle:loadTexture(ResDefineUtil.Yellow_lines_new_3,UI_TEX_TYPE_PLIST)
	buildingView:addWidget(circle)
	circle:setPosition(new_point)
	circle:setZOrder(-1)
	circle:setScale(config.getgScale())

	-- if name_widget then 
	-- 	name_widget:setPosition(cc.p(new_point.x - 0.5 *name_widget:getContentSize().width * config.getgScale(),
	-- 		new_point.y + 1 * name_widget:getContentSize().height * config.getgScale()))
	-- end

	local layer = ImageView:create()--cc.LayerColor:create(cc.c4b(0,0,0,255), 1.414*len, 4)
	layer:loadTexture(ResDefineUtil.Yellow_lines_new_1,UI_TEX_TYPE_PLIST)
	layer:setAnchorPoint(cc.p(0,0.5))
	buildingView:addWidget(layer)
	layer:setZOrder(-1)
	layer:setPosition(new_point)
	layer:setRotation(rotation1)
	layer:setScaleX(xieLen*config.getgScale()/layer:getContentSize().width)
	layer:setScaleY(config.getgScale())

	local layer1 = ImageView:create()--cc.LayerColor:create(cc.c4b(0,0,0,255), 1.414*len, 4)
	layer1:loadTexture(ResDefineUtil.Yellow_lines_new_1,UI_TEX_TYPE_PLIST)
	layer1:setAnchorPoint(cc.p(0,0.5))
	local temp_point = building:convertToWorldSpace(cc.p(math.floor(x), math.floor(y)))
	local new_point = buildingView:convertToNodeSpace(temp_point)
	buildingView:addWidget(layer1)
	layer1:setZOrder(-2)
	-- building:addChild(layer1)
	layer1:setPosition(new_point)
	layer1:setRotation(rotation2)
	layer1:setScaleX(len*config.getgScale()/layer1:getContentSize().width)
	layer1:setScaleY(config.getgScale())

	local line = {a = {x = posX, y =posY}, b = {x = posX+xieLen*config.getgScale() *math.cos(math.rad(-rotation1)), y =posY + xieLen*config.getgScale()*math.sin(math.rad(-rotation1))}}
	local _point = building:convertToWorldSpace(cc.p(x,y)) 
	local line_zhi = {a = {x = _point.x, y =_point.y}, b = {x = _point.x+len*config.getgScale()*math.cos(math.rad(-rotation2)), y =_point.y + len*config.getgScale()*math.sin(math.rad(-rotation2))}}

	
	for i, v in ipairs(m_component_line) do
		if config.intersect(line.a, line.b, v.a, v.b) then
			circle:removeFromParentAndCleanup(true)
			layer:removeFromParentAndCleanup(true)
			layer1:removeFromParentAndCleanup(true)
			return
		end
	end

	for i, v in ipairs(m_component_line) do
		if config.intersect(line_zhi.a, line_zhi.b, v.a, v.b) then
			circle:removeFromParentAndCleanup(true)
			layer:removeFromParentAndCleanup(true)
			layer1:removeFromParentAndCleanup(true)
			return
		end
	end

	-- local cacheLine = {}
	-- table.insert(cacheLine,circle)
	-- table.insert(cacheLine,layer)
	-- table.insert(cacheLine,layer1)

	-- list_cache_line[index] = cacheLine
	


	table.insert(m_component_line,line)
	table.insert(m_component_line,line_zhi)
end

local function getPos( index )
	local temp_ = nil
	local temp_Table = nil
	if index == 1 or index == 5 then
		-- return index, nil
	elseif index == 2 or index == 3 or index == 4 then
		temp_ = nagetiIndex
		temp_Table = buildingPosDefined.nageti
	else
		temp_ = smallIndex
		temp_Table = buildingPosDefined.small
	end

	local current_city_id = mainBuildScene.getThisCityid()
	if not current_city_id then return end
	local cityComponentData = mapData.getCityComponentData( math.floor(current_city_id/10000),current_city_id%10000 )
	if not cityComponentData then return end
	local disIndex = nil
	local dis  =nil
	local disT = nil
	for i, v in pairs(cityComponentData) do
		if BUILDING_TYPE[index][v.view] then
			local component = mapData.getObject().building:getChildByTag(v.parentTag)
			if component then
				if index == 1 or index == 5 then
					return index, component
				end
				local temp_point = component:convertToWorldSpace(cc.p(component:getContentSize().width/2,component:getContentSize().height/2))
				local posX,posY = config.countWorldSpace(temp_point.x,temp_point.y,map.getAngel())
				for m,n in ipairs(temp_Table) do
					if not temp_[m] then
						dis =getDistance(n[1]*config.getWinSize().width, posX, n[2]*config.getWinSize().height, posY) 
						if not disIndex or not disT or dis< disT then
							disIndex = m
							disT = dis
						end
					end
				end
				temp_[disIndex] = 1
				return disIndex, component
			end
		end
	end

	if not temp_Table then
		return index,nil
	end

	for i, v in pairs(temp_Table) do
		if not temp_[i] then
			temp_[i] = 1
			return i,nil
		end
	end
end

--生成每行的文字
local function createStrCell(panel, count, str )
	local p_widget = Label:create()
	p_widget:setText(str)
	p_widget:setFontSize(m_FontSize)
	p_widget:setAnchorPoint(cc.p(0,0))
	height = p_widget:getContentSize().height+m_FontOffset
	p_widget:setPosition(cc.p(0, -count*height))
	panel:addChild(p_widget)
	return height
end


--设置自适应的高度和位置
local function setCell( panel, height, str1, str2, str3, index,temp_widget, point)
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local nameIndex = 1
	if cityMessage.city_type == cityTypeDefine.yaosai and index ==1 then
		nameIndex = 2
	elseif cityMessage.city_type == cityTypeDefine.fencheng and index ==1 then
		nameIndex = 3
	end
	panel:setPositionY(panel:getPositionY()+height)
	local image = temp_widget:getChildByName(str1)
	image:setPositionY(panel:getPositionY())
	local mabi = tolua.cast(image:getChildByName(str3),"Label")

	tolua.cast(image:getChildByName(str3),"Label"):setText(buildingInclude[index].name[nameIndex])
	local background = temp_widget:getChildByName(str2)
	local height1 = image:getPositionY()+image:getSize().height
	-- 40是因为图片自带外发光
	background:setSize(CCSize(background:getSize().width, height1+40))


	temp_widget:setContentSize(CCSize(temp_widget:getContentSize().width, height1))
	local pos_x = nil
	local pos_y = nil
	local posIndex = nil
	local component = nil
	posIndex,component = getPos(index)
	if not posIndex or not component then
		-- return
	end
	
	--固定位置
	if index == 1 or index == 5 then
		pos_x = buildingPosDefined.positi[posIndex][1]
		pos_y = buildingPosDefined.positi[posIndex][2]
	elseif index == 2 or index == 3 or index == 4 then
		-- posIndex,component = getPos(index)
		pos_x = buildingPosDefined.nageti[posIndex][1]
		pos_y = buildingPosDefined.nageti[posIndex][2]
	else
		-- posIndex,component = getPos( index )
		pos_x = buildingPosDefined.small[posIndex][1]
		pos_y = buildingPosDefined.small[posIndex][2]
	end
	
	temp_widget:setPosition(cc.p(config.getWinSize().width*pos_x-temp_widget:getContentSize().width*0.5*config.getgScale(), 
		config.getWinSize().height*pos_y- 0.5*height1*config.getgScale()))

	local name_widget = nil
	if component then
		-- name_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_0.json")
		-- name_widget:setScale(config.getgScale())
		-- local label_name = uiUtil.getConvertChildByName(name_widget,"label_name")
		-- label_name:setText(buildingInclude[index].name[nameIndex])
		connectLine( city_msg_layer, temp_widget, height1,component)
	end

	-- return name_widget
end

--封禅台
local function setfengshen( )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_7.json")
	temp_widget:setTag(993)
	temp_widget:setScale(config.getgScale())
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local height = nil
	local count = 0
	local cost = 0
	local panel = tolua.cast(temp_widget:getChildByName("Panel_95193"),"Layout")
	for i ,v in pairs(buildingInclude[7].id) do
		if allTableData[dbTableDesList.build.name][current_city_id*100 + v] then
			local level = allTableData[dbTableDesList.build.name][current_city_id*100 + v].level
			if level > 0 then
				count = count + 1
				cost = cost+ Tb_cfg_build_cost[v*100+level].build_area
				height = createStrCell(panel, count, Tb_cfg_build_cost[v*100+level].show_tips)
			end
		end
	end

	setCell( panel, count*height, "ImageView_89371_0_1_0_0", "ImageView_89369_0_1_0_0", "Label_90047_0_0_1_0", 7,temp_widget,cost)

	return temp_widget
end

--社稷坛
local function setshejitan( )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_6.json")
	temp_widget:setTag(994)
	temp_widget:setScale(config.getgScale())
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local height = nil
	local count = 0
	local cost = 0
	local panel = tolua.cast(temp_widget:getChildByName("Panel_95192"),"Layout")
	for i ,v in pairs(buildingInclude[6].id) do
		if allTableData[dbTableDesList.build.name][current_city_id*100 + v] then
			local level = allTableData[dbTableDesList.build.name][current_city_id*100 + v].level
			if level > 0 then
				count = count + 1
				cost = cost+ Tb_cfg_build_cost[v*100+level].build_area
				height = createStrCell(panel, count, Tb_cfg_build_cost[v*100+level].show_tips)
			end
		end
	end


	setCell( panel, count*height, "ImageView_89371_0_1_0", "ImageView_89369_0_1_0", "Label_90047_0_0_1",6,temp_widget,cost)
	return temp_widget
end

--经济区
local function setjingji( )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_5.json")
	temp_widget:setTag(995)
	temp_widget:setScale(config.getgScale())
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local height = nil
	local count = 0
	local cost = 0
	local panel = tolua.cast(temp_widget:getChildByName("Panel_95191"),"Layout")
	for i ,v in pairs(buildingInclude[2].id) do
		if allTableData[dbTableDesList.build.name][current_city_id*100 + v] then
			local level = allTableData[dbTableDesList.build.name][current_city_id*100 + v].level
			if level > 0 then
				if Tb_cfg_build_cost[v*100+level] then
					count = count + 1
					cost = cost + Tb_cfg_build_cost[v*100+level].build_area
					height = createStrCell(panel, count, Tb_cfg_build_cost[v*100+level].show_tips)
				end
			end
		end
	end


	setCell( panel, count*height, "ImageView_89371_0_0", "ImageView_89369_0_0","Label_90047_0_0", 2,temp_widget,cost)


	return temp_widget
end

--部队区
local function setbudui( )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_4.json")
	temp_widget:setTag(996)
	temp_widget:setScale(config.getgScale())
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local height = nil
	local count = 0
	local cost = 0
	local firstLine = ""
	local flag = false
	local secLine = ""
	local firstCount = 0
	local panel = tolua.cast(temp_widget:getChildByName("Panel_95189"),"Layout")
	for i ,v in pairs(buildingInclude[3].id) do
		-- 预备兵是募兵所建造完就有的，所以就算没有预备役所也要显示预备兵数
		if v == 36  and allTableData[dbTableDesList.build.name][current_city_id*100 + 37] and not allTableData[dbTableDesList.build.name][current_city_id*100 + v] then
			count = count +1
			height = createStrCell(panel, count, languagePack["ForcesSoldier"].."  "..userData.getCityReserveForcesSoldierNum(current_city_id).."/"..REDIF_INIT_CUR)
		end

		if allTableData[dbTableDesList.build.name][current_city_id*100 + v] then
			local level = allTableData[dbTableDesList.build.name][current_city_id*100 + v].level

			if level > 0 then
				cost = cost + Tb_cfg_build_cost[v*100+level].build_area
				--校场
				if v == 40 then
					count = count + 1
					height = createStrCell(panel, count, stringFunc.gsub( Tb_cfg_build_cost[v*100+level].show_tips, "d" ,{armyData.getChildArmyMaxNumInCity(current_city_id)} ))
					--兵力
					count = count + 1
					createStrCell(panel,count,languagePack["bingli"]..userCityData.getCityHp(current_city_id))
					--粮食产量
					count = count + 1
					createStrCell(panel,count,languagePack["bingliangxiaohao"]..cityMessage.food_cost.."/"..languagePack["xiaoshi"])
					--征兵队列数
					count = count + 1
					createStrCell(panel,count,languagePack['Draft'].." "..userCityData.get_leave_zb_queue_in_city(current_city_id).."/"..userCityData.get_all_zb_queue_num(current_city_id))
				--兵营
				elseif v==30 then
					count = count +1
					height = createStrCell(panel, count, Tb_cfg_build_cost[v*100+level].show_tips)
				elseif v== 51 or v== 52 or v== 53 or v== 54 then
					if not flag then
						count = count + 1
						height = createStrCell(panel, count, languagePack["buduizhandoushuxing"])
						flag = true
					end

					count = count + 1
					height = createStrCell(panel, count, Tb_cfg_build_cost[v*100+level].show_tips)
				elseif v== 36 then
					local armyCount = userData.getCityReserveForcesSoldierNum(current_city_id)
					local arrStr = stringFunc.anlayerOnespot(Tb_cfg_build_cost[v*100+level].show_tips, "\n", false)
					count = count + 1
					height = createStrCell(panel, count, stringFunc.gsub( arrStr[1], "d" ,{armyCount} ))
					-- count = count + 1
					-- height = createStrCell(panel, count, arrStr[2])
				end
			end
		end
	end
	-- if firstLine ~= "" then
	-- 	count = count + 1
	-- 	height = createStrCell(panel, count, firstLine)
	-- end

	-- if secLine ~= "" then
	-- 	count = count + 1
	-- 	height = createStrCell(panel, count, secLine)
	-- end


	setCell( panel, count*height, "ImageView_89371_0_0_0", "ImageView_89369_0_0_0","Label_90047_0_0_0", 3,temp_widget,cost)
	
	return temp_widget
end

--将领区
local function setjianglin( )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_3.json")
	temp_widget:setTag(997)
	temp_widget:setScale(config.getgScale())
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local height = nil
	local count = 0
	local cost = 0
	local panel = tolua.cast(temp_widget:getChildByName("Panel_95127"),"Layout")
	for i ,v in pairs(buildingInclude[4].id) do
		if allTableData[dbTableDesList.build.name][current_city_id*100 + v] then
			local level = allTableData[dbTableDesList.build.name][current_city_id*100 + v].level
			if level > 0 then
				cost = cost + Tb_cfg_build_cost[v*100+level].build_area
				count = count + 1
				local junshi, qianfen = armyData.getCountForMidAndCounsellor(current_city_id)
				--军师（军议厅）
				if v == 41 then
					height = createStrCell(panel, count, stringFunc.gsub( Tb_cfg_build_cost[v*100+level].show_tips, "d" ,{junshi} ))
				--前锋 统帅厅
				-- elseif v==42 then
					-- height = createStrCell(panel, count, stringFunc.gsub( Tb_cfg_build_cost[v*100+level].show_tips, "d" ,{qianfen} ))
				else
					height = createStrCell(panel, count, Tb_cfg_build_cost[v*100+level].show_tips)
				end
			end
		end
	end



	setCell( panel, count*height, "ImageView_89371", "ImageView_89369", "Label_90047",4,temp_widget,cost,name_widget)


	return temp_widget
end


--城主府
local function setChengzhufu( )
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_1.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local height = nil
	local count = 0

	
	local building_id = 0
	local city_type = landData.get_world_city_info(current_city_id).city_type
	if city_type == cityTypeDefine.yaosai then
		building_id = buildingInclude[1].id[2]
	elseif city_type == cityTypeDefine.zhucheng then
		building_id = buildingInclude[1].id[1]
	else
		building_id = buildingInclude[1].id[3]
	end
	local level = allTableData[dbTableDesList.build.name][current_city_id*100 + building_id].level
	local cost = 0
	if level > 0 then
		cost = Tb_cfg_build_cost[building_id*100+level].build_area
	end

	local panel = tolua.cast(temp_widget:getChildByName("Panel_95194"),"Layout")

	-- count = count + 1
	--建设值
	-- height = createStrCell(panel, count, languagePack["jianshezhi"]..cityMessage.build_area_cur .. "/" .. cityMessage.build_area_max)

	--繁荣度
	-- count = count + 1
	-- createStrCell(panel, count, languagePack["fanrongdu"]..cityMessage.prosperity_cur)

	--耐久
	count = count + 1
	local cityMessage2 = landData.get_world_city_info(current_city_id)
	local current_durable = cityMessage2.durability_cur
	local max_durable = cityMessage2.durability_max
	if cityMessage2.durability_time ~= 0 then
		local add_durable = userData.getIntervalData(cityMessage2.durability_time,2*24*60*60,max_durable)
		current_durable = current_durable + math.floor(add_durable)
		if current_durable > max_durable then
			current_durable = max_durable
		end
	end
	height = createStrCell(panel, count, languagePack["naijiudu"]..current_durable .. "/" .. max_durable)

	--规模
	if city_type ~= cityTypeDefine.yaosai then
		count = count + 1
		local extend_wid = {}
		if string.len(cityMessage.extend_wids)>0 then
			extend_wid =stringFunc.anlayerOnespot(cityMessage.extend_wids,",", false)
		end
		createStrCell(panel, count, languagePack["yikuojiantudishu"]..(#extend_wid).."/"..(BUILD_EXPAND-1))
	end

	
	setCell( panel, count*height, "ImageView_89371_0", "ImageView_89369_0","Label_90047_0", 1,temp_widget,cost)

	return temp_widget
end

--城防区
local function setChengfang()
	local current_city_id = mainBuildScene.getThisCityid()
	local cityMessage = userCityData.getUserCityData(current_city_id)
	local height = nil
	local count = 0
	local cost = 0
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/new_overview_screen_2.json")
	temp_widget:setTag(998)
	temp_widget:setScale(config.getgScale())
	local panel = tolua.cast(temp_widget:getChildByName("Panel_95190"),"Layout")
	local flag = false
	local str = nil
	local component_table = {}
	for i ,v in ipairs(buildingInclude[5].id) do
		if allTableData[dbTableDesList.build.name][current_city_id*100 + v] then
			local level = allTableData[dbTableDesList.build.name][current_city_id*100 + v].level
			if level > 0 then
				cost = cost + Tb_cfg_build_cost[v*100+level].build_area
				--烽火台
				if v == 63 then
					count = count + 1
					table.insert(component_table,{count, Tb_cfg_build_cost[v*100+level].show_tips})
				elseif v== 64 or v==65 then
					if not flag then
						count = count + 1
						table.insert(component_table,{count, languagePack["fangyubudui"]})
					end
					count = count + 1
					table.insert(component_table,{count, Tb_cfg_build_cost[v*100+level].show_tips})

					flag = true
				else
					count = count + 1
					table.insert(component_table,{count, Tb_cfg_build_cost[v*100+level].show_tips})
				end
			end
		end
	end

	for i, v in ipairs(component_table) do
		height= createStrCell(panel, v[1], v[2])
	end



	setCell( panel, count*height, "ImageView_89371_0_1", "ImageView_89369_0_1", "Label_90047_0_0_0_0",5,temp_widget,cost)



	return temp_widget
end

local function getTips ( )
	local current_city_id = mainBuildScene.getThisCityid()
	local widgetTable = {} -- 提示框
	-- local nameTable = {} -- 城市名字
	if not current_city_id then return false end
	local cityMessage = userCityData.getUserCityData(current_city_id)
	-- if cityMessage.city_type == cityTypeDefine.yaosai then
	
	-- if
	local build = nil
	local temp_index = {4,3,2,6,7,1,5}

	for i, v in ipairs(temp_index) do
		for m,n in pairs(buildingInclude[v].id) do
			build = allTableData[dbTableDesList.build.name][current_city_id*100 + n]
			if build and build.level > 0 then
				local temp_widget,name_widget = nil
				--城主府
				if v == 1 then
					table.insert(widgetTable,setChengzhufu())
				--经济区
				elseif v==2 then
					table.insert(widgetTable,setjingji())
				--部队区
				elseif v==3 then
					table.insert(widgetTable,setbudui())
				--将领区
				elseif v== 4 then
					table.insert(widgetTable,setjianglin())
				--城防区
				elseif v== 5 then
					table.insert(widgetTable,setChengfang())
				--社稷坛
				elseif v== 6 then
					table.insert(widgetTable,setshejitan())
				--封神台
				elseif v==7 then
					table.insert(widgetTable,setfengshen())
				end
				
				-- if temp_widget and name_widget then 
				-- 	widgetTable[v] = temp_widget
				-- end
				-- if name_widget then 
				-- 	nameTable[v] = name_widget
				-- end
				break
			end
		end
	end

	-- end
	return widgetTable
end


function do_remove_self()
	if city_msg_layer then
		list_cache_name_widgets = nil
		list_cache_widgets = nil

		city_msg_layer:removeFromParentAndCleanup(true)
		city_msg_layer = nil
		smallIndex = nil
		nagetiIndex = nil
		removeLineData( )
		UIUpdateManager.remove_prop_update(dbTableDesList.user_city.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
		UIUpdateManager.remove_prop_update(dbTableDesList.world_city.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
		UIUpdateManager.remove_prop_update(dbTableDesList.army.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
		UIUpdateManager.remove_prop_update(dbTableDesList.user_res.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
		UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
		UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.add, cityMsg.dealWithMsgUpdate)
		UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.remove, cityMsg.dealWithMsgUpdate)
		uiManager.remove_self_panel(uiIndexDefine.CITY_MSG)

	end
	
	optionController.resetOptions()
end

local function hideEffect(callback)
	if not city_msg_layer then return end
	local function doHideEffect(widget,isLast)
		local finally = cc.CallFunc:create(function ( )
	        widget:setVisible(false)
	        if isLast and  callback then callback() end
    	end)
    	-- widget:setVisible(true)
    	local actionHide = CCFadeOut:create(0.3)
    	widget:runAction(animation.sequence({actionHide,finally}))
	end

	-- if list_cache_name_widgets then
	-- 	for i = 1 ,#list_cache_name_widgets do
	-- 		doHideEffect(list_cache_name_widgets[i],i == #list_cache_name_widgets)
	-- 	end
	-- else
	-- 	if callback then callback() end
	-- end

	-- if list_cache_line then 
	-- 	for k,v in pairs(list_cache_line) do 
	-- 		for kk,vv in pairs(v) do 
	-- 			doHideEffect(vv)
	-- 		end
	-- 	end
	-- end

	if list_cache_widgets then
		for i = 1 ,#list_cache_widgets do
			doHideEffect(list_cache_widgets[i],i == #list_cache_widgets)
		end
	else
		if callback then callback() end
	end

end
function remove_self()
	if mainOption.getIsInSwitchingEnable() then return end
	-- do_remove_self()
	-- if uiManager.isClearAll() then 
 --        do_remove_self()
 --        return 
 --    end
 --    hideDetails(true)
 --    hideLines(true)
 --    hideNames(true)

	hideEffect(do_remove_self)
end


function reloadData( needEffect )

	if buildingExpandTitle.getInstance() then 
		--打开扩建的时候不应该弹出总览
		return 
	end

	if not city_msg_layer then
		return
	end

	-- if list_cache_name_widgets then 
	-- 	for k,v in pairs(list_cache_widgets) do 
	-- 		v:removeFromParentAndCleanup(true)
	-- 	end
	-- end
	-- if list_cache_name_widgets then 
	-- 	for k,v in pairs(list_cache_name_widgets) do 
	-- 		v:removeFromParentAndCleanup(true)
	-- 	end
	-- end

	city_msg_layer:clear()
	list_cache_widgets = nil
	nagetiIndex = {}
	smallIndex = {}
	removeLineData( )



	

	-- list_cache_widgets,list_cache_name_widgets = getTips()
	local  widgets = getTips()

	-- if list_cache_name_widgets then 
	-- 	for i ,v in pairs( list_cache_name_widgets ) do
	-- 		city_msg_layer:addWidget(v)
	-- 		v:setVisible(false)
	-- 	end
	-- end

	-- if list_cache_widgets then 
	-- 	for i ,v in pairs( list_cache_widgets ) do
	-- 		city_msg_layer:addWidget(v)
	-- 		v:setVisible(false)
	-- 		v:setTouchEnabled(true)
	-- 	end
	-- end

	if widgets then
		for i ,v in pairs( widgets) do
			city_msg_layer:addWidget(v)
		end
	end

	local showEffect = function(widget)
		local finally = cc.CallFunc:create(function ( )
	        -- pass
	    end)
		widget:setScale(0.8 * config.getgScale())
	    local actionScale = CCScaleTo:create(0.3,1* config.getgScale())
	    local actionShow = CCFadeIn:create(0.3)
	    local scaleAndShow = CCSpawn:createWithTwoActions(actionScale,actionShow)
	    widget:runAction(animation.sequence({scaleAndShow,finally}))
	end
	if widgets and needEffect then 
		
	    for i ,v in pairs( widgets) do
			showEffect(v)
		end
	end

	list_cache_widgets = widgets

	-- hideDetails(false)
	-- hideLines(false)

	
	-- local showDetailByIndx = function(index)
	-- 	for k,v in pairs(list_cache_line) do 
	-- 		local flagVisible = k == index
	-- 		for kk,vv in pairs(v) do
	-- 			vv:setVisible(flagVisible)
	-- 			if flagVisible then 
	-- 				widgetShowEffect(vv,false)
	-- 			else
	-- 				widgetHideEffect(vv)
	-- 			end
	-- 		end
	-- 	end

	-- 	for k,v in pairs(list_cache_widgets) do 
	-- 		local flagVisible = k == index
	-- 		v:setVisible(flagVisible)
	-- 		if flagVisible then 
	-- 			widgetShowEffect(v)
	-- 		else
	-- 			widgetHideEffect(v)
	-- 		end
	-- 	end
	-- end
	
	-- if list_cache_name_widgets  then 
	--     for i ,v in pairs( list_cache_name_widgets) do
	--     	v:setTouchEnabled(true)
	--     	v:addTouchEventListener(function(sender,eventType)
	--     		if eventType == TOUCH_EVENT_ENDED then 
	--     			showDetailByIndx(i)
	--     		end
	--     	end)
	--     	if needEffect then 
	-- 			widgetShowEffect(v)
	-- 		end
	-- 		v:setVisible(true)
	-- 	end
	-- end
end

function create()
	if mainOption.getIsInSwitchingEnable() then return end

	require("game/buildScene/buildingExpandTitle")
	if not mainBuildScene.getThisCityid() then return end
	if buildingExpandTitle.getInstance() then 
		--打开扩建的时候不应该弹出总览
		return 
	end
	if city_msg_layer then
		return
	end

	

	city_msg_layer = TouchGroup:create()

	uiManager.add_panel_to_layer(city_msg_layer, uiIndexDefine.CITY_MSG)


	optionController.removeOptions()

	reloadData(true)

	UIUpdateManager.add_prop_update(dbTableDesList.user_city.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.world_city.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.army.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.user_res.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, cityMsg.dealWithMsgUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, cityMsg.dealWithMsgUpdate)
	UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.remove, cityMsg.dealWithMsgUpdate)

end

function dealWithMsgUpdate(packet)
	reloadData()
end

-- cityMsg = { 	create =create,
-- 				remove_self = remove_self,
-- 				dealwithTouchEvent = dealwithTouchEvent,
-- 				dealWithMsgUpdate = dealWithMsgUpdate
-- 			}