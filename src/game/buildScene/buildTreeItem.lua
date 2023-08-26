--建筑树每个建筑的item的管理
module("BuildTreeItem", package.seeall)

local function addBuildImage(build_id )
	local pClip=CCClippingNode:create()
	pClip:setAlphaThreshold(0)
	-- pClip:addChild(pColor,1,1)
	local build = ImageView:create()
	build:loadTexture("build_"..build_id..".png",UI_TEX_TYPE_PLIST)

	local pStencil= nil
	if build_id == 10 or build_id == 12 then
		pStencil = cc.Sprite:createWithSpriteFrameName("jianzhumengban_chengzhufu.png")
		build:setScale(0.6)
	else
		pStencil = cc.Sprite:createWithSpriteFrameName("jianzhumengban.png")
		build:setScale(0.5)
	end
	pClip:setStencil(pStencil)
	pClip:setInverted(false)

	pClip:addChild(build)

	return pClip, build
end

local function buildTimerAnimation( radius)
	local node = CCDrawNode:create()
	node:drawDot(cc.p(radius,radius), radius, ccc4f(0,0,0,0.7))

	local render = CCRenderTexture:create(radius*2, radius*2,kCCTexture2DPixelFormat_RGBA8888)
	render:begin()
	node:visit()
	render:endToLua()

	return cc.Sprite:createWithTexture(render:getSprite():getTexture())
end

local function setTimerPercent(build_id )
	if not mainBuildScene.getThisCityid() then return end
	local build_info = politics.getBuildInfo(mainBuildScene.getThisCityid(), build_id)
	if not build_info then return end
	local left_time = build_info.end_time - userData.getServerTime()
	if left_time < 0 then
		left_time = 0
	end
	if build_info.state == buildState.upgrade then
		return left_time, 100*left_time/Tb_cfg_build_cost[build_id*100+build_info.level+1].time_cost
	end

	if build_info.state == buildState.demolition then
		return left_time, 100*left_time/BUILD_DEGRADE_TIME
	end

	return 0, 100
end

function setTouchColor( widget,flag)
	-- local item = tolua.cast(widget:getChildByName("ImageView_600962_1"),"ImageView")
	tolua.cast(widget:getChildByName("ImageView_606938"),"ImageView"):setVisible(flag)
end

function setBlink( widget )
	local image = tolua.cast(widget:getChildByName("ImageView_blink"),"ImageView")
	image:setVisible(true)
	local action = animation.sequence({CCFadeIn:create(0.6), CCFadeOut:create(0.4)})
	image:runAction(CCRepeat:create(action, 2))
end

function initItem( widget, build_id )
	if not build_id then return end
	if not mainBuildScene.getThisCityid() then return end
	local pre_condition_lv = nil
	-- local back_image_name = {"lanse_zuidiceng.png","lvse_zuidiceng.png"}
	-- local circle_image_name = {"lanse_waikuang.png","lvse_waikuang.png"}
	-- local max_level_Image_name_2 = {"lanse_wuji_bianjiao_1.png","lanse_wuji_bianjiao_2.png"}
	-- local max_level_Image_name_3 = {"lvse_wuji_bianjiao_1.png", "lvse_wuji_bianjiao_2.png"}
	-- local level_image_name = {"lanse_diban_xiao_xiaotubiao.png","lvse_diban_xiao_xiaotubiao.png"}

	--圆盘
	local back_image = tolua.cast(widget:getChildByName("ImageView_600962_1"), "ImageView")

	--外框圆圈
	local circle_image = tolua.cast(widget:getChildByName("ImageView_600968_1"), "ImageView")

	--显示当前等级和最大等级的图片
	local level_image = tolua.cast(widget:getChildByName("ImageView_600969_2"), "ImageView")

	--满级后四个点
	local max_level_Image = {}
	-- for i=1, 4 do
		table.insert(max_level_Image, tolua.cast(widget:getChildByName("item_max"), "ImageView"))
	-- end

	-- if Tb_cfg_build[build_id].area == 2 then
		
	-- else
	-- end

	-- back_image:loadTexture(back_image_name[Tb_cfg_build[build_id].area-1],UI_TEX_TYPE_PLIST)
	-- circle_image:loadTexture(circle_image_name[Tb_cfg_build[build_id].area-1],UI_TEX_TYPE_PLIST)
	-- level_image:loadTexture(level_image_name[Tb_cfg_build[build_id].area-1],UI_TEX_TYPE_PLIST) 
	-- for i, v in ipairs(max_level_Image) do
	-- 	if Tb_cfg_build[build_id].area == 2 then
	-- 		v:loadTexture(max_level_Image_name_2[math.ceil(i/2)])
	-- 	elseif Tb_cfg_build[build_id].area == 3 then
	-- 		v:loadTexture(max_level_Image_name_3[math.ceil(i/2)])
	-- 	end
	-- end

	local build_info = politics.getBuildInfo(mainBuildScene.getThisCityid(), build_id)
	local current_lv = 0
	if build_info then
		current_lv = build_info.level
	end

	--放建筑图片的panel
	local panel = tolua.cast(widget:getChildByName("Panel_603577"), "Layout")

	--满级如果有技能效果，图片显示
	local max_level_skill = tolua.cast(widget:getChildByName("ImageView_600985_1"), "ImageView")

	--当前等级label
	local image = tolua.cast(widget:getChildByName("ImageView_600969_2"), "ImageView") 
	local current_lv_Label = tolua.cast(image:getChildByName("Label_606917"), "Label")
	current_lv_Label:setText(current_lv)
	current_lv_Label:setVisible(true)

	--最大等级label
	local max_level_label = tolua.cast(image:getChildByName("Label_606918"), "Label")
	max_level_label:setVisible(true)
	max_level_label:setText(Tb_cfg_build[build_id].max_level)

	-- local length = current_lv_Label:getSize().width + max_level_label:getSize().width
	-- local posX = -length/2
	-- current_lv_Label:setPositionX(posX)
	-- max_level_label:setPositionX(posX+current_lv_Label:getSize().width)


	-- --最大等级显示max
	-- local max_image = tolua.cast(widget:getChildByName("ImageView_607631"), "ImageView")
	-- max_image:setVisible(false)
	-- if Tb_cfg_build[build_id].max_level <= current_lv then
	-- 	max_image:setVisible(true)
	-- 	current_lv_Label:setVisible(false)
	-- 	max_level_label:setVisible(false)
	-- end

	local isMaxLevel = false
	if Tb_cfg_build[build_id].max_level <= current_lv then
		isMaxLevel = true
	end
	
	for i, v in ipairs(max_level_Image) do
		v:setVisible(isMaxLevel)
	end

	circle_image:setVisible(not isMaxLevel)

	if max_level_skill then
		if string.len(Tb_cfg_build[build_id].description_max) > 0 and isMaxLevel then
			max_level_skill:setVisible(true)
		else
			max_level_skill:setVisible(false)
		end
	end

	local gray_sprite = tolua.cast(widget:getChildByName("ImageView_601083_0"), "ImageView")
	if gray_sprite then
		gray_sprite:setVisible(false)
	end

	local isCanBuild = true
	local pre_build_id = nil
	for m, n in ipairs(Tb_cfg_build[build_id].pre_condition) do
		pre_build_id = n[1]
		if mainBuildScene.getThisCityid() ~= userData.getMainPos() and pre_build_id ==10 then
			pre_build_id = 12
		end

		pre_condition_lv = politics.getBuildLevel(mainBuildScene.getThisCityid(), pre_build_id)
		if n[2] > pre_condition_lv then
			-- GraySprite.create(widget)
			--如果是废墟，那么这个是已经存在的
			if current_lv == 0 then
				gray_sprite:setVisible(true)
				isCanBuild =false
			end
		end
	end

	if isCanBuild then
		GraySprite.create(widget,nil,true)
	else
		GraySprite.create(widget,{"ImageView_blink"})
	end

	-- --当可以建但是没建的时候，圆盘变灰色,外圈环是彩色
	if isCanBuild and current_lv == 0 then
		GraySprite.create(back_image)
	elseif isCanBuild and current_lv ~= 0 then
		GraySprite.create(back_image,nil,true)
	end

	panel:removeAllChildrenWithCleanup(true)
	local building, buildingItem = addBuildImage(build_id )
	building:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height/2))
	panel:addChild(building)

	if current_lv == 0 then
		GraySprite.create(buildingItem)
	else
		GraySprite.create(buildingItem,nil,true)
	end

	local label_panel = tolua.cast(widget:getChildByName("Panel_607618"),"Layout")
	label_panel:removeAllChildrenWithCleanup(true)
	panel:stopAllActions()

	--升级图标
	local upgradeIcon = tolua.cast(widget:getChildByName("ImageView_607622"),"ImageView")
	upgradeIcon:setVisible(false)

	--建造图标
	local buildIcon = tolua.cast(widget:getChildByName("ImageView_607623"),"ImageView")
	buildIcon:setVisible(false)

	if build_info and (build_info.state == buildState.upgrade or build_info.state == buildState.demolition) then
		if build_info.state == buildState.upgrade and current_lv ~= 0 then
			upgradeIcon:setVisible(true)
		elseif build_info.state == buildState.upgrade and current_lv == 0 then
			buildIcon:setVisible(true)
		end

		local timerItem = nil
		timerItem= buildTimerAnimation( panel:getSize().width/2)
		timerItem:getTexture():setAntiAliasTexParameters()
		local pProgressTimer = CCProgressTimer:create(timerItem)
		pProgressTimer:setReverseDirection(true)
		pProgressTimer:setType(kCCProgressTimerTypeRadial)
		panel:addChild(pProgressTimer)
		pProgressTimer:setPosition(cc.p(panel:getSize().width/2, panel:getSize().height/2))
		local left_time, percent = setTimerPercent(build_id )
		pProgressTimer:setPercentage(percent)

		local label = CCLabelTTF:create(commonFunc.format_time(left_time),config.getFontName(), 18, CCSize(label_panel:getSize().width, label_panel:getSize().height), kCCTextAlignmentCenter)
		label_panel:addChild(label)

		label:setPosition(cc.p(label_panel:getSize().width/2, label_panel:getSize().height/2))
		label:enableStroke(ccc3(0,0,0),1,true)

		local animationAction = animation.sequence({cc.DelayTime:create(1), cc.CallFunc:create(function ( )
			left_time, percent = setTimerPercent(build_id )
			label:setString(commonFunc.format_time(left_time))
			pProgressTimer:setPercentage(percent)
		end)})
		panel:runAction(CCRepeatForever:create(animationAction))
	end
end