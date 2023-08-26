local uiDailyLogin = {}
local loginRewardHelper = require("game/daily/login_reward_helper")

local m_pMainWidget = nil

local m_tbvDailyReward = nil

local m_lstCurMonthCfgReward = nil
local m_iMineLoginCount = nil -- 玩家本月累计的登录次数
local NUM_PER_LINE = 7

local last_offset_y = nil
local is_scrolling = nil

local m_bIsReceivedToday = nil -- 今日是否已领取 用来模拟的

local m_funCallback = nil


function uiDailyLogin.remove()
	if not m_pMainWidget then return end
	m_tbvDailyReward:removeFromParentAndCleanup(true)
	m_tbvDailyReward = nil

	m_pMainWidget:removeFromParentAndCleanup(true)
	m_pMainWidget = nil

	is_scrolling = false
	last_offset_y = false
end



local function resetData()
    m_lstCurMonthCfgReward = loginRewardHelper.getRewardListCurCycle()
    m_iMineLoginCount = loginRewardHelper.getCurLoginRewardCycleLoginedDays()
end
function reloadData()
    
end


function uiDailyLogin.reloadData()
	if not m_pMainWidget then return end
    if not m_tbvDailyReward then return end

    resetData()

    -- 刷新列表
    m_tbvDailyReward:reloadData()
end



function uiDailyLogin.showEffectReceiveTodayReward()
    if not m_tbvDailyReward then return end

    local dayth = loginRewardHelper.getCurLoginRewardCycleLoginedDays()
    local rewardTbRow = math.ceil(dayth/NUM_PER_LINE)
    local rewardTbCol = dayth - (rewardTbRow - 1) * NUM_PER_LINE
    local cell = m_tbvDailyReward:cellAtIndex(rewardTbRow - 1)
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if not layer then return end
    local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
    local rewardItem = uiUtil.getConvertChildByName(item_panel,"item_" .. rewardTbCol)
    if not rewardItem then return end
    loginRewardHelper.showReceiveEffect(rewardItem)
    
end

function uiDailyLogin.update_show_level(is_most_above)
	if m_tbvDailyReward then
		m_tbvDailyReward:setTouchEnabled(is_most_above)	
	end
end


-- 滑动到顶部或底部的时候的回调
local function scrollViewDidScroll(view)
    local mainWidget = m_pMainWidget
    if not last_offset_y then 
        
        local tableViewPanel = uiUtil.getConvertChildByName(mainWidget,"layout_listPanel")
        last_offset_y = tableViewPanel:getContentSize().height
        last_offset_y = last_offset_y - view:getContainer():getContentSize().height 
    end
    if math.abs(view:getContainer():getPositionY() - last_offset_y) > 2 then 
        is_scrolling = true
    end
    
    last_offset_y = view:getContainer():getPositionY()

    local up_img = uiUtil.getConvertChildByName(mainWidget,"img_drag_flag_up")
    local down_img = uiUtil.getConvertChildByName(mainWidget,"img_drag_flag_down")
    if view:getContentOffset().y < 0 then
        down_img:setVisible(true)
    else
        down_img:setVisible(false)
    end

    if view:getContentSize().height + view:getContentOffset().y > view:getViewSize().height then
        up_img:setVisible(true)
    else
        up_img:setVisible(false)
    end
end





-- tbIndx 第几行
-- itemIdx 第几列

local function setRewardLayout(rewardItem,tbIndx,itemIdx)
    if not rewardItem then return end
    if not rewardItem:isVisible() then return end

    local dayth = tbIndx * NUM_PER_LINE + itemIdx
    
    loginRewardHelper.setDailyRewardIconLayout(rewardItem,dayth)
    
end

local function cellSizeForTable(table,idx)
    return 80, 518
end


local function numberOfCellsInTableView(table)
    if not m_lstCurMonthCfgReward then return 0 end
    return math.ceil( #m_lstCurMonthCfgReward/ NUM_PER_LINE )
end


local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    if cell == nil then
        
        cell = CCTableViewCell:new()
        local mlayer = TouchGroup:create()
        local item_panel = Layout:create() 
        item_panel:setVisible(true)

        -- item_panel:setPosition(cc.p(0,0))
        mlayer:addWidget(item_panel)
        item_panel:setTag(1)
        cell:addChild(mlayer)
        mlayer:setTag(123)

        
    end

    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
        if layer:getWidgetByTag(1) then
            local item_panel = tolua.cast(layer:getWidgetByTag(1),"Layout")
            
            local totalItems = #m_lstCurMonthCfgReward
            if totalItems > loginRewardHelper.getCurLoginRewardCycleTotalDays() then 
                totalItems = loginRewardHelper.getCurLoginRewardCycleTotalDays()
            end
            local rewardItem = nil
            for i = 1, NUM_PER_LINE do 
                rewardItem = uiUtil.getConvertChildByName(item_panel,"item_" .. i)
                if not rewardItem then 
                    rewardItem = GUIReader:shareReader():widgetFromJsonFile("test/login_reward_cell.json")
                    rewardItem:setName("item_" .. i)
                    item_panel:addChild(rewardItem)
                    rewardItem:setPosition(cc.p(7 + (i - 1) * 72,0))
                end
                if idx * NUM_PER_LINE + i > totalItems then 
                    rewardItem:setVisible(false)
                    rewardItem:setTouchEnabled(false)
                else
                    rewardItem:setVisible(true)
                    rewardItem:setTouchEnabled(true)
                    setRewardLayout(rewardItem,idx,i)
                end
                rewardItem:addTouchEventListener(function(sender,eventType)
                    if eventType == TOUCH_EVENT_BEGAN then 
                        is_scrolling = false
                        return true
                    elseif eventType == TOUCH_EVENT_ENDED then
                        if is_scrolling then return end 
                        require("game/daily/ui_login_reward_detail")
                        UIDailyLoginRewardDetail.create(idx * NUM_PER_LINE + i)
                        is_scrolling = false
                    end
                end)
            end
        end
    end
  
    return cell
end



local function init()
	if not m_pMainWidget then return end
	

	local mainWidget = m_pMainWidget

	-- 列表
    local tableViewPanel = uiUtil.getConvertChildByName(mainWidget,"layout_listPanel")
    tableViewPanel:setBackGroundColorType(LAYOUT_COLOR_NONE)

    m_tbvDailyReward = CCTableView:create(CCSizeMake(tableViewPanel:getContentSize().width,tableViewPanel:getContentSize().height))
    tableViewPanel:addChild(m_tbvDailyReward)
    m_tbvDailyReward:setDirection(kCCScrollViewDirectionVertical)
    m_tbvDailyReward:setVerticalFillOrder(kCCTableViewFillTopDown)
    m_tbvDailyReward:ignoreAnchorPointForPosition(false)
    m_tbvDailyReward:setAnchorPoint(cc.p(0.5,0.5))
    m_tbvDailyReward:setPosition(cc.p(tableViewPanel:getContentSize().width/2,tableViewPanel:getContentSize().height/2))

    m_tbvDailyReward:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
    m_tbvDailyReward:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
    m_tbvDailyReward:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
    m_tbvDailyReward:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
    
    m_tbvDailyReward:setTouchEnabled(true)


end

local function create()
	if m_pMainWidget then return end

	m_pMainWidget = GUIReader:shareReader():widgetFromJsonFile("test/huodong_2.json")

	
	init()

	return m_pMainWidget
end


function uiDailyLogin.getInstance()
	create()
	return m_pMainWidget
end

return uiDailyLogin
