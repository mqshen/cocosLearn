module("comAlertConfirm",package.seeall)

comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL = 20 -- 带确认取消按钮
comAlertConfirm.ALERT_TYPE_CONFIRM_ONLY = 21 -- 带确认按钮
comAlertConfirm.ALERT_TYPE_CANCEL_ONLY = 22  -- 带取消按钮
comAlertConfirm.ALERT_TYPE_NONE_BTN = 23 -- 不带按钮


local TIPS_FONT_SIZE = 18
local CONTENT_FONT_SIZE = 20


local uiUtil = require("game/utils/ui_util")
local StringUtil = require("game/utils/string_util")



local main_layer = nil
local main_widget = nil

-- 正文高度
local m_viewContentHeight = 120
-- tips高度
local m_viewTipsHeight = 60

-- 按钮布局样式
local m_opLayoutType = comAlertConfirm.ALERT_TYPE_NONE_BTN
local m_closeBtnAble = true





local function do_remove_self()
    if main_widget  then 
        main_widget:removeFromParentAndCleanup(true)
        main_widget = nil
    end

    if main_layer then 
        main_layer:removeFromParentAndCleanup(true)
        main_layer = nil    
        uiManager.remove_self_panel(uiIndexDefine.COM_ALERT_CONFIRM)

        m_opLayoutType = nil
        m_closeBtnAble = nil
    end

end






function remove_self()
    if not main_layer then return end
   
    uiManager.hideConfigEffect(uiIndexDefine.COM_ALERT_CONFIRM,main_layer,do_remove_self)

end

function dealwithTouchEvent(x,y)
    if not main_layer then return false end
    if not main_widget then return false end

    local img_mainBg = uiUtil.getConvertChildByName(main_widget,"img_mainBg")
    if img_mainBg:hitTest(cc.p(x,y)) then 
        return false 
    else
        remove_self()
        return true
    end
end

function get_guide_widget(temp_guide_id)
    if not main_layer then return nil end
    return main_widget
end




function fetchContentBG()
    if not main_layer then return end
    local img_contentBg = uiUtil.getConvertChildByName(main_widget,"img_contentBg")
    return img_contentBg
end


local function autoSizeLayout()
    if not main_widget then return end

    local img_mainBg = uiUtil.getConvertChildByName(main_widget,"img_mainBg")
    local img_titleBg = uiUtil.getConvertChildByName(main_widget,"img_titleBg")
    local img_contentBg = uiUtil.getConvertChildByName(main_widget,"img_contentBg")
    local img_contentTipsSplitLine = uiUtil.getConvertChildByName(main_widget,"img_contentTipsSplitLine")
    local btn_cancel = uiUtil.getConvertChildByName(main_widget,"btn_cancel")
    local btn_ok = uiUtil.getConvertChildByName(main_widget,"btn_ok")
    local label_title = uiUtil.getConvertChildByName(main_widget,"label_title")
    local img_tips_flag = uiUtil.getConvertChildByName(main_widget,"img_tips_flag")
    local btn_close = uiUtil.getConvertChildByName(main_widget,"btn_close")
    local panel_content = uiUtil.getConvertChildByName(main_widget,"panel_content")
    local panel_tips = uiUtil.getConvertChildByName(main_widget,"panel_tips")


    if m_viewContentHeight < 120 then 
        m_viewContentHeight = 120
    end

    if m_viewTipsHeight < 40 then 
        m_viewTipsHeight = 40
    end

    -- 根据正文以及tips确定 整体高度
    local m_viewWidth = 460 
    local m_viewHeight = 350 

    -- 操作按钮区域的高度
    local m_viewBtnsHeight = 0 
    if btn_cancel:isVisible() or btn_ok:isVisible() then 
        m_viewBtnsHeight = btn_ok:getContentSize().height + 10
    end

    -- 内容背景高度
    local contentbg_h = 0
    if panel_tips:isVisible() then 
        contentbg_h = m_viewContentHeight + m_viewTipsHeight + 30
    else
        contentbg_h = m_viewContentHeight + 20
    end
    local contentbg_w = m_viewWidth - 44


    -- 标题高度
    local m_viewTitleHeight = 35
    -- 整体高度
    m_viewHeight = contentbg_h + 20 + m_viewTitleHeight + m_viewBtnsHeight + 10
    -- 主背景框
    img_mainBg:setSize(CCSizeMake(m_viewWidth, m_viewHeight))
    -- 标题背景
    img_titleBg:setSize(CCSizeMake(contentbg_w ,m_viewTitleHeight))
    img_titleBg:setPositionY(img_mainBg:getPositionY() + m_viewHeight/2 - 40 )
    -- 标题文本
    label_title:setPositionY(img_titleBg:getPositionY())

    -- 关闭按钮
    btn_close:setPositionX(img_mainBg:getPositionX() + m_viewWidth/2 - btn_close:getContentSize().width/2)
    btn_close:setPositionY(img_mainBg:getPositionY() + m_viewHeight/2 - btn_close:getContentSize().height/2)

    -- 内容背景图
    local contentbg_x = img_mainBg:getPositionX()
    local contentbg_y = img_mainBg:getPositionY()

    
    contentbg_y = img_titleBg:getPositionY() - img_titleBg:getSize().height / 2  - contentbg_h/2
    img_contentBg:setSize(CCSizeMake(contentbg_w ,contentbg_h))
    img_contentBg:setPosition(cc.p(contentbg_x,contentbg_y))


    local op_btn_y = contentbg_y  - contentbg_h/2 - btn_ok:getContentSize().height/2
    btn_ok:setPositionY(op_btn_y)
    btn_cancel:setPositionY(op_btn_y)

    local op_btn_x_center = img_mainBg:getPositionX()
    local op_btn_x_center_left = 140
    local op_btn_x_center_right = 320
    

    if btn_cancel:isVisible() and btn_ok:isVisible() then
        btn_cancel:setPositionX(op_btn_x_center_left)
        btn_ok:setPositionX(op_btn_x_center_right)
    else
        btn_cancel:setPositionX(op_btn_x_center)
        btn_ok:setPositionX(op_btn_x_center)
    end

    -- 提示面板
    local tips_w = contentbg_w - 20
    local tips_h = m_viewTipsHeight
    --- 正文面板
    local content_w = contentbg_w - 20
    local content_h = m_viewContentHeight

    

    if panel_tips:isVisible() then 
        panel_tips:setSize(CCSizeMake(tips_w,tips_h))
        panel_content:setSize(CCSizeMake(content_w,content_h))
        panel_tips:setContentSize(CCSizeMake(tips_w,tips_h))
        panel_content:setContentSize(CCSizeMake(content_w,content_h))
        img_contentTipsSplitLine:setSize(CCSizeMake(content_w-20 ,3))
        img_contentTipsSplitLine:setVisible(true)

        panel_tips:setPositionX(contentbg_x - contentbg_w/2 + 10)
        panel_tips:setPositionY(contentbg_y - contentbg_h/2 + 10)

        img_contentTipsSplitLine:setPositionY(panel_tips:getPositionY() + panel_tips:getSize().height + 5)
        panel_content:setPositionX(contentbg_x - contentbg_w/2 + 10)
        panel_content:setPositionY(img_contentTipsSplitLine:getPositionY() + 5)
    else
        panel_content:setSize(CCSizeMake(content_w,content_h))
        panel_content:setContentSize(CCSizeMake(content_w,content_h))
        panel_content:setPositionX(contentbg_x - contentbg_w/2 + 10)
        panel_content:setPositionY(contentbg_y - contentbg_h/2 + 10)
        img_contentTipsSplitLine:setVisible(false)
    end


    local rich_content = uiUtil.getConvertChildByName(panel_content,"rich_content")
    if rich_content then 
        -- rich_content:setSize(CCSizeMake(panel_content:getSize().width - 20, panel_content:getSize().height))
        -- rich_content:formatText()
        rich_content:setPosition(cc.p(panel_content:getSize().width/2,panel_content:getSize().height/2))
    end


    local panel_heroBg = uiUtil.getConvertChildByName(main_widget,"panel_heroBg")
    local img_heroBg = uiUtil.getConvertChildByName(panel_heroBg,"img_heroBg")
    img_heroBg:setSize(CCSizeMake(m_viewWidth, m_viewHeight))
end


function setBtnTitleText(okText,cancelText)
    if not main_widget then return end
    local btn_ok = uiUtil.getConvertChildByName(main_widget,"btn_ok")
    local btn_cancel = uiUtil.getConvertChildByName(main_widget,"btn_cancel")
    btn_cancel:setTitleText(cancelText)
    btn_ok:setTitleText(okText)
end



------------------------------标题

function setTitleText(title)
    if not main_widget then return end
    local label_title = uiUtil.getConvertChildByName(main_widget,"label_title")
    label_title:setText(title)
end

-- -- 标题居中或者左对齐
-- -- @param alginType  0左上角 1顶部中心
-- function setTitleLayoutType(alginType)
--     if not main_widget then return end
    
-- end



-- 设置正文内容
local function setContentText(content,content_arg)
    if not main_widget then return end
    local panel_content = uiUtil.getConvertChildByName(main_widget,"panel_content")
    panel_content:setBackGroundColorType(LAYOUT_COLOR_NONE)
    local rich_content = uiUtil.getConvertChildByName(panel_content,"rich_content")
    if rich_content then 
        rich_content:removeFromParentAndCleanup(true)
        rich_content = nil
    end

    local function getRichContent(view_h)
        local rich_content = RichText:create()
        
        if not view_h then 
            view_h = 0
        end

        rich_content:setAnchorPoint(cc.p(0.5,0.5))
        rich_content:ignoreContentAdaptWithSize(false)
        rich_content:setSize(CCSizeMake(panel_content:getSize().width - 20, view_h))

        
        local index = 1
        local temp = nil
        local tempStr = string.gsub(content, "&", function (n)
            temp = content_arg[index]
            index = index + 1
            return temp or "&"
        end)

        local re = nil
        local contentText = nil
        local realtext = ""
        -- local parseData = config.richText_split(alert_data.content, {"#","@","^","~","$"})
        local parseData = config.richText_split(tempStr)
        for kk,vv in ipairs(parseData) do 
            contentText = vv[2]
            realtext = realtext .. contentText
            if vv[1] == 1 then 
                re = RichElementText:create(1, ccc3(255,255,255), 255, contentText,config.getFontName(), CONTENT_FONT_SIZE)
            else
                re = RichElementText:create(1, ccc3(234,235,156), 255, contentText,config.getFontName(), CONTENT_FONT_SIZE)
            end 
            rich_content:pushBackElement(re)
        end
        rich_content:formatText()
        return rich_content, rich_content:getRealHeight()
    end
    rich_content,m_viewContentHeight = getRichContent()

    rich_content,m_viewContentHeight = getRichContent(m_viewContentHeight)
    rich_content:setPosition(cc.p(panel_content:getSize().width/2,panel_content:getSize().height/2))
    rich_content:setName("rich_content")
    panel_content:addChild(rich_content)

    if m_viewContentHeight and m_viewContentHeight > 30 then
        rich_content:ignoreContentAdaptWithSize(false)
    else
        rich_content:ignoreContentAdaptWithSize(true)
    end

end

-----------------------------提示
-- 设置提示内容
function setTipsText(tipsTab,tipsTabArgs)
    if not main_widget then return end

    local img_tips_flag = uiUtil.getConvertChildByName(main_widget,"img_tips_flag")
    local panel_tips = uiUtil.getConvertChildByName(main_widget,"panel_tips")
    panel_tips:setBackGroundColorType(LAYOUT_COLOR_NONE)
    local img_contentTipsSplitLine = uiUtil.getConvertChildByName(main_widget,"img_contentTipsSplitLine")
    panel_tips:removeAllChildrenWithCleanup(true)

    img_tips_flag:setVisible(false)

    m_viewTipsHeight = 0

    if not tipsTab or #tipsTab == 0 then 
        panel_tips:setVisible(false)
        img_contentTipsSplitLine:setVisible(false)
        return 
    end
    img_contentTipsSplitLine:setVisible(true)
    panel_tips:setVisible(true)

    
    local last_pos_y = 10
    m_viewTipsHeight = m_viewTipsHeight + last_pos_y

    for i = #tipsTab,1,-1 do 
        local img_flag = img_tips_flag:clone()
        img_flag:ignoreContentAdaptWithSize(false)
        img_flag:setAnchorPoint(cc.p(0.5,1))
        img_flag:setVisible(true)
        panel_tips:addChild(img_flag)
        img_flag:setPositionX(10 + img_flag:getSize().width/2)
        

        local rich_tip_pos_x = img_flag:getPositionX() + img_flag:getSize().width/2 + 5
        local rich_tip = RichText:create()
        rich_tip:ignoreContentAdaptWithSize(false)
        rich_tip:setSize(CCSizeMake(panel_tips:getSize().width - rich_tip_pos_x - 10, 0))
        rich_tip:setAnchorPoint(cc.p(0,1))
        rich_tip:setPositionX(rich_tip_pos_x)
        panel_tips:addChild(rich_tip)
        

        local index = 1
        local temp = nil
        local tempStr = string.gsub(tipsTab[i], "&", function (n)
            temp = tipsTabArgs[i][index]
            index = index + 1
            return temp or "&"
        end)

        local re = nil
        local contentText = nil
        local realtext = ""
        local parseData = config.richText_split(tempStr)
        for kk,vv in ipairs(parseData) do 
            contentText = vv[2]
            realtext = realtext .. contentText
            if vv[1] == 1 then 
                re = RichElementText:create(1, ccc3(125,187,139), 255, contentText,config.getFontName(), TIPS_FONT_SIZE)
            else
                re = RichElementText:create(1, ccc3(255,213,110), 255, contentText,config.getFontName(), TIPS_FONT_SIZE)
            end 
            rich_tip:pushBackElement(re)
        end
        rich_tip:formatText()
        
        local rich_tip_height = rich_tip:getRealHeight() + 10

        last_pos_y = last_pos_y + rich_tip_height
        m_viewTipsHeight = last_pos_y

        rich_tip:setPositionY(last_pos_y)
        img_flag:setPositionY(last_pos_y + 5)

    end
    m_viewTipsHeight = m_viewTipsHeight + 5
end


------------------------------操作按钮
-- 关闭按钮 确认按钮 取消按钮

local function autoLayoutBtns()
    if not main_widget then return end
    local btn_close = uiUtil.getConvertChildByName(main_widget,"btn_close")
    if m_closeBtnAble then 
        btn_close:setVisible(true)
        btn_close:setTouchEnabled(true)
    else
        btn_close:setVisible(false)
        btn_close:setTouchEnabled(false)
    end

    local btn_cancel = uiUtil.getConvertChildByName(main_widget,"btn_cancel")
    local btn_ok = uiUtil.getConvertChildByName(main_widget,"btn_ok")
    if m_opLayoutType == comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL then 
        btn_ok:setVisible(true)
        btn_ok:setTouchEnabled(true)
        btn_cancel:setVisible(true)
        btn_cancel:setTouchEnabled(true)
    elseif m_opLayoutType == comAlertConfirm.ALERT_TYPE_CONFIRM_ONLY then 
        btn_ok:setVisible(true)
        btn_ok:setTouchEnabled(true)
        btn_cancel:setVisible(false)
        btn_cancel:setTouchEnabled(false)
    elseif m_opLayoutType == comAlertConfirm.ALERT_TYPE_CANCEL_ONLY then 
        btn_ok:setVisible(false)
        btn_ok:setTouchEnabled(false)
        btn_cancel:setVisible(true)
        btn_cancel:setTouchEnabled(true)
    else
        btn_ok:setVisible(false)
        btn_ok:setTouchEnabled(false)
        btn_cancel:setVisible(false)
        btn_cancel:setTouchEnabled(false)
    end

end

function setBtnLayoutType(layoutType,closeBtnAble)
    m_opLayoutType = layoutType
    m_closeBtnAble = closeBtnAble
end

-- 确认按钮文本
function setConfirmBtnText()

end

-- 取消按钮文本
function setCancelBtnText()
    
end



--[[
@param title                ---> string
@param content              ---> string -- 正文富文本
@param content_arg          ---> table  -- 正文富文本参数
@param tipsTab              ---> {string,string ...} -- tips 富文本s （可以有多个）
@param tipsTabArgs          ---> {table,table,...}   -- tips 富文本s参数 （跟tipsTab 索引一一对应）
@param confirmCallBack      ---> function  -- 确认回调
@param cancelCallBack       ---> function  -- 取消回调
@param closeCallBack        ---> function  -- 关闭回调
]]

function show(title,content,content_arg,tipsTab,tipsTabArgs,confirmCallBack,cancelCallBack,closeCallBack)
    if main_layer or main_widget then 
        do_remove_self()
    end
    
    
    main_widget = GUIReader:shareReader():widgetFromJsonFile("test/com_alert_confirm.json")
    main_widget:setTouchEnabled(false)
    main_widget:setTag(999)
    main_widget:setAnchorPoint(cc.p(0.5,0.5))
    main_widget:setPosition(cc.p(config.getWinSize().width/2, config.getWinSize().height/2))
    main_widget:setScale(config.getgScale())

    main_layer = TouchGroup:create()
    main_layer:addWidget(main_widget)
    uiManager.add_panel_to_layer(main_layer, uiIndexDefine.COM_ALERT_CONFIRM,999)

    local img_mainBg = uiUtil.getConvertChildByName(main_widget,"img_mainBg")
    img_mainBg:setTouchEnabled(true)
    

    

    --- 取消按钮
    local btn_cancel = uiUtil.getConvertChildByName(main_widget,"btn_cancel")
    btn_cancel:setTouchEnabled(true)
    btn_cancel:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
            if cancelCallBack then 
                do_remove_self()
                cancelCallBack()
            else
                remove_self()
            end
            
        end
    end)

    -- 确认按钮
    local btn_ok = uiUtil.getConvertChildByName(main_widget,"btn_ok")
    btn_ok:setTouchEnabled(true)
    btn_ok:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
            if confirmCallBack then 
                do_remove_self()
                confirmCallBack()
            else
                remove_self()
            end
        end
    end)

    -- 关闭按钮
    local btn_close = uiUtil.getConvertChildByName(main_widget,"btn_close")
    btn_close:setTouchEnabled(true)
    btn_close:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            
            if closeCallBack then 
                do_remove_self()
                closeCallBack()
            else
                remove_self()
            end
        end
    end)

    -- 标题    
    setTitleText(title)
    -- 正文内容
    setContentText(content,content_arg)
    -- tips部分
    setTipsText(tipsTab,tipsTabArgs)

    -- 按钮
    if not m_opLayoutType then 
        setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL)
    end
    autoLayoutBtns()

    autoSizeLayout()
    uiManager.showConfigEffect(uiIndexDefine.COM_ALERT_CONFIRM,main_layer)
end




