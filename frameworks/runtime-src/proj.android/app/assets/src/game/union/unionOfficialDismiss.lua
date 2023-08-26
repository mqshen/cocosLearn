local UnionOfficialDismiss = {}

local mainWidget = nil
local unionId = nil
local uiUtil = require("game/utils/ui_util")
function UnionOfficialDismiss.remove()
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    unionId = nil
end

function UnionOfficialDismiss.create(mainPanel,pmainWidget,unionID)
    if mainWidget then return end
    unionId = punionID

    local widget = GUIReader:shareReader():widgetFromJsonFile("test/jieshan_tongmeng.json")
    mainWidget = widget
    pmainWidget:addChild(mainWidget)
    

   
    local confirm_btn = uiUtil.getConvertChildByName(widget,"confirm_btn")
    confirm_btn:setTouchEnabled(true)
    confirm_btn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if userData.getAffilated_union_id() ~= 0 then 
                tipsLayer.create(errorTable[89])
                return
            end
            -- 是否还有成员
            if UnionData.getUnionInfo().total_member > 1 then 
                tipsLayer.create(errorTable[80])
                return 
            end
            local function endFunc()

                -- 解散同盟
                Net.send(UNION_DISSOLVE,{})
                UnionOfficialManagement.remove_self()
                UnionMainUI.remove_self()
            end
            alertLayer.create(errorTable[79], nil, endFunc)
        end
    end)

    -- local img_main_bg = uiUtil.getConvertChildByName(mainWidget,"img_main_bg")
    -- UIListViewSize.definedUIpanel(mainWidget,img_main_bg,nil,nil,{})

end














return UnionOfficialDismiss