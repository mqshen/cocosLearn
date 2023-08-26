local basic_ui_layer = nil			--整个UI界面的管理LAYER
local xy_layer = nil
local panel_in_bottom_list = nil 	--显示在底层静态层的面板索引列表
local bottom_fix_layer = nil		--用来加载底层的窗口，也就是俗称的主界面
local suspend_layer_list = nil		--悬浮窗口的列表，该部分layer自带背景色

local last_began_x, last_began_y = 0,0
local last_click_point = ccp(0,0)
local last_is_move = false

local m_animation = nil
local uiUtil = require("game/utils/ui_util")

local SUSPEND_LAYER_OPACITY = 220
local SUSPEND_OPACITY_2 = 150

local function onTouchBegan(x,y)
	if simpleGuideTool and simpleGuideTool.is_show_state() then
		return false
	end

	if newGuideManager and newGuideManager.get_guide_state() then
		return false
	end

	if armyListDetail then
		armyListDetail.deal_with_touch_click(x, y)
	end

	if armyMark then
		armyMark.removeLockScreenWhenTouch()
	end

	if ObjectCountDown then
		ObjectCountDown.setReleaseLockArmy()
	end

	if SmallMiniMap then 
        SmallMiniMap.checkTouchState(x,y)
    end

	local suspend_nums = #suspend_layer_list
	for i = suspend_nums, 1, -1 do
		local show_index = suspend_layer_list[i][2]
		if show_index ~= 0 then
			local main_class = uiPanelInfo.get_main_class_by_index(show_index)
			if main_class then
				return main_class.dealwithTouchEvent(x, y)
			else
				return false
			end
		end
	end

	-- local fix_nums = #panel_in_bottom_list
	-- if fix_nums ~= 0 then
	-- 	local fix_index = panel_in_bottom_list[fix_nums]
	-- 	local fix_class = uiPanelInfo.get_main_class_by_index(fix_index)
	-- 	if fix_class then
	-- 		return fix_class.dealwithTouchEvent(x, y)
	-- 		--return false
	-- 	else
	-- 		return false
	-- 	end
	-- else
	-- 	return true
	-- end

	for k,v in pairs(panel_in_bottom_list) do
		local fix_index = v
		local fix_class = uiPanelInfo.get_main_class_by_index(fix_index)
		if fix_class and fix_class.dealwithTouchEvent(x,y) then 
			return true
		end
	end
	return false
end

local function hasUI( )
	if not suspend_layer_list then return false end
	local suspend_nums = #suspend_layer_list
	for i = suspend_nums, 1, -1 do
		local show_index = suspend_layer_list[i][2]
		if show_index ~= 0 then
			return true
		end
	end
	return false
end

local function is_most_above_layer(layer_index)
	local suspend_nums = #suspend_layer_list
	for i = suspend_nums, 1, -1 do
		local show_index = suspend_layer_list[i][2]
		if show_index ~= 0 then
			if show_index == layer_index then
				return true
			else
				return false
			end
		end
	end

	return false
end

--针对一些需要检测自身是不是在最上层来做某些操作的界面进行刷新处理（大部分是是否可以滚动的操作）
local function update_layer_show_level()
	local suspend_nums = #suspend_layer_list
	local most_above_state = true
	for i = suspend_nums, 1, -1 do
		local show_index = suspend_layer_list[i][2]
		if show_index ~= 0 then
			local main_class = uiPanelInfo.get_main_class_by_index(show_index)
			if main_class and main_class.update_show_level then
				main_class.update_show_level(most_above_state)
			end
			most_above_state = false
		end
	end
end

local function set_layer_opacity(temp_layer)
	local suspend_nums = #suspend_layer_list
	for i=1,suspend_nums do
		if suspend_layer_list[i][1] == temp_layer then
			if i == 1 then
				temp_layer:setOpacity(SUSPEND_LAYER_OPACITY)
			else
				temp_layer:setOpacity(SUSPEND_OPACITY_2)
			end
		end
	end
end

local function onLayerTouch(eventType, x, y)
	if eventType == "began" then
    	return onTouchBegan(x, y)
	else
		return false
	end
end

local function runAnimation(x,y )
	if not xy_layer then return end
	-- if m_animation then 
	-- 	m_animation:removeFromParentAndCleanup(true)
	-- end
	local temp_animation = CCArmature:create("chumo_1")
	if temp_animation then
		temp_animation:getAnimation():playWithIndex(0)
		temp_animation:setPosition(cc.p(x, y))
		xy_layer:addChild(temp_animation)
		temp_animation:getAnimation():setMovementEventCallFunc(function (armature, eventType, name )
			if eventType == 1 then
				armature:removeFromParentAndCleanup(true)
				-- m_animation = nil
			end
		end)
	end
end

local function onXYTouch(eventType, x, y)
	if eventType == "began" then
		last_began_x = x
		last_began_y = y
		last_is_move = false
		runAnimation(x,y)
	elseif eventType == "moved" then
		if not last_is_move then
			if math.abs(x - last_began_x) > 5 * config.getgScale() or math.abs(y - last_began_y) > 5 * config.getgScale() then
				last_is_move = true
			end
		end
	elseif eventType == "ended" then
		last_click_point.x = x
		last_click_point.y = y
	end

	return true
end

local function add_suspend_layer()
	if not suspend_layer_list then 
		suspend_layer_list = {}
	end

	--每次增加数量设置为3，即在找不到空闲的layer时会增加3个
	local win_size = config.getWinSize()
	for i=1,3 do
		local temp_color_layer = cc.LayerColor:create(cc.c4b(14, 17, 24, SUSPEND_LAYER_OPACITY), win_size.width, win_size.height)
		temp_color_layer:setVisible(false)
		basic_ui_layer:addChild(temp_color_layer)
		local layer_info_list = {}
		layer_info_list[1] = temp_color_layer
		layer_info_list[2] = 0
		table.insert(suspend_layer_list, layer_info_list)
	end
end

local function init_ui_layer()
	bottom_fix_layer = CCLayer:create()
	basic_ui_layer:addChild(bottom_fix_layer)
	panel_in_bottom_list = {}

	add_suspend_layer()
end

local function create()
	basic_ui_layer = CCLayer:create()
	basic_ui_layer:registerScriptTouchHandler(onLayerTouch, false, layerPriorityList.ui_priority, true)
	basic_ui_layer:setTouchEnabled(true)
	cc.Director:getInstance():getRunningScene():addChild(basic_ui_layer,UI_SCENE)

	xy_layer = CCLayer:create()
	xy_layer:registerScriptTouchHandler(onXYTouch, false, layerPriorityList.pos_priority, false)
	xy_layer:setTouchEnabled(true)
	cc.Director:getInstance():getRunningScene():addChild(xy_layer,SLIDE_SCENE)

	init_ui_layer()

	require("game/guide/newGuide/newGuideManager")
	newGuideManager.create()
end

local function clear_for_disconnect_net()
	local suspend_nums = #suspend_layer_list
	for i = suspend_nums, 1, -1 do
		local show_index = suspend_layer_list[i][2]
		if show_index ~= 0 then
			local main_class = uiPanelInfo.get_main_class_by_index(show_index)
			main_class.remove_self()
		end
	end

	local fix_nums = #panel_in_bottom_list
	for j = fix_nums, 1, -1 do
		local fix_index = panel_in_bottom_list[j]
		local fix_class = uiPanelInfo.get_main_class_by_index(fix_index)
		fix_class.remove_self()
	end
end

local function remove( )
	if basic_ui_layer then
		clear_for_disconnect_net()

		basic_ui_layer:removeFromParentAndCleanup(true)
		basic_ui_layer = nil

		bottom_fix_layer = nil
		suspend_layer_list = nil
	end

	if xy_layer then
		if m_animation then
			m_animation:removeFromParentAndCleanup(true)
			m_animation = nil
		end

		xy_layer:removeFromParentAndCleanup(true)
		xy_layer = nil
	end

	newGuideManager.remove()

	if simpleGuideTool then
		simpleGuideTool.remove()
	end
end

local function get_next_empty_layer_index()
	local result_index = 0
	for k,v in pairs(suspend_layer_list) do
		if v[2] == 0 then
			result_index = k
			break
		end
	end

	if result_index == 0 then
		result_index = #suspend_layer_list + 1
		add_suspend_layer()
	end

	return result_index
end

local function get_layer_index_by_panel_index(panel_index)
	local result_index = 0
	for k,v in pairs(suspend_layer_list) do
		if v[2] == panel_index then
			result_index = k
			break
		end
	end

	return result_index
end

--把除了全屏界面外的panel都隐藏或者显示
local function setPanelVisibel(flag, panel_index )
	if not suspend_layer_list then return end
	--不是全屏界面不处理
	if panelPropInfo[panel_index][4] == 0 then
		return
	end

	local index = 0 --最顶层的全屏界面index
	local hasFullScreenView = false --除了当前ui以外还有全屏界面
	local current_page_index = 0 --当前ui的index
	local suspend_nums = #suspend_layer_list
	for i = suspend_nums, 1, -1 do
		local show_index = suspend_layer_list[i][2]
		if show_index ~= 0 and panelPropInfo[show_index][4] == 1 then
			index = i
			break
		end
	end

	for i = suspend_nums, 1, -1 do
		local show_index = suspend_layer_list[i][2]
		if show_index ~= 0 and panelPropInfo[show_index][4] == 1 and show_index ~= panel_index then
			hasFullScreenView = true
			
			-- break
		end

		if show_index == panel_index then
			current_page_index = i
		end
	end

	if flag and not hasFullScreenView then
		map.setMapVisible(true)
		if not mainBuildScene.getThisCityid() then
			ObjectManager.setObjectVisible(true)
		end
		optionController.resetOptions(true)
	elseif not flag and panelPropInfo[panel_index][4] == 1 then
		map.setMapVisible(false)
		ObjectManager.setObjectVisible(false)
		optionController.removeOptions(true)
	end

	local function visi( )
		for i=current_page_index-1, 1, -1 do
			if suspend_layer_list[i][2] ~= 0 then
				suspend_layer_list[i][1]:setVisible(flag)
			end
			
			if suspend_layer_list[i][2] ~= 0 and panelPropInfo[suspend_layer_list[i][2]][4] == 1 then
				break
			end
		end
	end

	--打开全屏界面，当前ui以下都隐藏
	if not flag and current_page_index > 1 then
		visi()
	--关闭全屏界面, 如果是最上层的全屏，则把底下的都显示(一直到又出现全屏界面为止)
	elseif flag and current_page_index == index then
		visi()
	end
end

local function add_panel_to_layer(temp_touch_group, panel_index)
	--当其他ui打开，小地图如果打开，就关闭小地图
	-- require("game/option/cityListAndMiniMap")
	-- if panel_index ~= uiIndexDefine.UI_CITYLISTANDMAP or CityListAndMiniMap.getInstance() then
	-- 	CityListAndMiniMap.remove_self()
	-- end

	--当打开ui的时候，屏幕的飘字马上渐隐
	-- tipsLayer.FadeOutLayerWhenPageChange()

	local temp_prop_info = panelPropInfo[panel_index]
	if temp_prop_info then
		if temp_prop_info[3] == 0 then
			bottom_fix_layer:addChild(temp_touch_group)
			table.insert(panel_in_bottom_list, panel_index)
		else
			local show_layer_index = get_next_empty_layer_index()
			suspend_layer_list[show_layer_index][1]:addChild(temp_touch_group)
			suspend_layer_list[show_layer_index][1]:setVisible(true)
			if show_layer_index == 1 then
				suspend_layer_list[show_layer_index][1]:setOpacity(SUSPEND_LAYER_OPACITY)
			else
				suspend_layer_list[show_layer_index][1]:setOpacity(SUSPEND_OPACITY_2)
			end
			suspend_layer_list[show_layer_index][2] = panel_index
			if temp_prop_info[4] == 1 then
				if show_layer_index ~= 1 then
					-- suspend_layer_list[show_layer_index - 1][1]:setVisible(false)
				end
			end

			update_layer_show_level()
		end
	else
		tipsLayer.create("There is no the panel index in prop list !!!!!!!!!!")
	end

	--因为现在部分界面的动画没有采用统一出现的方式，所以需要特殊处理
	if panelPropInfo[panel_index][5][1] == 0 then
		newGuideInfo.deal_with_ui_loaded(panel_index)
		if comGuideInfo then
			comGuideInfo.deal_with_ui_loaded(panel_index)
		end

		if simpleGuideTool and simpleGuideTool.get_state() then
			simpleGuideTool.deal_with_ui_loaded()
		end
	end

	setPanelVisibel(false, panel_index)
end



local function remove_self_panel(panel_index)
	if panel_index ~= uiIndexDefine.MAP_MESSAGE_UI then
		LSound.playSound(musicSound["ui_cancel"])
	end

	--当打开ui的时候，屏幕的飘字马上渐隐
	-- tipsLayer.FadeOutLayerWhenPageChange()
	
	local temp_prop_info = panelPropInfo[panel_index]
	if temp_prop_info then
		if temp_prop_info[3] == 0 then
			for k,v in pairs(panel_in_bottom_list) do
				if v == panel_index then
					table.remove(panel_in_bottom_list, k)
					break
				end
			end
		else
			setPanelVisibel(true,panel_index )
			local show_layer_index = get_layer_index_by_panel_index(panel_index)
			suspend_layer_list[show_layer_index][1]:setVisible(false)
			suspend_layer_list[show_layer_index][2] = 0
			if temp_prop_info[4] == 1 then
				if show_layer_index ~= 1 then
					-- suspend_layer_list[show_layer_index - 1][1]:setVisible(true)
				end
			end
			IOSComment.shouldOpenComment()
			update_layer_show_level()
		end
	end
end

local function get_touch_began_pos()
	return last_began_x, last_began_y
end

local function getLastPoint()
	return last_click_point
end

local function getLastMoveState()
	return last_is_move
end

local function getBasicLayer()
	return bottom_fix_layer
end


local function hideScaleEffect(mainLayer,mainWidgetTag,callback,duration,scaleTo)
	--TODOTK 哑函数来的
	if callback then callback() end
end

local function showScaleEffect(mainLayer,mainWidgetTag,callback,duration,scaleFrom)
	--TODOTK 哑函数来的
	if callback then callback() end
end

--uiManager.showConfigEffect(uiIndexDefine.REPORT_UI,mLayer,nil,999,{m_backPanel:getMainWidget()})
--uiManager.hideConfigEffect(uiIndexDefine.REPORT_UI,mLayer,do_remove_self,999,{m_backPanel:getMainWidget()})


--uiManager.showConfigEffect(uiIndexDefine.BUILD_MSG_MANAGER,m_pMainLayer)
--uiManager.hideConfigEffect(uiIndexDefine.BUILD_TREE_MANAGER,m_mainLayer,do_remove_self)


-- widgets 不跑缩放特效的
local function showConfigEffect(uiDefinedId, mainLayer,callback,mainWidgetTag,widgets)
	local function doCallback ()
		if callback and type(callback) == "function" then 
			callback()
		end

		newGuideInfo.deal_with_ui_loaded(uiDefinedId)
		if comGuideInfo then
			comGuideInfo.deal_with_ui_loaded(uiDefinedId)
		end

		if simpleGuideTool and simpleGuideTool.get_state() then
			simpleGuideTool.deal_with_ui_loaded()
		end
	end

	if not mainWidgetTag then mainWidgetTag = 999 end -- 大家都用999 除了一些特殊的

	if not mainLayer then 
		doCallback()
		return
	end

	local mainWidget = mainLayer:getWidgetByTag(mainWidgetTag)
	if not mainWidget then 
		doCallback()
		return 
	end


	local configEffect = panelPropInfo[uiDefinedId][5]

	if not configEffect then 
		doCallback()
		return 
	end

	local showType = configEffect[1] -- 这个字段其实是没用的 给QC看更方便而已
	if showType == 0 then 
		doCallback()
		return 
	end

	local duration = configEffect[2] / 1000
	local scaleFrom = configEffect[3]
	local opacityFrom = configEffect[4]
	local mainLayerParent = mainLayer:getParent()

	if panelPropInfo[uiDefinedId][3] ~= 0 then 
		local function finallyParent()
			if mainLayerParent and mainLayerParent.setOpacity then
				set_layer_opacity(mainLayerParent)
				--mainLayerParent:setOpacity(SUSPEND_LAYER_OPACITY)
			end
		end
		uiUtil.showScaleEffect(mainLayerParent,finallyParent,duration)
	end
	uiUtil.showScaleEffect(mainWidget,doCallback,duration,scaleFrom,nil,opacityFrom)

	if widgets and type(widgets) == "table" then 
		for k,widget in pairs(widgets) do 
			uiUtil.showScaleEffect(widget,nil,duration,nil,nil,opacityFrom)
		end
	end
end

local function hideConfigEffect(uiDefinedId, mainLayer,callback,mainWidgetTag,widgets)
	local function doCallback ()
		if callback and type(callback) == "function" then 
			callback()
		end
	end

	if not mainWidgetTag then mainWidgetTag = 999 end -- 大家都用999 除了一些特殊的

	if not mainLayer then 
		doCallback()
		return
	end

	local mainWidget = mainLayer:getWidgetByTag(mainWidgetTag)
	if not mainWidget then 
		doCallback()
		return 
	end


	local configEffect = panelPropInfo[uiDefinedId][5]

	if not configEffect then 
		doCallback()
		return 
	end

	local showType = configEffect[1] -- 这个字段其实是没用的 给QC看更方便而已
	if showType == 0 then 
		doCallback()
		return 
	end
	
	local duration = configEffect[2] / 1000
	local scaleTo = configEffect[3]
	local opacityTo = configEffect[4]
	local mainLayerParent = mainLayer:getParent()

	if panelPropInfo[uiDefinedId][3] ~= 0 then 
		local function finallyParent()
			if mainLayerParent and mainLayerParent.setOpacity then
				set_layer_opacity(mainLayerParent)
				--mainLayerParent:setOpacity(SUSPEND_LAYER_OPACITY)
			end
		end
		uiUtil.hideScaleEffect(mainLayerParent,finallyParent,duration)
	end
	uiUtil.hideScaleEffect(mainWidget,doCallback,duration,scaleTo)

	if widgets and type(widgets) == "table" then 
		for k,widget in pairs(widgets) do 
			uiUtil.hideScaleEffect(widget,nil,duration)
		end
	end
end
local function isClearAll()
	return scene.isLeavingScene()
end

uiManager = {
				create = create,
				remove = remove,
				add_panel_to_layer = add_panel_to_layer,
				remove_self_panel = remove_self_panel,
				is_most_above_layer = is_most_above_layer,
				getBasicLayer = getBasicLayer,
				getLastPoint = getLastPoint,
				get_touch_began_pos = get_touch_began_pos,
				getLastMoveState = getLastMoveState,
				set_panel_visible = set_panel_visible,
				showScaleEffect = showScaleEffect,
				hideScaleEffect = hideScaleEffect,
				showConfigEffect = showConfigEffect,
				hideConfigEffect = hideConfigEffect,
				isClearAll = isClearAll,
				hasUI = hasUI,
}