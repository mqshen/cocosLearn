local uiUtil = require("game/utils/ui_util")
local cardUtil = require("game/utils/cardUtil")
local StringUtil = require("game/utils/string_util")
local TAG_HERO_INTRO_LIST = 890
local TAG_CARD_FRAME = 880
local TAG_HIT_TEST_LAYER = 500
local TAG_WASH_POINT = 600



local function playArmatureOnce(file,parent,posx,posy,apx,apy,scale,callback)
    if not parent then return end
    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo("Export/" .. file .. ".ExportJson")
    local armature = CCArmature:create(file)
    if apx and apy then 
    	armature:setAnchorPoint(cc.p(apx,apy))
    end
    if not scale then scale = 1 end
    armature:getAnimation():playWithIndex(0)
    parent:addChild(armature,999,999)
    armature:setPosition(cc.p(posx , posy))
    armature:setScale(scale)
    loadingLayer.create(nil,false)
    local function animationCallFunc(armatureNode, eventType, name)
        if eventType == 1 or eventType == 2 then
            armatureNode:removeFromParentAndCleanup(true)
            armature = nil
            loadingLayer.remove()
            CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo("Export/" .. file .. ".ExportJson")
			if callback then callback() end
        end
    end
    armature:getAnimation():setMovementEventCallFunc(animationCallFunc)
end


local function run3DTurnAction(hideItem,showItem,finallyFunc,duration)
	if not duration then duration = 0.5 end
	local finallyHide = function ()
		
	end
	local finallyShow = function()
		
	end
	local orbitHide = CCOrbitCamera:create(duration * 0.5,1, 0, 0,-90, 0, 0)
	local actionHide = animation.sequence({orbitHide,CCHide:create(),cc.DelayTime:create(duration*0.5),cc.CallFunc:create(finallyHide)})

	local orbitShow = CCOrbitCamera:create(duration * 0.5,1, 0, 90,-90, 0, 0)
	local finally = function ()
		if finallyFunc then finallyFunc() end
	end
	local actionShow = animation.sequence({cc.DelayTime:create(duration*0.5),CCShow:create(),orbitShow,cc.CallFunc:create(finallyShow),cc.CallFunc:create(finally)})

	hideItem:runAction(actionHide)
	showItem:runAction(actionShow)
end





-- 武将列传
local function setHeroIntro(item,basicHeroInfo,heroInfo)
	if not item then return end
	local panel_hero_intro = uiUtil.getConvertChildByName(item,"panel_hero_intro")
	
	local label_name = uiUtil.getConvertChildByName(panel_hero_intro,"label_name")
	label_name:setText(basicHeroInfo.name)

	local scrollView = uiUtil.getConvertChildByName(panel_hero_intro,"scrollView")
	local main_panel = uiUtil.getConvertChildByName(scrollView,"main_panel")
	
	local label_title_1 = uiUtil.getConvertChildByName(main_panel,"label_title_1")
	if not label_title_1 then 
		label_title_1 = Label:create()
		--TODOTK 中文收集
		label_title_1:setText("列传")
		main_panel:addChild(label_title_1)
		label_title_1:setColor(ccc3(219,173,100))
		label_title_1:setName("label_title_1")
		label_title_1:ignoreAnchorPointForPosition(false)
		label_title_1:setAnchorPoint(cc.p(0,0))
		label_title_1:setFontSize(22)
	end

	local label_title_2 = uiUtil.getConvertChildByName(main_panel,"label_title_2")
	if not label_title_2 then 
		label_title_2 = Label:create()
		--TODOTK 中文收集
		label_title_2:setText("武将组合")
		main_panel:addChild(label_title_2)
		label_title_2:setColor(ccc3(219,173,100))
		label_title_2:setName("label_title_2")
		label_title_2:ignoreAnchorPointForPosition(false)
		label_title_2:setAnchorPoint(cc.p(0,1))
		label_title_2:setFontSize(22)
	end

	local label_intro = uiUtil.getConvertChildByName(main_panel,"label_intro")
	if label_intro then label_intro:removeFromParentAndCleanup(true) end
	label_intro = Label:create()
	
	label_intro:setColor(ccc3(255,255,255))
	label_intro:setName("label_intro")
	label_intro:ignoreAnchorPointForPosition(false)
	label_intro:setAnchorPoint(cc.p(0,1))
	label_intro:setFontSize(18)
	label_intro:setContentSize(CCSizeMake(main_panel:getContentSize().width - 20,0))
	label_intro:setTextAreaSize(CCSizeMake(main_panel:getContentSize().width - 20,0))
	main_panel:addChild(label_intro)
	label_intro:setText(basicHeroInfo.description)

	local last_offset_y = main_panel:getContentSize().height - 10
	last_offset_y = last_offset_y - label_title_1:getContentSize().height
	label_title_1:setPosition(cc.p(10 , last_offset_y))
	last_offset_y = last_offset_y - 10
	label_intro:setPosition(cc.p(10,last_offset_y))
	label_intro:setText(basicHeroInfo.description)

	last_offset_y = last_offset_y - label_intro:getContentSize().height - 10 
	label_title_2:setPosition(cc.p(10,last_offset_y))


	local titleListInfo = cardUtil.getTitleInfo(basicHeroInfo.heroid)
    local hasTitle = false 
    for k,v in pairs(titleListInfo) do
    	hasTitle = true
    end

    if hasTitle then 
    	label_title_2:setVisible(true)
    else
    	label_title_2:setVisible(false)
    end


    last_offset_y = last_offset_y - label_title_2:getContentSize().height - 10

    local titleItem = 0
    -- 最多10个武将组合
    for i = 1 ,10 do 
    	titleItem = uiUtil.getConvertChildByName(main_panel,"titleItem_" .. i )
    	if titleItem then 
    		titleItem:setVisible(false)
    	end
    end

    local titleIndx = 0
    local label_effect = nil
    local ui_max_label_effect = 10
    local auto_size_offset = 0
    local label_effect_visible_num = 0
    local cur_label_idx = nil
    local label_title_name = nil
    for k,v in pairs(titleListInfo) do 

    	auto_size_offset = 0
    	titleIndx = titleIndx + 1
    	titleItem = uiUtil.getConvertChildByName(main_panel,"titleItem_" .. titleIndx)
    	if not titleItem then 
    		titleItem = GUIReader:shareReader():widgetFromJsonFile("test/cardTitleDetail.json")
    		titleItem:ignoreAnchorPointForPosition(false)
    		titleItem:setAnchorPoint(cc.p(0,1))
    		titleItem:setName("titleItem_" .. titleIndx)
    		-- titleItem:setScale(config.getgScale())
    		main_panel:addChild(titleItem)
    	end

    	label_title_name = uiUtil.getConvertChildByName(titleItem,"label_title_name")
    	label_title_name:setText(k)
    	
    	titleItem:setVisible(true)
    	label_effect_visible_num = 0
    	for i = 1, 10 do 
			label_effect = uiUtil.getConvertChildByName(titleItem,"label_effect_" .. i)
			label_effect:setVisible(false)
		end

		cur_label_idx = 1
		for heroName ,heroCountrys in pairs(v["heronames"]) do 
			label_effect = uiUtil.getConvertChildByName(titleItem,"label_effect_" .. cur_label_idx)
			heroName = heroName .. "（"
			heroName = heroName .. StringUtil.tableJoin2Str(heroCountrys,"/")
			heroName = heroName .. "）"
			label_effect:setText(heroName)
			label_effect:setVisible(true)
			cur_label_idx = cur_label_idx + 1
			label_effect_visible_num = label_effect_visible_num + 1
		end

		local label_hero_num = uiUtil.getConvertChildByName(titleItem,"label_hero_num")
		label_hero_num:setText(v["heronum"])

		local label_add_atts = uiUtil.getConvertChildByName(titleItem,"label_add_atts")
		label_add_atts:setText(skillData.get_skill_effect_simple_des(v["skillId"], 1, 0, 0))
		
		local label_title_name_2 = uiUtil.getConvertChildByName(titleItem,"label_title_name_2")
		cur_widget_heigt = titleItem:getContentSize().height 
		local itemLabelHeight = 24
		
		auto_size_offset = itemLabelHeight * math.floor( (ui_max_label_effect - label_effect_visible_num) / 2 )
		label_title_name_2:setPositionY(38 + auto_size_offset )
		label_add_atts:setPositionY(12 + auto_size_offset )
		cur_widget_heigt = cur_widget_heigt - auto_size_offset

    	titleItem:setPosition(cc.p(20,last_offset_y))
    	last_offset_y = last_offset_y - cur_widget_heigt - 10 
    end
    local twidth = scrollView:getSize().width
    if  last_offset_y >= 0 then 
        scrollView:setInnerContainerSize(CCSizeMake(twidth,main_panel:getSize().height))
        main_panel:setPositionY(0)
    else
    	scrollView:setInnerContainerSize(CCSizeMake(twidth,main_panel:getSize().height - last_offset_y))
        main_panel:setPositionY(-last_offset_y)
    end
end

-- 卡牌框信息
local function setCardFrame(item,basicHeroInfo,heroInfo,basicInfoOffset)
	if not item then return end
	local panel_card_frame = uiUtil.getConvertChildByName(item,"panel_card_frame")
	if not panel_card_frame then return end
	local heroId = nil
	local heroUid = nil

	local quality = 0
	if basicHeroInfo then 
		heroId = basicHeroInfo.heroid
		quality = basicHeroInfo.quality
	end

	if heroInfo then 
		heroUid = heroInfo.heroid_u
		heroId = heroInfo.heroid
	end
	local left_point_num = 0 -- TODOTK
	local icon_frame = panel_card_frame:getChildByTag(TAG_CARD_FRAME)

	if icon_frame then 
		cardFrameInterface.set_big_card_info(icon_frame, heroUid, heroId, false,left_point_num)

		if basicInfoOffset and basicInfoOffset.level then 
			cardFrameInterface.set_lv_images(basicInfoOffset.level,icon_frame)
		end
	else
		icon_frame = cardFrameInterface.create_big_card(heroUid,heroId,false,left_point_num)
		icon_frame:ignoreAnchorPointForPosition(false)
		icon_frame:setAnchorPoint(cc.p(0.5, 0.5))
	    panel_card_frame:addChild(icon_frame,0,TAG_CARD_FRAME)
	    icon_frame:setPosition(cc.p(panel_card_frame:getContentSize().width/2,panel_card_frame:getContentSize().height/2))
	    if basicInfoOffset and basicInfoOffset.level then 
			cardFrameInterface.set_lv_images(basicInfoOffset.level,icon_frame)
		end
	end
end

-- 体力信息
local function setPhysicalStrength(item,basicHeroInfo,heroInfo)
	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	
	local strengthCur = 1
	local strengthMax = HERO_ENERGY_MAX/10000

	if heroInfo then 
		strengthCur = heroData.getHeroEnergy(heroInfo.heroid_u)
   		strengthCur = math.floor(strengthCur/10000)
	end
	
	local bar_energy = uiUtil.getConvertChildByName(panel_info,"bar_energy")
	local progress_bar = uiUtil.getConvertChildByName(bar_energy,"progress_bar")
	local label_value_cur = uiUtil.getConvertChildByName(bar_energy,"label_value_cur")
	local label_value_split = uiUtil.getConvertChildByName(bar_energy,"label_value_split")
	local label_value_max = uiUtil.getConvertChildByName(bar_energy,"label_value_max")
	label_value_cur:setColor(ccc3(255,255,255))
	-- label_value_split:setColor(ccc3(255,195,111))
	-- label_value_max:setColor(ccc3(255,195,111))

	label_value_cur:setStringValue(strengthCur)
	label_value_max:setStringValue(strengthMax)

	if heroInfo then 
		label_value_cur:setVisible(true)
		label_value_max:setVisible(true)
		progress_bar:setPercent(math.floor(strengthCur*100/strengthMax) )
	else
		label_value_cur:setVisible(false)
		label_value_max:setVisible(false)
		progress_bar:setPercent(0)
	end
end

-- 体力介绍
local function setPhysicalStrengthIntro(item,basicHeroInfo,heroInfo)

end

-- 卡牌是否处于保护状态
local function setProtectState(item,basicHeroInfo,heroInfo,viewType)
	if not item then return end

	local imgProtectedState = uiUtil.getConvertChildByName(item,"imgProtectedState")
	local label_protectedState = uiUtil.getConvertChildByName(imgProtectedState,"label_protectedState")
	if not heroInfo then 
		imgProtectedState:setVisible(false)
		imgProtectedState:setTouchEnabled(false)
	else
		imgProtectedState:setVisible(true)
		imgProtectedState:setTouchEnabled(true)
		imgProtectedState:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				-- 发送的状态跟原先的状态相反
				local state = (heroInfo.lock_state == 1) and 0 or 1
				cardOpRequest.request_switch_card_protected_state(heroInfo.heroid_u,state)
			end
		end)

		if heroInfo.lock_state == 1 then 
			imgProtectedState:loadTexture(ResDefineUtil.New_unlock_Icon_n_2, UI_TEX_TYPE_PLIST)
			label_protectedState:setText(languagePack["cardProtectState_active"])
 			label_protectedState:setColor(ccc3(248,228,121))
		else
			imgProtectedState:loadTexture(ResDefineUtil.New_unlock_Icon_n, UI_TEX_TYPE_PLIST)
			label_protectedState:setText(languagePack["cardProtectState_passtive"])
 			label_protectedState:setColor(ccc3(171,171,171))
		end
	end

	if viewType == 4 then 
		imgProtectedState:setVisible(false)
		imgProtectedState:setTouchEnabled(false)
	end
end

-- 卡牌作者
local function setAuthor(item,basicHeroInfo,heroInfo)

end


-- 卡牌稀有度 以及进阶
local function setRareValue(item,basicHeroInfo,heroInfo,viewType,basicInfoOffset)
	if not item then return end

	local panel_card_frame = uiUtil.getConvertChildByName(item,"panel_card_frame")
	local img_max_advanced = uiUtil.getConvertChildByName(panel_card_frame,"img_max_advanced")
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	local btn_advance = uiUtil.getConvertChildByName(panel_info,"btn_advance")
	local img_advance_null = uiUtil.getConvertChildByName(item,"img_advance_null")
	btn_advance:setVisible(false)
	btn_advance:setTouchEnabled(false)
	img_advance_null:setVisible(false)
	img_max_advanced:setVisible(false)

	local cur_quality_lv = 0
	local max_quality_lv = basicHeroInfo.quality + 1

	if heroInfo then 
		cur_quality_lv = heroInfo.advance_num
	end

	local img_star = nil
	local pos_x = 110
	local pos_y = 438
	for i = 1,5 do 
		img_star = uiUtil.getConvertChildByName(panel_info,"img_star_" .. i)
		img_star:setVisible(true)
		img_star:setPosition(cc.p(pos_x + (i - 1) * 30,pos_y))
		if i <= max_quality_lv then 
			img_star:setVisible(true)
			if i <= cur_quality_lv then 
				img_star:loadTexture(ResDefineUtil.ui_card_star[2],UI_TEX_TYPE_PLIST)
			else
				img_star:loadTexture(ResDefineUtil.ui_card_star[3],UI_TEX_TYPE_PLIST)
			end
		else
			img_star:setVisible(false)
		end
	end

	local btn_advance = uiUtil.getConvertChildByName(panel_info,"btn_advance")
	if heroInfo then 
		btn_advance:setTouchEnabled(true)
		btn_advance:setVisible(true)

		local img_notice = uiUtil.getConvertChildByName(btn_advance,"img_notice")
		img_notice:setVisible(false)
		if cur_quality_lv < max_quality_lv then 
			-- 是否有同名卡
			for k,v in pairs(heroData.getAllHero()) do
				hero_info = heroData.getHeroInfo(k)
				if hero_info.heroid == heroInfo.heroid and (hero_info.heroid_u ~= heroInfo.heroid_u) then 
					img_notice:setVisible(true)
				end
			end
		end
	end

	-- 已进阶到最大阶数
	if cur_quality_lv >= max_quality_lv then 
		-- img_max_advanced:setVisible(true)
		btn_advance:setVisible(false)
		btn_advance:setTouchEnabled(false)
	end

	if viewType == 3 or viewType == 1 or viewType == 4 then 
		btn_advance:setVisible(false)
		btn_advance:setTouchEnabled(false)
	end

	-- -- 三星以下的不能进阶
	-- if basicHeroInfo.quality < HERO_ADVANCE_QUALITY_MIN then 
	-- 	btn_advance:setVisible(false)
	-- 	btn_advance:setTouchEnabled(false)
	-- 	img_max_advanced:setVisible(false)
	-- 	img_advance_null:setVisible(true)
	-- else
	-- 	img_advance_null:setVisible(false)
	-- end
	img_advance_null:setVisible(false)


	setCardFrame(item,basicHeroInfo,heroInfo,basicInfoOffset)

	local icon_frame = panel_card_frame:getChildByTag(TAG_CARD_FRAME)
	if heroInfo then 
		cardFrameInterface.setAdvancedDetail(icon_frame,heroInfo.heroid_u,heroInfo.heroid)
	else
		cardFrameInterface.setAdvancedDetail(icon_frame,nil,basicHeroInfo.heroid)
	end
	cardFrameInterface.showAdvacedMaxEffect(icon_frame)
end


-- 等级
local function setLevel(item,basicHeroInfo,heroInfo,basicInfoOffset)
	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	local label_level = uiUtil.getConvertChildByName(panel_info,"label_level")
	
	
	local levelCur = 1

	local expCur = 1
	local expMax = 1

	if heroInfo then 
		levelCur = heroInfo.level
		expCur = heroInfo.exp
		if Tb_cfg_hero_level[basicHeroInfo.quality*100 + heroInfo.level + 1] then
   			expMax = Tb_cfg_hero_level[basicHeroInfo.quality*100 + heroInfo.level + 1].exp
   		else
   			expMax = Tb_cfg_hero_level[basicHeroInfo.quality* 100 + heroInfo.level].exp
   		end

	else
		levelCur = 1

		if basicInfoOffset and basicInfoOffset.level then 
			levelCur = basicInfoOffset.level
		end
	end
	label_level:setText(levelCur)
	local bar_level = uiUtil.getConvertChildByName(panel_info,"bar_level")
	local progress_bar = uiUtil.getConvertChildByName(bar_level,"progress_bar")
	local label_value_cur = uiUtil.getConvertChildByName(bar_level,"label_value_cur")
	local label_value_split = uiUtil.getConvertChildByName(bar_level,"label_value_split")
	local label_value_max = uiUtil.getConvertChildByName(bar_level,"label_value_max")
	label_value_cur:setColor(ccc3(255,255,255))
	-- label_value_split:setColor(ccc3(255,195,111))
	-- label_value_max:setColor(ccc3(255,195,111))

	label_value_cur:setStringValue(expCur)
	label_value_max:setStringValue(expMax)

	
	if heroInfo then 
		label_value_cur:setVisible(true)
		label_value_max:setVisible(true)
		progress_bar:setPercent(math.floor(expCur*100/expMax) )
	else
		label_value_cur:setVisible(false)
		label_value_max:setVisible(false)
		progress_bar:setPercent(0)
	end

end

-- 经验值
local function setExp(item,basicHeroInfo,heroInfo)
	-- 在 setLevel 里了
end

-- 兵力
local function setSoldierNum(item,basicHeroInfo,heroInfo)

	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	

	local soldierCur = 1
	local soldierMax = 1

	if heroInfo then 
		soldierCur = heroInfo.hp
    	soldierMax = heroInfo.level * 100
		if heroInfo.armyid ~= 0 then
		    local own_city_id = math.floor(heroInfo.armyid/10)
		    local by_level = politics.getBuildLevel(own_city_id, cityBuildDefine.bingying)
		    if by_level ~= 0 then
		        soldierMax = soldierMax + Tb_cfg_build_cost[cityBuildDefine.bingying*100 + by_level].effect[1][2]
		    end
		end
	end
	
	local bar_soldier = uiUtil.getConvertChildByName(panel_info,"bar_soldier")
	local progress_bar = uiUtil.getConvertChildByName(bar_soldier,"progress_bar")
	local label_value_cur = uiUtil.getConvertChildByName(bar_soldier,"label_value_cur")
	local label_value_split = uiUtil.getConvertChildByName(bar_soldier,"label_value_split")
	local label_value_max = uiUtil.getConvertChildByName(bar_soldier,"label_value_max")
	label_value_cur:setColor(ccc3(255,255,255))
	-- label_value_split:setColor(ccc3(255,195,111))
	-- label_value_max:setColor(ccc3(255,195,111))

	label_value_cur:setStringValue(soldierCur)
	label_value_max:setStringValue(soldierMax)

	if heroInfo then 
		label_value_cur:setVisible(true)
		label_value_max:setVisible(true)
		progress_bar:setPercent(math.floor(soldierCur*100/soldierMax) )
	else
		label_value_cur:setVisible(false)
		label_value_max:setVisible(false)
		progress_bar:setPercent(0)
	end
end

-- 征兵时间
local function setConscriptCountDown(item,basicHeroInfo,heroInfo)

end


-- cost值
local function setCostValue(item,basicHeroInfo,heroInfo)
	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	
	local label_val_cost = uiUtil.getConvertChildByName(panel_info,"label_val_cost")
	local cost = basicHeroInfo.cost
	cost = cost/10
	label_val_cost:setText(cost)
end


-- 势力国家
local function setCountry(item,basicHeroInfo,heroInfo)

	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	
	local label_country = uiUtil.getConvertChildByName(panel_info,"label_country")

	label_country:setText(languagePack["countryName_" .. basicHeroInfo.country] )
end

-- 兵种
local function setSoldierType(item,basicHeroInfo,heroInfo)
	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	
	local img_solder_type = uiUtil.getConvertChildByName(panel_info,"img_solder_type")
	img_solder_type:loadTexture(ResDefineUtil.img_soldier_type[basicHeroInfo.hero_type],UI_TEX_TYPE_PLIST)

	local label_soldier_type = uiUtil.getConvertChildByName(panel_info,"label_soldier_type")
	-- 兵种 1：弓兵,2：枪兵,3：骑兵
	label_soldier_type:setText("（"  .. languagePack["heroTypeName_" .. basicHeroInfo.hero_type ] ..  "）")
end

-- 攻击距离
local function attackRange(item,basicHeroInfo,heroInfo)

	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	
	local label_val_attack_range = uiUtil.getConvertChildByName(panel_info,"label_val_attack_range")
	label_val_attack_range:setText(basicHeroInfo.hit_range)
end


local function grow_rate_val_to_string(val,decimalNum)
	val = tonumber(val)
	local integerTab,decimalTab = stringFunc.split_number_to_table(val)
	local ret_str = ""
	for i = 1,#integerTab do 
		ret_str = ret_str .. integerTab[i]
	end
	ret_str = ret_str .. '.'

	local tmp_decimal_num = decimalNum
	for i = 1,tmp_decimal_num do 
		if decimalTab[i] then 
			ret_str = ret_str .. decimalTab[i]
			decimalNum = decimalNum - 1
		end
	end

	for i = 1,decimalNum do 
		ret_str = ret_str .. '0'
	end

	return ret_str
end
-- 属性值
local function setProperty(item,basicHeroInfo,heroInfo,basicInfoOffset)
	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	
	local label_att_attack = uiUtil.getConvertChildByName(panel_info,"label_att_attack")
	local label_att_defense = uiUtil.getConvertChildByName(panel_info,"label_att_defense")
	local label_att_attack_city = uiUtil.getConvertChildByName(panel_info,"label_att_attack_city")
	local label_att_intel = uiUtil.getConvertChildByName(panel_info,"label_att_intel")
	local label_att_speed = uiUtil.getConvertChildByName(panel_info,"label_att_speed")


	local label_rate_attack = uiUtil.getConvertChildByName(panel_info,"label_rate_attack")
	local label_rate_defense = uiUtil.getConvertChildByName(panel_info,"label_rate_defense")
	local label_rate_attack_city = uiUtil.getConvertChildByName(panel_info,"label_rate_attack_city")
	local label_rate_intel = uiUtil.getConvertChildByName(panel_info,"label_rate_intel")
	local label_rate_speed = uiUtil.getConvertChildByName(panel_info,"label_rate_speed")


    -- 
    label_rate_attack:setText("(+" .. grow_rate_val_to_string( basicHeroInfo.attack_grow/100 ,2) .. ")")
    label_rate_intel:setText("(+" .. grow_rate_val_to_string( basicHeroInfo.intel_grow/100 ,2) .. ")")
    label_rate_defense:setText("(+" .. grow_rate_val_to_string( basicHeroInfo.defence_grow/100 ,2) .. ")")
    label_rate_speed:setText("(+" .. grow_rate_val_to_string( basicHeroInfo.speed_grow/100,2 ) .. ")")
    label_rate_attack_city:setText("(+" .. grow_rate_val_to_string( basicHeroInfo.destroy_grow/100 ,2) .. ")")


    local heroUid = 0
    local lv = 1
	-- 攻城力 
    local attck_strength = 0
	if heroInfo then
		heroUid = heroInfo.heroid_u 
		attck_strength = heroData.get_basic_prop_info(heroUid, basicHeroInfo.heroid, heroPorpDefine.destroy)
	else
		if basicInfoOffset and basicInfoOffset.level then lv = basicInfoOffset.level end
		attck_strength = heroData.get_basic_prop_info_by_lv(basicHeroInfo.heroid, heroPorpDefine.destroy,lv)
	end
	-- attck_strength = math.floor(attck_strength/100)
	label_att_attack_city:setText(math.floor(attck_strength))

	if heroInfo then 
		heroUid = heroInfo.heroid_u 
		label_att_attack:setText(math.floor(heroData.get_basic_prop_info(heroUid, basicHeroInfo.heroid, 1)))
		label_att_defense:setText(math.floor(heroData.get_basic_prop_info(heroUid, basicHeroInfo.heroid, 2)))
		label_att_intel:setText(math.floor(heroData.get_basic_prop_info(heroUid, basicHeroInfo.heroid, 3)))
		label_att_speed:setText(math.floor(heroData.get_basic_prop_info(heroUid, basicHeroInfo.heroid, 4)))
	else
		
		if basicInfoOffset and basicInfoOffset.level then lv = basicInfoOffset.level end
		label_att_attack:setText(math.floor(heroData.get_basic_prop_info_by_lv(basicHeroInfo.heroid, 1,lv)))
		label_att_defense:setText(math.floor(heroData.get_basic_prop_info_by_lv(basicHeroInfo.heroid, 2,lv)))
		label_att_intel:setText(math.floor(heroData.get_basic_prop_info_by_lv(basicHeroInfo.heroid, 3,lv)))
		label_att_speed:setText(math.floor(heroData.get_basic_prop_info_by_lv(basicHeroInfo.heroid, 4,lv)))
	end
end


-- 洗点配点入口
local function setPropertyCollocation(item,basicHeroInfo,heroInfo)
	if not item then return end
	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	
	local btn_washPoint = uiUtil.getConvertChildByName(panel_info,"btn_washPoint")
	local img_notice = uiUtil.getConvertChildByName(btn_washPoint,"img_notice")
	
	img_notice:setVisible(false)

	if heroInfo and heroInfo.point_left > 0 then 
		img_notice:setVisible(true)
	end


end


-- 技能转化入口
local function setSkillConversion(item,basicHeroInfo,heroInfo)
	
end



local function setSkillState(viewType,item,basicHeroInfo,heroInfo,indx,skillId,skillName,skillLevel,descColorType,opTye)


	local panel_skills = uiUtil.getConvertChildByName(item,"panel_skills")
	
	local skill_item = nil

	local img_type = nil
	local label_level = nil
	local label_desc = nil
	local img_learn = nil
	local img_notawaken = nil
	local img_lock = nil
	local img_bg_left = nil
	local img_bg_right = nil
	local img_typeBg = nil
	-- descColorType 1 正常 （255,243,195） 2 绿色 （147,197,115） 3 红色，（162,60,44）
	-- opTye 1 强化 2学习 3 觉醒

	skill_item = uiUtil.getConvertChildByName(panel_skills,"skill_item_" .. indx)
	label_level = uiUtil.getConvertChildByName(skill_item,"label_level")
	label_desc = uiUtil.getConvertChildByName(skill_item,"label_desc")
	img_learn = uiUtil.getConvertChildByName(skill_item,"img_learn")
	img_notawaken = uiUtil.getConvertChildByName(skill_item,"img_notawaken")
	img_lock = uiUtil.getConvertChildByName(skill_item,"img_lock")
	img_type = uiUtil.getConvertChildByName(skill_item,"img_type")
	img_typeBg = uiUtil.getConvertChildByName(skill_item,"img_typeBg")
	img_bg_left = uiUtil.getConvertChildByName(skill_item,"img_bg_left")
	img_bg_right = uiUtil.getConvertChildByName(skill_item,"img_bg_right")
	img_bg_left:setVisible(false)
	img_bg_right:setVisible(false)
	label_level:setVisible(false)
	label_desc:setVisible(false)
	img_learn:setVisible(false)
	img_notawaken:setVisible(false)
	img_lock:setVisible(false)



	if skillName then 
		label_desc:setText(skillName)
		label_desc:setVisible(true)
		if descColorType == 1 then 
			label_desc:setColor(ccc3(255,243,195))
		elseif descColorType == 2 then 
			label_desc:setColor(ccc3(147,197,115))
		elseif descColorType == 3 then 
			label_desc:setColor(ccc3(162,60,44))
		end
	end
	if skillLevel then 
		label_level:setText(languagePack["lv"] .. skillLevel)
		label_level:setVisible(true)
	end

	if not skillId then 
		img_lock:setVisible(true)
		if indx == 3 then 
			img_notawaken:setVisible(true)		
		end
	end


	-- 可学习
	if opTye == 2 then 
		img_learn:setVisible(true)
		
		-- label_btn_operator:setText("学习")
	end

	-- 可觉醒
	if opTye == 3 then 
		img_lock:setVisible(true)
	end

	if img_notawaken:isVisible() then 
		GraySprite.create(img_typeBg)
	else
		if img_lock:isVisible() then 
			GraySprite.create(img_typeBg)
		else
			GraySprite.create(img_typeBg,nil,true)
		end
	end
	
	
	
	local isOperateLock = false
	if viewType == 3 or viewType == 1 then 
		isOperateLock = true
	end

	-- 设置技能图标
   	if skillId and skillId >0 then 
   		local skill_info = Tb_cfg_skill[skillId]
   		local current_skill_type = skill_info.skill_type
   		-- 1 被动 2指挥  3战法 4追击
   		if current_skill_type >= 1 and current_skill_type <= 4 then 
	   		img_type:loadTexture(ResDefineUtil.ui_card_skill_typeA[current_skill_type],UI_TEX_TYPE_PLIST)
	   		img_typeBg:loadTexture(ResDefineUtil.ui_card_skill_typeD[current_skill_type],UI_TEX_TYPE_PLIST)
	   		img_bg_left:loadTexture(ResDefineUtil.ui_card_skill_typeC[current_skill_type],UI_TEX_TYPE_PLIST)
	   		img_bg_right:loadTexture(ResDefineUtil.ui_card_skill_typeC[current_skill_type],UI_TEX_TYPE_PLIST)
	   		img_bg_right:setFlipX(true)
	   	end
	   	img_bg_left:setVisible(true)
		img_bg_right:setVisible(true)
		GraySprite.create(img_type,nil,true)
   	else
   		GraySprite.create(img_type)
   	end



   	if opTye and opTye > 0 then 
   		skill_item:setTouchEnabled(true)
   		skill_item:addTouchEventListener(function(sender,eventType)
   			if eventType == TOUCH_EVENT_ENDED then 
   				
   				if opTye == 1 then 
   					-- 锁定操作的武将卡详情也能从这里进去 
   					local heroUid = nil
   					if heroInfo then 
   						heroUid = heroInfo.heroid_u
   					end
   					-- 如果heroUid不存在 技能详情的数据以 skillId 为准
   					require("game/skill/skill_detail")
   					local isEnemy = viewType == 4
   					
   					-- if viewType == 2 then 
   					-- 	if userCardViewer then 
   					-- 		userCardViewer.remove_self(true)
   					-- 	end
   					-- end
   					SkillDetail.create(SkillDetail.VIEW_TYPE_STRENGTH,nil,skillId,isOperateLock,heroUid,indx,isEnemy)
   				elseif opTye == 2 then
   					if not isOperateLock then  
   						-- if viewType == 2 then 
	   					-- 	if userCardViewer then 
	   					-- 		userCardViewer.remove_self(true)
	   					-- 	end
	   					-- end
   						require("game/skill/skill_overview")
   						SkillOverview.create(heroInfo.heroid_u,indx)
   					end
   				elseif opTye == 3 then 
   					if not isOperateLock then 
   						require("game/skill/skill_operate")
   						SkillOperate.create(SkillOperate.OP_TYPE_HERO_AWAKEN,nil, heroInfo.heroid_u)
   					end
   				end
   			end
   		end)
   	else
   		skill_item:setTouchEnabled(false)
   		if img_notawaken:isVisible() then 
			skill_item:setTouchEnabled(true)
			skill_item:addTouchEventListener(function(sender,eventType)
				if eventType == TOUCH_EVENT_ENDED then 
					-- TODOTK 收集中文
					
				    local contentTxt = "达到如下条件，消耗2张同星级武将卡进行觉醒：\n1.武将达到Lv.20\n2.初始战法达到Lv.10",
				    comAlertConfirm.setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_ONLY)
		    		comAlertConfirm.show("觉醒条件",contentTxt)
				end
			end)
		elseif img_lock:isVisible() then 
			skill_item:setTouchEnabled(true)
			skill_item:addTouchEventListener(function(sender,eventType)
				if eventType == TOUCH_EVENT_ENDED then 
					tipsLayer.create(languagePack["hero_second_skill_unopen_tips"])
				end
			end)
		end
   	end
end


local function checkSecondSkillEffect(item,heroId,heroUid,viewType,basicInfoOffset,needEffect)
	local heroInfo = heroData.getHeroInfo(heroUid)
	if heroInfo then 
		heroId = heroInfo.heroid
	end

    local basicHeroInfo = Tb_cfg_hero[heroId]

    local function callbackSet()
    	setSkillState(viewType,item,basicHeroInfo,heroInfo, 2,0,languagePack["hero_second_skill_able"],nil,2,2)
    end

    local hero_skill_list = heroData.getHeroSkillList(heroInfo.heroid_u)  or {}
	local skillId = nil
	local skillLv = nil
		

	local levelNeed = nil
	-- 第二个技能
	levelNeed = SKILL_UNLOCK_SECOND_HERO_LEVEL
	skillId = nil
	skillLv = nil

	if heroInfo.level >= levelNeed then 
		if hero_skill_list[2] then 
			skillId = hero_skill_list[2][1] 
			skillLv = hero_skill_list[2][2] 
		end
		if skillId and skillId > 0 then 
			-- 强化
			setSkillState(viewType,item,basicHeroInfo,heroInfo, 2,skillId,Tb_cfg_skill[skillId].name,skillLv,1,1)
		else
			-- 可学习
			if  heroInfo.second_skill_effect == 0 then
				local panel_skills = uiUtil.getConvertChildByName(item,"panel_skills")

				local skillItem = uiUtil.getConvertChildByName(panel_skills,"skill_item_2")
				local img_typeBg = uiUtil.getConvertChildByName(skillItem,"img_typeBg")
				playArmatureOnce("zhanfa_jiesuo",skillItem,img_typeBg:getPositionX(),img_typeBg:getPositionY(),nil,nil,0.8,callbackSet)
				Net.send(HERO_SHOW_SECOND_SKILL_EFFECT ,{heroInfo.heroid_u})
			else
				callbackSet()
			end
		end
	end
end

--TODOTK 中文字
-- 技能栏
local function setSkillInfo(item,basicHeroInfo,heroInfo,viewType,needEffect)
	if not item then return end

	local panel_skills = uiUtil.getConvertChildByName(item,"panel_skills")
	

	
	if basicHeroInfo then 
		setSkillState(viewType,item,basicHeroInfo,heroInfo,1,basicHeroInfo.skill_init,Tb_cfg_skill[basicHeroInfo.skill_init].name,1,1,1)
		setSkillState(viewType,item,basicHeroInfo,heroInfo,2,nil,languagePack["hero_second_skill_unable"],nil,3)
		setSkillState(viewType,item,basicHeroInfo,heroInfo,3,nil,languagePack["hero_third_skill_unable"],nil,3)
	end

	
	if heroInfo then
		local hero_skill_list = heroData.getHeroSkillList(heroInfo.heroid_u)  or {}
		local skillId = nil
		local skillLv = nil
   		-- 第一个
   		if hero_skill_list[1] then
   			skillId = hero_skill_list[1][1]
   			skillLv = hero_skill_list[1][2]
   			setSkillState(viewType,item,basicHeroInfo,heroInfo,1,skillId,Tb_cfg_skill[basicHeroInfo.skill_init].name,skillLv,1,1)
   		end


		local levelNeed = nil
		-- 第二个技能
		levelNeed = SKILL_UNLOCK_SECOND_HERO_LEVEL
		skillId = nil
		skillLv = nil

		if heroInfo.level >= levelNeed then 
			if hero_skill_list[2] then 
				skillId = hero_skill_list[2][1] 
				skillLv = hero_skill_list[2][2] 
			end
			if skillId and skillId > 0 then 
				-- 强化
				setSkillState(viewType,item,basicHeroInfo,heroInfo,2,skillId,Tb_cfg_skill[skillId].name,skillLv,1,1)
			else
				-- 可学习
				
				if heroInfo.second_skill_effect == 1 then
					setSkillState(viewType,item,basicHeroInfo,heroInfo, 2,0,languagePack["hero_second_skill_able"],nil,2,2)
				end
			end
		end



		-- 第三个技能
		levelNeed = SKILL_UNLOCK_THIRD_HERO_LEVEL
		skillId = nil
		skillLv = nil
		local originalSkillLv = hero_skill_list[1][2]
		if ((heroInfo.level >= levelNeed) and (originalSkillLv >= SKILL_UNLOCK_THIRD_ORIGINAL_SKILL_LEVEL)) or viewType == 4 then 

			if viewType == 4 then
				if hero_skill_list[3] then 
					skillId = hero_skill_list[3][1] 
					skillLv = hero_skill_list[3][2]
				end
				if skillId and skillId > 0 then 
					-- 强化
					setSkillState(viewType,item,basicHeroInfo,heroInfo,3,skillId,Tb_cfg_skill[skillId].name,skillLv,1,1)
				end
			else
				if hero_skill_list[3] then 
					skillId = hero_skill_list[3][1] 
					skillLv = hero_skill_list[3][2]
				end
				if skillId and skillId > 0 then 
					-- 强化
					setSkillState(viewType,item,basicHeroInfo,heroInfo,3,skillId,Tb_cfg_skill[skillId].name,skillLv,1,1)
				else
					if heroInfo.awake_state == 1 then 
						setSkillState(viewType,item,basicHeroInfo,heroInfo,3,0,languagePack["hero_second_skill_able"],nil,2,2)
					else
						setSkillState(viewType,item,basicHeroInfo,heroInfo,3,0,languagePack["hero_third_skill_able"],nil,2,3)
					end
				end
			end

		end		
	end
end
local function setTipsDetectPanelsAble(widget, isAble)
	if not widget then return end
	local panel_tips_touch = uiUtil.getConvertChildByName(widget,"panel_tips_touch")
	panel_tips_touch:setVisible(isAble)
	local img_attTips = uiUtil.getConvertChildByName(panel_tips_touch,"img_attTips")
	img_attTips:setVisible(false)
	local panel_touch = nil
	for i = 1,18 do 
		panel_touch = uiUtil.getConvertChildByName(panel_tips_touch,"touch_" .. i)
		panel_touch:setTouchEnabled(isAble)
		panel_touch:setBackGroundColorType(LAYOUT_COLOR_NONE)
	end
end



local function initTouchState(item,heroId,heroUid,viewType,isAllLock)
	if not item then return end

	local heroInfo = heroData.getHeroInfo(heroUid)
	if heroInfo then 
		heroId = heroInfo.heroid
	end

    local basicHeroInfo = Tb_cfg_hero[heroId]


	local finalAble = not isAllLock

	local panel_hero_intro = uiUtil.getConvertChildByName(item,"panel_hero_intro")
	local panel_card_frame = uiUtil.getConvertChildByName(item,"panel_card_frame")

	panel_card_frame:setTouchEnabled(true and finalAble)
	panel_hero_intro:setTouchEnabled(false and finalAble)
	local scrollView = uiUtil.getConvertChildByName(panel_hero_intro,"scrollView")
	scrollView:setTouchEnabled(false and finalAble)
	local scrollPanel = uiUtil.getConvertChildByName(scrollView,"main_panel")
	scrollPanel:setTouchEnabled(false and finalAble)



	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	local btn_washPoint = uiUtil.getConvertChildByName(panel_info,"btn_washPoint")
	
	if (not heroInfo) or (viewType == 3)  then 
		btn_washPoint:setVisible(false)
		btn_washPoint:setTouchEnabled(false)
	else
		btn_washPoint:setVisible(true)
		btn_washPoint:setTouchEnabled(true and finalAble)
	end

	-- local btn_heroTips = uiUtil.getConvertChildByName(panel_info,"btn_heroTips")
	-- btn_heroTips:setTouchEnabled(true and finalAble)

	local panel_skills = uiUtil.getConvertChildByName(item,"panel_skills")
	local btn_skill_detail = uiUtil.getConvertChildByName(panel_skills,"btn_skill_detail")
	btn_skill_detail:setTouchEnabled(true and finalAble)

	local skill_item = nil
	for i = 1,3 do 
		skill_item = uiUtil.getConvertChildByName(panel_skills,"skill_item_" .. i)
		skill_item:setTouchEnabled(false)
	end


	if viewType == 4 then 
		btn_washPoint:setTouchEnabled(false)
		btn_washPoint:setVisible(false)


		-- btn_heroTips:setVisible(false)
		-- btn_heroTips:setTouchEnabled(false)

		btn_skill_detail:setVisible(false)
		btn_skill_detail:setTouchEnabled(false)
	end

	setTipsDetectPanelsAble(item,true and finalAble)
end

--卡牌详情的初始化视图
local function initViewState(item)
	if not item then return end
	local panel_hero_intro = uiUtil.getConvertChildByName(item,"panel_hero_intro")
	local panel_card_frame = uiUtil.getConvertChildByName(item,"panel_card_frame")

	local posx = 118
	local posy = 76
	panel_card_frame:setVisible(true)	
	panel_hero_intro:setVisible(false)
	

	panel_card_frame:ignoreAnchorPointForPosition(false)
	panel_card_frame:setAnchorPoint(0.5,0.5)
	panel_card_frame:setPosition(cc.p(posx + panel_card_frame:getContentSize().width/2,posy + panel_card_frame:getContentSize().height/2))


	panel_hero_intro:ignoreAnchorPointForPosition(false)
	panel_hero_intro:setAnchorPoint(0.5,0.5)
	panel_hero_intro:setPosition(cc.p(posx + panel_hero_intro:getContentSize().width/2,posy + panel_hero_intro:getContentSize().height/2))
	

	run3DTurnAction(panel_hero_intro,panel_card_frame,nil,0)


	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	panel_info:setVisible(true)
	panel_info:setPositionX(0)
	require("game/cardDisplay/cardAddPoint")
	cardAddPoint.remove_self()


end


local heroAttTipsTab = {}
heroAttTipsTab[1] = languagePack["hero_float_att_tips_rarity"] 		
heroAttTipsTab[2] = languagePack["hero_float_att_tips_lv"] 			
heroAttTipsTab[3] = languagePack["hero_float_att_tips_soldier"] 	
heroAttTipsTab[4] = languagePack["hero_float_att_tips_energy"] 		
heroAttTipsTab[5] = languagePack["hero_float_att_tips_cost"] 		
heroAttTipsTab[6] = languagePack["hero_float_att_tips_forces"] 		
heroAttTipsTab[7] = languagePack["hero_float_att_tips_soldierType"] 
heroAttTipsTab[8] = languagePack["hero_float_att_tips_attackRange"] 

heroAttTipsTab[9] = languagePack["hero_float_att_tips_attack"] 		
heroAttTipsTab[13] = languagePack["hero_float_att_tips_defense"] 	
heroAttTipsTab[17] = languagePack["hero_float_att_tips_intel"] 		
heroAttTipsTab[15] = languagePack["hero_float_att_tips_speed"] 		
heroAttTipsTab[11] = languagePack["hero_float_att_tips_attackCity"] 

heroAttTipsTab[10] = languagePack["hero_float_att_tips_growRate"] 
heroAttTipsTab[12] = languagePack["hero_float_att_tips_growRate"] 	
heroAttTipsTab[14] = languagePack["hero_float_att_tips_growRate"] 	
heroAttTipsTab[16] = languagePack["hero_float_att_tips_growRate"] 	
heroAttTipsTab[18] = languagePack["hero_float_att_tips_growRate"] 	


local function setFloatAttTipsVisible(isVisible, item,tipsType,posx, posy,basicHeroInfo,heroInfo)
	if not item then return end

	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	local panel_tips_touch = uiUtil.getConvertChildByName(item,"panel_tips_touch")
	local img_attTips = uiUtil.getConvertChildByName(panel_tips_touch,"img_attTips")
	if not panel_info:isVisible() then 
		img_attTips:setVisible(false)
		return 
	end

	posx = posx - img_attTips:getSize().width/2
	
	img_attTips:setVisible(isVisible)

	if not isVisible then return end


	img_attTips:setPosition(cc.p(posx,posy))

	img_attTips:removeAllChildrenWithCleanup(true)

	local _richText = RichText:create()
    _richText:setVerticalSpace(1)
    _richText:setAnchorPoint(cc.p(0.5,0.5))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(260, 500))

	local re1 = RichElementText:create(tipsType, ccc3(255,213,110), 255, heroAttTipsTab[tipsType],config.getFontName(), 18)
    _richText:pushBackElement(re1)
    _richText:formatText()


    local viewHeight = _richText:getRealHeight()
    

    
    img_attTips:setSize(CCSizeMake(310,viewHeight + 60 ))

    _richText = RichText:create()
    _richText:setVerticalSpace(1)
    _richText:setAnchorPoint(cc.p(0.5,0.5))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(260, viewHeight))
    -- _richText:setPositionY(10)


    local index = 1
    local arg = {}
   	
   	if tipsType == 3 then 

   		local consume_res_list = {}
	    consume_res_list[resType.wood] = 0
	    consume_res_list[resType.stone] = 0
	    consume_res_list[resType.iron] = 0
	    consume_res_list[resType.food] = 0

	    for k,v in pairs(basicHeroInfo.recruit_cost) do
	        consume_res_list[v[1]] = consume_res_list[v[1]] + v[2]
	    end


   		arg = {consume_res_list[resType.wood],
   				consume_res_list[resType.iron],
   				consume_res_list[resType.food],
   				basicHeroInfo.food_cost}
   	end
    local str = heroAttTipsTab[tipsType]
    local tempStr = string.gsub(str, "&", function (n)
        temp = arg[index]
        index = index + 1
        return temp or "&"
    end)
    local tStr = config.richText_split(tempStr)

    local re1 = nil
    for i,v in ipairs(tStr) do
        if v[1] == 1 then
            re1 = RichElementText:create(i, ccc3(255,255,255), 255, v[2],config.getFontName(), 18)
        else
            re1 = RichElementText:create(i, ccc3(228,165,77), 255, v[2],config.getFontName(), 18)
        end
        _richText:pushBackElement(re1)
    end

    img_attTips:addChild(_richText)
end


local function ptinwidget(widget)
    local pt = widget:getTouchMovePos()
    tolua.cast(pt, "CCPoint") 
    return widget:hitTest(pt)
end


-- 添加触摸事件回掉
local function addTouchEvent(item,heroInfo,basicHeroInfo)
	if not item then return end
	local panel_card_frame = uiUtil.getConvertChildByName(item,"panel_card_frame")
	local panel_hero_intro = uiUtil.getConvertChildByName(item,"panel_hero_intro")
	local scrollView = uiUtil.getConvertChildByName(panel_hero_intro,"scrollView")
	local scrollPanel = uiUtil.getConvertChildByName(scrollView,"main_panel")



	local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
	local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")
	local btn_washPoint = uiUtil.getConvertChildByName(panel_info,"btn_washPoint")


	local function showHeroIntro()
		if not panel_info:isVisible() then return  end
		panel_card_frame:setTouchEnabled(false)
		run3DTurnAction(panel_card_frame,panel_hero_intro,function()
			panel_card_frame:setVisible(false)
			
			panel_hero_intro:setVisible(true)
			panel_hero_intro:setTouchEnabled(true)
			scrollView:setTouchEnabled(true)
			scrollPanel:setTouchEnabled(true)
		end)
	end

	local function showCardFrame()
		panel_hero_intro:setTouchEnabled(false)
		scrollView:setTouchEnabled(false)
		scrollPanel:setTouchEnabled(false)
		run3DTurnAction(panel_hero_intro,panel_card_frame,function()
			panel_card_frame:setVisible(true)
			panel_card_frame:setTouchEnabled(true)
			panel_hero_intro:setVisible(false)
		end)
	end
	panel_card_frame:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			showHeroIntro()
		end
	end)

	panel_hero_intro:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			showCardFrame()
		end
	end)

	local is_scrolling = false
	local last_offset_y = 0
	local img_drag_flag_down = uiUtil.getConvertChildByName(panel_hero_intro,"img_drag_flag_down")
	local img_drag_flag_up = uiUtil.getConvertChildByName(panel_hero_intro,"img_drag_flag_up")
	img_drag_flag_down:setVisible(false)
	img_drag_flag_up:setVisible(false)

	breathAnimUtil.start_scroll_dir_anim(img_drag_flag_up, img_drag_flag_down)
	local function ScrollViewEvent(sender, eventType) 
    	
		if math.abs(sender:getInnerContainer():getPositionY() - last_offset_y) > 1 then 
			is_scrolling = true
		end
		last_offset_y = sender:getInnerContainer():getPositionY()
    	if eventType == SCROLLVIEW_EVENT_SCROLL_TO_TOP then 
    		img_drag_flag_up:setVisible(false)
    		img_drag_flag_down:setVisible(true)
    	elseif eventType == SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM then 
    		img_drag_flag_up:setVisible(true)
    		img_drag_flag_down:setVisible(false)
    	elseif eventType == SCROLLVIEW_EVENT_SCROLLING then
    		if scrollView:getInnerContainer():getPositionY() > (-scrollPanel:getPositionY()) and 
				scrollView:getInnerContainer():getPositionY() < 0  then 
    			img_drag_flag_down:setVisible(true)
    			img_drag_flag_up:setVisible(true)
    		end
    	end
	end 

	scrollView:addEventListenerScrollView(ScrollViewEvent)


	scrollPanel:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			showCardFrame()
		end
	end)



	

	local switchWashPanelDuration = 0.2
	local function hideWashPoint()
		panel_info:setVisible(true)
		local actionMove = CCMoveTo:create(switchWashPanelDuration,ccp(0,panel_info:getPositionY()))
		local finally = cc.CallFunc:create(function ( )
	        panel_info:setVisible(true)
	    end)
		panel_info:runAction(animation.sequence({actionMove,finally}))

		setTipsDetectPanelsAble(item,true)
	end

	
	local function showWashPoint()
		if not heroInfo then return end
		require("game/cardDisplay/cardAddPoint")
		local parent = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
		cardAddPoint.showPointInfo(heroInfo.heroid_u,parent,hideWashPoint)

		local actionMove = CCMoveTo:create(switchWashPanelDuration,ccp(panel_info:getContentSize().width,panel_info:getPositionY()))
		local finally = cc.CallFunc:create(function ( )
	        panel_info:setVisible(false)
	        cardAddPoint.checkNonforceGuide()
	    end)
		panel_info:runAction(animation.sequence({actionMove,finally}))

		--[[
			切换到配点状态下时，始终显示武将大卡牌，点击后不显示列传信息；
			若在切换到配点状态前已显示列传，则点击配点后，需自动翻转到武将打卡牌
		]]
		if panel_hero_intro:isVisible() then 
			showCardFrame()
		end


		setTipsDetectPanelsAble(item,false)
	end


	

	---- 配点
	
	btn_washPoint:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			showWashPoint()
		end
	end)

	

	-- -- 成长值tips
	-- local btn_heroTips  = uiUtil.getConvertChildByName(panel_info,"btn_heroTips")
	-- btn_heroTips:addTouchEventListener(function(sender,eventType)
	-- 	if eventType == TOUCH_EVENT_ENDED then 
	-- 		local heroUid = 0
	-- 		local heroBid = 0
	-- 		if heroInfo then 
	-- 			heroUid = heroInfo.heroid_u
	-- 		end
	-- 		heroBid = basicHeroInfo.heroid
	-- 		require("game/cardDisplay/cardHeroGrowDetail")
	-- 		cardHeroGrowDetail.show(heroBid,heroUid)
	-- 	end
	-- end)

	local panel_skills = uiUtil.getConvertChildByName(item,"panel_skills")
	local btn_skill_detail = uiUtil.getConvertChildByName(panel_skills,"btn_skill_detail")
	btn_skill_detail:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 

			if basicHeroInfo.quality < SKILL_RESEARCH_QUALITY_MIN then 
				tipsLayer.create(languagePack["hero_can_teach_skill_tips"])
				return 
			end
			require("game/cardDisplay/cardTeachInfo")
			local hero_uid = 0
			if heroInfo then 
				hero_uid = heroInfo.heroid_u
			end
			cardTeachInfo.setShowInfo(basicHeroInfo.heroid)
		end
	end)
	local label_intro_a = uiUtil.getConvertChildByName(btn_skill_detail,"label_intro_a")
	local label_intro_b = uiUtil.getConvertChildByName(btn_skill_detail,"label_intro_b")
	if basicHeroInfo.quality < SKILL_RESEARCH_QUALITY_MIN then 
		btn_skill_detail:setBright(false)
		label_intro_a:setColor(ccc3(36,36,36))
		label_intro_b:setColor(ccc3(36,36,36))
	else
		
		btn_skill_detail:setBright(true)
		label_intro_a:setColor(ccc3(83,18,0))
		label_intro_b:setColor(ccc3(83,18,0))
	end
	-- 进阶
	local btn_advance = uiUtil.getConvertChildByName(panel_info,"btn_advance")
	btn_advance:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then 
			require("game/skill/skill_operate")
	   		SkillOperate.create(SkillOperate.OP_TYPE_HERO_ADVANCE,nil, heroInfo.heroid_u)
		end
	end)


	local panel_tips_touch = uiUtil.getConvertChildByName(item,"panel_tips_touch")
	
	for i = 1,18 do 
		local panel_touch = uiUtil.getConvertChildByName(panel_tips_touch,"touch_" .. i)
		local posy = panel_touch:getPositionY() + panel_touch:getContentSize().height /2
		local posx = panel_touch:getPositionX() 
		panel_touch:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				setFloatAttTipsVisible(false,item,i,posx,posy,basicHeroInfo,heroInfo)
			elseif eventType == TOUCH_EVENT_MOVED then
				local outofWidget = ptinwidget(sender)

				setFloatAttTipsVisible(outofWidget,item,i,posx,posy,basicHeroInfo,heroInfo)
			elseif eventType == TOUCH_EVENT_BEGAN then
				setFloatAttTipsVisible(true,item,i,posx,posy,basicHeroInfo,heroInfo)
			end
		end)
	end
end



local function updateInfo(item,heroId,heroUid,viewType,basicInfoOffset)
	if not item then return end
	local heroInfo = heroData.getHeroInfo(heroUid)
	if heroInfo then 
		heroId = heroInfo.heroid
	end

    local basicHeroInfo = Tb_cfg_hero[heroId]

    -- 体力信息
	setPhysicalStrength(item,basicHeroInfo,heroInfo)

	-- 卡牌是否处于保护状态
	setProtectState(item,basicHeroInfo,heroInfo,viewType)

	-- 卡牌稀有度 以及进阶
	setRareValue(item,basicHeroInfo,heroInfo,viewType,basicInfoOffset)

	-- 等级
	setLevel(item,basicHeroInfo,heroInfo,basicInfoOffset)

	-- 经验值
	setExp(item,basicHeroInfo,heroInfo)


	-- 兵力
	setSoldierNum(item,basicHeroInfo,heroInfo)

	-- 征兵时间
	setConscriptCountDown(item,basicHeroInfo,heroInfo)

	-- 属性值
	setProperty(item,basicHeroInfo,heroInfo,basicInfoOffset)

	-- 洗点配点入口
	setPropertyCollocation(item,basicHeroInfo,heroInfo)

	-- 技能转化入口
	setSkillConversion(item,basicHeroInfo,heroInfo)

	-- 技能栏
	setSkillInfo(item,basicHeroInfo,heroInfo,viewType,true)


	--
	require("game/cardDisplay/cardAddPoint")
	cardAddPoint.reload_data()
end
-- 加载数据
local function loadInfo(item,heroId,heroUid,viewType,basicInfoOffset)
	if not item then return end

	local heroInfo = heroData.getHeroInfo(heroUid)
	if heroInfo then 
		heroId = heroInfo.heroid
	end

    local basicHeroInfo = Tb_cfg_hero[heroId]

    -- 武将列传
	setHeroIntro(item,basicHeroInfo,heroInfo)

	-- 卡牌框信息
	setCardFrame(item,basicHeroInfo,heroInfo,basicInfoOffset)

	-- 体力介绍
	setPhysicalStrengthIntro(item,basicHeroInfo,heroInfo)

	-- 卡牌作者
	setAuthor(item,basicHeroInfo,heroInfo)

	-- cost值
	setCostValue(item,basicHeroInfo,heroInfo)


	-- 势力国家
	setCountry(item,basicHeroInfo,heroInfo)

	-- 兵种
	setSoldierType(item,basicHeroInfo,heroInfo)

	-- 攻击距离
	attackRange(item,basicHeroInfo,heroInfo)


	updateInfo(item,heroId,heroUid,viewType,basicInfoOffset)

	initViewState(item)
	initTouchState(item,heroId,heroUid,viewType,true)
	addTouchEvent(item,heroInfo,basicHeroInfo)
end


local function getSwitchItemBtns(item,isCleanup)
	if not isCleanup then isCleanup = false end
	local btn_left = uiUtil.getConvertChildByName(item,"btn_left")
	local btn_right = uiUtil.getConvertChildByName(item,"btn_right")
	local btn_close = uiUtil.getConvertChildByName(item,"btn_close")

	if btn_left then 
		btn_left:removeFromParentAndCleanup(isCleanup)
	end
	if btn_right then 
		btn_right:removeFromParentAndCleanup(isCleanup)
	end
	if btn_close then 
		btn_close:removeFromParentAndCleanup(isCleanup)
	end
	return btn_left,btn_right,btn_close
end


local function setSwitchItemBtnAble(item,isLeftAble,isRightAble)
	if not item then return end
	if not isLeftAble then isLeftAble = false end
	if not isRightAble then isRightAble = false end

	local btn_left = uiUtil.getConvertChildByName(item,"btn_left")
	local btn_right = uiUtil.getConvertChildByName(item,"btn_right")

	if btn_left then 
		btn_left:setVisible(isLeftAble)
		btn_left:setTouchEnabled(isLeftAble)
	end

	if btn_right then 
		btn_right:setVisible(isRightAble)
		btn_right:setTouchEnabled(isRightAble)
	end

end

local function registerSwitchItemHandler(item,leftHandler,rightHandler)
	if not item then return end
	local btn_left = uiUtil.getConvertChildByName(item,"btn_left")
	local btn_right = uiUtil.getConvertChildByName(item,"btn_right")
	if btn_left and (type(leftHandler) == "function") then 
		btn_left:addTouchEventListener(function(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				leftHandler()
			end
		end)			
	end

	if btn_right and (type(rightHandler) == "function") then 
		btn_right:addTouchEventListener(function(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				rightHandler()
			end
		end)	
	end
end







-- heroId，卡牌ID
-- heroUid, 卡牌唯一ID 有主的卡牌才有这个信息
local function createItem(heroId,heroUid)

	local heroInfo = heroData.getHeroInfo(heroUid)
	if heroInfo then 
		heroId = heroInfo.heroid
	end

    local basicHeroInfo = Tb_cfg_hero[heroId]

	local widget = GUIReader:shareReader():widgetFromJsonFile("test/wujikaxiangqing.json")

	setTipsDetectPanelsAble(widget,false)
	
	return widget
end


local function lockTouchState(item,heroId,heroUid,viewType)
	if not item then return end
	initTouchState(item,heroId,heroUid,viewType,true)
end

local function resetTouchState(item,heroId,heroUid,viewType,basicInfoOffset)

	local heroInfo = heroData.getHeroInfo(heroUid)
	if heroInfo then 
		heroId = heroInfo.heroid
	end

    local basicHeroInfo = Tb_cfg_hero[heroId]
    initTouchState(item,heroId,heroUid,viewType)
    addTouchEvent(item,heroInfo,basicHeroInfo)
    setLevel(item,basicHeroInfo,heroInfo,basicInfoOffset)
    setSoldierNum(item,basicHeroInfo,heroInfo)
    setPhysicalStrength(item,basicHeroInfo,heroInfo)

    setSkillInfo(item,basicHeroInfo,heroInfo,viewType)
end


 

-- 临时 技能觉醒特效
local function playSkillAwakenEffect(item,callback)
	if not item then return end
	local panel_skills = uiUtil.getConvertChildByName(item,"panel_skills")
	
	local skillItem = uiUtil.getConvertChildByName(panel_skills,"skill_item_3")
	local img_typeBg = uiUtil.getConvertChildByName(skillItem,"img_typeBg")
	playArmatureOnce("zhanfa_jiesuo",skillItem,img_typeBg:getPositionX(),img_typeBg:getPositionY(),nil,nil,0.8,callback)
end

-- 临时 技能学习成功特效
local function playSkillLearnedSkill(item,indx)
	if not item then return end

	local panel_skills = uiUtil.getConvertChildByName(item,"panel_skills")
	
	local skillItem = uiUtil.getConvertChildByName(panel_skills,"skill_item_" .. indx)
	local img_typeBg = uiUtil.getConvertChildByName(skillItem,"img_typeBg")
	playArmatureOnce("yanjiu",skillItem,img_typeBg:getPositionX(),img_typeBg:getPositionY(),nil,nil,0.8)
end

-- 技能进阶成功特效
-- jinjieshengji
-- jinjie
-- shuxing
local function playSkillAdvancedEffect(item,heroUid,callback)
	if not item then return end
	
	local panel_card_frame = uiUtil.getConvertChildByName(item,"panel_card_frame")
	if not panel_card_frame then return end
	playArmatureOnce("jinjieshengji",item,panel_card_frame:getPositionX() ,panel_card_frame:getPositionY() - panel_card_frame:getSize().height/2,0.5,0)
	playArmatureOnce("jinjie",item,panel_card_frame:getPositionX(),panel_card_frame:getPositionY() - panel_card_frame:getSize().height/2,0.5,0)

	
	
	local heroInfo = heroData.getHeroInfo(heroUid)

	local cur_quality_lv = nil
	local max_quality_lv = nil
	if heroInfo then
		local basicHeroInfo = Tb_cfg_hero[heroInfo.heroid]
		if not basicHeroInfo then return end

		max_quality_lv = basicHeroInfo.quality + 1

		
		cur_quality_lv = heroInfo.advance_num

	
		--[[
		local panel_info_and_washpoint = uiUtil.getConvertChildByName(item,"panel_info_and_washpoint")
		local panel_info = uiUtil.getConvertChildByName(panel_info_and_washpoint,"panel_info")

		for i = 1,5 do 
			img_star = uiUtil.getConvertChildByName(panel_info,"img_star_" .. i)
	
			if i == cur_quality_lv then 
				break
			end
		end

		if img_star then
			local pos_x = img_star:getPositionX()
			local pos_y = img_star:getPositionY() - img_star:getSize().height/2
			playArmatureOnce("jingjie_xingxing",img_star,-2,-4,0.5,0.5,nil,callback)
		else
			if callback then
				callback()
			end
		end
		]]
	else
		-- if callback then 
		-- 	callback()
		-- end
	end
	
	if cur_quality_lv then
		local icon_frame = panel_card_frame:getChildByTag(TAG_CARD_FRAME)
		cardFrameInterface.showAdvancedStarEffect(icon_frame,cur_quality_lv,max_quality_lv,callback)
	else
		if callback then
			callback()
		end
	end
end

-- 加点成功特效
local function playAddPointSucceedEffect(item)
	if not item then return end
	
	local panel_card_frame = uiUtil.getConvertChildByName(item,"panel_card_frame")
	if not panel_card_frame then return end
	playArmatureOnce("jinjieshengji",item,panel_card_frame:getPositionX(),panel_card_frame:getPositionY() - panel_card_frame:getSize().height/2,0.5,0)
	playArmatureOnce("shuxing",item,panel_card_frame:getPositionX(),panel_card_frame:getPositionY() - panel_card_frame:getSize().height/2,0.5,0)
end
local cardInfoItemIF = {
	createItem = createItem,
	resetTouchState = resetTouchState,
	lockTouchState = lockTouchState,
	loadInfo = loadInfo,
	updateInfo = updateInfo,
	registerSwitchItemHandler = registerSwitchItemHandler,
	setSwitchItemBtnAble = setSwitchItemBtnAble,
	getSwitchItemBtns = getSwitchItemBtns,
	playSkillAwakenEffect = playSkillAwakenEffect,
	playSkillLearnedSkill = playSkillLearnedSkill,
	playSkillAdvancedEffect = playSkillAdvancedEffect,
	playAddPointSucceedEffect = playAddPointSucceedEffect,
	checkSecondSkillEffect = checkSecondSkillEffect,
}


return cardInfoItemIF

