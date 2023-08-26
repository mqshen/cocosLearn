local team_confirm_layer = nil

local selected_army_id = nil
local warcoorX, warcoorY = nil, nil
local teamOp = 0
local m_bIsDecree = nil

local uiUtil = require("game/utils/ui_util")
local landDetailHelper = require("game/map/land_detail_helper")

local m_bFlagNewbieLimit = false -- 新手限制


local function do_remove_self()
	
	if team_confirm_layer then
		selected_army_id = nil
		warcoorX = nil
		warcoorY = nil

		team_confirm_layer:removeFromParentAndCleanup(true)
		team_confirm_layer = nil

		uiManager.remove_self_panel(uiIndexDefine.OP_ARMY_MOVE_CONFIRM)

		newGuideInfo.enter_next_guide()
		m_bIsDecree = nil

		m_bFlagNewbieLimit = false

		cardTextureManager.remove_cache()
	end

end

local function remove_self()
	if team_confirm_layer then
		
		uiManager.hideConfigEffect(uiIndexDefine.OP_ARMY_MOVE_CONFIRM, team_confirm_layer, do_remove_self)

	end
end

local function dealwithTouchEvent(x,y)
	if not team_confirm_layer then
		return false
	end

	local temp_widget = team_confirm_layer:getWidgetByTag(999)
	if temp_widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

local function deal_with_close_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then
		remove_self()
	end
end

local function doConfirmClick(teamOp,warcoorX,warcoorY,selected_army_id)
	if teamOp == armyOp.chuzheng or teamOp == armyOp.rake then
		armyOpRequest.requestBattle(warcoorX, warcoorY, selected_army_id)
	elseif teamOp == armyOp.farm then
		armyOpRequest.requestBattleDecree(warcoorX, warcoorY, selected_army_id)
	elseif teamOp == armyOp.training then 
		armyOpRequest.requestArmyTraining(warcoorX, warcoorY, selected_army_id)
	elseif teamOp == armyOp.yuanjun then
		-- 驻守
		armyOpRequest.requestYuanjun(warcoorX, warcoorY, selected_army_id)
	elseif teamOp == armyOp.zhuzha then
		-- 调动
		if armyData.isHasResidePosInFort(warcoorX * 10000 + warcoorY) then 
			armyOpRequest.requestZhuzha(warcoorX, warcoorY, selected_army_id)
		else
			tipsLayer.create(languagePack["errorContent_215"])
			-- tipsLayer.create(languagePack["errorContent_215"])
			-- tipsLayer.create(languagePack["errorContent_215"])
			return
		end
	end
	
	armyMoveManager.do_remove_self()
end
local function deal_with_confirm_click(sender, eventType)
	if eventType == TOUCH_EVENT_ENDED then

		local teamOp_t = teamOp
		local m_bIsDecree_t = m_bIsDecree
		local warcoorX_t = warcoorX
		local warcoorY_t = warcoorY
		local selected_army_id_t = selected_army_id
		local function doConfirm()
			doConfirmClick(teamOp_t,warcoorX_t,warcoorY_t,selected_army_id_t)
		end

		if m_bFlagNewbieLimit then 
			require("game/army/armyMove/opArmyMoveConfirmNewbie")
			opArmyMoveConfirmNewbie.create(doConfirm)
			remove_self()
			return 
		else
			doConfirm()
			remove_self()
		end
	end
end




local function create(new_army_id, select_city_id, new_dst_x, new_dst_y, new_op)
	if team_confirm_layer then
		return
	end

	local flag_enemy_too_strong = false
	selected_army_id = new_army_id
	warcoorX = new_dst_x
	warcoorY = new_dst_y
	teamOp = new_op
	
	m_bIsDecree = (new_op == armyOp.farm)

	local team_info = armyData.getTeamMsg(selected_army_id)
	if not team_info then
		return
	end
	

	local temp_widget = GUIReader:shareReader():widgetFromJsonFile("test/actionCheckUI.json")
	temp_widget:setTag(999)
	temp_widget:setScale(config.getgScale())
	temp_widget:ignoreAnchorPointForPosition(false)
	temp_widget:setAnchorPoint(cc.p(0.5,0.5))
	temp_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2 + 50 * config.getgScale()))


	local landType = landData.get_land_type(warcoorX*10000 + warcoorY)

	-- 关闭按钮
	local close_btn = uiUtil.getConvertChildByName(temp_widget,"close_btn")
	close_btn:setTouchEnabled(true)
	close_btn:addTouchEventListener(deal_with_close_click)


	local confirm_btn = uiUtil.getConvertChildByName(temp_widget,"confirm_btn")
	confirm_btn:setTouchEnabled(true)
	confirm_btn:addTouchEventListener(deal_with_confirm_click)

	------------  目标地信息
	local panel_target = uiUtil.getConvertChildByName(temp_widget,"panel_target")
	local img_flag = uiUtil.getConvertChildByName(panel_target,"img_flag")
	local label_target_info = uiUtil.getConvertChildByName(panel_target,"label_target_info")
	
	
	local ret_name, ret_lv = landData.get_city_name_lv_by_coordinate(warcoorX * 10000 + warcoorY)
	if landType == cityTypeDefine.player_chengqu then 
		nameLv = ret_name
	else
		if ret_lv then 
			nameLv = ret_name .. languagePack["lv"] .. ret_lv
		else
			nameLv = ret_name
		end
	end
	label_target_info:setText(nameLv .. "(" .. warcoorX .. "," .. warcoorY .. ")")
	label_target_info:setPositionX(panel_target:getSize().width/2)

	img_flag:setPositionX(label_target_info:getPositionX() - label_target_info:getSize().width/2 - 20)


	-- 出征详情
	local panel_detail = uiUtil.getConvertChildByName(temp_widget,"panel_detail")
	panel_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)

	--- 普通出征详情
	local detail_1 = uiUtil.getConvertChildByName(panel_detail,"detail_1")
	detail_1:setBackGroundColorType(LAYOUT_COLOR_NONE)
	-- 屯田才有的详情
	local detail_2 = uiUtil.getConvertChildByName(panel_detail,"detail_2")
	detail_2:setBackGroundColorType(LAYOUT_COLOR_NONE)
	-- 练兵的详情
	local detail_3 = uiUtil.getConvertChildByName(panel_detail,"detail_3")
	detail_3:setBackGroundColorType(LAYOUT_COLOR_NONE)

	local label_cost_energy = uiUtil.getConvertChildByName(detail_1,"label_cost_energy")
	
	if userData.isInNewBieProtection() then 
		label_cost_energy:setText(10)
	else
		label_cost_energy:setText(20)
	end
	
	-- 详情部分 自适应位置
	if teamOp == armyOp.farm then 
		detail_1:setVisible(true)
		detail_2:setVisible(true)
		detail_2:setPositionY(0)
		detail_1:setPositionY(detail_2:getPositionY() + detail_2:getSize().height)
		detail_3:setVisible(false)
	elseif teamOp == armyOp.training then 
		detail_2:setVisible(false)
		detail_1:setVisible(true)
		detail_3:setVisible(true)
		detail_3:setPositionY(0)
		detail_1:setPositionY(detail_3:getPositionY() + detail_3:getSize().height)
	else
		detail_1:setVisible(true)
		detail_2:setVisible(false)
		detail_3:setVisible(false)
		detail_1:setPositionY((panel_detail:getSize().height - detail_1:getSize().height)/2)
	end

	if teamOp == armyOp.chuzheng then 
		confirm_btn:setTitleText(languagePack["chuzheng"])
	elseif teamOp == armyOp.farm then
		confirm_btn:setTitleText(languagePack["tuntian"])
	elseif teamOp == armyOp.training then 
		confirm_btn:setTitleText(languagePack["training"])
	elseif teamOp == armyOp.rake then 
		confirm_btn:setTitleText(languagePack["saodang"])
	elseif teamOp == armyOp.yuanjun then 
		confirm_btn:setTitleText(languagePack["zhushou"])
	elseif teamOp == armyOp.zhuzha then
		confirm_btn:setTitleText(languagePack["diaodong"])
	else
		confirm_btn:setTitleText(languagePack["queren"])
	end
	-- 填充出征详情数据
	local move_dis, move_time = armyData.getMoveShowInfo(select_city_id, warcoorX*10000 + warcoorY, team_info.speed)
	if teamOp == armyOp.zhuzha then 
		move_time = math.floor(move_time * 100 / RESIDE_ACCELERATE)
	end

	-- 行军距离
	local dis_txt = uiUtil.getConvertChildByName(detail_1,"label_distance")
	local dis_txt_1 = uiUtil.getConvertChildByName(detail_1,"label_distance_1")

	-- NPC兵力对距离变化：
	local increaseCount = move_dis/NPC_FORCES_DISTANCE_PARAM
	if (teamOp == armyOp.chuzheng or teamOp == armyOp.rake) and increaseCount > 0.01 and not landData.is_type_npc_city(warcoorX*10000 + warcoorY) 
		and landType ~= cityTypeDefine.zhucheng
		and landType ~= cityTypeDefine.yaosai 
		and landType ~= cityTypeDefine.fencheng
		and landType ~= cityTypeDefine.player_chengqu
		and landType ~= cityTypeDefine.matou
		and landType ~= cityTypeDefine.npc_chengqu 
		and not GroundEventData.getWorldEventByWid(warcoorX*10000 + warcoorY ) 
		and not mapData.getValleyData()[warcoorX*10000 + warcoorY] then
		dis_txt:setText(string.format("%0.1f",move_dis))
		dis_txt_1:setVisible(true)
		dis_txt_1:setText("("..languagePack["dijunbingli"].."+"..math.floor(100*increaseCount).."%)")
		dis_txt_1:setPositionX(dis_txt:getPositionX() + dis_txt:getContentSize().width)
	else
		dis_txt:setText(string.format("%0.1f",move_dis))
		dis_txt_1:setVisible(false)
	end

	
	-- 行军时间
	local need_time_txt = uiUtil.getConvertChildByName(detail_1,"label_cost_time")

	need_time_txt:setText(commonFunc.format_time(move_time))
	-- 到达时间
	local arrive_time_txt = uiUtil.getConvertChildByName(detail_1,"label_end_time")
	arrive_time_txt:setText(commonFunc.format_date(userData.getServerTime() + move_time))
	local tips_panel = uiUtil.getConvertChildByName(temp_widget,"tips_panel")
	local tips_panel_1 = uiUtil.getConvertChildByName(tips_panel,"tips_panel_1")
	local tips_panel_2 = uiUtil.getConvertChildByName(tips_panel,"tips_panel_2")
	local tips_panel_3 = uiUtil.getConvertChildByName(tips_panel,"tips_panel_3")
	local tips_panel_4 = uiUtil.getConvertChildByName(tips_panel,"tips_panel_4")
	local tips_panel_5 = uiUtil.getConvertChildByName(tips_panel,"tips_panel_5")
	local tips_panel_6 = uiUtil.getConvertChildByName(tips_panel,"tips_panel_6")
	tips_panel_1:setVisible(false)
	tips_panel_2:setVisible(false)
	tips_panel_3:setVisible(false)
	tips_panel_4:setVisible(false)
	tips_panel_5:setVisible(false)
	tips_panel_6:setVisible(false)

	tips_panel:setBackGroundColorType(LAYOUT_COLOR_NONE)
	tips_panel_1:setBackGroundColorType(LAYOUT_COLOR_NONE)
	tips_panel_2:setBackGroundColorType(LAYOUT_COLOR_NONE)
	tips_panel_3:setBackGroundColorType(LAYOUT_COLOR_NONE)
	tips_panel_4:setBackGroundColorType(LAYOUT_COLOR_NONE)
	tips_panel_5:setBackGroundColorType(LAYOUT_COLOR_NONE)
	tips_panel_6:setBackGroundColorType(LAYOUT_COLOR_NONE)


	local diff_txt = uiUtil.getConvertChildByName(tips_panel_1,"diff_label")
	if teamOp == armyOp.chuzheng or teamOp == armyOp.rake then
		local res_level = math.floor(resourceData.resourceLevel(new_dst_x, new_dst_y)/10)
		local army_fight_power = armyData.getTeamFightPower(selected_army_id)
		local cmp_param = (landFightPower[res_level][1] + landFightPower[res_level][2]*(1+move_dis/NPC_FORCES_DISTANCE_PARAM)) /army_fight_power
		-- local cmp_param = (landFightPower[res_level][1] + landFightPower[res_level][2]*(1+move_dis * NPC_FORCES_DISTANCE_PARAM)) /army_fight_power
		
		local diff_value = commonFunc.get_sequene_range_in_list(cmp_param, fightPowerCMP)
		-- if userData.isInNewBieProtection() then 
		-- 	if landType == cityTypeDefine.player_chengqu then 
		-- 		diff_value = 2
		-- 	end
		-- end

		--地表事件
		local event = GroundEventData.getWorldEventByWid(warcoorX*10000 + warcoorY )
        if event then
        	if event[1] == GROUND.FIELD_EVENT_THIEF then
        		diff_txt:setColor(ccc3(fightPowerEstimate[12][1], fightPowerEstimate[12][2], fightPowerEstimate[12][3]))
	        	diff_txt:setText(fightPowerEstimate[12][4])
        	else
	        	diff_txt:setColor(ccc3(fightPowerEstimate[5][1], fightPowerEstimate[5][2], fightPowerEstimate[5][3]))
	        	diff_txt:setText(fightPowerEstimate[5][4])
	        end
	        tips_panel_1:setVisible(true)
        else
        	diff_txt:setColor(ccc3(fightPowerEstimate[diff_value][1], fightPowerEstimate[diff_value][2], fightPowerEstimate[diff_value][3]))
			diff_txt:setText(fightPowerEstimate[diff_value][4])
			tips_panel_3:setVisible(true)
			local img_tips = uiUtil.getConvertChildByName(tips_panel_3,"img_tips")
			if diff_value == 4 then 
				flag_enemy_too_strong = true
			end
			img_tips:loadTexture(ResDefineUtil.ui_army_move_tips_img[diff_value],UI_TEX_TYPE_PLIST)
        end
    elseif teamOp == armyOp.farm then 
    	local label_cost_decree = uiUtil.getConvertChildByName(detail_2,"label_cost_decree")
    	label_cost_decree:setText(FARM_DECREE_DEDUCT)
	elseif teamOp == armyOp.training then 
		tips_panel_5:setVisible(true)
		local label_exp = uiUtil.getConvertChildByName(tips_panel_5,"label_exp")
		label_exp:setText(armyData.getArmyTrainingProfit(warcoorX,warcoorY,selected_army_id))
		local label_cost_decree = uiUtil.getConvertChildByName(detail_3,"label_cost_decree")
		label_cost_decree:setText(TRAINING_DECREE_DEDUCT  )

		local label_cost_time = uiUtil.getConvertChildByName(detail_3,"label_cost_time")
		label_cost_time:setText(commonFunc.format_time(TRAINING_TIME) )


		local btn_tips = uiUtil.getConvertChildByName(detail_3,"btn_tips")
		btn_tips:setTouchEnabled(true)
		btn_tips:setVisible(true)
		btn_tips:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				alertLayer.create( errorTable[2015] )
			end
		end)
	elseif teamOp == armyOp.yuanjun then
		diff_txt:setColor(ccc3(125, 187, 139))
		diff_txt:setText(languagePack["diaodong_tips"])
		tips_panel_1:setVisible(true)
	elseif teamOp == armyOp.zhuzha then
		diff_txt:setColor(ccc3(125, 187, 139))
		diff_txt:setText(languagePack["zhuzha_tips"])
		tips_panel_1:setVisible(true)
	else
		diff_txt:setVisible(false)
	end

	--[[
		对
		NPC城市、
		NPC城区
		*敌方*玩家的领地（包括城市、要塞、领地）
		野外建筑出征时的战力评价统一写成“敌情难测，请斟酌行事”（字体颜色：fdd75c）；
	]]	
	
	if landData.is_type_npc_city(warcoorX*10000 + warcoorY) 
		or landType == cityTypeDefine.npc_yaosai
		or landType == cityTypeDefine.npc_chengqu 
		or 
		(landData.isLandOwnByEnemy(warcoorX*10000 + warcoorY)   
			and
		 	(landType == cityTypeDefine.zhucheng or 
		  	 landType == cityTypeDefine.yaosai or 
			 landType == cityTypeDefine.lingdi or 
			 landType == cityTypeDefine.fencheng or
			 landType == cityTypeDefine.player_chengqu or
			 landType == cityTypeDefine.matou or
			 landType == cityTypeDefine.npc_chengqu )
		 )
		then 
		tips_panel_1:setVisible(true)
		tips_panel_3:setVisible(false)
		diff_txt = uiUtil.getConvertChildByName(tips_panel_1,"diff_label")
		diff_txt:setColor(ccc3(fightPowerEstimate[8][1], fightPowerEstimate[8][2], fightPowerEstimate[8][3]))
        diff_txt:setText(fightPowerEstimate[8][4])
	end 
	-- 针对土地 校验玩家领地数是否达到上限
	local is_land_num_max = landData.is_type_assailable_land(warcoorX*10000 + warcoorY) and userData.isRunOutofTzl() and not landData.own_land(warcoorX*10000 + warcoorY) 
	if is_land_num_max then
		tips_panel_2:setVisible(true)
		diff_txt = uiUtil.getConvertChildByName(tips_panel_2,"diff_label")
		diff_txt:setColor(ccc3(fightPowerEstimate[6][1], fightPowerEstimate[6][2], fightPowerEstimate[6][3]))
        diff_txt:setText(fightPowerEstimate[6][4])
    end

    --当玩家处于沦陷状态，攻击其它玩家主城时提示不能附属，显示“处于沦陷状态，无法附属攻击目标”的提示 
-- 当玩家处于沦陷状态，攻击同盟目标（首府、州府、城池、关卡）时提示不能附属，显示“处于沦陷状态，无法附属攻击目标”的提示
    if userData.getAffilated_union_id() ~= 0 and (landData.is_type_main_city(warcoorX*10000 + warcoorY) or landData.is_type_npc_city(warcoorX*10000 + warcoorY)) then
    	tips_panel_2:setVisible(true)
		diff_txt = uiUtil.getConvertChildByName(tips_panel_2,"diff_label")
		diff_txt:setColor(ccc3(fightPowerEstimate[9][1], fightPowerEstimate[9][2], fightPowerEstimate[9][3]))
        diff_txt:setText(fightPowerEstimate[9][4])
    end

    -- 针对主城 校验是否处于在野状态 攻击主城
    if userData.getUnion_id() == 0 and landData.is_type_main_city( warcoorX*10000 + warcoorY )  then 
    	tips_panel_2:setVisible(true)
		diff_txt = uiUtil.getConvertChildByName(tips_panel_2,"diff_label")
		diff_txt:setColor(ccc3(fightPowerEstimate[7][1], fightPowerEstimate[7][2], fightPowerEstimate[7][3]))
        diff_txt:setText(fightPowerEstimate[7][4])
    end 

    -- 针对主城 校验是否处于在野状态 攻击npc城
    if userData.getUnion_id() == 0 and landData.is_type_npc_city( warcoorX*10000 + warcoorY )  then 
    	tips_panel_2:setVisible(true)
		diff_txt = uiUtil.getConvertChildByName(tips_panel_2,"diff_label")
		diff_txt:setColor(ccc3(fightPowerEstimate[10][1], fightPowerEstimate[10][2], fightPowerEstimate[10][3]))
        diff_txt:setText(fightPowerEstimate[10][4])
    end

    --当玩家攻击的无主或敌对目标处于免战，显示“目标处于免战状态，无法进行攻击”的提示 
-- 出征玩家自己的土地，不提示
  --   if landData.is_type_can_not_war(warcoorX*10000 + warcoorY) then
  --   	tips_panel_2:setVisible(true)
		-- diff_txt = uiUtil.getConvertChildByName(tips_panel_2,"diff_label")
		-- diff_txt:setColor(ccc3(fightPowerEstimate[11][1], fightPowerEstimate[11][2], fightPowerEstimate[11][3]))
  --       diff_txt:setText(fightPowerEstimate[11][4])
  --   end

  	local tips_width = 0
  	local posX = 0

  	local img_flag = uiUtil.getConvertChildByName(tips_panel_1,"img_flag")
  	local diff_label = uiUtil.getConvertChildByName(tips_panel_1,"diff_label")
  	tips_width = img_flag:getContentSize().width + 5 + diff_label:getContentSize().width
  	posX = (tips_panel:getContentSize().width - tips_width)/2
  	img_flag:setPositionX(posX)
  	diff_label:setPositionX(posX + img_flag:getContentSize().width + 5)

  	img_flag = uiUtil.getConvertChildByName(tips_panel_2,"img_flag")
  	diff_label = uiUtil.getConvertChildByName(tips_panel_2,"diff_label")
  	tips_width = img_flag:getContentSize().width + 5 + diff_label:getContentSize().width
  	posX = (tips_panel:getContentSize().width - tips_width)/2
  	img_flag:setPositionX(posX)
  	diff_label:setPositionX(posX + img_flag:getContentSize().width + 5)


  	img_flag = uiUtil.getConvertChildByName(tips_panel_3,"img_flag")
  	local img_tips = uiUtil.getConvertChildByName(tips_panel_3,"img_tips")
  	tips_width = img_flag:getContentSize().width + 5 + img_tips:getContentSize().width
  	posX = (tips_panel:getContentSize().width - tips_width)/2
  	img_flag:setPositionX(posX)
  	img_tips:setPositionX(posX + img_flag:getContentSize().width + 5)


    if tips_panel_2:isVisible() then 
    	tips_panel_2:setPosition(cc.p(0,0))
    	tips_panel_1:setPosition(cc.p(0,tips_panel_2:getContentSize().height))
    	tips_panel_3:setPosition(cc.p(0,tips_panel_3:getContentSize().height))
    else
    	tips_panel_1:setPosition(cc.p(0,(tips_panel:getContentSize().height - tips_panel_1:getContentSize().height)/2 ))
    	tips_panel_3:setPosition(cc.p(0,(tips_panel:getContentSize().height - tips_panel_3:getContentSize().height)/2 ))
    end

    

    local btn_tips = uiUtil.getConvertChildByName(detail_2,"btn_tips")
	btn_tips:setTouchEnabled(false)
	if teamOp == armyOp.farm then 
		tips_panel_1:setVisible(false)
		tips_panel_2:setVisible(false)
		tips_panel_3:setVisible(false)
		tips_panel_4:setVisible(true)
		

		tips_panel_4:setPosition(cc.p(0,(tips_panel:getContentSize().height - tips_panel_4:getContentSize().height)/2 ))

		--/** 屯田时间公式 屯田时间=1800秒-（部队总兵力-100）/100*60秒 */
		local label_cost_time = uiUtil.getConvertChildByName(detail_2,"label_cost_time")
		local cost_time = 1800 - (armyData.getTeamHp(selected_army_id) - 100) / 100 * 60
		if cost_time < 60 then cost_time = 60 end
		cost_time = math.floor(cost_time)
		
		label_cost_time:setText(commonFunc.format_time(cost_time))
		
		
		--屯田收益 -- 根据收益类型 居中自适应 
		-- tips_panel_4	

		local resProfit = armyData.getArmyDecreeProfit(warcoorX,warcoorY,selected_army_id)
		local label_res = nil
		for k,v in ipairs(resProfit) do 
			label_res = uiUtil.getConvertChildByName(tips_panel_4,"label_res_" .. k)
			if label_res then 
				label_res:setText(v)
			end
		end
		btn_tips:setTouchEnabled(true)
		btn_tips:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				-- TODOTK 提示配置
				local contentTxt = "屯田收益：随土地等级提高而提高，同时能从周围的领地获得15%的收益\n\n屯田时间：30分钟，增加部队兵力可以缩短时间"
			    comAlertConfirm.setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_ONLY)
			    comAlertConfirm.show(languagePack["tuntian"],contentTxt)
			end
		end)
		
		
	end


	

	-- 新手保护提示
	local label_newbie_protect_tips = uiUtil.getConvertChildByName(temp_widget,"label_newbie_protect_tips")
	label_newbie_protect_tips:setVisible(false)
	if not m_bIsDecree and userData.isNewBieTaskFinished() and userData.isInNewBieProtection() and flag_enemy_too_strong then 
		-- label_newbie_protect_tips:setVisible(true)
		-- confirm_btn:setVisible(false)
		-- confirm_btn:setTouchEnabled(false)

		m_bFlagNewbieLimit = true
	else
		m_bFlagNewbieLimit = false
		-- label_newbie_protect_tips:setVisible(false)
		-- confirm_btn:setVisible(true)
		-- confirm_btn:setTouchEnabled(true)
	end

	-- 新手期引导 出征 玩家城区(无主) 统一显示 
	if (teamOp == armyOp.chuzheng or teamOp == armyOp.rake)
		
		and not userData.isNewBieTaskFinished() 
		and userData.isInNewBieProtection()  
		and not landData.own_land(warcoorX*10000 + warcoorY) then 
		if landType == cityTypeDefine.player_chengqu then 
			-- diff_txt:setColor(ccc3(fightPowerEstimate[1][1], fightPowerEstimate[1][2], fightPowerEstimate[1][3]))
	        -- diff_txt:setText(fightPowerEstimate[1][4])
	        tips_panel_1:setVisible(false)
	        tips_panel_2:setVisible(false)
			tips_panel_3:setVisible(true)
			tips_panel_4:setVisible(false)

			local img_tips = uiUtil.getConvertChildByName(tips_panel_3,"img_tips")
			img_tips:loadTexture(ResDefineUtil.ui_army_move_tips_img[1],UI_TEX_TYPE_PLIST)

		end
	end

	-- 对战力评估提示的美术字做 闪烁提示
	if tips_panel_3:isVisible() then 
  		local img_tips = uiUtil.getConvertChildByName(tips_panel_3,"img_tips")
		breathAnimUtil.start_scroll_dir_anim(img_tips,img_tips)
	end
	-- 
	if tips_panel_3:isVisible() and flag_enemy_too_strong  and ( not (landType == cityTypeDefine.player_chengqu) ) then
		if userData.isInNewBieProtection() and ret_lv and ret_lv == 2 and (not is_land_num_max) then
			tips_panel_6:setVisible(true)
			tips_panel_6:setPosition(cc.p(0,0))
    		tips_panel_3:setPosition(cc.p(0,tips_panel_6:getContentSize().height))

    		local temp_need_time = 0.5
    		local scale_to = CCScaleTo:create(temp_need_time, 1.05)
		    light_img = uiUtil.getConvertChildByName(tips_panel_6,"light_img")
            breathAnimUtil.start_anim(light_img, false, 0, 128, temp_need_time, 1)

            light_img:setScale(1)
            light_img:runAction(tolua.cast(scale_to:copy():autorelease(), "CCActionInterval"))
            light_img:setVisible(true)
    	end
	end
	------------ 出征的部队详情
	local panel_army_detail = uiUtil.getConvertChildByName(temp_widget,"panel_army_detail")
	panel_army_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)
	require("game/army/armyMove/armyLineupManager")
  	local widget_army_detail =  armyLineupManager.fetchWidgetView(selected_army_id)
  	panel_army_detail:addChild(widget_army_detail)
  	local img_tips = uiUtil.getConvertChildByName(widget_army_detail,"img_tips")
  	img_tips:setVisible(false)

	team_confirm_layer = TouchGroup:create()
	team_confirm_layer:addWidget(temp_widget)
	uiManager.add_panel_to_layer(team_confirm_layer, uiIndexDefine.OP_ARMY_MOVE_CONFIRM,999)
	uiManager.showConfigEffect(uiIndexDefine.OP_ARMY_MOVE_CONFIRM, team_confirm_layer)

end

local function get_guide_widget(temp_guide_id)
    if not team_confirm_layer then
        return nil
    end

    return team_confirm_layer:getWidgetByTag(999)
end

opArmyMoveConfirm = {
						create = create,
						remove_self = remove_self,
						dealwithTouchEvent = dealwithTouchEvent,
						get_guide_widget = get_guide_widget
}