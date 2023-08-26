--同盟被邀请界面
module("UnionInviteNoUnion", package.seeall)
local m_pTableView  = nil
local m_pWidget = nil

function remove_self( )
	m_pTableView = nil
	m_pWidget = nil
end

function reloadData( )
	if not m_pWidget or not m_pTableView then return end
	m_pTableView:reloadData()

    local listNoneTips = uiUtil.getConvertChildByName(m_pWidget,"Label_217350_1_0")
    local listTitlePanel = uiUtil.getConvertChildByName(m_pWidget,"Panel_555066")
    if UnionCreateData.getInviteUnionCount() > 0 then 
        listNoneTips:setVisible(false)
        listTitlePanel:setVisible(true)
    else
        listNoneTips:setVisible(true)
        listTitlePanel:setVisible(false)
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
		local _pCell = GUIReader:shareReader():widgetFromJsonFile("test/alliance_invited_cell.json")
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
    		local inviteUnionData = UnionCreateData.getInviteUnion(idx+1)
            if inviteUnionData then
        		--同盟名字
        		local union_name = tolua.cast(widget:getChildByName("Label_212674_2_0_1"),"Label")
        		union_name:setText(inviteUnionData.union_name)

        		--同盟等级
        		local level = inviteUnionData.union_level
        		tolua.cast(widget:getChildByName("Label_218675_1"),"Label"):setText(level)
        		
        		--成员数
        		tolua.cast(widget:getChildByName("Label_218675_0_1"),"Label"):setText(inviteUnionData.union_member_count.."/"..Tb_cfg_union_level[level].people_max)
        		
        		--距离
        		tolua.cast(widget:getChildByName("Label_216963_0"),"Label"):setText(inviteUnionData.distance)
        		local name = "near-distance.png"
                if inviteUnionData.distance == languagePack["juliyuan"] then
                    name = "long-distance.png"
                elseif inviteUnionData.distance == languagePack["julizhong"] then
                    name = "middle-distance.png"
                end

                tolua.cast(widget:getChildByName("ImageView_191727_0_1_0_0"),"ImageView"):loadTexture(name,UI_TEX_TYPE_PLIST)


        		--所属州
        		tolua.cast(widget:getChildByName("Label_212678_1_0_1"),"Label"):setText(inviteUnionData.union_state)


        		--查看同盟信息
        		local unionBtn = tolua.cast(widget:getChildByName("Button_219121"),"Button")
        		unionBtn:addTouchEventListener(function ( sender, eventType )
        			if eventType == TOUCH_EVENT_ENDED then
        				UnionUIJudge.create(inviteUnionData.union_id)
        			end
        		end)

        		--同意邀请按钮
        		local Btn = tolua.cast(widget:getChildByName("Button_216968_0_0_0_0_0_1"),"Button")
        		Btn:addTouchEventListener(function ( sender, eventType )
        			if eventType == TOUCH_EVENT_ENDED then
        				UnionCreateData.requestAgreeInvite(inviteUnionData.invite_id)
        			end
        		end)

        		--新信息
        		local newMessage = tolua.cast(widget:getChildByName("ImageView_218692_1"),"ImageView")
        		if inviteUnionData.new == 1 then
        			newMessage:setVisible(true)
        		else
        			newMessage:setVisible(false)
        		end
            end
    	end
    end
	
    return cell
end

local function numberOfCellsInTableView(table)
	return UnionCreateData.getInviteUnionCount()
end

local function scrollViewDidScroll(table)
    if table:getContentOffset().y < 0 then
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0"),"ImageView" ):setVisible(true)
    else
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0"),"ImageView" ):setVisible(false)
    end

    if table:getContentSize().height + table:getContentOffset().y > table:getViewSize().height then
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0_0"),"ImageView" ):setVisible(true)
    else
        tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0_0"),"ImageView" ):setVisible(false)
    end
end

function create( )
	if m_pWidget then return end
	m_pWidget = GUIReader:shareReader():widgetFromJsonFile("test/Alliance_invited_2.json")
	return m_pWidget
end

function init( )
	if not m_pWidget then return end
	local panel = tolua.cast(m_pWidget:getChildByName("Panel_219042"),"Layout")
	local main_Image = tolua.cast(m_pWidget:getChildByName("img_labels_0_0"),"ImageView")
	local arrow = tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0"),"ImageView")
	arrow:setVisible(false)
    tolua.cast(m_pWidget:getChildByName("ImageView_209575_0_0_0_0"),"ImageView"):setVisible(false)
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
end