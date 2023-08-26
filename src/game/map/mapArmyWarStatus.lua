-- mapArmyWarStatus.lua
module("MapArmyWarStatus", package.seeall)

local tViewData = {}


local function getColor( relation)
	if relation == mapAreaRelation.free_enemy or relation == mapAreaRelation.attach_enemy then
		return "red",1
	elseif relation == mapAreaRelation.own_self then
		return "green",3
	else
		return "blue",2
	end
end

local function isNotInclude( color, allColor )
	local flag = false
	for i,v in ipairs(allColor) do
		if v == color then
			return false
		end
	end
	return true
end

local function setViewPosWhenMove( )
	local sprite = nil
	for i, v in pairs(tViewData) do
		sprite = mapData.getLoadedMapLayer(math.floor(i/10000), i%10000)
		if sprite then
			ObjectManager.setObjectPos(v,sprite:getPositionX(), sprite:getPositionY() )
		end
	end
end

function removeAll( )
	-- local m_pRoot = map.getSightLand()
	-- m_pRoot:clear()
	for i, v in pairs(tViewData) do
		-- v:removeFromParentAndCleanup(true)
		tolua.cast(v:getChildByName("Panel_animation"),"Layout"):removeAllChildrenWithCleanup(true)
		MapObjectPool.pushSprite("test/sight_view_label.json", v)
	end
	tViewData = {}
end

function removeByWid( coorX, coorY )
	if tViewData[coorX*10000+coorY] then
		tolua.cast(tViewData[coorX*10000+coorY]:getChildByName("Panel_animation"),"Layout"):removeAllChildrenWithCleanup(true)
		MapObjectPool.pushSprite("test/sight_view_label.json", tViewData[coorX*10000+coorY])
		tViewData[coorX*10000+coorY] = nil
	end
end

local function initJson( widget)
	-- tolua.cast(widget:getChildByName("mianzhan"),"ImageView"):setVisible(false)

	for i=1, 3 do
		tolua.cast(widget:getChildByName("aid_"..i),"ImageView"):setVisible(false)
	end

	for i=1, 3 do
		tolua.cast(widget:getChildByName("attack_"..i),"ImageView"):setVisible(false)
	end

end

function create(coorX, coorY )
	local sprite = mapData.getLoadedMapLayer(coorX, coorY)
	if not sprite then return end
	local tAid = {name ={"aid_1","aid_2"}, color = {}}
	local tAttack = {name ={"attack_1","attack_2","attack_3"},color= {}}
	removeByWid(coorX, coorY)
	local viewInfo = nil
	if not mapData.isInArea(coorX,coorY) then return end

	local buildingData =mapData.getBuildingData()
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].view_info then 
		viewInfo = buildingData[coorX][coorY].view_info
	end

	if not viewInfo then return end

	local isadd = false
	local city_type = nil
	if buildingData[coorX] and buildingData[coorX][coorY] and buildingData[coorX][coorY].cityType then
		city_type = buildingData[coorX][coorY].cityType
	end

	

	local zhushouCount_green = 0
	local zhushouCount_red = 0
	local zhushouCount_blue = 0

	local xiuzhengCount_green = 0
	local xiuzhengCount_red = 0
	local xiuzhengCount_blue = 0

	local tmp_count = 0

	local image = nil
	local index = nil
	local color = nil
	local isAddAnimation = false
	local widget = nil
	if viewInfo then
		local initWidget = function ( )
			if not widget then
				-- widget = MapObjectPool.popSprite("game/script_json/sight_view_label","lua")
				widget = MapObjectPool.popSprite("test/sight_view_label.json")
				initJson( widget)
			end
		end
		-- if not widget then
		-- 	widget = MapObjectPool.popSprite("test/sight_view_label.json")--GUIReader:shareReader():widgetFromJsonFile("test/sight_view_label.json")
		-- 	initJson( widget)
		-- end
		for i, v in ipairs(viewInfo) do

			--调动
			if v.state == armyState.zhuzhaed then

			--援军 --驻守
			elseif v.state == armyState.yuanjuned then
				initWidget()
				isadd = true
				color,index = getColor(v.relation)
				local aid = tolua.cast(widget:getChildByName("aid_"..index),"ImageView")
				aid:setVisible(true)

				image = tolua.cast(aid:getChildByName("ImageView_386043"),"ImageView")
				image:setVisible(false)

				if color == "green" then
					zhushouCount_green = zhushouCount_green + 1
					tmp_count = zhushouCount_green
				elseif color == "blue" then
					zhushouCount_blue = zhushouCount_blue + 1
					tmp_count = zhushouCount_blue
				elseif color == "red" then
					zhushouCount_red = zhushouCount_red + 1
					tmp_count = zhushouCount_red
				end

				if tmp_count > 1 then
					image:setVisible(true)
					tolua.cast(image:getChildByName("Label_386045"),"Label"):setText(tmp_count)
				end

				if color == "red" then
					local green_aid = tolua.cast(widget:getChildByName("aid_3"),"ImageView")
					aid:setPosition(cc.p(green_aid:getPositionX(), green_aid:getPositionY()))
				end

				if color == "green" then
				end
			--战间休息 --休整
			elseif v.state == armyState.sleeped then
				initWidget()
				isadd = true
				color,index = getColor(v.relation)
				local attack = tolua.cast(widget:getChildByName("attack_"..index),"ImageView")
				attack:setVisible(true)

				image = tolua.cast(attack:getChildByName("ImageView_386052"),"ImageView")
				image:setVisible(false)
				
				if color == "green" then
					xiuzhengCount_green = xiuzhengCount_green + 1
					tmp_count = xiuzhengCount_green
				elseif color == "blue" then
					xiuzhengCount_blue = xiuzhengCount_blue + 1
					tmp_count = xiuzhengCount_blue
				elseif color == "red" then
					xiuzhengCount_red = xiuzhengCount_red + 1
					tmp_count = xiuzhengCount_red
				end

				if not isAddAnimation and (color == "blue" or color == "red") then
					isAddAnimation = true
					CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/jiaozhan.ExportJson")
					local armature = CCArmature:create("jiaozhan")
					armature:getAnimation():playWithIndex(0)
					tolua.cast(widget:getChildByName("Panel_animation"),"Layout"):addChild(armature)
					armature:setPosition(cc.p(widget:getContentSize().width/2+10,widget:getContentSize().height/2+10))
				end
				if tmp_count > 1 then
					image:setVisible(true)
					tolua.cast(image:getChildByName("Label_386053"),"Label"):setText(tmp_count)
				end
			end
		end
	end

	if isadd then
		ObjectManager.addObject(ARMY_WAR_STATUS,widget, true, sprite:getPositionX(), sprite:getPositionY(), false, true )
		-- table.insert(tViewData, coorX*10000+ coorY, widget)
		tViewData[coorX*10000+ coorY] = widget
	end
	ObjectManager.addObjectCallBack(ARMY_WAR_STATUS, setViewPosWhenMove, setViewPosWhenMove)
end

function reloadAll( )
	removeAll()
	local buildingData =mapData.getBuildingData()
	local area = mapData.getArea()
	for i = area.row_up, area.row_down do
		for m = area.col_left, area.col_right do
			if buildingData[i] and buildingData[i][m] and buildingData[i][m].view_info then
				create(i,m)
			end
		end
	end
end

function getMapLandInfoArr( )
	return tViewData
end

-- MapLandInfo = {
-- 				create = create,
-- 				removeByWid = removeByWid,
-- 				removeAll = removeAll,
-- 				reloadAll = reloadAll,
-- 				getCannotWarTime = getCannotWarTime,
-- 				setCannotWarMarkVisible = setCannotWarMarkVisible,
-- 				getMapLandInfoArr = getMapLandInfoArr
-- }