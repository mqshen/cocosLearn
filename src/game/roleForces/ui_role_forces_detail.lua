module("UIRoleForcesDetail",package.seeall)


local uiUtil = require("game/utils/ui_util")
local StringUtil = require("game/utils/string_util")
-- 个人势力详情

local mainLayer = nil
local userID = nil
local userName = nil
local m_keyStrUserName = nil
local unionId = nil
local affilatedUnionId = nil


local function setEnable( flag )
    if mainLayer then
        local temp = mainLayer:getChildren()
        for i=0 , mainLayer:getChildrenCount()-1 do
            tolua.cast(temp:objectAtIndex(i),"Widget"):setEnabled(flag)
        end
    end
end

local function isUIUnionOpen()
    if UnionMainUI.getInstance() then 
        return true 
    end
    return false
end

function resetBlackNameState()
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end

    local btnRemoveBlack = uiUtil.getConvertChildByName(mainWidget,"btnRemoveBlack")
    local btnMail = uiUtil.getConvertChildByName(mainWidget,"btnMail")
    local btnBlackList = uiUtil.getConvertChildByName(mainWidget,"btnBlackList")
    btnRemoveBlack:setVisible(false)
    btnRemoveBlack:setTouchEnabled(false)
    btnMail:setVisible(false)
    btnMail:setTouchEnabled(false)
    btnBlackList:setVisible(false)
    btnBlackList:setTouchEnabled(false)

    local isInBlackNameList = false

    if userID then 
        isInBlackNameList = BlackNameListData.checkIsInListById(userID)
    elseif userName then
        isInBlackNameList = BlackNameListData.checkIsInListByName(userName)
    end
    if isInBlackNameList then 
        btnRemoveBlack:setVisible(true)
        btnRemoveBlack:setTouchEnabled(true)
    else
        btnMail:setVisible(true)
        btnMail:setTouchEnabled(true)
        btnBlackList:setVisible(true)
        btnBlackList:setTouchEnabled(true)
    end

end

local function refreshView(data)
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end


    local renwan = 0
    local renwanMax = 0
    local desc = nil

    local unionPosition = nil
    
    local unionName = nil
    local affilatedUnionName = nil

    
    unionName = data[1]
    affilatedUnionName = data[2]

    
    if userID == userData.getUserId() then
        renwan = userData.getShowRenownNums()
        renwanMax = userData.getShowRenownNumsMax()
        userName = userData.getRoleName()
        desc = userData.getUserIntroduction()
        unionId = userData.getUnion_id()
        affilatedUnionId = userData.getAffilated_union_id()
        if allTableData[dbTableDesList.user_union_attr.name] and 
            allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()]
            then
            unionPosition = allTableData[dbTableDesList.user_union_attr.name][userData.getUserId()].official_id
        end
    else
        if data[7] then 
            renwan = math.floor(data[7] / 100)
        end
        if data[14] then 
            renwanMax = math.floor(data[14] / 100)
        end
        userName = data[6]
        desc = data[8]
        unionId = data[3]
        affilatedUnionId = data[4]
        unionPosition = data[5]
    end
    local imgDesc = uiUtil.getConvertChildByName(mainWidget,"imgDesc")
    local label_desc_null = uiUtil.getConvertChildByName(imgDesc,"Label_1148577")
    label_desc_null:setVisible(false)
    if not desc or  desc == "" then 
        label_desc_null:setVisible(true)
        desc = " "
    end

    local imgName = uiUtil.getConvertChildByName(mainWidget,"imgName")
    local labelName = uiUtil.getConvertChildByName(imgName,"labelName")

    local labelRenwan = uiUtil.getConvertChildByName(mainWidget,"labelRenwan")

    
    local labelDesc = uiUtil.getConvertChildByName(imgDesc,"labelDesc")

    labelName:setText(userName)
    -- labelRenwan:setText(renwan .. "/" .. renwanMax)
    labelRenwan:setText(data[15])
    
    labelDesc:setText(desc)


    local imgDetail = uiUtil.getConvertChildByName(mainWidget,"imgDetail")
    local labelUnionNull = uiUtil.getConvertChildByName(imgDetail,"labelUnionNull")
    local imgAffilatedUnion = uiUtil.getConvertChildByName(imgDetail,"imgAffilatedUnion")
    local imgUnion = uiUtil.getConvertChildByName(imgDetail,"imgUnion")
    labelUnionNull:setVisible(false)
    imgAffilatedUnion:setVisible(false)
    imgUnion:setVisible(false)

    imgUnion:setTouchEnabled(false)
    imgAffilatedUnion:setTouchEnabled(false)

    local labelUnionName = nil
    local labelUnionPos = nil
    if unionId and unionId ~= 0 then 
        imgUnion:setVisible(true)
        imgUnion:setTouchEnabled(true)
        labelUnionName = uiUtil.getConvertChildByName(imgUnion,"labelName")
        labelUnionName:setText(unionName)

        labelUnionPos = uiUtil.getConvertChildByName(imgUnion,"labelPosition")

        if positionType[unionPosition] then 
            labelUnionPos:setText(positionType[unionPosition])
        elseif unionPosition == 0 then 
            labelUnionPos:setText(languagePack["chengyuan"])
        end

    else
        labelUnionNull:setVisible(true)
    end
    if affilatedUnionId and affilatedUnionId ~= 0 then 
        imgAffilatedUnion:setVisible(true)
        imgAffilatedUnion:setTouchEnabled(true)
        labelUnionName = uiUtil.getConvertChildByName(imgAffilatedUnion,"labelName")
        labelUnionName:setText(affilatedUnionName)
    end

   
    resetBlackNameState()
end


-- 服务端返回数据
local function receiveDataFromServer(data)
    if not mainLayer then return end
    if not data then return end
    setEnable(true)
    refreshView(data)
end

local function addObserver()
    netObserver.addObserver(GET_USER_PROFILE, receiveDataFromServer)
end

local function removeObserver()
    netObserver.removeObserver(GET_USER_PROFILE)
end



-- 请求数据
local function requestData()
    if userID and userID~= 0 then 
        Net.send(GET_USER_PROFILE, {userID})
    elseif not StringUtil.isEmptyStr(m_keyStrUserName) then 
        Net.send(GET_USER_PROFILE, {m_keyStrUserName})
    end
end


local function reloadData()
    if not mainLayer then return end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return end
    refreshView({})
    requestData()
end



local function do_remove_self()
    if mainLayer then 
        mainLayer:removeFromParentAndCleanup(true)
        mainLayer = nil
        uiManager.remove_self_panel(uiIndexDefine.UI_ROLE_FORCES_DETAIL)

        removeObserver()

        --[[
        if rankingManager then
            rankingManager.set_drag_state(true)
        end
        --]]
    end
end

function remove_self()
    if not mainLayer then return end
    uiManager.hideScaleEffect(mainLayer,999,do_remove_self,nil)
end

function dealwithTouchEvent(x,y)
    if not mainLayer then return false end
    local mainWidget = mainLayer:getWidgetByTag(999)
    if not mainWidget then return false end
    if mainWidget:hitTest(cc.p(x,y)) then 
        return false 
    else
        remove_self()
        return true
    end
end


local function handleJump2Union(unionId)
	if rankingManager.getInstance() then
		do_remove_self()
	end
			
    if UnionOfficialManagement then
        UnionOfficialManagement.remove_self(true)
    end

    if UnionGovernment then 
        UnionGovernment.remove_self(true)
    end
	if UnionMemberUI then
		UnionMemberUI.remove_self(true)
	end
	if UnionMainUI.getInstance() then
		UnionMainUI.remove_self(true)
		do_remove_self()
	end


	UIRoleForcesMain.remove_self()

			
    UnionUIJudge.create(unionId)
end
function create(p_userID,p_userName)
    if StringUtil.isEmptyStr(p_userName) and ( (not p_userID) or ( p_userID== 0) )   then 
        return 
    end
    -- 只能打开其他人的势力详情
    if p_userID == userData.getUserId() or p_userName == userData.getUserName() then 
        return 
    end

   
    if mainLayer then return end
    userID = p_userID
    userName = p_userName
    m_keyStrUserName = p_userName
    local mainWidget = GUIReader:shareReader():widgetFromJsonFile("test/Forces_the_details_new.json")
    mainWidget:setTag(999)
    mainWidget:setScale(config.getgScale())
    mainWidget:ignoreAnchorPointForPosition(false)
    mainWidget:setAnchorPoint(cc.p(0.5, 0.5))
    mainWidget:setPosition(cc.p(config.getWinSize().width/2 , config.getWinSize().height/2))
    mainLayer = TouchGroup:create()
    mainLayer:addWidget(mainWidget)
    uiManager.add_panel_to_layer(mainLayer, uiIndexDefine.UI_ROLE_FORCES_DETAIL)

    -- 按钮事件
    local btnClose = uiUtil.getConvertChildByName(mainWidget,"btnClose")
    btnClose:setTouchEnabled(true)
    btnClose:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            remove_self()
        end
    end)

    local btnMail = uiUtil.getConvertChildByName(mainWidget,"btnMail")
    btnMail:setTouchEnabled(true)
    btnMail:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            SendMailUI.create("","",userID,userName,true)
        end
    end)
    btnMail:setVisible(false)
    btnMail:setTouchEnabled(false)

    local btnRemoveBlack = uiUtil.getConvertChildByName(mainWidget,"btnRemoveBlack")
    btnRemoveBlack:setTouchEnabled(true)
    btnRemoveBlack:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            alertLayer.create(errorTable[2027],{userName},function()
                

                if userID then 
                    BlackNameListData.delUserByIdList({tonumber(userID)})
                elseif userName then
                    BlackNameListData.delUserByNameList({userName})
                end
                if UIChatMain and UIChatMain.getInstance() then
                    remove_self()
                elseif Setting and Setting.getInstance() then 
                    remove_self()
                else
                    reloadData()
                end
            end)

        end
    end)
    btnRemoveBlack:setVisible(false)
    btnRemoveBlack:setTouchEnabled(false)

    local btnBlackList = uiUtil.getConvertChildByName(mainWidget,"btnBlackList")
    btnBlackList:setTouchEnabled(true)
    btnBlackList:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then
            alertLayer.create(errorTable[2018],{userName},function()
                if userID then 
                    BlackNameListData.addUserByIdList({userID})
                elseif userName then
                    BlackNameListData.addUserByNameList({userName})
                end
                if UIChatMain and UIChatMain.getInstance() then
                    remove_self()
                else
                    reloadData()
                end
            end)
        end
    end)
    btnBlackList:setVisible(false)
    btnBlackList:setTouchEnabled(false)
    
    

    -- 同盟按钮事件
    local imgDetail = uiUtil.getConvertChildByName(mainWidget,"imgDetail")
    local imgAffilatedUnion = uiUtil.getConvertChildByName(imgDetail,"imgAffilatedUnion")
    local imgUnion = uiUtil.getConvertChildByName(imgDetail,"imgUnion")
    imgAffilatedUnion:setTouchEnabled(true)
    imgUnion:setTouchEnabled(true)

    imgUnion:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if not unionId then return end  
			local tmpUnionId = unionId
           	handleJump2Union(tmpUnionId) 
        end
    end)

    imgAffilatedUnion:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if not affilatedUnionId then return end  
            local tempAffilatedUnionId = affilatedUnionId
			handleJump2Union(tempAffilatedUnionId)
        end
    end)


    addObserver()

    reloadData()

    setEnable(false)

    uiManager.showConfigEffect(uiIndexDefine.UI_ROLE_FORCES_DETAIL, mainLayer)
end
