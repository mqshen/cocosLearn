module("opLocateCoordinateConfirm",package.seeall)
--[[
	坐标跳转确认
	json名      dingwei_tishi.json
	UI ID	   UI_OP_LOCATE_COORDINATE_CONFIRM
	类名       opLocateCoordinateConfirm	
]]


local m_pMainlayer = nil

local function do_remove_self()
    if m_pMainlayer then 
        m_pMainlayer:removeFromParentAndCleanup(true)
        m_pMainlayer = nil    
        uiManager.remove_self_panel(uiIndexDefine.UI_OP_LOCATE_COORDINATE_CONFIRM)
    end

end

function remove_self()
    if not m_pMainlayer then return end
    uiManager.hideConfigEffect(uiIndexDefine.UI_OP_LOCATE_COORDINATE_CONFIRM,m_pMainlayer,do_remove_self)
end

function dealwithTouchEvent(x,y)
    if not m_pMainlayer then return false end

    local main_widget = m_pMainlayer:getWidgetByTag(999)
    if main_widget:hitTest(cc.p(x,y)) then 
        return false 
    else
        remove_self()
        return true
    end
end


function create(coorX,coorY,confirmCallback,cancelCallback)
	if m_pMainlayer then return end

	local main_widget = GUIReader:shareReader():widgetFromJsonFile("test/dingwei_tishi.json")
    main_widget:setTouchEnabled(false)
    main_widget:setTag(999)
    main_widget:setAnchorPoint(cc.p(0.5,0.5))
    main_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_widget:setScale(config.getgScale())

    m_pMainlayer = TouchGroup:create()
    m_pMainlayer:addWidget(main_widget)
    uiManager.add_panel_to_layer(m_pMainlayer, uiIndexDefine.UI_OP_LOCATE_COORDINATE_CONFIRM,999)



    local btn_cancel = uiUtil.getConvertChildByName(main_widget,"btn_cancel")
    btn_cancel:setTouchEnabled(true)
    btn_cancel:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		do_remove_self()
    		if cancelCallback then 
    			cancelCallback()
    		end
    	end
    end)

    local function doConfirm()
    	do_remove_self()
		if confirmCallback then 
			confirmCallback()
		end
		mapController.locateCoordinate(coorX,coorY)
    end
    local btn_ok = uiUtil.getConvertChildByName(main_widget,"btn_ok")
    btn_ok:setTouchEnabled(true)
    btn_ok:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		doConfirm()
    	end
    end)



    local label_pos = uiUtil.getConvertChildByName(main_widget,"label_pos")
    label_pos:setText("（" .. coorX .. "," .. coorY .. "）")
    local img_pos_line = uiUtil.getConvertChildByName(main_widget,"img_pos_line")
    img_pos_line:setSize(CCSizeMake(label_pos:getSize().width - 30, 2))

    label_pos:setTouchEnabled(true)
    label_pos:addTouchEventListener(function(sender,eventType)
    	if eventType == TOUCH_EVENT_ENDED then 
    		doConfirm()
    	end
    end)


    uiManager.showConfigEffect(uiIndexDefine.UI_OP_LOCATE_COORDINATE_CONFIRM,m_pMainlayer)
end