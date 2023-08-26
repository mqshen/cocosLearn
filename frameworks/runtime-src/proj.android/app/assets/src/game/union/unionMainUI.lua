--同盟的主界面
module("UnionMainUI", package.seeall)
require("game/union/unionData")
require("game/union/unionOfficialData")
require("game/union/unionDonateUI")
require("game/union/unionMemberUI")
require("game/union/unionGovernment")
require("game/union/unionCreateMainUI")
require("game/union/unionAnnouncement")

local StringUtil = require("game/utils/string_util")
local m_pMainLayer = nil
local m_backPanel = nil
function getInstance()
	return m_pMainLayer
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	return false
end

local function do_remove_self( )
	UnionData.remove()
	UnionDonateUI.remove_self()
	UnionMemberUI.remove_self()
	UnionAnnouncement.remove_self()
	-- UnionGovernment.remove_self()
	if m_pMainLayer then
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UNION_MAIN_UI)

		--[[
		if rankingManager then
			rankingManager.set_drag_state(true)
		end
		--]]
		UIUpdateManager.remove_prop_update(dbTableDesList.union_apply_notice.name, dataChangeType.update, UnionMainUI.refreshNotice)
	end
end

function remove_self(closeEffect)
	if closeEffect then
		do_remove_self()
		return
	end
    if not m_backPanel then return end
    uiManager.hideConfigEffect(uiIndexDefine.UNION_MAIN_UI,m_pMainLayer,do_remove_self,999,{m_backPanel:getMainWidget()})
    -- uiUtil.hideScaleEffect(m_backPanel:getMainWidget(),do_remove_self,uiUtil.DURATION_FULL_SCREEN_HIDE)
end

local function initUnionAbility( )
	local unionInfo = UnionData.getUnionInfo()
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end
	local title = tolua.cast(widget:getChildByName("Panel_228952"),"Layout")
	title:setVisible(false)

	local widget = m_pMainLayer:getWidgetByTag(999)
	local noticLabel = tolua.cast(widget:getChildByName("Label_23598_0"),"Label")
	--没有同盟加成显示
	local no_noticLabel = tolua.cast(noticLabel:getChildByName("Label_542446"),"Label")
	no_noticLabel:setVisible(false)

	--每个单项
	local cell = tolua.cast(widget:getChildByName("Panel_228949"),"Layout")
	cell:setVisible(false)

	local image = tolua.cast(widget:getChildByName("ImageView_191477_0_0"),"ImageView")
	local panel = tolua.cast(image:getChildByName("Panel_238132"),"Layout")
	panel:removeAllChildrenWithCleanup(true)

	if unionInfo.level and unionInfo.level > 0 then
		local height = 0
		local count = 0
		local arrUnionAdd = {}
		height = height + title:getSize().height
		local des = {union_add_defined["exp_add"],
				union_add_defined["wood_npc_add"],union_add_defined["iron_npc_add"],
				union_add_defined["stone_npc_add"],
				union_add_defined["food_npc_add"]}
		local des2 = {"exp_add","wood_add","stone_add","iron_add","food_add"}
		for i=1, 5 do
			if Tb_cfg_union_level[unionInfo.level][des2[i]] ~= 0 then
				if i == 1 then
					count = count + 2
					table.insert(arrUnionAdd, {index = 1, title =des[i].." +".. Tb_cfg_union_level[unionInfo.level][des2[i]].."%"})
				else
					count = count + 1
					table.insert(arrUnionAdd, {index = count, title =des[i].." +".. Tb_cfg_union_level[unionInfo.level][des2[i]].."%"})
				end
			end
		end

		height = height + math.ceil(count/2)*cell:getSize().height

		local flag = false
		local _count = 0
		if unionInfo.union_add then
			for i, v in pairs(unionInfo.union_add) do
				if v ~= 0 then
					flag = true
					_count = _count + 1
					-- break
				end

				if i==4 and _count%2 == 1 then
					_count = _count + 1
				end
			end
		end

		if flag then
			height = height + title:getSize().height
			height = height + math.ceil(_count/2)*cell:getSize().height
		end
		
		local layer = TouchGroup:create()
		layer:setContentSize(CCSize(panel:getSize().width, height))

		local pScrollView = CCScrollView:create()
		local function scrollViewDidScroll(table)
	        if pScrollView:getContentOffset().y < 0 then
	            tolua.cast(image:getChildByName("ImageView_220881"),"ImageView" ):setVisible(true)
	        else
	            tolua.cast(image:getChildByName("ImageView_220881"),"ImageView" ):setVisible(false)
	        end

	        if pScrollView:getContentSize().height + pScrollView:getContentOffset().y > pScrollView:getViewSize().height then
	            tolua.cast(image:getChildByName("ImageView_372344"),"ImageView" ):setVisible(true)
	        else
	            tolua.cast(image:getChildByName("ImageView_372344"),"ImageView" ):setVisible(false)
	        end
	    end
	    tolua.cast(image:getChildByName("ImageView_220881"),"ImageView" ):setVisible(false)
	    tolua.cast(image:getChildByName("ImageView_372344"),"ImageView" ):setVisible(false)

		pScrollView:registerScriptHandler(scrollViewDidScroll,CCScrollView.kScrollViewScroll)
		pScrollView:setViewSize(CCSize(panel:getSize().width, panel:getSize().height))
        pScrollView:setContainer(layer)
        pScrollView:updateInset()
        pScrollView:setDirection(kCCScrollViewDirectionVertical)
        pScrollView:setClippingToBounds(true)
        pScrollView:setBounceable(false)
        pScrollView:setContentOffset(cc.p(0,-height+pScrollView:getViewSize().height))
        panel:addChild(pScrollView)
        -- pScrollView:setPosition(cc.p(-panel:getSize().width/2, -panel:getSize().height/2))

		local pTempTitle = title:clone()
		if unionInfo.union_id == userData.getUnion_id() and userData.getAffilated_union_id() ~= 0 then
			pTempTitle:setOpacity(100)
		else
			pTempTitle:setOpacity(255)
		end
		pTempTitle:setAnchorPoint(cc.p(0,1))
		layer:addWidget(pTempTitle)
		pTempTitle:setVisible(true)
		pTempTitle:setPosition(cc.p(0,height))
		tolua.cast(pTempTitle:getChildByName("Label_228948"),"Label"):setText(languagePack["tongmengjiacheng"])
		height = height - pTempTitle:getSize().height
		local pTemp = nil

		if #arrUnionAdd > 0 then
			no_noticLabel:setVisible(false)
		else
			no_noticLabel:setVisible(true)
		end

		for i, v in ipairs(arrUnionAdd) do
			if v.index%2 == 1 then
				pTemp = cell:clone()
				if unionInfo.union_id == userData.getUnion_id() and userData.getAffilated_union_id() ~= 0 then
					pTemp:setOpacity(100)
				else
					pTemp:setOpacity(255)
				end
				pTemp:setAnchorPoint(cc.p(0,1))
				layer:addWidget(pTemp)
				pTemp:setVisible(true)
				tolua.cast(pTemp:getChildByName("Label_228950"),"Label"):setText(v.title)
				pTemp:setPosition(cc.p(0,height))
				height = height - cell:getSize().height
			else
				tolua.cast(pTemp:getChildByName("Label_228951"),"Label"):setText(v.title)
			end
		end

		local add_des = {
						"wood_npc_add",
						"iron_npc_add",
						"stone_npc_add",
						"food_npc_add",
						"money_npc_add",
						"gong_attack_add",
						"gong_defend_add",
						"gong_intel_add",
						"qiang_attack_add",
						"qiang_defend_add",
						"qiang_intel_add",
						"qi_attack_add",
						"qi_defend_add",
						"qi_intel_add",}
		if flag then
			local pTempTitle = title:clone()
			if unionInfo.union_id == userData.getUnion_id() and userData.getAffilated_union_id() ~= 0 then
				pTempTitle:setOpacity(100)
			else
				pTempTitle:setOpacity(255)
			end
			pTempTitle:setAnchorPoint(cc.p(0,1))
			layer:addWidget(pTempTitle)
			pTempTitle:setVisible(true)
			pTempTitle:setPosition(cc.p(0,height))
			tolua.cast(pTempTitle:getChildByName("Label_228948"),"Label"):setText(languagePack["tongmengjudianjiacheng"])
			height = height - pTempTitle:getSize().height

			local iCount = 0
			local pTemp = nil
			local _de = nil
			local add_flag = false
			for i, v in ipairs(unionInfo.union_add) do
				if union_add_defined[add_des[i]] and unionInfo.union_add and v ~= 0 then
					no_noticLabel:setVisible(false)
					add_flag = true
					iCount = iCount + 1
					if add_des[i] == "wood_npc_add" or add_des[i] == "stone_npc_add" or add_des[i] == "iron_npc_add" 
						or add_des[i] == "food_npc_add" or add_des[i] == "money_npc_add" then
						_de = union_add_defined[add_des[i]].." +".. v
					else
						_de = union_add_defined[add_des[i]].." +".. v/100
					end
					if iCount%2 == 1 then
						pTemp = cell:clone()
						if unionInfo.union_id == userData.getUnion_id() and userData.getAffilated_union_id() ~= 0 then
							pTemp:setOpacity(100)
						else
							pTemp:setOpacity(255)
						end
						pTemp:setAnchorPoint(cc.p(0,1))
						layer:addWidget(pTemp)
						pTemp:setVisible(true)
						tolua.cast(pTemp:getChildByName("Label_228950"),"Label"):setText(_de)
						pTemp:setPosition(cc.p(0,height))
						height = height - cell:getSize().height
					else
						tolua.cast(pTemp:getChildByName("Label_228951"),"Label"):setText(_de)
					end

				end

				if i == 4 and iCount%2 == 1 then
					iCount = iCount + 1
				end
			end
			if not add_flag then
				no_noticLabel:setVisible(true)
			end
		end
	end
end

function initUI( )
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end
	local unionInfo = UnionData.getUnionInfo()
	local unionName = tolua.cast(widget:getChildByName("Label_23596"),"Label")
	local leaderName = tolua.cast(widget:getChildByName("Label_23598"),"Label")
	local memberCount = tolua.cast(widget:getChildByName("Label_19204_0"),"Label")
	local level = tolua.cast(widget:getChildByName("Label_23596_0_3"),"Label")
	local exp = tolua.cast(widget:getChildByName("Label_19204_0_0"),"Label")
	-- local underMember = tolua.cast(widget:getChildByName("Label_19204_0_0_0"),"Label")
	-- local buildingCount = tolua.cast(widget:getChildByName("Label_19204_0_0_1"),"Label")
	local noticLabel = tolua.cast(widget:getChildByName("Label_23598_0"),"Label")
	--没有公告的时候显示
	local no_noticLabel = tolua.cast(noticLabel:getChildByName("Label_542446_0"),"Label")
	no_noticLabel:setVisible(false)

	--没有同盟加成显示
	local no_adding = tolua.cast(noticLabel:getChildByName("Label_542446"),"Label")
	no_adding:setVisible(false)

	--被附属的图片
	local affilatedImage = tolua.cast(widget:getChildByName("ImageView_227232"),"ImageView")
	affilatedImage:setVisible(false)

	--成员按钮
	local memberBtn = tolua.cast(widget:getChildByName("Button_19090"),"Button")
	memberBtn:setVisible(false)
	memberBtn:setTouchEnabled(false)
	local memberBtn_flag = uiUtil.getConvertChildByName(memberBtn,"ImageView_349093_0")
	memberBtn_flag:setTouchEnabled(false)

	--战报按钮
	local ribaoBtn = tolua.cast(widget:getChildByName("Button_19090_0_0"),"Button")
	ribaoBtn:setVisible(false)
	ribaoBtn:setTouchEnabled(false)

	--日志
	local log_btn = tolua.cast(widget:getChildByName("log_btn"), "Button")
	log_btn:setVisible(false)
	log_btn:setTouchEnabled(false)

	--治所按钮
	local zhisuoBtn = tolua.cast(widget:getChildByName("Button_19090_0_0_0"),"Button")
	zhisuoBtn:setVisible(false)
	zhisuoBtn:setTouchEnabled(false)
	local zhisuoBtn_flag = uiUtil.getConvertChildByName(zhisuoBtn,"ImageView_353662")
	zhisuoBtn_flag:setTouchEnabled(false)

	--管理按钮
	local guanliBtn = tolua.cast(widget:getChildByName("Button_212622_3"),"Button")
	guanliBtn:setVisible(false)
	guanliBtn:setTouchEnabled(false)

	local guanliBtnNotice = tolua.cast(guanliBtn:getChildByName("img_notice"),"ImageView")
	guanliBtnNotice:setVisible(false)
	guanliBtnNotice:setTouchEnabled(false)


	--申请加入按钮
	local applyBtn = tolua.cast(widget:getChildByName("Button_227233"),"Button")
	applyBtn:setVisible(false)
	applyBtn:setTouchEnabled(false)
	--取消申请加入按钮
	local applyBtn_cancel = tolua.cast(widget:getChildByName("Button_237636_0"),"Button")
	applyBtn_cancel:setVisible(false)
	applyBtn_cancel:setTouchEnabled(false)

	--经验值进度条
	local loading = tolua.cast(widget:getChildByName("LoadingBar_52519"),"LoadingBar")

	--捐赠按钮
	local donateBtn = tolua.cast(widget:getChildByName("Button_23611"),"Button")
	donateBtn:setTouchEnabled(false)

	-- 捐献按钮底纹背景
	local donateBtnBg = tolua.cast(widget:getChildByName("ImageView_349093"),"ImageView")
	donateBtnBg:setTouchEnabled(false)


	--反叛按钮
	-- local fanpanBtn = tolua.cast(widget:getChildByName("Button_353666"),"Button")
	-- fanpanBtn:setEnabled(false)


	local noticePanel = tolua.cast(widget:getChildByName("ImageView_191477_0_0_0"),"ImageView")

	--公告板的编辑按钮
	local editBtn = tolua.cast(noticePanel:getChildByName("Button_220885"),"Button")
	editBtn:setVisible(false)
	editBtn:setTouchEnabled(false)

	--显示不能享受同盟加成的panel
	local notenablePanel = tolua.cast(widget:getChildByName("Panel_227230"),"Layout")
	notenablePanel:setVisible(false)

	--查看盟主信息按钮
	local leaderBtn = tolua.cast(widget:getChildByName("Button_227227"),"Button")
	leaderBtn:addTouchEventListener(function ( sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			UIRoleForcesMain.create(unionInfo.leader_id)
		end
	end)

	--查看同盟势力按钮
	-- local powerBtn = tolua.cast(widget:getChildByName("Button_227228"),"Button")
	-- powerBtn:addTouchEventListener(function ( sender, eventType )
	-- 	if eventType == TOUCH_EVENT_ENDED then
	-- 		require("game/union/unionPowerUI")
	-- 		UnionPowerUI.create()
	-- 	end
	-- end)

	--所属洲
	local state = stateData.getStateNameById(unionInfo.region)
	if state then
		tolua.cast(widget:getChildByName("Label_220101_0_0_0"),"Label"):setText(state)
	end

	--势力
	tolua.cast(widget:getChildByName("Label_212674_2_0_0"),"Label"):setText(unionInfo.power)


	donateBtn:setTouchEnabled(true)
	donateBtn:setVisible(true)

	donateBtnBg:setTouchEnabled(true)
	donateBtnBg:setVisible(true)
	-- if unionInfo.union_id  == userData.getUnion_id() and userData.getAffilated_union_id() == 0 then
	-- 	-- 未被附属 可以捐献
	-- 	donateBtn:setTouchEnabled(true)
	-- 	donateBtn:setVisible(true)
	-- else
	-- 	if userData.getAffilated_union_id() == 0 or userData.getAffilated_union_id() ~= unionInfo.union_id then
	-- 		donateBtn:setTouchEnabled(false)
	-- 		donateBtn:setVisible(false)
	-- 	else
	-- 		-- donateBtn:setTitleText(languagePack["fanpan"])
	-- 		-- donateBtn:setTouchEnabled(true)
	-- 		-- donateBtn:setVisible(true)
	-- 		-- fanpanBtn:setEnabled(true)
	-- 	end
	-- end

	local flag_is_others = false
	if unionInfo.union_id  ~= userData.getUnion_id() or 
		(userData.getAffilated_union_id() ~= 0 and userData.getAffilated_union_id() ~= unionInfo.union_id) then 
		donateBtn:setTouchEnabled(false)
		donateBtn:setVisible(false)

		donateBtnBg:setTouchEnabled(false)
		donateBtnBg:setVisible(false)

		flag_is_others = true
	end
	donateBtn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			if userData.getAffilated_union_id() ~= 0 then
				-- UnionDonateUI.create(false)
				tipsLayer.create(errorTable[188])
			elseif userData.getUserForcesPower() < UNION_DONATE_POWER then
				tipsLayer.create(errorTable[304],nil,{UNION_DONATE_POWER})
			else
				UnionDonateUI.create(true)
			end 
			-- m_pMainLayer:setVisible(false)
		end
	end)
	
	donateBtnBg:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			if userData.getAffilated_union_id() ~= 0 then
				-- UnionDonateUI.create(false)
				tipsLayer.create(errorTable[188])
			elseif userData.getUserForcesPower() < UNION_DONATE_POWER then
				tipsLayer.create(errorTable[304],nil,{UNION_DONATE_POWER})
			else
				UnionDonateUI.create(true)
			end 
			-- m_pMainLayer:setVisible(false)
		end
	end)

	local levelNext = unionInfo.level + 1
	if not Tb_cfg_union_level[unionInfo.level+1] then
		levelNext = unionInfo.level
	end

	unionName:setText(unionInfo.name)
	leaderName:setText(unionInfo.union_leader_name)
	if Tb_cfg_union_level[unionInfo.level] then
		if flag_is_others then 
			memberCount:setText(unionInfo.total_member)
		else
			memberCount:setText(unionInfo.total_member.."/"..Tb_cfg_union_level[unionInfo.level].people_max)
		end
		loading:setPercent(100*unionInfo.exp/Tb_cfg_union_level[levelNext].exp)
	else
		memberCount:setText(unionInfo.total_member)
	end
	level:setText("Lv."..unionInfo.level)

	exp:setText(unionInfo.exp.."/"..Tb_cfg_union_level[levelNext].exp)
	-- underMember:setText(unionInfo.under_number)
	-- buildingCount:setText(unionInfo.area_number)
	noticLabel:setText(unionInfo.notice)
	if StringUtil.isEmptyStr(unionInfo.notice)then
		no_noticLabel:setVisible(true)
	end

	--自己同盟页面的时候
	if unionInfo.union_id == userData.getUnion_id() then
		ribaoBtn:setVisible(true)
		ribaoBtn:setTouchEnabled(true)

		log_btn:setVisible(true)
		log_btn:setTouchEnabled(true)

		zhisuoBtn:setVisible(true)
		zhisuoBtn:setTouchEnabled(true)
		zhisuoBtn_flag:setTouchEnabled(true)

		memberBtn:setVisible(true)
		memberBtn:setTouchEnabled(true)
		memberBtn_flag:setTouchEnabled(true)

		if userData.getAffilated_union_id() ~= 0 then
			notenablePanel:setVisible(true)
		end

		
		if userData.getUserId() == unionInfo.leader_id or userData.getUserId() == unionInfo.vice_leader_id then
			
			

			editBtn:setVisible(true)
			editBtn:setTouchEnabled(true)

			editBtn:addTouchEventListener(function ( sender, eventType )
				if eventType == TOUCH_EVENT_ENDED then
					-- if userData.getAffilated_union_id() == 0 then
						
					-- 	UnionAnnouncement.create(noticLabel:getStringValue())
					-- else
					-- end
					UnionAnnouncement.create(noticLabel:getStringValue())
				end
			end)

			
			
		end
		
		--管理按钮的操作
		-- 改成所有成员都能查看管理系统
		guanliBtn:setVisible(true)
		guanliBtn:setTouchEnabled(true)
		guanliBtn:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				-- if userData.getAffilated_union_id() == 0 then
					UnionOfficialManagement.create(unionInfo.union_id)
				-- else
				-- end
			end
		end)

		memberBtn:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				require("game/union/unionMemberUI")
				UnionMemberUI.create()
			end
		end)
		memberBtn_flag:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				require("game/union/unionMemberUI")
				UnionMemberUI.create()
			end
		end)

		log_btn:addTouchEventListener(function (sender, eventType)
			if eventType == TOUCH_EVENT_ENDED then
				require("game/union/unionLogManager")
            	unionLogManager.on_enter()
			end
		end)
		ribaoBtn:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				reportUI.create(2,0)
			end
		end)
		zhisuoBtn:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				UnionGovernment.create(unionInfo.union_id)
			end
		end)
		zhisuoBtn_flag:addTouchEventListener(function (sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				UnionGovernment.create(unionInfo.union_id)
			end
		end)
	else
		--进入了被附属的同盟
		if unionInfo.union_id == userData.getAffilated_union_id() then
			affilatedImage:setVisible(true)
		else
			-- applyBtn:setVisible(true)
			-- applyBtn:setTouchEnabled(true)

			local applySend = false
			local cancelSend = false
			if unionInfo.applyed == 0 then
				if userData.getUnion_id() == 0 then
					applyBtn:setVisible(true)
					applyBtn:setTouchEnabled(true)
					applyBtn:addTouchEventListener(function (sender, eventType )
						if eventType == TOUCH_EVENT_ENDED then
							--申请加入同盟
							if applySend then 
								tipsLayer.create(errorTable[135])
							else
								UnionData.requestJoinUnion(UnionData.getUnionId())
								applySend = true
							end
						end
					end)
				end
			else
				applyBtn_cancel:setVisible(true)
				applyBtn_cancel:setTouchEnabled(true)
				applyBtn_cancel:addTouchEventListener(function (sender, eventType )
					if eventType == TOUCH_EVENT_ENDED then
						if cancelSend then 
							tipsLayer.create(errorTable[153])
						else
							UnionData.requestDeleteJoinUnion(UnionData.getUnionId())
							cancelSend = true
						end
					end
				end)
			end
			
		end
	end

	initUnionAbility()
	UnionMainUI.refreshNotice()
end

function setLayerVisible( flag )
	-- if m_pMainLayer then
	-- 	m_pMainLayer:setVisible(flag)
	-- end
end

function setTouchEnable( flag )
	-- if m_pMainLayer then
	-- 	local widget = m_pMainLayer:getWidgetByTag(999)
	-- 	if not widget then return end
	-- 	local panel = tolua.cast(widget:getChildByName("Panel_23643"),"Layout")
	-- 	local tableview = panel:getNodeByTag(1)
	-- 	if tableview then
	-- 		tableview:setTouchEnabled(flag)
	-- 	end
	-- end
end

function reload( )
	UnionData.requestUnionInfo()
end

-- UI上的一些状态提示更新（如 管理按钮的红点）
function refreshNotice()
	if not m_pMainLayer then return end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end

	--管理按钮
	local guanliBtn = tolua.cast(widget:getChildByName("Button_212622_3"),"Button")
	if guanliBtn:isVisible() then 
		-- 是否有新的同盟申请
		local guanliBtnNotice = tolua.cast(guanliBtn:getChildByName("img_notice"),"ImageView")
		if userData.hasNewUnionApply() then
			guanliBtnNotice:setVisible(true)
		else
			guanliBtnNotice:setVisible(false)
		end
	end

end

function create(union_id)
	require("game/config/buildingEffectDefined")
	if m_pMainLayer then return end
	UnionData.initData()
	UnionData.setUnionId(union_id)
	m_pMainLayer = TouchGroup:create()
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UNION_MAIN_UI)
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_home_nw_4.json")
	m_backPanel = UIBackPanel.new()
	local temp = m_backPanel:create(widget, remove_self, panelPropInfo[uiIndexDefine.UNION_MAIN_UI][2])
	m_pMainLayer:addWidget(temp)
	widget:setTag(999)
	local image = tolua.cast(widget:getChildByName("ImageView_191477_0_0"),"ImageView")
	tolua.cast(image:getChildByName("ImageView_220881"),"ImageView" ):setVisible(false)
	tolua.cast(image:getChildByName("ImageView_372344"),"ImageView" ):setVisible(false)
	UnionData.requestUnionInfo()

	UIUpdateManager.add_prop_update(dbTableDesList.union_apply_notice.name, dataChangeType.update, UnionMainUI.refreshNotice)
	uiManager.showConfigEffect(uiIndexDefine.UNION_MAIN_UI,nil,999,{m_backPanel:getMainWidget()})
end
