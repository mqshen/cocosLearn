local UnionOfficialQuit = {}
local uiUtil = require("game/utils/ui_util")
local mainWidget = nil
local unionId = nil

function UnionOfficialQuit.remove()
    if mainWidget then 
        mainWidget:removeFromParentAndCleanup(true)
        mainWidget = nil
    end
    unionId = nil
end

function UnionOfficialQuit.create(mainPanel,pmainWidget,unionID)
    if mainWidget then return end
    unionId = punionID

    local widget = GUIReader:shareReader():widgetFromJsonFile("test/tuichu_tongmeng_0.json")
    mainWidget = widget
    pmainWidget:addChild(mainWidget)
    


    local confirm_btn = uiUtil.getConvertChildByName(widget,"confirm_btn")
    confirm_btn:setTouchEnabled(true)
    confirm_btn:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            -- 退出同盟
            if userData.isUnionLeader() then 
                tipsLayer.create(errorTable[186])
                return
            end

            if userData.isUnionDeputyLeader() then 
                tipsLayer.create(errorTable[78])
                return
            end
            local function endFunc()
                -- 退出同盟
                Net.send(UNION_QUIT,{})
                UnionOfficialManagement.remove_self()
                UnionMainUI.remove_self()
            end

            local str = errorTable[77]
            if userData.getAffilated_union_id() ~= 0 then
                str = errorTable[301]
            end
            alertLayer.create(str, nil, endFunc)
        end
    end)

    -- local img_main_bg = uiUtil.getConvertChildByName(mainWidget,"img_main_bg")
    -- UIListViewSize.definedUIpanel(mainWidget,img_main_bg,nil,nil,{})
end














return UnionOfficialQuit