module("UnionMemberUI", package.seeall)
-- local m_pPopWidget = nil
local m_pTableView = nil
local m_backPanel = nil
-- local m_pCell = nil


local function do_remove_self( )
	if m_pMainLayer then
		if m_backPanel then
			m_backPanel:remove()
			m_backPanel = nil
		end
		m_pMainLayer:removeFromParentAndCleanup(true)
		-- m_pPopWidget = nil
		m_pMainLayer = nil
		m_pTableView = nil
		-- m_pCell = nil
		uiManager.remove_self_panel(uiIndexDefine.UNION_MEMBER_MAIN_UI)
	end
end

function remove_self(closeEffect)
	if closeEffect then
		do_remove_self()
		return
	end
    if not m_backPanel then return end
    uiUtil.hideScaleEffect(m_backPanel:getMainWidget(),do_remove_self,uiUtil.DURATION_FULL_SCREEN_HIDE)
end


function dealwithTouchEvent(x,y)
    return false
end

-- local function scrollViewDidScroll( table )
-- 	if m_pPopWidget then
-- 		m_pPopWidget:removeFromParentAndCleanup(true)
-- 		m_pPopWidget = nil
-- 	end
-- end

local function cellSizeForTable(table,idx)
    return 77, 1072
end

local function tableCellTouched( tableView,cell )
	if m_pPopWidget then return end
	local idx = cell:getIdx()
	local unionInfo = UnionData.getUnionInfo()
	local memberInfo = UnionData.getUnionMember()
	local tInfo = {}
	local function deleteMember(userid )
		if memberInfo[idx+1].position ~= 0 then
			tipsLayer.create(errorTable[72])
		else
			alertLayer.create(errorTable[71], {memberInfo[idx+1].userName}, function ( )
				UnionData.requestDeleteMember(userid)
			end)
		end
	end

	local function shanrangCall( userid )
		for i, v in pairs(memberInfo) do
			if v.isDemise == 1 then
				tipsLayer.create(errorTable[73],nil,{v.userName})
				return
			end
		end

		alertLayer.create(errorTable[74],{memberInfo[idx+1].userName},function ( )
			UnionData.requestDemise(userid)
		end)
	end

	local function deleteShanrangCall(userid )
		UnionData.requestCancelDemise(userid)
	end

	local function xierenCall(userid )
		alertLayer.create(errorTable[76],nil, function ()
			UnionData.requestOutgoing(userid)
		end)
	end


    --盟主 非盟主
    if userData.getUserId() == unionInfo.leader_id and memberInfo[idx+1] and memberInfo[idx+1].userid ~= userData.getUserId() then
     -- table.insert(tInfo,{str = languagePack["xiangxixinxi"], fun = nil})
     -- table.insert(tInfo,{str = languagePack["yichuchengyuan"], fun = deleteMember})
     -- if memberInfo[idx+1].isDemise == 0 then
     --     table.insert(tInfo,{str = languagePack["shanrang"], fun = shanrangCall})
     -- else
     --     table.insert(tInfo,{str = languagePack["quxiaoshanrang"], fun = deleteShanrangCall})
     -- end
     -- tableView:getParent():addChild(popOption(3, tInfo,cell, idx, tableView ), 99, 99)
    end

    
	-- --盟主 非官员
	-- if userData.getUserId() == unionInfo.leader_id and memberInfo[idx+1] and memberInfo[idx+1].position ~= 1 then
	-- 	table.insert(tInfo,{str = languagePack["xiangxixinxi"], fun = nil})
	-- 	table.insert(tInfo,{str = languagePack["yichuchengyuan"], fun = deleteMember})
	-- 	if memberInfo[idx+1].isDemise == 0 then
	-- 		table.insert(tInfo,{str = languagePack["shanrang"], fun = shanrangCall})
	-- 	else
	-- 		table.insert(tInfo,{str = languagePack["quxiaoshanrang"], fun = deleteShanrangCall})
	-- 	end
	-- 	tableView:getParent():addChild(popOption(3, tInfo,cell, idx, tableView ), 99, 99)
	-- end

	--盟主 官员
	-- if userData.getUserId() == unionInfo.leader_id and memberInfo[idx+1] and memberInfo[idx+1].position <= 11 and memberInfo[idx+1].position >= 2 then
	-- 	table.insert(tInfo,{ str = languagePack["xiangxixinxi"], fun = nil})
	-- 	if memberInfo[idx+1].isDemise == 0 then
	-- 		table.insert(tInfo,{str = languagePack["shanrang"], fun = UnionData.requestDemise})
	-- 	else
	-- 		table.insert(tInfo,{str = languagePack["quxiaoshanrang"], fun = UnionData.requestCancelDemise})
	-- 	end
	-- 	tableView:getParent():addChild(popOption(2, tInfo,cell,idx, tableView ), 99, 99)
	-- end

	-- --副盟主 非官员
	-- if userData.getUserId() == unionInfo.vice_leader_id and memberInfo[idx+1] and memberInfo[idx+1].position == 0 then
	-- 	table.insert(tInfo,{ str = languagePack["xiangxixinxi"], fun = nil})
	-- 	table.insert(tInfo,{ str = languagePack["yichuchengyuan"], fun = UnionData.requestDeleteMember})
	-- 	tableView:getParent():addChild(popOption(2, tInfo,cell,idx,tableView), 99, 99)
	-- end

	-- --副盟主 点击的是本人
	-- if userData.getUserId() == unionInfo.vice_leader_id and memberInfo[idx+1] and memberInfo[idx+1].position == 2 then
	-- 	table.insert(tInfo,{ str = languagePack["xiangxixinxi"], fun = nil})
	-- 	table.insert(tInfo,{ str = languagePack["xieren"], fun = xierenCall})
	-- 	tableView:getParent():addChild(popOption(2, tInfo,cell,idx,tableView), 99, 99)
	-- end
end

local function onClickBtnName(idx)
    local info = UnionData.getUnionMember()
    local function forceDetail()
        UIRoleForcesMain.create(info[idx+1].userid)
    end
    local function sendMail()
        SendMailUI.create("","",info[idx+1].userid, info[idx+1].userName)
    end
    local function deleteMember( )
        
        -- if info[idx+1].isAffiliated == 1  then 
        --     tipsLayer.create(errorTable[89])
        --     return
        -- end

        local userid = info[idx+1].userid
        if info[idx+1].position ~= 0 then
            tipsLayer.create(errorTable[72])
        else
            alertLayer.create(errorTable[71], {info[idx+1].userName}, function ( )
                UnionData.requestDeleteMember(userid)
            end)
        end
    end
    local unionInfo = UnionData.getUnionInfo()
    if userData.getUserId() == unionInfo.leader_id or 
        userData.getUserId() == unionInfo.vice_leader_id then 

        -- 盟主
        local optab = {}
        table.insert(optab,{label = languagePack["shilixinxi"],callback = forceDetail})
        table.insert(optab,{label = languagePack["fasongyoujian"],callback = sendMail})
        if info[idx+1].userid ~= unionInfo.leader_id and 
            info[idx+1].userid ~= unionInfo.vice_leader_id then 
            table.insert(optab,{label = languagePack["yichuchengyuan"],callback = deleteMember})
        end
        comOPMenu.create(optab)
    else
        UIRoleForcesMain.create(info[idx+1].userid)
    end
end
local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
    	cell = CCTableViewCell:new()
    	local layer = TouchGroup:create()
    	-- if m_pCell then
    		-- m_pCell = m_pCell:clone()
    	-- else
		local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_members_cell.json")
		-- end
	    tolua.cast(_pCell,"Layout")
	    layer:addWidget(_pCell)
	    _pCell:setTag(1)
	    cell:addChild(layer)
	    layer:setTag(123)
    end
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	local widget = layer:getWidgetByTag(1)
    	if widget then
    		local info = UnionData.getUnionMember()
    		local panel_back = tolua.cast(widget:getChildByName("Panel_214593"),"Layout")
            local main_btn = tolua.cast(widget:getChildByName("Button_407326"),"Button")
            main_btn:setTouchEnabled(false)
    		--玩家名字
    		tolua.cast(panel_back:getChildByName("Label_212674_1_0_0"),"Label"):setText(info[idx+1].userName)
    		--周贡献
    		tolua.cast(panel_back:getChildByName("Label_212677_0_0_0_1"),"Label"):setText(info[idx+1].donateWeekly)
			-- 总贡献
    		tolua.cast(panel_back:getChildByName("Label_212677_0_0_0_2"),"Label"):setText(info[idx+1].donate)
			-- 势力值
    		tolua.cast(panel_back:getChildByName("Label_212677_0_0_0"),"Label"):setText(info[idx+1].roleForce)
    		local position = tolua.cast(panel_back:getChildByName("Label_212674_0_0_0_0"),"Label")
    		--职位介绍按钮
    		-- local position_Image = tolua.cast(panel_back:getChildByName("Button_214595"),"Button")
    		--沦陷图片
    		local affiliate_image = tolua.cast(widget:getChildByName("ImageView_212693_0"),"ImageView")
    		affiliate_image:setVisible(false)
            --所在州
            local inState = tolua.cast(panel_back:getChildByName("Label_212678_0_0_0"),"Label")
            inState:setText(stateData.getStateName(info[idx+1].wid))
    		--玩家界面搜索按钮
    		local player_infoBtn = tolua.cast(panel_back:getChildByName("Button_214594"),"Button")
    		player_infoBtn:addTouchEventListener(function(sender,eventType)
                if eventType == TOUCH_EVENT_ENDED then 
                    onClickBtnName(idx)
                end
            end)
    		position:setVisible(false)
    		-- position_Image:setVisible(false)
    		-- position_Image:setTouchEnabled(false)
    		if info[idx+1].isAffiliated == 1 then
    			panel_back:setOpacity(100)
    			affiliate_image:setVisible(true)
    		else
    			panel_back:setOpacity(255)
    		end

    		if positionType[info[idx+1].position] then
    			position:setVisible(true)
    			-- position_Image:setVisible(true)
    			-- position_Image:setTouchEnabled(true)
    			-- position_Image:addTouchEventListener(function ( sender, eventType )
    				-- if eventType == TOUCH_EVENT_ENDED then
    					-- if officiaDescription[info[idx+1].position] then
    						-- alertLayer.create(officiaDescription[info[idx+1].position],nil,nil)
    					-- end
    				-- end
    			-- end)
    			position:setText(positionType[info[idx+1].position])
    		end
            local coor_x = math.floor(info[idx+1].wid/10000)
            local coor_y = info[idx+1].wid%10000
            local label_pos = tolua.cast(panel_back:getChildByName("label_pos"),"Label")
            label_pos:setText("（" .. coor_x .. "," .. coor_y .. "）")
            label_pos:setTouchEnabled(true)
            label_pos:addTouchEventListener(function(sender,eventType)
                if eventType == TOUCH_EVENT_ENDED then 
                    local coor_x_t = coor_x
                    local coor_y_t = coor_y
                    
                    require("game/uiCommon/op_locate_coordinate_confirm")
                    opLocateCoordinateConfirm.create(coor_x_t,coor_y_t,function()
                        remove_self()
                        UnionMainUI.remove_self()
                    end)
                end
            end)

            local img_pos_line = uiUtil.getConvertChildByName(panel_back,"img_pos_line")
            img_pos_line:setSize(CCSizeMake(label_pos:getSize().width- 30,2)) 
    	end
    end
	
    return cell
end

local function numberOfCellsInTableView(table)
	return #UnionData.getUnionMember()
end

-- local function onTouch( eventType, x,y )
-- 	if eventType == "began" then
-- 		if m_pPopWidget and not m_pPopWidget:hitTest(cc.p(x,y)) then
-- 			m_pPopWidget:removeFromParentAndCleanup(true)
-- 			m_pPopWidget = nil
-- 		end
--     end
--     return false
-- end

local function scrollViewDidScroll(table)
    local widget = m_pMainLayer:getWidgetByTag(999)
    if table:getContentOffset().y < 0 then
        tolua.cast(widget:getChildByName("ImageView_209575_0"),"ImageView" ):setVisible(true)
    else
        tolua.cast(widget:getChildByName("ImageView_209575_0"),"ImageView" ):setVisible(false)
    end

    if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
        tolua.cast(widget:getChildByName("ImageView_209575_0_0"),"ImageView" ):setVisible(true)
    else
        tolua.cast(widget:getChildByName("ImageView_209575_0_0"),"ImageView" ):setVisible(false)
    end
end

function reloadData( )
	if m_pMainLayer and m_pTableView then
		m_pTableView:reloadData()
	end
end

function create(  )
	-- m_pPopWidget = nil

	if m_pMainLayer then return end
	m_pMainLayer = TouchGroup:create()
	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UNION_MEMBER_MAIN_UI)
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_members.json")
	m_backPanel = UIBackPanel.new()
	local temp = m_backPanel:create(widget, remove_self, panelPropInfo[uiIndexDefine.UNION_MEMBER_MAIN_UI][2], false, true)
	m_pMainLayer:addWidget(temp)
	widget:setTag(999)

	local panel = tolua.cast(widget:getChildByName("Panel_214591"),"Layout")
	local main_Image = tolua.cast(widget:getChildByName("img_labels"),"ImageView")
	local arrow = tolua.cast(widget:getChildByName("ImageView_209575_0"),"ImageView")
    
    arrow:setVisible(false)
    tolua.cast(widget:getChildByName("ImageView_209575_0_0"),"ImageView"):setVisible(false)
	UIListViewSize.definedUIpanel(widget,main_Image,panel,arrow)
	m_pTableView = CCTableView:create(true,CCSizeMake(panel:getSize().width,panel:getSize().height))
	m_pTableView:setDirection(kCCScrollViewDirectionVertical)
	m_pTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
	m_pTableView:registerScriptHandler(tableCellTouched,CCTableView.kTableCellTouched)
    m_pTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	m_pTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	m_pTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	m_pTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	-- m_pTableView:registerScriptTouchHandler(onTouch)
	panel:addChild(m_pTableView,4,4)
	reloadData()
	UnionData.requestUnionMember()

	breathAnimUtil.start_scroll_dir_anim(tolua.cast(widget:getChildByName("ImageView_209575_0"),"ImageView" ), tolua.cast(widget:getChildByName("ImageView_209575_0_0"),"ImageView" ))

    local btn_tips = uiUtil.getConvertChildByName(widget,"btn_tips")
    btn_tips:setTouchEnabled(true)
    btn_tips:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
			alertLayer.create(errorTable[2036])
        end
    end)

	local btn_unionMail = uiUtil.getConvertChildByName(widget,"btn_unionMail")
	local flagIsAble = userData.isAbleSendUnionMail()
	btn_unionMail:setTouchEnabled(flagIsAble)
	btn_unionMail:setVisible(flagIsAble)
	btn_unionMail:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			SendMailUI.create("","",0,"",true,true)
		end
	end)
end
