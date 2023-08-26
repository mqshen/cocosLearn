local selectBornInfo = {}
local select_born_layer = nil
local pic_img_list = nil
local detect = nil
local isNewRole = nil
local last_select_state_index = nil

local uiUtil = require("game/utils/ui_util")

function selectBornInfo.remove()
	if select_born_layer then
		select_born_layer:removeFromParentAndCleanup(true)
		select_born_layer = nil
		isNewRole = nil
		last_select_state_index = nil
		--detect:release()
		detect = nil
		for i,v in ipairs(pic_img_list) do
			v:release()
		end
		pic_img_list = nil
	end
end

local function deal_with_return_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		loginGUI.showLoginView()
		selectBornInfo.remove()
	end
end

local function onRangerBack(packet)
	netObserver.removeObserver(USER_TRAMP)
	local ret = packet[1]
	if ret == 1 then 
		-- local user_game_info = packet[2]
		-- userData.setUserData(user_game_info[1])
		-- scene.create()
		-- loginGUI.remove()
		-- local user_game_info = packet[2]
		-- if user_game_info then
		-- 	userData.setUserData(user_game_info[1])
			
		-- 	scene.create()
		-- 	loginGUI.remove()
		-- end
		-- local userName,userCode = Login.getAccountInfo()
   		Login.requestLogin()
   		
	end
end

local function sortRuler(regoinIdA,regoinIdB)
	if regoinIdA < regoinIdB then return true end
	return false
end
-- 如果返回nil 说明整个服务器都爆满了
local function getDefaultRegionIndx()
	local canBornRegion = {}
	local normalState = false
	for k,v in pairs(Tb_cfg_region) do 
		normalState = loginGUI.get_state_info_by_index(v.region_id)
		if normalState and v.born == 1 then 
			table.insert(canBornRegion,v.region_id)
		end
	end

	table.sort( canBornRegion, sortRuler )

	--[[ 
	-- 默认开放四个州
	for i = #canBornRegion, 5, -1 do 
		table.remove(canBornRegion,i)
	end
	]]

	local default_indx = nil

	for k,v in pairs(canBornRegion) do 
		if not default_indx then 
			default_indx = v
		else
			if v < default_indx then 
				default_indx = v
			end
		end
	end
	return default_indx,canBornRegion
end
local function onSelectCheckRegionAble(new_index)
	local normalState = loginGUI.get_state_info_by_index(new_index)
	if Tb_cfg_region[new_index].born == 0 then 
		tipsLayer.create("争夺之地，不可选择")
		return false
	end

	if not normalState then 
		tipsLayer.create(errorTable[116])
		return false
	end

	local default_indx,canBornRegion = getDefaultRegionIndx()

	if not default_indx then 
		tipsLayer.create("服务器已满，请选择其它服务器")
		return false
	end
	local isInvalid = false
	for k,v in pairs(canBornRegion) do 
		if v == new_index then 
			isInvalid = true
		end
	end
	if not isInvalid then 
		local nameStr = ""
		for k,v in pairs(canBornRegion) do 
			nameStr = nameStr .. Tb_cfg_region[v].name
			if k ~= #canBornRegion then 
				nameStr = nameStr .. "、"
			end
		end
		tipsLayer.create("暂不开放，请选择" .. nameStr)
		return false
	end

	return normalState
end

local function deal_with_next_click(sender, eventType)
	

	local inputNameLoginInfo = require("game/login/inputNameLoginInfo")
	if inputNameLoginInfo.getInstance() then
		return
	end
	
	if eventType == TOUCH_EVENT_ENDED then
		if last_select_state_index == 0 then
			tipsLayer.create("服务器已满，请选择其它服务器")
		else
			if not onSelectCheckRegionAble(last_select_state_index) then 
				return 
			end
			if loginGUI.get_state_info_by_index(last_select_state_index) then
				if isNewRole then
					inputNameLoginInfo.create(last_select_state_index)
					
					-- remove()
				else
					-- sender:setTouchEnabled(false)
					-- TODOTK 添加州状态判断					
					netObserver.addObserver(USER_TRAMP, onRangerBack)
					Net.send(USER_TRAMP, {last_select_state_index})
				end
				
			else
				tipsLayer.create(errorTable[116])
			end
		end
	end
end



	
local function on_select_new_state(new_index)
	
	if last_select_state_index == new_index then
		return
	end
	local isSelectValid = onSelectCheckRegionAble(new_index)
	if not isSelectValid then return end
	tipsLayer.remove()

	local temp_widget = select_born_layer:getWidgetByTag(999)
	local base_map_panel = tolua.cast(temp_widget:getChildByName("base_map_img"), "ImageView")

	local state_img = nil
	if last_select_state_index ~= 0 then
		state_img = tolua.cast(base_map_panel:getChildByName("map_img_" .. last_select_state_index), "ImageView")
		state_img:setVisible(false)
	end

	require("game/encapsulation/action")
	last_select_state_index = new_index
	state_img = tolua.cast(base_map_panel:getChildByName("map_img_" .. last_select_state_index), "ImageView")
	state_img:setVisible(true)
	state_img:setOpacity(255)
	state_img:stopAllActions()
	state_img:runAction(CCRepeatForever:create(animation.sequence({CCFadeTo:create(0.4,255*0.4), CCFadeTo:create(0.4,255)})))

	local temp_des_panel = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	temp_des_panel:setVisible(true)

	local next_btn = tolua.cast(temp_des_panel:getChildByName("next_btn"), "Button")
	next_btn:setVisible(true)
	next_btn:setTouchEnabled(true)
	local name_txt = tolua.cast(temp_des_panel:getChildByName("name_label"), "Label")
	name_txt:setText(Tb_cfg_region[last_select_state_index].name)
	local des_txt = tolua.cast(temp_des_panel:getChildByName("des_label"), "Label")
	des_txt:setText(Tb_cfg_region[last_select_state_index].description)

	
	if not isSelectValid then 
		next_btn:setBright(false)
	else
		next_btn:setBright(true)
	end

	

	local back = tolua.cast(temp_widget:getChildByName("ImageView_557707"), "ImageView")
	local img_tips_left = uiUtil.getConvertChildByName(temp_widget,"img_tips_left")
	local img_tips_right = uiUtil.getConvertChildByName(temp_widget,"img_tips_right")

	img_tips_left:ignoreAnchorPointForPosition(false)
	img_tips_left:setAnchorPoint(cc.p(0,0))
	img_tips_left:setPosition(cc.p(
	temp_des_panel:getPositionX() - temp_des_panel:getSize().width/2 + 10,
	temp_des_panel:getPositionY() + temp_des_panel:getSize().height + 10))
	img_tips_right:ignoreAnchorPointForPosition(false)
	img_tips_right:setAnchorPoint(cc.p(1,0))
	img_tips_right:setPosition(cc.p(
	temp_des_panel:getPositionX() + temp_des_panel:getSize().width/2 - 10,
	temp_des_panel:getPositionY() + temp_des_panel:getSize().height + 10))

end

local function deal_with_select_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local touch_point = loginGUI.get_touch_point()
		local state_img = nil
		local alpha = nil
		for i=1,13 do
			state_img = tolua.cast(sender:getChildByName("map_img_" .. i), "ImageView")
			if state_img:hitTest(touch_point) then
				--local pic_size = state_img:getContentSize()
				local node_point = state_img:convertToNodeSpace(touch_point)
				-- node_point.x = node_point.x + state_img:getContentSize().width*0.5
				-- node_point.y = node_point.y + state_img:getContentSize().height*0.5
				alpha = detect:getAlpha(pic_img_list[i], node_point.x, state_img:getContentSize().height - node_point.y)
				if alpha.a ~= 0 then
					on_select_new_state(i)
					return
				end
			end
		end
	end
end

--[[
local pic_name_list = {"sili", "yengzhou", "yongzhou", "yuzhou", "yizou", "qingzhou", "xuzhou", 
							"yangzhou","bingzhou", "liangzhou", "yizhou", "youzhou", "jingzhiu"}
	
]]
local function init_pic_info()
	last_select_state_index = 0
	detect = CCTextureDetect:sharedDetect()
	local pic_name_list = {
		"dadituchusheng_12.png", 
		"dadituchusheng_10.png", 
		"dadituchusheng_13.png", 
		"dadituchusheng_11.png", 
		"dadituchusheng_6.png", 
		"dadituchusheng_5.png", 
		"dadituchusheng_4.png", 
		"dadituchusheng_3.png",
		"dadituchusheng_8.png", 
		"dadituchusheng_9.png", 
		"dadituchusheng_1.png", 
		"dadituchusheng_7.png", 
		"dadituchusheng_2.png"}
	pic_img_list = {}
	for i=1,#pic_name_list do
		local sprite = cc.Sprite:create("test/res_single/"..pic_name_list[i])
		sprite:setAnchorPoint(cc.p(0,0))
		local textureRender = CCRenderTexture:create(sprite:getContentSize().width,sprite:getContentSize().height,kCCTexture2DPixelFormat_RGBA8888)
		textureRender:begin()
		sprite:visit()
		textureRender:endToLua()
		local img = textureRender:newCCImage()
		pic_img_list[i] = img
	end
end

local function init_map_info()
	local temp_widget = select_born_layer:getWidgetByTag(999)
	local temp_des_panel = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	local name_txt = tolua.cast(temp_des_panel:getChildByName("name_label"), "Label")
	name_txt:setText(" ")
	local des_txt = tolua.cast(temp_des_panel:getChildByName("des_label"), "Label")
	des_txt:setText(" ")

	local base_map_panel = tolua.cast(temp_widget:getChildByName("base_map_img"), "ImageView")
	base_map_panel:addTouchEventListener(deal_with_select_click)
	base_map_panel:setTouchEnabled(true)

	local state_img = nil
	for i=1,13 do
		state_img = tolua.cast(base_map_panel:getChildByName("map_img_" .. i), "ImageView")
		state_img:setVisible(false)
		state_img:setAnchorPoint(cc.p(0,0))
	end
	local panel_img_flag = uiUtil.getConvertChildByName(temp_widget,"panel_img_flag")
	local img_flag = nil
	for i = 1,13 do
		img_flag = uiUtil.getConvertChildByName(panel_img_flag,"img_flag_" .. i)
		--------------- 1 到 4 是争夺地
		if i > 4 then 
			-- UI 把这两个资源的名字定义反了 。。。。。。。。
			if loginGUI.get_state_info_by_index(i) then 
				img_flag:loadTexture("fuwuqiyiman.png",UI_TEX_TYPE_PLIST)
			else
				img_flag:loadTexture("fuwuqilianghao.png",UI_TEX_TYPE_PLIST)
			end
			img_flag:setVisible(true)
		else
			img_flag:setVisible(false)
		end
	end

	-- 不能出生得州要变灰
	local panel_state_name = tolua.cast(temp_widget:getChildByName("Panel_state_name"), "Layout")
	local default_indx,canBornRegion = getDefaultRegionIndx()
	local state_name_image = nil
	local canBornRegionTable = {}
	for k,v in pairs(canBornRegion) do 
		-- if v == new_index then 
		-- 	isInvalid = true
		-- end
		canBornRegionTable[v] = 1
	end

	for k,v in pairs(Tb_cfg_region) do
		if v.born == 0 or not canBornRegionTable[v.region_id] then
			state_name_image = tolua.cast(panel_state_name:getChildByName("flag_region_"..v.region_id), "ImageView")
			tolua.cast(state_name_image:getVirtualRenderer(),"CCSprite"):setGray(kCCSpriteGray)
		end
	end
end

function selectBornInfo.create(isCreateRole)
	isNewRole = isCreateRole

	local win_size = config.getWinSize()

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/selectBornUI_0_cell.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local top_panel = tolua.cast(temp_widget:getChildByName("Panel_560093"), "Layout")
	local return_btn = tolua.cast(top_panel:getChildByName("return_btn"), "Button")
	return_btn:addTouchEventListener(deal_with_return_click)
	return_btn:setTouchEnabled(true)

	if not isNewRole then 
		return_btn:setVisible(false)
		return_btn:setTouchEnabled(false)
	end

	local temp_des_panel = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
	
	-- temp_des_panel:setTouchEnabled(true)
	local next_btn = tolua.cast(temp_des_panel:getChildByName("next_btn"), "Button")
	next_btn:setVisible(false)
	next_btn:setTouchEnabled(false)
	next_btn:addTouchEventListener(deal_with_next_click)

	if not isNewRole then 
		local btn_label = tolua.cast(next_btn:getChildByName("btn_label"), "Label")
		btn_label:setText(languagePack["queren"])
	end

	select_born_layer = TouchGroup:create()
	local temp_color_layer = cc.LayerColor:create(cc.c4b(14, 17, 24, 230), win_size.width, win_size.height)
	select_born_layer:addChild(temp_color_layer)
	temp_color_layer:setVisible(false)
	select_born_layer:addWidget(temp_widget)
	loginGUI.add_login_content(select_born_layer)

	init_map_info()
	init_pic_info()

	temp_des_panel:setVisible(false)
	local point_bottom = temp_des_panel:getParent():convertToNodeSpace(cc.p(win_size.width/2, 0))
	temp_des_panel:setPosition(point_bottom)
	temp_des_panel:setSize(CCSize(win_size.width/config.getgScale(), temp_des_panel:getSize().height))

	top_panel:setAnchorPoint(cc.p(0.5,1))
	local point_top = top_panel:getParent():convertToNodeSpace(cc.p(win_size.width/2, win_size.height))
	top_panel:setPosition(point_top)
	top_panel:setSize(CCSize(win_size.width/config.getgScale(), top_panel:getSize().height))

	local back = tolua.cast(temp_widget:getChildByName("ImageView_557707"), "ImageView")
	back:setScale(win_size.height/config.getgScale()/back:getSize().height)
	
	local top_image = tolua.cast(temp_widget:getChildByName("ImageView_557705"), "ImageView")
	top_image:setSize(CCSize(win_size.width/config.getgScale(), top_image:getSize().height))
	top_image:setPosition(cc.p(point_top.x, point_top.y- top_image:getSize().height))
	-- on_select_new_state(1)
	local default_indx = getDefaultRegionIndx()
	if default_indx then 
		on_select_new_state(default_indx)
	end
end

function selectBornInfo.setLayerTouchable( flag )
	if select_born_layer then
		local temp_widget = select_born_layer:getWidgetByTag(999)
		local base_map_panel = tolua.cast(temp_widget:getChildByName("base_map_img"), "ImageView")
		base_map_panel:setTouchEnabled(flag)

		local temp_des_panel = tolua.cast(temp_widget:getChildByName("des_img"), "ImageView")
		local next_btn = tolua.cast(temp_des_panel:getChildByName("next_btn"), "Button")
		next_btn:setTouchEnabled(flag)

		local top_panel = tolua.cast(temp_widget:getChildByName("Panel_560093"), "Layout")
		local return_btn = tolua.cast(top_panel:getChildByName("return_btn"), "Button")
		return_btn:setTouchEnabled(flag)
	end
end


return selectBornInfo 
