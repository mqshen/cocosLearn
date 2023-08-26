--同盟创建的界面
module("UnionCreateUI", package.seeall)

local StringUtil = require("game/utils/string_util")
function create(  )
	local widget = GUIReader:shareReader():widgetFromJsonFile("test/Create_Alliance.json")
	local titlePanel = tolua.cast(widget:getChildByName("Panel_union_nam"),"Layout")

	local editBoxSize = CCSizeMake(titlePanel:getContentSize().width*config.getgScale(),titlePanel:getContentSize().height*config.getgScale() )
    local rect = CCRectMake(9,9,2,2)
    local EditName = CCEditBox:create(editBoxSize, CCScale9Sprite:createWithSpriteFrameName("Enter_the_name_plate.png",rect))
    EditName:setFontName(config.getFontName())
    EditName:setFontSize(28*config.getgScale())
    EditName:setFontColor(ccc3(255,243,195))
    -- EditName:setAlignment(1)
    -- EditName:setMaxLength(8)
    widget:addChild(EditName)
    EditName:setScale(1/config.getgScale())
    EditName:setPosition(cc.p(titlePanel:getPositionX(), titlePanel:getPositionY()))
    EditName:setAnchorPoint(cc.p(0,0))

    -- 如果加入同盟冷却时间还没到，显示倒计时
    local timeVisible = tolua.cast(widget:getChildByName("isLeftTime"),"Label")
    local leftTimeLabel = tolua.cast(widget:getChildByName("Label_leftTime"),"Label")

    widget:runAction(CCRepeatForever:create(animation.sequence({cc.CallFunc:create(function ( )
        -- local leftTime = UNION_JOIN_COOL_DOWN_TIME- (userData.getServerTime() - userData.getQuitUnionTime())
        local leftTime = userData.getNextJoinUnionTime() - userData.getServerTime()
        if leftTime > 0 then
            leftTimeLabel:setText(commonFunc.format_time(leftTime))
        end
        timeVisible:setVisible(leftTime > 0)
        leftTimeLabel:setVisible(leftTime > 0)
    end), cc.DelayTime:create(1)})))

    local labelNameTips = uiUtil.getConvertChildByName(titlePanel,"Label_497460")
    labelNameTips:setVisible(true)

    EditName:registerScriptEditBoxHandler(function (strEventName,pSender)
        if strEventName == "began" then
            labelNameTips:setVisible(false)
        elseif strEventName == "ended" then
            -- ignore
        elseif strEventName == "return" then
            if StringUtil.isEmptyStr( EditName:getText() ) then
                labelNameTips:setVisible(true)
            end
        elseif strEventName == "changed" then
            -- ignore
        end
    end)

    --需要城主府等级
    -- UNION_CREATE_CHENG_ZHU_FU_LEVEL
    local level = tolua.cast(widget:getChildByName("Label_212462"),"Label")
    level:setText(languagePack["lv"]..UNION_CREATE_CHENG_ZHU_FU_LEVEL)

    --建立同盟需要铜钱数
    -- UNION_CREATE_MONEY_COST 
    local money = tolua.cast(widget:getChildByName("Label_212463"),"Label")
    money:setText(UNION_CREATE_MONEY_COST)

    local stateName = stateData.getStateName(userData.getMainPos())
    --所在州
    local state = tolua.cast(widget:getChildByName("Label_212465"),"Label")
    state:setText(stateName)

    local createBtn = tolua.cast(widget:getChildByName("Button_191510"),"Button")
    createBtn:addTouchEventListener(function (sender, eventType )
		if eventType == TOUCH_EVENT_ENDED then
			if politics.getSelfRes().money_cur < UNION_CREATE_MONEY_COST then
				tipsLayer.create(errorTable[64])
				return
			end

			if politics.getBuildLevel(userData.getMainPos(), 10) < UNION_CREATE_CHENG_ZHU_FU_LEVEL then
				tipsLayer.create(errorTable[65],nil,{UNION_CREATE_CHENG_ZHU_FU_LEVEL})
				return 
			end

            local num = stringFunc.get_str_length(EditName:getText())
            if num > 8 then
                tipsLayer.create(languagePack["tongmengmingzizuiduo"])
                return 
            end

			local len = string.len(EditName:getText())
			if len > 0 then
				for i=1,len do
					if string.sub(EditName:getText(),i,i) ~= " " then
                        -- ADD BY TK  BEGIN 如果被附属 不能创建
                        if userData.getAffilated_union_id() ~= 0 then 
                            tipsLayer.create(errorTable[205])
                            return
                        end
						UnionCreateData.requestCreateUnion(EditName:getText())
						return
					end
				end
				tipsLayer.create(languagePack["tongmengmingzibunengweikong"])
			else
				tipsLayer.create(languagePack["tongmengmingzibunengweikong"])
			end
		end
	end)
	return widget
end