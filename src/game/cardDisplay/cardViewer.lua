local cardViewer = {}


-- 因为有两个layer 可以同时存在 所以就可以同时存在两个实例

cardViewer.VIEW_TYPE_BASIC = 1					-- 展示类型是基础卡牌
cardViewer.VIEW_TYPE_USER = 2 					-- 展示类型是玩家拥有的卡牌
cardViewer.VIEW_TYPE_USER_LOCK = 3 				-- 展示类型是玩家拥有的卡牌 但是锁定住不可操作
cardViewer.VIEW_TYPE_OTHERS = 4					-- 展示类型  非玩家拥有的卡牌
cardViewer.VIEW_TYPE_USER_IN_EXERCISE = 5		-- 展示类型  玩家卡牌 在演武里
-- 两个卡牌详情实例
cardViewer.TAG_ID_CUR_ITEM = 999
cardViewer.TAG_ID_NEXT_ITEM = 998


cardViewer.TAG_ID_CLOSE_BTN =  990	--关闭按钮

cardViewer.TAG_ID_BTN_LEFT = 980	--左翻按钮
cardViewer.TAG_ID_BTN_RIGHT = 970	--右翻按钮



cardViewer.VIEW_TAG_ID_HERO_INTRO = 960 	-- 武将列传
cardViewer.VIEW_TAG_ID_ADD_POINT = 950 		-- 洗点配点


local cardInfoItemIF = require("game/cardDisplay/cardInfoItemIF")


local SkillOpreateObserver = require("game/skill/skill_operate_observer")



function cardViewer.setCardViewer2Layer(viewType,idList,curid,parentLayer,closeCallback,basicInfoOffset)

	local m_pCardViewCurItem = nil
	local m_pCardViewNextItem = nil
	local m_tIdList = nil
	local m_iIdIndx = nil
	local m_iIdIndxNext = nil

	local m_iViewType = nil	-- 展示的类型

	local m_pLeftBtn = nil
	local m_pRightBtn = nil
	local m_pCloseBtn = nil

	local m_bIsSwitching = nil

	
	m_iViewType = viewType

	m_bIsSwitching = false

	local isIdEmpty = (not curid) or (curid == 0)
	local isListEmpty = (not idList) or (#idList == 0)
	if isIdEmpty and isListEmpty then return end

	if (not isIdEmpty) and (not isListEmpty) then 
		for i = 1,#idList do 
			if idList[i] == curid then 
				m_iIdIndx = i
			end
		end

		if m_iIdIndx then 
			m_tIdList = idList
			m_iIdIndxNext = m_iIdIndx + 1
		else
			m_iIdIndx = 1
			m_tIdList = idList
			m_iIdIndxNext = m_iIdIndx + 1
			table.insert(m_tIdList,1,curid)
		end
		if m_iIdIndxNext > #m_tIdList then 
			m_iIdIndxNext = 1
		end

	else
		if isIdEmpty then 
			m_iIdIndx = 1
			m_iIdIndxNext = m_iIdIndx + 1
			m_tIdList = idList
			if m_iIdIndxNext > #m_tIdList then 
				m_iIdIndxNext = 1
			end
		end

		if isListEmpty then 
			m_iIdIndx = 1
			m_iIdIndxNext = 1
			m_tIdList = {curid}
		end
	end

	local function dispose()
		-- require("game/cardDisplay/cardAddPoint")



		if cardAddPoint then
			cardAddPoint.remove_self()
		end

		if m_pCardViewCurItem then 
			m_pCardViewCurItem:removeFromParentAndCleanup(true)
			m_pCardViewCurItem = nil
		end

		if m_pCardViewNextItem then 
			m_pCardViewNextItem:removeFromParentAndCleanup(true)
			m_pCardViewNextItem = nil
		end

		m_tIdList = nil
		m_iIdIndx = nil
		m_iIdIndxNext = nil

		m_iViewType = nil	-- 展示的类型

		m_pLeftBtn = nil
		m_pRightBtn = nil
		m_pCloseBtn = nil

		m_bIsSwitching = nil
	end
	local function loadCardViewItemInfo(item,idIndx,isUpdateOnly)
		if not item then return end
		if not idIndx then return end
		if not m_tIdList then return end
		if not m_tIdList[idIndx] then return end
		
		if isUpdateOnly then 
			if m_iViewType == cardViewer.VIEW_TYPE_USER then 
				cardInfoItemIF.updateInfo(item,nil,m_tIdList[idIndx],m_iViewType)
			elseif m_iViewType == cardViewer.VIEW_TYPE_OTHERS then 
				cardInfoItemIF.updateInfo(item,nil,m_tIdList[idIndx],m_iViewType)
			elseif m_iViewType == cardViewer.VIEW_TYPE_USER_LOCK then 
				cardInfoItemIF.updateInfo(item,nil,m_tIdList[idIndx],m_iViewType)
			elseif m_iViewType == cardViewer.VIEW_TYPE_BASIC then
				cardInfoItemIF.updateInfo(item,m_tIdList[idIndx],nil,m_iViewType,basicInfoOffset)
			end
		else
			if m_iViewType == cardViewer.VIEW_TYPE_USER then 
				cardInfoItemIF.loadInfo(item,nil,m_tIdList[idIndx],m_iViewType)
			elseif m_iViewType == cardViewer.VIEW_TYPE_OTHERS then 
				cardInfoItemIF.loadInfo(item,nil,m_tIdList[idIndx],m_iViewType)
			elseif m_iViewType == cardViewer.VIEW_TYPE_USER_LOCK then 
				cardInfoItemIF.loadInfo(item,nil,m_tIdList[idIndx],m_iViewType)
			elseif m_iViewType == cardViewer.VIEW_TYPE_BASIC then
				cardInfoItemIF.loadInfo(item,m_tIdList[idIndx],nil,m_iViewType,basicInfoOffset)
			end
		end
	end



	local function switchIdIndx2Next()
		m_iIdIndx = m_iIdIndxNext
		m_iIdIndxNext = m_iIdIndx + 1

		if m_iIdIndxNext > #m_tIdList then 
			m_iIdIndxNext = 1
		end
	end


	local function switchIdIndx2Pre()
		m_iIdIndx = m_iIdIndx - 1
		if m_iIdIndx < 1 then 
			m_iIdIndx = 1
		end
		m_iIdIndxNext = m_iIdIndx + 1

		if m_iIdIndxNext > #m_tIdList then 
			m_iIdIndxNext = 1
		end
	end

	local function resetItemTouchState(item,idIndx)
		if not item then return end
		if m_iViewType == cardViewer.VIEW_TYPE_USER then 
			cardInfoItemIF.resetTouchState(item,nil,m_tIdList[idIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_OTHERS then 
			cardInfoItemIF.resetTouchState(item,nil,m_tIdList[idIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_USER_LOCK then 
			cardInfoItemIF.resetTouchState(item,nil,m_tIdList[idIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_BASIC then
			cardInfoItemIF.resetTouchState(item,m_tIdList[idIndx],nil,m_iViewType,basicInfoOffset)
		end
	end

	local function loackItemTouchState(item,idIndx)
		if not item then return end
		if m_iViewType == cardViewer.VIEW_TYPE_USER then 
			cardInfoItemIF.lockTouchState(item,nil,m_tIdList[idIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_OTHERS then 
			cardInfoItemIF.lockTouchState(item,nil,m_tIdList[idIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_USER_LOCK then 
			cardInfoItemIF.lockTouchState(item,nil,m_tIdList[idIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_BASIC then
			cardInfoItemIF.lockTouchState(item,m_tIdList[idIndx],nil,m_iViewType)
		end
	end

	local function checkSwitchBtns()
		if not m_pLeftBtn or not m_pRightBtn then return end
		if not m_iIdIndx or not m_iIdIndxNext then return end

		if #m_tIdList == 1 then 
			m_pLeftBtn:setTouchEnabled(false)
			m_pLeftBtn:setVisible(false)
			m_pRightBtn:setTouchEnabled(false)
			m_pRightBtn:setVisible(false)
			return 
		end
		
		if m_iIdIndx == 1 and m_iIdIndxNext > m_iIdIndx then 
			m_pLeftBtn:setTouchEnabled(false)
			m_pLeftBtn:setVisible(false)
			m_pRightBtn:setTouchEnabled(true)
			m_pRightBtn:setVisible(true)
		elseif m_iIdIndx > 1 and m_iIdIndxNext > m_iIdIndx then 
			m_pLeftBtn:setTouchEnabled(true)
			m_pLeftBtn:setVisible(true)
			m_pRightBtn:setTouchEnabled(true)
			m_pRightBtn:setVisible(true)
		elseif m_iIdIndx == #m_tIdList and m_iIdIndxNext == 1 then 
			m_pLeftBtn:setTouchEnabled(true)
			m_pLeftBtn:setVisible(true)
			m_pRightBtn:setTouchEnabled(false)
			m_pRightBtn:setVisible(false)
		else
			m_pLeftBtn:setTouchEnabled(false)
			m_pLeftBtn:setVisible(false)
			m_pRightBtn:setTouchEnabled(false)
			m_pRightBtn:setVisible(false)
		end
	end

	local function doCheckSecondSkillEffect(item)
		if m_iViewType == cardViewer.VIEW_TYPE_USER then 
			cardInfoItemIF.checkSecondSkillEffect(item,nil,m_tIdList[m_iIdIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_OTHERS then 
			cardInfoItemIF.checkSecondSkillEffect(item,nil,m_tIdList[m_iIdIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_USER_LOCK then 
			cardInfoItemIF.checkSecondSkillEffect(item,nil,m_tIdList[m_iIdIndx],m_iViewType)
		elseif m_iViewType == cardViewer.VIEW_TYPE_BASIC then
			cardInfoItemIF.checkSecondSkillEffect(item,m_tIdList[m_iIdIndx],nil,m_iViewType,basicInfoOffset)
		end
	end

	local function switchCardViewItem()
		if not m_pCardViewCurItem or not m_pCardViewNextItem then return end
		if not m_iIdIndx or not m_iIdIndxNext then return end
		local duration = 0.5
		local showItem = nil
		local hideItem = nil

		if m_pCardViewCurItem:isVisible() then 
			showItem = m_pCardViewNextItem
			hideItem = m_pCardViewCurItem
		else
			showItem = m_pCardViewCurItem
			hideItem = m_pCardViewNextItem
		end

		
		loackItemTouchState(hideItem,m_iIdIndxNext)
		uiUtil.hideScaleEffect(hideItem,function()
			hideItem:setVisible(false)
			hideItem:setTouchEnabled(false)
			hideItem:setPosition(cc.p(2000,2000))
		end,duration)

		loadCardViewItemInfo(showItem,m_iIdIndx,nil,true)

		showItem:setVisible(true)
		showItem:setTouchEnabled(true)
		showItem:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
		uiUtil.showScaleEffect(showItem,function()
			m_bIsSwitching = false
			resetItemTouchState(showItem,m_iIdIndx)
			doCheckSecondSkillEffect(showItem)
			
		end,duration)
				
	end

	

	m_pCardViewCurItem = parentLayer:getWidgetByTag(cardViewer.TAG_ID_CUR_ITEM)
	m_pCardViewNextItem = parentLayer:getWidgetByTag(cardViewer.TAG_ID_NEXT_ITEM)
	
	if not m_pCardViewCurItem then 
		m_pCardViewCurItem = cardInfoItemIF.createItem()
		m_pCardViewCurItem:setTag(cardViewer.TAG_ID_CUR_ITEM)
		m_pCardViewCurItem:setScale(config.getgScale())
		m_pCardViewCurItem:ignoreAnchorPointForPosition(false)
		m_pCardViewCurItem:setAnchorPoint(cc.p(0.5, 0.5))
		m_pCardViewCurItem:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

		parentLayer:addWidget(m_pCardViewCurItem)

		m_pLeftBtn = parentLayer:getWidgetByTag(cardViewer.TAG_ID_BTN_LEFT)
		m_pRightBtn = parentLayer:getWidgetByTag(cardViewer.TAG_ID_BTN_RIGHT)

		if m_pLeftBtn then 
			m_pLeftBtn:removeFromParentAndCleanup(true)
		end
		if m_pRightBtn then 
			m_pRightBtn:removeFromParentAndCleanup(true)
		end

		m_pLeftBtn,m_pRightBtn,m_pCloseBtn = cardInfoItemIF.getSwitchItemBtns(m_pCardViewCurItem)

	end

	if m_pCardViewCurItem then 
		m_pCardViewCurItem:setVisible(true)
	end
	
	loadCardViewItemInfo(m_pCardViewCurItem,m_iIdIndx)
	

	if m_pLeftBtn then 

		parentLayer:addWidget(m_pLeftBtn)
		m_pLeftBtn:ignoreAnchorPointForPosition(false)
		m_pLeftBtn:setScale(config.getgScale())
		m_pLeftBtn:setAnchorPoint(cc.p(0,0.5))
		m_pLeftBtn:setPosition(cc.p(
			10 , 
			config.getWinSize().height/2
		))
		m_pLeftBtn:setTouchEnabled(true)
		m_pLeftBtn:addTouchEventListener(function(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				-- cardInfoItemIF.playSkillAdvancedEffect(m_pCardViewCurItem)
				-- cardInfoItemIF.playAddPointSucceedEffect(m_pCardViewCurItem)
				-- if true then return end
				
				if m_bIsSwitching then return end
				m_bIsSwitching = true
				switchIdIndx2Pre()
				checkSwitchBtns()
				switchCardViewItem()
			end
		end)
		breathAnimUtil.start_scroll_dir_anim(m_pLeftBtn,m_pLeftBtn)
	end

	if m_pRightBtn then 
		parentLayer:addWidget(m_pRightBtn)
		m_pRightBtn:ignoreAnchorPointForPosition(false)
		m_pRightBtn:setScale(config.getgScale())
		m_pRightBtn:setAnchorPoint(cc.p(1,0.5))
		m_pRightBtn:setPosition(cc.p(
			config.getWinSize().width - 10 , 
			config.getWinSize().height/2
		))
		m_pRightBtn:setTouchEnabled(true)
		m_pRightBtn:addTouchEventListener(function(sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				if m_bIsSwitching then return end
				m_bIsSwitching = true
				switchIdIndx2Next()
				checkSwitchBtns()
				switchCardViewItem()
			end
		end)

		breathAnimUtil.start_scroll_dir_anim(m_pRightBtn,m_pRightBtn)
	end

	if m_pCloseBtn then 
		m_pCloseBtn:setTouchEnabled(true)
		m_pCloseBtn:addTouchEventListener(function(sender,eventType)
			if eventType == TOUCH_EVENT_ENDED then 
				if closeCallback then 
					dispose()
					closeCallback()
				end
			end
		end)
		m_pCloseBtn:setTag(cardViewer.TAG_ID_CLOSE_BTN)
		parentLayer:addWidget(m_pCloseBtn)
		m_pCloseBtn:ignoreAnchorPointForPosition(false)
		m_pCloseBtn:setScale(config.getgScale())
		m_pCloseBtn:setAnchorPoint(cc.p(1,1))
		m_pCloseBtn:setPosition(cc.p(
			config.getWinSize().width - 10,
			config.getWinSize().height - 10
		))
	end
	checkSwitchBtns()

	if m_iIdIndx ~= m_iIdIndxNext and (not m_pCardViewNextItem) then 
		m_pCardViewNextItem = cardInfoItemIF.createItem()
		m_pCardViewNextItem:setTag(cardViewer.TAG_ID_NEXT_ITEM)
		m_pCardViewNextItem:setScale(config.getgScale())
		m_pCardViewNextItem:ignoreAnchorPointForPosition(false)
		m_pCardViewNextItem:setAnchorPoint(cc.p(0.5, 0.5))
		m_pCardViewNextItem:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
		parentLayer:addWidget(m_pCardViewNextItem)
		cardInfoItemIF.getSwitchItemBtns(m_pCardViewNextItem,true)
		
	end

	if m_pCardViewNextItem then 
		m_pCardViewNextItem:setVisible(false)
		m_pCardViewNextItem:setTouchEnabled(false)
		loadCardViewItemInfo(m_pCardViewNextItem,m_iIdIndxNext)
		loackItemTouchState(m_pCardViewNextItem,m_iIdIndxNext)
		m_pCardViewNextItem:setPosition(cc.p(2000,2000))
	end

	if m_pCardViewCurItem then 
		resetItemTouchState(m_pCardViewCurItem,m_iIdIndx)
	end
	


	

	
	local function dataUpdator(heroUid)
		if m_bIsSwitching then return end
	
		local function dodataUpdate()
			if m_tIdList[m_iIdIndx] == heroUid then 
				if m_pCardViewCurItem:isVisible() then 
					loadCardViewItemInfo(m_pCardViewCurItem,m_iIdIndx,true)
				else
					loadCardViewItemInfo(m_pCardViewNextItem,m_iIdIndx,true)
				end
			end

			if m_tIdList[m_iIdIndxNext] == heroUid then 
				if m_pCardViewCurItem:isVisible() then 
					loadCardViewItemInfo(m_pCardViewCurItem,m_iIdIndxNext,true)
				else
					loadCardViewItemInfo(m_pCardViewNextItem,m_iIdIndxNext,true)
				end
			end
		end

		local flag_refresh_now = true

		if cardOpRequest and cardOpRequest.checkHeroAddPointSucceedEffect(heroUid) then 
			-- 配点特效
			if m_pCardViewCurItem:isVisible() then 
				cardInfoItemIF.playAddPointSucceedEffect(m_pCardViewCurItem)
			else
				cardInfoItemIF.playAddPointSucceedEffect(m_pCardViewNextItem)
			end
		end
		

		if SkillOpreateObserver.checkHeroAwakenNeedEffect(heroUid) then
			flag_refresh_now = false
			if m_pCardViewCurItem:isVisible() then
				-- 觉醒特效
				cardInfoItemIF.playSkillAwakenEffect(m_pCardViewCurItem,dodataUpdate)
			else
				cardInfoItemIF.playSkillAwakenEffect(m_pCardViewNextItem,dodataUpdate)
			end
		end
		
		local lastLearnIndx = SkillOpreateObserver.cheHeroLearnSkillNeedEffect(heroUid)
		if lastLearnIndx then 
			if m_pCardViewCurItem:isVisible() then 
				-- 学习特效
				cardInfoItemIF.playSkillLearnedSkill(m_pCardViewCurItem,lastLearnIndx)
			else
				cardInfoItemIF.playSkillLearnedSkill(m_pCardViewNextItem,lastLearnIndx)
			end
		end
		

		if SkillOpreateObserver.checkHeroAdvaceNeedEffect(heroUid) then
			-- 进阶特效
			flag_refresh_now = false
			if m_pCardViewCurItem:isVisible() then 
				cardInfoItemIF.playSkillAdvancedEffect(m_pCardViewCurItem,heroUid,dodataUpdate)
			else
				cardInfoItemIF.playSkillAdvancedEffect(m_pCardViewNextItem,heroUid,dodataUpdate)
			end
		end
	
		if flag_refresh_now then
			dodataUpdate()
		end

		SkillOpreateObserver.clearOperateEffectData()

		if cardOpRequest then 
			cardOpRequest.clearOperateEffectCheckData()
		end
	end

	local function heroCardDeleted(heroUid)
		if m_bIsSwitching then return end
		
		local isInlist = false
		local deleteIndx = 0
		for i = 1,#m_tIdList do 
			if m_tIdList[i] == heroUid then 
				isInlist = true
				deleteIndx = i
				break
			end
		end

		if not isInlist then return end

		if #m_tIdList == 1 then 
			closeCallback()
			return 
		end


		table.remove(m_tIdList,deleteIndx)
		if m_iIdIndx == deleteIndx then 
			m_iIdIndx = m_iIdIndxNext
			m_iIdIndxNext = m_iIdIndx + 1
			if m_iIdIndxNext > #m_tIdList then 
				m_iIdIndxNext = 1
			end
			loadCardViewItemInfo(m_pCardViewCurItem,m_iIdIndx)
		end

		checkSwitchBtns()
	end

	local function heroCardAdded(heroUid)

	end

	local function getMainWidget()
		if m_pCardViewCurItem:isVisible() then 
			return m_pCardViewCurItem
		else
			return m_pCardViewNextItem
		end
	end

	local function afterShow()
		doCheckSecondSkillEffect(m_pCardViewCurItem)
	end
	return dataUpdator,heroCardDeleted,heroCardAdded,dispose,getMainWidget,afterShow
end



function cardViewer.dealwithTouchEvent(x,y,m_pMainLayer)
	if not m_pMainLayer then return false end
	local m_pCardViewCurItem = m_pMainLayer:getWidgetByTag(cardViewer.TAG_ID_CUR_ITEM)
	local m_pCardViewNextItem = m_pMainLayer:getWidgetByTag(cardViewer.TAG_ID_NEXT_ITEM)
	local btnClose = m_pMainLayer:getWidgetByTag(cardViewer.TAG_ID_CLOSE_BTN)

	return (m_pCardViewCurItem and m_pCardViewCurItem:hitTest(cc.p(x,y))) 
		or (m_pCardViewNextItem and m_pCardViewNextItem:hitTest(cc.p(x,y)))
		or (btnClose and btnClose:hitTest(cc.p(x,y)))

end

function cardViewer.defaultCloseCallback()

	-- require("game/cardDisplay/cardAddPoint")
	-- cardAddPoint.remove_self()
	-- 刷新其他界面
	--[[
	if cardOverviewManager then
		cardOverviewManager.update_tb_state(true)
	end

	if cardPacketManager then
		cardPacketManager.update_tb_state(true)
	end
	--]]
end
return cardViewer












