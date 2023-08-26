--战报界面的cell
local att_color = ccc3(255,213,110)
local def_color = ccc3(255,213,110)

local win_color = ccc3(210,168,139)
local lose_color = ccc3(126,125,124)
local function create(widget, cell_idx, parentPanel)
	local battleReport = reportData.getReportDataByIndex(cell_idx)
    local battleData = reportData.getReportListDataByidx(cell_idx+1 )
    if not battleReport or not battleData then return end
    local panel = tolua.cast(widget:getChildByName("ImageView_24502_0_0_0"),"ImageView")
    panel:setVisible(true)

    local temp = tolua.cast(widget:getChildByName("ImageView_24502_0_0_0_0"),"ImageView")
    temp:setVisible(false)

	local attacked = tolua.cast(panel:getChildByName("ImageView_31664"), "ImageView")
	--胜负平
	local draw = tolua.cast(panel:getChildByName("ImageView_24964_0_0"), "ImageView")
	--对方姓名
	local name = tolua.cast(panel:getChildByName("Label_24542_0_0_0"), "Label")
    --守军
    local shoujun_str = tolua.cast(panel:getChildByName("Label_413697"), "Label")
    shoujun_str:setVisible(false)

	--对方联盟名字
	local unionName = tolua.cast(panel:getChildByName("Label_31665"), "Label")
    --攻击还是防守（文字）
    local attOrDefLabel = tolua.cast(panel:getChildByName("Label_143686"), "Label")
    --结果的底板
    local resultPanel = tolua.cast(panel:getChildByName("ImageView_143693"),"ImageView")
	--结果
	local result= tolua.cast(panel:getChildByName("Label_19204_0_0_1_0_0_0_0_0_0"), "Label")

    --对方是否有同盟
    local unionImage = tolua.cast(panel:getChildByName("ImageView_143691"), "ImageView")

    --显示未读连续战报
    local unreadPanel = tolua.cast(panel:getChildByName("ImageView_143701"),"ImageView")

    --pvp战报
    local pvpImage = tolua.cast(panel:getChildByName("ImageView_143690"),"ImageView")

    -- 我方部队的战后兵力
    local ownPanel = tolua.cast(panel:getChildByName("own_hero_panel"),"Layout")
    local player_army_count = tolua.cast(ownPanel:getChildByName("num_label"),"Label")

    -- 敌方部队的战后兵力
    local enemyPanel = tolua.cast(panel:getChildByName("unown_hero_panel"),"Layout")
    local enemy_army_count = tolua.cast(enemyPanel:getChildByName("un_num_label"),"Label")

    local function setIcon(targetPanel, heroid, level, hp, isSelf, isAttack )
        local temp_hp = hp
        targetPanel:removeAllChildrenWithCleanup(true)
        if heroid == 0 then 
            temp_hp = 0
            local image = ImageView:create()
            image:loadTexture("wubudui_zhanbaodiban.png",UI_TEX_TYPE_PLIST)
            -- image:setAnchorPoint(cc.p(0,0))
            targetPanel:addChild(image)
            image:setPosition(cc.p(targetPanel:getSize().width/2,targetPanel:getSize().height/2))
        else
            local cardWidget = cardFrameInterface.create_small_card(nil, heroid , false)
            -- cardFrameInterface.set_army_count(cardWidget, hp, nil)
            cardFrameInterface.set_lv_images(level,cardWidget)
            targetPanel:addChild(cardWidget)

            if isAttack then
                if battleReport.attack_advance then
                    cardFrameInterface.doSetAdvancedDetail(cardWidget, battleReport.attack_advance[2][1], Tb_cfg_hero[heroid].quality+1,battleReport.attack_advance[2][2] == 1)
                end
            else
                if battleReport.defend_advance then
                    cardFrameInterface.doSetAdvancedDetail(cardWidget, battleReport.defend_advance[2][1], Tb_cfg_hero[heroid].quality+1,battleReport.defend_advance[2][2] == 1)
                end
            end
        end

        if isSelf then
            player_army_count:setText(temp_hp)
        else
            enemy_army_count:setText(temp_hp)
        end
    end

    --连续战斗按钮
    local listBtn = tolua.cast(panel:getChildByName("Button_143692"),"Button")
    if #battleData.count > 0 then
        listBtn:setVisible(true)
        listBtn:setTouchEnabled(true)
        tolua.cast(listBtn:getChildByTag(1),"Label"):setText(#battleData.count)
        listBtn:addTouchEventListener(function (sender, eventType )
            if eventType == TOUCH_EVENT_ENDED then
                if parentPanel then
                    if reportUI.closeUI() then
                        return
                    end
                    
                    if not parentPanel:hitTest(reportUI.getXY()) then
                        return
                    end
                end
                reportUI.openListWar(cell_idx)
            end
        end)
        local temp_report = nil
        local count = 0
        unreadPanel:setVisible(false)
        for i,v in ipairs(battleData.count) do
            temp_report = reportData.getReport(v)
            if temp_report then
                if reportData.returnAttackOrDefend( temp_report) then
                    if temp_report.attack_read == 0 then
                        count = count + 1
                    end
                else
                    if temp_report.defend_read == 0 then
                        count = count + 1
                    end
                end
            end
        end
        if count > 0 then
            unreadPanel:setVisible(true)
            tolua.cast(unreadPanel:getChildByTag(1),"Label"):setText(count)
        end
    else
        listBtn:setVisible(false)
        listBtn:setTouchEnabled(false)
        unreadPanel:setVisible(false)
    end

    if (reportData.returnAttackOrDefend( battleReport) and string.len(battleReport.defend_name) > 0)
        or not reportData.returnAttackOrDefend( battleReport) then
        pvpImage:loadTexture("pkvs.png",UI_TEX_TYPE_PLIST)
    else
        pvpImage:loadTexture("vs_y.png",UI_TEX_TYPE_PLIST)
    end

	-- result:setVisible(false)
    if reportData.returnAttackOrDefend( battleReport) then
        setIcon(tolua.cast(panel:getChildByName("Panel_143698"),"Layout"),battleReport.attack_base_heroid,
                            battleReport.attack_base_level, battleReport.attack_hp, true, true )
        setIcon(tolua.cast(panel:getChildByName("Panel_143699"),"Layout"),battleReport.defend_base_heroid,
                            battleReport.defend_base_level, battleReport.defend_hp,false, false )

        --已读
        if battleReport.attack_read == 1 then
            panel:loadTexture(ResDefineUtil.not_reading_frame_y_0,UI_TEX_TYPE_PLIST)
        else
            panel:loadTexture(ResDefineUtil.not_reading_frame_y,UI_TEX_TYPE_PLIST)
        end
    	--攻方
        if battleReport.result == REPORT_RESULT.WIN_NO_RESULT
            or battleReport.result == REPORT_RESULT.FALSE 
            or battleReport.result == REPORT_RESULT.PINGJU 
            or battleReport.result == REPORT_RESULT.ALLDIE
            or battleReport.result == REPORT_RESULT.DRAWfAIL
            or battleReport.result == REPORT_RESULT.NOWAR then
            result:setText(" ")
            resultPanel:setVisible(false)
        else
            result:setText(REPORT_STR[battleReport.result])
            result:setColor(win_color)
            resultPanel:setVisible(true)
            resultPanel:loadTexture(ResDefineUtil.Victory_affiliated_Shading_Language,UI_TEX_TYPE_PLIST)
        end
        attOrDefLabel:setText(languagePack["gongji"])
        attOrDefLabel:setColor(att_color)
        attacked:loadTexture(ResDefineUtil.They_attack_Icon_i, UI_TEX_TYPE_PLIST)
        if battleReport.result == REPORT_RESULT.FALSE then
    	    draw:loadTexture(ResDefineUtil.Failure_text_Icon, UI_TEX_TYPE_PLIST)
    	--平局
    	elseif battleReport.result == REPORT_RESULT.PINGJU or battleReport.result == REPORT_RESULT.DRAWfAIL then
    		draw:loadTexture(ResDefineUtil.Draw_text_Icon, UI_TEX_TYPE_PLIST)
        --同归于尽
        elseif battleReport.result == REPORT_RESULT.ALLDIE then
            draw:loadTexture(ResDefineUtil.Perish_together_text_Icon, UI_TEX_TYPE_PLIST)
        --未战
        elseif battleReport.result == REPORT_RESULT.NOWAR then
            draw:loadTexture(ResDefineUtil.Without_a_fight_n, UI_TEX_TYPE_PLIST)
    	--胜利
    	else
    		draw:loadTexture(ResDefineUtil.Victory_text_Icon, UI_TEX_TYPE_PLIST)
    	end

        --是npc部队
        if battleReport.npc ~= 0 then
            if string.len(battleReport.defend_name) >0 then
                name:setText(battleReport.defend_name)
                shoujun_str:setVisible(true)
                shoujun_str:setPositionX(name:getPositionX()+name:getSize().width + 15)
            else
                name:setText(languagePack["shoujun"])
            end

            if string.len(battleReport.defend_union_name) >0 then
                
                unionName:setText(battleReport.defend_union_name)
                unionImage:setVisible(true)
            else
                unionName:setText(" ")
                unionImage:setVisible(false)
            end
        else
            if string.len(battleReport.defend_name) >0 then
                name:setText(battleReport.defend_name)
            else
                name:setText(" ")
            end

            if string.len(battleReport.defend_union_name) > 0 then
                unionName:setText(battleReport.defend_union_name)
                unionImage:setVisible(true)
            else
                unionName:setText(" ")
                unionImage:setVisible(false)
            end
        end
    else
        setIcon(tolua.cast(panel:getChildByName("Panel_143698"),"Layout"),battleReport.defend_base_heroid,
                                battleReport.defend_base_level, battleReport.defend_hp, true, false )
        setIcon(tolua.cast(panel:getChildByName("Panel_143699"),"Layout"),battleReport.attack_base_heroid,
                                battleReport.attack_base_level, battleReport.attack_hp, false, true )
        --已读
        if battleReport.defend_read == 1 then
            panel:loadTexture(ResDefineUtil.not_reading_frame_y_0,UI_TEX_TYPE_PLIST)
        else
            panel:loadTexture(ResDefineUtil.not_reading_frame_y,UI_TEX_TYPE_PLIST)
        end

    	--守方
        if battleReport.result == REPORT_RESULT.WIN_NO_RESULT
            or battleReport.result == REPORT_RESULT.FALSE 
            or battleReport.result == REPORT_RESULT.PINGJU 
            or battleReport.result == REPORT_RESULT.ALLDIE then
            result:setText(" ")
            resultPanel:setVisible(false)
        else
            result:setText(REPORT_DEF_STR[battleReport.result])
            resultPanel:setVisible(true)
            result:setColor(lose_color)
            resultPanel:loadTexture(ResDefineUtil.small_box_body_soleplate,UI_TEX_TYPE_PLIST)
        end
        attOrDefLabel:setText(languagePack["fangshou"])
        attOrDefLabel:setColor(def_color)
        attacked:loadTexture(ResDefineUtil.They_defend_Icon_i, UI_TEX_TYPE_PLIST)
        --失败
        if battleReport.result == REPORT_RESULT.FALSE then
    		draw:loadTexture(ResDefineUtil.Victory_text_Icon, UI_TEX_TYPE_PLIST)
    	--平局
    	elseif battleReport.result == REPORT_RESULT.PINGJU or battleReport.result == REPORT_RESULT.DRAWfAIL then
    		draw:loadTexture(ResDefineUtil.Draw_text_Icon, UI_TEX_TYPE_PLIST)
        --同归于尽
        elseif battleReport.result == REPORT_RESULT.ALLDIE then
            draw:loadTexture(ResDefineUtil.Perish_together_text_Icon, UI_TEX_TYPE_PLIST)
        --未战
        elseif battleReport.result == REPORT_RESULT.NOWAR then
            draw:setVisible(false)
    	--胜利
    	else
    		draw:loadTexture(ResDefineUtil.Failure_text_Icon, UI_TEX_TYPE_PLIST)
    	end
        if string.len(battleReport.attack_name)>0 then
            name:setText(battleReport.attack_name)
        else
            name:setText(" ")
        end

        if string.len(battleReport.attack_union_name)>0 then
            unionName:setText(battleReport.attack_union_name)
            unionImage:setVisible(true)
        else
            unionName:setText(" ")
            unionImage:setVisible(false)
        end
    end

    --cityname 
    local cityname = tolua.cast(panel:getChildByName("Label_23598_2_0_0_0_0"), "Label")
    local temp_name = battleReport.wid_name
    if not battleReport.wid_name or battleReport.wid_name == "" then
        temp_name = landData.get_city_name_when_happened(battleReport.wid)
    end
    --坐标
    -- local location = tolua.cast(UIHelper:seekWidgetByName(widget,"Label_38362"), "Label")
    local x, y = math.floor(battleReport.wid/10000), battleReport.wid%10000
    if reportData.getReportType() and reportData.getReportType() == 4 then
        cityname:setText(temp_name)
    else
        cityname:setText(temp_name.."("..x..","..y..")")
    end
    --时间
    local beginTime = tolua.cast(panel:getChildByName("Label_24505_0_0_0"), "Label")
    beginTime:setText(os.date("%Y-%m-%d %X", battleReport.time))
end

ReportCell = {
				create = create
}