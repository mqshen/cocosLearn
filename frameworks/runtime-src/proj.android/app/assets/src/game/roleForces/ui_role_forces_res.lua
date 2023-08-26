local UIRoleForcesRes = {}
local uiUtil = require("game/utils/ui_util")

local instance = nil

function UIRoleForcesRes.remove()
	if instance then 
		instance:removeFromParentAndCleanup(true)
		instance = nil
	end
end

function UIRoleForcesRes.updateData()
	UIRoleForcesRes.reloadData()
end

local function responeClick(indx)
	if not indx then return end
	local errorTableIndx = nil
	if indx == 1 then 
		alertLayer.create(errorTable[146])
	elseif indx == 2 then 
		alertLayer.create(errorTable[147])
	elseif indx == 3 then 
		alertLayer.create(errorTable[148])
	elseif indx == 4 then 
		alertLayer.create(errorTable[151])
	elseif indx == 5 then 
		alertLayer.create(errorTable[149])
	elseif indx == 6 then 
		alertLayer.create(errorTable[150])
	end
    
end
local function onClickBtns(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then 
		local indx = tonumber(string.sub(sender:getName(),5))
		responeClick(indx)
	end
end

local function onClickBtnsFlag(sender,eventType)
	if eventType == TOUCH_EVENT_ENDED then 
		local indx = tonumber(string.sub(sender:getName(),10))
		responeClick(indx)
	end
end

function UIRoleForcesRes.reloadData()
	if not instance then return end
	local selfCommonRes = politics.getSelfRes()
	local img_labels = uiUtil.getConvertChildByName(instance,"img_labels")
	local label_1 = nil
	local label_2 = nil
	local label_3 = nil
	local label_4 = nil
	local label_5 = nil
	local label_6 = nil
	-- 木材加成相关
	label_1 = uiUtil.getConvertChildByName(img_labels,"label_wood_1")
	label_2 = uiUtil.getConvertChildByName(img_labels,"label_wood_2")
	label_3 = uiUtil.getConvertChildByName(img_labels,"label_wood_3")
	label_4 = uiUtil.getConvertChildByName(img_labels,"label_wood_4")
	label_5 = uiUtil.getConvertChildByName(img_labels,"label_wood_5")
	label_6 = uiUtil.getConvertChildByName(img_labels,"label_wood_6")
	label_1:setText(selfCommonRes.wood_field_add)
	label_2:setText(selfCommonRes.wood_build_add + RES_ADD_INIT)
	label_3:setText(selfCommonRes.wood_union_add .. '%')
	label_4:setText(selfCommonRes.wood_npc_add)
	label_5:setText("--")
	label_6:setText(selfCommonRes.wood_add)

	-- 石材加成相关
	label_1 = uiUtil.getConvertChildByName(img_labels,"label_stone_1")
	label_2 = uiUtil.getConvertChildByName(img_labels,"label_stone_2")
	label_3 = uiUtil.getConvertChildByName(img_labels,"label_stone_3")
	label_4 = uiUtil.getConvertChildByName(img_labels,"label_stone_4")
	label_5 = uiUtil.getConvertChildByName(img_labels,"label_stone_5")
	label_6 = uiUtil.getConvertChildByName(img_labels,"label_stone_6")
	label_1:setText(selfCommonRes.stone_field_add)
	label_2:setText(selfCommonRes.stone_build_add + RES_ADD_INIT)
	label_3:setText(selfCommonRes.stone_union_add .. '%')
	label_4:setText(selfCommonRes.stone_npc_add)
	label_5:setText("--")
	label_6:setText(selfCommonRes.stone_add)

	-- 铁矿相关
	label_1 = uiUtil.getConvertChildByName(img_labels,"label_iron_1")
	label_2 = uiUtil.getConvertChildByName(img_labels,"label_iron_2")
	label_3 = uiUtil.getConvertChildByName(img_labels,"label_iron_3")
	label_4 = uiUtil.getConvertChildByName(img_labels,"label_iron_4")
	label_5 = uiUtil.getConvertChildByName(img_labels,"label_iron_5")
	label_6 = uiUtil.getConvertChildByName(img_labels,"label_iron_6")
	label_1:setText(selfCommonRes.iron_field_add)
	label_2:setText(selfCommonRes.iron_build_add + RES_ADD_INIT)
	label_3:setText(selfCommonRes.iron_union_add .. '%')
	label_4:setText(selfCommonRes.iron_npc_add)
	label_5:setText("--")
	label_6:setText(selfCommonRes.iron_add)

	--粮食相关
	label_1 = uiUtil.getConvertChildByName(img_labels,"label_food_1")
	label_2 = uiUtil.getConvertChildByName(img_labels,"label_food_2")
	label_3 = uiUtil.getConvertChildByName(img_labels,"label_food_3")
	label_4 = uiUtil.getConvertChildByName(img_labels,"label_food_4")
	label_5 = uiUtil.getConvertChildByName(img_labels,"label_food_5")
	label_6 = uiUtil.getConvertChildByName(img_labels,"label_food_6")
	label_1:setText(selfCommonRes.food_field_add)
	label_2:setText(selfCommonRes.food_build_add + RES_ADD_INIT)
	label_3:setText(selfCommonRes.food_union_add .. '%')
	label_4:setText(selfCommonRes.food_npc_add)
	label_5:setText(selfCommonRes.food_cost)
	label_6:setText(selfCommonRes.food_add - selfCommonRes.food_cost)

	local img_btns = uiUtil.getConvertChildByName(img_labels,"img_btns")
	local temp_btn = nil
	for i = 1,5 do 
		temp_btn = uiUtil.getConvertChildByName(img_btns,"btn_" .. i)
		temp_btn:setTouchEnabled(true)
		temp_btn:addTouchEventListener(onClickBtns)
	end

	-- for i = 1,5 do 
	-- 	temp_btn = uiUtil.getConvertChildByName(img_btns,"btn_flag_" .. i)
	-- 	temp_btn:setTouchEnabled(true)
	-- 	temp_btn:addTouchEventListener(onClickBtnsFlag)
	-- end

	local btn_tips = uiUtil.getConvertChildByName(instance,"btn_tips")
	btn_tips:setTouchEnabled(false)
	btn_tips:setVisible(false)
end

function UIRoleForcesRes.create(parent)
	if instance then return end
	instance = GUIReader:shareReader():widgetFromJsonFile("test/role_forces_res.json")
	-- instance:setScale(config.getgScale())
	parent:addChild(instance)

	
	UIRoleForcesRes.reloadData()
end

return UIRoleForcesRes
