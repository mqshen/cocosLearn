--小地图的州地图部分
module("MiniMapState", package.seeall)
local m_stateId = nil
local m_widget = nil
local item_panel_copy = nil
local npcTable = nil
local m_idx = nil
local state_image = nil
local img = nil
local panel_state = nil
local Panel_root = nil
local layer_touch_ = nil
local s_dSqrt2 = math.sqrt(2)
local mark_state = nil
local m_root_widget = nil
local touch_mapPos = { x = nil, y = nil}
local m_layer_pos = nil
local scaleTime = 0.2
local m_arrNpcCityData = nil
local function refreshCell(table,idx )
	if idx and table:cellAtIndex(idx) then
		local layer = tolua.cast(table:cellAtIndex(idx):getChildByTag(123),"TouchGroup")
	    if layer then
	    	if layer:getWidgetByTag(1) then
	    		local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
		        local select_image = tolua.cast(item_panel:getChildByName("img_selected"),"ImageView")
		        select_image:setVisible(false)
	    	end
	    end
	end
end

local function tableCellTouched(table,cell)
	refreshCell(table,m_idx )
    m_idx = cell:getIdx()
    local widx, widy =math.floor(npcTable[m_idx+1]/10000), npcTable[m_idx+1]%10000
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	if layer:getWidgetByTag(1) then
    		local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
	        local select_image = tolua.cast(item_panel:getChildByName("img_selected"),"ImageView")
	        select_image:setVisible(true)
	        setMarkPosByWid(widx, widy,true )
	        miniMapManager.set_pos_txt(widx, widy)
    	end
    end
end

local function cellSizeForTable(table,idx)
    return 52,149
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if nil == cell then
        cell = CCTableViewCell:new()
        local mlayer = TouchGroup:create()
	    local item_panel = item_panel_copy:clone()
	    item_panel:setVisible(true)

        item_panel:setPosition(cc.p(0,0))
	    mlayer:addWidget(item_panel)
	    item_panel:setTag(1)
	    cell:addChild(mlayer)
	    mlayer:setTag(123)
    end

    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
	    if layer:getWidgetByTag(1) then
	        local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
	        local name = tolua.cast(item_panel:getChildByName("Label_name"),"Label")
	        local select_image = tolua.cast(item_panel:getChildByName("img_selected"),"ImageView")
	        name:setText(Tb_cfg_world_city[npcTable[idx+1]].name.." "..languagePack["lv"]..Tb_cfg_world_city[npcTable[idx+1]].param%100)
	        if m_idx == idx then
	        	select_image:setVisible(true)
	        else
	        	select_image:setVisible(false)
	        end
	    end
    end
    return cell
end

local function scrollViewDidScroll(table)
	local temp_widget = m_widget
	-- local cityPanel = tolua.cast(temp_widget:getChildByName("ImageView_548874"),"ImageView" )

	if table:getContentOffset().y < 0 then
		tolua.cast(temp_widget:getChildByName("ImageView_down"),"ImageView" ):setVisible(true)
	else
		tolua.cast(temp_widget:getChildByName("ImageView_down"),"ImageView" ):setVisible(false)
	end

	if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
		tolua.cast(temp_widget:getChildByName("ImageView_up"),"ImageView" ):setVisible(true)
	else
		tolua.cast(temp_widget:getChildByName("ImageView_up"),"ImageView" ):setVisible(false)
	end
end

local function numberOfCellsInTableView(table)
	return #stateData.getNpcCityInState(m_stateId)+#stateData.getGuangqiaInState(m_stateId)
end

-- 根据传过来的wid， 返回像素坐标点
function calcViewAtom(iWidX,iWidY)
	
	local dScaleY = Tb_cfg_client_mini_map_region[m_stateId].scale_y/100
	local dScaleX = Tb_cfg_client_mini_map_region[m_stateId].scale_x/100
	local iWidXDiff = iWidX-math.floor(Tb_cfg_world_anchor[m_stateId].left_up_wid/10000)+1501
	local iWidYDiff = iWidY-Tb_cfg_world_anchor[m_stateId].left_up_wid%10000+1501
	return Tb_cfg_client_mini_map_region[m_stateId].left_up_pos[1]+(iWidYDiff + iWidXDiff)*s_dSqrt2/2.0*dScaleX, -Tb_cfg_client_mini_map_region[m_stateId].left_up_pos[2]-s_dSqrt2/4.0 * (iWidXDiff - iWidYDiff)*dScaleY
end

-- 根据像素点坐标返回wid
local function calcViewWid(x,y )
	local dLeftUpViewXDiff = x - Tb_cfg_client_mini_map_region[m_stateId].left_up_pos[1]
	local dLeftUpViewYDiff = -y-Tb_cfg_client_mini_map_region[m_stateId].left_up_pos[2]
	local dScaleY = Tb_cfg_client_mini_map_region[m_stateId].scale_y/100
	local dScaleX = Tb_cfg_client_mini_map_region[m_stateId].scale_x/100
	return math.floor((math.floor(Tb_cfg_world_anchor[m_stateId].left_up_wid/10000)-1501) + (dLeftUpViewXDiff/dScaleX + 2*dLeftUpViewYDiff/dScaleY)/s_dSqrt2),
		math.floor((Tb_cfg_world_anchor[m_stateId].left_up_wid%10000-1501) + (dLeftUpViewXDiff/dScaleX - 2*dLeftUpViewYDiff/dScaleY)/s_dSqrt2)
end

local function wharfDirection( wid )
	local x = math.floor(wid/10000)
	local y = wid%10000
	local temp_x, temp_y = nil, nil
	-- local direction = 1 -- x坐标一样
	-- 
	if worldJoinList[wid] then
		for i, v in ipairs(worldJoinList[wid]) do
			if v ~= wid then
				temp_x, temp_y = math.floor(v/10000), v%10000
				if temp_x == x then
					-- direction = 1
					if temp_y > y then
						return 2
					else
						return 1
					end
				else
					-- direction = 2
					if temp_x > x then
						return 1
					else
						return 2
					end
				end
			end

		end
	end
end

local function drawNode( )
	local own_state = stateData.stateInMap(math.floor(userData.getMainPos()/10000), userData.getMainPos()%10000)
	if own_state and own_state == m_stateId then
		layer = ImageView:create()
		layer:loadTexture(ResDefineUtil.zhucheng_00001, UI_TEX_TYPE_PLIST)
		layer:setPosition(cc.p(calcViewAtom(math.floor(userData.getMainPos()/10000),userData.getMainPos()%10000)))
		state_image:addChild(layer,1)
	end

	local capitalParam = {}
    for i, v in ipairs(REGION_CAPITAL_PARAM) do
    	if NPC_CAPITAL_PARAM ~= v then
       		capitalParam[v] = 1
       	end
    end

    m_layer_pos = Layout:create()
    m_layer_pos:setSize(CCSizeMake(1,1))
    state_image:addChild(m_layer_pos)
    m_layer_pos:setVisible(false)

    local first_rotation = nil
	local first_len = nil
	local second_len = nil
	local second_rotation = nil
	local line1 = nil
	local line_sec = nil

	local npcCityName = nil

    local drawLine = function ( wid)
    	if not Tb_cfg_client_mini_map_name[wid] then return end

    	first_rotation = animation.pointRotate(cc.p(Tb_cfg_client_mini_map_name[wid].pos[2][1], -Tb_cfg_client_mini_map_name[wid].pos[2][2]), ccp(Tb_cfg_client_mini_map_name[wid].pos[1][1], -Tb_cfg_client_mini_map_name[wid].pos[1][2]))
    	-- local second_rotation = ccpAngle(cc.p(Tb_cfg_client_mini_map_name[wid].pos[3][1], -Tb_cfg_client_mini_map_name[wid].pos[3][2]), ccp(Tb_cfg_client_mini_map_name[wid].pos[2][1], -Tb_cfg_client_mini_map_name[wid].pos[2][2]))
    	first_len = ccpDistance(cc.p(Tb_cfg_client_mini_map_name[wid].pos[1][1], Tb_cfg_client_mini_map_name[wid].pos[1][2]), ccp(Tb_cfg_client_mini_map_name[wid].pos[2][1], Tb_cfg_client_mini_map_name[wid].pos[2][2]))
    	second_len = ccpDistance(cc.p(Tb_cfg_client_mini_map_name[wid].pos[2][1], Tb_cfg_client_mini_map_name[wid].pos[2][2]), ccp(Tb_cfg_client_mini_map_name[wid].pos[3][1], Tb_cfg_client_mini_map_name[wid].pos[3][2]))
    	second_rotation = animation.pointRotate(cc.p(Tb_cfg_client_mini_map_name[wid].pos[3][1], -Tb_cfg_client_mini_map_name[wid].pos[3][2]),  ccp(Tb_cfg_client_mini_map_name[wid].pos[2][1], -Tb_cfg_client_mini_map_name[wid].pos[2][2]))
    	line1 = ImageView:create()
    	line1:loadTexture("Yellow_lines_new_1.png", UI_TEX_TYPE_PLIST)
    	line1:setAnchorPoint(cc.p(0, 0.5))
    	line1:setRotation(-first_rotation)
    	line1:setScaleX(first_len/line1:getSize().width)
    	m_layer_pos:addChild(line1)
    	line1:setPosition(cc.p(Tb_cfg_client_mini_map_name[wid].pos[2][1], -Tb_cfg_client_mini_map_name[wid].pos[2][2]))

    	line_sec = ImageView:create()
    	line_sec:loadTexture("Yellow_lines_new_1.png", UI_TEX_TYPE_PLIST)
    	line_sec:setAnchorPoint(cc.p(0, 0.5))
    	line_sec:setRotation(-second_rotation)
    	line_sec:setScaleX(second_len/line_sec:getSize().width)
    	m_layer_pos:addChild(line_sec)
    	line_sec:setPosition(cc.p(Tb_cfg_client_mini_map_name[wid].pos[3][1], -Tb_cfg_client_mini_map_name[wid].pos[3][2]))

    	npcCityName = Label:create()
    	npcCityName:setAnchorPoint(cc.p(0,1))
    	npcCityName:setFontSize(16)
    	npcCityName:setColor(ccc3(255,213,110))
    	npcCityName:setText(Tb_cfg_world_city[wid].name.." Lv."..Tb_cfg_world_city[wid].param%100)
    	m_layer_pos:addChild(npcCityName)
    	npcCityName:setPosition(cc.p(Tb_cfg_client_mini_map_name[wid].pos[4][1], -Tb_cfg_client_mini_map_name[wid].pos[4][2]))
    end


	local layer = nil
	for i, v in pairs(stateData.getNpcCityInState(m_stateId)) do
		layer = ImageView:create()
		if NPC_CAPITAL_PARAM == Tb_cfg_world_city[v].param then
			layer:loadTexture(ResDefineUtil.guodou_001, UI_TEX_TYPE_PLIST)
		elseif capitalParam[Tb_cfg_world_city[v].param] then
			layer:loadTexture(ResDefineUtil.zoushoufu_001, UI_TEX_TYPE_PLIST)
		elseif Tb_cfg_world_city[v].param%100 <=4 then
			layer:loadTexture(ResDefineUtil.xiaochengshi_dian_1, UI_TEX_TYPE_PLIST)
		else
			layer:loadTexture(ResDefineUtil.zhongda_wenzi_bai, UI_TEX_TYPE_PLIST)
		end
		table.insert(m_arrNpcCityData, {wid = v, node = layer})
		layer:setPosition(cc.p(calcViewAtom(math.floor(v/10000),v%10000)))
		state_image:addChild(layer,1)
		drawLine(v)
	end

	for i, v in pairs(stateData.getGuangqiaInState(m_stateId)) do
		layer = ImageView:create()
		layer:loadTexture(ResDefineUtil.guanqia_01, UI_TEX_TYPE_PLIST)
		layer:setPosition(cc.p(calcViewAtom(math.floor(v/10000),v%10000)))
		state_image:addChild(layer,1)
		table.insert(m_arrNpcCityData, {wid = v, node = layer})
	end


	local direction = nil
	for i, v in pairs(stateData.getWharfInState(m_stateId)) do
		layer = ImageView:create()
		layer:loadTexture(ResDefineUtil.matou_bai, UI_TEX_TYPE_PLIST)
		direction = wharfDirection( v )
		if direction == 2 then
			layer:setRotation(180)
		end
		-- layer:setColor(ccc3(255,0,0))
		layer:setAnchorPoint(cc.p(0.5,0))
		layer:setPosition(cc.p(calcViewAtom(math.floor(v/10000),v%10000)))
		state_image:addChild(layer,1)
		table.insert(m_arrNpcCityData, {wid = v, node = layer})
	end

	-- Yellow_lines_new_1.png
end

local function isAlpha(x,y  )
	local alpha = CCTextureDetect:sharedDetect():getAlpha(img, x, state_image:getContentSize().height - y)
	if alpha.a ~= 255 then
		return false
	else
		return true
	end
end

function setMarkPosByWid(cx, cy,iscity  )
	mark_state = tolua.cast(m_root_widget:getChildByName("mark_state"), "ImageView")
	mark_state:setVisible(true)
    local dx, dy = calcViewAtom(cx, cy)
    local point = state_image:convertToWorldSpace(cc.p(dx,dy))
    local nodepoint = mark_state:getParent():convertToNodeSpace(point)
    mark_state:setPosition(nodepoint)
    if iscity then
		local cir = tolua.cast(m_root_widget:getChildByName("image_circel"),"ImageView")
		cir:setPosition(nodepoint)
		cir:setVisible(true)
		cir:setScale(2)
		local action = animation.sequence({CCScaleTo:create(0.3,0.1), cc.CallFunc:create(function ( )
			cir:setVisible(false)
		end)})

		cir:runAction(action)
	end
end

function setMarkPos(x,y )
	local point = state_image:convertToNodeSpace(cc.p(x,y))
	local new_coor_x, new_coor_y = calcViewWid(point.x,point.y )
	if isAlpha(point.x, point.y) and new_coor_x >= 1 and new_coor_x <= 1501 and new_coor_y >= 1 and new_coor_y <= 1501 then
	    local nodepoint = mark_state:getParent():convertToNodeSpace(cc.p(x,y))
	    mark_state:setPosition(nodepoint)
	    mark_state:setVisible(true)
	    return true
	else
		return false
	end
end

local function getHeight(x,y )
	local temp_widget = m_root_widget
	local jumpHeight = 2*mark_state:getContentSize().height
	local node = mark_state:getParent():convertToNodeSpace(cc.p(x,y))
	mark_state:setPosition(node)
	local worldPoint = mark_state:getParent():convertToWorldSpace(cc.p(mark_state:getPositionX(),mark_state:getPositionY()+jumpHeight))
	local nodePoint = state_image:convertToNodeSpace(worldPoint)
	local nextPoint = nil
	local temp_touch = mark_state:getParent():convertToNodeSpace(cc.p(x,y))
	touch_mapPos = {x = temp_touch.x, y = temp_touch.y}
	local alpha = isAlpha(nodePoint.x, nodePoint.y)
	if alpha then
		setMarkPos(worldPoint.x,worldPoint.y )
		miniMapManager.set_pos_txt(calcViewWid(nodePoint.x,nodePoint.y ))
	else
		if nodePoint.y > state_image:getSize().height then
			nextPoint = state_image:getSize().height - 1
		else
			nextPoint = nodePoint.y
		end
		while true do
			nextPoint = nextPoint - 1
			if isAlpha(nodePoint.x, nextPoint) then
				local worldPoint = state_image:convertToWorldSpace(cc.p(nodePoint.x,nextPoint)) 
				setMarkPos(worldPoint.x,worldPoint.y )
				miniMapManager.set_pos_txt(calcViewWid(nodePoint.x,nextPoint ))
				return 
			end
		end
	end
	return true	
end

function init( rootWidget, stateId)
	m_arrNpcCityData = {}
	m_root_widget = rootWidget
	item_panel_copy = tolua.cast(rootWidget:getChildByName("Panel_item"),"Layout" )
	item_panel_copy:setVisible(false)
	m_stateId = stateId
	local Panel_scroll = tolua.cast(rootWidget:getChildByName("Panel_scroll"), "Layout")
	m_widget = Panel_scroll

	npcTable = {}
	for i, v in pairs(stateData.getNpcCityInState(m_stateId)) do
		table.insert(npcTable, v)
	end

	for i, v in pairs(stateData.getGuangqiaInState(m_stateId)) do
		table.insert(npcTable, v)
	end

	Panel_scroll:runAction(CCFadeIn:create(scaleTime))
	-- 州首府名字
	local capital_label = tolua.cast(Panel_scroll:getChildByName("content_label"), "Label")
	capital_label:setText(languagePack["zhoufu"].." "..Tb_cfg_world_city[Tb_cfg_world_anchor[m_stateId].anchor_wid].name)

	Panel_root = tolua.cast(Panel_scroll:getChildByName("Panel_root"), "Layout")
	Panel_root:removeAllChildrenWithCleanup(true)

	local ImageView_down = tolua.cast(m_widget:getChildByName("ImageView_down"),"ImageView" )
	ImageView_down:setVisible(false)
	local ImageView_up = tolua.cast(m_widget:getChildByName("ImageView_up"),"ImageView" )
	ImageView_up:setVisible(false)

	breathAnimUtil.start_anim(ImageView_down, true, 76, 255, 1, 0)
	breathAnimUtil.start_anim(ImageView_up, true, 76, 255, 1, 0)

	local m_tableView = CCTableView:create(true, CCSizeMake(Panel_root:getSize().width,Panel_root:getSize().height))
    m_tableView:setDirection(kCCScrollViewDirectionVertical)
	m_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    m_tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    m_tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
	Panel_root:addChild(m_tableView)
	m_tableView:reloadData()

	panel_state = tolua.cast(rootWidget:getChildByName("Panel_state"),"Layout" )
	panel_state:removeAllChildrenWithCleanup(true)
	state_image = ImageView:create()
	state_image:loadTexture("test/res_single/"..m_stateId.."_daditu.png", UI_TEX_TYPE_LOCAL)
	state_image:setAnchorPoint(cc.p(0,0))
	state_image:setPosition(cc.p(Tb_cfg_client_mini_map_region[m_stateId].pos[1], panel_state:getSize().height - Tb_cfg_client_mini_map_region[m_stateId].pos[2] - state_image:getSize().height))
	panel_state:addChild(state_image)

	state_image:runAction(CCFadeIn:create(scaleTime))
	-- state_image:setScale(0.5)
	-- state_image:runAction(CCScaleTo:create(0.2,1))


	local sprite = cc.Sprite:create("test/res_single/"..m_stateId.."_daditu.png")
	sprite:setAnchorPoint(cc.p(0,0))
	local textureRender = CCRenderTexture:create(sprite:getContentSize().width,sprite:getContentSize().height,kCCTexture2DPixelFormat_RGBA8888)
	textureRender:begin()
	sprite:visit()
	textureRender:endToLua()
	img = textureRender:newCCImage()

	local selectBoxChange = function (flag )
		local back_Button = tolua.cast(m_root_widget:getChildByName("Button_back"), "Button")
		back_Button:setVisible(not flag)
		back_Button:setTouchEnabled(not flag)
		m_layer_pos:setVisible(flag)
		m_widget:setVisible(not flag)
		m_tableView:setTouchEnabled(not flag)
	end
	
    local Panel_small_item = tolua.cast(rootWidget:getChildByName("Panel_small_item"),"Layout" )
    local CheckBox_npc = tolua.cast(Panel_small_item:getChildByName("CheckBox_npc"),"CheckBox" )
    local Panel_touch = tolua.cast(rootWidget:getChildByName("Panel_touch"),"Layout" )
	layer_touch_ = CCLayer:create()
    layer_touch_:setTouchEnabled(true)
    local point_temp =nil 
    local alpha = nil
    layer_touch_:registerScriptTouchHandler(function (eventType, x,y  )
    	if not state_image then return end
    	point_temp = state_image:convertToNodeSpace(cc.p(x,y))
    	if eventType == "began" then
    		if Panel_root:hitTest(cc.p(x,y)) then
    			return false
    		end

    		if Panel_touch:hitTest(cc.p(x,y)) then
    			CheckBox_npc:setSelectedState(not m_layer_pos:isVisible())
    			selectBoxChange(not m_layer_pos:isVisible())
    			return false
    		end

    		if not panel_state:hitTest(cc.p(x,y)) then
    			return false
    		end

    		if not isAlpha(point_temp.x, point_temp.y) then
    			if m_layer_pos and m_layer_pos:isVisible() then
    				CheckBox_npc:setSelectedState(false)
    				selectBoxChange(false)
    				return false
    			end
    			-- miniMapManager.changeStateMapAndWorldMap(2)
    			-- remove(true)
    			return false
    		end
    		getHeight(x,y )
    		return true
		elseif eventType == "ended" then
			
			return false
		elseif eventType == "moved" then
			local temp_touch = mark_state:getParent():convertToNodeSpace(cc.p(x,y))
			local worldPoint = ccp(mark_state:getPositionX()+ temp_touch.x-touch_mapPos.x,mark_state:getPositionY()+ temp_touch.y-touch_mapPos.y)
			local nodePoint = mark_state:getParent():convertToWorldSpace(worldPoint)
			local point = state_image:convertToNodeSpace(nodePoint)
			if setMarkPos(nodePoint.x,nodePoint.y) then
			-- if setMarkPos(x,y) then
				miniMapManager.set_pos_txt(calcViewWid(point.x,point.y ))
			end
			touch_mapPos = {x = temp_touch.x, y = temp_touch.y}
			return true
		end
    end, false, -1, false)
	
	mark_state = tolua.cast(m_root_widget:getChildByName("mark_state"), "ImageView")
	local coorX, coorY  = map.touchInMap(config.getWinSize().width/2, config.getWinSize().height/2)

    rootWidget:addChild(layer_touch_,99)

    CheckBox_npc:setSelectedState(false)

	state_image:setAnchorPoint(cc.p(0.5,0.5))
	state_image:setScale(0.5)
	state_image:setPosition(cc.p(state_image:getPositionX()+state_image:getSize().width/2, state_image:getPositionY()+state_image:getSize().height/2))
	state_image:runAction(animation.sequence({CCScaleTo:create(scaleTime,1), cc.CallFunc:create(function ( )
		state_image:setAnchorPoint(cc.p(0,0))
		state_image:setPosition(cc.p(Tb_cfg_client_mini_map_region[m_stateId].pos[1], panel_state:getSize().height - Tb_cfg_client_mini_map_region[m_stateId].pos[2] - state_image:getSize().height))
		if stateData.stateInMap(coorX, coorY) == m_stateId then
			setMarkPosByWid(coorX, coorY)
			miniMapManager.set_pos_txt(coorX, coorY)
		else
			-- mark_state:setVisible(false)
	    	setMarkPosByWid(math.floor(Tb_cfg_world_anchor[m_stateId].anchor_wid/10000), Tb_cfg_world_anchor[m_stateId].anchor_wid%10000)
			miniMapManager.set_pos_txt(math.floor(Tb_cfg_world_anchor[m_stateId].anchor_wid/10000), Tb_cfg_world_anchor[m_stateId].anchor_wid%10000)
		end
    	drawNode( )
		MiniMapData.requestDataInState(stateId)
	end)}))
end

function remove( effect )
	local callback = function ( )
		if img then
			img:release()
		end

		if panel_state then
	    	panel_state:removeAllChildrenWithCleanup(true)
	    end

	    if Panel_root then
	    	Panel_root:removeAllChildrenWithCleanup(true)
	    end

	    if layer_touch_ then
	    	layer_touch_:removeFromParentAndCleanup(true)
	    end
	    m_layer_pos = nil
	    m_arrNpcCityData = nil
	    touch_mapPos = { x = nil, y = nil}
	    panel_state = nil
		Panel_root = nil
		layer_touch_ = nil
		state_image = nil
		m_stateId = nil
		m_widget = nil
		item_panel_copy = nil
		npcTable = nil
		m_idx = nil
		img = nil
	end

	if effect then
		state_image:setAnchorPoint(cc.p(0.5,0.5))
		state_image:removeAllChildrenWithCleanup(true)
		m_layer_pos = nil
		state_image:setPosition(cc.p(state_image:getPositionX()+state_image:getSize().width/2, state_image:getPositionY()+state_image:getSize().height/2))
		state_image:runAction(animation.sequence({CCScaleTo:create(scaleTime,0.5), cc.CallFunc:create(function ( )
			state_image:setAnchorPoint(cc.p(0,0))
			state_image:setPosition(cc.p(Tb_cfg_client_mini_map_region[m_stateId].pos[1], panel_state:getSize().height - Tb_cfg_client_mini_map_region[m_stateId].pos[2] - state_image:getSize().height))
	    	callback()
		end)}))
	else
		callback()
	end
	
end

function updateNpcCityColor( )
	if m_arrNpcCityData then
		local npcData = MiniMapData.getWorldNpcCityData()
		for i, v in pairs(m_arrNpcCityData) do
			if npcData[v.wid] then
				tolua.cast(v.node:getVirtualRenderer(),"CCSprite"):setColor(npcData[v.wid].color)
			end
		end
	end
end

function drawUnionMemberNode()
	if not state_image then
		return
	end
	local unionMember = MiniMapData.getUnionMemberData(m_stateId)
	local layer = nil
	for i, v in pairs(unionMember) do
		if stateData.stateInMap(math.floor(v.wid/10000), v.wid%10000) == m_stateId then 
			layer = ImageView:create()
			layer:loadTexture(ResDefineUtil.xiaochengshi_dian_1, UI_TEX_TYPE_PLIST)
			state_image:addChild(layer,2)
			layer:setPosition(cc.p(calcViewAtom(math.floor(v.wid/10000),v.wid%10000)))
			tolua.cast(layer:getVirtualRenderer(),"CCSprite"):setColor(v.color)
		end
	end
end