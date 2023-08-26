--建筑树事件
module("buildTreeManager", package.seeall)
local m_mainLayer = nil
local m_scroll_view = nil
local m_rootLayer = nil
local m_height = nil
local m_arrWidget = nil --item
local m_arrLine = nil --连线
local m_arrCell = nil
-- local m_arrWidgetToWidget =  nil --每个item和item之间的开启关系
local m_viewLayer = nil
local m_x, m_y = nil
local touchbeginx, touchbeginy = nil, nil
local m_isMove = nil
local m_arrConnectBuilding = nil --主building和它有关的building
local initOffset = nil
local m_offset = nil

local function do_remove_self()
	if m_mainLayer then
		m_mainLayer:removeFromParentAndCleanup(true)
		m_mainLayer = nil
		m_mainLayer = nil
		m_scroll_view = nil
		m_rootLayer = nil
		m_height = nil
		m_arrWidget = nil
		m_viewLayer = nil
		m_arrLine = nil
		m_arrCell = nil
		m_x, m_y = nil, nil
		m_isMove = nil
		initOffset = nil
		m_offset = nil
		touchbeginx, touchbeginy = nil, nil
		m_arrConnectBuilding = nil
		uiManager.remove_self_panel(uiIndexDefine.BUILD_TREE_MANAGER)
		UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.update, buildTreeManager.buildingChange)
		UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.add, buildTreeManager.buildingChange)
		UIUpdateManager.remove_prop_update(dbTableDesList.build.name, dataChangeType.remove, buildTreeManager.buildingDelete)
	end
end

function remove_self()
	-- uiManager.hideScaleEffect(m_mainLayer,999,do_remove_self,nil,0.85)
	uiManager.hideConfigEffect(uiIndexDefine.BUILD_TREE_MANAGER,m_mainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
	if not m_mainLayer then
		return false
	end

	local temp_widget = m_mainLayer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local layerDefined = {
		[1] = {10,12},
		[2] = {13,40},
		[3] = {20,21,23,52,54,37},
		[4] = {22,24,51,53},
		[5] = {31,42,61},
		[6] = {25,32,33,34,66,82},
		[7] = {35,63,36,81},
		[8] = {30,64,65,83,84},
		[9] = {43,44},
}

local build_location = {}
	--[[表中各个元素含义：	
							1 建筑显示的图标类型 	-- 1 校场区域 dune_icon.png;	2 点将台区域 touxiange_icon.png;	3 封禅台 shue_icon.png
													-- 4 居民区域 mingju_icon.png;	5 城防区域/要塞	chengqiang_icon.png;	6 社稷坛 shejitan_icon.png
							2 所处坐标X
								3 所处坐标Y
		--]]
build_location[10] = {0,385,49,1}
build_location[12] = {0,385,49,1}
build_location[13] = {0,506,49,2}
build_location[40] = {0,293,49,2}
build_location[20] = {0,506,49,3}
build_location[21] = {0,631,49,3}
build_location[23] = {0,756,49,3}
build_location[52] = {0,168,49,3}
build_location[54] = {0,43,49,3}
build_location[37] = {0,293,49,3}
build_location[22] = {0,756,49,4}
build_location[24] = {0,631,49,4}
build_location[51] = {0,168,49,4}
build_location[53] = {0,43,49,4}
build_location[31] = {0,168,49,5}
build_location[42] = {0,293,49,5}
build_location[61] = {0,631,49,5}
build_location[25] = {0,506,49,6}
build_location[32] = {0,43,49,6}
build_location[33] = {0,168,49,6}
build_location[34] = {0,293,49,6}
build_location[66] = {0,631,49,6}
build_location[82] = {7,756,49,6}
build_location[35] = {0,168,49,7}
build_location[63] = {0,631,49,7}
build_location[36] = {0,293,49,7}
build_location[81] = {6,506,49,7}
build_location[30] = {0,168,49,8}
build_location[64] = {0,506,49,8}
build_location[65] = {0,756,49,8}
build_location[83] = {8,631,49,8}
build_location[84] = {9,293,49,8}
build_location[43] = {0,631,49,9}
build_location[44] = {0,168,49,9}

-- 非强制引导
local function _guide_build_offset( )
	if userData.getBuildingQueneNum() == 2 and CCUserDefault:sharedUserDefault():getStringForKey("ID2009") == "" then
		-- 民居
		-- local buildLoca = m_arrCell[build_location[13][4]-1]
		-- local point = buildLoca:getParent():convertToWorldSpace(cc.p(buildLoca:getPositionX(), buildLoca:getPositionY()))
		-- point = m_scroll_view:convertToNodeSpace(point)

		-- -- 仓库
		-- buildLoca = m_arrCell[build_location[20][4]-1]
		-- local point_mid =buildLoca:getParent():convertToWorldSpace(cc.p(buildLoca:getPositionX(), buildLoca:getPositionY()))
		-- point_mid = m_scroll_view:convertToNodeSpace(point_mid)

		-- initOffset = -point_mid.y+point.y
		initOffset = 165
		-- comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2009)
		-- CCUserDefault:sharedUserDefault():setStringForKey("ID2009", "1")
	end
end

--显示非强制引导
local function _guide_build( )
	if userData.getBuildingQueneNum() == 2 and CCUserDefault:sharedUserDefault():getStringForKey("ID2009") == "" then
		comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2009)
		CCUserDefault:sharedUserDefault():setStringForKey("ID2009", "1")
	end
end

function create(callback )
	require("game/buildScene/buildTreeItem")
	if m_mainLayer then return end
	if not mainBuildScene.getThisCityid() then return end
	m_offset = 0
	initOffset = 0
	m_mainLayer = TouchGroup:create()
	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/latest_building_tree.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	m_mainLayer:addWidget(temp_widget)

	local confirm_close_btn = tolua.cast(temp_widget:getChildByName("btn_close_0"), "Button")
	confirm_close_btn:setTouchEnabled(true)
	confirm_close_btn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)

	local panel = tolua.cast(temp_widget:getChildByName("Panel_603447"), "Layout")

	m_rootLayer = TouchGroup:create()
	m_rootLayer:setContentSize(CCSize(panel:getSize().width, panel:getSize().height))
	m_scroll_view = CCScrollView:create()

	local function scrollViewDidScroll( )
        if m_scroll_view:getContentOffset().y < 0 then
            tolua.cast(temp_widget:getChildByName("ImageView_956113"),"ImageView" ):setVisible(true)
        else
            tolua.cast(temp_widget:getChildByName("ImageView_956113"),"ImageView" ):setVisible(false)
        end

        if m_scroll_view:getContentSize().height + m_scroll_view:getContentOffset().y > 1+m_scroll_view:getViewSize().height then
            tolua.cast(temp_widget:getChildByName("ImageView_956114"),"ImageView" ):setVisible(true)
        else
            tolua.cast(temp_widget:getChildByName("ImageView_956114"),"ImageView" ):setVisible(false)
        end
    end
    local ImageView_up = tolua.cast(temp_widget:getChildByName("ImageView_956113"),"ImageView" )
    ImageView_up:setVisible(false)
    local ImageView_down = tolua.cast(temp_widget:getChildByName("ImageView_956114"),"ImageView" )
    ImageView_down:setVisible(false)

    breathAnimUtil.start_anim(ImageView_down, true, 76, 255, 1, 0)
	breathAnimUtil.start_anim(ImageView_up, true, 76, 255, 1, 0)
    
	if nil ~= m_scroll_view then
        m_scroll_view:registerScriptHandler(scrollViewDidScroll,CCScrollView.kScrollViewScroll)
        m_scroll_view:setViewSize(CCSizeMake(panel:getSize().width,panel:getSize().height))
        m_scroll_view:setContainer(m_rootLayer)
        m_scroll_view:updateInset()
        m_scroll_view:setDirection(kCCScrollViewDirectionVertical)
        m_scroll_view:setClippingToBounds(true)
        m_scroll_view:setBounceable(false)
        m_scroll_view:setContentOffset(cc.p(0,m_scroll_view:getViewSize().height))
    end
    if newGuideManager.get_guide_state() then
    	m_scroll_view:setTouchEnabled(false)
    end
    panel:addChild(m_scroll_view)

    

    m_height = 0
	m_arrWidget = {}
	m_arrLine = {}
	m_arrCell = {}
	m_arrConnectBuilding = {}
	m_viewLayer = TouchGroup:create()
	m_viewLayer:setContentSize(CCSize(m_rootLayer:getContentSize().width, m_rootLayer:getContentSize().height))
	m_rootLayer:addChild(m_viewLayer)
	local data = {}
	for i=1, 4 do
		table.insert(data, layerDefined[i])
	end

	local _temp_layer = CCLayer:create()
	_temp_layer:setTouchEnabled(true)
	_temp_layer:registerScriptTouchHandler(function (eventType, x,y)
		if eventType == "began" then
			m_isMove = false
			touchbeginx, touchbeginy = x,y
		elseif eventType == "moved" then
			if math.abs(x - touchbeginx) > 5 or  math.abs(y - touchbeginy) > 5 then
				m_isMove = true
			end
		end
		m_x = x
		m_y = y
		return true
	end,false,0,false)
	m_mainLayer:addChild(_temp_layer)

	_guide_build_offset()
    initUI(data,true)

	
    --这一行要出现在scrollview初始化后面，要不在引导时会有问题
    uiManager.add_panel_to_layer(m_mainLayer, uiIndexDefine.BUILD_TREE_MANAGER,999)
	--这个函数一定要放到最后，否则分段加载会出现定位错误的问题
    uiManager.showConfigEffect(uiIndexDefine.BUILD_TREE_MANAGER,m_mainLayer, function ( )
		-- -- 
		m_mainLayer:runAction(animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function (  )
		  	data = {}
	    	for i=5, 9 do
				table.insert(data, layerDefined[i])
			end
			initUI(data,false)
			_guide_build()
			for i, v in pairs(m_arrWidget) do
				v[1]:setTouchEnabled(true)
				v[1]:addTouchEventListener(function (sender, eventType )
					if eventType == TOUCH_EVENT_ENDED then
						if m_x and m_y and panel:hitTest(cc.p(m_x, m_y)) and not m_isMove then
							newGuideInfo.enter_next_guide()
							buildMsgManager.showBuildMsg(i)
						end
						BuildTreeItem.setTouchColor( sender,false)
					elseif eventType == TOUCH_EVENT_BEGAN then
						BuildTreeItem.setTouchColor( sender,true)
					elseif eventType == TOUCH_EVENT_CANCELED then
						BuildTreeItem.setTouchColor( sender,false)
					end
				end)
			end

			if callback then
				callback()
			end
		end)}) )
    end)
	UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.update, buildTreeManager.buildingChange)
	UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.add, buildTreeManager.buildingChange)
	UIUpdateManager.add_prop_update(dbTableDesList.build.name, dataChangeType.remove, buildTreeManager.buildingDelete)
end

function get_com_guide_widget(temp_guide_id  )
	if not m_mainLayer then
        return nil
    end
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2009 then 
        return  m_mainLayer:getWidgetByTag(999)
    end
end

function setBuildingBlink(arr_build_id )
	local buildLoca = nil
	local dt = 0
	local hasSetOffset = nil
	local chengzhufu = nil
	for i, build_id in pairs(arr_build_id) do
		if build_id == 10 or build_id == 12 then
			chengzhufu = true
		end

		if build_location[build_id] then
			if build_location[build_id][4] ~= 1 then
				buildLoca = m_arrCell[build_location[build_id][4]-1]
				local point = buildLoca:getParent():convertToWorldSpace(cc.p(buildLoca:getPositionX(), buildLoca:getPositionY()))
				point = m_scroll_view:convertToNodeSpace(point)
				if point.y-buildLoca:getSize().height < 0 then
					dt = (-point.y+buildLoca:getSize().height)/800
					if not hasSetOffset then
						hasSetOffset = true
						m_scroll_view:setContentOffsetInDuration(cc.p(0,m_scroll_view:getContentOffset().y-point.y+buildLoca:getSize().height),dt)
					end
				end
			end

			if chengzhufu then
				buildLoca = m_arrCell[1]
			end
			buildLoca:runAction(animation.sequence({cc.DelayTime:create(dt), cc.CallFunc:create(function (  )
				BuildTreeItem.setBlink(m_arrWidget[build_id][1])
			end)}))
		end
	end
end

function buildingDelete(package )
	local cityid = mainBuildScene.getThisCityid()
	if not cityid then return end
	local build_id = nil
	if package then
		build_id = package%100
		initLine( build_id)
		-- BuildTreeItem.initItem(m_arrWidget[build_id][1],build_id)
		if m_arrConnectBuilding[build_id] then
			for i, v in pairs(m_arrConnectBuilding[build_id]) do
				BuildTreeItem.initItem(m_arrWidget[v][1],v)
			end
		end
		BuildTreeItem.initItem(m_arrWidget[build_id][1],build_id)

		if build_id == 10 or build_id == 12 then
			for i, v in pairs(m_arrWidget) do
				BuildTreeItem.initItem(v[1],i)
				initLine( i)
			end
			initCell(politics.getBuildLevel(cityid, build_id) )
		end
	end
end

function buildingChange(package )
	local cityid = mainBuildScene.getThisCityid()
	if not cityid then return end
	local build_id = nil
	if package then
		build_id = package.build_id_u%100
		initLine( build_id)
		-- BuildTreeItem.initItem(m_arrWidget[build_id][1],build_id)
		if m_arrConnectBuilding[build_id] then
			for i, v in pairs(m_arrConnectBuilding[build_id]) do
				BuildTreeItem.initItem(m_arrWidget[v][1],v)
			end
		end
		BuildTreeItem.initItem(m_arrWidget[build_id][1],build_id)

		if build_id == 10 or build_id == 12 then
			for i, v in pairs(m_arrWidget) do
				BuildTreeItem.initItem(v[1],i)
				initLine( i)
			end
			initCell(politics.getBuildLevel(cityid, build_id) )
		end
	end
end

--改变线段的颜色之类的
function initLine(build_id )
	local current_city_id = mainBuildScene.getThisCityid()
	if not current_city_id then return end
	local current_lv = politics.getBuildLevel(mainBuildScene.getThisCityid(), build_id)
	local this_build_id_level = nil
	if not m_arrLine[build_id] then return end
	for i, v in ipairs(m_arrLine[build_id]) do
		for m, n in ipairs(Tb_cfg_build[v.id].pre_condition) do
			if n[1] == build_id then
				--如果未到条件
				this_build_id_level = politics.getBuildLevel(mainBuildScene.getThisCityid(), v.id)
				if n[2] > current_lv and this_build_id_level == 0 then
					v.widget:loadTexture("huiseweichenggong_lianxian.png",UI_TEX_TYPE_PLIST)
					v.level_widget:loadTexture("dengjixiaotubiaotixing.png",UI_TEX_TYPE_PLIST)
					v.level_label:setColor(ccc3(158,12,4))
				elseif Tb_cfg_build[build_id].area == 2 then
					v.widget:loadTexture("lansechenggong_lianxian.png",UI_TEX_TYPE_PLIST)
					v.level_widget:loadTexture("dengjixiaotubiaolanse.png",UI_TEX_TYPE_PLIST)
					v.level_label:setColor(ccc3(255,255,255))
				elseif Tb_cfg_build[build_id].area == 3 then
					v.widget:loadTexture("lvsechenggong_lianxian.png",UI_TEX_TYPE_PLIST)
					v.level_widget:loadTexture("dengjixiaotubiaolvse.png",UI_TEX_TYPE_PLIST)
					v.level_label:setColor(ccc3(255,255,255))
				end
			end
		end
	end
end

function drawLine( build_id)
	local line_id = {}
	local level_id = {}
	for k, p in ipairs(Tb_cfg_build[build_id].pre_condition) do
		if p[1] ~= 10 then
			if not m_arrConnectBuilding[p[1]] then
				m_arrConnectBuilding[p[1]] = {}
			end
			table.insert(m_arrConnectBuilding[p[1]],build_id)

			table.insert(line_id, p[1])
			table.insert(level_id, p[2])
		end
	end


	if #line_id == 0 then
		return
	end

	local rotation = nil
	local line_widget = nil
	local fromx, fromy = nil,nil
	local level_widget = nil
	local level_label = nil
	local worldPos = nil
	local nodePos = nil
	for i,v in ipairs(line_id) do
		fromx = m_arrWidget[build_id][2].x
		fromy = m_arrWidget[build_id][1]:convertToWorldSpace(cc.p(m_arrWidget[v][1]:getSize().width*0.5, 0)).y + m_arrWidget[build_id][1]:getSize().height*config.getgScale() --m_arrWidget[build_id][2].y + m_arrWidget[build_id][1]:getSize().height*config.getgScale()
		rotation = animation.pointRotate(cc.p(fromx,fromy), m_arrWidget[v][2])
		line_widget = ImageView:create()
		line_widget:setScale9Enabled(true)
		line_widget:setCapInsets(CCRect(1,1,4,38))
		line_widget:setAnchorPoint(cc.p(0.5,0))
		line_widget:loadTexture("lansechenggong_lianxian.png", UI_TEX_TYPE_PLIST)
		line_widget:setSize(CCSize(line_widget:getSize().width, ccpDistance(cc.p(fromx,fromy), m_arrWidget[v][1]:convertToWorldSpace(cc.p(m_arrWidget[v][1]:getSize().width*0.5,0)))/config.getgScale() ))
		m_viewLayer:addWidget(line_widget)
		line_widget:setZOrder(1)
		if not m_arrLine[v] then
			m_arrLine[v] = {}
		end
		worldPos = m_arrWidget[build_id][1]:convertToWorldSpace(cc.p(m_arrWidget[build_id][1]:getSize().width/2, m_arrWidget[build_id][1]:getSize().height))
		nodePos = m_viewLayer:convertToNodeSpace(worldPos)
		line_widget:setPosition(nodePos)

		line_widget:setRotation(90-rotation)

		level_widget = ImageView:create()
		level_widget:loadTexture("dengjixiaotubiaolanse.png", UI_TEX_TYPE_PLIST)
		line_widget:addChild(level_widget)
		level_widget:setPosition(cc.p(0, 20/math.cos((rotation-90)*math.pi/180)))

		level_label = Label:create()
		level_label:setText(level_id[i])
		level_label:setFontSize(18)
		level_widget:addChild(level_label)

		level_label:setRotation(rotation-90)
		table.insert(m_arrLine[v], {widget = line_widget, id =build_id, level_label = level_label, level_widget = level_widget} )
		initLine(v )
	end
end

--层是否开放
function initCell(index  )
	if index == 1 then return end
	local build_id = nil
	local cityid = mainBuildScene.getThisCityid()
	if not cityid then return end
	if userData.getMainPos() == cityid then
		--城主府
		build_id = 10
	else
		--都督府
		build_id = 12
	end

	if m_arrCell[index] then
		if politics.getBuildLevel(cityid, build_id) >= index then
			tolua.cast(m_arrCell[index]:getChildByName("ImageView_600988_0"),"ImageView"):loadTexture("lanse_xiaoshubiao.png",UI_TEX_TYPE_PLIST)
			tolua.cast(m_arrCell[index]:getChildByName("Label_600989_0"),"Label"):setColor(ccc3(129,197,209))
		else
			tolua.cast(m_arrCell[index]:getChildByName("ImageView_600988_0"),"ImageView"):loadTexture("huisexiaoshubiao.png",UI_TEX_TYPE_PLIST)
			tolua.cast(m_arrCell[index]:getChildByName("Label_600989_0"),"Label"):setColor(ccc3(105,105,105))
		end
	end
end

function initUI( data, isFirst)
	local temp_widget = nil
	local cell_widget = nil
	local name_widget = nil
	local index = nil
	local pos = nil
	local worldPos = nil
	local nodePos = nil
	local arr_name = {}
	local current_city_id= mainBuildScene.getThisCityid()
	if not current_city_id then return end
	local groud_touch = nil
	for i,v in ipairs(data) do
		if i == 1 and isFirst then
			temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_cell_big.json")
		else
			temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_cell_small.json")
			table.insert(m_arrCell, temp_widget)
			initCell(#m_arrCell)
			if isFirst then
				tolua.cast(temp_widget:getChildByName("Label_600989_0"),"Label"):setText(i-1)
			else
				tolua.cast(temp_widget:getChildByName("Label_600989_0"),"Label"):setText(i+4-1)
			end
		end
		temp_widget:setAnchorPoint(cc.p(0,1))
		m_viewLayer:addWidget(temp_widget)
		temp_widget:setPosition(cc.p(0, m_viewLayer:getContentSize().height- m_height))
		m_height = m_height + temp_widget:getSize().height

		for m,n in ipairs(v) do
			index = n
			if build_location[index][1] == 0 or build_location[index][1] == math.floor(resourceData.resourceLevel(math.floor(current_city_id/10000), current_city_id%10000)/10) then

				if (index == 81 or index == 82 or index==83 or index ==84)
					and userData.getMainPos() == current_city_id --[[and userData.getMoveCityTime() == 0]] then
				else
					if isFirst and i==1 and mainBuildScene.getThisCityid() == userData.getMainPos() and m==2 then
						break
					elseif isFirst and i == 1 and mainBuildScene.getThisCityid() ~= userData.getMainPos() and m==1 then
						index = n+2
					end

					if Tb_cfg_build[index].area == 1 then
						cell_widget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_item_big.json")
					elseif Tb_cfg_build[index].area == 2 then
						cell_widget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_item_small_2.json")
					elseif Tb_cfg_build[index].area == 3 then
						cell_widget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_item_small.json")
					end
					
					groud_touch = TouchGroup:create()
					groud_touch:registerScriptTouchHandler(function (eventType, x,y)

					end,false,0,false)
					groud_touch:addWidget(cell_widget)
					m_viewLayer:addChild(groud_touch,3)
					-- if index ~= 10 and index ~= 12 then
						BuildTreeItem.initItem(cell_widget,index)
					-- end
					worldPos = temp_widget:convertToWorldSpace(cc.p(build_location[index][2], build_location[index][3]))
					nodePos = m_viewLayer:convertToNodeSpace(worldPos)
					cell_widget:setPosition(nodePos)
					m_arrWidget[index] = {cell_widget, cell_widget:convertToWorldSpace(cc.p(cell_widget:getSize().width/2, 0))}
					table.insert(arr_name, index)
					drawLine(index)
					if i== 1 and isFirst then
						break
					end
				end
			end
		end
	end

	local pre_condition_lv = nil
	local _build_id = nil
	local flag = nil
	local max_level = nil
	local cur_level = nil
	local isEnoughRes = true
	for i, v in pairs(arr_name) do
		cur_level = politics.getBuildLevel(mainBuildScene.getThisCityid(), v)
		flag = nil
		isEnoughRes = true
		name_widget = GUIReader:shareReader():widgetFromJsonFile("test/build_tree_name.json")
		name_widget:setAnchorPoint(cc.p(0.5,1))
		m_viewLayer:addWidget(name_widget)
		-- name_widget:setZOrder(2)
		m_viewLayer:reorderChild(name_widget,2)
		pos = m_viewLayer:convertToNodeSpace(m_arrWidget[v][2])
		name_widget:setPosition(pos)
		tolua.cast(name_widget:getChildByName("Label_600960_0_0"),"Label"):setText(Tb_cfg_build[v].name)

		for m, n in ipairs(Tb_cfg_build[v].pre_condition) do
			_build_id = n[1]
			if userData.getMainPos() ~= mainBuildScene.getThisCityid() and _build_id == 10 then
				_build_id = 12
			end
			pre_condition_lv = politics.getBuildLevel(mainBuildScene.getThisCityid(), _build_id)
			if n[2] > pre_condition_lv and cur_level == 0 then
				GraySprite.create(name_widget)
				flag = true
				break
			end
		end
		max_level = Tb_cfg_build[v].max_level
		if not flag and cur_level ~= max_level then
	        for k,q in pairs(Tb_cfg_build_cost[v*100+cur_level+1].res_cost) do
	            if politics.getResNumsByType(q[1]) < q[2] then
	                isEnoughRes = false
	                tolua.cast(name_widget:getChildByName("ImageView_606736_0"),"ImageView"):loadTexture(ResDefineUtil.ui_build_tree_cell_red, UI_TEX_TYPE_PLIST)
	                break
	            end
	        end

	        if isEnoughRes then
	        	tolua.cast(name_widget:getChildByName("ImageView_606736_0"),"ImageView"):loadTexture(ResDefineUtil.ui_build_tree_cell_normal, UI_TEX_TYPE_PLIST)
	        end
		end
	end

	m_rootLayer:setContentSize(CCSize(m_rootLayer:getContentSize().width, m_height))
	m_viewLayer:setPositionY(m_height-m_viewLayer:getContentSize().height)
	m_scroll_view:setContentOffset(cc.p(0,-m_offset+initOffset-m_rootLayer:getContentSize().height+m_scroll_view:getViewSize().height))
	m_offset = initOffset-m_rootLayer:getContentSize().height+m_scroll_view:getViewSize().height
	if m_offset <= 0 then
		m_offset = 0
	end
end

function get_guide_widget(temp_guide_id)
    if not m_mainLayer then
        return nil
    end

    return m_mainLayer:getWidgetByTag(999)
end