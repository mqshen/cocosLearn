---同盟治所
UnionGovernment = {}

local main_layer = nil

local UnionGovernmentStronghold = require("game/union/unionGovernmentStronghold") 
local UnionGovernmentSubordinate = require("game/union/unionGovernmentSubordinate") 

local selectedIndx = nil

local union_id = nil

local mainPanel = nil
local function do_remove_self()
    if not main_layer then return end

    UnionGovernmentStronghold.remove()
    UnionGovernmentSubordinate.remove()
    
    if mainPanel then 
        mainPanel:remove()
        mainPanel = nil
    end
    
    if main_layer then    
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil
        uiManager.remove_self_panel(uiIndexDefine.UNION_GOVERNMENT_UI)
    end
    
    union_id = nil

    selectedIndx = nil
    --TODO 删除数据更新器
end

function UnionGovernment.remove_self(closeEffect)
    if not main_layer then return end
    if not mainPanel then return end
    if closeEffect then
        do_remove_self()
        return
    end
    uiManager.hideConfigEffect(uiIndexDefine.UNION_GOVERNMENT_UI,main_layer,do_remove_self,999,{mainPanel:getMainWidget()})
end
function UnionGovernment.dealwithTouchEvent(x,y)
    return false
end

function UnionGovernment.setViewIndx(indx)
	if indx >2 or indx < 1 then return end
	-- if selectedIndx == indx then return end

    UnionGovernmentStronghold.remove()
	UnionGovernmentSubordinate.remove()

    local temp_widget = main_layer:getWidgetByTag(999)

    if indx == 1 then 
        UnionGovernmentStronghold.create(mainPanel,temp_widget,union_id)
    else
        UnionGovernmentSubordinate.create(mainPanel,temp_widget,union_id)
    end
    

	selectedIndx = indx 
    
    local temp_btn = nil
    for i = 1,2 do 
        temp_btn = uiUtil.getConvertChildByName(temp_widget,"btn_" .. i)
        temp_btn:setTouchEnabled(true)
        temp_btn:setBright(true)
        uiUtil.setBtnLabel(temp_btn,false)
        if selectedIndx == i then 
            temp_btn:setTouchEnabled(false)
            temp_btn:setBright(false)    
            uiUtil.setBtnLabel(temp_btn,true)
        end
    end
end



function UnionGovernment.updateData(package)
    if not selectedIndx then return end
    if not main_layer then return end
    if selectedIndx == 1 then 
        UnionGovernmentStronghold.updateData(package)
    elseif selectedIndx == 2 then 
        UnionGovernmentSubordinate.updateData(package)
    end
end

function UnionGovernment.create(unionId)
    union_id = unionId

    main_layer = TouchGroup:create()
    
    uiManager.add_panel_to_layer(main_layer, uiIndexDefine.UNION_GOVERNMENT_UI)
    --TODO 添加数据更新监听
    --

    

    local widget = GUIReader:shareReader():widgetFromJsonFile("test/alliance_government_main.json")
    
    widget:setTag(999)
    widget:setScale(config.getgScale())
    widget:ignoreAnchorPointForPosition(false)
    widget:setAnchorPoint(cc.p(0.5, 0.5))
    widget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    
    mainPanel = UIBackPanel.new() 

    local title_name = panelPropInfo[uiIndexDefine.UNION_GOVERNMENT_UI][2]
    local temp_widget= mainPanel:create(widget, UnionGovernment.remove_self,title_name)
    main_layer:addWidget(temp_widget)


    local temp_btn = nil
    for i = 1,2 do 
        temp_btn = uiUtil.getConvertChildByName(widget,"btn_" .. i)
        temp_btn:setTouchEnabled(true)
        temp_btn:addTouchEventListener(function (sender,eventType)
            if eventType == TOUCH_EVENT_ENDED then 
                UnionGovernment.setViewIndx(i) 
            end
        end)
    end

    UnionGovernment.setViewIndx(1)

    uiManager.showConfigEffect(uiIndexDefine.UNION_GOVERNMENT_UI,main_layer,nil,999,{mainPanel:getMainWidget()})
end


