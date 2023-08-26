--同盟加入界面
module("UnionJoin", package.seeall)
local StringUtil = require("game/utils/string_util")

local m_pTableView  = nil
local m_pWidget = nil
local m_leftTimeHandler = nil
function remove_self( )
	m_pTableView = nil
	m_pWidget = nil
end

function reloadData( )
	if not m_pWidget or not m_pTableView then return end
	m_pTableView:reloadData()
    local listNoneTips = uiUtil.getConvertChildByName(m_pWidget,"Label_217350_1")
    local listTitlePanel = uiUtil.getConvertChildByName(m_pWidget,"Panel_555064")
    if UnionCreateData.getRecommendUnionCount() > 0 then 
        listNoneTips:setVisible(false)
        listTitlePanel:setVisible(true)
    else
        listNoneTips:setVisible(true)
        listTitlePanel:setVisible(false)
    end
end

local function initCell(layer,idx )
    local widget = layer:getWidgetByTag(1)
    if widget then
        local recommendUnionData = UnionCreateData.getRecommendUnionData()
        --同盟名字
        local union_name = tolua.cast(widget:getChildByName("Label_212674_2_1_0_0"),"Label")
        union_name:setText(recommendUnionData[idx+1].union_name)

        --同盟等级
        local level = recommendUnionData[idx+1].union_level
        tolua.cast(widget:getChildByName("Label_212678_1_1_0_0"),"Label"):setText(level)
            
        --成员数
        tolua.cast(widget:getChildByName("Label_212954_1_0_0"),"Label"):setText(recommendUnionData[idx+1].union_member_count.."/"..Tb_cfg_union_level[level].people_max)
            
        --距离
        tolua.cast(widget:getChildByName("Label_216963_0_0"),"Label"):setText(recommendUnionData[idx+1].distance)
            
        local name = "near-distance.png"
        if recommendUnionData[idx+1].distance == languagePack["juliyuan"] then
            name = "long-distance.png"
        elseif recommendUnionData[idx+1].distance == languagePack["julizhong"] then
            name = "middle-distance.png"
        end

        tolua.cast(widget:getChildByName("ImageView_191727_0_1_0_0_0"),"ImageView"):loadTexture(name,UI_TEX_TYPE_PLIST)

        --所属州
        tolua.cast(widget:getChildByName("Label_218664_0"),"Label"):setText(recommendUnionData[idx+1].union_state)

        --申请状态
        --申请加入
        local btn = tolua.cast(widget:getChildByName("Button_216968_0_0"),"Button")
        btn:setTouchEnabled(false)
        btn:setVisible(false)
        --取消申请
        local btn_cancel = tolua.cast(widget:getChildByName("Button_237636"),"Button")
        btn_cancel:setTouchEnabled(false)
        btn_cancel:setVisible(false)

        if recommendUnionData[idx+1].applyed == 1 then
            btn_cancel:setTouchEnabled(true)
            btn_cancel:setVisible(true)
            btn_cancel:addTouchEventListener(function ( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    UnionCreateData.requestDeleteJoinUnion(recommendUnionData[idx+1].union_id)
                end
            end)
        else
            btn:setTouchEnabled(true)
            btn:setVisible(true)
            btn:addTouchEventListener(function ( sender, eventType )
                if eventType == TOUCH_EVENT_ENDED then
                    UnionCreateData.requestJoinUnion(recommendUnionData[idx+1].union_id)
                end
            end)
        end

        --查看同盟信息
        local unionBtn = tolua.cast(widget:getChildByName("Button_217509"),"Button")
        unionBtn:addTouchEventListener(function ( sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                UnionUIJudge.create(recommendUnionData[idx+1].union_id)
            end
        end)
    end
end

function refreshCell( index )
    if not m_pTableView then return end
    local cell = m_pTableView:cellAtIndex(index-1)
    if not cell then return end
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
        initCell(layer,index-1)
    end
end

local function cellSizeForTable(table,idx)
    return 77, 1072
end
local function tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local label = nil
    if nil == cell then
    	cell = CCTableViewCell:new()
    	local layer = TouchGroup:create()
		local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/alliance_create_application.json")
	    tolua.cast(_pCell,"Layout")
	    layer:addWidget(_pCell)
	    _pCell:setTag(1)
	    cell:addChild(layer)
	    layer:setTag(123)
    end
    local layer = tolua.cast(cell:getChildByTag(123),"TouchGroup")
    if layer then
    	initCell(layer,idx)
    end
	
    return cell
end

local function numberOfCellsInTableView(table)
	return UnionCreateData.getRecommendUnionCount()
end

local function scrollViewDidScroll(table)
    if table:getContentOffset().y < 0 then
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0"),"ImageView" ):setVisible(true)
    else
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0"),"ImageView" ):setVisible(false)
    end

    if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0"),"ImageView" ):setVisible(true)
    else
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0"),"ImageView" ):setVisible(false)
    end
end

local function changeApplyBtnState(isAble,isBright)
    if not m_pWidget then return end

    local applyBtn = uiUtil.getConvertChildByName(m_pWidget,"confirm_btn_0_0")
    applyBtn:setTouchEnabled(isAble)
    applyBtn:setBright(isBright)

end

local function createUnionLeftTime( )
    if not m_pWidget then return end
    -- 如果加入同盟冷却时间还没到，显示倒计时
    local timeVisible = tolua.cast(m_pWidget:getChildByName("isLeftTime"),"Label")
    local leftTimeLabel = tolua.cast(m_pWidget:getChildByName("Label_leftTime"),"Label")

    m_pWidget:runAction(CCRepeatForever:create(animation.sequence({cc.CallFunc:create(function ( )
        -- local leftTime = UNION_JOIN_COOL_DOWN_TIME- (userData.getServerTime() - userData.getQuitUnionTime())
        local leftTime = userData.getNextJoinUnionTime() - userData.getServerTime()
        if leftTime > 0 then
            leftTimeLabel:setText(commonFunc.format_time(leftTime))
        end
        timeVisible:setVisible(leftTime > 0)
        leftTimeLabel:setVisible(leftTime > 0)
    end), cc.DelayTime:create(1)})))
end

function create( )
	if m_pWidget then return end
	m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/alliance_to_join.json")
	local titlePanel = tolua.cast(m_pWidget:getChildByName("Panel_217507"),"Layout")

	local editBoxSize = CCSizeMake(titlePanel:getContentSize().width*config.getgScale(),titlePanel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    local EditName = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    EditName:setFontName(config.getFontName())
    EditName:setFontSize(26*config.getgScale())
    -- EditName:setAlignment(1)
    EditName:setMaxLength(8)
    m_pWidget:addChild(EditName)
    EditName:setScale(1/config.getgScale())
    EditName:setPosition(cc.p(titlePanel:getPositionX(), titlePanel:getPositionY()))
    EditName:setAnchorPoint(cc.p(0,0))


    local labelNameTips = uiUtil.getConvertChildByName(titlePanel,"Label_217351")
    labelNameTips:setVisible(true)

    EditName:registerScriptEditBoxHandler(function (strEventName,pSender)
        if strEventName == "began" then
            labelNameTips:setVisible(false)
        elseif strEventName == "ended" then
            -- ignore
        elseif strEventName == "return" then
            if StringUtil.isEmptyStr( EditName:getText() ) then
                labelNameTips:setVisible(true)
                changeApplyBtnState(true,false)
            else
                changeApplyBtnState(true,true)
            end
        elseif strEventName == "changed" then
            -- ignore
        end
    end)

    local applyBtn = tolua.cast(m_pWidget:getChildByName("confirm_btn_0_0"),"Button")
    applyBtn:addTouchEventListener(function ( sender, eventType )
    	if eventType == TOUCH_EVENT_ENDED then
    		UnionCreateData.requestJoinUnionByName(EditName:getText())
    	end
    end)

    changeApplyBtnState(true,false)

	return m_pWidget
end

function init( )
	if not m_pWidget then return end
    createUnionLeftTime()
	local panel = tolua.cast(m_pWidget:getChildByName("Panel_217508"),"Layout")
	local main_Image = tolua.cast(m_pWidget:getChildByName("img_labels_0_0"),"ImageView")
	local arrow = tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0"),"ImageView")
	arrow:setVisible(false)
    tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0"),"ImageView"):setVisible(false)
	UIListViewSize.definedUIpanel(m_pWidget,main_Image,panel,arrow)

	m_pTableView = CCTableView:create(true, CCSizeMake(panel:getSize().width,panel:getSize().height))
	m_pTableView:setDirection(kCCScrollViewDirectionVertical)
	m_pTableView:setVerticalFillOrder(kCCTableViewFillTopDown)
    m_pTableView:registerScriptHandler(scrollViewDidScroll,CCTableView.kTableViewScroll)
	m_pTableView:registerScriptHandler(cellSizeForTable,CCTableView.kTableCellSizeForIndex)
	m_pTableView:registerScriptHandler(tableCellAtIndex,CCTableView.kTableCellSizeAtIndex)
	m_pTableView:registerScriptHandler(numberOfCellsInTableView,CCTableView.kNumberOfCellsInTableView)
	panel:addChild(m_pTableView,4,4)

	reloadData()
    UnionCreateData.requestRecommendUnion()
end