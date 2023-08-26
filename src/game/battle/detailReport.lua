local mLayer = nil
local mWidget = nil
local widget = nil
local reportStrData = nil
-- local m_cellHeight = nil
local cell_offset = 5
local fontSize = 20
local fontHeight = 27
local imageTable = nil
local m_backPanel = nil
local ground_level = nil
local m_scrollViewLayer = nil

local function getInstance( )
    return mLayer
end
local uiUtil = require("game/utils/ui_util")

-- 只删除界面，不删除数据
local function remove_self_only( )
    if mLayer then
        if m_backPanel then
            m_backPanel:remove()
            m_backPanel = nil
        end

        mLayer:removeAllChildrenWithCleanup(true)
    end
end

local function do_remove_self( )
    if mLayer then
        reportInfo.remove()
        BattleAnimation.removeAnimationName()
        if m_backPanel then
            m_backPanel:remove()
            m_backPanel = nil
        end

        if ground_level then
            require("game/guide/shareGuide/picTipsManager")
            if ground_level ==3 then
                reportUI.addUnForceGuide()
            elseif ground_level == 4 then
                picTipsManager.create(18)
            elseif ground_level == 5 then
                -- reportUI.addUnForceGuide()
                picTipsManager.create(19)
            end
            CCUserDefault:sharedUserDefault():setStringForKey("fail_ground_"..ground_level, 1)
        end
        mLayer:removeFromParentAndCleanup(true)
        mLayer = nil
        scrollView1 = nil
        ground_level = nil
        m_scrollViewLayer = nil
        mWidget = nil
        widget = nil
        reportStrData = nil
        -- m_cellHeight = nil
        imageTable = nil
        --reportUI.setVisible(true)
        BattlaAnimationData.clearBattleData()
        -- BattleAnalyse.remove()
        uiManager.remove_self_panel(uiIndexDefine.DETAIL_REPORT)
    end
end

local function remove_self()
    if not m_backPanel then
        do_remove_self()
        return
    end
    uiManager.hideConfigEffect(uiIndexDefine.DETAIL_REPORT,mLayer,do_remove_self,999,{m_backPanel:getMainWidget()})
    -- uiUtil.hideScaleEffect(m_backPanel:getMainWidget(),do_remove_self,uiUtil.DURATION_FULL_SCREEN_HIDE)
end
local function dealwithTouchEvent(x, y )
    if not mLayer then
        return false
    end

    -- if mWidget:hitTest(cc.p(x,y)) then
        return false
    -- else
    --     remove_self()
    --     return true
    -- end
end

local function initHeroInfo( battleData )
    if not battleData then return end
    local armyInfo = BattlaAnimationData.getArmyInfo()

    local att_armyAfterCount = 0
    local def_armyAfterCount = 0
    local att_armyCount = 0
    local def_armyCount = 0
    for i, v in ipairs(armyInfo) do
        if i<=4 then
            att_armyAfterCount = att_armyAfterCount + v.armyAfter
            att_armyCount = att_armyCount + v.army
        else
            def_armyAfterCount = def_armyAfterCount + v.armyAfter
            def_armyCount = def_armyCount + v.army
        end
    end

    local panel_left = tolua.cast(widget:getChildByName("Panel_left"),"Layout")
    local panel_right = tolua.cast(widget:getChildByName("Panel_right"),"Layout")
    --左边总兵力
    local player_army = tolua.cast(widget:getChildByName("army_total_count_left"),"Label")
    -- 左边剩余兵力
    local player_army_left = tolua.cast(widget:getChildByName("army_left_1"),"Label")
    --右边玩家总兵力
    local enemy_army = tolua.cast(widget:getChildByName("army_total_right"),"Label")
    -- 右边玩家剩余兵力
    local enemy_army_left = tolua.cast(widget:getChildByName("left_army_2"),"Label")

    local mineLoadingBar = tolua.cast(panel_left:getChildByName("LoadingBar_28061_0"),"LoadingBar")
    local otherLoadingBar = tolua.cast(panel_right:getChildByName("LoadingBar_28061"),"LoadingBar")

    -- 左边玩家剩余兵力左边的亮光
    local leftLight = tolua.cast(panel_left:getChildByName("ImageView_810129_0"),"ImageView")
    -- 右边玩家剩余兵力右边的亮光
    local rightLight = tolua.cast(panel_right:getChildByName("ImageView_810129_0_0"),"ImageView")

    if reportData.returnAttackOrDefend( battleData) then 
        mineLoadingBar:setPercent(att_armyAfterCount*100/att_armyCount)
        leftLight:setPositionX(panel_left:getSize().width-mineLoadingBar:getSize().width*mineLoadingBar:getPercent()*0.01-5)


        otherLoadingBar:setPercent(def_armyAfterCount*100/def_armyCount)
        rightLight:setPositionX(otherLoadingBar:getSize().width*otherLoadingBar:getPercent()*0.01+5)

        player_army:setText("/"..att_armyCount)
        player_army_left:setText(att_armyAfterCount)
        player_army_left:setPositionX(player_army:getPositionX()-player_army:getSize().width)

        enemy_army_left:setText(def_armyAfterCount)
        enemy_army:setText("/"..def_armyCount)
        enemy_army:setPositionX(enemy_army_left:getPositionX()+enemy_army_left:getSize().width)

        -- if att_armyCount == 0 or att_armyAfterCount == 0 then
        --     mineLoadingBar:setVisible(false)
        -- end

        -- if def_armyCount ==0 or def_armyAfterCount == 0 then
        --     otherLoadingBar:setVisible(false)
        -- end
    else
        mineLoadingBar:setPercent(def_armyAfterCount*100/def_armyCount)
        leftLight:setPositionX(panel_left:getSize().width-mineLoadingBar:getSize().width*mineLoadingBar:getPercent()*0.01-5)
        
        otherLoadingBar:setPercent(att_armyAfterCount*100/att_armyCount)
        rightLight:setPositionX(otherLoadingBar:getSize().width*otherLoadingBar:getPercent()*0.01+5)

        player_army:setText("/"..def_armyCount)
        player_army_left:setText(def_armyAfterCount)
        player_army_left:setPositionX(player_army:getPositionX()-player_army:getSize().width)

        enemy_army:setText("/"..att_armyCount)
        enemy_army_left:setText(att_armyAfterCount)
        enemy_army:setPositionX(enemy_army_left:getPositionX()+enemy_army_left:getSize().width)

        -- if def_armyCount == 0 or def_armyAfterCount == 0 then
        --     mineLoadingBar:setVisible(false)
        -- end

        -- if att_armyCount == 0 or att_armyAfterCount == 0 then
        --     otherLoadingBar:setVisible(false)
        -- end
    end

    local function createHeroCard(panelName,i )
        local layout = tolua.cast(UIHelper:seekWidgetByName(widget,panelName),"Layout")
        local cardWidget = nil
        if i==1 or i==8 then
            cardWidget = cardFrameInterface.create_small_card(nil,armyInfo[i].heroid , false)
            tolua.cast(cardWidget:getChildByName("level_label"),"Label"):setText("Lv."..armyInfo[i].levelAfter)
        
            if armyInfo[i].level ~= armyInfo[i].levelAfter then
                tolua.cast(cardWidget:getChildByName("level_label"),"Label"):setColor(ccc3(255,0,0))
            end
        else
            cardWidget = cardFrameInterface.create_middle_card_special(nil,armyInfo[i].heroid , false)
            cardFrameInterface.set_army_count(cardWidget, armyInfo[i].armyAfter, armyInfo[i].wounded_soldier)
            cardFrameInterface.set_lv_images(armyInfo[i].levelAfter,cardWidget)
            if i <= 4 then 
                if battleData.attack_advance then
                    cardFrameInterface.doSetAdvancedDetail(cardWidget, battleData.attack_advance[i][1], Tb_cfg_hero[armyInfo[i].heroid].quality+1,battleData.attack_advance[i][2] == 1)
                end
            else
                if battleData.defend_advance then
                    cardFrameInterface.doSetAdvancedDetail(cardWidget, battleData.defend_advance[i-4][1], Tb_cfg_hero[armyInfo[i].heroid].quality+1,battleData.defend_advance[i-4][2] == 1)
                end
            end
        end
        
        layout:addChild(cardWidget,1,1)

        if armyInfo[i].isDead then
            GraySprite.create(cardWidget,{"armyleft_label"})--,armyInfo[i].level ~= armyInfo[i].levelAfter)
        end
    end
    
    local temp = {4,3,2}
    local temp1 = {5,6,7}
    --军师
    local count = 0
    local heroIndex = {}
    local heroIndex1 = {}
    if not reportData.returnAttackOrDefend( battleData) then
        if armyInfo[1].heroid~= 0 then
            createHeroCard("Panel_1",1)
        end

        if armyInfo[8].heroid~= 0 then
            createHeroCard("Panel_8",8)
        end
        heroIndex = {4,3,2}
        heroIndex1 = {5,6,7}
    else
        if armyInfo[8].heroid~= 0 then
            createHeroCard("Panel_1",8)
        end

        if armyInfo[1].heroid~= 0 then
            createHeroCard("Panel_8",1)
        end
        heroIndex = {5,6,7}
        heroIndex1 = {4,3,2}
    end
        
    for i,v in ipairs(heroIndex) do
        if armyInfo[v].heroid ~= 0 then
            count = count + 1
            createHeroCard("Panel_"..temp[count],v)
        end
    end
    count = 0
    for i,v in ipairs(heroIndex1) do
        if armyInfo[v].heroid ~= 0 then
            count = count + 1
            createHeroCard("Panel_"..temp1[count],v)
        end
    end
end

local function addImageAndText(str)
    local layer = GUIReader:shareReader():widgetFromJsonFile("test/imageAndLine.json")
    local temp_panel = tolua.cast(layer:getChildByName("Panel_263758"),"Layout")
    temp_panel:setVisible(false)
    local image = tolua.cast(layer:getChildByName("ImageView_263757"),"ImageView")
    image:setVisible(false)

    if str ~= "-1" then
        temp_panel:setVisible(true)
        tolua.cast(layer:getChildByName("Label_90237"),"Label"):setText(str)
    else
        image:setVisible(true)
        tolua.cast(layer:getChildByName("Label_90237"),"Label"):setText(" ")
    end
    return layer
end

local function create( detail,battle_id, topInfo)
    BattleAnalyse.setBeforePlay()
    BattleAnalyse.analyseAnimation()
    BattleAnalyse.remove()
    local battleReport = reportData.getReport(battle_id)
    if not battleReport then
        return false
    end

    if widget then return false end

	scrollView1 = CCScrollView:create()
    
    widget = GUIReader:shareReader():widgetFromJsonFile("test/Report_items_0.json")
    -- local winColor = ccc3(255,217,90)
    -- local loseColor = ccc3(255,255,255)
    local logoWin = tolua.cast(widget:getChildByName("ImageView_30382"), "ImageView")
    local logoLose = tolua.cast(widget:getChildByName("ImageView_30381"), "ImageView")
    --对方队伍的战斗结果图片
    -- local result_Enemy = tolua.cast(widget:getChildByName("ImageView_30381"),"ImageView")
    --自己队伍的战斗结果的图片
    local result_mine = tolua.cast(widget:getChildByName("ImageView_30382"),"ImageView")
    --自己队伍防守还是攻击
    local mine_logo = tolua.cast(widget:getChildByName("ImageView_28066"),"ImageView")
    --敌人队伍防守还是攻击
    local other_logo = tolua.cast(widget:getChildByName("ImageView_28065"),"ImageView")

    --玩家同盟
    local player_union = tolua.cast(widget:getChildByName("Label_23598_2_0_1_0_0_0"),"Label")
    --玩家名字
    local player_name = tolua.cast(widget:getChildByName("Label_23598_2_0_1_0_0"),"Label")
    --玩家名字背景
    local player_name_img = uiUtil.getConvertChildByName(widget,"img_defName")

    --对方同盟
    local enemy_union = tolua.cast(widget:getChildByName("Label_28064"),"Label")
    --对方名字
    local enemy_name = tolua.cast(widget:getChildByName("Label_28063"),"Label")
    --对方名字背景
    local enemy_name_img = uiUtil.getConvertChildByName(widget,"img_attName")

    --玩家是否有同盟
    local player_union_image = tolua.cast(widget:getChildByName("temp_image_union_left_0"),"ImageView")

    --对方玩家是否有同盟
    local enemy_union_image = tolua.cast(widget:getChildByName("temp_image_union_right_0"),"ImageView")

    -- 0:失败 1:胜利没有结果, 2：成功占领, 3:同盟占领, 4:成功附属 , 5:成功解救,6平局7同归于尽 8平局但是输了" 
   
    local att_result_mine_str = ResDefineUtil.ui_batle_detail_report_1
    
    
    local def_result_Enemy_str = ResDefineUtil.ui_batle_detail_report_2

    local att_name = nil
    local att_union = nil
    local def_name = nil
    local def_union = nil
    local att_color = nil
    local def_color = nil

    local att_union_image = nil
    local def_union_image = nil

    local att_uid = nil
    local def_uid = nil

    local img_defName = nil
    local img_attName = nil

    -- local 
    if reportData.returnAttackOrDefend( battleReport) then 
        mine_logo:loadTexture(ResDefineUtil.ui_battle_report[1], UI_TEX_TYPE_PLIST)
        result_mine:loadTexture(att_result_mine_str[battleReport.result+1], UI_TEX_TYPE_PLIST)

        other_logo:loadTexture(ResDefineUtil.ui_battle_report[2],UI_TEX_TYPE_PLIST)
        -- result_Enemy:loadTexture(def_result_Enemy_str[battleReport.result+1], UI_TEX_TYPE_PLIST)
        att_name = player_name
        att_union = player_union

        def_name = enemy_name
        def_union = enemy_union

        att_union_image = player_union_image

        def_union_image = enemy_union_image

        att_uid = battleReport.attack_userid
        def_uid = battleReport.defend_userid

        img_defName = enemy_name_img
        img_attName = player_name_img
        -- if battleReport.result+1 >=2 and battleReport.result+1 <=6 then
        --     att_color = winColor
        --     def_color = loseColor
        -- else
        --     att_color = loseColor
        --     def_color = winColor
        -- end
    else
        mine_logo:loadTexture(ResDefineUtil.ui_battle_report[2], UI_TEX_TYPE_PLIST)
        result_mine:loadTexture(def_result_Enemy_str[battleReport.result+1], UI_TEX_TYPE_PLIST)

        other_logo:loadTexture(ResDefineUtil.ui_battle_report[1],UI_TEX_TYPE_PLIST)
        -- result_Enemy:loadTexture(att_result_mine_str[battleReport.result+1], UI_TEX_TYPE_PLIST)

        att_name = enemy_name
        att_union = enemy_union
        def_name = player_name
        def_union = player_union

        att_union_image = enemy_union_image

        def_union_image = player_union_image

        att_uid = battleReport.defend_userid
        def_uid = battleReport.attack_userid
        img_defName = player_name_img
        img_attName = enemy_name_img
        -- if battleReport.result+1 <=1 or battleReport.result+1 >=7 then
        --     att_color = loseColor
        --     def_color = winColor
        -- else
        --     att_color = winColor
        --     def_color = loseColor
        -- end
    end

    -- if battleReport.npc == 0 then
        if string.len(battleReport.attack_name) >0 then
            att_name:setText(battleReport.attack_name)
        else
            att_name:setText(" ")
        end

        if string.len(battleReport.attack_union_name) > 0 then
            att_union:setText(battleReport.attack_union_name)
        else
            att_union:setText(" ")
            att_union_image:setVisible(false)
        end
    -- else
    --     att_name:setText(languagePack["shoujun"])
    --     att_union:setText(languagePack["wu"])
    -- end

    img_attName:setTouchEnabled(true)
    img_attName:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if att_uid and att_uid ~= 0 then 
                UIRoleForcesMain.create(att_uid)
            end
        end
    end)

    
    if battleReport.npc == 0 then
        if string.len(battleReport.defend_name) >0 then
            def_name:setText(battleReport.defend_name)
        else
            def_name:setText(" ")
        end

        if string.len(battleReport.defend_union_name) >0 then
            def_union:setText(battleReport.defend_union_name)
        else
            def_union:setText(" ")
            def_union_image:setVisible(false)
        end
    else
        def_union:setText(" ")
        def_union_image:setVisible(false)
        def_name:setText(languagePack["shoujun"])
    end
    
    img_defName:setTouchEnabled(true)
    img_defName:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            -- UIRoleForcesMain.create(attId)
            if def_uid and def_uid ~= 0 then 
                UIRoleForcesMain.create(def_uid)
            end
        end
    end)

    -- att_name:setColor(att_color)
    -- att_union:setColor(att_color)
    -- def_name:setColor(def_color)
    -- def_union:setColor(def_color)
    
    initHeroInfo( battleReport )

    mLayer = TouchGroup:create()
    mWidget = GUIReader:shareReader():widgetFromJsonFile("test/Report_items.json")
    mWidget:setTag(999)
    m_backPanel = UIBackPanel.new()
    local temp = m_backPanel:create(mWidget, remove_self, panelPropInfo[uiIndexDefine.DETAIL_REPORT][2],false,true)
    mLayer:addWidget(temp)
    
    local back = tolua.cast(mWidget:getChildByName("ImageView_23592_0_0_2_0"),"ImageView")
    local panel_temp = tolua.cast(mWidget:getChildByName("Panel_416090"),"Layout")
    local arrow = tolua.cast(mWidget:getChildByName("ImageView_28077"),"ImageView" )
    local backimage = tolua.cast(panel_temp:getChildByName("ImageView_263744"),"ImageView" )
    UIListViewSize.definedUIpanel(mWidget ,back,panel_temp, arrow)
    backimage:setAnchorPoint(cc.p(1,1))
    backimage:setPosition(cc.p(panel_temp:getSize().width, panel_temp:getSize().height))

    local str = nil
    reportStrData = {}

    local function readReport(string,iaction)
        str = config.richText_split(string, {"#","@","^","~","$"})
        table.insert(reportStrData,{str,iaction})
        -- m_cellHeight = m_cellHeight + cell + cell_offset
    end

    for i, v in ipairs(topInfo) do
        readReport(v[1],v[2])
    end

    
    -- m_cellHeight = m_cellHeight + fontHeight + cell_offset
    local btn = Button:create()
    btn:setTitleText(languagePack["luxiang"])
    btn:loadTextureNormal(ResDefineUtil.ui_battle_report[3], UI_TEX_TYPE_PLIST)
    btn:loadTexturePressed(ResDefineUtil.ui_battle_report[4], UI_TEX_TYPE_PLIST)
    btn:setTitleColor(ccc3(83,18,0))
    btn:setTitleFontSize(22)
    btn:setVisible(true)
    btn:setTouchEnabled(true)
    btn:addTouchEventListener(function (sender,eventType )
        if eventType == 2 then
            if not BattlaAnimationData.isNoBattleReport() then
                -- BattlaAnimationUI.create()
                    -- LSound.setVolume(10)
                -- tipsLayer.create("敬请期待")
                -- if BattleAnalyse.getFirst() then
                    newGuideInfo.enter_next_guide()
                    BattleAnimationController.create()

                    if not userData.isNewBieTaskFinished() then
                        detailReport.remove_self_only()
                        reportUI.remove_self_only()
                    end
                -- else
                    -- BattleAnalyse.analyseAnimation()
                -- end
            else
                
            end
        end
    end)
    widget:addChild(btn)
    btn:setPosition(cc.p(widget:getContentSize().width- btn:getContentSize().width, -btn:getContentSize().height/2- cell_offset ))

    --显示录像按钮
    imageTable = {}
    table.insert(reportStrData,{{111},-1})
    table.insert(imageTable, {"-1", 0})

    for i, v in ipairs(detail) do
        if actionDefine.beforeWar == v[2] or actionDefine.roundIndex == v[2] then
            table.insert(reportStrData,{{111},v[2]})
            table.insert(imageTable, {v[1], 0})
        else
            -- if actionDefine.win == v[2] or actionDefine.lose == v[2] 
            -- or actionDefine.draw == v[2] or actionDefine.allDead == v[2]
            -- or actionDefine.drawNoRest == v[2] then
            if v[2] == 13 then
                table.insert(reportStrData,{{111},-1})
                table.insert(imageTable, {warRoundKeyword[13][1], 0})
            else
                readReport(v[1],v[2] )
            end
        end
    end

    local height = widget:getContentSize().height
    m_scrollViewLayer = TouchGroup:create()
    m_scrollViewLayer:setContentSize(CCSize(mWidget:getSize().width, height))
    m_scrollViewLayer:addWidget(widget)
    widget:setZOrder(3)
    widget:setAnchorPoint(cc.p(0,1))
    widget:setPosition(cc.p(0,height))

    -- local panel = tolua.cast(UIHelper:seekWidgetByName(mWidget,"ImageView_23592_0_0_2_0"),"ImageView")
    
    local function scrollViewDidScroll( )
        if scrollView1:getContentOffset().y < 0 then
            tolua.cast(mWidget:getChildByName("ImageView_28077"),"ImageView" ):setVisible(true)
        else
            tolua.cast(mWidget:getChildByName("ImageView_28077"),"ImageView" ):setVisible(false)
        end

        if scrollView1:getContentSize().height + scrollView1:getContentOffset().y > 1+scrollView1:getViewSize().height then
            tolua.cast(mWidget:getChildByName("ImageView_372343"),"ImageView" ):setVisible(true)
        else
            tolua.cast(mWidget:getChildByName("ImageView_372343"),"ImageView" ):setVisible(false)
        end
    end
    local ImageView_up = tolua.cast(mWidget:getChildByName("ImageView_28077"),"ImageView" )
    ImageView_up:setVisible(false)
    local ImageView_down = tolua.cast(mWidget:getChildByName("ImageView_372343"),"ImageView" )
    ImageView_down:setVisible(false)

    breathAnimUtil.start_anim(ImageView_down, true, 76, 255, 1, 0)
    breathAnimUtil.start_anim(ImageView_up, true, 76, 255, 1, 0)

    if nil ~= scrollView1 then
        scrollView1:registerScriptHandler(scrollViewDidScroll,CCScrollView.kScrollViewScroll)
        scrollView1:setViewSize(CCSizeMake(mWidget:getSize().width,panel_temp:getSize().height))
        scrollView1:setContainer(m_scrollViewLayer)
        scrollView1:updateInset()
        scrollView1:setDirection(kCCScrollViewDirectionVertical)
        scrollView1:setClippingToBounds(true)
        scrollView1:setBounceable(false)
        if newGuideManager.get_guide_state() then
            scrollView1:setTouchEnabled(false)
        end
        --if not newGuideManager.get_guide_state() then
            scrollView1:setContentOffset(cc.p(0,-height+scrollView1:getViewSize().height))
        --end
    end
    mWidget:addChild(scrollView1)
    scrollView1:setPositionY(arrow:getPositionY())

    uiManager.add_panel_to_layer(mLayer, uiIndexDefine.DETAIL_REPORT)
    uiManager.showConfigEffect(uiIndexDefine.DETAIL_REPORT,mLayer,nil,999,{m_backPanel:getMainWidget()})

    -- 为了做非强制引导引入的
    local temp_level = nil
    local _ = nil
    if not battleReport.wid_name or battleReport.wid_name == "" then
        _,temp_level = landData.get_city_name_when_happened(battleReport.wid)
        if temp_level and temp_level >=3 and temp_level <=5 and battleReport.result == 0 and reportData.returnAttackOrDefend( battleReport)
            and battleReport.npc ~= 0 then
            local isExsit = CCUserDefault:sharedUserDefault():getStringForKey("fail_ground_"..temp_level)
            if isExsit and string.len(isExsit) == 0 then
                ground_level = temp_level
            end
        end
    end

    return true
end

local function initUI(detail )
    if not mLayer then return end
    -- local _height = widget:getSize().height

    local _richText = RichText:create()
    _richText:setVerticalSpace(cell_offset)
    _richText:setAnchorPoint(cc.p(0,1))
    _richText:ignoreContentAdaptWithSize(false)
    _richText:setSize(CCSizeMake(1005, 100))
    -- layer:addChild(_richText)
    _richText:setPosition(cc.p(1087/2-1005/2, 100))
    local re = nil
    local count = 0

    for i, v in ipairs(reportStrData) do

        for m,n in ipairs(v[1]) do
            if v[2] == -1 or actionDefine.beforeWar == v[2] or actionDefine.roundIndex == v[2] then
                count = count + 1
                if imageTable[count] then
                    local node = addImageAndText(imageTable[count][1])
                    re = RichElementCustomNode:create(1, ccc3(255,255,255), 255, node)
                    _richText:pushBackElement(re)
                    re = RichElementText:create(1, ccc3(255,255,255), 255, "\n",config.getFontName(), fontSize)
                    _richText:pushBackElement(re)
                end
            else
                if m == #v[1] then
                    n[2] = n[2].."\n"
                end
                --平常的字
                if n[1] == 1 then
                    re = RichElementText:create(1, ccc3(255,255,255), 255, n[2],config.getFontName(), fontSize)
                --数字
                elseif n[1] == 2 then
                    re = RichElementText:create(1, ccc3(219,173,100), 255, n[2],config.getFontName(), fontSize)
                --我方武将 ^
                elseif n[1] == 3 then
                    re = RichElementText:create(1, ccc3(125,187,139), 255, n[2],config.getFontName(), fontSize)
                --敌方武将 ~
                elseif n[1] == 4 then
                    re = RichElementText:create(1, ccc3(229,60,67), 255, n[2],config.getFontName(), fontSize)
                elseif n[1] == 5 then
                    --攻
                    if n[2] == "-1" then
                        re = RichElementImage:create(1, ccc3(0,0,0), 255, ResDefineUtil.ui_battle_animation_1[2])
                    --守
                    elseif n[2] == "-2" then
                        re = RichElementImage:create(1, ccc3(0,0,0), 255, ResDefineUtil.ui_battle_animation_3[1])
                    elseif n[2] == "-3" then
                        re = RichElementImage:create(1, ccc3(0,0,0), 255, ResDefineUtil.ui_battle_animation_1[1])
                    elseif n[2] == "-4" then
                        re = RichElementImage:create(1, ccc3(0,0,0), 255, ResDefineUtil.ui_battle_animation_3[2])
                    else
                        re = RichElementImage:create(1, ccc3(0,0,0), 255, itemTextureName[tonumber(n[2])])
                    end
                end
                _richText:pushBackElement(re)
            end
        end
    end
    _richText:formatText()
    local realHeight = _richText:getRealHeight()
    m_scrollViewLayer:setContentSize(CCSize(m_scrollViewLayer:getContentSize().width, m_scrollViewLayer:getContentSize().height+realHeight))
    --[[
    if newGuideManager.get_guide_state() then
        scrollView1:setContentOffset(cc.p(0,-m_scrollViewLayer:getContentSize().height+scrollView1:getViewSize().height + 375))
    else
        scrollView1:setContentOffset(cc.p(0,-m_scrollViewLayer:getContentSize().height+scrollView1:getViewSize().height))
    end
    --]]
    scrollView1:setContentOffset(cc.p(0,-m_scrollViewLayer:getContentSize().height+scrollView1:getViewSize().height))
    
    local layer = cc.LayerColor:create(cc.c4b(9,14,28,0),1087, 100)
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(cc.p(0,1))
    widget:getParent():addChild(layer)
    layer:setPosition(cc.p(0, 0))
    layer:addChild(_richText)
    layer:setContentSize(CCSize(m_scrollViewLayer:getContentSize().width, realHeight))
    layer:setPositionY(realHeight)

    widget:setPositionY(m_scrollViewLayer:getContentSize().height)

    _richText:setPositionY(realHeight)
end

local function setVisible( flag )
    -- if mLayer then
    --     mLayer:setVisible(flag)
    -- end
end

local function get_guide_widget(temp_guide_id)
    if not mLayer then
        return nil
    end

    return mWidget
end

detailReport = {
					create = create,
                    remove_self = remove_self,
                    setVisible = setVisible,
                    dealwithTouchEvent = dealwithTouchEvent,
                    get_guide_widget = get_guide_widget,
                    initUI = initUI,
                    getInstance = getInstance,
                    remove_self_only = remove_self_only,
                    do_remove_self = do_remove_self,
}