local landDetailInfo = {}
local landDetailHelper = require("game/map/land_detail_helper")

local m_pMainWidget = nil
local m_pNpcIntroWidget = nil
local m_pNpcOccupiedRewardTipsWidget = nil

local detailInfo = nil
local m_bIsInited = nil

local SPLIT_HEIGHT = 0

local schedulerHandler = nil

local m_iarmy_recover_timestamp = nil


local m_sUnionOwnerName = ""


local m_fViewHeight = 0


function landDetailInfo.getViewSizeHeight()
	return m_fViewHeight
end

-- 自动适应高度
local function autoSizeHeight()
	if not m_pMainWidget then return end

	local lastPosY = -12
	local lastPosX = -93
	local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
	-- 地块名字以及等级 和坐标是固定有的
	local panel_coordinate = uiUtil.getConvertChildByName(m_pMainWidget,"panel_coordinate")
	
	local panel_jianshou = uiUtil.getConvertChildByName(img_mainBg,"panel_jianshou")
	if panel_jianshou:isVisible() then 
		panel_jianshou:setPosition(cc.p(lastPosX,lastPosY - panel_jianshou:getContentSize().height))
		lastPosY = panel_jianshou:getPositionY()
	end
	-- 免战信息
	local panel_free_war = uiUtil.getConvertChildByName(img_mainBg,"panel_free_war")
	if panel_free_war:isVisible() then 
		panel_free_war:setPosition(cc.p(lastPosX,lastPosY - panel_free_war:getContentSize().height))
		lastPosY = panel_free_war:getPositionY()
	end
	
	-- 同盟信息
	local panel_unionNull = uiUtil.getConvertChildByName(img_mainBg,"panel_unionNull")
	local panel_unionOnly = uiUtil.getConvertChildByName(img_mainBg,"panel_unionOnly")
	local panel_owner = uiUtil.getConvertChildByName(img_mainBg,"panel_owner")
	local panel_unionOwner = uiUtil.getConvertChildByName(img_mainBg,"panel_unionOwner")
	local panel_userNull = uiUtil.getConvertChildByName(img_mainBg,"panel_userNull")

	if panel_unionOwner:isVisible() then 
		panel_unionOwner:setPosition(cc.p(lastPosX,lastPosY - panel_unionOwner:getContentSize().height))
		lastPosY = panel_unionOwner:getPositionY()
	end

	if panel_owner:isVisible() then 
		panel_owner:setPosition(cc.p(lastPosX,lastPosY - panel_owner:getContentSize().height))
		lastPosY = panel_owner:getPositionY()

	end

	if panel_unionOnly:isVisible() then 
		panel_unionOnly:setPosition(cc.p(lastPosX,lastPosY - panel_unionOnly:getContentSize().height))
		lastPosY = panel_unionOnly:getPositionY()
	end

	panel_userNull:setVisible(false)
	if panel_userNull:isVisible() then 
		panel_userNull:setPosition(cc.p(lastPosX,lastPosY - panel_userNull:getContentSize().height))
		lastPosY = panel_userNull:getPositionY()
	end

	if panel_unionNull:isVisible() then 
		panel_unionNull:setPosition(cc.p(lastPosX,lastPosY - panel_unionNull:getContentSize().height))
		lastPosY = panel_unionNull:getPositionY()
	end

	

	local img_lineSplit_ownInfo = uiUtil.getConvertChildByName(img_mainBg,"img_lineSplit_ownInfo")
	if img_lineSplit_ownInfo:isVisible() then 
		img_lineSplit_ownInfo:setPositionY(lastPosY - img_lineSplit_ownInfo:getContentSize().height - 2)
		lastPosY = img_lineSplit_ownInfo:getPositionY() - 2
	end
	-- 资源产出信息
	local temp_res_out = nil
	for i = 1,17 do 
		temp_res_out = uiUtil.getConvertChildByName(img_mainBg,"res_out_" .. i)
		if temp_res_out and temp_res_out:isVisible() then 
			temp_res_out:setPosition(cc.p(lastPosX,lastPosY - temp_res_out:getContentSize().height))
			lastPosY = temp_res_out:getPositionY()
		end
	end

	-- 占领加成提示
	local panel_name_occupy = uiUtil.getConvertChildByName(img_mainBg,"panel_name_occupy")
	if panel_name_occupy:isVisible() then 
		panel_name_occupy:setPosition(cc.p(lastPosX,lastPosY - panel_name_occupy:getContentSize().height))
		lastPosY = panel_name_occupy:getPositionY()
	end

	-- 分割线
	local img_lineSplit = uiUtil.getConvertChildByName(img_mainBg,"img_lineSplit")
	if img_lineSplit:isVisible() then 
		img_lineSplit:setPositionY(lastPosY - img_lineSplit:getContentSize().height - 2)
		lastPosY = img_lineSplit:getPositionY() - 2
	end

	-- 守军信息
	local panel_defenderLv = uiUtil.getConvertChildByName(img_mainBg,"panel_defenderLv")
	if panel_defenderLv:isVisible() then 
		panel_defenderLv:setPosition(cc.p(lastPosX,lastPosY - panel_defenderLv:getContentSize().height))
		lastPosY = panel_defenderLv:getPositionY()
	end
	-- 预备兵
	local panel = tolua.cast(img_mainBg:getChildByName("panel_yubeibing"),"Layout")
	if panel:isVisible() then 
		panel:setPosition(cc.p(lastPosX,lastPosY - panel:getContentSize().height))
		lastPosY = panel:getPositionY()
	end
	-- 守军恢复
	local panel_defenderRecover = uiUtil.getConvertChildByName(img_mainBg,"panel_defenderRecover")
	if panel_defenderRecover:isVisible() then 
		panel_defenderRecover:setPosition(cc.p(lastPosX,lastPosY - panel_defenderRecover:getContentSize().height))
		lastPosY = panel_defenderRecover:getPositionY()
	end
	

	local panel_intro = uiUtil.getConvertChildByName(img_mainBg,"panel_intro")
	if panel_intro:isVisible() then 
		panel_intro:setPositionY(lastPosY - panel_intro:getContentSize().height)
		lastPosY = panel_intro:getPositionY()

		local richText = uiUtil.getConvertChildByName(panel_intro,"richText")
		if richText and richText:getRealHeight() > panel_intro:getContentSize().height then 
			lastPosY = lastPosY - (richText:getRealHeight() - panel_intro:getContentSize().height)
		end
	end
	lastPosY = lastPosY - 10
	-------------- 自适应高度 ----------------
	img_mainBg:setAnchorPoint(cc.p(0.5,1))
	img_mainBg:setSize(CCSizeMake(img_mainBg:getSize().width,-lastPosY))
	img_mainBg:setPositionY(img_mainBg:getSize().height/2 + m_pMainWidget:getContentSize().height/2)

	m_fViewHeight = -lastPosY
	
	if -lastPosY < 40 then 
		img_mainBg:setVisible(false)
	end
end


local function disposeSchedulerHandler()
    if schedulerHandler then 
        scheduler.remove(schedulerHandler)
        schedulerHandler = nil
    end
end
local function updateScheduler()
	
	if not m_pMainWidget or not detailInfo then 
		disposeSchedulerHandler()
		return 
	end

	local totalTime = m_iarmy_recover_timestamp - userData.getServerTime()
	local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
	local panel_defenderRecover = uiUtil.getConvertChildByName(img_mainBg,"panel_defenderRecover")
	local label_time = uiUtil.getConvertChildByName(panel_defenderRecover,"label_time")
	label_time:setText(commonFunc.format_time(totalTime))


	local panel_free_war = uiUtil.getConvertChildByName(img_mainBg,"panel_free_war")
	local protect_cd = mapData.getProtect_end_timeData(detailInfo.coorX,detailInfo.coorY)

	if protect_cd then
		protect_cd = protect_cd  - userData.getServerTime()
		local label_time = uiUtil.getConvertChildByName(panel_free_war,"label_time")
		label_time:setText(commonFunc.format_time(protect_cd))
	end

	if totalTime <= 0 and (protect_cd and protect_cd <= 0) then 
		disposeSchedulerHandler()
		panel_defenderRecover:setVisible(false)
		panel_free_war:setVisible(false)
		autoSizeHeight()
	end
end

local function activeSchedulerHandler()
    disposeSchedulerHandler()
    schedulerHandler = scheduler.create(updateScheduler,1)
end


function landDetailInfo.remove()
	if m_pNpcIntroWidget then 
		m_pNpcIntroWidget:removeFromParentAndCleanup(true)
		m_pNpcIntroWidget = nil
	end

	if m_pNpcOccupiedRewardTipsWidget then 
		m_pNpcOccupiedRewardTipsWidget:removeFromParentAndCleanup(true)
		m_pNpcOccupiedRewardTipsWidget = nil
	end

	if m_pMainWidget then 
		m_pMainWidget:removeFromParentAndCleanup(true)
		m_pMainWidget = nil
		
		m_bIsInited = nil

		m_sUnionOwnerName = ""

		m_iarmy_recover_timestamp = nil

		CityName.showByWid(detailInfo.coorX,detailInfo.coorY,true)
		detailInfo = nil
	end

	netObserver.removeObserver(GET_NPC_RECRUIT_INFO_CMD)

	disposeSchedulerHandler()

	m_fViewHeight = 0

end





function landDetailInfo.isInitedCompleted()
	return m_bIsInited
end

function landDetailInfo.dealwithTouchEvent(x,y)
	if not m_pMainWidget then return false end
	if not detailInfo then return false end 

	local main_bg = nil
	if detailInfo.isWater or detailInfo.isMountain then
		local main_panel = uiUtil.getConvertChildByName(m_pMainWidget,"main_panel")
		main_bg = uiUtil.getConvertChildByName(main_panel,"main_bg")
	else
		main_bg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")

	end

	if main_bg:hitTest(cc.p(x,y)) then 
		return true 
	end

	if m_pNpcIntroWidget then 
		if m_pNpcIntroWidget:hitTest(cc.p(x,y)) then 
			return true
		end
	end

	if m_pNpcOccupiedRewardTipsWidget then 
		if m_pNpcOccupiedRewardTipsWidget:hitTest(cc.p(x,y)) then
			return true
		end
	end

	return false 
end
--- NPC 首攻奖励说明

local function loadNpcCityFirstOccupiedRewardTips(occupiedInfo)
	if not m_pMainWidget then return end

	if not detailInfo then return end
	if (not detailInfo.isNPCCity) then return end

	local flagOccupied = (type(occupiedInfo) == 'table')

	if flagOccupied then 
		m_pNpcOccupiedRewardTipsWidget = GUIReader:shareReader():widgetFromJsonFile("test/shouzhanjiangl_2.json")
	else
		m_pNpcOccupiedRewardTipsWidget = GUIReader:shareReader():widgetFromJsonFile("test/shouzhanjiangl_1.json")
	end

	m_pNpcOccupiedRewardTipsWidget:ignoreAnchorPointForPosition(false)
    m_pNpcOccupiedRewardTipsWidget:setAnchorPoint(cc.p(0.5, 1))

    local pos_y = -m_fViewHeight /2 + 60
    if pos_y > -70 then
    	pos_y = -70
    end
    
	m_pNpcOccupiedRewardTipsWidget:setPosition(cc.p( 0 + m_pMainWidget:getContentSize().width /2,pos_y))
	-- - m_pNpcOccupiedRewardTipsWidget:getContentSize().width/2
	m_pMainWidget:addChild(m_pNpcOccupiedRewardTipsWidget)
	
	

	
	if flagOccupied then 
		local panel_detail = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_detail")
		panel_detail:setVisible(false)

		local label_kill_null = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"label_kill_null")
		local label_duribility_null = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"label_duribility_null")
		label_kill_null:setVisible(false)
		label_duribility_null:setVisible(false)


		local label_union_name = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"label_union_name")
		local label_union_leader_name = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"label_union_leader_name")
		
		label_union_name:setText(occupiedInfo.union_name)
		label_union_leader_name:setText(occupiedInfo.leader_name)

		local duribility_rank = cjson.decode(occupiedInfo.duribility_rank)
		local kill_rank = cjson.decode(occupiedInfo.kill_rank)
		if not duribility_rank then duribility_rank = {} end
		if not kill_rank then kill_rank = {} end

		label_kill_null:setVisible(#kill_rank == 0)
		label_duribility_null:setVisible(#duribility_rank == 0 )

		--[[
		local detailInfo_count = #duribility_rank
		if detailInfo_count < #kill_rank then 
			detailInfo_count = #kill_rank
		end
		]]

		local detailInfo_count = 3
		-- 至少有一个是盟主
		local panel_detail = nil
		for i = 1,detailInfo_count do 
			if i == 1 then 
				panel_detail = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_detail")
				panel_detail:setVisible(true)
			else
				local panel_detail_clone = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_detail")
				panel_detail = panel_detail_clone:clone()
				m_pNpcOccupiedRewardTipsWidget:addChild(panel_detail)
				panel_detail:setPosition(cc.p(panel_detail_clone:getPositionX(), panel_detail:getPositionY() - panel_detail:getContentSize().height  * (i -  1)  ))
				panel_detail:setVisible(true)
			end
			
			local panel_kill = uiUtil.getConvertChildByName(panel_detail,"panel_kill")
			local label_kill_rank = uiUtil.getConvertChildByName(panel_kill,"label_kill_rank")
			local label_kill_name = uiUtil.getConvertChildByName(panel_kill,"label_kill_name")
			local label_kill_num = uiUtil.getConvertChildByName(panel_kill,"label_kill_num")
			
			label_kill_rank:setText(i)
			label_kill_name:setText("---")
			label_kill_num:setText("---")


			local panel_duribility = uiUtil.getConvertChildByName(panel_detail,"panel_duribility")
			local label_duribility_rank = uiUtil.getConvertChildByName(panel_duribility,"label_duribility_rank")
			local label_duribility_name = uiUtil.getConvertChildByName(panel_duribility,"label_duribility_name")
			local label_duribility_num = uiUtil.getConvertChildByName(panel_duribility,"label_duribility_num")
			label_duribility_rank:setText(i)
			label_duribility_name:setText("---")
			label_duribility_num:setText("---")
			

			for k,v in pairs(kill_rank) do 
				if v[1] == i then 
					label_kill_rank:setText(i)
					label_kill_name:setText(v[3])
					label_kill_num:setText(v[4])
				end
			end
			
			for k,v in pairs(duribility_rank) do 
				if v[1] == i then 
					label_duribility_rank:setText(i)
					label_duribility_name:setText(v[3])
					label_duribility_num:setText(v[4])
				end
			end
		end
		

	else
		local panel_destory_enemy = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_destory_enemy")
		local panel_destory_city = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_destory_city")
		local panel_wood = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_wood")
		local panel_stone = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_stone")
		local panel_iron = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_iron")
		local panel_food = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"panel_food")

		local cfgWorldCity = Tb_cfg_world_city[detailInfo.landId]
		local cfgRewardInfoAll = Tb_cfg_npc_city_occupy_reward[ cfgWorldCity.param * 10 + 1 ]
		local cfgRewardInfoKill = Tb_cfg_npc_city_occupy_reward[ cfgWorldCity.param * 10 + 2 ]
		local cfgRewardInfoDuribility = Tb_cfg_npc_city_occupy_reward[ cfgWorldCity.param * 10 + 3 ]

		config.dump(cfgRewardInfoAll)
		config.dump(cfgRewardInfoKill)
		config.dump(cfgRewardInfoDuribility)
		
		for k,v in pairs(cfgRewardInfoAll.drops) do 
			if v[1] == 1 then 
				local label_value = uiUtil.getConvertChildByName(panel_wood,"label_value")
				label_value:setText(v[2])
			elseif v[1] == 2 then 
				local label_value = uiUtil.getConvertChildByName(panel_stone,"label_value")
				label_value:setText(v[2])
			elseif v[1] == 3 then 
				local label_value = uiUtil.getConvertChildByName(panel_iron,"label_value")
				label_value:setText(v[2])
			elseif v[1] == 4 then 
				local label_value = uiUtil.getConvertChildByName(panel_food,"label_value")
				label_value:setText(v[2])
			end
		end	

		for k,v in pairs(cfgRewardInfoKill.drops) do 
			if v[1] == 5 then 
				local label_value = uiUtil.getConvertChildByName(panel_destory_enemy,"label_value")
				label_value:setText(v[2])
			end
		end	
		
		for k,v in pairs(cfgRewardInfoDuribility.drops) do 
			if v[1] == 5 then 
				local label_value = uiUtil.getConvertChildByName(panel_destory_city,"label_value")
				label_value:setText(v[2])
			end		
		end
		
		local btn_tips = uiUtil.getConvertChildByName(m_pNpcOccupiedRewardTipsWidget,"btn_tips")
		btn_tips:setTouchEnabled(true)
		btn_tips:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				require("game/map/npc_city_occupied_tips")
				NpcCityOccupiedTips.create()
			end
		end)
	end
end



--只有NPC城市，且配置信息不为空才显示
local function initCityInfo()
	if not detailInfo then return end 

	local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
	local panel_intro = uiUtil.getConvertChildByName(img_mainBg,"panel_intro")
	panel_intro:setVisible(false)
	panel_intro:setBackGroundColorType(LAYOUT_COLOR_NONE)
	panel_intro:removeAllChildrenWithCleanup(true)


	local flagHasIntro = false

	if detailInfo.isNPCCity then 
		flagHasIntro = true
	end
	if detailInfo.landLv and detailInfo.landLv >=6 and detailInfo.landLv <= 9 then 
		flagHasIntro = true
	end

	if detailInfo.isNpcYaosai then
		flagHasIntro = true
	end

	if not flagHasIntro then return end

	local strIntro = nil

	if detailInfo.isNPCCity then 
		local temp_city_info = Tb_cfg_world_city[detailInfo.landId]
		if temp_city_info and temp_city_info.description ~= "" then 
			strIntro = temp_city_info.description
		end
	end

	if not detailInfo.isNPCProper and not detailInfo.isNPCCity and detailInfo.landLv and detailInfo.landLv >=6 and detailInfo.landLv <= 9 then 
		strIntro = languagePack["land_intro_lv_" .. detailInfo.landLv]
	end

	if detailInfo.isNpcYaosai then
		-- 兵营
		if Tb_cfg_world_city[detailInfo.coorX*10000+detailInfo.coorY].param >=NPC_FORT_TYPE_RECRUIT[1] and
			Tb_cfg_world_city[detailInfo.coorX*10000+detailInfo.coorY].param <=NPC_FORT_TYPE_RECRUIT[2] then
			strIntro = languagePack["land_yunying"]
		-- 要塞
		else
			strIntro = languagePack["land_yaosai"]
		end
	end


	
	if not strIntro then return end

    panel_intro:setVisible(true)

    
    local _richText = RichText:create()
	_richText:ignoreContentAdaptWithSize(false)
	_richText:setVerticalSpace(3)
    _richText:setSize(CCSizeMake(panel_intro:getContentSize().width - 20, panel_intro:getContentSize().height))
    _richText:setAnchorPoint(cc.p(0.5,1))
    _richText:setPosition(cc.p(panel_intro:getContentSize().width/2, panel_intro:getContentSize().height))
    panel_intro:addChild(_richText)
    _richText:setName("richText")

    local tStr = config.richText_split(strIntro)
    local re = nil
    
    for i,v in ipairs(tStr) do

    	if v[1] == 1 then
    		re = RichElementText:create(i, ccc3(255,255,255), 255, v[2],config.getFontName(), 16)
    	else
    		re = RichElementText:create(i, ccc3(234,232,156), 255, v[2],config.getFontName(), 16)
    	end

    	_richText:pushBackElement(re)
	end
	_richText:formatText()
end

local function reloadData2()
	if not m_pMainWidget then return end
	if not detailInfo then return end 

	local main_panel = uiUtil.getConvertChildByName(m_pMainWidget,"main_panel")
	local label_name = uiUtil.getConvertChildByName(main_panel,"label_name")
	local label_region = uiUtil.getConvertChildByName(main_panel,"label_region")
	local label_pos = uiUtil.getConvertChildByName(main_panel,"label_pos")

	label_name:setText(detailInfo.landName)
	label_pos:setText(detailInfo.coorX .. "," .. detailInfo.coorY)
	label_region:setText(detailInfo.regionName)
end





-- NPC主城守军兵力恢复 以及免战CD
function landDetailInfo.setNpcCityForcesRecover(army_recover_timestamp)
	if not m_pMainWidget then return end
	if not detailInfo then return end

	disposeSchedulerHandler()

	local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
	local img_lineSplit = uiUtil.getConvertChildByName(img_mainBg,"img_lineSplit")

	local panel_defenderLv = uiUtil.getConvertChildByName(img_mainBg,"panel_defenderLv")
	local panel_defenderRecover = uiUtil.getConvertChildByName(img_mainBg,"panel_defenderRecover")

	local flagExistCounDown = false
	-- if not detailInfo.isNPCCity and not detailInfo.isNpcYaosai then 
	-- 	panel_defenderRecover:setVisible(false)
	-- else
	-- 	if army_recover_timestamp == 0 then
	-- 		panel_defenderRecover:setVisible(false)
	-- 	elseif army_recover_timestamp - userData.getServerTime() <= 0 then 
	-- 		panel_defenderRecover:setVisible(false)
	-- 	else
	-- 		flagExistCounDown = true
	-- 		panel_defenderRecover:setVisible(true)

	-- 		local totalTime = army_recover_timestamp - userData.getServerTime()
	-- 		local label_time = uiUtil.getConvertChildByName(panel_defenderRecover,"label_time")
	-- 		label_time:setText(commonFunc.format_time(totalTime))
	-- 	end
	-- end
	if army_recover_timestamp == 0 then
		panel_defenderRecover:setVisible(false)
	elseif army_recover_timestamp - userData.getServerTime() <= 0 then 
		panel_defenderRecover:setVisible(false)
	else
		flagExistCounDown = true
		panel_defenderRecover:setVisible(true)

		local totalTime = army_recover_timestamp - userData.getServerTime()
		local label_time = uiUtil.getConvertChildByName(panel_defenderRecover,"label_time")
		label_time:setText(commonFunc.format_time(totalTime))
	end


	-- 免战CD  
	local flag_is_free_war_visible = false
	-- 只有自己 还有 归属自己同盟的NPC城市 才可见
	if detailInfo.isOwnSelf then 
		flag_is_free_war_visible = true
	end
	if detailInfo.isNPCCity and userData.getUnion_name() == m_sUnionOwnerName then 
		flag_is_free_war_visible = true
	end

	local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
	local panel_free_war = uiUtil.getConvertChildByName(img_mainBg,"panel_free_war")
	panel_free_war:setVisible(false)

	-- 免战是否过期
	local flag_is_overdue = true
	local protect_end_time = mapData.getProtect_end_timeData(detailInfo.coorX,detailInfo.coorY)
	if protect_end_time and protect_end_time > userData.getServerTime() then 
		flag_is_overdue = false
	end

	
	
	if flag_is_free_war_visible and not flag_is_overdue  then 
		panel_free_war:setVisible(true)
		flagExistCounDown = true
		local totalTime = protect_end_time - userData.getServerTime()
		local label_time = uiUtil.getConvertChildByName(panel_free_war,"label_time")
		label_time:setText(commonFunc.format_time(totalTime))
	else
		panel_free_war:setVisible(false)
	end

	
	if flagExistCounDown then 
		activeSchedulerHandler()
	end
	
	autoSizeHeight()
end




--根据服务器返回刷新预备兵数量
local function refreshRedif(packet )
	if m_pMainWidget then
		local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
		local panel = tolua.cast(img_mainBg:getChildByName("panel_yubeibing"),"Layout")
		local label = tolua.cast(panel:getChildByName("Label_787781"),"Label")
		local cur = packet[1]
		local level = 1
		if Tb_cfg_world_city[detailInfo.landId] then
			level = Tb_cfg_world_city[detailInfo.landId].param%100
			-- if level == 0 then
			-- 	level = 10
			-- end
		end

		local max = NPC_RECRUIT_REDIF_MAX[level]
		label:setText(cur.."/"..max)
	end
end

--设置是否显示预备兵
local function setRedif( )
	local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
	local panel = tolua.cast(img_mainBg:getChildByName("panel_yubeibing"),"Layout")
	if detailInfo.isRedifVisible then
		local img_lineSplit = uiUtil.getConvertChildByName(img_mainBg,"img_lineSplit")
		panel:setVisible(true)

		--显示当前预备兵数和最大预备兵数
		local label = tolua.cast(panel:getChildByName("Label_787781"),"Label")
		local cur = "--"
		local level = 1
		if Tb_cfg_world_city[detailInfo.landId] then
			level = Tb_cfg_world_city[detailInfo.landId].param%100
			-- if level == 0 then
			-- 	level = 10
			-- end
		end

		local max = NPC_RECRUIT_REDIF_MAX[level]
		label:setText(cur.."/"..max)
	
		netObserver.addObserver(GET_NPC_RECRUIT_INFO_CMD, refreshRedif)
		Net.send(GET_NPC_RECRUIT_INFO_CMD, {detailInfo.landId})
	else
		panel:setVisible(false)
	end
end





local function reloadData1(owner_name, owner_union_name, affilate_union_name,durability_cur,durability_max,army_recover_timestamp,durability_rate)

	if not m_pMainWidget then return end
	if not detailInfo then return end

	if not owner_name then 
		owner_name = detailInfo.owner_name
	end

	if not owner_union_name then 
		owner_union_name = detailInfo.owner_union_name
	end

	if not affilate_union_name then 
		affilate_union_name = detailInfo.affilate_union_name
	end
	if not durability_cur or durability_cur == "" then 
		durability_cur = detailInfo.durability_cur
	end

	if not durability_max or durability_max == "" then 
		durability_max = detailInfo.durability_max
	end
	

	local panel_lines = uiUtil.getConvertChildByName(m_pMainWidget,"panel_lines")
	panel_lines:setBackGroundColorType(LAYOUT_COLOR_NONE)



	local img_mainBg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")

	-- 地块名字以及等级
	local panel_name_occupy = uiUtil.getConvertChildByName(img_mainBg,"panel_name_occupy")
	local panel_name = uiUtil.getConvertChildByName(m_pMainWidget,"panel_name")
	local label_name = uiUtil.getConvertChildByName(panel_name,"label_name")
	local label_lv = uiUtil.getConvertChildByName(panel_name,"label_lv")
	label_name:setText(detailInfo.landName)
	if detailInfo.landLv and detailInfo.landLv > 0 then 
		label_lv:setText(languagePack["lv"] .. detailInfo.landLv)
		label_lv:setPositionX(label_name:getPositionX() +  label_name:getContentSize().width + 5)
		label_lv:setVisible(true)
	else
		label_lv:setVisible(false)
	end

	if detailInfo.isNPCProper then 
		panel_name_occupy:setVisible(true)
	else
		panel_name_occupy:setVisible(false)
	end

	-- 地块位置信息
	local panel_coordinate = uiUtil.getConvertChildByName(m_pMainWidget,"panel_coordinate")
	local label_region = uiUtil.getConvertChildByName(panel_coordinate,"label_region")
	local label_pos = uiUtil.getConvertChildByName(panel_coordinate,"label_pos")
	label_pos:setText(detailInfo.coorX .. "," .. detailInfo.coorY)
	label_region:setText(detailInfo.regionName)
	-- 地块归属信息
	local panel_unionNull = uiUtil.getConvertChildByName(img_mainBg,"panel_unionNull")
	local panel_unionOnly = uiUtil.getConvertChildByName(img_mainBg,"panel_unionOnly")
	local panel_owner = uiUtil.getConvertChildByName(img_mainBg,"panel_owner")
	local panel_unionOwner = uiUtil.getConvertChildByName(img_mainBg,"panel_unionOwner")
	local panel_userNull = uiUtil.getConvertChildByName(img_mainBg,"panel_userNull")
	panel_unionNull:setVisible(false)
	panel_unionOnly:setVisible(false)
	panel_owner:setVisible(false)
	panel_unionOwner:setVisible(false)
	panel_userNull:setVisible(false)

	local img_lineSplit_ownInfo = uiUtil.getConvertChildByName(img_mainBg,"img_lineSplit_ownInfo")
	img_lineSplit_ownInfo:setVisible(false)


	local panel_jianshou = uiUtil.getConvertChildByName(img_mainBg,"panel_jianshou")
	panel_jianshou:setVisible(false)


	local guard_end_time = mapData.getGuard_end_timeData(detailInfo.coorX, detailInfo.coorY)
    if guard_end_time and guard_end_time > userData.getServerTime() then
    	panel_jianshou:setVisible(true)
    end
	-- if userData.getUserGuardState() == userGuardState.guarding and
	--  	detailInfo.isOwnSelf and 
	--  	(detailInfo.isUserMainCity or detailInfo.isUserMainCityProper or detailInfo.isUserCity or detailInfo.isUserFort )

	--    then 
	-- 	panel_jianshou:setVisible(true)
	-- end
	-- NPC 城属同盟占领  NPC 城区属个人占领
	if detailInfo.isOwnFree then
		if detailInfo.isNPCCity then  
			panel_unionOnly:setVisible(true)
		else
			panel_userNull:setVisible(true)
		end
	else
		if detailInfo.isNPCCity then 
			--只有同盟可以占领
			if detailInfo.union_id and detailInfo.union_id~=0 then 
				panel_unionOwner:setVisible(true)
				label_name = uiUtil.getConvertChildByName(panel_unionOwner,"label_name")
				label_name:setText(owner_union_name)
			else
				panel_unionOnly:setVisible(true)
			end
		else
			-- 有归属玩家的
			panel_owner:setVisible(true)
			label_name = uiUtil.getConvertChildByName(panel_owner,"label_name")
			label_name:setText(owner_name)
			-- 是否有归属同盟
			if detailInfo.union_id and detailInfo.union_id~=0 then 
				panel_unionOwner:setVisible(true)
				label_name = uiUtil.getConvertChildByName(panel_unionOwner,"label_name")
				label_name:setText(owner_union_name)
			else
				panel_unionNull:setVisible(true)
			end
		end
	end

	

	-- 地块产出信息
	local panel_res_item = uiUtil.getConvertChildByName(img_mainBg,"panel_res_item")
	panel_res_item:setVisible(false)
	local temp_res_panel = nil
	for i = 1,17 do 
		temp_res_panel = uiUtil.getConvertChildByName(img_mainBg,"res_out_" .. i)
		if temp_res_panel then 
			temp_res_panel:removeFromParentAndCleanup(true)
			temp_res_panel = nil
		end
	end
	
	local temp_res_txt = nil
    local temp_res_name = nil
    local temp_res_flag = nil
    local temp_city_info = Tb_cfg_world_city[detailInfo.landId]

  	

    img_lineSplit_ownInfo:setVisible(detailInfo.flag_show_res_out)

    if panel_userNull:isVisible() then
    	img_lineSplit_ownInfo:setVisible(false)
    end
	if detailInfo.flag_show_res_out and detailInfo.isNPCCity then 
		-- NPC 产出加成
        local value_tab = {}
        local img_flag_tab = {}
        if temp_city_info then 
        	local npc_add_info = Tb_cfg_npc_add[temp_city_info.param]
        	value_tab[1] = npc_add_info.wood_add 
            value_tab[2] = npc_add_info.stone_add
            value_tab[3] = npc_add_info.iron_add
            value_tab[4] = npc_add_info.food_add
            value_tab[5] = npc_add_info.login_money_add

            value_tab[6] = math.floor( npc_add_info.qi_attack_add / 100 )
            value_tab[7] = math.floor( npc_add_info.qi_defend_add / 100 )
            value_tab[8] = math.floor( npc_add_info.qi_intel_add / 100 )
            value_tab[9] = 0
            value_tab[10] = math.floor( npc_add_info.gong_attack_add / 100 )
            value_tab[11] = math.floor( npc_add_info.gong_defend_add / 100 )
            value_tab[12] = math.floor( npc_add_info.gong_intel_add / 100 )
            value_tab[13] = 0
            value_tab[14] = math.floor( npc_add_info.qiang_attack_add / 100 )
            value_tab[15] = math.floor( npc_add_info.qiang_defend_add / 100 )
            value_tab[16] = math.floor( npc_add_info.qiang_intel_add / 100 )
            value_tab[17] = 0

            for i = 1,17 do
                if value_tab[i] > 0 then 
                	temp_res_panel = panel_res_item:clone()
            		temp_res_panel:setVisible(true)
            		temp_res_panel:setName("res_out_" .. i)
                    if i >= 1 and i <=4 then 
                        value_tab[i] = value_tab[i] .. "/" .. languagePack["xiaoshi"]
                    end
                    temp_res_txt = uiUtil.getConvertChildByName(temp_res_panel,"label_value")
                    temp_res_name = uiUtil.getConvertChildByName(temp_res_panel,"label_title")
                    temp_res_flag = uiUtil.getConvertChildByName(temp_res_panel,"img_flag")
                    temp_res_flag:loadTexture(ResDefineUtil.land_res_type_img[i],UI_TEX_TYPE_PLIST)
                    temp_res_name:setText(languagePack["land_res_type_name_" .. i])
                    temp_res_txt:setText("+" .. tostring(value_tab[i]))

                    img_mainBg:addChild(temp_res_panel)
                end
                
            end
        end
    elseif detailInfo.flag_show_res_out and (detailInfo.isNPCProper and temp_city_info) then 
    	-- NPC 城区 只产出铜钱
    	local param = temp_city_info.param
        local lv = param % 10
        if lv == 0 then lv = 10 end

        temp_res_panel = panel_res_item:clone()
		temp_res_panel:setVisible(true)
        temp_res_panel:setName("res_out_5")
        temp_res_txt = uiUtil.getConvertChildByName(temp_res_panel,"label_value")
        temp_res_name = uiUtil.getConvertChildByName(temp_res_panel,"label_title")
        temp_res_flag = uiUtil.getConvertChildByName(temp_res_panel,"img_flag")
        temp_res_flag:loadTexture(ResDefineUtil.land_res_type_img[5],UI_TEX_TYPE_PLIST)
        temp_res_name:setText(languagePack["land_res_type_name_5"])
        temp_res_txt:setText(languagePack["tax_title"] .. "+" .. tostring(NPC_SUBURB_LEVEL_MONEY[lv]))
        img_mainBg:addChild(temp_res_panel)

        -- for k,v in pairs(Tb_cfg_res_output[lv * 10 + 9].res_output) do
        --     if v[2] > 0 then 
        --     	temp_res_panel = panel_res_item:clone()
        -- 		temp_res_panel:setVisible(true)
        --         temp_res_panel:setName("res_out_" .. v[1])
        --         temp_res_txt = uiUtil.getConvertChildByName(temp_res_panel,"label_value")
        --         temp_res_name = uiUtil.getConvertChildByName(temp_res_panel,"label_title")
        --         temp_res_flag = uiUtil.getConvertChildByName(temp_res_panel,"img_flag")
        --         temp_res_flag:loadTexture(ResDefineUtil.land_res_type_img[v[1]],UI_TEX_TYPE_PLIST)
        --         temp_res_name:setText(languagePack["land_res_type_name_" .. v[1]])
        --         if v[1] == 5 then 
        --             temp_res_txt:setText(languagePack["tax_title"] .. "+" .. tostring(v[2]))
        --         else
        --             temp_res_txt:setText("+" .. tostring(v[2])  .. "/" .. languagePack["xiaoshi"])
        --         end
        --         img_mainBg:addChild(temp_res_panel)
        --     end
        -- end 
	else
		if detailInfo.flag_show_res_out and detailInfo.landResLv then
        	for k,v in pairs(Tb_cfg_res_output[detailInfo.landResLv].res_output) do
                if v[2] > 0 then 
                	temp_res_panel = panel_res_item:clone()
	        		temp_res_panel:setVisible(true)
	                temp_res_panel:setName("res_out_" .. v[1])
	                temp_res_txt = uiUtil.getConvertChildByName(temp_res_panel,"label_value")
	                temp_res_name = uiUtil.getConvertChildByName(temp_res_panel,"label_title")
	                temp_res_flag = uiUtil.getConvertChildByName(temp_res_panel,"img_flag")
	                temp_res_flag:loadTexture(ResDefineUtil.land_res_type_img[v[1]],UI_TEX_TYPE_PLIST)
	                temp_res_name:setText(languagePack["land_res_type_name_" .. v[1]])

        	        temp_res_txt:setText("+" .. tostring(v[2]) .. "/" .. languagePack["xiaoshi"])
	                img_mainBg:addChild(temp_res_panel)
                end
        	end
        end
	end

	if panel_name_occupy:isVisible() then 
		local label_name = nil
		label_name = uiUtil.getConvertChildByName(panel_name_occupy,"label_name_2")
		label_name:setText(Tb_cfg_world_city[Tb_cfg_world_city[detailInfo.landId].belong_city].name)
		local posX = panel_name_occupy:getContentSize().width
		for i = 1,3 do 
			label_name = uiUtil.getConvertChildByName(panel_name_occupy,"label_name_" .. i)
			posX = posX - label_name:getContentSize().width
		end

		posX = posX/2

		for i = 1,3 do 
			label_name = uiUtil.getConvertChildByName(panel_name_occupy,"label_name_" .. i)
			label_name:setPositionX(posX)
			posX = posX + label_name:getContentSize().width
		end
		
	end
	-- 分割线
	local img_lineSplit = uiUtil.getConvertChildByName(img_mainBg,"img_lineSplit")
	


	-- 守军信息
	local panel_defenderLv = uiUtil.getConvertChildByName(img_mainBg,"panel_defenderLv")
	local panel_defenderRecover = uiUtil.getConvertChildByName(img_mainBg,"panel_defenderRecover")
	
	local label_lv = uiUtil.getConvertChildByName(panel_defenderLv,"label_lv")
	local img_kulou = uiUtil.getConvertChildByName(panel_defenderLv,"img_kulou")
	if detailInfo.isDefenderVisible then 
		img_lineSplit:setVisible(true)

		local defender_army_count = landData.getLandCfgDefenderArmyCount(detailInfo.coorX,detailInfo.coorY)
		local defender_army_count_txt = " "
		
		if defender_army_count > 1 then 
			defender_army_count_txt = "X" .. defender_army_count
		end
		panel_defenderLv:setVisible(true)
		
		if detailInfo.landResDefenderLv >=  10 then 
			label_lv:setText(defender_army_count_txt)
			img_kulou:setVisible(true)
		else
			label_lv:setText(languagePack["lv"] .. detailInfo.landResDefenderLv .. defender_army_count_txt)
			img_kulou:setVisible(false)
		end
	else
		img_lineSplit:setVisible(false)
		panel_defenderLv:setVisible(false)
	end

	panel_defenderRecover:setVisible(false)
	
	

	
	local btn_roleForcesDetail = uiUtil.getConvertChildByName(img_mainBg,"btn_roleForcesDetail")
	btn_roleForcesDetail:setVisible(false)
	btn_roleForcesDetail:setTouchEnabled(false)
	btn_roleForcesDetail:addTouchEventListener(function(sender, eventType)
		if eventType == TOUCH_EVENT_ENDED then
	    	local message = nil
	    	local buildingData = mapData.getBuildingData()
	    	local touch_map_x = detailInfo.coorX
	    	local touch_map_y = detailInfo.coorY
	    	if buildingData[touch_map_x] and buildingData[touch_map_x][touch_map_y] then
	    		message = buildingData[touch_map_x][touch_map_y]
	    	end
	        mapMessageUI.remove_self()
	        if message and  message.userId and message.userId~= 0 then 
	            UIRoleForcesMain.create(message.userId)
	        elseif m_strOwnerName then 
	            UIRoleForcesMain.create(nil,owner_name)      
	        end
	    end
	end)

	if owner_name and owner_name ~= "" then 
		btn_roleForcesDetail:setVisible(true)
		btn_roleForcesDetail:setTouchEnabled(true)
	end

	if detailInfo.isOwnSelf then 
        btn_roleForcesDetail:setVisible(false)
        btn_roleForcesDetail:setTouchEnabled(false)
    end

	local img_luanxian = uiUtil.getConvertChildByName(img_mainBg,"img_luanxian")
	img_luanxian:setVisible(detailInfo.isLunxianVisible)


	local panel_Durability = uiUtil.getConvertChildByName(m_pMainWidget,"panel_Durability")
	panel_Durability:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local panel_unknow = uiUtil.getConvertChildByName(panel_Durability,"panel_unknow")
	panel_unknow:setBackGroundColorType(LAYOUT_COLOR_NONE)
	local atlas_label_val = uiUtil.getConvertChildByName(panel_Durability,"atlas_label_val")
	local bar = uiUtil.getConvertChildByName(panel_Durability,"bar")

	
	-- 耐久度信息
	if detailInfo.isDurabilityInfoVisible and not (durability_cur == 0 and durability_max == 0) then 
		panel_unknow:setVisible(false)
		atlas_label_val:setVisible(true)
		atlas_label_val:setStringValue(durability_cur .. "/" .. durability_max)
	else

		panel_unknow:setVisible(true)
		atlas_label_val:setVisible(false)
	end

	

	if (durability_cur == 0 and durability_max == 0) then 
		bar:setPercent(0)
	else
		bar:setPercent( math.floor(durability_cur*100/durability_max) )
	end


	if not detailInfo.isDurabilityInfoVisible and not (durability_cur == 0 and durability_max == 0) then 
		panel_unknow:setVisible(false)
		atlas_label_val:setVisible(false)
		-- atlas_label_val:setStringValue(math.floor(durability_cur*100/durability_max) )
	end

	local label_rate = uiUtil.getConvertChildByName(panel_Durability,"label_rate")
	label_rate:setVisible(false)
	if (durability_cur == 0 and durability_max == 0) and durability_rate and durability_rate ~= "" then 
		panel_unknow:setVisible(false)
		bar:setPercent(tonumber(durability_rate))
		atlas_label_val:setVisible(false)
		label_rate:setVisible(true)
		label_rate:setText(durability_rate .. "%")

		tolua.cast(label_rate:getVirtualRenderer(),"CCLabelTTF"):enableStroke(ccc3(0,0,0),2,true)
	end
	
	CityName.hideByWid(detailInfo.coorX,detailInfo.coorY,true)

	
	setRedif( )

	if not army_recover_timestamp then army_recover_timestamp = 0 end
	m_iarmy_recover_timestamp = army_recover_timestamp
	m_sUnionOwnerName = owner_union_name
	landDetailInfo.setNpcCityForcesRecover(army_recover_timestamp)

	initCityInfo()
	autoSizeHeight()
end

local function reloadData(...)
	if not m_pMainWidget then return end
	if not detailInfo then return end
	if detailInfo.isWater or detailInfo.isMountain then
		reloadData2(...) 
	else
		reloadData1(...)
	end
	m_pMainWidget:setVisible(true)
end

local function initWidget(parent,show_pos_x,show_pos_y)
	if m_pMainWidget then return end
	if not detailInfo then return end

	if detailInfo.isWater or detailInfo.isMountain then 
		m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/dibiaoshijian_2.json")
	    m_pMainWidget:setScale(config.getgScale())
	    m_pMainWidget:ignoreAnchorPointForPosition(false)
	    m_pMainWidget:setAnchorPoint(cc.p(0.5, 0))
    	m_pMainWidget:setPosition(cc.p(show_pos_x ,show_pos_y))
    	parent:addWidget(m_pMainWidget)
    	m_pMainWidget:setTag(997)
	else
		m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/dibiaoshijian_1.json")
	    m_pMainWidget:setScale(config.getgScale())
	    m_pMainWidget:ignoreAnchorPointForPosition(false)
	    m_pMainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    	m_pMainWidget:setPosition(cc.p(show_pos_x ,show_pos_y))
    	parent:addWidget(m_pMainWidget)
    	m_pMainWidget:setTag(998)
	end
	
	m_pMainWidget:setVisible(false)
	m_pMainWidget:setTouchEnabled(false)

end

function landDetailInfo.create(coorX,coorY,parent,show_pos_x,show_pos_y)
	if m_pMainWidget then return end

    detailInfo = landDetailHelper.getInfo(coorX,coorY)

    initWidget(parent,show_pos_x,show_pos_y)

    if detailInfo.isNeedDataFromServer then 
    	mapOpRequest.requestLandInfo(coorX, coorY)
    	m_bIsInited = false
    else
    	reloadData()
    	m_bIsInited = true
    end
end

function landDetailInfo.setBelongInfo(owner_name, owner_union_name, affilate_union_name,durability_cur,durability_max,army_recover_timestamp,durability_rate,occupiedInfo)
	reloadData(owner_name, owner_union_name, affilate_union_name,durability_cur,durability_max,army_recover_timestamp,durability_rate)
	m_bIsInited = true
	loadNpcCityFirstOccupiedRewardTips(occupiedInfo)
end


function landDetailInfo.disableTouchAndRemove()
	if not m_pMainWidget then return end
	m_pMainWidget:setTouchEnabled(false)
	local main_bg = nil
	if detailInfo.isWater or detailInfo.isMountain then
		local main_panel = uiUtil.getConvertChildByName(m_pMainWidget,"main_panel")
		main_bg = uiUtil.getConvertChildByName(main_panel,"main_bg")
	else
		main_bg = uiUtil.getConvertChildByName(m_pMainWidget,"img_mainBg")
	end
	main_bg:setTouchEnabled(false)
end

return landDetailInfo
