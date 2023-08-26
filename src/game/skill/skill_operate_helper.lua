local skillOperateHelper = {}

local skillDetailHelper = require("game/skill/skill_detail_helper")
local SkillOpreateObserver = require("game/skill/skill_operate_observer")


-- 技巧值不足
function skillOperateHelper.notEnoughResSkillValue(errorTipsId,afterConfirm, afterCloseTransfer)
    --TODOTK 提示配置
    local callback = function()
        if afterConfirm then 
            afterConfirm()
        end
        
        require("game/skill/skill_operate")
        SkillOperate.create(SkillOperate.OP_TYPE_TRANSFER,function()
            if afterCloseTransfer then 
                afterCloseTransfer()
            end
        end)
    end
    
    alertLayer.create(errorTable[errorTipsId],nil,callback)
    comAlertConfirm.setBtnTitleText(languagePack['goto_transferSkillValue'],languagePack['cancel'])
end

-- 卡牌遗忘技能
function skillOperateHelper.heroDeleteSkill(heroUid,skillId,skillLv,callbackT)
    if not skillId then return end
    if not heroUid then return end
    local heroInfo = heroData.getHeroInfo(heroUid) 
    if not heroInfo then return end

    local basicHeroInfo = Tb_cfg_hero[heroInfo.heroid]
    local cfgSkillInfo = Tb_cfg_skill[skillId]

    local indx = cfgSkillInfo.skill_quality*100 + skillLv
    local skillVaueReturn = -1
    if Tb_cfg_skill_level[indx] then 
        skillVaueReturn = Tb_cfg_skill_level[indx].total_exp 
    end
    skillVaueReturn = skillVaueReturn * SKILL_VALUE_RETURN_RATIO / 100
    skillVaueReturn = math.floor(skillVaueReturn)
    --TODOTK 提示配置
    local callback = function()
        if skillVaueReturn + SkillDataModel.getUserSkillValue() > SKILL_VALUE_MAX then 
            local callback = function()
                callbackT()
                SkillOpreateObserver.requestHeroDeleteSkill(heroUid,skillId)
            end
            local title = "遗忘战法"
            local content = "本次遗忘所得战法经验将会大于可拥有上限，大于部分将不返回。"
            comAlertConfirm.setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL)
            comAlertConfirm.show(title,content,nil,nil,nil,callback)

        else
            callbackT()
            SkillOpreateObserver.requestHeroDeleteSkill(heroUid,skillId)
        end
    end

    local title = "遗忘战法"
    local content = "#确认将#@&@#的战法#@&@#遗忘吗？#"
    local contentArg = {basicHeroInfo.name,cfgSkillInfo.name,skillVaueReturn}
    local tips = {"遗忘此战法后，会返回战法经验" .. skillVaueReturn .. "，并返回此战法1次学习数"}
    comAlertConfirm.setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL)
    comAlertConfirm.show(title,content,contentArg,tips,nil,callback)
end


-- 技能库移除技能
function skillOperateHelper.deleteSkill(skillId,callbackT)
    if not skillId then return end
    local skillInfo = SkillDataModel.getUserSkillInfoById(skillId)
    if not skillInfo then return end

    if skillInfo.own_type == SkillDataModel.OWN_TYPE_IMMUTABLE then 
        --TODOTK 提示配置
        tipsLayer.create("系统预设战法不能移除")
        return 
    end

    if #skillInfo.hero_list_learned >0 then 
        --TODOTK 提示配置
        tipsLayer.create("该战法已被武将学习，不能移除")
        return 
    end

    --TODOTK 提示配置
    local callback = function()
        callbackT()
        SkillOpreateObserver.requestDeleteSkill(skillId)
    end
    local title = "确定移除战法"
    local content = "战法移除后将不能学习和研究"
    comAlertConfirm.setBtnLayoutType(comAlertConfirm.ALERT_TYPE_CONFIRM_AND_CANCEL)
    comAlertConfirm.show(languagePack["queren"],content,nil,nil,nil,callback)

end


----- 技能提升研究度 预测效果
function skillOperateHelper.effectPreAddingSkillStudyProgress(mainWidget,addValue,skillItemProgressBg,skillId,tmpLeft)
    if not mainWidget then return end
    if not addValue then return end
    if addValue == 0 then return end

    local panel_main_3 = uiUtil.getConvertChildByName(mainWidget,"panel_main_3")

    local label_add = uiUtil.getConvertChildByName(panel_main_3,"label_add")
    label_add:setText(addValue .. "%")

    if addValue > 0 then 
        label_add:setColor(ccc3(0,255,0))
    else
        label_add:setColor(ccc3(255,0,0))
    end
    local label_add_clone = label_add:clone()
    label_add_clone:setVisible(true)
    label_add:getParent():addChild(label_add_clone)
    label_add_clone:setZOrder(100)
    label_add_clone:setPosition(cc.p(188,-91))
    -- local action1 = cc.DelayTime:create(0.1 * k)
    local action2 = CCMoveBy:create(1 ,ccp(0, 50*1*config.getgScale()))
    local action3 = cc.CallFunc:create(function ( )
        -- do something
        label_add_clone:removeFromParentAndCleanup(true)
    end)
    label_add_clone:runAction(animation.sequence({action2, action3}))



    if not skillItemProgressBg then return end
    local skillItemHelper = require("game/skill/skill_item_helper")
    local curProgress,maxProgress = SkillDataModel.getSkillStudyProgressInfo(skillId)
    local tmpCurProgress = maxProgress - tmpLeft
    skillItemHelper.effectSutdyProgressCalculate(skillItemProgressBg,skillId,tmpCurProgress,addValue)
end

-- 技巧值转换的飘字效果
-- addValueList = {{值,是否暴击}}
function skillOperateHelper.floatEffectAddingSkillValue(mainWidget,addValueList)
    if not mainWidget then return end
    local panel_main_1 = uiUtil.getConvertChildByName(mainWidget,"panel_main_1")
    local panel_op_1 = uiUtil.getConvertChildByName(mainWidget,"panel_op_1")

    local label_add = uiUtil.getConvertChildByName(panel_main_1,"label_add")
    local ori_str = label_add:getStringValue()
    for k,v in ipairs(addValueList) do 
        if v[1] > 0 then 
            label_add:setColor(ccc3(0,255,0))
            label_add:setText("+" .. v[1])
        else
            label_add:setColor(ccc3(168,76,78))
            label_add:setText(v[1])
        end
        local effect_label = label_add:clone()
        effect_label:setVisible(true)
        label_add:getParent():addChild(effect_label)

        -- local action1 = cc.DelayTime:create(0.1 * k)
        local action2 = CCMoveBy:create(0.3 + k * 0.1,ccp(0, 50*1*config.getgScale()))
        local action3 = cc.CallFunc:create(function ( )
            -- do something
            effect_label:removeFromParentAndCleanup(true)
        end)
        effect_label:runAction(animation.sequence({action2, action3}))
    end
    label_add:setText(ori_str)
    label_add:setColor(ccc3(100,166,219))
end

--转换技巧值
function skillOperateHelper.updateTransferSkillValue(mainWidget,heroUidList)
    if not mainWidget then return end

    local panel_main_1 = uiUtil.getConvertChildByName(mainWidget,"panel_main_1")
    local panel_op_1 = uiUtil.getConvertChildByName(mainWidget,"panel_op_1")

    local label_own = uiUtil.getConvertChildByName(panel_main_1,"label_own")
    local label_add = uiUtil.getConvertChildByName(panel_main_1,"label_add")
    label_own:setText(SkillDataModel.getUserSkillValue())
    label_add:setVisible(false)
    
    local btn_op_coin = uiUtil.getConvertChildByName(panel_op_1,"btn_op_coin")
    local btn_op_gold = uiUtil.getConvertChildByName(panel_op_1,"btn_op_gold")
    local img_flag_gold = uiUtil.getConvertChildByName(panel_op_1,"img_flag_gold")
    local img_flag_coin = uiUtil.getConvertChildByName(panel_op_1,"img_flag_coin")

    btn_op_coin:setTouchEnabled(false)
    btn_op_gold:setTouchEnabled(false)
    btn_op_coin:setBright(false)
    btn_op_gold:setBright(false)
    GraySprite.create(img_flag_gold)
    GraySprite.create(img_flag_coin)

    local label_coin = uiUtil.getConvertChildByName(panel_op_1,"label_coin")
    label_coin:setText(0)
    label_coin:setColor(ccc3(40,40,40))
    local label_title_coin = uiUtil.getConvertChildByName(panel_op_1,"label_title_coin")
    label_title_coin:setColor(ccc3(40,40,40))
    local label_gold = uiUtil.getConvertChildByName(panel_op_1,"label_gold")
    label_gold:setText(0)
    label_gold:setColor(ccc3(40,40,40))
    local label_title_gold = uiUtil.getConvertChildByName(panel_op_1,"label_title_gold")
    label_title_gold:setColor(ccc3(40,40,40))

    if not heroUidList  or #heroUidList == 0 then return end
    
    label_add:setVisible(true)
    local add_value = 0
    for k,v in ipairs(heroUidList) do 
        add_value = add_value + SkillDataModel.getSkillValueTurnedFromHeroCard(v)
    end
    label_add:setText("+" .. add_value)

    local cost_coin = SKILL_VALUE_TRANSFORM_MONEY * #heroUidList
    local cost_gold = SKILL_VALUE_TRANSFORM_YUANBAO * #heroUidList
    label_coin:setText(cost_coin)
    label_gold:setText(cost_gold)
    local yuanbao_nums = userData.getYuanbao()
    local money_nums = userData.getUserCoin()
    
    btn_op_gold:setTouchEnabled(true)
    btn_op_coin:setTouchEnabled(true)
    
    
    
    if cost_coin <= money_nums then 
        btn_op_coin:setBright(true)
        GraySprite.create(img_flag_coin,nil,true)

        label_title_coin:setColor(ccc3(83,18,0))
        label_coin:setColor(ccc3(83,18,0))
    end

    if cost_gold <= yuanbao_nums then 
        btn_op_gold:setBright(true)
        GraySprite.create(img_flag_gold,nil,true)
        label_title_gold:setColor(ccc3(83,18,0))
        label_gold:setColor(ccc3(83,18,0))
    end


    

    btn_op_coin:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            

            local function do_confirm()
                if money_nums < cost_coin then 
                    tipsLayer.create(languagePack["res_not_enough_coin"])
                    return 
                end
                SkillOpreateObserver.requestTranserlateSkillValue(heroUidList,5)
            end
            if (not CCUserDefault:sharedUserDefault():getBoolForKey("first_transfer_skill_value_confirm") ) then 
                alertLayer.create(errorTable[2026],{},do_confirm)
                CCUserDefault:sharedUserDefault():setBoolForKey("first_transfer_skill_value_confirm",true)
            else
                do_confirm()
            end

        end
    end)

    btn_op_gold:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            local function do_confirm()
                if yuanbao_nums < cost_gold then 
                    tipsLayer.create(languagePack["res_not_enough_gold"])
                    return 
                end
                SkillOpreateObserver.requestTranserlateSkillValue(heroUidList,99)
            end
            if (not CCUserDefault:sharedUserDefault():getBoolForKey("first_transfer_skill_value_confirm") ) then 
                alertLayer.create(errorTable[2026],{},do_confirm)
                CCUserDefault:sharedUserDefault():setBoolForKey("first_transfer_skill_value_confirm",true)
            else
                do_confirm()
            end
        end
    end)
end

-- 武将卡进阶
function skillOperateHelper.updateAdvanceHeroView(mainWidget,targetCardId,mainCardId)
    if not mainWidget then return end

    local panel_op_4 = uiUtil.getConvertChildByName(mainWidget,"panel_op_4")
    local btn_op = uiUtil.getConvertChildByName(panel_op_4,"btn_op")
    local btn_flag = uiUtil.getConvertChildByName(panel_op_4,"btn_flag")
    btn_op:setTouchEnabled(true)
    btn_op:setBright(false)
    btn_flag:setBright(false)

    local panel_main_4 = uiUtil.getConvertChildByName(mainWidget,"panel_main_4")
    local label_num = uiUtil.getConvertChildByName(panel_main_4,"label_num")
    label_num:setText("0/1")

    btn_op:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if not mainCardId or mainCardId == 0 then
                --TODOTK 中文收集
                tipsLayer.create("#请放入素材卡#")
                return 
            end
            SkillOpreateObserver.requestHeroAdvance(targetCardId,mainCardId)
            SkillOperate.remove_self()
        end
    end)

    if mainCardId == 0 then mainCardId = nil end
    if not targetCardId or not mainCardId then return end


    label_num:setText("1/1")
    btn_op:setBright(true)
    btn_flag:setBright(true)
end

-- 武将卡觉醒
function skillOperateHelper.updateAwakeSkillView(mainWidget,targetCardId,mainCardId,secondCardId)
    if not mainWidget then return end
    local panel_main_5 = uiUtil.getConvertChildByName(mainWidget,"panel_main_5")
    local label_num = uiUtil.getConvertChildByName(panel_main_5,"label_num")
    local panel_op_5 = uiUtil.getConvertChildByName(mainWidget,"panel_op_5")
    local btn_op = uiUtil.getConvertChildByName(panel_op_5,"btn_op")
    local btn_flag = uiUtil.getConvertChildByName(panel_op_5,"btn_flag")
    btn_op:setTouchEnabled(true)
    btn_op:setBright(false)
    btn_flag:setBright(false)
    local heroInfo = heroData.getHeroInfo(targetCardId)
    local cfgHeroInfo = Tb_cfg_hero[heroInfo.heroid]

    local countNeed = cfgHeroInfo.awake_cost[4][1]  

    local count = 0
    if mainCardId and mainCardId ~=0  then 
        count = count + 1
    end

    if secondCardId and secondCardId ~=0 then 
        count = count + 1
    end

    label_num:setText(count .. "/" .. countNeed)

    if count == countNeed then 
        btn_op:setBright(true)
        btn_flag:setBright(true)
    end
end


-- 研究新技能 视图（上半部分）
function skillOperateHelper.updateSutdySkillView(mainWidget,mainCardId)
	if not mainWidget then return end

	local panel_main_2 = uiUtil.getConvertChildByName(mainWidget,"panel_main_2")
	local panel_op_2 = uiUtil.getConvertChildByName(mainWidget,"panel_op_2")
	local panel_intro_1 = uiUtil.getConvertChildByName(mainWidget,"panel_intro_1")
    local panel_skill_detail = uiUtil.getConvertChildByName(mainWidget,"panel_skill_detail")

    local panel_container = uiUtil.getConvertChildByName(panel_main_2,"panel_container")
    panel_container:setBackGroundColorType(LAYOUT_COLOR_NONE)

    local btn_op_ji = uiUtil.getConvertChildByName(panel_op_2,"btn_op_ji")
    local label_num_ji = uiUtil.getConvertChildByName(panel_op_2,"label_num_ji")
    local label_title_ji = uiUtil.getConvertChildByName(panel_op_2,"label_title_ji")
    local img_flag_ji = uiUtil.getConvertChildByName(panel_op_2,"img_flag_ji")
    label_num_ji:setText(0)
    label_num_ji:setColor(ccc3(40,40,40))
    label_title_ji:setColor(ccc3(40,40,40))
    GraySprite.create(img_flag_ji)
    local initBtnState = false
    if not mainCardId or mainCardId == 0 then 
    	panel_intro_1:setVisible(true)
    	panel_skill_detail:setVisible(false)
        initBtnState = false
    else
    	panel_intro_1:setVisible(false)
    	panel_skill_detail:setVisible(true)
        initBtnState = true
    end

    local btn_skill = nil
    for i = 1,3 do 
        btn_skill = uiUtil.getConvertChildByName(panel_main_2,"btn_skill_" .. i)
        btn_skill:setTouchEnabled(initBtnState)
        btn_skill:setVisible(initBtnState)
    end

    btn_op_ji:setTouchEnabled(true)
    btn_op_ji:setBright(false)
    panel_skill_detail:setBackGroundColorType(LAYOUT_COLOR_NONE)

    local selected_skill_id = nil
    btn_op_ji:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
            if not selected_skill_id then 
                tipsLayer.create("请放入素材卡")
                return
            end
            if SkillDataModel.isSkillOwned( selected_skill_id ) then 
                --TODOTK 提示配置
                tipsLayer.create("此战法已研究")
                return
            end

            local function do_confirm()
                if SkillDataModel.getStudyNewSkillCost(mainCardId) > SkillDataModel.getUserSkillValue() then 
                    skillOperateHelper.notEnoughResSkillValue(2017,
                        function()
                            SkillOperate.remove_self(true)
                        end)
                else
                    SkillOperate.remove_self(true)
                    SkillOpreateObserver.requestStudyNewSkill(mainCardId,selected_skill_id)            
                end
            end
            
            if (not CCUserDefault:sharedUserDefault():getBoolForKey("first_study_new_skill_confirm") ) then 
                local heroInfo = heroData.getHeroInfo(mainCardId)
                local cfgHeroInfo = Tb_cfg_hero[heroInfo.heroid]
                alertLayer.create(errorTable[2020],{cfgHeroInfo.name},do_confirm)
                CCUserDefault:sharedUserDefault():setBoolForKey("first_study_new_skill_confirm",true)
            else
                do_confirm()
            end
        end
    end)
    
    if not mainCardId or mainCardId == 0 then return end

    

    btn_op_ji:setTouchEnabled(true)
    btn_op_ji:setBright(true)
    
    local heroInfo = heroData.getHeroInfo(mainCardId)
    local cfgHeroInfo = Tb_cfg_hero[heroInfo.heroid]
    local cfgSkillLearnInfo = Tb_cfg_skill_learn[cfgHeroInfo.skill_init]
    local skillDetailWidget = skillDetailHelper.getSkillDetailWidget(panel_skill_detail)
    local cfgSkillInfo = nil



    local function resetSkillBtnState(indxSelected)
        for i = 1,3 do 
            btn_skill = uiUtil.getConvertChildByName(panel_main_2,"btn_skill_" .. i)
            if i == indxSelected then 
                btn_skill:setBright(false)
            else
                btn_skill:setBright(true)
            end
        end
        selected_skill_id = cfgSkillLearnInfo.learn[indxSelected]
        skillDetailHelper.updateInfo(panel_skill_detail,cfgSkillLearnInfo.learn[indxSelected],1,3)
        local cost = SkillDataModel.getStudyNewSkillCost(mainCardId)
        label_num_ji:setText(cost)
        
        if SkillDataModel.isSkillOwned( selected_skill_id ) then
            -- 战法已拆解
            label_num_ji:setColor(ccc3(40,40,40))
            label_title_ji:setColor(ccc3(40,40,40))
            GraySprite.create(img_flag_ji)
            btn_op_ji:setBright(false)
        elseif cost > SkillDataModel.getUserSkillValue()  then 
            -- 技巧值不足
            label_num_ji:setColor(ccc3(202,75,75))
            label_title_ji:setColor(ccc3(83,18,0))
            GraySprite.create(img_flag_ji,nil,true)
            btn_op_ji:setBright(true)
        else
            label_num_ji:setColor(ccc3(83,18,0))
            label_title_ji:setColor(ccc3(83,18,0))
            GraySprite.create(img_flag_ji,nil,true)
            btn_op_ji:setBright(true)
        end   
    end

    local img_flag = nil
    local indx_default = nil
    if initBtnState then 
        for i = 1,3 do 
            btn_skill = uiUtil.getConvertChildByName(panel_main_2,"btn_skill_" .. i)
            if cfgSkillLearnInfo.learn[i] then 
                
                btn_skill:setTitleText(Tb_cfg_skill[cfgSkillLearnInfo.learn[i]].name)
                btn_skill:addTouchEventListener(function(sender,eventType)
                    if eventType == TOUCH_EVENT_ENDED then 
                        resetSkillBtnState(i)
                    end
                end)
                img_flag = uiUtil.getConvertChildByName(btn_skill,"img_flag")
                if SkillDataModel.isSkillOwned( cfgSkillLearnInfo.learn[i] ) then 
                    img_flag:setVisible(true)
                else
                    if not indx_default then 
                        indx_default = i
                    end
                    img_flag:setVisible(false)
                end
            else
                btn_skill:setVisible(false)
                btn_skill:setTouchEnabled(false)
            end
        end
    end
    
    if not indx_default then indx_default = 1 end
    resetSkillBtnState(indx_default)

    
end

-- 技能研究度提升
function skillOperateHelper.updateStudySkillProgressView(mainWidget,heroUidList,skillId)
    if not mainWidget then return end
    local cfgSkillInfo = Tb_cfg_skill[skillId]
    local skillInfo = SkillDataModel.getUserSkillInfoById(skillId)
    
    local panel_main_3 = uiUtil.getConvertChildByName(mainWidget,"panel_main_3")
    local panel_op_3 = uiUtil.getConvertChildByName(mainWidget,"panel_op_3")

    local label_add = uiUtil.getConvertChildByName(panel_main_3,"label_add")
    label_add:setVisible(false)

    -- -- 可研究数
    -- local label_num = uiUtil.getConvertChildByName(panel_main_3,"label_num")
    -- label_num:setText(skillInfo.study_count_retain)
    -- 技能名字
    local label_sk_name = uiUtil.getConvertChildByName(panel_main_3,"label_sk_name")
    label_sk_name:setText(cfgSkillInfo.name)

    -- 进度加成预估
    local label_progress = uiUtil.getConvertChildByName(panel_op_3 ,"label_progress")
    label_progress:setText("0%")

    local btn_op = uiUtil.getConvertChildByName(panel_op_3,"btn_op")
    btn_op:setTouchEnabled(false)
    btn_op:setBright(false)

    -- local btn_tips = uiUtil.getConvertChildByName(panel_op_3,"btn_tips")
    -- btn_tips:setTouchEnabled(false)

    if not heroUidList or #heroUidList == 0 then return end


    
    btn_op:setTouchEnabled(true)
    btn_op:setBright(true)
    btn_op:addTouchEventListener(function(sender,eventType)
        if eventType == TOUCH_EVENT_ENDED then 
			local function finally()
				SkillOpreateObserver.requestImproveSkillStudyValue(heroUidList,skillId)
			end
			if (not CCUserDefault:sharedUserDefault():getBoolForKey("clicked_study_skill_progress") ) then 
				CCUserDefault:sharedUserDefault():setBoolForKey("clicked_study_skill_progress",true)
				alertLayer.create(errorTable[2041],nil,finally)
			else
				finally()
			end
        end
    end)

    --预估进度
    local add_value = 0
    local total_value = 0
    local heroInfo = nil
    for k,v in ipairs(heroUidList) do 
        heroInfo = heroData.getHeroInfo(v)
        if heroInfo then 
            add_value = SkillDataModel.getStudyProgressValueByCard(skillId,heroInfo.heroid,heroInfo.advance_num) or 0
            total_value = total_value + add_value
        end
    end
    label_progress:setText(total_value .. "%")
    
end

return skillOperateHelper
