local inputNameLoginInfo = {}
local input_name_and_confirm_layer = nil
local name_content = nil
local state_type = nil 	--州编号
local current_phase = nil --1 输入名字部分；2 确认信息部分
local inputBoxX = nil

function inputNameLoginInfo.remove()
	if input_name_and_confirm_layer then
		input_name_and_confirm_layer:removeFromParentAndCleanup(true)
		input_name_and_confirm_layer = nil

		name_content = nil
		state_type = nil
		current_phase = nil
		inputBoxX = nil
		local selectBornInfo = require("game/login/selectBornInfo")
		selectBornInfo.setLayerTouchable(true)
		loginGUI.setBlackLayerVisible(false)
	end
end

local function deal_with_enter_phase(new_phase)
	local temp_widget = input_name_and_confirm_layer:getWidgetByTag(999)
	local name_img = tolua.cast(temp_widget:getChildByName("name_img"), "ImageView")
	local random_btn = tolua.cast(temp_widget:getChildByName("random_btn"), "Button")
	-- local confirm_img = tolua.cast(temp_widget:getChildByName("confirm_img"), "ImageView")

	current_phase = new_phase
	local born_txt = tolua.cast(name_img:getChildByName("born_label"), "Label")
	born_txt:setText(Tb_cfg_region[state_type].name)
	if current_phase == 1 then
		-- local name_txt = tolua.cast(name_img:getChildByName("name_tf"), "TextField")

		inputBoxX:setText("")
		-- inputBoxX:setTouchEnabled(true)
		-- confirm_img:setTouchEnabled(false)
		-- confirm_img:setVisible(false)
		name_img:setVisible(true)
		random_btn:setTouchEnabled(true)
		
		math.randomseed(os.time())
	else
		-- local confirm_name_txt = tolua.cast(confirm_img:getChildByName("name_label"), "Label")
		inputBoxX:setText(name_content)
		-- name_img:setVisible(false)
		-- confirm_img:setTouchEnabled(true)
		-- confirm_img:setVisible(true)
		random_btn:setTouchEnabled(false)

		if configBeforeLoad.getDebugEnvironment() then
			EndGameUI.create("是否建立高级账号",function ( )
				Net.send(CREATE_ROLE, {state_type,0})
				EndGameUI.remove_self()
			end, function ( )
				Net.send(CREATE_ROLE, {state_type,1})
				EndGameUI.remove_self()
			end, "否", "是")
		else
			Net.send(CREATE_ROLE, {state_type,0})
		end
	end
end

local function deal_with_name_random(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		local xing = PLAYER_FAMILY_NAME[math.random(#PLAYER_FAMILY_NAME)]
		local ming = PLAYER_FIRST_NAME[math.random(#PLAYER_FIRST_NAME)]
		local temp_widget = input_name_and_confirm_layer:getWidgetByTag(999)
		-- local name_img = tolua.cast(temp_widget:getChildByName("name_img"), "ImageView")
		-- local name_txt = tolua.cast(name_img:getChildByName("name_tf"), "TextField")
		local temp_name = string.format("%s%s", xing, ming)
		inputBoxX:setText(temp_name)
	end
end

local function deal_with_return_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if current_phase == 1 then
			-- selectBornInfo.create(true)
			inputNameLoginInfo.remove()
		else
			deal_with_enter_phase(1)
		end
	end
end

local function deal_with_confirm_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		if current_phase == 1 then
			local temp_widget = input_name_and_confirm_layer:getWidgetByTag(999)
			-- local name_img = tolua.cast(temp_widget:getChildByName("name_img"), "ImageView")
			-- local name_txt = tolua.cast(name_img:getChildByName("name_tf"), "TextField")
			name_content = inputBoxX:getText()
			if name_content == "" then
				tipsLayer.create(errorTable[118])
			else
				if stringFunc.get_str_length(name_content) > 8 then
					tipsLayer.create(errorTable[117])
				else
					Net.send(CREATE_ROLE_NAME, {name_content})
				end
			end
		else
			if configBeforeLoad.getDebugEnvironment() then
				EndGameUI.create("是否建立高级账号",function ( )
					Net.send(CREATE_ROLE, {state_type,0})
					EndGameUI.remove_self()
				end, function ( )
					Net.send(CREATE_ROLE, {state_type,1})
					EndGameUI.remove_self()
				end, "否", "是")
			else
				Net.send(CREATE_ROLE, {state_type,0})
			end
			-- Net.send(CREATE_ROLE, {state_type,0})
		end
	end
end

function inputNameLoginInfo.create(new_type)

	local selectBornInfo = require("game/login/selectBornInfo")
	selectBornInfo.setLayerTouchable(false)
	state_type = new_type

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/inputNameLoginUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))

	local name_image = tolua.cast(temp_widget:getChildByName("name_img"),"ImageView")

	local panel = tolua.cast(name_image:getChildByName("Panel_510789"),"Layout")
	local editBoxSize = CCSizeMake(panel:getContentSize().width*config.getgScale(),panel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(14,14,2,2)
    inputBoxX = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("main_interface_of_city_information_base.png",rect))
    inputBoxX:setAlignment(1)
    inputBoxX:setFontName(config.getFontName())
    inputBoxX:setFontSize(30*config.getgScale())
    inputBoxX:setFontColor(ccc3(255,255,255))
    name_image:addChild(inputBoxX)
    inputBoxX:setScale(1/config.getgScale())
    inputBoxX:setPosition(cc.p(panel:getPositionX(), panel:getPositionY()))
    inputBoxX:setAnchorPoint(cc.p(0,0))


    -- local title = tolua.cast(name_image:getChildByName("title_label"),"Label")
    -- title = tolua.cast(title:getVirtualRenderer(),"CCLabelTTF")
    -- title:enableStroke(ccc3(0,255,0), 2, true)
    -- local title = CCLabelTTF:create("请输入势力名",config.getFontName(), 22, CCSize(264, 30), kCCTextAlignmentCenter)

    -- title:enableStroke(ccc3(0,0,0), 2, true)
    -- name_image:addChild(title)
    -- name_image:setPosition()

	-- local name_img = tolua.cast(temp_widget:getChildByName("name_img"), "ImageView")
	local random_btn = tolua.cast(temp_widget:getChildByName("random_btn"), "Button")
	random_btn:addTouchEventListener(deal_with_name_random)

	local return_btn = tolua.cast(temp_widget:getChildByName("return_btn"), "Button")
	return_btn:addTouchEventListener(deal_with_return_click)
	return_btn:setTouchEnabled(true)

	local confirm_btn = tolua.cast(temp_widget:getChildByName("confirm_btn"), "Button")
	confirm_btn:addTouchEventListener(deal_with_confirm_click)
	confirm_btn:setTouchEnabled(true)

	input_name_and_confirm_layer = TouchGroup:create()

	-- local _layout = Layout:create()
	-- _layout:setContentSize(config.getWinSize().width, config.getWinSize().height)
	-- _layout:setSize(CCSize(config.getWinSize().width, config.getWinSize().height))
	-- _layout:setTouchEnabled(true)
	-- input_name_and_confirm_layer:addWidget(_layout)
	input_name_and_confirm_layer:addWidget(temp_widget)
	loginGUI.setBlackLayerVisible(true)
	loginGUI.add_login_content(input_name_and_confirm_layer)

	deal_with_enter_phase(1)
    local xing = PLAYER_FAMILY_NAME[math.random(#PLAYER_FAMILY_NAME)]
	local ming = PLAYER_FIRST_NAME[math.random(#PLAYER_FIRST_NAME)]
	-- local temp_widget = input_name_and_confirm_layer:getWidgetByTag(999)
	-- local name_img = tolua.cast(temp_widget:getChildByName("name_img"), "ImageView")
	-- local name_txt = tolua.cast(name_img:getChildByName("name_tf"), "TextField")
	local temp_name = string.format("%s%s", xing, ming)
	inputBoxX:setText(temp_name)
end

function inputNameLoginInfo.name_check_finish()
	deal_with_enter_phase(2)
end

function inputNameLoginInfo.getInstance( )
	return input_name_and_confirm_layer
end

return inputNameLoginInfo
-- inputNameLoginInfo = {
-- 						create = create,
-- 						remove = remove,
-- 						name_check_finish = name_check_finish,
-- 						getInstance = getInstance
-- }