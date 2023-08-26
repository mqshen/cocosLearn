--任务界面
module("TaskUI", package.seeall)
require("game/task/taskData")
local m_pMainLayer = nil
local m_tableView = nil
local remove_callFunc = nil
local remove_timer = nil

local m_bOpenStateFinished = false

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local temp_widget = m_pMainLayer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function do_remove_self( )
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		m_tableView = nil
		TaskData.remove()
		
		uiManager.remove_self_panel(uiIndexDefine.TASK_UI)
		if remove_callFunc then
			remove_timer = scheduler.create(function ( )
				remove_callFunc()
				remove_callFunc = nil
				scheduler.remove(remove_timer)
				remove_timer = nil
			end,0)
		end
		m_bOpenStateFinished = false
	end
end

function remove_self()
    if not m_pMainLayer then return end
    if comGuideInfo then
		comGuideInfo.deal_with_guide_stop()
	end
    -- uiManager.hideScaleEffect(m_pMainLayer,999,do_remove_self,nil,0.85)
    uiManager.hideConfigEffect(uiIndexDefine.TASK_UI,m_pMainLayer,do_remove_self)
end

function get_com_guide_widget(temp_guide_id)
	if m_pMainLayer then
		return m_pMainLayer:getWidgetByTag(999)
	else
		return nil
	end
end

local function refreshCell( widget, idx)
	if not widget then return end
	local info = TaskData.getTaskInfoByIndex(idx+1)
	if not info then return end

	local p_PanelNormal = tolua.cast(widget:getChildByName("Panel_235482"),"Layout")
	p_PanelNormal:setVisible(false)
	local p_PanelSpecial = tolua.cast(widget:getChildByName("Panel_235483"),"Layout")
	p_PanelSpecial:setVisible(false)

	if info.special then
		p_PanelSpecial:setVisible(true)
		if info.special == 1 then
			tolua.cast(p_PanelSpecial:getChildByName("ImageView_235484"),"ImageView"):setVisible(true)
			tolua.cast(p_PanelSpecial:getChildByName("ImageView_235485"),"ImageView"):setVisible(false)
		else
			tolua.cast(p_PanelSpecial:getChildByName("ImageView_235484"),"ImageView"):setVisible(false)
			tolua.cast(p_PanelSpecial:getChildByName("ImageView_235485"),"ImageView"):setVisible(true)
		end
		return
	else
		p_PanelNormal:setVisible(true)
	end

	if info.isChoose then
		tolua.cast(p_PanelNormal:getChildByName("ImageView_62714"),"ImageView"):loadTexture(ResDefineUtil.not_reading_frame_y, UI_TEX_TYPE_PLIST)
	else
		tolua.cast(p_PanelNormal:getChildByName("ImageView_62714"),"ImageView"):loadTexture(ResDefineUtil.not_reading_frame_y_0, UI_TEX_TYPE_PLIST)
	end

	if info.is_completed == 1 then
		tolua.cast(p_PanelNormal:getChildByName("ImageView_60251_0"),"ImageView"):setVisible(true)
	else
		tolua.cast(p_PanelNormal:getChildByName("ImageView_60251_0"),"ImageView"):setVisible(false)
	end

	if Tb_cfg_task[info.task_id] then
		local task_title = tolua.cast(p_PanelNormal:getChildByName("Label_62715"),"Label")
		task_title:setText(Tb_cfg_task[info.task_id].task_name)
		if Tb_cfg_task[info.task_id].priority == 1 then
			task_title:setColor(ccc3(219,173,100))
		else
			task_title:setColor(ccc3(255,243,195))
		end
	end
end

local function jump(task_id )
	local x , y = math.floor(userData.getMainPos()/10000), userData.getMainPos()%10000
	local building_id = task_building_cfg[task_id].buiding_id
	remove_self()
	if mainBuildScene.isInCity() then
		if userData.getMainPos() == mainBuildScene.getThisCityid() then
			remove_callFunc = function ( )
				buildTreeManager.create(function ( )
					buildTreeManager.setBuildingBlink(building_id)
				end)
			end
		else
			remove_callFunc = function ( )
				mapMessageUI.enterCityDetailinfo(x,y)
				buildTreeManager.create(function ( )
					buildTreeManager.setBuildingBlink(building_id)
				end)
			end
		end
	else
		mapController.setOpenMessage(false)
		local temp_layer = CCLayer:create()
		temp_layer:setTouchEnabled(true)
		temp_layer:registerScriptTouchHandler(function (  )
			return true
		end,false,layerPriorityList.global_priority,true)
		cc.Director:getInstance():getRunningScene():addChild(temp_layer, 999, 999)

		mapController.locateCoordinate(x , y, function ( )
			mainOption.setSecondPanelVisible(false,false)
		    mainScene.setBtnsVisible(false)
		    ObjectManager.setObjectLayerVisible(2)
		    armyMark.setLineVisible(false)
			local function finally()
		        mapController.addSmokeAnimation()
		        newGuideInfo.enter_next_guide()
		    	mainBuildScene.create(x , y)
		        buildTreeManager.create(function ( )
					buildTreeManager.setBuildingBlink(building_id)
				end)
				temp_layer:removeFromParentAndCleanup(true)
		    end
		    mapController.setResVisible(false)
		    mapController.setCityShadow(true)
    		mapController.enterCity(x , y,finally)
			mapController.setOpenMessage(true)
		end)
	end
end

-- 出征跳转
local function cz_jump( )
	remove_self()
	local warFunc = function ( )
		local x,y = mapController.findLevelOne()
		if x and y then
			mapController.locateCoordinate(x,y,function ( )
				CCUserDefault:sharedUserDefault():setStringForKey("ID2001", "1")
				comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2003)
			end)
		end
	end
	if mainBuildScene.isInCity() then
		mainBuildScene.remove(true,warFunc )
	else
		warFunc()
	end
end

local function do_tax_jump()
	-- CCUserDefault:sharedUserDefault():setStringForKey(userData.getUserId().."ID2006", "1")
	comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2007)
	require("game/tax/taxUI")
	TaxUI.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2008)
end
	
-- 税收跳转
local function tax_jump()
	remove_self()
	
	if mainBuildScene.isInCity() then
		mainBuildScene.remove(true,do_tax_jump )
	else
		do_tax_jump()
	end
end

--预备兵征兵跳转
local function do_zb_jump()
	if not armyData.is_need_ybb_guide() then
		return
	end

	local temp_city_id = mainBuildScene.getThisCityid()
	for i=1,ARMY_MAX_NUMS_IN_CITY do
		local temp_army_id = temp_city_id * 10 + i
		if armyData.is_show_ybb_guide_for_army(temp_army_id) then
			comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2016)
			armyListInCityManager.enter_army_by_index(i)
			break
		end
	end
end

local function zb_jump()
	--因为这个操作涉及到打开新界面，所以要直接关闭
	do_remove_self()

	if mainBuildScene.isInCity() then
		do_zb_jump()
	else
		local main_city_id = userData.getMainPos()
		local coor_x = math.floor(main_city_id/10000)
		local coor_y = main_city_id%10000
		mapController.locateAndEnterCity(coor_x,coor_y,do_zb_jump)
	end
end

local function do_expand_building_jump()
	if buildingExpandTitle then 
		buildingExpandTitle.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2023)
	end
	comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2022)
end
local function expand_building_jump()
	remove_self()

	if mainBuildScene.isInCity() then 
		do_expand_building_jump()
	else
		local main_wid = userData.getMainPos()
		local coor_x = math.floor(main_wid / 10000)
		local coor_y = main_wid % 10000
		mapController.locateAndEnterCity(coor_x,coor_y,do_expand_building_jump)
	end
end

local function do_tansfer_skillValue_jump()

	comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2024)
	if SkillOverview then 
		SkillOverview.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2025)
	end
end

local function tansfer_skillValue_jump()
	remove_self()
	if mainBuildScene.isInCity() then
		mainBuildScene.remove(true,do_tansfer_skillValue_jump )
	else
		do_tansfer_skillValue_jump()
	end
end


local function study_new_skill_jump()
	do_remove_self()

	if SkillOverview then 
		SkillOverview.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2031)
		SkillOverview.create()
	end

end
local function study_skill_progress_jump()
	do_remove_self()
	if SkillOverview then 
		SkillOverview.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2034)
		SkillOverview.create()
	end
	CCUserDefault:sharedUserDefault():setBoolForKey("nonforce_guide_task_10504",true)
end
local function hero_learn_skill_jump()
	do_remove_self()
	-- 自动打开可进行学习操作的武将卡详情界面
	local ret_hero_id = nil
	local heroInfo = nil
	local hero_skill_list = nil
	for k,v in pairs(heroData.getAllHero()) do
		heroInfo = heroData.getHeroInfo(k)
		hero_skill_list = heroData.getHeroSkillList(heroInfo.heroid_u)  or {}
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
				-- pass
			else
				-- 可学习
				ret_hero_id = heroInfo.heroid_u
				break
			end
		end
	end

	if not ret_hero_id then return end

	require("game/cardDisplay/userCardViewer")
	userCardViewer.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2029)
	userCardViewer.create(nil,ret_hero_id)
	CCUserDefault:sharedUserDefault():setBoolForKey("nonforce_guide_task_10413",true)
end
local function strengthen_skill_jump()
	do_remove_self()
	local heroInfo = nil
	local ret_hero_id = nil
	local sec_ret_hero_id = nil
	for k,v in pairs(heroData.getAllHero()) do
		heroInfo = heroData.getHeroInfo(k)

		if heroInfo.heroid == 100042 then 
			if not ret_hero_id then 
				ret_hero_id = heroInfo.heroid_u
			else
				if heroInfo.armyid ~= 0 then 
					ret_hero_id = heroInfo.heroid_u
				end
			end
		end

		if heroInfo.armyid ~= 0 then 
			if not sec_ret_hero_id then 
				sec_ret_hero_id = heroInfo.heroid_u
			else
				local lastSecHeroInfo = heroData.getHeroInfo(sec_ret_hero_id)
				local lastBasicSecHeroInfo = Tb_cfg_hero[lastSecHeroInfo.heroid]
				local curBasicSecHeroInfo = Tb_cfg_hero[heroInfo.heroid]
				if curBasicSecHeroInfo.quality > lastBasicSecHeroInfo.quality then 
					sec_ret_hero_id = heroInfo.heroid_u
				elseif curBasicSecHeroInfo.quality == lastBasicSecHeroInfo.quality then
					if lastSecHeroInfo.level > heroInfo.level then 
						sec_ret_hero_id = heroInfo.heroid_u
					end
				end
			end
		end
	end

	if not ret_hero_id and not sec_ret_hero_id then 
		-- TODOTK 理论上不会出现这种情况 但是不排除极品玩家的操作  怎么整 ！！！！！！！！！
		return 
	end

	if not ret_hero_id then 
		ret_hero_id = sec_ret_hero_id 
	end

	require("game/cardDisplay/userCardViewer")
	userCardViewer.activeNonForceGuide(com_guide_id_list.CONST_GUIDE_2028)
	userCardViewer.create(nil,ret_hero_id)
	CCUserDefault:sharedUserDefault():setBoolForKey("nonforce_guide_task_10411",true)
end

local function exercise_jump()
	do_remove_self()

	if not mainBuildScene.isInCity() then
		comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2038)
	end
end

-- 非强制引导出现的条件
local function unForce_guide_display( idx )
	if not m_pMainLayer then
		return
	end
	local info = TaskData.getTaskInfoByIndex(idx+1)
	if not info then return end
	if info.is_completed == 0 and (
		(info.task_id == 10102 and CCUserDefault:sharedUserDefault():getStringForKey("ID2001") == "")
	 	or (info.task_id == 10104 and CCUserDefault:sharedUserDefault():getStringForKey("ID2006") == "") )  then
		if m_bOpenStateFinished then 
			comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2006)
		else
			comGuideManager.set_show_guide(com_guide_id_list.CONST_GUIDE_2001)
		end
		
	end
end

-- 非强制引导条件函数
local function unForce_guide_jump( idx )
	local info = TaskData.getTaskInfoByIndex(idx+1)
	if not info then return end
	if info.task_id == 10102 then
		cz_jump()
	elseif info.task_id == 10104 then 
		tax_jump()
	elseif info.task_id == 10302 then
		zb_jump()
	elseif info.task_id == 10305 then 
		expand_building_jump()
	elseif info.task_id == 10410 then 
		tansfer_skillValue_jump()
	elseif info.task_id == 10411 then 
		strengthen_skill_jump()
	elseif info.task_id == 10413 then 
		hero_learn_skill_jump()
	elseif info.task_id == 10503 then 
		study_new_skill_jump()
	elseif info.task_id == 10504 then 
		study_skill_progress_jump()
	elseif info.task_id == 10508 or info.task_id == 10509 then
		exercise_jump()
	end
end

local function isBuildingUpdateOrBuild( buiding_id )
	local build_info = nil
	local current_lv = 0
	
	-- for k,v in pairs(allTableData[dbTableDesList.user_city.name]) do
		build_info= politics.getBuildInfo(userData.getMainPos(), buiding_id)
		if build_info then
			current_lv = build_info.level
			if build_info.state == buildState.upgrade and current_lv ~= 0 then
				return 1,current_lv, build_info.end_time
			elseif build_info.state == buildState.upgrade and current_lv == 0 then
				return 2,nil,build_info.end_time
			end
		end
	-- end
	return false
end

local function refreshTaskDetail(idx )
	local info = TaskData.getTaskInfoByIndex(idx+1)
	local widget = m_pMainLayer:getWidgetByTag(999)
	local panel = tolua.cast(widget:getChildByName("Panel_86587"),"Layout")
	panel:removeAllChildren()
	local completeBtn = tolua.cast(widget:getChildByName("upgrade_btn"),"Button")
	completeBtn:setVisible(false)
	if not info or not widget or not Tb_cfg_task[info.task_id] then return end

	local richtextHeight = 120
    local count = math.floor(#Tb_cfg_task[info.task_id].condition_name/2) + #Tb_cfg_task[info.task_id].condition_name%2
	local reward_count = math.floor(#Tb_cfg_task[info.task_id].rewards/2) + #Tb_cfg_task[info.task_id].rewards%2
	local height = 35*4 + richtextHeight + count*27 + reward_count*35
	local size = panel:getContentSize()
	local layer = TouchGroup:create()
    layer:setContentSize(CCSize(size.width, height))
    local layerSize = layer:getContentSize()

    local offset = 10
    --任务名字
    local line = GUIReader:shareReader():widgetFromJsonFile("test/task_name.json")
    tolua.cast(line:getChildByName("Label_235480"),"Label"):setText(Tb_cfg_task[info.task_id].task_name)
    layer:addWidget(line)
    line:setAnchorPoint(cc.p(0,1))
    line:setPosition(cc.p(0,layerSize.height))

	--任务目标
	--50
	local lineTask = GUIReader:shareReader():widgetFromJsonFile("test/task_line.json")
    tolua.cast(lineTask:getChildByName("Label_58287_0_0"),"Label"):setText(languagePack["renwumubiao"])
    tolua.cast(lineTask:getChildByName("ImageView_86580"),"ImageView"):setVisible(false)
    layer:addWidget(lineTask)
    lineTask:setAnchorPoint(cc.p(0,1))
    lineTask:setPosition(cc.p(offset,line:getPositionY() - line:getContentSize().height))

    --任务条件
    for i = 1, #Tb_cfg_task[info.task_id].condition_name do
	    local conditionTask = GUIReader:shareReader():widgetFromJsonFile("test/task_condition.json")
	    layer:addWidget(conditionTask)
	    conditionTask:setAnchorPoint(cc.p(0,1))
	    local width = (i%2 == 0 and 1) or 0
	    conditionTask:setPosition(cc.p(offset+width*conditionTask:getContentSize().width,
	    	lineTask:getPositionY() - lineTask:getContentSize().height- (math.ceil(i/2)-1)*27 ))
	    local str = ""
	    local index = nil
		if #Tb_cfg_task[info.task_id].condition_name > 0 then
			index = stringFunc.lua_string_split(info.complete_amounts,";")
			if #index == 0 then
				for k = 1, #Tb_cfg_task[info.task_id].condition_name do
					table.insert(index, 0)
				end
			end
			str = index[i].."/"..Tb_cfg_task[info.task_id].amounts[i]
		end
	    local name = tolua.cast(conditionTask:getChildByName("Label_condition"),"Label")
	    name:setText(Tb_cfg_task[info.task_id].condition_name[i].."  "..str)

	    -- local updateBtn = tolua.cast(conditionTask:getChildByName("ImageView_upgrade"),"ImageView")
	    -- updateBtn:setPositionX(name:getPositionX()+name:getSize().width+updateBtn:getSize().width*0.5+10)
	    -- updateBtn:setVisible(false)
	    -- local buildingBtn = tolua.cast(conditionTask:getChildByName("ImageView_build"),"ImageView")
	    -- buildingBtn:setVisible(false)
	    -- buildingBtn:setPositionX(updateBtn:getPositionX())

	    -- if task_condition_cfg[info.task_id] then
	    -- 	local build_state = false
	    -- 	for k,m in pairs(task_condition_cfg[info.task_id].buiding_id[i]) do
	    -- 		if m then
	    -- 			build_state = isBuildingUpdateOrBuild( m )
	    -- 			if build_state then
	    -- 				updateBtn:setVisible(true)
	    -- 				local move = CCMoveBy:create(0.6, ccp(0,5))
	    -- 				local action = animation.sequence({move, move:reverse()})
	    -- 				updateBtn:runAction(CCRepeatForever:create(action))
	    -- 			end
	    -- 		end
	    -- 	end
	    -- end

	    if tonumber(index[i]) >= tonumber(Tb_cfg_task[info.task_id].amounts[i]) then
	    	-- name:setColor(ccc3(213,87,84))
	    	name:setColor(ccc3(255,255,255))
	    else
	    	name:setColor(ccc3(213,87,84))
	    	-- name:setColor(ccc3(255,255,255))
	    end
	end

    --任务描述
    local linedes = GUIReader:shareReader():widgetFromJsonFile("test/task_line.json")
    tolua.cast(linedes:getChildByName("Label_58287_0_0"),"Label"):setText(languagePack["renwumiaoshu"])
    layer:addWidget(linedes)
    linedes:setAnchorPoint(cc.p(0,1))
    linedes:setPosition(cc.p(offset,lineTask:getPositionY()-lineTask:getContentSize().height-27*count))

    local _richText = RichText:create()
	_richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(panel:getContentSize().width, richtextHeight))
    _richText:setAnchorPoint(cc.p(0,1))
    layer:addWidget(_richText)
    _richText:setPosition(cc.p(offset,linedes:getPositionY()-linedes:getContentSize().height))

    local tStr = stringFunc.anlayerOnespot(tostring(Tb_cfg_task[info.task_id].description), "@", false)
    local re
    for i,v in ipairs(tStr) do
    	if i%2 == 0 then
	    	re = RichElementText:create(1, ccc3(125,187,139), 255, v,config.getFontName(), 18)
		else
			re = RichElementText:create(1, ccc3(255,255,255), 255, v,config.getFontName(), 18)
		end
		_richText:pushBackElement(re)
	end

	--任务奖励
	--50
	local lineTask_reward = GUIReader:shareReader():widgetFromJsonFile("test/task_line.json")
    tolua.cast(lineTask_reward:getChildByName("Label_58287_0_0"),"Label"):setText(languagePack["renwujiangli"])
    layer:addWidget(lineTask_reward)
    lineTask_reward:setAnchorPoint(cc.p(0,1))
    lineTask_reward:setPosition(cc.p(offset,linedes:getPositionY()-linedes:getContentSize().height-richtextHeight))

    local item = nil
    local rewards = Tb_cfg_task[info.task_id].rewards
    
    local ColorUtil = require("game/utils/color_util")
    local function layoutReward(i,v)

        -- 同名卡
        if v[1] == 16 then 
            local hero_id = userData.getLastSameNameHero()
            v[1] = hero_id * 100 + 8
        end

        local width = (i%2 == 0 and 1) or 0
        item = GUIReader:shareReader():widgetFromJsonFile("test/task_item.json")
        if clientConfigData.getDorpName(v[1]) and clientConfigData.getDorpCount(v[1], v[2] ) then
        	if v[1]%100 == dropType.RES_ID_HERO then
        		tolua.cast(item:getChildByName("Label_86586"),"Label"):setText(ColorUtil.getHeroNameWriteByResIdU(v[1])..clientConfigData.getDorpCount(v[1], v[2] ))
        		tolua.cast(item:getChildByName("Label_86586"),"Label"):setColor(ColorUtil.getHeroColor(Tb_cfg_hero[math.floor(v[1]/100)].quality))
        	else
            	tolua.cast(item:getChildByName("Label_86586"),"Label"):setText(clientConfigData.getDorpName(v[1]).." "..clientConfigData.getDorpCount(v[1], v[2] ))
        	end
        else
            tolua.cast(item:getChildByName("Label_86586"),"Label"):setText("rewards are wrong!")
        end
        tolua.cast(item:getChildByName("wood_img_0_0"),"ImageView"):loadTexture(itemTextureName[v[1]%100],UI_TEX_TYPE_PLIST)
        item:setAnchorPoint(cc.p(0,1))
        layer:addWidget(item)
        item:setPosition(cc.p(offset+width*item:getContentSize().width,
        lineTask_reward:getPositionY() - lineTask_reward:getContentSize().height-(math.ceil(i/2)-1)*35 ))
    end
    local i = nil
	for i,v in ipairs(rewards) do
		layoutReward(i,v)
	end


	local scrollView = CCScrollView:create()
	local function scrollViewDidScrollChild( )
		if scrollView:getContentOffset().y < 0 then
            tolua.cast(widget:getChildByName("arrow_4"),"ImageView" ):setVisible(true)
        else
            tolua.cast(widget:getChildByName("arrow_4"),"ImageView" ):setVisible(false)
        end

        if scrollView:getContentSize().height + scrollView:getContentOffset().y > scrollView:getViewSize().height then
            tolua.cast(widget:getChildByName("arrow_3"),"ImageView" ):setVisible(true)
        else
            tolua.cast(widget:getChildByName("arrow_3"),"ImageView" ):setVisible(false)
        end
	end

	if nil ~= scrollView then
        scrollView:setViewSize(CCSizeMake(size.width,size.height))
        scrollView:setContainer(layer)
        scrollView:updateInset()
        scrollView:setDirection(kCCScrollViewDirectionVertical)
        scrollView:setClippingToBounds(true)
        scrollView:setBounceable(false)
        scrollView:registerScriptHandler(scrollViewDidScrollChild,CCScrollView.kScrollViewScroll)
        scrollView:setContentOffset(cc.p(0,-layerSize.height))
    end
    panel:addChild(scrollView)

	
	-- local str = tolua.cast(completeBtn:getChildByName("Label_235475"),"Label")
	local go_btn = tolua.cast(widget:getChildByName("Button_go"),"Button")
	go_btn:setVisible(false)
	go_btn:setTouchEnabled(false)

	local updateBtn = tolua.cast(widget:getChildByName("ImageView_upgrade"),"ImageView")
	updateBtn:setVisible(false)
	updateBtn:stopAllActions()
	updateBtn:setAnchorPoint(cc.p(0,0.5))
	updateBtn:setPositionY(118)

	local Label_building = tolua.cast(widget:getChildByName("Label_building"),"Label")
	Label_building:setVisible(false)

	local Label_temp = tolua.cast(widget:getChildByName("Label_temp"),"Label")
	Label_temp:setVisible(false)
	local Label_lv = tolua.cast(widget:getChildByName("Label_lv"),"Label")
	Label_lv:setVisible(false)
	local Label_descirb = tolua.cast(widget:getChildByName("Label_descirb"),"Label")
	Label_descirb:setVisible(false)
	--完成按钮
	if info.is_completed == 1 then
		completeBtn:setVisible(true)
		completeBtn:setTouchEnabled(true)
		-- str:setText(languagePack['wanchengrenwu'])
		completeBtn:addTouchEventListener(function (sender, eventType  )
			if eventType == TOUCH_EVENT_ENDED then
				TaskData.requestCompleteTask(info.task_id_u,info.task_id)
			end
		end)
	else
		completeBtn:setVisible(false)
		completeBtn:setTouchEnabled(false)
		unForce_guide_display( idx )
		if task_building_cfg[info.task_id] or unforce_guide_task_cfg[info.task_id] then
			go_btn:setVisible(true)
			go_btn:setTouchEnabled(true)

			for i = 1, #Tb_cfg_task[info.task_id].condition_name do

			    if task_condition_cfg[info.task_id] then
			    	local build_state = false
			    	local temp_current_lv = nil
			    	local end_time = nil
			    	for k,m in pairs(task_condition_cfg[info.task_id].buiding_id[i]) do
			    		if m then
			    			build_state, temp_current_lv, end_time = isBuildingUpdateOrBuild( m )
			    			if build_state then

			    				if build_state == 1 then
			    					Label_temp:setVisible(true)
									Label_lv:setVisible(true)
									Label_descirb:setVisible(true)
									Label_lv:setText("Lv."..temp_current_lv+1)

									local pos = go_btn:getPositionX() - (updateBtn:getSize().width+Label_temp:getSize().width + Label_lv:getSize().width + Label_descirb:getSize().width)/2
			    					updateBtn:setPositionX(pos)

			    					Label_temp:setPositionX(pos+updateBtn:getSize().width)
			    					Label_lv:setPositionX(Label_temp:getPositionX() + Label_temp:getSize().width)

									Label_descirb:setPositionX(Label_lv:getPositionX()+Label_lv:getSize().width)
			    				elseif build_state == 2 then
			    					Label_building:setVisible(true)

			    					local pos = go_btn:getPositionX() - (updateBtn:getSize().width+Label_building:getSize().width)/2

			    					updateBtn:setPositionX(pos)

			    					Label_building:setPositionX(pos+updateBtn:getSize().width)
			    				end

			    				updateBtn:runAction(animation.sequence({cc.DelayTime:create(end_time), cc.CallFunc:create(function ( )
			    					refreshTaskDetail(TaskData.getChooseTaskIndex()-1)
			    				end)}))
			    				updateBtn:setVisible(true)
			    				local move = CCMoveBy:create(0.6, ccp(0,5))
			    				local action = animation.sequence({move, move:reverse()})
			    				updateBtn:runAction(CCRepeatForever:create(action))
			    			end
			    		end
			    	end
			    end
			end
			
			-- str:setText(languagePack['qianwangjianzao'])
			go_btn:addTouchEventListener(function (sender, eventType  )
				if eventType == TOUCH_EVENT_ENDED then
					if unforce_guide_task_cfg[info.task_id] then
						unForce_guide_jump(idx)
					else
						jump(info.task_id)
					end
				end
			end)
		end
	end
end

local function cellSizeForTable(table,idx)
	local info = TaskData.getTaskInfoByIndex(idx+1)
	if info and info.special then
		return 33, 274
	else
    	return 58, 274
	end
end

local function tableCellTouched( tableView,cell )
	local idx = cell:getIdx()
	local info = TaskData.getTaskInfoByIndex(idx+1)
	if info and info.special then
		return
	end
	TaskData.setTaskChoose(idx+1)
	if tableView then
		for i=1 ,TaskData.getTaskNum() do
			local cell = tableView:cellAtIndex(i-1)
			if cell then
				local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
				if layer then
					local widget = layer:getWidgetByTag(1)
					if widget then
						refreshCell(widget, i-1)
					end
				end
			end
		end
		refreshTaskDetail(idx)
	end
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
    	cell = CCTableViewCell:new()
    	local layer = TouchGroup:create()
		local widget = GUIReader:shareReader():widgetFromJsonFile("test/task_cell.json")
	    tolua.cast(widget,"Layout")
	    layer:addWidget(widget)
	    widget:setTag(1)
	    cell:addChild(layer)
	    layer:setTag(123)
    end
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	local widget = layer:getWidgetByTag(1)
    	if widget then
    		refreshCell(widget, idx)
    	end
    end
	
    return cell
end

local function numberOfCellsInTableView(table)
	return TaskData.getTaskNum()
end

local function scrollViewDidScroll(table)
	local mWidget = m_pMainLayer:getWidgetByTag(999)
	if table:getContentOffset().y < 0 then
		tolua.cast(mWidget:getChildByName("arrow_2"),"ImageView" ):setVisible(true)
	else
		tolua.cast(mWidget:getChildByName("arrow_2"),"ImageView" ):setVisible(false)
	end

	if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
		tolua.cast(mWidget:getChildByName("arrow_1"),"ImageView" ):setVisible(true)
	else
		tolua.cast(mWidget:getChildByName("arrow_1"),"ImageView" ):setVisible(false)
	end
end

function taskChange( )
	if m_tableView then
		m_tableView:reloadData()
		refreshTaskDetail(TaskData.getChooseTaskIndex()-1)
	end
end

function create( )
	require("game/dbData/client_cfg/unforce_guide_task_cfg")
	require("game/dbData/client_cfg/task_building_cfg_info")
	require("game/dbData/client_cfg/task_condition_id")
	if m_pMainLayer then return end
	TaskData.initData()
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/task_interface.json")
	widget:setTag(999)
	widget:setAnchorPoint(cc.p(0.5,0.5))
	widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	m_pMainLayer = TouchGroup:create()
	widget:setScale(config.getgScale())
	m_pMainLayer:addWidget(widget)

	tolua.cast(widget:getChildByName("upgrade_btn"),"Button"):setTouchEnabled(false)
	tolua.cast(widget:getChildByName("upgrade_btn"),"Button"):setVisible(false)

	local arrow_1 = tolua.cast(widget:getChildByName("arrow_1"),"ImageView")
	arrow_1:setVisible(false)
	local arrow_2 = tolua.cast(widget:getChildByName("arrow_2"),"ImageView")
	arrow_2:setVisible(false)

	local arrow_3 = tolua.cast(widget:getChildByName("arrow_3"),"ImageView")
	arrow_3:setVisible(false)
	local arrow_4 = tolua.cast(widget:getChildByName("arrow_4"),"ImageView")
	arrow_4:setVisible(false)

	breathAnimUtil.start_anim(arrow_1, true, 76, 255, 1, 0)
	breathAnimUtil.start_anim(arrow_2, true, 76, 255, 1, 0)

	breathAnimUtil.start_anim(arrow_3, true, 76, 255, 1, 0)
	breathAnimUtil.start_anim(arrow_4, true, 76, 255, 1, 0)

	local panel = tolua.cast(widget:getChildByName("Panel_62712"),"Layout")
	m_tableView = CCTableView:create(CCSizeMake(panel:getContentSize().width,panel:getContentSize().height))
	panel:addChild(m_tableView)
	m_tableView:setDirection(kCCScrollViewDirectionVertical)
	m_tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	m_tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
	m_tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	m_tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	m_tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	m_tableView:reloadData()

	refreshTaskDetail(TaskData.getChooseTaskIndex()-1)
	-- refreshTaskDetail(1)
	local closeBtn = tolua.cast(widget:getChildByName("close_btn"),"Button")
	closeBtn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			remove_self()
		end
	end)
	m_bOpenStateFinished = false
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.TASK_UI,999)
	uiManager.showConfigEffect(uiIndexDefine.TASK_UI,m_pMainLayer,function()
		m_bOpenStateFinished = true
	end)
end

function get_com_guide_widget(temp_guide_id)
    if not m_pMainLayer then
        return nil
    end
    if temp_guide_id == com_guide_id_list.CONST_GUIDE_2001 then
        return  m_pMainLayer:getWidgetByTag(999)
    elseif temp_guide_id == com_guide_id_list.CONST_GUIDE_2006 then
        return  m_pMainLayer:getWidgetByTag(999)
    end
    return nil
end

