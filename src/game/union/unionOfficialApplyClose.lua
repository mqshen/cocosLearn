local UnionOfficialApplyClose = {}



local uiUtil = require("game/utils/ui_util")
local union_id = nil
local mainWidget = nil

function UnionOfficialApplyClose.remove()
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    union_id = nil
    list_data = nil
end


function UnionOfficialApplyClose.create(mainPanel,pmainWidget,unionID)
    if mainWidget then return end
    union_id = unionID
    
    local widget = GUIReader:shareReader():widgetFromJsonFile("test/alliance_close_application.json")
    mainWidget = widget
    pmainWidget:addChild(mainWidget)
    
    
   



    -- local img_main_bg = uiUtil.getConvertChildByName(widget,"img_main_bg")
    -- UIListViewSize.definedUIpanel(widget,img_main_bg,list_panel,nil,{})

    
    local btn_open = uiUtil.getConvertChildByName(widget,"btn_open")
    btn_open:setTouchEnabled(true)
    btn_open:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            sender:setTouchEnabled(false)
            UnionOfficialManagement.switchApplyState()
        end
    end)

end


return UnionOfficialApplyClose 
