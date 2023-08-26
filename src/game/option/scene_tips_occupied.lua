module("SceneTipsOccupied",package.seeall)
-- 沦陷后的提示
-- 类名 SceneTipsOccupied
-- json名 lunxian.json
-- 配置ID UI_SCENE_TIPS_OCCUPIED

local m_pMainLayer = nil

local function do_remove_self()
	if m_pMainLayer then
		m_pMainLayer:removeFromParentAndCleanup(true)
		m_pMainLayer = nil
		uiManager.remove_self_panel(uiIndexDefine.UI_SCENE_TIPS_OCCUPIED)
	end
end

function remove_self()
	--do_remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.UI_SCENE_TIPS_OCCUPIED, m_pMainLayer, do_remove_self, 999)
end


function dealwithTouchEvent(x,y)
	if not m_pMainLayer then return false end
	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return false end

	if widget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end


local function reloadData()
	if not m_pMainLayer then return end

	local widget = m_pMainLayer:getWidgetByTag(999)
	if not widget then return end

	local panel_detail = uiUtil.getConvertChildByName(widget,"panel_detail")
	panel_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)

	local btn_rebel = uiUtil.getConvertChildByName(widget,"btn_rebel")
	btn_rebel:setTouchEnabled(true)
	btn_rebel:addTouchEventListener(function(sender,eventType)
		if eventType == TOUCH_EVENT_ENDED then
			do_remove_self()
			UnionRebelUI.create()
		end
	end)
	
	local affiliate_info = nil
	for k,v in pairs(allTableData[dbTableDesList.user_stuff.name]) do
		affiliate_info = v.affiliate_info
	end
	local rich_str = ""
	local arg = {}
	if affiliate_info then
		affiliate_info = cjson.decode(affiliate_info)
		if type(affiliate_info) == "table" then			
			if affiliate_info[3] == 0 then
				-- TODOTK 中文收集
				rich_str = "^您因 ^#【同盟】& #@ & @^ 的进攻而 ^~沦陷~"
				table.insert(arg,affiliate_info[1])
				table.insert(arg,affiliate_info[2])
			else
				-- TODOTK 中文收集
				rich_str = "^您因 ^#【同盟】& #@ & @^ 的进攻而 ^~沦陷~"
				-- table.insert(arg,userData.getAffilated_union_name())
				table.insert(arg,affiliate_info[1])
				table.insert(arg,affiliate_info[2])
			end
		end
	end


	local space = 1
    local _richText = RichText:create()
    _richText:setVerticalSpace(space)
    _richText:setAnchorPoint(cc.p(0.5,1))
    _richText:ignoreContentAdaptWithSize(true)
    _richText:setSize(CCSizeMake(panel_detail:getContentSize().width, panel_detail:getContentSize().height))
    panel_detail:addChild(_richText)
    _richText:setPosition(cc.p(panel_detail:getContentSize().width/2,panel_detail:getContentSize().height))

    

    
    local index = 1
    local tempStr = string.gsub(rich_str, "&", function (n)
        local temp = arg[index]
        index = index + 1
        return temp or "&"
    end)

    local tStr = config.richText_split(tempStr,{"#","@","^","~"})
    local re1 = nil
    for i,v in ipairs(tStr) do
        if v[1] == 1 then
            re1 = RichElementText:create(i, ccc3(188,216,168), 255, v[2],config.getFontName(), 20)
        elseif v[1] == 2 then
            re1 = RichElementText:create(i, ccc3(255,213,110), 255, v[2],config.getFontName(), 20)
        elseif v[1] == 3 then
            re1 = RichElementText:create(i, ccc3(222,212,171), 255, v[2],config.getFontName(), 20)
        else
            re1 = RichElementText:create(i, ccc3(154,42,61), 255, v[2],config.getFontName(), 20)
        end
        _richText:pushBackElement(re1)
    end
    _richText:formatText()
end
function create()
	if m_pMainLayer then return end
	
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/lunxian.json")
    widget:setTag(999)
	widget:setScale(config.getgScale())
	widget:ignoreAnchorPointForPosition(false)
	widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))

    m_pMainLayer = TouchGroup:create()
    m_pMainLayer:addWidget(widget)
    uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_SCENE_TIPS_OCCUPIED)
	

	reloadData()

	uiManager.showConfigEffect(uiIndexDefine.UI_SCENE_TIPS_OCCUPIED,m_pMainLayer)
end
