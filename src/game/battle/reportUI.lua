local mLayer = nil
local mWidget = nil
local panel = nil
local tableView = nil
local m_ptouchLayer = nil
local isAddData = nil --是否刷新战报
local isClick = nil --是否点击下拉或上拉框
local sortWay = {all =1, attack = 2, defend = 3}
local touchPoint = nil
local m_fScheduler = nil
local m_backPanel = nil
local m_pWidget = nil
local releaseColor = ccc3(155,158,158)
local pressColor = ccc3(190,204,200)
local m_x, m_y = nil, nil


--同盟战报还是自己的战报 1 自己战报 2 同盟战报
-- local m_iReportType = 1
local function createReportInfoUI( report, attack_userid, defend_userid,id)
	local detail,info = reportInfo.analyze(report,attack_userid, defend_userid, id)
	local scrollView = detailReport.create(detail,id,info)
	if scrollView then
		reportUI.setVisible(false)
	end

	local function open( )
		detailReport.initUI(detail)
		scheduler.remove(m_fScheduler)
		m_fScheduler = nil
	end
	
	if scrollView then
		m_fScheduler = scheduler.create(open,0.1)
	end
end

local function openListWar(idx )
	isClick = reportData.getPanelLenght(reportData.getReportShowNums()) + tableView:getContentOffset().y
    reportData.openOrCloseCell( idx + 1)
end

local function refreshAllCell( )
	if tableView and reportData.getReportShowNums() > 0 then
		local report = nil
		local cell = nil
		for i=1 ,reportData.getReportShowNums() do
			cell = tableView:cellAtIndex(i-1)
			if cell then
				local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
				if layer then
					local widget = layer:getWidgetByTag(1)
					if widget then
						report = reportData.getReportListDataByidx(cell:getIdx()+1 )
						if report then
							if report.count then
								if reportData.getReportType() == 1 or reportData.getReportType() == 4 then
									ReportCell.create(tolua.cast(widget,"Layout"), cell:getIdx(), panel)
								else
									WarReportUnionCell.create(tolua.cast(widget,"Layout"), cell:getIdx(), panel)
								end
							else
								ReporSmalltCell.create(tolua.cast(widget,"Layout"), cell:getIdx(), report.index)
							end
						end
					end
				end
			end
		end
	end
end

local function tableCellTouched(table,cell)
	local battleReport = reportData.getReportDataByIndex(cell:getIdx())
	if not battleReport then return end
	
	newGuideInfo.enter_next_guide()

	local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    local report = reportData.getReportListDataByidx(cell:getIdx()+1 )
    -- if battleReport then
		if battleReport.report then
			createReportInfoUI(battleReport.report,battleReport.attack_userid,battleReport.defend_userid, battleReport.battle_id)
		else
			reportData.requestReportMsgById(battleReport.battle_id)
		end

	    if layer then
	    	if layer:getWidgetByTag(1) then
	    		if report.count then
	    			if reportData.getReportType() == 1 or reportData.getReportType() == 4 then
	    				ReportCell.create(tolua.cast(layer:getWidgetByTag(1),"Layout"), cell:getIdx(), panel)
	    			else
	    				WarReportUnionCell.create(tolua.cast(layer:getWidgetByTag(1),"Layout"), cell:getIdx(), panel)
	    			end
	    		else
	    			ReporSmalltCell.create(tolua.cast(layer:getWidgetByTag(1),"Layout"), cell:getIdx(), report.index)
	    			--刷新未读战报数
	    			local temp_cell = tableView:cellAtIndex(math.floor(report.index/10000)-1)
	    			if temp_cell then
	    				local temp_layer = tolua.cast(temp_cell:getChildByTag(123),"TouchGroup")
	    				if temp_layer then
	    					ReportCell.create(tolua.cast(temp_layer:getWidgetByTag(1),"Layout"), temp_cell:getIdx(), panel)
	    				end
	    			end
	    		end
	    	end
	    end
	-- end
end

local function cellSizeForTable(table,idx)
    return reportData.getCellSize(idx+1)
end

local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local report = reportData.getReportListDataByidx(idx+1 )
    if nil == cell then
    	cell = CCTableViewCell:new()
    	local layer = TouchGroup:create()
    	if not m_pWidget then
    		if reportData.getReportType() == 1 or reportData.getReportType() == 4 then
				m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/new_report_interface_0.json")
			else
				m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/new_report_interface_union.json")
			end
		else
			m_pWidget = m_pWidget:clone()
		end
	    tolua.cast(m_pWidget,"Layout")
	    layer:addWidget(m_pWidget)
	    m_pWidget:setTag(1)
	    cell:addChild(layer)
	    layer:setTag(123)
    end

    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	local widget = layer:getWidgetByTag(1)
    	if widget then
    		if report then
	    		if report.count then
	    			if reportData.getReportType() == 1 or reportData.getReportType() == 4 then
			    		ReportCell.create(widget, idx, panel)
			    	else
			    		WarReportUnionCell.create(widget, idx, panel)
			    	end
			    else
			    	ReporSmalltCell.create(widget, idx, report.index)
			    end
			end
    	end
    end

    return cell
end

local function scrollViewDidScroll(table)
	if table:getContentOffset().y < 0 then
		tolua.cast(mWidget:getChildByName("ImageView_209575"),"ImageView" ):setVisible(true)
	else
		tolua.cast(mWidget:getChildByName("ImageView_209575"),"ImageView" ):setVisible(false)
	end

	if table:getContentSize().height + table:getContentOffset().y >1+table:getViewSize().height then
		tolua.cast(mWidget:getChildByName("ImageView_209575_0"),"ImageView" ):setVisible(true)
	else
		tolua.cast(mWidget:getChildByName("ImageView_209575_0"),"ImageView" ):setVisible(false)
	end
end

local function numberOfCellsInTableView(table)
	return reportData.getReportShowNums()
end

-- 只删除界面，不删除数据
local function remove_self_only( )
    if mLayer then
        if m_backPanel then
            m_backPanel:remove()
            m_backPanel = nil
        end

        mLayer:removeAllChildrenWithCleanup(true)
        cardTextureManager.remove_cache()
    end
end

local function do_remove_self(  )
	if mLayer then
		detailReport.remove_self()
		BattleAnimationController.remove_self()
		config.removeAnimationFile()
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end
		mLayer:removeFromParentAndCleanup(true)
		mLayer = nil
		m_pWidget = nil
		mWidget  = nil
		panel = nil
		tableView = nil
		isAddData = nil
		isClick = nil
		m_ptouchLayer = nil
		touchPoint = nil
		m_x = nil
		m_y = nil
		-- m_iReportType = 1
		-- config.removeAnimationFile()
		reportData.remove()
		if m_fScheduler then
			scheduler.remove(m_fScheduler)
			m_fScheduler = nil
		end
		UnionMainUI.setLayerVisible(true)
		
		uiManager.remove_self_panel(uiIndexDefine.REPORT_UI)
	end
end

local function remove_self()
    if not m_backPanel then
    	do_remove_self()
    	cardTextureManager.remove_cache()
    	return
    end
    -- uiUtil.hideScaleEffect(m_backPanel:getMainWidget(),do_remove_self,uiUtil.DURATION_FULL_SCREEN_HIDE)
    uiManager.hideConfigEffect(uiIndexDefine.REPORT_UI,mLayer,do_remove_self,999,{m_backPanel:getMainWidget()})
end

local function setBtnBling(flag)
	--[[
	if flag and openBtn then
		openBtn:stopAllActions()
		local action = CCRepeatForever:create(animation.sequence({CCFadeOut:create(0.5), CCFadeIn:create(0.5)}))
		openBtn:runAction(action)
	elseif (not flag) and openBtn then
		openBtn:stopAllActions()
		openBtn:setOpacity(255)
	end
	--]]
end

local function dealwithTouchEvent(x, y )
 	if not mLayer then
		return false
	end

	-- if mWidget:hitTest(cc.p(x,y)) then
		return false
	-- else
		-- remove_self()
		-- return true
	-- end
end

local function onTouchBegan(x,y)
	touchPoint = nil
	touchPoint = {x = x, y= y}
	return true
end

local function onTouchEnded( x,y )
	local count = nil
	if not touchPoint or not touchPoint.x or not touchPoint.y then
		return true 
	end

	if y - touchPoint.y > 100*config.getgScale() and 100*config.getgScale() <= tableView:getContentOffset().y and reportData.getReportShowNums()> 0 then
		count = reportData.getReportShowNums()-1
		-- if reportData.getReportDataByIndex(count) then
			isAddData = reportData.getPanelLenght(count)
		-- end
	end

	local timer = nil

	local function callback( )
		scheduler.remove(timer)
		if reportData.getReportDataByIndex(count) then
			reportData.requestMoreReportByType(reportData.getSortWay(), reportData.getReportDataByIndex(count).battle_id)
		end
	end

	if isAddData then
		loadingLayer.create(999)
		timer =scheduler.create(callback,1)
	end
end

local function onTouch( eventType, x,y)
	m_x = x
	m_y = y
	if detailReport.getInstance() then return true end
	if not panel then return true end
	if not panel:hitTest(cc.p(x,y)) then return true end
	if eventType == "began" then
		return onTouchBegan(x,y)
    elseif eventType == "ended" then
    	return onTouchEnded(x,y)
    else
    	return true
    end
end

local function refreshReadReportBtn( )
	if not mWidget then return end
	local readBtn = tolua.cast(mWidget:getChildByName("readImage"),"ImageView")
	if (not reportData.getReportType() or reportData.getReportType() == 1 or reportData.getReportType() == 4) and reportData.getIfUnreadReport() then
		readBtn:setVisible(true)
		readBtn:setTouchEnabled(true)
		readBtn:addTouchEventListener(function (sender,eventType )
	        if eventType == TOUCH_EVENT_ENDED then
	        	reportData.requestAllReportRead()
	        end
	        readBtn:setVisible(false)
			readBtn:setTouchEnabled(false)
	    end)
	else
		readBtn:setVisible(false)
		readBtn:setTouchEnabled(false)
	end
end

--pageIndex 0 全部 1攻击 2 防守 3 未读
local function create(report_type, pageIndex)
	-- require("game/battle/battleAnimationUI")
	require("game/battle/battleAnimation")
	require("game/battle/battleAnimationController")
	require("game/battle/battleAnalyse")
	require("game/battle/battleAnimationData")
	require("game/battle/warReportCell")
	require("game/battle/warReportSmallCell")
	require("game/battle/warReportUnionCell")
	require("game/battle/warReportUnionSmallCell")
	-- require("game/battle/battleAction")
	require("game/battle/actionDefine")
	require("game/dbData/client_cfg/animation_Music_cfg_info")
	if mLayer then return end
	local _type = report_type or 1
	reportData.initData(_type)
	m_fScheduler = nil
	mLayer = TouchGroup:create()
	mWidget = GUIReader:shareReader():widgetFromJsonFile("test/new_report_interface.json")
	mWidget:setTag(999)

	local label_null = uiUtil.getConvertChildByName(mWidget,"label_null")
	label_null:setVisible(false)

	m_backPanel = UIBackPanel.new()
	local title_name = panelPropInfo[uiIndexDefine.REPORT_UI][2]
	if report_type == 2 then
		title_name = languagePack["tongmengzhanbao"]
		label_null:setText(languagePack["reportEmptyTipsUnion"])
	else
		label_null:setText(languagePack["reportEmptyTips"])
	end



	local temp = m_backPanel:create(mWidget, remove_self, title_name, false, true)
	mLayer:addWidget(temp)

	-- if _type ~= 4 then
		refreshReadReportBtn()
	-- end
	

	local checkBoxArray = {}
	local checkBox_all = tolua.cast(mWidget:getChildByName("CheckBox_31657"),"CheckBox")
	table.insert(checkBoxArray, checkBox_all)
	local checkBox_att = tolua.cast(mWidget:getChildByName("CheckBox_31655"),"CheckBox")
	table.insert(checkBoxArray, checkBox_att)
	local checkBox_def = tolua.cast(mWidget:getChildByName("CheckBox_31659"),"CheckBox")
	table.insert(checkBoxArray, checkBox_def)
	local checkBox_unread = tolua.cast(mWidget:getChildByName("CheckBox_31661"),"CheckBox")

	checkBox_unread:setVisible(false)
	checkBox_unread:setTouchEnabled(false)

	local page = pageIndex or 0
	reportData.setSortWay(page)
	checkBoxArray[page+1]:setSelectedState(true)
	checkBoxArray[page+1]:setTouchEnabled(false)

	for i, v in ipairs(checkBoxArray) do
		if _type == 4 then
			v:setVisible(false)
			v:setTouchEnabled(false)
		else
			v:addEventListenerCheckBox(function ( sender, eventType )
				if eventType == CHECKBOX_STATE_EVENT_SELECTED then
					v:setTouchEnabled(false)
					v:setSelectedState(true)
					tolua.cast(v:getChildByTag(1),"Label"):setColor(pressColor)
					reportData.setSortWay(i-1)
					for m,n in ipairs(checkBoxArray) do
						if m ~= i then
							n:setSelectedState(false)
							n:setTouchEnabled(true)
							tolua.cast(n:getChildByTag(1),"Label"):setColor(releaseColor)
						end
					end
					reportData.requestReportByType(i-1, 0)
				elseif eventType == CHECKBOX_STATE_EVENT_UNSELECTED then
				end
			end)
		end
	end

	local back = tolua.cast(mWidget:getChildByName("ImageView_23592_0_0"),"ImageView" )
	local arrow = tolua.cast(mWidget:getChildByName("ImageView_209575"),"ImageView" )
	local up_arrow = tolua.cast(mWidget:getChildByName("ImageView_209575_0"),"ImageView" )
	up_arrow:setVisible(false)

	breathAnimUtil.start_anim(arrow, true, 76, 255, 1, 0)
	breathAnimUtil.start_anim(up_arrow, true, 76, 255, 1, 0)

	panel = tolua.cast(mWidget:getChildByName("Panel_31663"),"Layout")
	local back_ground = tolua.cast(back:getChildByName("Panel_891796"),"Layout")
	-- back_ground:setVisible(false)
	UIListViewSize.definedUIpanel(mWidget ,back,panel, arrow, {back_ground})
	tableView = CCTableView:create(true, CCSizeMake(panel:getSize().width,panel:getSize().height))
    tableView:setDirection(kCCScrollViewDirectionVertical)
	tableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	tableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    tableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    tableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    tableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    tableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)  
	panel:addChild(tableView)
	m_ptouchLayer = CCLayer:create()
	m_ptouchLayer:setTouchEnabled(true)
	m_ptouchLayer:registerScriptTouchHandler(onTouch,false, -123, false)
	tableView:addChild(m_ptouchLayer)
	tableView:reloadData()

	tableView:runAction(animation.sequence({cc.DelayTime:create(0.1), cc.CallFunc:create(function ( )
		reportData.requestReportByType(page,0 )
	end)}))

	uiManager.add_panel_to_layer(mLayer, uiIndexDefine.REPORT_UI)
	uiManager.showConfigEffect(uiIndexDefine.REPORT_UI,mLayer,nil,999,{m_backPanel:getMainWidget()})

	-- 个人战报和同盟战报转换按钮
	local changeBtn = tolua.cast(mWidget:getChildByName("change_report_btn"),"ImageView" )
	if userData.getUnion_id() ~= 0 and _type <=2 then
		changeBtn:setVisible(true)
		changeBtn:setTouchEnabled(true)
		-- 个人战报文字
		local player_report = tolua.cast(changeBtn:getChildByName("player_report"),"Label" )
		player_report:setVisible(_type == 2 )

		-- 同盟战报文字
		local union_report = tolua.cast(changeBtn:getChildByName("union_report"),"Label" )
		union_report:setVisible( not _type or _type == 1)

		changeBtn:addTouchEventListener(function ( sender, eventType )
			if eventType == TOUCH_EVENT_ENDED then
				do_remove_self()
				if not _type or _type == 1 then
					create(2)
				else
					create(1)
				end
			end
		end)
	else
		changeBtn:setVisible(false)
		changeBtn:setTouchEnabled(false)
	end
	
	-- reportData.requestReportByType(page,0 )

    -- tableView:reloadData()
end

local function getInstance( )
	return mLayer
end

local function dealWithReportChange()
	if tableView then
		tableView:reloadData()
		if isAddData then
			if reportData.getPanelLenght(reportData.getReportShowNums()) <= tableView:getViewSize().height then
			-- if isAddData-reportData.getReportShowNums()*130 < 0 then
			else
				tableView:setContentOffset(cc.p(0,isAddData-reportData.getPanelLenght(reportData.getReportShowNums()-1)),false)
				-- tableView:setContentOffset(cc.p(0,0),false)
			end
			isAddData = false
		end

		if isClick then
			tableView:setContentOffset(cc.p(0, -(reportData.getPanelLenght(reportData.getReportShowNums()) - isClick)))
			isClick = false
		end
	end

	local label_null = uiUtil.getConvertChildByName(mWidget,"label_null")
	if reportData.getReportShowNums() > 0 then 
		label_null:setVisible(false)
	else
		label_null:setVisible(true)
	end

end

local function setVisible( flag )
		-- mWidget:setVisible(flag)
		-- mWidget:setTouchEnabled(flag)
		-- tableView:setTouchEnabled(flag)
		-- m_ptouchLayer:setTouchEnabled(flag)
end

local function get_guide_widget(temp_guide_id)
	if not mLayer then
		return nil
	end

	return mWidget
end


local function getXY( )
	return ccp(m_x, m_y)
end

local function closeUI()
	if m_backPanel:getCloseBtn():hitTest(cc.p(m_x,m_y)) then
		remove_self()
		return true
	end
	return false
end

local function addUnForceGuide( )
	if not mWidget then
		return
	end

	local level3Image = ImageView:create()
	level3Image:setName("unforceImage_level3")
	level3Image:loadTexture(ResDefineUtil.tips_res[17],UI_TEX_TYPE_LOCAL)
	mWidget:addChild(level3Image,99,99)
	local worldPoint = mWidget:convertToNodeSpace(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
	level3Image:setPosition(worldPoint)
	newGuideManager.set_show_guide(guide_id_list.CONST_GUIDE_3031)
end

local function removeUnForceGuide( )
	if not mWidget then
		return
	end
	local level3Image = tolua.cast(mWidget:getChildByName("unforceImage_level3"),"ImageView")
	if level3Image then
		level3Image:removeFromParentAndCleanup(true)
	end
end

reportUI = {
				create = create,
				remove_self = remove_self,
				createReportInfoUI = createReportInfoUI,
				getInstance = getInstance,
				dealwithTouchEvent = dealwithTouchEvent,
				get_guide_widget = get_guide_widget,
				dealWithReportChange = dealWithReportChange,
				setVisible = setVisible,
				openListWar = openListWar,
				refreshAllCell = refreshAllCell,
				getXY = getXY,
				closeUI = closeUI,
				refreshReadReportBtn = refreshReadReportBtn,
				addUnForceGuide = addUnForceGuide,
				removeUnForceGuide = removeUnForceGuide,
				remove_self_only = remove_self_only,
				do_remove_self = do_remove_self,
}