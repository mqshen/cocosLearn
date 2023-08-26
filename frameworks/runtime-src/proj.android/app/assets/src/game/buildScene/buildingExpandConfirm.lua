module("BuildingExpandConfirm", package.seeall)


-- 类名    BuildingExpandConfirm
-- json名  kuojian.json
-- ID 名   UI_BUILDING_EXPAND_CONFIRM

local m_pMainLayer = nil
local m_fCallback = nil

local function do_remove_self()
	if m_pMainLayer then 
		m_pMainLayer:getParent():setOpacity(150)
		m_pMainLayer:removeFromParentAndCleanup(true)
        m_pMainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_BUILDING_EXPAND_CONFIRM)
        if m_fCallback and type(m_fCallback) == "function" then 
        	m_fCallback()
        end
	end
end

function remove_self()
	uiManager.hideConfigEffect(uiIndexDefine.UI_BUILDING_EXPAND_CONFIRM,m_pMainLayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
	if not m_pMainLayer then
		return false
	end

	local mainWidget = m_pMainLayer:getWidgetByTag(999)
	if mainWidget:hitTest(cc.p(x,y)) then
		return false
	else
		remove_self()
		return true
	end
end

function create(mainWid,landWid)
	if m_pMainLayer then return end

	local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/kuojian.json")
	mainWidget:setTag(999)
	mainWidget:setScale(config.getgScale())
	mainWidget:ignoreAnchorPointForPosition(false)
	mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
	mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
	mainWidget:setTouchEnabled(true)

	m_pMainLayer = TouchGroup:create()
	m_pMainLayer:addWidget(mainWidget)

	uiManager.add_panel_to_layer(m_pMainLayer, uiIndexDefine.UI_BUILDING_EXPAND_CONFIRM,999)
    uiManager.showConfigEffect(uiIndexDefine.UI_BUILDING_EXPAND_CONFIRM, m_pMainLayer, nil, 999, {all_widget})


    local panel_res = uiUtil.getConvertChildByName(mainWidget,"panel_res")
    local btn_ok = uiUtil.getConvertChildByName(mainWidget,"btn_ok")
    local btn_cancel = uiUtil.getConvertChildByName(mainWidget,"btn_cancel")
    local label_tips = uiUtil.getConvertChildByName(mainWidget,"label_tips")

    --TODOTK 中文收集
    local costTipsTxt = "扩建一次可增加&的税收" --
    local costTipsArg = {EXTEND_REVENUE_ADD .. "%"}
    local index = 1
    local temp
    local tempStr = string.gsub(costTipsTxt, "&", function (n)
    	temp = costTipsArg[index]
    	index = index + 1
    	return temp or "&"
    end)
    label_tips:setText(tempStr)


    btn_ok:setTouchEnabled(true)
    btn_cancel:setTouchEnabled(true)


    btn_ok:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
            if politics.getResNumsByType(resType.wood) < 5000  or 
               politics.getResNumsByType(resType.stone) < 10000  or 
               politics.getResNumsByType(resType.iron) < 5000  or
               politics.getResNumsByType(resType.food) < 5000   then 
                
                alertLayer.create(errorTable[48])
                return
            end 
    		Net.send(WORLD_EXTEND_CITY, {mainWid, landWid})
            remove_self()
    	end
    end)

    btn_cancel:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		remove_self()
    	end
    end)

    local label_res = nil
    for i = 1,4 do 
    	label_res = uiUtil.getConvertChildByName(panel_res,"label_res_" .. i)
    	label_res:setText(CITY_EXTEND_COST[i * 2 ])
    end
end